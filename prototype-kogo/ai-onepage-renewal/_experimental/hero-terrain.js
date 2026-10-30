/* Layered pointillist landscape: variable pigment density, GSAP depth motion. */
(function () {
  'use strict';
  if (new URLSearchParams(location.search).get('bg') === 'original') return;
  var hero = document.querySelector('.hero_wrap');
  if (!hero) return;
  hero.classList.add('terrain-active');
  var scene = document.createElement('div');
  scene.className = 'hero_terrain';
  scene.setAttribute('aria-hidden', 'true');
  hero.prepend(scene);
  var video = hero.querySelector('video');
  if (video) { video.pause(); video.removeAttribute('autoplay'); video.preload = 'none'; }
  var motion = matchMedia('(prefers-reduced-motion: reduce)');
  var fine = matchMedia('(pointer: fine)');
  var layers = [], loops = [], paused = false, visible = true;
  // Back to front: mountain silhouettes, drifting mist, coastal land, open sea.
  var profiles = [
    {name: 'mountains', x: .12, y: .08, duration: 38, depth: 2},
    {name: 'mist', x: 2.4, y: .18, duration: 32, depth: 5},
    {name: 'land', x: -.22, y: .12, duration: 29, depth: 8},
    {name: 'sea', x: .55, y: .28, duration: 23, depth: 14}
  ];
  function random(seed) {
    return function () { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296; };
  }
  profiles.forEach(function (p) {
    var plane = document.createElement('div'); plane.className = 'terrain-plane';
    var canvas = document.createElement('canvas'); canvas.dataset.layer = p.name;
    plane.append(canvas); scene.append(plane); layers.push(canvas);
    if (window.gsap) loops.push(gsap.to(canvas, {
      xPercent: p.x, yPercent: p.y, duration: p.duration,
      ease: 'sine.inOut', repeat: -1, yoyo: true, paused: true
    }));
  });
  var lastWidth = 0, lastHeight = 0;
  function paint() {
    var w = Math.round(hero.clientWidth * 1.1), h = Math.round(hero.clientHeight * 1.1);
    if (!w || !h || (w === lastWidth && h === lastHeight)) return;
    lastWidth = w; lastHeight = h;
    var dpr = Math.min(devicePixelRatio || 1, 1.5);
    var occupied = new Map(), cellSize = 48;
    var shapeContext = document.createElement('canvas').getContext('2d');
    var palette = ['#008C83', null, '#55A819', '#006BC7'];
    var travel = profiles.map(function (p) {
      return Math.abs(p.x)*w/100 + Math.abs(p.y)*h/100 + p.depth*.75;
    });
    function place(x,y,r,index) {
      var gx=Math.floor(x/cellSize),gy=Math.floor(y/cellSize);
      // Reserve the full motion envelope across layers, so dots never collide in a loop.
      var reach=Math.ceil((r+3+travel[index]+Math.max.apply(null,travel)+1)/cellSize);
      for(var yy=gy-reach;yy<=gy+reach;yy++) for(var xx=gx-reach;xx<=gx+reach;xx++) {
        var bucket=occupied.get(xx+','+yy); if(!bucket) continue;
        for(var j=0;j<bucket.length;j++) {
          var q=bucket[j],gap=r+q.r+1;
          if(index!==q.layer) gap+=travel[index]+travel[q.layer];
          if((x-q.x)*(x-q.x)+(y-q.y)*(y-q.y)<gap*gap) return false;
        }
      }
      var key=gx+','+gy;
      if(!occupied.has(key)) occupied.set(key,[]);
      occupied.get(key).push({x:x,y:y,r:r,layer:index}); return true;
    }
    // Foreground owns its space; distant dots recede at overlapping boundaries.
    layers.map(function(canvas,index){return {canvas:canvas,index:index};}).reverse().forEach(function (item) {
      var canvas=item.canvas,index=item.index;
      canvas.style.width=w+'px';canvas.style.height=h+'px';
      canvas.width = Math.round(w * dpr); canvas.height = Math.round(h * dpr);
      var ctx = canvas.getContext('2d'); if (!ctx) return;
      ctx.scale(w * dpr / 1600, h * dpr / 1000);
      var rand = random(597 + index * 1301);
      function field(x, y) {
        // Smooth, reproducible patches of pigment instead of uniform random density.
        return .5 + .23*Math.sin(x*.013 + Math.sin(y*.019)*1.6)
          + .17*Math.cos(y*.025-x*.006) + .1*Math.sin(x*.044+y*.036);
      }
      function wash(path, color, top, bottom, opacity) {
        var shape = new Path2D(path);
        ctx.save();
        ctx.setTransform(canvas.width/w,0,0,canvas.height/h,0,0);
        var sx = 1600/w, sy = 1000/h;
        var spacing = index === 0 ? 3.7 : index === 3 ? 4.2 : 3.9;
        for (var y=top; y<Math.min(bottom,1005); y+=spacing*sy) {
          for (var x=0; x<1600; x+=spacing*sx) {
            var px=x+(rand()-.5)*spacing*sx*.8;
            var py=y+(rand()-.5)*spacing*sy*.8;
            var t=(py-top)/(bottom-top),f=field(px,py);
            var fade=index===3 ? 1 : Math.pow(Math.max(0,1-t),.65);
            var band=index===3 ? .5+.5*Math.sin(py*.083+Math.sin(px*.008)*1.9) : f;
            var density=(.26+f*.65)*(.2+fade*.8);
            if(index===3) density*=.4+band*.6;
            if(rand()>density) continue;
            var radius=.65+Math.pow(rand(),1.4)*1.65;
            // Reject edge dots rather than clipping circles into irregular fragments.
            if(!shapeContext.isPointInPath(shape,px,py) ||
              !shapeContext.isPointInPath(shape,px-radius*sx,py) ||
              !shapeContext.isPointInPath(shape,px+radius*sx,py) ||
              !shapeContext.isPointInPath(shape,px,py-radius*sy) ||
              !shapeContext.isPointInPath(shape,px,py+radius*sy)) continue;
            if(!place(px/sx,py/sy,radius,index)) continue;
            ctx.fillStyle=palette[index];
            var tone=Math.min(3,Math.floor((fade*.45+f*.3+opacity*.25)*4));
            ctx.globalAlpha=[.45,.65,.85,1][tone];
            ctx.beginPath();ctx.arc(px/sx,py/sy,radius,0,Math.PI*2);ctx.fill();
          }
        }
        ctx.restore();
      }
      if (index === 0) {
        wash('M-80 315 Q20 255 110 206 Q155 180 195 148 Q223 130 249 157 L295 189 Q328 174 365 118 Q388 87 414 105 Q445 127 480 161 Q520 195 559 179 Q610 140 650 167 Q717 210 766 180 Q813 145 848 119 Q873 101 905 126 Q942 163 975 153 Q1010 130 1052 87 Q1080 58 1107 79 Q1160 131 1196 156 Q1228 181 1260 156 Q1293 121 1328 141 Q1390 194 1443 183 Q1520 145 1680 250 L1680 460 L-80 460Z', '#548b8d',80,460,.34);
        wash('M-70 383 Q25 339 84 293 Q125 259 155 274 Q203 300 240 242 Q280 184 311 213 Q350 251 390 271 Q436 306 478 292 Q515 276 560 239 Q590 211 625 239 Q680 287 720 278 Q765 258 799 284 Q850 321 895 289 Q950 245 990 260 Q1036 276 1080 217 Q1109 180 1142 206 Q1180 243 1210 267 Q1250 296 1290 258 Q1340 216 1376 241 Q1430 278 1472 258 Q1530 218 1660 284 L1660 490 L-70 490Z', '#397c77',200,490,.49);
        wash('M-70 408 Q50 340 118 367 Q176 390 237 337 Q275 309 315 329 Q384 378 436 367 Q495 352 550 374 Q621 414 708 381 Q780 357 830 384 Q916 423 983 367 Q1036 320 1082 352 Q1140 399 1202 351 Q1252 307 1299 334 Q1370 383 1440 329 Q1513 274 1670 351 L1670 510 L-70 510Z', '#367463',310,510,.36);
      } else if (index === 1) {
        // White negative space reads as wind moving between ridges, never a drawn ribbon.
        for(var i=0;i<11;i++) {
          var cx=i*170-40, cy=390+Math.sin(i*.8)*24;
          var fog=ctx.createRadialGradient(cx,cy,3,cx,cy,210);
          fog.addColorStop(0,'#ffffffdf'); fog.addColorStop(.5,'#ffffff70'); fog.addColorStop(1,'#ffffff00');
          ctx.save(); ctx.translate(cx,cy);ctx.scale(1,.35);ctx.translate(-cx,-cy);
          ctx.fillStyle=fog;ctx.fillRect(cx-210,cy-210,420,420);ctx.restore();
        }
      } else if (index === 2) {
        wash('M-60 585 C100 507 217 513 365 554 C470 580 529 571 651 591 C786 618 886 577 1014 555 C1153 529 1273 482 1404 506 C1500 521 1565 502 1660 484 L1660 760 C1380 688 1180 691 987 714 C710 744 432 662 230 689 L-60 750Z','#7e9f63',490,790,.55);
        wash('M-50 645 C96 568 197 586 326 612 C449 639 494 625 600 647 C452 656 350 702 222 710 C99 712 30 747 -50 752Z','#527c55',575,770,.63);
        wash('M980 652 C1100 615 1220 569 1330 585 C1470 603 1540 555 1660 560 L1660 795 C1470 722 1320 704 1160 705 C1075 706 1020 676 980 652Z','#4e8069',560,800,.65);
        wash('M-40 735 C160 693 330 715 509 691 C669 670 810 705 965 710 C1140 711 1320 682 1640 769 L1640 827 L-40 807Z','#c2bb85',690,830,.38);
      } else {
        wash('M-60 774 C170 754 365 786 560 756 C730 735 875 778 1050 751 C1220 730 1400 771 1660 778 L1660 1100 L-60 1100Z','#609fa5',745,1160,.66);
        wash('M-60 882 C175 849 340 898 580 864 C826 833 1020 895 1220 864 C1390 843 1510 866 1670 845 L1670 1110 L-60 1110Z','#357b8f',835,1180,.48);
        ctx.globalAlpha=1;
      }
    });
    // Expose only geometry for local visual QA; no animation-frame collision work is needed.
    scene.terrainGeometry = {dots: Array.from(occupied.values()).flat(), travel: travel, palette: palette.filter(Boolean)};
  }
  var button = document.createElement('button');
  button.type = 'button'; button.className = 'terrain-toggle';
  hero.append(button);
  function blocked() {
    return paused || motion.matches || !visible || document.hidden ||
      document.documentElement.classList.contains('hs-live') || document.body.classList.contains('is_chat');
  }
  function sync() {
    loops.forEach(function (loop) { blocked() ? loop.pause() : loop.resume(); });
    button.hidden = motion.matches || !window.gsap;
    button.setAttribute('aria-pressed', String(paused));
    button.textContent = paused ? '배경 움직임 재생' : '배경 움직임 멈춤';
    if (blocked() && window.gsap) gsap.killTweensOf(layers.map(function (c) { return c.parentElement; }));
    if (motion.matches) layers.forEach(function (c) { c.parentElement.style.transform = ''; });
  }
  button.addEventListener('click', function () { paused = !paused; sync(); });
  hero.addEventListener('pointermove', function (event) {
    if (blocked() || !fine.matches || !window.gsap) return;
    var r = hero.getBoundingClientRect();
    layers.forEach(function (canvas, i) {
      gsap.to(canvas.parentElement, {x: ((event.clientX-r.left)/r.width-.5)*-profiles[i].depth,
        y: ((event.clientY-r.top)/r.height-.5)*-profiles[i].depth*.5,
        duration: 2, overwrite: true, ease: 'power2.out'});
    });
  });
  hero.addEventListener('pointerleave', function () {
    if (!blocked() && window.gsap) layers.forEach(function (canvas) {
      gsap.to(canvas.parentElement, {x: 0, y: 0, duration: 2.5, overwrite: true});
    });
  });
  new ResizeObserver(paint).observe(hero);
  new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; sync(); }).observe(hero);
  var observer = new MutationObserver(sync);
  observer.observe(document.documentElement, {attributes: true, attributeFilter: ['class']});
  observer.observe(document.body, {attributes: true, attributeFilter: ['class']});
  document.addEventListener('visibilitychange', sync);
  motion.addEventListener('change', sync);
  paint(); sync();
})();
