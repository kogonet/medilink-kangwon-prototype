/* 히어로 배경 패럴랙스: 스크롤하면 배경이 콘텐츠보다 느리게(0.3배) 따라오고, 마우스를 움직이면 반대 방향으로 살짝 밀린다.
 * 히어로가 화면 밖이거나 세션(hs-live)이 열려 있으면 계산하지 않는다. 움직임 줄이기 설정이면 정지 */
(function () {
  'use strict';
  if (new URLSearchParams(window.location.search).get('bg') !== 'original') return;
  var hero = document.querySelector('.hero_wrap'); if (!hero) return;
  var bg = document.createElement('div'); bg.className = 'hero_bg'; bg.setAttribute('aria-hidden', 'true');
  hero.insertBefore(bg, hero.firstChild);
  var veil = document.createElement('div'); veil.className = 'hero_veil'; veil.innerHTML = '<i></i><i></i><i></i>'; veil.setAttribute('aria-hidden', 'true'); hero.insertBefore(veil, bg.nextSibling);
  var rm = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var fine = window.matchMedia && window.matchMedia('(pointer: fine)').matches;
  var sy = 0, tx = 0, ty = 0, cx = 0, cy = 0, raf = 0, root = document.documentElement;
  function onScroll() { sy = window.pageYOffset || 0; kick(); }
  function onMove(e) { tx = -(e.clientX / window.innerWidth - .5) * 24; ty = -(e.clientY / window.innerHeight - .5) * 14; kick(); }
  function kick() { if (!raf) raf = requestAnimationFrame(tick); }
  function tick() {
    raf = 0;
    if (root.classList.contains('hs-live') || document.body.classList.contains('is_chat')) return;
    cx += (tx - cx) * .12; cy += (ty - cy) * .12;
    bg.style.transform = 'translate3d(' + cx.toFixed(2) + 'px,' + (sy * 0.3 + cy).toFixed(2) + 'px,0)';
    if (Math.abs(tx - cx) > .1 || Math.abs(ty - cy) > .1) kick();
  }
  /* 화이트 오브젝트의 중심을 콘텐츠 묶음(라벨~안내문)의 중심에 맞춘다 */
  var content = hero.querySelector('.hero_content');
  function alignVeil() {
    if (!content) return;
    var hr = hero.getBoundingClientRect(), cr = content.getBoundingClientRect(); if (!cr.height) return;
    veil.style.setProperty('--hv-cy', Math.round(cr.top - hr.top + cr.height / 2) + 'px');
  }
  alignVeil();
  if (window.ResizeObserver && content) new ResizeObserver(alignVeil).observe(content);
  window.addEventListener('resize', alignVeil); window.addEventListener('load', alignVeil);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(alignVeil);
  if (!rm) window.addEventListener('scroll', onScroll, { passive: true });
  if (fine && !rm) window.addEventListener('mousemove', onMove, { passive: true });
  if (!rm) onScroll();
})();
