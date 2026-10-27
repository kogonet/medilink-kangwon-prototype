<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 컨텐츠 상세
 **************************************************/
%>
<head>
	<script type="text/javascript">
		$(document).ready(function(){
		});
		//수정
		function fn_Update(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/contsWrite.do'/>");
			$("#frm").submit();
		}
		//삭제
		function fn_Delete(){
			if( confirm("삭제 하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/contsDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/contsList.do'/>");
			$("#frm").submit();
		}
		//미리보기
		function fn_PreView(){
			var array = {"siteCd":$("#siteCd").val(),"contsNo":$("#contsNo").val(),"conts":$("#conts").val(),"url1":$("#url1").val(),"url2":$("#url2").val()};
			G_PostPopupOpen("PreViewPop","<c:url value='/admmgr/manage/contsViewPop.do'/>",window.screen.width,window.screen.height,array);
		}
		//이력 미리보기
		function fn_HistPreView(siteCd,contsNo,contsVer){
			var array = {"siteCd":siteCd,"contsNo":contsNo,"contsVer":contsVer};
			G_PostPopupOpen("PreViewPop","<c:url value='/admmgr/manage/contsViewPop.do'/>",window.screen.width,window.screen.height,array);
		}
		//적용
		function fn_UpdateCurrConts(siteCd,contsNo,contsVer){
			if( confirm("선택한 버젼으로 적용 하시겠습니까?") ){
				$("#siteCd").val(siteCd);
				$("#contsNo").val(contsNo);
				$("#contsVer").val(contsVer);
				$("#frm").attr("action","<c:url value='/admmgr/manage/contsUpdateCurrContsProc.do'/>");
				$("#frm").submit();
			}
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="siteCd" name="siteCd" value="<c:out value="${rMap.SITE_CD}"/>"/>
		<input type="hidden" id="contsNo" name="contsNo" value="<c:out value="${rMap.CONTS_NO}"/>"/>
		<input type="hidden" id="contsVer" name="contsVer" value="<c:out value="${rMap.CONTS_VER}"/>"/>
		<input type="hidden" id="conts" name="conts" value="<c:out value="${rMap.CONTS}"/>"/>
		<input type="hidden" id="url1" name="url1" value="<c:out value="${rMap.URL_1}"/>"/>
		<input type="hidden" id="url2" name="url2" value="<c:out value="${rMap.URL_2}"/>"/>
		<input type="hidden" id="openYn" name="openYn" value="<c:out value="${rMap.OPEN_YN}"/>"/>
	</form>
	<div class="sub_contents_form_type1">
		<div>
			<h4 class="sub_tit_h4 fix"><em>컨텐츠 상세</em></h4>
			<div style="padding:15px;">
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
							<td><c:out value="${rMap.SITE_NM}"/></td>
							<th>게시여부</th>
							<td>
								<c:choose>
									<c:when test="${rMap.OPEN_YN eq 'Y'}">게시</c:when>
									<c:otherwise>비게시</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<tr>
							<th>컨텐츠명</th>
							<td><c:out value="${rMap.TITLE}"/></td>
							<th>컨텐츠 버젼</th>
							<td><c:out value="${rMap.CONTS_VER}"/></td>
						</tr>
						<tr>
							<th>내용</th>
							<td colspan="3" class="td_con" valign="top" style="height:300px"><c:out value="${rMap.CONTS}" escapeXml="false"/></td>
						</tr>
						<tr>
							<th>URL 1</th>
							<td><c:out value="${rMap.URL_1}"/></td>
							<th>URL 2</th>
							<td><c:out value="${rMap.URL_2}"/></td>
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
						<a class="btn_red" href="javascript:void(0);" onclick="javascript:fn_Delete();"><em>삭제</em></a>
					</span>
					<span class="rit_btn_section">
						<a class="btn1_ty3" href="javascript:void(0);" onclick="javascript:fn_PreView();"><em>미리보기</em></a>
						<a class="btn_blue" href="javascript:void(0);" onclick="javascript:fn_Update();"><em>수정</em></a>
						<a class="btn_gray" href="javascript:void(0);" onclick="javascript:fn_List();"><em>목록</em></a>
					</span>
				</p>
			</div>
		</div>
		<h4 class="sub_tit_h4 fix"><em>컨텐츠 이력</em></h4>
		<div class="search_list_table" style="padding:15px;margin-bottom:100px;">
			<table cellpadding="0" cellspacing="0" border="0" class="table_renew_type2" id="normal">
				<colgroup>
					<col width="5%"/>
					<col width="5%"/>
					<col width="8%"/>
					<col width="%"/>
					<col width="6%"/>
					<col width="10%"/>
					<col width="9%"/>
					<col width="9%"/>
				</colgroup>
				<thead>
					<tr>
						<th>번호</th>
						<th>버젼</th>
						<th>사이트명</th>
						<th>컨텐츠명</th>
						<th>작성자</th>
						<th>등록일시</th>
						<th>현재적용</th>
						<th>미리보기</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${histList}" var="rList" varStatus="status">
						<tr>
							<td><c:out value="${PAGING_NUM-status.index}"/></td>
							<td><c:out value="${rList.CONTS_VER}"/></td>
							<td><c:out value="${rList.SITE_NM}"/></td>
							<td class="left">
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('<c:out value='${rList.SITE_CD}'/>','<c:out value='${rList.CONTS_NO}'/>');">
									<c:out value="${rList.TITLE}"/>
								</a>
							</td>
							<td><c:out value="${rList.REG_ID}"/></td>
							<td><c:out value="${rList.REG_DT}"/></td>
							<td>
								<c:choose>
									<c:when test="${rMap.CONTS_VER eq rList.CONTS_VER}">현재 적용 컨텐츠</c:when>
									<c:otherwise>
										<a class="btn2_ty2" href="javascript:void(0);" onclick="javascript:fn_UpdateCurrConts('${rList.SITE_CD}','${rList.CONTS_NO}','${rList.CONTS_VER}');"><em>적용</em></a>
									</c:otherwise>
								</c:choose>
							</td>
							<td><a class="btn2_ty3" href="javascript:void(0);" onclick="javascript:fn_HistPreView('${rList.SITE_CD}','${rList.CONTS_NO}','${rList.CONTS_VER}');"><em>미리보기</em></a></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(histList) eq 0}">
						<tr><td colspan="8">이력 내역이 없습니다.</td></tr>
					</c:if>
				</tbody>
			</table>
			<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
		</div>
	</div>
	<!--/컨텐츠 영역-->
</body>