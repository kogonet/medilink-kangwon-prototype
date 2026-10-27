# 메디링크 강원 · Mediflo 웹앱 및 프로토타입

강원 지역 의료 포털의 JSP 웹 리소스, AI 상담 화면, 리뉴얼 프로토타입과 제품 소개 자료를 모은 저장소입니다. 기존 저장소의 리뉴얼 화면·브랜드 자료와 `webapp` 프로젝트를 함께 관리합니다.

## 빠르게 화면 확인하기

Python 3가 설치된 환경에서 다음 명령을 실행합니다.

```bash
git clone https://github.com/kogonet/medilink-kangwon-prototype.git
cd medilink-kangwon-prototype
python3 -m http.server 8000 --bind 127.0.0.1
```

브라우저에서 다음 주소를 엽니다. 서버 종료는 `Ctrl+C`입니다.

| 주소 | 내용 |
|---|---|
| http://127.0.0.1:8000/index.html | 기존 리뉴얼 프로토타입 진입점 |
| http://127.0.0.1:8000/pt-ai/knuh/html/main/knuh_ai.html | AI 상담 정적 화면 |
| http://127.0.0.1:8000/introduce/mediflo.html | 제품 소개 화면 |

정적 서버는 HTML·CSS·JavaScript·이미지를 제공합니다. JSP, `*.do` 요청, 로그인, DB 조회, 실제 AI 상담은 이 명령으로 실행되지 않습니다. 외부 CDN을 사용하는 화면은 인터넷 연결이 필요합니다.

## 프로젝트 구조

```text
.
├── index.html                 # 리뉴얼 프로토타입 진입점
├── index.jsp                  # 관리자 로그인 .do 경로로 전달
├── main-renewal/               # 메인 화면 리뉴얼 스타일
├── intro-renewal/              # 회사소개 및 하단 메뉴 프로토타입
├── medical-service-restyle/    # 응급실·병원 목록 리뉴얼 스타일
├── medilink-kangwon/           # 브랜드 소개와 BI/SVG 에셋
├── WEB-INF/
│   ├── web.xml                # Servlet·필터·Spring 초기화 설정
│   ├── config/                # 로컬 설정 예제와 Spring MVC 설정
│   ├── jsp/                   # 관리자·사용자·AI 상담 JSP
│   ├── lib/                   # 번들 JAR 라이브러리
│   ├── tlds/                  # JSP 커스텀 태그 정의
│   └── decorators.xml         # SiteMesh 레이아웃 매핑
├── META-INF/                  # 매니페스트와 라이선스 자료
├── common/                    # 공통·관리자·사용자 CSS/JS/폰트/이미지
├── pt-ai/                     # AI 상담 화면별 정적 리소스
│   ├── knuh/                  # 정적 상담 시안과 공통 에셋
│   ├── gwtpax2/               # 상담 리소스
│   ├── gwtpax3/               # 상담 리소스
│   ├── gwtpax4/               # 상담 리소스와 답변 블록 템플릿
│   ├── gwtpax5/               # 상담 리소스와 답변 블록 템플릿
│   └── tips/                  # 안내 화면 에셋
├── plug-in/                   # 에디터·업로더·문서 뷰어 등
├── images/                    # 공통 이미지
├── introduce/                 # 제품 소개 HTML/JSP·덱·디자인 자료
└── docs/renewal-prototype.md   # 기존 리뉴얼 적용 가이드
```

`pt-ai/@pt-ai/`에는 별도의 시안 리소스도 포함되어 있습니다. 날짜나 `_bak` 접미사가 붙은 기존 파일은 전달받은 자료의 일부로 보존했습니다.

## 서버 애플리케이션 실행

### 현재 저장소로 가능한 범위

`WEB-INF/web.xml`은 Servlet 2.5 형식이며 Spring MVC, eGovFramework, SiteMesh를 참조합니다. `*.do` 요청은 Spring `DispatcherServlet`으로 전달되고, 뷰는 `/WEB-INF/jsp/` 아래의 JSP로 해석됩니다.

현재 저장소에는 `pom.xml`, Gradle 빌드 파일, Java 소스, `WEB-INF/classes`가 없습니다. 번들 JAR에도 Spring/eGovFramework 실행에 필요한 전체 의존성이 갖춰져 있지 않습니다. 따라서 이 저장소만으로 완전한 서버를 빌드하거나 기동할 수 없습니다. 정확한 JDK·Tomcat 버전도 포함된 자료만으로 확정할 수 없으므로 기존 서버의 검증된 구성을 사용해야 합니다.

### 준비할 구성물

