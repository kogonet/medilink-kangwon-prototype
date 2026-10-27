<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : AI 상담3 답변 평가 - 상세 (Ai3FeedbackAdmin.view)
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
	function fn_List(){
		location.href = "<c:url value='/admmgr/ai3/feedbackList.do'/>";
	}
	function fn_Turn(jobId){
		location.href = "<c:url value='/admmgr/ai3/feedbackView.do'/>?jobId=" + encodeURIComponent(jobId);
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
				<table cellspacing="0" cellpadding="0" border="0" summary="AI 상담3 턴 정보" class="tbl_ty2">
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

			<!-- 실제 답변 -->
			<div class="table_header mt20">
				<h6 class="sub_tit_h6">실제 답변</h6>
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
