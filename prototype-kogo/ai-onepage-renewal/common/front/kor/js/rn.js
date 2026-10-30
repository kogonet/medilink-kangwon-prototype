/* 메디링크 강원 리뉴얼 — 공통 스크립트 (모든 페이지). body 끝, 원안 스크립트 다음에 defer 로 로드 */

/* ═════════════════ 원안 메인 정리 ═════════════════ */
/* 원안 메인(index.jsp) 정리 — 원안 마크업은 그대로 두고, 한 페이지 상담에 쓰지 않는 요소를 걷어낸다.
 * 프롬프트 독·셸보다 먼저 실행되어야 하므로 rn.js 의 맨 앞에 둔다.
 * 개발 반영 시 index.jsp 에서 해당 마크업을 지우면 이 블록도 지운다. */
(function () {
  'use strict';
  var doc = document, hero = doc.querySelector('.hero_wrap');
  if (!hero) return;
  function rm(sel) { [].forEach.call(doc.querySelectorAll(sel), function (n) { n.parentNode.removeChild(n); }); }
  rm('.hero_wrap .hero_chips, .hero_wrap .service_link');                  // 히어로 바로가기 칩 · '의료 서비스 보기' (셸 헤더 바로가기로 대체)
  rm('.service_wrap, .ai_wrap, .notice_wrap, .footer_wrap');               // 의료 서비스 · AI Concierge · 공지/FAQ 섹션 · 원안 푸터 (셸 푸터로 대체)
  rm('.quick_wrap');                                                       // 원안 퀵메뉴 — 셸이 공통 퀵메뉴로 다시 그린다
  var note = hero.querySelector('.hero_note'), form = hero.querySelector('form.search_form');
  if (note && form) { note.className = 'op_fnote'; form.appendChild(note); }   // 고지 문구는 입력창 바로 아래(독 안)로
})();

/* ═════════════════ 공통 셸 (헤더·퀵메뉴·푸터 주입) ═════════════════ */
/* 공통 셸 — 헤더(좌 로고 / 우 바로가기·지도·기록·계정), 퀵메뉴, 푸터를 주입한다.
 * 원안 마크업(데코레이터·각 JSP)을 고치지 않기 위해 셸은 이 스크립트가 만든다.
 * 다른 리뉴얼 스크립트가 #opUtil 등을 찾으므로 rn.js 의 맨 앞에서 동기로 실행한다.
 * 개발 반영 시: ROUTES 의 .html 을 실제 .do 주소로 바꾼다. 셸 마크업을 데코레이터로 옮기면 이 블록은 지운다. */
