/**
 * AI 상담4: 답변 아래 "이어서 물어보기" 추천 질문 칩.
 * done 데이터 suggestions([{label, query}], SuggestionBuilder.java)로 그린다. 서버가 DB 로 미리 확인해 결과가 있는 질문만 온다.
 * 칩에는 짧은 label 을 보이고, 누르면 완성된 질문 문장(query)을 일반 질문처럼 보낸다 (PT_AI_CHAT.startChat → AI 판단).
 * 검색 과정 상자(answer-trace.js)·지도(answer-map.js) 아래, 답변 평가(answer-feedback.js) 위에 둔다. 모든 글자는 textContent 로 넣는다.
 */
(function (global) {
  "use strict";

  var MAX = 3;

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
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

  function busy() {
    var ans = global.PT_AI_ANSWER;
    return !!(ans && typeof ans.isBusy === "function" && ans.isBusy());
  }

  function render(body, list) {
    var anchor = anchorAfter(body);
    var old = anchor.nextElementSibling;
    if (old && old.classList && old.classList.contains("ai3-sg")) old.parentNode.removeChild(old);

    var box = el("div", "ai3-sg");
    box.appendChild(el("p", "ai3-sg__title", "이어서 물어보기"));
    var row = el("div", "ai3-sg__chips");
    list.slice(0, MAX).forEach(function (s) {
      var c = el("button", "ai3-sg__chip", s.label);
      c.type = "button";
      c.title = s.query;
      c.addEventListener("click", function () {
        var chat = global.PT_AI_CHAT;
        if (!chat || typeof chat.startChat !== "function" || busy()) return;
        c.classList.add("is-on");
        chat.startChat(s.query);
      });
      row.appendChild(c);
    });
    box.appendChild(row);
    anchor.insertAdjacentElement("afterend", box);
    return box;
  }

  global.PT_AI3_SUGGEST = { render: render };

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!d.body || data.source !== "gwtpax-agent" || !Array.isArray(data.suggestions)) return;
    var list = data.suggestions.filter(function (s) {
      return s && typeof s.label === "string" && typeof s.query === "string" && s.label && s.query;
    });
    if (!list.length) return;
    try {
      render(d.body, list);
    } catch (err) {
      if (global.console) console.warn("[ai4-suggest] render failed", err);
    }
  });
})(window);
