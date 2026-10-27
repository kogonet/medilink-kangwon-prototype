<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * erLive.jsp
 * @desc    : 응급실 LIVE - 국립중앙의료원 실시간 가용병상정보 API 연동.
 *            기관 기본정보(주소/전화/등급)는 tb_ai_emergency, 병상현황(hvec/hvoc/hvicc)만 실시간 API에서 hpid로 매칭.
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>응급실 LIVE - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="wrap">
	<div class="main_area">

		<div class="tab_panel on" id="panel-er">
			<div class="tp_nav">
				<div class="tp_nav_inner">
					<div class="tp_nav_row">
						<div class="tp_nav_title">
							<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="var(--primary)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">
								<path d="M7 17h10l-1.1-6.3A4 4 0 0 0 12 7a4 4 0 0 0-3.9 3.7L7 17Z" />
								<path d="M5 19h14M12 4V2M6.2 6.2 4.8 4.8M17.8 6.2l1.4-1.4" />
							</svg>
							강원도 응급의료기관
							<span class="live_pill">실시간</span>
						</div>
						<div class="tp_nav_actions">
							<a class="tp_nav_back" href="/front/medical/index.do">
								<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M15 18l-6-6 6-6" /></svg>
								<span>처음으로</span>
							</a>
							<button class="er_refresh" onclick="location.reload()">
								<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
									<path d="M1 4v6h6" />
									<path d="M3.51 15a9 9 0 1 0 .49-4.51L1 10" />
								</svg>
								새로고침
							</button>
						</div>
					</div>
				</div>
			</div>
			<div class="tp_body">
				<div class="tp_sub" style="margin-bottom:18px">국립중앙의료원 응급의료정보 API 연동 · 카드 클릭 시 전화 연결</div>

				<c:if test="${!apiOk}">
					<div class="api_notice">
						<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" /></svg>
						실시간 병상 현황을 불러오지 못했습니다. 기관 정보만 표시합니다.
					</div>
				</c:if>

				<c:choose>
					<c:when test="${empty rList}">
						<div class="no_result">표시할 응급의료기관 정보가 없습니다.</div>
					</c:when>
					<c:otherwise>
						<div class="er_grid">
							<c:forEach items="${rList}" var="row">
								<div class="er_card">
									<div class="er_card_top">
										<div class="er_top_row">
											<div class="er_nm"><c:out value="${row.dutyName}" /></div>
											<span class="er_type ${row.lvCls}"><c:out value="${row.dutyEmclsName}" /></span>
										</div>
										<div class="er_tel">
											<svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81 19.79 19.79 0 013 1.18a2 2 0 012-.18h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L9.09 8.91A16 16 0 0015.09 15l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
											<c:out value="${row.dutyTel1}" />
										</div>
										<div class="er_addr"><c:out value="${row.dutyAddr}" /></div>
									</div>
									<div class="er_card_beds">
										<div class="er_beds_lbl">
											가용 병상 현황
											<c:if test="${not empty row.hvidateDisp}"> · <c:out value="${row.hvidateDisp}" /></c:if>
										</div>
										<div class="er_beds">
											<div class="er_bed ${row.hvecClass}"><div class="er_bed_n"><c:out value="${row.hvec}" /></div><div class="er_bed_l">일반응급</div></div>
											<div class="er_bed ${row.hvocClass}"><div class="er_bed_n"><c:out value="${row.hvoc}" /></div><div class="er_bed_l">수술실</div></div>
											<div class="er_bed ${row.hviccClass}"><div class="er_bed_n"><c:out value="${row.hvicc}" /></div><div class="er_bed_l">중증응급</div></div>
										</div>
									</div>
									<div class="er_card_foot">
										<button class="er_btn fill" onclick="location.href='tel:${row.dutyTel1}'">전화 연결</button>
									</div>
								</div>
							</c:forEach>
						</div>
					</c:otherwise>
				</c:choose>
			</div>
		</div>

	</div>
</div>
</body>
</html>
