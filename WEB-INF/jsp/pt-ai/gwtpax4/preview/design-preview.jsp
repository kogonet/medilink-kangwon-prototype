<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  AI 상담4 답변 디자인 미리보기 틀 (관리자 /admmgr/ai4/design.do 안의 iframe, Ai4DesignAdmin.previewFrame, 2026-10-16).
  관리자 화면 CSS 와 섞이지 않게 상담 화면과 같은 답변 스타일(ai-answer-style.jsp)과 렌더링 스크립트로 따로 그린다.
  부모 화면이 postMessage 로 편집 중인 값을 보내면 /admmgr/ai4/designPreview.do 로 미리보기 답변과 CSS 를 받아 그린다.
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex">
  <title>답변 디자인 미리보기</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
  <link rel="stylesheet" href="${ptAiWebPath}/common/css/ai-consult.css">
  <%@ include file="../main/ai-answer-style.jsp" %>
  <style>
    html, body { margin: 0; background: #EEF1F7; }
    body { padding: 12px; font-family: "Pretendard Variable", "Malgun Gothic", sans-serif; color: #1B2A4E; }
    .dp-nav { position: sticky; top: 0; z-index: 2; display: flex; flex-wrap: wrap; gap: 6px; padding: 8px 0 10px; background: #EEF1F7; }
    .dp-nav a { padding: 4px 10px; border: 1px solid #C9D3EA; border-radius: 999px; background: #fff; color: #3D4759; font-size: 12px; text-decoration: none; }
    .dp-status { margin: 0 0 10px; font-size: 13px; color: #5A6A8C; }
    .dp-status.is-error { color: #C92A2A; font-weight: 700; }
    .dp-card { margin: 0 0 16px; padding: 18px 20px; border-radius: 16px; background: #fff; box-shadow: 0 1px 3px rgba(16, 24, 40, .06); }
    .dp-card > h2 { margin: 0 0 10px; font-size: 12px; font-weight: 700; color: #5A6A8C; }
    .dp-card > .dp-err { color: #C92A2A; font-size: 13px; }
    /* 대표 답변 바로가기 칩: 이름표·지금 보는 답변·이동한 카드 깜빡임 (design-preview.js) */
    .dp-nav__label { align-self: center; margin-right: 2px; color: #5A6A8C; font-size: 11px; font-weight: 700; }
    .dp-nav a:hover { border-color: #4C6EF5; color: #3B5BDB; }
    .dp-nav a.is-on { border-color: #1B2A4E; background: #1B2A4E; color: #fff; font-weight: 700; }
    .dp-card.is-flash { animation: dp-card-flash .45s ease-in-out 3; }
    @keyframes dp-card-flash { 50% { box-shadow: 0 0 0 3px #4C6EF5; } }
    /* 편집 화면 연동 덮개 (design-preview.js): 마우스 대상 점선·고른 대상 테두리·이름표. 답변 DOM 은 건드리지 않는다 */
    #samples { cursor: pointer; }
    /* z-index 1: 위쪽 고정 답변 이동 버튼 줄(.dp-nav, z-index 2)보다 아래 */
    .dp-ov { position: absolute; left: 0; top: 0; width: 0; height: 0; z-index: 1; pointer-events: none; }
    .dp-ov > div { position: absolute; box-sizing: border-box; pointer-events: none; }
    .dp-ov__hover { border: 2px dashed #4C6EF5; border-radius: 6px; background: rgba(76, 110, 245, .05); }
    .dp-ov__sel { border: 2px solid #E8590C; border-radius: 6px; box-shadow: 0 0 0 3px rgba(232, 89, 12, .18); }
    .dp-ov__sel.is-soft { border: 1px dashed #E8590C; box-shadow: none; }
    .dp-ov__sel.is-flash { animation: dp-flash .45s ease-in-out 3; }
    @keyframes dp-flash { 50% { background: rgba(232, 89, 12, .16); } }
    .dp-ov__tag { padding: 0 8px; border-radius: 4px; background: #1B2A4E; color: #fff; font-size: 11px; line-height: 20px; white-space: nowrap; }
    .dp-ov__badge { margin-left: 6px; padding: 0 5px; border-radius: 3px; background: #C92A2A; }
    /* 클릭 위치 메뉴 (문구 / 디자인 고르기). 위쪽 답변 이동 버튼 줄(.dp-nav z-index 2) 위에 뜬다 */
    .dp-menu { position: absolute; z-index: 10; min-width: 220px; max-width: 320px; padding: 6px 0; border: 1px solid #C9D3EA; border-radius: 10px; background: #fff; box-shadow: 0 8px 24px rgba(16, 24, 40, .18); font-size: 12px; color: #1B2A4E; }
    .dp-menu__head { display: flex; align-items: center; gap: 6px; padding: 4px 12px 8px; border-bottom: 1px solid #E3E8F2; font-weight: 700; }
    .dp-menu__head .dp-ov__badge { margin-left: auto; color: #fff; font-size: 11px; font-weight: 600; }
    .dp-menu__sec { padding: 8px 12px 2px; color: #5A6A8C; font-size: 11px; font-weight: 700; }
    .dp-menu__item { display: flex; align-items: center; gap: 6px; width: 100%; padding: 6px 12px 6px 22px; border: 0; background: none; color: #1B2A4E; font: inherit; text-align: left; cursor: pointer; }
    .dp-menu__item:hover, .dp-menu__item:focus-visible { background: #EEF2FF; outline: none; }
    .dp-menu__item code { margin-left: auto; color: #8A93A6; font-size: 11px; }
    .dp-menu__prot { padding: 0 4px; border-radius: 3px; background: #FFE3E3; color: #C92A2A; font-size: 10px; font-weight: 700; }
    .dp-menu__none { padding: 4px 12px 6px 22px; color: #8A93A6; }
  </style>
  <%-- 퍼블리셔 템플릿 (방식 2): 미리보기에서 "퍼블리셔 템플릿 사용" 체크일 때만 켠다 (media 로 끄고 켬, design-preview.js) --%>
  <c:forEach var="u" items="${publisher.cssUrls}"><link rel="stylesheet" href="${ctx}${u}?v=<c:out value='${publisher.hash}'/>" media="not all" data-publisher-css></c:forEach>
  <%-- 편집 중인 디자인 CSS (서버가 검사한 값으로 만든 것) --%>
  <style id="draft-css"></style>
</head>
<body data-api="${ctx}/admmgr/ai4/designPreview.do">
  <nav class="dp-nav" id="nav" aria-label="미리보기 답변"></nav>
  <p class="dp-status" id="status">미리보기를 누르면 편집 중인 문구와 디자인으로 대표 답변을 보여 드립니다.</p>
  <div id="samples"></div>

  <%-- 퍼블리셔 템플릿 (방식 2, PublisherSet 이 검사한 블록 틀). answer-blocks.js 가 DOMPurify 로 한 번 더 거른 뒤 쓴다 --%>
  <div id="ai4-publisher" hidden data-on="0" data-asset-base="${ctx}/pt-ai/gwtpax4/answer-assets/"><c:forEach var="t" items="${publisher.templates}"><template data-ab-block="<c:out value='${t.type}'/>">${t.html}</template></c:forEach></div>
  <script>window.PT_AI_BOOT = { moduleId: "gwtpax4-preview" };</script>
  <script src="https://cdn.jsdelivr.net/npm/markdown-it@14.1.0/dist/markdown-it.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/dompurify@3.1.6/dist/purify.min.js"></script>
  <script src="${ctx}/pt-ai/gwtpax4/js/ai-core4.js"></script>
  <script src="${ctx}/pt-ai/gwtpax4/js/answer-blocks.js"></script>
  <script src="${ctx}/pt-ai/gwtpax4/js/answer-fold.js"></script>
  <script src="${ctx}/pt-ai/gwtpax4/js/design-preview.js"></script>
</body>
</html>
