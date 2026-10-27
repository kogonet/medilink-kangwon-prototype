<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * faq.jsp
 * @desc    : 메디링크 강원 자주 묻는 질문 (frontMedicalBoard.Faq)
 *            상세페이지 없이 질문 클릭 시 답변이 펼쳐지는 아코디언(details/summary).
 *            카테고리 탭(전체 + categoryList)은 화면에서 필터링 - ?category=카테고리1 로 탭 지정,
 *            ?open=게시글번호 로 해당 질문을 펼친 채 진입(메인 FAQ 영역 링크).
 *            관리자: 게시판관리 > 게시판목록구분 MFAQ 게시판 (카테고리 = BOARD_TYPE)
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>자주 묻는 질문 | 메디링크 강원</title>
<link rel="stylesheet" href="/common/front/kor/css/landing.css">
<link rel="stylesheet" href="/common/front/kor/css/medical_board.css">
</head>
<body>
<main class="mb_main">
	<div class="mb_inner">

		<header class="mb_head">
			<p class="section_label">FAQ</p>
			<h1 class="mb_title">자주 묻는 질문</h1>
			<p class="mb_desc">궁금한 질문을 누르면 답변을 바로 확인할 수 있습니다.</p>
		</header>

		<div class="mb_tabs" role="tablist" aria-label="FAQ 카테고리">
			<button type="button" class="mb_tab" role="tab" data-category="" aria-selected="${empty category}" aria-controls="faqList">전체</button>
			<c:forEach items="${categoryList}" var="cat">
				<button type="button" class="mb_tab" role="tab" data-category="<c:out value="${cat}"/>" aria-selected="${category eq cat}" aria-controls="faqList"><c:out value="${cat}"/></button>
			</c:forEach>
		</div>

		<form id="frm" name="frm" method="GET" action="/front/medical/faq.do">
			<input type="hidden" id="category" name="category" value="<c:out value="${category}"/>"/>
			<div class="mb_toolbar">
				<p class="mb_total">전체 <strong id="faqCount"><fmt:formatNumber value="${TOTAL_NUM}" groupingUsed="true"/></strong>건</p>
				<div class="mb_search" role="search">
					<input type="hidden" name="searchfield" value="ALL"/>
					<label for="searchword" hidden>검색어</label>
					<input type="search" id="searchword" name="searchword" value="<c:out value="${searchword}"/>" placeholder="궁금한 내용을 검색해 보세요">
					<button type="submit">검색</button>
				</div>
			</div>
		</form>

		<div class="mb_faq" id="faqList" role="tabpanel">
			<c:forEach items="${rList}" var="row">
				<details class="mb_faq_item" id="faq_${row.BOARD_NO}" data-category="<c:out value="${row.BOARD_TYPE}"/>">
					<summary class="mb_faq_q">
						<span class="mb_faq_mark" aria-hidden="true">Q</span>
						<span><c:if test="${not empty row.BOARD_TYPE}"><em class="mb_faq_cat"><c:out value="${row.BOARD_TYPE}"/></em></c:if><c:out value="${str:getReverseXSS(row.TITLE)}"/></span>
						<svg class="mb_faq_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
					</summary>
					<div class="mb_faq_a">
						<span class="mb_faq_mark" aria-hidden="true">A</span>
						<div><c:out value="${row.CONTS}" escapeXml="false"/></div>
					</div>
				</details>
			</c:forEach>
			<p class="mb_empty" id="faqEmpty" <c:if test="${not empty rList}">hidden</c:if>>
				<c:choose>
					<c:when test="${not empty searchword}">검색 결과가 없습니다.</c:when>
					<c:otherwise>등록된 질문이 없습니다.</c:otherwise>
				</c:choose>
			</p>
		</div>

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
(function () {
	var tabs = document.querySelectorAll('.mb_tab');
	var items = document.querySelectorAll('.mb_faq_item');
	var countEl = document.getElementById('faqCount');
	var emptyEl = document.getElementById('faqEmpty');
	var categoryInput = document.getElementById('category');

	/* 탭 전환 - 선택한 카테고리 질문만 표시 */
	function selectCategory(category) {
		var shown = 0;
		tabs.forEach(function (tab) {
			tab.setAttribute('aria-selected', tab.getAttribute('data-category') === category ? 'true' : 'false');
		});
		items.forEach(function (item) {
			var visible = category === '' || item.getAttribute('data-category') === category;
			item.hidden = !visible;
			if (!visible) item.open = false;
			if (visible) shown++;
		});
		countEl.textContent = shown.toLocaleString();
		if (items.length > 0) emptyEl.hidden = shown > 0;
		categoryInput.value = category;
	}

	tabs.forEach(function (tab) {
		tab.addEventListener('click', function () {
			selectCategory(tab.getAttribute('data-category'));
		});
	});

	/* 질문 하나를 펼치면 나머지는 접음 */
	items.forEach(function (item) {
		item.addEventListener('toggle', function () {
			if (!item.open) return;
			items.forEach(function (other) {
				if (other !== item) other.open = false;
			});
		});
	});

	selectCategory(categoryInput.value);

	/* ?open=게시글번호 - 메인 FAQ 영역에서 들어온 질문을 펼침 */
	var openNo = new URLSearchParams(location.search).get('open');
	var target = openNo ? document.getElementById('faq_' + openNo) : null;
	if (target) {
		selectCategory('');
		target.open = true;
		target.scrollIntoView({ block: 'center' });
	}
})();
</script>
</body>
</html>
