(function () {
  var tabs = [].slice.call(document.querySelectorAll('.gd_tab')), items = [].slice.call(document.querySelectorAll('.gd_q')), q = document.getElementById('gdSq'), cnt = document.getElementById('gdCnt'), emp = document.getElementById('gdEmpty'), cat = '';
  if (!tabs.length) return;
  function run() {
    var k = (q.value || '').trim().toLowerCase(), n = 0;
    items.forEach(function (it) { var ok = (!cat || it.dataset.c === cat) && (!k || it.textContent.toLowerCase().indexOf(k) > -1); it.hidden = !ok; if (ok) n++; });
    cnt.textContent = n; emp.hidden = n > 0;
  }
  tabs.forEach(function (t) { t.addEventListener('click', function () { cat = t.dataset.c; tabs.forEach(function (x) { x.setAttribute('aria-selected', x === t); }); run(); }); });
  q.addEventListener('input', run);
  var p = new URLSearchParams(location.search).get('category'); if (p) { var t = tabs.filter(function (x) { return x.dataset.c === p; })[0]; if (t) t.click(); }
})();
