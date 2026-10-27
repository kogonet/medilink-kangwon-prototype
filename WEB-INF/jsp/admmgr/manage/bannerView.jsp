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
<head>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript">
		<%-- 목록 --%>
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerList.do'/>");
			$("#frm").submit();
		}
		<%-- 수정 --%>
		function fn_Update(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerWrite.do'/>");
			$("#frm").submit();
		}
		<%-- 삭제 --%>
		function fn_Delete(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/bannerDeleteProc.do'/>");
			$("#frm").submit();
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST" enctype="multipart/form-data">
	<input type="hidden" id="bannNo" name="bannNo" value="${rMap.BANN_NO}"/>
	<input type="hidden" id="chk" name="chk" value="${rMap.SITE_CD}:${rMap.BANN_NO}"/>
	<input type="hidden" id="searchfield" name="searchfield" value="<c:out value="${param.searchfield}"/>"/>
	<input type="hidden" id="searchword" name="searchword" value="<c:out value="${param.searchword}"/>"/>
	<input type="hidden" id="s_site_cd" name="s_site_cd" value="<c:out value="${param.s_site_cd}"/>"/>
	<input type="hidden" id="s_date_start" name="s_date_start" value="<c:out value="${param.s_date_start}"/>"/>
	<input type="hidden" id="s_date_end" name="s_date_end" value="<c:out value="${param.s_date_end}"/>"/>
	<input type="hidden" id="page" name="page" value="<c:out value="${param.page}"/>"/>
	<input type="hidden" id="s_bann_tp" name="s_bann_tp" value="<c:out value="${param.s_bann_tp}"/>"/>

	<input type="hidden" id="siteCd" name="siteCd" value="<c:out value="${rMap.SITE_CD}"/>"/>
	<input type="hidden" id="fileNo" name="fileNo" value="<c:out value="${rMap.FILE_NO}"/>"/>
	<input type="hidden" id="origin_fileNo" name="origin_fileNo" value="<c:out value="${rMap.FILE_NO}"/>"/>
	<input type="hidden" id="fileSeq" name="fileSeq"/>

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
			

				<div id="profInfo" class="table_wrap n_table_sty01 n_view01 mt10">
					<table class="table_renew_type1" cellspacing="0" cellpadding="0" border="0" style="">
						<colgroup>
							<col width="15%"/>
							<col width="35%"/>
							<col width="15%"/>
							<col width="35%"/>
						</colgroup>
						<tbody>
							<tr>
								<th>사이트</th>
								<td>
									<c:set var="siteList" value="${str:getSiteList()}"/>
									<c:forEach items="${siteList}" var="siteList" varStatus="status">
										<c:if test="${siteList.SITE_CD eq rMap.SITE_CD}"><c:out value="${siteList.SITE_NM}"/></c:if>
									</c:forEach>
								</td>
								<th>게시여부</th>
								<td>
									<c:choose>
										<c:when test="${rMap.OPEN_YN eq 'Y'}">게시</c:when>
										<c:otherwise>비게시</c:otherwise>
									</c:choose>
								</td>
							</tr>
							<tr>
								<th>배너타입</th>
								<td><c:out value="${rMap.BANN_TP}"/></td>
								<th>새창여부</th>
								<td><c:out value="${rMap.POPUP_YN}"/></td>
							</tr>
							<tr>
								<th>배너명</th>
								<td colspan="3"><c:out value="${str:getReverseXSS(rMap.TITLE)}"/></td>
							</tr>
							<tr>
								<th>내용</th>
								<td colspan="3">
									<c:out value="${str:getReverseXSS(rMap.CONTS)}" escapeXml="false"/>
									<%--
									<c:set var="CONTS"><c:out value="${rMap.CONTS}" escapeXml="false"/></c:set>
									<%
										String CONTS = String.valueOf(pageContext.getAttribute("CONTS"));
										out.println(com.ctit.helper.WebUtil.reverseXSSMinimum(CONTS));
									%>
									--%>
								</td>
							</tr>
							<tr>
								<th>링크 URL</th>
								<td colspan="3"><c:out value="${rMap.LINK_URL}"/></td>
							</tr>
							<tr>
								<th>게시시작일자</th>
								<td><c:out value="${rMap.SHOW_START_DD}"/></td>
								<th>게시종료일자</th>
								<td><c:out value="${rMap.SHOW_END_DD}"/></td>
							</tr>

							<tr>
								<th>배너 이미지</th>
								<td colspan="3">
									<c:set var="fileList1" value="${str:makeFileList(rMap.FILE_NO)}"/>
									<c:choose>
										<c:when test="${fn:length(fileList1) eq 0}"><p class="down_link">등록된 파일이 없습니다.</p></c:when>
										<c:otherwise>
											<c:forEach items="${fileList1}" var="fileList1" varStatus="status">
												<img src="<c:url value='/commonFile/loadImage.do?fileNo=${fileList1.FILE_NO}&fileSeq=${fileList1.FILE_SEQ}'/>" alt="<c:out value="${fileList1.ORIGIN_NM}"/> 이미지" style="max-width:450px;margin-bottom:5px;"/>
												<p>
													<strong><c:out value="${fileList1.ORIGIN_NM}"/></strong>
													<input type="button" class="btn primary sm" value="다운로드" onclick="javascript:fileDownload('<c:out value="${fileList1.FILE_NO}"/>','<c:out value="${fileList1.FILE_SEQ}"/>'); return false;"/>
												</p>
											</c:forEach>
										</c:otherwise>
									</c:choose>
								</td>
							</tr>
						</tbody>
					</table>
				</div>

				<%-- 버튼 영역 --%>
				<!-- page_btn_wrap -->
				<div id="btnArea" class="page_btn_wrap jc_between mt20">
					<div class="lft">
						<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
					</div>
					<div class="rgt">
						<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Update();"><span>수정</span></a>
						<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
					</div>
				</div>
				<!-- // page_btn_wrap -->

			
		</div>
		<!--// sub_contents_area-->

	</div>
	<!-- // sub_contents_wrap -->
</form>
</body>