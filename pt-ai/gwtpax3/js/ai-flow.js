/**
 * AI 상담3 작동 과정 시연 (ai3-flow.do).
 *
 * POST {api}/run.do {question, sessionId} → {jobId}
 * GET  {api}/events.do?jobId=… (SSE)
 *   event: flow  {seq, t, dur, stage, lane, node, title, text, data}   t = 서버 처리 시작 후 ms
 *   event: done  {route, markdown, items, trace, summary}
 *   event: fail  {message}
 *
 * 실시간 실행과 "다시 재생"은 같은 그리기 코드를 쓴다. 이벤트는 도착 시각(t + dur) 순서로 그려지고,
 * AI 호출처럼 오래 걸리는 단계는 요청 이벤트가 오면 막대가 늘어나다가 응답 이벤트에서 확정된다.
 */
(function () {
  "use strict";

  var root = document.getElementById("flow");
  if (!root) return;
  var API = root.getAttribute("data-api") || "";
  var $ = function (id) { return document.getElementById(id); };
  var lanes = {};
  Array.prototype.forEach.call(document.querySelectorAll(".fl-lane"), function (el) {
    lanes[el.getAttribute("data-lane")] = el.querySelector(".fl-track");
  });
  var md = window.markdownit ? window.markdownit({ html: false, linkify: true, breaks: true }) : null;

  var LANE_NAME = { browser: "화면", was: "서버(Java)", ai: "AI", db: "데이터베이스" };
  var ROLE_NAME = { system: "규칙", user: "사용자", assistant: "AI", tool: "도구 결과" };

  /** 단계별 쉬운 설명 (발표용) */
  var EXPLAIN = {
    accept: "서버가 질문을 받자마자 작업번호를 발급하고, 실제 처리는 뒤에서 따로 돌립니다. 그래서 화면은 기다리지 않고 바로 '처리 중' 상태가 됩니다.",
    emergency: "AI보다 먼저 Java가 '가슴 통증', '숨이 안 쉬어져' 같은 응급 표현이 있는지 검사합니다. 응급 상황은 AI가 실수하면 안 되기 때문에 정해진 규칙으로 처리합니다.",
    memory: "AI는 지난 대화를 스스로 기억하지 못합니다. 그래서 서버가 최근 대화 3개를 매번 같이 보내, \"그중에\", \"거기\" 같은 말을 알아듣게 합니다.",
    runner: "이제 AI와 도구를 주고받기 시작합니다. 무한 반복을 막기 위해 도구는 최대 4번, 전체 시간은 60초로 제한합니다.",
    llm_request: "AI에게 지켜야 할 규칙, 대화 내용, 사용할 수 있는 도구 목록을 함께 보냈습니다. AI가 생각하는 동안 막대가 늘어납니다.",
    llm_response_tool: "AI는 데이터베이스를 직접 볼 수 없습니다. 대신 '이 도구를 이 값으로 실행해 달라'고 서버에 요청합니다.",
    llm_response_text: "필요한 자료가 모였다고 판단해, 사용자에게 보여 줄 설명 글을 썼습니다.",
    llm_error: "AI 서버가 제때 답하지 못했습니다. 이럴 때는 문서 검색(RAG)으로 넘겨 답을 이어 갑니다.",
    tool_call: "서버(Java)가 AI의 요청을 받아 실제 검색을 준비합니다. AI가 잘못 넣은 값(지역 이름, 기관 종류 등)은 여기서 바로잡습니다.",
    db_query: "데이터베이스에서 실제 의료기관 정보를 찾았습니다. AI에게는 짧은 요약만 주고, 화면에는 서버가 만든 표와 지도를 그대로 붙입니다. 숫자를 AI가 다시 쓰지 않으니 틀릴 일이 없습니다.",
    tool_result: "데이터베이스 없이 서버의 규칙(증상 사전)으로 판단했습니다. 여러 증상에 공통인 진료과를 앞에 둡니다.",
    progress: "이 순간 사용자 화면에는 이 진행 문구가 보입니다.",
    check: "AI가 도구 없이 답했을 때, 정말 도구가 필요 없는 질문인지 서버가 한 번 더 확인합니다.",
    guess: "다시 요청해도 AI가 도구를 쓰지 않으면, 서버의 질문 분류기가 알맞은 검색을 대신 골라 실행합니다.",
    compose: "AI의 설명 글 아래에 서버가 만든 표를 붙이고, 지도에 찍을 위치를 정리합니다.",
    memory_save: "이번 질문과 답, 답에 나온 기관 이름을 기억해 둡니다. 다음 질문에서 \"첫 번째 병원\"처럼 말해도 알아듣습니다.",
    deliver: "완성된 답변을 화면으로 보냅니다. 본문은 한 줄씩 흘러가듯 그려지고, 표 아래에 지도와 '검색 과정' 상자가 붙습니다.",
    handoff: "의료기관 정보로 답할 수 없는 질문(이용 안내, 서류 등)이라 기존 문서 검색(RAG)으로 넘깁니다.",
    error: "처리 중 문제가 생겼습니다."
  };

  /** 상담3 본 화면 기준으로 그 일을 하는 코드 */
  var CODE = {
    accept: "GwtpaxAi3Controller.queryRag() → AgentJobStore.create()",
    emergency: "SymptomService.emergencyPlan()",
    memory: "AgentMemory.history()",
    runner: "AgentRunner.run()",
    llm_request: "OllamaAgentClient.chat() → Ollama /api/chat",
    llm_response: "AppApiAgentClient.toReply() · parseToolCalls()",
    llm_error: "AgentRunner.fallback(\"llm_error\")",
    tool_call: "AgentTools.execute()",
    tool_result: "SymptomService.departmentsFor()",
    progress: "AgentJobStore.push(\"progress\") → ai-core2.js",
    check: "AgentTools.requiresTool()",
    guess: "AgentTools.guessCall()",
    compose: "AnswerComposer.compose()",
    memory_save: "AgentMemory.add()",
    deliver: "AgentJobStore.finish() → SSE(queryEvents.do)",
    handoff: "RagStarter.start()",
    error: "GwtpaxAi3Controller.work()"
  };
  var DB_CODE = {
    search_facilities: "FacilityService.search() → ai_chat.xml HOSPITAL_SEARCH 등",
    find_by_address: "PlaceService.answer() → ai_chat.xml PLACE_SEARCH (진료과가 있으면 NearbyService.search() 로 주변까지)",
    search_nearby: "NearbyService.search() → ai_chat.xml NEARBY_HOSPITAL",
    search_aed: "AedService.byRegion() / nearby() → ai_chat.xml AED_SEARCH · NEARBY_AED",
    search_hospital_info: "HospitalDocsService.search() → Weaviate DocumentChunk 키워드 검색 (병원 홈페이지 자료)",
    hospital_detail: "StaffService.answerForHospital()",
    health_info: "HealthService.answer() → ai_chat.xml HEALTH_DETAIL"
  };

  // ---- 상태 ----
  var S = null;

  function reset() {
    if (S && S.source) S.source.close();
    if (S && S.raf) cancelAnimationFrame(S.raf);
    S = {
      events: [],        // 도착한 이벤트 (원본, 재생용)
      done: null,
      marks: [],         // {el, t, dur, pending}
      pending: [],       // AI 요청 중인 막대
      selected: null,
      follow: true,
      clock: null,       // () => 현재 ms
      endMs: 0,
      running: false
    };
    Object.keys(lanes).forEach(function (k) { lanes[k].textContent = ""; });
    $("flSteps").textContent = "";
    $("flDetail").removeAttribute("data-lane");
    $("flDetail").innerHTML = '<p class="fl-placeholder">단계를 고르면 무엇이 오갔는지 보여 드립니다.</p>';
    $("flAnswer").innerHTML = '<p class="fl-placeholder">처리가 끝나면 상담 화면에 보이는 답변이 여기에 나타납니다.</p>';
    $("flNow").hidden = true;
    setStats(0, 0, 0, 0);
    renderRuler(4000);
  }

  // ---- 시간축 ----
  function domain() {
    var now = S.clock && S.running ? S.clock() : 0;
    return Math.max(4000, S.endMs * 1.06, now * 1.06);
  }

  var rulerKey = "";
  function renderRuler(d) {
    var key = String(Math.round(d / 50));
    if (key === rulerKey) return;
    rulerKey = key;
    var steps = [250, 500, 1000, 2000, 5000, 10000, 20000, 30000];
    var step = steps[steps.length - 1];
    for (var i = 0; i < steps.length; i += 1) {
      if (d / steps[i] <= 9) { step = steps[i]; break; }
    }
    var r = $("flRuler");
    r.textContent = "";
    for (var t = 0; t <= d; t += step) {
      var s = document.createElement("span");
      s.style.left = (t / d * 100) + "%";
      s.textContent = (t / 1000).toFixed(step < 1000 ? 2 : 0) + "초";
      r.appendChild(s);
    }
  }

  function layout() {
    var d = domain();
    var now = S.clock && S.running ? S.clock() : S.endMs;
    S.marks.forEach(function (m) {
      var dur = m.pending ? Math.max(0, now - m.t) : m.dur;
      m.el.style.left = (m.t / d * 100) + "%";
      if (!m.tick) m.el.style.width = (dur / d * 100) + "%";
    });
    var lanesEl = $("flLanes");
    var nowEl = $("flNow");
    if (S.running) {
      var trackLeft = lanes.was.getBoundingClientRect().left - lanesEl.getBoundingClientRect().left;
      var trackW = lanes.was.getBoundingClientRect().width;
      nowEl.hidden = false;
      nowEl.style.left = (trackLeft + trackW * Math.min(1, now / d)) + "px";
      nowEl.setAttribute("data-time", (now / 1000).toFixed(1) + "초");
      setStatTime(now);
    }
    renderRuler(d);
  }

  function tick() {
    if (!S.running) return;
    if (S.pump) S.pump();
    layout();
    S.raf = requestAnimationFrame(tick);
  }

  // ---- 그리기 ----
  function addEvent(ev) {
    S.endMs = Math.max(S.endMs, ev.t + (ev.dur || 0));
    var lane = lanes[ev.lane] ? ev.lane : "was";

    if (ev.stage === "llm_request") {
      var pm = mark(ev, lane, true);
      S.pending.push(pm);
    } else if (ev.stage === "llm_response" || ev.stage === "llm_error") {
      var p = S.pending.shift();
      if (p) { p.el.parentNode.removeChild(p.el); S.marks.splice(S.marks.indexOf(p), 1); }
      mark(ev, "ai", false);
    } else {
      mark(ev, lane, false);
    }
    step(ev, lane);
    updateStats(ev);
    if (S.follow) select(ev);
    layout();
  }

  function mark(ev, lane, pending) {
    var b = document.createElement("button");
    b.type = "button";
    var tick = !pending && !(ev.dur > 40);
    b.className = "fl-mark" + (tick ? " fl-mark--tick" : "") + (pending ? " fl-mark--pending" : "");
    b.title = ev.title + (ev.text ? " — " + ev.text : "");
    b.setAttribute("aria-label", (ev.seq || "") + "번 " + ev.title);
    b.setAttribute("aria-pressed", "false");
    if (!tick) {
      var sp = document.createElement("span");
      sp.textContent = ev.title;
      b.appendChild(sp);
    }
    b.addEventListener("click", function () { S.follow = false; select(ev); });
    ev._mark = b;
    lanes[lane].appendChild(b);
    var m = { el: b, t: ev.t, dur: ev.dur || 0, pending: pending, tick: tick };
    S.marks.push(m);
    return m;
  }

  function step(ev, lane) {
    var li = document.createElement("li");
    li.setAttribute("data-lane", lane);
    var b = document.createElement("button");
    b.type = "button";
    var ti = document.createElement("span");
    ti.className = "ti";
    ti.textContent = ev.title;
    var tx = document.createElement("span");
    tx.className = "tx";
    tx.textContent = ev.text || "";
    ti.appendChild(tx);
    var t = document.createElement("span");
    t.className = "t";
    t.textContent = (ev.t / 1000).toFixed(2) + "초" + (ev.dur > 0 ? " · " + fmtMs(ev.dur) : "");
    b.appendChild(ti);
    b.appendChild(t);
    b.addEventListener("click", function () { S.follow = false; select(ev); });
    ev._step = b;
    li.appendChild(b);
    $("flSteps").appendChild(li);
    if (S.follow) {
      var list = $("flSteps"); // 페이지는 움직이지 않고 목록 안에서만 내린다
      list.scrollTop = list.scrollHeight;
    }
  }

  function select(ev) {
    if (S.selected) {
      if (S.selected._mark) S.selected._mark.setAttribute("aria-pressed", "false");
      if (S.selected._step) S.selected._step.removeAttribute("aria-current");
    }
    S.selected = ev;
    if (ev._mark && ev._mark.isConnected) ev._mark.setAttribute("aria-pressed", "true");
    if (ev._step) ev._step.setAttribute("aria-current", "true");
    renderDetail(ev);
  }

  // ---- 상세 ----
  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function pre(obj) {
    return el("pre", null, typeof obj === "string" ? obj : JSON.stringify(obj, null, 2));
  }

  function mdBlock(text) {
    var div = el("div", "fl-answer-body");
    div.style.padding = "12px 16px";
    div.style.background = "#f6f8f7";
    if (md && window.DOMPurify) div.innerHTML = window.DOMPurify.sanitize(md.render(text || ""));
    else div.textContent = text || "";
    return div;
  }

  function messages(list) {
    var ul = el("ul", "fl-msgs");
    (list || []).forEach(function (m) {
      var li = el("li");
      var d = el("details");
      var s = el("summary");
      var label = ROLE_NAME[m.role] || m.role;
      if (m.tool_name) label += " · " + m.tool_name;
      s.appendChild(el("b", null, label));
      var body = m.content || (m.tool_calls ? JSON.stringify(m.tool_calls) : "");
      s.appendChild(el("span", null, body.replace(/\s+/g, " ").slice(0, 120)));
      d.appendChild(s);
      d.appendChild(pre(m.tool_calls && !m.content ? m.tool_calls : body));
      li.appendChild(d);
      ul.appendChild(li);
    });
    return ul;
  }

  function renderDetail(ev) {
    var box = $("flDetail");
    var data = ev.data || {};
    box.setAttribute("data-lane", lanes[ev.lane] ? ev.lane : "was");
    box.textContent = "";
    box.appendChild(el("h3", null, ev.title));
    box.appendChild(el("p", "who", LANE_NAME[ev.lane] + " · " + (ev.t / 1000).toFixed(2) + "초"
      + (ev.dur > 0 ? " 시작, " + fmtMs(ev.dur) + " 걸림" : "") + (ev.text ? " · " + ev.text : "")));

    var key = ev.stage;
    if (key === "llm_response") key = (data.tool_calls && data.tool_calls.length) ? "llm_response_tool" : "llm_response_text";
    if (EXPLAIN[key]) box.appendChild(el("p", "easy", EXPLAIN[key]));
    var code = ev.stage === "db_query" && DB_CODE[data.tool] ? DB_CODE[data.tool] : CODE[ev.stage];
    if (code) {
      var c = el("p", "code", "코드: ");
      c.appendChild(el("code", null, code));
      box.appendChild(c);
    }

    switch (ev.stage) {
      case "accept":
        box.appendChild(el("h4", null, "받은 질문"));
        box.appendChild(pre({ question: data.question, jobId: data.jobId, sessionId: data.sessionId, thread: data.thread }));
        break;
      case "memory":
        box.appendChild(el("h4", null, "함께 보내는 지난 대화"));
        box.appendChild(data.history && data.history.length ? messages(data.history) : el("p", "fl-placeholder", "이번이 첫 질문이라 보낼 대화가 없습니다."));
        break;
      case "runner":
        box.appendChild(el("h4", null, "AI에게 주는 규칙 (시스템 메시지)"));
        box.appendChild(pre(data.system || ""));
        break;
      case "llm_request":
        box.appendChild(el("h4", null, "보낸 메시지 " + (data.messages || []).length + "개"));
        box.appendChild(messages(data.messages));
        box.appendChild(el("h4", null, "쓸 수 있는 도구"));
        box.appendChild(el("p", null, data.tools && data.tools.length ? data.tools.join(", ") : "없음 (이번에는 글로만 답하라고 요청)"));
        box.appendChild(el("p", "who", (data.model || "") + " · " + (data.url || "")));
        break;
      case "llm_response":
        if (data.tool_calls && data.tool_calls.length) {
          box.appendChild(el("h4", null, "AI가 요청한 도구"));
          box.appendChild(pre(data.tool_calls));
        } else {
          box.appendChild(el("h4", null, "AI가 쓴 설명"));
          box.appendChild(pre(data.content || ""));
        }
        break;
      case "tool_call":
        box.appendChild(el("h4", null, "실행할 값"));
        box.appendChild(pre(data.arguments || {}));
        break;
      case "db_query":
      case "tool_result":
        if (data.error) box.appendChild(el("p", "fl-fail", "오류: " + data.error));
        if (data.toAi) {
          box.appendChild(el("h4", null, "AI에게 돌려준 요약"));
          box.appendChild(pre(data.toAi));
        }
        if (data.markdown) {
          box.appendChild(el("h4", null, "화면에 붙는 표 (서버가 만든 것)"));
          box.appendChild(mdBlock(data.markdown));
        }
        break;
      case "compose":
        box.appendChild(el("h4", null, "AI 설명 글"));
        box.appendChild(pre(data.aiText || ""));
        box.appendChild(el("p", null, "표 " + (data.tables || 0) + "개 · 지도 마커 " + (data.mapItems || 0) + "개 · 전체 " + (data.length || 0) + "자"));
        break;
      default:
        var keys = Object.keys(data).filter(function (k) { return data[k] != null; });
        if (keys.length) {
          box.appendChild(el("h4", null, "데이터"));
          box.appendChild(pre(data));
        }
    }
  }

  // ---- 요약 수치 ----
  function setStats(time, llm, tool, db) {
    setStatTime(time);
    stat("llm", llm); stat("tool", tool); stat("db", db);
  }
  function setStatTime(ms) { stat("time", (ms / 1000).toFixed(1)); }
  function stat(k, v) {
    var b = document.querySelector('#flStats [data-k="' + k + '"]');
    if (b) b.textContent = v;
  }
  function updateStats(ev) {
    var n = function (stage) { return S.events.filter(function (e) { return e.stage === stage; }).length; };
    stat("llm", n("llm_request"));
    stat("tool", n("tool_call"));
    stat("db", n("db_query"));
  }

  function fmtMs(ms) { return ms < 1000 ? ms + "ms" : (ms / 1000).toFixed(1) + "초"; }

  function status(text) { $("flStatus").textContent = text; }

  function showAnswer(done) {
    var box = $("flAnswer");
    if (!done) return;
    if (md && window.DOMPurify) box.innerHTML = window.DOMPurify.sanitize(md.render(done.markdown || ""));
    else box.textContent = done.markdown || "";
    var s = done.summary || {};
    setStats(s.totalMs || S.endMs, s.llmCalls || 0, s.toolRuns || 0, s.dbQueries || 0);
    status("끝났습니다. " + ((s.totalMs || S.endMs) / 1000).toFixed(1) + "초 동안 AI를 " + (s.llmCalls || 0) + "번 부르고, 도구를 "
      + (s.toolRuns || 0) + "번 썼습니다." + (done.route === "rag-handoff" ? " (문서 검색으로 넘김)" : ""));
  }

  function stop() {
    S.running = false;
    if (S.raf) cancelAnimationFrame(S.raf);
    $("flNow").hidden = true;
    layout();
  }

  // ---- 실행 ----
  function sessionId() {
    var k = "ai3flow_sid";
    var id = null;
    try { id = sessionStorage.getItem(k); } catch (e) { /* 저장소 없음 */ }
    if (!id) {
      id = "flow_" + Math.random().toString(36).slice(2, 12);
      try { sessionStorage.setItem(k, id); } catch (e) { /* 저장소 없음 */ }
    }
    return id;
  }
  var turn = 0;
  function renderSession() {
    var p = $("flSession");
    p.textContent = turn ? "같은 대화의 " + (turn + 1) + "번째 질문으로 보냅니다 (앞의 대화를 AI가 함께 봅니다). " : "";
    if (turn) {
      var b = el("button", null, "새 대화로 시작");
      b.type = "button";
      b.addEventListener("click", function () {
        try { sessionStorage.removeItem("ai3flow_sid"); } catch (e) { /* 저장소 없음 */ }
        turn = 0;
        renderSession();
      });
      p.appendChild(b);
    }
  }

  function run(question) {
    reset();
    var btn = $("flRun");
    btn.disabled = true;
    $("flReplay").disabled = true;
    status("질문을 보내는 중입니다…");
    S.running = true;
    var t0 = performance.now();
    S.clock = function () { return performance.now() - t0; };
    S.raf = requestAnimationFrame(tick);

    fetch(API + "/run.do", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question: question, sessionId: sessionId() })
    }).then(function (res) {
      if (res.status === 429) throw new Error("다른 시연이 진행 중입니다. 잠시 후 다시 보내 주세요.");
      if (!res.ok) throw new Error("질문을 보내지 못했습니다 (" + res.status + ").");
      return res.json();
    }).then(function (ack) {
      status("처리하는 모습을 그리고 있습니다…");
      var src = new EventSource(API + "/events.do?jobId=" + encodeURIComponent(ack.jobId));
      S.source = src;
      var synced = false;
      src.addEventListener("flow", function (e) {
        var ev = JSON.parse(e.data);
        if (!synced) {
          // 서버 시계(처리 시작 = 0)에 화면 시계를 맞춘다
          synced = true;
          var base = performance.now() - (ev.t + (ev.dur || 0));
          S.clock = function () { return performance.now() - base; };
        }
        S.events.push(ev);
        addEvent(ev);
      });
      src.addEventListener("done", function (e) {
        src.close();
        S.done = JSON.parse(e.data);
        stop();
        showAnswer(S.done);
        finishRun();
      });
      src.addEventListener("fail", function (e) {
        src.close();
        stop();
        var msg = "처리하지 못했습니다.";
        try { msg = JSON.parse(e.data).message || msg; } catch (x) { /* 형식 오류 */ }
        status(msg);
        finishRun();
      });
      src.onerror = function () {
        if (S.done) return;
        src.close();
        stop();
        status("연결이 끊겼습니다. 다시 보내 주세요.");
        finishRun();
      };
    }).catch(function (err) {
      stop();
      status(err.message);
      finishRun();
    });
  }

  function finishRun() {
    $("flRun").disabled = false;
    $("flReplay").disabled = !S.events.length;
    turn += S.done ? 1 : 0;
    renderSession();
  }

  /** 저장된 이벤트를 도착 시각 순서대로 다시 그린다 */
  function replay() {
    var events = S.events.slice();
    var done = S.done;
    var speed = parseFloat($("flSpeed").value) || 1;
    if (!events.length) return;
    reset();
    S.events = [];
    S.done = done;
    var queue = events.map(function (e) { return { at: e.t + (e.dur || 0), ev: e }; })
      .sort(function (a, b) { return a.at - b.at || a.ev.seq - b.ev.seq; });
    var t0 = performance.now();
    S.clock = function () { return (performance.now() - t0) * speed; };
    S.running = true;
    $("flReplay").disabled = true;
    $("flRun").disabled = true;
    status("다시 재생하는 중입니다" + (speed < 1 ? " (" + Math.round(1 / speed) + "배 느리게)" : "") + "…");
    S.pump = function () {
      var now = S.clock();
      while (queue.length && queue[0].at <= now) {
        var ev = clean(queue.shift().ev);
        S.events.push(ev);
        addEvent(ev);
      }
      if (!queue.length) {
        S.pump = null;
        stop();
        showAnswer(done);
        $("flReplay").disabled = false;
        $("flRun").disabled = false;
      }
    };
    S.raf = requestAnimationFrame(tick);
  }

  function clean(ev) {
    var c = {};
    Object.keys(ev).forEach(function (k) { if (k.charAt(0) !== "_") c[k] = ev[k]; });
    return c;
  }

  // ---- 연결 ----
  $("flAsk").addEventListener("submit", function (e) {
    e.preventDefault();
    var q = $("flQ").value.trim();
    if (!q) { $("flQ").focus(); return; }
    run(q);
  });
  $("flQ").addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey && !e.isComposing) {
      e.preventDefault();
      $("flAsk").requestSubmit();
    }
  });
  Array.prototype.forEach.call(document.querySelectorAll(".fl-samples button"), function (b) {
    b.addEventListener("click", function () { $("flQ").value = b.textContent; $("flQ").focus(); });
  });
  $("flReplay").addEventListener("click", replay);
  window.addEventListener("resize", function () { if (S) layout(); });

  reset();
  renderSession();
})();
