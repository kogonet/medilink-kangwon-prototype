/**
 * AI 상담3 — 의료기관 목록 답변 아래에 작은 지도를 붙인다.
 * 2026-10-16 상담2(pt-ai/gwtpax2/js)에서 복사해 상담3 전용으로 분리. 상담2 파일과 따로 고친다.
 *
 * - ai-core2.js 의 "ptai:answer" 이벤트(detail = { body, data })를 받는다.
 * - data.source 가 "gwtpax-db"(상담2) 또는 "gwtpax-agent"(상담3)이고 items 에 좌표(lat/lon)가 있을 때만 그린다. RAG 답변은 건드리지 않는다.
 * - 지도는 기존 의료기관 지도 화면(medical_ai_map.js)과 같은 OpenLayers + VWorld 배경지도.
 * - 지도는 답변 본문(body)의 바로 뒤에 붙인다. 본문은 렌더링 중 innerHTML 이 다시 써지므로 안에 넣지 않는다.
 * - 목록 표의 행(①②③…)을 누르면 지도에서 같은 번호 마커로 이동·강조하고 말풍선을 연다. 마커를 누르면 해당 행을 강조한다.
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
  /** 지도와 연결할 목록 표 (첫 머리글이 이것이면 행 순서 = 마커 번호) */
  var LIST_HEADERS = ["기관명", "약국명", "병원명"];

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

  /** 답변 본문의 목록 표 행들 (행 i → 마커 번호 i+1). 없으면 [] */
  function listRows(body) {
    var tables = body.querySelectorAll("table");
    for (var t = 0; t < tables.length; t += 1) {
      var th = tables[t].querySelector("thead th");
      if (th && LIST_HEADERS.indexOf((th.textContent || "").trim()) >= 0) {
        return Array.prototype.slice.call(tables[t].querySelectorAll("tbody tr"));
      }
    }
    return [];
  }

  function render(body, items) {
    var ol = global.ol;
    var points = items.filter(hasCoord);
    if (!points.length) return;

    // 같은 답변에 다시 그리는 경우 이전 지도 제거
    var prev = body.nextElementSibling;
    if (prev && prev.classList && prev.classList.contains("ai2-map")) prev.parentNode.removeChild(prev);

    var wrap = el("div", "ai2-map");
    var canvas = el("div", "ai2-map__canvas");
    var pop = el("div", "ai2-map__pop");
    canvas.setAttribute("role", "img");
    canvas.setAttribute("aria-label", "검색된 기관 " + points.length + "곳 위치 지도");
    wrap.appendChild(canvas);
    wrap.appendChild(pop);
    body.insertAdjacentElement("afterend", wrap);

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
      rows.forEach(function (tr, i) {
        tr.classList.toggle("is-active", i + 1 === no);
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
    rows.forEach(function (tr, i) {
      var no = i + 1;
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

  /**
   * 표의 [상세] 링크 (href="#ai2-detail=기관명", FacilityService.actions).
   * 페이지를 이동하지 않고 "{기관명} 상세정보" 질문을 보낸다. 지도 유무·타이핑 중 여부와 상관없이 동작하도록 문서에 위임.
   */
  var DETAIL_HASH = "#ai2-detail=";
  document.addEventListener("click", function (e) {
    var a = e.target && e.target.closest ? e.target.closest('a[href^="' + DETAIL_HASH + '"]') : null;
    if (!a) return;
    e.preventDefault();
    var name;
    try {
      name = decodeURIComponent(a.getAttribute("href").slice(DETAIL_HASH.length).replace(/\+/g, " "));
    } catch (err) {
      return;
    }
    name = (name || "").trim();
    if (!name || !global.PT_AI_CHAT || typeof global.PT_AI_CHAT.startChat !== "function") return;
    global.PT_AI_CHAT.startChat(name + " 상세정보");
  });

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!cfg.tileKey || !global.ol || !d.body) return;
    // gwtpax-agent: AI 상담3 답변 (2026-10-14 평가: 상담3 약국 목록에 지도가 안 나오던 문제)
    if ((data.source !== "gwtpax-db" && data.source !== "gwtpax-agent") || !Array.isArray(data.items)) return;
    try {
      render(d.body, data.items);
    } catch (err) {
      // 지도는 부가 기능이라 실패해도 답변 표시에 영향을 주지 않는다
      if (global.console) console.warn("[ai2-map] render failed", err);
    }
  });
})(window);
