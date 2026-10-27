# 상담4 답변 퍼블리셔 템플릿 작성 안내

> **2026-10-21 부터 블록 틀은 관리자 화면(`/admmgr/ai4/design.do` → 답변 디자인 → [틀] 탭)에서 편집합니다.**
> 이 폴더는 관리자 화면에 틀이 하나도 없을 때만 쓰이며, 관리자 화면의 **[파일 세트 가져오기]** 로 옮길 수 있습니다
> (가져온 뒤 임시 저장·게시해야 반영됩니다). 틀 문법·안전 규칙은 아래와 같고, 관리자 화면에서도 똑같이 검사합니다.
> 설계: `docs/specs/2026-10-21-ai4-cms-block-templates.md`

AI 상담4(`/gwtpax/ai-consult4.do`) 답변의 블록 모양을 퍼블리셔가 직접 만드는 폴더입니다 (2026-10-16, 답변 템플릿 빌더 방식 2).
관리자는 코드를 보지 않고, 관리자 화면(`/admmgr/ai4/design.do`)에서 미리보기로 확인한 뒤 **"틀 사용"**(2026-10-21 전 이름: "퍼블리셔 템플릿 사용") 을 체크해 게시합니다.
체크하지 않으면 이 폴더는 답변에 영향이 없습니다.

## 폴더 구성

```
publisher/
  manifest.json          이름·버전, 블록별 템플릿 파일, CSS 파일
  blocks/{블록}.html      블록 틀 (HTML 조각)
  publisher.css          퍼블리셔 CSS (여러 개 가능)
```

`manifest.json` 예:

```json
{
  "name": "2026 가을 디자인",
  "version": "2026-10-20",
  "blocks": { "facility-list": "blocks/facility-list.html", "health-info": "blocks/health-info.html" },
  "css": ["publisher.css"]
}
```

- 템플릿이 없는 블록은 관리자 화면의 기본 디자인(방식 1)으로 그려집니다.
- 파일은 이 폴더 안에만 둘 수 있습니다 (`../` 금지). 템플릿 50KB, CSS 200KB 이하.
- 파일을 고치면 서버가 10초 안에 다시 읽습니다. 배포 후 관리자 화면 미리보기로 확인하세요.

## 블록 틀 쓰는 법

블록 틀에는 **내용이 들어갈 자리**만 표시합니다. 내용(문구·표·버튼·탭)은 시스템이 만들어 넣습니다.

| 표시 | 뜻 |
|---|---|
| `data-ab-slot="칸"` | 그 칸의 내용이 이 요소 안에 들어갑니다 |
| `data-ab-if="칸"` | 그 칸에 내용이 없으면 이 요소를 지웁니다 (감싸는 상자·제목용) |

```html
<div class="pb-card">
  <div class="pb-card__head">
    <span class="pb-badge">기관 목록</span>
    <div data-ab-slot="head"></div>
  </div>
  <div class="pb-card__table" data-ab-slot="table"></div>
  <div data-ab-if="more"><div data-ab-slot="more"></div></div>
  <div class="pb-card__foot" data-ab-slot="foot"></div>
</div>
```

- **블록별 칸 이름**: `docs/specs/2026-10-16-ai4-answer-blocks.md` 의 "블록 종류와 칸" 표, 또는 관리자 화면의 블록 목록.
- 틀에 자리가 없는 칸은 블록 끝에 붙습니다 (내용이 사라지지 않음). 관리자 화면에 "자리가 없는 칸" 으로 알려 줍니다.
- 표·지도 연결·[상세] 버튼·탭은 시스템이 `data-*` 표시까지 붙여 만들므로 퍼블리셔가 따로 만들 필요가 없습니다.

## 응급·안전 안내 (2026-10-22 변경)

- **응급 안내**, **증상 안내** 블록과 119·진단 아님 같은 안내 칸도 다른 블록·칸과 똑같이 틀·CSS 로 바꿀 수 있습니다 (시스템이 강제로 막거나 틀 밖에 붙이지 않음).
- 이 안내를 어떻게 보여 줄지(배치·크기·문구)는 퍼블리싱·운영 검토에서 정합니다.

## 쓸 수 없는 것 (검사에서 걸리면 그 블록은 기본 모양)

- 태그: `script` `iframe` `object` `embed` `link` `style` `form` `meta` `base` `frame` `svg` `math` — CSS 는 CSS 파일에 씁니다.
- `onclick` 같은 이벤트 속성, `javascript:` 주소, `srcdoc`
- 없는 칸 이름
- CSS: `@import`, 외부 주소 `url(https://…)`·`url(//…)`, `expression()`, `behavior`, `javascript:`

화면에서도 DOMPurify 로 한 번 더 거릅니다. `input`·`button` 같은 입력 요소도 지워집니다.

## CSS 선택자 안내

| 선택자 | 대상 |
|---|---|
| `.ab[data-publisher]` | 퍼블리셔 틀로 그린 블록 (선택자는 이 아래로 한정하는 것을 권장) |
| `.ab[data-block="facility-list"]` | 블록 종류 |
| `.ab__part[data-slot="head"][data-kind="text"]` | 칸 내용 |
| `table[data-role="list-table"]`, `tr[data-item-index]` | 목록 표, 행 |
| `[data-role="item-no"]`, `[data-role="item-name"]` | 기관 번호, 이름 |
| `[data-action="route"]`, `[data-action="detail"]` | 길찾기, 상세 버튼 |
| `[data-slot="tabs"] .ai2-tabs button` | 건강정보 탭 칩 |

방식 1(관리자 디자인 값) CSS 는 퍼블리셔 틀로 그린 블록에는 걸리지 않습니다. 문구는 관리자 화면에서 고친 문구를 함께 씁니다.

## 변수·행 반복·할당 (2026-10-21, 관리자 화면 틀)

관리자 화면 [틀] 탭의 틀은 위 표시 외에 아래 문법을 더 쓸 수 있습니다 (publisher 폴더 파일 틀은 위 표시만). 자세한 것은 `docs/specs/2026-10-21-ai4-cms-block-templates-phase2-4.md`.

| 표시 | 뜻 |
|---|---|
| `{region}` | 블록 변수 값 (관리자 화면 "변수" 칩). 행 반복 안에서는 행 필드(`{name}` 등)도 |
| `{#v}…{/v}` / `{^v}…{/v}` | 값이 있을 때만 / 없을 때만 보이는 글자 (태그를 넘지 않게) |
| `data-ab-show="v"` / `data-ab-hide="v"` | 값이 있을 때만 / 없을 때만 남는 요소 |
| `data-ab-each="rows"` | 목록 행마다 복제 (표 대신 카드 목록, 지도와 자동 연결) |
| `data-ab-group="sggu"` | 행 필드 값으로 묶어 묶음마다 복제 (안에 `data-ab-each`) |
| `data-ab-action="route\|detail\|tel\|homepage"` | 길찾기·상세·전화·홈페이지 버튼 자리 (안 글자 = 버튼 글자) |
| `<img data-ab-asset="img-loading.png">` | 답변 자산 폴더(`pt-ai/gwtpax4/answer-assets/`)의 그림 |
| `data-ab-map` | 지도를 넣을 자리 |

- `href`·`src` 에는 `{변수}` 를 쓸 수 없습니다 (주소는 버튼 표시로 시스템이 넣음).
- 블록마다 틀을 여러 개 만들고(`{블록}.{이름}`), [할당] 탭에서 AI 가 쓴 도구(출처)·조건별로 고를 수 있습니다.
