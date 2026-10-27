/**
 * AI 상담4: 답변 아래 "검색 과정" 상자 (접힌 상태로 시작).
 * done 데이터 trace(도구별 summary/count/ms/error)와 traceMeta(llmCalls/totalMs)로 그린다.
 * 지도(answer-map.js)가 있으면 지도 아래에 둔다. 모든 글자는 textContent 로 넣는다.
 */
(function (global) {
  "use strict";

  var CIRCLED = "①②③④⑤⑥⑦⑧⑨⑩";

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  /** 한도 때문에 실행하지 않은 호출 (AgentRunner.skipped: error "skipped:per_reply_limit" 등) */
  function isSkipped(t) {
    return !!(t && typeof t.error === "string" && t.error.indexOf("skipped:") === 0);
  }

  function seconds(ms) {
    var n = Number(ms) || 0;
    return (n / 1000).toFixed(n < 1000 ? 2 : 1) + "초";
  }

  function render(body, trace, meta) {
    var anchor = body;
    var next = body.nextElementSibling;
    if (next && next.classList && next.classList.contains("ai2-map")) anchor = next;
    var old = anchor.nextElementSibling;
    if (old && old.classList && old.classList.contains("ai3-trace")) old.parentNode.removeChild(old);

    var box = el("details", "ai3-trace");
    // 2026-10-22: "N번 검색했어요" 상자는 화면에서 숨긴다 (요소는 남겨 두어 지도·추천 질문·평가의 자리 계산은 그대로)
    box.hidden = true;
    // 건너뛴 호출은 검색 횟수에서 빼고 번호 없이 회색으로 (2026-10-16)
    var runs = 0;
    var skips = 0;
    for (var k = 0; k < trace.length; k += 1) {
      if (isSkipped(trace[k])) skips += 1;
      else runs += 1;
    }
    var summary = runs ? "🔍 " + runs + "번 검색했어요" : "🔍 검색 없이 답변했어요";
    if (skips) summary += " (건너뜀 " + skips + "건)";
    box.appendChild(el("summary", null, summary));
    if (trace.length) {
      var list = el("ol", "ai3-trace__list");
      var n = 0;
      for (var i = 0; i < trace.length; i += 1) {
        var t = trace[i] || {};
        var li = el("li", null);
        if (isSkipped(t)) {
          li.className = "ai3-trace__skip";
          li.style.color = "#8A93A6";
          li.appendChild(document.createTextNode("– " + (t.summary || t.tool || "") + " → 건너뜀"));
          list.appendChild(li);
          continue;
        }
        li.appendChild(document.createTextNode((CIRCLED.charAt(n) || (n + 1) + ".") + " " + (t.summary || t.tool || "")));
        n += 1;
        if (t.error) {
          li.appendChild(el("span", "ai3-trace__err", " → 오류: " + t.error));
        } else {
          li.appendChild(document.createTextNode(" → " + (t.count || 0) + "건 (" + seconds(t.ms) + ")"));
        }
        list.appendChild(li);
      }
      box.appendChild(list);
    }
    var metaText = "AI 판단 " + (meta.llmCalls || 0) + "회 · 전체 " + seconds(meta.totalMs);
    if (meta.fallback) metaText += " · 대체 경로: " + meta.fallback;
    box.appendChild(el("p", "ai3-trace__meta", metaText));
    anchor.insertAdjacentElement("afterend", box);
    return box;
  }

  global.PT_AI3_TRACE = { render: render };

  global.addEventListener("ptai:answer", function (e) {
    var d = (e && e.detail) || {};
    var data = d.data || {};
    if (!d.body || data.source !== "gwtpax-agent" || !Array.isArray(data.trace)) return;
    try {
      render(d.body, data.trace, data.traceMeta || {});
    } catch (err) {
      if (global.console) console.warn("[ai3-trace] render failed", err);
    }
  });
})(window);
