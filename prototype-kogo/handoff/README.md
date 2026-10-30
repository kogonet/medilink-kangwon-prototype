# 메디링크 강원 리뉴얼 — 개발 반영 패키지 (2026-10-30)

## 1. 개요
- 기준 소스: 개발팀 전달 zip (2026-10-27 수령본)
- 방식: 원안 파일은 그대로 두고, 리뉴얼 레이어 파일 7개를 추가해 동작
- 원안 수정: 데코레이터 2개에 각 4줄 추가 + 메인 index.jsp 2곳 (patch/ 참고)
- 하위 페이지: 화면 구성이 새로 바뀌어 본문 마크업 교체 필요 (prototype/ 참고)

## 2. UX 컨셉
- 프롬프트 중심 설계: 하단 프롬프트 독이 모든 페이지의 공통 입력창
- 모듈러 방식: 대화·옵션 패널·병원 AI·지도를 같은 셸 안의 모듈로 연결
- 페이지 이동 최소화: 메인에서 질문 → 같은 자리에서 대화로 전환, 병원 AI는 대화 위 하위 세션으로 열림
- 지도는 '병·의원 찾기' 화면 하나로 통일 (메인 대화의 지도 버튼도 이 화면으로 이동)
- 목표: 서비스 일체감 강화 (헤더·퀵메뉴·푸터·독을 전 페이지 동일하게)

## 3. 패키지 구성
| 폴더 | 내용 | 용도 |
|---|---|---|
| `webapp/` | `common/front/kor/css·js` 리뉴얼 파일 7개 | 웹앱 루트에 그대로 복사 |
| `patch/` | 데코레이터 2개, index.jsp 변경 내용 | 해당 위치에 줄 추가·삭제 |
| `prototype/` | 시안 13개 화면 + 같은 리뉴얼 파일 | 화면·동작 참고 |

### 3-1. 리뉴얼 파일 (webapp/common/front/kor/)
| 파일 | 대상 | 내용 |
|---|---|---|
| `css/rn.css` | 전 페이지 | 토큰, 프롬프트 독, 공통 셸(헤더·퀵메뉴·푸터), 메인 대화, 병원 AI 세션, 공통 지도 모듈 |
| `css/rn-main.css` | 메인 | 메인 히어로 보정 (화이트 배경) |
| `css/rn-sub.css` | 하위 | 병·의원/약국/응급실/계정/문서 본문 |
| `css/rn-docs.css` | 문서 | 이용약관·정보공개·사업소개·회사소개·찾아오시는길·서비스가이드 |
| `js/rn.js` | 전 페이지 | 원안 메인 정리 → 셸 주입 → 지도 모듈 → 프롬프트 독 → 병원 AI 세션 |
| `js/rn-main.js` | 메인 | 대화 영역 주입, 히어로 배경, 메인 대화 |
| `js/rn-sub.js` | 하위 | 지도·목록, 응급실, 계정 폼, 서비스가이드 |

### 3-2. 하위 페이지 대응
| 시안 | 원안 JSP | body class |
|---|---|---|
| `hospital.html` | `hospitalList.jsp` | `op_sub op_map` |
| `pharmacy.html` | `pharmacyList.jsp` | `op_sub op_map` |
| `er-live.html` | `erLive.jsp` | `op_sub op_er` |
| `terms` · `info` · `project` · `directions.html` | `footer/` 동일 이름 JSP | `op_sub op_info` |
| `company.html` | `footer/intro.jsp` | `op_sub op_info` |
| `guide.html` | 신규 (서비스가이드) | `op_sub op_info` |
| `login` · `join` · `find-account.html` | 회원 화면 | `op_sub op_acc` |

- body class = 레이아웃 분기 키 (하위 데코레이터가 이미 body.class 를 전달함)
- 계정 페이지(`op_acc`): 헤더만 표시, 퀵메뉴·푸터·독 없음
- 시안 본문은 `<main>` 안쪽만 옮기면 됨 (헤더·퀵메뉴·푸터·독·병원 AI 는 rn.js 가 주입)

