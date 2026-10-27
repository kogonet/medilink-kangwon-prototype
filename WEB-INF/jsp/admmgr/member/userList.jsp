<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 평가회원 목록
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
	<script type="text/javascript">
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").prop("checked",true);
			}else{
				$("input[name=chk]").prop("checked",false);
			}
		}
		function fn_Search(){
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}List.do'/>");
			$("#frm").submit();
		}
		
		//상세
		function fn_Detail(userId){
			
			$.ajax({
				type : 'get',
				url : '/admmgr/member/userView.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					if(data) {
						
						var appYn;
						
						if(data.APP_YN === "Y") {
							appYn = "승인";
						} else {
							appYn = "미승인";
						}
						
						$("#userId").text(data.USER_ID);
						$("#appYn").text(appYn);
						$("#userNm").text(data.USER_NM);
						$("#hpNo").text(data.HP_NO);
						$("#email").text(data.EMAIL);
						$("#phoneRecv").text(data.PHONE_RECV);
						$("#emailRecv").text(data.EMAIL_RECV);
						$("#birth").text(data.BIRTH);
						$("#zipNo").text(data.ZIP_NO);
						$("#addr").text(data.ADDR);
						$("#addrPt").text(data.ADDR_PT);
						$("#regDt").text(data.REG_DTM);
						$("#mdfDt").text(data.MDF_DTM);
						
						if(data.GENDER === "M") {
							$("#gender").text("남");	
						}else {
							$("#gender").text("여");
						}
						
						$(".btn_n_modi").show();
						$("#viewBody").show();
						$("#editBody").hide();
						$(".btn_n_save").hide();	
						
					}else {
						alert("실패");
					}
				},
				error : function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		
		//수정
		function fn_Update() {
			
			const userId = $("#userId").text();
			
			$.ajax({
				type : 'get',
				url : '/admmgr/member/userView.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					if(data) {
						const arrHpNo = data.HP_NO != null ? data.HP_NO.split("-") : [];
						const hpNo1 = arrHpNo[0];
						const hpNo2 = arrHpNo[1];
						const hpNo3 = arrHpNo[2];	
						const arrEmail = data.EMAIL != null ? data.EMAIL.split("@") : [];
						const email1 = arrEmail[0];
						const email2 = arrEmail[1];
						let appYn;
						
						if(data.APP_YN === "Y") {
							$("#appYn_Y").prop("checked", true);
						} else {
							$("#appYn_N").prop("checked", true);
						}
						
						$("#edit_userId").text(data.USER_ID);
						$("#edit_userNm").val(data.USER_NM);
						$("#hpNo1").val(hpNo1);
						$("#hpNo2").val(hpNo2);
						$("#hpNo3").val(hpNo3);
						$("input[name='phoneRecv'][value='"+data.PHONE_RECV+"']").prop('checked', true);
						$("#email1").val(email1);
						$("#email2").val(email2);
						$("input[name='emailRecv'][value='"+data.EMAIL_RECV+"']").prop('checked', true);
						$("#edit_birth").val(data.BIRTH);
						$("input[name='gender'][value='"+data.GENDER+"']").prop('checked', true);
						$("#edit_zipNo").val(data.ZIP_NO);
						$("#edit_addr").val(data.ADDR);
						$("#edit_addrPt").val(data.ADDR_PT);
						
						$("#editBody").show();
						$("#viewBody").hide();
						$(".btn_n_save").show();
						$(".btn_n_modi").hide();
					
					}else {
						alert("실패");
					}
				}, 
				error : function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
				}
			})
		}
		
		//수정 프로세스
		function fn_UpdateProc() {
			
			if( $("#edit_userNm").val().trim() == "" ){ 
	            alert("이름을 입력해주세요.");
	            $("#edit_userNm").focus();
	            return false;
	        }
			
			if( $("#hpNo1").val() == "" || $("#hpNo2").val() == "" || $("#hpNo3").val() == "" ){ 
	            alert("핸드폰번호를 입력해주세요.");
	            if( $("#hpNo1").val() == "" ){
	                $("#hpNo1").focus();
	            } else if( $("#hpNo2").val() == "" ){
	                $("#hpNo2").focus();
	            }else{
	                $("#hpNo3").focus();
	            }
	            return false;
	        }
			if( $("#hpNo2").val().length < 4 ){
	        	alert("휴대폰번호를 정확히 입력해주세요.");
	        	$("#hpNo2").focus();
	        	return false;
	        }
	        if( $("#hpNo3").val().length < 4 ){
	        	alert("휴대폰번호를 정확히 입력해주세요.");
	        	$("#hpNo3").focus();
	        	return false;
	        }
	        
	     	//이메일 유효성검사
	        if( $("#email1").val().trim() == "" || $("#email2").val().trim() == "" ){ 
	            alert("이메일을 입력해주세요.");
	            if( $("#email1").val().trim() == "" ){
	                $("#email1").focus();
	            }else if( $("#email2").val().trim() == "" ){
	                $("#email2").focus();
	            }
	            return false;
	        }
	        var email1_rule = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*$/;
        	var email2_rule = /^[a-zA-Z0-9]+([.-]?[a-zA-Z0-9]+)*\.[a-zA-Z]{2,6}$/;
        	var email1 = $("#email1").val();
        	var email2 = $("#email2").val();
        	
        	if( /[@]/.test(email1) || !email1_rule.test(email1) ) { //@포함하거나 규칙 통과(true)하지 못하면
        		alert("이메일을 정확히 입력해주세요.");
        		$("#email1").focus();
        		return false;
        	}
        	if( /[@]/.test(email2) || !email2_rule.test(email2) ) {
        		alert("이메일을 정확히 입력해주세요.");
        		$("#email2").focus();
        		return false;
        	}
			
        	if( $("#edit_addrPt").val().trim() == "" ){ 
	            alert("상세주소를 입력해주세요.");
	            $("#edit_addrPt").focus();
	            return false;
	        }
			
			let userTp = $("#userTp").val();
			const userId = $("#userId").text();
			const userNm = $("#edit_userNm").val().trim();
			$("#edit_hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
			const hpNo = $("#edit_hpNo").val();
			$("#edit_email").val($("#email1").val()+"@"+$("#email2").val());
			const email = $("#edit_email").val();
			const phoneRecv = $("input[name='phoneRecv']:checked").val();
			const emailRecv = $("input[name='emailRecv']:checked").val();
			const birth = $("#edit_birth").val();
			const gender = $("input[name='gender']:checked").val();
			const zipNo = $("#edit_zipNo").val();
			const addr = $("#edit_addr").val();
			const addrPt = $("#edit_addrPt").val().trim();
			
			let appYn = $("input[name='appYn']:checked").val();
			
			if(appYn == "Y") {
				userTp = "Eval";
			} else {
				userTp = "Basic";
			}

			if(confirm("저장하시겠습니까?")) {

				$.ajax({
					type : 'POST',
					url : '/admmgr/member/userUpdateProc.do',
					data : {
						userTp : userTp,
						userId : userId,
						userNm : userNm,
						hpNo :	hpNo,
						email :	email,
						phoneRecv : phoneRecv,
						emailRecv : emailRecv,
						birth : birth,
						gender : gender,
						zipNo : zipNo,
						addr : addr,
						addrPt : addrPt,
						appYn : appYn
						},
					success : function(data) {
						if(data === "OK") {
							alert("저장되었습니다.");
							location.reload();
						}else {
							alert("실패");
						}
					},
					error : function(request,status,error){
						alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
					}
				})
			}
		}
		
		//등록
		/* function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}Regist.do'/>");
			$("#frm").submit();
		} */
		//삭제
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
				$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}DeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		// 엑셀 다운로드
		function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/user${userTp}Down.do'/>");
			$("#frm").submit();
		}
		
		function fn_Rejection() {
			if(!confirm) {
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}RejectionProc.do'/>");
			$("#frm").append("<input type='hidden' name='edit_userId' value='" + $("#edit_userId").text() + "'>");
			$("#frm").submit();
		}
		
		$(document).ready(function() {
			
			// record_cnt
			var record_cnt = $('#record_cnt').val();
			$('#record_' + record_cnt).attr('checked','checked');
			
			if ( record_cnt != '' ) {
				$(".btn2_ty3 + em img").attr("src", "/common/admmgr/images/sub_common/btn_close1.png");
		        $(".radio").show();
		    }
			
			$("input[name='record_cnt']").change(function() {
	            // 체크된 체크박스의 수를 확인합니다.
	            var chkRadio = $("input[name='record_cnt']:checked");

	            // 체크박스가 선택된 경우 폼을 제출합니다.
	            if (chkRadio.length > 0) {
	            	$("#record_cnt").val($(this).val());
	                $("#frm").attr("action", "<c:url value='/admmgr/member/user${userTp}List.do'/>");
	                $("#frm").submit();
	            }
	        });
			
			//EnterKey
			$("#searchword").on("keydown",function(key){
		        if( key.keyCode == 13 ){
		        	fn_Search();
		        }
		    });
			
		});
	</script>
