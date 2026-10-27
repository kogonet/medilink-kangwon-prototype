/**
 * AI 상담4 — 건강정보 답변의 단락 탭 / 긴 단락 접기.
 * 2026-10-16 상담2(pt-ai/gwtpax2/js)에서 복사해 상담4 전용으로 분리. 상담2 파일과 따로 고친다.
 *
 * - 건강정보(HealthService)는 요약만 바로 보이고, 나머지 단락은 탭 영역(블록 health-info 의 tabs 칸)으로 온다.
 *   그 단락들을 탭 칩으로 바꿔 한 번에 한 단락만 보여 준다. 처음에는 아무 단락도 열지 않고,
 *   특정 단락을 물은 경우(data.health.focus)만 그 단락을 연다. 같은 칩을 다시 누르면 닫힌다.
 * - 긴 내용은 처음 몇 줄만 보여 주고 "더보기 (+N자)"로 펼친다. (기관 목록 표가 든 곳은 접지 않음)
 * - 건강정보 그림 링크는 버튼으로 바꿔 누를 때만 받는다.
 * - 판단 기준 (2026-10-16 블록 렌더링, 관리자가 바꿀 수 있는 글자로 찾지 않는다):
 *   · 최종 화면(answer-blocks.js 가 블록으로 다시 그린 뒤, body[data-blocks]): 탭 = [data-slot="tabs"],
 *     목록 표 = [data-role="list-table"] (표 또는 관리자 틀의 행 반복 목록), 그림 = a[data-role="health-img"], 접기 = 블록의 본문 칸 단위
 *   · 타이핑 중(마크다운 그대로): 탭 = 첫 #### 제목 뒤의 ### 단락들(끝은 done 데이터의 탭 제목, 없으면 ※ 안내문),
 *     목록 표 = ①②… 번호로 시작하는 행, 그림 = 포털 그림 파일 주소 링크, 접기 = ### 단락 단위
 * - 타이핑 중에도 같은 모양이 되도록 ai-core4.js 타자기가 렌더할 때마다 PT_AI2_FOLD.apply 를 부른다.
 *   렌더마다 innerHTML 이 새로 그려지므로 사용자가 고른 탭·펼친 단락·그림은 body 에 기억해 두고 다시 적용한다.
 * - 스타일은 ai-consult.jsp(gwtpax4)의 .ai2-fold, .ai2-tabs, .ai2-img-btn
 */
