<%@ page pageEncoding="UTF-8" %>
<%-- AI 상담4 답변 스타일 (ai-consult.jsp 와 관리자 답변 디자인 미리보기 design-preview.jsp 가 함께 include, 2026-10-16 분리) --%>
  <style>
    .kp-answer-card__body[data-knuh-answer-style="sample"] th,
    .kp-answer-card__body[data-knuh-answer-style="sample"] td { word-break: keep-all; overflow-wrap: break-word; }
    .kp-answer-card__body[data-knuh-answer-style="sample"] td a[href^="tel:"] { white-space: nowrap; }
    /* 표 가로 스크롤은 표를 감싼 div.ai2-tscroll 에서 한다 (ai-core4.js wrapTables).
       표 자체를 display:block 으로 바꾸면 칸이 표 폭만큼 늘어나지 않아 오른쪽이 비어 보인다 (2열 진료과 표 등) */
    .kp-answer-card__body .ai2-tscroll { margin: 12px 0 18px; overflow-x: auto; -webkit-overflow-scrolling: touch; border-radius: 12px; }
    .kp-answer-card__body[data-knuh-answer-style="sample"] .ai2-tscroll > table { margin: 0; }
    @media (max-width: 640px) {
      .kp-answer-card__body[data-knuh-answer-style="sample"] th,
      .kp-answer-card__body[data-knuh-answer-style="sample"] td { min-width: 4.5em; }
      .kp-answer-card__body[data-knuh-answer-style="sample"] th:first-child,
      .kp-answer-card__body[data-knuh-answer-style="sample"] td:first-child { min-width: 8em; }
    }
    /* 의료기관 답변 지도 (answer-map.js) */
    .ai2-map { position: relative; margin: 4px 0 24px; border: 1px solid #CBD4EC; border-radius: 12px; overflow: hidden; background: #EEF2FB; }
    .ai2-map__canvas { width: 100%; height: 260px; }
    .ai2-map__pop { position: relative; min-width: 160px; max-width: 240px; padding: 10px 28px 10px 12px; border-radius: 10px; background: #fff; box-shadow: 0 6px 20px rgba(5,34,105,.18); font-size: 12px; line-height: 1.45; color: #263241; }
    .ai2-map__pop::after { content: ""; position: absolute; left: 50%; bottom: -6px; margin-left: -6px; border: 6px solid transparent; border-bottom: 0; border-top-color: #fff; }
    .ai2-map__pop-name { display: block; color: #052269; font-size: 13px; font-weight: 800; }
    .ai2-map__pop-cat, .ai2-map__pop-addr { display: block; color: #5B6577; }
    .ai2-map__pop-tel { display: inline-block; margin: 2px 0; color: #002789; font-weight: 700; }
    .ai2-map__pop-close { position: absolute; top: 4px; right: 6px; border: 0; background: none; color: #8A93A6; font-size: 16px; line-height: 1; cursor: pointer; }
    @media (max-width: 640px) { .ai2-map__canvas { height: 220px; } }
    /* 목록 표 행 → 지도 마커 연결 (answer-map.js) */
    .kp-answer-card__body tr.ai2-row-link { cursor: pointer; }
    .kp-answer-card__body tr.ai2-row-link:hover > td, .kp-answer-card__body tr.ai2-row-link:focus-visible > td { background: #F4F7FF; }
    .kp-answer-card__body tr.ai2-row-link:focus-visible { outline: none; }
    .kp-answer-card__body tr.ai2-row-link.is-active > td { background: #FFF1E8; }
    .kp-answer-card__body tr.ai2-row-link.is-active > td:first-child { box-shadow: inset 3px 0 0 #E8590C; }
    /* 기관명 칸 안의 [길찾기]·[상세] 버튼 (FacilityService.actions). ai-core4.js groupRowActions 가 span.ai2-acts 로 묶어 이름 아래 한 줄에 둔다 */
    .kp-answer-card__body td .ai2-acts { display: block; margin-top: 4px; white-space: nowrap; }
    .kp-answer-card__body td a[href*="map.kakao.com/link/to/"],
    .kp-answer-card__body td a[href^="#ai2-detail="] {
      display: inline-block; margin: 0 4px 0 0; padding: 0 7px; border: 1px solid #C9D3EA; border-radius: 999px;
      background: #fff; color: #3B5BDB; font-size: 11.5px; font-weight: 600; line-height: 20px;
      text-decoration: none; white-space: nowrap; vertical-align: middle;
    }
    .kp-answer-card__body td a[href*="map.kakao.com/link/to/"]:hover,
    .kp-answer-card__body td a[href^="#ai2-detail="]:hover { background: #EEF2FF; border-color: #91A7FF; }
    /* 상담4 블록 렌더링 (answer-blocks.js, 2026-10-16): 같은 버튼을 data-action 으로 그린다 */
    .kp-answer-card__body td [data-action="route"],
    .kp-answer-card__body td [data-action="detail"] {
      display: inline-block; margin: 0 4px 0 0; padding: 0 7px; border: 1px solid #C9D3EA; border-radius: 999px;
      background: #fff; color: #3B5BDB; font: inherit; font-size: 11.5px; font-weight: 600; line-height: 20px;
      text-decoration: none; white-space: nowrap; vertical-align: middle; cursor: pointer;
    }
    .kp-answer-card__body td [data-action="route"]:hover,
    .kp-answer-card__body td [data-action="detail"]:hover { background: #EEF2FF; border-color: #91A7FF; }
    .kp-answer-card__body[data-blocks] > .ab:first-child > .ab__part:first-child > *:first-child { margin-top: 0; }

    /* 로딩 템플릿 + 답변 등장 애니메이션 (ai-core4.js showLoading / playReveal) */
    .ai2-loading { display: inline-flex; align-items: center; gap: 10px; padding: 10px 14px; border-radius: 999px; background: #EEF2FB; color: #052269; font-size: 14px; font-weight: 600; }
    /* 모바일은 답변 카드 아래 여백이 0 (ai-consult.css .kp-answer-card padding: 22px 16px 0) 이라 로딩 표시가 카드 테두리에 붙는다 */
    @media (max-width: 880px) {
      .kp-answer-card__body .ai2-loading, .kp-answer-card__body .kp-answer-status { margin-bottom: 22px; }
    }
    .ai2-loading__spinner { flex: none; width: 18px; height: 18px; border: 2.5px solid #CBD4EC; border-top-color: #002789; border-radius: 50%; animation: ai2-spin .8s linear infinite; }
    .ai2-loading__dots i { font-style: normal; animation: ai2-dot 1.2s infinite both; }
    .ai2-loading__dots i:nth-child(2) { animation-delay: .2s; }
    .ai2-loading__dots i:nth-child(3) { animation-delay: .4s; }
    .kp-answer-card__body.ai2-reveal, .ai2-map { animation: ai2-reveal .45s cubic-bezier(.2,.7,.3,1) both; }
    /* 타자기 렌더 중 통째로 나타나는 표·이미지 (ai-core4.js createTypewriter) */
    .kp-answer-card__body table.ai2-pop, .kp-answer-card__body img.ai2-pop { animation: ai2-reveal .45s cubic-bezier(.2,.7,.3,1) both; }
    .ai2-loading__label--swap { display: inline-block; animation: ai2-swap .3s ease-out both; }
    @keyframes ai2-swap { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
    @keyframes ai2-spin { to { transform: rotate(360deg); } }
    @keyframes ai2-dot { 0%, 80%, 100% { opacity: .2; } 40% { opacity: 1; } }
    @keyframes ai2-reveal { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: none; } }
    /* 건강정보 긴 단락 접기/펼치기 (answer-fold.js) */
    .ai2-fold { position: relative; margin: 0 0 14px; }
    .ai2-fold__inner { position: relative; max-height: 7.2em; overflow: hidden; }
    .ai2-fold__inner::after { content: ""; position: absolute; left: 0; right: 0; bottom: 0; height: 3em; background: linear-gradient(rgba(255,255,255,0), #fff); pointer-events: none; }
    .ai2-fold.is-open .ai2-fold__inner { max-height: none; }
    .ai2-fold.is-open .ai2-fold__inner::after { display: none; }
    .ai2-fold__btn { display: inline-flex; align-items: center; gap: 4px; margin-top: 6px; padding: 4px 12px; border: 1px solid #CBD4EC; border-radius: 999px; background: #fff; color: #002789; font-size: 12px; font-weight: 700; cursor: pointer; }
    .ai2-fold__btn::after { content: "▾"; font-size: 10px; }
    .ai2-fold.is-open .ai2-fold__btn::after { content: "▴"; }
    /* 건강정보 "자세히 보기" 탭: 한 번에 한 단락 (answer-fold.js, 2026-10-15) */
    .ai2-fold__btn small { font-weight: 400; color: #5A6A8C; }
    h4.ai2-tabs-label { margin: 18px 0 6px; font-size: 13px; color: #5A6A8C; }
    .ai2-tabs { display: flex; flex-wrap: wrap; gap: 6px; margin: 0 0 10px; }
    .ai2-tabs button { padding: 5px 12px; border: 1px solid #CBD4EC; border-radius: 999px; background: #fff; color: #1B2A4E; font-size: 13px; cursor: pointer; }
    .ai2-tabs button:hover { border-color: #002789; }
    .ai2-tabs button.is-on { background: #002789; border-color: #002789; color: #fff; font-weight: 700; }
    .ai2-tab-panel { margin: 0 0 14px; padding: 4px 14px 2px; border-left: 3px solid #002789; background: #F7F9FD; border-radius: 0 8px 8px 0; }
    .ai2-tab-panel > h3:first-child { margin-top: 8px; }
    /* 건강정보 그림·표 (2026-10-15) */
    .ai2-img-btn { padding: 4px 12px; border: 1px dashed #CBD4EC; border-radius: 8px; background: #F7F9FD; color: #1B2A4E; font-size: 12px; cursor: pointer; }
    img.ai2-health-img { display: block; max-width: 100%; max-height: 360px; width: auto; height: auto; margin: 8px 0; border: 1px solid #E3E8F2; border-radius: 8px; background: #F3F6FC; cursor: zoom-in; }
    img.ai2-health-img.is-zoom { max-height: none; cursor: zoom-out; }
    @media (prefers-reduced-motion: reduce) {
      .ai2-loading__spinner, .ai2-loading__dots i, .ai2-loading__label--swap, .kp-answer-card__body.ai2-reveal, .ai2-map,
      .kp-answer-card__body table.ai2-pop, .kp-answer-card__body img.ai2-pop { animation: none; }
    }
    /* AI 상담4 전용: 답변 아래 검색 과정 상자 (answer-trace.js) */
    .ai3-trace { margin: 4px 0 20px; border: 1px solid #DCE1EF; border-radius: 12px; background: #F8FAFF; font-size: 12.5px; color: #3D4759; }
    .ai3-trace > summary { cursor: pointer; padding: 9px 14px; font-weight: 700; color: #052269; list-style: none; }
    .ai3-trace > summary::-webkit-details-marker { display: none; }
    .ai3-trace > summary::after { content: " ▾"; font-size: 10px; }
    .ai3-trace[open] > summary::after { content: " ▴"; }
    .ai3-trace__list { margin: 0; padding: 0 14px 4px 34px; list-style: none; }
    .ai3-trace__list li { margin: 3px 0; }
    .ai3-trace__err { color: #C92A2A; }
    .ai3-trace__meta { margin: 0; padding: 4px 14px 10px; color: #6B7487; }
    /* AI 상담4 전용: 답변 평가 (answer-feedback.js) */
    .ai3-fb { margin: 0 0 22px; font-size: 13px; color: #3D4759; }
    .ai3-fb__row { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }
    .ai3-fb__q { margin-right: 2px; }
    .ai3-fb__vote { width: 34px; height: 30px; border: 1px solid #DCE1EF; border-radius: 999px; background: #fff; cursor: pointer; font-size: 15px; line-height: 1; }
    .ai3-fb__vote:hover { background: #EEF2FF; }
    .ai3-fb__vote.is-on { border-color: #3B5BDB; background: #EDF2FF; }
    .ai3-fb__link { border: 0; background: none; color: #3B5BDB; cursor: pointer; font-size: 12.5px; text-decoration: underline; padding: 0 4px; }
    .ai3-fb__status { color: #6B7487; font-size: 12.5px; }
    .ai3-fb__panel { margin-top: 8px; padding: 12px 14px; border: 1px solid #DCE1EF; border-radius: 12px; background: #F8FAFF; }
    .ai3-fb__title { margin: 0 0 8px; font-weight: 700; color: #052269; }
    .ai3-fb__chips { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px; }
    .ai3-fb__chip { padding: 4px 12px; border: 1px solid #C9D3EA; border-radius: 999px; background: #fff; cursor: pointer; font-size: 12.5px; }
    .ai3-fb__chip.is-on { border-color: #3B5BDB; background: #3B5BDB; color: #fff; }
    .ai3-fb__memo { width: 100%; box-sizing: border-box; padding: 8px 10px; border: 1px solid #C9D3EA; border-radius: 8px; font: inherit; resize: vertical; }
    .ai3-fb__actions { display: flex; gap: 6px; justify-content: flex-end; margin-top: 8px; }
    .ai3-fb__send, .ai3-fb__cancel { padding: 5px 14px; border-radius: 8px; cursor: pointer; font-size: 12.5px; }
    .ai3-fb__send { border: 0; background: #002789; color: #fff; }
    .ai3-fb__send:disabled { opacity: .5; cursor: default; }
    .ai3-fb__cancel { border: 1px solid #C9D3EA; background: #fff; }
    /* AI 상담4 전용: 추천 질문 칩 (answer-suggest.js) */
    .ai3-sg { margin: 0 0 12px; }
    .ai3-sg__title { margin: 0 0 6px; font-size: 12.5px; font-weight: 700; color: #052269; }
    .ai3-sg__chips { display: flex; flex-wrap: wrap; gap: 6px; }
    .ai3-sg__chip { padding: 5px 12px; border: 1px solid #C9D3EA; border-radius: 999px; background: #fff; color: #3D4759; cursor: pointer; font-size: 13px; text-align: left; }
    .ai3-sg__chip:hover { border-color: #3B5BDB; background: #EEF2FF; }
    .ai3-sg__chip.is-on { border-color: #3B5BDB; background: #EDF2FF; color: #3B5BDB; }
    /* 답변html 시안(2026-10-21) follow_wrap·vote_wrap 모양: 추천 질문은 위 가로줄 + 둥근 칩, 평가는 동그란 버튼 */
    .ai3-sg { margin: 22px 0 8px; padding: 18px 0 0; border-top: 1px solid #E8ECF2; }
    .ai3-sg__title { margin: 0 0 10px; font-size: 15px; color: #000; }
    .ai3-sg__chips { gap: 8px; }
    .ai3-sg__chip { padding: 7px 12px; border-color: #C9D8FA; border-radius: 99px; color: #1F2937; font-size: 14px; line-height: 1.4; }
    .ai3-sg__chip:hover { border-color: #C9D8FA; background: #E9EEFA; }
    .ai3-sg__chip.is-on { border-color: #0038C3; background: #E9EEFA; color: #0038C3; }
    .ai3-fb { margin-top: 10px; font-size: 14px; }
    .ai3-fb__row { gap: 8px; }
    .ai3-fb__vote { display: inline-grid; place-items: center; width: 36px; height: 36px; padding: 0; border-color: #C9D8FA; border-radius: 50%; font-size: 18px; }
    .ai3-fb__vote:hover { background: #E9EEFA; }
    .ai3-fb__vote.is-on { border-color: #0038C3; background: #E9EEFA; }
    @media (max-width: 480px) { .ai3-sg__chip { font-size: 13px; } }
    /* 관리자 틀의 지도 자리 (CMS 블록 템플릿 3단계): 지도가 없으면 자리를 접는다 */
    .ab [data-ab-map]:empty { display: none; }
  </style>
