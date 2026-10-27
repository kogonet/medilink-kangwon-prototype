/**
 * AI 상담4 — 답변을 블록 단위로 다시 그린다 (2026-10-16 답변 템플릿 빌더 2단계).
 *
 * - 서버 done 데이터의 blocks(AnswerBlock.toMap)를 받아, 타자기가 다 찍은 본문을 같은 내용의 블록 구조로 바꾼다.
 *     section.ab[data-block="facility-list"] > div.ab__part[data-slot="head"][data-kind="text"]
 * - 표는 블록 데이터의 열·행으로 직접 만든다 (글자로 표를 알아보지 않도록):
 *     table[data-role="list-table" | "table"][data-map]   th[data-col]   tr[data-item-index]   td[data-col]
 *     기관 이름 칸 = span[data-role="item-no"] + span[data-role="item-name"]
 *                  + span.ai2-acts > a[data-action="route"] + button[data-action="detail"][data-name][data-query]
 * - 건강정보 그림 링크는 블록 meta.images 의 주소와 같은 링크에 a[data-role="health-img"] 를 붙인다.
 * - 지도(answer-map.js)·접기(answer-fold.js) 등은 이 표시만 본다. 그래서 다른 플러그인보다 먼저 실행되어야 하며,
 *   JSP 에서 ai-core4.js 바로 뒤에 둔다 ("ptai:answer" 리스너는 등록 순서대로 불린다).
 * - 글자는 서버가 만든 마크다운을 화면 렌더러(PT_AI_RENDER: markdown-it + DOMPurify)로만 넣고, 이름 등은 textContent 로 넣는다.
 * - 퍼블리셔 템플릿(방식 2, 5단계): #ai4-publisher[data-on="1"] 안의 template[data-ab-block] 이 있는 블록은 그 틀로 그린다.
 *   틀은 DOMPurify 로 한 번 더 거르고, 칸 내용(위와 같은 div.ab__part)을 틀의 [data-ab-slot="칸"] 자리에 넣는다.
 *   자리가 없는 칸은 틀 밖 블록 끝에 붙인다. 내용이 없는 칸의 [data-ab-if="칸"] 요소는 지운다.
 *   틀로 그린 블록은 section.ab[data-publisher] (방식 1 디자인 CSS 는 걸리지 않음).
 *   2026-10-22: 안전 안내 칸·블록의 틀 밖 고정·숨김 방지(ai4-protect.css)를 없앴다 — 모든 칸·블록을 틀에서 똑같이 다룬다.
 * - 관리자 화면 틀 (CMS 블록 템플릿 1단계, 2026-10-21): template[data-ab-variant="{틀 id}"] 는 블록 데이터의 variant 로 고른다
 *   (section.ab[data-variant]). 서버가 done 에 design 을 실으면(화면 버전 ≠ 게시본) 같은 이벤트에서 틀·CSS 를 바꾸고 그린다.
 * - 틀 변수·행 반복 (2·3단계, 2026-10-21): 블록 vars·rows 로 {var} {#v}…{/v} {^v}…{/v}, data-ab-show/hide,
 *   data-ab-group="행 필드"(첫 등장 순서로 묶음) > data-ab-each="rows"(행마다 복제, data-item-index),
 *   data-ab-action="route|detail|tel|homepage"(행 안), img[data-ab-asset](#ai4-publisher[data-asset-base] + 파일 이름)을 채운다.
 *   행 반복의 바깥 요소는 [data-role="list-table"][data-map] 이 되어 지도·접기가 표처럼 다룬다. 자리 없는 표 칸은 그리지 않는다.
 */
