<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 탈퇴회원 등록/수정
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
	<script type="text/javascript">
	$(document).ready(function(){
		<%-- 진료업무 선택 이벤트 --%>
		$("input:radio[name=treatYn]").on("change", function(){
			if($("input:radio[name=treatYn]:checked").val() == "N"){
				$("#treatYn").val("N");
				$("#licenseNo").val("");
				$("#licenseNo").attr("disabled", true);
			}else if($("input:radio[name=treatYn]:checked").val() == "Y"){
				$("#treatYn").val("Y");
				$("#licenseNo").attr("disabled", false);
			}
		});
		<%-- 구분 선택 이벤트 --%>
		$("input:radio[name=studyTp]").on("change", function(){
			var selectTxt = $(this).next().text();
			if( selectTxt.indexOf("기타") != -1 ){
				$(this).parent().find(".input_text_n").attr("disabled", false);
			}else{
				if( $(this).parent().find(".input_text_n").length != 0 ){
					$(this).parent().find(".input_text_n").attr("disabled", true);
					$(this).parent().find(".input_text_n").val("");
				}
			}
			$("#studyNm").val(selectTxt);
		});
	});

		<%-- 아이디 중복검사 --%>
		var duplYn = true;
		function fn_CheckDupl(obj){
			if( $("#userId").val() == "" ){
				alert("아이디를 입력해 주세요.");
				$("#userId").focus();
				return false;
			}
			$.ajax({
				type:"POST",
				url:"<c:url value='/admmgr/member/userDuplCheckAjax.do'/>",
				data:{"userId":$("#userId").val()},
				dataType:"text",
				success:function(rData){
					onebtnchk=0;
					if( rData == "OK" ){
						if( confirm("사용할 수 있는 아이디입니다.\n사용하시겠습니까?") ){
							duplYn = false;
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
		<%-- 전공 팝업창 --%>
		function fn_SearchMajor(obj, pCode, tagId){
			FrameLayer.open("<c:url value='/admmgr/member/majorLayer.do'/>","500","250","no",
					{
						"pCode" : pCode,
						"tagId" : tagId,
						"mainCatNm" : $(obj).parent().prev().text()
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
	        }
			if( $("#userPw").val() != "" ){
	            var limitStartCnt = 8;
	            var limitEndCnt = 20;
	            var pw = $("#userPw").val().split(" ").join("");
	            var num = pw.search(/[0-9]/g);
	            var eng = pw.search(/[a-z]/ig);
	            var spe = pw.search(/^.*(?=.*[!@#$%^&+=]).*$/);
	            //글자수 제한
	            if( pw.length < limitStartCnt || pw.length > limitEndCnt ){
	                alert("비밀번호는 " + limitStartCnt + "자리에서 " + limitEndCnt + "자리 이하로 입력해 주세요.");
	                $("#userPw").focus();
	                return false;
	            }
	            //공백 제한
	            if( pw.search(/\s/) != -1 ){
	                alert("비밀번호는 공백업이 입력해 주세요.");
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
	        }
	        if( $("#userPwConfirm").val() != "" ){
	            if( $("#userPw").val() != $("#userPwConfirm").val() ){
	                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
	                $("#userPwConfirm").focus();
	                return false;
	            }
	        }
	        if( $("#userNm").val() == "" ){
	            alert("이름(국문)을 입력해 주세요.");
	            $("#userNm").focus();
	            return false;
	        }
	        if( $("#userEngNm").val() == "" ){
	            alert("이름(영문)을 입력해 주세요.");
	            $("#userEngNm").focus();
	            return false;
	        }
	        if( $("#birth").val() == "" ){
	            alert("생년월일을 입력해 주세요.");
	            $("#birth").focus();
	            return false;
	        }
	        /*
	        if( $("#joinDd").val() == "" ){
	            alert("최초임용일자를 입력해 주세요.");
	            $("#joinDd").focus();
	            return false;
	        }
	        if( $("#nationCd").val() == "" ){
	            alert("국가를 선택해 주세요.");
	            $("#nationCd").focus();
	            return false;
	        }
	        */
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
	        if( $("#email1").val() == "" || $("#email2").val() == "" ){
	            alert("이메일을 입력해 주세요.");
	            if( $("#email1").val() == "" ){
	                $("#email1").focus();
	            }else if( $("#email2").val() == "" ){
	                $("#email2").focus();
	            }
	            return false;
	        }
	        if($("input:radio[name=licenseNoYn]:checked").val() == "y" && $("#licenseNo").val() == ""){
				alert("대표면허번호가 있을 경우 입력 해주세요.");
				$("#licenseNo").focus();
				return false;
			}
	        $.each($("input[name=radio_basicYn]"),function(item,index){
	        	if( $(this).is(":checked") )	$(this).prev().val("Y");
	        	else							$(this).prev().val("N");
	        });
	        $.each($("input[name=chk_joinYn]"),function(item,index){
	        	if( $(this).is(":checked") )	$(this).prev().val("Y");
	        	else							$(this).prev().val("N");
	        });

	        if($("#orgTable > tbody > tr").length < 1){
	        	alert("최소 하나의 소속기관은 등록해 주세요.");
				return false;
	        }else{
	        	var orgChk = true;
	        	$("#orgTable > tbody > tr").each(function(){
	        		if($(this).children("td").eq(1).children("input[name=orgNm]").val() == ""){
	        			orgChk = false;
	        		}
	        	});

	        	if(!orgChk){
	        		alert("소속기관을 입력해 주세요.");
					return false;
	        	}
	        }

	        $("#hpNo").val($("#hpNo1").val()+"-"+$("#hpNo2").val()+"-"+$("#hpNo3").val());
	        if( $("#compTelNo1").val() != "" && $("#compTelNo2").val() != "" && $("#compTelNo3").val() != "" ){
	        	$("#compTelNo").val($("#compTelNo1").val()+"-"+$("#compTelNo2").val()+"-"+$("#compTelNo3").val());
			}
	    	$("#email").val($("#email1").val().replaceAll(" ","")+"@"+$("#email2").val().replaceAll(" ",""));
	    	$("#studyNm").val($("#studyNmEtc").val());
	    	//대표기관 부서
			var deptNm = $("input[name=basicYn]:checked").parent().parent().find("input[name=orgDeptNm]").val()
			if( deptNm )	$("#deptNm").val(deptNm);

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
			$("#frm").attr("action","<c:url value='/admmgr/member/user${userTp}List.do'/>");
			$("#frm").submit();
		}
		//국가검색 팝업창
		function fn_SearchNation(){
			FrameLayer.open("<c:url value='/admmgr/member/nationLayer.do'/>","500","250","no","");
		}
		//소속기관 팝업창
		function fn_SearchOrg(obj){
			FrameLayer.open("<c:url value='/admmgr/member/orgLayer.do'/>","800","250","no",{"selectorIndex":$(obj).parent().parent().index()});
		}
		//소속기관추가
		function fn_AddOrg(obj){
			var oTbody = $(obj).parent().parent().parent();
			var oTr    = $(obj).parent().parent().clone();
			oTr.find("input[name=orgNo]").val("");
			oTr.find("input[name=orgNm]").val("");
			oTr.find("input[name=deptNm]").val("");
			oTr.find("input[name=posiNm]").val("");
			oTr.find("input[name=joinYn]").prop("checked",false);
			oTr.find("input[name=basicYn]").prop("checked",false);
			oTbody.append(oTr);
		}
		//소속기관제거
		function fn_DelOrg(obj){
			var oTbody = $(obj).parent().parent().parent();
			if( oTbody.find("tr").length == 1 ){
				alert("최소 하나의 소속기관은 등록해 주세요.");
				return false;
			}
			$(obj).parent().parent().remove();
		}
		//전문분야검색 팝업창
		function fn_SearchSpecialty(obj, pCode, tagId){
			FrameLayer.open("<c:url value='/admmgr/member/specialtyLayer.do'/>","500","250","no",
					{
						"pCode" : pCode
						, "tagId" : tagId
						, "mainCatNm" : $(obj).parent().parent().find("td").eq(0).text()
					});
		}
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
		<input type="hidden" id="deptNm" name="deptNm"/>
		<input type="hidden" id="studyNm" name="studyNm"/>
		<input type="hidden" id="treatYn" name="treatYn"/>
		<div class="sub_contents_wrap">
			<h4 class="sub_tit_h4 fix">
				<c:choose>
					<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><em>일반 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></c:when>
					<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><em>연구자 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></c:when>
					<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><em>평가위원 회원 ${(not empty rMap.USER_ID)?'수정':'등록'}</em></c:when>
				</c:choose>
			</h4>
			<div class="sub_contents_area">
				<div class="con_list_wrap">
					<div class="tit_area fix">
						<h6 class="sub_tit_h6 f_left">기본정보</h6>
					</div>
					<div class="table-wrap">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
							<colgroup>
								<col width="10%"/>
								<col width="40%"/>
								<col width="10%"/>
								<col width="40%"/>
							</colgroup>
							<tbody>
								<tr>
									<th>아이디 <em class="point">&nbsp;</em></th>
									<td colspan="3">
										<c:choose>
											<c:when test="${not empty rMap.USER_ID}">
												<input type="hidden" id="userId" name="userId" value="<c:out value="${rMap.USER_ID}"/>"/>
												<c:out value="${rMap.USER_ID}"/>
											</c:when>
											<c:otherwise>
												<input type="text" class="input_text mr5" id="userId" name="userId" maxlength="20"/>
												<input type="button" class="btn_ty1 mr30" id="userIdBtn" name="userIdBtn" value="중복체크" onclick="javascript:fn_CheckDupl(this); return false;"/>
												<em>※ 아이디는 6 ~ 16자 사이 영문, 숫자만 가능 합니다.</em>
											</c:otherwise>
										</c:choose>
									</td>
								</tr>
								<tr>
									<th>비밀번호 <em class="point">&nbsp;</em></th>
									<td>
										<input type="password" class="input_text" id="userPw" name="userPw" maxlength="20"/><br/>
										<em>*영문 대/소문자,숫자,특수문자(~!@#$%^&*만 가능) 중 2종류 이상 조합하여 8 ~ 20자리 입력</em>
									</td>
									<th>비밀번호 확인 <em class="point">&nbsp;</em></th>
									<td><input type="password" class="input_text" id="userPwConfirm" name="userPwConfirm" maxlength="20"/></td>
								</tr>
								<tr>
									<th>이름(국문) <em class="point">&nbsp;</em></th>
									<td><input type="text" class="input_text_n" id="userNm" name="userNm" value="<c:out value="${rMap.USER_NM}"/>" maxlength="50"/></td>
									<th>이름(영문) <em class="point">&nbsp;</em></th>
									<td><input type="text" class="input_text_n" id="userEngNm" name="userEngNm" value="<c:out value="${rMap.USER_ENG_NM}"/>" maxlength="50"/></td>
								</tr>
								<tr>
									<th>생년월일 <em class="point">&nbsp;</em></th>
									<td><input type="text" class="input_text_n" id="birth" name="birth" value="<c:out value="${rMap.BIRTH}"/>" placeholder="예) 19810522" maxlength="8" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/></td>
									<th>성별 <em class="point">&nbsp;</em></th>
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
								</tr>
								<%--
								<tr>
									<th>최초임용일자 <em class="point">&nbsp;</em></th>
									<td>
										<em class="input_text_em">
											<input type="text" id="joinDd" name="joinDd" placeholder="최초임용일자" class="input_text1" value="<c:out value="${rMap.JOIN_DD}"/>" onclick="calendar(event,'joinDd','yyyy-mm-dd')" style="cursor:pointer;width:100px;">
											<img src="<c:url value='/common/admmgr/images/sub_common/ico_cal1.png'/>" alt="최초임용일자" onclick="javascript:$('#joinDd').trigger('click');"/>
										</em>
									</td>
									<th>국가 <em class="point">&nbsp;</em></th>
									<td>
										<input type="hidden" class="input_text mr5" id="nationCd" name="nationCd" value="<c:out value="${rMap.NATION_CD}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="nationNm" name="nationNm" value="<c:out value="${str:getCodeName('001000000000000',rMap.NATION_CD)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" id="nationBtn" name="nationBtn" value="검색" onclick="javascript:fn_SearchNation(this); return false;"/>
									</td>
								</tr>
								--%>
								<tr>
									<th>핸드폰번호 <em class="point">&nbsp;</em></th>
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
										<select id="hpNo1" name="hpNo1" title="선택" class="select_type1" style="width:100px !important;">
											<option value="">선택</option>
											<option value="010"<c:if test="${hpNo1 eq '010'}"> selected="selected"</c:if>>010</option>
											<option value="011"<c:if test="${hpNo1 eq '011'}"> selected="selected"</c:if>>011</option>
											<option value="016"<c:if test="${hpNo1 eq '016'}"> selected="selected"</c:if>>016</option>
											<option value="017"<c:if test="${hpNo1 eq '017'}"> selected="selected"</c:if>>017</option>
											<option value="018"<c:if test="${hpNo1 eq '018'}"> selected="selected"</c:if>>018</option>
											<option value="019"<c:if test="${hpNo1 eq '019'}"> selected="selected"</c:if>>019</option>
										</select>
										<span class="m"> - </span>
										<input type="text" id="hpNo2" name="hpNo2" class="input_text_n" placeholder="" maxlength="4" style="width:70px" value="<c:out value="${hpNo2}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
										<span class="m"> - </span>
										<input type="text" id="hpNo3" name=hpNo3 class="input_text_n" placeholder="" maxlength="4" style="width:70px" value="<c:out value="${hpNo3}"/>" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"/>
									</td>
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
										<select id="compTelNo1" name="compTelNo1" title="선택" class="select_type1" style="width:100px !important;">
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
									<th>이메일 <em class="point">&nbsp;</em></th>
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
										<input type="text" class="input_text_n" id="email1" name="email1" value="<c:out value="${email1}"/>" maxlength="50"/>
										<span class="m"> @ </span>
										<input type="text" class="input_text_n" id="email2" name="email2" value="<c:out value="${email2}"/>" maxlength="50"/>
									</td>
									<td></td>
									<td></td>
								</tr>
								<tr>
									<th>연구자 구분</th>
									<td colspan="3">
										<c:forEach var="result" items="${str:makeCodeListForPtCode('001000000000000','002007000000000')}" varStatus="status">
											<input type="radio" class="join_radio <c:if test="${!status.first}"> ml10</c:if> id="studyTp${status.count}" name="studyTp" value="<c:out value="${result.CODE}"/>" title="<c:out value="${result.CODE_NM}"/>">
											<label for="studyTp${status.count}"><span></span><c:out value="${result.CODE_NM}"/></label>
											<c:if test="${fn:contains(result.CODE_NM, '기타')}">
												<input type="text" class="input_text_n" id="studyNmEtc" name="studyNmEtc" placeholder="직접입력" maxlength="20" style="width:200px;vertical-align:initial;" value="<c:out value="${rMap.STUDY_NM}"/>" disabled="disabled" />
											</c:if>
										</c:forEach>
									</td>
								</tr>
								<tr>
									<th>진료업무</th>
									<td colspan="3">
										<input type="radio" name="treatYn" id="treatYn1" value="Y" <c:if test="${rMap.TREAT_YN ne '' || !empty rMap.TREAT_YN}">checked="checked"</c:if>>
										<label for="treatYn1"><span></span>유</label>
										<input type="text" class="input_text_n sty02" id="licenseNo" name="licenseNo" placeholder="면허번호를 입력해주세요." value="<c:out value="${rMap.LICENSE_NO}"/>" disabled="disabled"/>
										<input type="radio" name="treatYn" id="treatYn2" value="N" <c:if test="${rMap.TREAT_YN eq '' || empty rMap.TREAT_YN}">checked="checked"</c:if>>
										<label for="treatYn2"><span></span>무</label>

										<%--
										<input type="radio" name="licenseNoYn" id="licenseNoYn1" value="y" <c:if test="${rMap.LICENSE_NO ne '' || !empty rMap.LICENSE_NO}">checked="checked"</c:if>>
										<label for="licenseNoYn1">
											<span class="kt_img"></span>
											<span style="padding:0 15px 0 0;">유</span>
										</label>
										<input type="text" class="input_text_n" id="licenseNo" name="licenseNo" value="<c:out value="${rMap.LICENSE_NO}"/>" placeholder="면허번호를 입력해주세요" maxlength="20" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" <c:if test="${rMap.LICENSE_NO eq '' || empty rMap.LICENSE_NO}">readonly="readonly"</c:if>/>
										<br>
										<input type="radio" name="licenseNoYn" id="licenseNoYn2" value="n" <c:if test="${rMap.LICENSE_NO eq '' || empty rMap.LICENSE_NO}">checked="checked"</c:if>>
										<label for="licenseNoYn2">
											<span class="kt_img"></span>
											<span style="padding:0 15px 0 0;">무</span>
										</label>
										--%>
									</td>
								</tr>
								<tr>
									<th>전공</th>
									<td>
										<input type="hidden" class="input_text_n" id="majorCd" name="majorCd" maxlength="9" />
										<input type="text" class="input_text_n" id="majorNm" name="majorNm" maxlength="50" style="width:200px;" onchange="javascript:fn_Change(this);" maxlength="20" readonly="readonly"/>
										<a href="javascript:void(0);" class="btn_ty3 mr30" onclick="javascript:fn_SearchMajor(this, '015000000000000', 'major'); return false;"><span>찾기</span></a>
									</td>
									<td>세부전공</td>
									<td><input type="text" class="input_text_n" id="majorDtlNm" name="majorDtlNm" value="<c:out value="${rMap.MAJOR_DTL_NM}"/>" maxlength="30"/></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="tit_area fix">
						<h6 class="sub_tit_h6 f_left">소속기관</h6>

						<!-- <p class="btn_section">
							<span class="rit_btn_section">
								<a href="javascript:void(0);" onclick="javascript:fn_AddOrg(this);" class="btn_add">소속기관추가</a>
							</span>
						</p> -->
					</div>
					<div class="table-wrap">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2" id="orgTable">
							<colgroup>
								<col width="5%"/>
								<col width="20%"/>
								<col width="15%"/>
								<col width="15%"/>
								<col width="5%"/>
								<col width="15%"/>
							</colgroup>
							<thead>
								<tr>
									<th style="text-align:center">대표기관</th>
									<th style="text-align:center">소속기관</th>
									<th style="text-align:center">부서</th>
									<th style="text-align:center">직위</th>
									<th style="text-align:center">재직여부</th>
									<th style="text-align:center">관리</th>
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>

					<%-- 20211130 1차 오픈 숨김처리 요청
					<div class="tit_area fix">
						<h6 class="sub_tit_h6 f_left">전문분야(보건의료기술분류체계)</h6>
					</div>
					<div class="table-wrap">
						<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2" id="expertiseTable">
							<colgroup>
								<col width="30%"/>
								<col width="10%"/>
								<col width="*"/>
							</colgroup>
							<thead>
								<tr>
									<th style="text-align:center">분야</th>
									<th style="text-align:center">종류 1</th>
									<th style="text-align:center">종류 2</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td rowspan="3" style="text-align:center">질병분류</td>
									<td style="text-align:center">1순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickTp1" name="sickTp1" value="<c:out value="${rMap.SICK_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickTp1Nm" name="sickTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '004000000000000', 'sickTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">질병분류</td>
									<td style="text-align:center">2순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickTp2" name="sickTp2" value="<c:out value="${rMap.SICK_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickTp2Nm" name="sickTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '004000000000000', 'sickTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">질병분류</td>
									<td style="text-align:center">3순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickTp3" name="sickTp3" value="<c:out value="${rMap.SICK_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickTp3Nm" name="sickTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '004000000000000', 'sickTp3'); return false;"/>
									</td>
								</tr>
								<tr>
									<td rowspan="3" style="text-align:center">연구행위 및 산출물 분류</td>
									<td style="text-align:center">1순위</td>
									<td style="text-align:center">
										<input type="hidden" id="actTp1" name="actTp1" value="<c:out value="${rMap.ACT_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="actTp1Nm" name="actTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.ACT_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '005000000000000', 'actTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">연구행위 및 산출물 분류</td>
									<td style="text-align:center">2순위</td>
									<td style="text-align:center">
										<input type="hidden" id="actTp2" name="actTp2" value="<c:out value="${rMap.ACT_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="actTp2Nm" name="actTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.ACT_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '005000000000000', 'actTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">연구행위 및 산출물 분류</td>
									<td style="text-align:center">3순위</td>
									<td style="text-align:center">
										<input type="hidden" id="actTp3" name="actTp3" value="<c:out value="${rMap.ACT_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="actTp3Nm" name="actTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.ACT_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '005000000000000', 'actTp3'); return false;"/>
									</td>
								</tr>
								<tr>
									<td rowspan="3" style="text-align:center">과학기술표준분류</td>
									<td style="text-align:center">1순위</td>
									<td style="text-align:center">
										<input type="hidden" id="techTp1" name="techTp1" value="<c:out value="${rMap.TECH_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="techTp1Nm" name="techTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.TECH_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '006000000000000', 'techTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">과학기술표준분류</td>
									<td style="text-align:center">2순위</td>
									<td style="text-align:center">
										<input type="hidden" id="techTp2" name="techTp2" value="<c:out value="${rMap.TECH_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="techTp2Nm" name="techTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.TECH_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '006000000000000', 'techTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">과학기술표준분류</td>
									<td style="text-align:center">3순위</td>
									<td style="text-align:center">
										<input type="hidden" id="techTp3" name="techTp3" value="<c:out value="${rMap.TECH_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="techTp3Nm" name="techTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.TECH_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '006000000000000', 'techTp3'); return false;"/>
									</td>
								</tr>
								<tr>
									<td rowspan="3" style="text-align:center">한국보건산업진흥원</td>
									<td style="text-align:center">1순위</td>
									<td style="text-align:center">
										<input type="hidden" id="healthTp1" name="healthTp1" value="<c:out value="${rMap.HEALTH_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="healthTp1Nm" name="healthTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.HEALTH_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '007000000000000', 'healthTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">한국보건산업진흥원</td>
									<td style="text-align:center">2순위</td>
									<td style="text-align:center">
										<input type="hidden" id="healthTp2" name="healthTp2" value="<c:out value="${rMap.HEALTH_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="healthTp2Nm" name="healthTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.HEALTH_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '007000000000000', 'healthTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">한국보건산업진흥원</td>
									<td style="text-align:center">3순위</td>
									<td style="text-align:center">
										<input type="hidden" id="healthTp3" name="healthTp3" value="<c:out value="${rMap.HEALTH_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="healthTp3Nm" name="healthTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.HEALTH_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '007000000000000', 'healthTp3'); return false;"/>
									</td>
								</tr>
								<tr>
									<td rowspan="3" style="text-align:center">질병관리본부</td>
									<td style="text-align:center">1순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickOrgTp1" name="sickOrgTp1" value="<c:out value="${rMap.SICK_ORG_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickOrgTp1Nm" name="sickOrgTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_ORG_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '008000000000000', 'sickOrgTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">질병관리본부</td>
									<td style="text-align:center">2순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickOrgTp2" name="sickOrgTp2" value="<c:out value="${rMap.SICK_ORG_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickOrgTp2Nm" name="sickOrgTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_ORG_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '008000000000000', 'sickOrgTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">질병관리본부</td>
									<td style="text-align:center">3순위</td>
									<td style="text-align:center">
										<input type="hidden" id="sickOrgTp3" name="sickOrgTp3" value="<c:out value="${rMap.SICK_ORG_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="sickOrgTp3Nm" name="sickOrgTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.SICK_ORG_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '008000000000000', 'sickOrgTp3'); return false;"/>
									</td>
								</tr>
								<tr>
									<td rowspan="3" style="text-align:center">국립암센터</td>
									<td style="text-align:center">연구분야</td>
									<td style="text-align:center">
										<input type="hidden" id="nccTp1" name="nccTp1" value="<c:out value="${rMap.NCC_TP_1}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="nccTp1Nm" name="nccTp1Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.NCC_TP_1)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '009000000000000', 'nccTp1'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">국립암센터</td>
									<td style="text-align:center">연구성격</td>
									<td style="text-align:center">
										<input type="hidden" id="nccTp2" name="nccTp2" value="<c:out value="${rMap.NCC_TP_2}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="nccTp2Nm" name="nccTp2Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.NCC_TP_2)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '009000000000000', 'nccTp2'); return false;"/>
									</td>
								</tr>
								<tr>
									<td style="display: none;">국립암센터</td>
									<td style="text-align:center">암종</td>
									<td style="text-align:center">
										<input type="hidden" id="nccTp3" name="nccTp3" value="<c:out value="${rMap.NCC_TP_3}"/>" maxlength="9"/>
										<input type="text" class="input_text mr5" id="nccTp3Nm" name="nccTp3Nm" value="<c:out value="${str:getCodeName('001000000000000',rMap.NCC_TP_3)}"/>" maxlength="50" readonly="readonly"/>
										<input type="button" class="btn_ty3 mr30" value="검색" onclick="javascript:fn_SearchSpecialty(this, '009000000000000', 'nccTp3'); return false;"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					--%>
					<div class="btm_list_wrap">
						<p class="btn_section fix">
							<span class="rit_btn_section">
								<a class="btn1_ty4" href="javascript:void(0);" onclick="javascript:fn_Regist();"><em>저장</em></a>
								<a class="btn1_ty5" href="javascript:void(0);" onclick="javascript:fn_List();"><em>취소</em></a>
							</span>
						</p>
					</div>
				</div>
			</div>
		</div>
	</form>
</body>