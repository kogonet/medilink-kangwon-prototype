<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 메디링크 FAQ - 등록/수정 (게시판목록구분 MFAQ, admMedicalBoard 컨트롤러 + sql/medical_board.xml 사용)
 *            faqRegist.jsp 기반. 카테고리(boardType → MEDIA_NAME 컬럼, 화면에서는 BOARD_TYPE)는 사용자 FAQ 화면의 탭이 된다.
 *            카테고리 목록을 바꾸면 def.front.medical.frontMedicalBoard.FAQ_CATEGORIES 도 같이 수정할 것.
 **************************************************/
%>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			fn_Cheditor();
		});

		var texteditor;
		function fn_Cheditor(){
			texteditor = new cheditor();
			texteditor.config.editorHeight = '300px';
			texteditor.config.editorWidth = '100%';
			texteditor.config.imgSetAttrWidth = -1;
			texteditor.inputForm = 'conts';
			texteditor.run();
		}

		//등록
		function fn_Regist(){
			if( $("#boardType").val() == "" ){
				alert("카테고리를 선택해주세요.");
				$("#boardType").focus();
				return false;
			}
			if( $("#regNm").val().trim() == "" ){
				alert("작성자를 입력해주세요.");
				$("#regNm").focus();
				return false;
			}
			//데코레이터(default_admmgr)에 id="title" 요소가 있어 name으로 찾음
			var titleInput = $("#frm input[name=title]");
			if( titleInput.val().trim() == "" ){
				alert("질문을 입력해주세요.");
				titleInput.focus();
				return false;
			}

			var textBody = texteditor.outputBodyHTML();
			if( textBody.length > 0 ){
				$("#conts").val(textBody);
			}
			if( $("#conts").val() == "" ){
				alert("답변을 입력해주세요.");
				return false;
			}

			$("#frm").attr("action","<c:url value='${mbUrl}/RegistProc.do'/>").submit();
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='${mbUrl}/List.do'/>").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${(not empty rMap.BOARD_MNG_NO)?rMap.BOARD_MNG_NO:boardMngNo}"/>"/>
	<input type="hidden" id="boardNo" name="boardNo" value="<c:out value="${rMap.BOARD_NO}"/>"/>
	<%-- FAQ는 상위고정 없음 - 프로시저에 빈 값이 넘어가지 않도록 일반(100) 고정 --%>
	<input type="hidden" id="topOrder" name="topOrder" value="100"/>
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4"></h4>

			<div class="table_header">
				<h4 class="sub_tit_h4 fix"><em>FAQ ${(not empty rMap.BOARD_NO)?'수정':'등록'}</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span></h4>
			</div>

			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="FAQ 등록" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>카테고리 <em class="point">&nbsp;</em></th>
							<td>
								<select id="boardType" name="boardType" class="form_select md" title="카테고리 선택" style="min-width:200px;">
									<option value="">선택</option>
									<option value="카테고리1" ${ rMap.BOARD_TYPE eq '카테고리1' ? "selected='selected'" : "" }>카테고리1</option>
									<option value="카테고리2" ${ rMap.BOARD_TYPE eq '카테고리2' ? "selected='selected'" : "" }>카테고리2</option>
									<option value="카테고리3" ${ rMap.BOARD_TYPE eq '카테고리3' ? "selected='selected'" : "" }>카테고리3</option>
									<option value="카테고리4" ${ rMap.BOARD_TYPE eq '카테고리4' ? "selected='selected'" : "" }>카테고리4</option>
								</select>
							</td>
							<th>게시여부 <em class="point">&nbsp;</em></th>
							<td>
								<div class="agree_check_box">
									<input type="radio" id="openYn1" name="openYn" value="Y" <c:if test="${rMap.OPEN_YN eq 'Y' || empty rMap.OPEN_YN}">checked="checked"</c:if>/>
									<label for="openYn1"><span>게시</span></label>
									&nbsp;&nbsp;&nbsp;
									<input type="radio" id="openYn2" name="openYn" value="N" <c:if test="${rMap.OPEN_YN eq 'N'}">checked="checked"</c:if>/>
									<label for="openYn2"><span>숨김</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>작성자 <em class="point">&nbsp;</em></th>
							<td colspan="3">
								<input type="text" id="regNm" name="regNm" class="form_text" style="width:300px;" value="<c:out value="${(not empty rMap.REG_NM)?rMap.REG_NM:userMap.userNm}"/>"/>
							</td>
						</tr>
						<tr>
							<th>질문 <em class="point">&nbsp;</em></th>
							<td colspan="3"><input type="text" id="title" name="title" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.TITLE)}"/>"/></td>
						</tr>
						<tr>
							<th>답변 <em class="point">&nbsp;</em></th>
							<td class="td_con" valign="top" colspan="3">
								<textarea id="conts" name="conts" cols="" rows="" style="width:calc(100% - 20px);"><c:out value="${rMap.CONTS}" escapeXml="false"/></textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>

		</div>
		<!-- // sub_contents_area -->
	</div>
	<!-- // sub_contents_wrap -->
</form>
</body>
