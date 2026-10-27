<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
/**************************************************
 * hospitalList.jsp
 * @desc    : 의료기관 정보 - 참고소스(docs/html파일소스) panel-pharm 패턴을 의료기관 데이터로 재구성.
 *            지도보기(등급별 마커, VWorld+OpenLayers) / 목록보기(기존 HOSPITAL_LIST 프로시저, 페이징) 토글.
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>의료기관 정보 - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@8.2.0/ol.css">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="wrap">
	<div class="main_area">

		<div class="tab_panel on" id="panel-pharm" style="padding:0">
			<div class="pharm_wrap">
				<div class="pharm_hd">
					<div class="pharm_hd_inner">
						<div class="pharm_title_row">
							<div class="pharm_title">
								<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="var(--primary)" stroke-width="2.5" stroke-linecap="round">
									<path d="M7 17h10l-1.1-6.3A4 4 0 0012 7a4 4 0 00-3.9 3.7L7 17z" />
									<path d="M5 19h14M12 4V2M6.2 6.2L4.8 4.8M17.8 6.2l1.4-1.4" />
								</svg>
								의료기관 정보
								<span class="pharm_cnt_pill" id="pharmCnt">0개</span>
							</div>
							<a class="tp_nav_back" href="/front/medical/index.do">
								<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M15 18l-6-6 6-6" /></svg>
								<span>처음으로</span>
							</a>
						</div>
						<div class="pharm_srch">
							<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--g400)" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7" /><path d="M21 21l-4.35-4.35" /></svg>
							<input class="pharm_inp" id="pharmInp" placeholder="의료기관명 또는 주소 검색…">
						</div>
						<div class="pharm_filters">
							<%@ include file="_gugunFilters.jspf" %>
						</div>
						<div class="pharm_vtabs">
							<button class="pvt on" onclick="setPharmView('map',this)">
								<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6" /><line x1="8" y1="2" x2="8" y2="18" /><line x1="16" y1="6" x2="16" y2="22" /></svg>
								지도 보기
							</button>
							<button class="pvt" onclick="setPharmView('list',this)">
								<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="8" y1="6" x2="21" y2="6" /><line x1="8" y1="12" x2="21" y2="12" /><line x1="8" y1="18" x2="21" y2="18" /><circle cx="3" cy="6" r="1" fill="currentColor" /><circle cx="3" cy="12" r="1" fill="currentColor" /><circle cx="3" cy="18" r="1" fill="currentColor" /></svg>
								목록 보기
							</button>
						</div>
					</div>
				</div>

				<div class="pharm_body">
					<div class="pharm_map_view" id="pharmMapView">
						<div class="pharm_map_left">
							<div id="pharmMapEl"></div>
							<div class="pharm_map_card" id="pharmMapCard">
								<button class="pmc_x" onclick="document.getElementById('pharmMapCard').classList.remove('on')">✕</button>
								<div class="pmc_nm" id="pmcNm"></div>
								<div class="pmc_addr_row">
									<div class="pmc_addr" id="pmcAddr"></div>
									<button type="button" class="pmc_copy" id="pmcCopyBtn">복사</button>
								</div>
								<div class="pmc_row"><a class="pmc_tel" id="pmcTel"></a></div>
							</div>
						</div>
						<div class="pharm_map_sidebar">
							<div class="pms_hd" id="pharmSideHd">전체 0개</div>
							<div class="pms_list" id="pharmSideList"></div>
						</div>
					</div>

					<div class="pharm_list_view" id="pharmListView">
						<div class="pharm_list_inner">
							<div class="pharm_pg">
								<div class="pharm_pg_info" id="pharmPgInfo"></div>
								<div class="pharm_pg_btns">
									<button class="pharm_pg_btn" id="pharmPgPrev">◀ 이전</button>
									<span id="pharmPgIndicator" style="font-size:14px;font-weight:700;color:var(--g600);padding:0 4px"></span>
									<button class="pharm_pg_btn" id="pharmPgNext">다음 ▶</button>
								</div>
							</div>
							<div class="pharm_grid" id="pharmListEl"></div>
						</div>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>

<script src="/common/js/map/medical_map_data.js"></script>
<script src="https://cdn.jsdelivr.net/npm/ol@8.2.0/dist/ol.js"></script>
<script src="/common/front/kor/js/medical_ai_map.js"></script>
<script>
	/* 목록보기: CSS 4열 기준 페이지당 16개(4×4). 변경 시 pageSize만 수정 */
	MedicalAIMap.init({
		gubun: "hospital",
		tileKey: "<c:out value='${vworldTileKey}'/>",
		center: [128.15, 37.7],
		zoom: 8,
		markerColor: getComputedStyle(document.documentElement).getPropertyValue("--primary").trim() || "#004EA2",
		pageSize: 16
	});
</script>
</body>
</html>
