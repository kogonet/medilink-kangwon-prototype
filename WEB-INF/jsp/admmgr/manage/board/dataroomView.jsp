<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 게시판 상세
 **************************************************/
%>
<head>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
		});
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/Regist${boardMngNo}.do'/>").submit();
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
		//copyUrl
		function fn_Copy(menuCd, mngNo, no){
			var copyConts = "/front/board/"+menuCd+"_Link.do?boardMngNo="+mngNo+"&boardNo="+no;
			if( copyConts ){
				var textarea = document.createElement("textarea");
				document.body.appendChild(textarea);

				textarea.value = copyConts;
				textarea.select();
				document.execCommand("copy");
				document.body.removeChild(textarea);
				alert("클립보드에 복사되었습니다.")
			}
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="<c:out value="${(not empty rMap.BOARD_MNG_NO)?rMap.BOARD_MNG_NO:boardMngNo}"/>"/>
	<input type="hidden" id="boardNo" name="boardNo" value="<c:out value="${rMap.BOARD_NO}"/>"/>
	<input type="hidden" id="fileNo1" name="fileNo1" value="<c:out value="${rMap.FILE_NO_1}"/>"/>
	<input type="hidden" id="fileNo2" name="fileNo2" value="<c:out value="${rMap.FILE_NO_2}"/>"/>
	<input type="hidden" id="chk" name="chk" value="${rMap.BOARD_MNG_NO}:${rMap.BOARD_NO}"/>
	<!-- sub_contents_wrap -->
		<div class="sub_contents_wrap">
			<!--sub_contents_area-->
			<div class="sub_contents_area">

				<h4 class="sub_tit_h4 fix">
				</h4>
				
				<div class="table_header">
					<h6 class="sub_tit_h6">게시글 상세</h6>
				</div>
				
				<div class="table_wrap n_table_sty01 n_view01 mt10">
					<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
						<colgroup>
							<col width="20%">
							<col width="30%">
							<col width="20%">
							<col width="40%">
						</colgroup>
						<tbody>
							<tr>
								<th>게시여부</th>
								<td>
									<c:choose>
										<c:when test="${rMap.OPEN_YN eq 'Y'}">게시</c:when>
										<c:otherwise>숨김</c:otherwise>
									</c:choose>
								</td>
								<th>작성자</th>
								<td><c:out value="${rMap.REG_NM}"/></td>
							</tr>
							
							<tr>
								<th>제목</th>
								<td colspan="3"><c:out value="${str:getReverseXSS(rMap.TITLE)}"/></td>
							</tr>
							<tr>
								<th>내용</th>
								<td class="td_con" valign="top" colspan="3"><c:out value="${str:getReverseXSS(rMap.CONTS)}" escapeXml="false"/></td>
							</tr>
							<%-- <tr>
								<th>첨부파일</th>
								<td class="td_con" valign="top" colspan="3">
									<c:set var="fileList1" value="${str:makeFileList(rMap.FILE_NO_1)}"/>
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
							</tr> --%>
						</tbody>
					</table>
				</div>
				
				<div class="page_btn_wrap jc_between mt20">
					<div class="lft"></div>
					<div class="rgt">
						<%-- <a class="btn_n_" href="javascript:void(0);" onclick="javascript:fn_Copy('<c:out value="${boardMenuMap.MENU_CD}"/>','<c:out value="${rMap.BOARD_MNG_NO}"/>','<c:out value="${rMap.BOARD_NO}"/>');"><em>Url복사</em></a> --%> 
						<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>수정</span></a>
						<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
					</div>
				</div>
			</div>
			<!--sub_contents_area-->
		</div>
		<!-- //sub_contents_wrap -->
	</form>
</body>