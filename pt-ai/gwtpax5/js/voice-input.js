/*
 * AI 상담5 음성 입력 (CLOVA Speech 단문 인식, 2026-10-22)
 * - 입력창마다 전송 버튼 앞에 마이크 버튼을 넣는다 (서버 설정 SttEnabled=Y 이고 키가 있을 때만).
 * - 누르면 녹음 → 소리를 16kHz·모노·16bit PCM 으로 바꿔 모아 둔다.
 * - 다시 누르거나 최대 시간(기본 20초)이 되면 모은 PCM 을 한 번에 서버(sttRecognize.do)로 보낸다.
 *   서버가 WAV 로 감싸 CLOVA 단문 인식에 넘기고, 인식된 문장을 입력창에 넣는다. 전송은 사용자가 확인한 뒤 직접 누른다.
 * - 녹음 중 전송 버튼·Enter 는 녹음 끝내기로 바꾸고, Esc 는 취소(입력창 원래대로)다.
 * - 마이크(getUserMedia)는 https 또는 localhost 에서만 브라우저가 허용한다.
 * 2026-10-22: 처음엔 실시간 스트리밍(조각 전송)이었으나 키가 단문 인식 도메인이라 녹음 후 한 번에 보내는 방식으로 바꿨다.
 */
(function () {
  "use strict";

  var BOOT = window.PT_AI_BOOT || {};
  var API = String(BOOT.apiBase || "").replace(/\/+$/, "");
  var TARGET_RATE = 16000;
  var MIN_MS = 500; // 이보다 짧게 누르고 끝내면 인식하지 않는다
  var STATUS_HIDE_MS = 4000;
  // 녹음 중 버튼 반응 (2026-10-22): 말소리 크기(100Hz 아래 웅웅거림은 뺀 RMS, dB)를 0~1 로 바꿔 버튼의 --kp-voice-level 로 넣는다
  var LEVEL_HIGHPASS_HZ = 100;
  var LEVEL_MIN_DB = -55; // 이 아래면 0 (조용한 방의 잡음)
  var LEVEL_MAX_DB = -18; // 이 위면 1 (가까이서 크게 말할 때)
  var HEARING_ON = 0.12; // 이 위로 올라가면 is-hearing (소리가 들어오는 중)
  var HEARING_OFF = 0.05; // 이 아래로 내려가면 is-hearing 해제 (깜빡임 방지로 두 값을 다르게)

  var MIC_SVG =
    '<svg class="kp-svg kp-svg--20 kp-voice-btn__mic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
    '<rect x="9" y="3" width="6" height="11" rx="3"></rect><path d="M5 11a7 7 0 0 0 14 0M12 18v3"></path></svg>' +
    '<svg class="kp-svg kp-svg--20 kp-voice-btn__stop" viewBox="0 0 24 24" aria-hidden="true"><rect x="7" y="7" width="10" height="10" rx="1.5" fill="currentColor"></rect></svg>' +
    '<svg class="kp-svg kp-svg--20 kp-voice-btn__wait" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 3a9 9 0 1 0 9 9"></path></svg>';

  var maxSec = 20;
  var current = null; // 진행 중인 녹음 1건

  function api(path, opts) {
    var o = opts || {};
    o.credentials = "same-origin";
    o.cache = "no-store";
    return fetch(API + path, o).then(function (res) {
      return res.json().catch(function () { return {}; }).then(function (body) {
        if (!res.ok) {
          var err = new Error(body.error || "http " + res.status);
          err.status = res.status;
          throw err;
        }
        return body;
      });
    });
  }

  function errorMessage(err) {
    if (err && err.name === "NotAllowedError") return "마이크 사용이 허용되지 않았어요. 브라우저 주소창에서 마이크 권한을 허용해 주세요.";
    if (err && err.name === "NotFoundError") return "마이크를 찾지 못했어요. 연결을 확인해 주세요.";
    if (err && err.status === 429) return "지금 음성 인식 요청이 많아요. 잠시 후 다시 시도해 주세요.";
    if (err && err.status === 413) return "녹음이 너무 길어요. 짧게 다시 말씀해 주세요.";
    if (err && err.status === 503) return "음성 입력을 지금 쓸 수 없어요.";
    return "음성을 인식하지 못했어요. 잠시 후 다시 시도해 주세요.";
  }

  /* ---------- 소리 → 16kHz PCM ---------- */

  /** 입력 표본률 → 16kHz. 구간 평균으로 줄여 높은 소리가 섞이는 것(앨리어싱)을 줄인다 */
  function Downsampler(inRate) {
    this.ratio = inRate / TARGET_RATE;
    this.need = this.ratio;
    this.acc = 0;
    this.n = 0;
  }

  Downsampler.prototype.push = function (input, out) {
    for (var i = 0; i < input.length; i++) {
      this.acc += input[i];
      this.n++;
      if (this.n >= this.need) {
        var s = this.acc / this.n;
        s = s < -1 ? -1 : s > 1 ? 1 : s;
        out.push(s < 0 ? s * 0x8000 : s * 0x7fff);
        this.need = this.ratio + (this.need - this.n);
        this.acc = 0;
        this.n = 0;
      }
    }
  };

  /** 정수 샘플 → 바이트 (16bit little-endian) */
  function toPcm(samples) {
    var buf = new ArrayBuffer(samples.length * 2);
    var view = new DataView(buf);
    for (var i = 0; i < samples.length; i++) view.setInt16(i * 2, samples[i], true);
    return buf;
  }

  /* ---------- 화면 ---------- */

  function setStatus(composer, text, isError, autoHide) {
    var el = composer.querySelector(".kp-voice-status");
    if (!el) return;
    clearTimeout(el._hideTimer);
    if (!text) {
      el.hidden = true;
      return;
    }
    el.textContent = text;
    el.classList.toggle("is-error", !!isError);
    el.hidden = false;
    if (autoHide) {
      el._hideTimer = setTimeout(function () { el.hidden = true; }, STATUS_HIDE_MS);
    }
  }

  function setButton(btn, phase) {
    btn.classList.toggle("is-recording", phase === "recording");
    btn.classList.toggle("is-waiting", phase === "starting" || phase === "recognizing");
    var label = phase === "recording" ? "음성 입력 끝내기" : phase ? "음성 인식 중" : "음성으로 입력";
    btn.setAttribute("aria-label", label);
    btn.title = label;
    btn.setAttribute("aria-pressed", phase === "recording" ? "true" : "false");
  }

  /** 입력창 값 바꾸기. input 이벤트를 내야 ai-consult.js 가 높이·전송 버튼 상태를 갱신한다 */
  function setInput(input, value) {
    input.value = value;
    input.dispatchEvent(new Event("input", { bubbles: true }));
    input.scrollTop = input.scrollHeight;
  }

  function fmt(sec) {
    return "0:" + (sec < 10 ? "0" : "") + sec;
  }

  /* ---------- 녹음 1건 ---------- */

  function start(composer, btn, input) {
    if (current || input.disabled) return;
    if (!window.isSecureContext || !navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      setStatus(composer, "마이크는 https 주소(또는 localhost)에서만 쓸 수 있어요.", true, true);
      return;
    }
    var rec = {
      composer: composer,
      btn: btn,
      input: input,
      phase: "starting",
      original: input.value,
      samples: [],
      startedAt: 0,
      cancelled: false
    };
    current = rec;
    setButton(btn, "starting");
    setStatus(composer, "마이크를 준비하고 있어요…");

    navigator.mediaDevices.getUserMedia({ audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true } })
      .then(function (stream) {
        rec.stream = stream;
        if (rec.cancelled) {
          releaseAudio(rec); // 취소 뒤에 마이크가 열렸으면 바로 닫는다
          return;
        }
        beginCapture(rec);
      })
      .catch(function (err) {
        if (!rec.cancelled) end(rec, errorMessage(err), true);
      });
  }

  function beginCapture(rec) {
    var Ctx = window.AudioContext || window.webkitAudioContext;
    var ctx = new Ctx();
    var source = ctx.createMediaStreamSource(rec.stream);
    // ScriptProcessorNode: AudioWorklet 보다 오래됐지만 별도 모듈 파일 없이 모든 브라우저에서 동작한다
    var proc = ctx.createScriptProcessor(4096, 1, 1);
    var down = new Downsampler(ctx.sampleRate);
    proc.onaudioprocess = function (e) {
      if (rec.phase === "recording") down.push(e.inputBuffer.getChannelData(0), rec.samples);
    };
    source.connect(proc);
    proc.connect(ctx.destination); // 연결해야 onaudioprocess 가 불린다 (출력은 무음)
    // 버튼 반응용 (인식에 보내는 소리와는 별개 갈래)
    var highpass = ctx.createBiquadFilter();
    highpass.type = "highpass";
    highpass.frequency.value = LEVEL_HIGHPASS_HZ;
    var analyser = ctx.createAnalyser();
    analyser.fftSize = 1024;
    source.connect(highpass);
    highpass.connect(analyser);
    rec.ctx = ctx;
    rec.source = source;
    rec.proc = proc;
    rec.highpass = highpass;
    rec.analyser = analyser;
    if (ctx.state === "suspended" && ctx.resume) ctx.resume();

    rec.phase = "recording";
    rec.startedAt = Date.now();
    rec.input.readOnly = true;
    setButton(rec.btn, "recording");
    tick(rec);
    rec.timer = setInterval(function () { tick(rec); }, 250);
    meter(rec);
  }

  /** 녹음 중 화면 프레임마다 말소리 세기를 재 버튼에 넣는다 (올라갈 땐 바로, 내려갈 땐 천천히) */
  function meter(rec) {
    var analyser = rec.analyser;
    var wave = new Float32Array(analyser.fftSize);
    var level = 0;
    var hearing = false;
    var frame = function () {
      if (rec.phase !== "recording") return;
      analyser.getFloatTimeDomainData(wave);
      var sum = 0;
      for (var i = 0; i < wave.length; i++) sum += wave[i] * wave[i];
      var db = 10 * Math.log10(sum / wave.length + 1e-10);
      var now = Math.min(1, Math.max(0, (db - LEVEL_MIN_DB) / (LEVEL_MAX_DB - LEVEL_MIN_DB)));
      level = now > level ? now : level * 0.85 + now * 0.15;
      rec.btn.style.setProperty("--kp-voice-level", level.toFixed(3));
      if (!hearing && level > HEARING_ON) hearing = true;
      else if (hearing && level < HEARING_OFF) hearing = false;
      rec.btn.classList.toggle("is-hearing", hearing);
      rec.raf = requestAnimationFrame(frame);
    };
    rec.raf = requestAnimationFrame(frame);
  }

  function tick(rec) {
    var sec = Math.min(maxSec, Math.floor((Date.now() - rec.startedAt) / 1000));
    setStatus(rec.composer, "듣고 있어요 " + fmt(sec) + " / " + fmt(maxSec) + " · 다시 누르면 끝나요");
    if (Date.now() - rec.startedAt >= maxSec * 1000) stop(rec);
  }

  function releaseAudio(rec) {
    clearInterval(rec.timer);
    if (rec.raf) cancelAnimationFrame(rec.raf);
    rec.btn.classList.remove("is-hearing");
    rec.btn.style.removeProperty("--kp-voice-level");
    if (rec.highpass) { try { rec.highpass.disconnect(); } catch (e) {} }
    if (rec.analyser) { try { rec.analyser.disconnect(); } catch (e) {} }
    if (rec.proc) { rec.proc.onaudioprocess = null; try { rec.proc.disconnect(); } catch (e) {} }
    if (rec.source) { try { rec.source.disconnect(); } catch (e) {} }
    if (rec.ctx && rec.ctx.close) rec.ctx.close().catch(function () {});
    if (rec.stream) rec.stream.getTracks().forEach(function (t) { t.stop(); });
  }

  /** 녹음 끝 → 모은 소리를 한 번에 보내 인식 */
  function stop(rec) {
    if (rec.phase !== "recording") return;
    rec.phase = "recognizing";
    releaseAudio(rec);
    if (Date.now() - rec.startedAt < MIN_MS || !rec.samples.length) {
      end(rec, "너무 짧아요. 버튼을 누르고 말씀한 뒤 다시 눌러 주세요.", true);
      return;
    }
    var body = toPcm(rec.samples);
    rec.samples = [];
    setButton(rec.btn, "recognizing");
    setStatus(rec.composer, "말씀하신 내용을 인식하고 있어요…");
    api("/sttRecognize.do", {
      method: "POST",
      headers: { "Content-Type": "application/octet-stream" },
      body: body
    })
      .then(function (res) {
        if (rec.cancelled) return;
        var text = String(res.text || "").trim();
        if (!text) {
          end(rec, "말씀을 알아듣지 못했어요. 다시 말씀해 주세요.", true);
          return;
        }
        var before = rec.original.trim() ? rec.original.replace(/\s*$/, " ") : "";
        setInput(rec.input, before + text);
        end(rec, "내용을 확인한 뒤 전송 버튼을 눌러 주세요.", false);
      })
      .catch(function (err) {
        if (!rec.cancelled) end(rec, errorMessage(err), true);
      });
  }

  /** 취소: 녹음을 버리고 입력창은 그대로 둔다 (인식 중이면 결과를 버린다) */
  function cancel(rec) {
    if (rec.cancelled) return;
    rec.cancelled = true;
    setInput(rec.input, rec.original);
    end(rec, "음성 입력을 취소했어요.", false);
  }

  function end(rec, message, isError) {
    releaseAudio(rec);
    rec.phase = null;
    rec.samples = [];
    rec.input.readOnly = false;
    setButton(rec.btn, null);
    setStatus(rec.composer, message, isError, true);
    if (current === rec) current = null;
    if (!rec.input.disabled) {
      rec.input.focus();
      var len = rec.input.value.length;
      try { rec.input.setSelectionRange(len, len); } catch (e) {}
    }
  }

  /* ---------- 붙이기 ---------- */

  function attach(composer) {
    var send = composer.querySelector(".kp-composer__send");
    var input = composer.querySelector(".kp-composer__input");
    if (!send || !input || composer.querySelector(".kp-voice-btn")) return;

    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "kp-voice-btn";
    btn.innerHTML = MIC_SVG;
    setButton(btn, null);
    send.parentNode.insertBefore(btn, send);

    var status = document.createElement("div");
    status.className = "kp-voice-status";
    status.setAttribute("role", "status");
    status.setAttribute("aria-live", "polite");
    status.hidden = true;
    composer.appendChild(status);

    btn.addEventListener("click", function () {
      if (current && current.btn === btn) {
        if (current.phase === "recording") stop(current);
        else if (current.phase === "starting") cancel(current);
        return; // 인식 중에는 기다린다 (Esc 로 취소 가능)
      }
      if (current) return;
      start(composer, btn, input);
    });

    // 답변 중에는 입력창이 잠긴다 (ai-consult.js setComposerBusy) → 마이크도 같이 잠근다
    var sync = function () { btn.disabled = input.disabled && !(current && current.btn === btn); };
    sync();
    if (window.MutationObserver) new MutationObserver(sync).observe(input, { attributes: true, attributeFilter: ["disabled"] });
  }

  function init() {
    if (!API || !window.fetch) return;
    api("/sttStatus.do", { method: "GET" })
      .then(function (res) {
        if (!res.enabled) return;
        if (res.maxSec) maxSec = res.maxSec;
        document.querySelectorAll(".kp-composer").forEach(attach);
      })
      .catch(function () {});

    // 녹음·인식 중 전송 버튼 → 바로 보내지 않는다 (녹음 중이면 녹음 끝내기, 인식 결과를 사용자가 확인하게 한다)
    window.addEventListener("click", function (e) {
      if (!current || !e.target.closest) return;
      var send = e.target.closest(".kp-composer__send");
      if (!send) return;
      e.preventDefault();
      e.stopPropagation();
      if (current.phase === "recording") stop(current);
    }, true);

    window.addEventListener("keydown", function (e) {
      if (!current) return;
      if (e.key === "Escape") {
        e.preventDefault();
        cancel(current);
      } else if (e.key === "Enter" && e.target === current.input) {
        e.preventDefault();
        e.stopPropagation();
        if (current.phase === "recording") stop(current);
      }
    }, true);

    // 다른 탭으로 가면 녹음을 끝내고 그때까지 말한 내용을 인식한다
    document.addEventListener("visibilitychange", function () {
      if (document.hidden && current && current.phase === "recording") stop(current);
    });
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
