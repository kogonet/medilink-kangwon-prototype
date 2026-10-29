<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib prefix="page" uri="http://www.opensymphony.com/sitemesh/page"%>
<%
/**************************************************
 * default_medical.jsp
 * @desc    : 메디링크 강원 메인 데코레이터 (/index.do, /front/medical/index.do)
 *            히어로 위 투명 헤더 - 좌측 흰색 로고(medilink-bi-white.svg) / 가운데 서비스 소개·의료 서비스·AI 상담·공지사항·FAQ
 *            서브페이지는 default_medical_sub.jsp 사용
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
<%-- [리뉴얼 옵트인] 기본 off = 현재 화면 유지.
     켜는 법: 헤더의 "리뉴얼" 토글(쿠키 renewal=1 저장) 또는 ?renewal=1 (?renewal=0 은 강제 off).
     적용 확정 시 renewalDefault 를 true, 토글 노출은 renewalToggle 을 false 로 변경. 롤백은 renewalDefault=false. --%>
<c:set var="renewalDefault" value="false"/>
<c:set var="renewalToggle" value="true"/>
<c:if test="${renewalToggle}">
<link rel="stylesheet" href="/common/front/kor/css/renewal-toggle.css">
</c:if>
<c:set var="rnOn" value="${param.renewal eq '1' or (param.renewal ne '0' and (renewalDefault or cookie.renewal.value eq '1'))}"/>
<c:if test="${rnOn}">
<link rel="stylesheet" href="/common/front/kor/css/renewal-main.css">
<script src="/common/front/kor/js/renewal-main.js" defer></script>
</c:if>
</head>
<body class="gm_layout_overlay <decorator:getProperty property="body.class"/>">

<!-- ====================== 헤더 ====================== -->
<header class="gm_header is_overlay" id="gmHeader">
	<div class="gm_header_inner">
		<a class="gm_brand" href="#top" aria-label="메디링크 강원 홈">
			<img class="gm_brand_logo" src="/common/front/kor/images/medilink-bi-white.svg" alt="메디링크 강원 MediLink Kangwon">
		</a>
		<%-- [리뉴얼 메뉴] 좌측=홈 섹션(스크롤), 우측 유틸리티=사업소개(페이지 이동). 현재 메뉴는 renewal off 일 때 그대로 유지 --%>
		<c:if test="${rnOn}">
		<nav class="gm_nav" id="gmNav" aria-label="주요 메뉴">
			<a href="#services">의료 서비스</a>
			<a href="#ai">AI 상담</a>
			<a href="#notice">공지·FAQ</a>
			<a class="gm_nav_biz" href="/front/medical/project.do">사업소개</a>
		</nav>
		</c:if>
		<c:if test="${not rnOn}">
		<nav class="gm_nav" id="gmNav" aria-label="주요 메뉴">
			<a href="/front/medical/project.do">서비스 소개</a>
			<a href="#services">의료 서비스</a>
			<a href="#ai">AI 상담</a>
			<a href="/front/medical/noticeList.do">공지사항</a>
			<a href="/front/medical/faq.do">FAQ</a>
		</nav>
		</c:if>
		<c:if test="${renewalToggle or rnOn}"><div class="gm_actions"></c:if>
		<c:if test="${renewalToggle}">
		<%-- 리뉴얼 옵트인 토글(테스트용): 좌 현재 / 우 리뉴얼. 쿠키 renewal 에 0/1 저장 후 새로고침 --%>
		<button class="gm_rn_toggle" id="gmRnToggle" type="button" role="switch" aria-checked="false" aria-label="리뉴얼 화면 보기"><span class="gm_rn_opt">현재</span><span class="gm_rn_opt">리뉴얼</span><span class="gm_rn_knob" aria-hidden="true"></span></button>
		</c:if>
		<c:if test="${rnOn}"><a class="gm_biz" href="/front/medical/project.do">사업소개 <span aria-hidden="true">↗</span></a></c:if>
		<%-- 2026-10-22 AI 상담5 팝업 전용 화면(gwtpax5 ai-consult-popup.jsp)으로 연결. 이전: /gwtpax/ai-consult3-popup.do (2026-10-21), 기존: /gwtpax/ai-consult.do --%>
		<a class="gm_cta" href="/gwtpax/ai-consult5-popup.do" target="_blank" rel="noopener" title="AI 상담 (새 창)">AI에게 물어보기</a>
		<c:if test="${renewalToggle or rnOn}"></div></c:if>
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
	var rn = document.getElementById('gmRnToggle');
	if (rn) {
		var on = !!document.querySelector('link[href*="renewal.css"],link[href*="renewal-main.css"]');
		rn.setAttribute('aria-checked', on ? 'true' : 'false');
		rn.addEventListener('click', function() {
			document.cookie = 'renewal=' + (on ? '0' : '1') + '; path=/; max-age=31536000; SameSite=Lax';
			var u = new URL(location.href); u.searchParams.set('renewal', on ? '0' : '1'); /* 쿠키 미지원 환경 대비: 현재 페이지는 파라미터로도 즉시 전환 */
			location.href = u.toString();
		});
	}
	if (document.querySelector('link[href*="renewal.css"],link[href*="renewal-main.css"]')) {
		header.querySelectorAll('.gm_biz, .gm_nav_biz').forEach(function(a) { if (a.pathname === location.pathname) a.setAttribute('aria-current', 'page'); });
		var spy = [].slice.call(header.querySelectorAll('.gm_nav a[href^="#"]')).map(function(a) { return {a: a, s: document.querySelector(a.getAttribute('href'))}; }).filter(function(x) { return x.s; });
		if (spy.length && 'IntersectionObserver' in window) {
			var io = new IntersectionObserver(function(es) {
				es.forEach(function(e) { var t = spy.filter(function(x) { return x.s === e.target; })[0]; if (t) { if (e.isIntersecting) t.a.setAttribute('aria-current', 'location'); else t.a.removeAttribute('aria-current'); } });
			}, {rootMargin: '-45% 0px -50% 0px'});
			spy.forEach(function(x) { io.observe(x.s); });
		}
	}
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
	function setScrolled() {
		header.classList.toggle('is_scrolled', window.pageYOffset > 40);
	}
	window.addEventListener('scroll', setScrolled, { passive: true });
	setScrolled();
})();
</script>
</body>
</html>
