/**
 * AI 상담4 — 의료기관 목록 답변 아래에 작은 지도를 붙인다.
 * 2026-10-16 상담2(pt-ai/gwtpax2/js)에서 복사해 상담4 전용으로 분리. 상담2 파일과 따로 고친다.
 *
 * - ai-core4.js 의 "ptai:answer" 이벤트(detail = { body, data })를 받는다.
 * - data.source 가 "gwtpax-agent"(상담4 답변)이고 items 에 좌표(lat/lon)가 있을 때만 그린다. RAG 답변은 건드리지 않는다.
 * - 지도는 기존 의료기관 지도 화면(medical_ai_map.js)과 같은 OpenLayers + VWorld 배경지도.
 * - 지도는 답변 본문(body)의 바로 뒤에 붙인다. 본문은 렌더링 중 innerHTML 이 다시 써지므로 안에 넣지 않는다.
 * - 목록 표의 행(①②③…)을 누르면 지도에서 같은 번호 마커로 이동·강조하고 말풍선을 연다. 마커를 누르면 해당 행을 강조한다.
 * - 2026-10-16 블록 렌더링(answer-blocks.js): 지도와 짝인 표는 table[data-map](없으면 첫 table[data-role="list-table"]),
 *   행 tr[data-item-index] 의 값 + 1 = 마커 번호. 머리글 글자("기관명" 등)로 표를 찾지 않는다.
 * - 2026-10-21 관리자 틀(CMS 블록 템플릿 3단계): 행 반복 목록([data-map] 안의 [data-item-index] 카드)도 같은 방식으로 잇고,
 *   틀에 지도 자리 [data-ab-map] 이 있으면 지도를 본문 뒤 대신 그 자리에 넣는다.
 * - [상세] 버튼(button[data-action="detail"])은 { action: "detail", name } 을 함께 보내 서버가 질문 글을 해석하지 않게 한다.
 *
 * 필요: window.ol (OpenLayers 8), window.PT_AI2_MAP = { tileKey }
 */
