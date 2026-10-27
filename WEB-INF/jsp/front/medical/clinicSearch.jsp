<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * clinicSearch.jsp
 * @desc    : 진료과 검색 - _sidebar.jspf의 iframe 모달(.mbox > .mhd + ✕닫기) 안에 그대로 끼워지는
 *            콘텐츠 페이지. 모달 제목/닫기 버튼은 부모 페이지(_sidebar.jspf)가 이미 그려주므로
 *            이 페이지엔 그 헤더를 또 넣지 않고, 참고소스(docs/강원ai/js/app.js의 openSpecSearch())의
 *            .mbody 부분만 그대로 서버 렌더링으로 재현한다(08-19, 처음으로 버튼 있던 tp_nav 제거).
 *            필터/페이징은 전부 <a href>/<form> GET이라 JS 템플릿 리터럴이 없음(JSP EL과 충돌 없음).
 *            직접 URL 접속 시엔 모달 헤더 없이 이 내용만 보임(의도된 동작).
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>진료과 검색 - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="mbody spec_body">

	<form id="clinicForm" method="get" action="/front/medical/clinicSearch.do">
		<input type="hidden" name="clinicNm" value="<c:out value="${clinicNm}"/>">
		<input type="hidden" name="sgguNm" value="<c:out value="${sgguNm}"/>">
		<div class="spec_search" style="display:flex;gap:8px;align-items:center">
			<div class="doc_sinp" style="flex:1;margin-bottom:0">
				<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--g400)" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.35-4.35"/></svg>
				<input type="text" name="searchword" value="<c:out value="${searchword}"/>" placeholder="병원명 또는 진료과 검색…">
			</div>
			<button type="submit" class="dtb on" style="flex-shrink:0">검색</button>
			<c:if test="${not empty searchword}">
				<c:url var="urlClearSearch" value="/front/medical/clinicSearch.do">
					<c:if test="${not empty clinicNm}"><c:param name="clinicNm" value="${clinicNm}"/></c:if>
					<c:if test="${not empty sgguNm}"><c:param name="sgguNm" value="${sgguNm}"/></c:if>
				</c:url>
				<a class="dtb" style="flex-shrink:0" href="${urlClearSearch}">전체보기</a>
			</c:if>
		</div>
	</form>

	<div class="spec_layout">
		<div class="dtab spec_dept_nav">
			<c:url var="urlAllDept" value="/front/medical/clinicSearch.do">
				<c:if test="${not empty sgguNm}"><c:param name="sgguNm" value="${sgguNm}"/></c:if>
				<c:if test="${not empty searchword}"><c:param name="searchword" value="${searchword}"/></c:if>
			</c:url>
			<a class="dtb ${empty clinicNm ? 'on' : ''}" href="${urlAllDept}">전체</a>
			<c:forEach items="${deptList}" var="dept">
				<c:url var="urlDept" value="/front/medical/clinicSearch.do">
					<c:param name="clinicNm" value="${dept}"/>
					<c:if test="${not empty sgguNm}"><c:param name="sgguNm" value="${sgguNm}"/></c:if>
					<c:if test="${not empty searchword}"><c:param name="searchword" value="${searchword}"/></c:if>
				</c:url>
				<a class="dtb ${clinicNm eq dept ? 'on' : ''}" href="${urlDept}"><c:out value="${dept}"/></a>
			</c:forEach>
		</div>
		<div class="spec_results">
			<div class="dtab spec_dist_nav">
				<c:url var="urlAllSggu" value="/front/medical/clinicSearch.do">
					<c:if test="${not empty clinicNm}"><c:param name="clinicNm" value="${clinicNm}"/></c:if>
					<c:if test="${not empty searchword}"><c:param name="searchword" value="${searchword}"/></c:if>
				</c:url>
				<a class="dtb ${empty sgguNm ? 'on' : ''}" href="${urlAllSggu}">전체지역</a>
				<c:forEach items="${sgguList}" var="g">
					<c:url var="urlSggu" value="/front/medical/clinicSearch.do">
						<c:if test="${not empty clinicNm}"><c:param name="clinicNm" value="${clinicNm}"/></c:if>
						<c:param name="sgguNm" value="${g}"/>
						<c:if test="${not empty searchword}"><c:param name="searchword" value="${searchword}"/></c:if>
					</c:url>
					<a class="dtb ${sgguNm eq g ? 'on' : ''}" href="${urlSggu}"><c:out value="${g}"/></a>
				</c:forEach>
			</div>

			<div class="spec_cnt">검색결과 <fmt:formatNumber value="${TOTAL_NUM}" groupingUsed="true"/>개<c:if test="${limitExceeded}"> (상위 100개 표시)</c:if></div>

			<c:choose>
				<c:when test="${empty rList}">
					<div class="no_result">검색 결과가 없습니다.</div>
				</c:when>
				<c:otherwise>
					<div class="spec_list">
						<c:forEach items="${rList}" var="h">
							<div class="ditem" style="cursor:default">
								<div style="flex:1;min-width:0">
									<div style="display:flex;align-items:center;gap:7px;margin-bottom:3px">
										<span style="font-size:15px;font-weight:800;color:var(--g900)"><c:out value="${h.yadmNm}"/></span>
										<span style="font-size:12px;padding:1px 6px;border-radius:4px;background:var(--primary);color:#fff;white-space:nowrap"><c:out value="${h.clCdNm}"/></span>
									</div>
									<div style="font-size:14px;color:var(--g500);margin-bottom:4px"><c:out value="${h.addr}"/></div>
									<div style="display:flex;align-items:center;gap:10px">
										<c:if test="${not empty h.telno}">
											<a href="tel:${h.telno}" style="font-size:14px;color:var(--teal);font-weight:700;text-decoration:none"><c:out value="${h.telno}"/></a>
										</c:if>
										<c:if test="${not empty h.drTotCnt}">
											<span style="font-size:14px;color:var(--g400)">의사 <c:out value="${h.drTotCnt}"/>명</span>
										</c:if>
									</div>
									<div style="font-size:13px;color:var(--g400);margin-top:4px"><c:out value="${h.clinicNames}"/></div>
								</div>
							</div>
						</c:forEach>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>

</div>
</body>
</html>
