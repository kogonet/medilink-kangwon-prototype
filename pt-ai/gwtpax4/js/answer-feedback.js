/**
 * AI 상담4: 답변마다 "도움이 되었나요? 👍 👎 · 대화 전체 평가" (턴·세션 평가 → tb_ai4_turn / tb_ai4_session_feedback).
 * - 작업 ID 는 "ptai:done" 이벤트의 jobId (gwa-…) 를 쓴다. 문서 검색(RAG)으로 넘긴 답변도 같은 ID 로 기록되어 있다.
 * - 👎 이면 이유·메모를 받고, 화면에 보인 답변 글(answerText)을 함께 보낸다 (RAG 답변은 서버가 내용을 모르기 때문).
 * - 검색 과정 상자(answer-trace.js)·지도(answer-map.js) 아래에 붙인다. 모든 글자는 textContent 로 넣는다.
 */
(function (global) {
  "use strict";

  var REASONS = [
    ["wrong_info", "틀린 정보"],
    ["wrong_search", "엉뚱한 검색"],
    ["table_map", "표·지도 문제"],
    ["slow", "너무 느림"],
    ["etc", "기타"]
  ];
  var MAX_COMMENT = 1000;
  var MAX_ANSWER = 20000;
  var lastJobId = null;

  function boot() {
    return global.PT_AI_BOOT || {};
  }

  function apiUrl(path) {
    return (boot().apiBase || "") + path;
  }

  /** ai-core4.js getSessionId 와 같은 sessionStorage 키 */
  function sessionId() {
    try {
      return sessionStorage.getItem("pt_ai_" + (boot().moduleId || "") + "_session_id") || "";
    } catch (e) {
      return "";
    }
  }

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function btn(cls, text, label) {
    var b = el("button", cls, text);
    b.type = "button";
    if (label) b.setAttribute("aria-label", label);
    return b;
  }

  function post(path, body) {
    return fetch(apiUrl(path), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    }).then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    });
  }

  /** 지도·검색 과정 상자 뒤 (없으면 답변 본문 뒤) */
  function anchorAfter(body) {
    var a = body;
    var n = body.nextElementSibling;
    while (n && n.classList && (n.classList.contains("ai2-map") || n.classList.contains("ai3-trace"))) {
      a = n;
      n = n.nextElementSibling;
    }
    return a;
  }

  function render(body, jobId) {
    var anchor = anchorAfter(body);
    var old = anchor.nextElementSibling;
    if (old && old.classList && old.classList.contains("ai3-fb")) old.parentNode.removeChild(old);

    var box = el("div", "ai3-fb");
    box.setAttribute("data-job-id", jobId);
    var row = el("div", "ai3-fb__row");
    row.appendChild(el("span", "ai3-fb__q", "이 답변이 도움이 되었나요?"));
    var up = btn("ai3-fb__vote", "👍", "도움이 되었어요");
    var down = btn("ai3-fb__vote", "👎", "아쉬워요");
    var sessionLink = btn("ai3-fb__link", "대화 전체 평가");
    row.appendChild(up);
    row.appendChild(down);
    row.appendChild(sessionLink);
    var status = el("span", "ai3-fb__status");
    row.appendChild(status);
    box.appendChild(row);

    var panel = el("div", "ai3-fb__panel");
    panel.hidden = true;
    box.appendChild(panel);
    anchor.insertAdjacentElement("afterend", box);

    function mark(which) {
      up.classList.toggle("is-on", which === 1);
      down.classList.toggle("is-on", which === -1);
      up.setAttribute("aria-pressed", which === 1 ? "true" : "false");
      down.setAttribute("aria-pressed", which === -1 ? "true" : "false");
    }

    function send(rating, reason, comment) {
      status.textContent = "저장 중…";
      return post("/feedback.do", {
        jobId: jobId,
        sessionId: sessionId(),
        rating: rating,
        reason: reason || null,
        comment: comment || null,
        answerText: (body.innerText || body.textContent || "").slice(0, MAX_ANSWER)
      }).then(function () {
        mark(rating);
        status.textContent = rating === 1 ? "감사합니다!" : "의견 감사합니다. 개선에 반영할게요.";
        panel.hidden = true;
      }).catch(function () {
        status.textContent = "저장하지 못했어요. 잠시 후 다시 눌러 주세요.";
      });
    }

    up.addEventListener("click", function () {
      send(1);
    });

    down.addEventListener("click", function () {
      openPanel("turn");
    });

    sessionLink.addEventListener("click", function () {
      openPanel("session");
    });

    function openPanel(kind) {
      panel.textContent = "";
      panel.hidden = false;
      var picked = { reason: null, rating: kind === "session" ? 0 : -1 };
      panel.appendChild(el("p", "ai3-fb__title", kind === "session" ? "이번 대화 전체는 어떠셨나요?" : "어떤 점이 아쉬웠나요?"));

      if (kind === "session") {
        var srow = el("div", "ai3-fb__chips");
        [[1, "👍 좋았어요"], [-1, "👎 아쉬웠어요"]].forEach(function (o) {
          var c = btn("ai3-fb__chip", o[1]);
          c.addEventListener("click", function () {
            picked.rating = o[0];
            srow.querySelectorAll(".ai3-fb__chip").forEach(function (x) { x.classList.remove("is-on"); });
            c.classList.add("is-on");
          });
          srow.appendChild(c);
        });
        panel.appendChild(srow);
      } else {
        var chips = el("div", "ai3-fb__chips");
        REASONS.forEach(function (r) {
          var c = btn("ai3-fb__chip", r[1]);
          c.addEventListener("click", function () {
            picked.reason = r[0];
            chips.querySelectorAll(".ai3-fb__chip").forEach(function (x) { x.classList.remove("is-on"); });
            c.classList.add("is-on");
          });
          chips.appendChild(c);
        });
        panel.appendChild(chips);
      }

      var memo = el("textarea", "ai3-fb__memo");
      memo.maxLength = MAX_COMMENT;
      memo.rows = 2;
      memo.placeholder = "자세한 내용을 남겨 주시면 고치는 데 도움이 돼요 (선택)";
      panel.appendChild(memo);

      var actions = el("div", "ai3-fb__actions");
      var ok = btn("ai3-fb__send", "보내기");
      var cancel = btn("ai3-fb__cancel", "취소");
      actions.appendChild(ok);
      actions.appendChild(cancel);
      panel.appendChild(actions);

      cancel.addEventListener("click", function () {
        panel.hidden = true;
      });
      ok.addEventListener("click", function () {
        if (ok.disabled) return;
        if (kind === "session") {
          if (!picked.rating) {
            status.textContent = "👍 또는 👎 를 골라 주세요.";
            return;
          }
          ok.disabled = true;
          status.textContent = "저장 중…";
          post("/sessionFeedback.do", { sessionId: sessionId(), rating: picked.rating, comment: memo.value || null })
            .then(function () {
              status.textContent = "대화 평가 감사합니다!";
              panel.hidden = true;
            })
            .catch(function () {
              status.textContent = "저장하지 못했어요. 잠시 후 다시 시도해 주세요.";
            })
            .then(function () { ok.disabled = false; });
          return;
        }
        ok.disabled = true;
        send(-1, picked.reason || "etc", memo.value).then(function () { ok.disabled = false; });
      });
      memo.focus();
    }
    return box;
  }

  global.PT_AI3_FEEDBACK = { render: render };

  global.addEventListener("ptai:done", function (e) {
    var id = e && e.detail && e.detail.jobId;
    lastJobId = typeof id === "string" && id.indexOf("gwa-") === 0 ? id : null;
  });

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    if (!d.body || !lastJobId) return;
    var jobId = lastJobId;
    lastJobId = null;
    try {
      render(d.body, jobId);
    } catch (err) {
      if (global.console) console.warn("[ai4-feedback] render failed", err);
    }
  });
})(window);
