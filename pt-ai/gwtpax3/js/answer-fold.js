/**
 * AI 상담3 — 건강정보 답변의 단락 탭 / 긴 단락 접기.
 * 2026-10-16 상담2(pt-ai/gwtpax2/js)에서 복사해 상담3 전용으로 분리. 상담2 파일과 따로 고친다.
 *
 * - 건강정보(HealthService)는 "이것만은 꼭 기억하세요" 요약만 바로 보이고, 나머지 단락은 "#### 자세히 보기"
 *   (HealthService.MORE_HEADING) 아래 ### 단락들로 온다. 그 단락들을 탭 칩으로 바꿔 한 번에 한 단락만 보여 준다.
 *   처음에는 아무 단락도 열지 않고, 특정 단락을 물은 경우(data.health.focus)만 그 단락을 연다. 같은 칩을 다시 누르면 닫힌다.
 *   (2026-10-15: 단락 3개를 펼쳐 보여 주니 답변이 지나치게 길다는 의견으로 "요약 우선 + 탭" 방식)
 * - 그 밖의 ### 단락은 글자 수가 기준을 넘으면 처음 몇 줄만 보여 주고 "더보기 (+N자)"로 펼친다. (기관 목록 표가 든 단락은 접지 않음)
 * - 건강정보 그림은 서버가 "[🖼 … 그림 보기](포털 파일 주소)" 링크로 보낸다 → 버튼으로 바꿔 누를 때만 받는다.
 * - 타이핑 중에도 같은 모양이 되도록 ai-core2.js 타자기가 렌더할 때마다 PT_AI2_FOLD.apply 를 부른다.
 *   렌더마다 innerHTML 이 새로 그려지므로 사용자가 고른 탭·펼친 단락·그림은 body 에 기억해 두고 다시 적용한다.
 * - 스타일은 ai-consult.jsp(gwtpax3)의 .ai2-fold, .ai2-tabs, .ai2-img-btn
 */
