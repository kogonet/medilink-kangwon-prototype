<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 회원정보 등록/수정
 **************************************************/
%>
<fmt:formatDate var="nowYear" value="<%=new java.util.Date()%>" pattern="yyyy"/>
<fmt:formatDate var="nowMonth" value="<%=new java.util.Date()%>" pattern="MM"/>
<fmt:formatDate var="nowDay" value="<%=new java.util.Date()%>" pattern="dd"/>
<head>
	<style type="text/css">
		.btn_add{width:120px;background: #00aeff url(/common/admmgr/images/ico/ico_pluse.png)no-repeat;background-position: calc(100% - 13px) center;font-size: 13px;font-weight: 400;text-align: left;color: #fff !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;border: 1px solid #00aeff;box-sizing: border-box;height: 30px;}
		.btn_remove{width:120px;background: #ffffff url(/common/admmgr/images/ico/ico_minus.png)no-repeat;background-position: calc(100% - 13px) center;border: 1px solid #d2d2d2;font-size: 13px;font-weight: 400;text-align: left;color: #999999 !important;display: inline-block;line-height: 1;padding: 7px 13px;font-family: 'Malgun Gothic',sans-serif;border-radius: 3px;box-sizing: border-box;height: 30px;}
	</style>

	<script type="text/javascript" src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
	<script type="text/javascript">
		<%-- 아이디 중복검사 --%>
		var duplYn = true;
		function fn_CheckDupl(obj){
			if ( $(obj).val() == '다시검색' ) {
				duplYn = true;
				$("#userId").prop("readonly", "");
				$(obj).val("중복체크");
				return false;
			}
			
			if( $("#userId").val() == "" ){
				alert("아이디를 입력해 주세요.");
				$("#userId").focus();
				return false;
			}
			
			/* if( $("#userId").val().trim() != "" ){
				var disallowedId = ['admin', 'root', 'superuser', 'test', 'guest', 'administrator', 'system', 'null', 'undefined'];
				$.each(disallowedId, function(index, value){
					if( $("#userId").val() === value ){
						alert('사용할 수 없는 아이디입니다.');
						return false;
					}
				});
			} */
			
			if( $("#userId").val() != "" ){
				var limitStartCnt = 4;
	            var limitEndCnt = 12;
	            var userId = $("#userId").val();
	            var id = $("#userId").val().split(" ").join("");
	            var num = id.search(/[0-9]/g);
	            var eng = id.search(/[a-z]/ig);
	            var spe = id.search(/^.*(?=.*[!@#$%^&+=]).*$/);
	            var disallowedId = ['admin', 'root', 'superuser', 'test', 'guest', 'administrator', 'system', 'null', 'undefined'];
	            var flag = true;
	            //아이디 제한
	            $.each(disallowedId, function(index, value){
					if( $("#userId").val() === value ){
						flag = false;
						alert('사용할 수 없는 아이디입니다.');
						return false;
					}
				});
	            if(!flag) return false;
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
				type:"POST",
				url:"<c:url value='/admmgr/member/userDuplCheckAjax.do'/>",
				data:{"userId":$("#userId").val()},
				dataType:"text",
				success:function(rData){
					onebtnchk=0;
					console.log(rData)
					if( rData == "OK" ){
						if( confirm("사용할 수 있는 아이디입니다.\n사용하시겠습니까?") ){
							duplYn = false;
							$("#userId").prop("readonly", "readonly");
							$(obj).val("다시검색");
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
		function fn_Regist(){
			if( $("#preUserId").val() == "" ){
				if( $("#userId").val() == "" ){
		            alert("아이디를 입력해 주세요.");
		            $("#userId").focus();
		            return false;
		        }
		        if( duplYn ){
		            alert("아이디 중복검사를 진행해 주세요.");
		            $("#userIdBtn").focus();
		            return false;
		        }
		        if( $("#userPw").val() == "" ){
		            alert("비밀번호를 입력해 주세요.");
		            $("#userPw").focus();
		            return false;
		        }
		        if( $("#userPwConfirm").val() == "" ){
		            alert("비밀번호 확인을 입력해 주세요.");
		            $("#userPwConfirm").focus();
		            return false;
		        }
	        
				if( $("#userPw").val() != "" ){
		            var limitStartCnt = 8;
		            var limitEndCnt = 20;
		            var userPw = $("#userPw").val().trim();
		            var pw = $("#userPw").val().split(" ").join("");
		            var num = pw.search(/[0-9]/g);
		            var eng = pw.search(/[a-z]/ig);
		            var spe = pw.search(/^.*(?=.*[!@#$%^&+=]).*$/);
		            var flag = 0;
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
		            if( num >= 0 ) {
		            	flag += 1;
		            }
		            if( eng >= 0 ) {
		            	flag += 1;
		            }
		            if( spe >= 0 ) {
		            	flag += 1;
		            }
		            if( flag < 2 ){
		                alert("영문,숫자,특수문자중 2가지이상 혼합하여 입력해 주세요.");
		                $("#userPw").focus();
		                return false;
		            }
		            if( $("#userPwConfirm").val() == "" ){
		                alert("비밀번호 확인을 입력해 주세요.");
		                $("#userPwConfirm").focus();
		                return false;
		            }
		        }
		        if( $("#userPwConfirm").val() != "" ){
		            if( $("#userPw").val() != $("#userPwConfirm").val() ){
		                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
		                $("#userPwConfirm").focus();
		                return false;
		            }
		        }
			}
	        if( $("#userNm").val().trim() == "" ){
	            alert("이름(국문)을 입력해 주세요.");
	            $("#userNm").focus();
	            return false;
	        }
	        /* if( $("#userEngNm").val() == "" ){
	            alert("이름(영문)을 입력해 주세요.");
	            $("#userEngNm").focus();
	            return false;
	        } */
	        
	        if( $("#hpNo1").val() == "" || $("#hpNo2").val() == "" || $("#hpNo3").val() == "" ){
	            alert("핸드폰번호를 입력해 주세요.");
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
	        	alert("휴대폰번호를 정확히 입력해 주세요.");
	        	$("#hpNo2").focus();
	        	return false;
	        }
	        if( $("#hpNo3").val().length < 4 ){
	        	alert("휴대폰번호를 정확히 입력해 주세요.");
	        	$("#hpNo3").focus();
	        	return false;
	        }
	        if( !$("input[name=smsYn]").is(":checked") ) {
	        	alert("SMS 수신여부를 선택해주세요.");
	        	return false;
	        }
	        
	    	// 이메일 유효성검사
	        if( $("#email1").val() == "" || $("#email2").val() == "" ){
	            alert("이메일을 입력해 주세요.");
	            if( $("#email1").val() == "" ){
	                $("#email1").focus();
	            }else if( $("#email2").val() == "" ){
	                $("#email2").focus();
	            }
	            return false;
	        }
	        
	        if( $("#email1").val().trim() != "" || $("#email2").val().trim() != "" ){
	        	var email1_rule = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*$/;
	        	var email2_rule = /^[a-zA-Z0-9]+([.-]?[a-zA-Z0-9]+)*\.[a-zA-Z]{2,6}$/;
	        	var email1 = $("#email1").val();
	        	var email2 = $("#email2").val();
	        	
	        	if( /[@]/.test(email1) || !email1_rule.test(email1) ) {
	        		alert("이메일을 정확히 입력해주세요.");
	        		$("#email1").focus();
	        		return false;
	        	}
	        	if( /[@]/.test(email2) || !email2_rule.test(email2) ) {
	        		alert("이메일을 정확히 입력해주세요.");
	        		$("#email2").focus();
	        		return false;
	        	}
	        	
	        }
	        
	        if( !$("input[name=emailYn]").is(":checked") ) {
	        	alert("이메일 수신여부를 선택해주세요.");
	        	return false;
	        }
	        
	        if( $("#birth").val() == "" ){
	            alert("생년월일을 입력해 주세요.");
	            $("#birth").focus();
	            return false;
	        }
	        if( $("#birth").val().length < 10 ){
	            alert("생년월일을 정확히 입력해 주세요.");
	            $("#birth").focus();
	            return false;
	        }
	        /* if( $("#nationCd").val() == "" ){
	            alert("국가를 선택해 주세요.");
	            $("#nationCd").focus();
	            return false;
	        } */
	        
	        
	        if( !$("input[name=gender]").is(":checked") ) {
	        	alert("성별을 선택해주세요.");
	        	return false;
	        }
	        if( $("#zipNo").val() == "" ) {
	        	alert("우편번호를 입력해주세요.");
	        	$("#zipNo").focus();
	        	return false;
	        }
	        if( $("#addr").val() == "" ) {
	        	alert("주소를 입력해주세요.");
	        	$("#addr").focus();
	        	return false;
	        }
	        if( $("#addrPt").val().trim() == "" ) {
	        	alert("상세주소를 입력해주세요.");
	        	$("#addrPt").focus();
	        	return false;
	        }
	        
	       /*  $.each($("input[name=radio_basicYn]"),function(item,index){
	        	if( $(this).is(":checked") )	$(this).prev().val("Y");
	        	else							$(this).prev().val("N");
	        });
	        $.each($("input[name=chk_joinYn]"),function(item,index){
	        	if( $(this).is(":checked") )	$(this).prev().val("Y");
	        	else							$(this).prev().val("N");
	        }); */

	        $("#hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
	        /* if( $("#compTelNo1").val() != "" && $("#compTelNo2").val() != "" && $("#compTelNo3").val() != "" ){
	        	$("#compTelNo").val($("#compTelNo1").val()+"-"+$("#compTelNo2").val()+"-"+$("#compTelNo3").val());
			} */
	    	$("#email").val($("#email1").val().replaceAll(" ","")+"@"+$("#email2").val().replaceAll(" ",""));
	    	if($("#userTp").val() == "Eval"){
	    		$("#authCd").val("002000000");
	    	}else if($("#userTp").val() == "Study"){
	    		$("#authCd").val("003000000");
	    	}
	    	$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}RegistProc.do'/>");
			$("#frm").submit();
		}
		/*
		//승인
		function fn_Approve(){
			$("#frm").attr("action","<c:url value='/admmgr/member/comApproveProc.do'/>");
			$("#frm").submit();
		}
		*/
		//삭제
		function fn_Delete(){
			if( confirm("해당 회원을 삭제하시겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/member/comDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		//목록
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/member/userAllList.do'/>");
			$("#frm").submit();
		}
		$(document).ready(function(){
			$("#title").text("일반회원 등록");
			
			// 이메일 수신여부
			if(${rMap.EMAIL_RECV == "Y"}) {
				$("#emailYn_Y").prop("checked","checked");
			}
			if(${rMap.EMAIL_RECV == "N"}) {
				$("#emailYn_N").prop("checked","checked");
			}
			// sms 수신여부
			if(${rMap.PHONE_RECV == "Y"}) {
				$("#smsYn_Y").prop("checked","checked");
			}
			if(${rMap.PHONE_RECV == "N"}) {
				$("#smsYn_N").prop("checked","checked");
			}
		});
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST">
		<input type="hidden" id="userTp" name="userTp" value="<c:out value="${userTp}"/>"/>
		<input type="hidden" id="preUserId" name="preUserId" value="<c:out value="${rMap.USER_ID}"/>"/>
		<input type="hidden" id="hpNo" name="hpNo"/>
		<input type="hidden" id="compTelNo" name="compTelNo"/>
		<input type="hidden" id="email" name="email"/>
		<input type="hidden" id="authCd" name="authCd"/>
	
		<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
			
			
			<c:choose>
				<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><h4 class="sub_tit_h4"><em>일반 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></h4></c:when>
				<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><h4 class="sub_tit_h4"><em>연구자 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></h4></c:when>
				<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><h4 class="sub_tit_h4"><em>평가위원 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></h4></c:when>
			</c:choose>

			<div class="table_header">
				<h6 class="sub_tit_h6">기본정보</h6>
			</div>

			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="13%"/>
						<col width="37%"/>
						<col width="13%"/>
						<col width="37%"/>
					</colgroup>
					<tbody>
						<tr>
							<th>아이디 <em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<c:choose>
									<c:when test="${not empty rMap.USER_ID}">
										<input type="hidden" id="userId" name="userId" value="<c:out value="${rMap.USER_ID}"/>"/>
										<c:out value="${rMap.USER_ID}"/>
									</c:when>
									<c:otherwise>
										<input type="text" class="form_text wd320" id="userId" name="userId" maxlength="20"/>
										<input type="button" class="btn secondary xsm wd80" id="userIdBtn" name="userIdBtn" value="중복체크" onclick="javascript:fn_CheckDupl(this); return false;"/>
										<em class="c_sky">※ 아이디는 4 ~ 12자 사이 영문, 숫자만 가능 합니다.</em>
									</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<tr>
							<th>비밀번호 <em class="c_red" style="background: none;">*</em></th>
							<td>
								<input type="password" class="form_text wd320" id="userPw" name="userPw" maxlength="20"/><br/>
								<em  class="c_sky">*영문 대/소문자,숫자,특수문자(~!@#$%^&*만 가능) 중 2종류 이상 조합하여 8 ~ 20자리 입력</em>
							</td>
							<th>비밀번호 확인 <em class="c_red" style="background: none;">*</em></th>
							<td><input type="password" class="form_text wd320" id="userPwConfirm" name="userPwConfirm" maxlength="20"/></td>
						</tr>
						<tr>
							<th>이름(국문) <em class="c_red" style="background: none;">*</em></th>
							<td colspan="3"><input type="text" class="form_text wd320" id="userNm" name="userNm" value="<c:out value="${rMap.USER_NM}"/>" maxlength="50"/></td>
							<%-- <th>이름(영문) <em class="c_red">*</em></th>
							<td><input type="text" class="form_text wd320" id="userEngNm" name="userEngNm" value="<c:out value="${rMap.USER_ENG_NM}"/>" maxlength="50"/></td> --%>
						</tr>
						<%-- <tr>
							<th>생년월일 <em class="c_red">*</em></th>
							<td colspan="3"><input type="text" class="form_text wd320" id="birth" name="birth" value="<c:out value="${rMap.BIRTH}"/>" placeholder="예) 19810522" maxlength="8" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/></td>
							<th>성별 <em class="c_red">*</em></th>
							<td>
								<input type="radio" name="gender" id="gender1" value="M" <c:if test="${rMap.GENDER eq 'M' || empty rMap.GENDER}">checked="checked"</c:if>/>
								<label for="gender1">
									<span class="kt_img"></span>
									<span style="padding:0 20px 0 0;">남</span>
								</label>
								<input type="radio" name="gender" id="gender2" value="F" <c:if test="${rMap.GENDER eq 'F'}">checked="checked"</c:if>/>
								<label for="gender2">
									<span class="kt_img"></span>
									<span style="padding:0 20px 0 0;">여</span>
								</label>
							</td>
						</tr> --%>
						<tr>
							<th>핸드폰번호 <em class="c_red" style="background: none;">*</em></th>
							<td>
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
									<select id="hpNo1" name="hpNo1" title="선택" class="form_select wd100">
										<option value="">선택</option>
										<option value="010"<c:if test="${hpNo1 eq '010'}"> selected="selected"</c:if>>010</option>
										<option value="011"<c:if test="${hpNo1 eq '011'}"> selected="selected"</c:if>>011</option>
										<option value="016"<c:if test="${hpNo1 eq '016'}"> selected="selected"</c:if>>016</option>
										<option value="017"<c:if test="${hpNo1 eq '017'}"> selected="selected"</c:if>>017</option>
										<option value="018"<c:if test="${hpNo1 eq '018'}"> selected="selected"</c:if>>018</option>
										<option value="019"<c:if test="${hpNo1 eq '019'}"> selected="selected"</c:if>>019</option>
									</select>
									<span class="m"> - </span>
									<input type="text" id="hpNo2" name="hpNo2" class="form_text wd70" placeholder="" maxlength="4" value="<c:out value="${hpNo2}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
									<span class="m"> - </span>
									<input type="text" id="hpNo3" name=hpNo3 class="form_text wd70" placeholder="" maxlength="4" value="<c:out value="${hpNo3}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
								</div>
								<div class="mt5">
									<label for="smsYn_Y" class="ch"><input type="radio" id="smsYn_Y" name="smsYn" value="Y"><span>SMS 수신</span></label>
									<label for="smsYn_N" class="ch"><input type="radio" id="smsYn_N" name="smsYn" value="N"><span>SMS 수신안함</span></label>
								</div>
							</td>
							<th>이메일 <em class="c_red" style="background: none;">*</em></th>
							<td>
								<c:if test="${not empty rMap.EMAIL}">
									<c:set var="arrEmail" value="${fn:split(rMap.EMAIL,'@')}"/>
									<c:if test="${not empty arrEmail[0]}">
										<c:set var="email1" value="${arrEmail[0]}"/>
									</c:if>
									<c:if test="${not empty arrEmail[1]}">
										<c:set var="email2" value="${arrEmail[1]}"/>
									</c:if>
								</c:if>
								<div>
									<input type="text" class="form_text" id="email1" name="email1" value="<c:out value="${email1}"/>" maxlength="50"/>
									<span class="m"> @ </span>
									<input type="text" class="form_text" id="email2" name="email2" value="<c:out value="${email2}"/>" maxlength="50"/>
								</div>

								<div class="mt5">
									<label for="emailYn_Y" class="ch"><input type="radio" id="emailYn_Y" name="emailYn" value="Y"><span>이메일 수신</span></label>
									<label for="emailYn_N" class="ch"><input type="radio" id="emailYn_N" name="emailYn" value="N"><span>이메일 수신안함</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>생년월일<em class="c_red" style="background: none;">*</em></th>
							<td>
								<span class="form_date">
									<input type="text" id="birth" name="birth" placeholder="시작일 입력" class="form_text wd200" value="<c:out value="${rMap.BIRTH}"/>" onclick="calendar(event,'birth','yyyy-mm-dd')">
									<input type="button" class="btn_form_date" onclick="javascript:$('#birth').trigger('click');">
								</span></br>
								<em  class="c_sky">* ex) 1998-01-23</em>
							</td>
							<th>성별<em class="c_red" style="background: none;">*</em></th>
							<td>
								<div>
									<label for="male" class="ch"><input type="radio" id="male" name="gender" value="M" <c:if test="${rMap.GENDER eq 'M'}">checked="checked"</c:if>><span>남자</span></label>
									<label for="female" class="ch"><input type="radio" id="female" name="gender" value="F" <c:if test="${rMap.GENDER eq 'F'}">checked="checked"</c:if>><span>여자</span></label>
								</div>
							</td>
						</tr>
						<tr>
							<th>우편번호<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="zipNo" name="zipNo" class="form_text min_w70" readonly="readonly" value="<c:out value="${rMap.ZIP_NO}"/>">
								<a href="javascript:void(0);" onclick="openPost('zipNo','addr')" class="btn secondary xsm"><span>주소검색</span></a>
							</td>
						</tr>
						<tr>
							<th>주소<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="addr" name="addr" class="form_text w100" readonly="readonly" value="<c:out value="${rMap.ADDR}"/>">
							</td>
						</tr>
						<tr>
							<th>상세주소<em class="c_red" style="background: none;">*</em></th>
							<td colspan="3">
								<input type="text" id="addrPt" name="addrPt" class="form_text w100" value="<c:out value="${rMap.ADDR_PT}"/>">
							</td>
						</tr>
						<%-- <tr>
							<th>회사이름 </th>
							<td><input type="text" class="form_text" id="compNm" name="compNm" value="<c:out value="${rMap.COMP_NM}"/>" maxlength="50"/></td>
							<th>회사전화번호</th>
							<td>
								<c:if test="${not empty rMap.COMP_TEL_NO}">
									<c:set var="arrCompTelNo" value="${fn:split(rMap.COMP_TEL_NO,'-')}"/>
									<c:if test="${not empty arrCompTelNo[0]}">
										<c:set var="compTelNo1" value="${arrCompTelNo[0]}"/>
									</c:if>
									<c:if test="${not empty arrCompTelNo[1]}">
										<c:set var="compTelNo2" value="${arrCompTelNo[1]}"/>
									</c:if>
									<c:if test="${not empty arrCompTelNo[2]}">
										<c:set var="compTelNo3" value="${arrCompTelNo[2]}"/>
									</c:if>
								</c:if>
								<select id="compTelNo1" name="compTelNo1" title="선택" class="form_select wd100">
									<option value="">선택</option>
									<option value="02"<c:if test="${compTelNo1 eq '02'}"> selected="selected"</c:if>>02</option>
									<option value="031"<c:if test="${compTelNo1 eq '031'}"> selected="selected"</c:if>>031</option>
									<option value="032"<c:if test="${compTelNo1 eq '032'}"> selected="selected"</c:if>>032</option>
									<option value="033"<c:if test="${compTelNo1 eq '033'}"> selected="selected"</c:if>>033</option>
									<option value="041"<c:if test="${compTelNo1 eq '041'}"> selected="selected"</c:if>>041</option>
									<option value="042"<c:if test="${compTelNo1 eq '042'}"> selected="selected"</c:if>>042</option>
									<option value="043"<c:if test="${compTelNo1 eq '043'}"> selected="selected"</c:if>>043</option>
									<option value="051"<c:if test="${compTelNo1 eq '051'}"> selected="selected"</c:if>>051</option>
									<option value="052"<c:if test="${compTelNo1 eq '052'}"> selected="selected"</c:if>>052</option>
									<option value="053"<c:if test="${compTelNo1 eq '053'}"> selected="selected"</c:if>>053</option>
									<option value="054"<c:if test="${compTelNo1 eq '054'}"> selected="selected"</c:if>>054</option>
									<option value="055"<c:if test="${compTelNo1 eq '055'}"> selected="selected"</c:if>>055</option>
									<option value="061"<c:if test="${compTelNo1 eq '061'}"> selected="selected"</c:if>>061</option>
									<option value="062"<c:if test="${compTelNo1 eq '062'}"> selected="selected"</c:if>>062</option>
									<option value="063"<c:if test="${compTelNo1 eq '063'}"> selected="selected"</c:if>>063</option>
									<option value="064"<c:if test="${compTelNo1 eq '064'}"> selected="selected"</c:if>>064</option>
									<option value="064"<c:if test="${compTelNo1 eq '064'}"> selected="selected"</c:if>>070</option>
								</select>
								<span class="m"> - </span>
								<input type="text" id="compTelNo2" name="compTelNo2" class="input_text_n" placeholder="" maxlength="4" style="width:70px" value="<c:out value="${compTelNo2}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
								<span class="m"> - </span>
								<input type="text" id="compTelNo3" name="compTelNo3" class="input_text_n" placeholder="" maxlength="4" style="width:70px" value="<c:out value="${compTelNo3}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
							</td>
						</tr>
						<tr>
							<th>부서 </th>
							<td><input type="text" class="input_text_n" id="deptNm" name="deptNm" value="<c:out value="${rMap.DEPT_NM}"/>" maxlength="50"/></td>
							<th>직위/직급 </th>
							<td><input type="text" class="input_text_n" id="posiNm" name="posiNm" value="<c:out value="${rMap.POSI_NM}"/>" maxlength="50"/></td>
						</tr> --%>
					</tbody>
				</table>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>
				

			</div>
			<!-- // sub_contents_area -->

		</div>
		<!-- // sub_contents_wrap -->

	</form>
</body>