</head>
<body>
<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>

<form id="frm" name="frm" method="POST">
	<input type="hidden" id="siteCd" name="siteCd" value="001000000000000"/>
	<input type="hidden" id="userTp" name="userTp" value="${userTp}"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${ record_cnt }"/>
	<!-- 전체 레이아웃을 flex로 -->
	<div class="listview_grid_wrap">
		<!-- list_grid_wrap -->
		<div class="list_grid_wrap wd760">
			<!--sub_contents_area-->
			<div class="sub_contents_area">
			
			<!-- 타이틀 -->
			<h4 class="sub_tit_h4">
				<c:choose>
					<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><em>일반 회원 목록</em></c:when>
					<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><em>연구자 회원 목록</em></c:when>
					<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><em>평가회원 회원 목록</em></c:when>
				</c:choose>
			</h4>
			<!-- 타이틀 -->

			<!-- 검색 -->
			<div class="search_form_wrap mb15">
				<div class="search_form_inner">
					<div class="filter_form">
						<div>
							<label>검색조건</label>
							<select id="searchfield" name="searchfield" class="form_select" title="검색조건 선택">
								<option value="ALL">전체</option>
								<option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option>
								<option value="USER_NM" ${ param.searchfield eq 'USER_NM' ? "selected='selected'" : "" }>이름</option>
							</select>
							<input type="text" id="searchword" name="searchword" class="form_text" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
						</div>

						<div>
							<label>등록일자</label>
							<div>
								<span class="form_date">
									<input type="text" id="s_date_start" name="s_date_start" placeholder="시작일 입력" class="form_text wd140" value="<c:out value="${param.s_date_start}"/>" onclick="calendar(event,'s_date_start','yyyy-mm-dd')">
									<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_start').trigger('click');">
								</span>
								~
								<span class="form_date">
									<input type="text" id="s_date_end" name="s_date_end" placeholder="종료일 입력" class="form_text wd140" value="<c:out value="${param.s_date_end}"/>" onclick="calendar(event,'s_date_end','yyyy-mm-dd')" >
									<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_end').trigger('click');">
								</span>
							</div>
						</div>

						<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
					</div>
				</div>
			</div>
			<!-- // 검색 -->

			<!-- 상단 정보 -->
			<div class="table_header flx jc_between mb5">
				<div class="lft">
					<!-- record_cnt -->
					<label for="record_10" class="form_chip md"><input type="radio" id="record_10" name="record_cnt" value="10"><span>10개</span></label>
					<label for="record_30" class="form_chip md"><input type="radio" id="record_30" name="record_cnt" value="30"><span>30개</span></label>
					<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt" value="50"><span>50개</span></label>
					<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt" value="100"><span>100개</span></label>
					<!-- // record_cnt -->
				</div>

				<div class="rgt">
					<a class="btn_icon ico_xls sm" href="javascript:void(0);" onclick="javascript:fn_excelDown()">
						<i class="ico"><img src="/common/admmgr/images/icon/ico_xlsx02.svg" alt="엑셀"></i>
						<!-- <em>엑셀 다운로드</em> -->
					</a>
				</div>
				
			</div>
			<!-- 상단 정보 -->
					

			<!-- 리스트 -->
			<div class="n_table_sty01 n_list01">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
					<colgroup>
						<col width="3%"/>
						<col width="5%"/>
						<col width="10%"/>
						<col width="8%"/>
						<col width="9%"/>
						<c:if test="${userTp eq 'Basic' || userTp eq 'Eval'}">
							<col width="9%"/>
						</c:if>
					</colgroup>
					<thead>
						<tr>
							<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
							<th class="center"><span>번호</span></th>
							<th class="center"><span>아이디</span></th>
							<th class="center"><span>이름(국문)</span></th>
							<c:if test="${userTp eq 'Basic' || userTp eq 'Eval'}">
								<th class="center"><span>평가위원 승인여부</span></th>
							</c:if>
							<th class="center"><span>가입일시</span></th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${rList}" var="rList" varStatus="status">
							<tr>
								<td><input type="checkbox" name="chk" value="<c:out value="${rList.USER_ID}"/>"/></td>
								<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
								<%-- <td><fmt:formatNumber value="${rList.RNUM}" groupingUsed="true"/></td> --%>
								<td class="center"><a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.USER_ID}');"><c:out value="${rList.USER_ID}"/></a></td>
								<td class="center"><a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.USER_ID}');"><c:out value="${rList.USER_NM}"/></a></td>
								<%--
								<td><a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.USER_ID}');"><c:out value="${rList.USER_ENG_NM}"/></a></td>
								--%>
								<c:if test="${userTp eq 'Basic' || userTp eq 'Eval'}">
									<td class="center">
										<c:choose>
											<c:when test="${rList.APP_YN eq 'Y'}">
												<span class="av_link av_green center">승인</span>
											</c:when>
											<c:otherwise>
												<span class="av_link av_red center">미승인</span>
											</c:otherwise>
										</c:choose>
									</td>
								</c:if>
								<td class="center"><c:out value="${rList.REG_DTM}"/></td>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="10">등록된 회원이 없습니다.</td></tr></c:if>
					</tbody>
				</table>
			</div>
			<!-- 리스트 -->
			
			<!-- table_footer -->
			<div class="table_footer">
				<div class="btn_wrap lft">
					<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
				</div>

				<div class="pagination_wrap">
					<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
				</div>

				<div class="btn_wrap rgt">
					<!-- <a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a> -->
				</div>
			</div>
			<!-- // table_footer -->

			

			</div>
			<!-- //sub_contents_area -->

		</div>
		<!-- // list_grid_wrap -->

		<!-- view_grid_wrap : 우측 상세정보 영역 -->
		<div id="detail_info" class="view_grid_wrap">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">일반회원 정보 상세</h6>
			</div>
			<!-- // table_header -->

			<div class="table_wrap n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="13%"/>
						<col width="37%"/>
						<col width="13%"/>
						<col width="37%"/>
					</colgroup>
					<tbody id="viewBody">
						<tr>
							<th>
								아이디
								<!-- <div class="tooltip">
									<button class="tooltip_icon"></button>
									<div class="tooltip_inner">
										<div class="tooltip_con">
											아이디는 수정할 수 없습니다. 
										</div>
										<button class="tooltip_close"></button>
										<span class="tooltip_arrow"></span>
									</div>
								</div> -->
							</th>
							<%-- <c:choose>
								<c:when test="${userTp eq 'Basic'}">
									<td colspan="3" id="userId"></td>
								</c:when>
								<c:otherwise> --%>
									<td id="userId"></td>
									<th>평가위원 승인여부</th>
									<td id="appYn"></td>
								<%-- </c:otherwise>
							</c:choose> --%>
						</tr>
						<tr>
							<th>이름(국문)</th>
							<td colspan="3" id="userNm"></td>
						</tr>
						
						<tr>
							<th>핸드폰번호</th>
							<td id="hpNo"></td>
							<th>이메일</th>
							<td id="email"></td>
							
						</tr>
						<tr>
							<th>SMS 수신여부</th>
							<td id="phoneRecv"></td>
							<th>이메일 수신여부</th>
							<td id="emailRecv"></td>
						</tr>
						<tr>
							<th>생년월일</th>
							<td id="birth"></td>
							<th>성별</th>
							<td id="gender"></td>
						</tr>
						<tr>
							<th>우편번호</th>
							<td colspan="3" id="zipNo"></td>
						</tr>
						<tr>
							<th>주소</th>
							<td colspan="3" id="addr"></td>
						</tr>
						<tr>
							<th>상세주소</th>
							<td colspan="3" id="addrPt"></td>
						</tr>
						<tr>
							<th>가입일</th>
							<td id="regDt"></td>
							<th>수정일</th>
							<td id="mdfDt"></td>
						</tr>
					</tbody>
					
					<!-- 수정 -->
					<tbody id="editBody" style="display: none;">
						<tr>
							<th>아이디 <em class="c_red" style="background: none;">*</em></th>
							<%-- <c:choose>
								<c:when test="${userTp eq 'Basic'}">
									<td colspan="3" class="left" id="edit_userId"></td>
								</c:when>
								<c:otherwise> --%>
									<td class="left" id="edit_userId"></td>
									<th>평가위원 승인여부</th>
									<td class="left">
										<label><input type="radio" id="appYn_Y" name="appYn" value="Y">승인</label>
										<label><input type="radio" id="appYn_N" name="appYn" value="N">미승인</label>
										<%-- <c:if test="${userTp eq 'Basic'}">
											<span style="float: right;">
												<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Rejection();"><span>거절</span></a>
											</span>
										</c:if> --%>
									</td>
								<%-- </c:otherwise>
							</c:choose> --%>
						</tr>
						<tr>
							<th>이름(국문) <em class="c_red" style="background: none;">*</em></th>
							<td colspan="3"><input type="text" class="form_text wd100" id="edit_userNm" name="edit_userNm" maxlength="50"/></td>
						</tr>
						<tr>
							<th>핸드폰번호 <em class="c_red" style="background: none;">*</em></th>
							<td>
								<div>
									<input type="hidden" id="edit_hpNo" name="edit_hpNo"/>
									<select id="hpNo1" name="hpNo1" title="선택" class="form_select wd70">
										<option value="">선택</option>
										<option value="010">010</option>
										<option value="011">011</option>
										<option value="016">016</option>
										<option value="017">017</option>
										<option value="018">018</option>
										<option value="019">019</option>
									</select>
									<span class="m"> - </span>
									<input type="text" id="hpNo2" name="hpNo2" class="form_text wd70" placeholder="" maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
									<span class="m"> - </span>
									<input type="text" id="hpNo3" name=hpNo3 class="form_text wd70" placeholder="" maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
								</div>
								<div class="mt5">
									<label for="phoneRecv_Y" class="ch"><input type="radio" id="phoneRecv_Y" name="phoneRecv" value="Y"><span>SMS 수신</span></label>
									<label for="phoneRecv_N" class="ch"><input type="radio" id="phoneRecv_N" name="phoneRecv" value="N"><span>SMS 수신안함</span></label>
								</div>
							</td>
							<th>이메일 <em class="c_red" style="background: none;">*</em></th>
							<td>
								<div>
									<input type="hidden" id="edit_email" name="edit_email"/>
									<input type="text" class="form_text wd120" id="email1" name="email1" maxlength="50"/>
									<span class="m"> @ </span>
									<input type="text" class="form_text wd100" id="email2" name="email2" maxlength="50"/>
								</div>

								<div class="mt5">
									<label for="emailRecv_Y" class="ch"><input type="radio" id="emailRecv_Y" name="emailRecv" value="Y"><span>이메일 수신</span></label>
									<label for="emailRecv_N" class="ch"><input type="radio" id="emailRecv_N" name="emailRecv" value="N"><span>이메일 수신안함</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>생년월일<em class="c_red" style="background: none;">*</em></th>
							<td>
								<span class="form_date">
									<input type="text" id="edit_birth" name="edit_birth" placeholder="시작일 입력" class="form_text wd200" onclick="calendar(event,'edit_birth','yyyy-mm-dd')" readonly>
									<input type="button" class="btn_form_date" onclick="javascript:$('#edit_birth').trigger('click');">
								</span></br>
								<em  class="c_sky">* ex) 1998-01-23</em>
							</td>
							<th>성별<em class="c_red" style="background: none;">*</em></th>
							<td>
								<div>
									<label for="gender_M" class="ch"><input type="radio" id="gender_M" name="gender" value="M"><span>남자</span></label>
									<label for="gender_F" class="ch"><input type="radio" id="gender_F" name="gender" value="F"><span>여자</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>우편번호<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="edit_zipNo" name="edit_zipNo" class="form_text min_w70" readonly="readonly">
								<a href="javascript:void(0);" onclick="openPost('edit_zipNo','edit_addr')" class="btn secondary xsm"><span>주소검색</span></a>
							</td>
						</tr>
						<tr>
							<th>주소<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="edit_addr" name="edit_addr" class="form_text w100" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th>상세주소<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="edit_addrPt" name="edit_addrPt" class="form_text w100">
							</td>
						</tr>
					</tbody>
					<!-- // 수정 -->
				</table>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Update();" style="display: none;"><span>수정</span></a>
					<a class="btn_n_save" href="javascript:fn_UpdateProc();" style="display: none;"><span>저장</span></a>
				</div>
			</div>
		</div>
		<!-- // view_grid_wrap : 우측 상세정보 영역 -->
	</div>

</form>
</body>