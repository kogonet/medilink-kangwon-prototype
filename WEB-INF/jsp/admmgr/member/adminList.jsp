<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 관리자 목록
 **************************************************/
%>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript">
		
		var user_Id = "";
		
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").attr("checked",true);
			}else{
				$("input[name=chk]").attr("checked",false);
			}
		}
		function fn_Search(){
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/member/adminList.do'/>");
			$("#frm").submit();
		}
		
		//상세 정보
		function fn_Detail(userId) {

			$.ajax({
				type : 'get',
				url : '/admmgr/member/adminView.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					if(data.rMap) {
						const rMap = data.rMap;
						
						document.getElementById("userId").textContent = rMap.USER_ID;	
						document.getElementById("authNm").innerText = rMap.AUTH_NM;	
						document.getElementById("userNm").textContent = rMap.USER_NM;	
						document.getElementById("regDtm").textContent = rMap.REG_DTM;	
						document.getElementById("hpNo").textContent = rMap.HP_NO;	
						document.getElementById("email").textContent = rMap.EMAIL;	
						document.getElementById("phoneRecv").textContent = rMap.PHONE_RECV;	
						document.getElementById("emailRecv").textContent = rMap.EMAIL_RECV;	
						
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
			})
		}
		
		//수정
		function fn_Update(){
			const userId = document.getElementById("userId").innerText;
			
			$.ajax({
				type : 'get',
				url : '/admmgr/member/adminView.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					if(data.rMap) {
						const rMap = data.rMap;
						const arrHpNo = rMap.HP_NO != null ? rMap.HP_NO.split('-') : [];
						const hpNo1 = arrHpNo[0];
						const hpNo2 = arrHpNo[1];
						const hpNo3 = arrHpNo[2];
						const arrEmail = rMap.EMAIL != null ? rMap.EMAIL.split("@") : [];
						const email1 = arrEmail[0];
						const email2 = arrEmail[1];
						
						document.getElementById("edit_userId").textContent = rMap.USER_ID;	
						document.getElementById("edit_userNm").value = rMap.USER_NM;	
						$("#email1").val(email1);
						$("#email2").val(email2);	
						document.getElementById("hpNo1").value = hpNo1;	
						document.getElementById("hpNo2").value = hpNo2;	
						document.getElementById("hpNo3").value = hpNo3;		

						if(rMap.EMAIL_RECV === "Y") {
							document.getElementById("emailRecv_Y").checked = true;
						} else {
							document.getElementById("emailRecv_N").checked = true;
						}

						if(rMap.PHONE_RECV === "Y") {
							document.getElementById("phoneRecv_Y").checked = true;
						} else {
							document.getElementById("phoneRecv_N").checked = true;
						}
						
						const rList = data.rList;
						//이전 html 중복방지
						$("#authCd").empty();
						
						rList.forEach(function(item) {
							const isSelected = item.AUTH_NM === rMap.AUTH_NM ? 'selected' : "";
							const option = `<option value="`+item.AUTH_CD+`" `+isSelected+`>`+item.AUTH_NM+`</option>`;
							$("#authCd").append(option);
						})
						
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
			
			const userId = $("#userId").text();
			const authCd = $("#authCd").val();
			const userNm = $("#edit_userNm").val().trim();
			$("#edit_hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
			const hpNo = $("#edit_hpNo").val();
			$("#edit_email").val($("#email1").val()+"@"+$("#email2").val());
			const email = $("#edit_email").val();
			const phoneRecv = $("input[name='phoneRecv']:checked").val();
			const emailRecv = $("input[name='emailRecv']:checked").val();

			if(confirm("저장하시겠습니까?")) {

				$.ajax({
					type : 'POST',
					url : '/admmgr/member/adminUpdateProc.do',
					data : {
						userId : userId,
						authCd : authCd,
						userNm : userNm,
						hpNo :	hpNo,
						email :	email,
						phoneRecv : phoneRecv,
						emailRecv : emailRecv
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

		//로그인 로그
		function fn_LoginLog(userId) {
			user_Id = userId;

			$.ajax({
				type : 'get',
				url : '/admmgr/member/adminLoginLog.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					var html = "";
					
					if(data.rList.length > 0) {
						const rList = data.rList;
						const pagingNum = data.pagingNum;
						const pagingHtml = data.pagingHtml;
						$("#loginLogPageList").html(pagingHtml);
						
						rList.forEach(function(item, index) {
							const itemNumber = pagingNum - index;

							html += 
								`
									<tr>
										<td class="center pl0">`+itemNumber+`</td>
										<td class="left pl20">
											<span style="color:blue; font-weight:bold;"><c:out value="`+item.USER_NM+`"/>(<c:out value="`+item.USER_ID+`"/>)</span>님
											<span style="color:orange; font-weight:bold;">[ <c:out value="`+item.REG_DT+`"/> ]</span>에 
											<span style="color:#ac00d5; font-weight:bold;"><c:out value="`+item.ACT+`"/></span>
											을(를) 수행함
										</td>
										<td class="center"><c:out value="`+item.USER_IP+`"/></td>
										<td class="center"><c:out value="`+item.USER_DV+`"/></td>
										<td class="center"><c:out value="`+item.USER_BR+`"/></td>
									</tr>
								`;
						});
						
					}else {
						html += 
							`
								<tr class="center"><td colspan="5">접속 이력이 없습니다.</td></tr>
							`
					}
					$("#loginLogBody").html(html);
				}, 
				error : function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		
		//로그인 로그 페이지 클릭
		function G_MoveLoginLogPage(page) {
			$.ajax({
				type : 'POST', //POST
				url : '/admmgr/member/adminLoginLog.do',
				data : {userId : user_Id, page : page},
				dataType : 'json',
				success : function(data) {
					var html = "";
					
					if(data.rList.length > 0) {
						const rList = data.rList;
						const pagingNum = data.pagingNum;
						const pagingHtml = data.pagingHtml;
						$("#loginLogPageList").html(pagingHtml);
						
						rList.forEach(function(item, index) {
							const itemNumber = pagingNum - index;

							html += 
								`
									<tr>
										<td class="center pl0">`+itemNumber+`</td>
										<td class="left pl20">
											<span style="color:blue; font-weight:bold;"><c:out value="`+item.USER_NM+`"/>(<c:out value="`+item.USER_ID+`"/>)</span>님
											<span style="color:orange; font-weight:bold;">[ <c:out value="`+item.REG_DT+`"/> ]</span>에 
											<span style="color:#ac00d5; font-weight:bold;"><c:out value="`+item.ACT+`"/></span>
											을(를) 수행함
										</td>
										<td class="center"><c:out value="`+item.USER_IP+`"/></td>
										<td class="center"><c:out value="`+item.USER_DV+`"/></td>
										<td class="center"><c:out value="`+item.USER_BR+`"/></td>
									</tr>
								`;
						});
						
					}else {
						html += 
							`
								<tr class="center"><td colspan="5">접속 이력이 없습니다.</td></tr>
							`
					}
					$("#loginLogBody").html(html);
				}, 
				error : function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
				}
			});
		} 
		
		//등록
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/member/adminRegist.do'/>");
			$("#frm").submit();
		}
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
				$("#frm").attr("action","<c:url value='/admmgr/member/adminDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		// 엑셀 다운로드
		function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/adminListDown.do'/>");
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
	                $("#frm").attr("action", "<c:url value='/admmgr/member/adminList.do'/>");
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

<form id="frm" name="frm" method="GET">
<input type="hidden" id="record_cnt" name="record_cnt" value="${ record_cnt }"/>
<!-- 전체 레이아웃을 flex로 -->
<div class="listview_grid_wrap">
	<!--list_grid_wrap-->
	<div class="list_grid_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">

			<!-- 검색 -->
			<div class="search_form_wrap mb15">
				<div class="search_form_inner">
					<div class="filter_form">
						<div>
							<label>검색조건</label>
							<select id="searchfield" name="searchfield" class="form_select" title="조건 선택">
								<option value="ALL">전체</option>
								<option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option>
								<option value="USER_NM" ${ param.searchfield eq 'USER_NM' ? "selected='selected'" : "" }>이름</option>
								<%-- <option value="DEPT_NM" ${ param.searchfield eq 'DEPT_NM' ? "selected='selected'" : "" }>부서</option> --%>
							</select>
							<input type="text" id="searchword" name="searchword" class="form_text" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
						</div>
					</div>
					<input type="button" src="<c:url value='/common/admmgr/images/sub_common/btn_search.png'/>" class="btn_ico_search" alt="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
			<!-- // 검색 -->

			<!-- 상단 정보 -->
			<div class="table_header mb5">
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
			
			<div class="n_table_sty01 n_list01">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
					<colgroup>
						<col width="3%"/>
						<col width="5%"/>
						<col width="10%"/>
						<col width="*"/>
						<col width="10%"/>
						<%-- <col width="10%"/> --%>
						<col width="10%"/>
					</colgroup>
					<thead>
						<tr>
							<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
							<th class="center"><span>번호</span></th>
							<th class="center"><span>권한</span></th>
							<th class="center"><span>아이디</span></th>
							<th class="center"><span>이름</span></th>
							<!-- <th scope="col">부서</span></th> -->
							<th class="center"><span>마지막접속일</span></th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${rList}" var="rList" varStatus="status">
							<tr>
								<td><input type="checkbox" name="chk" id="chk" value="<c:out value="${rList.USER_ID}"/>"/></td>
								<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
								<td class="center"><c:out value="${str:getReverseXSS(rList.AUTH_NM)}"/></td>
								<td class="center" class="lft_td">
									<a href="javascript:fn_Detail('<c:out value="${rList.USER_ID}"/>'); fn_LoginLog('<c:out value="${rList.USER_ID}"/>');">
										<c:out value="${str:getReverseXSS(rList.USER_ID)}"/>
									</a>
								</td>
								<td class="center"><c:out value="${str:getReverseXSS(rList.USER_NM)}"/></td>
								<%-- <td class="center"><c:out value="${str:getReverseXSS(rList.DEPT_NM)}"/></td> --%>
								<td class="center"><c:out value="${rList.LAST_CONN_DTM}"/></td>
							</tr>
						</c:forEach>
						<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="8">등록된 관리자가 없습니다.</td></tr></c:if>
					</tbody>
				</table>
			</div>
			

			<!-- table_footer -->
			<div class="table_footer">
				<div class="btn_wrap lft">
					<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
				</div>

				<div class="pagination_wrap">
					<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
				</div>
				
				<div class="btn_wrap rgt">
					<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
				</div>

			</div>
			<!-- // table_footer -->
		

		</div>
		<!--// sub_contents_area-->
	</div>
	<!-- // list_grid_wrap -->

	<!-- view_grid_wrap -->
	<div id="detail_info" class="view_grid_wrap">
		<!-- table_header -->
		<div class="box_tit">
			<h6 class="title">관리자 정보 상세</h6>
		</div>
		<!-- // table_header -->

		<div class="n_table_sty01 n_view01">
			<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
				<caption>관리자 정보 상세</caption>
				<colgroup>
					<col width="13%">
					<col width="37%">
					<col width="13%">
					<col width="37%">
				</colgroup>
				<!-- 상세 -->
				<tbody id="viewBody">
					<tr>
						<th>권한</th>
						<td class="left" id="authNm"></td>
						<th>아이디</th>
						<td class="left" id="userId"></td>
					</tr>
					<tr>
						<th>이름(한글)</th>
						<td class="left" id="userNm"></td>
						<th>등록일시</th>
						<td colspan="3" class="left" id="regDtm"></td>
					</tr>
					<tr>
						<th>핸드폰</th>
						<td class="left" id="hpNo"></td>
						<th>이메일</th>
						<td class="left" id="email"></td>
					</tr>
					<tr>
						<th>SMS 수신여부</th>
						<td id="phoneRecv"></td>
						<th>이메일 수신여부</th>
						<td id="emailRecv"></td>
					</tr>
				</tbody>
				<!-- 수정 -->
				<tbody id="editBody" style="display: none;">
					<tr>
						<th>권한 <em class="c_red" style="background: none; width: auto;">*</em></th>
						<td>
							<select id="authCd" name="authCd" class="form_select wd200">
							</select>
						</td>
						<th>아이디 <em class="c_red" style="background: none; width: auto;">*</em></th>
						<td class="left" id="edit_userId"></td>
					</tr>
					<tr>
						<th>이름(한글) <em class="c_red" style="background: none; width: auto;">*</em></th>
						<td class="left">
									<input type="text" class="form_text" id="edit_userNm" name="edit_userNm" />
						</td>
						<th>이메일</th>
						<td class="left">
							<div>
								<input type="hidden" id="edit_email" name="edit_email"/>
								<input type="text" class="form_text wd100" id="email1" name="email1" maxlength="50"/>
								<span class="m"> @ </span>
								<input type="text" class="form_text wd100" id="email2" name="email2" maxlength="50"/>
							</div>
							<div class="mt5">
								<label for="emailRecv_Y" class="ch"><input type="radio" id="emailRecv_Y" name="emailRecv" value="Y" ><span>이메일 수신</span></label>
								<label for="emailRecv_N" class="ch"><input type="radio" id="emailRecv_N" name="emailRecv" value="N" ><span>이메일 수신안함</span></label>
							</div>
						</td>
					</tr>
					<tr>
						<th>핸드폰번호</th>
						<td class="left" colspan="3">
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
								<span>-</span>
								<input type="text" class="form_text wd70" id="hpNo2" name="hpNo2" maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9-]/g,'');"/>
								<span>-</span>
								<input type="text" class="form_text wd70" id="hpNo3" name="hpNo3" maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9-]/g,'');"/>
							</div>
							<div class="mt5">
								<label for="phoneRecv_Y" class="ch" ><input type="radio" id="phoneRecv_Y" name="phoneRecv" value="Y"><span>SMS 수신</span></label>
								<label for="phoneRecv_N" class="ch"><input type="radio" id="phoneRecv_N" name="phoneRecv" value="N"><span>SMS 수신안함</span></label>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</div>

		<!-- page_btn_wrap -->
		<div class="page_btn_wrap jc_between mt20">
			<div class="lft"></div>
			<div class="rgt">
				<a class="btn_n_modi" href="javascript:fn_Update();" style="display: none;"><span>수정</span></a>
				<a class="btn_n_save" href="javascript:fn_UpdateProc();" style="display: none;"><span>저장</span></a>
			</div>
		
		</div>
		<!-- // page_btn_wrap -->
		
		<!-- 로그인 로그 -->
		<!-- 리스트 -->	
		<div class="box_tit">
			<h6 class="title">접속이력</h6>
		</div>
		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="7%"/>
					<col width="*"/>
					<col width="10%"/>
					<col width="7%"/>
					<col width="10%"/>
				</colgroup>
				<thead>
					<tr>
						<th class="center pr30">번호</th>
						<th class="center"><span>로그</span></th>
						<th class="center"><span>접속 IP</span></th>
						<th class="center"><span>접속 환경</span></th>
						<th class="center"><span>접속 브라우저</span></th>
					</tr>
				</thead>
				<tbody id="loginLogBody">
					<tr class="center"><td colspan="5">접속 이력이 없습니다.</td></tr>
				</tbody>
			</table>
		</div>
		<!-- 리스트 -->
		
		<!-- table_footer -->
		<div class="table_footer">
			<div class="pagination_wrap">
				<div id="loginLogPageList"></div>
			</div>
		</div>
		<!-- // table_footer -->
		<!--// 로그인 로그 -->
	</div>
	<!-- // view_grid_wrap -->
</div>
<!-- main-container -->
</form>
</body>