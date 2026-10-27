<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * index.jsp
 * @desc    : 강원 메디컬 AI 홈 - 퍼블리싱 docs/gangwon_ai_v2/index.html 기반(2026-09-28 전면 교체).
 *            헤더(로고 + 의료서비스/공지사항/FAQ)는 데코레이터 default_medical.jsp가 그림.
 *            meta gm-header=overlay 로 히어로 위에 투명 헤더로 표시된다.
 *            지역/증상/진료과 드롭다운 + AI 검색은 /common/front/kor/js/landing.js
 *            (검색 시 /gwtpax/ai-consult.do?q= 로 이동 - 기존 doAISearch 동작 이관).
 *            공지사항/FAQ 영역은 메디링크 게시판 최근 4건(frontMedicalAI.Index → frontMedicalBoard).
 *            이전 버전 백업: index.jsp_20260928
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="강원특별자치도 공공 의료 안내 서비스">
<meta name="gm-header" content="overlay">
<title>메디링크 강원</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css">
<link rel="stylesheet" href="/common/front/kor/css/landing.css">
<script>
  if (!window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    document.documentElement.classList.add("is_motion");
    window.addEventListener("load", function () { document.documentElement.classList.remove("is_motion"); });
  }
</script>
<style>
  video.hero_image { display: block; object-fit: cover; background: #000 url("/common/front/kor/images/visual_img.jpg") center / cover no-repeat; pointer-events: none; }
</style>
</head>
<body>
  <main>
    <!-- ====================== 히어로 ====================== -->
    <section class="hero_wrap" id="top" aria-labelledby="hero_title">
      <video class="hero_image" autoplay muted loop playsinline webkit-playsinline preload="auto" poster="/common/front/kor/images/visual_img.jpg" disablepictureinpicture disableremoteplayback aria-label="메디링크 강원 메인 비주얼 영상">
        <source src="/common/front/kor/images/main_visual_low.mp4" type="video/mp4">
        <img src="/common/front/kor/images/visual_img.jpg" alt="메디링크 강원 메인 비주얼 이미지">
      </video>
      <div class="hero_overlay" aria-hidden="true"></div>
      <div class="hero_inner">
        <div class="hero_content">
          <div class="hero_copy">
            <p class="hero_label">AI Medical Portal for Gangwon</p>
            <h1 class="hero_title" id="hero_title">강원도민의 건강,<br><em>묻고, 잇고,</em> 찾습니다.</h1>
          </div>
          <form class="search_form" role="search">
            <p class="search_desc">병의원·질병·응급까지, 궁금한 것을 말하면 AI가 공공데이터를 근거로 가까운 의료기관과 다음 행동을 안내합니다.</p>
            <div class="search_options" aria-label="검색 조건">

              <div class="option_wrap">
                <button class="option_btn" id="symptom_btn" type="button" aria-expanded="false" aria-controls="symptom_panel">증상별 검색 <svg class="option_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></button>
                <div class="option_panel symptom_panel" id="symptom_panel" hidden></div>
              </div>

              <div class="option_wrap">
                <button class="option_btn" id="region_btn" type="button" aria-expanded="false" aria-controls="region_panel">지역별 검색 <svg class="option_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></button>
                <div class="option_panel region_panel" id="region_panel" hidden></div>
              </div>
              
              <div class="option_wrap">
                <button class="option_btn" id="department_btn" type="button" aria-expanded="false" aria-controls="department_panel">진료과별 검색 <svg class="option_chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></button>
                <div class="option_panel department_panel" id="department_panel" hidden></div>
              </div>
            </div>
            <div class="selected_tags" id="selected_tags" aria-live="polite"></div>
            <div class="search_field">
              <svg class="search_icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
                <circle cx="11" cy="11" r="8"/>
                <path d="m21 21-4.35-4.35"/>
              </svg>
              <label for="medical_search" hidden>증상, 지역 또는 진료과 검색</label>
              <input class="search_input" id="medical_search" type="search" placeholder="허리 통증이 있을 땐 어떤 과를 가야 해?" autocomplete="off">
              <button class="search_btn" type="submit" aria-label="의료기관 검색">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true">
                  <path d="M5 12h14M13 6l6 6-6 6"/>
                </svg>
              </button>
            </div>
            <div class="hero_chips" aria-label="바로가기">
              <a class="hero_chip" href="/front/medical/hospitalList.do">병·의원 찾기</a>
              <button class="hero_chip" type="button" data-open-panel="symptom">질병 정보</button>
              <a class="hero_chip" href="/front/medical/erLive.do">응급실 LIVE</a>
              <a class="hero_chip" href="/front/medical/pharmacyList.do">약국 찾기</a>
            </div>
            <p class="hero_note">본 서비스의 안내는 의료적 판단을 대신하지 않습니다. 응급 상황에서는 119에 연락하세요.</p>
          </form>
        </div>
        <div class="hero_bottom">
          <a class="service_link" href="#services">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
              <path d="M12 5v14M19 12l-7 7-7-7"/>
            </svg>
            의료 서비스 보기
          </a>
          <div class="emergency_group" aria-label="긴급 연락처">
            <a class="emergency_link" href="tel:119"><span>응급·화재·구조</span><strong>119</strong></a>
            <a class="emergency_link emergency_sub" href="tel:1339"><span>응급의료 상담</span><strong>1339</strong></a>
            <a class="emergency_link emergency_sub" href="tel:1577-1000"><span>건강보험 상담</span><strong>1577-1000</strong></a>
          </div>
        </div>
      </div>
    </section>

    <!-- ====================== 의료 서비스 ====================== -->
    <section class="service_wrap" id="services" aria-labelledby="service_title">
      <div class="service_inner">
        <header class="section_head">
          <div>
            <p class="section_label">Services</p>
            <h2 class="section_title" id="service_title">하나의 창구에서<br>필요한 의료 정보를 잇습니다</h2>
          </div>
          <p class="section_desc">기존 의료 서비스 기능은 그대로, 이름과 첫 화면의 경험만 하나로 묶었습니다.</p>
        </header>
        <nav class="service_list" aria-label="의료 서비스">
          <a class="service_item" href="/front/medical/hospitalList.do">
            <span class="service_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16M3 21h18M9 21v-4h6v4M9 8h6M12 5v6M8 13h2M14 13h2"/></svg></span>
            <strong class="service_name">병·의원 찾기</strong>
            <span class="service_desc">지역·진료과·운영 시간으로 가까운 기관을 찾고 지도로 확인</span>
            <span class="service_side"><span class="service_en">바로가기</span><span class="service_arrow">→</span></span>
          </a>
          <a class="service_item" href="#top" data-open-panel="symptom">
            <span class="service_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M11 2v2M5 2v2M5 3H4a2 2 0 0 0-2 2v4a6 6 0 0 0 12 0V5a2 2 0 0 0-2-2h-1M8 15a6 6 0 0 0 12 0v-3"/><circle cx="20" cy="10" r="2"/></svg></span>
            <strong class="service_name">질병 · 증상 정보</strong>
            <span class="service_desc">증상에서 질환을 이해하고, 어느 진료과로 가야 할지 안내</span>
            <span class="service_side"><span class="service_en">바로가기</span><span class="service_arrow">→</span></span>
          </a>
          <a class="service_item" href="/front/medical/erLive.do">
            <span class="service_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/><path d="M4 12h4l2-4 3.5 8 2-4H20"/></svg></span>
            <strong class="service_name">응급실 LIVE</strong>
            <span class="service_desc">응급실 가용 병상과 연락처를 실시간으로 확인</span>
            <span class="service_side"><span class="service_en">바로가기</span><span class="service_arrow">→</span></span>
          </a>
          <a class="service_item" href="/front/medical/pharmacyList.do">
            <span class="service_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/><path d="m8.5 8.5 7 7"/></svg></span>
            <strong class="service_name">약국 · 의약 정보</strong>
            <span class="service_desc">운영 중인 약국과 의약품 정보를 한 곳에서 확인</span>
            <span class="service_side"><span class="service_en">바로가기</span><span class="service_arrow">→</span></span>
          </a>
        </nav>
        <p class="service_live"><span class="live_dot" aria-hidden="true"></span><strong>응급실 LIVE</strong><span>공공데이터 실시간 연동 · 가용 병상 정보는 갱신 시점에 따라 달라질 수 있습니다.</span></p>
      </div>
    </section>

    <!-- ====================== 퀵메뉴 ====================== -->
    <aside class="quick_wrap" aria-label="퀵메뉴">
      <div class="quick_group">
        <span class="quick_title">QUICK<br>MENU</span>
        <ul class="quick_list">
          <li>
            <a class="quick_link" href="/front/medical/vaccinationList.do">
              <span class="quick_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m18 2 4 4M17 7l3-3M19 9 8.7 19.3a1 1 0 0 1-1.4 0l-2.6-2.6a1 1 0 0 1 0-1.4L15 5M9 11l4 4M5 19l-3 3M14 4l6 6"/></svg></span>
              <span class="quick_name">예방접종<br>병원찾기</span>
            </a>
          </li>
          <li>
            <a class="quick_link" href="/front/medical/pharmacyList.do">
              <span class="quick_icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/><path d="m8.5 8.5 7 7"/></svg></span>
              <span class="quick_name">약국 찾기</span>
            </a>
          </li>
        </ul>
      </div>
      <div class="quick_group quick_partner">
        <a class="quick_link" href="http://pt-ai.ctit.co.kr/knuh/ai-consult.do" target="_blank" rel="noopener" title="강원대학교병원 AI 상담 (새 창)">
          <img class="quick_logo" src="/common/front/kor/images/knuh_ci.png" alt="" width="371" height="128">
          <span class="quick_name">강원대학교<br>병원</span>
        </a>
      </div>
      <a class="quick_top" href="#top" aria-label="맨 위로 이동">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 15 6-6 6 6"/></svg>
      </a>
    </aside>

    <!-- ====================== AI Concierge ====================== -->
    <section class="ai_wrap" id="ai" aria-labelledby="ai_title">
      <div class="ai_inner">
        <header class="section_head">
          <div>
            <p class="section_label">AI Concierge</p>
            <h2 class="section_title" id="ai_title">찾아 헤매지 않고,<br>말하면 이어집니다</h2>
          </div>
          <p class="section_desc">검색어를 고민하는 대신 평소 말로 묻습니다. 답변에는 근거와 출처, 다음 행동이 함께 붙습니다.</p>
        </header>
        <div class="ai_grid">
          <div class="ai_chat" aria-label="AI 상담 대화 예시">
            <p class="chat_msg chat_user">아이가 밤에 열이 나는데 지금 갈 수 있는 곳 있어?</p>
            <div class="chat_msg chat_ai">
              <p>현재 위치 기준으로 응급실 운영 기관 2곳이 확인됩니다. 열이 39℃ 이상이거나 경련·호흡 곤란이 있으면 119에 먼저 연락하세요.</p>
              <div class="chat_actions">
                <a href="/front/medical/erLive.do">응급실 LIVE 보기</a>
                <a href="/front/medical/pharmacyList.do">가까운 약국</a>
              </div>
              <span class="chat_source">출처 · 국립중앙의료원 응급의료정보 · 갱신 방금 전</span>
            </div>
            <p class="chat_msg chat_user">그럼 낮에는 어느 과로 가야 해?</p>
            <div class="chat_msg chat_ai">
              <p>소아청소년과를 권장합니다. 평일 진료 중인 기관을 지역별로 보여드릴까요?</p>
            </div>
          </div>
          <ol class="ai_points">
            <li><span class="point_num">01</span><div><strong>근거 있는 답변</strong><p>모든 안내는 국가 공공데이터를 기반으로 하며 출처와 갱신 시점을 함께 표시합니다.</p></div></li>
            <li><span class="point_num">02</span><div><strong>다음 행동까지</strong><p>정보 전달에서 끝나지 않고 전화·길찾기·응급 연결 같은 실제 행동으로 이어줍니다.</p></div></li>
            <li><span class="point_num">03</span><div><strong>강원도민의 맥락</strong><p>도내 시군 단위 생활권, 이동 거리, 응급 의료 여건을 우선으로 응대합니다.</p></div></li>
            <li><span class="point_num">04</span><div><strong>판단은 전문가에게</strong><p>AI는 안내자이며 의료적 최종 판단은 의료 전문가의 몫임을 항상 고지합니다.</p></div></li>
          </ol>
        </div>
      </div>
    </section>

    <!-- ====================== 공지사항 / FAQ (메디링크 게시판 최근 4건 - frontMedicalAI.Index) ====================== -->
    <section class="notice_wrap" id="notice" aria-labelledby="notice_title">
      <div class="notice_inner">
        <header class="notice_header">
          <p class="section_label">News &amp; FAQ</p>
          <h2 class="section_title" id="notice_title">새로운 소식과<br>자주 묻는 질문</h2>
        </header>
        <div class="board_grid">
          <article class="board_column">
            <header class="board_head">
              <div><p class="section_label">News</p><h3><a href="/front/medical/noticeList.do">공지사항</a></h3></div>
              <!-- <span>총 ${noticeTotal}건</span> -->
               <a href="/front/medical/noticeList.do"><img src="/common/front/kor/images/main/ico_main_qic_plus.png" alt="공지사항 더보기"></a>
            </header>
            <div class="board_list">
              <c:forEach items="${noticeList}" var="row">
                <a class="notice_row" href="/front/medical/noticeView.do?boardNo=${row.BOARD_NO}"><span><c:if test="${row.IS_NEW}"><em class="new_badge">NEW</em></c:if><c:out value="${str:getReverseXSS(row.TITLE)}"/></span><time datetime="${fn:replace(row.REG_DATE, '.', '-')}"><c:out value="${row.REG_DATE}"/></time></a>
              </c:forEach>
              <c:if test="${empty noticeList}">
                <a class="notice_row" href="/front/medical/noticeList.do"><span>등록된 공지사항이 없습니다.</span></a>
              </c:if>
            </div>
          </article>
          <article class="board_column">
            <header class="board_head">
              <div><p class="section_label">FAQ</p><h3><a href="/front/medical/faq.do">자주 묻는 질문</a></h3></div>
              <!-- <span>총 ${faqTotal}건</span> -->
               <a href="/front/medical/faq.do"><img src="/common/front/kor/images/main/ico_main_qic_plus.png" alt="FAQ 더보기"></a>
            </header>
            <div class="board_list">
              <c:forEach items="${faqList}" var="row">
                <a class="faq_row" href="/front/medical/faq.do?open=${row.BOARD_NO}"><span><c:out value="${str:getReverseXSS(row.TITLE)}"/></span><span aria-hidden="true">→</span></a>
              </c:forEach>
              <c:if test="${empty faqList}">
                <a class="faq_row" href="/front/medical/faq.do"><span>등록된 FAQ가 없습니다.</span><span aria-hidden="true">→</span></a>
              </c:if>
            </div>
          </article>
        </div>
      </div>
    </section>
  </main>

  <!-- ====================== 푸터 ====================== -->
  <footer class="footer_wrap">
    <div class="footer_inner">
      <div class="footer_left">
        <a class="footer_bi" href="#top"><img src="/common/front/kor/images/medilink-bi-white.svg" alt="메디링크 강원 MediLink Kangwon"></a>
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

  <script src="/common/front/kor/js/landing.js" defer></script>
  <script src="/common/front/kor/js/gsap.min.js" defer></script>
  <script src="/common/front/kor/js/ScrollTrigger.min.js" defer></script>
  <script src="/common/front/kor/js/landing_motion.js" defer></script>
  <script>
  document.addEventListener("click", function (event) {
    var trigger = event.target.closest("[data-open-panel]");
    if (!trigger) return;
    var button = document.getElementById(trigger.getAttribute("data-open-panel") + "_btn");
    if (!button) return;
    event.preventDefault();
    event.stopPropagation();
    button.scrollIntoView({ behavior: "smooth", block: "center" });
    if (button.getAttribute("aria-expanded") !== "true") button.click();
    button.focus({ preventScroll: true });
  }, true);

  (function () {
    var link = document.querySelector(".quick_partner .quick_link");
    if (!link) return;
    link.addEventListener("click", function (event) {
      var w = Math.min(1280, screen.availWidth);
      var h = Math.min(900, screen.availHeight);
      var l = (screen.availLeft || 0) + (screen.availWidth - w) / 2;
      var t = (screen.availTop || 0) + (screen.availHeight - h) / 2;
      var popup = window.open(link.href, "knuh_ai_popup",
        "width=" + w + ",height=" + h + ",left=" + l + ",top=" + t + ",scrollbars=yes,resizable=yes");
      if (!popup) return;
      event.preventDefault();
      popup.focus();
    });
  })();
  </script>
  <script>
  (function () {
    var video = document.querySelector("video.hero_image");
    if (!video) return;

    function start() {
      video.muted = true;
      video.defaultMuted = true;
      video.volume = 0;
      video.setAttribute("muted", "");
      video.setAttribute("playsinline", "");
      video.setAttribute("webkit-playsinline", "");
      var play = video.play();
      if (play && typeof play.catch === "function") play.catch(function () {});
    }

    video.addEventListener("ended", function () {
      video.currentTime = 0;
      start();
    });

    if (video.readyState >= 2) start();
    else video.addEventListener("canplay", start, { once: true });

    document.addEventListener("visibilitychange", function () {
      if (!document.hidden && video.paused) start();
    });
    window.addEventListener("pageshow", function () {
      if (video.paused) start();
    });
  })();
  </script>
</body>
</html>