(function (global) {
  "use strict";

  var DEFAULT_FOLD_CHARS = 320;
  /** 접힌 단락에서 미리 보이는 대략의 글자 수 ("+N자" 계산용) */
  var PREVIEW_CHARS = 150;
  /** 목록 표 행의 번호 (FacilityService.circledNumber ①~㊿) */
  var CIRCLED = /^[①-⑳㉑-㉟㊱-㊿]/;
  /** 포털 그림 파일 주소 (HealthService.IMAGE_URL) — 타이핑 중에만 쓴다 */
  var IMAGE_HREF = 'a[href*="healthInfoFileDown"]';

  function tagOf(el) {
    return (el && el.tagName || "").toUpperCase();
  }

  function isFinal(body) {
    return !!(body && body.getAttribute && body.getAttribute("data-blocks"));
  }

  function state(body) {
    if (!body.__ai2Fold) body.__ai2Fold = { open: {}, tab: null, tabTouched: false, img: {} };
    return body.__ai2Fold;
  }

  function fmt(n) {
    return n >= 1000 ? (Math.round(n / 100) / 10).toLocaleString("ko-KR") + "천" : String(n);
  }

  function isListTable(t) {
    var role = t.getAttribute("data-role");
    if (role) return role === "list-table";
    var td = t.querySelector("tbody tr td");
    return !!td && CIRCLED.test((td.textContent || "").trim());
  }

  /**
   * 요소들에 기관 목록 표(추천 병원 등)가 있는지. 건강정보 본문의 표(통계 등)는 접어도 된다.
   * 관리자 틀의 행 반복 목록(카드 등, 2026-10-21)은 표가 아니어도 [data-role="list-table"] 이다
   */
  function hasListTable(parts) {
    return parts.some(function (p) {
      if (p.getAttribute && p.getAttribute("data-role") === "list-table") return true;
      if (p.querySelector && p.querySelector('[data-role="list-table"]:not(table)')) return true;
      var tables = tagOf(p) === "TABLE" ? [p] : (p.querySelectorAll ? Array.prototype.slice.call(p.querySelectorAll("table")) : []);
      return tables.some(isListTable);
    });
  }

  /** 타이핑 중 단락의 끝: 다음 제목, 가로줄, ※ 안내문 */
  function isLiveSectionEnd(el) {
    if (!el) return true;
    var tag = tagOf(el);
    if (tag === "H2" || tag === "H3" || tag === "H4" || tag === "HR") return true;
    return /^\s*※/.test(el.textContent || "");
  }

  /** h3 다음부터 단락 끝까지의 요소들 (탭 영역 안에서는 다음 ### 까지) */
  function sectionParts(h3, inTabs) {
    var parts = [];
    for (var el = h3.nextElementSibling; el; el = el.nextElementSibling) {
      if (inTabs ? (tagOf(el) === "H3" || tagOf(el) === "H4") : isLiveSectionEnd(el)) break;
      parts.push(el);
    }
    return parts;
  }

  // ---- 그림 버튼 ----

  function prepareImages(body) {
    var st = state(body);
    var links = body.querySelectorAll(isFinal(body) ? 'a[data-role="health-img"]' : IMAGE_HREF);
    Array.prototype.forEach.call(links, function (a) {
      var src = a.getAttribute("href");
      var label = (a.textContent || "그림 보기").replace(/^\s*🖼\s*/, "");
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "ai2-img-btn";
      btn.setAttribute("data-role", "health-img");
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

  /** 이번 답변 done 데이터의 탭 제목 (타이핑 중 탭 영역의 끝을 알기 위해). 아직 없으면 null */
  function liveTabTitles() {
    var api = global.PT_AI_API;
    var data = api && typeof api.getLastDoneData === "function" ? api.getLastDoneData() : null;
    var blocks = data && Array.isArray(data.blocks) ? data.blocks : null;
    if (!blocks) return null;
    for (var i = 0; i < blocks.length; i += 1) {
      var parts = blocks[i].parts || [];
      for (var j = 0; j < parts.length; j += 1) {
        if (Array.isArray(parts[j].tabs)) return parts[j].tabs;
      }
    }
    return null;
  }

  /** 탭 영역 { h4, heads, box }. 없으면 null */
  function tabZone(body) {
    if (isFinal(body)) {
      var box = body.querySelector('[data-slot="tabs"]');
      if (!box) return null;
      var hs = Array.prototype.filter.call(box.children, function (c) { return tagOf(c) === "H3"; });
      return hs.length ? { h4: box.querySelector("h4"), heads: hs, box: box } : null;
    }
    var h4 = body.querySelector("h4"); // 마크다운에서 #### 는 탭 영역 제목만 쓴다 (MarkdownRenderer TABS)
    if (!h4) return null;
    var titles = liveTabTitles();
    var heads = [];
    for (var el = h4.nextElementSibling; el; el = el.nextElementSibling) {
      var tag = tagOf(el);
      if (tag === "H2" || tag === "H4") break;
      if (titles) {
        if (tag === "H3") {
          if (titles.indexOf((el.textContent || "").trim()) < 0) break;
          heads.push(el);
        }
        continue;
      }
      if (/^\s*※/.test(el.textContent || "")) break;
      if (tag === "H3") heads.push(el);
    }
    return heads.length ? { h4: h4, heads: heads, box: null } : null;
  }

  function buildTabs(body, zone) {
    var st = state(body);
    var bar = document.createElement("div");
    bar.className = "ai2-tabs";
    bar.setAttribute("role", "group");
    bar.setAttribute("aria-label", zone.h4 ? (zone.h4.textContent || "").trim() : "단락");
    var panels = [];
    var buttons = [];
    var titles = liveTabTitles();

    zone.heads.forEach(function (h3, idx) {
      var key = (h3.textContent || "").trim();
      // 마지막 탭은 (타이핑 중, done 데이터가 있으면) 다음 블록 전까지만
      var parts = sectionParts(h3, !!zone.box || !!titles);
      if (!zone.box && titles && idx === zone.heads.length - 1) parts = trimAfterTabs(parts);
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
      b.setAttribute("data-tab", key);
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

    if (zone.h4) {
      zone.h4.classList.add("ai2-tabs-label");
      zone.h4.insertAdjacentElement("afterend", bar);
    } else {
      zone.box.insertBefore(bar, zone.box.firstChild);
    }
    body.__ai2SelectTab = select;
    select(st.tab);
  }

  /** 타이핑 중 마지막 탭 단락에서 탭 영역 뒤(※ 안내문부터)를 뺀다 */
  function trimAfterTabs(parts) {
    for (var i = 0; i < parts.length; i += 1) {
      if (/^\s*※/.test(parts[i].textContent || "")) return parts.slice(0, i);
    }
    return parts;
  }

  // ---- 긴 내용 접기 ----

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

  /** 요소들을 접힘 상자로 감싼다. key 는 펼침 상태 기억용 */
  function fold(body, parts, key, limit) {
    var len = parts.reduce(function (n, p) { return n + (p.textContent || "").length; }, 0);
    if (!parts.length || len <= limit || hasListTable(parts)) return;
    var st = state(body);
    var opened = !!st.open[key];
    var wrap = document.createElement("div");
    wrap.className = "ai2-fold" + (opened ? " is-open" : "");
    var inner = document.createElement("div");
    inner.className = "ai2-fold__inner";
    parts[0].parentNode.insertBefore(wrap, parts[0]);
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

  /** 최종 화면: 블록의 본문 칸(md·section) 하나가 길면 접는다 */
  function foldParts(body, limit) {
    Array.prototype.forEach.call(body.querySelectorAll('.ab__part[data-kind="md"], .ab__part[data-kind="section"]'), function (part) {
      if (part.querySelector(".ai2-fold") || part.closest(".ai2-tab-panel")) return;
      var sec = part.closest("[data-block-index]");
      var key = "part:" + (sec ? sec.getAttribute("data-block-index") : "") + ":" +
          Array.prototype.indexOf.call(part.parentNode.children, part);
      fold(body, Array.prototype.slice.call(part.children), key, limit);
    });
  }

  /** 타이핑 중: ### 단락이 길면 접는다 */
  function foldLiveSections(body, limit) {
    Array.prototype.slice.call(body.querySelectorAll("h3")).forEach(function (h3) {
      if (h3.closest(".ai2-tab-panel") || h3.closest(".ai2-fold")) return;
      var next = h3.nextElementSibling;
      if (next && next.classList && next.classList.contains("ai2-fold")) return;
      fold(body, sectionParts(h3, false), "h3:" + (h3.textContent || "").trim(), limit);
    });
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
    if (isFinal(body)) {
      foldParts(body, max);
      return false;
    }
    foldLiveSections(body, max);
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
      if (global.console) console.warn("[ai4-fold] failed", err);
    }
  });
})(window);
