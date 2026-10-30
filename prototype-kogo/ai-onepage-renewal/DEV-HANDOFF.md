# 메디링크 강원 리뉴얼 — 개발 반영 가이드

기준: 개발 원안 = 저장소의 `prototype-kogo/` 를 뺀 소스(커밋 `5097876`, 개발팀 전달본).
원칙: **원안 파일은 고치지 않는다.** 리뉴얼은 원안 위에 얹는 레이어 파일 7개로 동작한다.
원안 마크업을 바꿔야 하는 곳은 아래 [예외] 목록뿐이다.

## 1. 추가할 파일 (7개)

`prototype-kogo/ai-onepage-renewal/common/front/kor/` 를 웹앱 루트의 `/common/front/kor/` 에 그대로 복사한다.

| 파일 | 대상 | 내용 |
|---|---|---|
| `css/rn.css` | 모든 페이지 | 토큰·히어로, 프롬프트 독, 공통 셸(헤더·퀵메뉴·푸터), 원페이지 대화, 병원 AI 하위 세션, 공통 지도 모듈(`.mp`) |
| `css/rn-main.css` | 메인 | 메인 히어로 보정(화이트 배경 등) |
| `css/rn-sub.css` | 하위 페이지 | 병·의원/약국/응급실/계정/문서 본문 |
| `css/rn-docs.css` | 문서 페이지 | 이용약관·정보공개·사업소개·회사소개·찾아오시는길·서비스가이드 본문 (`.ip`, `.gd` 스코프) |
| `js/rn.js` | 모든 페이지 | 원안 메인 정리 → 공통 셸 주입 → 공통 지도 모듈(`RNMap`) → 프롬프트 독 → 병원 AI 하위 세션 |
| `js/rn-main.js` | 메인 | 대화 영역·패널 주입, 히어로 엠비언트, 원페이지 대화 |
| `js/rn-sub.js` | 하위 페이지 | 지도·목록·응급실·계정 폼·서비스가이드 동작 |

각 파일 안의 `═══ (구 …) ═══` 머리말이 예전 파일명(구 renewal-dock.js, onepage.css 등)과의 대응이다.

## 2. 로드 위치

원안 CSS 다음, 원안 스크립트 다음에 둔다(순서가 중요).

**메인 — `WEB-INF/jsp/decorators/default_medical.jsp`**

```jsp
<link rel="stylesheet" href="/common/front/kor/css/medical_header.css">   <%-- 원안 --%>
<link rel="stylesheet" href="/common/front/kor/css/rn.css">
<link rel="stylesheet" href="/common/front/kor/css/rn-main.css">
</head>
…
</script>   <%-- 원안 헤더 스크립트 --%>
<script src="/common/front/kor/js/rn.js" defer></script>
<script src="/common/front/kor/js/rn-main.js" defer></script>
</body>
```

**하위 — `WEB-INF/jsp/decorators/default_medical_sub.jsp`**

```jsp
<link rel="stylesheet" href="/common/front/kor/css/rn.css">
<link rel="stylesheet" href="/common/front/kor/css/rn-sub.css">
<%-- 문서 페이지(footer/*.jsp, 서비스가이드)는 페이지 head 에 rn-docs.css 추가 --%>
…
<script src="/common/front/kor/js/rn.js" defer></script>
<script src="/common/front/kor/js/rn-sub.js" defer></script>
```

## 3. 원안 마크업 예외

### 메인 `front/medical/index.jsp` — 2곳

| # | 내용 | 이유 |
|---|---|---|
| E1 | `gsap.min.js`, `ScrollTrigger.min.js`, `landing_motion.js` 3줄 삭제 | 히어로 스크롤 모션이 리뉴얼 히어로·프롬프트 독과 충돌 |
| E2 | `.search_desc` 문구를 "병의원·질병·응급까지, AI가 공공데이터를 근거로 가까운 의료기관과 다음 행동을 안내합니다."로 변경 | 문구 확정분 |

프로토타입 `index.html` 은 원안 데코레이터 + 원안 `index.jsp` 를 그대로 옮긴 것이며, 위 2곳만 `[RN 예외]` 주석으로 표시돼 있다.

그 밖의 차이는 `rn.js` 의 **원안 메인 정리** 블록이 런타임에 처리한다. 원안 마크업을 지울 여력이 생기면 아래 요소를 지우고 이 블록도 함께 지운다.