(function () {
  'use strict';
  var doc = document, body = doc.body;
  if (doc.getElementById('opUtil')) return;   // 이미 셸 마크업이 있는 페이지(데코레이터로 옮긴 뒤)는 건너뛴다

  /* 경로 — 개발: index.do / hospitalList.do / pharmacyList.do / erLive.do / login.do … */
  var ROUTES = window.RN_ROUTES || {
    home: 'index.html', hospital: 'hospital.html', pharmacy: 'pharmacy.html', er: 'er-live.html', login: 'login.html',
    terms: 'terms.html', info: 'info.html', guide: 'guide.html', project: 'project.html', company: 'company.html', directions: 'directions.html',
    vaccination: '/front/medical/vaccinationList.do', knuh: 'http://pt-ai.ctit.co.kr/knuh/ai-consult.do'
  };
  var IMG = '/common/front/kor/images/';

  /* 페이지 종류: 메인(히어로 존재) / 지도형(병·의원·약국) / 응급실 / 계정 / 문서 */
  var isHome = !!doc.querySelector('.hero_wrap');
  var isAcc = body.classList.contains('op_acc');
  var path = location.pathname;
  var cur = /hospital/i.test(path) ? 'hospital' : /pharmacy/i.test(path) ? 'pharmacy' : /er-?live/i.test(path) ? 'er' : '';
  var isMap = cur === 'hospital' || cur === 'pharmacy';

  var I = function (d) { return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + d + '</svg>'; };
  var ICON = {
    menu: I('<path d="M4 6h16M4 12h16M4 18h16"/>'),
    map: I('<path d="M9 4 3 6.5v13L9 17l6 3 6-2.5v-13L15 7zM9 4v13M15 7v13"/>'),
    hist: I('<path d="M5 6h14v10H9l-4 3z"/>'),
    acct: I('<circle cx="12" cy="8" r="4"/><path d="M4 20c1.5-4 4.5-6 8-6s6.5 2 8 6"/>'),
    up: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 15 6-6 6 6"/></svg>',
    syringe: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m18 2 4 4M17 7l3-3M19 9 8.7 19.3a1 1 0 0 1-1.4 0l-2.6-2.6a1 1 0 0 1 0-1.4L15 5M9 11l4 4M5 19l-3 3M14 4l6 6"/></svg>'
  };
  function nav(key, label) { return '<a href="' + ROUTES[key] + '"' + (cur === key ? ' aria-current="page"' : '') + '>' + label + '</a>'; }
  function frag(html) { var t = doc.createElement('template'); t.innerHTML = html; return t.content; }

  /* ① 헤더 */
  var mapAttr = isHome ? ' aria-haspopup="dialog" aria-expanded="false" aria-controls="opPnMap"' : '';
  var mapState = isMap ? ' aria-current="page"' : ' disabled';
  var head =
    (isHome ? '' : '<a class="op_skip" href="#main">본문으로 바로가기</a>') +
    '<aside class="op_side" id="opSide" aria-label="전역 메뉴">' +
      '<a class="op_logo" id="opLogo" href="' + (isHome ? '#top' : ROUTES.home) + '" aria-label="메디링크 강원 홈"><img src="' + IMG + 'medilink-bi.svg" alt="메디링크 강원 MediLink Kangwon"></a>' +
    '</aside>' +
    '<div class="op_util" id="opUtil" role="toolbar" aria-label="바로가기와 대화 도구">' +
      '<nav class="op_tnav" id="opSideNav" aria-label="바로가기">' + nav('hospital', '병·의원 찾기') + nav('pharmacy', '약국 찾기') + nav('er', '응급실 LIVE') + '</nav>' +
      '<button class="op_ub op_side_m" id="opSideMenuBtn" type="button" aria-expanded="false" aria-controls="opSideNav" aria-label="바로가기 열기">' + ICON.menu + '</button>' +
      '<button class="op_ub" id="opMapBtn" type="button"' + mapAttr + ' aria-label="지도 보기" title="지도 보기"' + mapState + '>' + ICON.map +
        (isHome ? '<span class="op_sr"><em id="opMapCnt"></em></span><i class="op_dot" aria-hidden="true"></i>' : '') + '</button>' +
      '<button class="op_ub" id="opHistBtn" type="button"' + (isHome ? ' aria-haspopup="dialog" aria-expanded="false" aria-controls="opPnHist"' : '') + ' aria-label="채팅 기록" title="채팅 기록" disabled>' + ICON.hist + '</button>' +
      '<a class="op_ub" id="opAcctBtn" href="' + ROUTES.login + '" aria-label="로그인" title="로그인">' + ICON.acct + '<span class="op_sr" id="opAcctLabel">로그인</span></a>' +
    '</div>';
  body.insertBefore(frag(head), body.firstChild);

  if (isAcc) return;   // 계정 페이지는 헤더만

  /* ② 퀵메뉴 (원안 메인에는 이미 있으므로 없을 때만) */
  var main = doc.querySelector('main');
  var tail = main ? main.nextSibling : null;
  if (!doc.querySelector('.quick_wrap')) {
    var quick =
      '<aside class="quick_wrap" aria-label="퀵메뉴"><div class="quick_group"><span class="quick_title">QUICK<br>MENU</span><ul class="quick_list">' +
        '<li><a class="quick_link" href="' + ROUTES.vaccination + '"><span class="quick_icon" aria-hidden="true">' + ICON.syringe + '</span><span class="quick_name">예방접종<br>병원찾기</span></a></li>' +
        '<li class="quick_partner"><a class="quick_link" href="' + ROUTES.knuh + '" target="_blank" rel="noopener" title="강원대학교병원 AI 상담 열기"><img class="quick_logo" src="' + IMG + 'knuh_ci.png" alt="" width="371" height="128"><span class="quick_name">강원대학교<br>병원</span></a></li>' +
      '</ul></div><a class="quick_top" href="#top" aria-label="맨 위로 이동">' + ICON.up + '</a></aside>';
    body.insertBefore(frag(quick), tail);
  }

  /* ③ 푸터 */
  var top = isHome ? '#top' : ROUTES.home;
  var foot =
    '<footer class="site-ft" id="opFooter"><div class="ft_in">' +
      '<div class="ft_top"><a href="' + top + '" class="ft-bi" aria-label="메디링크 강원 맨 위로"><img src="' + IMG + 'medilink-bi-white.svg" alt="메디링크 강원 MediLink Kangwon"></a>' +
        '<nav class="site-ft-links" aria-label="푸터 메뉴">' +
          '<a href="' + ROUTES.terms + '">이용약관</a><a href="' + ROUTES.info + '">정보공개</a><a href="' + ROUTES.guide + '">서비스가이드</a>' +
          '<a href="' + ROUTES.project + '">사업소개</a><a href="' + ROUTES.company + '">회사소개</a><a href="' + ROUTES.directions + '">찾아오시는길</a>' +
        '</nav></div>' +
      '<div class="ft_body"><address class="ft_info">' +
        '<p class="ft_org">한국글로벌헬스케어사업협동조합 · 코고네트웍스</p><p class="ft_en">KOGHA | KOGO NETWORKS</p>' +
        '<p>CP <a href="tel:+811088769980">81-10-8876-9980</a> · <a href="mailto:andy@polestarhc.com">andy@polestarhc.com</a></p>' +
        '<p>강원특별자치도 원주시 지정면 기업도시로 200 의료기기종합지원센터</p><p class="copy">© KOGO NETWORKS. ALL RIGHTS RESERVED.</p>' +
      '</address><a class="ft_totop" href="' + (isHome ? '#top' : '#main') + '" aria-label="맨 위로 이동"><span>TOP</span>' + ICON.up + '</a></div>' +
    '</div></footer>';
  var q = doc.querySelector('.quick_wrap');
  body.insertBefore(frag(foot), q && q.parentNode === body ? q.nextSibling : tail);
})();

