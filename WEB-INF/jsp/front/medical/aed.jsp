<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * aed.jsp
 * @desc    : AED 위치 - hospitalList.jsp와 동일한 지도보기(등급 없음, 단일 마커색)/목록보기 토글 패턴.
 *            tb_ai_aed는 admMapDataExport 배치가 gubun="aed"로 medical_map_data.js에 함께 내보내고,
 *            지도/목록 렌더링은 공용 MedicalAIMap 모듈이 그대로 처리한다(08-19, 리스트 전용에서 전환).
 *            08-19 이전 리스트 전용 버전은 aed.jsp_bak20260819(지도없음) 참고.
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>AED 위치 - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@8.2.0/ol.css">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="wrap">
	<div class="main_area">

		<div class="tab_panel on" id="panel-aed" style="padding:0">
			<div class="pharm_wrap">
				<div class="pharm_hd">
					<div class="pharm_hd_inner">
						<div class="pharm_title_row">
							<div class="pharm_title">
								<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="var(--primary)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
									<path d="M20.8 5.7a5.4 5.4 0 0 0-7.6 0L12 6.9l-1.2-1.2a5.4 5.4 0 0 0-7.6 7.6L12 22l8.8-8.7a5.4 5.4 0 0 0 0-7.6Z" />
									<path d="m13 7-4 6h4l-2 5 5-7h-4l1-4Z" />
								</svg>
								자동심장충격기 (AED)
								<span class="pharm_cnt_pill" id="pharmCnt">0개</span>
							</div>
							<a class="tp_nav_back" href="/front/medical/index.do">
								<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M15 18l-6-6 6-6" /></svg>
								<span>처음으로</span>
							</a>
						</div>
						<div class="pharm_srch">
							<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--g400)" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7" /><path d="M21 21l-4.35-4.35" /></svg>
							<input class="pharm_inp" id="pharmInp" placeholder="설치기관명 또는 주소 검색…">
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
								<div class="pmc_place" id="pmcPlace"></div>
								<div class="pmc_row"><a class="pmc_tel" id="pmcTel"></a><span class="pmc_hr" id="pmcHours"></span></div>
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
	MedicalAIMap.init({
		gubun: "aed",
		tileKey: "<c:out value='${vworldTileKey}'/>",
		center: [128.15, 37.7],
		zoom: 8,
		markerColor: getComputedStyle(document.documentElement).getPropertyValue("--primary").trim() || "#004EA2"
	});
</script>
</body>
</html>
