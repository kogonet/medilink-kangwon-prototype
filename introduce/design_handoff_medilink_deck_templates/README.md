# Handoff: 메디링크 강원 제품소개서 — 덱 템플릿 3종

## Overview
메디링크 강원(강원도민 대상 AI 의료 포털) 제품소개서(원본 GWTPAI.pptx, 10장)를 전문적으로 다시 디자인하기 위한 **템플릿 방향 3종** 시안입니다. 각 템플릿마다 대표 슬라이드 3장(표지 / 해결할 문제 / 응급실 LIVE)을 실제 원고로 구성했습니다. 고른 템플릿 시스템을 나머지 7장(서비스 소개, 서비스 흐름, 탐색 방식, 통합 정보, AI 상담 도우미, 신뢰의 기반, 기대효과와 확장)에도 적용하면 됩니다.

- **A · Clinical Grid (추천)** — 흰 바탕, 남색 글자, 의료용 파란색 하나만 사용. 괘선과 그리드 중심. B2G·지원사업 제출용.
- **B · Midnight Signal** — 짙은 남색 바탕, 하늘색 신호색과 산호색 경보색. 데이터 콘솔 느낌. 무대 발표·IR용.
- **C · Gangwon Care** — 따뜻한 미색 종이 바탕, 짙은 초록, 명조체 제목. 사진 중심. 도민 대상 홍보용.

## About the Design Files
이 묶음의 파일은 **HTML로 만든 디자인 레퍼런스**입니다. 의도한 생김새를 보여주는 프로토타입이며, 그대로 가져다 쓰는 프로덕션 코드가 아닙니다. 목적 매체에 맞게 다시 구현하세요. 예를 들면 PowerPoint/Keynote/Google Slides 마스터, HTML 슬라이드 덱(React + 1920×1080 스케일 스테이지), PDF 등입니다. 기존 환경이 없다면 가장 알맞은 도구를 고르면 됩니다. `design_canvas.jsx`는 시안 비교용 팬/줌 캔버스일 뿐이며 결과물에는 포함되지 않습니다.

## Fidelity
**High-fidelity.** 색상, 타이포그래피, 간격, 레이아웃은 최종값입니다. 픽셀 단위로 재현하세요. 단, 템플릿 B "응급실 LIVE"의 병상 표(강원대학교병원 7, 원주세브란스기독병원 4, 강릉아산병원 2, 갱신 14:32)는 **예시 데이터**이므로 실제 화면이나 데이터로 바꿔야 합니다.

## Canvas & Global Rules
- 슬라이드 크기: **1920 × 1080 px** (16:9). 뷰포트 안에서는 `transform: scale()`로 레터박스 처리합니다.
- 바깥 여백: 좌우 **120px**. 헤더 위치 top 72px, 본문 시작 top 약 200px, 푸터 bottom 56–110px.
- 기본 글꼴: **Pretendard Variable** (CDN: `cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable.min.css`). 전역 `letter-spacing: -0.02em`. 큰 제목은 -0.04 ~ -0.045em.
- 보조 글꼴: B는 **JetBrains Mono**(번호, 레이블), C는 **Noto Serif KR** 600(제목). 둘 다 Google Fonts.
- 최소 본문 크기 20px, 일반 본문 24–28px.
- 숫자에는 `font-variant-numeric: tabular-nums`를 적용합니다.
- 로고: `assets/logo.svg`(흰색 단색, viewBox 194.6×48). 시안에서는 CSS mask로 색을 입혔습니다(A 남색, B 흰색, C 초록).

---

## Template A — Clinical Grid

### Tokens
| Token | Hex | 용도 |
|---|---|---|
| ink | `#0B1B3A` | 제목, 본문 강조, 진한 패널 |
| sub | `#5A6478` | 보조 텍스트 |
| line | `#D9DEE7` | 1px 구분선 |
| acc | `#1F5EFF` | 유일한 강조색 (번호, 키워드) |
| bg | `#FFFFFF` | 배경 |
| soft | `#F3F5F9` | 연한 패널 |
| red | `#E5372B` | LIVE 표시 전용 |
Radius 0, 그림자 없음. 구분은 괘선으로만 합니다.

### Header (본문 공통)
절대 위치 left/right 120, top 72, flex space-between. 왼쪽: 번호(acc, 22px/600) – 40×2px ink 막대 – 섹션명(ink). 오른쪽: 로고 150px(ink).
### Footer
bottom 56, 위쪽 1px line, padding-top 20, 20px sub. 왼쪽 "메디링크 강원 제품소개서", 오른쪽 페이지 번호.

