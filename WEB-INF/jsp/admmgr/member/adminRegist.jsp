<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 관리자 등록/수정
 **************************************************/
%>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript">
	
		// 직원 정보 팝업
		function fn_findEmp() {
			window.open("<c:url value='/admmgr/manage/board/findEmpLayer.do'/>","담당자 정보 팝업","width=1000,height=800,top=50%,left=50%,location=no")
		}
		
		// 선택한 직원 값 넘기기
		function fn_addEmp(seq, userNm, email, posiNm, deptNm) {
		    document.getElementById("seq").value = seq;
		    document.getElementById("userNm").value = userNm;
		    document.getElementById("userNm").readOnly = true;
		    document.getElementById("email").value = email;
		    document.getElementById("email").readOnly = true;
		    document.getElementById("posiNm").value = posiNm;
		    document.getElementById("posiNm").readOnly = true;
		    document.getElementById("deptNm").value = deptNm;
		    document.getElementById("deptNm").readOnly = true;
		}
		//이메일 유효성 체크
		function fn_VerificationEmail(email){
			var regEmail = /([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
			if( !regEmail.test(email) ){
	            return false;
	        }
			return true;
		}
		//아이디 중복검사
		var duplYn = true;
		function fn_CheckDupl(obj){
			if ( $(obj).text() == '다시검색' ) {
				duplYn = true;
				$("#userId").prop("readonly", "");
				$(obj).text("중복체크");
				return false;
			}
			if( $("#userId").val() == "" ){
				alert("아이디를 입력해 주세요.");
				$("#userId").focus();
				return false;
			}
			
			if( $("#userId").val() != "" ){
				var limitStartCnt = 4;
	            var limitEndCnt = 12;
	            var userId = $("#userId").val();
	            var id = $("#userId").val().split(" ").join("");
	            var num = id.search(/[0-9]/g);
	            var eng = id.search(/[a-z]/ig);
	            var spe = id.search(/^.*(?=.*[!@#$%^&+=]).*$/);
	            //글자수 제한
	            if( id.length < limitStartCnt || id.length > limitEndCnt ){
	                alert("아이디는 " + limitStartCnt + "자리에서 " + limitEndCnt + "자리 이하로 입력해 주세요.");
	                $("#userId").focus();
	                return false;
	            }
	            //공백 제한
	            if( userId.search(/\s/g) != -1 ){
	                alert("아이디에 공백을 사용하실 수 없습니다.");
	                $("#userId").focus();
	                return false;
	            }
	            //한글,특수문자 제한
	            if( spe > -1 || id.search(/[ㄱ-ㅎ]/g) > -1 || id.search(/[가-힣]/g) > -1 ){
	                alert("아이디는 한글 또는 특수문자를 사용하실 수 없습니다.");
	                $("#userId").focus();
	                return false;
	            }
			}
			
			$.ajax({
				type		:"POST",
				url			:"<c:url value='/admmgr/member/adminDuplCheckAjax.do'/>",
				data		:{"userId":$("#userId").val()},
				dataType	:"text",
				success		:function(rData){
					onebtnchk=0;
					if( rData == "OK" ){
						if( confirm("사용할 수 있는 아이디입니다.\n사용하시겠습니까?") ){
							duplYn = false;
							$("#userId").prop("readonly", "readonly");
							$(obj).text("다시검색");
						}
					}else{
						alert("해당 아이디는 사용할 수 없습니다.");
						duplYn = true;
					}
				},
				error:function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/member/adminList.do'/>");
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			if( $("#userId").val() == "" ){
	            alert("아이디를 입력해 주세요.");
	            $("#userId").focus();
	            return false;
	        }
	        if( $("#preUserId").val() == "" ){
	        	if( duplYn ){
		            alert("아이디 중복검사를 진행해 주세요.");
		            $("#userIdBtn").focus();
		            return false;
		        }
				if( $("#userNm").val() == "" ){
					alert("성명을 입력해 주세요.");
					$("#userNm").focus();
					return false;
				}
	        }
			
	        if( $("#hpNo1").val() != "" || $("#hpNo2").val() != "" || $("#hpNo3").val() != "" ) {
	        	if( $("#hpNo1").val().length < 3 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo1").focus();
	        		return false;
	        	}
	        	if( $("#hpNo2").val().length < 4 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo2").focus();
	        		return false;
	        	}
	        	if( $("#hpNo3").val().length < 4 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo3").focus();
	        		return false;
	        	}
	        	
		        for(let i=1; i<4; i++) {
		        	if( $("#hpNo"+i).val() == "" ) {
		        		alert("핸드폰 번호를 정확히 입력해주세요.");
		        		$("#hpNo"+i).focus();
		        		return false;
		        	}
		        }
		        
		        if( $("#userId").val() != "" ) {
		        	if( !$("input[name=smsYn]").is(":checked") ) {
			        	alert("SMS 수신여부를 선택해주세요.");
			        	return false;
			        }
		        }
	        }
	        
	        if( $("#email").val() != "" ) {
	        	if( !$("input[name=emailYn]").is(":checked") ) {
		        	alert("이메일 수신여부를 선택해주세요.");
		        	return false;
		        }
	        }
	        
			if( $("#userPw").val() != "" || $("#preUserId").val() == "" ){
				if( $("#userPw").val() == "" ){
		            alert("비밀번호를 입력해 주세요.");
		            $("#userPw").focus();
		            return false;
		        }

				if( $("#userPw").val() != "" ){
		            var limitStartCnt = 8;
		            var limitEndCnt = 20;
		            var userPw = $("#userPw").val();
		            var pw = $("#userPw").val().split(" ").join("");
		            var num = pw.search(/[0-9]/g);
		            var eng = pw.search(/[a-z]/ig);
		            var spe = pw.search(/^.*(?=.*[~!@#$%^&*()_+-=`~,.;<>?|]).*$/g);
		            //var spe = pw.search(/^.*(?=.*[!@#$%^&+=]).*$/);
		            //글자수 제한
		            if( pw.length < limitStartCnt || pw.length > limitEndCnt ){
		                alert("비밀번호는 " + limitStartCnt + "자리에서 " + limitEndCnt + "자리 이하로 입력해 주세요.");
		                $("#userPw").focus();
		                return false;
		            }
		          //공백 제한
		            if( userPw.search(/\s/g) != -1 ){
		                alert("비밀번호는 공백없이 입력해 주세요.");
		                $("#userPw").focus();
		                return false;
		            }
		            //영문,숫자,특수문자 혼용
		            if( num < 0 || eng < 0 || spe < 0 ){
		                alert("영문,숫자,특수문자를 혼합하여 입력해 주세요.");
		                $("#userPw").focus();
		                return false;
		            }
		            
		            if( $("#userPwConfirm").val() == "" ){
		                alert("비밀번호 확인을 입력해 주세요.");
		                $("#userPwConfirm").focus();
		                return false;
		            }
		            if( $("#userPwConfirm").val() != "" ){
			            if( $("#userPw").val() != $("#userPwConfirm").val() ){
			                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
			                $("#userPwConfirm").focus();
			                return false;
			            }
			        }
		        }
			}

			if( $("#hpNo1").val() != "" && $("#hpNo2").val() != "" && $("#hpNo3").val() != "" ){
				$("#hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
			}
			
			//대시보드 값 전송
			const selectBoxes = document.getElementsByClassName('form_select md w100');
			let selectedValues = [];
			
			for(let i=0 ; i<selectBoxes.length ; i++) {
				//항목 순서대로 선택하기
				if(i+1<selectBoxes.length && selectBoxes[i+1].value !== "" && selectBoxes[i].value === "") { 
					alert("대시보드 항목을 순서대로 선택하세요.");
					return false; 
				}

				if(selectBoxes[i].value !== "") {
					//항목 중복선택 불가
					if(selectedValues.includes(selectBoxes[i].value)) {
						alert("대시보드 항목을 중복 선택할 수 없습니다.");
						return false;
					}
					
					selectedValues.push(selectBoxes[i].value);
				}
			}
			$("#dashboard").val(selectedValues);

			$("#frm").attr("action","<c:url value='/admmgr/member/adminRegistProc.do'/>");
			$("#frm").submit();
		}

		$(document).ready(function(){
			// 이메일 수신여부
			if(${rMap.EMAIL_RECV eq "Y"}) {
				$("#emailYn_Y").prop("checked","checked");
			}
			if(${rMap.EMAIL_RECV eq "N"}) {
				$("#emailYn_N").prop("checked","checked");
			}
			// sms 수신여부
			if(${rMap.PHONE_RECV eq "Y"}) {
				$("#smsYn_Y").prop("checked","checked");
			}
			if(${rMap.PHONE_RECV eq "N"}) {
				$("#smsYn_N").prop("checked","checked");
			}
			//대시보드 값 불러오기
			const dashboardInput = document.getElementById('dashboard');
			let dashboardValues = dashboardInput.value.split(",");
			const selectBoxes = document.getElementsByClassName('form_select md w100');
			
			for(i=0 ; i<selectBoxes.length ; i++) {
				if(dashboardValues[i]) { //값이 있으면
					selectBoxes[i].value = dashboardValues[i];
				}else {
					selectBoxes[i].value = ""; //selectBox value값 지정해주기
				}
			}
			
			if(document.querySelector('#title').innerText == ''){
				$('#title').text('마이페이지');
				$('.sub_tit_h6').text('내 정보 수정');
			}
		});
		
		//마이페이지 수정
		function fn_MyPageUpdate() {
			
			if( $("#userNm").val() == "" ){
				alert("성명을 입력해 주세요.");
				$("#userNm").focus();
				return false;
			}
			
	        if( $("#hpNo1").val() != "" || $("#hpNo2").val() != "" || $("#hpNo3").val() != "" ) {
	        	if( $("#hpNo1").val().length < 3 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo1").focus();
	        		return false;
	        	}
	        	if( $("#hpNo2").val().length < 4 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo2").focus();
	        		return false;
	        	}
	        	if( $("#hpNo3").val().length < 4 ) {
	        		alert("핸드폰 번호를 정확히 입력해주세요.");
	        		$("#hpNo3").focus();
	        		return false;
	        	}
	        	
		        /* for(let i=1; i<4; i++) {
		        	if( $("#hpNo"+i).val() == "" ) {
		        		alert("핸드폰 번호를 정확히 입력해주세요.");
		        		$("#hpNo"+i).focus();
		        		return false;
		        	}
		        } */
	        }else {
	        	alert("핸드폰 번호를 입력해주세요.");
				$("#hpNo1").focus();
				return false;
	        }
	        
	        if( !$("input[name=smsYn]").is(":checked") ) {
	        	alert("SMS 수신여부를 선택해주세요.");
	        	return false;
	        }
	        
        	if( !$("input[name=emailYn]").is(":checked") ) {
	        	alert("이메일 수신여부를 선택해주세요.");
	        	return false;
	        }
	        

			if( $("#userPw").val() != "" ){
	            var limitStartCnt = 8;
	            var limitEndCnt = 20;
	            var userPw = $("#userPw").val();
	            var pw = $("#userPw").val().split(" ").join("");
	            var num = pw.search(/[0-9]/g);
	            var eng = pw.search(/[a-z]/ig);
	            var spe = pw.search(/^.*(?=.*[~!@#$%^&*()_+-=`~,.;<>?|]).*$/g);
	            //var spe = pw.search(/^.*(?=.*[!@#$%^&+=]).*$/);
	            //글자수 제한
	            if( pw.length < limitStartCnt || pw.length > limitEndCnt ){
	                alert("비밀번호는 " + limitStartCnt + "자리에서 " + limitEndCnt + "자리 이하로 입력해 주세요.");
	                $("#userPw").focus();
	                return false;
	            }
	          //공백 제한
	            if( userPw.search(/\s/g) != -1 ){
	                alert("비밀번호는 공백없이 입력해 주세요.");
	                $("#userPw").focus();
	                return false;
	            }
	            //영문,숫자,특수문자 혼용
	            if( num < 0 || eng < 0 || spe < 0 ){
	                alert("영문,숫자,특수문자를 혼합하여 입력해 주세요.");
	                $("#userPw").focus();
	                return false;
	            }
	            
	            if( $("#userPwConfirm").val() == "" ){
	                alert("비밀번호 확인을 입력해 주세요.");
	                $("#userPwConfirm").focus();
	                return false;
	            }
	            if( $("#userPwConfirm").val() != "" ){
		            if( $("#userPw").val() != $("#userPwConfirm").val() ){
		                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
		                $("#userPwConfirm").focus();
		                return false;
		            }
		        }
	        }

			if( $("#hpNo1").val() != "" && $("#hpNo2").val() != "" && $("#hpNo3").val() != "" ){
				$("#hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
			}
			
			//대시보드 값 전송
			const selectBoxes = document.getElementsByClassName('form_select md w100');
			let selectedValues = [];
			
			for(let i=0 ; i<selectBoxes.length ; i++) {
				//항목 순서대로 선택하기
				if(i+1<selectBoxes.length && selectBoxes[i+1].value !== "" && selectBoxes[i].value === "") { 
					alert("대시보드 항목을 순서대로 선택하세요.");
					return false; 
				}

				if(selectBoxes[i].value !== "") {
					//항목 중복선택 불가
					if(selectedValues.includes(selectBoxes[i].value)) {
						alert("대시보드 항목을 중복 선택할 수 없습니다.");
						return false;
					}
					
					selectedValues.push(selectBoxes[i].value);
				}
			}
			$("#dashboard").val(selectedValues);
			
			
			$("#frm").attr("action", "<c:url value='/admmgr/member/adminMyPageUpdateProc.do'/>").submit();
		}
		
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="preUserId" name="preUserId" value="<c:out value="${rMap.USER_ID}"/>" />
	<input type="hidden" id="hpNo" name="hpNo"/>
	<input type="hidden" id="seq" name="seq"/>
	<input type="hidden" id="dashboard" name="dashboard" value="<c:out value='${rMap.DASHBOARD}'/>" />

	<!--sub_contents_wrap-->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">관리자 계정 ${(not empty rMap.USER_ID)?'수정':'등록'}</h6>
			</div>

			<div class="table_wrap n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="15%">
						<col width="35%">
						<col width="15%">
						<col width="35%">
					</colgroup>
					<tbody>
						<tr>
							<th>권한 <em class="c_red" style="background: none; width: auto;">*</em></th>
							<td>
								<select id="authCd" name="authCd" class="form_select wd320">
									<c:forEach items="${rList}" var="rList" varStatus="status">
										<option value="<c:out value="${rList.AUTH_CD}"/>" ${rList.AUTH_NM == rMap.AUTH_NM ? 'selected' : ""}><c:out value="${rList.AUTH_NM}"/></option>
									</c:forEach>
								</select>
							</td>
							<th>아이디 <em class="c_red" style="background: none; width: auto;">*</em></th>
							<td class="left">
								<c:choose>
									<c:when test="${empty rMap.USER_ID}">
										<input type="text" class="form_text" id="userId" name="userId" value="<c:out value="${str:getReverseXSS(rMap.USER_ID)}"/>" maxlength="50" />
										<a href="javascript:void(0);" class="btn secontary xsm" id="userIdBtn" name="userIdBtn" onclick="javascript:fn_CheckDupl(this); return false;">중복확인</a>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="userId" name="userId" value="<c:out value="${str:getReverseXSS(rMap.USER_ID)}"/>" />
										<c:out value="${str:getReverseXSS(rMap.USER_ID)}"/>
									</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<%-- <tr>
							<th>직급</th>
							<td class="left" style="border:1px solid #dbdfe2;">
								<input type="text" class="form_text mr5" id="posiNm" name="posiNm" maxlength="30" value="<c:out value="${str:getReverseXSS(rMap.POSI_NM)}"/>" />
							</td>
							<th>부서</th>
							<td class="left" style="border:1px solid #dbdfe2;">
								<input type="text" class="form_text mr5" id="deptNm" name="deptNm" maxlength="30" value="<c:out value="${str:getReverseXSS(rMap.DEPT_NM)}"/>" />
							</td>
						</tr> --%>
						<tr>
							<th>이름(한글) <em class="c_red" style="background: none; width: auto;">*</em></th>
							<td class="left">
								<c:choose>
									<c:when test="${empty rMap.USER_ID}">
										<input type="text" class="form_text" id="userNm" name="userNm" />
										<!-- <a href="javascript:void(0);" class="btn3_ty3 mr30" onclick="javascript:fn_findEmp(); return false;">직원찾기</a> -->
									</c:when>
									<c:otherwise>
										<input type="text" class="form_text" id="userNm" name="userNm" value="<c:out value="${str:getReverseXSS(rMap.USER_NM)}"/>" />
									</c:otherwise>
								</c:choose>
							</td>
							
							<th>핸드폰번호</th>
							<td class="left">
								<c:if test="${not empty rMap.HP_NO}">
									<c:set var="arrHpNo" value="${fn:split(rMap.HP_NO,'-')}"/>
									<c:if test="${not empty arrHpNo[0]}">
										<c:set var="hpNo1" value="${arrHpNo[0]}"/>
									</c:if>
									<c:if test="${not empty arrHpNo[1]}">
										<c:set var="hpNo2" value="${arrHpNo[1]}"/>
									</c:if>
									<c:if test="${not empty arrHpNo[2]}">
										<c:set var="hpNo3" value="${arrHpNo[2]}"/>
									</c:if>
								</c:if>
								<div>
									<input type="text" class="form_text wd70" id="hpNo1" name="hpNo1" value="<c:out value="${hpNo1}"/>" style="width:10%;"maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9-]/g,'');"/>
									<span>-</span>
									<input type="text" class="form_text wd70" id="hpNo2" name="hpNo2" value="<c:out value="${hpNo2}"/>" style="width:15%;"maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9-]/g,'');"/>
									<span>-</span>
									<input type="text" class="form_text wd70" id="hpNo3" name="hpNo3" value="<c:out value="${hpNo3}"/>" style="width:15%;"maxlength="4" onKeyup="this.value=this.value.replace(/[^0-9-]/g,'');"/>
								</div>
								<div>
									<label for="smsYn_Y" class="ch" ><input type="radio" id="smsYn_Y" name="smsYn" value="Y"><span>SMS 수신</span></label>
									<label for="smsYn_N" class="ch"><input type="radio" id="smsYn_N" name="smsYn" value="N"><span>SMS 수신안함</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>이메일</th>
							<td class="left">
								<div>
									<input type="text" class="form_text wd320" id="email" name="email" value="<c:out value="${str:getReverseXSS(rMap.EMAIL)}"/>" maxlength="50"/>
								</div>
								<div>
									<label for="emailYn_Y" class="ch"><input type="radio" id="emailYn_Y" name="emailYn" value="Y"><span>이메일 수신</span></label>
									<label for="emailYn_N" class="ch"><input type="radio" id="emailYn_N" name="emailYn" value="N"><span>이메일 수신안함</span></label>
								</div>
							</td>
						</tr>
						<tr>
						<th>비밀번호
								<c:choose>
									<c:when test="${empty rMap.USER_ID}">
										<em class="c_red" style="background: none; width: auto;">*</em>
									</c:when>
								</c:choose>
							</th>
							<td class="left">
								<input type="password" class="form_text" id="userPw" name="userPw" maxlength="20"/>
								<p class="c_sky mt5">※영문,숫자,특수문자를 혼합하여 8자리 이상 20자리 이하</p>
							</td>
							<th>비밀번호 확인 <em class="c_red" style="background: none; width: auto;">*</em></th>
							<td colspan="3"><input type="password" class="form_text" id="userPwConfirm" name="userPwConfirm" maxlength="20"/></td>
						</tr>
					</tbody>
				</table>
			</div>

			
			<c:if test="${not empty rMap.USER_ID}">
				<div class="noti_area mt10">
					<p class="noti_text"><em>비밀번호를 입력하지 않으면 기존 비밀번호가 유지됩니다.</em></p>
					<p class="noti_text"><em>개인설정 시, 로그아웃 후 다시 로그인하면 적용됩니다.</em></p>
				</div>
			</c:if>
			
			<br>

			<!-- 대시보드 -->
			<div class="con_sec flx" style="gap:20px; align-items:flex-start">
				<div class="" style="flex:1">
					<!-- table_header -->
					<div class="box_tit">
						<h6 class="title">대시보드</h6>
					</div>
					<!-- // table_header -->
					
					<div class="table_wrap n_table_sty01 n_view01">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
							<colgroup>
								<col width="33%"/>
								<col width="33%"/>
								<col width="33%"/>
							</colgroup>
							<tbody>
								<tr>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 1</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 2</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 3</th>
								</tr>
								<tr>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option> 
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
								<tr>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 4</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 5</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 6</th>
								</tr>
								<tr>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option> 
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
								<tr>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 7</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 8</th>
									<th style="text-align:center; vertical-align: bottom; padding-bottom: 5px;">항목 9</th>
								</tr>
								<tr>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option> 
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
									<td>
										<select class="form_select md w100">
											<option value="" selected>없음</option>
											<option value="01">일반회원</option>
											<option value="02">탈퇴회원</option>
											<option value="03">관리자</option>
											<option value="04">공지사항</option>
											<option value="05">수요조사</option>
											<option value="06">사업공고</option>
										</select>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

				</div>

				<div class="" style="flex:1">
					<div class="box_tit">
						<h6 class="title">개인 설정</h6>
					</div>
					<div class="table_wrap n_table_sty01 n_view01">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
							<colgroup>
								<col width="15%">
								<col width="35%">
								<col width="15%">
								<col width="35%">
							</colgroup>
							<tbody>
								<tr>
									<th>테마</th>
									<td class="left" colspan="3">
										<div>
											<label for="themeDark" class="ch">
												<input type="radio" id="themeDark" name="theme" value="01" <c:out value="${rMap.THEME eq '01' ? 'checked' : ''}"/>>
												<span>다크 모드</span>
											</label>
											<label for="themeLight" class="ch">
												<input type="radio" id="themeLight" name="theme" value="02" <c:out value="${rMap.THEME eq '02' || rMap.THEME eq null  ? 'checked' : ''}"/>>
												<span>라이트 모드</span>
											</label>
										</div>
									</td>
								</tr>
								<tr>
									<th>배율</th>
									<td class="left" colspan="3">
										<div>
											<label for="zoom80" class="ch">
												<input type="radio" id="zoom80" name="zoom" value="80" ${rMap.ZOOM eq '80' ? 'checked' : ''}>
												<span>80%</span>
											</label>
											<label for="zoom90" class="ch">
												<input type="radio" id="zoom90" name="zoom" value="90" ${rMap.ZOOM eq '90' ? 'checked' : ''}>
												<span>90%</span>
											</label>
											<label for="zoom100" class="ch">
												<input type="radio" id="zoom100" name="zoom" value="100" ${rMap.ZOOM eq '100' || rMap.ZOOM eq null ? 'checked' : ''}>
												<span>100%(기본)</span>
											</label>
											<label for="zoom110" class="ch">
												<input type="radio" id="zoom110" name="zoom" value="110" ${rMap.ZOOM eq '110' ? 'checked' : ''}>
												<span>110%</span>
											</label>
											<label for="zoom120" class="ch">
												<input type="radio" id="zoom120" name="zoom" value="120" ${rMap.ZOOM eq '120' ? 'checked' : ''}>
												<span>120%</span>
											</label>
										</div>
									</td>
								</tr>
								<tr>
									<th>게시물 개수</th>
									<td class="left" colspan="3">
										<div>
											<label for="record_cnt10" class="ch">
												<input type="radio" id="record_cnt10" name="record_cnt" value="10" ${rMap.RECORD_CNT eq '10' ? 'checked' : ''}>
												<span>10개</span>
											</label>
											<label for="record_cnt30" class="ch">
												<input type="radio" id="record_cnt30" name="record_cnt" value="30" ${rMap.RECORD_CNT eq '30' || rMap.RECORD_CNT eq null ? 'checked' : ''}>
												<span>30개(기본)</span>
											</label>
											<label for="record_cnt50" class="ch">
												<input type="radio" id="record_cnt50" name="record_cnt" value="50" ${rMap.RECORD_CNT eq '50' ? 'checked' : ''}>
												<span>50개</span>
											</label>
											<label for="record_cnt100" class="ch">
												<input type="radio" id="record_cnt100" name="record_cnt" value="100" ${rMap.RECORD_CNT eq '100' ? 'checked' : ''}>
												<span>100개</span>
											</label>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- // 대시보드 -->

			<div class="page_btn_wrap jc_between mt20"">
				<div class="lft"></div>
				<div class="rgt">
					<c:choose>
						<c:when test="${isMyPage == 'Y' }">
							<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_MyPageUpdate();"><span>저장</span></a>
						</c:when>
						<c:otherwise>
							<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
							<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		

		</div>
		<!--// sub_contents_area-->

	</div>
	<!--/ sub_contents_wrap-->
</form>
</body>