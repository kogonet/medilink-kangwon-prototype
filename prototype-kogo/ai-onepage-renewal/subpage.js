/* 병·의원 / 약국 / 응급실 LIVE 시안 공통 스크립트 (샘플 데이터 · 서버 연동 없음) */
(function () {
  var $ = function (s, r) { return (r || document).querySelector(s); }, body = document.body;
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

  /* ── 공통 헤더: 좁은 화면 메뉴 ── */
  var u = $('#opUtil'), mb = $('#opSideMenuBtn');
  if (u && mb) {
    mb.addEventListener('click', function () { var o = !u.classList.contains('is_m_open'); u.classList.toggle('is_m_open', o); mb.setAttribute('aria-expanded', o); mb.setAttribute('aria-label', o ? '바로가기 닫기' : '바로가기 열기'); });
    document.addEventListener('click', function (e) { if (u.classList.contains('is_m_open') && !e.target.closest('#opUtil')) mb.click(); });
  }

  /* ── 계정 페이지(로그인·회원가입·찾기): 시안, 실제 처리 없음 ── */
  (function () {
    var forms = document.querySelectorAll('form[data-ac]'); if (!forms.length) return;
    var msg = function (f, t, ok) { var p = f.querySelector('.ac_err') || document.getElementById('acErr'); if (!p) return; p.textContent = t; p.hidden = false; p.classList.toggle('is_ok', !!ok); };
    [].forEach.call(forms, function (f) {
      f.addEventListener('submit', function (e) {
        e.preventDefault(); var bad = [].filter.call(f.querySelectorAll('input[required]'), function (i) { return i.type === 'checkbox' ? !i.checked : !i.value.trim(); });
        if (bad.length) { msg(f, '필수 항목을 입력해 주세요.'); bad[0].focus(); return; }
        var k = f.dataset.ac;
        if (k === 'login') { location.href = 'index.html'; return; }
        if (k === 'join') { var a = f.querySelector('#pw').value, b = f.querySelector('#pw2').value; if (a !== b) { msg(f, '비밀번호가 서로 달라요.'); f.querySelector('#pw2').focus(); return; } msg(f, '가입 신청을 받았어요. (시안 — 실제로 가입되지 않습니다)', true); return; }
        msg(f, '입력하신 정보로 안내를 보냈어요.', true);
      });
    });
    var tid = document.getElementById('tId'), tpw = document.getElementById('tPw');
    if (tid && tpw) {
      var pick = function (pw) { tid.setAttribute('aria-selected', !pw); tpw.setAttribute('aria-selected', pw); document.getElementById('pId').hidden = pw; document.getElementById('pPw').hidden = !pw; };
      tid.addEventListener('click', function () { pick(false); }); tpw.addEventListener('click', function () { pick(true); });
      if (location.hash === '#pw') pick(true);
    }
    var all = document.getElementById('tAll');
    if (all) all.addEventListener('change', function () { [].forEach.call(document.querySelectorAll('.t'), function (c) { c.checked = all.checked; }); });
  })();

  /* ── (구) 계정 패널 ── */
  var ab = $('#opAcctBtn'), ap = $('#opPnAcct');
  function acctOpen(o) {
    if (!ap) return;
    if (o) { ap.hidden = false; requestAnimationFrame(function () { ap.classList.add('is_open'); }); }
    else { ap.classList.remove('is_open'); setTimeout(function () { ap.hidden = true; }, 240); }
    ab.setAttribute('aria-expanded', o);
  }
  function setUser(on) { $('#opAcctOut').hidden = on; $('#opAcctIn').hidden = !on; $('#opAcctLabel').textContent = on ? '홍길동' : '로그인'; }
  if (ab && ap) {
    ab.addEventListener('click', function () { acctOpen(ap.hidden); });
    ap.addEventListener('click', function (e) { if (e.target.closest('[data-close]')) { acctOpen(false); ab.focus(); } });
    var li = $('#opLoginBtn'), lo = $('#opLogoutBtn');
    if (li) li.addEventListener('click', function () { setUser(true); });
    if (lo) lo.addEventListener('click', function () { setUser(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !ap.hidden) { acctOpen(false); ab.focus(); } });
  }

  /* ── 공통 프롬프트: 제출하면 원페이지 AI 상담으로 이어서 질문 ── */
  document.addEventListener('submit', function (e) {
    var f = e.target.closest && e.target.closest('form.search_form'); if (!f) return;
    e.preventDefault(); e.stopImmediatePropagation();
    var inp = f.querySelector('#medical_search'), t = inp ? inp.value.trim() : '';
    var tags = [].map.call(f.querySelectorAll('.selected_tag'), function (n) { var c = n.cloneNode(true); [].forEach.call(c.querySelectorAll('button,b'), function (x) { x.remove(); }); return c.textContent.trim(); }).filter(Boolean).join(' ');
    var q = (tags + ' ' + t).trim();
    if (!q) { if (inp) inp.focus(); return; }
    location.href = 'index.html?q=' + encodeURIComponent(q);
  }, true);

  /* ── 지도 기반 페이지(병·의원/약국): 구글 지도식 레이아웃 ── */
  var mp = $('#mp');
  var mapBtn = $('#opMapBtn');
  if (mp && window.MP_DATA) {
    var D = MP_DATA, g = '전체', q = '', sel = -1, zoom = 1;
    var chips = $('#mpChips'), list = $('#mpList'), pins = $('#mpPins');
    var gs = ['전체'].concat(D.map(function (d) { return d.g; }).filter(function (v, i, a) { return a.indexOf(v) === i; }));
    chips.innerHTML = gs.map(function (x) { return '<button type="button" class="' + (x === g ? 'on' : '') + '" aria-pressed="' + (x === g) + '">' + x + '</button>'; }).join('');
    list.innerHTML = D.map(function (d, i) {
      var open = /진료 중|영업 중/.test(d.s);
      return '<li data-i="' + i + '"><button type="button" class="mp_item"><span class="mp_no">' + (i + 1) + '</span><span class="mp_tx"><span class="mp_nm">' + esc(d.t) + ' <em class="' + (open ? 'is_open' : '') + '">' + d.s + '</em></span><span class="mp_ad">' + esc(d.a) + '</span><span class="mp_tl">' + d.tel + '</span></span></button></li>';
    }).join('') + '<li class="mp_none" hidden>검색 결과가 없습니다.</li>';
    function match(d) { return (g === '전체' || d.g === g) && (!q || (d.t + d.a).indexOf(q) > -1); }
    function render() {
      var n = 0;
      D.forEach(function (d, i) {
        var m = match(d); if (m) n++;
        list.querySelector('li[data-i="' + i + '"]').hidden = !m; var p = pins.children[i]; if (p) p.hidden = !m;
      });
      list.querySelector('.mp_none').hidden = n > 0; $('#mpCnt').textContent = n + '곳';
    }

    /* 정렬 옵션: 선택한 상태(진료 중 / 진료 종료)를 먼저 보여 줌 · 다시 누르면 기본 순서 */
    var sortEl = $('#mpSort'), sortBy = '';
    var sts = D.map(function (d) { return d.s; }).filter(function (v, i, a) { return a.indexOf(v) === i; }).sort(function (a, b) { return /종료/.test(a) - /종료/.test(b); });
    sortEl.innerHTML = sts.map(function (s) { return '<button type="button" class="' + (/종료/.test(s) ? 'closed' : 'open') + '" data-s="' + s + '" aria-pressed="false">' + s.replace(/\s/g, '') + '</button>'; }).join('');
    function applySort() {
      var none = list.querySelector('.mp_none');
      [].slice.call(list.querySelectorAll('li[data-i]')).sort(function (a, b) {
        var ra = sortBy && D[+a.dataset.i].s !== sortBy ? 1 : 0, rb = sortBy && D[+b.dataset.i].s !== sortBy ? 1 : 0;
        return ra - rb || a.dataset.i - b.dataset.i;
      }).forEach(function (li) { list.insertBefore(li, none); });
      [].forEach.call(sortEl.children, function (b) { var on = b.dataset.s === sortBy; b.classList.toggle('on', on); b.setAttribute('aria-pressed', on); });
    }
    sortEl.addEventListener('click', function (e) { var b = e.target.closest('button'); if (!b) return; sortBy = sortBy === b.dataset.s ? '' : b.dataset.s; applySort(); });
    function select(i, scroll) {
      sel = i;
      [].forEach.call(list.querySelectorAll('li[data-i]'), function (li) { li.querySelector('.mp_item').classList.toggle('is_on', +li.dataset.i === i); });
      [].forEach.call(pins.children, function (p, k) { p.classList.toggle('is_on', k === i); });
      if (scroll) list.querySelector('li[data-i="' + i + '"]').scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }
    chips.addEventListener('click', function (e) { var b = e.target.closest('button'); if (!b) return; g = b.textContent; [].forEach.call(chips.children, function (c) { c.classList.toggle('on', c === b); c.setAttribute('aria-pressed', c === b); }); render(); });
    $('#mpInp').addEventListener('input', function (e) { q = e.target.value.trim(); render(); });
    list.addEventListener('click', function (e) { var li = e.target.closest('li[data-i]'); if (li) select(+li.dataset.i, false); });
    pins.addEventListener('click', function (e) { var p = e.target.closest('.mp_pin'); if (p) select(+p.dataset.i, true); });
    function zoomTo(z) { zoom = Math.max(1, Math.min(1.8, z)); pins.style.transform = 'scale(' + zoom + ')'; }
    $('#mpZin').addEventListener('click', function () { zoomTo(zoom + .2); });
    $('#mpZout').addEventListener('click', function () { zoomTo(zoom - .2); });
    function setView(v) {
      mp.classList.toggle('is_list', v === 'list');
      [].forEach.call(mp.querySelectorAll('.mp_toggle button[data-v="map"], .mp_toggle button[data-v="list"]'), function (b) { var on = b.dataset.v === v; b.classList.toggle('on', on); b.setAttribute('aria-pressed', on); });
      var sw = mp.querySelector('.mp_sw'); if (sw) sw.setAttribute('aria-checked', v === 'list');
      if (mapBtn) mapBtn.classList.toggle('is_on', v === 'map');
    }
    $('.mp_toggle').addEventListener('click', function (e) { var b = e.target.closest('button'); if (!b) return; setView(b.dataset.v === 'toggle' ? (mp.classList.contains('is_list') ? 'map' : 'list') : b.dataset.v); });
    if (mapBtn) { mapBtn.addEventListener('click', function () { setView('map'); }); mapBtn.classList.add('is_on'); }
    render();
  } else if (mapBtn) {
    mapBtn.addEventListener('click', function () { location.href = 'hospital.html'; });   /* 지도 아이콘: 지도 기반 페이지로 */
  }

  /* ── 응급실 LIVE ── */
  var eg = $('#erGrid');
  if (eg && window.ER) {
    var bed = function (n, l) { return '<div class="er_bed ' + (n > 2 ? 'ok' : n > 0 ? 'warn' : 'none') + '"><div class="er_bed_n">' + n + '</div><div class="er_bed_l">' + l + '</div></div>'; };
    var renderEr = function () {
      eg.innerHTML = ER.map(function (d) {
        return '<article class="er_card"><div class="er_top"><h2 class="er_nm">' + d.n + '</h2><span class="er_type lv' + d.l + '">' + d.t + '</span></div><p class="er_addr">' + d.a + '</p>' +
          '<div class="er_beds_lbl">가용 병상 현황</div><div class="er_beds">' + bed(d.b1, '일반응급') + bed(d.b2, '수술실') + bed(d.b3, '중증응급') + '</div>' +
          '<a class="er_btn" href="tel:' + d.tel.replace(/-/g, '') + '">전화 연결 ' + d.tel + '</a></article>';
      }).join('');
    };
    $('#erRefresh').addEventListener('click', renderEr); renderEr();
  }
})();

/* 도크 프롬프트는 푸터 위에서 멈춘다 */
(function () {
  var ft = document.getElementById('opFooter'), root = document.documentElement, raf = 0;
  if (!ft) return;
  function sync() { raf = 0; var r = ft.getBoundingClientRect(); root.style.setProperty('--op-ft', Math.max(0, Math.round(window.innerHeight - r.top)) + 'px'); }
  function tick() { if (!raf) raf = requestAnimationFrame(sync); }
  window.addEventListener('scroll', tick, { passive: true, capture: true }); window.addEventListener('resize', tick); window.addEventListener('load', tick); sync();
})();
