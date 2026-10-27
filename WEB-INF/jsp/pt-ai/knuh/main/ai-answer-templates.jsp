<%@ page pageEncoding="UTF-8" %>
<%-- AI 답변 템플릿 (ai-consult.jsp 공통 include) --%>

<!-- 마이페이지 템플릿 -->
<template id="tpl-my-page">

  <!-- 예약확인 -->
  <section class="kp-answer-card__section">
    <h3 class="kp-answer-card__h"><span class="kp-answer-card__bullet" aria-hidden="true">▶</span> 예약확인</h3>
    <div class="kp-answer-card__table-wrap--fit">
      <table class="kp-rsv-table">
        <thead>
          <tr>
            <th>일자 · 시간</th>
            <th>진료과</th>
            <th>의료진</th>
            <th>현황</th>
          </tr>
        </thead>
        <tbody>
          <tr class="kp-rsv-row--upcoming" data-rsv-datetime="2026.06.20 (토) 10:00" data-rsv-dept="척추센터 · 신경외과" data-rsv-doctor="김철수 교수">
            <td>2026.06.20 (토) 10:00</td>
            <td>척추센터 · 신경외과</td>
            <td>김철수 교수</td>
            <td><span class="kp-rsv-badge kp-rsv-badge--upcoming">방문예정</span></td>
          </tr>
          <tr>
            <td>2026.05.15 (수) 14:30</td>
            <td>신경외과</td>
            <td>김철수 교수</td>
            <td><span class="kp-rsv-badge kp-rsv-badge--done">진료완료</span></td>
          </tr>
          <tr>
            <td>2026.04.03 (목) 09:00</td>
            <td>영상의학과</td>
            <td>이영희 과장</td>
            <td><span class="kp-rsv-badge kp-rsv-badge--done">진료완료</span></td>
          </tr>
          <tr>
            <td>2026.03.10 (월) 11:00</td>
            <td>신경외과</td>
            <td>김철수 교수</td>
            <td><span class="kp-rsv-badge kp-rsv-badge--done">진료완료</span></td>
          </tr>
          <tr>
            <td>2026.02.14 (토) 13:00</td>
            <td>재활의학과</td>
            <td>박지원 과장</td>
            <td><span class="kp-rsv-badge kp-rsv-badge--done">진료완료</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <!-- 고객의 소리 -->
  <section class="kp-answer-card__section">
    <h3 class="kp-answer-card__h"><span class="kp-answer-card__bullet" aria-hidden="true">▶</span> 고객의 소리</h3>
    <div class="kp-board-list">
      <div class="kp-board-item">
        <button type="button" class="kp-board-item__head" aria-expanded="false">
          <span>
            <span class="kp-board-item__title">주차 공간 확대를 요청드립니다</span>
            <span class="kp-board-item__meta">답변일 2026.06.10</span>
          </span>
          <span style="display:flex;align-items:center;gap:8px;">
            <span class="kp-board-item__status kp-board-item__status--done">답변완료</span>
            <span class="kp-board-item__chev" aria-hidden="true"></span>
          </span>
        </button>
        <div class="kp-board-item__body" hidden>
          안녕하세요, 강원대학교병원입니다. 고객님의 소중한 의견 감사드립니다. 주차장 증설 공사가 내년 상반기 착공 예정이며, 완공 전까지 병원 인근 공영주차장을 안내해 드릴 예정입니다. 불편을 드려 대단히 죄송합니다.
        </div>
      </div>
      <div class="kp-board-item">
        <button type="button" class="kp-board-item__head kp-board-item__head--pending" aria-expanded="false">
          <span>
            <span class="kp-board-item__title">외래 대기시간 개선을 건의합니다</span>
            <span class="kp-board-item__meta">2026.06.05 접수</span>
          </span>
          <span style="display:flex;align-items:center;gap:8px;">
            <span class="kp-board-item__status kp-board-item__status--pending">미답변</span>
            <span class="kp-board-item__chev" aria-hidden="true"></span>
          </span>
        </button>
      </div>
      <div class="kp-board-item">
        <button type="button" class="kp-board-item__head" aria-expanded="false">
          <span>
            <span class="kp-board-item__title">식당 메뉴 다양화를 건의합니다</span>
            <span class="kp-board-item__meta">답변일 2026.05.28</span>
          </span>
          <span style="display:flex;align-items:center;gap:8px;">
            <span class="kp-board-item__status kp-board-item__status--done">답변완료</span>
            <span class="kp-board-item__chev" aria-hidden="true"></span>
          </span>
        </button>
        <div class="kp-board-item__body" hidden>
          고객님의 소중한 의견 감사합니다. 영양팀과 협의하여 주 1회 특선 메뉴를 추가 제공하고, 계절 메뉴를 정기적으로 교체하는 방향으로 개선을 추진하고 있습니다. 앞으로도 많은 관심 부탁드립니다.
        </div>
      </div>
    </div>
  </section>

  <!-- 병문안 편지 -->
  <section class="kp-answer-card__section">
    <h3 class="kp-answer-card__h"><span class="kp-answer-card__bullet" aria-hidden="true">▶</span> 병문안 편지</h3>
    <div class="kp-letter-tabs">
      <button type="button" class="kp-letter-tab is-active" data-ltab="recv">수신</button>
      <button type="button" class="kp-letter-tab" data-ltab="send">발신</button>
    </div>
    <div class="kp-letter-list" data-lpanel="recv">
      <div class="kp-letter-item">
        <span class="kp-letter-item__title">빠른 쾌유를 빕니다! 힘내세요 응원합니다</span>
        <span class="kp-letter-item__from">박민준</span>
        <span class="kp-letter-item__date">2026.06.12</span>
      </div>
      <div class="kp-letter-item">
        <span class="kp-letter-item__title">항상 응원하고 있어요, 얼른 나으세요</span>
        <span class="kp-letter-item__from">이수진</span>
        <span class="kp-letter-item__date">2026.06.11</span>
      </div>
      <div class="kp-letter-item">
        <span class="kp-letter-item__title">곧 건강하게 퇴원하실 거예요!</span>
        <span class="kp-letter-item__from">정유나</span>
        <span class="kp-letter-item__date">2026.06.09</span>
      </div>
    </div>
    <div class="kp-letter-list" data-lpanel="send" hidden>
      <div class="kp-letter-item">
        <span class="kp-letter-item__title">아버지 잘 지내고 계신지요, 걱정됩니다</span>
        <span class="kp-letter-item__from">홍길순</span>
        <span class="kp-letter-item__date">2026.06.13</span>
      </div>
      <div class="kp-letter-item">
        <span class="kp-letter-item__title">병원 음식은 입에 맞으세요?</span>
        <span class="kp-letter-item__from">홍길남</span>
        <span class="kp-letter-item__date">2026.06.10</span>
      </div>
    </div>
  </section>

</template>