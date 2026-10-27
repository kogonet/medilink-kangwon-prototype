<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 탈퇴회원 조회
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<head>
	<script type="text/javascript">
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/member/withDrawRegist.do'/>");
			$("#frm").submit();
		}
		/*
		//승인
		function fn_Approve(){
			$("#frm").attr("action","<c:url value='/admmgr/member/comApproveProc.do'/>");
			$("#frm").submit();
		}
		*/
		//삭제
		function fn_Delete(){
			if( confirm("선택된 항목을 삭제하겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/member/withDrawDeleteProc2.do'/>");
				$("#frm").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/member/withDrawList.do'/>");
			$("#frm").submit();
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="userTp" name="userTp" value="<c:out value="${userTp}"/>"/>
		<input type="hidden" id="userId" name="userId" value="<c:out value="${rMap.USER_ID}"/>"/>
		
		
		<!-- sub_contents_wrap -->
		<div class="sub_contents_wrap">
			<!--sub_contents_area-->
			<div class="sub_contents_area">
		
				<%-- <h4 class="sub_tit_h4 fix">
					<c:choose>
						<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><em>일반 회원 상세</em></c:when>
						<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><em>연구자 회원 상세</em></c:when>
						<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><em>평가위원 회원 상세</em></c:when>
					</c:choose>
				</h4> --%>
				
				<div class="table_header">
					<h6 class="sub_tit_h6">기본정보</h6>
				</div>
				
					<div class="table_wrap n_table_sty01 n_view01 mt10">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
							<colgroup>
								<col width="10%"/>
								<col width="40%"/>
								<col width="10%"/>
								<col width="40%"/>
							</colgroup>
							<tbody>
								<tr>
									<th>아이디</th>
									<td><c:out value="${str:getReverseXSS(rMap.USER_ID)}"/></td>
									<th>핸드폰번호</th>
									<td><c:out value="${rMap.HP_NO}"/></td>
								</tr>
								<%-- <tr>
									<th>이름(국문)</th>
									<td><c:out value="${str:getReverseXSS(rMap.USER_NM)}"/></td>
								</tr> --%>
								<%-- <tr>
									<th>이메일</th>
									<td colspan="3"><c:out value="${str:getReverseXSS(rMap.EMAIL)}"/></td>
								</tr> --%>
								<tr>
									<th>가입일자</th>
									<td><c:out value="${str:getReverseXSS(rMap.JOIN_DTM)}"/></td>
									<th>탈퇴일자</th>
									<td><c:out value="${str:getReverseXSS(rMap.WITHDRAW_DTM)}"/></td>
								</tr>
								<tr>
									<th>탈퇴 사유</th>
									<td colspan="3"><c:out value="${str:getReverseXSS(rMap.WITHDRAW_DESC)}"/></td>
								</tr>
							</tbody>
						</table>
					</div>

					<div class="page_btn_wrap jc_between mt20">
						<div class="lft">
							<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
						</div>
						<div class="rgt">
							<!-- <a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>수정</span></a> -->
							<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
						</div>
					</div>
					
				<!--sub_contents_area-->
				</div>
					
			</div>
			<!-- //sub_contents_wrap -->
				
	</form>
</body>