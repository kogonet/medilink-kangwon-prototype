<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : AI 상담5 답변 평가 - 상세 (Ai5FeedbackAdmin.view)
 *            정렬: 상세 표 = 왼쪽 / 목록 표는 순서·시각·도구·건수·시간·경로·평가 = 가운데, 질문·입력값·결과 = 왼쪽
 **************************************************/
%>
<head>
<script src="https://cdn.jsdelivr.net/npm/markdown-it@14.1.0/dist/markdown-it.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dompurify@3.1.6/dist/purify.min.js"></script>
<style>
	/* 실제 답변 미리보기 (CMS 색상 변수 사용 → 다크 테마 대응) */
	.ai3_answer { padding:16px 20px; border:1px solid var(--bd-color06); background:var(--bg-color06); box-sizing:border-box; font-size:13px; line-height:1.6; color:var(--txt-color); overflow-x:auto; }
	.ai3_answer p { margin:0 0 8px; }
	.ai3_answer h3, .ai3_answer h4 { margin:14px 0 6px; font-size:14px; font-weight:600; }
	.ai3_answer ul, .ai3_answer ol { margin:0 0 8px 18px; }
	.ai3_answer ul li { list-style:disc; }
	.ai3_answer ol li { list-style:decimal; }
	.ai3_answer table { border-collapse:collapse; margin:8px 0; font-size:12px; }
	.ai3_answer th, .ai3_answer td { padding:6px 8px; border:1px solid var(--bd-color06); text-align:left; vertical-align:top; }
	.ai3_answer th { background:var(--bg-color05); font-weight:500; }
	.ai3_answer a { color:var(--txt-color03); text-decoration:underline; }
	.ai3_empty { color:var(--txt-color03); }
	.ai3_mono { font-family:Consolas, Menlo, monospace; font-size:11px; word-break:break-all; }
	.ai3_err { margin-left:4px; }
	.n_table_sty01 .badge { cursor:default; }
	.ai3_nowrap { white-space:nowrap; }
	.n_table_sty01.n_list01 tbody tr.ai3_current td { background-color:var(--bg-color02); font-weight:600; }
	/* 질문 흐름 (TurnFlow, 2026-10-22) */
	.ai5_flow_bar { display:flex; flex-wrap:wrap; align-items:center; gap:12px; font-size:12px; color:var(--txt-color03); }
	.ai5_flow_bar label { display:inline-flex; align-items:center; gap:4px; cursor:pointer; }
	.ai5_flow_sum { margin-right:auto; }
	.ai5_flow_sum strong { color:var(--txt-color); font-weight:600; }
	.ai5_flow td { vertical-align:top; }
	.ai5_flow tr.is-step td { color:var(--txt-color03); font-size:12px; padding-top:4px; padding-bottom:4px; }
	.ai5_flow tr.is-ai td { background-color:var(--bg-color06); }
	.ai5_text { margin:6px 0 0; white-space:pre-wrap; word-break:break-word; font-size:13px; line-height:1.6; color:var(--txt-color); }
	.ai5_text.is-empty { color:var(--txt-color03); font-style:italic; }
	.ai5_line { margin-top:4px; font-size:12px; line-height:1.6; }
	.ai5_line .ai3_mono { color:var(--txt-color03); }
	.ai5_flow details { margin-top:6px; }
	.ai5_flow details summary { cursor:pointer; font-size:12px; color:var(--txt-color03); }
	.ai5_flow pre { margin:6px 0 0; padding:8px 10px; max-height:360px; overflow:auto; border:1px solid var(--bd-color06); background:var(--bg-color05);
		font-family:Consolas, Menlo, monospace; font-size:11px; line-height:1.5; white-space:pre-wrap; word-break:break-all; }
	.ai5_flow .badge + .badge { margin-left:4px; }
