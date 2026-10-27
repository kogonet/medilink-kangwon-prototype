<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 응급 의료기관 정보 관리 - 상세
 **************************************************/
%>
<head>
	<script type="text/javascript">
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/Regist.do'/>").submit();
		}
		function fn_Delete(){
			if( confirm("삭제하겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/DeleteProc.do'/>").submit();
			}
		}
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/List.do'/>").submit();
		}
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
				<h6 class="sub_tit_h6">응급 의료기관 정보 상세</h6>
			</div>

			<div class="table_wrap n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="응급 의료기관 정보 상세" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>기관명</th>
							<td><c:out value="${rMap.dutyName}"/></td>
							<th>분류</th>
							<td><c:out value="${rMap.dutyEmclsName}"/></td>
						</tr>
						<tr>
							<th>주소</th>
							<td colspan="3"><c:out value="${rMap.dutyAddr}"/></td>
						</tr>
						<tr>
							<th>대표전화</th>
							<td><c:out value="${rMap.dutyTel1}"/></td>
							<th>응급실전화</th>
							<td><c:out value="${rMap.dutyTel3}"/></td>
						</tr>
						<tr>
							<th>운영시간</th>
							<td colspan="3"><c:out value="${rMap.openTime}"/> ~ <c:out value="${rMap.closeTime}"/></td>
						</tr>
						<tr>
							<th>좌표(위도/경도)</th>
							<td colspan="3"><c:out value="${rMap.wgs84Lat}"/> / <c:out value="${rMap.wgs84Lon}"/></td>
						</tr>
					</tbody>
				</table>
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