/* ═════════════════ 프롬프트 독 (구 renewal-dock.js) ═════════════════ */
/* 메디링크 강원 — 공통 프롬프트 독
 * - 뷰포트 하단 고정. 구성: [옵션(증상별·지역별·진료과별) 상단] + [입력창 + 전송]
 * - 랜딩 최상단: 큰 상태 / 스크롤: 한 줄 미니(폭·버튼 축소, 옵션은 + 아이콘) / 클릭·입력·포커스: 다시 커짐
 * - 하위 페이지: 동일 폼을 주입(미니 상태로 시작), landing.js 를 불러와 연결
 * - 옵션 패널은 위로 열리며 헤더 아래로 가려지지 않도록 높이를 계산해 제한 */
(function () {
  'use strict';
  var doc = document;
  if (doc.body.classList.contains('op_acc')) return;   // 계정 페이지(로그인·회원가입·찾기)는 독을 두지 않는다

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
  /* 최근 검색 (localStorage, 실패 시 무시) */
  var RK = 'rn_recent_q';
  function getRecent() { try { return JSON.parse(localStorage.getItem(RK) || '[]'); } catch (e) { return []; } }
  function currentQuery() {
    var t = input && input.value.trim();
    if (t) return t;
    return [].map.call(form.querySelectorAll('.selected_tag'), function (x) {
      var c = x.cloneNode(true);
      [].forEach.call(c.querySelectorAll('b, button'), function (n) { n.remove(); });
      return c.textContent.trim();
    }).join(' ').trim();
  }
  form.addEventListener('submit', function () {
    var q = currentQuery(); if (!q) return;
    try {
      var list = getRecent().filter(function (x) { return x !== q; });
      list.unshift(q);
      localStorage.setItem(RK, JSON.stringify(list.slice(0, 5)));
    } catch (e) { /* 저장 불가 환경 */ }
  }, true);
  function addRecent(panel) {
    var rec = getRecent().slice(0, 3);
    if (!rec.length || panel.querySelector('.rn_recent')) return;
    var box = doc.createElement('div');
    box.className = 'rn_recent';
    box.innerHTML = '<span>최근 검색</span>' + rec.map(function (q) {
      return '<button type="button" class="rn_recent_chip">' + q.replace(/&/g, '&amp;').replace(/</g, '&lt;') + '</button>';
    }).join('');
    box.addEventListener('click', function (e) {
      var c = e.target.closest('.rn_recent_chip'); if (!c) return;
      e.stopPropagation();
      if (input) { input.value = c.textContent; input.dispatchEvent(new Event('input', { bubbles: true })); input.focus(); }
      var btn = doc.getElementById(panel.id.replace('_panel', '_btn')); if (btn) btn.click();
    });
    var head = panel.querySelector('.panel_head');
    panel.insertBefore(box, head ? head.nextSibling : panel.firstChild);
  }
  /* 개수 표시 (데이터는 landing.js 에서 노출한 window.__rnData) */
  function decorate(panel) {
    var d = window.__rnData; if (!d || !panel) return;
    var head = panel.querySelector('.panel_head span');
    if (panel.id === 'department_panel') {
      if (head && !head.dataset.rn) { head.textContent = d.departments.length + '개 진료과'; head.dataset.rn = 1; }
    } else if (panel.id === 'region_panel') {
      var parents = panel.querySelectorAll('[data-parent]');
      if (parents.length) {
        if (head && !head.dataset.rn) { head.textContent = parents.length + '개 시·군'; head.dataset.rn = 1; }
        [].forEach.call(parents, function (b) {
          if (b.querySelector('small')) return;
          var r = d.regions.filter(function (x) { return x.name === b.dataset.parent; })[0];
          if (r) b.insertAdjacentHTML('beforeend', '<small>' + r.children.length + '</small>');
        });
      }
    } else if (panel.id === 'symptom_panel') {
      [].forEach.call(panel.querySelectorAll('.category_btn'), function (b) {
        if (b.querySelector('small')) return;
        var c = b.dataset.category;
        var n = c === '전체' ? d.symptoms.length : d.symptoms.filter(function (x) { return x.category === c; }).length;
        b.insertAdjacentHTML('beforeend', '<small>' + n + '</small>');
      });
    }
  }

  /* 선택은 칩으로 쌓고 '전송'으로 묻는다 (landing.js 의 즉시 이동을 대체) */
  window.__rnSelect = function (type, value, a) {
    a.selected[type] = value;
    a.renderTags();
    a.closePanels();
    expand();
    if (input) input.focus({ preventScroll: true });
  };
  function hookLanding() {
    try {
      if (typeof selectOption === 'function' && typeof selected !== 'undefined') {
        window.selectOption = function (type, value) {
          window.__rnSelect(type, value, { selected: selected, renderTags: renderTags, closePanels: closePanels });
        };
        window.__rnData = { regions: regions, departments: departments, symptoms: symptoms };
        ['symptom_panel', 'region_panel', 'department_panel'].forEach(function (id) { decorate(doc.getElementById(id)); });
      }
    } catch (e) { /* landing.js 미로딩 */ }
  }
  if (isLanding) {
    if (doc.readyState === 'complete') hookLanding(); else doc.addEventListener('DOMContentLoaded', hookLanding);   // defer 스크립트 실행 시점의 readyState 는 'interactive'
  }

  ['symptom_panel', 'region_panel', 'department_panel'].forEach(function (id) {
    var panel = doc.getElementById(id);
    if (!panel) return;
    new MutationObserver(function () { enhance(panel); decorate(panel); addRecent(panel); fitPanel(); }).observe(panel, { childList: true });
    enhance(panel); decorate(panel); addRecent(panel);
  });

  /* 열린 패널이 헤더 아래로 숨지 않도록 높이 제한 (데스크톱; 모바일은 바텀시트) */
  function fitPanel() {
    var hdr = doc.querySelector('.gm_header');
    var top = hdr ? hdr.getBoundingClientRect().bottom : 72;
    [].forEach.call(form.querySelectorAll('.option_panel'), function (p) {
      if (p.hidden) { p.style.maxHeight = ''; return; }
      if (window.innerWidth <= 760) { p.style.maxHeight = ''; return; }
      var wrapTop = composer.getBoundingClientRect().top;
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
  var tracks = isLanding || doc.body.getAttribute('data-rn-dock') === 'full';   // 랜딩/결과 페이지: 스크롤에 따라 축소
  var scrolled = !tracks || (!isLanding && window.innerWidth <= 760);   // 결과 페이지는 모바일에서 한 줄로 시작   // 그 외 하위 페이지는 처음부터 미니
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
    if (!tracks) return;
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
      try {
        src = src.replace('function selectOption(type, value) {', 'function selectOption(type, value) { if (window.__rnSelect) { return window.__rnSelect(type, value, { selected: selected, renderTags: renderTags, closePanels: closePanels }); }');
        src += '\n;window.__rnData = { regions: regions, departments: departments, symptoms: symptoms };';
        (new Function(src))();
        ['symptom_panel', 'region_panel', 'department_panel'].forEach(function (id) { var pn = doc.getElementById(id); decorate(pn); addRecent(pn); });
      } catch (e) { if (window.console) console.warn('[renewal-dock] landing.js', e); }
    });
  }
  onScroll();
  render();
})();