</style>
<script type="text/javascript">
	var AI3_ANSWER = ${answerJson};
	$(document).ready(function () {
		var box = document.getElementById("ai3Answer");
		if (!AI3_ANSWER) {
			box.innerHTML = '<span class="ai3_empty">저장된 답변이 없습니다. (문서검색으로 넘긴 턴은 사용자가 평가할 때 화면에 보인 답변이 저장됩니다)</span>';
			return;
		}
		if (window.markdownit && window.DOMPurify) {
			box.innerHTML = DOMPurify.sanitize(window.markdownit({ html: false, linkify: true, breaks: true }).render(AI3_ANSWER));
			box.querySelectorAll('a[href^="http"]').forEach(function (a) { a.target = "_blank"; a.rel = "noopener noreferrer"; });
		} else {
			box.textContent = AI3_ANSWER;
		}
	});
	/*
	 * 질문 흐름 (TurnFlow, 2026-10-22): 서버가 저장한 이벤트를 순서대로 그린다. 모든 값은 글자(textContent)로만 넣는다.
	 *   step 진행 줄 / ai AI가 쓴 글 그대로(+부른 도구) / tool 도구 결과(+AI에게 준 결과) / skip 실행 안 함 / system 시스템 판단 / screen 화면에 보낸 것
	 *   guard AI 글 검사가 화면에 보내기 전에 뺀 것 (원래 글·보낸 글)
	 *   request 마지막 글을 쓰게 한 AI 요청 (보낸 메시지 그대로, 시스템 규칙은 길이만)
	 */
	var AI5_FLOW = ${flowJson};
	var AI5_LABELS = ${flowLabelsJson};
	/** 글에 마크다운 표 줄이 있는지 (AI가 표·목록을 직접 쓴 경우 표시) */
	var AI5_TABLE_LINE = /^\s*\|.*\|\s*$/m;

	function ai5El(tag, cls, text) {
		var e = document.createElement(tag);
		if (cls) e.className = cls;
		if (text != null) e.textContent = text;
		return e;
	}
	function ai5Badge(cls, text) {
		return ai5El("span", "badge sm " + cls, text);
	}
	function ai5Json(v, pretty) {
		try {
			return JSON.stringify(v, null, pretty ? 2 : 0);
		} catch (e) {
			return String(v);
		}
	}
	function ai5Pretty(s) {
		try {
			return JSON.stringify(JSON.parse(s), null, 2);
		} catch (e) {
			return String(s == null ? "" : s);
		}
	}
	function ai5Tool(name) {
		var l = AI5_LABELS.tools[name];
		return l ? l + " (" + name + ")" : String(name);
	}
	function ai5Block(type) {
		var l = AI5_LABELS.blocks[type];
		return l ? l + " (" + type + ")" : String(type);
	}
	function ai5Text(box, text) {
		var t = String(text == null ? "" : text);
		box.appendChild(ai5El("div", "ai5_text" + (t ? "" : " is-empty"), t || "(글 없음)"));
	}
	function ai5Details(box, title, blocks) {
		var d = ai5El("details");
		d.appendChild(ai5El("summary", null, title));
		blocks.forEach(function (b) {
			d.appendChild(ai5El("div", "ai5_line", b[0]));
			d.appendChild(ai5El("pre", null, b[1]));
		});
		box.appendChild(d);
	}

	function ai5Row(e, n) {
		var tr = ai5El("tr", "is-" + e.kind);
		tr.setAttribute("data-kind", e.kind);
		tr.appendChild(ai5El("td", "center", String(n)));
		tr.appendChild(ai5El("td", "center ai3_nowrap", ((Number(e.t) || 0) / 1000).toFixed(2)));
		var kindTd = ai5El("td", "center ai3_nowrap");
		var box = ai5El("td", "left");
		var tableWarn = false;
		if (e.kind === "step") {
			kindTd.textContent = "진행";
			box.textContent = e.text || "";
		} else if (e.kind === "ai") {
			kindTd.appendChild(ai5Badge("line_primary", "AI 글"));
			var head = ai5El("div");
			head.appendChild(ai5El("span", null, (e.round ? e.round + "번째 AI 응답" : "AI 응답")));
			if (e.final) head.appendChild(ai5Badge("light_success", "마지막 글"));
			if (e.note) head.appendChild(ai5Badge("light_danger", e.note));
			tableWarn = AI5_TABLE_LINE.test(e.text || "");
			if (tableWarn) head.appendChild(ai5Badge("line_warning", "AI가 표를 직접 씀"));
			box.appendChild(head);
			ai5Text(box, e.text);
			(e.calls || []).forEach(function (c) {
				var line = ai5El("div", "ai5_line");
				line.appendChild(document.createTextNode("→ 도구 호출: " + ai5Tool(c.tool) + " "));
				line.appendChild(ai5El("span", "ai3_mono", ai5Json(c.args)));
				box.appendChild(line);
			});
		} else if (e.kind === "tool") {
			kindTd.appendChild(ai5Badge("line_info", "도구 결과"));
			var t = ai5El("div");
			t.appendChild(ai5El("strong", null, ai5Tool(e.tool)));
			t.appendChild(document.createTextNode(" · " + (e.summary || "-") + " · " + (e.count || 0) + "건 · " +
				((Number(e.ms) || 0) / 1000).toFixed(2) + "초 "));
			if (e.error) t.appendChild(ai5Badge("light_danger", "오류 " + e.error));
			if (e.empty) t.appendChild(ai5Badge("line_warning", "결과 없음"));
			if (e.handoff) t.appendChild(ai5Badge("line_info", "문서 검색으로 넘김"));
			box.appendChild(t);
			var bl = (e.blocks || []).map(ai5Block);
			box.appendChild(ai5El("div", "ai5_line", "화면 블록: " + (bl.length ? bl.join(", ") : "없음")));
			ai5Details(box, "입력값 · AI에게 돌려준 결과 보기", [
				["입력값 (AI가 보낸 값 그대로)", ai5Json(e.args, true)],
				["AI에게 돌려준 결과 (AI는 이것만 보고 다음 글을 씀)", ai5Pretty(e.forLlm)]
			]);
		} else if (e.kind === "skip") {
			kindTd.appendChild(ai5Badge("line_warning", "실행 안 함"));
			box.appendChild(ai5El("div", null, e.text || ""));
			box.appendChild(ai5El("div", "ai5_line ai3_mono", ai5Tool(e.tool) + " " + ai5Json(e.args)));
		} else if (e.kind === "request") {
			// 마지막 글을 쓰게 한 AI 요청 (AgentRunner.requestData): 시스템 규칙은 길이만, 나머지 메시지는 그대로
			kindTd.appendChild(ai5Badge("line_primary", "AI 요청"));
			var msgs = Array.isArray(e.messages) ? e.messages : [];
			box.appendChild(ai5El("div", null, (e.text || "AI 요청") + " · 메시지 " + msgs.length + "개 · " + (e.tools || "")));
			if (e.omitted) box.appendChild(ai5El("div", "ai5_line", "앞 메시지 " + e.omitted + "개는 생략 (긴 대화)"));
			ai5Details(box, "보낸 메시지 보기 (AI가 마지막 글을 쓰기 직전에 읽은 것)", msgs.map(function (m, i) {
				var head = (i + 1) + ". " + m.role + (m.tool_name ? " (" + ai5Tool(m.tool_name) + " 결과)" : "");
				var body = String(m.content == null ? "" : m.content);
				if (m.role === "tool") body = ai5Pretty(body);
				if (m.tool_calls) body += (body ? "\n" : "") + "도구 호출: " + ai5Json(m.tool_calls, true);
				return [head, body || "(내용 없음)"];
			}));
		} else if (e.kind === "guard") {
			// AI 글 검사(AiTextGuard)가 화면에 보내기 전에 뺀 것
			kindTd.appendChild(ai5Badge("line_info", "글 거름"));
			box.appendChild(ai5El("div", null, e.text || ""));
			box.appendChild(ai5El("div", "ai5_line", "화면에 보낸 글:"));
			ai5Text(box, e.after);
			ai5Details(box, "AI가 쓴 원래 글 보기", [["원래 글", String(e.before == null ? "" : e.before)]]);
		} else if (e.kind === "system") {
			kindTd.appendChild(ai5Badge("line_warning", "시스템"));
			box.appendChild(ai5El("div", null, e.text || ""));
			if (e.args) box.appendChild(ai5El("div", "ai5_line ai3_mono", ai5Json(e.args)));
		} else if (e.kind === "screen") {
			kindTd.appendChild(ai5Badge("light_success", "화면 표시"));
			if (e.what === "say") {
				box.appendChild(ai5El("div", null, "AI 글 (" + e.seq + "번째 항목)"));
				ai5Text(box, e.text);
				tableWarn = AI5_TABLE_LINE.test(e.text || "");
				if (tableWarn) box.appendChild(ai5Badge("line_warning", "AI가 쓴 표가 화면에 보임"));
			} else {
				box.appendChild(ai5El("div", null, "블록 (" + e.seq + "번째 항목): " + ai5Block(e.block)));
			}
		} else {
			kindTd.textContent = String(e.kind);
			box.textContent = e.text || ai5Json(e);
		}
		tr.appendChild(kindTd);
		tr.appendChild(box);
		return tr;
	}

	function ai5RenderFlow() {
		var tbody = document.getElementById("ai5FlowBody");
		var sum = document.getElementById("ai5FlowSum");
		if (!Array.isArray(AI5_FLOW) || !AI5_FLOW.length) {
			var tr = ai5El("tr");
			var td = ai5El("td", "center", "질문 흐름 기록이 없습니다. (요청이 많아 처리하지 못한 턴, 흐름 기록 추가 전의 턴)");
			td.colSpan = 4;
			tr.appendChild(td);
			tbody.appendChild(tr);
			return;
		}
		var count = { ai: 0, tool: 0, screen: 0, dropped: 0, system: 0, guard: 0 };
		AI5_FLOW.forEach(function (e, i) {
			if (count.hasOwnProperty(e.kind)) count[e.kind] += 1;
			if (e.kind === "ai" && e.note) count.dropped += 1;
			tbody.appendChild(ai5Row(e, i + 1));
		});
		sum.textContent = "";
		[["AI 응답", count.ai], ["화면에 안 보낸 AI 글", count.dropped], ["AI 글 거름", count.guard], ["도구 실행", count.tool], ["시스템 판단", count.system], ["화면 항목", count.screen]]
			.forEach(function (p, i) {
				if (i) sum.appendChild(document.createTextNode(" · "));
				sum.appendChild(document.createTextNode(p[0] + " "));
				sum.appendChild(ai5El("strong", null, String(p[1])));
			});
		// 진행 줄·화면 표시 보이기/숨기기
		Array.prototype.forEach.call(document.querySelectorAll("[data-flow-toggle]"), function (cb) {
			cb.addEventListener("change", function () {
				var kind = cb.getAttribute("data-flow-toggle");
				Array.prototype.forEach.call(tbody.querySelectorAll('tr[data-kind="' + kind + '"]'), function (r) {
					r.style.display = cb.checked ? "" : "none";
				});
			});
		});
	}
	$(document).ready(ai5RenderFlow);

	function fn_List(){
		location.href = "<c:url value='/admmgr/ai5/feedbackList.do'/>";
	}
	function fn_Turn(jobId){
		location.href = "<c:url value='/admmgr/ai5/feedbackView.do'/>?jobId=" + encodeURIComponent(jobId);
	}
