/* 메디링크 강원 — 공통 프롬프트 독 (리뉴얼 옵트인 시에만 로드)
 * - 랜딩: 히어로 폼(.search_form)을 컴포저(.rn_composer)로 재구성(노드 이동만, 리스너 보존)
 * - 하위 페이지: 동일 폼을 하단 독으로 주입하고 landing.js를 불러와 연결
 * - 스크롤 → 미니마이즈(.is_min) / 입력·포커스·클릭 → 원래 크기로 롤백 */
(function () {
  'use strict';
  var doc = document;

  function arrow() {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><path d="M12 19V5M6 11l6-6 6 6"/></svg>';
  }
  function optHtml(id, label, cls) {
    return '<div class="option_wrap"><button class="option_btn" id="' + id + '_btn" type="button" aria-expanded="false" aria-controls="' + id + '_panel">' + label +
      ' <svg class="option_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></button>' +
      '<div class="option_panel ' + cls + '" id="' + id + '_panel" hidden></div></div>';
  }

  var form = doc.querySelector('form.search_form');
  var isLanding = !!form;
  var slot = null;

  if (isLanding) {
    /* 1) 재구성: composer = tags + field(input) + options + send */
    var tags = form.querySelector('.selected_tags');
    var field = form.querySelector('.search_field');
    var opts = form.querySelector('.search_options');
    var send = form.querySelector('.search_btn');
    var composer = doc.createElement('div');
    composer.className = 'rn_composer';
    composer.appendChild(tags);
    composer.appendChild(field);
    composer.appendChild(opts);
    composer.appendChild(send);
    var chips = form.querySelector('.hero_chips');
    form.insertBefore(composer, chips);
    var sendIcon = send.querySelector('svg');
    if (sendIcon) sendIcon.outerHTML = arrow();
    slot = doc.createElement('div');
    slot.className = 'rn_slot';
    form.parentNode.insertBefore(slot, form);
    slot.appendChild(form);
  } else {
    /* 2) 하위 페이지: 폼 주입 */
    form = doc.createElement('form');
    form.className = 'search_form';
    form.setAttribute('role', 'search');
    form.innerHTML =
      '<div class="rn_composer">' +
      '<div class="selected_tags" id="selected_tags" aria-live="polite"></div>' +
      '<div class="search_field"><label for="medical_search" hidden>증상, 지역 또는 진료과 검색</label>' +
      '<input class="search_input" id="medical_search" type="search" placeholder="AI에게 물어보세요 — 예) 허리 통증이 있을 땐 어떤 과를 가야 해?" autocomplete="off"></div>' +
      '<div class="search_options" aria-label="검색 조건">' +
      optHtml('symptom', '증상별', 'symptom_panel') + optHtml('region', '지역별', 'region_panel') + optHtml('department', '진료과별', 'department_panel') +
      '</div>' +
      '<button class="search_btn" type="submit" aria-label="AI에게 질문하기">' + arrow() + '</button>' +
      '</div>';
    doc.body.appendChild(form);
  }

  form.classList.add('rn_prompt');
  var input = form.querySelector('#medical_search');

  /* 라벨: 옵션 버튼은 짧게 */
  [['symptom_btn', '증상별'], ['region_btn', '지역별'], ['department_btn', '진료과별']].forEach(function (p) {
    var b = doc.getElementById(p[0]);
    if (b && b.firstChild && b.firstChild.nodeType === 3) b.firstChild.nodeValue = p[1] + ' ';
  });

  /* 2.5) 옵션 항목 과다 대응: 자주 찾는 항목 우선 노출 + 더보기 + 패널 내 검색 (landing.js 무수정, 렌더 후 보강)
   *  - 상위 노출 목록은 임시 기준(일반적 이용 빈도 가정) → 이용 로그/공공데이터 진료 건수로 교체 필요 */
  var POP_DEPT = ['내과', '정형외과', '소아청소년과', '이비인후과', '피부과', '산부인과', '안과', '치과'];
  var POP_SYM = ['감기', '두통', '발열', '기침', '어지럼증', '허리디스크', '당뇨', '고혈압'];
  var CAP = 8;

  function filterBox(ph, onInput) {
    var wrap = doc.createElement('div');
    wrap.className = 'rn_tools';
    wrap.innerHTML = '<input class="rn_filter" type="search" placeholder="' + ph + '" autocomplete="off" aria-label="' + ph + '">';
    wrap.firstChild.addEventListener('input', function (e) { e.stopPropagation(); onInput(e.target.value.trim()); });
    return wrap;
  }
  function pinPopular(list, pops, attr) {
    var items = [].slice.call(list.children).filter(function (el) { return el.tagName === 'BUTTON'; });
    var pop = pops.map(function (n) { return items.filter(function (b) { return b.dataset[attr] === n; })[0]; }).filter(Boolean);
    pop.slice().reverse().forEach(function (b) { list.insertBefore(b, list.firstChild); });
    var all = [].slice.call(list.children).filter(function (el) { return el.tagName === 'BUTTON'; });
    all.forEach(function (b, i) { if (i >= CAP) b.classList.add('rn_extra'); });
    return all;
  }
  function moreBtn(list, label, total) {
    var b = doc.createElement('button');
    b.type = 'button'; b.className = 'rn_more_btn';
    b.textContent = label + ' (' + total + ')';
    b.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = list.classList.toggle('rn_open');
      b.textContent = open ? '접기' : label + ' (' + total + ')';
    });
    return b;
  }
  function localFilter(list, items, more) {
    return function (q) {
      list.classList.toggle('rn_open', !!q);
      if (more) more.hidden = !!q;
      items.forEach(function (b) { b.hidden = !!q && b.textContent.indexOf(q) < 0; });
    };
  }
  function enhance(panel) {
    if (!panel || panel.querySelector('.rn_tools, .rn_more_btn')) return;
    var id = panel.id, list, items, more, box;
    if (id === 'department_panel') {
      list = panel.querySelector('.department_grid'); if (!list) return;
      items = pinPopular(list, POP_DEPT, 'department');
      more = moreBtn(list, '전체 진료과 보기', items.length);
      box = filterBox('진료과 검색', localFilter(list, items, more));
      list.parentNode.insertBefore(box, list);
      list.parentNode.insertBefore(more, list.nextSibling);
    } else if (id === 'region_panel') {
      var grids = panel.querySelectorAll('.panel_grid');
      if (!grids.length) return;
      items = [].slice.call(panel.querySelectorAll('.panel_item'));
      var apply = function (q) { items.forEach(function (b) { b.hidden = !!q && b.textContent.indexOf(q) < 0; }); [].forEach.call(panel.querySelectorAll('.panel_label'), function (l) { l.hidden = !!q; }); };
      box = filterBox(grids[0].classList.contains('emd_grid') ? '읍·면·동 검색' : '시·군 검색', apply);
      grids[0].parentNode.insertBefore(box, panel.querySelector('.panel_all') || grids[0]);
    } else if (id === 'symptom_panel') {
      list = panel.querySelector('.symptom_list'); if (!list) return;
      var qv = panel.querySelector('#symptom_query'), cat = panel.querySelector('.category_btn.is_active');
      if ((qv && qv.value) || (cat && cat.dataset.category !== '전체')) { list.parentNode.insertBefore(Object.assign(doc.createElement('i'), { className: 'rn_tools' }), list); return; }
      items = pinPopular(list, POP_SYM, 'symptom');
      if (items.length <= CAP) return;
      list.parentNode.insertBefore(moreBtn(list, '전체 증상 보기', items.length), list.nextSibling);
    }
  }
  ['symptom_panel', 'region_panel', 'department_panel'].forEach(function (id) {
    var panel = doc.getElementById(id);
    if (!panel) return;
    new MutationObserver(function () { enhance(panel); }).observe(panel, { childList: true });
    enhance(panel);
  });

  /* 패널을 다시 열 때 이전 검색어 초기화 */
  form.addEventListener('click', function (e) {
    if (!e.target.closest('.option_btn')) return;
    [].forEach.call(form.querySelectorAll('.rn_filter'), function (f) {
      if (f.value) { f.value = ''; f.dispatchEvent(new Event('input')); }
    });
  });

  /* 3) 상태 제어 */
  var docked = false, min = false, hover = false;
  function panelOpen() { return !!form.querySelector('.option_panel:not([hidden])'); }
  function hasValue() { return (input && input.value.trim()) || form.querySelector('.selected_tag'); }
  function setMin(v) {
    min = v;
    form.classList.toggle('is_min', docked && v);
  }
  function setDock(v) {
    if (v === docked) return;
    docked = v;
    if (v && slot) slot.style.height = slot.getBoundingClientRect().height + 'px';
    form.classList.toggle('is_dock', v);
    if (!v && slot) slot.style.height = '';
    if (!v) form.classList.remove('is_min');
    else setMin(true);
  }
  function expand() { if (docked) setMin(false); }
  function maybeMin() {
    if (docked && !panelOpen() && !hasValue() && !form.contains(doc.activeElement) && !hover) setMin(true);
  }

  function onScroll() {
    if (!isLanding) { setDock(true); return; }
    var r = slot.getBoundingClientRect();
    var h = parseFloat(slot.style.height) || r.height;
    /* 도킹 상태에서는 슬롯 높이가 고정되므로 슬롯 위치 기준으로 판단 */
    var shouldDock = r.top + h * 0.55 < 72;
    var was = docked;
    setDock(shouldDock);
    if (shouldDock && was) maybeMin();
  }

  form.addEventListener('focusin', expand);
  form.addEventListener('pointerdown', expand);
  form.addEventListener('input', expand);
  form.addEventListener('mouseenter', function () { hover = true; expand(); });
  form.addEventListener('mouseleave', function () { hover = false; setTimeout(maybeMin, 600); });
  form.addEventListener('focusout', function () { setTimeout(maybeMin, 150); });
  form.addEventListener('click', function () { setTimeout(maybeMin, 0); });
  doc.addEventListener('keydown', function (e) { if (e.key === 'Escape') { if (input) input.blur(); setTimeout(maybeMin, 0); } });
  /* 스크롤: 창/내부 스크롤 컨테이너(.page_scroll) 모두 캡처 */
  var ticking = false;
  function tick() { if (ticking) return; ticking = true; requestAnimationFrame(function () { ticking = false; onScroll(); }); }
  doc.addEventListener('scroll', tick, true);
  window.addEventListener('resize', tick);

  if (!isLanding) {
    doc.body.classList.add('rn_has_dock');
    /* landing.js 연결 (최상위 const 충돌 방지를 위해 함수 스코프로 실행) */
    fetch('/common/front/kor/js/landing.js').then(function (r) { return r.text(); }).then(function (src) {
      try { (new Function(src))(); } catch (e) { if (window.console) console.warn('[renewal-dock] landing.js', e); }
    });
    setDock(true);
  } else {
    doc.body.classList.add('rn_has_dock');
    onScroll();
  }
})();
