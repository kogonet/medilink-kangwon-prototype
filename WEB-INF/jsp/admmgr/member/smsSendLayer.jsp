<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 컨텐츠 등록
 **************************************************/
%>
<head>
	<%-- <link rel="stylesheet" href="<c:url value='/common/admmgr/css/bootstrap.css'/>"> --%>
	<%-- <script src="<c:url value='/common/admmgr/js/summernote/dist/lib/jquery-3.2.1.js'/>"></script>
	<script src="<c:url value='/common/admmgr/js/summernote/dist/lib/bootstrap-3.3.5.js'/>"></script>
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/js/summernote/dist/summernote.css'/>">
	<script  src="<c:url value='/common/admmgr/js/summernote/dist/summernote.min.js'/>"></script> --%>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/plugin/tooltip.js'/>"></script>
	<script type="text/javascript">
	
		var chkYn = true;
		
		$(document).ready(function(){
			
			//textarea 길이제한 
	    	//fn_TextCount_Byte_Init('90','90');
			
	    	// 페이지 로딩시 글자수 노출
	    	/* $("textarea").each(function() {
	            fn_TextCount_Byte('undefined', 1000, this);
	        }); */
			
	    	messageEvent($('textarea[name=message]'),"N");
	    	
			$(document).on("keyup", "textarea[name=message]", function() {
				messageEvent($(this), "N");
			});
			
		});

		window.onload = function(){
			getImage();	// 이미지 가져오기
			
			document.querySelector('#check').addEventListener('click', function(){
			    var answer = document.querySelector('#answer').value;
			    var params = { answer: answer };

			    $.ajax({
			        url: '/admmgr/business/chkAnswer.do',
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

		}
		/*매번 랜덤값을 파라미터로 전달하는 이유 : IE의 경우 매번 다른 임의 값을 전달하지 않으면 '새로고침' 클릭해도 정상 호출되지 않아 이미지가 변경되지 않는 문제가 발생된다*/
		function audio(){
			var rand = Math.random();
			var uAgent = navigator.userAgent;
			var soundUrl = '/admmgr/business/captchaAudio.do?rand='+rand;
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
		    var url = '/admmgr/business/captchaImg.do?rand=' + rand;
		    console.log('New image URL:', url); // 확인용 메시지
		    $('#captchaImg').attr('src', url);
		}
		function audioPlayer(objUrl){
			document.querySelector('#ccaudio').innerHTML = '<bgsoun src="' +objUrl +'">';
		}

		
		function messageEvent(messageObj, isFile) {
			var subjectName = "input[name=subject]";
			var infoClass = ".info_msg";
			var bytes = getValueByte(messageObj.val());
			var area = messageObj.parent().parent();

			//특수문자 입력시 MMS타입 변경 오류 방지 조건 추가
			//if (isFile == "input[name=subject]" && Number($("#filecnt", opener.document).val() > 0)) {
			//	isFile = "Y";
			//}

			if (bytes <= 90) {
				if (isFile != "Y") {
					//area.find(subjectName).val("");
					area.find(infoClass).html("<p><strong>SMS</strong></p><p><em class=\"text_theme\">" + bytes + "</em> / 90 byte</p>");
				}
				//area.find(subjectName).attr("disabled",true);		
			} else if (bytes > 2000) {
				alert("2000byte 이상 입력할 수 없습니다.");
				messageObj.val(getValueByteLimit(messageObj.val(), 2000));
				area.find(infoClass).html("<p><strong>LMS</strong></p><p><em class=\"text_theme\">" + getValueByte(messageObj.val()) + "</em> / 2000 byte</p>");
			} else {

				if (getValueByte(area.find(subjectName).val()) == 0) {
					area.find(subjectName).val("");
				}
				area.find(subjectName).attr("disabled", false);

				if (isFile != "Y") {
					area.find(infoClass).html("<p><strong>LMS</strong></p><p><em class=\"text_theme\">" + bytes + "</em> / 2000 byte</p>");
				}
			}

			if (isFile == "Y") {
				area.find(subjectName).attr("disabled", false);
				area.find(infoClass).html("<p><strong>MMS</strong></p><p><em class=\"text_theme\">" + bytes + "</em> / 2000 byte</p>");
			}
		}
		
		/* function onSuccessFunction(response, status, request) {
			//var result = response.result;
			if (result.indexOf("S") > -1) {
				//var result = "메시지 전송이 완료되었습니다.\n단, 수신거부번호로 등록된 전화번호는 전송되지 않습니다.";
				//						response = response.replace("T", "총 건수");
				//						response = response.replace("D", "수신번호 중복 건수");
				//						response = response.replace("R", "수신거부 번호 건수");
				//						response = response.replace("S", "발송 건수");
				alert("메시지 전송이 완료되었습니다.\n단, 수신거부번호로 등록된 전화번호는 전송되지 않습니다.");
				location.href = "/message/send/sendFormG.do";
			} else {
				if (result == "0")
					alert("일반전송의 1회 전송 가능한 최대건수는 1만건 입니다.");
				else if (result == "1")
					alert("제목 또는 메시지에 스팸문자가 포함되어 있습니다.");
				else if (result == "2")
					alert("충전금액이 부족하여 메시지를 전송할 수 없습니다.");
				else if (result == "3") {
					alert("메시지 전송 일 제한요금을 초과하였습니다.\n일 제한금액 : "
						+ response.dLimit + ", 일 사용량 : " + response.dAmount);
				} else if (result == "4") {
					alert("메시지 전송 월 제한요금을 초과하였습니다.\n월 제한금액 : "
						+ response.mLimit + ", 월 사용량 : " + response.mAmount);
				} else if (result == "5")
					alert("해당번호는 발신번호 차단 요청된 번호입니다.");
				else if (result == "6")
					alert("수신 번호 전체가 수신거부 번호로 등록되어있습니다.");
				else if (result == "7") {
					alert("인증 처리가 필요합니다.\n인증 팝업이 뜨지 않는 경우 브라우저 팝업 허용 설정을 해주세요.");
					authPopup();
				} else if (result == "8") {//admin 유저가입시 필수입력값 검증 완료되기전 임시 확인용
					alert("선.후불 방식이 정해지지 않았거나 , 메시지 단가 또는 일.월별 제한 값이 0원 입니다. \n관리자에게 문의하세요.");
				} else if (result == "9") {
					alert("발송프로세스가 재호출 되었습니다. 보낸 메시지함을 확인해 주세요.");
				} else
					alert("메시지 전송 처리 중 오류가 발생하였습니다.");
			}
		} */
		
		//SMS 발송
		function fn_Regist(){
			
			if( $("#answer").val() == '' ){
	    		alert("자동등록방지 문구를 입력해주세요.");
	    		$("#answer").focus();
	    		return false;
	    	}
	        if( chkYn ){
	            alert("자동등록방지 확인을 클릭해 주세요.");
	            $("#check").focus();
	            return false;
	        }
			
			const userId = '<%= request.getParameter("userId") %>';
			let subject = $("#subject").val();
			let message = $("#message").val();
			
			let messageByte = getValueByte(message);
			
			$.ajax({
				url : "/admmgr/member/smsSendLayerProcAjax.do",
				type : "POST",
				dataType : "json",
				data : {
					"userId" : userId,
					"subject" : subject,
					"message" : message,
					"messageByte" : messageByte
				},
				async : false,
				success : function(response, status, request) {
					console.log(response);
					
					if (response.status === "OK") {
						alert("메시지 전송이 완료되었습니다.\n단, 수신거부번호로 등록된 전화번호는 전송되지 않습니다.");
					} else {
						
						switch (response.status) {
	                    case "0":
	                        alert("일반전송의 1회 전송 가능한 최대건수는 1천건 입니다.");
	                        break;
	                    case "1":
	                        alert("제목 또는 메시지에 스팸문자가 포함되어 있습니다.");
	                        break;
	                    case "2":
	                        alert("충전금액이 부족하여 메시지를 전송할 수 없습니다.");
	                        break;
	                    case "3":
	                        alert("메시지 전송 일 제한건수를 초과하였습니다.");
	                        break;
	                    case "4":
	                        alert("메시지 전송 월 제한건수를 초과하였습니다.");
	                        break;
	                    case "5":
	                        alert("해당번호는 발신번호 차단 요청된 번호입니다.\n재사용을 원하실 경우 KISA 불법스팸대응센터(www.spamcop.or.kr)로 문의하시기 바랍니다.");
	                        break;
	                    default:
	                        alert("메시지 전송 처리 중 오류가 발생하였습니다.");
	                	}
						
					}
					
					/* if(response.indexOf("T") > -1) {
						var result = "메시지 전송이 완료되었습니다.\n단, 수신거부번호로 등록된 전화번호는 전송되지 않습니다.";
			// 						response = response.replace("T", "총 건수");
			// 						response = response.replace("D", "수신번호 중복 건수");
			// 						response = response.replace("R", "수신거부 번호 건수");
			// 						response = response.replace("S", "발송 건수");
						alert(result);
					} else {
						if(response == "0") alert("일반전송의 1회 전송 가능한 최대건수는 1천건 입니다.");
						else if(response == "1") alert("제목 또는 메시지에 스팸문자가 포함되어 있습니다.");
						else if(response == "2") alert("충전금액이 부족하여 메시지를 전송할 수 없습니다.");
						else if(response == "3") alert("메시지 전송 일 제한건수를 초과하였습니다.");
						else if(response == "4") alert("메시지 전송 월 제한건수를 초과하였습니다.");
						else if(response == "5") alert("해당번호는 발신번호 차단 요청된 번호입니다.\n재사용을 원하실 경우 KISA 불법스팸대응센터(www.spamcop.or.kr)로 문의하시기 바랍니다.");
						else  alert("메시지 전송 처리 중 오류가 발생하였습니다.");
					} */
				},
				error : function(request,status,error) {
					
					var response = request.responseJSON;
					
					if(request.status == '400') {
						if(response.status === "10") {
							alert("등록된 평가위원이 없습니다.");
						} else {
							alert("메시지 전송처리 중 오류가 발생하였습니다.(Bad Request)");
						}
						
					}else if(request.status == '901') {
						alert("보안 공격이 감지되었습니다.");
					}else{
						alert("메시지 전송처리 중 오류가 발생하였습니다." + request.status);
					}
				},
				complete : function() {
					opener.location.reload();
					self.close();
				}
			});
			
		}
	</script>
</head>
<body>
	<div class="pop_tit_section">
		<h3 class="pop_tit_h3">SMS 발송</h3>
		<button class="pop_btn_close" onclick="javascript:window.close();"><i class="ico_close"></i></button>
	</div>

	<!-- pop_con_section -->
	<div class="pop_con_section">
		<form id="frm" name="frm" method="POST" >

			<!-- sms_wrap -->
			<div id="sms_div" class="sms_wrap">
				<div class="sms_mobile">
					<div class="box_tit">
						<h6 class="title">SMS 발송</h6>
					</div>
					<div class="sms_mobile_box">
						<input type="text" title="LMS/MMS 제목 입력" value="" id="subject" name="subject" class="form_text md w100" placeholder="LMS/MMS 제목 입력">
						<!-- <textarea cols="25" rows="9" id="message" name="message" class="msg_txt" style="resize: none;"></textarea> -->
						<textarea class="form_textarea w100 mt10" id="message" name="message" style="height:300px;" cols="" rows=""  maxlength="2000"  placeholder="LMS/MMS 내용 입력"></textarea>
						<div class="info_msg">
							<!-- <p><span class="text_theme">0</span> / 90 byte</p> -->
						</div>
						<div class="callout mt10">
							<i><img src="/common/admmgr/images/icon/ico_noti_b.svg"></i>
							<div class="callout_txt">
								90byte 초과시 LMS로 자동 전환됩니다.<br>
								<span class="c_red">SMS 발송시 제목은 무시됩니다.</span>
							</div>
						</div>
						
						
						<%-- 캡챠 --%>
						<div class="mt10">
							<img class="ht30" src="/admmgr/business/captchaImg.do" id="captchaImg" alt="캡차이미지"/>
							<div id="ccaudio" style="display:none"></div>
						
							<input id="reload" class="btn md bg_gray" type="button" onclick="javaScript:getImage()" value="새로고침"/>
							<input id="soundOn" class="btn md bg_gray" type="button" onclick="javaScript:audio()" value="음성듣기"/>
						</div>
						<div class="mt10">
							<input id="answer" type="text" class="form_text md wd190" value="">
							<input id="check" class="btn md bg_info " type="button" value="확인"/>
						</div>


						<a class="btn md bg_info w100 mt30" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>전송하기</span></a>
							
						<div class="callout mt10">
							<div class="callout_txt"><b>※ 선정된 평가회원에게 평가와 관련한 정보나 안내사항을 발송합니다.</b></div>
						</div>

					</div>
					
					<div class="table_footer">
						<div class="btn_wrap lft"></div>
							<%-- <div class="pagination_wrap">
								<div id="pageList">
									<c:out value="${PAGING_HTML}" escapeXml="false" />
								</div>
							</div> --%>
						<div class="btn_wrap rgt">
							<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:window.close();"><em>닫기</em></a>
						</div>
					</div>
					
				</div>
				
			</div>
			<!-- // sms_wrap -->
	</form>
	</div>
	<!-- // pop_con_section -->
</body>