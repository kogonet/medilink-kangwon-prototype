<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : AI-건강정보 관리 - 상세(읽기전용)
 **************************************************/
%>
<head>
	<style type="text/css">
		.detail_row{border:1px solid #d2d2d2;border-radius:4px;padding:12px;margin-bottom:10px;background:#fff;}
		.detail_row .row_head{margin-bottom:8px;color:#555;}
		.detail_row .row_head b{color:#222;}
		.detail_row .cl_cn{white-space:pre-wrap;word-break:break-all;font-family:inherit;font-size:13px;margin:0;}
		.detail_row .cl_cn img{max-height:200px;max-width:100%;border:1px solid #eee;}
	</style>
	<script type="text/javascript">
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/health/Regist.do'/>").submit();
		}
		function fn_Delete(){
			if( confirm("삭제하시겠습니까?\n(하위 상세 항목도 함께 삭제됩니다)") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/health/DeleteProc.do'/>").submit();
			}
		}
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/health/List.do'/>").submit();
		}
		$(document).ready(function(){
			// 내용이 이미지 URL 한 줄이면 이미지로 보여준다.
			$(".cl_cn").each(function(){
				var val = $(this).text().trim();
				if( /^https?:\/\/\S+$/i.test(val) ){
					$(this).html('<img src="' + val + '" onerror="this.style.display=\'none\';"/>');
				}
			});
		});
	</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="rnum" name="rnum" value="<c:out value="${rMap.rnum}"/>"/>
	<input type="hidden" id="chk" name="chk" value="<c:out value="${rMap.rnum}"/>"/>
	<div class="sub_contents_wrap">
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4 fix"></h4>

			<div class="table_header">
				<h6 class="sub_tit_h6">AI-건강정보 상세</h6>
			</div>

			<div class="table_wrap n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="AI-건강정보 상세" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>건강정보명</th>
							<td><c:out value="${rMap.name}"/></td>
							<th>구분</th>
							<td><c:out value="${rMap['div']}"/></td>
						</tr>
						<tr>
							<th>질병관리청 콘텐츠 일련번호</th>
							<td colspan="3"><c:out value="${rMap.id}"/></td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="n_table_sty01 n_view01 mt20">
				<div class="table_header">
					<h6 class="sub_tit_h6">상세 내용</h6>
				</div>

				<div id="detailList">
					<c:forEach items="${detailList}" var="d" varStatus="status">
						<div class="detail_row">
							<div class="row_head">
								<b><c:out value="${status.index + 1}"/>. <c:out value="${d.clNm}"/></b>
								<c:if test="${not empty d.clsn}"> (분류코드 <c:out value="${d.clsn}"/>)</c:if>
							</div>
							<pre class="cl_cn"><c:out value="${d.clCn}"/></pre>
						</div>
					</c:forEach>
					<c:if test="${fn:length(detailList) eq 0}">등록된 상세 내용이 없습니다.</c:if>
				</div>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>수정</span></a>
					<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
