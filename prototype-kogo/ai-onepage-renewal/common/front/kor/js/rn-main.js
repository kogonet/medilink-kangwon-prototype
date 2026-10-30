/* 메디링크 강원 리뉴얼 — 메인(index) 전용. rn.js 다음에 로드 */

/* ═════════════════ 메인 대화 영역·오버레이 주입 ═════════════════ */
/* 메인 대화 영역·오버레이 주입 — 원안 index.jsp 에 없는 한 페이지 상담용 마크업.
 * 아래 '원페이지 대화' 블록이 #opThread 등을 찾으므로 먼저 실행한다. */
(function () {
  'use strict';
  var doc = document, hero = doc.querySelector('.hero_wrap');
  if (!hero || doc.getElementById('opThread')) return;
  function frag(html) { var t = doc.createElement('template'); t.innerHTML = html; return t.content; }
  hero.parentNode.insertBefore(frag("<section class=\"op_thread\" id=\"opThread\" aria-label=\"AI 상담 대화\" hidden>\n      <a class=\"op_skip\" href=\"#opCol\">결과로 바로가기</a>\n      <div class=\"op_stage\" id=\"opStage\">\n        <div class=\"op_condbar\" id=\"opCondBar\"><span class=\"op_cond_label\">검색 조건</span><ul class=\"rr_chips\" id=\"opChips\" aria-label=\"적용된 검색 조건\"></ul></div>\n        <div class=\"op_col\" id=\"opCol\" tabindex=\"-1\"></div>\n      </div>\n    </section>"), hero.nextSibling);   // 대화(결과) 영역: 히어로가 그 자리에서 변신
  doc.body.appendChild(frag("<section class=\"op_ovp op_ovp_wide\" id=\"opPnMap\" role=\"dialog\" aria-modal=\"false\" aria-labelledby=\"opPnMapT\" hidden>\n    <div class=\"op_ovp_hd\"><h2 id=\"opPnMapT\" tabindex=\"-1\">지도</h2><button class=\"op_x\" type=\"button\" data-close=\"map\" aria-label=\"지도 닫기\"><svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M6 6l12 12M18 6 6 18\"/></svg></button></div>\n    <div class=\"op_ovp_bd\">\n      <div class=\"op_tabs\" role=\"tablist\" aria-label=\"지도 보기 방식\">\n        <button type=\"button\" role=\"tab\" id=\"opTabTile\" aria-selected=\"true\" aria-controls=\"opPaneTile\">시·군 요약</button>\n        <button type=\"button\" role=\"tab\" id=\"opTabPin\" aria-selected=\"false\" aria-controls=\"opPanePin\">기관 위치</button>\n      </div>\n      <div class=\"op_pane\" id=\"opPaneTile\" role=\"tabpanel\" aria-labelledby=\"opTabTile\"></div>\n      <div class=\"op_pane\" id=\"opPanePin\" role=\"tabpanel\" aria-labelledby=\"opTabPin\" hidden></div>\n      <p class=\"op_map_cap\">시안용 임시 지도입니다. 지도의 모든 정보는 목록에도 동일하게 있습니다.</p>\n    </div>\n  </section>\n  <section class=\"op_ovp\" id=\"opPnHist\" role=\"dialog\" aria-modal=\"false\" aria-labelledby=\"opPnHistT\" hidden>\n    <div class=\"op_ovp_hd\"><h2 id=\"opPnHistT\" tabindex=\"-1\">기록</h2><button class=\"op_x\" type=\"button\" data-close=\"hist\" aria-label=\"기록 닫기\"><svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M6 6l12 12M18 6 6 18\"/></svg></button></div>\n    <div class=\"op_ovp_bd\">\n      <p class=\"op_drawer_note\" id=\"opDrawerNote\">이 기기에만 저장된 최근 검색입니다. 로그인하면 계정에 저장할 수 있어요.</p>\n      <ul class=\"op_hist\" id=\"opHist\"></ul>\n      <button class=\"op_clear\" id=\"opHistClear\" type=\"button\">기록 전체 삭제</button>\n    </div>\n  </section>\n  <section class=\"op_ovp\" id=\"opPnAcct\" role=\"dialog\" aria-modal=\"false\" aria-labelledby=\"opPnAcctT\" hidden>\n    <div class=\"op_ovp_hd\"><h2 id=\"opPnAcctT\" tabindex=\"-1\">계정</h2><button class=\"op_x\" type=\"button\" data-close=\"acct\" aria-label=\"계정 닫기\"><svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M6 6l12 12M18 6 6 18\"/></svg></button></div>\n    <div class=\"op_ovp_bd\">\n      <div id=\"opAcctOut\">\n        <p class=\"op_pop_t\">로그인은 선택입니다</p>\n        <p class=\"op_pop_d\">로그인 없이도 모든 기능을 쓸 수 있어요. 로그인하면 대화 기록과 즐겨찾는 기관을 저장하고 직접 관리할 수 있습니다.</p>\n        <button class=\"op_primary\" id=\"opLoginBtn\" type=\"button\">로그인 (시안)</button>\n      </div>\n      <div id=\"opAcctIn\" hidden>\n        <p class=\"op_pop_t\">홍길동 님 <small>(샘플)</small></p>\n        <button type=\"button\" data-acct=\"hist\">내 대화 기록</button>\n        <button type=\"button\" data-acct=\"fav\">즐겨찾는 기관</button>\n        <label class=\"op_switch\"><input type=\"checkbox\" id=\"opSaveHist\" checked><span>대화 기록 저장</span></label>\n        <button type=\"button\" data-acct=\"clear\">기록 전체 삭제</button>\n        <button type=\"button\" id=\"opLogoutBtn\">로그아웃</button>\n      </div>\n    </div>\n  </section>\n  <div class=\"op_note\" id=\"opNote\" role=\"status\" aria-live=\"polite\" hidden></div>\n  <div class=\"op_live\" id=\"opLive\" role=\"status\" aria-live=\"polite\"></div>"));                              // 지도·기록·계정 패널, 알림
})();

