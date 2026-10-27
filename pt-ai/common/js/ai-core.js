/**
 * PT-AI 공통 코어 (ai-core.js)
 *
 * [역할]
 *   프로젝트별 ai-consult.js(UI)와 서버 API 사이의 AI 엔진 계층.
 *   JSP가 주입한 window.PT_AI_BOOT 설정을 읽어 API 호출·렌더·채팅 흐름을 처리한다.
 *
 * [전체 흐름]
 *   1. JSP → PT_AI_BOOT (config.properties + 컨트롤러가 model로 전달)
 *   2. ai-consult.js → PT_AI_CHAT.startChat(query) 호출
 *   3. startChat → 멀티턴 DOM 추가 → PT_AI_ANSWER.dispatch
 *   4. dispatch → data-answer-type이 <template id>와 일치하면 템플릿, 아니면 LLM/RAG
 *   5. answerWithLlm → PT_AI_API.send → RAG(jobId+SSE) 또는 LLM(SSE/JSON)
 *   6. 스트림 청크 → PT_AI_RENDER.apply → 마크다운 DOM 반영
 *
 * [전역 export]
 *   PT_AI_CONFIG  설정·세션·URL
 *   PT_AI_API     서버 fetch / EventSource
 *   PT_AI_RENDER  마크다운·타이핑 연출
 *   PT_AI_AVATAR  스레드별 아바타 이미지
 *   PT_AI_ANSWER  답변 생성·중단·템플릿
 *   PT_AI_CHAT    멀티턴 채팅 오케스트레이션 (ai-consult.js 진입점)
 */
