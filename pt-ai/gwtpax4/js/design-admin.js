/**
 * AI 상담4 답변 디자인 관리자 화면 (admmgr/ai4/design.jsp, 2026-10-16 답변 템플릿 빌더 4단계).
 * - /admmgr/ai4/designData.do 의 편집 항목 목록(meta)으로 블록별 "문구"·"디자인" 폼을 그린다.
 * - 임시 저장(designSave.do) → 미리보기(iframe design-preview.jsp 에 postMessage) → 게시(designPublish.do), 이력 불러오기(designLoad.do).
 * - 문구는 기본과 다른 것만, 디자인 값은 기준값(모든 블록 값 → 미리보기에서 읽은 기본값)과 다른 것만 보낸다. 검사는 서버가 하고 오류 문구를 그대로 보여 준다.
 * - 저장하지 않은 변경이 있으면 게시를 막고, 화면을 떠날 때 묻는다. 모든 글자는 textContent 로 넣는다.
 * - UI 개선 (2026-10-16, docs/specs/2026-10-16-ai4-design-editor-ui.md):
 *   디자인 입력칸에 실제 적용 값 채우기, 그룹·블록 전체 초기화, 편집 항목 ↔ 미리보기 강조
 *   (미리보기 클릭 → 그 자리 메뉴에서 문구/디자인 고르기 → 편집 영역 이동),
 *   미리보기 자동 갱신(디자인 값은 designCss.do 로 CSS 만, 문구는 전체), 좌우 폭 드래그.
 *   2026-10-22: 안전 안내 블록·칸 제한(틀 금지, 칸 칩 막음, 13px·대비 4.5 하한, 필수 단어 표시)을 없앴다.
 * - [틀] 탭 (CMS 블록 템플릿 1단계, 2026-10-21): 블록마다 HTML 틀·CSS({블록}.default), "모든 블록"이면 공통 CSS.
 *   칸 칩을 누르면 커서 자리에 <div data-ab-slot="칸"></div> 를 넣는다. 검사는 서버(BlockVariants)가 하고
 *   미리보기 응답의 오류·참고 중 그 블록 것을 탭 아래에 보여 준다. [파일 세트 가져오기] 는 publisher 폴더 틀을 편집 값에 채운다(저장 안 함).
 * - 2~4단계 (2026-10-21, docs/specs/2026-10-21-ai4-cms-block-templates-phase2-4.md):
 *   [틀] 탭은 블록마다 여러 틀({블록}.{이름}: 새 틀·복제·삭제(할당에서 쓰면 막음)), 변수·행 필드·버튼·구조·그림 칩, 목록 카드 시작 틀, 문법 도움말.
 *   [할당] 탭은 출처(도구) × 블록 → 틀 표와 조건 할당(블록 변수 = 값). 저장 본문에 assign 을 싣는다.
 */
