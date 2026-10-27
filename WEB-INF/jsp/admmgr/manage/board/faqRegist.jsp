<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 게시판 등록
 **************************************************/
%>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<style type="text/css">
		.file_cont{border: 2px solid #043e88;}
		.file_cont .file_tit{background: #043e88;display: table;width: 100%;padding: 0px 12px 0 24px;box-sizing: border-box;height: 40px;}
		.file_cont .file_tit > p{font-size: 14px;font-weight: 700;color: #fff;line-height: 1;position: relative;font-family: 'Malgun Gothic';display: table-cell;padding-top: 10px;}
		.file_cont .file_tit > p:before{position: absolute;content: '';display: block;width: 3px;height: 3px;background-color: #fff;left: -10px;margin-top: 6px;}
		.file_cont .file_btn{vertical-align: middle;display: table-cell;text-align: right;}
		.file_list{background-color: #fff;}
		.file_list li{border-bottom: 1px solid #d2d8e7;padding: 8px 13px;}
		.file_list li .file_no{text-align: center;font-size: 14px;font-weight: 400;color: #333333;}
		.file_list li .file_size{font-size: 14px;font-weight: 400;color: #666666;line-height: 1;float: right;display: inline-block;margin-top: 4px;}
		.file_list li:last-of-type{border-bottom: 0;}
		.btn_add{width:120px;background: #00aeff url(<c:url value="/common/admmgr/images/ico/ico_pluse.png"/>)no-repeat;background-position: calc(100% - 13px) center;font-size: 13px;font-weight: 400;text-align: left;color: #fff !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;border: 1px solid #00aeff;box-sizing: border-box;height: 30px;}
		.btn_remove{width:120px;background: #ffffff url(<c:url value="/common/admmgr/images/ico/ico_minus.png"/>)no-repeat;background-position: calc(100% - 13px) center;border: 1px solid #d2d2d2;font-size: 13px;font-weight: 400;text-align: left;color: #999999 !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;box-sizing: border-box;height: 30px;}
		.check_box input[type="checkbox"]{display: none;}
		.check_box input[type="checkbox"] + label{display: inline-block;cursor: pointer;vertical-align: middle;font-size: 14px;font-weight: 400;line-height: 17px;color: #333;font-family: 'Malgun Gothic',sans-serif;margin-right: 25px;}
		.check_box input[type="checkbox"] + label span{display: inline-block;height: 20px;background: url(<c:url value="/common/admmgr/images/ico/ico_check_off.png"/>) no-repeat left 50%;vertical-align: middle;vertical-align: middle;transition: all ease-out 0.2s;padding-left: 27px;}
		.check_box input[type="checkbox"]:checked + label span{background: url(<c:url value="/common/admmgr/images/ico/ico_check_on.png"/>) no-repeat left 50%;}
	</style>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			//[Init]cheditor
			var texteditor;
			fn_Cheditor();
		});
		function fn_Cheditor(){
			texteditor = new cheditor();              	// 에디터 개체를 생성합니다.
			texteditor.config.editorHeight = '300px';   // 에디터 세로폭입니다.
			texteditor.config.editorWidth = '100%';     // 에디터 가로폭입니다.
			texteditor.config.imgSetAttrWidth = -1;		// -1 = (width="100%"; height="auto"), 0 = 설정 안함, 1 = 기본값
			texteditor.inputForm = 'conts';             // textarea의 id입니다. 주의: name 속성 이름이 아닙니다.
			texteditor.run();                           // 에디터를 실행합니다.
		}
		
		//등록
		function fn_Regist(){
			const titleInput = document.getElementsByName("title")[0];
			const title = titleInput.value;

			if( $("#regNm").val().trim() == "" ){
				alert("작성자를 입력해주세요.");
				$("#regNm").focus();
				return false;
			}
			
			if( title.trim() == "" ){
				alert("제목을 입력해주세요.");
				titleInput.focus();
				return false;
			}
			
			//[2]HtmlEditor Value 재정의
			var textBody = texteditor.outputBodyHTML();
			if( textBody.length > 0 ){
				$("#conts").val(textBody);
			}
			if( $("#conts").val() == "" ){ 
				alert("내용을 입력해주세요.");
				$("#conts").focus();
				return false;
			}
			
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/Regist${boardMngNo}Proc.do'/>").submit();
		}
		
		//삭제
		function fn_Delete(){
			if( confirm("삭제하겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/board/Delete${boardMngNo}Proc.do'/>").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/List${boardMngNo}.do'/>").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${(not empty rMap.BOARD_MNG_NO)?rMap.BOARD_MNG_NO:boardMngNo}"/>"/>
	<input type="hidden" id="boardNo" name="boardNo" value="<c:out value="${rMap.BOARD_NO}"/>"/>
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
		
			<h4 class="sub_tit_h4">
			</h4>
		
			<div class="table_header">
				<h4 class="sub_tit_h4 fix"><em>게시글 ${(not empty rMap.CONTS_NO)?'수정':'등록'}</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span></h4>
			</div>
			
			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="40%">
					</colgroup>
					<tbody>
						<tr>
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
							<th>작성자 <em class="point">&nbsp;</em></th>
							<td>
								<input type="text" id="regNm" name="regNm" class="input_text" style="width:calc(100% - 20px);" value="<c:out value="${(not empty rMap.REG_NM)?rMap.REG_NM:'관리자'}"/>"/>
							</td>
						</tr>
						<tr>
							<th>제목 <em class="point">&nbsp;</em></th>
							<td colspan="3"><input type="text" id="title" name="title" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.TITLE)}"/>"/></td>
						</tr>
						<tr>
							<th>내용 <em class="point">&nbsp;</em></th>
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