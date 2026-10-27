<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : AI 상담5 답변 평가 - 목록 (Ai5FeedbackAdmin.list)
 *            정렬: 번호·일시·경로·시간·평가 = 가운데 / 질문·사용 도구·이유·메모 = 왼쪽
 **************************************************/
%>
<head>
<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
<style>
	/* 최근 7일 요약 (CMS 색상 변수 사용 → 다크 테마 대응) */
	.ai3_summary { display:flex; flex-wrap:wrap; gap:8px; }
	.ai3_summary > li { display:flex; align-items:center; gap:8px; padding:8px 16px; border:1px solid var(--bd-color06); background:var(--bg-color06); box-sizing:border-box; font-size:12px; color:var(--txt-color03); }
	.ai3_summary > li strong { font-size:15px; font-weight:600; color:var(--txt-color); }
	.ai3_summary > li .badge { cursor:default; }
	.ai3_q { display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
	.ai3_sub { display:block; margin-top:2px; font-size:11px; color:var(--txt-color03); }
	.n_table_sty01 .badge { cursor:default; }
	.ai3_nowrap { white-space:nowrap; }
</style>
<script type="text/javascript">
	function fn_Search(){
		$("#page").val("1");
		$("#frm").attr("action","<c:url value='/admmgr/ai5/feedbackList.do'/>");
		$("#frm").submit();
	}
	function fn_Reset(){
		$("#fromDate,#toDate,#keyword").val("");
		$("#ratingFilter,#reason,#route,#aiIssue").val("");
		fn_Search();
	}
	function fn_Detail(jobId){
		location.href = "<c:url value='/admmgr/ai5/feedbackView.do'/>?jobId=" + encodeURIComponent(jobId);
	}
	$(document).ready(function() {
		var record_cnt = $("#record_cnt").val();
		$("#record_" + record_cnt).attr("checked","checked");
		$("input[name='record_cnt_radio']").change(function() {
			$("#record_cnt").val($(this).val());
			fn_Search();
		});
		$("#keyword").on("keydown",function(key){
			if( key.keyCode == 13 ){
				fn_Search();
				return false;
			}
		});
	});
</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="page" name="page" value="<c:out value='${param.page}'/>"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="<c:out value='${record_cnt}'/>"/>

	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

		<h4 class="sub_tit_h4"></h4>

		<!-- 최근 7일 요약 -->
		<div class="table_header mb5">
			<h6 class="sub_tit_h6">최근 7일 요약</h6>
		</div>
		<ul class="ai3_summary mb15">
			<li>답변 수 <strong><fmt:formatNumber value="${stats.total}"/></strong></li>
			<li><span class="badge sm light_success">좋음</span> <strong><fmt:formatNumber value="${stats.good}"/></strong></li>
			<li><span class="badge sm light_danger">나쁨</span> <strong><fmt:formatNumber value="${stats.bad}"/></strong></li>
			<li><span class="badge sm line_info">문서검색</span> 넘김 <strong><fmt:formatNumber value="${stats.handoff}"/></strong></li>
			<li>평균 응답 <strong><fmt:formatNumber value="${stats.avgMs / 1000}" maxFractionDigits="1"/>초</strong></li>
			<li>AI 글
				<span class="badge sm line_warning">표 직접 씀</span> <strong><fmt:formatNumber value="${stats.aiTable}"/></strong>
				<span class="badge sm line_info">거름</span> <strong><fmt:formatNumber value="${stats.aiGuard}"/></strong>
			</li>
			<li>대화 전체 평가
				<span class="badge sm light_success">좋음</span> <strong><fmt:formatNumber value="${stats.sessionGood}"/></strong>
				<span class="badge sm light_danger">나쁨</span> <strong><fmt:formatNumber value="${stats.sessionBad}"/></strong>
			</li>
		</ul>
		<!-- // 최근 7일 요약 -->

		<!-- 검색 -->
		<fieldset>
			<legend>검색</legend>
			<div class="search_form_wrap mb10">
				<div class="search_form_inner">
					<!-- filter_form -->
					<div class="filter_form">
						<div>
							<label>기간</label>
							<div>
								<span class="form_date">
									<input type="text" id="fromDate" name="fromDate" placeholder="시작일" class="form_text wd140" value="<c:out value='${filter.fromDate}'/>" onclick="calendar(event,'fromDate','yyyy-mm-dd')" readonly="readonly">
									<input type="button" class="btn_form_date" onclick="javascript:$('#fromDate').trigger('click');">
								</span>
								~
								<span class="form_date">
									<input type="text" id="toDate" name="toDate" placeholder="종료일" class="form_text wd140" value="<c:out value='${filter.toDate}'/>" onclick="calendar(event,'toDate','yyyy-mm-dd')" readonly="readonly">
									<input type="button" class="btn_form_date" onclick="javascript:$('#toDate').trigger('click');">
								</span>
							</div>
						</div>
						<div>
							<label>평가</label>
							<select id="ratingFilter" name="ratingFilter" class="form_select md" title="평가 선택">
								<option value="">전체</option>
								<option value="bad"   ${filter.ratingFilter eq 'bad'   ? "selected='selected'" : ""}>나쁨</option>
								<option value="good"  ${filter.ratingFilter eq 'good'  ? "selected='selected'" : ""}>좋음</option>
								<option value="rated" ${filter.ratingFilter eq 'rated' ? "selected='selected'" : ""}>평가됨</option>
								<option value="none"  ${filter.ratingFilter eq 'none'  ? "selected='selected'" : ""}>미평가</option>
							</select>
						</div>
						<div>
							<label>이유</label>
							<select id="reason" name="reason" class="form_select md" title="이유 선택">
								<option value="">전체</option>
								<c:forEach items="${reasonLabels}" var="r">
									<option value="<c:out value='${r.key}'/>" ${filter.reason eq r.key ? "selected='selected'" : ""}><c:out value="${r.value}"/></option>
								</c:forEach>
							</select>
						</div>
						<div>
							<label>경로</label>
							<select id="route" name="route" class="form_select md" title="경로 선택">
								<option value="">전체</option>
								<option value="agent"       ${filter.route eq 'agent'       ? "selected='selected'" : ""}>AI(DB)</option>
								<option value="emergency"   ${filter.route eq 'emergency'   ? "selected='selected'" : ""}>응급</option>
								<option value="rag-handoff" ${filter.route eq 'rag-handoff' ? "selected='selected'" : ""}>문서검색</option>
								<option value="busy"        ${filter.route eq 'busy'        ? "selected='selected'" : ""}>요청많음</option>
								<option value="error"       ${filter.route eq 'error'       ? "selected='selected'" : ""}>오류</option>
							</select>
						</div>
						<div>
							<label>AI 글</label>
							<select id="aiIssue" name="aiIssue" class="form_select md" title="AI 글 문제 선택">
								<option value="">전체</option>
								<option value="any"   ${filter.aiIssue eq 'any'   ? "selected='selected'" : ""}>문제 있음 (표·거름)</option>
								<option value="table" ${filter.aiIssue eq 'table' ? "selected='selected'" : ""}>표를 직접 씀</option>
								<option value="guard" ${filter.aiIssue eq 'guard' ? "selected='selected'" : ""}>보내기 전에 거름</option>
							</select>
						</div>
						<div>
							<label>검색어</label>
							<input type="text" id="keyword" name="keyword" class="form_text md wd300" value="<c:out value='${filter.keyword}'/>" placeholder="질문 내용을 입력해 주세요"/>
						</div>
					</div>
					<!-- // filter_form -->
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
		</fieldset>
		<!-- // 검색 -->

		<!-- 리스트 -->
		<div class="con_list_wrap">
			<div class="noti_area mt0">
				<p class="noti_text"><em>AI 상담5의 모든 답변이 기록되며, 사용자가 남긴 평가(좋음·나쁨)와 이유·메모를 함께 확인할 수 있습니다.</em></p>
				<p class="noti_text"><em>질문에 건강 정보가 포함될 수 있어 열람 기록이 남으며, 90일이 지난 기록은 자동으로 삭제됩니다.</em></p>
			</div>

			<div class="table_header flx jc_between mt10 mb5">
				<div class="lft">
					<label for="record_20" class="form_chip md"><input type="radio" id="record_20" name="record_cnt_radio" value="20"><span>20개</span></label>
					<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt_radio" value="50"><span>50개</span></label>
					<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt_radio" value="100"><span>100개</span></label>
				</div>
				<div class="rgt">총 <strong><fmt:formatNumber value="${TOTAL_NUM}"/></strong>건</div>
			</div>

			<div class="n_table_sty01 n_list01">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="AI 상담5 답변 평가 목록">
					<colgroup>
						<col width="5%"/>
						<col width="12%"/>
						<col width="*"/>
						<col width="8%"/>
						<col width="18%"/>
						<col width="8%"/>
						<col width="6%"/>
						<col width="7%"/>
						<col width="13%"/>
					</colgroup>
					<thead>
						<tr>
							<th class="center"><span>번호</span></th>
							<th class="center"><span>일시</span></th>
							<th class="center"><span>질문</span></th>
							<th class="center"><span>경로</span></th>
							<th class="center"><span>사용 도구</span></th>
							<th class="center"><span>AI 글</span></th>
							<th class="center ai3_nowrap"><span>시간(초)</span></th>
							<th class="center"><span>평가</span></th>
							<th class="center"><span>이유 · 메모</span></th>
						</tr>
					</thead>
					<tbody>
						<c:set var="curPage" value="${empty param.page ? 1 : param.page}"/>
						<c:forEach items="${rList}" var="r" varStatus="status">
							<tr>
								<td class="center"><fmt:formatNumber value="${TOTAL_NUM - (curPage - 1) * record_cnt - status.index}"/></td>
								<td class="center ai3_nowrap"><c:out value="${r.createdAt}"/></td>
								<td class="left">
									<a href="javascript:void(0);" onclick="javascript:fn_Detail('<c:out value="${r.jobId}"/>');" class="ai3_q" title="<c:out value='${r.question}'/>"><c:out value="${r.question}"/></a>
								</td>
								<td class="center">
									<c:choose>
										<c:when test="${r.route eq 'agent'}"><span class="badge sm line_primary">AI(DB)</span></c:when>
										<c:when test="${r.route eq 'emergency'}"><span class="badge sm line_danger">응급</span></c:when>
										<c:when test="${r.route eq 'rag-handoff'}"><span class="badge sm line_info">문서검색</span></c:when>
										<c:when test="${r.route eq 'busy'}"><span class="badge sm line_warning">요청많음</span></c:when>
										<c:when test="${r.route eq 'error'}"><span class="badge sm bg_danger">오류</span></c:when>
										<c:otherwise><c:out value="${r.route}"/></c:otherwise>
									</c:choose>
									<c:if test="${not empty r.fallback}"><span class="ai3_sub"><c:out value="${r.fallback}"/></span></c:if>
								</td>
								<td class="left"><c:out value="${empty r.tools ? '-' : r.tools}"/></td>
								<td class="center">
									<c:if test="${r.aiTable eq 1}"><span class="badge sm line_warning" title="AI가 표를 직접 썼습니다 (상세의 질문 흐름 참고)">표 직접 씀</span></c:if>
									<c:if test="${r.aiGuard eq 1}"><span class="badge sm line_info" title="화면에 보내기 전에 AI 글 일부를 걸렀습니다">거름</span></c:if>
									<c:if test="${r.aiTable ne 1 and r.aiGuard ne 1}">-</c:if>
								</td>
								<td class="center ai3_nowrap"><fmt:formatNumber value="${r.totalMs / 1000}" minFractionDigits="1" maxFractionDigits="1"/></td>
								<td class="center">
									<c:choose>
										<c:when test="${r.rating eq -1}"><span class="badge sm light_danger">나쁨</span></c:when>
										<c:when test="${r.rating eq 1}"><span class="badge sm light_success">좋음</span></c:when>
										<c:otherwise>-</c:otherwise>
									</c:choose>
								</td>
								<td class="left">
									<c:choose>
										<c:when test="${empty r.reasonLabel and empty r.comment}">-</c:when>
										<c:otherwise>
											<c:out value="${r.reasonLabel}"/>
											<c:if test="${not empty r.comment}"><span class="ai3_sub"><c:out value="${r.comment}"/></span></c:if>
										</c:otherwise>
									</c:choose>
								</td>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(rList) eq 0}">
							<tr><td class="center" colspan="9">조건에 맞는 기록이 없습니다.</td></tr>
						</c:if>
					</tbody>
				</table>
			</div>
		</div>
		<!-- // 리스트 -->

		<!-- table_footer -->
		<div class="table_footer">
			<div class="btn_wrap lft">
				<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_Reset();"><span>조건 초기화</span></a>
			</div>
			<div class="pagination_wrap">
				<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
			</div>
			<div class="btn_wrap rgt"></div>
		</div>
		<!-- // table_footer -->

		</div>
		<!-- //sub_contents_area -->
	</div>
	<!-- sub_contents_wrap -->
</form>
</body>
