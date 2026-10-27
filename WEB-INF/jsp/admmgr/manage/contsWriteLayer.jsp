<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 컨텐츠 등록
 **************************************************/
%>
<head>
	<link rel="stylesheet" href="<c:url value='/common/admmgr/css/bootstrap.css'/>">
	<script src="<c:url value='/common/admmgr/js/summernote/dist/lib/jquery-3.2.1.js'/>"></script>
	<script src="<c:url value='/common/admmgr/js/summernote/dist/lib/bootstrap-3.3.5.js'/>"></script>
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/js/summernote/dist/summernote.css'/>">
	<script  src="<c:url value='/common/admmgr/js/summernote/dist/summernote.min.js'/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			//레이어 상단 타이틀 변경
			$("h3.pop_tit_h3").text("컨텐츠 관리");
			//$("#conts").summernote({height:300});
		});
		//등록
		function fn_Regist(){
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
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/contsWriteProcAjax.do'/>",
				data : {
					"siteCd"   : $("#siteCd").val(),
					"menuCd"   : $("#menuCd").val(),
					"title"    : $("#title").val(),
					"conts"    : $("#conts").val(),
					"url1"     : $("#url1").val(),
					"url2"     : $("#url2").val(),
					"url3"     : $("#url3").val(),
					"contsVer" : $("#contsVer").val(),
					"openYn"   : $("input[name='openYn']:checked").val()
				},
				dataType : "text",
				success : function(data){
					onebtnchk=0;
					if( data == "OK" ){
						alert("저장 되었습니다.");
						parent.fn_ZTreeRefresh();
						parent.fn_Search();
						parent.FrameLayer.close();
					}else{
						alert("저장 중 오류가 발생되었습니다.");
					}
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//미리보기
		function fn_PreView(){
			var array = {"siteCd":$("#siteCd").val(),"menuCd":$("#menuCd").val(),"conts":$("#conts").val()};
			var popWidth  = window.screen.width;
			var popHeight = window.screen.height;
			if( Number($("#siteCd").val()) > 10000000 ){
				popWidth  = popWidth/2;
				//popHeight = popHeight/2;
			}
			G_PostPopupOpen("PreViewPop","<c:url value='/admmgr/manage/contsViewPop.do'/>",popWidth,popHeight,array);
		}
	</script>
</head>
<body>
	<form id="regiform" name="regiform" method="POST" >
		<input type="hidden" id="menuCd" name="menuCd" value="<c:out value="${rMap.MENU_CD}"/>"/>
		<!--common_wrapper-->
		<div class="pop_common_wrapper">

	            <!--body_wrapper-->
	            <div class="body_wrapper">

	                <!-- pop_wrapper -->
	                <div class="pop_wrapper">
	                    <!-- pop_inner -->
	                    <div class="pop_inner">
	                        <!-- 컨텐츠 영역 -->
	                        <div class="pop_con_section">
	                            <div class="con_list_wrap" >

	                                    <h6 class="sub_tit_h6 fix"><em>컨텐츠 ${(not empty rMap.CONTS_NO)?'수정':'등록'}</em></h6>
										<div class="n_table_sty01 n_view01 mt10">
											<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
												<caption>게시판 리스트</caption>
												<colgroup>
													<col width="15%">
													<col width="35%">
													<col width="15%">
													<col width="35%">
												</colgroup>
												<tbody>
													<tr>
														<th>사이트</th>
														<td>
															<input type="hidden" id="siteCd" name="siteCd" value="<c:out value="${rMap.SITE_CD}"/>"/>
															<c:out value="${rMap.SITE_NM}"/>
														</td>
														<th>매핑 메뉴</th>
														<td>
															<c:set var="menuPath"><c:out value="${rMap.MENU_PATH}" escapeXml="false"/></c:set>
															<c:out value="${menuPath}"/>
														</td>
													</tr>
													<tr>
														<th>컨텐츠명 <em class="point">&nbsp;</em></th>
														<td><input type="text" id="title" name="title" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${(not empty rMap.TITLE)?str:getReverseXSS(rMap.TITLE):menuPath}"/>"/></td>
														<th>게시여부 <em class="point">&nbsp;</em></th>
														<td>
															<label class="ch"><input type="radio" name="openYn" value="Y" <c:if test="${rMap.OPEN_YN eq 'Y' || empty rMap.OPEN_YN}">checked="checked"</c:if>/> <span>게시</span></label>
															<label class="ch"><input type="radio" name="openYn" value="N" <c:if test="${rMap.OPEN_YN eq 'N'}">checked="checked"</c:if>/> <span>비게시</span></label>
														</td>
													</tr>
													<tr>
														<th>내용 <em class="point">&nbsp;</em></th>
														<td class="td_con" valign="top" colspan="3">
															<textarea id="conts" name="conts" cols="" rows="" class="form_textarea ht300"><c:out value="${str:getReverseXSS(rMap.CONTS)}" escapeXml="false"/></textarea>
														</td>
													</tr>
													<tr>
														<th>버젼정보</th>
														<td>
															<input type="hidden" id="contsVer" name="contsVer" value="<c:out value="${str:getReverseXSS(rMap.CONTS_VER)}"/>"/>
															<c:out value="${rMap.CONTS_VER}"/>
														</td>
														<th>URL 1</th>
														<td><input type="text" id="url1" name="url1" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.URL_1)}"/>"/></td>
													</tr>
													<tr>
														<th>URL 2</th>
														<td><input type="text" id="url2" name="url2" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.URL_2)}"/>"/></td>
														<th>URL 3</th>
														<td><input type="text" id="url3" name="url3" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${str:getReverseXSS(rMap.URL_3)}"/>"/></td>
													</tr>
													<c:if test="${not empty rMap.CONTS_NO}">
														<tr>
															<th>최종수정자</th>
															<td><c:out value="${rMap.MDF_ID}"/></td>
															<th>최종수정일시</th>
															<td><c:out value="${rMap.MDF_DT}"/></td>
														</tr>
													</c:if>
												</tbody>
											</table>
										</div>

	                                    <div class="page_btn_wrap jc_between mt20">
	                                        
											<div class="lft">
												<em>※ 내용에 입력된 {URL1}은 URL1에 입력된 URL로 변환됩니다.(URL2도 동일)</em>
											</div>

											<div class="btn_wrap rgt">
												<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_PreView();"><em>미리보기</em></a>
												<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><em>저장</em></a>
												<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:parent.FrameLayer.close();"><em>닫기</em></a>
											</div>
	                                        
	                                    </div>

	                                </div>


	                        </div>
	                        <!-- // 컨텐츠 영역 -->
	                    </div>
	                    <!-- pop_inner -->

	                </div>
	                <!-- // pop_wrapper -->


	            </div>
	            <!--/body_wrapper-->

	        </div>
	        <!--/common_wrapper-->
	</form>
</body>