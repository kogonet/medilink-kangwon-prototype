<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 게시판 속성 관리 상세
 **************************************************/
%>
<head>
	<script type="text/javascript">
		$(document).ready(function(){
		});
		//삭제
		function fn_Delete(){
			if( confirm("해당 게시판을 삭제 하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		//수정
		function fn_Update(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngWrite.do'/>");
			$("#frm").submit();
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngList.do'/>");
			$("#frm").submit();
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${rMap.BOARD_MNG_NO}"/>"/>
		<input type="hidden" id="chk" name="chk" value="<c:out value="${rMap.BOARD_MNG_NO}"/>"/>
	</form>

	<!--sub_contents_wrap-->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">게시판 속성 관리 상세</h6>
			</div>
			<!-- // table_header -->

			<!-- table_wrap -->
			<div class="table_wrap n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="15%">
						<col width="35%">
						<col width="15%">
						<col width="35%">
					</colgroup>
					<tbody>
						<tr>
							<th>게시판명 <em class="point">&nbsp;</em></th>
							<td><c:out value="${rMap.BOARD_NM}"/></td>
							<th>게시판번호 <em class="point">&nbsp;</em></th>
							<td><c:out value="${rMap.BOARD_MNG_NO}"/></td>
						</tr>
						<tr>
							<th>게시판설명 <em class="point">&nbsp;</em></th>
							<td colspan="3"><c:out value="${rMap.BOARD_DC}"/></td>
						</tr>
						<tr>
							<th>등록자</th>
							<td><c:out value="${empty rMap.MDF_NM ? rMap.MDF_ID : rMap.MDF_NM}"/></td>
							<th>등록일시</th>
							<td><c:out value="${rMap.MDF_DT}"/></td>
						</tr>
						<tr>
							<th>게시판목록구분 <em class="point">&nbsp;</em></th>
							<td colspan="3"><c:out value="${rMap.BOARD_LIST_TYPE}"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- // table_wrap -->

			<!-- page_btn_wrap -->
			<div class="page_btn_wrap jc_between mt20">
			
				<div class="lft">
					<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
				</div>

				<div class="rgt">
					<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Update();"><span>수정</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
				
			</div>
			<!-- // page_btn_wrap -->

		</div>
		<!--// sub_contents_area-->

	</div>
	<!--/ sub_contents_wrap-->
</body>