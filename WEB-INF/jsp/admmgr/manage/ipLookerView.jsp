<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 공지사항  상세
 **************************************************/
%>
<head>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript">		
// 		function fn_Regist(){
// 			//[1]Validate
// 			if( $("#title").val() == "" ){
// 				alert("제목을 입력해 주세요.");
// 				$("#title").focus();
// 				return false;
// 			}	
			
// 			$("#frm").attr("action","<c:url value='/admmgr/manage/board/auditRegist.do'/>").submit();
// 		}	

		//삭제
// 		function fn_Delete(){
// 			if( confirm("삭제하겠습니까?") ){
// 				$("#frm").attr("action","<c:url value='/admmgr/manage/board/auditDeleteProc.do'/>").submit();
// 			}
// 		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerList.do'/>").submit();
		}
		
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="gubun" name="gubun" value="<c:out value="${(not empty rMap.GUBUN)?rMap.GUBUN:gubun}"/>"/>
	<input type="hidden" id="seq" name="seq" value="<c:out value="${rMap.SEQ}"/>"/>
	<input type="hidden" id="fileNo1" name="fileNo1" value="<c:out value="${rMap.FILE_SEQ}"/>"/>
	<input type="hidden" id="chk" name="chk" value="${rMap.GUBUN}:${rMap.SEQ}"/>
	<input type="hidden" id="page" name="page" value="<c:out value="${param.page}"/>"/>
	
	
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
		
			<h4 class="sub_tit_h4 fix">
				<em>상세</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span>
			</h4>
			
			<div class="box_tit">
				<h6 class="title">기본정보</h6>
			</div>
			
			<div class="table_wrap n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="40%">
					</colgroup>
					<tbody>
						<tr>
							<th>시작 IP </th>
							<td><c:out value="${rMap.START_IP}"/></td>
							<th>종료 IP </th>
							<td><c:out value="${rMap.END_IP}"/></td>
						</tr>
						<tr>
							<th>신청자 </th>
							<td><c:out value="${rMap.REG_NM}"/></td>
							<th>이메일 </th>
							<td><c:out value="${rMap.REG_EMAIL}"/></td>
						</tr>
						<tr>
							<th>기업명 </th>
							<td><c:out value="${rMap.REG_COMP}"/></td>
							<th>전화번호 </th>
							<td><c:out value="${rMap.REG_TEL}"/></td>
						</tr>
						<tr>
							<th>비고 </th>
							<td colspan="3"><c:out value="${rMap.REMARK}"/></td>
						</tr>
						<tr>
							<th>승인여부 </th>
								<td colspan="3">
								    <label class="ch"><input type="checkbox" onclick="checkboxClicked()" value="Y" name="appYn" id="appYn" ${rMap.APP_YN eq "Y" ? 'checked="checked"' : '' }><span>승인</span></label>
								</td>
						</tr>
						<tr>
							<th>등록일 </th>
							<td>
								<c:out value="${rMap.REG_DTM}"/>
							</td>
							<th>최종 수정일 </th>
							<td>
								<c:out value="${rMap.MDF_DTM}"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<!-- <a class="btn1_ty1" href="javascript:void(0);" onclick="javascript:fn_Delete();"><em>삭제</em></a>
					<a class="btn1_ty4" href="javascript:void(0);" onclick="javascript:fn_Regist();"><em>수정</em></a> -->
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>
			
			
		</div>
	</div>
</form>
<script>
function checkboxClicked() {
    var isChecked = document.getElementById("appYn").checked;
    $("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerCdUpdate.do'/>").submit();
}
</script>
</body>