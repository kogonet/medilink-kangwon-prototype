<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 설문조사 등록
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<style type="text/css">
		.btn_add{width:120px;background: #00aeff url(/common/admmgr/images/ico/ico_pluse.png)no-repeat;background-position: calc(100% - 13px) center;font-size: 13px;font-weight: 400;text-align: left;color: #fff !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;border: 1px solid #00aeff;box-sizing: border-box;height: 30px;}
		.btn_remove{width:120px;background: #ffffff url(/common/admmgr/images/ico/ico_minus.png)no-repeat;background-position: calc(100% - 13px) center;border: 1px solid #d2d2d2;font-size: 13px;font-weight: 400;text-align: left;color: #999999 !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;box-sizing: border-box;height: 30px;}
	</style>

	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<link rel="stylesheet" type="text/css"	href="/plug-in/coaUpload/CoaUpload.css" />
	<script type="text/javascript" src="/plug-in/coaUpload/CoaConfig.js"></script>
	<script type="text/javascript" src="/plug-in/coaUpload/CoaUpload.min.js"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
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
		function fn_Regist(){
			const titleInput = document.getElementsByName("title")[0];
			const title = titleInput.value;
			
			//[1]Validate
			if( $("#gubun").val() == "" ){
				alert("분류를 선택해 주세요.");
				$("#gubun").focus();
				return false;
			}
			if( $("#writer").val() == "" ){
				alert("작성자를 입력해 주세요.");
				$("#writer").focus();
				return false;
			}			
			
			if( title.trim() == "" ){
				alert("제목을 입력해주세요.");
				titleInput.focus();
				return false;
			}
			
			if( $("#s_date_start").val() == "" ){
				alert("시작일을 입력해 주세요.");
				$("#s_date_start").focus();
				return false;
			}
			
			if( $("#s_date_end").val() == "" ){
				alert("종료일을 입력해 주세요.");
				$("#s_date_end").focus();
				return false;
			}
			
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			
			//[2]HtmlEditor Value 재정의
			var textBody = texteditor.outputBodyHTML();
			console.log(textBody);
			console.log($("#conts"));
			if( textBody.length > 0 ){
				$("#conts").val(textBody);
			}
			if( $("#conts").val() == "" ){
				alert("내용을 입력해 주세요.");
				$("#conts").focus();
				return false;
			}
			
			fn_RegistProc();
		}
		
		function fn_RegistProc(){

			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyRegistProc.do'/>").submit();
			
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyList.do'/>").submit();
		}
		
		//상세
		function fn_Detail(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyView.do'/>").submit();
		}
		
		// 그룹 추가
		$('.add_group_btn').live('click', function () {
			
			var group_obj = "" +
							"<table cellspacing='0' cellpadding='0' border='0' summary='게시판 뷰' class='tbl_ty2 group_tr'>"+
							"	<colgroup>"+
							"		<col width='15%' />"+
							"		<col width='75%' />"+
							"		<col width='10%' />"+
							"	</colgroup>"+
							"	<tbody>"+
							"		<tr>"+
							"			<th>그룹번호</th>"+
							"			<td class='group_key'>1</td>"+
							"			<td rowspan='3'>"+
							"				<input class='gray_btn_s del_group_btn hand' type='button' value='그룹삭제' />"+
							"				<input type='hidden' name='group_seq' class='group_seq' value='1' />"+
							"			</td>"+
							"		</tr>"+
							"		<tr>"+
							"			<th>그룹명</th>"+
							"			<td><input type='text' name='group_nm' class='form_text w80' style='width:98%;' value='' maxlength='2000' /></td>"+
							"		</tr>"+
							"		<tr>"+
							"			<th>그룹 설명</th>"+
							"			<td><textarea class='form_textarea' name='group_cont' style='height:50px;' cols='' rows=''  maxlength='2000' ></textarea></td>"+
							"		</tr>"+
							"		<tr>"+
							"			<td colspan='3' class='quest_box'>"+
							"				<table cellspacing='0' cellpadding='0' border='0' summary='게시판 뷰' class='tbl_ty2 quest_tr'>"+
							"					<colgroup>"+
							"						<col width='5%' />"+
							"						<col width='10%' />"+
							"						<col width='75%' />"+
							"						<col width='10%' />"+
							"					</colgroup>"+
							"					<tbody>"+
							"						<tr>"+
							"							<th rowspan='3' class='quest_key'>Q1-1</th>"+
							"							<th>질문유형</th>"+
							"							<td>"+
							"								<select name='quest_gubun' class='form_select quest_gubun' style='width:150px;'>"+
							"									<option value='S' selected='selected'>단일선택</option>"+
							"									<option value='M'>다중선택</option>"+
							"									<option value='A'>주관식</option>"+
							"								</select>"+
							"							</td>"+
							"							<td rowspan='3'>" +
							"								<input class='sky_blue_btn_s add_quest_btn hand' type='button' value='문항추가' />"+
							"								<input type='hidden' name='quest_seq' class='quest_seq' value='1' />"+
							"							</td>"+
							"						</tr>"+
							"						<tr>"+
							"							<th>질문내용</th>"+
							"							<td><textarea class='form_textarea' name='quest_title' style='height:50px;' cols='' rows=''  maxlength='2000' ></textarea></td>"+
							"						</tr>"+
							"						<tr class='catgy_tr'>"+
							"							<th>답변</th>"+
							"							<td>"+
							"								<div class='catgy_div'>"+
							"									<div class='catgy_span' style='padding:5px;'>"+
							"										<input type='text' name='catgy_cont' class='form_text w80 catgy_cont' style='width:80%;' value='' />"+
							"										기타여부 : <input type='checkbox' name='etc_yn_chk' class='etc_yn_chk' value='Y'>" +
							"										<input type='hidden' name='etc_yn' class='etc_yn' value='N'>" +							
							"										<input class='sapa_btn_s add_catgy_btn hand' type='button' value='항목추가' style='width:100px;' />"+
							"										<input type='hidden' name='catgy_seq' class='catgy_seq' value='1' />"+
							"									</div>"+
							"								</div>"+
							"							</td>"+
							"						</tr>"+
							"					</tbody>"+
							"				</table>"+
							"			</td>"+
							"		</tr>"+
							"	</tbody>"+
							"</table>";
				
			$('.group_box').append(group_obj);
			numbering();
			SettingSeq();
			
		});
		
		// 문항 추가
		$('.add_quest_btn').live('click', function () {

			var quest_obj = "" +
							"<table cellspacing='0' cellpadding='0' border='0' summary='게시판 뷰' class='tbl_ty2 quest_tr'>"+
							"	<colgroup>"+
							"		<col width='5%' />"+
							"		<col width='10%' />"+
							"		<col width='75%' />"+
							"		<col width='10%' />"+
							"	</colgroup>"+
							"	<tbody>"+
							"		<tr>"+
							"			<th rowspan='3' class='quest_key'>Q1-1</th>"+
							"			<th>질문유형</th>"+
							"			<td>"+
							"				<select name='quest_gubun' class='form_select quest_gubun' style='width:150px;'>"+
							"					<option value='S' selected='selected'>단일선택</option>"+
							"					<option value='M'>다중선택</option>"+
							"					<option value='A'>주관식</option>"+
							"				</select>"+
							"			</td>"+
							"			<td rowspan='3'>" +
							"				<input class='l_green_btn_s del_quest_btn hand' type='button' value='문항삭제' />"+
							"				<input type='hidden' name='quest_seq' class='quest_seq' value='1' />"+
							"			</td>"+
							"		</tr>"+
							"		<tr>"+
							"			<th>질문내용</th>"+
							"			<td><textarea class='form_textarea' name='quest_title' style='height:50px;' cols='' rows=''  maxlength='2000' ></textarea></td>"+
							"		</tr>"+
							"		<tr class='catgy_tr'>"+
							"			<th>답변</th>"+
							"			<td>"+
							"				<div class='catgy_div'>"+
							"					<div class='catgy_span' style='padding:5px;'>"+
							"						<input type='text' name='catgy_cont' class='form_text w80 catgy_cont' style='width:80%;' value='' />"+
							"						기타여부 : <input type='checkbox' name='etc_yn_chk' class='etc_yn_chk' value='Y'>" +
							"						<input type='hidden' name='etc_yn' class='etc_yn' value='N'>" +
							"						<input class='sapa_btn_s add_catgy_btn hand' type='button' value='항목추가' style='width:100px;' />"+
							"						<input type='hidden' name='catgy_seq' class='catgy_seq' value='1' />"+
							"					</div>"+
							"				</div>"+
							"			</td>"+
							"		</tr>"+
							"	</tbody>"+
							"</table>";

			$(this).parents(".group_tr").find('.quest_box').append(quest_obj);			
			numbering();
			SettingSeq();
			
		});		
		
		// 문항 추가		
		$('.add_catgy_btn').live('click', function () {

			var catgy_obj = "" +
							"<div class='catgy_span' style='padding:5px;'>"+
							"	<input type='text' name='catgy_cont' class='form_text w80 catgy_cont' style='width:80%;' value='' />"+
							"	기타여부 : <input type='checkbox' name='etc_yn_chk' class='etc_yn_chk' value='Y'>" +
							"	<input type='hidden' name='etc_yn' class='etc_yn' value='N'>" +							
							"	<input class='red_btn_s del_catgy_btn hand' type='button' value='항목삭제' style='width:100px;' />"+
							"	<input type='hidden' name='catgy_seq' class='catgy_seq' value='1' />"+
							"</div>";

			$(this).parents(".catgy_div").append(catgy_obj);			
			numbering();
			SettingSeq();
			
		});
		
		// 그룹 삭제	
		$('.del_group_btn').live('click', function () {

			$(this).parents(".group_tr").remove();			
			numbering();
			SettingSeq();
			
		});	
		
		// 문항 삭제	
		$('.del_quest_btn').live('click', function () {

			$(this).parents(".quest_tr").remove();			
			numbering();
			SettingSeq();
			
		});	
		
		// 항목 삭제	
		$('.del_catgy_btn').live('click', function () {

			$(this).parents(".catgy_span").remove();
			numbering();
			SettingSeq();
			
		});		
		
		// 질문 유형 선택		
		$(".quest_gubun").live('change', function () {
			
			if( $(this).val() == "A" || $(this).val() == "F" ) {
				$(this).parents(".quest_tr").find(".catgy_tr").hide();	
			}  else {
				$(this).parents(".quest_tr").find(".catgy_tr").show();	
			}
			
		});	
		
		// 기타여부 선택	
		$(".etc_yn_chk").live('click', function () {
			
			if( $(this).is(":checked") ) {
				
				$(this).parent(".catgy_span").find(".etc_yn").val("Y");
				$(this).parent(".catgy_span").find(".catgy_cont").val("기타");
				$(this).parent(".catgy_span").find(".catgy_cont").css("background-color","#d5d5d5");
				$(this).parent(".catgy_span").find(".catgy_cont").attr("readonly",true);
				
			} else {
				
				$(this).parent(".catgy_span").find(".etc_yn").val("N");
				$(this).parent(".catgy_span").find(".catgy_cont").val("");
				$(this).parent(".catgy_span").find(".catgy_cont").css("background-color","#fff");
				$(this).parent(".catgy_span").find(".catgy_cont").attr("readonly",false);				
				
			}
			
		});			

		function numbering() {

			$(".group_key").each(function (index, Element) {
				
				var idx = parseInt(index) + 1;
				$(this).html( idx );					
				$(this).parents(".group_tr").find(".quest_key").each(function (index, Element) {
					var ch_idx = parseInt(index) + 1;
					$(this).html( "Q" + idx + "-" + ch_idx );
				});
				
			});	

		}
		
		function SettingSeq() {
			
			// 그룹번호 리사이징
			$(".group_tr").each(function (index, Element) {
			
				// 그룹번호 세팅
				var group_idx = parseInt(index) + 1;
				$(this).find(".group_seq").val( group_idx );
				
				// 문항번호 리사이징
				$(this).find(".quest_tr").each(function (index, Element) {
					
					// 문항번호 세팅
					var quest_idx = parseInt(index) + 1;
					$(this).find(".quest_seq").val( group_idx + "," + quest_idx );
					
					// 항목번호 리사이징
					$(this).find(".catgy_span").each(function (index, Element) {
						
						// 항목번호 세팅
						var catgy_idx = parseInt(index) + 1;
						$(this).find(".catgy_seq").val( group_idx + "," + quest_idx + "," + catgy_idx );
						
					});						
					
				});					
				
			});
			
		}
	
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">	
	<input type="hidden" id="basic_seq" name="basic_seq" value="<c:out value="${rMap.BASIC_SEQ}"/>"/>
	<input type="hidden" id="page" name="page" value="<c:out value="${param.page}"/>"/>
	
		<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
			
			<div class="table_header">
				<h6 class="sub_tit_h6">설문조사 등록</h6>
			</div>

			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>분류<em class="point">&nbsp;</em></th>
							<td>
								<select id="gubun" name="gubun" class="form_select" style="width:200px;">
								<c:if test="${empty rMap.GUBUN}"><option value="">-- 선택하세요 --</option></c:if>
									<c:forEach items="${categoryList}" var="categoryList" varStatus="status">
										<c:set var="selected" value=""/>
								        <c:if test="${categoryList.CODE == rMap.GUBUN}">
								            <c:set var="selected" value="selected"/>
								        </c:if>
										<option value="<c:out value="${categoryList.CODE}"/>" ${selected}><c:out value="${categoryList.CODE_NM}"/></option>
									</c:forEach>
								</select>
							</td>
							<th>작성자<em class="point">&nbsp;</em></th>
							<td>									
								<input type="text" id="writer" name="writer" class="input_text_n w80" style="width:calc(30%);" readonly="" value="<c:out value="${ WRITER }"/>" maxlength="15" />
							</td>
						</tr>
						<tr>
							<th>제목<em class="point">&nbsp;</em></th>
							<td colspan="3">
								<input type="text" id="title" name="title" class="form_text" style="width:calc(80%);" value="<c:out value="${rMap.TITLE}"/>" maxlength="100"/>
							</td>
						</tr>
						<tr>
							<th>설문기간<em class="point">&nbsp;</em></th>
							<td colspan="3">
								<em class="input_text_em">
									<input type="text" id="s_date_start" name="s_date_start" placeholder="시작일 입력" class="form_text" value="<c:out value="${rMap.STR_DD}"/>" onclick="calendar(event,'s_date_start','yyyy-mm-dd')" style="cursor:pointer;width:100px;">
									<img src="/common/admmgr/images/sub_common/ico_cal1.png" alt="등록시작일자" onclick="javascript:$('#s_date_start').trigger('click');">
								</em>
								 ~
								<em class="input_text_em">
									<input type="text" id="s_date_end" name="s_date_end" placeholder="종료일 입력" class="form_text" value="<c:out value="${rMap.END_DD}"/>" onclick="calendar(event,'s_date_end','yyyy-mm-dd')" style="cursor:pointer;width:100px;">
									<img src="/common/admmgr/images/sub_common/ico_cal1.png" alt="등록시작일자" onclick="javascript:$('#s_date_end').trigger('click');">
								</em>
							</td>
						</tr>														
						<tr>
							<th>내용 <em class="point">&nbsp;</em></th>
							<td class="td_con" valign="top" colspan="4">
									<textarea class="form_textarea" id="conts" name="conts" cols="" rows="" style="width:calc(100% - 20px);"><c:out value="${rMap.CONTENTS}" escapeXml="false"/></textarea>
							</td>
						</tr>
						<tr>
							<th>공개여부<em class="point">&nbsp;</em></th>
							<td>
								<div class="agree_check_box">
									<input type="radio" id="open_ynY" name="open_yn" value="Y" <c:if test="${rMap.OPEN_YN eq 'Y' || empty rMap.OPEN_YN}">checked="checked"</c:if>/>
									<label for="open_ynY"><span>예</span></label>
									&nbsp;&nbsp;&nbsp;
									<input type="radio" id="open_ynN" name="open_yn" value="N" <c:if test="${rMap.OPEN_YN eq 'N'}">checked="checked"</c:if>/>
									<label for="open_ynN"><span>아니오</span></label>
								</div>
							</td>
							<th>개인정보수집여부<em class="point">&nbsp;</em></th>
							<td>
								<div class="agree_check_box">
									<input type="radio" id="agree_ynY" name="agree_yn" value="Y" <c:if test="${rMap.AGREE_YN eq 'Y' || empty rMap.AGREE_YN}">checked="checked"</c:if>/>
									<label for="agree_ynY"><span>예</span></label>
									&nbsp;&nbsp;&nbsp;
									<input type="radio" id="agree_ynN" name="agree_yn" value="N" <c:if test="${rMap.AGREE_YN eq 'N'}">checked="checked"</c:if>/>
									<label for="agree_ynN"><span>아니오</span></label>
								</div>
							</td>								
						</tr>																					
					</tbody>
				</table>
				
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="100%" />
					</colgroup>
					<tbody>
						<tr>
							<td>
								<div style="border-top: 2px solid black; border-bottom: 1px solid gray; height: 50px; text-align: center; background: #fafafa;">
								<span style="line-height: 50px; font-size: 12px; font-weight: bold;">설문조사 정보</span>
								</div>
							</td>
						<tr>
							<td>
								<div class="group_box">
									<c:forEach items="${GroupList}" var="GroupList" varStatus="status">
										<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2 group_tr">
											<colgroup>
												<col width="15%" />
												<col width="75%" />
												<col width="10%" />
											</colgroup>
											<tbody>												
												<tr>
													<th>그룹번호</th>
													<td class="group_key"><c:out value="${GroupList.GROUP_SEQ}"/></td>
													<td rowspan="3">
														<c:choose>
															<c:when test="${ status.index eq '0' }">
																<input class="black_btn_s add_group_btn hand" type="button" value="그룹추가" />																	
															</c:when>
															<c:otherwise>
																<input class="gray_btn_s del_group_btn hand" type="button" value="그룹삭제" />
															</c:otherwise>
														</c:choose>
														<input type="hidden" name="group_seq" class="group_seq" value="<c:out value="${GroupList.GROUP_SEQ}"/>" />
													</td>
												</tr>
												<tr>
													<th>그룹명</th>
													<td><input type="text" name="group_nm" class="form_text w80" style="width:98%;" value="<c:out value="${GroupList.GROUP_NM}" escapeXml="false"/>"  maxlength="100" /></td>
												</tr>
												<tr>
													<th>그룹 설명</th>
													<td><textarea class="form_textarea" name="group_cont" style="height:50px;" cols="" rows=""  maxlength="2000"><c:out value="${GroupList.GROUP_CONT}" escapeXml="false" /></textarea></td>
												</tr>
												<tr>
													<td colspan="3" class="quest_box">
														<c:forEach var="QuestList" items="${str:makeSurveyQuestList(GroupList.BASIC_SEQ,GroupList.GROUP_SEQ)}" varStatus="status">
															<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2 quest_tr">
																<colgroup>
																	<col width="5%" />
																	<col width="10%" />
																	<col width="75%" />
																	<col width="10%" />
																</colgroup>
																<tbody>
																	<tr>
																		<th rowspan="3" class="quest_key">Q<c:out value="${QuestList.GROUP_SEQ}" />-<c:out value="${QuestList.QUEST_SEQ}" /></th>
																		<th>질문유형</th>
																		<td>
																			<select name="quest_gubun" class="form_select quest_gubun" style="width:150px;">
																				<option value="S" ${ QuestList.QUEST_GUBUN eq "S" ? "selected='selected'" : "" }>단일선택</option>
																				<option value="M" ${ QuestList.QUEST_GUBUN eq "M" ? "selected='selected'" : "" }>다중선택</option>																				
																				<option value="A" ${ QuestList.QUEST_GUBUN eq "A" ? "selected='selected'" : "" }>주관식</option>
																			</select>
																		</td>
																		<td rowspan="3">
																			<c:choose>
																				<c:when test="${ status.index eq '0' }">
																					<input class="sky_blue_btn_s add_quest_btn hand" type="button" value="문항추가" />																	
																				</c:when>
																				<c:otherwise>
																					<input class="l_green_btn_s del_quest_btn hand" type="button" value="문항삭제" />
																				</c:otherwise>
																			</c:choose>
																			<input type="hidden" name="quest_seq" class="quest_seq" value="<c:out value="${QuestList.GROUP_SEQ}"/>,<c:out value="${QuestList.QUEST_SEQ}"/>" />
																		</td>
																	</tr>
																	<tr>
																		<th>질문내용</th>
																		<td><textarea class="form_textarea" name="quest_title" style="height:50px" cols="" rows=""  maxlength="2000"><c:out value="${QuestList.QUEST_TITLE}" escapeXml="false" /></textarea></td>
																	</tr>
																	<tr class="catgy_tr" style="display:${ QuestList.QUEST_GUBUN eq 'A' ? 'none' : QuestList.QUEST_GUBUN eq 'F' ? 'none' : 'contents' };">
																		<th>답변</th>
																		<td>
																			<div class="catgy_div">
																				<c:forEach var="CatgyList" items="${str:makeSurveyCatgyList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ)}" varStatus="status">																							
																					<div class="catgy_span"  style="padding:5px;">
																						<input type="text" name="catgy_cont" class="form_text w80 catgy_cont" style="width:80%; ${ CatgyList.ETC_YN eq 'Y' ? 'background-color:#d5d5d5;' : '' }" value="<c:out value="${CatgyList.CATGY_CONT}" escapeXml="false"/>" />
																						기타여부 : <input type="checkbox" name="etc_yn_chk" class="etc_yn_chk" value="Y" ${ CatgyList.ETC_YN eq 'Y' ? 'checked="checked"' : '' } >
																						<input type="hidden" name="etc_yn" class="etc_yn" value="${ CatgyList.ETC_YN }" >
																						<c:choose>
																							<c:when test="${ status.index eq '0' }">
																								<input class="sapa_btn_s add_catgy_btn hand" type="button" value="항목추가" style="width:100px;" />
																							</c:when>
																							<c:otherwise>
																								<input class="red_btn_s del_catgy_btn hand" type="button" value="항목삭제" />
																							</c:otherwise>
																						</c:choose>
																						<input type="hidden" name="catgy_seq" class="catgy_seq" value="<c:out value="${CatgyList.GROUP_SEQ}"/>,<c:out value="${CatgyList.QUEST_SEQ}"/>,<c:out value="${CatgyList.CATGY_SEQ}"/>" />
																					</div>
																				</c:forEach>	
																			</div>
																		</td>
																	</tr>
																</tbody>
															</table>
														</c:forEach>																			
													</td>
												</tr>
											</tbody>
										</table>
									</c:forEach>
									<c:if test="${fn:length( GroupList ) <= 0}">
										<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2 group_tr">
											<colgroup>
												<col width="15%" />
												<col width="75%" />
												<col width="10%" />
											</colgroup>
											<tbody>												
												<tr>
													<th>그룹번호</th>
													<td class="group_key">1</td>
													<td rowspan="3">
														<input class="black_btn_s add_group_btn hand" type="button" value="그룹추가" />
														<input type="hidden" name="group_seq" class="group_seq" value="1" />
													</td>
												</tr>
												<tr>
													<th>그룹명</th>
													<td><input type="text" name="group_nm" class="form_text w80" style="width:98%;" value=""  maxlength="100" /></td>
												</tr>
												<tr>
													<th>그룹 설명</th>
													<td><textarea class="form_textarea" name="group_cont" style="height:50px;" cols="" rows=""  maxlength="2000" ></textarea></td>
												</tr>
												<tr>
													<td colspan="3" class="quest_box">
														<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2 quest_tr">
															<colgroup>
																<col width="5%" />
																<col width="10%" />
																<col width="75%" />
																<col width="10%" />
															</colgroup>
															<tbody>
																<tr>
																	<th rowspan="3" class="quest_key">Q1-1</th>
																	<th>질문유형</th>
																	<td>
																		<select name="quest_gubun" class="form_select quest_gubun" style="width:150px;">
																			<option value="S" selected='selected'>단일선택</option>
																			<option value="M">다중선택</option>																				
																			<option value="A">주관식</option>
																		</select>
																	</td>
																	<td rowspan="3">
																		<input class="sky_blue_btn_s add_quest_btn hand" type="button" value="문항추가" />
																		<input type="hidden" name="quest_seq" class="quest_seq" value="1,1" />
																	</td>																		
																</tr>
																<tr>
																	<th>질문내용</th>
																	<td><textarea class="form_textarea" name="quest_title" style="height:50px" cols="" rows=""  maxlength="2000" ></textarea></td>
																</tr>																														
																<tr class="catgy_tr">
																	<th>답변</th>
																	<td>
																		<div class="catgy_div">
																			<div class="catgy_span" style="padding:5px;">
																				<input type="text" name="catgy_cont" class="form_text w80 catgy_cont" style="width:80%;" value="" />
																				기타여부 : <input type="checkbox" name="etc_yn_chk" class="etc_yn_chk" value="Y">
																				<input type="hidden" name="etc_yn" class="etc_yn" value="N" >																					
																				<input class="sapa_btn_s add_catgy_btn hand" type="button" value="항목추가" style="width:100px;" />
																				<input type="hidden" name="catgy_seq" class="catgy_seq" value="1,1,1" />
																			</div>
																		</div>																					
																	</td>
																</tr>
															</tbody>
														</table>																			
													</td>
												</tr>
											</tbody>
										</table>										
									</c:if>
								</div>									
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<c:choose>
						<c:when test="${ rMap.BASIC_SEQ eq null }">
							<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
						</c:when>
						<c:otherwise>
							<a class="btn" href="javascript:void(0);" onclick="javascript:fn_Detail();"><span>취소</span></a>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
				

			</div>
			<!-- // sub_contents_area -->

		</div>
		<!-- // sub_contents_wrap -->

	</form>
</body>