(function (global) {
  "use strict";

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  /** ①~㊿ (FacilityService.circledNumber 와 같음) */
  function circled(n) {
    if (n >= 1 && n <= 20) return String.fromCharCode(0x2460 + n - 1);
    if (n >= 21 && n <= 35) return String.fromCharCode(0x3251 + n - 21);
    if (n >= 36 && n <= 50) return String.fromCharCode(0x32b1 + n - 36);
    return n + ".";
  }

  function renderInto(target, md) {
    var R = global.PT_AI_RENDER;
    if (R && typeof R.apply === "function") {
      R.apply(target, md || "", "markdown");
      target.removeAttribute("data-raw-text");
    } else {
      target.textContent = md || "";
    }
  }

  /** 표 칸의 짧은 마크다운 (전화 링크 등) → 문단 태그 없는 HTML */
  function renderInline(target, md) {
    // "-" 하나만 있는 칸(빈 값)은 마크다운에서 빈 목록이 되어 사라지므로 글자로 넣는다
    if (/^\s*[-–—]?\s*$/.test(md)) {
      target.textContent = (md || "").trim() || "-";
      return;
    }
    renderInto(target, md);
    var only = target.children.length === 1 && target.firstElementChild.tagName === "P" ? target.firstElementChild : null;
    if (only) {
      while (only.firstChild) target.insertBefore(only.firstChild, only);
      target.removeChild(only);
    }
  }

  function isWebUrl(u) {
    return typeof u === "string" && /^https?:\/\//i.test(u);
  }

  function nameCell(td, v) {
    td.appendChild(el("span", "ab-no", circled(Number(v.no) || 0))).setAttribute("data-role", "item-no");
    td.appendChild(document.createTextNode(" "));
    td.appendChild(el("span", "ab-name", v.name || "")).setAttribute("data-role", "item-name");
    var acts = el("span", "ai2-acts");
    if (isWebUrl(v.routeUrl)) {
      var a = el("a", "ab-act", v.routeLabel || "길찾기");
      a.href = v.routeUrl;
      a.target = "_blank";
      a.rel = "noopener noreferrer";
      a.setAttribute("data-action", "route");
      acts.appendChild(a);
    }
    if (v.detail && v.name) {
      var b = el("button", "ab-act", v.detailLabel || "상세");
      b.type = "button";
      b.setAttribute("data-action", "detail");
      b.setAttribute("data-name", v.name);
      b.setAttribute("data-query", v.detailQuery || v.name + " 상세정보");
      acts.appendChild(b);
    }
    if (acts.childNodes.length) td.appendChild(acts);
  }

  function buildTable(t) {
    var box = el("div", "ai2-tscroll");
    var table = el("table");
    table.setAttribute("data-role", t.role === "list" ? "list-table" : "table");
    if (t.map) table.setAttribute("data-map", "1");
    var cols = Array.isArray(t.cols) ? t.cols : [];
    var thead = el("thead");
    var htr = el("tr");
    cols.forEach(function (c) {
      var th = el("th", null, c.label || "");
      th.setAttribute("data-col", c.key);
      htr.appendChild(th);
    });
    thead.appendChild(htr);
    table.appendChild(thead);
    var tbody = el("tbody");
    (Array.isArray(t.rows) ? t.rows : []).forEach(function (r) {
      var tr = el("tr");
      if (typeof r.itemIndex === "number") tr.setAttribute("data-item-index", String(r.itemIndex));
      cols.forEach(function (c) {
        var td = el("td");
        td.setAttribute("data-col", c.key);
        var v = r.cells ? r.cells[c.key] : null;
        if (v && typeof v === "object") nameCell(td, v);
        else renderInline(td, v == null ? "-" : String(v));
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    box.appendChild(table);
    return box;
  }

  function markImages(section, images) {
    if (!Array.isArray(images) || !images.length) return;
    Array.prototype.forEach.call(section.querySelectorAll("a[href]"), function (a) {
      if (images.indexOf(a.getAttribute("href")) >= 0) a.setAttribute("data-role", "health-img");
    });
  }

  // ---- 퍼블리셔 템플릿 ----

  var publisher = null;

  /** 틀 HTML 을 DOMPurify 로 거른 template. 거를 수 없으면 null (그 블록은 기본 모양) */
  function clean(html) {
    if (!global.DOMPurify || typeof global.DOMPurify.sanitize !== "function") return null;
    var t = document.createElement("template");
    t.innerHTML = global.DOMPurify.sanitize(String(html || ""), {
      USE_PROFILES: { html: true },
      FORBID_TAGS: ["style", "form", "input", "button", "textarea", "select", "iframe", "object", "embed"]
    });
    return t;
  }

  /**
   * 페이지의 틀 (처음 한 번 DOMPurify 로 걸러 둔다).
   *   tpl    : 관리자 화면 틀 template[data-ab-variant] — 키 = 틀 id (블록 데이터 variant 와 짝)
   *   legacy : 옛 publisher 폴더 파일 틀 template[data-ab-block] — 키 = 블록 종류 (variant 없는 블록만)
   *   version: 이 화면의 답변 디자인 버전 (#ai4-publisher[data-version]). 질문을 보낼 때 함께 보낸다 (ai-core4.js)
   */
  function publisherSet() {
    if (publisher) return publisher;
    publisher = { on: false, tpl: {}, legacy: {}, version: "" };
    var box = document.getElementById("ai4-publisher");
    if (!box) return publisher;
    publisher.on = box.getAttribute("data-on") === "1";
    publisher.version = box.getAttribute("data-version") || "";
    Array.prototype.forEach.call(box.querySelectorAll("template[data-ab-variant]"), function (t) {
      var c = clean(t.innerHTML);
      if (c) publisher.tpl[t.getAttribute("data-ab-variant")] = c;
    });
    Array.prototype.forEach.call(box.querySelectorAll("template[data-ab-block]"), function (t) {
      var c = clean(t.innerHTML);
      if (c) publisher.legacy[t.getAttribute("data-ab-block")] = c;
    });
    return publisher;
  }

  /** 답변 디자인 CSS 주소: 같은 사이트의 /gwtpax/api4/answerCss.do 만 받는다 (DispatcherServlet 이 *.do 만 받으므로 .do, 2026-10-22) */
  var CSS_PATH = /\/gwtpax\/api4\/answerCss\.do$/;

  /**
   * 서버가 done 데이터에 실은 새 디자인 (화면 버전이 게시본과 다를 때만, CMS 블록 템플릿 1단계 2026-10-21).
   * 같은 ptai:answer 안에서 틀·CSS 주소·버전을 바꾸고 바로 그 답변을 그린다 — 따로 받아 다시 그리면
   * 지도·접기가 먼저 붙은 화면을 지우게 되므로.
   *   { version, cssUrl, on, hasVariants, templates: { 틀 id: html } }  (templates 는 이 답변이 쓴 틀만)
   */
  function applyDesign(d) {
    if (!d || typeof d !== "object") return;
    var P = publisherSet();
    P.on = !!d.on;
    if (d.hasVariants) P.legacy = {}; // 관리자 화면 틀이 있으면 옛 파일 틀은 쓰지 않는다 (서버와 같은 규칙)
    var t = d.templates && typeof d.templates === "object" ? d.templates : {};
    Object.keys(t).forEach(function (k) {
      var c = clean(t[k]);
      if (c) P.tpl[k] = c;
    });
    if (d.version) {
      P.version = String(d.version);
      var box = document.getElementById("ai4-publisher");
      if (box) box.setAttribute("data-version", P.version);
    }
    var link = document.getElementById("ai4-answer-css");
    if (link && typeof d.cssUrl === "string") {
      try {
        var u = new URL(d.cssUrl, global.location.href);
        if (u.origin === global.location.origin && CSS_PATH.test(u.pathname)) {
          link.setAttribute("href", u.pathname + u.search);
        }
      } catch (e) {
        /* 주소가 이상하면 CSS 는 그대로 */
      }
    }
  }

  function part(p) {
    var div = el("div", "ab__part");
    div.setAttribute("data-slot", p.slot || "body");
    div.setAttribute("data-kind", p.kind || "md");
    if (p.table) div.appendChild(buildTable(p.table));
    else renderInto(div, p.md);
    if (Array.isArray(p.tabs)) div.setAttribute("data-tabs", String(p.tabs.length));
    return div;
  }

  // ---- 틀 변수·행 반복 (CMS 블록 템플릿 2·3단계, 2026-10-21) ----
  // 서버(TemplateCheck)가 문법을 검사한 틀이다. 값은 글자(nodeValue)·속성값으로만 넣고, 주소는 http(s)·tel: 만 쓴다.

  var VAR = /\{([A-Za-z][A-Za-z0-9_]*)\}/g;
  var SECTION = /\{([#^])([A-Za-z][A-Za-z0-9_]*)\}([\s\S]*?)\{\/\2\}/g;
  var ASSET = /^[a-z0-9][a-z0-9-]{0,60}\.(png|jpg|jpeg|webp|svg)$/; // AnswerAssets.NAME 과 같음
  /** 변수를 넣을 수 있는 속성 (TemplateCheck 와 같은 규칙: href·src 는 안 됨) */
  var VAR_ATTR = /^(title|alt|aria-label|class|data-(?!ab-)[a-z0-9-]+)$/;

  function truthy(v) {
    return !(v == null || v === "" || v === false || v === 0);
  }

  /** "{#v}…{/v}" "{^v}…{/v}" 를 고른 뒤 "{v}" 를 값으로 바꾼 글자 */
  function fillText(s, scope) {
    var prev;
    do {
      prev = s;
      s = s.replace(SECTION, function (m, k, n, inner) { return (k === "#") === truthy(scope[n]) ? inner : ""; });
    } while (s !== prev);
    return s.replace(VAR, function (m, n) {
      var v = scope[n];
      return v == null || v === false ? "" : String(v);
    });
  }

  function merge(a, b) {
    var o = {};
    [a, b].forEach(function (x) { if (x) Object.keys(x).forEach(function (k) { o[k] = x[k]; }); });
    return o;
  }

  function all(root, sel) {
    var list = Array.prototype.slice.call(root.querySelectorAll(sel));
    if (root.nodeType === 1 && root.matches(sel)) list.unshift(root);
    return list;
  }

  /** 행 반복·묶음 요소를 주석 자리표로 떼어 낸다 (바깥 변수로 먼저 채우지 않게). [{ el, mark }] */
  function detach(root, sel) {
    var out = [];
    all(root, sel).forEach(function (e) {
      if (e === root) return;
      for (var p = e.parentNode; p && p !== root; p = p.parentNode) {
        if (p.nodeType === 1 && p.matches(sel)) return; // 가장 바깥 것만
      }
      var mark = document.createComment("ab-rows");
      e.parentNode.replaceChild(mark, e);
      out.push({ el: e, mark: mark });
    });
    return out;
  }

  /** 행 안의 버튼 자리 → 실제 링크·버튼 (데이터가 없으면 자리째 지운다) */
  function action(w, scope) {
    var kind = w.getAttribute("data-ab-action");
    var text = (w.textContent || "").trim();
    var c = null;
    if (kind === "route" && isWebUrl(scope.routeUrl)) {
      c = el("a", null, text || scope.routeLabel || "길찾기");
      c.href = scope.routeUrl;
    } else if (kind === "homepage" && isWebUrl(scope.homepageUrl)) {
      c = el("a", null, text || "홈페이지");
      c.href = scope.homepageUrl;
    } else if (kind === "tel" && /^\+?[0-9]{3,15}$/.test(String(scope.telDigits || ""))) {
      c = el("a", null, text || scope.tel || scope.telDigits);
      c.href = "tel:" + scope.telDigits;
    } else if (kind === "detail" && scope.detail && scope.name) {
      c = el("button", null, text || scope.detailLabel || "상세");
      c.type = "button";
      c.setAttribute("data-name", String(scope.name));
      c.setAttribute("data-query", String(scope.detailQuery || scope.name + " 상세정보"));
    }
    if (!c) {
      w.parentNode.removeChild(w);
      return;
    }
    if (c.tagName === "A") {
      c.target = "_blank";
      c.rel = "noopener noreferrer";
      if (kind === "tel") c.removeAttribute("target");
    }
    c.className = ((w.getAttribute("class") || "") + " ab-act").trim();
    c.setAttribute("data-action", kind);
    w.parentNode.replaceChild(c, w);
  }

  /** 한 범위(블록 변수 또는 블록 변수 + 행)로 변수·보이기/숨기기·버튼을 채운다 */
  function fillScope(root, scope) {
    all(root, "[data-ab-show],[data-ab-hide]").forEach(function (e) {
      var show = e.getAttribute("data-ab-show");
      var hide = e.getAttribute("data-ab-hide");
      var gone = (show != null && !truthy(scope[show])) || (hide != null && truthy(scope[hide]));
      if (gone && e.parentNode) e.parentNode.removeChild(e);
      e.removeAttribute("data-ab-show");
      e.removeAttribute("data-ab-hide");
    });
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
    var texts = [];
    while (walker.nextNode()) texts.push(walker.currentNode);
    texts.forEach(function (t) { if (t.nodeValue.indexOf("{") >= 0) t.nodeValue = fillText(t.nodeValue, scope); });
    all(root, "*").forEach(function (e) {
      Array.prototype.slice.call(e.attributes).forEach(function (a) {
        if (a.value.indexOf("{") >= 0 && VAR_ATTR.test(a.name)) e.setAttribute(a.name, fillText(a.value, scope));
      });
    });
    all(root, "[data-ab-action]").forEach(function (w) { if (w.parentNode) action(w, scope); });
  }

  function itemIndex(r, i) {
    return typeof r.itemIndex === "number" ? r.itemIndex : i;
  }

  /** 행마다 틀을 복제해 자리표 앞에 넣는다 */
  function expandEach(item, rows, vars) {
    var e = item.el;
    e.removeAttribute("data-ab-each");
    rows.forEach(function (r) {
      var c = e.cloneNode(true);
      c.setAttribute("data-item-index", String(itemIndex(r.row, r.i)));
      fillScope(c, merge(vars, r.row));
      item.mark.parentNode.insertBefore(c, item.mark);
    });
    item.mark.parentNode.removeChild(item.mark);
  }

  /** 행 필드 값(첫 등장 순서)으로 묶고, 묶음마다 안쪽 행 반복을 펼친다 */
  function expandGroup(item, rows, vars) {
    var e = item.el;
    var field = e.getAttribute("data-ab-group");
    e.removeAttribute("data-ab-group");
    var keys = [];
    var by = {};
    rows.forEach(function (r) {
      var k = r.row[field] == null ? "" : String(r.row[field]);
      if (!by.hasOwnProperty(k)) { by[k] = []; keys.push(k); }
      by[k].push(r);
    });
    keys.forEach(function (k) {
      var c = e.cloneNode(true);
      var inner = detach(c, "[data-ab-each]");
      fillScope(c, merge(vars, by[k][0].row));
      inner.forEach(function (it) { expandEach(it, by[k], vars); });
      item.mark.parentNode.insertBefore(c, item.mark);
    });
    item.mark.parentNode.removeChild(item.mark);
  }

  /**
   * 틀의 변수·행 반복·묶음·버튼·자산 그림을 채운다. 행 반복을 쓰면 그 바깥 요소가 목록(지도 짝)이 된다.
   * @returns {boolean} 행 반복이 있었는지 (그러면 표 칸은 자리가 없을 때 그리지 않는다)
   */
  function expand(frag, b) {
    var vars = b.vars && typeof b.vars === "object" ? b.vars : {};
    var rows = (Array.isArray(b.rows) ? b.rows : []).map(function (row, i) { return { row: row || {}, i: i }; });
    var items = detach(frag, "[data-ab-group],[data-ab-each]");
    fillScope(frag, vars);
    var map = (Array.isArray(b.parts) ? b.parts : []).some(function (p) { return p.table && p.table.map; });
    items.forEach(function (it) {
      var box = it.mark.parentNode;
      if (box.nodeType !== 1) { // 틀 맨 바깥이면 감싸 준다
        var w = el("div", "ab-rows");
        box.replaceChild(w, it.mark);
        w.appendChild(it.mark);
        box = w;
      }
      box.setAttribute("data-role", "list-table");
      if (map) box.setAttribute("data-map", "1");
      if (it.el.hasAttribute("data-ab-group")) expandGroup(it, rows, vars);
      else expandEach(it, rows, vars);
    });
    var base = (document.getElementById("ai4-publisher") || { getAttribute: function () { return null; } }).getAttribute("data-asset-base");
    Array.prototype.forEach.call(frag.querySelectorAll("[data-ab-asset]"), function (img) {
      var name = img.getAttribute("data-ab-asset");
      img.removeAttribute("data-ab-asset");
      if (img.tagName === "IMG" && base && ASSET.test(name)) img.setAttribute("src", base + name);
      else if (img.parentNode) img.parentNode.removeChild(img);
    });
    return items.length > 0;
  }

  /** 퍼블리셔 틀에 칸들을 넣는다. 틀이 없으면 false */
  function fillTemplate(sec, b, parts) {
    var P = publisherSet();
    // 관리자 화면 틀은 블록 데이터의 variant 로, 옛 파일 틀은 variant 가 없는 블록만 블록 종류로
    var tpl = P.on ? (b.variant ? P.tpl[b.variant] : P.legacy[b.type]) : null;
    if (!tpl) return false;
    var frag = tpl.content.cloneNode(true);
    var each = expand(frag, b);
    var spots = {};
    Array.prototype.forEach.call(frag.querySelectorAll("[data-ab-slot]"), function (e) {
      var k = e.getAttribute("data-ab-slot");
      if (!spots[k]) spots[k] = e;
    });
    var filled = {};
    var tail = [];
    parts.forEach(function (div, i) {
      var p = b.parts[i];
      if (each && p.table && !spots[p.slot]) return; // 행 반복이 표를 대신한다
      if (!spots[p.slot]) {
        tail.push(div);
      } else {
        spots[p.slot].appendChild(div);
        filled[p.slot] = true;
      }
    });
    Array.prototype.forEach.call(frag.querySelectorAll("[data-ab-if]"), function (e) {
      if (!filled[e.getAttribute("data-ab-if")] && e.parentNode) e.parentNode.removeChild(e);
    });
    sec.setAttribute("data-publisher", "1");
    if (b.variant) sec.setAttribute("data-variant", String(b.variant)); // 틀 CSS 는 .ab[data-variant="{id}"] 아래로 감싸져 있다
    sec.appendChild(frag);
    tail.forEach(function (div) { sec.appendChild(div); });
    return true;
  }

  /** @returns {boolean} 블록으로 다시 그렸는지 */
  function render(body, blocks) {
    if (!body || !Array.isArray(blocks) || !blocks.length) return false;
    var frag = document.createDocumentFragment();
    blocks.forEach(function (b, bi) {
      var sec = el("section", "ab");
      sec.setAttribute("data-block", b.type || "markdown");
      sec.setAttribute("data-block-index", String(bi));
      var parts = (Array.isArray(b.parts) ? b.parts : []).map(part);
      if (!fillTemplate(sec, b, parts)) {
        parts.forEach(function (div) { sec.appendChild(div); });
      }
      markImages(sec, b.meta && b.meta.images);
      frag.appendChild(sec);
    });
    body.textContent = "";
    body.appendChild(frag);
    body.setAttribute("data-blocks", "1");
    return true;
  }

  global.PT_AI4_BLOCKS = {
    render: render,
    circled: circled,
    /** 퍼블리셔 템플릿을 켜고 끈다 (관리자 미리보기). 틀이 없는 블록은 언제나 기본 모양 */
    setPublisher: function (on) { publisherSet().on = !!on; },
    /** 페이지의 퍼블리셔 틀을 다시 읽는다 (틀을 나중에 넣은 확인 페이지용) */
    resetPublisher: function () { publisher = null; },
    /** 틀이 있는 것: 관리자 화면 틀 id + 옛 파일 틀 블록 종류 */
    publisherBlocks: function () { var P = publisherSet(); return Object.keys(P.tpl).concat(Object.keys(P.legacy)); },
    /** 이 화면의 답변 디자인 버전 (없으면 null). ai-core4.js 가 질문 요청에 싣는다 */
    designVersion: function () { return publisherSet().version || null; },
    /**
     * 관리자 미리보기: 편집 중인 틀로 바꾼다 (서버가 검사한 틀, 여기서도 DOMPurify).
     * hasVariants 면 옛 파일 틀은 쓰지 않는다
     */
    setTemplates: function (map, on, hasVariants) {
      var P = publisherSet();
      P.tpl = {};
      Object.keys(map || {}).forEach(function (k) {
        var c = clean(map[k]);
        if (c) P.tpl[k] = c;
      });
      P.on = !!on;
      if (hasVariants) P.legacy = {};
    },
    applyDesign: applyDesign
  };

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!d.body || data.source !== "gwtpax-agent") return;
    try {
      if (data.design) applyDesign(data.design); // 게시본이 바뀌었으면 새 틀로 이 답변부터
      render(d.body, data.blocks);
    } catch (err) {
      // 다시 그리기에 실패하면 타자기가 찍은 마크다운 그대로 둔다
      if (global.console) console.warn("[ai4-blocks] render failed", err);
    }
  });
})(window);