- 히어로 바로가기 칩(`.hero_chips`), '의료 서비스 보기'(`.service_link`)
- 의료 서비스·AI Concierge·공지/FAQ 섹션, 원안 푸터(`.footer_wrap`)
- 원안 퀵메뉴(`.quick_wrap`): 셸이 공통 퀵메뉴(예방접종 + 강원대학교병원)로 다시 그린다
- 고지 문구(`.hero_note`): `.op_fnote` 로 바꿔 입력창 아래로 옮긴다
- 원안 헤더(`.gm_header`): `rn.css` 에서 숨긴다(셸 헤더 사용)

### 하위 페이지 — 본문 교체

병·의원/약국/응급실 LIVE·계정·문서 페이지는 화면 구성이 새로 바뀌어 **본문(`<main>`) 마크업을 교체**해야 한다.
프로토타입 각 HTML 의 `<body>` 에는 본문만 남겨 두었다(헤더·퀵메뉴·푸터·독·병원 세션은 `rn.js` 가 주입).

| 프로토타입 | 원안 JSP | body class |
|---|---|---|
| `hospital.html` | `hospitalList.jsp` | `op_sub op_map` |
| `pharmacy.html` | `pharmacyList.jsp` | `op_sub op_map` |
| `er-live.html` | `erLive.jsp` | `op_sub op_er` |
| `terms.html` · `info.html` · `project.html` · `directions.html` | `footer/terms·info·project·directions.jsp` | `op_sub op_info` |
| `company.html` | `footer/intro.jsp` | `op_sub op_info` |
| `guide.html` | (신규) | `op_sub op_info` |
| `login.html` · `join.html` · `find-account.html` | (회원 화면) | `op_sub op_acc` |

- body class 가 레이아웃 분기 키다. 하위 데코레이터가 페이지의 `body.class` 를 넘기도록 해야 한다(메인 데코레이터와 같은 방식).
- 계정 페이지(`op_acc`)는 헤더만 주입하고 퀵메뉴·푸터·독은 두지 않는다.
- 프로토타입 하위 페이지는 원안 `landing.css` 만 깔고 검증했다. 원안 `style.css`·`footer.css` 를 함께 로드하는 JSP 에 붙일 때는 충돌 여부를 확인한다.

## 4. 공통 지도 모듈 (`RNMap`)

지도 화면은 병·의원 찾기 페이지 하나로 통일한다(약국 찾기도 같은 모듈).
`RNMap.mount(요소, 기관목록, { id, label, mapBtn })` 로 그리며, 기관은 `{ g: 시·군, t: 기관명, a: 주소, tel, k: 종류, s: 상태, p: [x%, y%] }` 형식이다.
페이지에서는 `<section class="mp" id="mp" data-label="병·의원">` 만 두면 된다.

메인 대화에서 지도를 열면(헤더 지도 아이콘, 답변의 '지도로 보기') 오버레이를 쓰지 않고 `병·의원 찾기?from=chat` 으로 이동한다.
답변의 기관 목록은 `sessionStorage['rn.mapItems']` 로 넘기며, 실서비스에서는 검색 조건을 쿼리로 넘겨 서버 결과를 그리면 된다.
뒤로 가기 하면 메인이 `?q=` 로 같은 질문을 다시 보여 준다.
실제 지도 SDK 를 붙일 때는 모듈 안의 `.mp_map`(핀 그리기·확대·축소)만 교체한다.

## 5. 링크 경로

셸 링크는 `rn.js` 의 `ROUTES` 한 곳에 모여 있다. 프로토타입 값은 `.html` 이므로 실제 주소(`/front/medical/hospitalList.do` 등)로 바꾸거나, 페이지에서 `window.RN_ROUTES = {…}` 로 덮어쓴다.

## 6. 반영 대상이 아닌 것 (프로토 전용)

- 하위 페이지의 샘플 데이터(`MP_DATA`, `ER`): 서버 데이터로 교체
- 병원 AI 하위 세션의 응답: `rn.js` 의 `reply()` 목업을 병원별 AI 엔드포인트 호출로 교체(KNUH 등)
- 유튜브·블로그·인스타그램 칩의 URL, 강원대학교병원 홈페이지 URL(`HOSPITALS[].home`)은 확정 후 입력
- `_experimental/`: 히어로 배경 이미지 실험(패럴랙스·terrain). 현재 페이지에 연결하지 않음
- `ai-result-renewal/`: 이전 시안. 옛 리뉴얼 파일은 `ai-result-renewal/legacy/` 로 옮겨 그 폴더 안에서만 쓴다

## 7. 검증

리팩토링 전후로 13개 페이지 × 2개 폭(1440·390)의 전체 화면과 주요 동작(옵션 패널, 대화 전환, 병원 세션 질문·접기, 지도/목록 전환, 서비스가이드 스크롤, 로그인 제출) 화면을 픽셀 비교해 차이 0을 확인했다. 콘솔 오류도 0건이다.