/* ═════════════════ 히어로 엠비언트 (구 renewal-main.js) ═════════════════ */
/* 메디링크 강원 리뉴얼(랜딩) — 히어로 엠비언트 그라데이션 배경.
 * Hello.Persona 히어로 배경과 같은 방식: 색 정지점을 OKLab 으로 보간해 256단계 테이블로 굽고,
 * 저해상도 캔버스에 천천히 흐르는 필드로 그린다(영상 대체, 가독성용 스카이블루 → 흰색).
 * rn.css 와 함께 로드된다. prefers-reduced-motion 이면 정지 화면 1장. */
(function () {
  'use strict';
  var hero = document.querySelector('.hero_wrap');
  if (!hero || hero.getAttribute('data-rn-amb')) return;
  hero.setAttribute('data-rn-amb', '1');

  // 밝은 히어로 위에서는 컬러 로고 사용
  var logo = document.querySelector('.gm_brand_logo');
  if (logo && /medilink-bi-white\.svg/.test(logo.getAttribute('src') || '')) logo.setAttribute('src', logo.getAttribute('src').replace('medilink-bi-white.svg', 'medilink-bi.svg'));

  var cv = document.createElement('canvas');
  cv.className = 'rn_ambient';
  cv.setAttribute('aria-hidden', 'true');
  var W = 192, H = 108;
  cv.width = W; cv.height = H;
  hero.insertBefore(cv, hero.firstChild);
  var g = cv.getContext('2d');
  if (!g) return;
  var img = g.createImageData(W, H);

  // ── OKLab ──
  function toLin(c) { return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }
  function toSrgb(c) { c = Math.min(1, Math.max(0, c)); return c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1 / 2.4) - 0.055; }
  function hexLab(h) {
    var r = toLin((h >> 16 & 255) / 255), gg = toLin((h >> 8 & 255) / 255), b = toLin((h & 255) / 255);
    var l = Math.cbrt(0.4122214708 * r + 0.5363325363 * gg + 0.0514459929 * b);
    var m = Math.cbrt(0.2119034982 * r + 0.6806995451 * gg + 0.1073969566 * b);
    var s = Math.cbrt(0.0883024619 * r + 0.2817188376 * gg + 0.6299787005 * b);
    return [0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s, 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s, 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s];
  }
  function labRgb(L, A, B) {
    var l = Math.pow(L + 0.3963377774 * A + 0.2158037573 * B, 3);
    var m = Math.pow(L - 0.1055613458 * A - 0.0638541728 * B, 3);
    var s = Math.pow(L - 0.0894841775 * A - 1.291485548 * B, 3);
    return [
      toSrgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
      toSrgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
      toSrgb(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s)
    ];
  }
  // 스카이 블루(상단) → 흰색(하단). 이미지 레퍼런스: 상단 #1E90FF 계열 → 연한 하늘색 → 백색
  var STOPS = [[0, 0x1E90FF], [0.26, 0x38C6FF], [0.5, 0x86C4FF], [0.74, 0xD3E8FF], [1, 0xFFFFFF]];
  // 농도 70%: 각 정지점을 흰색과 OKLab 에서 30% 섞는다
  var STRENGTH = 0.7, WHITE = hexLab(0xFFFFFF);
  var LABS = STOPS.map(function (s) {
    var L = hexLab(s[1]);
    return [s[0], L.map(function (x, j) { return WHITE[j] + (x - WHITE[j]) * STRENGTH; })];
  });
  var LUT = new Uint8ClampedArray(256 * 3);
  for (var i = 0; i < 256; i++) {
    var v = i / 255, k = 1;
    while (k < LABS.length - 1 && v > LABS[k][0]) k++;
    var a = LABS[k - 1], b2 = LABS[k];
    var f = Math.min(1, Math.max(0, (v - a[0]) / (b2[0] - a[0])));
    var c = labRgb(a[1][0] + (b2[1][0] - a[1][0]) * f, a[1][1] + (b2[1][1] - a[1][1]) * f, a[1][2] + (b2[1][2] - a[1][2]) * f);
    LUT[i * 3] = c[0] * 255; LUT[i * 3 + 1] = c[1] * 255; LUT[i * 3 + 2] = c[2] * 255;
  }

  // ── 필드: 세로 그라데이션 + 느린 파동 + 떠다니는 빛 덩어리 ──
  function frame(sec) {
    var d = img.data, p = 0;
    var bx = 0.5 + Math.sin(sec * 0.11) * 0.28, by = 0.32 + Math.cos(sec * 0.09) * 0.1;   // 밝은 덩어리
    var cx = 0.5 + Math.cos(sec * 0.07 + 1.3) * 0.34, cy = 0.2 + Math.sin(sec * 0.08) * 0.08;   // 깊은 덩어리
    for (var y = 0; y < H; y++) {
      var ny = y / (H - 1);
      for (var x = 0; x < W; x++) {
        var nx = x / (W - 1);
        var t = ny * 0.96;
        t += Math.sin(nx * 3.1 + sec * 0.16 + ny * 2.2) * 0.045;
        t += Math.sin(nx * 6.3 - sec * 0.12 + ny * 3.4) * 0.025;
        var dx = (nx - bx) * 1.7, dy = ny - by;
        t += Math.exp(-(dx * dx + dy * dy) * 7) * 0.2;       // 밝아짐
        var ex = (nx - cx) * 1.6, ey = ny - cy;
        t -= Math.exp(-(ex * ex + ey * ey) * 9) * 0.12;      // 깊어짐
        t = t < 0 ? 0 : t > 1 ? 1 : t;
        var li = (t * 255 + 0.5 | 0) * 3;
        d[p++] = LUT[li]; d[p++] = LUT[li + 1]; d[p++] = LUT[li + 2]; d[p++] = 255;
      }
    }
    g.putImageData(img, 0, 0);
  }

  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var acc = 6, last = 0, raf = 0, running = false;
  frame(acc);
  hero.classList.add('is_rn_ready');
  if (reduced) return;
  function tick(now) {
    if (now - last > 33) { acc += Math.min(0.1, (now - last) / 1000); last = now; frame(acc); }
    raf = requestAnimationFrame(tick);
  }
  function start() { if (running) return; running = true; last = performance.now(); raf = requestAnimationFrame(tick); }
  function stop() { running = false; cancelAnimationFrame(raf); }
  if ('IntersectionObserver' in window) new IntersectionObserver(function (e) { e[0].isIntersecting ? start() : stop(); }, { threshold: 0.01 }).observe(hero); else start();
  document.addEventListener('visibilitychange', function () { document.hidden ? stop() : start(); });
})();

