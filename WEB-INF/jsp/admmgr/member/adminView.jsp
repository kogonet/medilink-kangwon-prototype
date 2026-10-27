<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 관리자 상세
 **************************************************/
%>
<head>
	<script type="text/javascript">
		$(document).ready(function(){
		});
		//삭제
		function fn_Delete(){
			if( confirm("해당 관리자를 삭제하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/member/adminDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		//수정
		function fn_Update(){
			$("#frm").attr("action","<c:url value='/admmgr/member/adminRegist.do'/>");
			$("#frm").submit();
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/member/adminList.do'/>");
			$("#frm").submit();
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="userId" name="userId" value="<c:out value="${rMap.USER_ID}"/>"/>
		<input type="hidden" id="chk" name="chk" value="<c:out value="${rMap.USER_ID}"/>"/>
	</form>

	<!--sub_contents_wrap-->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<!-- table_header -->
			<div class="table_header">
				<h6 class="sub_tit_h6 f_left">관리자 정보 상세</h6>
			</div>
			<!-- // table_header -->

			<div class="table_wrap n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<caption>사용자 정보</caption>
					<colgroup>
						<col width="15%">
						<col width="30%">
						<col width="15%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>아이디</th>
							<td class="left"><c:out value="${str:getReverseXSS(rMap.USER_ID)}"/></td>
							<th>권한</th>
							<td class="left"><c:out value="${str:getReverseXSS(rMap.AUTH_NM)}"/></td>
						</tr>
						<%-- <tr>
							<th>부서명</th>
							<td class="left"><c:out value="${rMap.DEPT_NM}"/></td>
							<th>직급</th>
							<td class="left"><c:out value="${rMap.POSI_NM}"/></td>
						</tr> --%>
						<tr>
							<th>이름(한글)</th>
							<td class="left"><c:out value="${str:getReverseXSS(rMap.USER_NM)}"/></td>
							<th>등록일시</th>
							<td colspan="3" class="left"><c:out value="${rMap.REG_DTM}"/></td>
						</tr>
						<tr>
							<th>핸드폰</th>
							<td class="left"><c:out value="${rMap.HP_NO}"/></td>
							<th>이메일</th>
							<td class="left"><c:out value="${rMap.EMAIL}"/></td>
						</tr>
						<tr>
							<th>SMS 수신여부</th>
							<td><c:out value="${rMap.PHONE_RECV}"/></td>
							<th>이메일 수신여부</th>
							<td><c:out value="${rMap.EMAIL_RECV}"/></td>
						</tr>
					</tbody>
				</table>
			</div>

			<!-- page_btn_wrap -->
			<div class="page_btn_wrap jc_between mt20">
			
				<div class="lft">
					<a class="btn_n_del" href="javascript:fn_Delete();"><span>삭제</span></a>
				</div>
				<div class="rgt">
					<a class="btn_n_modi" href="javascript:fn_Update();"><span>수정</span></a>
					<a class="btn_n_list" href="javascript:fn_List();"><span>목록</span></a>
				</div>
			
			</div>
			<!-- // page_btn_wrap -->
			
		</div>
		<!--// sub_contents_area-->

	</div>
	<!--/ sub_contents_wrap-->
</body>