### A1 표지
- 오른쪽 사진 `cover-ai-hand.jpg` 760×1080, 화면 오른쪽 끝에 붙임, background-position 30% center.
- 로고 220px ink, left 120 / top 96.
- 텍스트 블록 left 120 / top 330 / width 960:
  - "AI MEDICAL PORTAL FOR GANGWON" 26px/700, acc, letter-spacing 0.12em
  - "메디링크 강원 / 제품소개서" 112px/800, line-height 1.12, margin-top 36
  - "강원도민의 건강, 묻고 잇고 찾는 AI 의료 포털" 38px/500 sub, margin-top 48
- 하단 줄 left 120 / bottom 96 / width 920, 위쪽 2px ink 선, 22px sub. 왼쪽 "강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업", 오른쪽 "(주)센텀인터넷"

### A2 해결할 문제 (헤더 번호 02, 페이지 03)
- 2열 그리드 `600px 1fr`, gap 120, top 200.
- 왼쪽: 제목 68px/800 lh 1.25 "의료 정보는 많지만 / **도민에게는**(acc) / 찾기 어렵다". 설명 28px sub, lh 1.6, mt 40.
- 오른쪽: 2×2 그리드, 위쪽 2px ink 선. 셀 padding 44/40/48, 아래쪽 1px line, 오른쪽 열은 왼쪽 1px line과 padding-left 40, min-height 300. 셀 구성: 번호 "01–04" 30px/700 acc → 제목 38px/700 (mt 28) → 설명 26px sub lh 1.6 (mt 18).

### A3 응급실 LIVE (06 / 07)
- 제목 top 200: "지금 갈 수 있는 응급실을 / 실시간으로 확인한다" 68px/800.
- 3열 그리드 `1fr 1fr 560px`, gap 40, top 460, height 480:
  1. 사진 `ambulance.jpeg` cover
  2. soft 패널 padding 48: LIVE 표시(빨간 점 14px + "LIVE 연계" 24px/700 red) → 36px/700 "국립중앙의료원 공공데이터 실시간 연계" → 26px sub "응급실 병상 가용 현황을 제공합니다." → 맨 아래 위쪽 1px line, 22px 안내문 "병상 현황은 수시로 변동되므로 이용 전 문의가 필요합니다."
  3. ink 패널(흰 글자) padding 48: "빠른 전화 연결" 24px 투명도 .7. 아래쪽에 3행. 각 행은 위쪽 1px rgba(255,255,255,.2) 선, 번호 52px/800 + 레이블 22px. 내용: 119 화재·구조·구급 / 1339 응급의료 상담 / 1577-1000 보건복지상담센터

---

## Template B — Midnight Signal

### Tokens
| Token | Value | 용도 |
|---|---|---|
| bg | `#07122B` | 배경 |
| panel | `#0E1D40` | 카드 |
| line | `rgba(160,190,255,.16)` | 선, 그리드 gap 배경 |
| ink | `#F2F5FB` | 텍스트 |
| sub | `#93A3C4` | 보조 텍스트 |
| acc | `#4FD1FF` | 신호색, 강조 |
| alert | `#FF5D4F` | LIVE·경보, 병상 2개 이하 |
카드 그리드는 `gap: 2px; background: line` 방식으로 2px 헤어라인을 만듭니다. Radius 0.

### Header
왼쪽: 번호 배지(1px acc 테두리, padding 6/14, JetBrains Mono 20px acc) + 섹션명 22px/600 + 영문 18px sub, letter-spacing .08em. 오른쪽: 로고 150px.

### B1 표지
사진을 전면에 깔고 opacity .55, 그 위에 `linear-gradient(90deg, #07122B 0%, #07122B00 70%)`. 로고 오른쪽 위(right 120, top 96). 텍스트는 오른쪽 정렬(right 120, top 360): 모노 24px acc 영문 → "메디링크 강원" 120px/800 → "제품소개서" 120px/200 → 34px sub 부제. 하단 줄은 위쪽 1px line, 22px sub.

### B2 해결할 문제
제목 top 210, 72px/800: "의료 정보는 많지만 / 도민에게는 찾기 어렵다(acc)". 그 아래 4열 카드(top 520 ~ bottom 110). 카드 padding 48/40: "/01" 모노 22px acc가 맨 위, 제목 36px/700과 설명 24px sub는 맨 아래.

### B3 응급실 LIVE
- 왼쪽 열(width 760): LIVE 배지(1px alert 테두리, 점 12px) → 제목 68px/800 → 설명 28px sub → 전화 카드 3개(2px gap, padding 28, 번호 40px/800, 레이블 20px).
- 오른쪽 패널(width 820, top 210 ~ bottom 110, panel 배경, 1px line 테두리, padding 48): 모노 헤더 "ER BED STATUS · 예시 화면 / 갱신 14:32". 행 3개(위쪽 1px line, padding 34): 병원명 32px/700 + 지역 22px sub, 병상 수 64px/800(2 이하이면 alert, 아니면 acc) + "병상" 22px. 맨 아래 안내문 20px.
- **실제 구현 시 국립중앙의료원 응급실 가용병상 API와 연동할 수 있습니다.** 이 경우 갱신 시각 표기가 필수입니다.