/* ═════════════════ 원페이지 대화 (구 onepage.js) ═════════════════ */
/* 한 페이지 AI 상담 시안 (목업) — 히어로가 그 자리에서 대화로 변신, 상단 동적 바, 지도 온디맨드
 * 백엔드 없음: 응답은 샘플 데이터로 흉내 낸다. 실제 연동 시 mock() 만 API 호출로 교체한다.
 * 의존: landing.js(옵션 패널·칩 selected/renderTags), renewal-dock.js(하단 프롬프트 독) */
(function () {
  'use strict';
  var doc = document, body = doc.body;
  var $ = function (s, r) { return (r || doc).querySelector(s); };
  var $$ = function (s, r) { return [].slice.call((r || doc).querySelectorAll(s)); };
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var form = $('form.search_form'), input = $('#medical_search');
  var hero = $('.hero_wrap'), thread = $('#opThread'), col = $('#opCol'), stage = $('#opStage');
  var live = $('#opLive'), chipsEl = $('#opChips');
  var mapBtn = $('#opMapBtn'), mapEl = $('#opPnMap');
  if (!form || !thread) return;

  var state = { cond: { region: '', symptom: '', department: '' }, lastText: '', n: 0, timers: [], loc: false, mapAuto: false, last: null, user: false };

  /* ── 유틸 ── */
  function esc(s) { return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function say(msg) { live.textContent = ''; setTimeout(function () { live.textContent = msg; }, 30); }
  function later(fn, ms) { var t = setTimeout(fn, ms); state.timers.push(t); return t; }
  function clearTimers() { state.timers.forEach(clearTimeout); state.timers = []; }
  function note(msg) {
    var n = $('#opNote'); n.textContent = msg; n.hidden = false;
    clearTimeout(note.t); note.t = setTimeout(function () { n.hidden = true; }, 2600);
  }
  var LABELS = { region: '지역', department: '진료과', symptom: '증상' };
  var SYM2DEPT = { '허리디스크': '정형외과', '퇴행슬관절염': '정형외과', '두통': '신경과', '어지럼증': '신경과', '감기': '내과', '발열': '내과', '기침': '내과', '당뇨': '내과', '고혈압': '내과', '중이염': '이비인후과', '피부발진': '피부과', '가려움증': '피부과', '치통': '치과', '우울증': '정신건강의학과' };

  /* ── 상단 바: 조건 칩 ── */
  function renderChips() {
    chipsEl.innerHTML = ['region', 'department', 'symptom'].filter(function (k) { return state.cond[k]; }).map(function (k) {
      return '<li class="rr_chip"><b>' + LABELS[k] + '</b>' + esc(state.cond[k]) + '<button type="button" data-rm="' + k + '" aria-label="' + LABELS[k] + ' 조건 ' + esc(state.cond[k]) + ' 삭제">×</button></li>';
    }).join('');
  }
  chipsEl.addEventListener('click', function (e) {
    var b = e.target.closest('[data-rm]'); if (!b) return;
    state.cond[b.dataset.rm] = '';
    renderChips();
    ask({ text: state.lastText }, { fromBar: true, note: '조건을 바꿔 다시 찾았어요' });
  });

  /* ── 히어로 → 대화 전환 ── */
  function enterChat(label, first) {
    if (!body.classList.contains('is_chat')) {
      var done = function () {
        var f0 = form.getBoundingClientRect().top; body.classList.add('is_chat'); thread.hidden = false; (function () { var d = f0 - form.getBoundingClientRect().top; if (!reduce && Math.abs(d) > 40) { document.documentElement.style.setProperty('--op-from', Math.round(d) + 'px'); form.classList.remove('is_settle'); void form.offsetWidth; form.classList.add('is_settle'); setTimeout(function () { form.classList.remove('is_settle'); }, 700); } })(); hero.classList.remove('is_leaving');
        window.scrollTo(0, 0);
      };
      hero.classList.add('is_leaving');
      if (reduce) done(); else later(done, 280);
      try { history.pushState({ chat: 1 }, '', '?q=' + encodeURIComponent(label)); } catch (e) { /* file:// 등 */ }
    } else {
      try { history.replaceState({ chat: 1 }, '', '?q=' + encodeURIComponent(label)); } catch (e) { }
    }
  }
  function newChat(fromPop) {
    clearTimers();
    state.cond = { region: '', symptom: '', department: '' }; state.lastText = ''; state.n = 0; state.last = null;
    col.innerHTML = ''; renderChips(); closePanels(); $('#opHistBtn').disabled = true; mapBtn.disabled = true; mapBtn.classList.remove('is_new'); $('#opMapCnt').textContent = '';
    body.classList.remove('is_chat', 'has_dist'); thread.hidden = true; hero.classList.remove('is_leaving');
    window.scrollTo(0, 0);
    if (!fromPop) { try { history.replaceState(null, '', location.pathname); } catch (e) { } }
    if (input) input.focus({ preventScroll: true });
    say('새 대화를 시작합니다.');
  }
  window.addEventListener('popstate', function () { if (body.classList.contains('is_chat')) newChat(true); });

  /* ── 질문 접수 (landing.js 의 페이지 이동 submit 을 가로챈다) ── */
  function readComposer() {
    var sel = (typeof selected !== 'undefined') ? selected : {};
    return { region: sel.region || '', symptom: sel.symptom || '', department: sel.department || '', text: input.value.trim() };
  }
  function clearComposer() {
    if (typeof selected !== 'undefined') { selected.region = ''; selected.symptom = ''; selected.department = ''; if (typeof renderTags === 'function') renderTags(); }
    input.value = '';
  }
  form.addEventListener('submit', function (e) {
    e.preventDefault(); e.stopImmediatePropagation();
    var q = readComposer();
    if (!q.text && !q.region && !q.symptom && !q.department) { input.focus(); return; }
    clearComposer();
    ask(q);
  }, true);

  function composeLabel(cond, text) {
    var p = [cond.region, cond.department, cond.symptom].filter(Boolean).join(' ');
    return text ? (p ? p + ' ' + text : text) : (p ? p + ' 알려줘' : '');
  }

  function ask(q, opt) {
    opt = opt || {};
    if (!opt.fromBar && q.text) {   // 문장 속 시·군 이름을 조건으로 인식
      var rm = /(춘천|원주|강릉|동해|태백|속초|삼척|홍천|횡성|영월|평창|정선|철원|화천|양구|인제|고성|양양)(시|군)?/.exec(q.text);
      if (rm && !q.region) { q.region = rm[1] + (SUFFIX[rm[1]] || ''); q.text = q.text.replace(rm[0], '').trim(); }
    }
    if (!opt.fromBar) ['region', 'symptom', 'department'].forEach(function (k) { if (q[k]) state.cond[k] = q[k]; });
    if (q.text !== undefined) state.lastText = q.text;
    renderChips();
    var cond = { region: state.cond.region, symptom: state.cond.symptom, department: state.cond.department };
    var label = composeLabel(cond, q.text);
    enterChat(label); $('#opHistBtn').disabled = false;
    var rev = !!(opt.fromBar && state.lastTurn && state.lastTurn.isConnected);
    var turn = rev ? state.lastTurn : doc.createElement('section');
    if (rev) { $('.rr_q p', turn).textContent = label; $('.rr_a', turn).innerHTML = ''; var vv = $('.op_ver', turn); if (vv) vv.hidden = true; var ap = $('.rr_a', turn); respond(ap, turn, cond, q.text || '', true, label); if (opt.note) note(opt.note); input.focus({ preventScroll: true }); return; }
    turn.className = 'op_turn'; turn.id = 'turn' + (++state.n); turn._v = { list: [], i: -1 };
    turn.setAttribute('aria-label', '질문 ' + state.n);
    if (state.n === 1) col.insertAdjacentHTML('beforeend', '<p class="rr_notice"><strong>응급 상황이면 119</strong><span>이 안내는 의료적 판단을 대신하지 않습니다. 진료시간과 운영 여부는 방문 전 전화로 확인해 주세요.</span></p>');
    turn.innerHTML = '<div class="rr_q"><p>' + esc(label) + '</p></div><div class="op_ver" hidden></div><article class="rr_a" aria-label="AI 답변"></article>';
    col.appendChild(turn); state.lastTurn = turn;
    state.last = { q: q, cond: cond, label: label };
    var ans = $('.rr_a', turn);
    if (opt.note) note(opt.note);
    respond(ans, turn, cond, q.text || '', false, label);
    input.focus({ preventScroll: true });
  }

  /* ── 응답(시안): 로딩 → 요약 → 카드 점진 표시 ── */
  function mock(cond, text) {
    var regionFull = cond.region || '강원특별자치도 전체';
    var first = regionFull.split(' ')[0];
    var compact = /시$/.test(first);
    var dm = /(정형외과|내과|외과|안과|피부과|치과|이비인후과|신경과|소아청소년과|산부인과)/.exec(text);
    var dept = cond.department || SYM2DEPT[cond.symptom] || (dm && dm[1]) || '내과';
    var short = dept.replace(/과$/, '');
    var cities = compact ? [first, first, first] : ['홍천군', '횡성군', '평창군'];
    var kinds = ['의원', '병원', '종합병원'], suf = ['의원 A', '병원 B', '종합병원 C'];
    var fac = [0, 1, 2].map(function (i) {
      return { n: i + 1, name: '샘플' + short + suf[i], kind: kinds[i], addr: cities[i] + ' ' + ['○○로', '△△로', '□□로'][i] + ' 00', tel: '033-000-000' + i,
        km: compact ? [3, 6, 8][i] : [12, 47, 83][i], pin: [[34, 38], [58, 56], [44, 72]][i], big: i === 2 };
    });
    var counts = compact ? (function () { var o = {}; o[first] = 12; return o; })() : { '홍천군': 9, '횡성군': 7, '평창군': 6, '원주시': 5, '춘천시': 4, '강릉시': 3 };
    return { regionFull: regionFull, first: first, compact: compact, dept: dept, total: compact ? 12 : 34, fac: fac, counts: counts, spread: compact ? 8 : 96 };
  }

  function respond(ans, turn, cond, text, revised, label) {
    var ctrl = '<p class="op_status" role="status"><span class="op_dots" aria-hidden="true"><i></i><i></i><i></i></span><span>공공데이터에서 찾는 중…</span><button class="op_stop" type="button">중지</button></p>';
    ans.innerHTML = '<p class="rr_who"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2l1.8 6.2L20 10l-6.2 1.8L12 18l-1.8-6.2L4 10l6.2-1.8z" fill="currentColor"/></svg>메디링크 AI</p>' + ctrl;
    say('검색 중입니다.');
    if (!reduce) later(function () { turn.scrollIntoView({ behavior: 'smooth', block: 'start' }); }, 30); else turn.scrollIntoView({ block: 'start' });
    $('.op_stop', ans).addEventListener('click', function () {
      clearTimers();
      $('.op_status', ans).outerHTML = '<div class="op_err"><p>검색을 중지했습니다.</p><button class="op_retry" type="button">다시 시도</button></div>';
      say('검색을 중지했습니다.');
    });
    ans.addEventListener('click', function (e) {
      if (e.target.closest('.op_retry')) { var t = e.target.closest('.op_turn'); t.remove(); ask({ text: text }, { fromBar: true }); }
    });
    later(function () {
      if (/오류/.test(text)) {   // 오류 상태 시안: 입력과 조건은 보존, 다시 시도 제공
        $('.op_status', ans).outerHTML = '<div class="op_err" role="alert"><p>답변을 가져오지 못했습니다. 입력하신 내용과 조건은 그대로 두었어요.</p><button class="op_retry" type="button">다시 시도</button></div>';
        say('답변을 가져오지 못했습니다.'); return;
      }
      var m = mock(cond, text);
      $('.op_status', ans).remove();
      ans.insertAdjacentHTML('beforeend',
        '<p class="rr_sum"><strong>' + esc(m.regionFull === '강원특별자치도 전체' ? '강원도' : m.first) + '에서 ' + esc(m.dept) + ' 진료가 가능한 의료기관 ' + m.total + '곳</strong>을 찾았고, 먼저 3곳을 안내합니다. 공공데이터에 등록된 순서이며, 내 위치를 알려주시면 거리순으로 다시 정리해 드립니다.</p>' +
        (m.compact ? '' : '<div class="op_hint"><span>결과가 강원도 여러 시·군에 넓게 흩어져 있어 <b>지도는 접어 두고 목록을 먼저</b> 보여 드려요.</span><button type="button" data-open-map="tile">시·군별 분포 보기</button></div>') +
        '<ol class="rr_list is_pending"></ol>');
      var ol = $('.rr_list', ans);
      m.fac.forEach(function (f, i) {
        later(function () {
          ol.insertAdjacentHTML('beforeend',
            '<li class="rr_card" data-pin="' + f.n + '"><span class="rr_no" aria-hidden="true">' + f.n + '</span><div class="rr_body"><h3>' + esc(f.name) + ' <span class="rr_tag' + (f.big ? ' rr_tag_hi' : '') + '">' + f.kind + '</span><span class="rr_dist">내 위치에서 약 ' + f.km + 'km</span></h3>' +
            '<dl><div><dt>주소</dt><dd>' + esc(f.addr) + '</dd></div><div><dt>대표전화</dt><dd><a href="tel:033000000' + i + '">' + f.tel + '</a></dd></div><div><dt>진료시간</dt><dd class="rr_muted">정보 확인 필요</dd></div></dl></div>' +
            '<div class="rr_act"><a class="rr_btn" href="#" data-op-note="길찾기(시안)">길찾기</a><a class="rr_link" href="#" data-op-note="상세 정보(시안)">상세 정보 ↗</a></div></li>');
          if (i === 2) finish();
        }, 220 * i);
      });
      function finish() {
        ol.classList.remove('is_pending');
        var depts = ['정형외과', '내과', '피부과', '이비인후과'].filter(function (d) { return d !== m.dept; }).slice(0, 3);
        ans.insertAdjacentHTML('beforeend',
          '<p class="rr_more"><a href="#" data-op-note="전체 목록(시안)">전체 목록 보기 (' + m.total + '곳) →</a> <button class="op_dist_btn" type="button" aria-pressed="' + state.loc + '">내 위치로 거리 표시</button></p>' +
          '<p class="rr_ask"><strong>어느 동네에 계신가요?</strong> 동 이름을 보내 주시면 그 지역 기관으로 다시 찾아드릴게요.</p>' +
          '<div class="rr_follow"><h4>이어서 물어보기</h4><ul>' + depts.map(function (d) { return '<li><button type="button" data-ask-dept="' + d + '">다른 진료과: ' + d + '</button></li>'; }).join('') +
          '<li><button type="button" data-ask-text="' + esc(m.first) + ' 응급실">' + esc(m.first) + ' 응급실</button></li><li><button type="button" data-ask-text="' + esc(m.dept) + ' 진료 전 준비할 것">' + esc(m.dept) + ' 진료 전 준비할 것</button></li></ul></div>' +
          '<div class="rr_fb"><span>이 답변이 도움이 되었나요?</span><button type="button" aria-label="도움이 됨">👍</button><button type="button" aria-label="도움이 안 됨">👎</button></div>');
        snap(turn, ans, cond, label, m, revised);
        publish(m);
        say(m.dept + ' 진료 가능한 의료기관 ' + m.total + '곳 중 3곳을 안내했습니다.' + (m.compact ? ' 지도를 함께 표시했습니다.' : ' 지도는 접어 두었습니다.'));
      }
    }, revised ? 380 : 900);
  }

  /* ── 필터형 변경은 새 턴이 아니라 직전 답변을 갱신(버전 이동 ‹ n/m ›) ── */
  function condText(c) { return [c.region, c.department, c.symptom].filter(Boolean).join(' · ') || '조건 없음'; }
  function snap(turn, ans, cond, label, m, revised) {
    var V = turn._v; V.list.push({ cond: cond, label: label, html: ans.innerHTML, m: m }); V.i = V.list.length - 1; stepper(turn);
    if (revised) say('조건을 바꿔 직전 답변을 갱신했습니다. ' + (V.i + 1) + '/' + V.list.length + '번째 결과입니다.');
  }
  function stepper(turn) {
    var V = turn._v, box = $('.op_ver', turn); if (V.list.length < 2) { box.hidden = true; return; }
    box.hidden = false;
    box.innerHTML = '<button type="button" class="op_vb" data-v="-1" aria-label="이전 조건의 결과"' + (V.i === 0 ? ' disabled' : '') + '>‹</button><span class="op_vn" aria-live="polite">' + (V.i + 1) + ' / ' + V.list.length + '</span><button type="button" class="op_vb" data-v="1" aria-label="다음 조건의 결과"' + (V.i === V.list.length - 1 ? ' disabled' : '') + '>›</button><ol class="op_trail" aria-label="조건 변경 이력">' + V.list.map(function (v, i) { return '<li' + (i === V.i ? ' aria-current="true"' : '') + '>' + esc(condText(v.cond)) + '</li>'; }).join('') + '</ol>';
  }
  col.addEventListener('click', function (e) {
    var b = e.target.closest('.op_vb'); if (!b) return;
    var turn = b.closest('.op_turn'), V = turn._v, n = V.i + parseInt(b.dataset.v, 10); if (n < 0 || n >= V.list.length) return;
    V.i = n; var v = V.list[n];
    $('.rr_a', turn).innerHTML = v.html; $('.rr_q p', turn).textContent = v.label;
    state.cond = { region: v.cond.region, symptom: v.cond.symptom, department: v.cond.department }; renderChips(); publish(v.m); stepper(turn);
    var nb = $('.op_vb[data-v="' + b.dataset.v + '"]', turn) || $('.op_vb', turn); if (nb && !nb.disabled) nb.focus();
    say((n + 1) + '번째 결과입니다. 조건: ' + condText(v.cond));
  });

  /* ── 지도: 기본은 접힘, 결과가 좁게 모일 때만 자동 펼침 ── */
  var TILES = [['철원', 1, 1], ['화천', 2, 1], ['양구', 3, 1], ['인제', 4, 1], ['고성', 5, 1], ['춘천', 1, 2], ['홍천', 2, 2], ['평창', 3, 2], ['속초', 4, 2], ['양양', 5, 2], ['원주', 1, 3], ['횡성', 2, 3], ['정선', 3, 3], ['강릉', 5, 3], ['영월', 2, 4], ['태백', 3, 4], ['동해', 4, 4], ['삼척', 5, 4]];
  var SUFFIX = { '철원': '군', '화천': '군', '양구': '군', '인제': '군', '고성': '군', '홍천': '군', '평창': '군', '양양': '군', '횡성': '군', '정선': '군', '영월': '군', '춘천': '시', '속초': '시', '원주': '시', '강릉': '시', '태백': '시', '동해': '시', '삼척': '시' };
  function publish(m) {
    mapBtn.disabled = false; $('#opMapCnt').textContent = '(' + m.total + '곳)';
    var grid = '<div class="op_tile" role="group" aria-label="강원도 시·군별 결과 수 (개략 배치)">';
    for (var r = 1; r <= 4; r++) for (var c = 1; c <= 5; c++) {
      var t = TILES.filter(function (x) { return x[1] === c && x[2] === r; })[0];
      if (!t) { grid += '<button class="gap" type="button" tabindex="-1" aria-hidden="true"></button>'; continue; }
      var full = t[0] + SUFFIX[t[0]], n = m.counts[full] || 0;
      grid += '<button type="button" class="' + (n ? 'has' : '') + '" data-region="' + full + '" aria-label="' + full + ' ' + n + '곳, 이 지역으로 좁히기"><span>' + t[0] + '</span><b>' + n + '</b></button>';
    }
    $('#opPaneTile').innerHTML = grid + '</div>';
    $('#opPanePin').innerHTML = '<div class="rr_map_canvas" role="img" aria-label="검색 결과 3곳의 위치(샘플)">' + m.fac.map(function (f) { return '<span class="rr_pin" style="left:' + f.pin[0] + '%;top:' + f.pin[1] + '%" data-pin="' + f.n + '">' + f.n + '</span>'; }).join('') + '</div>';
    state.mapTab = m.compact ? 'pin' : 'tile';   // 자동으로 열지 않고 버튼 점으로만 알림
    if (!panelOpen('map')) mapBtn.classList.add('is_new');
  }
  /* ── 우상단 유틸리티(지도·기록·계정) → 우측 오버레이 패널: 지도는 넓게(본문을 덮음), 기록·계정은 좁게 ── */
  var PN = { map: ['opMapBtn', 'opPnMap'], hist: ['opHistBtn', 'opPnHist'] };
  var narrow = window.matchMedia('(max-width: 1100px)'), opened = null;
  function panelOpen(k) { return opened === k; }
  function openPanel(k) {
    closePanel(null, true);
    var el = $('#' + PN[k][1]); el.hidden = false; void el.offsetWidth; el.classList.add('is_open');
    $('#' + PN[k][0]).setAttribute('aria-expanded', 'true'); opened = k; syncSheet();
    if (k === 'map') mapBtn.classList.remove('is_new');
    if (k === 'hist') renderHist();
    setTimeout(function () { var t = $('h2', el); if (t) t.focus({ preventScroll: true }); }, reduce ? 0 : 60);
  }
  function closePanel(k, silent) {
    var key = k || opened; if (!key || opened !== key) return;
    var el = $('#' + PN[key][1]); el.classList.remove('is_open'); el.hidden = true;
    var b = $('#' + PN[key][0]); b.setAttribute('aria-expanded', 'false'); opened = null;
    if (!silent) b.focus();
  }
  function closePanels() { closePanel(null, true); }
  Object.keys(PN).forEach(function (k) {
    $('#' + PN[k][0]).addEventListener('click', function () { if (panelOpen(k)) closePanel(k); else { openPanel(k); if (k === 'map') say('지도 패널을 열었습니다.'); } });
    $('#' + PN[k][1]).addEventListener('keydown', function (e) { if (e.key === 'Escape') { e.stopPropagation(); closePanel(k); } });
  });
  $$('[data-close]').forEach(function (b) { b.addEventListener('click', function () { closePanel(b.dataset.close); }); });
  function openMap(tab) { openPanel('map'); selectTab(tab || state.mapTab || 'tile'); }
  function selectTab(t) {
    var pin = t === 'pin';
    $('#opTabTile').setAttribute('aria-selected', !pin); $('#opTabPin').setAttribute('aria-selected', pin);
    $('#opPaneTile').hidden = pin; $('#opPanePin').hidden = !pin;
  }
  $('#opTabTile').addEventListener('click', function () { selectTab('tile'); });
  $('#opTabPin').addEventListener('click', function () { selectTab('pin'); });
  $('#opPaneTile').addEventListener('click', function (e) {
    var b = e.target.closest('[data-region]'); if (!b) return;
    if (narrow.matches) closePanel('map', true);
    state.cond.region = b.dataset.region; renderChips();
    ask({ text: state.lastText }, { fromBar: true, note: b.dataset.region + '으로 좁혀 답변을 갱신했어요' });
  });
  /* 패널은 입력 독 위에 놓는다 */
  function syncSheet() {
    var dock = $('.rn_prompt.is_dock');
    var off = dock ? Math.max(12, window.innerHeight - dock.getBoundingClientRect().top + 10) : 170;
    document.documentElement.style.setProperty('--op-dock-off', off + 'px');
  }
  var syncTick = 0;
  function syncLoop() { cancelAnimationFrame(syncTick); var t0 = Date.now(); (function f() { syncSheet(); if (Date.now() - t0 < 500) syncTick = requestAnimationFrame(f); })(); }
  window.addEventListener('scroll', syncLoop, { passive: true }); window.addEventListener('resize', syncLoop);
  form.addEventListener('focusin', syncLoop); form.addEventListener('transitionend', syncSheet);
  syncSheet();
  /* ── 좌측 전역 모듈: 로고(세션 중에는 새 대화) + 바로가기 3종. 좁은 화면에서는 버튼으로 펼침 ── */
  var side = $('#opUtil'), sideM = $('#opSideMenuBtn');
  sideM.addEventListener('click', function () { var o = !side.classList.contains('is_m_open'); side.classList.toggle('is_m_open', o); sideM.setAttribute('aria-expanded', o); sideM.setAttribute('aria-label', o ? '바로가기 닫기' : '바로가기 열기'); });
  side.addEventListener('keydown', function (e) { if (e.key === 'Escape' && side.classList.contains('is_m_open')) { sideM.click(); sideM.focus(); } });
  $('#opLogo').addEventListener('click', function (e) { if (body.classList.contains('is_chat')) { e.preventDefault(); newChat(false); } });
  doc.addEventListener('click', function (e) { if (side.classList.contains('is_m_open') && !e.target.closest('#opUtil')) sideM.click(); });

  /* ── 답변 내 상호작용(위임) ── */
  col.addEventListener('click', function (e) {
    var t;
    if ((t = e.target.closest('[data-open-map]'))) { openMap(t.dataset.openMap); say('시·군별 분포를 열었습니다.'); return; }
    if ((t = e.target.closest('[data-ask-dept]'))) { state.cond.department = t.dataset.askDept; renderChips(); ask({ text: state.lastText }, { fromBar: true }); return; }
    if ((t = e.target.closest('[data-ask-text]'))) { ask({ text: t.dataset.askText }); return; }
    if ((t = e.target.closest('.op_dist_btn'))) {
      state.loc = !state.loc; body.classList.toggle('has_dist', state.loc);
      $$('.op_dist_btn').forEach(function (b) { b.setAttribute('aria-pressed', state.loc); });
      say(state.loc ? '내 위치 기준 거리를 표시했습니다.(시안)' : '거리 표시를 껐습니다.'); return;
    }
    if ((t = e.target.closest('.rr_fb button'))) { note('의견을 보내주셔서 감사합니다 (시안)'); return; }
  });
  col.addEventListener('mouseover', function (e) { pinHover(e, true); });
  col.addEventListener('mouseout', function (e) { pinHover(e, false); });
  function pinHover(e, on) {
    var c = e.target.closest('.rr_card'); if (!c) return;
    var p = $('#opPanePin .rr_pin[data-pin="' + c.dataset.pin + '"]'); if (p) p.classList.toggle('is_on', on); c.classList.toggle('is_on', on);
  }
  doc.addEventListener('click', function (e) {
    var t = e.target.closest('[data-op-note]');
    if (t) { e.preventDefault(); note(t.getAttribute('data-op-note') + '로 이동합니다 (시안에서는 이동하지 않아요)'); }
    var f = e.target.closest('[data-focus-prompt]');
    if (f) { e.preventDefault(); input.focus(); }
  });

  /* ── 계정(시안) ── */
  function setUser(on) {
    state.user = on;
    $('#opAcctOut').hidden = on; $('#opAcctIn').hidden = !on;
    $('#opAcctLabel').textContent = on ? '홍길동' : '로그인';
    $('#opDrawerNote').textContent = on ? '계정에 저장된 대화 기록입니다. 설정에서 저장을 끄거나 전체 삭제할 수 있어요.' : '이 기기에만 저장된 최근 검색입니다. 로그인하면 계정에 저장할 수 있어요.';
  }
  $('#opLoginBtn').addEventListener('click', function () { setUser(true); say('로그인했습니다. (시안)'); });
  $('#opLogoutBtn').addEventListener('click', function () { setUser(false); say('로그아웃했습니다.'); });
  $('#opAcctIn').addEventListener('click', function (e) {
    var b = e.target.closest('[data-acct]'); if (!b) return;
    if (b.dataset.acct === 'hist') openPanel('hist');
    else if (b.dataset.acct === 'clear') { clearHist(); note('기록을 모두 삭제했습니다 (시안)'); }
    else note('즐겨찾는 기관 (시안 — 준비 중)');
  });
  /* ── 기록 ── */
  function histItems() { try { return JSON.parse(localStorage.getItem('rn_recent_q') || '[]'); } catch (e) { return []; } }
  function clearHist() { try { localStorage.removeItem('rn_recent_q'); } catch (e) { } renderHist(); }
  function renderHist() {
    var h = histItems();
    $('#opHist').innerHTML = h.length ? h.map(function (q) { return '<li><button type="button" data-q="' + esc(q) + '">' + esc(q) + '</button></li>'; }).join('') : '<li class="op_empty">아직 검색 기록이 없습니다.</li>';
  }
  $('#opHistClear').addEventListener('click', function () { clearHist(); say('기록을 삭제했습니다.'); });
  $('#opHist').addEventListener('click', function (e) {
    var b = e.target.closest('[data-q]'); if (!b) return;
    closePanel('hist', true); ask({ text: b.dataset.q });
  });

  /* ── ?q= 딥링크: 로딩 시 자동 질문 ── */
  var q0 = new URLSearchParams(location.search).get('q');
  if (q0) setTimeout(function () { clearComposer(); ask({ text: q0 }); }, 60);
})();

/* 미니(도크) 프롬프트는 푸터 위에서 멈춘다: 푸터가 화면에 보이는 높이만큼 도크를 올린다 */
(function () {
  var ft = document.getElementById('opFooter'), root = document.documentElement, raf = 0;
  if (!ft) return;
  function sync() { raf = 0; var r = ft.getBoundingClientRect(), v = ft.offsetParent === null && getComputedStyle(ft).display === 'none' ? 0 : Math.max(0, window.innerHeight - r.top); root.style.setProperty('--op-ft', Math.round(v) + 'px'); }
  function tick() { if (!raf) raf = requestAnimationFrame(sync); }
  window.addEventListener('scroll', tick, { passive: true, capture: true }); window.addEventListener('resize', tick); sync();
})();
/* 히어로: 프롬프트를 키카피(설명문) 바로 아래에 묶어 함께 세로 중앙에 둔다 */
(function () {
  var root = document.documentElement, raf = 0;
  function pos() {
    raf = 0;
    var d = document.querySelector('.rn_hero_aux .search_desc') || document.querySelector('.search_desc');
    if (!d || window.innerWidth <= 760) { root.style.removeProperty('--op-hero-top'); return; }
    var r = d.getBoundingClientRect();
    root.style.setProperty('--op-hero-top', Math.round(r.bottom + 80) + 'px');   /* 설명문 아래 여백 + 셀렉트 줄(약 42px) */
  }
  function tick() { if (!raf) raf = requestAnimationFrame(pos); }
  window.addEventListener('scroll', tick, { passive: true, capture: true }); window.addEventListener('resize', tick);
  window.addEventListener('load', tick); setTimeout(pos, 300); pos();
})();