- 기존 애플리케이션의 Java 소스 및 빌드 설정 또는 실행 가능한 WAR/클래스
- Spring/eGovFramework와 애플리케이션 의존 라이브러리
- `classpath*:egovframework/spring/context-*.xml`에 해당하는 Spring 설정
- `com.ctit.filter.LoginCheckFilter` 등 `web.xml`과 MVC 설정이 참조하는 클래스
- DB 연결 설정, 스키마·데이터 및 필요한 외부 서비스 접근 권한
- 기존 서버와 호환되는 JDK 및 `javax.servlet` 기반 Servlet/JSP 컨테이너

### 로컬 설정 복원

새로 clone한 저장소 루트에서 실행합니다. 기존 설정이 있으면 덮어쓰지 않습니다.

```bash
cp -n WEB-INF/config/config.properties.example WEB-INF/config/config.properties
cp -n common/niceid/checkplus_join.jsp.example common/niceid/checkplus_join.jsp
cp -n common/niceid/checkplus_findId.jsp.example common/niceid/checkplus_findId.jsp
cp -n common/niceid/checkplus_findPw.jsp.example common/niceid/checkplus_findPw.jsp
cp -n WEB-INF/jsp/common/niceid/checkplus_success.jsp.example WEB-INF/jsp/common/niceid/checkplus_success.jsp
```

예제의 `REPLACE_WITH_LOCAL_VALUE`, `REPLACE_WITH_LOCAL_CREDENTIAL`을 실제 환경 값으로 채우고, 나머지 주소·경로·식별자도 실행 환경에 맞게 확인합니다.

| 설정 영역 | 확인할 내용 |
|---|---|
| `DEV.Globals.*` | 서비스 주소, 파일·콘텐츠 저장 경로 및 쓰기 권한 |
| `DEV.VWorld.*`, `DEV.NMC.*` | 지도·공공데이터 API 인증값 |
| `DEV.GwtpaxAi*.*` | 상담 버전별 LLM/Agent 주소, 모델, 테넌트, 스트리밍 설정 |
| Weaviate·Embed·Rerank·ClovaSpeech 관련 항목 | 사용하는 기능의 서비스 주소와 인증값 |
| `DEV.Debug.Ssh*` | 해당 기능을 사용하는 경우에만 SSH 접속 정보와 키 경로 |
| NICE JSP 예제 | 본인인증 서비스의 로컬 인증정보 |

SSH 키가 필요한 환경은 `WEB-INF/config/llm_server_key`를 별도로 공급합니다. 실제 설정·키·인증정보가 있는 JSP 원본은 `.gitignore`로 제외되어 있습니다. 자세한 제외 목록은 [REPOSITORY_SETUP.md](REPOSITORY_SETUP.md)를 참고하세요.

### 배포·확인 순서

1. 기존 서버 프로젝트에 이 저장소의 웹 리소스를 반영합니다. 기존 저장소의 리뉴얼 CSS는 [적용 가이드](docs/renewal-prototype.md)에 따라 필요한 화면에 추가합니다.
2. 서버 클래스, Spring 설정, 의존 라이브러리, DB와 외부 서비스 설정을 함께 구성합니다.
3. 기존 서버 프로젝트의 빌드 절차로 WAR를 만들거나, 구성물이 완비된 웹앱을 기존 Servlet 컨테이너에 배포합니다.
4. 서버 로그에서 클래스 로딩·Spring 초기화·DB 연결 오류를 확인합니다.
5. 실제 컨텍스트 경로를 기준으로 `/index.do` 및 `/admmgr/member/login.do`를 확인합니다. `index.jsp`는 관리자 로그인 경로로 전달합니다.

이 절차는 포함된 설정을 기준으로 정리한 배포 안내이며, 서버 구성물이 없는 현재 환경에서 전체 서비스 기동은 검증하지 않았습니다.

## 화면 수정 시 참고

- JSP 화면: `WEB-INF/jsp/`, 레이아웃: `WEB-INF/jsp/decorators/` 및 `WEB-INF/decorators.xml`
- 공통 스타일·스크립트: `common/`, 상담 버전별 에셋: `pt-ai/`
- AI 답변 블록 템플릿: [상담4 가이드](pt-ai/gwtpax4/publisher/README.md), [상담5 가이드](pt-ai/gwtpax5/publisher/README.md)
- 리뉴얼 CSS 적용·브랜드 규칙: [기존 프로토타입 가이드](docs/renewal-prototype.md)
- 제품 소개 덱: `introduce/`, [디자인 전달 자료](introduce/design_handoff_medilink_deck_templates/README.md)

하위 가이드에 언급된 서버 문서나 관리자 기능은 원래 서버 프로젝트에 속하며, 일부는 이 저장소에 포함되어 있지 않습니다.