(function (global) {
  "use strict";

  // JSP <script> 블록에서 주입. ANDONG_AI_BOOT는 하위 호환 fallback
  var boot = global.PT_AI_BOOT || global.ANDONG_AI_BOOT || {};

  // --- PT_AI_API 내부 상태 (동시 요청·중단 제어) ---
  var activeEventSource = null;   // RAG/LLM SSE 연결
  var activeFetchController = null;
  var abortRequested = false;
  var firstQuestion = true;       // RAG 첫 질문 여부 (서버에 firstQuestion 전달)
  var lastJobId = null;           // 마지막 RAG jobId (디버그 trace용)

  // --- PT_AI_RENDER 내부 상태 ---
  var mdInstance = null;          // markdown-it 싱글톤

  // --- PT_AI_ANSWER 내부 상태 ---
  var answerBusy = false;
  var answerAborted = false;
  var streamChunkReceived = false;
  var renderTimer = null;         // 스트림 렌더 스로틀 타이머
  var pendingAnswerText = "";
  var templateAnswerTimer = null;
  var templateStreamHandle = null;
  var activeBody = null;          // 현재 답변 영역

  // ---------------------------------------------------------------------------
  // DOM 계약 (data-role)
  //   JS가 DOM을 찾을 때 사용하는 셀렉터 상수.
  //   퍼블리셔가 class를 변경·삭제해도 JS 동작이 깨지지 않도록
  //   JSP 템플릿의 구조 훅을 class 대신 data-role 속성으로 분리.
  //   CSS 스타일 규칙은 기존 class 선택자(kp-*) 기준으으로 유지.
  // ---------------------------------------------------------------------------
  var ROLE = {
    // 1턴 전체 래퍼. appendTurn에서 cloneNode 후 thread·pill·body를 탐색하는 기준점.
    // JSP: tpl-chat-turn > div[data-role="thread"]
    thread:     '[data-role="thread"]',

    // 질문 pill 텍스트 노드. streamText로 타이핑 연출 대상이 되며,
    // data-ai-streaming 속성이 붙는 동안 CSS 커서 애니메이션이 적용됨.
    // CSS: [data-role="query-pill"][data-ai-streaming]::after (kpta/andong/wiltse ai-consult.css)
    // JSP: tpl-chat-turn > ... > span[data-role="query-pill"]
    queryPill:  '[data-role="query-pill"]',

    // LLM/RAG 답변이 렌더되는 본문 영역. showLoading·showError·flushAnswerRender의 대상.
    // data-ai-loading 속성이 붙어 있는 동안 로딩 상태임을 나타냄.
    // JSP: tpl-chat-turn > ... > div[data-role="answer-body"]
    answerBody: '[data-role="answer-body"]',

    // 질문(사용자) 쪽 아바타 스파크. applySparkAvatar가 이미지 경로를 적용하는 대상.
    // 이미지 설정 시 data-ai-avatar="image" 속성이 붙고 <img>가 삽입됨.
    // CSS: [data-ai-avatar="image"] (kpta/andong/wiltse ai-consult.css)
    // JSP: tpl-chat-turn > ... > div[data-role="user-spark"]
    userSpark:  '[data-role="user-spark"]',

    // 답변(봇) 쪽 아바타 스파크. applySparkAvatar가 이미지 경로를 적용하는 대상.
    // CSS: [data-ai-avatar="image"] (kpta/andong/wiltse ai-consult.css)
    // JSP: tpl-chat-turn > ... > div[data-role="bot-spark"]
    botSpark:   '[data-role="bot-spark"]',

    // 답변 템플릿 내 표 스크롤 래퍼. streamTemplate에서 표 단위 reveal 애니메이션의 기준점.
    // data-ai-pending 속성으로 숨겨두었다가 행 스트리밍 완료 시 제거해 노출.
    // style.display로 JS가 직접 제어하므로 CSS 규칙 없어도 동작.
    // JSP: ai-answer-templates.jsp > div[data-role="table-wrap"]
    tableWrap:  '[data-role="table-wrap"]',

    // 빠른검색 항목 텍스트 노드. (현재 미사용, 향후 타이핑 연출 확장 예비 훅)
    qitemText:  '[data-role="qitem-text"]'
  };

  // ---------------------------------------------------------------------------
  // JS 런타임 상태 속성 (data-ai-*)
  //   JS가 DOM 상태를 CSS에 알릴 때 class 대신 사용하는 속성 이름 상수.
  //   퍼블리셔 class와 충돌 없이 상태 스타일을 적용할 수 있도록 분리.
  // ---------------------------------------------------------------------------
  var ATTR = {
    // 스트림 진행 중. streamText·streamTemplate 시작 시 setAttribute, 완료·취소 시 removeAttribute.
    // CSS: [data-role="query-pill"][data-ai-streaming]::after — 커서 깜빡임 애니메이션
    streaming: "data-ai-streaming",

    // 템플릿 스트리밍 중 아직 노출되지 않은 행/표. markStreamPending에서 set, revealStreamEl에서 remove.
    pending:   "data-ai-pending",

    // 답변 로딩 중(LLM 응답 대기). showLoading에서 set, flushAnswerRender에서 remove.
    // (현재 CSS 규칙 없음 — 필요 시 [data-ai-loading] 선택자로 스피너 등 추가 가능)
    loading:   "data-ai-loading",

    // 아바타 스파크 이미지 모드. applySparkAvatar에서 경로가 있으면 "image"로 set, 없으면 remove.
    // CSS: [data-ai-avatar="image"] — 흰 배경·border·img 표시 규칙 (kpta/andong/wiltse ai-consult.css)
    avatar:    "data-ai-avatar"
  };

  // --- PT_AI_CHAT ↔ ai-consult.js 콜백 (순환 참조 방지용 uiBindings 분리) ---
  var uiBindings = {
    onBusyChange: null,
    onScroll: null,
    onChatActivated: null,
    onShowLoading: null,
    onShowError: null,
    onShowAborted: null
  };
  var chatBusy = false;
  var queryStreamHandle = null;   // 질문 pill 타이핑 연출 핸들
  var activeTurn = null;          // { threadEl, answerBody }
  var turnSeq = 0;

  // =========================================================================
  // 유틸
  // =========================================================================

  /** 문자열/불리언을 boolean으로 변환. JSP에서 넘어온 streamEnabled 등에 사용 */
  function toBool(value, defaultValue) {
    if (value === undefined || value === null || value === "") {
      return defaultValue;
    }
    if (typeof value === "boolean") {
      return value;
    }
    return String(value).toLowerCase() === "true";
  }

  /** sessionStorage에 저장할 클라이언트 세션 ID 생성 */
  function createSessionId() {
    return (
      "kp_" +
      Date.now().toString(36) +
      "_" +
      Math.random().toString(36).slice(2, 11)
    );
  }

  // =========================================================================
  // PT_AI_CONFIG — boot 기반 런타임 설정
  // =========================================================================

  var config = {
    apiBase: boot.apiBase || "",           // 컨트롤러 프록시 기준 (/kpta/api 등)
    tenant: boot.tenant || "",             // RAG tenant
    chatMode: boot.chatMode || "rag",      // rag | llm
    streamEnabled: toBool(boot.streamEnabled, true),
    renderMode: boot.renderMode || "markdown",
    llmModel: boot.llmModel || "gemma4:e4b-it-q4_K_M",
    avatarBot: boot.avatarBot || "",
    avatarUser: boot.avatarUser || "",
    moduleId: boot.moduleId || boot.tenant || "pt-ai",  // sessionStorage 키 구분
    queryStreamDelayMs: typeof boot.queryStreamDelayMs === "number" ? boot.queryStreamDelayMs : 22,
    minQuestionLength: 4,
    renderThrottleMs: 40,                  // 스트림 답변 DOM 갱신 간격(ms)
    endpoints: {
      ragQuery: "/queryRag.do",
      ragEvents: "/queryEvents.do",
      llmChat: "/chat.do",
      llmStream: "/chatStream.do"
    },
    /** moduleId별 sessionStorage 키로 세션 유지. 탭 단위 멀티턴 대화 식별 */
    getSessionId: function () {
      var sessionKey = "pt_ai_" + this.moduleId + "_session_id";
      try {
        var stored = sessionStorage.getItem(sessionKey);
        if (stored && stored.length > 1) {
          return stored;
        }
        var created = createSessionId();
        sessionStorage.setItem(sessionKey, created);
        return created;
      } catch (e) {
        return createSessionId();
      }
    },
    /** apiBase + endpoints[키] 로 컨트롤러 프록시 URL 조합 */
    buildUrl: function (endpointKey) {
      var path = this.endpoints[endpointKey];
      if (!path) {
        return this.apiBase;
      }
      return this.apiBase + path;
    }
  };

  // =========================================================================
  // DOM / UI 이벤트 (ai-consult.js 콜백 브릿지)
  // =========================================================================

  function resolveMainEl() {
    return document.getElementById("main");
  }

  function resolveChatScrollEl() {
    return document.getElementById("chat-scroll");
  }

  /** 답변·채팅 busy 상태 변경 시 ai-consult.js onBusyChange 호출 (전송 버튼 등) */
  function emitBusyChange(busy) {
    chatBusy = !!busy;
    if (typeof uiBindings.onBusyChange === "function") {
      uiBindings.onBusyChange(chatBusy);
    }
  }

  /** 채팅 영역 스크롤. 콜백 없으면 #chat-scroll 하단으로 자동 스크롤 */
  function emitScroll() {
    if (typeof uiBindings.onScroll === "function") {
      uiBindings.onScroll();
      return;
    }
    var chatScroll = resolveChatScrollEl();
    if (!chatScroll) return;
    requestAnimationFrame(function () {
      chatScroll.scrollTop = chatScroll.scrollHeight;
    });
  }

  /** 첫 질문 시 채팅 레이아웃 활성화. 레이아웃 class 조작은 콜백이 담당 */
  function activateChatLayout() {
    if (typeof uiBindings.onChatActivated === "function") {
      uiBindings.onChatActivated();
      return;
    }
    // 콜백 미등록 시 fallback
    var mainEl = resolveMainEl();
    if (mainEl) {
      mainEl.classList.add("kp-main--chat");
    }
  }

  function getConfig() {
    return config;
  }

  // =========================================================================
  // PT_AI_API — 서버 프록시 호출 (RAG / LLM, SSE)
  // =========================================================================

  /** 활성 EventSource 연결 종료 */
  function stopStream() {
    if (activeEventSource) {
      activeEventSource.close();
      activeEventSource = null;
    }
  }

  function clearFetchController() {
    activeFetchController = null;
  }

  /**
   * 새 요청 시작: 이전 SSE·fetch 중단 후 AbortController 반환.
   * 반환 signal을 fetch에 넘겨 사용자 중단(abort)에 대응한다.
   */
  function beginRequest() {
    abortRequested = false;
    stopStream();
    if (activeFetchController) {
      try {
        activeFetchController.abort();
      } catch (e) {
        /* ignore */
      }
    }
    activeFetchController = new AbortController();
    return activeFetchController.signal;
  }

  /** 진행 중 fetch·SSE 전부 중단 플래그 설정 */
  function abort() {
    abortRequested = true;
    if (activeFetchController) {
      try {
        activeFetchController.abort();
      } catch (e) {
        /* ignore */
      }
      activeFetchController = null;
    }
    stopStream();
  }

  function isAborted() {
    return abortRequested;
  }

  /** fetch AbortController 중단 시 발생하는 에러 판별 */
  function isAbortError(err) {
    return !!(err && (err.name === "AbortError" || err.code === 20));
  }

  /** options.stream > config.streamEnabled > true 순으로 스트리밍 여부 결정 */
  function resolveStreamEnabled(options) {
    if (typeof options.stream === "boolean") {
      return options.stream;
    }
    var cfg = getConfig();
    if (typeof cfg.streamEnabled === "boolean") {
      return cfg.streamEnabled;
    }
    return true;
  }

  /** sendRag/sendLlm 공통 콜백 옵션 정규화 (onChunk/onDone/onError 등) */
  function normalizeHandlers(options) {
    options = options || {};
    return {
      stream: resolveStreamEnabled(options),
      onChunk: typeof options.onChunk === "function" ? options.onChunk : function () {},
      onProgress: typeof options.onProgress === "function" ? options.onProgress : function () {},
      onDone: typeof options.onDone === "function" ? options.onDone : function () {},
      onError: typeof options.onError === "function" ? options.onError : function () {}
    };
  }

  /** RAG 전송 전 질문 길이·tenant·sessionId 검증 */
  function validateQuestion(question) {
    var cfg = getConfig();
    var q = String(question || "").trim();
    if (q.length < (cfg.minQuestionLength || 4)) {
      return { ok: false, message: "질문을 조금 길게 입력해주세요. (4자 이상)" };
    }
    if (!cfg.tenant || cfg.tenant.length < 2) {
      return { ok: false, message: "tenant 설정이 올바르지 않습니다." };
    }
    if (!cfg.getSessionId || !cfg.getSessionId()) {
      return { ok: false, message: "세션 정보가 없습니다. 페이지를 새로고침 후 다시 시도해주세요." };
    }
    return { ok: true, message: "", question: q };
  }

  /** SSE 초기 연결 핸드셰이크 [connected] 무시용 */
  function isConnectedHandshake(text) {
    return /^\[connected\]/i.test(String(text || "").trim());
  }

  /** RAG done 이벤트가 메타 JSON(모델 정보)인지 최종 텍스트인지 구분 */
  function isFinalDonePayload(payload) {
    if (!payload) {
      return false;
    }
    try {
      var data = JSON.parse(payload);
      return !!(data && (data.model || data.created_at || data.total_duration !== undefined));
    } catch (e) {
      return false;
    }
  }

  /**
   * SSE payload에서 실제 텍스트 청크 추출.
   * JSON {chunk|content|text|delta|message} 또는 plain text 모두 처리.
   */
  function extractStreamChunk(raw) {
    var text = String(raw || "");
    if (!text) {
      return "";
    }
    try {
      var data = JSON.parse(text);
      if (typeof data === "string") return data;
      if (data && data.chunk) return String(data.chunk);
      if (data && data.content) return String(data.content);
      if (data && data.text) return String(data.text);
      if (data && data.delta) return String(data.delta);
      if (data && data.message) return String(data.message);
    } catch (e) {
      /* plain text chunk */
    }
    return text;
  }

  /**
   * RAG 2단계 중 2단계: queryRag.do가 반환한 jobId로 queryEvents.do SSE 구독.
   * 이벤트: stream/message/progress/done/fail/error
   */
  function connectRagSse(jobId, handlers) {
    var cfg = getConfig();
    var url = new URL(cfg.buildUrl("ragEvents"), window.location.origin);
    url.searchParams.set("jobId", jobId);
    url.searchParams.set("sessionId", cfg.getSessionId());

    stopStream();
    activeEventSource = new EventSource(url.toString());
    var buffer = "";
    var doneReceived = false;

    function appendChunk(raw) {
      if (isAborted()) return;
      var chunk = extractStreamChunk(raw);
      if (!chunk) return;
      buffer += chunk;
      if (handlers.stream) {
        handlers.onChunk(buffer, chunk);
      }
    }

    function finishStream(finalText) {
      if (isAborted() || doneReceived) return;
      doneReceived = true;
      if (finalText) {
        buffer = String(finalText);
        if (handlers.stream) {
          handlers.onChunk(buffer, buffer);
        }
      }
      if (!handlers.stream) {
        handlers.onChunk(buffer, buffer);
      }
      handlers.onDone(buffer);
      stopStream();
    }

    activeEventSource.addEventListener("stream", function (evt) {
      appendChunk(evt.data || "");
    });
    activeEventSource.addEventListener("message", function (evt) {
      if (isAborted()) return;
      var data = String(evt.data || "");
      if (isConnectedHandshake(data)) {
        handlers.onProgress(data);
        return;
      }
      appendChunk(data);
    });
    activeEventSource.addEventListener("progress", function (evt) {
      if (isAborted()) return;
      handlers.onProgress(evt.data || "");
    });
    activeEventSource.addEventListener("done", function (evt) {
      if (isAborted()) return;
      var payload = evt && evt.data ? String(evt.data).trim() : "";
      if (!payload) return;
      if (isFinalDonePayload(payload)) {
        finishStream(buffer);
        return;
      }
      if (!buffer) {
        buffer = extractStreamChunk(payload) || payload;
      }
      finishStream(buffer);
    });
    activeEventSource.addEventListener("fail", function (evt) {
      if (isAborted()) return;
      var message = "오류가 발생하였습니다.";
      try {
        var data = evt.data ? JSON.parse(evt.data) : null;
        if (data && data.message) {
          message = String(data.message);
        }
      } catch (e) {
        if (evt.data) {
          message = String(evt.data);
        }
      }
      handlers.onError(message);
      stopStream();
    });
    activeEventSource.addEventListener("error", function (evt) {
      if (isAborted()) return;
      if (evt && evt.data) {
        handlers.onError(String(evt.data));
        stopStream();
      }
    });
    activeEventSource.onerror = function () {
      if (isAborted()) return;
      if (buffer) {
        finishStream(buffer);
      } else {
        handlers.onError("연결이 종료되었습니다. 잠시 후 다시 시도해주세요.");
        stopStream();
      }
    };
  }

  /**
   * RAG 질의 1단계: POST queryRag.do → jobId 수신 → connectRagSse.
   * @param {string} question
   * @param {Object} options onChunk/onDone/onError/stream
   */
  function sendRag(question, options) {
    var cfg = getConfig();
    var handlers = normalizeHandlers(options);
    var checked = validateQuestion(question);
    if (!checked.ok) {
      handlers.onError(checked.message);
      return Promise.reject(new Error(checked.message));
    }

    var signal = beginRequest();
    return fetch(cfg.buildUrl("ragQuery"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        question: checked.question,
        sessionId: cfg.getSessionId(),
        firstQuestion: firstQuestion
      }),
      signal: signal
    })
      .then(function (response) {
        if (isAborted()) return null;
        if (!response.ok) throw new Error("HTTP " + response.status);
        return response.json();
      })
      .then(function (payload) {
        if (!payload || isAborted()) return;
        clearFetchController();
        if (firstQuestion) firstQuestion = false;
        var jobId = payload && payload.jobId;
        if (!jobId) throw new Error("jobId가 없습니다.");
        lastJobId = String(jobId);
        connectRagSse(jobId, handlers);
      })
      .catch(function (err) {
        clearFetchController();
        if (isAborted() || isAbortError(err)) return;
        handlers.onError(err && err.message ? err.message : "요청 처리에 실패했습니다.");
        throw err;
      });
  }

  /** LLM 스트리밍: GET chatStream.do EventSource */
  function connectLlmSse(prompt, handlers) {
    var cfg = getConfig();
    var url = new URL(cfg.buildUrl("llmStream"), window.location.origin);
    url.searchParams.set("prompt", prompt);
    url.searchParams.set("model", cfg.llmModel || "");

    stopStream();
    activeEventSource = new EventSource(url.toString());
    var buffer = "";
    var doneReceived = false;

    function appendChunk(raw) {
      if (isAborted()) return;
      var chunk = extractStreamChunk(raw);
      if (!chunk) return;
      buffer += chunk;
      if (handlers.stream) {
        handlers.onChunk(buffer, chunk);
      }
    }

    function finishStream(finalText) {
      if (isAborted() || doneReceived) return;
      doneReceived = true;
      if (finalText) {
        buffer = String(finalText);
        if (handlers.stream) {
          handlers.onChunk(buffer, buffer);
        }
      }
      if (!handlers.stream) {
        handlers.onChunk(buffer, buffer);
      }
      handlers.onDone(buffer);
      stopStream();
    }

    activeEventSource.addEventListener("stream", function (evt) {
      appendChunk(evt.data || "");
    });
    activeEventSource.addEventListener("message", function (evt) {
      if (isAborted()) return;
      var data = String(evt.data || "");
      if (isConnectedHandshake(data)) {
        handlers.onProgress(data);
        return;
      }
      appendChunk(data);
    });
    activeEventSource.addEventListener("done", function () {
      if (isAborted()) return;
      finishStream(buffer);
    });
    activeEventSource.addEventListener("error", function (evt) {
      if (isAborted()) return;
      var message = evt && evt.data ? String(evt.data) : "LLM 스트리밍 오류";
      handlers.onError(message);
      stopStream();
    });
    activeEventSource.onerror = function () {
      if (isAborted()) return;
      if (buffer) {
        finishStream(buffer);
      } else {
        handlers.onError("LLM 연결이 종료되었습니다.");
        stopStream();
      }
    };
  }

  /**
   * LLM 질의. stream=true면 chatStream.do SSE, false면 chat.do JSON 1회 응답.
   */
  function sendLlm(prompt, options) {
    var cfg = getConfig();
    var handlers = normalizeHandlers(options);
    var text = String(prompt || "").trim();
    if (!text) {
      handlers.onError("질문을 입력해주세요.");
      return Promise.reject(new Error("empty prompt"));
    }

    if (handlers.stream) {
      beginRequest();
      clearFetchController();
      connectLlmSse(text, handlers);
      return Promise.resolve();
    }

    var signal = beginRequest();
    return fetch(cfg.buildUrl("llmChat"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        prompt: text,
        model: cfg.llmModel || ""
      }),
      signal: signal
    })
      .then(function (response) {
        if (isAborted()) return null;
        if (!response.ok) throw new Error("HTTP " + response.status);
        return response.json();
      })
      .then(function (payload) {
        if (!payload || isAborted()) return;
        clearFetchController();
        var content = payload && payload.content ? String(payload.content) : "";
        handlers.onChunk(content, content);
        handlers.onDone(content);
        return content;
      })
      .catch(function (err) {
        clearFetchController();
        if (isAborted() || isAbortError(err)) return;
        handlers.onError(err && err.message ? err.message : "LLM 요청에 실패했습니다.");
        throw err;
      });
  }

  /**
   * chatMode(rag|llm)에 따라 sendRag 또는 sendLlm 위임.
   * PT_AI_ANSWER.answerWithLlm의 실질 진입점.
   */
  function send(question, options) {
    var cfg = getConfig();
    var mode = (options && options.mode) || cfg.chatMode || "rag";
    if (mode === "llm") {
      return sendLlm(question, options);
    }
    return sendRag(question, options);
  }

  // =========================================================================
  // PT_AI_RENDER — 마크다운·HTML·타이핑 연출
  // =========================================================================

  function escapeHtml(text) {
    return String(text || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function nl2br(text) {
    return escapeHtml(text).replace(/\r?\n/g, "<br>");
  }

  /** markdown-it 인스턴스 생성 (CDN 로드 여부에 따라 null 가능) */
  function getMarkdownIt(options) {
    if (!global.markdownit) return null;
    return global.markdownit(options || {});
  }

  /** DOMPurify로 XSS 방지. 없으면 escapeHtml fallback */
  function sanitizeHtml(html) {
    if (global.DOMPurify && typeof global.DOMPurify.sanitize === "function") {
      return global.DOMPurify.sanitize(html, { USE_PROFILES: { html: true } });
    }
    return escapeHtml(html);
  }

  function renderMarkdown(text, options) {
    var md = getMarkdownIt(options);
    if (!md) {
      return nl2br(text);
    }
    return sanitizeHtml(md.render(String(text || "")));
  }

  /** renderMode별 변환 함수 맵 (markdown, text, pre, raw 등) */
  var modes = {
    markdown: function (text) {
      if (!mdInstance) {
        mdInstance = getMarkdownIt({
          html: false,
          linkify: true,
          breaks: true,
          typographer: true
        });
      }
      if (!mdInstance) {
        return nl2br(text);
      }
      return sanitizeHtml(mdInstance.render(String(text || "")));
    },
    markdownLite: function (text) {
      return renderMarkdown(text, {
        html: false,
        linkify: true,
        breaks: true,
        typographer: false
      });
    },
    text: function (text) {
      return '<div data-ai-render="text">' + nl2br(text) + "</div>";
    },
    pre: function (text) {
      return '<pre data-ai-render="pre">' + escapeHtml(text) + "</pre>";
    },
    raw: function (text) {
      return (
        '<div data-ai-render="raw">' +
        '<div data-ai-render="raw-label">원문</div>' +
        '<pre data-ai-render="raw-source">' +
        escapeHtml(text) +
        "</pre></div>"
      );
    }
  };

  /** config.renderMode 또는 인자 mode로 HTML 문자열 생성 */
  function render(text, mode) {
    var key = mode || config.renderMode || "markdown";
    var fn = modes[key] || modes.markdown;
    return fn(text);
  }

  /** 렌더된 답변 내 외부 링크에 target=_blank, rel=noopener 적용 */
  function enhanceExternalLinks(root) {
    if (!root || !root.querySelectorAll) return;
    var links = root.querySelectorAll('a[href^="http://"], a[href^="https://"]');
    for (var i = 0; i < links.length; i += 1) {
      links[i].setAttribute("target", "_blank");
      links[i].setAttribute("rel", "noopener noreferrer");
    }
  }

  /**
   * 답변 영역 DOM에 렌더 결과 반영.
   * innerHTML + data-render-mode/data-raw-text 속성 설정.
   */
  function apply(targetEl, text, mode) {
    if (!targetEl) return "";
    var html = render(text, mode);
    targetEl.innerHTML = html;
    enhanceExternalLinks(targetEl);
    targetEl.setAttribute("data-render-mode", mode || "markdown");
    targetEl.setAttribute("data-raw-text", String(text || ""));
    return html;
  }

  /** 한글 등 grapheme 단위 분할 (질문 pill·템플릿 타이핑 연출용) */
  function splitGraphemes(text) {
    var value = String(text || "");
    if (!value) return [];
    if (typeof Intl !== "undefined" && typeof Intl.Segmenter === "function") {
      var segmenter = new Intl.Segmenter("ko", { granularity: "grapheme" });
      return Array.from(segmenter.segment(value), function (part) {
        return part.segment;
      });
    }
    return Array.from(value);
  }

  /**
   * 단일 텍스트 노드에 글자 단위 타이핑 연출.
   * @returns {{ cancel: Function }} 중단용 핸들
   */
  function streamText(targetEl, text, options) {
    options = options || {};
    var fullText = String(text || "");
    var units = splitGraphemes(fullText);
    var delayMs = typeof options.delayMs === "number" ? options.delayMs : 22;
    var onTick = options.onTick;
    var onDone = options.onDone;
    var timer = null;
    var cancelled = false;
    var index = 0;

    if (!targetEl) {
      if (onDone) onDone();
      return { cancel: function () {} };
    }
    if (!units.length) {
      targetEl.textContent = "";
      targetEl.removeAttribute(ATTR.streaming);
      if (onDone) onDone();
      return { cancel: function () {} };
    }

    targetEl.textContent = "";
    targetEl.setAttribute(ATTR.streaming, "");

    function finish() {
      timer = null;
      targetEl.textContent = fullText;
      targetEl.removeAttribute(ATTR.streaming);
      if (onDone) onDone();
    }

    function tick() {
      if (cancelled) return;
      index += 1;
      targetEl.textContent = units.slice(0, index).join("");
      if (onTick) onTick();
      if (index >= units.length) {
        finish();
        return;
      }
      timer = setTimeout(tick, delayMs);
    }

    timer = setTimeout(tick, delayMs);
    return {
      cancel: function () {
        cancelled = true;
        if (timer) {
          clearTimeout(timer);
          timer = null;
        }
        targetEl.removeAttribute(ATTR.streaming);
      }
    };
  }

  /** 템플릿 스트리밍 시 행/문단 단위 reveal 대상 DOM 탐색 */
  function getRevealEl(textNode) {
    var node = textNode.parentElement;
    while (node) {
      var tag = node.tagName;
      if (tag === "TR" || tag === "LI" || tag === "P" || /^H[1-6]$/.test(tag)) {
        return node;
      }
      node = node.parentElement;
    }
    return textNode.parentElement;
  }

  function getTableWrap(textNode) {
    var table = textNode.parentElement && textNode.parentElement.closest("table");
    return table ? table.closest(ROLE.tableWrap) : null;
  }

  function getRowEl(textNode) {
    return textNode.parentElement ? textNode.parentElement.closest("tr") : null;
  }

  /** <template> 복제본 내 모든 텍스트 노드를 세그먼트 배열로 수집 */
  function collectTextSegments(root) {
    var segments = [];
    var walker = document.createTreeWalker(
      root,
      NodeFilter.SHOW_TEXT,
      {
        acceptNode: function (node) {
          return node.nodeValue ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
        }
      }
    );
    var node;
    while ((node = walker.nextNode())) {
      var full = node.nodeValue;
      if (!full) continue;
      segments.push({
        node: node,
        full: full,
        units: splitGraphemes(full),
        pos: 0,
        revealEl: getRevealEl(node),
        rowEl: getRowEl(node),
        tableWrap: getTableWrap(node)
      });
    }
    return segments;
  }

  function markStreamPending(segments) {
    var revealEls = new Set();
    var tableWraps = new Set();
    segments.forEach(function (seg) {
      if (seg.revealEl) revealEls.add(seg.revealEl);
      if (seg.tableWrap) tableWraps.add(seg.tableWrap);
    });
    revealEls.forEach(function (el) { el.setAttribute(ATTR.pending, ""); el.style.display = "none"; });
    tableWraps.forEach(function (el) { el.setAttribute(ATTR.pending, ""); el.style.display = "none"; });
  }

  function clearStreamPending(root) {
    if (!root) return;
    root.querySelectorAll("[" + ATTR.pending + "]").forEach(function (el) {
      el.removeAttribute(ATTR.pending);
      el.style.removeProperty("display");
    });
  }

  function revealStreamEl(el) {
    if (!el) return;
    el.removeAttribute(ATTR.pending);
    el.style.removeProperty("display");
  }

  function revealTableRow(rowEl) {
    if (!rowEl) return;
    revealStreamEl(rowEl.closest(ROLE.tableWrap));
    revealStreamEl(rowEl);
  }

  function isRowSegmentsComplete(rowEl, segments) {
    for (var i = 0; i < segments.length; i += 1) {
      if (segments[i].rowEl === rowEl && segments[i].pos < segments[i].units.length) {
        return false;
      }
    }
    return true;
  }

  /**
   * HTML 템플릿 답변을 글자 단위로 순차 노출 (표 행 단위 reveal 포함).
   * answerType 템플릿 답변 시 PT_AI_ANSWER.answerWithTemplate에서 호출.
   */
  function streamTemplate(targetEl, templateContent, options) {
    options = options || {};
    var delayMs = typeof options.delayMs === "number" ? options.delayMs : 10;
    var charsPerTick = typeof options.charsPerTick === "number" ? options.charsPerTick : 2;
    var onTick = options.onTick;
    var onDone = options.onDone;
    var timer = null;
    var cancelled = false;

    if (!targetEl || !templateContent) {
      if (onDone) onDone();
      return { cancel: function () {} };
    }

    var mount = document.createDocumentFragment();
    mount.appendChild(templateContent.cloneNode(true));
    var segments = collectTextSegments(mount);
    if (!segments.length) {
      targetEl.innerHTML = "";
      targetEl.appendChild(mount);
      if (onDone) onDone();
      return { cancel: function () {} };
    }

    segments.forEach(function (seg) {
      seg.node.nodeValue = "";
    });
    markStreamPending(segments);

    targetEl.innerHTML = "";
    targetEl.appendChild(mount);
    targetEl.setAttribute(ATTR.streaming, "");
    var segIndex = 0;

    function afterSegmentProgress(seg) {
      if (seg.rowEl) {
        if (isRowSegmentsComplete(seg.rowEl, segments)) {
          revealTableRow(seg.rowEl);
        }
        return;
      }
      if (seg.pos > 0) {
        revealStreamEl(seg.revealEl);
      }
    }

    function finish() {
      timer = null;
      segments.forEach(function (seg) {
        seg.node.nodeValue = seg.full;
      });
      clearStreamPending(targetEl);
      targetEl.removeAttribute(ATTR.streaming);
      if (onDone) onDone();
    }

    function tick() {
      if (cancelled) return;
      var remaining = charsPerTick;
      while (remaining > 0 && segIndex < segments.length) {
        var seg = segments[segIndex];
        if (!seg.rowEl && seg.pos === 0) {
          revealStreamEl(seg.revealEl);
        }
        var take = Math.min(remaining, seg.units.length - seg.pos);
        seg.pos += take;
        if (!seg.rowEl) {
          seg.node.nodeValue = seg.units.slice(0, seg.pos).join("");
        }
        remaining -= take;
        if (seg.pos >= seg.units.length) {
          if (seg.rowEl) {
            seg.node.nodeValue = seg.full;
            afterSegmentProgress(seg);
          }
          segIndex += 1;
        } else {
          afterSegmentProgress(seg);
          break;
        }
      }
      if (onTick) onTick();
      if (segIndex >= segments.length) {
        finish();
        return;
      }
      timer = setTimeout(tick, delayMs);
    }

    timer = setTimeout(tick, delayMs);
    return {
      cancel: function () {
        cancelled = true;
        if (timer) {
          clearTimeout(timer);
          timer = null;
        }
        clearStreamPending(targetEl);
        targetEl.removeAttribute(ATTR.streaming);
      }
    };
  }

  // =========================================================================
  // PT_AI_AVATAR — 스레드별 봇/사용자 아바타
  // =========================================================================

  function normalizePath(path) {
    return String(path || "").trim();
  }

  function getBotPath() {
    return normalizePath(config.avatarBot);
  }

  function getUserPath() {
    return normalizePath(config.avatarUser);
  }

  /** 스파크 엘리먼트에 이미지 또는 기본 스파크 UI 적용 */
  function applySparkAvatar(sparkEl, imagePath, hideWhenEmpty) {
    if (!sparkEl) return;
    var path = normalizePath(imagePath);
    if (!path) {
      sparkEl.removeAttribute(ATTR.avatar);
      var existing = sparkEl.querySelector("img");
      if (existing) existing.remove();
      sparkEl.hidden = !!hideWhenEmpty;
      return;
    }
    sparkEl.hidden = false;
    sparkEl.setAttribute(ATTR.avatar, "image");
    var img = sparkEl.querySelector("img");
    if (!img) {
      img = document.createElement("img");
      img.setAttribute("alt", "");
      sparkEl.appendChild(img);
    }
    img.setAttribute("src", path);
  }

  /** 한 턴(data-role="thread") 내 질문·답변 스파크에 config 아바타 경로 적용 */
  function applyToThread(threadEl) {
    if (!threadEl) return;
    var userSpark = threadEl.querySelector(ROLE.userSpark);
    var botSpark = threadEl.querySelector(ROLE.botSpark);
    applySparkAvatar(userSpark, getUserPath(), true);
    applySparkAvatar(botSpark, getBotPath());
  }

  // =========================================================================
  // PT_AI_ANSWER — 답변 생성·중단·템플릿 분기
  // =========================================================================

  function setBusy(value) {
    answerBusy = !!value;
    emitBusyChange(answerBusy);
  }

  function scroll() {
    emitScroll();
  }

  /** data-answer-type이 페이지 내 <template id="...">와 일치하는지 */
  function isTemplateType(answerType) {
    return !!getTemplateEl(answerType);
  }

  /** 채팅 pill에 표시할 질문 라벨 정규화 (KPTA 빠른검색 일부 문구 치환) */
  function normalizeQueryLabel(query) {
    var text = String(query || "");
    if (/교육이수|수료점수|납부 현황/.test(text)) return "교육이수 · 납부 현황 조회";
    if (/보수교육비.*환불|환불.*보수교육비/.test(text)) return "보수교육비 환불 조건";
    if (/면허신고확인서|면허.*출력/.test(text)) return "면허신고확인서 출력 방법";
    return query;
  }

  /** data-answer-type 값으로 <template> 요소 조회 */
  function getTemplateEl(templateId) {
    if (!templateId) return null;
    var el = document.getElementById(templateId);
    if (!el) return null;
    if (typeof HTMLTemplateElement !== "undefined" && el instanceof HTMLTemplateElement) {
      return el;
    }
    if (String(el.tagName).toUpperCase() !== "TEMPLATE") return null;
    return el;
  }

  function appendAbortNotice(body) {
    if (uiBindings.onShowAborted) {
      uiBindings.onShowAborted(body, null);
      return;
    }
    var notice = document.createElement("p");
    notice.textContent = "답변 생성이 중단되었습니다.";
    body.appendChild(notice);
  }

  /** 답변 영역 로딩 상태 표시 */
  function showLoading(body) {
    if (!body) return;
    body.setAttribute(ATTR.loading, "");
    if (uiBindings.onShowLoading) {
      uiBindings.onShowLoading(body);
      return;
    }
    body.textContent = "답변을 생성하고 있습니다...";
  }

  function showError(body, message) {
    if (!body) return;
    body.removeAttribute(ATTR.loading);
    if (uiBindings.onShowError) {
      uiBindings.onShowError(body, message);
      return;
    }
    var safe = global.PT_AI_RENDER ? global.PT_AI_RENDER.escapeHtml(message) : String(message || "오류가 발생했습니다.");
    body.textContent = safe;
  }

  /**
   * 스트림 청크 수신 시 렌더 스로틀.
   * 첫 청크는 즉시, 이후는 renderThrottleMs 간격으로 flushAnswerRender.
   */
  function scheduleAnswerRender(body, text) {
    pendingAnswerText = text || "";
    if (!pendingAnswerText) return;
    if (!streamChunkReceived) {
      streamChunkReceived = true;
      if (renderTimer) {
        clearTimeout(renderTimer);
        renderTimer = null;
      }
      flushAnswerRender(body);
      return;
    }
    var delay = config.renderThrottleMs || 40;
    if (renderTimer) clearTimeout(renderTimer);
    renderTimer = setTimeout(function () {
      renderTimer = null;
      flushAnswerRender(body);
    }, delay);
  }

  /** pendingAnswerText를 마크다운 렌더 후 body에 반영 */
  function flushAnswerRender(body) {
    if (!body || !global.PT_AI_RENDER) return;
    body.removeAttribute(ATTR.loading);
    global.PT_AI_RENDER.apply(body, pendingAnswerText, config.renderMode || "markdown");
    scroll();
  }

  /** LLM/RAG 스트림 완료 시 최종 렌더 + busy 해제 */
  function finishLlmRequest(body) {
    if (renderTimer) {
      clearTimeout(renderTimer);
      renderTimer = null;
    }
    flushAnswerRender(body);
    setBusy(false);
    scroll();
  }

  /** 사용자 중단 시 부분 답변 + 중단 안내 문구 */
  function showAnswerAborted(body, partialText) {
    if (!body) return;
    body.removeAttribute(ATTR.loading);
    var text = String(partialText || "").trim();
    if (uiBindings.onShowAborted) {
      if (text && global.PT_AI_RENDER) {
        global.PT_AI_RENDER.apply(body, text, config.renderMode || "markdown");
      }
      uiBindings.onShowAborted(body, text || null);
      return;
    }
    if (text && global.PT_AI_RENDER) {
      global.PT_AI_RENDER.apply(body, text, config.renderMode || "markdown");
      appendAbortNotice(body);
    } else {
      body.textContent = "답변 생성이 중단되었습니다.";
    }
    scroll();
  }

  /** 템플릿 답변 타이머·스트림 핸들 정리 */
  function cancelTemplate() {
    if (templateAnswerTimer) {
      clearTimeout(templateAnswerTimer);
      templateAnswerTimer = null;
    }
    if (templateStreamHandle && typeof templateStreamHandle.cancel === "function") {
      templateStreamHandle.cancel();
    }
    templateStreamHandle = null;
  }

  /**
   * 고정 HTML 템플릿 답변 경로.
   * 로딩 딜레이 후 streamTemplate으로 타이핑 연출.
   */
  function answerWithTemplate(ctx) {
    var body = ctx.body;
    var type = ctx.answerType;
    var tpl = getTemplateEl(type);
    if (!body || !tpl) return false;
    activeBody = body;
    cancelTemplate();
    showLoading(body);
    setBusy(true);

    var loadingDelay = typeof config.templateLoadingDelayMs === "number" ? config.templateLoadingDelayMs : 1500;
    templateAnswerTimer = setTimeout(function () {
      templateAnswerTimer = null;
      if (!body.parentNode) {
        setBusy(false);
        return;
      }
      body.removeAttribute(ATTR.loading);
      if (global.PT_AI_RENDER && typeof global.PT_AI_RENDER.streamTemplate === "function") {
        templateStreamHandle = global.PT_AI_RENDER.streamTemplate(body, tpl.content, {
          delayMs: typeof config.templateStreamDelayMs === "number" ? config.templateStreamDelayMs : 10,
          charsPerTick: typeof config.templateCharsPerTick === "number" ? config.templateCharsPerTick : 2,
          onTick: scroll,
          onDone: function () {
            templateStreamHandle = null;
            setBusy(false);
            scroll();
          }
        });
      } else {
        body.innerHTML = "";
        body.appendChild(tpl.content.cloneNode(true));
        setBusy(false);
        scroll();
      }
    }, loadingDelay);

    return true;
  }

  /**
   * LLM/RAG 답변 경로.
   * PT_AI_API.send → onChunk 스트림 렌더 → onDone 완료.
   */
  function answerWithLlm(ctx) {
    var body = ctx.body;
    var query = String(ctx.query || "").trim();
    if (!body || !query) return false;
    if (!global.PT_AI_API || typeof global.PT_AI_API.send !== "function") {
      showError(body, "AI API 모듈이 로드되지 않았습니다.");
      return false;
    }
    activeBody = body;
    answerAborted = false;
    streamChunkReceived = false;
    pendingAnswerText = "";
    showLoading(body);
    setBusy(true);
    global.PT_AI_API.send(query, {
      mode: config.chatMode || "rag",
      stream: config.streamEnabled !== false,
      onChunk: function (fullText) {
        if (answerAborted) return;
        scheduleAnswerRender(body, fullText);
      },
      onDone: function (fullText) {
        if (answerAborted) return;
        pendingAnswerText = fullText || pendingAnswerText;
        finishLlmRequest(body);
      },
      onError: function (message) {
        if (answerAborted) return;
        setBusy(false);
        showError(body, message || "요청 처리에 실패했습니다.");
      }
    });
    return true;
  }

  function bindCtx(ctx) {
    if (ctx.body) {
      activeBody = ctx.body;
    }
  }

  /**
   * 답변 요청 진입점. answerType 있으면 템플릿, 없으면 LLM/RAG.
   * @param {Object} ctx { body, query, answerType }
   */
  function dispatch(ctx) {
    ctx = ctx || {};
    if (answerBusy) return false;
    bindCtx(ctx);
    if (isTemplateType(ctx.answerType)) {
      return answerWithTemplate(ctx);
    }
    return answerWithLlm(ctx);
  }

  /** 진행 중 답변 중단 (템플릿·LLM/RAG 공통) */
  function abortAnswer(ctx) {
    if (!answerBusy) return false;
    if (ctx) bindCtx(ctx);
    var body = (ctx && ctx.body) || activeBody;
    if (templateAnswerTimer || templateStreamHandle) {
      cancelTemplate();
      setBusy(false);
      if (body) body.removeAttribute(ATTR.loading);
      scroll();
      return true;
    }
    answerAborted = true;
    if (renderTimer) {
      clearTimeout(renderTimer);
      renderTimer = null;
    }
    flushAnswerRender(body);
    if (global.PT_AI_API && typeof global.PT_AI_API.abort === "function") {
      global.PT_AI_API.abort();
    } else if (global.PT_AI_API && typeof global.PT_AI_API.stop === "function") {
      global.PT_AI_API.stop();
    }
    var partial = pendingAnswerText;
    pendingAnswerText = "";
    setBusy(false);
    showAnswerAborted(body, partial);
    return true;
  }

  /** 홈 이동 시 진행 중 요청·타이머 정리 (세션 리셋은 PT_AI_CHAT.resetForHome) */
  function stopForHome(ctx) {
    if (ctx) bindCtx(ctx);
    cancelTemplate();
    if (renderTimer) {
      clearTimeout(renderTimer);
      renderTimer = null;
    }
    answerAborted = true;
    if (global.PT_AI_API && typeof global.PT_AI_API.abort === "function") {
      global.PT_AI_API.abort();
    } else if (global.PT_AI_API && typeof global.PT_AI_API.stop === "function") {
      global.PT_AI_API.stop();
    }
    pendingAnswerText = "";
    setBusy(false);
  }

  // =========================================================================
  // PT_AI_CHAT — 멀티턴 채팅 오케스트레이션 (ai-consult.js 진입점)
  // =========================================================================

  /** 현재 턴의 답변 body 엘리먼트 */
  function getAnswerBody() {
    return activeTurn ? activeTurn.answerBody : null;
  }

  /**
   * #tpl-chat-turn 복제 후 #chat-scroll에 추가.
   * activeTurn 갱신, 아바타 적용.
   */
  function appendTurn() {
    var tpl = document.getElementById("tpl-chat-turn");
    var chatScroll = resolveChatScrollEl();
    if (!tpl || !chatScroll) return null;
    var fragment = tpl.content.cloneNode(true);
    var thread = fragment.querySelector(ROLE.thread);
    var pill = fragment.querySelector(ROLE.queryPill);
    var body = fragment.querySelector(ROLE.answerBody);
    if (!thread || !pill || !body) return null;
    pill.textContent = "";
    turnSeq += 1;
    thread.setAttribute("data-turn-id", String(turnSeq));
    chatScroll.appendChild(fragment);
    activeTurn = {
      threadEl: chatScroll.lastElementChild,
      answerBody: body
    };
    if (global.PT_AI_AVATAR && typeof global.PT_AI_AVATAR.applyToThread === "function") {
      global.PT_AI_AVATAR.applyToThread(activeTurn.threadEl);
    }
    return activeTurn;
  }

  /** 채팅 히스토리·턴 카운터 초기화 */
  function clearChatHistory() {
    cancelQueryStream();
    var chatScroll = resolveChatScrollEl();
    if (chatScroll) {
      chatScroll.innerHTML = "";
    }
    activeTurn = null;
    turnSeq = 0;
  }

  /** PT_AI_ANSWER.dispatch/abort에 넘길 컨텍스트 (body + UI 콜백) */
  function buildAnswerCtx() {
    return {
      body: getAnswerBody(),
      onBusyChange: emitBusyChange,
      onScroll: emitScroll
    };
  }

  /** 질문 pill 타이핑 연출 취소 */
  function cancelQueryStream() {
    if (queryStreamHandle && typeof queryStreamHandle.cancel === "function") {
      queryStreamHandle.cancel();
    }
    queryStreamHandle = null;
  }

  /** 질문 pill(.kp-chat-query__pill) 타이핑 연출. QueryStreamDelayMs 사용 */
  function showQueryStream(el, text) {
    cancelQueryStream();
    if (!el) return;
    if (!global.PT_AI_RENDER || typeof global.PT_AI_RENDER.streamText !== "function") {
      el.textContent = text;
      return;
    }
    queryStreamHandle = global.PT_AI_RENDER.streamText(el, text, {
      delayMs: config.queryStreamDelayMs || 22,
      onTick: emitScroll
    });
  }

  function isTemplateAnswerType(answerType) {
    return global.PT_AI_ANSWER && global.PT_AI_ANSWER.isTemplateType(answerType);
  }

  // --- 빠른검색·버튼 클릭 → LLM 질문 문자열 변환 ---

  /** 공백·물음표 정리 */
  function normalizeQuerySourceText(text) {
    return String(text || "")
      .replace(/\s+/g, " ")
      .replace(/[?？]+$/, "?")
      .trim();
  }

  /**
   * UI 요소에서 질문 원문 추출.
   * 우선순위: data-query > value > .kp-qitem__text > aria-label > title > textContent
   */
  function readElementQueryText(el) {
    if (!el) return "";
    var dataQuery = el.getAttribute("data-query");
    if (dataQuery && dataQuery.trim()) {
      return dataQuery.trim();
    }

    var value = typeof el.value === "string" ? el.value : "";
    if (value && value.trim()) {
      return normalizeQuerySourceText(value);
    }

    var qText = el.querySelector ? el.querySelector(ROLE.qitemText) : null;
    if (qText && qText.textContent) {
      return normalizeQuerySourceText(qText.textContent);
    }

    var ariaLabel = el.getAttribute ? el.getAttribute("aria-label") : "";
    if (ariaLabel && ariaLabel.trim()) {
      return normalizeQuerySourceText(ariaLabel);
    }

    var title = el.getAttribute ? el.getAttribute("title") : "";
    if (title && title.trim()) {
      return normalizeQuerySourceText(title);
    }

    return normalizeQuerySourceText(el.textContent);
  }

  function endsWithAny(text, suffixes) {
    for (var i = 0; i < suffixes.length; i += 1) {
      if (text.slice(-suffixes[i].length) === suffixes[i]) {
        return true;
      }
    }
    return false;
  }

  /** titleToDescriptiveQuery 기본 접미사: "{text}에 대해 알려줘" */
  function buildGenericQuestion(text) {
    return text + "에 대해 알려줘";
  }

  /** UI 라벨을 자연어 질문으로 변환. 기본: "{라벨}에 대해 알려줘" */
  function titleToDescriptiveQuery(title) {
    var text = normalizeQuerySourceText(title);
    if (!text) return "";
    if (/알려줘$|안내해줘$|설명해줘$|보여줘$|확인해줘$/.test(text)) return text;
    if (/[?？]$/.test(text)) return text;
    if (/안됨|안 됨/.test(text)) return text.replace(/안됨$/, "안 되는데").replace(/안 됨$/, "안 되는데") + " 어떻게 해야 할까?";
    if (/장애 발생/.test(text)) return text.replace("장애 발생", "장애가 발생했는데") + " 어떻게 해야 할까?";
    if (/회색 화면/.test(text)) return text + "이 나타나는데 어떻게 해야 할까?";
    return buildGenericQuestion(text);
  }

  /** 빠른검색 항목(.kp-qitem 등) 클릭 시 최종 질문 문자열 */
  function getQuickSearchQuery(qitem) {
    var sourceText = readElementQueryText(qitem);
    if (!sourceText) return "";
    if (qitem && qitem.getAttribute) {
      var explicitQuery = qitem.getAttribute("data-query");
      if (explicitQuery && explicitQuery.trim()) {
        return explicitQuery.trim();
      }
    }
    return titleToDescriptiveQuery(sourceText);
  }

  /** 진행 중 채팅 요청 중단 (전송 버튼 토글 시) */
  function abortChatRequest() {
    if (!chatBusy || !global.PT_AI_ANSWER) return;
    var ctx = buildAnswerCtx();
    global.PT_AI_ANSWER.abort(ctx);
  }

  /**
   * 채팅 1턴 시작 (ai-consult.js에서 호출).
   * 1) appendTurn 2) 질문 pill 표시 3) PT_AI_ANSWER.dispatch
   */
  function startChat(query, answerType) {
    var mainEl = resolveMainEl();
    var text = String(query || "").trim();
    if (!text || !mainEl || chatBusy) return false;
    if (!appendTurn()) return false;
    activateChatLayout();
    if (activeTurn && activeTurn.threadEl) {
      var pill = activeTurn.threadEl.querySelector(ROLE.queryPill);
      if (isTemplateAnswerType(answerType)) {
        pill.textContent = normalizeQueryLabel(text);
      } else {
        showQueryStream(pill, text);
      }
    }
    emitScroll();
    if (!global.PT_AI_ANSWER) return false;
    var ctx = buildAnswerCtx();
    ctx.query = text;
    ctx.answerType = answerType;
    global.PT_AI_ANSWER.dispatch(ctx);
    return true;
  }

  /** 홈 복귀: 요청 중단 + 채팅 초기화 + sessionStorage 세션 리셋 */
  function resetForHome() {
    cancelQueryStream();
    if (global.PT_AI_ANSWER) {
      global.PT_AI_ANSWER.stopForHome({ onBusyChange: emitBusyChange });
    }
    clearChatHistory();
    if (global.PT_AI_API && typeof global.PT_AI_API.resetSession === "function") {
      global.PT_AI_API.resetSession();
    }
  }

  /** ai-consult.js init 시 UI 콜백 등록 */
  function initChat(options) {
    options = options || {};
    uiBindings.onBusyChange = typeof options.onBusyChange === "function" ? options.onBusyChange : null;
    uiBindings.onScroll = typeof options.onScroll === "function" ? options.onScroll : null;
    uiBindings.onChatActivated = typeof options.onChatActivated === "function" ? options.onChatActivated : null;
    uiBindings.onShowLoading = typeof options.onShowLoading === "function" ? options.onShowLoading : null;
    uiBindings.onShowError = typeof options.onShowError === "function" ? options.onShowError : null;
    uiBindings.onShowAborted = typeof options.onShowAborted === "function" ? options.onShowAborted : null;
  }

  // =========================================================================
  // 전역 export (window)
  // =========================================================================

  global.PT_AI_CONFIG = config;
  global.PT_AI_API = {
    send: send,
    sendRag: sendRag,
    sendLlm: sendLlm,
    stop: stopStream,
    abort: abort,
    resetSession: function () {
      firstQuestion = true;
      lastJobId = null;
    },
    getLastJobId: function () {
      return lastJobId;
    }
  };
  global.PT_AI_RENDER = {
    modes: Object.keys(modes),
    render: render,
    apply: apply,
    escapeHtml: escapeHtml,
    streamText: streamText,
    streamTemplate: streamTemplate
  };
  global.PT_AI_AVATAR = {
    getBotPath: getBotPath,
    getUserPath: getUserPath,
    applySparkAvatar: applySparkAvatar,
    applyToThread: applyToThread
  };
  global.PT_AI_ANSWER = {
    isTemplateType: isTemplateType,
    normalizeQueryLabel: normalizeQueryLabel,
    isBusy: function () {
      return answerBusy;
    },
    isTemplateActive: function () {
      return !!(templateAnswerTimer || templateStreamHandle);
    },
    answerWithLlm: answerWithLlm,
    answerWithTemplate: answerWithTemplate,
    dispatch: dispatch,
    abort: abortAnswer,
    stopForHome: stopForHome,
    cancelTemplate: cancelTemplate
  };
  global.PT_AI_CHAT = {
    init: initChat,
    startChat: startChat,
    abortChatRequest: abortChatRequest,
    buildAnswerCtx: buildAnswerCtx,
    getQuickSearchQuery: getQuickSearchQuery,
    resetForHome: resetForHome,
    isTemplateAnswerType: isTemplateAnswerType,
    normalizeQueryLabel: normalizeQueryLabel
  };
})(window);
