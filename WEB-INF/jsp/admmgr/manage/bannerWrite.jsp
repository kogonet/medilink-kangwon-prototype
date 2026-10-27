<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 배너 등록
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
		.btn_add{width:120px;background: #00aeff url(/common/admmgr/images/ico/ico_pluse.png)no-repeat;background-position: calc(100% - 13px) center;font-size: 13px;font-weight: 400;text-align: left;color: #fff !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;border: 1px solid #00aeff;box-sizing: border-box;height: 30px;}
		.btn_remove{width:120px;background: #ffffff url(/common/admmgr/images/ico/ico_minus.png)no-repeat;background-position: calc(100% - 13px) center;border: 1px solid #d2d2d2;font-size: 13px;font-weight: 400;text-align: left;color: #999999 !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;box-sizing: border-box;height: 30px;}
		.check_box input[type="checkbox"]{display: none;}
		.check_box input[type="checkbox"] + label{display: inline-block;cursor: pointer;vertical-align: middle;font-size: 14px;font-weight: 400;line-height: 17px;color: #333;font-family: 'Malgun Gothic',sans-serif;margin-right: 25px;}
		.check_box input[type="checkbox"] + label span{display: inline-block;height: 20px;background: url(/common/admmgr/images/ico/ico_check_off.png) no-repeat left 50%;vertical-align: middle;vertical-align: middle;transition: all ease-out 0.2s;padding-left: 27px;}
		.check_box input[type="checkbox"]:checked + label span{background: url(/common/admmgr/images/ico/ico_check_on.png) no-repeat left 50%;}
	</style>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/plug-in/cheditor/cheditor.js'/>"></script>
	<link rel="stylesheet" type="text/css"	href="/plug-in/coaUpload/CoaUpload.css" />
	<script type="text/javascript" src="/plug-in/coaUpload/CoaConfig.js"></script>
	<script type="text/javascript" src="/plug-in/coaUpload/CoaUpload.min.js"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			//[Init]cheditor
			//var texteditor;
			//fn_Cheditor();
			//[Init]File Component
			// 업로드창이 활성화 되었을때
			/* if ($("#upload_area").length > 0) {
				// Coa_InitCustom(area_id, folder_nm, file_type, callback_fn, colum_nm)
				Coa_InitCustom("upload_area", "banner", "bannerFile", fn_RegistProc, "fileNo");
			} */
			
			/** 파일 체크 **/
			var permit_ext = [ "zip" , "pdf" , "jpg" , "png" , "bmp" , "hwp" , "doc" , "docx" , "xls" , "xlsx" , "ppt" , "pptx" , "hwpx"];
			$('#fileNo1').change(function() {
				
				var fileNm = $('#fileNo1').val().split('\\').pop().toLowerCase();
				var ext = fileNm.split('.').pop();
				var fileSize = this.files[0].size;
				
				//1. 확장자 체크
				if($.inArray(ext, permit_ext) == -1){
					$('#fileNo1').val('');
					alert(ext + "확장자는 업로드 불가능합니다.");
					return false;
				}
				
				//2. 파일용량 제한
				const maxSize = 1024*1024*5;	// 5MB
				if(fileSize > maxSize){
					$('#fileNo1').val('');
					alert("파일크기는" + maxSize/1024/1024 +"MB 까지 가능합니다.");
				}
				
			});
			
			// 게시일 설정 여부 라디오 버튼 변경 시 이벤트 처리를 수행합니다.
		    $('input[name="formDateYn"]').change(function() {
		    	if ($('input[name="formDateYn"]:checked').val() === 'N') {
		            $('.form_date_row').hide(); // 신청서폼 숨기기
		        } else {
		            $('.form_date_row').show(); // 신청서폼 보이기
		        }
		    });
			
			var isShowStartDdEmpty = "${empty rMap.SHOW_START_DD}" === "true";
		    var showStartDd = "${not empty rMap.SHOW_START_DD ? rMap.SHOW_START_DD : ''}";
		    var showEndDd = "${not empty rMap.SHOW_END_DD ? rMap.SHOW_END_DD : ''}";
			
			// 초기 숨기기/보이기 처리
			if( isShowStartDdEmpty ) {
				$('.form_date_row').hide();
			}
			
			// 숨김처리시 date값 날리기
			if( $('input[name="formDateYn"]:checked').val() === 'N' ) {
				$("#showStartDd").val('');
				$("#showEndDd").val('');
			} else {
				if (!isShowStartDdEmpty) {
		            $("#showStartDd").val(showStartDd);
		            $("#showEndDd").val(showEndDd);
		        }
			}
		    
		});
		/*
		function fn_Cheditor(){
			texteditor = new cheditor();              	// 에디터 개체를 생성합니다.
			texteditor.config.editorHeight = '300px';   // 에디터 세로폭입니다.
			texteditor.config.editorWidth  = '100%';    // 에디터 가로폭입니다.
			texteditor.config.imgSetAttrWidth = -1;		// -1 = (width="100%"; height="auto"), 0 = 설정 안함, 1 = 기본값
			texteditor.inputForm = 'conts';             // textarea의 id입니다. 주의: name 속성 이름이 아닙니다.
			texteditor.run();                           // 에디터를 실행합니다.
		}
		*/
		<%-- 목록 --%>
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerList.do'/>");
			$("#frm").submit();
		}
		<%-- 등록 --%>
		function fn_Regist(){
			//[1]Validate
			if( $("#siteCd").val() == "" ){
				alert("병원을 선택해 주세요.");
				$("#siteCd").focus();
				return false;
			}
			if( $("#bannTp").val() == "" ){
				alert("배너타입을 선택해 주세요.");
				$("#bannTp").focus();
				return false;
			}

			// 푸터배너 제외 체크
			if( $("#bannTp").val() != "FOOTER" ){
				//var textBody = texteditor.outputBodyHTML();
				if( $("#conts").val() == "" ){
					alert("내용을 입력해 주세요.");
					$("#conts").focus();
					return false;
				}
			}

			if( $("#bann_title").val() == "" ){
				alert("배너명을 입력해 주세요.");
				$("#bann_title").focus();
				return false;
			}
			if( $('input[name="formDateYn"]:checked').val() === 'Y' ) {
				if( $("#showStartDd").val() == "" ){
					alert("게시시작일자를 입력해 주세요.");
					$("#showStartDd").focus();
					return false;
				}
				if( $("#showEndDd").val() == "" ){
					alert("게시종료일자를 입력해 주세요.");
					$("#showEndDd").focus();
					return false;
				}
			} else {
				$("#showStartDd").val('');
				$("#showEndDd").val('');
			}
			//[2]HtmlEditor Value 재정의
			/*
			var textBody = texteditor.outputBodyHTML();
			if( textBody.length > 0 ){
				$("#conts").val(textBody);
			}
			*/
			//[3]파일등록여부 확인
			/* if ( $(".coa_file").length > 0 ) {
				Coa.Upload();
			} else {
				fn_RegistProc();
			} */
			
			fn_RegistProc();
			
		}
		function fn_RegistProc(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerWriteProc.do'/>").submit();
		}
		<%-- 파일 다운로드 --%>
		function fn_FileDown(fileNo,fileSeq){
			$("#fileNo").val(fileNo);
			$("#fileSeq").val(fileSeq);
			$("#frm").attr("action","<c:url value='/com/bannerFileDownload.do'/>");
			$("#frm").attr("target","self");
			$("#frm").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST" enctype="multipart/form-data">
	<input type="hidden" id="bannNo" name="bannNo" value="${rMap.BANN_NO}"/>
	<input type="hidden" id="columNm" name="columNm" value=""/>
	<input type="hidden" id="chk" name="chk" value="${rMap.SITE_CD}:${rMap.BANN_NO}"/>
	<input type="hidden" id="searchfield" name="searchfield" value="<c:out value="${param.searchfield}"/>"/>
	<input type="hidden" id="searchword" name="searchword" value="<c:out value="${param.searchword}"/>"/>
	<input type="hidden" id="s_site_cd" name="s_site_cd" value="<c:out value="${param.s_site_cd}"/>"/>
	<input type="hidden" id="s_date_start" name="s_date_start" value="<c:out value="${param.s_date_start}"/>"/>
	<input type="hidden" id="s_date_end" name="s_date_end" value="<c:out value="${param.s_date_end}"/>"/>
	<input type="hidden" id="page" name="page" value="<c:out value="${param.page}"/>"/>
	<input type="hidden" id="s_bann_tp" name="s_bann_tp" value="<c:out value="${param.s_bann_tp}"/>"/>
	<input type="hidden" id="fileNo" name="fileNo" value="<c:out value="${rMap.FILE_NO}"/>"/>

	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4 fix">
				<em>배너관리 ${(not empty rMap.BANN_NO)?'수정':'등록'}</em>
			</h4>

			<div class="table_header">
				<span><b class="c_red">*</b> 는 필수 입력사항 입니다.</span>
			</div>

			<div id="profInfo" class="n_table_sty01 n_view01 mt10">
				<table class="table_renew_type1" cellspacing="0" cellpadding="0" border="0" style="">
					<colgroup>
						<col width="15%"/>
						<col width="35%"/>
						<col width="15%"/>
						<col width="35%"/>
					</colgroup>
					<tbody>
						<tr>
							<th>사이트 <b class="c_red">*</b></th>
							<td>
								<select id="siteCd" name="siteCd" class="form_select wd320" title="사이트 선택">
									<option value="">전체</option>
									<c:set var="siteList" value="${str:getSiteList()}"/>
									<c:forEach items="${siteList}" var="siteList" varStatus="status">
										<option value="<c:out value="${siteList.SITE_CD}"/>" ${(siteList.SITE_CD eq rMap.SITE_CD)?"selected='selected'":""}><c:out value="${siteList.SITE_NM}"/></option>
									</c:forEach>
								</select>
							</td>
							<th>게시여부</th>
							<td>
								<label><input type="radio" name="openYn" value="Y" <c:if test="${rMap.OPEN_YN eq 'Y' || empty rMap.OPEN_YN}">checked="checked"</c:if>/> 게시</label>
								<label><input type="radio" name="openYn" value="N" <c:if test="${rMap.OPEN_YN eq 'N'}">checked="checked"</c:if>/> 숨김</label>
							</td>
						</tr>
						<tr>
							<th>배너타입 <b class="c_red">*</b></th>
							<td>
								<select class="form_select wd320" title="배너타입 선택" id="bannTp" name="bannTp">
									<option value="CENTER" ${(rMap.BANN_TP eq 'CENTER')?"selected='selected'":""}>CENTER</option>
									<option value="RIGHT"  ${(rMap.BANN_TP eq 'RIGHT' )?"selected='selected'":""}>RIGHT</option>
									<option value="FOOTER" ${(rMap.BANN_TP eq 'FOOTER')?"selected='selected'":""}>FOOTER</option>
									<option value="POPUP"  ${(rMap.BANN_TP eq 'POPUP' )?"selected='selected'":""}>POPUP</option>
								</select>
							</td>
							<th>새창여부</th>
							<td>
								<label><input type="radio" name="popupYn" value="N" <c:if test="${rMap.POPUP_YN eq 'N' || empty rMap.POPUP_YN}">checked="checked"</c:if>/> 일반</label>
								<label><input type="radio" name="popupYn" value="Y" <c:if test="${rMap.POPUP_YN eq 'Y'}">checked="checked"</c:if>/> 새창</label>
							</td>
						</tr>
						<tr>
							<th>배너명 <b class="c_red">*</b></th>
							<td colspan="3"><input type="text" id="bann_title" name="bann_title" class="form_text w100" value="<c:out value='${str:getReverseXSS(rMap.TITLE)}'/>" placeholder="배너명을 입력해 주세요." maxlength="100"/></td>
						</tr>
						<tr>
							<th>내용 <b class="c_red">*</b></th>
							<td colspan="3">
								<textarea id="conts" name="conts" class="form_textarea" maxlength="1000"><c:out value="${str:getReverseXSS(rMap.CONTS)}" escapeXml="false"/></textarea>
							</td>
						</tr>
						<tr>
							<th>링크 URL <b class="c_red">*</b></th>
							<td colspan="3">
								<input type="text" id="linkUrl" name="linkUrl" class="form_text w100" value="<c:out value='${str:getReverseXSS(rMap.LINK_URL)}'/>" placeholder="링크URL을 입력해 주세요." maxlength="200"/>
							</td>
						</tr>
						<tr>
							<th>게시일 설정 여부 <b class="c_red">*</b></th>
							<td colspan="3">
								<input type="radio" id="formDateYn1" name="formDateYn" value="Y" ${not empty rMap.SHOW_START_DD ? 'checked' : '' } >
								<label for="entryYn1"><span>게시기간 설정</span></label>
								<input type="radio" id="formDateYn2" name="formDateYn" value="N" ${empty rMap.SHOW_START_DD ? 'checked' : '' } >
								<label for="entryYn2"><span>무기한</span></label>
							</td>
						</tr>
						<tr class="form_date_row">
							<th>게시시작일자 <b class="c_red">*</b></th>
							<td>
								<div class="form_date">
									<input type="text" id="showStartDd" name="showStartDd" class="form_text wd140"
										placeholder="시작일 입력" style="cursor:pointer;" onclick="calendar(event,'showStartDd','yyyy-mm-dd')"
										value="${(not empty rMap.SHOW_START_DD)?rMap.SHOW_START_DD:nowDate}"
									/>
						
									<input type="button" class="btn_form_date" alt="등록시작일자" onclick="javascript:$('#showStartDd').trigger('click');">
								</div>
							</td>
							<th>게시종료일자<b class="c_red">*</b></th>
							<td>
								<div class="form_date">
									<input type="text" id="showEndDd" name="showEndDd" class="form_text wd140"
										placeholder="종료일 입력" style="cursor:pointer;" onclick="calendar(event,'showEndDd','yyyy-mm-dd')"
										value="${(not empty rMap.SHOW_END_DD)?rMap.SHOW_END_DD:after3Month}"
									/>
				
									<input type="button" class="btn_form_date" alt="등록시작일자" onclick="javascript:$('#showEndDd').trigger('click');">
								</div>
							</td>
						</tr>
						<tr>
							<th>배너 이미지 다운로드</th>
							<td colspan="3">
								<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
									<colgroup>
										<col width="80%">
										<col width="20%">
									</colgroup>
									<tbody>
										<c:set var="fileList" value="${str:makeFileList(rMap.FILE_NO)}"/>
										<c:choose>
											<c:when test="${fn:length(fileList) eq 0}">
												<tr>
													<th class="center" colspan="2">등록된 파일이 없습니다.</th>
												</tr>
											</c:when>
											<c:otherwise>
												<c:forEach items="${fileList}" var="fileList" varStatus="status">
													<tr>
														<td><strong><c:out value="${fileList.ORIGIN_NM}"/></strong></th>
														<td>
															<input type="button" class="btn primary sm" value="다운로드" onclick="javascript:fileDownload('<c:out value="${fileList.FILE_NO}"/>','<c:out value="${fileList.FILE_SEQ}"/>'); return false;" />
															<input type="button" class="btn secodary sm " value="삭제" onclick="javascript:fileDeleteLogi(this, '<c:out value="${fileList.FILE_NO}"/>','<c:out value="${fileList.FILE_SEQ}"/>'); return false;" />
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
							<th>배너 이미지 등록</th>
							<!-- <td class="td_con" valign="top" colspan="3">
								<div class="upload_form" id="upload_area"></div>
							</td> -->
							<td colspan="3">
								<div><input type="file" id="fileNo1" name="fileNo1" accept=".zip,.pdf,.jpg,.png,.bmp,.hwp,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.hwpx"/></div>
								<em class="c_sky">※ 파일은 [ zip, pdf, jpg, png, bmp, hwp, doc, docx, xls, xlsx, ppt, pptx, hwpx ]만 가능 합니다.</em>
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<%-- 버튼 영역 --%>
			<div id="btnArea" class="page_btn_wrap jc_between mt20">
				<span class="lft">
					<c:if test="${not empty rMap.BANN_NO}">
						<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
					</c:if>
				</span>
				<span class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</span>
			</div>

			
		</div>
		<!--// sub_contents_area-->

	</div>
	<!-- // sub_contents_wrap -->
</form>
</body>