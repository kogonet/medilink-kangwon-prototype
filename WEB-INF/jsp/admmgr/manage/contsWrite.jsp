<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 컨텐츠 등록
 **************************************************/
%>
<head>
	<link rel="stylesheet" href="<c:url value='/common/admmgr/css/bootstrap.css'/>">
	<script src="<c:url value='/common/admmgr/js/summernote/dist/lib/jquery-3.2.1.js'/>"></script>
	<script src="<c:url value='/common/admmgr/js/summernote/dist/lib/bootstrap-3.3.5.js'/>"></script>
	<%--
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/js/summernote/dist/summernote.css'/>">
	<script  src="<c:url value='/common/admmgr/js/summernote/dist/summernote.min.js'/>"></script>
	--%>
	<script type="text/javascript">
		$(document).ready(function(){
			//$("#conts").summernote({height:400});
		});
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/contsList.do'/>");
			$("#frm").submit();
		}
		function fn_Regist(){
			if( $("#siteCd option:selected").val() == "" ){
				alert("사이트를 선택해 주세요.");
				$("#siteCd").focus();
				return false;
			}
			if( $("#title").val() == "" ){
				alert("제목을 입력해 주세요.");
				$("#title").focus();
				return false;
			}
			if( $("#conts").val() == "" ){
				alert("내용을 입력해 주세요.");
				$("#conts").focus();
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/contsWriteProc.do'/>");
			$("#frm").submit();
		}
		function fn_PreView(){
			console.log(window.screen.width);
			var array = {"siteCd":$("#siteCd").val(),"contsNo":$("#contsNo").val(),"conts":$("#conts").val()};
			G_PostPopupOpen("PreViewPop","<c:url value='/admmgr/manage/contsViewPop.do'/>",window.screen.width,window.screen.height,array);
		}
		/*
		//파일 다운로드
		function fn_FileDown(fileSeq){
			$("#fileSeq").val(fileSeq);
			$("#frm").attr("action","<c:url value='/com/qnaFileDownload.do'/>");
			$("#frm").attr("target","self");
			$("#frm").submit();
		}
		function fn_FileDelete(fileSeq){
			if( confirm("파일을 삭제하시겠습니까?") ){
				var objDiv = $("#divFile"+fileSeq);
				//$("#fileSeq").val(fileSeq);
				$.ajax({
					url         : "<c:url value='/com/qnaFileDeleteProc.do'/>",
					type        : "POST",
					//contentType : "text/plain; charset=UTF-8",
					data        : {
						"qnaNo" : $("#qnaNo").val(),
						"fileNo"  : $("#fileNo").val(),
						"fileSeq" : fileSeq
					},
					success     : function(data){
						console.log(data);
						var rData = $.parseJSON(data);
						if( rData.result == "SUCCESS" ){
							objDiv.remove();
						}else{
							alert("첨부파일 삭제 중 오류가 발생하였습니다.");
						}
					}
				});
			}
		}
		*/
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST" >
		<input type="hidden" id="contsNo" name="contsNo" value="<c:out value="${rMap.CONTS_NO}"/>"/>
		<div class="sub_contents_form_type1">
			<div>
				<h4 class="sub_tit_h4 fix"><em>컨텐츠 ${(not empty rMap.CONTS_NO)?'수정':'등록'}</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span></h4>
				<div style="padding:15px; margin-bottom:30px;">
					<table class="table_renew_type1" cellspacing="0" cellpadding="0" border="0" style="">
						<colgroup>
							<col width="15%"/>
							<col width="35%"/>
							<col width="15%"/>
							<col width="35%"/>
						</colgroup>
						<tbody>
							<tr>
								<th>사이트 <em class="point">&nbsp;</em></th>
								<td>
									<c:choose>
										<c:when test="${not empty rMap.CONTS_NO}">
											<input type="hidden" id="siteCd" name="siteCd" value="<c:out value="${rMap.SITE_CD}"/>"/>
											<c:out value="${rMap.SITE_NM}"/>
										</c:when>
										<c:otherwise>
											<select id="siteCd" name="siteCd" class="select_type1" title="사이트 선택">
												<option value="">선택</option>
												<c:forEach items="${siteList}" var="siteList" varStatus="status">
													<option value="<c:out value="${siteList.SITE_CD}"/>" ${(rMap.SITE_CD eq siteList.SITE_CD)?"selected='selected'":""}><c:out value="${siteList.SITE_NM}"/></option>
												</c:forEach>
											</select>
										</c:otherwise>
									</c:choose>

								</td>
								<th>게시여부 <em class="point">&nbsp;</em></th>
								<td>
									<input type="radio" name="openYn" value="Y" <c:if test="${rMap.OPEN_YN eq 'Y' || empty rMap.OPEN_YN}">checked="checked"</c:if>/> 게시
									<input type="radio" name="openYn" value="N" <c:if test="${rMap.OPEN_YN eq 'N'}">checked="checked"</c:if>/> 비게시
								</td>
							</tr>
							<tr>
								<th>컨텐츠명 <em class="point">&nbsp;</em></th>
								<td colspan="3">
									<input type="text" id="title" name="title" class="input_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.TITLE}"/>"/>
								</td>
							</tr>
							<tr>
								<th>내용 <em class="point">&nbsp;</em></th>
								<td class="td_con" valign="top" colspan="3">
									<textarea id="conts" name="conts" cols="" rows=""><c:out value="${rMap.CONTS}" escapeXml="false"/></textarea>
								</td>
							</tr>
							<tr>
								<th>URL 1</th>
								<td><input type="text" id="url1" name="url1" class="input_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.URL_1}"/>"/></td>
								<th>URL 2</th>
								<td><input type="text" id="url2" name="url2" class="input_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.URL_2}"/>"/></td>
							</tr>
							<%--
							<tr>
								<th>첨부파일 1</th>
								<td><input type="text" id="fileNo1" name="fileNo1" class="input_text" style="width:calc(100%-20px);" value="<c:out value="${rMap.FILE_NO_1}"/>"/></td>
								<th>첨부파일 2</th>
								<td><input type="text" id="fileNo2" name="fileNo2" class="input_text" style="width:calc(100%-20px);" value="<c:out value="${rMap.FILE_NO_2}"/>"/></td>
							</tr>
							--%>
							<c:if test="${not empty rMap.CONTS_NO}">
								<tr>
									<th>최종수정자</th>
									<td><c:out value="${rMap.MDF_ID}"/></td>
									<th>최종수정일시</th>
									<td><c:out value="${rMap.MDF_DT}"/></td>
								</tr>
								<tr>
									<th>매핑 메뉴</th>
									<td colspan="3">
										<c:forEach items="${mapMenuList}" var="mapMenuList" varStatus="status">
											<p><c:out value="${mapMenuList.MENU_NM}"/></p>
										</c:forEach>
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>
					<p class="btn_section fix">
						<span class="lft_btn_section">
							<em>※ 내용에 입력된 {URL1}은 URL1에 입력된 URL로 변환됩니다.(URL2도 동일)</em>
						</span>
						<span class="rit_btn_section">
							<a class="btn1_ty3" href="javascript:void(0);" onclick="javascript:fn_PreView();"><em>미리보기</em></a>
							<a class="btn_red" href="javascript:void(0);" onclick="javascript:fn_Regist();"><em>저장</em></a>
							<a class="btn_gray" href="javascript:void(0);" onclick="javascript:fn_List();"><em>목록</em></a>
						</span>
					</p>
				</div>
			</div>
		</div>
	</form>
</body>