/* ═════════════════ 병원 AI 하위 세션 (구 hospital-session.js) ═════════════════ */
/* 병원 하위 세션 — 우리 AI 대화 안에 병원 AI를 하위 세션으로 붙인다.
 *  진입  퀵메뉴의 병원 항목(공통) → 우측에서 좌측으로 열려 페이지 전체(로고 포함)를 덮는 서랍
 *        헤더 우측 도구와 프롬프트는 같은 위치에 그대로 둔다. 병원이 늘면 HOSPITALS 에 항목만 추가한다.
 *  상태  closed → open(서랍) ↔ min(우측 레일)
 *  저장  세션: sessionStorage(페이지 이동 시 최소화로 유지)
 *  응답  목업(키워드 규칙). 병원별 AI 엔드포인트가 정해지면 reply() 만 교체한다. */
(function () {
  'use strict';
  var doc = document, root = doc.documentElement;

  var ARROW = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>';
  var MIN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 6-6 6 6 6"/></svg>';
  var HOSP_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 21h18M5 21V8l7-4 7 4v13M12 9v5M9.5 11.5h5M10 21v-4h4v4"/></svg>';
  var CHEV = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>';
  var X = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>';
  var HOME = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 11.5 12 4l9 7.5M5.5 10v10h13V10M10 20v-5h4v5"/></svg>';

  /* ── 병원 레지스트리 ── */
  var HOSPITALS = [{
    id: 'knuh',
    name: '강원대학교병원',
    en: 'Kangwon National University Hospital',
    logo: '/common/front/kor/images/knuh_ci.png',
    home: 'https://www.knuh.or.kr',
    lead: '강원대학교병원 AI가 진료·병원 이용에 관한 정보를 안내해 드립니다.',
    cards: [
      { t: '의료진 소개', d: '각 진료과 전문의와 풍부한 임상 경험의 의료진을 소개합니다.', bl: ['진료과별 전문의 안내', '담당 의료진 상세 프로필', '전문클리닉 의료진 소개'], btn: ['진료과 및 의료진 소개'], pri: true, sec: 0 },
      { t: '진료안내', d: '외래진료, 진료절차, 건강검진', bl: ['외래진료 안내', '복용약 처방 안내', '검사실 및 예약 안내'], btn: ['외래진료 안내', '복용약 처방 안내', '검사실 및 예약 안내'], sec: 3 },
      { t: '병원안내', d: '병원이용, 층별, 오시는길 안내', bl: ['오시는길 안내', '입원 절차 및 준비사항', '건강검진 안내'], btn: ['병원이용', '입원 안내', '건강검진 안내'], sec: 4 }
    ],
    tabs: [
      ['진료과', ['가정의학과', '감염내과', '구강외과/치과', '내분비내과', '류마티스내과', '마취통증의학과', '방사선종양학과', '병리과', '비뇨의학과', '산부인과', '성형외과', '소아성형외과', '소아청소년과', '순환기내과', '신경과', '신경외과', '신장내과', '심장혈관흉부외과', '안과', '영상의학과', '외과', '응급의학과', '이비인후과', '재활의학과', '정신건강의학과', '정형외과', '진단검사의학과', '피부과'], '진료과'],
      ['전문센터', ['암센터', '심뇌혈관센터', '응급의료센터', '건강증진센터', '수술센터', '소아청소년센터', '인공신장센터', '재활센터'], '전문센터'],
      ['클리닉', ['금연클리닉', '수면클리닉', '통증클리닉', '갑상선클리닉', '당뇨클리닉', '비만클리닉', '두통클리닉', '어지럼클리닉', '천식클리닉', '척추클리닉', '유방클리닉', '인지장애클리닉'], '클리닉'],
      ['진료안내', ['외래 예약', '예약 확인·변경', '예약 취소', '검사 예약', '건강검진 예약'], '진료 예약'],
      ['병원이용', ['오시는 길', '주차 안내', '층별 안내', '편의시설', '면회 안내', '입원 절차'], '병원 이용'],
      ['건강정보', ['질환 정보', '검사·시술 안내', '건강 칼럼', '복용약 안내'], '건강정보'],
      ['병원소개', ['인사말', '연혁', '조직·연락처', '병원 이념', '시설 소개'], '병원소개']
    ]
  }];
  function hosp(id) { for (var i = 0; i < HOSPITALS.length; i++) if (HOSPITALS[i].id === id) return HOSPITALS[i]; return null; }

  /* ── 저장소 (접근 실패 대비) ── */
  function rd(key, def) { try { var v = window.sessionStorage.getItem(key); return v ? JSON.parse(v) : def; } catch (e) { return def; } }
  function wr(key, val) { try { window.sessionStorage.setItem(key, JSON.stringify(val)); } catch (e) {} }
  var SKEY = 'hs.state.v3';
  var st = rd(SKEY, null);
  if (!st || (st.id && !hosp(st.id))) st = { mode: 'closed', id: null, tab: 0, msgs: [] };
  if (st.mode === 'open') st.mode = st.id ? 'min' : 'closed';   // 다른 페이지로 넘어오면 레일로 시작
  function save() { wr(SKEY, st); }

  function el(tag, cls, html) { var n = doc.createElement(tag); if (cls) n.className = cls; if (html != null) n.innerHTML = html; return n; }
  var $ = function (id) { return doc.getElementById(id); };

  var form = doc.querySelector('form.rn_prompt') || doc.querySelector('form.search_form');
  var input = $('medical_search');
  var returnFocus = null, pending = null;

  /* ── 헤더 병원 아이콘: 병원 목록 없이 우선 강원대학교병원으로 이동 ── */
  var util = $('opUtil');
  var drawerBtn = el('button', 'op_ub', HOSP_ICON);
  drawerBtn.type = 'button'; drawerBtn.id = 'hsDrawerBtn';
  drawerBtn.setAttribute('aria-haspopup', 'dialog'); drawerBtn.setAttribute('aria-label', '강원대학교병원 AI 열기'); drawerBtn.title = '강원대학교병원 AI';
  if (util) { var anchor = $('opMapBtn') || $('opAcctBtn'); if (anchor) util.insertBefore(drawerBtn, anchor); else util.appendChild(drawerBtn); }
  drawerBtn.addEventListener('click', function () { returnFocus = drawerBtn; openSession('knuh'); });

  /* ── 서랍(전체 덮개) ── */
  var panel = el('aside', 'hs_panel');
  panel.id = 'hsPanel'; panel.hidden = true; panel.setAttribute('role', 'complementary'); panel.setAttribute('aria-labelledby', 'hsTitle');
  panel.innerHTML =
    '<header class="hs_hd"><img class="hs_logo" id="hsLogo" alt="" src=""><h2 id="hsTitle" tabindex="-1"></h2>' +
    '<a class="hs_home" id="hsHome" target="_blank" rel="noopener">' + HOME + '</a>' +
    '<span class="hs_acts">' +
    '<button type="button" class="hs_ib" id="hsMin" aria-label="서랍 접기 — 바로가기만 남기기" title="서랍 접기">' + MIN + '</button>' +
    '<button type="button" class="hs_ib" id="hsEnd" aria-label="세션 종료 — 대화 지우기" title="세션 종료">' + X + '</button></span></header>' +
    '<div class="hs_bd"><nav class="hs_side" id="hsSide" aria-label="분류별 바로가기"><div class="hs_acc" id="hsAcc"></div></nav>' +
    '<section class="hs_main" aria-label="대화"><div class="hs_scroll" id="hsScroll"></div>' +
    '<p class="hs_note">AI가 생성한 답변으로, 부정확하거나 사실과 다른 내용이 포함될 수 있습니다.</p></section></div>';
  doc.body.appendChild(panel);

  /* 대화 */
  function renderMain() {
    var h = hosp(st.id), sc = $('hsScroll');
    if (!h) { sc.innerHTML = ''; return; }
    var cards = h.cards.map(function (c) {
      return '<article class="hs_card' + (c.pri ? ' is_pri' : '') + '"><h4>' + c.t + '</h4><p class="hs_cd">' + c.d + '</p><ul>' + c.bl.map(function (x) { return '<li>' + x + '</li>'; }).join('') + '</ul>' +
        '<div class="hs_cb">' + c.btn.map(function (x) { return '<button type="button" class="hs_cbtn" data-ask="' + x + '" data-sec="' + c.sec + '">' + x + '</button>'; }).join('') + '</div></article>';
    }).join('');
    sc.innerHTML =
      '<div class="hs_brand">' + (h.logo ? '<img src="' + h.logo + '" alt="">' : '') + '<span><b>' + h.name + '</b>' + (h.en ? '<small>' + h.en + '</small>' : '') + '</span></div>' +
      '<p class="hs_lead"></p>' +
      '<div class="hs_car"><button type="button" class="hs_cnav" id="hsPrev" aria-label="이전 카드" hidden>' + MIN + '</button><div class="hs_track" id="hsTrack" role="group" aria-label="안내 카드" tabindex="0">' + cards + '</div><button type="button" class="hs_cnav" id="hsNext" aria-label="다음 카드" hidden>' + ARROW + '</button></div>' +
      '<div class="hs_dots" id="hsDots" aria-hidden="true"></div>' +
      '<div class="hs_log" id="hsLog" role="log" aria-live="polite" aria-label="대화 내용"></div>';
    sc.querySelector('.hs_lead').textContent = h.lead;
    var log = $('hsLog'); st.msgs.forEach(function (m) { log.appendChild(msgNode(m)); });
    initCar();
  }
  function initCar() {
    var tr = $('hsTrack'); if (!tr) return;
    function upd() {
      var more = tr.scrollWidth - tr.clientWidth > 6, pages = Math.max(1, Math.ceil((tr.scrollWidth - 6) / tr.clientWidth));
      $('hsPrev').hidden = !more; $('hsNext').hidden = !more;
      var cur = Math.min(pages - 1, Math.round(tr.scrollLeft / Math.max(1, tr.scrollWidth - tr.clientWidth) * (pages - 1)));
      $('hsDots').innerHTML = more ? Array.apply(null, Array(pages)).map(function (_, i) { return '<i' + (i === cur ? ' class="on"' : '') + '></i>'; }).join('') : '';
    }
    tr.addEventListener('scroll', upd);
    $('hsPrev').addEventListener('click', function () { tr.scrollBy({ left: -tr.clientWidth * 0.9, behavior: 'smooth' }); });
    $('hsNext').addEventListener('click', function () { tr.scrollBy({ left: tr.clientWidth * 0.9, behavior: 'smooth' }); });
    requestAnimationFrame(upd);
  }
  function msgNode(m) {
    var p = el('p', 'hs_msg ' + (m.r === 'u' ? 'u' : 'a')); p.textContent = m.t;
    (m.acts || []).forEach(function (a) {
      var b = a.href ? el('a', 'hs_act') : el('button', 'hs_act');
      b.textContent = a.label;
      if (a.href) b.href = a.href; else { b.type = 'button'; b.setAttribute('data-go', a.go); }
      p.appendChild(b);
    });
    return p;
  }
  function toEnd() { panel.scrollTop = panel.scrollHeight; }
  function pushMsg(m) { st.msgs.push(m); if (st.msgs.length > 40) st.msgs.shift(); save(); var n = msgNode(m); $('hsLog').appendChild(n); toEnd(); return n; }

  function renderHead() {
    var h = hosp(st.id); if (!h) return;
    $('hsLogo').src = h.logo || ''; $('hsLogo').hidden = !h.logo;
    $('hsTitle').textContent = h.name + ' AI';
    var a = $('hsHome'); a.href = h.home; a.setAttribute('aria-label', h.name + ' 홈페이지 (새 창)'); a.title = h.name + ' 홈페이지';
  }
  function renderSide() {
    var h = hosp(st.id), side = $('hsSide');
    side.hidden = !h; if (!h) return;
    $('hsAcc').innerHTML = h.tabs.map(function (t, i) {
      var open = i === st.tab;
      return '<section class="hs_sec' + (open ? ' is_open' : '') + '"><h3><button type="button" class="hs_sech" data-sec="' + i + '" aria-expanded="' + open + '" aria-controls="hsSec' + i + '"><span class="hs_sect">' + t[2] + '</span><em class="hs_cnt">' + t[1].length + '</em>' + CHEV + '</button></h3>' +
        '<ul class="hs_items" id="hsSec' + i + '"' + (open ? '' : ' hidden') + '>' + t[1].map(function (n) { return '<li><button type="button" data-item="' + n + '">' + n + '</button></li>'; }).join('') + '</ul></section>';
    }).join('');
  }
  function renderAll() { renderHead(); renderMain(); renderSide(); }

  function setTab(i, keep) { st.tab = (keep && st.tab === i) ? -1 : i; save(); renderSide(); var o = panel.querySelector('.hs_sec.is_open'); if (o && o.scrollIntoView) o.scrollIntoView({ block: 'nearest' }); }

  /* ── 목업 응답 (병원 AI 엔드포인트 연결 시 이 함수만 교체) ── */
  function reply(q) {
    var s = q.replace(/\s+/g, '');
    if (/응급/.test(s)) return { t: '응급 상황이라면 지체 없이 119에 연락하세요. 가까운 응급실 현황은 응급실 LIVE에서 확인할 수 있어요.', acts: [{ label: '응급실 LIVE 보기', href: 'er-live.html' }] };
    if (/주차|오시는|위치|길|편의|면회|병원이용|입원/.test(s)) return { t: '병원 이용 안내(오시는 길, 주차, 편의시설, 면회, 입원 절차)는 병원 공식 안내를 기준으로 확인해 주세요. 홈페이지 바로가기는 제목 옆 아이콘에서 열 수 있어요.', acts: [] };
    if (/진료시간|예약|접수|외래|증명|진료비|진료안내|복용약|검사/.test(s)) return { t: '진료 시간과 예약은 진료과·의료진마다 다를 수 있어요. 궁금한 진료과나 검사를 알려주시면 이어서 안내해 드릴게요.', acts: [] };
    if (/의료진|교수|의사|전문의|진료과|내과|외과|소아|산부인|정형|신경|정신|피부|안과|이비인후|비뇨|재활/.test(s)) return { t: '진료과와 의료진 정보는 병원 공식 홈페이지에서 가장 정확하게 확인할 수 있어요. 찾으시는 진료과를 말씀해 주세요.', acts: [] };
    return { t: '질문을 확인했어요. 증상에 맞는 진료과가 궁금하면 전체 AI 상담으로 돌아가 물어보셔도 좋아요.', acts: [{ label: '전체 AI로 전환', go: 'all' }] };
  }
  function ask(q) {
    q = (q || '').trim(); if (!q || st.mode !== 'open' || !st.id) return;
    pushMsg({ r: 'u', t: q });
    var w = el('p', 'hs_msg a wait'); w.textContent = '답변을 준비하고 있어요…'; $('hsLog').appendChild(w); toEnd();
    clearTimeout(pending);
    pending = setTimeout(function () { if (w.parentNode) w.parentNode.removeChild(w); pushMsg(Object.assign({ r: 'a' }, reply(q))); }, 650);
  }

  panel.addEventListener('click', function (e) {
    var t = e.target;
    var q = t.closest('[data-ask]'); if (q) { setTab(+q.getAttribute('data-sec')); ask(q.getAttribute('data-ask')); return; }
    var sec = t.closest('[data-sec]'); if (sec) { setTab(+sec.getAttribute('data-sec'), true); var hb = panel.querySelector('[data-sec="' + sec.getAttribute('data-sec') + '"]'); if (hb) hb.focus(); return; }
        var it = t.closest('[data-item]'); if (it) { ask(hosp(st.id).tabs[Math.max(st.tab, 0)][0] + ' · ' + it.getAttribute('data-item')); return; }
    var go = t.closest('[data-go]'); if (go) { setMode('min'); if (input) input.focus(); }
  });
  $('hsMin').addEventListener('click', function () { setMode('min'); });
  $('hsEnd').addEventListener('click', function () { endSession(); });

  /* ── 최소화 레일 (우측) ── */
  var rail = el('nav', 'hs_rail'); rail.id = 'hsRail'; rail.hidden = true;
  doc.body.appendChild(rail);
  function fillRail() {
    var h = hosp(st.id); if (!h) return;
    rail.setAttribute('aria-label', h.name + ' AI');
    rail.innerHTML =
      '<button type="button" class="hs_rail_open" id="hsRailOpen" aria-label="' + h.name + ' AI 서랍 열기">' + (h.logo ? '<img src="' + h.logo + '" alt="">' : '<b class="hs_rail_nm">' + h.name + '</b>') + '<span class="hs_rail_txt">' + h.name + ' AI</span></button>' +
      '<ul>' + h.tabs.map(function (t, i) { return '<li><button type="button" data-rail-tab="' + i + '">' + t[0] + '</button></li>'; }).join('') + '</ul>' +
      '<button type="button" class="hs_rail_end" id="hsRailEnd" aria-label="세션 종료">종료</button>';
  }
  rail.addEventListener('click', function (e) {
    if (e.target.closest('#hsRailOpen')) { setMode('open'); return; }
    var rt = e.target.closest('[data-rail-tab]'); if (rt) { st.tab = +rt.getAttribute('data-rail-tab'); setMode('open'); return; }
    if (e.target.closest('#hsRailEnd')) endSession();
  });

  /* ── 프롬프트 안의 바로가기 칩(원안: 유튜브·블로그·인스타그램) ── */
  var links = el('div', 'hs_links');
  links.innerHTML =
    '<a href="#" data-ext="youtube"><svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M21.6 7.2a2.5 2.5 0 0 0-1.8-1.8C18.2 5 12 5 12 5s-6.2 0-7.8.4A2.5 2.5 0 0 0 2.4 7.2C2 8.8 2 12 2 12s0 3.2.4 4.8a2.5 2.5 0 0 0 1.8 1.8C5.8 19 12 19 12 19s6.2 0 7.8-.4a2.5 2.5 0 0 0 1.8-1.8c.4-1.6.4-4.8.4-4.8s0-3.2-.4-4.8zM10 15V9l5.2 3z"/></svg>유튜브 채널</a>' +
    '<a href="#" data-ext="blog"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 4v16M5 12h7a4 4 0 0 1 0 8H5M5 4h6a4 4 0 0 1 0 8"/></svg>블로그</a>' +
    '<a href="#" data-ext="instagram"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.2" cy="6.8" r=".8" fill="currentColor"/></svg>인스타그램</a>';
  links.addEventListener('click', function (e) { if (e.target.closest('a')) e.preventDefault(); });   // 채널 URL 확정 시 href 로 교체
  var comp = form && form.querySelector('.rn_composer'); if (comp) comp.appendChild(links);

  /* 입력창 안내문: 기존 입력창은 타이핑 효과로 placeholder 를 계속 바꾸므로, 세션 중에는 같은 자리에 고정 문구를 덮는다 */
  var ph = el('span', 'hs_ph'); ph.setAttribute('aria-hidden', 'true');
  var fld = input && input.parentNode; if (fld) fld.appendChild(ph);

  function syncPh() {
    if (!input || st.mode !== 'open') return;
    var cs = getComputedStyle(input);
    ph.style.padding = cs.padding; ph.style.font = cs.font; ph.style.letterSpacing = cs.letterSpacing; ph.style.lineHeight = cs.lineHeight;
    ph.style.top = input.offsetTop + 'px'; ph.style.left = input.offsetLeft + 'px'; ph.style.right = 'auto'; ph.style.width = input.offsetWidth + 'px'; ph.style.height = input.offsetHeight + 'px';
  }
  if (window.ResizeObserver && input) new ResizeObserver(syncPh).observe(input);
  if (form && window.MutationObserver) new MutationObserver(function () { requestAnimationFrame(syncPh); }).observe(form, { attributes: true, attributeFilter: ['class'] });
  window.addEventListener('resize', syncPh);

  /* ── 프롬프트 연결 표시 + 제출 가로채기 ── */
  var target = el('div', 'hs_target');
  target.innerHTML = '<span id="hsTargetTxt"></span><button type="button" id="hsTargetOff">전체 AI로 전환</button>';
  if (form) form.insertBefore(target, form.firstChild);
  target.querySelector('#hsTargetOff').addEventListener('click', function () { setMode('min'); if (input) input.focus(); });
  doc.addEventListener('submit', function (e) {
    if (st.mode !== 'open' || !st.id || !form || e.target !== form) return;
    e.preventDefault(); e.stopImmediatePropagation();
    var v = input ? input.value : ''; if (input) input.value = '';
    ask(v);
  }, true);

  /* ── 상태 전환 ── */
  function openSession(id) {
    if (st.id !== id) { st.id = id; st.msgs = []; }
    setMode('open');
  }
  function setMode(m) {
    if (m === 'min' && !st.id) m = 'closed';
    var was = st.mode; st.mode = m; save();
    var h = hosp(st.id);
    root.classList.toggle('hs-open', m === 'open'); root.classList.toggle('hs-min', m === 'min');
    root.classList.toggle('hs-live', m === 'open' && !!h);
    if (m === 'open') {
      if (was !== 'open') { try { window.scrollTo(0, 0); } catch (e) {} }   // 프롬프트 독이 히어로(큰) 상태로 돌아오도록
      renderAll(); rail.hidden = true; panel.hidden = false;
      requestAnimationFrame(function () { panel.classList.add('is_open'); });
      ph.textContent = '진료 예약·의료진·병원 이용 등 ' + h.name + '에 관한 무엇이든 물어보세요.';
      syncPh();
      $('hsTargetTxt').textContent = h.name + ' AI와 대화 중';
      if (was !== 'open') $('hsTitle').focus();
    } else {
      panel.classList.remove('is_open'); panel.hidden = true;
      ph.textContent = '';
      if (m === 'min') { fillRail(); rail.hidden = false; if (was === 'open') { var b = $('hsRailOpen'); if (b) b.focus(); } }
      else { rail.hidden = true; if (was === 'open' && returnFocus && returnFocus.focus) returnFocus.focus(); }
    }
    setTimeout(function () { window.dispatchEvent(new Event('resize')); }, 60);
  }
  function endSession() { clearTimeout(pending); st = { mode: st.mode, id: null, tab: 0, msgs: [] }; setMode('closed'); }

  /* ── 퀵메뉴 병원 항목(공통) → 팝업 대신 하위 세션 ── */
  doc.addEventListener('click', function (e) {
    var l = e.target.closest('.quick_partner .quick_link'); if (!l) return;
    e.preventDefault(); e.stopPropagation(); returnFocus = l; openSession('knuh');
  }, true);
  var ql = doc.querySelectorAll('.quick_partner .quick_link');
  for (var qi = 0; qi < ql.length; qi++) { ql[qi].setAttribute('title', '강원대학교병원 AI 상담 열기'); ql[qi].setAttribute('aria-haspopup', 'dialog'); }

  /* ── 키보드 / 레이아웃 ── */
  doc.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape' || st.mode !== 'open') return;
    var ae = doc.activeElement;
    if (panel.contains(ae) || (form && form.contains(ae))) { e.stopPropagation(); setMode('min'); }
  });
  function layout() {
    var q = doc.querySelector('.quick_wrap'); var fixed = !!q && getComputedStyle(q).position === 'fixed';
    root.classList.toggle('hs-q', fixed);
  }
  window.addEventListener('resize', layout);
  layout();

  /* 초기 복원 */
  if (st.mode === 'min') setMode('min');
})();
