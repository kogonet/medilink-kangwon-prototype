/**
 * AI 상담4 답변 디자인 미리보기 틀 (design-preview.jsp, 관리자 화면 안의 iframe, 2026-10-16).
 * - 부모(관리자 /admmgr/ai4/design.do)가 { type: "ai4-design-preview", draft } 를 postMessage 로 보내면
 *   POST /admmgr/ai4/designPreview.do 로 미리보기 답변(samples)과 CSS 를 받아 그린다. 저장하지 않는다.
 * - 답변은 상담 화면과 같은 순서로 그린다: 마크다운 렌더 → "ptai:answer" → answer-blocks.js(블록) → answer-fold.js(탭·접기).
 * - CSS 는 서버가 검사한 값으로 만든 것만 오고, style 요소에 textContent 로 넣는다. { type: "ai4-design-css", css } 는 CSS 만 바꾼다.
 * - "퍼블리셔 템플릿 사용"(draft.usePublisher)이면 퍼블리셔 틀(answer-blocks.js)과 CSS(link[data-publisher-css])를 켠다.
 * - 편집 화면 연동 (2026-10-16 UI 개선):
 *   그린 뒤 편집 중인 CSS 를 잠깐 빼고 실제 기본값을 읽어 보낸다 (ai4-design-defaults).
 *   클릭한 블록·칸을 알리면 (ai4-design-pick) 부모가 고칠 문구·디자인 목록을 보내고 (ai4-design-menu), 클릭 위치에 메뉴를 띄워
 *   고른 것을 돌려준다 (ai4-design-go). 부모가 고른 대상을 테두리로 강조한다 (ai4-design-focus → ai4-design-focus-done).
 *   테두리·이름표는 pointer-events:none 인 덮개로만 그리고 답변 DOM 은 바꾸지 않는다.
 * - 같은 출처(origin)의 메시지만 받는다.
 */
