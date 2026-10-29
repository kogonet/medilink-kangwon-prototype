/* 메디링크 강원 리뉴얼(랜딩) — 히어로 엠비언트 그라데이션 배경.
 * Hello.Persona 히어로 배경과 같은 방식: 색 정지점을 OKLab 으로 보간해 256단계 테이블로 굽고,
 * 저해상도 캔버스에 천천히 흐르는 필드로 그린다(영상 대체, 가독성용 스카이블루 → 흰색).
 * renewal-main.css 와 함께 리뉴얼 옵트인 시에만 로드된다. prefers-reduced-motion 이면 정지 화면 1장. */
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
  var LABS = STOPS.map(function (s) { return [s[0], hexLab(s[1])]; });
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
