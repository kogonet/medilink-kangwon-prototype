<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * moon.jsp
 * @desc    : 달빛어린이병원 - 국립중앙의료원 병·의원 찾기 API(달빛어린이병원 목록정보) 연동.
 *            강원도엔 3곳뿐이라 DB 저장 없이 요청마다 API를 그대로 호출(라이브 프록시).
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>달빛어린이병원 - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="wrap">
	<div class="main_area">

		<div class="tab_panel on" id="panel-moon">
			<div class="tp_nav">
				<div class="tp_nav_inner">
					<div class="tp_nav_row">
						<div class="tp_nav_title">
							<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="var(--primary)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">
								<path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" />
								<path d="M17 5v4M15 7h4" />
							</svg>
							달빛어린이병원
						</div>
						<div class="tp_nav_actions">
							<a class="tp_nav_back" href="/front/medical/index.do">
								<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M15 18l-6-6 6-6" /></svg>
								<span>처음으로</span>
							</a>
						</div>
					</div>
				</div>
			</div>
			<div class="tp_body">
				<div class="tp_hd">
					<div class="tp_sub" style="margin-bottom:18px">국립중앙의료원 병·의원 찾기 API 연동 · 평일 야간·주말 소아청소년과 진료 가능 병원</div>
				</div>

				<c:if test="${!apiOk}">
					<div class="api_notice">
						<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" /></svg>
						달빛어린이병원 목록을 불러오지 못했습니다.
					</div>
				</c:if>

				<c:choose>
					<c:when test="${empty babyList}">
						<div class="no_result">표시할 달빛어린이병원 정보가 없습니다.</div>
					</c:when>
					<c:otherwise>
						<div class="moon_grid">
							<c:forEach items="${babyList}" var="h">
								<div class="moon_card">
									<div class="mc_top">
										<div class="mc_top_row">
											<div class="mc_nm"><c:out value="${h.dutyName}" /></div>
											<span class="mc_status ${h.statusCls}"><c:out value="${h.statusLabel}" /></span>
										</div>
										<c:if test="${not empty h.dutyTel1}">
											<div class="mc_tel">
												<svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81 19.79 19.79 0 013 1.18a2 2 0 012-.18h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L9.09 8.91A16 16 0 0015.09 15l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
												<c:out value="${h.dutyTel1}" />
											</div>
										</c:if>
										<div class="mc_addr"><c:out value="${h.dutyAddr}" /></div>
									</div>
									<div class="mc_info">
										<div class="mc_info_lbl">야간 진료 정보</div>
										<div class="mc_info_grid">
											<div class="mc_info_box">
												<div class="mc_info_n"><c:out value="${h.region}" /></div>
												<div class="mc_info_l">지역</div>
											</div>
											<div class="mc_info_box">
												<div class="mc_info_n"><c:out value="${h.timeStr}" /></div>
												<div class="mc_info_l">오늘 진료시간</div>
											</div>
										</div>
									</div>
									<div class="mc_foot">
										<button class="mc_call" onclick="location.href='tel:${h.dutyTel1}'">전화 연결</button>
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
