<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>메디링크 강원 · AI 상담이 답을 만드는 과정</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400&family=IBM+Plex+Sans+KR:wght@400;500;700&display=swap">
  <link rel="stylesheet" href="${ctx}/pt-ai/gwtpax3/css/ai-flow.css">
</head>
<body>
  <main class="fl-wrap" id="flow" data-api="<c:out value='${apiBase}'/>">
    <p class="fl-brand"><strong>메디링크 강원</strong> AI 상담</p>
    <h1 class="fl-title">질문 하나가 답이 되기까지</h1>
    <p class="fl-lead">질문을 보내면 화면, 서버(Java), AI, 데이터베이스가 각각 무엇을 하는지 실제 걸린 시간 그대로 그려 보여 드립니다.
      막대를 누르면 그 순간 오간 내용을 볼 수 있습니다.</p>

    <form class="fl-ask" id="flAsk">
      <label for="flQ" class="sr-only" style="position:absolute;left:-9999px">질문</label>
      <textarea id="flQ" maxlength="300" rows="2" placeholder="예: 원주 피부과 알려줘">내가 배가 아픈데, 강원특별자치도 춘천시 중앙로 1 (봉의동)에 있는 감기 잘 하는 병원 알려줘</textarea>
      <button type="submit" class="fl-btn" id="flRun">보내고 지켜보기</button>
    </form>
    <ul class="fl-samples" aria-label="예시 질문">
      <li><button type="button">원주 피부과 알려줘</button></li>
      <li><button type="button">강원도 강릉시 약국 알려줘</button></li>
      <li><button type="button">횡성군에서 가장 크고 소아청소년과가 있는 병원</button></li>
      <li><button type="button">당뇨에 대해 알려줘</button></li>
      <li><button type="button">그중에 인증 받은 곳은?</button></li>
    </ul>
    <p class="fl-session" id="flSession"></p>

    <section class="fl-stage" aria-labelledby="flStatus">
      <div class="fl-bar">
        <ul class="fl-stats" id="flStats">
          <li><b data-k="time">0.0</b>초</li>
          <li>AI 호출 <b data-k="llm">0</b>번</li>
          <li>도구 실행 <b data-k="tool">0</b>번</li>
          <li>DB 조회 <b data-k="db">0</b>번</li>
        </ul>
        <p class="fl-status" id="flStatus" role="status">질문을 보내면 여기서부터 그려집니다.</p>
        <div class="fl-replay">
          <label for="flSpeed">재생 속도</label>
          <select id="flSpeed">
            <option value="1">실제 속도</option>
            <option value="0.5">2배 느리게</option>
            <option value="0.25">4배 느리게</option>
          </select>
          <button type="button" class="fl-btn fl-btn--ghost" id="flReplay" disabled>다시 재생</button>
        </div>
      </div>
      <div class="fl-lanes-scroll">
        <div class="fl-lanes" id="flLanes">
          <div class="fl-ruler" id="flRuler"></div>
          <div class="fl-lane" data-lane="browser"><div class="fl-lane-name"><strong>화면</strong><small>사용자 브라우저</small></div><div class="fl-track"></div></div>
          <div class="fl-lane" data-lane="was"><div class="fl-lane-name"><strong>서버</strong><small>Java · Spring</small></div><div class="fl-track"></div></div>
          <div class="fl-lane" data-lane="ai"><div class="fl-lane-name"><strong>AI</strong><small>gemma4 · Ollama</small></div><div class="fl-track"></div></div>
          <div class="fl-lane" data-lane="db"><div class="fl-lane-name"><strong>데이터베이스</strong><small>MySQL 의료기관 정보</small></div><div class="fl-track"></div></div>
          <div class="fl-now" id="flNow" hidden></div>
        </div>
      </div>
    </section>

    <section class="fl-explain" aria-label="단계별 설명">
      <div>
        <h2 class="fl-explain-title">일어난 순서</h2>
        <ol class="fl-steps" id="flSteps"></ol>
      </div>
      <article class="fl-detail" id="flDetail" aria-live="polite">
        <p class="fl-placeholder">단계를 고르면 무엇이 오갔는지 보여 드립니다.</p>
      </article>
    </section>

    <section class="fl-answer" aria-labelledby="flAnswerTitle">
      <h2 id="flAnswerTitle">사용자가 받는 답변</h2>
      <div class="fl-answer-body" id="flAnswer"><p class="fl-placeholder">처리가 끝나면 상담 화면에 보이는 답변이 여기에 나타납니다.</p></div>
    </section>
  </main>

  <script src="https://cdn.jsdelivr.net/npm/markdown-it@14.1.0/dist/markdown-it.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/dompurify@3.1.6/dist/purify.min.js"></script>
  <script src="${ctx}/pt-ai/gwtpax3/js/ai-flow.js"></script>
</body>
</html>