## 4. 적용 순서
1. `webapp/common` → 웹앱 루트 `/common` 에 복사 (기존 파일 덮어쓰기 없음, 신규 7개)
2. `patch/default_medical.jsp.txt` → 메인 데코레이터에 4줄 추가
3. `patch/default_medical_sub.jsp.txt` → 하위 데코레이터에 4줄 추가, 문서 JSP 에 rn-docs.css 1줄
4. `patch/index.jsp.txt` → 메인 예외 2곳 반영
5. 하위 페이지 JSP 본문 교체 + body class 지정 (3-2 표)
6. `rn.js` 의 ROUTES 를 실제 주소(.do)로 변경 (5-1)

## 5. 설정 지점 (rn.js)
### 5-1. ROUTES — 셸 링크 경로
- 시안 값: `hospital.html` 등 → 실제: `/front/medical/hospitalList.do` 등
- 페이지에서 `window.RN_ROUTES = {…}` 로 덮어써도 됨

### 5-2. BRAND — 로고·서비스명
- 헤더 로고(`logo`), 푸터 로고(`logoWhite`), 서비스명(`name`), 대체 텍스트(`alt`)
- 로고 변경 시: 이미지 2개 교체 + BRAND 값만 수정

### 5-3. 공통 지도 모듈 (RNMap)
- 사용처: 병·의원 찾기, 약국 찾기, 메인 대화의 지도 버튼(→ 병·의원 찾기로 이동)
- 호출: `RNMap.mount(요소, 기관목록, { id, label, mapBtn })`
- 기관 형식: `{ g: 시·군, t: 기관명, a: 주소, tel, k: 종류, s: 상태, p: [x%, y%] }`
- 페이지 마크업: `<section class="mp" id="mp" data-label="병·의원"></section>` 만 둠
- 메인 → 지도 이동: `병·의원 찾기?from=chat`, 결과는 sessionStorage 로 전달 (실서비스는 검색 조건을 쿼리로 넘겨 서버 결과로 대체)
- 실제 지도 SDK 연동 시: 모듈 안 `.mp_map`(핀·확대/축소)만 교체

### 5-4. 병원 AI 하위 세션
- 진입: 퀵메뉴 '강원대학교병원', 헤더 병원 아이콘
- 병원 정보: `HOSPITALS` (현재 강원대학교병원 1곳)
- 응답: `reply()` 는 목업 → 병원별 AI 엔드포인트 호출로 교체

## 6. 시안 전용 (반영 대상 아님)
- 하위 페이지 샘플 데이터: `MP_DATA`(병·의원·약국), `ER`(응급실) → 서버 데이터로 교체
- 메인 대화 답변: 목업 → AI 상담 API 로 교체
- 유튜브·블로그·인스타그램 칩 URL, 강원대학교병원 홈페이지 URL: 확정 후 입력

## 7. 후속 전달 예정
- 메인 히어로 배경 이미지: 테스트 중, 확정 후 전달 (현재는 화이트 배경)
- 로고: 메디링크 → 메디플로 변경 예정 (5-2 BRAND 로 교체)

## 8. 확인 필요
- 하위 페이지는 시안에서 원안 `landing.css` 만 깔고 검증함 → 원안 `style.css`·`footer.css`·`medical_header.css` 와 함께 로드 시 충돌 여부 확인
- 원안 헤더(`.gm_header`)는 rn.css 에서 숨김 처리 (셸 헤더 사용)

## 9. 시안 보는 법
- `prototype/` 폴더를 웹앱 루트 아래에 두고 개발 서버로 열기 (예: `/prototype/index.html`)
- 원안 자원(`/common/front/kor/css/landing.css`, `/common/front/kor/js/landing.js`, 이미지)을 절대경로로 쓰므로 파일 더블클릭(file://)으로는 일부가 깨짐

## 10. 검증
- 13개 화면 × 2개 폭(1440·390): 리팩토링 전후 픽셀 비교 차이 0
- 주요 동작: 옵션 패널, 대화 전환, 병원 AI 질문·접기, 지도/목록 전환, 서비스가이드, 로그인 제출, 메인 → 지도 이동 → 뒤로 가기
- 콘솔 오류 0건
