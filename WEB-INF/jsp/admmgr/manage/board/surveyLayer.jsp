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
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<script type="text/javascript" src="<c:url value="/plug-in/cheditor/cheditor.js"/>"></script>
	<link rel="stylesheet" type="text/css"	href="/plug-in/coaUpload/CoaUpload.css" />
	<script type="text/javascript" src="/plug-in/coaUpload/CoaConfig.js"></script>
	<script type="text/javascript" src="/plug-in/coaUpload/CoaUpload.min.js"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/common/admmgr/js/frameLayer.js"/>"></script>
	<script type="text/javascript">
		$( document ).ready(function() {
			$( "#close_btn" ).on( "click", function() {
				FrameLayer.close();
			});
		});		
	</script>
</head>
<body>
	<!-- 타이틀 -->
	<div class="pop_tit_section fix">
		<h3 class="pop_tit_h3">미리보기</h3>
		<a href="javascript:FrameLayer.close();" class="pop_btn_close"><img src="/common/admmgr/images/sub_common/btn_pop_close01.png" alt="닫기 버튼"></a>
	</div>
	<!-- 팝업 : 본문 -->
	<div class="pop_con_section">
		<form id="frm" name="frm" method="GET">
			<input type="hidden" id="basic_seq" name="basic_seq" value="<c:out value="${rMap.BASIC_SEQ}"/>"/>
			<!--content wrap-->
			<div class="content_inner">
				<div class="con_sec">
					<h3 class="sub_tit_h3 sty02"><c:out value="${rMap.TITLE}"/></h3>				
					<div class="n_table_sty01 n_view01">
						<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
							<colgroup>
								<col width="18%">
								<col width="%">
							</colgroup>
							<tbody>
								<tr>
								<th>분류</th>
									<td class="left"><c:out value="${rMap.GUBUN_NM}"/></td>
								</tr>
								<tr>
								<th>설문기간</th>
									<td class="left"><c:out value="${rMap.STR_DD}"/>~<c:out value="${rMap.END_DD}"/></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<c:if test="${ rMap.AGREE_YN eq 'Y' }">
					<div class="con_sec">
						<h3 class="sub_tit_h3">개인정보 수집 및 이용 동의</h3>
						<div class="agree_wrap">
							<div class="agree_txt">
								<p class="p_txt f_w700">【개인정보의 수집ㆍ이용 목적】</p>
								<p class="p_txt f_w400">한국회계기준원은 관계법령 등에서 정하는 소관 업무의 수행을 위하여 다음과 같이 개인정보를 수집 및 이용합니다. </p>
								<p class="p_txt f_w700">【수집하는 개인정보의 항목】</p>
								<div class="float_row">
									<a href="/front/conts/124004000000000.do" class="btn_right01" target="_blank"><span>개인정보처리방침 바로가기</span></a>
								</div>
								<p class="p_txt f_w700">【개인정보의 보유 및 이용기간】</p>
								<p class="p_txt f_w400">한국회계기준원이 수집한 개인정보는 관계법령에 의하여 기록·보존되고, 기간이 경과된 경우 「개인정보보호법」 에서 정하는 바에 따라 파기됩니다.</p>
								<p class="p_txt f_w700">【동의 거부 권리 및 동의 거부 시 불이익】</p>
								<p class="p_txt f_w400">귀하는 위에 기술된 개인정보의 수집·이용 등 처리에 대해 동의를 거부하실 수 있습니다. 다만, 귀하가 동의를 거부하실 경우 해당 서비스 이용이 어려울 수 있습니다.</p>
				
							</div>
							<div class="agree_radio">
								<p class="agree_radio_txt">위 회원약관에 동의하십니까?</p>
								<div class="check_wrap03">
									<label for="agreeCh1"><input type="checkbox" id="agreeCh1"><span>이용약관을 모두 읽었으며 동의합니다.</span></label>
								</div>
							</div>
						</div>
					</div>
				</c:if>
					<c:forEach items="${GroupList}" var="GroupList" varStatus="status">
						<div class="con_sec">
							<h3 class="sub_tit_h3"><c:out value="${GroupList.GROUP_NM}"/></h3>
							<p class="p_txt"><c:out value="${GroupList.GROUP_CONT}"  escapeXml="false"/></p>
							<ul class="survey_wrap">
								<c:forEach var="QuestList" items="${str:makeSurveyQuestList(GroupList.BASIC_SEQ,GroupList.GROUP_SEQ)}" varStatus="status">
									<li class="surveyList">
										<div class="survey_top">
											<p class="survey_num">Q<c:out value="${QuestList.GROUP_SEQ}" />-<c:out value="${QuestList.QUEST_SEQ}" />.</p>
											<p class="survey_q"><span><c:out value="${QuestList.QUEST_TITLE}"  escapeXml="false" /></span></p>
										</div>
										<div class="survey_bott">
											<c:choose>
												<c:when test="${ QuestList.QUEST_GUBUN eq 'A' }">
													<input type="text" name="shrt_answer" class="shrt_answer input_text02 form_sizef mustNeed" title="Q<c:out value="${QuestList.GROUP_SEQ}" />-<c:out value="${QuestList.QUEST_SEQ}" />항목"  maxlength="200">
												</c:when>
												<c:otherwise>
													<div class="${ QuestList.QUEST_GUBUN eq 'S' ? 'radio_wrap02' : 'check_wrap02' } ">
														<c:forEach var="CatgyList" items="${str:makeSurveyCatgyList(QuestList.BASIC_SEQ,QuestList.GROUP_SEQ,QuestList.QUEST_SEQ)}" varStatus="status">
															<label for="mult_${ CatgyList.BASIC_SEQ }_${ CatgyList.QUEST_SEQ }_${ CatgyList.CATGY_SEQ }">
																<input value="${ CatgyList.CATGY_SEQ }" class="mustNeed" title="Q<c:out value="${CatgyList.GROUP_SEQ}" />-<c:out value="${CatgyList.QUEST_SEQ}" />항목" type="${ QuestList.QUEST_GUBUN eq 'S' ? 'radio' : 'checkbox' }" name="mult_choice_${ CatgyList.GROUP_SEQ }_${ CatgyList.QUEST_SEQ }" id="mult_${ CatgyList.BASIC_SEQ }_${ CatgyList.QUEST_SEQ }_${ CatgyList.CATGY_SEQ }">
																<span><c:out value="${CatgyList.CATGY_CONT}"  escapeXml="false"/></span>
																<span style="display:${ CatgyList.ETC_YN eq 'Y' ? 'block' : 'none' };">
																	<input type="text" name="etc_text" class="etc_text${ CatgyList.ETC_YN } etc_text input_text02 form_sizef" title="" style="background-color:#d5d5d5;" readonly="readonly" maxlength="200">
																</span>															
															</label>
														</c:forEach>
													</div>
												</c:otherwise>
											</c:choose>
										</div>
										<input type="hidden" name="survey_key" class="survey_key" id="survey_key_${ QuestList.GROUP_SEQ }_${ QuestList.QUEST_SEQ }" value="${ QuestList.GROUP_SEQ }_${ QuestList.QUEST_SEQ }" />
										<input type="hidden" name="survey_rstl" class="survey_rstl" id="survey_rstl_${ QuestList.GROUP_SEQ }_${ QuestList.QUEST_SEQ }" value="" />
										<input type="hidden" name="survey_gubun" class="survey_gubun" id="survey_gubun_${ QuestList.GROUP_SEQ }_${ QuestList.QUEST_SEQ }" value="${ QuestList.QUEST_GUBUN }" /> 					
									</li>		
								</c:forEach>
							</ul>
						</div>
					</c:forEach>	
				
				<div class="con_sec">
					<div class="n_table_sty01 n_view01 mt10">
						<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
							<caption>인적사항에 관련된 표</caption>
							<colgroup>
								<col width="20%">
								<col width="30%">
								<col width="20%">
								<col width="30%">
							</colgroup>
							<tbody>
								<tr>
									<th>자동 입력 방지 코드</th>
									<td  colspan="3">														
										<div class="capt_wrap">
											<div class="capt_img">
												<img id="captchaImg" src="/captchaImg.do?rand=<%= System.currentTimeMillis() %>" alt="캡차이미지"/>
												<a href="javascript:void(0);" onclick="getImage();" class="btn secondary sm"><span>새로고침</span></a>
												<a href="javascript:void(0);" onclick="audio();" class="btn secondary sm"><span>음성으로 듣기</span></a>
											</div>
											<div id="ccaudio" style="display:none"></div>
											<div class="capt_input">
												<input id="answer" type="text" value="" class="form_text">
												<input id="check1" type="button" class="btn primary sm" value="확인"/>
												<span class="sub_input_txt">* 자동등록방지 숫자를 순서대로 입력하세요.</span>
											</div>
										</div>
									</td>
								</tr>	                     
							</tbody>
						</table>
					</div>
					<div class="table_footer">
						<div class="btn_wrap lft">
						</div>
						<div class="btn_wrap rgt">
							<a id="close_btn" class="btn_n_list" href="javascript:void(0);"><span>취소</span></a>
							<a class="btn_n_save" href="javascript:void(0);"><span>제출</span></a>
						</div>
					</div>
				</div>					


				
			</div>      
			<!--//content wrap-->
			<script>
			
				var chkYn = true;
				
				$(document).ready(function(){
					getImage();	// 이미지 가져오기
					
					document.querySelector('#check1').addEventListener('click', function(){
						var answer = document.querySelector('#answer').value;
						var params = { answer: answer };
						$.ajax({
							url: '/chkAnswer.do',
							type: 'POST', // 요청 메소드에 맞게 변경
							data: params,
							dataType: 'json',
							success: function(returnData) {
								if (returnData === 200) {
									alert('입력값이 일치합니다.');
									chkYn = false;
								} else {
									alert('입력값이 일치하지 않습니다.');
									getImage();
									document.querySelector('#answer').value = ''; // value 설정 수정
									chkYn = true;
								}
							},
							error: function(xhr, status, error) {
								// 요청 실패 처리
							}
						});
					});
			
				});
				
				function audio(){
					var rand = Math.random();
					var uAgent = navigator.userAgent;
					var soundUrl = '${ctx}/captchaAudio.do?rand='+rand;
					if(uAgent.indexOf('Trident')>-1 || uAgent.indexOf('MISE')>-1){	/*IE 경우 */
						audioPlayer(soundUrl);
					}else if(!!document.createElement('audio').canPlayType){ /*Chrome 경우 */
						try {
							new Audio(soundUrl).play();
						} catch (e) {
							audioPlayer(soundUrl);
						}
					}else{
						window.open(soundUrl,'','width=1,height=1');
					}
				}
				
				function getImage() {
					var rand = Math.random();
					var url = '/captchaImg.do?rand=' + rand;
					console.log('New image URL:', url); // 확인용 메시지
					$('#captchaImg').attr('src', url);
				}
				
				function audioPlayer(objUrl){
					document.querySelector('#ccaudio').innerHTML = '<bgsoun src="' +objUrl +'">';
				}	
			
			</script>
		</form>
	</div>
	<!-- // 팝업 : 본문 -->
</body>