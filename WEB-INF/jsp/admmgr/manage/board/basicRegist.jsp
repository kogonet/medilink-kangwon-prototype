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
	<link rel="stylesheet" type="text/css"	href="/plug-in/coaUpload/CoaUpload.css" />
	<script type="text/javascript" src="/plug-in/coaUpload/CoaConfig.js"></script>
	<script type="text/javascript" src="/plug-in/coaUpload/CoaUpload.min.js"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script> 
	<script type="text/javascript">
		$(document).ready(function(){
			
			//[Init]cheditor
			var texteditor;
			fn_Cheditor();
			//[Init]File Component
			// 업로드창이 활성화 되었을때
			if ($("#upload_area").length > 0) {
				// Coa_InitCustom(area_id, folder_nm, file_type, callback_fn, colum_nm)
				Coa_InitCustom("upload_area", "board_${boardMngNo}", "boardFile", fn_RegistProc, "fileNo1");
			}
			
		});
		
		function fn_Cheditor(){
			texteditor = new cheditor();              	// 에디터 개체를 생성합니다.
			texteditor.config.editorHeight = '300px';   // 에디터 세로폭입니다.
			texteditor.config.editorWidth = '100%';     // 에디터 가로폭입니다.
			texteditor.config.imgSetAttrWidth = -1;		// -1 = (width="100%"; height="auto"), 0 = 설정 안함, 1 = 기본값
			texteditor.inputForm = 'conts';             // textarea의 id입니다. 주의: name 속성 이름이 아닙니다.
			texteditor.run();                           // 에디터를 실행합니다.
		}
		
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
			if( $("#boardMngNo").val() != "3" && $("#conts").val() == "" ){ 
				alert("내용을 입력해주세요.");
				$("#conts").focus();
				return false;
			}
			
			//[3]파일등록여부 확인
			if ( $(".coa_file").length > 0 ) {
				Coa.Upload();
			} else {
				fn_RegistProc();
			}
		}
		function fn_RegistProc(){
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
	<input type="hidden" id="columNm" name="columNm" value=""/>
	<input type="hidden" id="fileNo1" name="fileNo1" value="<c:out value="${rMap.FILE_NO_1}"/>"/>
	<input type="hidden" id="fileNo2" name="fileNo2" value="<c:out value="${rMap.FILE_NO_2}"/>"/>
	<!-- sub_contents_wrap -->
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
								<th>상위공지여부 <em class="point">&nbsp;</em></th>
								<td>
									<div class="agree_check_box">
										<input type="radio" id="topOrder1" name="topOrder" value="50" <c:if test="${rMap.TOP_ORDER eq '50'}">checked="checked"</c:if>/>
										<label for="topOrder1"><span>상위</span></label>
										&nbsp;&nbsp;&nbsp;
										<input type="radio" id="topOrder2" name="topOrder" value="100" <c:if test="${rMap.TOP_ORDER eq '100' || empty rMap.TOP_ORDER}">checked="checked"</c:if>/>
										<label for="topOrder2"><span>일반</span></label>
									</div>
								</td>
							</tr>
							<tr>
								<th>작성자 <em class="point">&nbsp;</em></th>
								<td>
									<input type="text" id="regNm" name="regNm" class="input_text" style="width:calc(100% - 20px);" value="<c:out value="${(not empty rMap.REG_NM)?rMap.REG_NM:userMap.userNm}"/>"/>
								</td>
								<th>링크 URL(새창으로 열기)</th>
								<td>
									<input type="text" id="linkUrl" name="linkUrl" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.LINK_URL}"/>"/>
								</td>
							</tr>
							
							<!-- 공지사항 일 때 -->
							<c:if test="${boardMngNo eq '1'}">
								<tr>
									<th>타입 <em class="point">&nbsp;</em></th>
									<td colspan="3">
										<select id="boardType" name="boardType" class="form_select md w15" title="게시글 타입 선택">
											<option value="공지" ${ rMap.BOARD_TYPE eq '공지' ? "selected='selected'" : "" }>공지</option>
											<option value="알림" ${ rMap.BOARD_TYPE eq '알림' ? "selected='selected'" : "" }>알림</option>
											<option value="언론" ${ rMap.BOARD_TYPE eq '언론' ? "selected='selected'" : "" }>언론</option>
											<option value="행사" ${ rMap.BOARD_TYPE eq '행사' ? "selected='selected'" : "" }>행사</option>
										</select>
									</td>
								</tr>
							</c:if>
							<c:if test="${boardMngNo eq '3'}">
								<th>연도 <em class="point">&nbsp;</em></th>
								<td>
									<input type="text" id="year" name="year" class="form_text wd120" value="${ fn:substring( rMap.YEAR, 0, 10 ) }" onclick="calendar(event,'year','yyyy-mm-dd')" style="cursor:pointer;">
									<img src="/common/admmgr/images/sub_common/ico_cal1.png" onclick="calendar(event,'year','yyyy-mm-dd')"/>
								</td>
							</c:if>
							<tr>
								<th>제목 <em class="point">&nbsp;</em></th>
								<!-- default_admmgr id="title" 중복 -->
								<td colspan="3"><input type="text" id="title" name="title" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.TITLE)}"/>"/></td>
							</tr>
							<tr>
								<th>내용 <em class="point">&nbsp;</em></th>
								<td class="td_con" valign="top" colspan="3">
									<textarea id="conts" name="conts" cols="" rows="" style="width:calc(100% - 20px);"><c:out value="${rMap.CONTS}" escapeXml="false"/></textarea>
								</td>
							</tr>
							<tr>
								<th>첨부파일 다운로드</th>
								<td colspan="3">
									<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
										<colgroup>
											<col width="80%">
											<col width="20%">
										</colgroup>
										<tbody>
											<c:set var="fileList1" value="${str:makeFileList(rMap.FILE_NO_1)}"/>
											<c:choose>
												<c:when test="${fn:length(fileList1) eq 0}">
													<tr>
														<th class="center" colspan="2">등록된 파일이 없습니다.</th>
													</tr>
												</c:when>
												<c:otherwise>
													<c:forEach items="${fileList1}" var="fileList1" varStatus="status">
														<tr>
															<td><strong><c:out value="${fileList1.ORIGIN_NM}"/></strong></th>
															<td>
																<input type="button" class="btn_ty2" value="다운로드" onclick="javascript:fileDownload('<c:out value="${fileList1.FILE_NO}"/>','<c:out value="${fileList1.FILE_SEQ}"/>'); return false;" />
																<input type="button" class="btn_ty1" value="삭제" onclick="javascript:fileDeleteLogi(this, '<c:out value="${fileList1.FILE_NO}"/>','<c:out value="${fileList1.FILE_SEQ}"/>'); return false;" />
															</td>
														</tr>
													</c:forEach>
												</c:otherwise>
											</c:choose>
										</tbody>
									</table>
								</td>
							</tr>
							<tr>
								<th>첨부파일 등록</th>
								<td class="td_con" valign="top" colspan="3">
									<div class="upload_form" id="upload_area"></div>
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