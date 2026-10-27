<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 메디링크 FAQ - 상세 (게시판목록구분 MFAQ, admMedicalBoard 컨트롤러 + sql/medical_board.xml 사용)
 *            faqView.jsp 기반
 **************************************************/
%>
<head>
	<script type="text/javascript">
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='${mbUrl}/Regist.do'/>").submit();
		}
		//삭제
		function fn_Delete(){
			if( confirm("삭제하겠습니까?") ){
				$("#frm").attr("action","<c:url value='${mbUrl}/DeleteProc.do'/>").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='${mbUrl}/List.do'/>").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${(not empty rMap.BOARD_MNG_NO)?rMap.BOARD_MNG_NO:boardMngNo}"/>"/>
	<input type="hidden" id="boardNo" name="boardNo" value="<c:out value="${rMap.BOARD_NO}"/>"/>
	<input type="hidden" id="chk" name="chk" value="${rMap.BOARD_MNG_NO}:${rMap.BOARD_NO}"/>
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4 fix"></h4>

			<div class="table_header">
				<h6 class="sub_tit_h6">FAQ 상세</h6>
			</div>

			<div class="table_wrap n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="FAQ 상세" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>카테고리</th>
							<td><c:out value="${empty rMap.BOARD_TYPE ? '-' : rMap.BOARD_TYPE}"/></td>
							<th>게시여부</th>
							<td>
								<c:choose>
									<c:when test="${rMap.OPEN_YN eq 'Y'}">게시</c:when>
									<c:otherwise>숨김</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<tr>
							<th>작성자</th>
							<td><c:out value="${rMap.REG_NM}"/></td>
							<th>등록일시</th>
							<td><c:out value="${rMap.REG_DTM}"/></td>
						</tr>
						<tr>
							<th>질문</th>
							<td colspan="3"><c:out value="${str:getReverseXSS(rMap.TITLE)}"/></td>
						</tr>
						<tr>
							<th>답변</th>
							<td class="td_con" valign="top" colspan="3"><c:out value="${str:getReverseXSS(rMap.CONTS)}" escapeXml="false"/></td>
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
		<!--sub_contents_area-->
	</div>
	<!-- //sub_contents_wrap -->
</form>
</body>