</script>
</head>
<body>
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4 fix"></h4>

			<!-- 턴 정보 -->
			<div class="table_header">
				<h6 class="sub_tit_h6">턴 정보</h6>
			</div>
			<div class="table_wrap n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="AI 상담5 턴 정보" class="tbl_ty2">
					<colgroup>
						<col width="15%">
						<col width="35%">
						<col width="15%">
						<col width="35%">
					</colgroup>
					<tbody>
						<tr>
							<th>질문</th>
							<td colspan="3" class="left"><strong><c:out value="${turn.question}"/></strong></td>
						</tr>
						<tr>
							<th>일시</th>
							<td class="left"><c:out value="${turn.createdAt}"/></td>
							<th>경로</th>
							<td class="left">
								<c:choose>
									<c:when test="${turn.route eq 'agent'}"><span class="badge sm line_primary">AI(DB)</span></c:when>
									<c:when test="${turn.route eq 'emergency'}"><span class="badge sm line_danger">응급</span></c:when>
									<c:when test="${turn.route eq 'rag-handoff'}"><span class="badge sm line_info">문서검색</span></c:when>
									<c:when test="${turn.route eq 'busy'}"><span class="badge sm line_warning">요청많음</span></c:when>
									<c:when test="${turn.route eq 'error'}"><span class="badge sm bg_danger">오류</span></c:when>
									<c:otherwise><c:out value="${turn.route}"/></c:otherwise>
								</c:choose>
								<c:if test="${not empty turn.fallback}"> (넘긴 이유: <c:out value="${turn.fallback}"/>)</c:if>
							</td>
						</tr>
						<tr>
							<th>AI 판단 횟수</th>
							<td class="left"><c:out value="${turn.llmCalls}"/>회</td>
							<th>전체 시간</th>
							<td class="left"><fmt:formatNumber value="${turn.totalMs / 1000}" minFractionDigits="1" maxFractionDigits="1"/>초</td>
						</tr>
						<tr>
							<th>평가</th>
							<td class="left">
								<c:choose>
									<c:when test="${turn.rating eq -1}"><span class="badge sm light_danger">나쁨</span></c:when>
									<c:when test="${turn.rating eq 1}"><span class="badge sm light_success">좋음</span></c:when>
									<c:otherwise>미평가</c:otherwise>
								</c:choose>
								<c:if test="${not empty turn.ratedAt}"> <c:out value="${turn.ratedAt}"/></c:if>
							</td>
							<th>이유</th>
							<td class="left"><c:out value="${empty turn.reasonLabel ? '-' : turn.reasonLabel}"/></td>
						</tr>
						<tr>
							<th>메모</th>
							<td colspan="3" class="left"><c:out value="${empty turn.comment ? '-' : turn.comment}"/></td>
						</tr>
						<tr>
							<th>작업 ID</th>
							<td class="left ai3_mono"><c:out value="${turn.jobId}"/></td>
							<th>세션 ID</th>
							<td class="left ai3_mono"><c:out value="${turn.sessionId}"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- // 턴 정보 -->

			<!-- 질문 흐름 (2026-10-22) -->
			<div class="table_header mt20">
				<h6 class="sub_tit_h6">질문 흐름 (AI 글 → 도구 → 결과 → 화면, 일어난 순서)</h6>
			</div>
			<div class="ai5_flow_bar mt10">
				<span class="ai5_flow_sum" id="ai5FlowSum"></span>
				<label><input type="checkbox" data-flow-toggle="step" checked> 진행 줄</label>
				<label><input type="checkbox" data-flow-toggle="screen" checked> 화면 표시</label>
			</div>
			<div class="n_table_sty01 n_list01 mt10 ai5_flow">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="질문 흐름">
					<colgroup>
						<col width="5%"/>
						<col width="7%"/>
						<col width="10%"/>
						<col width="*"/>
					</colgroup>
					<thead>
						<tr>
							<th class="center"><span>순서</span></th>
							<th class="center ai3_nowrap"><span>시각(초)</span></th>
							<th class="center"><span>구분</span></th>
							<th class="center"><span>내용</span></th>
						</tr>
					</thead>
					<tbody id="ai5FlowBody"></tbody>
				</table>
			</div>
			<!-- // 질문 흐름 -->

			<!-- 실제 답변 -->
			<div class="table_header mt20">
				<h6 class="sub_tit_h6">답변 기록 (조립본: 끊김 복구·턴 기록용이라 화면 순서와 다를 수 있음 — 화면에 보인 순서는 위 "화면 표시")</h6>
			</div>
			<div id="ai3Answer" class="ai3_answer mt10"></div>
			<!-- // 실제 답변 -->

			<!-- 도구 기록 -->
			<div class="table_header mt20">
				<h6 class="sub_tit_h6">도구 기록 (AI가 고른 검색)</h6>
			</div>
			<div class="n_table_sty01 n_list01 mt10">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="도구 기록">
					<colgroup>
						<col width="6%"/>
						<col width="14%"/>
						<col width="*"/>
						<col width="28%"/>
						<col width="7%"/>
						<col width="8%"/>
					</colgroup>
					<thead>
						<tr>
							<th class="center"><span>순서</span></th>
							<th class="center"><span>도구</span></th>
							<th class="center"><span>입력값</span></th>
							<th class="center"><span>결과 요약</span></th>
							<th class="center"><span>건수</span></th>
							<th class="center ai3_nowrap"><span>시간(초)</span></th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${trace}" var="t" varStatus="s">
							<tr>
								<td class="center">${s.index + 1}</td>
								<td class="center"><c:out value="${t.tool}"/></td>
								<td class="left ai3_mono"><c:out value="${t.argsText}"/></td>
								<td class="left">
									<c:out value="${t.summary}"/>
									<c:if test="${not empty t.error}"><span class="badge sm light_danger ai3_err"><c:out value="${t.error}"/></span></c:if>
								</td>
								<td class="center"><c:out value="${t.count}"/></td>
								<td class="center"><fmt:formatNumber value="${t.ms / 1000}" minFractionDigits="2" maxFractionDigits="2"/></td>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(trace) eq 0}">
							<tr>
								<td class="center" colspan="6">
									도구를 사용하지 않았습니다.
									<c:if test="${not empty traceRaw}"><span class="ai3_mono">(기록 해석 실패: <c:out value="${traceRaw}"/>)</span></c:if>
								</td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>
			<!-- // 도구 기록 -->

			<!-- 같은 세션의 대화 -->
			<div class="table_header flx jc_between mt20">
				<h6 class="sub_tit_h6">같은 세션의 대화 (현재 턴 강조)</h6>
				<c:if test="${not empty sessionFeedback}">
					<div class="rgt">
						대화 전체 평가
						<c:choose>
							<c:when test="${sessionFeedback.rating eq -1}"><span class="badge sm light_danger">나쁨</span></c:when>
							<c:otherwise><span class="badge sm light_success">좋음</span></c:otherwise>
						</c:choose>
						<c:if test="${not empty sessionFeedback.comment}"> <c:out value="${sessionFeedback.comment}"/></c:if>
						(<c:out value="${sessionFeedback.updatedAt}"/>)
					</div>
				</c:if>
			</div>
			<div class="n_table_sty01 n_list01 mt10">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="같은 세션의 대화">
					<colgroup>
						<col width="6%"/>
						<col width="10%"/>
						<col width="*"/>
						<col width="10%"/>
						<col width="8%"/>
						<col width="8%"/>
					</colgroup>
					<thead>
						<tr>
							<th class="center"><span>순서</span></th>
							<th class="center"><span>시각</span></th>
							<th class="center"><span>질문</span></th>
							<th class="center"><span>경로</span></th>
							<th class="center ai3_nowrap"><span>시간(초)</span></th>
							<th class="center"><span>평가</span></th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${sessionTurns}" var="st" varStatus="s">
							<tr class="${st.jobId eq turn.jobId ? 'ai3_current' : ''}">
								<td class="center">${s.index + 1}</td>
								<td class="center ai3_nowrap"><c:out value="${st.createdAt}"/></td>
								<td class="left">
									<c:choose>
										<c:when test="${st.jobId eq turn.jobId}"><c:out value="${st.question}"/></c:when>
										<c:otherwise><a href="javascript:void(0);" onclick="javascript:fn_Turn('<c:out value="${st.jobId}"/>');"><c:out value="${st.question}"/></a></c:otherwise>
									</c:choose>
								</td>
								<td class="center">
									<c:choose>
										<c:when test="${st.route eq 'agent'}"><span class="badge sm line_primary">AI(DB)</span></c:when>
										<c:when test="${st.route eq 'emergency'}"><span class="badge sm line_danger">응급</span></c:when>
										<c:when test="${st.route eq 'rag-handoff'}"><span class="badge sm line_info">문서검색</span></c:when>
										<c:when test="${st.route eq 'busy'}"><span class="badge sm line_warning">요청많음</span></c:when>
										<c:when test="${st.route eq 'error'}"><span class="badge sm bg_danger">오류</span></c:when>
										<c:otherwise><c:out value="${st.route}"/></c:otherwise>
									</c:choose>
								</td>
								<td class="center"><fmt:formatNumber value="${st.totalMs / 1000}" minFractionDigits="1" maxFractionDigits="1"/></td>
								<td class="center">
									<c:choose>
										<c:when test="${st.rating eq -1}"><span class="badge sm light_danger">나쁨</span></c:when>
										<c:when test="${st.rating eq 1}"><span class="badge sm light_success">좋음</span></c:when>
										<c:otherwise>-</c:otherwise>
									</c:choose>
								</td>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(sessionTurns) eq 0}">
							<tr><td class="center" colspan="6">세션 기록이 없습니다.</td></tr>
						</c:if>
					</tbody>
				</table>
			</div>
			<!-- // 같은 세션의 대화 -->

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>

		</div>
		<!-- //sub_contents_area -->
	</div>
	<!-- sub_contents_wrap -->
</body>
