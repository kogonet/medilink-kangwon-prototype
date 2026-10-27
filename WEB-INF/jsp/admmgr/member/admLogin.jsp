<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.ctit.base.CBase"%>
<%@ page import="com.ctit.helper.SettingUtil"%>
<%@ page import="com.ctit.helper.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 관리자 로그인
 **************************************************/
%>
<!doctype html>
<html lang="ko" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta charset="utf-8">
	<meta http-equiv="Content-Script-Type" content="text/javascript">
	<meta http-equiv="Content-Style-Type" content="text/css">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="robots" content="noindex">
	<title>강원 메디컬 AI</title>
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/css/default.css'/>"/>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/jquery.min.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/design.js'/>"></script>
	<link rel="shortcut icon" href="<c:url value='/common/front/images/ico/ctit.ico'/>"/>
	<link rel="icon" href="<c:url value='/common/front/images/ico/ctit.ico'/>"/>
	<script type="text/javascript">
		$(document).ready(function(){
			// 저장된 쿠키값을 가져와서 ID 칸에 넣어준다. 없으면 공백으로 들어감.
		    var key = getCookie("key");
		    $("#userId").val(key);
		    if($("#userId").val() != ""){ // 그 전에 ID를 저장해서 처음 페이지 로딩 시, 입력 칸에 저장된 ID가 표시된 상태라면,
		        $("#idSaveCheck").attr("checked", true); // ID 저장하기를 체크 상태로 두기.
		    }
		    $("#idSaveCheck").change(function(){ // 체크박스에 변화가 있다면,
		        if($("#idSaveCheck").is(":checked")){ // ID 저장하기 체크했을 때,
		            setCookie("key", $("#userId").val(), 7); // 7일 동안 쿠키 보관
		        }else{ // ID 저장하기 체크 해제 시,
		            deleteCookie("key");
		        }
		    });
		    // ID 저장하기를 체크한 상태에서 ID를 입력하는 경우, 이럴 때도 쿠키 저장.
		    $("#userId").keyup(function(){ // ID 입력 칸에 ID를 입력할 때,
		        if($("#idSaveCheck").is(":checked")){ // ID 저장하기를 체크한 상태라면,
		            setCookie("key", $("#userId").val(), 7); // 7일 동안 쿠키 보관
		        }
		    });
		  	//EnterKey
			$("#userPw").on("keydown",function(key){
		        if( key.keyCode == 13 ){
		        	fn_Login();
		        }
		    });
		  	
		  	// 열려있는 메뉴 저장 된 것 삭제
			localStorage.removeItem("onClass");
		  	
		});

		function setCookie(cookieName, value, exdays){
		    var exdate = new Date();
		    exdate.setDate(exdate.getDate() + exdays);
		    var cookieValue = escape(value) + ((exdays==null) ? "" : "; expires=" + exdate.toGMTString());
		    document.cookie = cookieName + "=" + cookieValue;
		}

		function deleteCookie(cookieName){
		    var expireDate = new Date();
		    expireDate.setDate(expireDate.getDate() - 1);
		    document.cookie = cookieName + "= " + "; expires=" + expireDate.toGMTString();
		}

		function getCookie(cookieName) {
		    cookieName = cookieName + '=';
		    var cookieData = document.cookie;
		    var start = cookieData.indexOf(cookieName);
		    var cookieValue = '';
		    if(start != -1){
		        start += cookieName.length;
		        var end = cookieData.indexOf(';', start);
		        if(end == -1)end = cookieData.length;
		        cookieValue = cookieData.substring(start, end);
		    }
		    return unescape(cookieValue);
		}
		function fn_IpAddress(callback) {
		    $.ajax({
		        url: 'https://api.ip.pe.kr/',
		        type: 'POST', 
		        success: function(Data) {
		            console.log(Data);
		            $('#ipAddress').val(Data);
		            callback();
		        }
		    });
		}
		function fn_Login(){
			if( $("#userId").val() == "" ){
				alert("아이디를 입력해 주세요.");
				$("#userId").focus();
				return false;
			}
			if( $("#userPw").val() == "" ){
				alert("비밀번호를 입력해 주세요.");
				$("#userPw").focus();
				return false;
			}
			fn_IpAddress(function() {
		        $("#frm").submit();
		    });
		}
	</script>
</head>
<body class="login_body">
    <div class="common_wrapper">
        <!-- 로그인영역 -->
        <div class="login_wrapper">
            <div class="login_area">
                <div class="login_cnt_box">
                    <div class="login_cnt">
                        <!-- 입력폼 -->
                        <form id="frm" name="frm" method="post" action="<c:url value='/admmgr/member/loginProc.do'/>">
                        	<input type="hidden" id="ipAddress" name="ipAddress">
                            <fieldset>
                                <legend>로그인</legend>
                                <div class="login_input_box">

									 <!-- 로고이미지 -->
									 <div class="login_logo">
										<img src="/common/admmgr/images/common/GangWonMediAi_logo.png" alt="강원메디컬 AI">
									</div>
									
                                    <div class="login_input">
                                        
                                        <!-- id,pw 인풋 -->
                                        <p class="form_id_pw">
                                            <label for="id" class="">
                                                <input type="text" name="userId" id="userId" title="아이디" class="input_login" maxlength="20" placeholder="ID" />
                                            </label>
                                            <label for="pw" class="">
                                                <input type="password" name="userPw" id="userPw" title="비밀번호" class="input_login" maxlength="20"
                                                    placeholder="Password" />
                                            </label>
                                        </p>

                                        <!-- 에러 -->
                                        <p class="form_error" style="display: none;">
                                            <span>로그인 5회 실패 시 계정이 차단됩니다.</span>
                                        </p>

                                        <!-- 아이디저장 -->
                                        <p class="form_save">
                                            <label class="ch">
                                                <input type="checkbox" id="idSaveCheck" name="idSaveCheck" value="Y" checked="checked" /><span>아이디 저장</span>
                                            </label>
                                        </p>

                                        <!-- 로그인버튼 -->
                                        <p>
                                            <a class="btn_login" onclick="javascript:fn_Login();">로그인</a>
                                        </p>
                                    </div>

                                    <!-- 카피라이트 -->
                                    <div class="copy_text">
                                        <p>CTIT</p>
                                    </div>
                                </div>
                            </fieldset>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <footer class="login_footer">
            <div class="inner">
                <div class="login_footer_box">
                    <h3 class="footer_tit">최신 브라우저 다운로드</h3>
                    <div class="footer_con">
                        <a href="https://www.microsoft.com/ko-kr/edge/download?form=MA13FJ" target="_blank"><img src="<c:url value='/common/admmgr/images/login/img_browser01.png'/>"></a>
                        <a href="https://www.google.com/chrome/browser/desktop/index.html" target="_blank"><img src="<c:url value='/common/admmgr/images/login/img_browser02.png'/>"></a>
                        <ul class="bul_attention">
                            <li><i><img src="<c:url value='/common/admmgr/images/login/ico_attention.png'/>"></i>해당 시스템은 최신 브라우저에 최적화 되어 있습니다.</li>
                            <li><i><img src="<c:url value='/common/admmgr/images/login/ico_attention.png'/>"></i>최신 브라우저로 업그레이드 이후 사용하시길 바랍니다.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </footer>
    </div>
</body>
</html>