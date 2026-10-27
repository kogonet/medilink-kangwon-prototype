<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * noticeList.jsp
 * @desc    : 메디링크 강원 공지사항 - 목록 (frontMedicalBoard.NoticeList)
 *            헤더는 데코레이터 default_medical_sub.jsp. 상위고정(fixList)은 매 페이지 맨 위에 노출.
 *            관리자: 게시판관리 > 게시판목록구분 MNOTICE 게시판
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>공지사항 | 메디링크 강원</title>
<link rel="stylesheet" href="/common/front/kor/css/landing.css">
<link rel="stylesheet" href="/common/front/kor/css/medical_board.css">
</head>
<body>
<main class="mb_main">
	<div class="mb_inner">

		<header class="mb_head">
			<p class="section_label">Notice</p>
			<h1 class="mb_title">공지사항</h1>
			<p class="mb_desc">메디링크 강원의 새로운 소식과 서비스 안내를 확인하세요.</p>
		</header>

		<form id="frm" name="frm" method="GET" action="/front/medical/noticeList.do">
			<input type="hidden" id="page" name="page" value="<c:out value="${param.page}"/>"/>
			<div class="mb_toolbar">
				<p class="mb_total">전체 <strong><fmt:formatNumber value="${TOTAL_NUM + fn:length(fixList)}" groupingUsed="true"/></strong>건</p>
				<div class="mb_search" role="search">
					<label for="searchfield" hidden>검색 조건</label>
					<select id="searchfield" name="searchfield">
						<option value="ALL">전체</option>
						<option value="TITLE" ${searchfield eq 'TITLE' ? "selected='selected'" : ""}>제목</option>
						<option value="CONTS" ${searchfield eq 'CONTS' ? "selected='selected'" : ""}>내용</option>
					</select>
					<label for="searchword" hidden>검색어</label>
					<input type="search" id="searchword" name="searchword" value="<c:out value="${searchword}"/>" placeholder="검색어를 입력해 주세요">
					<button type="submit" onclick="document.getElementById('page').value='1';">검색</button>
				</div>
			</div>
		</form>

		<div class="mb_list">
			<div class="mb_row mb_list_head" aria-hidden="true">
				<span class="mb_no">번호</span>
				<span>제목</span>
				<span class="mb_date">등록일</span>
				<span class="mb_hit">조회</span>
			</div>

			<%-- 상위고정 --%>
			<c:forEach items="${fixList}" var="row">
				<a class="mb_row is_fixed" href="/front/medical/noticeView.do?boardNo=${row.BOARD_NO}">
					<span class="mb_no"><em class="mb_fix_badge">고정</em></span>
					<span class="mb_subject">
						<span class="mb_subject_text"><c:out value="${str:getReverseXSS(row.TITLE)}"/></span>
						<c:if test="${row.IS_NEW}"><em class="new_badge">NEW</em></c:if>
						<c:if test="${not empty row.FILE_NO_1}"><svg class="mb_clip" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-label="첨부파일"><path d="m21.4 11.1-9.2 9.2a6 6 0 0 1-8.5-8.5l9.2-9.2a4 4 0 0 1 5.7 5.7l-9.2 9.2a2 2 0 0 1-2.8-2.8l8.5-8.5"/></svg></c:if>
					</span>
					<time class="mb_date" datetime="${fn:replace(row.REG_DATE, '.', '-')}"><c:out value="${row.REG_DATE}"/></time>
					<span class="mb_hit"><fmt:formatNumber value="${row.READ_CNT}" groupingUsed="true"/></span>
				</a>
			</c:forEach>

			<%-- 일반 --%>
			<c:forEach items="${rList}" var="row" varStatus="status">
				<a class="mb_row" href="/front/medical/noticeView.do?boardNo=${row.BOARD_NO}">
					<span class="mb_no"><fmt:formatNumber value="${PAGING_NUM - status.index}" groupingUsed="true"/></span>
					<span class="mb_subject">
						<span class="mb_subject_text"><c:out value="${str:getReverseXSS(row.TITLE)}"/></span>
						<c:if test="${row.IS_NEW}"><em class="new_badge">NEW</em></c:if>
						<c:if test="${not empty row.FILE_NO_1}"><svg class="mb_clip" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-label="첨부파일"><path d="m21.4 11.1-9.2 9.2a6 6 0 0 1-8.5-8.5l9.2-9.2a4 4 0 0 1 5.7 5.7l-9.2 9.2a2 2 0 0 1-2.8-2.8l8.5-8.5"/></svg></c:if>
					</span>
					<time class="mb_date" datetime="${fn:replace(row.REG_DATE, '.', '-')}"><c:out value="${row.REG_DATE}"/></time>
					<span class="mb_hit"><fmt:formatNumber value="${row.READ_CNT}" groupingUsed="true"/></span>
				</a>
			</c:forEach>

			<c:if test="${empty fixList and empty rList}">
				<p class="mb_empty">
					<c:choose>
						<c:when test="${not empty searchword}">검색 결과가 없습니다.</c:when>
						<c:otherwise>등록된 공지사항이 없습니다.</c:otherwise>
					</c:choose>
				</p>
			</c:if>
		</div>

		<nav class="mb_paging" aria-label="페이지 이동"><c:out value="${PAGING_HTML}" escapeXml="false"/></nav>

	</div>
</main>

<%-- 푸터 - 메인(index.jsp)과 동일 마크업 --%>
<footer class="footer_wrap">
	<div class="footer_inner">
		<div class="footer_left">
			<a class="footer_bi" href="/front/medical/index.do"><img src="/common/front/kor/images/medilink-bi-white.svg" alt="메디링크 강원 MediLink Kangwon"></a>
			<nav class="footer_nav" aria-label="하단 메뉴">
				<a href="/front/medical/terms.do">이용약관</a>
				<a href="/front/medical/intro.do">회사소개</a>
				<a href="/front/medical/info.do">정보공개</a>
				<a href="/front/medical/project.do">사업소개</a>
				<a href="/front/medical/directions.do">찾아오시는길</a>
			</nav>
		</div>
		<div class="footer_right">
			<p>주식회사 코고네트웍스 · 한국글로벌헬스케어사업협동조합 사업 자회사</p>
			<p class="footer_copy">&copy; MediLink Kangwon. All rights reserved.</p>
		</div>
		<p class="footer_note">본 서비스의 모든 정보는 국가 공공데이터를 기반으로 하며, 의료적 판단의 최종 결정은 반드시 의료 전문가와 상의하시기 바랍니다.</p>
	</div>
</footer>

<script>
	/* Paging.get_paging_front_post 가 만드는 링크(javascript:G_MovePage(n)) 처리 */
	function G_MovePage(page) {
		document.getElementById('page').value = page;
		document.getElementById('frm').submit();
	}
</script>
</body>
</html>
