<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * bannerList.jsp
 * @desc    : 배너 목록
 **************************************************/
%>
<head>
<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>

<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		$('.btn_down_wrap > .close').click(function() {
			$('.content_wrap').removeClass('open');
			$('.content_wrap').addClass('close');
		});

		$('.btn_lft_menu > .open').click(function() {
			$('.content_wrap').removeClass('close');
			$('.content_wrap').addClass('open');
		});
	});
	<%-- 리스트 전체체크 --%>
	function fn_CheckAll(obj){
		if( $(obj).is(":checked") ){
			$("input[name=chk]").attr("checked",true);
		}else{
			$("input[name=chk]").attr("checked",false);
		}
	}
	<%-- 검색 --%>
	function fn_Search(){
		if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
			return false;
		}
		$("#frm").attr("action","<c:url value='/admmgr/manage/bannerList.do'/>");
		$("#frm").submit();
	}
	<%-- 상세 --%>
	function fn_Detail(siteCd,bannNo){
		$("#siteCd").val(siteCd);
		$("#bannNo").val(bannNo);
		$("#frm").attr("action","<c:url value='/admmgr/manage/bannerView.do'/>");
		$("#frm").submit();
	}
	<%-- 등록 --%>
	function fn_Regist(){
		$("#frm").attr("action","<c:url value='/admmgr/manage/bannerWrite.do'/>");
		$("#frm").submit();
	}
	<%-- 삭제 --%>
	function fn_Delete(){
		var checkedCnt = 0;
		$("input[name=chk]").each(function(){
			if( $(this).is(":checked") ){
				checkedCnt++;
			}
		});
		if( checkedCnt == 0 ){
			alert("삭제할 항목을 선택해 주세요.");
			return false;
		}
		if( confirm("선택된 항목을 삭제하겠습니까?") ){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerDeleteProc2.do'/>");
			$("#frm").submit();
		}
	}
	/* 다운로드 클릭 시 */
	function fn_open(element) {
		$('.btn_down_wrap.act').removeClass('act');
		$(element).closest('.btn_down_wrap').addClass("act");
	}
	/* 닫기 클릭 시 */
	function fn_close(element) {
		$(element).closest('.btn_down_wrap.act').removeClass("act");
	}

	//레이어
	function fn_Layer(){
		FrameLayer.open("<c:url value='/admmgr/manage/bannerSortLayer.do'/>",1100,900,"yes");
	}
</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
<input type="hidden" id="siteCd" name="siteCd"/>
<input type="hidden" id="bannNo" name="bannNo" />
<%-- 해당 권한에 부여된 사이트만 검색 가능 --%>
<c:if test="${userSiteCd ne '000000000000000' && userAuthCd ne '000000000000000'}">
	<input type="hidden" id="s_site_cd" name="s_site_cd" value="${userSiteCd}"/>
