/* 메디링크 강원 — 공통 프롬프트 독 (리뉴얼 옵트인 시에만 로드)
 * - 뷰포트 하단 고정. 구성: [옵션(증상별·지역별·진료과별) 상단] + [입력창 + 전송]
 * - 랜딩 최상단: 큰 상태 / 스크롤: 한 줄 미니(폭·버튼 축소, 옵션은 + 아이콘) / 클릭·입력·포커스: 다시 커짐
 * - 하위 페이지: 동일 폼을 주입(미니 상태로 시작), landing.js 를 불러와 연결
 * - 옵션 패널은 위로 열리며 헤더 아래로 가려지지 않도록 높이를 계산해 제한 */
(function () {
  'use strict';
  var doc = document;

  function arrow() {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><path d="M12 19V5M6 11l6-6 6 6"/></svg>';
  }
  function plus() {
    var b = doc.createElement('button');
    b.type = 'button'; b.className = 'rn_plus'; b.setAttribute('aria-label', '검색 옵션 열기 (증상별·지역별·진료과별)');
    b.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>';
    return b;
  }
  function optHtml(id, label, cls) {
    return '<div class="option_wrap"><button class="option_btn" id="' + id + '_btn" type="button" aria-expanded="false" aria-controls="' + id + '_panel">' + label +
      ' <svg class="option_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></button>' +
      '<div class="option_panel ' + cls + '" id="' + id + '_panel" hidden></div></div>';
  }

  var form = doc.querySelector('form.search_form');
  var isLanding = !!form;
  var composer;

  if (isLanding) {
    /* 1) 재구성: 폼에는 컴포저만 남기고(뷰포트 하단 고정), 설명·바로가기·고지는 히어로에 남긴다 */
    var tags = form.querySelector('.selected_tags');
    var field = form.querySelector('.search_field');
    var opts = form.querySelector('.search_options');
    var send = form.querySelector('.search_btn');
    var aux = doc.createElement('div');
    aux.className = 'rn_hero_aux';
    ['.search_desc', '.hero_chips', '.hero_note'].forEach(function (s) { var n = form.querySelector(s); if (n) aux.appendChild(n); });
    form.parentNode.insertBefore(aux, form);
    composer = doc.createElement('div');
    composer.className = 'rn_composer';
    composer.appendChild(opts);
    composer.appendChild(tags);
    composer.appendChild(plus());
    composer.appendChild(field);
    composer.appendChild(send);
    form.appendChild(composer);
    var sendIcon = send.querySelector('svg');
    if (sendIcon) sendIcon.outerHTML = arrow();
    doc.body.appendChild(form);
  } else {
    /* 2) 하위 페이지: 폼 주입 */
    form = doc.createElement('form');
    form.className = 'search_form';
    form.setAttribute('role', 'search');
    form.innerHTML =
      '<div class="rn_composer">' +
      '<div class="search_options" aria-label="검색 조건">' +
      optHtml('symptom', '증상별', 'symptom_panel') + optHtml('region', '지역별', 'region_panel') + optHtml('department', '진료과별', 'department_panel') +
      '</div>' +
      '<div class="selected_tags" id="selected_tags" aria-live="polite"></div>' +
      '<div class="search_field"><label for="medical_search" hidden>증상, 지역 또는 진료과 검색</label>' +
      '<input class="search_input" id="medical_search" type="search" placeholder="AI에게 물어보세요 — 예) 허리 통증이 있을 땐 어떤 과를 가야 해?" autocomplete="off"></div>' +
      '<button class="search_btn" type="submit" aria-label="AI에게 질문하기">' + arrow() + '</button>' +
      '</div>';
    composer = form.firstChild;
    composer.insertBefore(plus(), composer.querySelector('.search_field'));
    doc.body.appendChild(form);
  }

  form.classList.add('rn_prompt', 'is_dock');
  var input = form.querySelector('#medical_search');
  doc.body.classList.add('rn_has_dock');

  [['symptom_btn', '증상별'], ['region_btn', '지역별'], ['department_btn', '진료과별']].forEach(function (p) {
    var b = doc.getElementById(p[0]);
    if (b && b.firstChild && b.firstChild.nodeType === 3) b.firstChild.nodeValue = p[1] + ' ';
  });

  /* 2.5) 옵션 항목 과다 대응: 자주 찾는 항목 우선 + 더보기 + 패널 내 검색 (landing.js 무수정)
   *  - 상위 노출 목록은 임시 기준 → 이용 로그/공공데이터 진료 건수로 교체 필요 */
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
      fitPanel();
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
    new MutationObserver(function () { enhance(panel); fitPanel(); }).observe(panel, { childList: true });
    enhance(panel);
  });

  /* 열린 패널이 헤더 아래로 숨지 않도록 높이 제한 (데스크톱; 모바일은 바텀시트) */
  function fitPanel() {
    var hdr = doc.querySelector('.gm_header');
    var top = hdr ? hdr.getBoundingClientRect().bottom : 72;
    [].forEach.call(form.querySelectorAll('.option_panel'), function (p) {
      if (p.hidden) { p.style.maxHeight = ''; return; }
      if (window.innerWidth <= 760) { p.style.maxHeight = ''; return; }
      var wrapTop = p.parentNode.getBoundingClientRect().top;
      p.style.maxHeight = Math.max(200, Math.min(560, wrapTop - top - 24)) + 'px';
    });
  }

  /* 패널을 다시 열 때 이전 검색어 초기화 */
  form.addEventListener('click', function (e) {
    if (!e.target.closest('.option_btn')) return;
    [].forEach.call(form.querySelectorAll('.rn_filter'), function (f) {
      if (f.value) { f.value = ''; f.dispatchEvent(new Event('input')); }
    });
    setTimeout(fitPanel, 0);
  });

  /* 3) 상태 제어: hero(랜딩 최상단 큰 상태) / min(한 줄) / 클릭·입력 시 큰 상태 */
  var scrolled = !isLanding;   // 하위 페이지는 처음부터 미니
  var userOpen = false;
  function panelOpen() { return !!form.querySelector('.option_panel:not([hidden])'); }
  function hasValue() { return (input && input.value.trim()) || form.querySelector('.selected_tag'); }
  function render() {
    form.classList.toggle('is_hero', isLanding && !scrolled);
    form.classList.toggle('is_min', scrolled && !userOpen);
    fitPanel();
  }
  function expand() { userOpen = true; render(); }
  function maybeMin() {
    if (!userOpen) return;
    if (panelOpen() || hasValue() || form.contains(doc.activeElement)) return;
    userOpen = false; render();
  }

  form.addEventListener('focusin', expand);
  form.addEventListener('pointerdown', function (e) {
    if (e.target.closest('.rn_plus')) {   // + 아이콘: 펼친 뒤 입력창에 포커스(레이아웃 변경으로 포커스가 사라지는 것 방지)
      e.preventDefault(); expand(); if (input) input.focus({ preventScroll: true }); return;
    }
    expand();
  });
  form.addEventListener('input', expand);
  form.addEventListener('focusout', function () { setTimeout(maybeMin, 200); });
  form.addEventListener('click', function () { setTimeout(maybeMin, 250); });
  doc.addEventListener('click', function (e) {
    if (e.target.closest('[data-open-panel]')) expand();           // 히어로 '질병 정보' 등에서 옵션 열기
    else if (!form.contains(e.target)) setTimeout(maybeMin, 250);
  });
  doc.addEventListener('keydown', function (e) { if (e.key === 'Escape') { if (input) input.blur(); setTimeout(maybeMin, 0); } });

  function onScroll() {
    if (!isLanding) return;
    var s = (window.pageYOffset || doc.documentElement.scrollTop || 0) > 80;
    if (s === scrolled) { fitPanel(); return; }
    scrolled = s;
    if (s && !hasValue() && !panelOpen()) { if (input) input.blur(); userOpen = false; }
    render();
  }
  var ticking = false;
  function tick() { if (ticking) return; ticking = true; requestAnimationFrame(function () { ticking = false; onScroll(); }); }
  doc.addEventListener('scroll', tick, true);
  window.addEventListener('resize', function () { tick(); fitPanel(); });

  if (!isLanding) {
    /* landing.js 연결 (최상위 const 충돌 방지를 위해 함수 스코프로 실행) */
    fetch('/common/front/kor/js/landing.js').then(function (r) { return r.text(); }).then(function (src) {
      try { (new Function(src))(); } catch (e) { if (window.console) console.warn('[renewal-dock] landing.js', e); }
    });
  }
  onScroll();
  render();
})();
