<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 회원정보 조회
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<head>
	<script type="text/javascript">
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}Regist.do'/>");
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
			if( confirm("해당 회원을 삭제하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/member/comDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}List.do'/>");
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

				<h4 class="sub_tit_h4 fix">
					<c:choose>
						<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><em>일반 회원 상세</em></c:when>
						<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><em>연구자 회원 상세</em></c:when>
						<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><em>평가위원 회원 상세</em></c:when>
					</c:choose>
				</h4>
				
				<div class="table_header">
					<h6 class="sub_tit_h6">기본정보</h6>
				</div>

				<div class="table_wrap n_table_sty01 n_view01 mt10">
					<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
						<colgroup>
							<col width="15%"/>
							<col width="35%"/>
							<col width="15%"/>
							<col width="35%"/>
						</colgroup>
						<tbody>
							<tr>
								<th>
									아이디
									<div class="tooltip">
										<button class="tooltip_icon"></button>
										<div class="tooltip_inner">
											<div class="tooltip_con">
												아이디는 수정할 수 없습니다. 
											</div>
											<button class="tooltip_close"></button>
											<span class="tooltip_arrow"></span>
										</div>
									</div>
								</th>
								<td colspan="3"><c:out value="${rMap.USER_ID}"/></td>
							</tr>
							<tr>
								<th>이름(국문)</th>
								<td colspan="3"><c:out value="${rMap.USER_NM}"/></td>
								<%-- <th>이름(영문)</th>
								<td><c:out value="${rMap.USER_ENG_NM}"/></td> --%>
							</tr>
							
							<tr>
								<th>핸드폰번호</th>
								<td><c:out value="${rMap.HP_NO}"/></td>
								<th>이메일</th>
								<td><c:out value="${rMap.EMAIL}"/></td>
								
							</tr>
							<tr>
								<th>SMS 수신여부</th>
								<td><c:out value="${rMap.PHONE_RECV}"/></td>
								<th>이메일 수신여부</th>
								<td><c:out value="${rMap.EMAIL_RECV}"/></td>
							</tr>
							<tr>
								<th>생년월일</th>
								<td>
									<%-- <fmt:parseDate value="${rMap.BIRTH}" var="BIRTH" pattern="yyyyMMdd"/>
									<fmt:formatDate value="${BIRTH}" pattern="yyyy.MM.dd"/> --%>
									<c:out value="${rMap.BIRTH}"/>
								</td>
								<th>성별</th>
								<td>
									<c:choose>
										<c:when test="${rMap.GENDER eq 'M'}">남</c:when>
										<c:otherwise>여</c:otherwise>
									</c:choose>
								</td>
							</tr>
							<tr>
								<th>우편번호</th>
								<td colspan="3"><c:out value="${rMap.ZIP_NO}"/></td>
							</tr>
							<tr>
								<th>주소</th>
								<td colspan="3">
									<c:out value="${rMap.ADDR}"/>
								</td>
							</tr>
							<tr>
								<th>상세주소</th>
								<td colspan="3">
									<c:out value="${rMap.ADDR_PT}"/>
								</td>
							</tr>
							<%-- <tr>
								<th>회사이름</th>
								<td><c:out value="${rMap.COMP_NM}"/></td>
								<th>회사전화번호</th>
								<td><c:out value="${rMap.COMP_TEL_NO}"/></td>
							</tr>
							<tr>
								<th>부서</th>
								<td><c:out value="${rMap.DEPT_NM}"/></td>
								<th>직위/직급</th>
								<td><c:out value="${rMap.POSI_NM}"/></td>
							</tr> --%>
						</tbody>
					</table>
				</div>

				<div class="page_btn_wrap jc_between mt20">
					<div class="lft"></div>
					<div class="rgt">
						<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>수정</span></a>
						<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
					</div>
				</div>

			<!--sub_contents_area-->
			</div>

		</div>
		<!-- //sub_contents_wrap -->

	</form>
</body>