(function (global) {
  "use strict";

  var cfg = global.PT_AI2_MAP || {};
  var GANGWON_CENTER = [128.2, 37.75];
  var MARKER_COLOR = "rgba(0,39,137,.9)";
  var MARKER_ACTIVE_COLOR = "rgba(232,89,12,.95)";
  var FOCUS_ZOOM = 16;

  function hasCoord(it) {
    return it && typeof it.lat === "number" && typeof it.lon === "number" && isFinite(it.lat) && isFinite(it.lon);
  }

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text) e.textContent = text;
    return e;
  }

  /** 마커 클릭 시 말풍선 내용 (textContent 로만 채워 XSS 방지) */
  function fillPopup(pop, it, no) {
    pop.textContent = "";
    var close = el("button", "ai2-map__pop-close", "×");
    close.type = "button";
    close.setAttribute("aria-label", "닫기");
    pop.appendChild(close);
    pop.appendChild(el("strong", "ai2-map__pop-name", (no ? no + ". " : "") + (it.name || "")));
    if (it.category) pop.appendChild(el("span", "ai2-map__pop-cat", it.category));
    var tel = it.erTel || it.tel;
    if (tel && typeof it.telUrl === "string" && it.telUrl.indexOf("tel:") === 0) {
      var a = el("a", "ai2-map__pop-tel", tel);
      a.href = it.telUrl;
      pop.appendChild(a);
    }
    if (it.addr) pop.appendChild(el("span", "ai2-map__pop-addr", it.addr));
    return close;
  }

  /**
   * 지도와 짝인 목록의 행들 [{ tr, no }] (no = data-item-index + 1). 없으면 [].
   * 목록 = 표 또는 관리자 틀의 행 반복 목록(카드 등, 2026-10-21) — 둘 다 [data-map] / [data-role="list-table"]
   */
  function listRows(body) {
    var table = body.querySelector("[data-map]") || body.querySelector('[data-role="list-table"]');
    if (!table) return [];
    var out = [];
    Array.prototype.forEach.call(table.querySelectorAll("[data-item-index]"), function (tr) {
      var i = parseInt(tr.getAttribute("data-item-index"), 10);
      if (!isNaN(i)) out.push({ tr: tr, no: i + 1 });
    });
    return out;
  }

  function render(body, items) {
    var ol = global.ol;
    var points = items.filter(hasCoord);
    if (!points.length) return;

    // 같은 답변에 다시 그리는 경우 이전 지도 제거
    var prev = body.nextElementSibling;
    if (prev && prev.classList && prev.classList.contains("ai2-map")) prev.parentNode.removeChild(prev);
    // 관리자 틀이 지도 자리(data-ab-map)를 두었으면 그 안에 그린다 (블록으로 다시 그린 뒤라 본문이 다시 써지지 않음)
    var spot = body.getAttribute("data-blocks") ? body.querySelector("[data-ab-map]") : null;
    if (spot) spot.textContent = "";

    var wrap = el("div", "ai2-map");
    var canvas = el("div", "ai2-map__canvas");
    var pop = el("div", "ai2-map__pop");
    canvas.setAttribute("role", "img");
    canvas.setAttribute("aria-label", "검색된 기관 " + points.length + "곳 위치 지도");
    wrap.appendChild(canvas);
    wrap.appendChild(pop);
    if (spot) spot.appendChild(wrap);
    else body.insertAdjacentElement("afterend", wrap);

    // 번호는 표의 ①②③ 순번(items 순서)과 같게, 좌표 없는 기관은 번호만 건너뛴다
    var source = new ol.source.Vector();
    var featureByNo = {};
    items.forEach(function (it, i) {
      if (!hasCoord(it)) return;
      var f = new ol.Feature({ geometry: new ol.geom.Point(ol.proj.fromLonLat([it.lon, it.lat])) });
      f.set("item", it);
      f.set("no", i + 1);
      featureByNo[i + 1] = f;
      source.addFeature(f);
    });

    var activeNo = null;
    var styleCache = {};
    function markerStyle(f) {
      var no = f.get("no");
      var active = no === activeNo;
      var key = no + (active ? "a" : "");
      if (!styleCache[key]) {
        styleCache[key] = new ol.style.Style({
          image: new ol.style.Circle({
            radius: active ? 15 : 11,
            fill: new ol.style.Fill({ color: active ? MARKER_ACTIVE_COLOR : MARKER_COLOR }),
            stroke: new ol.style.Stroke({ color: "#fff", width: active ? 3 : 2 })
          }),
          text: new ol.style.Text({
            text: String(no),
            font: (active ? "800 13px" : "700 11px") + " 'Pretendard Variable', sans-serif",
            fill: new ol.style.Fill({ color: "#fff" })
          }),
          zIndex: active ? 10 : 1
        });
      }
      return styleCache[key];
    }

    var overlay = new ol.Overlay({
      element: pop,
      positioning: "bottom-center",
      offset: [0, -18],
      stopEvent: true,
      autoPan: { animation: { duration: 200 }, margin: 12 }
    });

    var vectorLayer = new ol.layer.Vector({ source: source, style: markerStyle });
    var map = new ol.Map({
      target: canvas,
      layers: [
        new ol.layer.Tile({
          source: new ol.source.XYZ({
            url: "https://api.vworld.kr/req/wmts/1.0.0/" + encodeURIComponent(cfg.tileKey) + "/Base/{z}/{y}/{x}.png",
            maxZoom: 19,
            attributions: "&copy; VWorld"
          })
        }),
        vectorLayer
      ],
      overlays: [overlay],
      view: new ol.View({ center: ol.proj.fromLonLat(GANGWON_CENTER), zoom: 8, maxZoom: 19 })
    });
    // 위쪽 여백을 넉넉히 둬서 맨 위 마커의 말풍선이 지도 밖으로 잘리지 않게 한다
    map.getView().fit(source.getExtent(), { padding: [110, 40, 30, 40], maxZoom: 15 });

    var rows = listRows(body);

    function markRow(no) {
      rows.forEach(function (r) {
        r.tr.classList.toggle("is-active", r.no === no);
      });
    }

    function openPopup(f) {
      var close = fillPopup(pop, f.get("item"), f.get("no"));
      close.onclick = function () {
        overlay.setPosition(undefined);
        select(null);
      };
      overlay.setPosition(f.getGeometry().getCoordinates());
    }

    /** 번호 선택 상태 반영 (마커 강조 + 행 강조) */
    function select(no) {
      activeNo = no;
      vectorLayer.changed();
      markRow(no);
    }

    /** 표의 행 → 지도 마커로 이동·강조·말풍선 */
    function focusNo(no) {
      var f = featureByNo[no];
      if (!f) return;
      select(no);
      var view = map.getView();
      view.animate({
        center: f.getGeometry().getCoordinates(),
        zoom: Math.max(view.getZoom() || 0, FOCUS_ZOOM),
        duration: 450
      });
      openPopup(f);
      if (wrap.scrollIntoView) wrap.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }

    // 목록 표 행을 지도와 연결 (좌표 있는 행만)
    rows.forEach(function (r) {
      var tr = r.tr;
      var no = r.no;
      if (!featureByNo[no]) return;
      tr.classList.add("ai2-row-link");
      tr.setAttribute("tabindex", "0");
      tr.setAttribute("title", "지도에서 위치 보기");
      tr.addEventListener("click", function (e) {
        if (e.target.closest && e.target.closest("a, button")) return; // 전화 링크 등은 그대로
        focusNo(no);
      });
      tr.addEventListener("keydown", function (e) {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          focusNo(no);
        }
      });
    });

    map.on("singleclick", function (evt) {
      var f = map.forEachFeatureAtPixel(evt.pixel, function (x) { return x; });
      if (!f) {
        overlay.setPosition(undefined);
        select(null);
        return;
      }
      select(f.get("no"));
      openPopup(f);
    });
    map.on("pointermove", function (evt) {
      if (evt.dragging) return;
      canvas.style.cursor = map.hasFeatureAtPixel(evt.pixel) ? "pointer" : "";
    });
  }

  /** [상세]: 말풍선에는 query 를 보이고, 요청에는 { action: "detail", name } 을 함께 보낸다 */
  function askDetail(name, query) {
    name = (name || "").trim();
    if (!name || !global.PT_AI_CHAT || typeof global.PT_AI_CHAT.startChat !== "function") return;
    global.PT_AI_CHAT.startChat(query || name + " 상세정보", undefined, { action: "detail", name: name });
  }

  /**
   * 표의 [상세] 버튼. 지도 유무와 상관없이 동작하도록 문서에 위임한다.
   * - 블록 렌더링 뒤: button[data-action="detail"][data-name][data-query]
   * - 타이핑 중(블록으로 다시 그리기 전): 마크다운 링크 href="#ai2-detail=기관명"
   */
  var DETAIL_HASH = "#ai2-detail=";
  document.addEventListener("click", function (e) {
    var t = e.target && e.target.closest ? e.target : null;
    if (!t) return;
    var btn = t.closest('[data-action="detail"]');
    if (btn) {
      e.preventDefault();
      askDetail(btn.getAttribute("data-name"), btn.getAttribute("data-query"));
      return;
    }
    var a = t.closest('a[href^="' + DETAIL_HASH + '"]');
    if (!a) return;
    e.preventDefault();
    var name;
    try {
      name = decodeURIComponent(a.getAttribute("href").slice(DETAIL_HASH.length).replace(/\+/g, " "));
    } catch (err) {
      return;
    }
    askDetail(name, null);
  });

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!cfg.tileKey || !global.ol || !d.body) return;
    // gwtpax-agent: AI 상담4 답변 (2026-10-20: 상담2의 gwtpax-db 답변은 상담4 화면에 오지 않아 조건에서 뺐다)
    if (data.source !== "gwtpax-agent" || !Array.isArray(data.items)) return;
    try {
      render(d.body, data.items);
    } catch (err) {
      // 지도는 부가 기능이라 실패해도 답변 표시에 영향을 주지 않는다
      if (global.console) console.warn("[ai2-map] render failed", err);
    }
  });
})(window);
