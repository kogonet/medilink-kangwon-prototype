<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 설문조사 상세
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>  
<head>
	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script>
	<link rel="stylesheet" type="text/css"	href="/plug-in/coaUpload/CoaUpload.css" />
	<script type="text/javascript" src="/plug-in/coaUpload/CoaConfig.js"></script>
	<script type="text/javascript" src="/plug-in/coaUpload/CoaUpload.min.js"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript" src="/common/admmgr/js/frameLayer.js"></script>
	<script type="text/javascript" src="/common/admmgr/js/jquery.table2excel.js"></script>	
	<script type="text/javascript">
		//삭제
		function fn_Delete(){
			if( confirm("삭제하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyDeleteProc.do'/>")
				$("#frm").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyList.do'/>")
			$("#frm").submit();
		}
		//미리보기
		function fn_Review() {
			FrameLayer.open( "<c:url value='./surveyLayer.do'/>",1280,800,"yes",{"basic_seq":"<c:out value="${rMap.BASIC_SEQ}"/>"});
			
		}
		//복사하기
		function fn_Copy() {
			$("#copy").val( "Y" );
			$("#frm").attr("action","/admmgr/manage/board/surveyRegist.do").submit();
		}
		//수정하기
		function fn_Update(){
			$("#frm").attr("action","/admmgr/manage/board/surveyRegist.do").submit();
		}
		//엑셀다운로드
		function excelDownLink() {
						
			var file_nm = "<c:out value="${rMap.TITLE}"/>_설문조사 정보";
			
			$( "#excel_down" ).table2excel({
				exclude: ".noExl",
				name: "설문조사정보",
				filename: file_nm + "_통계항목" +'.xls', //확장자를 여기서 붙여줘야한다.
				fileext: ".xls",
				exclude_img: true,
				exclude_links: true,
				exclude_inputs: true
			});	
			
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="GET">
	<input type="hidden" id="basic_seq" name="basic_seq" value="<c:out value="${rMap.BASIC_SEQ}"/>"/>
	<input type="hidden" id="copy" name="copy" value="N"/>
	<input type="hidden" id="chk" name="chk" value="${rMap.BASIC_SEQ}"/>


		<!-- sub_contents_wrap -->
		<div class="sub_contents_wrap">
			<!--sub_contents_area-->
			<div class="sub_contents_area">

				<!-- 설문조사 상세 -->
				<div class="con_sec">
					<div class="box_tit">
						<h6 class="title">설문조사 상세</h6>
						<div class="rgt">
							<a class="btn primary xsm" href="javascript:void(0);" onclick="javascript:excelDownLink();"><em>엑셀 다운로드</em></a>
						</div>
					</div>
					
					<div id="excel_down" style="display: none;">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
							<colgroup>
								<col width="20%">
								<col width="30%">
								<col width="20%">
								<col width="30%">
							</colgroup>
							<tbody>
								<tr>
									<th>분류</th>
									<td><c:out value="${rMap.GUBUN_NM}"/></td>
									<th>작성자</th>
									<td><c:out value="${rMap.WRITER}"/></td>
								</tr>
								<tr>
									<th>제목</th>
									<td colspan="3"><c:out value="${rMap.TITLE}"/></td>
								</tr>
								<tr>
									<th>설문기간</th>
									<td colspan="3"><c:out value="${rMap.STR_DD}"/>~<c:out value="${rMap.END_DD}"/></td>
								</tr>														
								<tr>
									<th>내용</th>
									<td class="td_con" valign="top" colspan="3">
										<div id = "divConts"><c:out value="${rMap.CONTENTS}" escapeXml="false"/></div>
									</td>
								</tr>
								<tr>
									<th>공개여부</th>
									<td>${ rMap.OPEN_YN eq 'Y' ? "예" : "아니오" }</td>
									<th>개인정보수집여부</th>
									<td>${ rMap.AGREE_YN eq 'Y' ? "예" : "아니오" }</td>									
								</tr>
								<c:forEach items="${GroupList}" var="GroupList" varStatus="status">
									<ul>
										<ls>
											<ul>
											
											</ul>
										</ls>
									</ul>
									<tr>
										<th>그룹번호</th>
										<td colspan="3" style="text-align:left;"><c:out value="${GroupList.GROUP_SEQ}"/></td>
									</tr>
									<tr>
										<th>그룹명</th>
										<td colspan="3"><c:out value="${GroupList.GROUP_NM}" escapeXml="false" /></td>
									</tr>
									<tr>
										<th>그룹 설명</th>
										<td colspan="3"><c:out value="${GroupList.GROUP_CONT}" escapeXml="false"/></td>
									</tr>
									<c:forEach var="QuestList" items="${str:makeSurveyQuestList(GroupList.BASIC_SEQ,GroupList.GROUP_SEQ)}" varStatus="status">
										<tr>
											<th rowspan="3">Q<c:out value="${QuestList.GROUP_SEQ}" />-<c:out value="${QuestList.QUEST_SEQ}" /></th>
											<th>질문유형</th>
											<td colspan="2">${ QuestList.QUEST_GUBUN eq 'A' ? "주관식" : QuestList.QUEST_GUBUN eq 'S' ? "단일선택" : QuestList.QUEST_GUBUN eq 'M' ? "다중선택" : "" }</td>
										</tr>
										<tr>
											<th>질문내용</th>
											<td colspan="2"><c:out value="${QuestList.QUEST_TITLE}" escapeXml="false" /></td>
										</tr>
										<tr>
											<th>답변</th>
											<td colspan="2">
												<div style="height:300px; overflow-y:auto;">
													<c:choose>
														<c:when test="${ QuestList.QUEST_GUBUN eq 'A' }">
															<c:forEach var="AnswerList" items="${str:makeSurveyAnswerList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ,'A')}" varStatus="status">
																<div style="border: 1px solid #dbdfe2;padding: 8px;  background:#f5f5f5;" class="fix mb5">*. <c:out value="${AnswerList.SHRT_ANSWER}"/></div>
															</c:forEach>
														</c:when>
														<c:otherwise>
															<c:forEach var="CatgyList" items="${str:makeSurveyCatgyList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ)}" varStatus="status">
																<div style="border: 1px solid #dbdfe2;padding: 8px; background:#f5f5f5; border-bottom-color:red;" class="fix mb5">
																	<span style="float:left;">
																		<c:out value="${CatgyList.CATGY_SEQ}"/>. <c:out value="${CatgyList.CATGY_CONT}" escapeXml="false"/>
																	</span>
																	<span style="float:right;">
																		<c:choose>
																			<c:when test="${ CatgyList.RESULT_VOLTE eq 'NaN' }">
																				<c:out value="${CatgyList.CATE_CNT}"/>명 ( 0 % )
																			</c:when>
																			<c:otherwise>
																				<c:out value="${CatgyList.CATE_CNT}"/>명 ( <fmt:formatNumber value="${ CatgyList.RESULT_VOLTE }" pattern="#.##"/> % )
																			</c:otherwise>
																		</c:choose>
																	</span>
																</div>
																<c:if test="${ CatgyList.ETC_YN eq 'Y' }">
																	<c:forEach var="EtcList" items="${str:makeSurveyEctList(CatgyList.BASIC_SEQ,CatgyList.GROUP_SEQ,CatgyList.QUEST_SEQ,CatgyList.CATGY_SEQ)}" varStatus="status">
																		<div>
																			${ EtcList.SHRT_ANSWER }
																		</div>
																	</c:forEach>
																</c:if>															
															</c:forEach>
														</c:otherwise>																						
													</c:choose>	
												</div>
											</td>
										</tr>
									</c:forEach>																										
								</c:forEach>																													
							</tbody>
						</table>
					</div>

					<div class="table_wrap n_table_sty01 n_view01">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="">
							<colgroup>
								<col width="20%">
								<col width="30%">
								<col width="20%">
								<col width="30%">
							</colgroup>
							<tbody>
								<tr>
									<th>분류</th>
									<td><c:out value="${rMap.GUBUN_NM}"/></td>
									<th>작성자</th>
									<td><c:out value="${rMap.WRITER}"/></td>
								</tr>
								<tr>
									<th>제목</th>
									<td colspan="3"><c:out value="${rMap.TITLE}"/></td>
								</tr>
								<tr>
									<th>설문기간</th>
									<td colspan="3"><c:out value="${rMap.STR_DD}"/>~<c:out value="${rMap.END_DD}"/></td>
								</tr>														
								<tr>
									<th>내용</th>
									<td class="td_con" valign="top" colspan="4">
										<div id = "divConts"><c:out value="${rMap.CONTENTS}" escapeXml="false"/></div>
									</td>
								</tr>
								<tr>
									<th>공개여부</th>
									<td>${ rMap.OPEN_YN eq 'Y' ? "예" : "아니오" }</td>
									<th>개인정보수집여부</th>
									<td>${ rMap.AGREE_YN eq 'Y' ? "예" : "아니오" }</td>									
								</tr>																					
							</tbody>	
						</table>
					</div>
				</div>
				<!-- // 설문조사 상세 -->
				
				<!-- 설문조사 정보 -->
				<div class="con_sec">
					<div class="box_tit">
						<h6 class="title">설문조사 정보</h6>
					</div>

					<div class="table_wrap n_table_sty01 n_view01">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="">
							<colgroup>
								<col width="15%" />
								<col width="85%" />
							</colgroup>
							<tbody>
								<c:forEach items="${GroupList}" var="GroupList" varStatus="status">
									<tr>
										<th>그룹번호</th>
										<td><c:out value="${GroupList.GROUP_SEQ}"/></td>
									</tr>
									<tr>
										<th>그룹명</th>
										<td><c:out value="${GroupList.GROUP_NM}" escapeXml="false"/></td>
									</tr>
									<tr>
										<th>그룹 설명</th>
										<td><c:out value="${GroupList.GROUP_CONT}" escapeXml="false"/></td>
									</tr>
									<tr>
										<td colspan="2">
											<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="" style="width:100%;">
												<colgroup>
													<col width="5%" />
													<col width="10%" />
													<col width="85%" />
												</colgroup>
												<tbody>														
													<c:forEach var="QuestList" items="${str:makeSurveyQuestList(GroupList.BASIC_SEQ,GroupList.GROUP_SEQ)}" varStatus="status">
														<tr>
															<th rowspan="3">Q<c:out value="${QuestList.GROUP_SEQ}" />-<c:out value="${QuestList.QUEST_SEQ}" /></th>
															<th>질문유형</th>
															<td>${ QuestList.QUEST_GUBUN eq 'A' ? "주관식" : QuestList.QUEST_GUBUN eq 'S' ? "단일선택" : QuestList.QUEST_GUBUN eq 'M' ? "다중선택" : "" }</td>
														</tr>
														<tr>
															<th>질문내용</th>
															<td><c:out value="${QuestList.QUEST_TITLE}" escapeXml="false"/></td>
														</tr>
														<tr>
															<th>답변</th>
															<td>
																<div style="height:300px; overflow-y:auto;">
																<c:choose>
																	<c:when test="${ QuestList.QUEST_GUBUN eq 'A' }">
																		<c:forEach var="AnswerList" items="${str:makeSurveyAnswerList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ,'A')}" varStatus="status">
																			<div style="border: 1px solid #dbdfe2;padding: 8px;  background:#f5f5f5;" class="fix mb5">*. <c:out value="${AnswerList.SHRT_ANSWER}"/></div>
																		</c:forEach>
																	</c:when>
																	<c:otherwise>
																		<c:forEach var="CatgyList" items="${str:makeSurveyCatgyList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ)}" varStatus="status">
																			<div style="border: 1px solid #dbdfe2;padding: 8px; background:#f5f5f5; border-bottom-color:red;" class="fix mb5">
																				<span style="float:left;">
																					<c:out value="${CatgyList.CATGY_SEQ}"/>. <c:out value="${CatgyList.CATGY_CONT}" escapeXml="false"/>
																				</span>
																				<span style="float:right; color:red;">
																					<c:choose>
																						<c:when test="${ CatgyList.RESULT_VOLTE eq 'NaN' }">
																							<c:out value="${CatgyList.CATE_CNT}"/>명 ( 0 % )
																						</c:when>
																						<c:otherwise>
																							<c:out value="${CatgyList.CATE_CNT}"/>명 ( <fmt:formatNumber value="${ CatgyList.RESULT_VOLTE }" pattern="#.##"/> % )
																						</c:otherwise>
																					</c:choose>																								
																				</span>
																				<c:if test="${ CatgyList.ETC_YN eq 'Y' }">
																					<c:forEach var="EtcList" items="${str:makeSurveyEctList(CatgyList.BASIC_SEQ,CatgyList.GROUP_SEQ,CatgyList.QUEST_SEQ,CatgyList.CATGY_SEQ)}" varStatus="status">
																						<div style="clear:both; padding-left:20px;">
																							- ${ EtcList.SHRT_ANSWER }
																						</div>
																					</c:forEach>
																				</c:if>																			
																			</div>
																		</c:forEach>																						
																	</c:otherwise>																						
																</c:choose>	
															</div>
															</td>
														</tr>																																																				
													</c:forEach>
												</tbody>
											</table>																	
										</td>
									</tr>																										
								</c:forEach>												
							</tbody>	
						</table>
					</div>

					<div class="table_footer">
						<div class="lft">
							<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
						</div>
						<div class="rgt">
							<a class="btn_n_copy" href="javascript:void(0);" onclick="javascript:fn_Copy();"><span>복사하기</span></a>
							<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_Review();"><span>미리보기</span></a>
							<c:if test="${ CHK_RSTL eq '0' }">
								<c:if test="${ STATE_CHK eq 'Y' }">							
									<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Update();"><span>수정</span></a>
								</c:if>
							</c:if>
							<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
						</div>
					</div>
				</div>
				<!-- // 설문조사 정보 -->

			<!--sub_contents_area-->
			</div>

		</div>
		<!-- //sub_contents_wrap -->

	</form>
</body>