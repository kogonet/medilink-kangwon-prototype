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