</c:if>
<!--컨텐츠 영역-->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

		<!-- 검색 -->
		<fieldset>
			<legend>검색</legend>
			<div class="search_form_wrap mb10">
				<div class="search_form_inner" >
					<!-- filter_form -->
					<div class="filter_form">
						<%-- 시스템관리자의 경우 --%>
						<c:if test="${userSiteCd eq '000000000000000' && userAuthCd eq '001000000'}">
							<div>
								<label>사이트</label>
								<select id="s_site_cd" name="s_site_cd" class="form_select md" title="사이트 선택" onchange="javascript:fn_ChangeSite(this);">
									<option value="">전체</option>
									<c:set var="siteList" value="${str:getSiteList()}"/>
									<c:forEach items="${siteList}" var="siteList" varStatus="status">
										<option value="<c:out value="${siteList.SITE_CD}"/>" ${(param.s_site_cd eq siteList.SITE_CD)?"selected='selected'":""}><c:out value="${siteList.SITE_NM}"/></option>
									</c:forEach>
								</select>
							</div>
						</c:if>
						<div>
							<label>배너타입</label>
							<select id="s_bann_tp" name="s_bann_tp" class="form_select md" title="배너 선택">
								<option value="">전체</option>
								<option value="CENTER" ${ param.s_bann_tp eq 'CENTER' ? "selected='selected'" : "" }>메인배너</option>
								<option value="RIGHT" ${ param.s_bann_tp eq 'RIGHT' ? "selected='selected'" : "" }>우측배너</option>
								<option value="FOOTER" ${ param.s_bann_tp eq 'FOOTER' ? "selected='selected'" : "" }>푸터배너</option>
							</select>
						</div>
						<div>
							<label>검색조건</label>
							<select id="searchfield" name="searchfield" class="form_select md" title="조건 선택" style="width: 80px;">
								<option value="ALL">전체</option>
								<option value="TITLE"    ${ param.searchfield eq 'TITLE' ? "selected='selected'" : "" }>배너명</option>
								<option value="LINK_URL" ${ param.searchfield eq 'LINK_URL' ? "selected='selected'" : "" }>링크URL</option>
							</select>
							<input type="text" id="searchword" name="searchword" class="form_text md wd300"  value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
						</div>
					
						<div>
							<label>등록일자</label>
							<div>
								<span class="form_date">
									<input type="text" id="s_date_start" name="s_date_start" placeholder="시작일 입력" class="form_text wd140" value="<c:out value="${(not empty param.s_date_start)?param.s_date_start:s_date_start}"/>" onclick="calendar(event,'s_date_start','yyyy-mm-dd')" >
									<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_start').trigger('click');">
								</span>
								~
								<span class="form_date">
									<input type="text" id="s_date_end" name="s_date_end" placeholder="종료일 입력" class="form_text wd140" value="<c:out value="${(not empty param.s_date_end)?param.s_date_end:s_date_end}"/>" onclick="calendar(event,'s_date_end','yyyy-mm-dd')">
									<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_end').trigger('click');">
								</span>
							</div>
						</div>
					</div>
					<!-- filter_form -->
					 
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
				<%--
				<input type="hidden" id="search_view" value="Y"/>
				<a href="#" class="btn_search_open"><img src="<c:url value='/images/admmgr/sub_common/btn_open1.png'/>" alt="검색영역 열고닫기 이미지"/></a>
				--%>
			</div>
		</fieldset>
		<!-- // 검색 -->

		<!--리스트 시작-->
		<div class="con_list_wrap">
			<div class="table-wrap">
				<div class="noti_area mt0">
					<p class="noti_text"><em>그룹 홈페이지를 포함한 각 사이트 홈페이지의 상단 배너와 모바일 홈페이지 팝업 배너를 관리할 수 있습니다.</em><br></p>
					<p class="noti_text"><em>게시기간이 지날 경우 자동으로 배너가 사라집니다.</em><br></p>
				</div>

			<div class="n_table_sty01 n_list01 mt10">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
					<colgroup>
						<col width="3%"/>
						<col width="13%"/>
						<%-- <col width="22%"/> --%>
						<col width="*"/>
						<col width="12%"/>
						<col width="7%"/>
						<col width="8%"/>
						<col width="15%"/>
						<col width="8%"/>
					</colgroup>
					<thead>
						<tr>
							<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
							<th class="center"><span>사이트</span></th>
							<th class="center"><span>배너명</span></th>
							<!-- <th class="center"><span>링크URL</span></th> -->
							<th class="center"><span>게시기간</span></th>
							<th class="center"><span>게시여부</span></th>
							<th class="center"><span>등록자</span></th>
							<th class="center"><span>등록일시</span></th>
							<th class="center"><span>다운로드</span></th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${rList}" var="rList" varStatus="status">
						<c:set var="fileList" value="${str:makeFileList(rList.FILE_NO)}"/>
							<tr>
								<td><input type="checkbox" name="chk" id="chk" value="<c:out value="${rList.SITE_CD}"/>,<c:out value="${rList.BANN_NO}"/>"/></td>
								<td class="center">
									<c:set var="siteList" value="${str:getSiteList()}"/>
									<c:forEach items="${siteList}" var="siteList" varStatus="status">
										<c:if test="${siteList.SITE_CD eq rList.SITE_CD}"><c:out value="${siteList.SITE_NM}"/></c:if>
									</c:forEach>
								</td>
								<td style="text-align:left"><a href="javascript:fn_Detail('${rList.SITE_CD}','${rList.BANN_NO}');"><c:out value="${str:getReverseXSS(rList.TITLE)}"/></a></td>
								<%-- <td class="center" style="text-align:left"><c:out value="${rList.LINK_URL}"/></td> --%>
								<c:choose>
									<c:when test="${not empty rList.SHOW_START_DD}">
										<td class="center"><c:out value="${rList.SHOW_START_DD}"/> ~ <c:out value="${rList.SHOW_END_DD}"/></td>
									</c:when>
									<c:otherwise>
										<td class="center">무기한</td>
									</c:otherwise>
								</c:choose>
								<td class="center">
									<c:choose>
										<c:when test="${rList.OPEN_YN eq 'Y'}">게시</c:when>
										<c:otherwise>비게시</c:otherwise>
									</c:choose>
								</td>
								<td class="center"><c:out value="${rList.REG_ID}"/></td>
								<td class="center"><c:out value="${rList.REG_DTM}"/></td>
								
								<c:choose>
									<c:when test="${not empty fileList}">
										<td class="center">
											<div class="btn_down_wrap">
												<a href="javascript:void(0);" onclick="javascript:fn_open(this);" class="btn_down" title="다운로드버튼"><span>다운로드</span></a>
												<div class="down_pop_wrap">
														<div class="down_pop_top"><p>파일 다운로드 선택</p><a href="javascript:void(0);" onClick="fn_close(this);"><img src="/common/admmgr/images/layout_n/ico_logout.png" alt="로그아웃"></a></div>
														<div class="down_pop_bott">
															<ul class="down_pop_list">
																<c:forEach items="${fileList}" var="fileList1" varStatus="status">
																	<c:set var="extension" value="${fn:split(fileList1.ORIGIN_NM, '.')}" /> <!-- .으로 파일명 분리 -->
																	<c:set var="string_temp" value="${extension[fn:length(extension)-1]}"></c:set> <!-- 가장 마지막 요소 (확장자) -->
																		<!-- 실제 확장자명과 클래스명이 일치하지않아 맞춰줌  -->
																		<c:choose>
																			<c:when test="${string_temp eq 'xlsx' }"><c:set var="ico_class" value="down_excel"></c:set></c:when>
																			<c:when test="${string_temp eq 'hwp' || string_temp eq 'hwpx'}"><c:set var="ico_class" value="down_hwp"></c:set></c:when>
																			<c:when test="${string_temp eq 'etc' }"><c:set var="ico_class" value="down_etc"></c:set></c:when>
																			<c:when test="${string_temp eq 'pdf' }"><c:set var="ico_class" value="down_pdf"></c:set></c:when>
																			<c:when test="${string_temp eq 'img' }"><c:set var="ico_class" value="down_img"></c:set></c:when>
																			<c:when test="${string_temp eq 'zip' }"><c:set var="ico_class" value="down_zip"></c:set></c:when>
																			<c:when test="${string_temp eq 'ppt' || string_temp eq 'pptx' }"><c:set var="ico_class" value="down_ppt"></c:set></c:when> 
																			<c:when test="${string_temp eq 'doc' || string_temp eq 'docx' }"><c:set var="ico_class" value="down_word"></c:set></c:when>
																			<c:when test="${string_temp eq 'png' }"><c:set var="ico_class" value="down_png"></c:set></c:when>
																			<c:when test="${string_temp eq 'jpg' }"><c:set var="ico_class" value="down_jpg"></c:set></c:when>
																			<c:otherwise><c:set var="ico_class" value="ico_etc"></c:set></c:otherwise>
																		</c:choose>
																		<li class="${ico_class}"><a title="다운로드 하려면 클릭하세요  ${ fileList1.ORIGIN_NM }" onclick="javascript:fileDownload('<c:out value="${fileList1.FILE_NO}"/>','<c:out value="${fileList1.FILE_SEQ}"/>'); return false;"><span><c:out value="${fileList1.ORIGIN_NM}"/></span></a></li>
																</c:forEach>
															</ul>
														</div>
												</div>
											</div>
										</td>
									</c:when>
									<c:otherwise>
										<td></td>
									</c:otherwise>
								</c:choose>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(rList) eq 0}">
							<tr><td colspan="8">등록된 게시물이 없습니다.</td></tr>
						</c:if>
					</tbody>
				</table>
			</div>

			<div class="table_footer">
				<div class="pagination_wrap">
					<%-- Paging START --%>
					<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
					<%-- Paging END   --%>
				</div>

				
				<div class="btn_wrap lft">
					<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
				</div>

				<div class="btn_wrap rgt"">
					<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
				</div>
				
			</div>
		</div>
		<!--/리스트 끝-->

	</div>
	<!--// sub_contents_area-->

</div>
<!--/ 컨텐츠 영역-->
</form>
</body>