(function (global) {
  "use strict";

  var DEFAULT_FOLD_CHARS = 320;
  /** HealthService.MORE_HEADING 과 같은 값 */
  var TAB_HEADING = "자세히 보기";
  /** 접힌 단락에서 미리 보이는 대략의 글자 수 ("+N자" 계산용) */
  var PREVIEW_CHARS = 150;
  /** 기관 목록 표의 첫 머리글 (answer-map.js 와 같음). 이 표가 든 단락은 접지 않는다 */
  var LIST_HEADERS = ["기관명", "약국명", "병원명"];

  function tagOf(el) {
    return (el && el.tagName || "").toUpperCase();
  }

  function isSectionEnd(el) {
    if (!el) return true;
    var tag = tagOf(el);
    if (tag === "H2" || tag === "H3" || tag === "H4" || tag === "HR") return true;
    return /^\s*※/.test(el.textContent || "");
  }

  function state(body) {
    if (!body.__ai2Fold) body.__ai2Fold = { open: {}, tab: null, tabTouched: false, img: {} };
    return body.__ai2Fold;
  }

  function fmt(n) {
    return n >= 1000 ? (Math.round(n / 100) / 10).toLocaleString("ko-KR") + "천" : String(n);
  }

  /** 단락에 기관 목록 표(추천 병원 등)가 있는지. 건강정보 본문의 표(통계 등)는 접어도 된다 */
  function hasListTable(parts) {
    return parts.some(function (p) {
      var tables = tagOf(p) === "TABLE" ? [p] : (p.querySelectorAll ? Array.prototype.slice.call(p.querySelectorAll("table")) : []);
      return tables.some(function (t) {
        var th = t.querySelector("thead th");
        return th && LIST_HEADERS.indexOf((th.textContent || "").trim()) >= 0;
      });
    });
  }

  /** h3 다음부터 단락 끝까지의 요소들 */
  function sectionParts(h3) {
    var parts = [];
    for (var el = h3.nextElementSibling; el && !isSectionEnd(el); el = el.nextElementSibling) parts.push(el);
    return parts;
  }

  // ---- 그림 버튼 ----

  function prepareImages(body) {
    var st = state(body);
    Array.prototype.forEach.call(body.querySelectorAll('a[href*="healthInfoFileDown"]'), function (a) {
      var src = a.getAttribute("href");
      var label = (a.textContent || "그림 보기").replace(/^🖼\s*/, "");
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "ai2-img-btn";
      var img = null;
      function show(open) {
        if (open && !img) {
          img = document.createElement("img");
          img.className = "ai2-health-img";
          img.alt = label.replace(/ 보기$/, "");
          img.decoding = "async";
          img.src = src;
          img.addEventListener("error", function () { img.remove(); img = null; btn.textContent = "그림을 불러오지 못했습니다"; btn.disabled = true; });
          img.addEventListener("click", function () { img.classList.toggle("is-zoom"); });
          btn.insertAdjacentElement("afterend", img);
        }
        if (img) img.hidden = !open;
        st.img[src] = open;
        btn.setAttribute("aria-expanded", open ? "true" : "false");
        btn.textContent = open ? "🖼 그림 접기" : "🖼 " + label;
      }
      btn.addEventListener("click", function () { show(!(img && !img.hidden)); });
      a.parentNode.replaceChild(btn, a);
      show(!!st.img[src]);
    });
  }

  // ---- 건강정보 탭 ----

  /** "자세히 보기" h4 와 그 뒤 "※" 안내문 전까지의 h3 단락들. 없으면 null */
  function tabZone(body) {
    var h4 = null;
    Array.prototype.some.call(body.querySelectorAll("h4"), function (h) {
      if ((h.textContent || "").trim() === TAB_HEADING) { h4 = h; return true; }
      return false;
    });
    if (!h4) return null;
    var heads = [];
    for (var el = h4.nextElementSibling; el; el = el.nextElementSibling) {
      if (/^\s*※/.test(el.textContent || "") || tagOf(el) === "H2") break;
      if (tagOf(el) === "H3") heads.push(el);
    }
    return heads.length ? { h4: h4, heads: heads } : null;
  }

  function buildTabs(body, zone) {
    var st = state(body);
    var bar = document.createElement("div");
    bar.className = "ai2-tabs";
    bar.setAttribute("role", "group");
    bar.setAttribute("aria-label", TAB_HEADING);
    var panels = [];
    var buttons = [];

    zone.heads.forEach(function (h3) {
      var key = (h3.textContent || "").trim();
      var parts = sectionParts(h3);
      var panel = document.createElement("div");
      panel.className = "ai2-tab-panel";
      panel.id = "ai2tab-" + Math.random().toString(36).slice(2, 9);
      h3.parentNode.insertBefore(panel, h3);
      panel.appendChild(h3);
      parts.forEach(function (p) { panel.appendChild(p); });
      panels.push(panel);

      var b = document.createElement("button");
      b.type = "button";
      b.textContent = key;
      b.setAttribute("aria-controls", panel.id);
      b.addEventListener("click", function () {
        st.tabTouched = true;
        select(st.tab === key ? null : key);
      });
      buttons.push(b);
      bar.appendChild(b);
    });

    function select(key) {
      st.tab = key;
      zone.heads.forEach(function (h3, i) {
        var on = (h3.textContent || "").trim() === key;
        panels[i].hidden = !on;
        buttons[i].setAttribute("aria-expanded", on ? "true" : "false");
        buttons[i].classList.toggle("is-on", on);
      });
    }

    zone.h4.classList.add("ai2-tabs-label");
    zone.h4.insertAdjacentElement("afterend", bar);
    body.__ai2SelectTab = select;
    select(st.tab);
  }

  // ---- 그 밖의 긴 단락 접기 ----

  function setFoldButton(btn, open, len) {
    btn.setAttribute("aria-expanded", open ? "true" : "false");
    btn.textContent = "";
    if (open) {
      btn.appendChild(document.createTextNode("접기"));
      return;
    }
    btn.appendChild(document.createTextNode("더보기 "));
    var small = document.createElement("small");
    small.textContent = "(+" + fmt(Math.max(0, len - PREVIEW_CHARS)) + "자)";
    btn.appendChild(small);
  }

  function foldSection(body, h3, limit) {
    var parts = sectionParts(h3);
    var len = parts.reduce(function (n, p) { return n + (p.textContent || "").length; }, 0);
    if (!parts.length || len <= limit || hasListTable(parts)) return;
    var st = state(body);
    var key = (h3.textContent || "").trim();
    var opened = !!st.open[key];
    var wrap = document.createElement("div");
    wrap.className = "ai2-fold" + (opened ? " is-open" : "");
    var inner = document.createElement("div");
    inner.className = "ai2-fold__inner";
    h3.parentNode.insertBefore(wrap, parts[0]);
    wrap.appendChild(inner);
    parts.forEach(function (p) { inner.appendChild(p); });
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "ai2-fold__btn";
    setFoldButton(btn, opened, len);
    btn.addEventListener("click", function () {
      var open = wrap.classList.toggle("is-open");
      st.open[key] = open;
      setFoldButton(btn, open, len);
    });
    wrap.appendChild(btn);
  }

  /**
   * 본문을 탭·접기 모양으로 만든다.
   * @returns {boolean} 본문의 마지막(타이핑 중인) 부분이 가려져 있는지 — 타자기는 이 경우 다음으로 건너뛴다
   */
  function apply(body, limit) {
    if (!body) return false;
    var max = typeof limit === "number" ? limit : DEFAULT_FOLD_CHARS;
    prepareImages(body);
    var zone = body.querySelector(".ai2-tabs") ? null : tabZone(body);
    if (zone) buildTabs(body, zone);
    Array.prototype.slice.call(body.querySelectorAll("h3")).forEach(function (h3) {
      if (h3.closest(".ai2-tab-panel") || h3.closest(".ai2-fold")) return;
      var next = h3.nextElementSibling;
      if (next && next.classList && next.classList.contains("ai2-fold")) return;
      foldSection(body, h3, max);
    });
    var last = body.lastElementChild;
    if (!last || !last.classList) return false;
    if (last.classList.contains("ai2-tab-panel")) return !!last.hidden;
    return last.classList.contains("ai2-fold") && !last.classList.contains("is-open");
  }

  global.PT_AI2_FOLD = { apply: apply, DEFAULT_FOLD_CHARS: DEFAULT_FOLD_CHARS };

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!d.body || (data.answerType !== "health_info" && data.answerType !== "agent_answer")) return;
    var limit = data.health && typeof data.health.foldChars === "number" ? data.health.foldChars : DEFAULT_FOLD_CHARS;
    try {
      apply(d.body, limit);
      // 특정 단락을 물었으면 그 탭을 연다 (사용자가 이미 탭을 골랐으면 그대로)
      var st = state(d.body);
      if (data.health && data.health.focus && !st.tabTouched && d.body.__ai2SelectTab) d.body.__ai2SelectTab(data.health.focus);
    } catch (err) {
      if (global.console) console.warn("[ai2-fold] failed", err);
    }
  });
})(window);