---

## Template C — Gangwon Care

### Tokens
| Token | Hex | 용도 |
|---|---|---|
| bg | `#F5F2EC` | 미색 배경 |
| ink | `#13261F` | 텍스트 |
| sub | `#5F6B64` | 보조 텍스트 |
| line | `#D8D2C6` | 선 |
| acc | `#1E5B47` | 포레스트 그린 (강조, 로고) |
| mint | `#CFE6D8` | 진한 카드 위의 번호 |
| alert | `#C8452F` | 119 카드 |
| card | `#FFFFFF` | 카드 |
Radius: 카드 24px, 전화 카드 20px. 그림자 없음.

### Header
섹션명 22px/600 acc(왼쪽), 로고 150px acc(오른쪽).

### C1 표지
왼쪽 사진 `senior-phone.jpeg` 860×1080 (position center 30%). 오른쪽 블록 left 980: 로고 220px(top 96) → 영문 24px/600 acc .1em(top 340) → 명조 80px/600 lh 1.3 "강원도민의 건강, / 묻고 잇고 찾는 / AI 의료 포털" → 36px/700 "메디링크 강원 제품소개서". 하단 줄은 위쪽 1px line, 22px sub, 사업명 · (주)센텀인터넷.

### C2 해결할 문제
명조 제목 68px 한 줄(top 200). 4열 카드(top 400 ~ bottom 110, gap 32, padding 48/40): 명조 숫자 80px acc → 맨 아래에 제목 36px/700과 설명 25px sub. **3번째 카드(지역마다 다른 이동 여건)만 acc 배경에 흰 글자**로 강조합니다. 강원 지역 특수성을 부각하기 위해서입니다.

### C3 응급실 LIVE
오른쪽 사진 `ambulance.jpeg` 800×1080. 왼쪽 블록 width 880: 명조 제목 68px "지금 갈 수 있는 곳을 / 먼저 확인합니다" → 28px sub 설명 → 전화 카드 3열(gap 20, padding 32/28, 번호 44px/800). 119 카드만 alert 배경에 흰 글자 → 아래 안내문 22px(위쪽 1px line).

---

## Interactions & Behavior
정적인 슬라이드입니다. HTML 덱으로 구현하는 경우:
- ←/→, Space로 슬라이드 이동. 현재 슬라이드는 localStorage에 저장합니다.
- 1920×1080 고정 캔버스를 뷰포트에 맞춰 스케일합니다.
- 인쇄/PDF는 슬라이드 한 장당 한 페이지(`@page { size: 1920px 1080px }`).
- (선택) B의 LIVE 점에 1.6s ease-in-out 무한 pulse(opacity 1→.35)를 줍니다.

## State Management
정적 덱이라 필요 없습니다. 실데이터 연동(B3)을 하는 경우 `{ hospital, region, beds, updatedAt }[]`를 받아오고, 오류가 나면 "현황을 불러올 수 없습니다 · 1339 문의" 안내로 대체합니다.

## Remaining Slides — Content (원본 원고)
02 서비스 소개 · 04 서비스 흐름(질문→근거→행동, 01–03) · 05 탐색 방식(증상/지역/진료과) · 06 통합 정보(병·의원 찾기/질병 정보/약국 찾기, "모든 결과에 출처와 갱신 시각을 표기합니다.") · 08 AI 상담 도우미(3단계 + "AI는 안내자") · 09 신뢰의 기반(근거 중심/행동 중심/지역 맥락/전문 판단 존중) · 10 기대효과와 확장(도민 편익/사업 확장성, 문의: (주)센텀인터넷 031-261-7093). 원고 원문은 원본 PPTX를 기준으로 합니다.

## Assets
| 파일 | 출처 | 사용처 |
|---|---|---|
| `assets/cover-ai-hand.jpg` | 원본 PPTX media/image1 | A1, B1 표지 |
| `assets/senior-phone.jpeg` | 원본 image3 | C1 표지 (원본 02장) |
| `assets/phone-app.jpeg` | 원본 image4 | 서비스 흐름 장에 사용 가능 (원본 04장) |
| `assets/ambulance.jpeg` | 원본 image11 | A3, C3 |
| `assets/logo.svg` | 원본 image2 | 전 템플릿 로고 (흰색 단색, mask로 색 지정) |

## Files
- `템플릿 추천.html` — 3개 템플릿 × 3장을 보여주는 비교 캔버스 (진입점)
- `tpl-shared.jsx` — 공통 원고 데이터(`MLK`), `MlkSlide`(1920×1080 프레임), `MlkLogo`, `MlkPhoto`
- `tpl-a.jsx` / `tpl-b.jsx` / `tpl-c.jsx` — 각 템플릿의 토큰과 슬라이드 컴포넌트
- `design_canvas.jsx` — 비교용 캔버스 (구현 대상 아님)
