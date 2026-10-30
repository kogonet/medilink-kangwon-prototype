<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib prefix="page" uri="http://www.opensymphony.com/sitemesh/page"%>
<%
/**************************************************
 * default_medical_sub.jsp
 * @desc    : 메디링크 강원 서브페이지 데코레이터 (/front/medical/*.* - index 제외)
 *            흰 배경 헤더 - 좌측 컬러 로고(medilink-bi.svg) / 가운데 서비스 소개·의료 서비스·AI 상담·공지사항·FAQ
 *            헤더 아래 본문이 남은 높이를 채움 (gm_layout_solid)
 *            메인은 default_medical.jsp 사용
 *            스타일: /common/front/kor/css/medical_header.css
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><decorator:title default="메디링크 강원"/></title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css">
<decorator:head/>
<link rel="stylesheet" href="/common/front/kor/css/medical_header.css">
</head>
<body class="gm_layout_solid <decorator:getProperty property="body.class"/>">

<!-- ====================== 헤더 ====================== -->
<header class="gm_header" id="gmHeader">
	<div class="gm_header_inner">
		<a class="gm_brand" href="/front/medical/index.do" aria-label="메디링크 강원 홈">
			<img class="gm_brand_logo" src="/common/front/kor/images/medilink-bi.svg" alt="메디링크 강원 MediLink Kangwon">
		</a>
		<nav class="gm_nav" id="gmNav" aria-label="주요 메뉴">
			<a href="/front/medical/project.do">서비스 소개</a>
			<a href="/front/medical/index.do#services">의료 서비스</a>
			<a href="/front/medical/index.do#ai">AI 상담</a>
			<a href="/front/medical/noticeList.do">공지사항</a>
			<a href="/front/medical/faq.do">FAQ</a>
		</nav>
		<%-- 2026-10-22 AI 상담5 팝업 전용 화면(gwtpax5 ai-consult-popup.jsp)으로 연결. 이전: /gwtpax/ai-consult3-popup.do (2026-10-21), 기존: /gwtpax/ai-consult.do --%>
		<a class="gm_cta" href="/gwtpax/ai-consult5-popup.do" target="_blank" rel="noopener" title="AI 상담 (새 창)">AI에게 물어보기</a>
		<button class="gm_menu_btn" id="gmMenuBtn" type="button" aria-label="메뉴 열기" aria-expanded="false" aria-controls="gmNav">
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
				<path d="M4 5h16M4 12h16M4 19h16"/>
			</svg>
		</button>
	</div>
</header>
<!-- //헤더 -->

<decorator:body/>

<script>
(function() {
	var header = document.getElementById('gmHeader');
	var btn = document.getElementById('gmMenuBtn');
	if (!header || !btn) return;
	var cta = header.querySelector('.gm_cta');
	if (cta) {
		cta.addEventListener('click', function(event) {
			var w = Math.min(1280, screen.availWidth);
			var h = Math.min(900, screen.availHeight);
			var l = (screen.availLeft || 0) + (screen.availWidth - w) / 2;
			var t = (screen.availTop || 0) + (screen.availHeight - h) / 2;
			var popup = window.open(cta.href, 'medilink_ai_popup',
				'width=' + w + ',height=' + h + ',left=' + l + ',top=' + t + ',scrollbars=yes,resizable=yes');
			if (!popup) return;
			event.preventDefault();
			popup.focus();
		});
	}
	function setMenu(open) {
		header.classList.toggle('is_open', open);
		btn.setAttribute('aria-expanded', open ? 'true' : 'false');
		btn.setAttribute('aria-label', open ? '메뉴 닫기' : '메뉴 열기');
	}
	btn.addEventListener('click', function(event) {
		event.stopPropagation();
		setMenu(!header.classList.contains('is_open'));
	});
	document.getElementById('gmNav').addEventListener('click', function(event) {
		if (event.target.closest('a')) setMenu(false);
	});
	document.addEventListener('click', function(event) {
		if (!header.contains(event.target)) setMenu(false);
	});
	document.addEventListener('keydown', function(event) {
		if (event.key === 'Escape') setMenu(false);
	});
})();
</script>
</body>
</html>
