<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 게시판 속성 관리 등록/수정
 **************************************************/
%>
<head>
	<script type="text/javascript">
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngList.do'/>");
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			if( $("#boardNm").val() == "" ){
				alert("게시판명을 입력해 주세요.");
				$("#boardNm").focus();
				return false;
			}
			if( $("#boardDc").val() == "" ){
				alert("게시판설명을 입력해 주세요.");
				$("#boardDc").focus();
				return false;
			}
			if( $("#boardType").val() == "" ){
				alert("게시판타입을 선택해 주세요.");
				$("#boardType").focus();
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngWriteProc.do'/>");
			$("#frm").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${rMap.BOARD_MNG_NO}"/>"/>
	<!--sub_contents_wrap-->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<div class="box_tit">
				<h6 class="title">게시판 속성 ${(not empty rMap.USER_ID)?'수정':'등록'}</h6>
			</div>

			<div class="n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="15%">
						<col width="35%">
						<col width="15%">
						<col width="35%">
					</colgroup>
					<tbody>
						<tr>
							<th>게시판명 <b class="c_red">*</b></th>
							<td colspan="3">
								<input type="text" class="form_text wd320" id="boardNm" name="boardNm" value="<c:out value="${rMap.BOARD_NM}"/>" placeholder="게시판명을 입력해 주세요." maxlength="50" style="width:90%">
							</td>
						</tr>
						<tr>
							<th>게시판설명 <b class="c_red">*</b></th>
							<td colspan="3">
								<input type="text" class="form_text wd320" id="boardDc" name="boardDc" value="<c:out value="${rMap.BOARD_DC}"/>" placeholder="게시판설명을 입력해 주세요." maxlength="200" style="width:90%">
							</td>
						</tr>
						<tr>
							<th>게시판목록구분 <b class="c_red">*</b></th>
							<td colspan="3">
								<select name="boardListType" id="boardListType" class="form_select wd320" title="게시판목록 구분 선택" style="min-width:250px;">
									<option value="">전체</option>
									<option value="BASIC" ${(rMap.BOARD_LIST_TYPE eq 'BASIC')?"selected='selected'":""}>BASIC</option>
									<option value="IMG"   ${(rMap.BOARD_LIST_TYPE eq 'IMG' )?"selected='selected'":""}>IMG</option>
									<option value="FAQ"	  ${(rMap.BOARD_LIST_TYPE eq 'FAQ')?"selected='selected'":""}>FAQ</option>
									<option value="PRESS" ${(rMap.BOARD_LIST_TYPE eq 'PRESS')?"selected='selected'":""}>PRESS</option>
									<option value="REFERENCE" ${(rMap.BOARD_LIST_TYPE eq 'REFERENCE')?"selected='selected'":""}>REFERENCE</option>
									<%-- 메디링크(강원 메디컬 AI) 전용 - admmgr/manage/board/mnotice*.jsp, mfaq*.jsp / 사용자 /front/medical/noticeList.do, faq.do --%>
									<option value="MNOTICE" ${(rMap.BOARD_LIST_TYPE eq 'MNOTICE')?"selected='selected'":""}>MNOTICE (메디링크 공지사항)</option>
									<option value="MFAQ" ${(rMap.BOARD_LIST_TYPE eq 'MFAQ')?"selected='selected'":""}>MFAQ (메디링크 FAQ)</option>
									<%--
									<option value="BOOK"  ${(rMap.BOARD_LIST_TYPE eq 'BOOK')?"selected='selected'":""}>BOOK</option>
									<option value="MEDIA" ${(rMap.BOARD_LIST_TYPE eq 'MEDIA')?"selected='selected'":""}>MEDIA</option>
									<option value="BUSINESS" ${(rMap.BOARD_LIST_TYPE eq 'BUSINESS')?"selected='selected'":""}>BUSINESS</option>
									--%>
									<%--
									<c:out value="${str:makeCodeSelectBoxForPtCode('001000000000000','011000000000000','${rMap.BOARD_LIST_TYPE}')}" escapeXml="false"/>
									--%>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
			</div>


			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<span class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</span>
			</div>
			
		</div>
		<!--// sub_contents_area-->

	</div>
	<!--/ sub_contents_wrap-->
</form>
</body>