(function (global) {
  "use strict";

  var root = document.getElementById("ad4");
  if (!root) return;
  var URL_DATA = root.getAttribute("data-data");
  var URL_SAVE = root.getAttribute("data-save");
  var URL_PUBLISH = root.getAttribute("data-publish");
  var URL_LOAD = root.getAttribute("data-load");
  var URL_CSS = root.getAttribute("data-css");
  var URL_IMPORT = root.getAttribute("data-import");
  var $ = function (id) { return document.getElementById(id); };
  var frame = $("ad4Frame");

  var S = { meta: null, templates: {}, style: { blocks: {} }, usePublisher: false, savedVersion: null, dirty: false,
    /** 블록 틀 {common:{css}, variants:{"{블록}.default":{html, css}}} (서버 BlockVariants 모양) */
    variants: { common: { css: "" }, variants: {} },
    /** 할당 {rules:[{source, block, when?, variant}]} (4단계, 서버 BlockVariants 규칙) */
    assign: { rules: [] },
    /** [틀] 탭에서 블록마다 고른 틀 id */
    tplSel: {},
    /** 마지막 미리보기 검사 결과 (틀 탭 아래에 그 블록 것만) */
    issues: { errors: [], warnings: [] },
    /** publisher 폴더 상태 (designData.do 의 publisher) */
    pub: null,
    block: "facility-list", tab: "text", published: null, draft: null,
    /** 미리보기에서 읽은 기본값 {type: {block, slots:{}, table, actions, notes}} (받기 전 null) */
    defaults: null,
    /** 지금 고른 편집 대상 (같은 대상을 다시 누르면 step 이 늘어 다음 위치로) */
    focus: { key: null, step: 0 },
    /** 디자인 값이 바뀐 횟수 (전체 미리보기 뒤 CSS 를 다시 맞출지 판단) */
    styleRev: 0 };

  /** 템플릿 키 뒤쪽 이름 → 화면 이름 (칸 이름은 블록 목록의 이름을 쓴다) */
  var KEY_LABELS = {
    empty: "결과 없을 때 문장", emptyHint: "결과 없을 때 안내", emptyHintEvaluation: "결과 없을 때 안내 (의료기관평가)",
    nightNote: "야간 안내", footEvaluation: "※ 안내 (의료기관평가)", footVaccination: "※ 안내 (예방접종)",
    certifiedNote: "인증 기관만 안내", relaxedNote: "조건 넓힘 안내", sectionTitle: "항목 제목 모양", addr: "주소 줄",
    contact: "연락처 줄", established: "개설일자 줄", text: "본문", otherDept: "다른 진료과 안내", askRegion: "지역 묻기",
    all: "모두 없을 때", partial: "일부만 없을 때", detailQuery: "상세 질문 말풍선", route: "길찾기 버튼", detail: "상세 버튼",
    "hint.facility": "다시 찾기 안내 (기관 목록)", "hint.evaluation": "다시 찾기 안내 (의료기관평가)", "hint.place": "다시 찾기 안내 (주소)",
    "hint.nearby": "다시 찾기 안내 (주변)", "hint.aed": "다시 찾기 안내 (AED)", "hint.hospitalInfo": "다시 찾기 안내 (홈페이지 자료)",
    "hint.hospital": "다시 찾기 안내 (병원 이름)", "hint.health": "다시 찾기 안내 (건강정보)"
  };
  /** 문구 키 뒤쪽 이름 → 그 문구가 들어가는 칸 (칸 이름과 같으면 표에 없어도 된다) */
  var TEXT_SLOT = {
    empty: "head", all: "head", partial: "head", emptyHint: "hint", emptyHintEvaluation: "hint", nightNote: "note",
    footEvaluation: "foot", footVaccination: "foot", addr: "info", contact: "info", established: "info", sectionTitle: "section"
  };
  var ALIGN_LABELS = { left: "왼쪽", center: "가운데", right: "오른쪽" };
  var CSS_DELAY = 400;
  var FULL_DELAY = 1500;

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function copy(o) { return JSON.parse(JSON.stringify(o || {})); }

  function has(o, k) { return Object.prototype.hasOwnProperty.call(o, k); }

  function request(url, body) {
    return fetch(url, body === undefined ? { credentials: "same-origin", cache: "no-store" } : {
      method: "POST",
      credentials: "same-origin",
      headers: { "Content-Type": "application/json", "X-Requested-With": "XMLHttpRequest" },
      body: JSON.stringify(body)
    }).then(function (r) {
      return r.json().catch(function () { return { ok: false, errors: ["HTTP " + r.status] }; });
    });
  }

  function message(kind, title, errors) {
    var box = $("ad4Msg");
    box.textContent = "";
    S.previewError = false;
    if (!title) return;
    var m = el("div", "ad4_msg " + (kind === "error" ? "is-error" : "is-ok"), title);
    if (errors && errors.length) {
      var ul = el("ul");
      errors.forEach(function (e) { ul.appendChild(el("li", null, e)); });
      m.appendChild(ul);
    }
    box.appendChild(m);
  }

  function setDirty(v) {
    S.dirty = v;
    renderState();
  }

  /** 편집 값이 바뀜: kind "style" 이면 CSS 만, "text"·"publisher" 면 전체 미리보기를 예약한다 */
  function changed(kind) {
    setDirty(true);
    if (kind === "style") scheduleCss();
    else scheduleFull();
    updateResetBlock();
    updateUseCheck();
  }

  function toFrame(msg) {
    if (frame && frame.contentWindow) frame.contentWindow.postMessage(msg, location.origin);
  }

  function hasVariants() { return Object.keys(S.variants.variants).length > 0; }

  /** "틀 사용" 체크: 이 화면의 틀이나 쓸 수 있는 파일 틀이 있을 때만 켤 수 있다 (켜져 있으면 끌 수는 있다) */
  function updateUseCheck() {
    var chk = $("ad4Publisher");
    if (!chk) return;
    chk.disabled = !chk.checked && !hasVariants() && !(S.pub && S.pub.usable);
  }

  /** 퍼블리셔 파일 틀 상태 (publisher 폴더) + [파일 세트 가져오기] */
  function renderPublisher(p) {
    S.pub = p || null;
    var box = $("ad4Pub");
    box.textContent = "";
    if (!p || !p.exists) {
      box.appendChild(el("span", null, "파일 틀: publisher 폴더(pt-ai/gwtpax4/publisher)에 manifest.json 이 없습니다. [틀] 탭에서 블록 틀을 만들 수 있습니다."));
      updateUseCheck();
      return;
    }
    var line = el("span", null, "파일 틀: " + (p.name || "(이름 없음)") + (p.version ? " · " + p.version : "") +
      " · 블록 " + (p.blocks || []).length + "개" + ((p.blocks || []).length ? " (" + p.blocks.join(", ") + ")" : "") +
      " — [틀] 탭의 틀이 하나라도 있으면 파일 틀은 쓰지 않습니다. ");
    box.appendChild(line);
    if (p.usable && URL_IMPORT) {
      var imp = el("a", "btn secondary xsm", "파일 세트 가져오기");
      imp.href = "#";
      imp.title = "publisher 폴더의 틀을 [틀] 탭 편집 값으로 가져옵니다 (임시 저장 전까지 저장되지 않음)";
      imp.onclick = function (e) { e.preventDefault(); importFiles(); };
      box.appendChild(imp);
    }
    var issues = (p.errors || []).map(function (e) { return { t: e, err: true }; })
      .concat((p.warnings || []).map(function (w) { return { t: w, err: false }; }));
    if (issues.length) {
      var d = el("details");
      d.appendChild(el("summary", (p.errors || []).length ? "is-err" : null,
        "오류 " + (p.errors || []).length + "건 · 참고 " + (p.warnings || []).length + "건 (오류가 있는 블록은 지금 디자인으로 그립니다)"));
      var ul = el("ul");
      issues.forEach(function (i) { ul.appendChild(el("li", i.err ? "is-err" : null, i.t)); });
      d.appendChild(ul);
      box.appendChild(d);
    }
    updateUseCheck();
  }

  /** publisher 폴더 파일 세트 → 틀 탭 편집 값 (서버 designImport.do, 저장하지 않음) */
  function importFiles() {
    if (hasVariants() && !global.confirm("지금 편집 중인 틀을 파일 세트로 덮어씁니다. 가져올까요?")) return;
    request(URL_IMPORT, {}).then(function (res) {
      if (!res.ok) { message("error", "가져오지 못했습니다.", res.errors); return; }
      S.variants = normVariants(res.variants);
      if (S.tab === "template") renderPanel();
      changed("text");
      var notes = (res.errors || []).concat(res.warnings || []);
      message("ok", "파일 세트를 가져왔습니다 (틀 " + Object.keys(S.variants.variants).length + "개). 확인한 뒤 임시 저장·게시해 주세요." +
        (notes.length ? " 아래는 참고입니다." : ""), notes);
    });
  }

  function renderState() {
    var st = $("ad4State");
    st.textContent = "";
    var p = S.published;
    var line1 = el("div");
    line1.appendChild(document.createTextNode("게시본 "));
    line1.appendChild(el("strong", null, p ? "v" + p.version : "없음 (기본 모양)"));
    if (p) line1.appendChild(document.createTextNode(" · " + (p.publishedAt || "") + (p.savedBy ? " · " + p.savedBy : "")));
    st.appendChild(line1);
    var line2 = el("div");
    line2.appendChild(document.createTextNode("임시 저장본 "));
    line2.appendChild(el("strong", null, S.savedVersion ? "v" + S.savedVersion : "없음"));
    if (S.draft && S.draft.updatedAt) line2.appendChild(document.createTextNode(" · " + S.draft.updatedAt));
    if (S.dirty) line2.appendChild(el("span", "ad4_dirty", " · 저장하지 않은 변경 있음"));
    st.appendChild(line2);
  }

  // ---- 블록 선택 ----

  function blockMeta(type) {
    var bs = S.meta.blocks;
    for (var i = 0; i < bs.length; i += 1) if (bs[i].type === type) return bs[i];
    return null;
  }

  function slotMeta(type, slot) {
    var b = blockMeta(type);
    if (!b) return null;
    for (var i = 0; i < b.slots.length; i += 1) if (b.slots[i].slot === slot) return b.slots[i];
    return null;
  }

  function renderPicker() {
    var sel = $("ad4Block");
    sel.textContent = "";
    S.meta.blocks.forEach(function (b) {
      var o = el("option", null, b.type === "*" ? "모든 블록 (디자인만)" : b.label);
      o.value = b.type;
      sel.appendChild(o);
    });
    [["col", "표 열 이름 (문구만)"], ["action", "기관 이름 칸 버튼 (문구만)"]].forEach(function (g) {
      var o = el("option", null, g[1]);
      o.value = g[0];
      sel.appendChild(o);
    });
    sel.value = S.block;
    sel.onchange = function () { S.block = sel.value; sampleNote(null); renderPanel(); };
  }

  /** 이 블록에 되돌릴 값이 있나 (문구 + 디자인) */
  function blockHasChanges(type) {
    var text = S.meta.templates.some(function (t) { return t.group === type && has(S.templates, t.key); });
    return text || !!S.style.blocks[type] || has(S.variants.variants, variantId(type));
  }

  function updateResetBlock() {
    var b = $("ad4ResetBlock");
    if (!b || !S.meta) return;
    var on = blockHasChanges(S.block);
    b.classList.toggle("is-disabled", !on);
    b.setAttribute("aria-disabled", on ? "false" : "true");
  }

  // ---- 편집 항목 ↔ 미리보기 ----

  function focusKey(block, target) {
    return block + "|" + target.group + "|" + (target.slot || target.col || "");
  }

  /** 문구 항목이 들어가는 미리보기 대상 */
  function textTarget(t) {
    var rest = t.key.slice(t.group.length + 1);
    if (t.group === "col") return { block: "*", target: { group: "table", col: rest } };
    if (t.group === "action") return { block: "*", target: { group: "actions" } };
    if (t.group === "empty-result" && rest.indexOf("hint.") === 0) return { block: "empty-result", target: { group: "slot", slot: "hint" } };
    var slot = slotMeta(t.group, rest) ? rest : (TEXT_SLOT[rest] && slotMeta(t.group, TEXT_SLOT[rest]) ? TEXT_SLOT[rest] : null);
    return { block: t.group, target: slot ? { group: "slot", slot: slot } : { group: "block" } };
  }

  function styleTarget(path) {
    if (path[0] === "slots") return { group: "slot", slot: path[1] };
    return { group: path[0] };
  }

  /** 편집 항목(그룹·문구)에 미리보기 연동을 건다 */
  function bindFocus(node, block, target, label) {
    var key = focusKey(block, target);
    node.setAttribute("data-fkey", key);
    var count = node.querySelector(".ad4_count");
    node.addEventListener("mouseenter", function () { toFrame({ type: "ai4-design-focus", mode: "hover", block: block, target: target, label: label }); });
    node.addEventListener("mouseleave", function () { toFrame({ type: "ai4-design-focus", mode: "clear" }); });
    function select(next) {
      if (S.focus.key === key && !next) return;
      S.focus = { key: key, step: S.focus.key === key ? S.focus.step + 1 : 0, count: count };
      markSelected(key);
      toFrame({ type: "ai4-design-focus", mode: "select", block: block, target: target, step: S.focus.step });
    }
    node.addEventListener("focusin", function () { select(false); });
    node.addEventListener("click", function (e) {
      if (e.target.closest("input, select, textarea, a, button, .ad4_vars")) return;
      select(true);
    });
    if (S.focus.key === key) {
      S.focus.count = count;
      node.classList.add("is-sel");
    }
  }

  function markSelected(key) {
    Array.prototype.forEach.call(root.querySelectorAll("[data-fkey]"), function (n) {
      n.classList.toggle("is-sel", n.getAttribute("data-fkey") === key);
    });
  }

  function flash(node) {
    node.classList.remove("is-flash");
    void node.offsetWidth; // 애니메이션 다시 시작
    node.classList.add("is-flash");
    global.setTimeout(function () { node.classList.remove("is-flash"); }, 1300);
  }

  /** 미리보기에서 누른 대상에 들어가는 문구 */
  function textsFor(block, target) {
    if (target.group === "table") {
      return target.col ? S.meta.templates.filter(function (t) { return t.key === "col." + target.col; }) : [];
    }
    if (target.group === "actions") return S.meta.templates.filter(function (t) { return t.group === "action"; });
    if (target.group !== "slot") return [];
    var want = focusKey(block, target);
    return S.meta.templates.filter(function (t) {
      var tt = textTarget(t);
      return focusKey(tt.block, tt.target) === want;
    });
  }

  /** 미리보기에서 누른 대상의 디자인 묶음 (칸 목록에 없는 칸은 블록 상자). 고칠 수 없으면 null */
  function styleFor(block, target) {
    var b = blockMeta(block);
    if (!b || block === "*") return null;
    if (target.group === "slot") {
      var s = slotMeta(block, target.slot);
      return s ? { target: target, label: "칸 · " + s.label + " 디자인" } : { target: { group: "block" }, label: "블록 상자 디자인" };
    }
    if (target.group === "table") {
      var hasTable = b.slots.some(function (x) { return x.slot === "table"; });
      return hasTable ? { target: { group: "table" }, label: "표 디자인" } : { target: { group: "block" }, label: "블록 상자 디자인" };
    }
    if (target.group === "actions") return { target: { group: "actions" }, label: "길찾기·상세 버튼 디자인" };
    return { target: { group: "block" }, label: "블록 상자 디자인" };
  }

  function pickTitle(block, target) {
    var b = blockMeta(block);
    var name = b ? b.label : block;
    if (target.group === "slot") {
      var s = slotMeta(block, target.slot);
      return name + " › " + (s ? s.label : target.slot);
    }
    if (target.group === "table") return name + " › 표" + (target.col ? " 열 이름" : "");
    if (target.group === "actions") return name + " › 길찾기·상세 버튼";
    return name + " › 블록 상자";
  }

  /** 미리보기에서 누른 대상 → 그 자리에 띄울 "문구 / 디자인" 메뉴 항목을 계산해 돌려준다 */
  function onPick(d) {
    var target = d.target || { group: "block" };
    var texts = textsFor(d.block, target);
    var style = styleFor(d.block, target);
    S.pick = { block: d.block, target: target, style: style, index: d.index || 0, count: d.count || 0 };
    var textNote = target.group === "table" ? "표 내용은 데이터입니다 (열 이름은 머리글을 누르세요)"
      : target.group === "block" ? "블록 상자에는 문구가 없습니다 (안쪽 칸을 누르세요)"
      : "데이터로 채워지는 칸이라 고칠 문구가 없습니다";
    toFrame({ type: "ai4-design-menu", menu: {
      x: d.x, y: d.y, title: pickTitle(d.block, target),
      texts: texts.map(function (t) {
        return { key: t.key, label: keyLabel(t), code: t.key.slice(t.group.length + 1) };
      }),
      textNote: textNote,
      style: style ? { label: style.label } : null,
      styleNote: "이 블록은 디자인을 고칠 수 없습니다"
    } });
  }

  function nodesByAttr(attr, value) {
    return Array.prototype.filter.call(root.querySelectorAll("[" + attr + "]"), function (n) { return n.getAttribute(attr) === value; });
  }

  /** 메뉴에서 고른 문구 또는 디자인 묶음으로 이동해 강조하고 입력칸에 포커스 */
  function onGo(choice) {
    var p = S.pick;
    if (!p || !choice) return;
    var node;
    var fk;
    if (choice.kind === "text") {
      var t = null;
      S.meta.templates.forEach(function (x) { if (x.key === choice.key) t = x; });
      if (!t) return;
      var tt = textTarget(t);
      fk = focusKey(tt.block, tt.target);
      S.block = t.group;
      S.tab = "text";
      S.focus = { key: fk, step: p.index };
      $("ad4Block").value = S.block;
      renderPanel();
      node = nodesByAttr("data-tkey", t.key)[0];
    } else {
      if (!p.style) return;
      fk = focusKey(p.block, p.style.target);
      S.block = p.block;
      S.tab = "style";
      S.focus = { key: fk, step: p.index };
      $("ad4Block").value = S.block;
      renderPanel();
      node = nodesByAttr("data-fkey", fk)[0];
    }
    markSelected(fk);
    sampleNote(null);
    if (!node) return;
    S.focus.count = node.querySelector(".ad4_count");
    onFocusDone({ index: p.index, count: p.count });
    node.scrollIntoView({ block: "center", behavior: "smooth" });
    flash(node);
    var input = node.querySelector("input, select, textarea");
    if (input) {
      try { input.focus({ preventScroll: true }); } catch (e) { input.focus(); }
    }
  }

  /** 블록 선택 줄 옆 안내 ("미리보기 ○○ 답변의 첫 블록"). text 가 null 이면 지운다 */
  function sampleNote(text) {
    var row = root.querySelector(".ad4_pick");
    var n = row.querySelector(".ad4_pick_from");
    if (!text) { if (n) n.parentNode.removeChild(n); return; }
    if (!n) { n = el("span", "ad4_pick_from"); row.insertBefore(n, $("ad4ResetBlock")); }
    n.textContent = text;
  }

  /** 미리보기 위쪽 칩(대표 답변 바로가기) → 그 답변의 첫 블록을 편집할 블록으로 (탭은 그대로) */
  function onSample(d) {
    var types = (d.blocks || []).filter(function (t) { return !!blockMeta(t) && t !== "*"; });
    if (!types.length) return;
    S.block = types[0];
    S.focus = { key: null, step: 0 };
    $("ad4Block").value = S.block;
    renderPanel();
    sampleNote("← 미리보기 '" + (d.label || "") + "' 답변" + (types.length > 1 ? " (블록 " + types.length + "개 중 첫 번째)" : ""));
    var row = root.querySelector(".ad4_pick");
    flash(row);
    if (row.getBoundingClientRect().top < 0) row.scrollIntoView({ block: "start", behavior: "smooth" });
  }

  function onFocusDone(d) {
    var c = S.focus.count;
    if (!c) return;
    c.textContent = !d.count ? "미리보기에 나오는 답변 없음" : (d.count > 1 ? (d.index + 1) + "/" + d.count + " · 다시 누르면 다음" : "");
    c.classList.toggle("is-none", !d.count);
  }

  /** 미리보기 이름표용 블록·칸 이름 */
  function sendLabels() {
    var labels = { blocks: {}, slots: {}, prot: {} };
    S.meta.blocks.forEach(function (b) {
      labels.blocks[b.type] = b.type === "*" ? "모든 블록" : b.label;
      labels.slots[b.type] = {};
      b.slots.forEach(function (s) {
        labels.slots[b.type][s.slot] = s.label;
      });
    });
    toFrame({ type: "ai4-design-labels", labels: labels });
  }

  // ---- 문구 ----

  function keyLabel(t) {
    var rest = t.key.slice(t.group.length + 1);
    if (t.group === "col") return "열 이름 · " + t["default"];
    if (KEY_LABELS[rest]) return KEY_LABELS[rest];
    var b = blockMeta(t.group);
    if (b) for (var i = 0; i < b.slots.length; i += 1) if (b.slots[i].slot === rest) return b.slots[i].label;
    return rest;
  }

  function renderTexts(panel) {
    var items = S.meta.templates.filter(function (t) { return t.group === S.block; });
    if (!items.length) {
      panel.appendChild(el("p", "ad4_note", S.block === "*" ? "모든 블록 묶음에는 문구가 없습니다. 블록을 골라 주세요." : "이 블록에는 고칠 문구가 없습니다."));
      return;
    }
    panel.appendChild(el("p", "ad4_note", "{이름} 은 값으로 바뀌고, {#이름}…{/이름} 은 값이 있을 때만, {^이름}…{/이름} 은 없을 때만 보입니다. 비우면 그 줄이 나오지 않습니다."));
    items.forEach(function (t) {
      var item = el("div", "ad4_item");
      item.setAttribute("data-tkey", t.key);
      var head = el("div", "ad4_item_head");
      head.appendChild(el("strong", null, keyLabel(t)));
      head.appendChild(el("code", null, t.key));
      var changedEl = el("span", "ad4_changed", has(S.templates, t.key) ? "바뀜" : "");
      head.appendChild(changedEl);
      head.appendChild(el("span", "ad4_count"));
      var reset = el("a", "btn secondary xsm", "초기화");
      reset.href = "#";
      head.appendChild(reset);
      item.appendChild(head);
      var ta = el("textarea", "form_textarea");
      ta.value = has(S.templates, t.key) ? S.templates[t.key] : t["default"];
      ta.setAttribute("aria-label", keyLabel(t));
      function syncReset() {
        var on = has(S.templates, t.key);
        changedEl.textContent = on ? "바뀜" : "";
        reset.classList.toggle("is-disabled", !on);
      }
      ta.oninput = function () {
        if (ta.value === t["default"]) delete S.templates[t.key];
        else S.templates[t.key] = ta.value;
        syncReset();
        changed("text");
      };
      reset.onclick = function (e) {
        e.preventDefault();
        if (!has(S.templates, t.key)) return;
        ta.value = t["default"];
        ta.oninput();
      };
      syncReset();
      item.appendChild(ta);
      if (t.vars && t.vars.length) {
        var vars = el("div", "ad4_vars");
        t.vars.forEach(function (v) {
          var chip = el("span", null, "{" + v + "}");
          chip.title = "누르면 커서 위치에 넣습니다";
          chip.onclick = function () {
            var s = ta.selectionStart || ta.value.length;
            ta.value = ta.value.slice(0, s) + "{" + v + "}" + ta.value.slice(ta.selectionEnd || s);
            ta.oninput();
            ta.focus();
          };
          vars.appendChild(chip);
        });
        item.appendChild(vars);
      }
      var tt = textTarget(t);
      bindFocus(item, tt.block, tt.target, keyLabel(t));
      panel.appendChild(item);
    });
  }

  // ---- 디자인 ----

  /** 디자인 값 위치: [group] 또는 ["slots", slot] */
  function getProps(type, path) {
    var b = S.style.blocks[type];
    if (!b) return {};
    var g = b[path[0]];
    if (!g) return {};
    return path.length > 1 ? (g[path[1]] || {}) : g;
  }

  /** 미리보기에서 읽은 기본값 묶음 (못 읽었으면 undefined) */
  function defaultGroup(type, path) {
    var d = S.defaults && S.defaults[type];
    if (!d) return undefined;
    var g = path[0] === "slots" ? (d.slots || {})[path[1]] : d[path[0]];
    return g || undefined;
  }

  /** 미리보기에서 이 블록 종류가 틀로만 그려졌는지 (틀 사용 체크가 꺼져 있으면 항상 false) */
  function isTemplated(type) {
    return !!(S.usePublisher && S.templated && S.templated[type]);
  }

  function defaultNote(type, path, key) {
    var d = S.defaults && S.defaults[type];
    var n = d && d.notes && d.notes[path.join(".")];
    return n && n[key] ? n[key] : null;
  }

  /** 기준값: (블록이면) 모든 블록 값 → 읽은 기본값. 모르면 undefined, "없음"(투명·테두리 없음)이면 null */
  function baseline(type, path, key) {
    if (type !== "*") {
      var all = getProps("*", path)[key];
      if (all != null && all !== "") return all;
    }
    var g = defaultGroup(type, path);
    if (!g || !has(g, key)) return undefined;
    return g[key];
  }

  function same(a, b) {
    if (a == null || b == null) return a == null && b == null;
    if (typeof a === "number" || typeof b === "number") return Number(a) === Number(b);
    return String(a).toLowerCase() === String(b).toLowerCase();
  }

  function setProp(type, path, key, value) {
    var blocks = S.style.blocks;
    var b = blocks[type] || (blocks[type] = {});
    var g = b[path[0]] || (b[path[0]] = {});
    var target = path.length > 1 ? (g[path[1]] || (g[path[1]] = {})) : g;
    // 기준값과 같으면 저장하지 않는다 (= 비움). 기준값을 모르면 그대로 둔다.
    // 모든 블록(*) 값은 블록마다 기본값이 달라 같은 값이어도 저장한다
    var base = type === "*" ? undefined : baseline(type, path, key);
    if (value === "" || value == null || (base !== undefined && same(value, base))) delete target[key];
    else target[key] = value;
    cleanup(type, path);
    S.styleRev += 1;
    changed("style");
  }

  /** 빈 묶음 정리 */
  function cleanup(type, path) {
    var blocks = S.style.blocks;
    var b = blocks[type];
    if (!b) return;
    var g = b[path[0]];
    if (g && path.length > 1 && g[path[1]] && !Object.keys(g[path[1]]).length) delete g[path[1]];
    if (g && !Object.keys(g).length) delete b[path[0]];
    if (!Object.keys(b).length) delete blocks[type];
  }

  /** 저장돼 있던 값 중 기준값과 같은 것을 뺀다 (보이는 모양은 같다, 모든 블록 값은 그대로) */
  function prune() {
    if (!S.defaults) return;
    Object.keys(S.style.blocks).forEach(function (type) {
      if (type === "*") return;
      var b = S.style.blocks[type];
      var paths = [];
      Object.keys(b).forEach(function (g) {
        if (g === "slots") Object.keys(b.slots || {}).forEach(function (s) { paths.push(["slots", s]); });
        else paths.push([g]);
      });
      paths.forEach(function (path) {
        var props = getProps(type, path);
        Object.keys(props).forEach(function (k) {
          var base = baseline(type, path, k);
          if (base !== undefined && same(props[k], base)) delete props[k];
        });
        cleanup(type, path);
      });
    });
  }

  function clearProps(type, path) {
    var b = S.style.blocks[type];
    if (!b || !b[path[0]]) return;
    if (path.length > 1) delete b[path[0]][path[1]];
    else delete b[path[0]];
    cleanup(type, path);
    S.styleRev += 1;
    changed("style");
  }

  function placeholderFor(type, path, p, base) {
    if (!S.defaults) return "기본값 읽는 중";
    var note = defaultNote(type, path, p.key);
    if (note) return note;
    if (base === undefined) return "기본";
    if (base === null) return /background/i.test(p.key) ? "투명" : "없음";
    return "기본";
  }

  function propInput(type, path, p, opts, onChange) {
    var wrap = el("label", "ad4_prop");
    var min = p.min;
    wrap.appendChild(el("span", null, p.label + (p.kind === "px" ? " (" + min + "~" + p.max + "px)" : "")));
    var box = el("span", "ad4_in");
    var cur = getProps(type, path)[p.key];
    var base = baseline(type, path, p.key);
    var shown = cur != null && cur !== "" ? cur : (base == null ? "" : base);
    if (cur != null && cur !== "") wrap.classList.add("is-changed");
    var input;
    function set(v) {
      setProp(type, path, p.key, v);
      wrap.classList.toggle("is-changed", getProps(type, path)[p.key] != null);
      onChange();
    }
    if (p.kind === "color") {
      input = el("input");
      input.type = "text";
      input.maxLength = 7;
      input.value = shown;
      var pick = el("input");
      pick.type = "color";
      pick.value = /^#[0-9a-f]{6}$/i.test(input.value) ? input.value : "#ffffff";
      pick.oninput = function () { input.value = pick.value; set(pick.value); };
      input.oninput = function () {
        var v = input.value.trim();
        if (/^#[0-9a-f]{6}$/i.test(v)) pick.value = v;
        // 입력 중인 덜 쓴 색(#12 등)은 보내지 않는다 (자동 미리보기 오류 깜빡임 방지)
        var ok = v === "" || /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(v);
        input.classList.toggle("is-bad", !ok);
        if (ok) set(v);
      };
      box.appendChild(pick);
    } else if (p.kind === "px") {
      input = el("input");
      input.type = "number";
      input.min = min;
      input.max = p.max;
      input.value = shown === "" ? "" : shown;
      input.oninput = function () {
        var n = Number(input.value);
        // 범위 밖(입력 중인 "1" 등)은 표시만 하고 보내지 않는다
        var ok = input.value === "" || (!isNaN(n) && n >= min && n <= p.max);
        input.classList.toggle("is-bad", !ok);
        if (ok) set(input.value === "" ? "" : n);
      };
    } else {
      input = el("select");
      var values = p.kind === "weight" ? ["", 400, 500, 600, 700, 800] : ["", "left", "center", "right"];
      values.forEach(function (v) {
        var o = el("option", null, v === "" ? "기본" : (ALIGN_LABELS[v] || String(v)));
        o.value = String(v);
        input.appendChild(o);
      });
      input.value = shown === "" ? "" : String(shown);
      input.onchange = function () {
        set(input.value === "" ? "" : (p.kind === "weight" ? Number(input.value) : input.value));
      };
    }
    input.placeholder = placeholderFor(type, path, p, base);
    input.setAttribute("data-k", path.join(".") + "." + p.key);
    box.insertBefore(input, box.firstChild);
    wrap.appendChild(box);
    return wrap;
  }

  function group(panel, title, type, path, props, opts) {
    opts = opts || {};
    var g = el("div", "ad4_group");
    var head = el("div", "ad4_group_head");
    head.appendChild(el("h6", null, title));
    var changedEl = el("span", "ad4_changed");
    head.appendChild(changedEl);
    head.appendChild(el("span", "ad4_count"));
    var reset = el("a", "btn secondary xsm ad4_reset", "초기화");
    reset.href = "#";
    reset.title = "이 묶음의 값을 모두 기본값으로 되돌립니다";
    head.appendChild(reset);
    g.appendChild(head);
    // 틀로 그린 블록은 디자인 값이 걸리지 않으므로 잠근다 (틀 사용 체크를 끄면 다시 그린 미리보기에서 풀린다)
    var locked = isTemplated(type);
    if (!locked && S.defaults && !defaultGroup(type, path)) g.appendChild(el("p", "ad4_note", "기본값 확인용 샘플 없음 — 미리보기 답변에 이 항목이 나오지 않아 기본값을 읽지 못했습니다."));
    function sync() {
      var on = Object.keys(getProps(type, path)).length > 0;
      changedEl.textContent = on ? "바뀜" : "";
      reset.classList.toggle("is-disabled", !on || locked);
    }
    reset.onclick = function (e) {
      e.preventDefault();
      if (locked || !Object.keys(getProps(type, path)).length) return;
      clearProps(type, path);
      renderPanel();
    };
    var grid = el("div", "ad4_props");
    props.forEach(function (p) { grid.appendChild(propInput(type, path, p, opts, sync)); });
    if (locked) {
      Array.prototype.forEach.call(grid.querySelectorAll("input, select"), function (x) { x.disabled = true; });
      grid.style.opacity = "0.5";
    }
    g.appendChild(grid);
    sync();
    bindFocus(g, type, styleTarget(path), null);
    panel.appendChild(g);
  }

  function renderStyles(panel) {
    var b = blockMeta(S.block);
    if (!b) {
      panel.appendChild(el("p", "ad4_note", "이 묶음은 문구만 고칠 수 있습니다. 디자인은 블록을 골라 주세요."));
      return;
    }
    var props = S.meta.props;
    panel.appendChild(el("p", "ad4_note", S.block === "*"
      ? "모든 블록에 함께 적용됩니다. 블록별 값이 있으면 그 값이 이깁니다. 입력칸 값은 첫 번째 블록에서 읽은 값이며, 고친 값은 기본과 같아도 저장됩니다."
      : "입력칸에는 지금 적용되는 값(모든 블록 값 → 기본값)이 들어 있습니다. 같은 값은 저장하지 않습니다. 글자색과 배경 대비가 낮으면 저장되지 않습니다."));
    panel.appendChild(el("p", "ad4_note", S.defaults ? "기본값은 미리보기 폭 기준으로 읽은 값입니다 (모바일 화면에서는 다를 수 있음)." : "기본값 읽는 중… (미리보기를 그린 뒤 채워집니다)"));
    if (isTemplated(S.block)) {
      var lock = el("p", "ad4_note", "이 블록은 미리보기에서 틀(퍼블리셔·[틀] 탭)로 그려져 디자인 값이 적용되지 않아 입력칸을 잠갔습니다. 모양은 [틀] 탭의 CSS 로 고치거나, '퍼블리셔 템플릿 사용' 체크를 해제하면 다시 고칠 수 있습니다.");
      lock.style.cssText = "color:#C92A2A;font-weight:700;";
      panel.appendChild(lock);
    }
    group(panel, "블록 상자", S.block, ["block"], props.block);
    b.slots.forEach(function (s) {
      group(panel, "칸 · " + s.label + " (" + s.slot + ")", S.block, ["slots", s.slot], props.slots);
    });
    var hasTable = S.block === "*" || b.slots.some(function (s) { return s.slot === "table"; });
    if (hasTable) {
      group(panel, "표", S.block, ["table"], props.table);
      group(panel, "길찾기·상세 버튼", S.block, ["actions"], props.actions);
    }
  }

  // ---- 블록 틀 (CMS 블록 템플릿 1단계) ----

  /** 서버 모양 → 편집 값 (label·html·css 만, 모르는 키는 버린다) */
  function normVariants(v) {
    var out = { common: { css: "" }, variants: {} };
    if (!v || typeof v !== "object") return out;
    if (v.common && typeof v.common.css === "string") out.common.css = v.common.css;
    var vs = v.variants && typeof v.variants === "object" ? v.variants : {};
    Object.keys(vs).forEach(function (id) {
      var x = vs[id] || {};
      out.variants[id] = { html: String(x.html || ""), css: String(x.css || "") };
      if (!/\.default$/.test(id) && x.label) out.variants[id].label = String(x.label);
    });
    return out;
  }

  /** 할당 {rules:[{source, block, when?, variant}]} (서버 BlockVariants.toAssignJson 모양) */
  function normAssign(a) {
    var rules = a && Array.isArray(a.rules) ? a.rules : [];
    return {
      rules: rules.filter(function (r) { return r && r.source && r.block && r.variant; }).map(function (r) {
        var x = { source: String(r.source), block: String(r.block), variant: String(r.variant) };
        if (r.when && typeof r.when === "object" && Object.keys(r.when).length) x.when = copy(r.when);
        return x;
      })
    };
  }

  function variantId(type) { return type + ".default"; }

  /** 틀 이름 규칙 (서버 BlockVariants.ID 의 이름 부분), 틀·할당 개수 한도 */
  var NAME_RE = /^[a-z0-9][a-z0-9-]{0,39}$/;
  var MAX_VARIANTS = 50;
  var MAX_RULES = 200;

  /** 이 블록의 틀 id 목록 (기본 틀 먼저, 나머지는 이름 순) */
  function variantsOf(type) {
    var def = variantId(type);
    return Object.keys(S.variants.variants).filter(function (id) { return id.indexOf(type + ".") === 0; })
      .sort(function (a, b) { return a === def ? -1 : b === def ? 1 : (a < b ? -1 : 1); });
  }

  function variantLabel(id) {
    var v = S.variants.variants[id];
    var type = id.slice(0, id.indexOf("."));
    var name = id.slice(id.indexOf(".") + 1);
    var base = (blockMeta(type) || {}).label || type;
    if (name === "default") return base + " 기본 틀";
    return (v && v.label) || base + "(" + name + ")";
  }

  /** 이 틀을 쓰는 할당 규칙 (삭제 막기) */
  function usedBy(id) {
    return S.assign.rules.filter(function (r) { return r.variant === id; });
  }

  function sourceLabel(src) {
    var s = (S.meta.sources || []).filter(function (x) { return x.source === src; })[0];
    return s ? s.label : src;
  }

  function ruleText(r) {
    var when = r.when ? Object.keys(r.when).map(function (k) { return k + "=" + r.when[k]; }).join(", ") : "";
    return sourceLabel(r.source) + " × " + ((blockMeta(r.block) || {}).label || r.block) + (when ? " [" + when + "]" : "");
  }

  /** 새 틀 시작 모양: 블록의 칸을 차례대로 */
  function starterHtml(type) {
    var b = blockMeta(type);
    var lines = ['<div class="tpl-' + type + '">'];
    (b ? b.slots : []).forEach(function (s) {
      lines.push('  <div data-ab-slot="' + s.slot + '"></div>');
    });
    lines.push("</div>");
    return lines.join("\n");
  }

  function hasField(list, key) {
    return (list || []).some(function (f) { return f.key === key; });
  }

  /**
   * 목록 카드 시작 틀 (답변html 시안 answer-list 의 카드·시군 묶음, 2026-10-21).
   * 블록에 있는 행 필드만 쓰고, 기관 목록은 시안처럼 전문의·의료진·개원일·홈페이지까지 넣는다.
   */
  function cardStarter(type) {
    var b = blockMeta(type) || {};
    var rf = b.rowFields || [];
    var slots = (b.slots || []).filter(function (s) { return s.slot !== "table"; }).map(function (s) { return s.slot; });
    var img = (S.meta.assets || []).indexOf("img-loading.png") >= 0 ? "img-loading.png" : (S.meta.assets || [])[0];
    var L = [];
    L.push('<div class="ac-list">');
    if (slots.indexOf("head") >= 0) L.push('  <div class="ac-head" data-ab-slot="head"></div>');
    ["note", "hint"].forEach(function (s) {
      if (slots.indexOf(s) >= 0) L.push('  <div class="ac-' + s + '" data-ab-if="' + s + '"><div data-ab-slot="' + s + '"></div></div>');
    });
    L.push('  <section class="ac-map" data-ab-map></section>');
    var group = hasField(rf, "sggu");
    var ind = group ? "      " : "    ";
    L.push('  <div class="ac-cards">');
    if (group) L.push('    <section class="ac-region" data-ab-group="sggu">', '      <h4 class="ac-region__title">{sggu}</h4>');
    L.push(ind + '<article class="ac-card" data-ab-each="rows">');
    if (img) L.push(ind + '  <img class="ac-card__thumb" data-ab-asset="' + img + '" alt="{name} 이미지 준비중">');
    L.push(ind + '  <div class="ac-card__info">');
    L.push(ind + '    <div class="ac-card__head"><strong class="ac-card__name">{name}</strong>' +
      (hasField(rf, "kind") ? ' <span class="ac-card__kind" data-ab-show="kind">({kind})</span>' : "") +
      ' <span class="ac-btn" data-ab-action="detail">상세 정보보기</span></div>');
    L.push(ind + '    <dl class="ac-card__fields">');
    if (hasField(rf, "place")) L.push(ind + '      <div data-ab-show="place"><dt>설치 장소</dt><dd>{place}</dd></div>');
    if (hasField(rf, "addr")) L.push(ind + '      <div><dt>주소</dt><dd>{addr} <span class="ac-btn" data-ab-action="route">길찾기</span></dd></div>');
    if (hasField(rf, "distance")) L.push(ind + '      <div data-ab-show="distance"><dt>거리</dt><dd>{distance}</dd></div>');
    if (hasField(rf, "today")) L.push(ind + '      <div data-ab-show="today"><dt>오늘 사용 시간</dt><dd>{today}</dd></div>');
    if (hasField(rf, "tel")) L.push(ind + '      <div data-ab-show="tel"><dt>대표전화</dt><dd><span data-ab-action="tel"></span></dd></div>');
    if (hasField(rf, "homepage")) L.push(ind + '      <div><dt>홈페이지</dt><dd><span class="ac-btn" data-ab-action="homepage">바로가기</span><span class="ac-pending" data-ab-hide="homepage">정보 확인 필요</span></dd></div>');
    if (hasField(rf, "specialists") && hasField(b.vars, "clinicLabel")) L.push(ind + '      <div data-ab-show="specialists"><dt>{clinicLabel} 전문의</dt><dd>{specialists}명</dd></div>');
    if (hasField(rf, "doctors")) L.push(ind + '      <div><dt>의료진</dt><dd><span data-ab-show="doctors">총 {doctors}명</span><span class="ac-pending" data-ab-hide="doctors">정보 확인 필요</span></dd></div>');
    if (hasField(rf, "established")) L.push(ind + '      <div><dt>개원일</dt><dd>{established}<span class="ac-pending" data-ab-hide="established">정보 확인 필요</span></dd></div>');
    L.push(ind + "    </dl>", ind + "  </div>", ind + "</article>");
    if (group) L.push("    </section>");
    L.push("  </div>");
    slots.filter(function (s) { return ["head", "note", "hint"].indexOf(s) < 0; }).forEach(function (s) {
      L.push('  <div data-ab-slot="' + s + '"></div>');
    });
    L.push("</div>");
    return L.join("\n");
  }

  /** 시안 answer-list 의 카드 모양 (색은 시안 변수 값: --brand #0038C3, --brand-100 #C9D8FA, --brand-50 #E9EEFA, --title-ink #0B1F5C) */
  var CARD_CSS = [
    ".ac-region + .ac-region { margin-top:18px; }",
    ".ac-region__title { margin:0 0 8px; color:#0B1F5C; font-size:16px; font-weight:800; }",
    ".ac-card { display:flex; align-items:flex-start; gap:12px; padding:0 0 16px; margin:0 0 16px; border-bottom:1px solid #E8ECF2; cursor:pointer; }",
    ".ac-card.is-active { background:#E9EEFA; }",
    ".ac-card__thumb { flex:0 0 138px; width:138px; height:184px; object-fit:cover; border-radius:8px; background:#E9EEFA; }",
    ".ac-card__info { flex:1; min-width:0; }",
    ".ac-card__head { display:flex; flex-wrap:wrap; align-items:center; gap:4px 6px; margin-bottom:8px; }",
    ".ac-card__name { color:#0B1F5C; font-size:18px; font-weight:800; line-height:1.4; }",
    ".ac-card__kind { color:#0038C3; font-size:14px; font-weight:600; }",
    ".ac-card__fields { display:grid; gap:4px; margin:0; color:#000; font-size:14px; line-height:1.45; }",
    ".ac-card__fields > div { display:flex; flex-wrap:wrap; align-items:baseline; gap:0 5px; }",
    ".ac-card__fields dt { flex-shrink:0; font-weight:700; }",
    ".ac-card__fields dd { flex:1; min-width:0; margin:0; }",
    ".ac-btn { display:inline-flex; align-items:center; min-height:24px; padding:2px 7px; border:1px solid #C9D8FA; border-radius:5px; background:#fff; color:#0038C3; font-size:13px; font-weight:700; line-height:1.2; text-decoration:none; cursor:pointer; }",
    ".ac-btn:hover { background:#E9EEFA; border-color:#0038C3; }",
    ".ac-pending { color:#000; }",
    "@media (max-width: 768px) { .ac-card__thumb { flex-basis:112px; width:112px; height:150px; } .ac-card__name { font-size:16px; } }",
    "@media (max-width: 480px) { .ac-card__thumb { flex-basis:76px; width:76px; height:102px; } .ac-card__name { font-size:15px; } .ac-card__fields dd { flex-basis:100%; } }"
  ].join("\n");

  /** 미리보기 검사 결과 중 이 블록 것 (서버 문구가 "{블록 이름} 틀", "{블록 이름}(이름) 틀" 또는 "공통 CSS" 로 시작) */
  function issuesFor(type) {
    var prefix = type === "*" ? "공통 CSS" : ((blockMeta(type) || {}).label || type);
    var pick = function (list) {
      return (list || []).filter(function (m) { return m.indexOf(prefix + " 틀") === 0 || m.indexOf(prefix + "(") === 0; });
    };
    return { errors: pick(S.issues.errors), warnings: pick(S.issues.warnings) };
  }

  /** 틀 탭 아래 검사 결과 (입력 중 포커스를 잃지 않게 이 상자만 다시 그린다) */
  function renderTplIssues() {
    var box = $("ad4TplMsgs");
    if (box) {
      box.textContent = "";
      var is = issuesFor(S.block);
      if (!is.errors.length && !is.warnings.length) {
        box.appendChild(el("p", "ad4_note", "미리보기 검사 결과 문제가 없습니다. (오류가 있는 틀은 미리보기·게시에서 빠지고 기본 모양으로 그립니다)"));
      } else {
        var ul = el("ul");
        is.errors.forEach(function (m) { ul.appendChild(el("li", "is-err", m)); });
        is.warnings.forEach(function (m) { ul.appendChild(el("li", "is-warn", m)); });
        box.appendChild(ul);
      }
    }
    var ab = $("ad4AssignMsgs");
    if (ab) {
      ab.textContent = "";
      var errs = (S.issues.errors || []).filter(function (m) { return m.indexOf("할당") === 0; });
      if (errs.length) {
        var ul2 = el("ul");
        errs.forEach(function (m) { ul2.appendChild(el("li", "is-err", m)); });
        ab.appendChild(ul2);
      }
    }
  }

  /** 커서 자리에 글자 넣기 */
  function insertAt(ta, text) {
    var s = ta.selectionStart == null ? ta.value.length : ta.selectionStart;
    var e = ta.selectionEnd == null ? s : ta.selectionEnd;
    ta.value = ta.value.slice(0, s) + text + ta.value.slice(e);
    ta.selectionStart = ta.selectionEnd = s + text.length;
    ta.focus();
    ta.dispatchEvent(new Event("input"));
  }

  function codeArea(cls, value, label, onInput) {
    var ta = el("textarea", "ad4_code " + cls);
    ta.value = value || "";
    ta.spellcheck = false;
    ta.setAttribute("aria-label", label);
    ta.addEventListener("input", function () { onInput(ta.value); });
    ta.addEventListener("keydown", function (e) {
      if (e.key === "Tab" && !e.shiftKey) { e.preventDefault(); insertAt(ta, "  "); }
    });
    return ta;
  }

  /** 칩 줄: [제목] 칩들. 칩을 누르면 커서 자리에 snippet */
  function chipRow(title, items, ta) {
    var row = el("div", "ad4_slots");
    row.appendChild(el("span", "ad4_chip_title", title));
    items.forEach(function (it) {
      var b = el("button", null, it.label);
      b.type = "button";
      if (it.title) b.title = it.title;
      if (it.disabled) {
        b.disabled = true;
        if (it.badge) b.appendChild(el("span", "ad4_badge", it.badge));
      } else {
        b.onclick = function () { insertAt(ta, it.text); };
      }
      row.appendChild(b);
    });
    return row;
  }

  var ACTION_LABELS = { route: "길찾기", detail: "상세", tel: "전화", homepage: "홈페이지" };

  /** 문법 도움말 (접힘) */
  function syntaxHelp() {
    var d = el("details", "ad4_help");
    d.appendChild(el("summary", null, "틀 문법 도움말"));
    [
      ["data-ab-slot=\"칸\"", "그 칸의 내용(서버가 만든 문장·표)을 넣을 자리. data-ab-if=\"칸\" 요소는 칸이 비면 지웁니다."],
      ["{변수}", "블록 변수·행 필드 값을 글자로 넣습니다. 속성은 title·alt·aria-label·class·data-* 에만 (href·src 는 안 됨)."],
      ["{#변수}…{/변수} / {^변수}…{/변수}", "값이 있을 때만 / 없을 때만 보이는 글자 (한 글자 덩어리 안에서만)."],
      ["data-ab-show=\"변수\" / data-ab-hide=\"변수\"", "값이 있을 때만 / 없을 때만 그 요소를 남깁니다."],
      ["data-ab-each=\"rows\"", "목록 행마다 그 요소를 복제합니다. 안에서 행 필드({name} 등)를 쓸 수 있고, 표 대신 이 목록이 지도와 짝이 됩니다."],
      ["data-ab-group=\"행 필드\"", "그 값(예: 시군 sggu)으로 행을 묶고, 묶음마다 요소를 복제합니다. 안에 data-ab-each 를 둡니다."],
      ["data-ab-action=\"route|detail|tel|homepage\"", "행 안의 버튼 자리. 데이터가 있을 때만 링크·버튼으로 바뀌고, 안 글자가 버튼 글자가 됩니다."],
      ["img data-ab-asset=\"파일\"", "답변 자산 폴더(pt-ai/gwtpax4/answer-assets)의 그림. 폴더에 있는 파일만 쓸 수 있습니다."],
      ["data-ab-map", "지도를 넣을 자리 (목록 블록만). 없으면 답변 아래에 붙습니다."]
    ].forEach(function (x) {
      var p = el("p", "ad4_note");
      p.appendChild(el("code", null, x[0]));
      p.appendChild(document.createTextNode(" — " + x[1]));
      d.appendChild(p);
    });
    return d;
  }

  /** 틀 고르기 줄: 목록 + [새 틀] [복제] [삭제] */
  function variantBar(type, id) {
    var bar = el("div", "ad4_tpl_bar");
    var sel = el("select", "form_select");
    sel.setAttribute("aria-label", "편집할 틀");
    var ids = variantsOf(type);
    if (ids.indexOf(variantId(type)) < 0) ids.unshift(variantId(type));
    ids.forEach(function (x) {
      var o = el("option", null, variantLabel(x) + (S.variants.variants[x] ? "" : " (없음)") + " · " + x);
      o.value = x;
      if (x === id) o.selected = true;
      sel.appendChild(o);
    });
    sel.onchange = function () { S.tplSel[type] = sel.value; renderPanel(); };
    bar.appendChild(sel);
    function btn(text, title, fn) {
      var b = el("a", "btn secondary xsm", text);
      b.href = "#";
      b.title = title;
      b.onclick = function (e) { e.preventDefault(); fn(); };
      bar.appendChild(b);
      return b;
    }
    function askName(from) {
      if (Object.keys(S.variants.variants).length >= MAX_VARIANTS) { global.alert("틀은 " + MAX_VARIANTS + "개까지 만들 수 있습니다."); return; }
      var name = global.prompt("새 틀 이름 (영문 소문자·숫자·-, 40자까지. 예: card, pharmacy-card)", "");
      if (name == null) return;
      name = name.trim();
      if (!NAME_RE.test(name)) { global.alert("이름은 영문 소문자·숫자·- 로 40자까지입니다."); return; }
      var nid = type + "." + name;
      if (S.variants.variants[nid]) { global.alert("같은 이름의 틀이 이미 있습니다: " + nid); return; }
      var label = global.prompt("화면에 보일 이름 (40자까지, 비우면 " + ((blockMeta(type) || {}).label || type) + "(" + name + "))", "") || "";
      var v = from ? copy(from) : { html: starterHtml(type), css: "" };
      delete v.label;
      if (label.trim() && name !== "default") v.label = label.trim().slice(0, 40);
      S.variants.variants[nid] = v;
      S.tplSel[type] = nid;
      renderPanel();
      changed("text");
    }
    btn("새 틀", "이 블록의 틀을 하나 더 만듭니다 (할당 탭에서 출처별로 고를 수 있습니다)", function () { askName(null); });
    var dup = btn("복제", "지금 틀을 복사해 새 이름으로 만듭니다", function () { askName(S.variants.variants[id]); });
    if (!S.variants.variants[id]) dup.classList.add("is-disabled");
    var del = btn("삭제", "이 틀을 지웁니다 (할당에서 쓰는 틀은 지울 수 없습니다)", function () {
      var used = usedBy(id);
      if (used.length) {
        global.alert("할당에서 쓰는 틀이라 지울 수 없습니다. 먼저 할당 탭에서 바꿔 주세요.\n- " + used.map(ruleText).join("\n- "));
        return;
      }
      if (!global.confirm("\"" + variantLabel(id) + "\" 틀(HTML·CSS)을 지울까요? (임시 저장 전까지는 반영되지 않습니다)")) return;
      delete S.variants.variants[id];
      S.tplSel[type] = variantId(type);
      renderPanel();
      changed("text");
    });
    if (!S.variants.variants[id]) del.classList.add("is-disabled");
    return bar;
  }

  function renderTemplate(panel) {
    var type = S.block;
    if (type === "col" || type === "action") {
      panel.appendChild(el("p", "ad4_note", "이 항목은 문구만 있습니다. 블록을 고르면 그 블록의 틀을 편집할 수 있습니다."));
      return;
    }
    var msgs = el("div", "ad4_tpl_msgs");
    msgs.id = "ad4TplMsgs";
    if (type === "*") {
      var g0 = el("div", "ad4_group");
      g0.appendChild(el("h6", null, "공통 CSS (틀로 그린 모든 블록)"));
      g0.appendChild(el("p", "ad4_note", "선택자는 .ab[data-variant] 아래로 감싸져 적용됩니다. 가져온 파일 세트의 publisher.css 가 여기 들어갑니다."));
      g0.appendChild(codeArea("is-css", S.variants.common.css, "공통 CSS", function (v) {
        S.variants.common.css = v;
        changed("text");
      }));
      g0.appendChild(msgs);
      panel.appendChild(g0);
      panel.appendChild(syntaxHelp());
      renderTplIssues();
      return;
    }
    var bm = blockMeta(type) || {};
    var id = S.tplSel[type] && (S.variants.variants[S.tplSel[type]] || S.tplSel[type] === variantId(type)) ? S.tplSel[type] : variantId(type);
    var v = S.variants.variants[id];
    var isDefault = id === variantId(type);
    var g = el("div", "ad4_group");
    var head = el("div", "ad4_group_head");
    head.appendChild(el("h6", null, (bm.label || type) + " 틀"));
    head.appendChild(el("code", null, id));
    var used = usedBy(id);
    if (used.length) head.appendChild(el("span", "ad4_count", "할당 " + used.length + "곳"));
    g.appendChild(head);
    g.appendChild(variantBar(type, id));
    if (isDefault) {
      var on = el("label", "ad4_tpl_on");
      var cb = el("input");
      cb.type = "checkbox";
      cb.checked = !!v;
      on.appendChild(cb);
      on.appendChild(document.createTextNode(" 이 블록 기본 틀 쓰기 (할당이 없으면 이 틀, 끄면 지금 디자인으로 그립니다)"));
      cb.onchange = function () {
        if (cb.checked) {
          S.variants.variants[id] = { html: starterHtml(type), css: "" };
        } else {
          if (!global.confirm("이 블록의 기본 틀(HTML·CSS)을 지울까요? (임시 저장 전까지는 반영되지 않습니다)")) { cb.checked = true; return; }
          delete S.variants.variants[id];
        }
        renderPanel();
        changed("text");
      };
      g.appendChild(on);
    } else {
      g.appendChild(el("p", "ad4_note", "이름 있는 틀은 [할당] 탭에서 출처(도구)·조건별로 고른 경우에만 씁니다."));
      var lab = el("label", "ad4_tpl_on");
      lab.appendChild(document.createTextNode("화면 이름 "));
      var li = el("input");
      li.type = "text";
      li.maxLength = 40;
      li.className = "form_text";
      li.value = (v && v.label) || "";
      li.placeholder = (bm.label || type) + "(" + id.slice(id.indexOf(".") + 1) + ")";
      li.oninput = function () {
        if (li.value.trim()) S.variants.variants[id].label = li.value.trim();
        else delete S.variants.variants[id].label;
        setDirty(true);
      };
      lab.appendChild(li);
      g.appendChild(lab);
    }
    if (!v) {
      g.appendChild(el("p", "ad4_note", "켜면 이 블록의 칸이 차례대로 들어간 시작 틀이 만들어집니다."));
      panel.appendChild(g);
      panel.appendChild(syntaxHelp());
      return;
    }
    g.appendChild(el("p", "ad4_note", "칩을 누르면 커서 자리에 넣습니다. 자리가 없는 칸은 블록 끝에 붙습니다."));
    var html = codeArea("is-html", v.html, "틀 HTML", function (val) {
      S.variants.variants[id].html = val;
      changed("text");
    });
    g.appendChild(chipRow("칸", (bm.slots || []).map(function (s) {
      return { label: s.label + " (" + s.slot + ")", text: '<div data-ab-slot="' + s.slot + '"></div>' };
    }), html));
    if ((bm.vars || []).length) {
      g.appendChild(chipRow("변수", bm.vars.map(function (x) { return { label: x.label + " {" + x.key + "}", text: "{" + x.key + "}" }; }), html));
    }
    var rows = bm.rowFields || [];
    if (rows.length) {
      g.appendChild(chipRow("행 필드", rows.map(function (x) {
        return { label: x.label + " {" + x.key + "}", text: "{" + x.key + "}", title: "data-ab-each 안에서만 쓸 수 있습니다" };
      }), html));
      g.appendChild(chipRow("버튼", (S.meta.actions || []).map(function (a) {
        return { label: ACTION_LABELS[a] || a, text: '<span data-ab-action="' + a + '">' + (ACTION_LABELS[a] || a) + "</span>", title: "data-ab-each 안에서만 쓸 수 있습니다" };
      }), html));
      var struct = [{ label: "행 반복", text: '<div data-ab-each="rows">\n  {name}\n</div>' }];
      if (hasField(rows, "sggu")) struct.push({ label: "시군 묶음", text: '<section data-ab-group="sggu">\n  <h4>{sggu}</h4>\n  <div data-ab-each="rows">{name}</div>\n</section>' });
      struct.push({ label: "지도 자리", text: "<section data-ab-map></section>" });
      g.appendChild(chipRow("구조", struct, html));
    }
    if ((S.meta.assets || []).length) {
      g.appendChild(chipRow("그림", S.meta.assets.map(function (f) { return { label: f, text: '<img data-ab-asset="' + f + '" alt="">' }; }), html));
    }
    if (rows.length) {
      var st = el("a", "btn secondary xsm", "목록 카드 시작 틀");
      st.href = "#";
      st.title = "답변html 시안(목록형 카드·시군 묶음) 모양으로 HTML·CSS 를 바꿉니다";
      st.onclick = function (e) {
        e.preventDefault();
        if (v.html.trim() && !global.confirm("지금 HTML·CSS 를 목록 카드 시작 틀로 바꿀까요?")) return;
        S.variants.variants[id].html = cardStarter(type);
        S.variants.variants[id].css = CARD_CSS;
        renderPanel();
        changed("text");
      };
      var sp = el("div", "ad4_tpl_bar");
      sp.appendChild(st);
      g.appendChild(sp);
    }
    g.appendChild(html);
    g.appendChild(el("p", "ad4_note", "CSS (선택자는 .ab[data-variant=\"" + id + "\"] 아래로 감싸져 이 틀에만 적용됩니다)"));
    g.appendChild(codeArea("is-css", v.css, "틀 CSS", function (val) {
      S.variants.variants[id].css = val;
      changed("text");
    }));
    g.appendChild(msgs);
    panel.appendChild(g);
    panel.appendChild(syntaxHelp());
    renderTplIssues();
  }

  // ---- 할당 탭 (CMS 블록 템플릿 4단계, 2026-10-21) ----
  // 순서: ① 출처 + 블록 + 조건 → ② 출처 + 블록 → ③ {블록}.default → ④ 지금 디자인 (서버 BlockVariants.variantFor)

  function plainRule(src, block) {
    return S.assign.rules.filter(function (r) { return r.source === src && r.block === block && !r.when; })[0] || null;
  }

  function variantSelect(block, value, emptyLabel, onChange) {
    var sel = el("select", "form_select");
    var o0 = el("option", null, emptyLabel);
    o0.value = "";
    sel.appendChild(o0);
    variantsOf(block).filter(function (x) { return x !== variantId(block); }).concat(S.variants.variants[variantId(block)] ? [variantId(block)] : [])
      .forEach(function (x) {
        var o = el("option", null, variantLabel(x));
        o.value = x;
        if (x === value) o.selected = true;
        sel.appendChild(o);
      });
    if (value && !S.variants.variants[value]) { // 지워진 틀을 가리키는 규칙
      var ox = el("option", null, value + " (없는 틀)");
      ox.value = value;
      ox.selected = true;
      sel.appendChild(ox);
    }
    sel.onchange = function () { onChange(sel.value); };
    return sel;
  }

  function assignChanged() {
    renderPanel();
    changed("text");
  }

  function renderAssign(panel) {
    var srcs = S.meta.sources || [];
    var g = el("div", "ad4_group");
    var head = el("div", "ad4_group_head");
    head.appendChild(el("h6", null, "출처 × 블록 → 틀"));
    head.appendChild(el("span", "ad4_count" + (S.assign.rules.length ? "" : " is-none"), "할당 " + S.assign.rules.length + "개"));
    g.appendChild(head);
    g.appendChild(el("p", "ad4_note", "AI 가 쓴 도구(출처)마다 블록을 어느 틀로 그릴지 고릅니다. 고르지 않으면 그 블록의 기본 틀, 기본 틀도 없으면 지금 디자인으로 그립니다. 이름 있는 틀은 [틀] 탭에서 만듭니다."));
    var table = el("table", "ad4_assign");
    var thead = el("thead");
    var hr = el("tr");
    ["출처", "블록", "틀"].forEach(function (h) { hr.appendChild(el("th", null, h)); });
    thead.appendChild(hr);
    table.appendChild(thead);
    var tb = el("tbody");
    srcs.forEach(function (s) {
      (s.blocks || []).forEach(function (block, i) {
        var tr = el("tr");
        var th = el("td", null, i === 0 ? s.label : "");
        if (i === 0) th.appendChild(el("code", null, " " + s.source));
        tr.appendChild(th);
        tr.appendChild(el("td", null, (blockMeta(block) || {}).label || block));
        var td = el("td");
        var r = plainRule(s.source, block);
        var dflt = S.variants.variants[variantId(block)] ? "기본 틀" : "지금 디자인";
        td.appendChild(variantSelect(block, r ? r.variant : "", "(정하지 않음 → " + dflt + ")", function (val) {
          S.assign.rules = S.assign.rules.filter(function (x) { return x !== r; });
          if (val) {
            if (S.assign.rules.length >= MAX_RULES) { global.alert("할당은 " + MAX_RULES + "개까지입니다."); return; }
            S.assign.rules.push({ source: s.source, block: block, variant: val });
          }
          assignChanged();
        }));
        tr.appendChild(td);
        tb.appendChild(tr);
      });
    });
    table.appendChild(tb);
    g.appendChild(table);
    panel.appendChild(g);

    // 조건 할당: 블록 변수 값이 같을 때만 (예: 기관 목록의 type = pharmacy)
    var g2 = el("div", "ad4_group");
    var h2 = el("div", "ad4_group_head");
    h2.appendChild(el("h6", null, "조건 할당 (위 할당보다 먼저)"));
    var add = el("a", "btn secondary xsm ad4_reset", "조건 추가");
    add.href = "#";
    add.onclick = function (e) {
      e.preventDefault();
      if (S.assign.rules.length >= MAX_RULES) { global.alert("할당은 " + MAX_RULES + "개까지입니다."); return; }
      var s0 = srcs.filter(function (s) { return (s.blocks || []).some(function (b) { return ((blockMeta(b) || {}).vars || []).length; }); })[0];
      if (!s0) return;
      var b0 = s0.blocks.filter(function (b) { return ((blockMeta(b) || {}).vars || []).length; })[0];
      var k0 = blockMeta(b0).vars[0].key;
      var when = {};
      when[k0] = "";
      S.assign.rules.push({ source: s0.source, block: b0, when: when, variant: "" });
      assignChanged();
    };
    h2.appendChild(add);
    g2.appendChild(h2);
    g2.appendChild(el("p", "ad4_note", "블록 변수 값이 똑같을 때만 그 틀을 씁니다 (예: 기관 목록 · 종류 코드 type = pharmacy). 틀을 고르지 않은 줄은 저장할 때 오류가 납니다."));
    var conds = S.assign.rules.filter(function (r) { return r.when; });
    if (!conds.length) g2.appendChild(el("p", "ad4_note", "조건 할당이 없습니다."));
    conds.forEach(function (r) {
      var row = el("div", "ad4_cond");
      var ss = el("select", "form_select");
      srcs.forEach(function (s) {
        var o = el("option", null, s.label);
        o.value = s.source;
        if (s.source === r.source) o.selected = true;
        ss.appendChild(o);
      });
      ss.onchange = function () {
        r.source = ss.value;
        var s = srcs.filter(function (x) { return x.source === r.source; })[0];
        if (s && s.blocks.indexOf(r.block) < 0) { r.block = s.blocks[0]; r.when = {}; r.variant = ""; }
        assignChanged();
      };
      row.appendChild(ss);
      var bs = el("select", "form_select");
      (srcs.filter(function (x) { return x.source === r.source; })[0] || { blocks: [] }).blocks.forEach(function (b) {
        var o = el("option", null, (blockMeta(b) || {}).label || b);
        o.value = b;
        if (b === r.block) o.selected = true;
        bs.appendChild(o);
      });
      bs.onchange = function () { r.block = bs.value; r.when = {}; r.variant = ""; assignChanged(); };
      row.appendChild(bs);
      var key = Object.keys(r.when)[0] || "";
      var ks = el("select", "form_select");
      ((blockMeta(r.block) || {}).vars || []).forEach(function (x) {
        var o = el("option", null, x.label + " (" + x.key + ")");
        o.value = x.key;
        if (x.key === key) o.selected = true;
        ks.appendChild(o);
      });
      if (!key && ks.options.length) { key = ks.options[0].value; r.when = {}; r.when[key] = ""; }
      ks.onchange = function () { var val = r.when[key] || ""; r.when = {}; r.when[ks.value] = val; assignChanged(); };
      row.appendChild(ks);
      row.appendChild(el("span", null, "="));
      var vi = el("input", "form_text");
      vi.type = "text";
      vi.maxLength = 100;
      vi.value = key ? (r.when[key] || "") : "";
      vi.placeholder = "값";
      vi.oninput = function () { r.when[key] = vi.value; changed("text"); };
      row.appendChild(vi);
      row.appendChild(el("span", null, "→"));
      row.appendChild(variantSelect(r.block, r.variant, "(틀 고르기)", function (val) { r.variant = val; assignChanged(); }));
      var del = el("a", "btn secondary xsm", "삭제");
      del.href = "#";
      del.onclick = function (e) {
        e.preventDefault();
        S.assign.rules = S.assign.rules.filter(function (x) { return x !== r; });
        assignChanged();
      };
      row.appendChild(del);
      g2.appendChild(row);
    });
    panel.appendChild(g2);
    var msgs = el("div", "ad4_tpl_msgs");
    msgs.id = "ad4AssignMsgs";
    panel.appendChild(msgs);
    renderTplIssues();
  }

  function renderPanel() {
    var panel = $("ad4Panel");
    panel.textContent = "";
    S.focus.count = null;
    Array.prototype.forEach.call(document.querySelectorAll(".ad4_tabs button"), function (bt) {
      bt.classList.toggle("is-on", bt.getAttribute("data-tab") === S.tab);
    });
    if (S.tab === "text") renderTexts(panel);
    else if (S.tab === "template") renderTemplate(panel);
    else if (S.tab === "assign") renderAssign(panel);
    else renderStyles(panel);
    updateResetBlock();
  }

  /** 기본값이 새로 오면 디자인 탭을 다시 그린다 (입력 중인 칸의 포커스 유지). templated = 틀로만 그린 블록 종류 */
  function onDefaults(blocks, templated) {
    var json = JSON.stringify([blocks || {}, templated || []]);
    if (json === S.defaultsJson) return;
    S.defaultsJson = json;
    S.defaults = blocks || {};
    S.templated = {};
    (templated || []).forEach(function (t) { S.templated[t] = true; });
    prune();
    if (S.tab !== "style") { updateResetBlock(); return; }
    var active = document.activeElement;
    var k = active && active.getAttribute ? active.getAttribute("data-k") : null;
    var keep = S.focus.key;
    renderPanel();
    if (k) {
      var again = $("ad4Panel").querySelector("[data-k=\"" + k + "\"]");
      S.focus.key = keep;
      if (again) { try { again.focus({ preventScroll: true }); } catch (e) { again.focus(); } }
    }
  }

  // ---- 미리보기 (자동 갱신) ----

  var auto = { cssTimer: null, fullTimer: null, cssBusy: false, cssAgain: false, fullBusy: false, fullAgain: false, fullRev: 0, seq: 0 };

  function scheduleCss() {
    if (auto.fullTimer || !URL_CSS) return; // 곧 전체를 다시 그리면 CSS 도 같이 온다
    global.clearTimeout(auto.cssTimer);
    auto.cssTimer = global.setTimeout(runCss, CSS_DELAY);
  }

  function scheduleFull() {
    global.clearTimeout(auto.cssTimer);
    auto.cssTimer = null;
    global.clearTimeout(auto.fullTimer);
    auto.fullTimer = global.setTimeout(runFull, FULL_DELAY);
  }

  function runCss() {
    auto.cssTimer = null;
    if (auto.cssBusy) { auto.cssAgain = true; return; }
    auto.cssBusy = true;
    var seq = ++auto.seq;
    request(URL_CSS, draftBody()).then(function (res) {
      auto.cssBusy = false;
      // 그 사이 전체 미리보기가 나갔으면 그 결과를 기다린다 (끝나면 다시 맞춘다)
      if (seq === auto.seq && !auto.fullBusy) {
        toFrame({ type: "ai4-design-css", css: res.css || "" });
        previewErrors(res.errors || []);
      }
      if (auto.cssAgain) { auto.cssAgain = false; runCss(); }
    }, function () {
      auto.cssBusy = false;
    });
  }

  function runFull() {
    global.clearTimeout(auto.fullTimer);
    auto.fullTimer = null;
    global.clearTimeout(auto.cssTimer);
    auto.cssTimer = null;
    if (!frameReady) return; // 틀이 준비되면 boot() 가 그린다
    if (auto.fullBusy) { auto.fullAgain = true; return; }
    auto.fullBusy = true;
    auto.fullRev = S.styleRev;
    auto.seq += 1; // 진행 중인 CSS 응답은 버린다
    // 응답이 오지 않는 경우(틀 오류)에도 멈추지 않게
    global.clearTimeout(auto.guard);
    auto.guard = global.setTimeout(function () { auto.fullBusy = false; }, 60000);
    toFrame({ type: "ai4-design-preview", draft: draftBody() });
  }

  function onPreviewDone(d) {
    global.clearTimeout(auto.guard);
    auto.fullBusy = false;
    previewErrors(d.errors || []);
    S.issues = { errors: d.errors || [], warnings: d.warnings || [] };
    renderTplIssues(); // 틀 탭이 열려 있으면 그 블록 검사 결과
    updateUseCheck();
    if (auto.fullAgain) { auto.fullAgain = false; runFull(); return; }
    if (auto.fullRev !== S.styleRev) runCss(); // 그리는 동안 바뀐 디자인 값
  }

  function previewErrors(errs) {
    if (errs.length) {
      message("error", "미리보기: 아래 값은 빼고 보여 드렸습니다.", errs);
      S.previewError = true;
    } else if (S.previewError) {
      message();
    }
  }

  // ---- 이력 ----

  function renderHistory(rows) {
    var tb = $("ad4History");
    tb.textContent = "";
    if (!rows || !rows.length) {
      var tr0 = el("tr");
      var td0 = el("td", "center", "게시한 적이 없습니다.");
      td0.colSpan = 6;
      tr0.appendChild(td0);
      tb.appendChild(tr0);
      return;
    }
    rows.forEach(function (r) {
      var tr = el("tr");
      var st = el("td", "center");
      st.appendChild(el("span", "badge sm " + (r.status === "published" ? "light_success" : "line_info"), r.status === "published" ? "게시 중" : "이력"));
      tr.appendChild(st);
      tr.appendChild(el("td", "center", r.publishedAt || ""));
      tr.appendChild(el("td", "center", r.version ? "v" + r.version : ""));
      tr.appendChild(el("td", "center", r.savedBy || ""));
      tr.appendChild(el("td", null, r.memo || ""));
      var act = el("td", "center");
      var btn = el("a", "btn secondary xsm", "불러오기");
      btn.href = "#";
      btn.onclick = function (e) {
        e.preventDefault();
        if (S.dirty && !global.confirm("저장하지 않은 변경이 사라집니다. 불러올까요?")) return;
        request(URL_LOAD, { id: r.designId }).then(function (res) {
          if (!res.ok || !res.record) { message("error", "불러오지 못했습니다.", res.errors); return; }
          fill(res.record);
          changed("text");
          message("ok", "v" + res.record.version + " 을(를) 불러왔습니다. 임시 저장한 뒤 게시하면 이 디자인으로 되돌아갑니다.");
        });
      };
      act.appendChild(btn);
      tr.appendChild(act);
      tb.appendChild(tr);
    });
  }

  // ---- 저장·미리보기·게시 ----

  function fill(rec) {
    S.templates = copy(rec && rec.templates);
    S.style = copy(rec && rec.style);
    if (!S.style.blocks) S.style.blocks = {};
    S.usePublisher = !!(rec && rec.usePublisher);
    $("ad4Publisher").checked = S.usePublisher;
    S.variants = normVariants(rec && rec.variants);
    S.assign = normAssign(rec && rec.assign);
    S.issues = { errors: [], warnings: [] };
    updateUseCheck();
    prune();
    S.styleRev += 1;
    renderPanel();
  }

  function draftBody() {
    return { templates: S.templates, style: S.style, usePublisher: S.usePublisher, variants: S.variants, assign: S.assign, memo: $("ad4Memo").value };
  }

  function load() {
    return request(URL_DATA).then(function (d) {
      S.meta = d.meta;
      S.published = d.published || null;
      S.draft = d.draft || null;
      S.savedVersion = d.draft ? d.draft.version : null;
      renderPicker();
      fill(d.draft || d.published || null);
      if (d.draft && d.draft.memo) $("ad4Memo").value = d.draft.memo;
      renderHistory(d.history);
      renderPublisher(d.publisher);
      S.dirty = false;
      renderState();
      var errs = (d.errors || []).concat(d.draft && d.draft.dropped ? d.draft.dropped : []);
      if (errs.length) message("error", "확인이 필요합니다.", errs);
      boot();
    });
  }

  /** 화면 데이터와 미리보기 틀이 모두 준비되면 이름표를 보내고 첫 미리보기를 그린다 (기본값도 이때 읽힌다) */
  var frameReady = false;
  var booted = false;
  function boot() {
    if (booted || !frameReady || !S.meta) return;
    booted = true;
    sendLabels();
    runFull();
  }

  function onFrameReady() {
    frameReady = true;
    booted = false; // 틀을 다시 읽었으면 다시 그린다
    auto.fullBusy = false;
    boot();
  }

  $("ad4Publisher").onchange = function () { S.usePublisher = this.checked; changed("publisher"); };

  Array.prototype.forEach.call(document.querySelectorAll(".ad4_tabs button"), function (bt) {
    bt.onclick = function () { S.tab = bt.getAttribute("data-tab"); renderPanel(); };
  });

  var resetBlock = $("ad4ResetBlock");
  if (resetBlock) {
    resetBlock.onclick = function (e) {
      e.preventDefault();
      var type = S.block;
      if (!blockHasChanges(type)) return;
      var name = $("ad4Block").options[$("ad4Block").selectedIndex].textContent;
      if (!global.confirm("\"" + name + "\"의 문구·디자인 값·틀을 모두 기본값으로 되돌릴까요? (임시 저장 전까지는 반영되지 않습니다)")) return;
      var text = false;
      S.meta.templates.forEach(function (t) {
        if (t.group === type && has(S.templates, t.key)) { delete S.templates[t.key]; text = true; }
      });
      // 할당에서 쓰는 기본 틀은 남긴다 (규칙이 없는 틀을 가리키지 않게)
      if (has(S.variants.variants, variantId(type)) && !usedBy(variantId(type)).length) { delete S.variants.variants[variantId(type)]; text = true; }
      if (S.style.blocks[type]) { delete S.style.blocks[type]; S.styleRev += 1; }
      renderPanel();
      changed(text ? "text" : "style");
    };
  }

  $("ad4Save").onclick = function (e) {
    e.preventDefault();
    request(URL_SAVE, draftBody()).then(function (res) {
      if (!res.ok) { message("error", "저장하지 않았습니다. 아래 값을 고쳐 주세요.", res.errors); return; }
      S.savedVersion = res.version;
      S.draft = { updatedAt: "방금" };
      setDirty(false);
      message("ok", "임시 저장했습니다 (v" + res.version + "). 미리보기로 확인한 뒤 게시해 주세요.");
    });
  };

  $("ad4Preview").onclick = function (e) {
    e.preventDefault();
    runFull();
  };

  $("ad4Publish").onclick = function (e) {
    e.preventDefault();
    if (S.dirty) { global.alert("저장하지 않은 변경이 있습니다. 먼저 임시 저장해 주세요."); return; }
    if (!S.savedVersion) { global.alert("임시 저장본이 없습니다. 먼저 임시 저장해 주세요."); return; }
    if (!global.confirm("임시 저장본(v" + S.savedVersion + ")을 게시할까요? 1분 안에 모든 서버의 상담4 답변에 적용됩니다.")) return;
    request(URL_PUBLISH, { version: S.savedVersion, memo: $("ad4Memo").value }).then(function (res) {
      if (!res.ok) { message("error", "게시하지 않았습니다.", res.errors); return; }
      message("ok", "게시했습니다 (v" + res.version + ").");
      load();
    });
  };

  global.addEventListener("message", function (e) {
    if (e.origin !== location.origin || !e.data) return;
    var d = e.data;
    if (d.type === "ai4-design-preview-done") onPreviewDone(d);
    else if (d.type === "ai4-design-preview-ready") onFrameReady();
    else if (d.type === "ai4-design-defaults") onDefaults(d.blocks, d.templated);
    else if (d.type === "ai4-design-pick") { if (S.meta) onPick(d); }
    else if (d.type === "ai4-design-go") onGo(d.choice);
    else if (d.type === "ai4-design-sample") { if (S.meta) onSample(d); }
    else if (d.type === "ai4-design-focus-done") onFocusDone(d);
  });

  global.addEventListener("beforeunload", function (e) {
    if (!S.dirty) return;
    e.preventDefault();
    e.returnValue = "";
  });

  // ---- 좌우 폭 조절 ----

  (function splitter() {
    var split = $("ad4Split");
    var wrap = root.querySelector(".ad4_wrap");
    var edit = root.querySelector(".ad4_edit");
    if (!split || !wrap || !edit) return;
    var KEY = "ad4.split";
    var DEFAULT = 52;
    var MIN_EDIT = 360;
    var MIN_PREV = 320;
    var pct = DEFAULT;
    try {
      var saved = parseFloat(global.localStorage.getItem(KEY));
      if (saved > 0 && saved < 100) pct = saved;
    } catch (e) { /* 저장소를 못 쓰면 기본 비율 */ }

    function narrow() { return global.matchMedia && global.matchMedia("(max-width: 1280px)").matches; }

    function apply(v) {
      if (narrow()) { edit.style.flex = ""; return; }
      var w = wrap.clientWidth;
      if (w > 0) {
        var lo = MIN_EDIT / w * 100;
        var hi = 100 - (MIN_PREV + split.offsetWidth) / w * 100;
        v = Math.min(Math.max(v, lo), Math.max(lo, hi));
      }
      pct = v;
      edit.style.flex = "0 0 " + v.toFixed(2) + "%";
      split.setAttribute("aria-valuenow", String(Math.round(v)));
    }

    function save() {
      try { global.localStorage.setItem(KEY, pct.toFixed(2)); } catch (e) { /* 무시 */ }
    }

    var dragging = false;
    split.addEventListener("pointerdown", function (e) {
      if (narrow()) return;
      dragging = true;
      split.setPointerCapture(e.pointerId);
      wrap.classList.add("is-dragging");
      e.preventDefault();
    });
    split.addEventListener("pointermove", function (e) {
      if (!dragging) return;
      var r = wrap.getBoundingClientRect();
      apply((e.clientX - r.left) / r.width * 100);
    });
    function end() {
      if (!dragging) return;
      dragging = false;
      wrap.classList.remove("is-dragging");
      save();
    }
    split.addEventListener("pointerup", end);
    split.addEventListener("pointercancel", end);
    split.addEventListener("dblclick", function () { apply(DEFAULT); save(); });
    split.addEventListener("keydown", function (e) {
      if (e.key !== "ArrowLeft" && e.key !== "ArrowRight") return;
      e.preventDefault();
      apply(pct + (e.key === "ArrowLeft" ? -2 : 2));
      save();
    });
    global.addEventListener("resize", function () { apply(pct); });
    apply(pct);
  })();

  // 미리보기 틀이 이 스크립트보다 먼저 준비됐을 수 있다 (준비 알림을 놓친 경우)
  try {
    if (frame && frame.contentWindow && frame.contentWindow.document.readyState === "complete" && frame.contentWindow.PT_AI_RENDER) frameReady = true;
  } catch (e) { /* 다른 출처 */ }

  load().catch(function (err) { message("error", "화면 데이터를 불러오지 못했습니다: " + err.message); });

  // 확인용 페이지(4.Test/ai4/design-harness.html)에서 상태를 볼 수 있게
  global.__ai4Design = S;
})(window);