(function (global) {
  "use strict";

  var api = document.body.getAttribute("data-api");
  var nav = document.getElementById("nav");
  var list = document.getElementById("samples");
  var statusEl = document.getElementById("status");
  var cssEl = document.getElementById("draft-css");
  var current = null;
  /** 부모가 보낸 이름표 (블록·칸 이름) */
  var labels = { blocks: {}, slots: {}, prot: {} };
  /** 마지막으로 강조한 대상 (다시 그린 뒤 테두리를 다시 건다) */
  var lastFocus = null;

  // answer-fold.js 가 타이핑 중 탭 판단에 쓰는 done 데이터 (미리보기는 바로 최종 화면이라 지금 그리는 답변의 데이터)
  if (global.PT_AI_API) global.PT_AI_API.getLastDoneData = function () { return current; };

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function tell(msg) {
    if (global.parent && global.parent !== global) global.parent.postMessage(msg, location.origin);
  }

  function status(text, error) {
    statusEl.textContent = text;
    statusEl.className = "dp-status" + (error ? " is-error" : "");
  }

  // ---- 기본값 읽기 ----

  var probe = null;

  /** CSS 색 → #rrggbb (완전 투명이면 null) */
  function hex(c) {
    if (!c) return null;
    var m = /rgba?\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)(?:[,\s/]+([\d.]+%?))?\s*\)/.exec(c);
    if (!m) {
      // 이름 색·hex 등은 계산값으로 바꿔 다시 읽는다
      if (!probe) { probe = el("span"); probe.style.display = "none"; document.body.appendChild(probe); }
      probe.style.color = "";
      probe.style.color = c;
      var cc = getComputedStyle(probe).color;
      return cc && cc !== c ? hex(cc) : null;
    }
    if (m[4] != null && parseFloat(m[4]) === 0) return null;
    return "#" + [m[1], m[2], m[3]].map(function (v) { var h = Number(v).toString(16); return h.length < 2 ? "0" + h : h; }).join("");
  }

  function px(v) {
    var n = parseFloat(v);
    return isNaN(n) ? null : Math.round(n);
  }

  function weight(v) {
    var n = parseInt(v, 10);
    if (isNaN(n)) n = v === "bold" ? 700 : 400;
    var best = 400;
    [400, 500, 600, 700, 800].forEach(function (w) { if (Math.abs(w - n) < Math.abs(best - n)) best = w; });
    return best;
  }

  function align(v) {
    if (v === "start" || v === "left" || v === "justify" || v === "-webkit-left") return "left";
    if (v === "end" || v === "right" || v === "-webkit-right") return "right";
    if (v === "center" || v === "-webkit-center") return "center";
    return null;
  }

  /** 상자 항목 (배경·여백·테두리). notes 에 padding 이 네 변 다를 때 설명을 넣는다 */
  function boxOf(e, keys, notes) {
    var cs = getComputedStyle(e);
    var o = {};
    if (keys.background) o.background = hex(cs.backgroundColor);
    if (keys.padding) {
      var p = [cs.paddingTop, cs.paddingRight, cs.paddingBottom, cs.paddingLeft].map(px);
      if (p[0] === p[1] && p[1] === p[2] && p[2] === p[3]) o.padding = p[0];
      else {
        o.padding = null;
        notes.padding = (p[0] === p[2] && p[1] === p[3]) ? "위아래 " + p[0] + " · 옆 " + p[1] : "위 " + p[0] + " · 오른쪽 " + p[1] + " · 아래 " + p[2] + " · 왼쪽 " + p[3];
      }
    }
    if (keys.marginTop) o.marginTop = px(cs.marginTop);
    if (keys.marginBottom) o.marginBottom = px(cs.marginBottom);
    if (keys.border) {
      var w = px(cs.borderTopWidth);
      if (cs.borderTopStyle === "none" || !w) { o.borderWidth = 0; o.borderColor = null; notes.borderColor = "없음"; }
      else { o.borderWidth = w; o.borderColor = hex(cs.borderTopColor); }
    }
    if (keys.radius) o.borderRadius = px(cs.borderTopLeftRadius);
    return o;
  }

  /** 칸 안 첫 글자의 문단 요소 (p·li·h3·td 등. 굵게·링크 같은 글자 안 요소는 건너뜀, 없으면 칸 자신) */
  function textHolder(part) {
    var w = document.createTreeWalker(part, NodeFilter.SHOW_TEXT, null, false);
    var n;
    while ((n = w.nextNode())) {
      if (!/\S/.test(n.nodeValue)) continue;
      var e = n.parentNode;
      while (e && e !== part && /^inline/.test(getComputedStyle(e).display) && getComputedStyle(e).display !== "inline-block") e = e.parentNode;
      return e && part.contains(e) ? e : part;
    }
    return part;
  }

  function textOf(e) {
    var cs = getComputedStyle(e);
    return { color: hex(cs.color), fontSize: px(cs.fontSize), fontWeight: weight(cs.fontWeight), textAlign: align(cs.textAlign) };
  }

  /** 계산값으로 읽을 수 없는 :hover·.is-active 행 배경은 스타일시트 규칙에서 찾는다 */
  function ruleBackground(test) {
    var found = null;
    Array.prototype.forEach.call(document.styleSheets, function (sh) {
      if (found || sh === cssEl.sheet) return;
      var rules;
      try { rules = sh.cssRules; } catch (e) { return; } // 다른 출처 시트
      Array.prototype.forEach.call(rules || [], function (r) {
        if (!found && r.selectorText && test(r.selectorText) && r.style && r.style.backgroundColor) found = hex(r.style.backgroundColor);
      });
    });
    return found;
  }

  function tableOf(b) {
    var t = b.querySelector("table");
    if (!t) return null;
    var o = { fontSize: px(getComputedStyle(t).fontSize) };
    var th = t.querySelector("thead th") || t.querySelector("th");
    if (th) {
      var cs = getComputedStyle(th);
      o.headBackground = hex(cs.backgroundColor) || hex(getComputedStyle(th.parentNode).backgroundColor);
      o.headColor = hex(cs.color);
    }
    var even = t.querySelector("tbody tr:nth-child(even) > td");
    if (even) o.stripeBackground = hex(getComputedStyle(even).backgroundColor);
    var td = t.querySelector("td") || th;
    if (td) {
      var tcs = getComputedStyle(td);
      o.borderColor = tcs.borderTopStyle === "none" || !px(tcs.borderTopWidth) ? hex(getComputedStyle(t).borderTopColor) : hex(tcs.borderTopColor);
    }
    o.hoverBackground = ruleBackground(function (s) { return s.indexOf("tr.ai2-row-link:hover > td") >= 0; });
    o.activeBackground = ruleBackground(function (s) { return s.indexOf("tr.ai2-row-link.is-active > td") >= 0 && s.indexOf("first-child") < 0; });
    return o;
  }

  function actionsOf(b) {
    var a = b.querySelector("[data-action]");
    if (!a) return null;
    var cs = getComputedStyle(a);
    var bw = px(cs.borderTopWidth);
    return {
      color: hex(cs.color), background: hex(cs.backgroundColor),
      borderColor: cs.borderTopStyle === "none" || !bw ? null : hex(cs.borderTopColor), borderRadius: px(cs.borderTopLeftRadius)
    };
  }

  function partsOf(b) {
    return Array.prototype.filter.call(b.querySelectorAll(".ab__part[data-slot]"), function (p) { return p.closest(".ab") === b; });
  }

  /** 한 블록의 기본값을 out[key] 에 채운다 (이미 읽은 칸은 건너뜀 = 첫 번째 것) */
  function measureBlock(b, out) {
    if (!out.block) {
      out.notes.block = {};
      out.block = boxOf(b, { background: 1, padding: 1, marginBottom: 1, border: 1, radius: 1 }, out.notes.block);
    }
    partsOf(b).forEach(function (p) {
      var slot = p.getAttribute("data-slot");
      if (out.slots[slot]) return;
      var notes = out.notes["slots." + slot] = {};
      var o = boxOf(p, { background: 1, padding: 1, marginTop: 1, marginBottom: 1, border: 1, radius: 1 }, notes);
      var t = textOf(textHolder(p));
      Object.keys(t).forEach(function (k) { o[k] = t[k]; });
      out.slots[slot] = o;
    });
    if (!out.table) out.table = tableOf(b);
    if (!out.actions) out.actions = actionsOf(b);
  }

  /** 틀로만 그린 블록 종류 (틀 없이 그린 같은 종류가 하나도 없을 때. 모든 블록이 틀이면 "*" 도) */
  function templatedTypes(res) {
    var out = [];
    Array.prototype.forEach.call(list.querySelectorAll(".ab[data-block][data-publisher]"), function (b) {
      var type = b.getAttribute("data-block");
      if (!res[type] && out.indexOf(type) < 0) out.push(type);
    });
    if (out.length && !res["*"]) out.push("*");
    return out;
  }

  /** 편집 중인 CSS 를 잠깐 빼고 읽는다 (같은 작업 안이라 화면은 바뀌지 않는다). 틀로 그린 블록은 디자인 값이 걸리지 않아 읽지 않는다 */
  function measure() {
    var saved = cssEl.textContent;
    cssEl.textContent = "";
    var res = {};
    try {
      Array.prototype.forEach.call(list.querySelectorAll(".ab[data-block]:not([data-publisher])"), function (b) {
        ["*", b.getAttribute("data-block")].forEach(function (type) {
          var out = res[type] || (res[type] = { slots: {}, notes: {} });
          measureBlock(b, out);
        });
      });
    } finally {
      cssEl.textContent = saved;
    }
    tell({ type: "ai4-design-defaults", blocks: res, templated: templatedTypes(res) });
  }

  // ---- 덮개 (테두리·이름표) ----

  var layer = el("div", "dp-ov");
  var hoverBox = el("div", "dp-ov__hover");
  var tag = el("div", "dp-ov__tag");
  var selBoxes = [];
  layer.appendChild(hoverBox);
  layer.appendChild(tag);
  document.body.appendChild(layer);
  hoverBox.hidden = true;
  tag.hidden = true;

  function place(box, e) {
    var r = e.getBoundingClientRect();
    box.style.left = (r.left + global.pageXOffset - 3) + "px";
    box.style.top = (r.top + global.pageYOffset - 3) + "px";
    box.style.width = (r.width + 6) + "px";
    box.style.height = (r.height + 6) + "px";
    return r;
  }

  function clearSelect() {
    selBoxes.forEach(function (b) { b.parentNode && b.parentNode.removeChild(b); });
    selBoxes = [];
  }

  function nameOf(block, target) {
    var name = labels.blocks[block] || block;
    if (!target || target.group === "block") return name + " › 블록 상자";
    if (target.group === "table") return name + " › 표" + (target.col ? " (" + target.col + ")" : "");
    if (target.group === "actions") return name + " › 길찾기·상세 버튼";
    var s = (labels.slots[block] || {})[target.slot] || (labels.slots["*"] || {})[target.slot] || target.slot;
    return name + " › " + s;
  }

  // ---- 대상 찾기 ----

  /** 클릭·마우스 위치 → { block, target, el } */
  function targetAt(node) {
    if (!node || !node.closest) return null;
    var b = node.closest(".ab[data-block]");
    if (!b || !list.contains(b)) return null;
    var type = b.getAttribute("data-block");
    var act = node.closest("[data-action]");
    if (act && b.contains(act)) return { block: type, target: { group: "actions" }, el: act, blockEl: b };
    var th = node.closest("th[data-col]");
    if (th && b.contains(th)) return { block: type, target: { group: "table", col: th.getAttribute("data-col") }, el: th.closest("table"), blockEl: b };
    var tbl = node.closest("table");
    if (tbl && b.contains(tbl)) return { block: type, target: { group: "table" }, el: tbl, blockEl: b };
    var part = node.closest(".ab__part[data-slot]");
    if (part && part.closest(".ab") === b) return { block: type, target: { group: "slot", slot: part.getAttribute("data-slot") }, el: part, blockEl: b };
    return { block: type, target: { group: "block" }, el: b, blockEl: b };
  }

  /** 대상 요소 묶음: 블록 하나당 한 묶음 ("*" 이면 모든 블록) */
  function matches(block, target) {
    var sel = block === "*" ? ".ab[data-block]" : ".ab[data-block=\"" + block + "\"]";
    var out = [];
    Array.prototype.forEach.call(list.querySelectorAll(sel), function (b) {
      var els = [];
      var g = target ? target.group : "block";
      if (g === "block") els = [b];
      else if (g === "slot") els = partsOf(b).filter(function (p) { return p.getAttribute("data-slot") === target.slot; });
      else if (g === "table") {
        if (target.col) els = Array.prototype.slice.call(b.querySelectorAll("th[data-col=\"" + target.col + "\"]"));
        else els = Array.prototype.slice.call(b.querySelectorAll("table"));
      } else if (g === "actions") els = Array.prototype.slice.call(b.querySelectorAll("[data-action]"));
      if (els.length) out.push(els);
    });
    return out;
  }

  function drawSelect(f, scroll) {
    clearSelect();
    var groups = matches(f.block, f.target);
    if (!groups.length) return { index: 0, count: 0 };
    var i = ((f.step || 0) % groups.length + groups.length) % groups.length;
    groups.forEach(function (els, gi) {
      if (gi !== i && f.block !== "*") return;
      els.forEach(function (e) {
        var box = el("div", "dp-ov__sel" + (gi === i ? "" : " is-soft") + (scroll && gi === i ? " is-flash" : ""));
        layer.appendChild(box);
        place(box, e);
        selBoxes.push(box);
      });
    });
    if (scroll) groups[i][0].scrollIntoView({ block: "center", behavior: "smooth" });
    return { index: i, count: groups.length };
  }

  function hideHover() {
    hoverBox.hidden = true;
    tag.hidden = true;
  }

  function showHover(e, block, target, label) {
    hoverBox.hidden = false;
    var r = place(hoverBox, e);
    tag.hidden = false;
    tag.textContent = label || nameOf(block, target);
    tag.style.left = Math.max(0, r.left + global.pageXOffset) + "px";
    tag.style.top = Math.max(0, r.top + global.pageYOffset - 24) + "px";
  }

  function redraw() {
    if (lastFocus) drawSelect(lastFocus, false);
  }

  // 미리보기 위 마우스: 대상 이름표
  list.addEventListener("mousemove", function (ev) {
    if (menu) return; // 메뉴를 연 동안은 이름표를 띄우지 않는다
    var t = targetAt(ev.target);
    if (!t) { hideHover(); return; }
    showHover(t.el, t.block, t.target);
  });
  list.addEventListener("mouseleave", hideHover);

  // ---- 클릭 위치 메뉴 (문구 / 디자인 중 고르기) ----

  var menu = null;

  function closeMenu() {
    if (menu && menu.parentNode) menu.parentNode.removeChild(menu);
    menu = null;
  }

  /** 부모가 계산한 항목으로 메뉴를 그린다: { x, y, title, texts:[{key,label,code}], textNote, style:{label}|null, styleNote } */
  function openMenu(m) {
    closeMenu();
    menu = el("div", "dp-menu");
    menu.setAttribute("role", "menu");
    var head = el("div", "dp-menu__head", m.title || "");
    menu.appendChild(head);
    function go(choice) {
      closeMenu();
      tell({ type: "ai4-design-go", choice: choice });
    }
    function item(cls, text, sub, choice) {
      var b = el("button", "dp-menu__item " + cls);
      b.type = "button";
      b.setAttribute("role", "menuitem");
      b.appendChild(document.createTextNode(text));
      if (sub) b.appendChild(el("code", null, sub));
      b.onclick = function (e) { e.preventDefault(); e.stopPropagation(); go(choice); };
      return b;
    }
    menu.appendChild(el("div", "dp-menu__sec", "✎ 문구"));
    if (m.texts && m.texts.length) {
      m.texts.forEach(function (t) {
        menu.appendChild(item("is-text", t.label, t.code, { kind: "text", key: t.key }));
      });
    } else {
      menu.appendChild(el("div", "dp-menu__none", m.textNote || "고칠 문구 없음"));
    }
    menu.appendChild(el("div", "dp-menu__sec", "🎨 디자인"));
    if (m.style) menu.appendChild(item("is-style", m.style.label, null, { kind: "style" }));
    else menu.appendChild(el("div", "dp-menu__none", m.styleNote || "고칠 디자인 없음"));
    document.body.appendChild(menu);
    // 화면 밖으로 나가지 않게
    var vw = document.documentElement.clientWidth;
    var vh = global.innerHeight;
    var w = menu.offsetWidth;
    var h = menu.offsetHeight;
    var x = Math.min(m.x, global.pageXOffset + vw - w - 8);
    var y = m.y + 8;
    if (y + h > global.pageYOffset + vh - 8) y = Math.max(global.pageYOffset + 8, m.y - h - 8);
    menu.style.left = Math.max(global.pageXOffset + 8, x) + "px";
    menu.style.top = y + "px";
    var first = menu.querySelector("button");
    if (first) first.focus({ preventScroll: true });
  }

  document.addEventListener("keydown", function (e) {
    if (!menu) return;
    if (e.key === "Escape") { closeMenu(); return; }
    if (e.key === "ArrowDown" || e.key === "ArrowUp") {
      var bs = Array.prototype.slice.call(menu.querySelectorAll("button"));
      var i = bs.indexOf(document.activeElement);
      var next = bs[(i + (e.key === "ArrowDown" ? 1 : -1) + bs.length) % bs.length];
      if (next) { e.preventDefault(); next.focus(); }
    }
  });

  // 미리보기 클릭: 그 자리에 문구/디자인 메뉴. 답변 안 링크·버튼의 원래 동작(새 창·상세 질문)은 막는다. 탭·접기·그림 버튼은 그대로
  global.addEventListener("click", function (ev) {
    var n = ev.target;
    if (menu && n && n.closest && n.closest(".dp-menu")) return;
    closeMenu();
    if (!n || !n.closest || !list.contains(n)) return;
    if (n.closest(".ai2-tabs button, .ai2-fold__btn, .ai2-img-btn, img.ai2-health-img")) return;
    var t = targetAt(n);
    if (!t) return;
    ev.preventDefault();
    ev.stopPropagation();
    var groups = matches(t.block, t.target);
    var index = 0;
    groups.forEach(function (els, gi) { if (els.indexOf(t.el) >= 0 || (t.target.group === "block" && els[0] === t.blockEl)) index = gi; });
    lastFocus = { block: t.block, target: t.target, step: index };
    drawSelect(lastFocus, false);
    hideHover();
    // 부모가 문구·디자인 항목을 계산해 ai4-design-menu 로 돌려준다
    tell({ type: "ai4-design-pick", block: t.block, target: t.target, index: index, count: groups.length,
      x: ev.pageX, y: ev.pageY });
  }, true);

  global.addEventListener("resize", redraw);

  // ---- 대표 답변 바로가기 (위쪽 칩) ----

  /** 답변 샘플의 블록 종류 (나온 순서, 중복 없음) */
  function blockTypes(s) {
    var out = [];
    ((s.data && s.data.blocks) || []).forEach(function (b) {
      if (b && b.type && out.indexOf(b.type) < 0) out.push(b.type);
    });
    return out;
  }

  function setActiveChip(a) {
    Array.prototype.forEach.call(nav.querySelectorAll("a"), function (x) {
      x.classList.toggle("is-on", x === a);
      if (x === a) x.setAttribute("aria-current", "true");
      else x.removeAttribute("aria-current");
    });
  }

  // 칩: 미리보기 안에서만 이동한다 (주소 # 이동은 관리자 화면까지 같이 스크롤해서 쓰지 않음). 카드가 칩 줄 아래에 보이게 맞추고 깜빡인다
  nav.addEventListener("click", function (e) {
    var a = e.target.closest ? e.target.closest("a") : null;
    if (!a || !nav.contains(a)) return;
    e.preventDefault();
    var card = document.getElementById((a.getAttribute("href") || "").slice(1));
    if (!card) return;
    var top = card.getBoundingClientRect().top + global.pageYOffset - nav.offsetHeight - 8;
    spyPause = Date.now() + 900;
    setActiveChip(a);
    global.scrollTo({ top: Math.max(0, top), behavior: "smooth" });
    card.classList.remove("is-flash");
    void card.offsetWidth;
    card.classList.add("is-flash");
    global.setTimeout(function () { card.classList.remove("is-flash"); }, 1300);
    var types = (a.getAttribute("data-blocks") || "").split(",").filter(Boolean);
    tell({ type: "ai4-design-sample", id: card.id, label: a.textContent, blocks: types });
  });

  // 지금 보고 있는 답변의 칩 표시 (칩으로 이동하는 동안은 잠깐 멈춤)
  var spyPause = 0;
  var spyQueued = false;
  function spy() {
    spyQueued = false;
    if (Date.now() < spyPause) return;
    var line = nav.getBoundingClientRect().bottom + 24;
    var cur = null;
    Array.prototype.forEach.call(list.querySelectorAll(".dp-card"), function (c) {
      if (c.getBoundingClientRect().top <= line) cur = c;
    });
    if (!cur && list.firstElementChild) cur = list.firstElementChild;
    var a = cur ? nav.querySelector("a[href=\"#" + cur.id + "\"]") : null;
    setActiveChip(a);
  }
  global.addEventListener("scroll", function () {
    if (spyQueued) return;
    spyQueued = true;
    global.requestAnimationFrame(spy);
  });

  // ---- 그리기 ----

  function render(res) {
    var y = global.pageYOffset;
    cssEl.textContent = res.css || "";
    nav.textContent = "";
    nav.appendChild(el("span", "dp-nav__label", "대표 답변 바로가기"));
    list.textContent = "";
    clearSelect();
    hideHover();
    closeMenu();
    (res.samples || []).forEach(function (s, i) {
      var card = el("section", "dp-card");
      card.id = "dp-" + (s.id || i);
      card.appendChild(el("h2", null, s.label || s.id));
      // 이 답변의 블록이 어느 틀로 그려졌는지 (CMS 블록 템플릿 4단계 할당 확인, 2026-10-21)
      var used = ((s.data && s.data.blocks) || []).filter(function (b) { return b.variant; }).map(function (b) {
        return (labels.blocks[b.type] || b.type) + " → " + b.variant + (b.source ? " (출처 " + b.source + ")" : "");
      });
      if (used.length) {
        var tag = el("p", "dp-tpl", "쓴 틀: " + used.join(" · "));
        tag.style.cssText = "margin:-6px 0 10px;font-size:11px;color:#5A6A8C;";
        card.appendChild(tag);
      }
      var a = el("a", null, s.label || s.id);
      a.href = "#" + card.id;
      var types = blockTypes(s);
      a.setAttribute("data-blocks", types.join(","));
      a.title = types.length ? "이 답변의 블록: " + types.map(function (t) { return labels.blocks[t] || t; }).join(", ") : "";
      nav.appendChild(a);
      if (s.error) {
        card.appendChild(el("p", "dp-err", "이 답변을 만들지 못했습니다: " + s.error));
      } else {
        var body = el("div", "kp-answer-card__body");
        body.setAttribute("data-knuh-answer-style", "sample");
        card.appendChild(body);
        current = s.data;
        global.PT_AI_RENDER.apply(body, s.markdown || "", "markdown");
        try {
          global.dispatchEvent(new CustomEvent("ptai:answer", { detail: { body: body, data: s.data || {} } }));
        } catch (e) {
          /* CustomEvent 미지원 */
        }
      }
      list.appendChild(card);
    });
    current = null;
    // 다시 그려도 보던 자리 유지
    global.scrollTo(0, y);
    spy();
    var errs = res.errors || [];
    status(errs.length ? "고칠 값이 " + errs.length + "개 있어 그 값은 빼고 보여 드립니다." : "편집 중인 값으로 그린 미리보기입니다 (저장되지 않음).", errs.length > 0);
    tell({ type: "ai4-design-preview-done", errors: errs, warnings: res.warnings || [], version: res.version || null });
    // 접기·탭 처리가 끝난 뒤 기본값을 읽고 강조를 다시 건다
    setTimeout(function () { measure(); redraw(); }, 60);
  }

  /**
   * 틀 켜고 끄기: 틀은 answer-blocks.js, CSS 는 media 로.
   * hasVariants(관리자 화면 틀이 있음)면 publisher 폴더 파일 틀·CSS 는 끈다 (상담 화면과 같은 규칙).
   * 관리자 화면 틀의 CSS 는 서버가 감싸서 res.css(style#draft-css)에 넣어 준다.
   */
  function publisher(on, hasVariants) {
    if (global.PT_AI4_BLOCKS && global.PT_AI4_BLOCKS.setPublisher) global.PT_AI4_BLOCKS.setPublisher(on);
    Array.prototype.forEach.call(document.querySelectorAll("link[data-publisher-css]"), function (l) {
      l.media = on && !hasVariants ? "all" : "not all";
    });
  }

  /** 서버가 검사한 편집 중인 틀로 바꾼다 (CMS 블록 템플릿 1단계). 그리기 전에 부른다 */
  function templates(draft, res) {
    var on = !!(draft && draft.usePublisher);
    var hasVariants = !!(res && res.hasVariants);
    var B = global.PT_AI4_BLOCKS;
    if (B && typeof B.resetPublisher === "function" && typeof B.setTemplates === "function") {
      B.resetPublisher(); // 파일 틀(#ai4-publisher)을 다시 읽은 뒤 편집 중인 틀을 얹는다 (틀을 지웠다 되돌린 경우 대비)
      B.setTemplates((res && res.templates) || {}, on, hasVariants);
    }
    publisher(on, hasVariants);
  }

  function run(draft) {
    publisher(!!(draft && draft.usePublisher), false);
    status("미리보기 답변을 만들고 있습니다…", false);
    fetch(api, {
      method: "POST",
      credentials: "same-origin",
      headers: { "Content-Type": "application/json", "X-Requested-With": "XMLHttpRequest" },
      body: JSON.stringify(draft || {})
    })
      .then(function (r) {
        if (!r.ok) throw new Error("HTTP " + r.status);
        return r.json();
      })
      .then(function (res) {
        templates(draft, res);
        render(res);
      })
      .catch(function (err) {
        status("미리보기를 만들지 못했습니다: " + err.message, true);
        tell({ type: "ai4-design-preview-done", errors: ["미리보기를 만들지 못했습니다: " + err.message] });
      });
  }

  global.addEventListener("message", function (e) {
    if (e.origin !== location.origin || !e.data) return;
    var d = e.data;
    if (d.type === "ai4-design-preview") run(d.draft);
    else if (d.type === "ai4-design-css") {
      cssEl.textContent = d.css || "";
      global.requestAnimationFrame(redraw);
    } else if (d.type === "ai4-design-menu") {
      openMenu(d.menu || {});
    } else if (d.type === "ai4-design-labels") {
      labels = d.labels || labels;
    } else if (d.type === "ai4-design-focus") {
      if (d.mode === "clear") { hideHover(); return; }
      if (d.mode === "hover") {
        var g = matches(d.block, d.target);
        if (g.length) showHover(g[0][0], d.block, d.target, d.label);
        else hideHover();
        return;
      }
      lastFocus = { block: d.block, target: d.target, step: d.step || 0 };
      var r = drawSelect(lastFocus, d.scroll !== false);
      tell({ type: "ai4-design-focus-done", index: r.index, count: r.count });
    }
  });

  tell({ type: "ai4-design-preview-ready" });
})(window);
