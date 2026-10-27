/**
 * 강원 메디컬 AI - 지도(VWorld+OpenLayers) 공용 렌더러
 * medical_map_data.js(MedicalMap.searchResult.Area[])를 gubun으로 필터링해서
 * 지도 마커+사이드 리스트+지역필터+검색을 그린다. 6개 데이터셋 페이지(hospitalList/pharmacyList/
 * emergencyList/vaccinationList/evaluationList/aed)에서 동일하게 재사용한다.
 * item.place/item.hours는 선택 필드(현재 aed만 채움) - 지도 팝업/사이드리스트/카드 3곳 모두
 * place는 주소 아래, hours는 전화번호 옆에 표시. 값 없으면 자동으로 빈 문자열이라 안 보임(08-20 추가).
 *
 * 사용법(각 페이지 하단에서):
 *   MedicalAIMap.init({ gubun: 'pharmacy', tileKey: '...', center: [127.9, 37.6] });
 */
var MedicalAIMap = (function () {

	var GUGUN_LIST = ["춘천시", "원주시", "강릉시", "동해시", "태백시", "속초시", "삼척시",
		"홍천군", "횡성군", "영월군", "평창군", "정선군", "철원군", "화천군", "양구군", "인제군", "고성군", "양양군"];

	/** 시군구 필터 클릭 시 지도 중심을 이동시킬 시청/군청 좌표(경도, 위도). 값은 대략치이므로
	 *  실제 반영 전 VWorld 주소검색("OO시청")으로 한 번씩 대조 확인 권장. */
	var GUGUN_CENTER = {
		"춘천시": [127.72976980517016, 37.881399903208965], "원주시": [127.9201, 37.3420], "강릉시": [128.8759, 37.7521],
		"동해시": [129.11429929301, 37.5247415047966], "태백시": [128.98572415543916, 37.16400833957862], "속초시": [128.591938589235, 38.206894335257],
		"삼척시": [129.165111673952, 37.4498976008123], "홍천군": [127.88868410893069, 37.69716551454279], "횡성군": [127.98507091126034, 37.491783235566665],
		"영월군": [128.461783934737, 37.1836860419405], "평창군": [128.390161790138, 37.3707820404635], "정선군": [128.660813602092, 37.3805844996162],
		"철원군": [127.3133798516857, 38.14679198808101], "화천군": [127.708150578834, 38.1061819512278], "양구군": [127.989950629022, 38.1100012808218],
		"인제군": [128.1703491696283, 38.069706161608956], "고성군": [128.467866303864, 38.3805924324258], "양양군": [128.619079851718, 38.0755111735392]
	};
	var GUGUN_ZOOM = 14;

	var PAGE_SIZE = 16; // 목록: 한 줄 4열 × 4줄 (기존 10=5열×2줄)

	var state = {
		allItems: [],
		filtered: [],
		gugun: null,
		keyword: "",
		map: null,
		vectorSource: null,
		selectedFeature: null,
		selectedNo: null,
		markerColor: "#004EA2",
		listPage: 1
	};

	function css(varName) {
		return getComputedStyle(document.documentElement).getPropertyValue(varName).trim();
	}

	function gradeColor(grade) {
		if (grade === "3") return css("--primary") || "#004EA2";
		if (grade === "2") return css("--primary-l") || "#1A6BC4";
		return css("--g500") || "#5A7590";
	}

	function gradeRadius(grade) {
		if (grade === "3") return 9;
		if (grade === "2") return 7;
		return 5;
	}

	function matchesGugun(item, gugun) {
		if (!gugun) return true;
		return (item.addr || "").indexOf(gugun) > -1;
	}

	function matchesKeyword(item, kw) {
		if (!kw) return true;
		var k = kw.toLowerCase();
		return (item.title || "").toLowerCase().indexOf(k) > -1 || (item.addr || "").toLowerCase().indexOf(k) > -1;
	}

	function applyFilter() {
		state.filtered = state.allItems.filter(function (it) {
			return matchesGugun(it, state.gugun) && matchesKeyword(it, state.keyword);
		});
	}

	/** 카카오맵 마커처럼 물방울(핀) 모양 SVG를 만들어 data URI로 반환. VWorld/OpenLayers엔
	 *  카카오 SDK의 kakao.maps.Marker 같은 내장 마커 이미지가 없어서 직접 그려서 쓴다. */
	var pinIconCache = {};
	function buildPinIcon(color) {
		if (pinIconCache[color]) return pinIconCache[color];
		var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">' +
			'<path d="M12 0C7.03 0 3 4.03 3 9c0 6.75 9 15 9 15s9-8.25 9-15c0-4.97-4.03-9-9-9z" fill="' + color + '" stroke="#fff" stroke-width="1"/>' +
			'<circle cx="12" cy="9" r="3.4" fill="#fff"/>' +
			'</svg>';
		var uri = 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
		pinIconCache[color] = uri;
		return uri;
	}

	function buildVectorLayer() {
		state.vectorSource = new ol.source.Vector();
		var clusterSource = new ol.source.Cluster({
			distance: 42,
			source: state.vectorSource
		});

		var layer = new ol.layer.Vector({
			source: clusterSource,
			style: function (feature) {
				var features = feature.get("features");
				var size = features.length;

				if (size === 1) {
					var single = features[0];
					var grade = single.get("grade");
					var color = single.get("markerColor") || gradeColor(grade);
					var radius = single.get("markerRadius") || gradeRadius(grade);
					var singleItem = single.get("item");
					var isSelected = state.selectedNo != null && singleItem && singleItem.no === state.selectedNo;

					// 핀 모양(카카오맵 스타일)으로 표시하되, 색상은 기존 등급별 색상 로직을 그대로 사용.
					// 선택된 항목만 주황색 + 확대로 강조.
					return new ol.style.Style({
						image: new ol.style.Icon({
							src: buildPinIcon(isSelected ? "#FF9500" : color),
							anchor: [0.5, 1],
							scale: (radius / 7) * (isSelected ? 1.3 : 1)
						})
					});
				}

				return new ol.style.Style({
					image: new ol.style.Circle({
						radius: 13 + Math.min(size, 40) / 4,
						fill: new ol.style.Fill({ color: "rgba(0,78,162,.82)" }),
						stroke: new ol.style.Stroke({ color: "#fff", width: 2 })
					}),
					text: new ol.style.Text({
						text: String(size),
						fill: new ol.style.Fill({ color: "#fff" }),
						font: "bold 12px 'Noto Sans KR',sans-serif"
					})
				});
			}
		});

		return layer;
	}

	function refreshMarkers() {
		state.vectorSource.clear();
		var feats = state.filtered.filter(function (it) {
			return it.grd_lo && it.grd_la;
		}).map(function (it) {
			var f = new ol.Feature({
				geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(it.grd_lo), parseFloat(it.grd_la)]))
			});
			f.set("item", it);
			f.set("grade", it.grade);
			f.set("markerColor", state.markerColor);
			return f;
		});
		state.vectorSource.addFeatures(feats);
	}

	function renderSideList(hdEl, listEl) {
		if (hdEl) hdEl.textContent = "전체 " + formatNum(state.filtered.length) + "개";
		if (!listEl) return;

		var html = state.filtered.map(function (it, idx) {
			return '<div class="pms_item" data-idx="' + idx + '">' +
				'<div class="pms_nm">' + escHtml(it.title) + '</div>' +
				'<div class="pms_addr">' + escHtml(it.addr) + '</div>' +
				(it.place ? '<div class="pms_place">' + escHtml(it.place) + '</div>' : '') +
				'<div class="pms_row">' +
				(it.tel ? '<span class="pms_tel">' + escHtml(it.tel) + '</span>' : '') +
				(it.hours ? '<span class="pms_hr">' + escHtml(it.hours) + '</span>' : '') +
				'</div>' +
				'</div>';
		}).join("");

		listEl.innerHTML = html || '<div class="no_result">검색 결과가 없습니다</div>';

		var items = listEl.querySelectorAll(".pms_item");
		items.forEach(function (el) {
			el.addEventListener("click", function () {
				var idx = parseInt(el.getAttribute("data-idx"), 10);
				focusItem(state.filtered[idx]);
				highlightSideItem(idx);
			});
		});
	}

	function gradeLabel(grade) {
		if (grade === "3") return "3차";
		if (grade === "2") return "2차";
		if (grade === "1") return "1차";
		return "";
	}

	function renderListView() {
		if (!state.cfg) return;

		var totalPages = Math.max(1, Math.ceil(state.filtered.length / PAGE_SIZE));
		if (state.listPage > totalPages) state.listPage = totalPages;
		if (state.listPage < 1) state.listPage = 1;

		var start = (state.listPage - 1) * PAGE_SIZE;
		var pageItems = state.filtered.slice(start, start + PAGE_SIZE);

		var gridEl = document.getElementById(state.cfg.listGridId);
		if (gridEl) {
			var html = pageItems.map(function (it) {
				var badge = it.grade ? '<span class="ph_status ph_open">' + gradeLabel(it.grade) + '</span>' : "";
				var place = it.place ? '<div class="ph_place">' + escHtml(it.place) + '</div>' : "";
				var tel = it.tel ? '<div class="ph_tel_sm">' + escHtml(it.tel) + '</div>' : "";
				var hours = it.hours ? '<div class="ph_hr">' + escHtml(it.hours) + '</div>' : "";
				return '<div class="ph_card">' +
					'<div class="ph_card_hd"><div class="ph_nm">' + escHtml(it.title) + '</div>' + badge + '</div>' +
					'<div class="ph_addr">' + escHtml(it.addr) + '</div>' +
					place +
					'<div class="ph_card_ft"><div>' + tel + hours + '</div></div>' +
					'</div>';
			}).join("");
			gridEl.innerHTML = html || '<div class="no_result">등록된 정보가 없습니다.</div>';
		}

		var infoEl = document.getElementById(state.cfg.listInfoId);
		if (infoEl) {
			infoEl.textContent = state.filtered.length === 0 ? "총 0개" :
				formatNum(start + 1) + "-" + formatNum(Math.min(start + PAGE_SIZE, state.filtered.length)) + " / 총 " + formatNum(state.filtered.length) + "개";
		}

		var indicatorEl = document.getElementById(state.cfg.listIndicatorId);
		if (indicatorEl) indicatorEl.textContent = state.listPage + " / " + totalPages;

		var prevBtn = document.getElementById(state.cfg.listPrevId);
		var nextBtn = document.getElementById(state.cfg.listNextId);
		if (prevBtn) prevBtn.disabled = state.listPage <= 1;
		if (nextBtn) nextBtn.disabled = state.listPage >= totalPages;
	}

	function goListPage(delta) {
		state.listPage = state.listPage + delta;
		renderListView();
	}

	function refreshAll() {
		applyFilter();
		refreshMarkers();
		if (state.cfg) {
			renderSideList(document.getElementById(state.cfg.sideHdElId), document.getElementById(state.cfg.sideListElId));
		}
		state.listPage = 1;
		renderListView();
	}

	function formatNum(n) {
		return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	function escHtml(s) {
		if (!s) return "";
		return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
	}

	function focusItem(item) {
		if (!item || !item.grd_lo || !item.grd_la) return;
		state.selectedNo = item.no;
		state.vectorSource.changed();
		var coord = ol.proj.fromLonLat([parseFloat(item.grd_lo), parseFloat(item.grd_la)]);
		state.map.getView().animate({ center: coord, zoom: Math.max(state.map.getView().getZoom(), 19), duration: 300 });
		showCard(item);
	}

	function showCard(item) {
		if (!state.cfg) return;
		var card = document.getElementById(state.cfg.cardElId);
		if (!card) return;
		document.getElementById(state.cfg.cardNmId).textContent = item.title || "";
		document.getElementById(state.cfg.cardAddrId).textContent = item.addr || "";

		var placeEl = document.getElementById(state.cfg.cardPlaceId);
		if (placeEl) placeEl.textContent = item.place || "";

		var hoursEl = document.getElementById(state.cfg.cardHoursId);
		if (hoursEl) hoursEl.textContent = item.hours || "";

		var telEl = document.getElementById(state.cfg.cardTelId);
		telEl.textContent = item.tel || "";
		if (item.tel) {
			telEl.setAttribute("href", "tel:" + item.tel.replace(/[^0-9+]/g, ""));
		} else {
			telEl.removeAttribute("href");
		}

		card.classList.add("on");
	}

	// HDH 2026-08-18 마커 클릭 시 오른쪽 사이드 리스트를 해당 항목으로 하이라이트+스크롤
	function highlightSideItem(idx) {
		if (!state.cfg) return;
		var listEl = document.getElementById(state.cfg.sideListElId);
		if (!listEl) return;
		var items = listEl.querySelectorAll(".pms_item");
		items.forEach(function (el) { el.classList.remove("on"); });
		if (idx == null || idx < 0) return;
		var target = listEl.querySelector('.pms_item[data-idx="' + idx + '"]');
		if (target) {
			target.classList.add("on");
			target.scrollIntoView({ block: "nearest", behavior: "smooth" });
		}
	}

	/** 주소 복사 버튼. 사내망 http 환경(비-HTTPS)에서는 Clipboard API를 못 쓰므로
	 *  구식 execCommand 방식으로 대체한다. */
	function copyText(text, btnEl) {
		function done(ok) {
			if (!btnEl) return;
			var original = btnEl.textContent;
			btnEl.textContent = ok ? "복사됨" : "복사 실패";
			btnEl.classList.toggle("copied", ok);
			setTimeout(function () {
				btnEl.textContent = original;
				btnEl.classList.remove("copied");
			}, 1500);
		}

		if (window.isSecureContext && navigator.clipboard && navigator.clipboard.writeText) {
			navigator.clipboard.writeText(text).then(function () { done(true); }, function () { done(false); });
			return;
		}

		var textarea = document.createElement("textarea");
		textarea.value = text;
		textarea.style.position = "fixed";
		textarea.style.opacity = "0";
		document.body.appendChild(textarea);
		textarea.focus();
		textarea.select();
		var ok = false;
		try {
			ok = document.execCommand("copy");
		} catch (e) {
			ok = false;
		}
		document.body.removeChild(textarea);
		done(ok);
	}

	function init(cfg) {
		cfg = Object.assign({
			mapElId: "pharmMapEl",
			sideHdElId: "pharmSideHd",
			sideListElId: "pharmSideList",
			cardElId: "pharmMapCard",
			cardNmId: "pmcNm",
			cardAddrId: "pmcAddr",
			cardPlaceId: "pmcPlace",
			cardTelId: "pmcTel",
			cardHoursId: "pmcHours",
			cardCopyBtnId: "pmcCopyBtn",
			searchInputId: "pharmInp",
			cntPillId: "pharmCnt",
			filterBtnClass: "pf_btn",
			listGridId: "pharmListEl",
			listInfoId: "pharmPgInfo",
			listIndicatorId: "pharmPgIndicator",
			listPrevId: "pharmPgPrev",
			listNextId: "pharmPgNext",
			center: [128.15, 37.7],
			zoom: 8,
			markerColor: "#004EA2"
		}, cfg || {});

		state.markerColor = cfg.markerColor;
		state.cfg = cfg;
		// 페이지에서 pageSize 넘기면 목록 개수 덮어씀 (기본 16)
		if (cfg.pageSize && cfg.pageSize > 0) PAGE_SIZE = cfg.pageSize;

		var raw = (window.MedicalMap && window.MedicalMap.searchResult && window.MedicalMap.searchResult.Area) || [];
		state.allItems = raw.filter(function (it) { return it.gubun === cfg.gubun; });
		state.filtered = state.allItems.slice();

		var cntPill = document.getElementById(cfg.cntPillId);
		if (cntPill) cntPill.textContent = formatNum(state.allItems.length) + "개";

		var mapEl = document.getElementById(cfg.mapElId);
		if (!mapEl) return;

		var tileSource;
		if (cfg.tileKey) {
			tileSource = new ol.source.XYZ({
				url: "https://api.vworld.kr/req/wmts/1.0.0/" + cfg.tileKey + "/Base/{z}/{y}/{x}.png",
				maxZoom: 19,
				attributions: "&copy; VWorld"
			});
		} else {
			// 타일 키 미설정 시 임시 대체(빈 배경) - 키 발급 확인되는 대로 교체됨
			tileSource = new ol.source.XYZ({ url: "" });
		}

		state.map = new ol.Map({
			target: cfg.mapElId,
			layers: [
				new ol.layer.Tile({ source: tileSource })
			],
			view: new ol.View({
				center: ol.proj.fromLonLat(cfg.center),
				zoom: cfg.zoom,
				maxZoom: 19
			}),
			controls: []
		});

		var vectorLayer = buildVectorLayer();
		state.map.addLayer(vectorLayer);

		refreshMarkers();
		renderSideList(document.getElementById(cfg.sideHdElId), document.getElementById(cfg.sideListElId));

		state.map.on("click", function (evt) {
			var feature = state.map.forEachFeatureAtPixel(evt.pixel, function (f) { return f; });
			if (!feature) return;
			var features = feature.get("features");
			if (!features) return;

			if (features.length === 1) {
				var clickedItem = features[0].get("item");
				state.selectedNo = clickedItem ? clickedItem.no : null;
				state.vectorSource.changed();
				showCard(clickedItem);
				highlightSideItem(state.filtered.indexOf(clickedItem));
			} else {
				var extent = ol.extent.createEmpty();
				features.forEach(function (f) { ol.extent.extend(extent, f.getGeometry().getExtent()); });
				state.map.getView().fit(extent, { duration: 300, padding: [40, 40, 40, 40], maxZoom: 15 });
			}
		});

		var closeBtn = document.getElementById(cfg.cardElId);
		if (closeBtn) {
			var x = closeBtn.querySelector(".pmc_x");
			if (x) x.addEventListener("click", function () { closeBtn.classList.remove("on"); });
		}

		var copyBtn = document.getElementById(cfg.cardCopyBtnId);
		if (copyBtn) {
			copyBtn.addEventListener("click", function () {
				var addrEl = document.getElementById(cfg.cardAddrId);
				var addr = addrEl ? addrEl.textContent : "";
				if (!addr) return;
				copyText(addr, copyBtn);
			});
		}

		// 검색
		var searchInput = document.getElementById(cfg.searchInputId);
		if (searchInput) {
			searchInput.addEventListener("input", function () {
				state.keyword = searchInput.value;
				refreshAll();
			});
		}

		// 목록보기 페이징
		var prevBtn = document.getElementById(cfg.listPrevId);
		var nextBtn = document.getElementById(cfg.listNextId);
		if (prevBtn) prevBtn.addEventListener("click", function () { goListPage(-1); });
		if (nextBtn) nextBtn.addEventListener("click", function () { goListPage(1); });

		renderListView();

		setTimeout(function () { state.map.updateSize(); }, 100);
	}

	function setGugun(gugun, btnEl) {
		document.querySelectorAll(".pf_btn").forEach(function (b) { b.classList.remove("on"); });
		if (btnEl) btnEl.classList.add("on");
		state.gugun = gugun;
		refreshAll();

		if (!state.map) return;
		var target = gugun && GUGUN_CENTER[gugun];
		if (target) {
			state.map.getView().animate({ center: ol.proj.fromLonLat(target), zoom: GUGUN_ZOOM, duration: 400 });
		} else {
			// "전체" 선택 시 페이지 초기 화면(cfg.center/zoom)으로 복귀
			state.map.getView().animate({ center: ol.proj.fromLonLat(state.cfg.center), zoom: state.cfg.zoom, duration: 400 });
		}
	}

	function setView(mode) {
		var mapView = document.querySelector(".pharm_map_view");
		var listView = document.querySelector(".pharm_list_view");
		var btns = document.querySelectorAll(".pvt");

		btns.forEach(function (b) { b.classList.remove("on"); });

		if (mode === "map") {
			if (mapView) mapView.style.display = "flex";
			if (listView) listView.style.display = "none";
			if (state.map) setTimeout(function () { state.map.updateSize(); }, 50);
		} else {
			if (mapView) mapView.style.display = "none";
			if (listView) listView.style.display = "flex";
		}
	}

	return {
		init: init,
		setView: setView,
		setGugun: setGugun,
		goListPage: goListPage,
		GUGUN_LIST: GUGUN_LIST
	};

})();

function setPharmView(mode, btnEl) {
	document.querySelectorAll(".pvt").forEach(function (b) { b.classList.remove("on"); });
	if (btnEl) btnEl.classList.add("on");
	MedicalAIMap.setView(mode);
}
