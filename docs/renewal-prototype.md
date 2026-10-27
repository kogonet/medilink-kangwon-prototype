# 메디링크 강원 (MediLink Kangwon) · 프로토타입

강원도민을 위한 병의원·질병·응급 AI 응대형 메디컬 포털 서비스의 리뉴얼 프로토타입입니다.
기존 서비스명 '강원 메디컬 AI / 헬로메디강원'을 **메디링크 강원**으로 변경하고, Hello.Persona 스타일 체계(흑백, 1px 라인, 각진 면, 플랫)를 적용했습니다.

브라우저에서 바로 보려면 [`index.html`](index.html)을 여세요. (GitHub Pages를 켜면 링크로 공유할 수 있습니다.)

## 폴더 구성

| 폴더 | 대상 | 성격 | 개발 반영 방법 |
|---|---|---|---|
| `main-renewal/` | 메인 `index.do` | 스타일 전용 레이어 | `landing.css`, `medical_header.css` 다음에 `main-restyle.css` 1개 추가 |
| `medical-service-restyle/` | `erLive.do`, `hospitalList.do` | 스타일 전용 레이어 | `style.css`, `medical_header.css` 다음에 `medical-service-restyle.css` 1개 추가 |
| `intro-renewal/` | 하단 메뉴 페이지 5종 (회사소개·이용약관·정보공개·사업소개·찾아오시는길) | 회사소개는 스타일 레이어(`renewal-layer.css`), 나머지 4종은 새 스타일로 재구성한 프로토 | 회사소개: `renewal-layer.css` 추가 / 나머지: 화면 참고용 |
| `medilink-kangwon/` | 브랜드 · 서비스 컨셉 | 네이밍·심볼·BI 소개 페이지 | 참고용 |
| `*/assets/` | BI · 심볼 SVG | 글자 윤곽선 처리 완료 (서체 설치 불필요) | 로고 파일 교체 |

스타일 레이어는 HTML·JS를 바꾸지 않습니다. color · background · border · radius · shadow · font-weight 등만 덮어쓰며, JS 토글 클래스(`.on`, `.is_open`, `.sel` 등)는 그대로 동작합니다.

## 마크업 변경이 필요한 곳 (예외)

- **헤더 로고**: `logo.svg` → `assets/medilink-bi-dark.svg` (히어로 위 오버레이) / `assets/medilink-bi.svg` (흰 배경)
- **하단 브랜드**: 텍스트 '강원메디컬 AI' → `<img class="footer_bi" src="assets/medilink-bi-white.svg" alt="메디링크 강원">`
- **서비스명 텍스트**: 페이지 제목, 공지·FAQ 문구, 저작권(© MediLink Kangwon)
- **이용약관 본문**의 서비스명 변경은 법무 검토 후 반영

## 컬러 규칙

| 용도 | 값 | 비고 |
|---|---|---|
| 글자 블루 | `#004EA2` | 새 블루는 글자에 쓰기에 강해서 기존 블루 유지 |
| 면·선·버튼 블루 | `#0038C3` | 버튼 배경, 테두리, 선택 표시, 심볼 |
| 연한 블루 면 | `#E9EEFA` | |
| 잉크 / 그레이 / 라인 | `#090909` / `#F1F1F1` / `#DEDEDE` | |
| 응급 레드 | `#E5202E` | 119 버튼에만 사용. 상담 번호(1339·1577-1000)는 흰 외곽선 |

각 CSS 파일 상단의 토큰만 바꾸면 일괄 변경됩니다.

## 서체

- 국문: Pretendard (메디링크 500 / **강원** 700)
- 영문: Montserrat (MediLink 500 / **Kangwon** 700)

## 심볼

- 크기 비율은 황금비: 중심 세포 R : 우측 상단 R/φ : 연결부·dot R/φ²
- 기본은 톤온톤 그라데이션(`#0038C3` → `#A9C4FF`), 32px 이하·인쇄·각인은 단색(`medilink-symbol-mono.svg`)

## 프로토 전용 처리 (실서비스 반영 대상 아님)

- 메인 히어로의 배경 영상 자리는 그레이로 영역만 표시 (영상 소스 추후 교체)
- `main-restyle.css` 맨 끝의 **[버그 수정 · 선택 적용]** 1줄: 모바일에서 검색 영역이 화면 밖으로 넘치는 기존 현상 수정. 레이아웃에 영향을 주는 유일한 줄이므로 적용 여부 판단 필요
- 공지·FAQ 연결 게시판은 이번 범위에서 제외
