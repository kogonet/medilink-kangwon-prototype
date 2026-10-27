﻿String.prototype.replaceAll = function(regex,replacement){
	return this.split(regex).join(replacement);
}

String.prototype.trim = function () {
	return this.replace(/(^\s*)|(\s*$)/g, "");
}

Array.prototype.indexOf = function (item, from) {
	var len = this.length;
	for (var i = (from < 0) ? Math.max(0, len + from) : from || 0; i < len; i++) {
		if (this[i] === item) return i;
	}
	return -1;
}

String.prototype.comma = function () {

	var l_text = this;
	var l_pattern = /^(-?\d+)(\d{3})($|\..*$)/;

	if (l_pattern.test(l_text)) {
		l_text = l_text.replace(l_pattern, function (str, p1, p2, p3) {
			return p1.comma() + ("," + p2 + p3);
		});
	}

	return l_text;

}

function isNumber(value) {
	value = Number(value);
	return typeof value === 'number' && isFinite(value);
}

function $id(id) {

	return document.getElementById(id);

}

function submit_msg( id ) {

	if (!id) id = regi_area;

	if ($("#" + id).length > 0) {

		$("#" + id).children().css("visibility", "hidden");
		$("#" + id).append("<span>등록중입니다. 잠시만 기다려주세요...</span>");

	}

}


function list_check(seq, option_name) {

	var option = this[option_name];
	var seq_name = option.seq_name;		//시퀀스 명
	var page = option.page;						//페이지 번호

	//검색 항목 설정
	var search_arr = [];
	for (var key in option.search) {

		search_arr.push(key + "=" + option.search[key]);

	}
	var search_str = search_arr.join("&");
	if (search_str.trim()) {

		search_str = "&" + search_str;

	}

	var browser = navigator.userAgent.toLowerCase();

	if (-1 != browser.indexOf('msie')) {
		seq = seq.replace("&reg", "&amp;reg");
	} else if (-1 != browser.indexOf('rv')) {
		seq = seq.replace("&reg", "&amp;reg");
	}
	location.href = option.read_url + "?" + seq_name + "=" + seq + "&page=" + page + search_str;

}

//날짜 변경시
function date_term_chage(oThis, str) {

  var arr = str.split('_');
  var term = arr[0];
  var unit = arr[1];

  //종료일자
  var date = moment();
  var e_date = date.format("YYYY-MM-DD");

  //시작일자
  date.add(Number(-term), unit);
  var s_date = date.format("YYYY-MM-DD");

  $(oThis).parents("td").find("#s_date").val(s_date);
  $(oThis).parents("td").find("#e_date").val(e_date);

  if ($("#date_term").length > 0) $("#date_term").val(str);
  if ($("#searchform").length > 0) $("#searchform").submit();

}

//일 변경시
function day_change(str, now) {

  var arr = str.split('_');
  var term = arr[0];
  var unit = arr[1];

  //일자
  var date = null;

  //오늘이 아닐경우
  if (str != "0_d") {

    date = moment(now);

  } else {

    date = moment();

  }

  date.add(Number(term), unit);
  var s_date = date.format("YYYY-MM-DD");
  $("#s_date").val(s_date);
  $("#searchform").submit();

}


function onlyNumber() {
	if (!((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || (event.keyCode == 8) || (event.keyCode == 9) || (event.keyCode == 110) || (event.keyCode == 190))) {
		if (event.preventDefault) {
			event.preventDefault();
		} else {
			event.returnValue = false;
		}
	}
}

//체크 박스 체크
function comm_all_check(oThis, chk_name) {

  $(":checkbox[name='" + chk_name + "']").prop("checked", oThis.checked);

}

//페이지 이동
function make_new_url(new_page_name, q_json) {

  var url = location.href;
  var page_url_arr = url.split(".aspx");
  var url_arr = page_url_arr[0].split("/");
  var page_name = url_arr[url_arr.length - 1]

  param.get();
  for (var key in q_json) {

    param.add(key, q_json[key]);

  }

  return param.join().replace(page_name + ".aspx", new_page_name + ".aspx");

}

function page_move(new_page_name, q_json, blank_chk) {

	var url = make_new_url(new_page_name, q_json);
	if (!blank_chk) {

		location.href = url;

	} else {

		window.open(url, "page_move", "");

	}

}

function openPost(zipcodeId, addrId) {

	// 다음우편번호를 불러올 수 있는 환경일때
//	if (daum) {

		new daum.Postcode({
			oncomplete: function (data) {
				// 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

				// 각 주소의 노출 규칙에 따라 주소를 조합한다.
				// 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
				var fullAddr = ''; // 최종 주소 변수
				var extraAddr = ''; // 조합형 주소 변수

				// 사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
				if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
					fullAddr = data.roadAddress;

				} else { // 사용자가 지번 주소를 선택했을 경우(J)
					fullAddr = data.jibunAddress;
				}

				// 사용자가 선택한 주소가 도로명 타입일때 조합한다.
				if (data.userSelectedType === 'R') {
					//법정동명이 있을 경우 추가한다.
					if (data.bname !== '') {
						extraAddr += data.bname;
					}
					// 건물명이 있을 경우 추가한다.
					if (data.buildingName !== '') {
						extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
					}
					// 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
					fullAddr += (extraAddr !== '' ? ' (' + extraAddr + ')' : '');
				}

				// 우편번호와 주소 정보를 해당 필드에 넣는다.
				$("#"+zipcodeId+"").val(data.zonecode);
				$("#"+addrId+"").val(fullAddr);
				$("#"+addrId+"").focus();
				/*document.getElementById(zipcodeId).value = data.zonecode; //5자리 새우편번호 사용
				document.getElementById(addrId).value = fullAddr;

				// 커서를 상세주소 필드로 이동한다.
				document.getElementById(addrId).focus();*/
			}
		}).open();

//		return;
//
//	} else {
//
//		alert( "우편번호를 이용할 수 없습니다." );
//
//	}

}

function clearPost(zipcodeId, addrId) {

	$("#" + zipcodeId).val("");
	$("#" + addrId).val("");

}

function basicFileDown( folder, filename ) {

	if (!document.filedownForm) {
		var html = "<form name='filedownForm' action='/download/download.aspx' method='post'>";
		html += "<input type='hidden' name='folder' value='" + folder + "' />";
		html += "<input type='hidden' name='filename' value='" + filename + "' />";
		html += "</form>";
		$("body").append(html);
	} else {
		document.filedownForm.folder.value = folder;
		document.filedownForm.filename.value = filename;
	}

	document.filedownForm.submit();

}

function G_PostPopupOpen(popupName, url, width, height, valueObjects) {
    if (popupName == "") {
        popupName = 'NewWindow';
    }
    var m_left =  (window.screen.width - width) / 2;
    var m_top = (window.screen.height - height) / 2;
    var stat = "menubar=0 location=0 directories=0 resizable=1 scrollbars=1 status=0 titlebar=1 toolbar=0 left="+m_left+" top="+m_top;
    var form = document.createElement("form");
    form.method = "POST";
    form.target = popupName;
    form.action = url;
    for (keyName in valueObjects) {
    	var param = CreateHiddenElement(keyName, valueObjects[keyName]);
    	form.appendChild(param);
    }
    document.body.appendChild(form);
    var openWindow = window.open("",popupName,"width="+width+"px height="+height+"px "+stat)
    form.submit();
    openWindow.focus();
    document.body.removeChild(form);
}

function CreateHiddenElement(name,value) {
    var param = document.createElement("input");
    param.setAttribute("type", "hidden");
    param.setAttribute("name", name);
    param.setAttribute("value", value);
    return param;
}
//이메일 유효성 체크
function G_VerificationEmail(email){
	var regEmail = /([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
	if( !regEmail.test(email) ){
        return false;
    }
	return true;
}
//날짜 포멧팅 : yyyymmdd -> yyyy-mm-dd
function G_formatDate(date){
	var result = "";
	var year  = "";
	var month = "";
	var day   = "";
	if( date.length == 8 ){
		year  = date.substring(0,4);
		month = date.substring(4,6);
		day   = date.substring(6,8);
		result = [year, month, day].join('-');
	}
	return result;
}
//페이징 POST
function G_MovePage(pageNo){
	var moveUrl = $(location).attr("pathname");
	var objForm = $("<form/>").attr({
		"id"     : "GLOVAL_PAGE_FORM",
		"name"   : "GLOVAL_PAGE_FORM",
		"action" : moveUrl,
		"target" : "_self",
		"method" : "POST"
	});

	/*input,select 페이징 유지 작업[2024.06.04]*/
	$('input, select, textarea').each(function(){
        var name  = $(this).attr('name');
        var value = $(this).val();

        if(typeof name !== "undefined" && value != null && value.length > 0) $("<input/>").attr({"type":"hidden", "id":name, "name":name, "value":value}).appendTo(objForm);
    });

	/*$("<input/>").attr({"type":"hidden","id":"searchfield","name":"searchfield","value":$("#searchfield").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"searchword","name":"searchword","value":$("#searchword").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"sDateStart","name":"sDateStart","value":$("input[name=sDateStart]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"sDateEnd","name":"sDateEnd","value":$("input[name=sDateEnd]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_date_start","name":"s_date_start","value":$("input[name=s_date_start]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_date_end","name":"s_date_end","value":$("input[name=s_date_end]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"eduSeq","name":"eduSeq","value":$("input[name=eduSeq]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"seq","name":"seq","value":$("input[name=seq]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"chk","name":"chk","value":$("input[name=chk]").val()}).appendTo(objForm);

	$("<input/>").attr({"type":"hidden","id":"s_eval_tp_1","name":"s_eval_tp_1","value":$("input[name=s_eval_tp_1]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_eval_status_cd","name":"s_eval_status_cd","value":$("input[name=s_eval_status_cd]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_org_nm_1","name":"s_org_nm_1","value":$("input[name=s_org_nm_1]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_assign_tp","name":"s_assign_tp","value":$("input[name=s_assign_tp]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_assign_nm_1","name":"s_assign_nm_1","value":$("input[name=s_assign_nm_1]").val()}).appendTo(objForm);
	
	$("<input/>").attr({"type":"hidden","id":"planYear","name":"planYear","value":$("input[name=planYear]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"planMonth","name":"planMonth","value":$("input[name=planMonth]").val()}).appendTo(objForm);

	if( $("input[name=noticeNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"noticeNo","name":"noticeNo","value":$("input[name=noticeNo]").val()}).appendTo(objForm);
	if( $("input[name=assignNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"assignNo","name":"assignNo","value":$("input[name=assignNo]").val()}).appendTo(objForm);
	if( $("input[name=assignAppNo]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"assignAppNo","name":"assignAppNo","value":$("input[name=assignAppNo]").val()}).appendTo(objForm);
	if( $("input[name=assignAppConfigNo]").length > 0 )			$("<input/>").attr({"type":"hidden","id":"assignAppConfigNo","name":"assignAppConfigNo","value":$("input[name=assignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=stepNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"stepNo","name":"stepNo","value":$("input[name=stepNo]").val()}).appendTo(objForm);
	if( $("input[name=layerStepYn]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"layerStepYn","name":"layerStepYn","value":$("input[name=layerStepYn]").val()}).appendTo(objForm);
	if( $("input[name=subTabNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"subTabNo","name":"subTabNo","value":$("input[name=subTabNo]").val()}).appendTo(objForm);
	if( $("input[name=resultUrl]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"resultUrl","name":"resultUrl","value":$("input[name=resultUrl]").val()}).appendTo(objForm);
	if( $("input[name=configTp]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"configTp","name":"configTp","value":$("input[name=configTp]").val()}).appendTo(objForm);
	if( $("input[name=pre_pAssignAppConfigNo]").length > 0 )	$("<input/>").attr({"type":"hidden","id":"pre_pAssignAppConfigNo","name":"pre_pAssignAppConfigNo","value":$("input[name=pre_pAssignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=pAssignAppConfigNo]").length > 0 )		$("<input/>").attr({"type":"hidden","id":"pAssignAppConfigNo","name":"pAssignAppConfigNo","value":$("input[name=pAssignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=assignDtlNm]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"assignDtlNm","name":"assignDtlNm","value":$("input[name=assignDtlNm]").val()}).appendTo(objForm);
	if( $("input[name=assignTp]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"assignTp","name":"assignTp","value":$("input[name=assignTp]").val()}).appendTo(objForm);
	if( $("input[name=layerIndex]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"layerIndex","name":"layerIndex","value":$("input[name=layerIndex]").val()}).appendTo(objForm);
	if( $("input[name=selectorIndex]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"selectorIndex","name":"selectorIndex","value":$("input[name=selectorIndex]").val()}).appendTo(objForm);

	$("<input/>").attr({"type":"hidden","id":"list_show_cnt","name":"list_show_cnt","value":$("#list_show_cnt").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"noticeNo","name":"noticeNo","value":$("#noticeNo").val()}).appendTo(objForm);*/

	$("<input/>").attr({"type":"hidden","id":"page","name":"page","value":pageNo}).appendTo(objForm);
	$(document.body).append(objForm);
	objForm.submit();
}
//빈객체 여부
function G_IsEmpty(obj){
	if( obj == undefined ){
		return true;
	}else if( obj == "" ){
		return true;
	}else if( obj == " " ){
		return true;
	}else if( obj == "null" ){
		return true;
	}
	return false;
}

//글자수 제한
function fn_TextCount_Init(defaultLimit, textLimit, textAreaId){
	$("textarea").each(function(){
		var limit = ($(this).attr("id") === textAreaId) ? textLimit : defaultLimit;
		$(this).attr("onkeyup","fn_TextCount('" + textAreaId + "'," + limit + ",this);");
		$(this).attr("maxlength",limit);
		$(this).after("<p class='textarea_count'><em>0자</em> / <br>" + limit + "자</p>");
	});
}

function fn_TextCount(textAreaId, textLimit, e){
	let ObjContent = $(e);
	let ObjTextLen = ObjContent.parent().find('em');
	let content = ObjContent.val();
	
	//속성 부여
	ObjTextLen.css("color", content.length >= textLimit ? "	#FF0000" : "#338DCD");
    
    // 글자수 세기
	ObjTextLen.text((content.length == 0 || content == '') ? '0' : content.length + '자');
    
    // 글자수 제한
    if (content.length > textLimit) {
    	// textLimit자 부터는 타이핑 되지 않도록
    	ObjContent.val(content.substring(0, textLimit));
        ObjTextLen.text(textLimit + '자');
        // textLimit자 넘으면 알림창 뜨도록
        alert("글자수는 "+ textLimit+"자까지 입력 가능합니다.");
        
    };
}

//바이트 수 계산 함수 (UTF-8 기준)
//function getValueByte(s) {
//    return new TextEncoder().encode(s).length;
//}

//바이트 수 계산 함수 (MS949 기준)
function getValueByte(s) {
	var nBytes = 0;
	for (var i = 0, txtLen = s.length; i < txtLen; i++) {
		var len = escape(s.charAt(i)).length;
		nBytes += (len > 3) ? ((len / 3)) : 1;
	}
	return nBytes;
}

//글자수 제한 (바이트 기준)
/*function fn_TextCount_Byte_Init(defaultLimit, textLimit, textAreaId){
	$("textarea").each(function(){
		var limit = ($(this).attr("id") === textAreaId) ? textLimit : defaultLimit;
		$(this).attr("onkeyup","fn_TextCount_Byte('" + textAreaId + "'," + limit + ",this);");
		console.log($(".info_msg").find("p"));
		$(".info_msg").find("p").after("<p><em class='text_theme'>0</em> / " + limit + "byte</p>");
	});
}*/

//글자수 제한 (바이트 기준)
function getValueByteLimit(str, limit_byte) {
	var result = "";
	var byte_value = limit_byte - getValueByte(str);
	var temp_str = str;
	if (byte_value < 0) {
		while (byte_value < 0) {
			temp_str = temp_str.substring(0, temp_str.length - 1);
			result = temp_str;
			byte_value = limit_byte - getValueByte(temp_str);
		}
	}
	return result;
}

//function fn_TextCount_Byte(textAreaId, textLimit, e){
//	let ObjContent = $(e);
//	let ObjTextLen = ObjContent.parent().find('em');
//	let content = ObjContent.val();
//	let byteLength = getValueByte(content);
//	
//	// 속성 부여 (제한 초과 시 빨간색)
//	ObjTextLen.css("color", byteLength > textLimit ? "#FF0000" : "#338DCD");
//
//    // 바이트 수 표시
//	ObjTextLen.text(byteLength);
//
//    // 바이트 제한 초과 시 처리
//    while (byteLength > textLimit) {
//        content = content.slice(0, -1); // 마지막 글자 제거
//        byteLength = getValueByte(content); // 다시 바이트 계산
//    }
//
//    // 입력된 값 수정
//    ObjContent.val(content);
//    
//    // 초과 시 알림
//    if (byteLength >= textLimit) {
//        alert("입력 가능한 최대 바이트는 " + textLimit + "바이트입니다.");
//    }
//}

//파일 입력 변경 이벤트
function file_limit(){
	$('#fileSelectButton').click(function(e) {
        e.preventDefault();
        $('#fileNo1').click();
    });

	$('input[type=file]').change(function() {
	    var fileVal = $(this).val().split('\\').pop();
	    var ext = fileVal.split('.').pop().toLowerCase(); // 확장자 분리
	    var validExtensions = ['pdf', 'pdfx', 'hwp', 'hwpx', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png', 'gix', 'zip'];
	    let maxSize = 10 * 1024 * 1024; //* 10MB 사이즈 제한
	    let fileSize = this.files[0].size; //업로드한 파일용량

	    // 확장자 검사
	    if ($.inArray(ext, validExtensions) == -1) {
	        alert('해당 파일 유형은 보안 사유로 허용되지 않습니다.\n ※허용 확장자명 : zip, pdf, hwp, hwpx, doc, docx, ppt, pptx , jpg, png, gif \n ※ 파일 크기 제한 : 10.00MB');
	        $(this).val(""); // 선택된 파일 초기화
	        $('#fileName').text('선택된 파일이 없습니다.');
	    } else if(fileSize > maxSize){
			alert("※ 파일 크기 제한 : 10.00MB");
			$(this).val(''); //업로드한 파일 제거
			$('#fileName').text('선택된 파일이 없습니다.');
			return; 
		} else {
	        $('#fileName').text(fileVal);
	    }
	    
	});
	
	//파일 특수문자 확인
	//fn_regx();
}

//파일 특수문자 확인
function fn_regx(){
	$('input[type=file]').change(function() {
		//파일명에 특수문자 검사 (정규 표현식 사용)
		var fileName = $(this).val().split("\\").pop(); // 파일 경로에서 파일명 추출
		var specialChars = /[*|\":<>{}`\\';@&$]/; // 특수문자를 나타내는 정규 표현식
	
		//파일명에 특수문자 체크
		if (specialChars.test(fileName)) {
			alert("파일명에 특수문자가 포함되어 있습니다. 특수문자를 제거해주세요. \n ※");
			$(this).val(''); // 파일 선택 필드 초기화
			$('#fileName').text('선택된 파일이 없습니다.');
			return false;
		}
	});
}


//인앱 관련 처리([참고]https://burndogfather.com/271)
function inappdeny(){ 
	var inappdeny_exec_vanillajs = (callback) => {
		if(document.readyState != 'loading'){
			callback();
		}else{
			document.addEventListener('DOMContentLoaded', callback);
		} 
	}
	inappdeny_exec_vanillajs(() => { 
		/* Do things after DOM has fully loaded */ 
		function copytoclipboard(val){
			var t = document.createElement("textarea");
			document.body.appendChild(t);
			t.value = val;
			t.select();
			document.execCommand('copy');
			document.body.removeChild(t);
		};
		function inappbrowserout(){
			copytoclipboard(window.location.href);
			alert('URL주소가 복사되었습니다.\n\nSafari가 열리면 주소창을 길게 터치한 뒤, "붙여놓기 및 이동"를 누르면 정상적으로 이용하실 수 있습니다.');
			location.href='x-web-search://?';
		};
	
		var useragt = navigator.userAgent.toLowerCase();
		var target_url = location.href + "?IsKakaoNotiClick=Y";
		
		if(useragt.match(/kakaotalk/i)){
			
			//카카오톡 외부브라우저로 호출
			location.href = 'kakaotalk://web/openExternal?url='+encodeURIComponent(target_url);
			window.close();
			
		}else if(useragt.match(/line/i)){
			
			//라인 외부브라우저로 호출
			if(target_url.indexOf('?') !== -1){
				location.href = target_url+'&openExternalBrowser=1';
			}else{
				location.href = target_url+'?openExternalBrowser=1';
			}
			
		}else if(useragt.match(/inapp|naver|snapchat|wirtschaftswoche|thunderbird|instagram|everytimeapp|whatsApp|electron|wadiz|aliapp|zumapp|iphone(.*)whale|android(.*)whale|kakaostory|band|twitter|DaumApps|DaumDevice\/mobile|FB_IAB|FB4A|FBAN|FBIOS|FBSS|SamsungBrowser\/[^1]/i)){
			
			//그외 다른 인앱들
			if(useragt.match(/iphone|ipad|ipod/i)){
				
				//아이폰은 강제로 사파리를 실행할 수 없다 ㅠㅠ
				//모바일대응뷰포트강제설정
				var mobile = document.createElement('meta');
				mobile.name = 'viewport';
				mobile.content = "width=device-width, initial-scale=1, shrink-to-fit=no, user-scalable=no, minimal-ui";
				document.getElementsByTagName('head')[0].appendChild(mobile);
				//노토산스폰트강제설정
				var fonts = document.createElement('link');
				fonts.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap';
				document.getElementsByTagName('head')[0].appendChild(fonts);
				document.body.innerHTML = "<style>body{margin:0;padding:0;font-family: 'Noto Sans KR', sans-serif;overflow: hidden;height: 100%;}</style><h2 style='padding-top:50px; text-align:center;font-family: 'Noto Sans KR', sans-serif;'>인앱브라우저 호환문제로 인해<br />Safari로 접속해야합니다.</h2><article style='text-align:center; font-size:17px; word-break:keep-all;color:#999;'>아래 버튼을 눌러 Safari를 실행해주세요<br />Safari가 열리면, 주소창을 길게 터치한 뒤,<br />'붙여놓기 및 이동'을 누르면<br />정상적으로 이용할 수 있습니다.<br /><br /><button onclick='inappbrowserout();' style='min-width:180px;margin-top:10px;height:54px;font-weight: 700;background-color:#31408E;color:#fff;border-radius: 4px;font-size:17px;border:0;'>Safari로 열기</button></article><img style='width:70%;margin:50px 15% 0 15%' src='https://tistory3.daumcdn.net/tistory/1893869/skin/images/inappbrowserout.jpeg' />";
			
			}else{
				//안드로이드는 Chrome이 설치되어있음으로 강제로 스킴실행한다.
				location.href='intent://'+target_url.replace(/https?:\/\//i,'')+'#Intent;scheme=http;package=com.android.chrome;end';
			}
		}
	});
}

//모바일 체크
function isMobile(){
	return /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
}

//새 세션 저장
function newSessionStore(name,sUrl){
	sessionStorage.removeItem(name);
   	sessionStorage.setItem(name, sUrl ); // 저장
}

//NICE 인증결과
/*function fnCheckPlusResult(sMessage, sName, sResponseNumber, sMobileNo , sDupInfo , sConnInfo, userTp, sUrl ) {
	var newForm = $("<form/>").attr({
		"id"     : "frm_success",
		"name"   : "frm_success",
		"action" : sUrl,
		"target" : "_self",
		"method" : "POST"
	});
	$("<input/>").attr({"type":"hidden","id":"sMessage","name":"sMessage","value":sMessage}).appendTo(newForm);
	$("<input/>").attr({"type":"hidden","id":"writerNm","name":"writerNm","value":sName}).appendTo(newForm);
	$("<input/>").attr({"type":"hidden","id":"sResponseNumber","name":"sResponseNumber","value":sResponseNumber}).appendTo(newForm);
	$("<input/>").attr({"type":"hidden","id":"sMobileNo","name":"sMobileNo","value":sMobileNo}).appendTo(newForm);
	$("<input/>").attr({"type":"hidden","id":"sDupInfo","name":"sDupInfo","value":sDupInfo}).appendTo(newForm);
	$("<input/>").attr({"type":"hidden","id":"sConnInfo","name":"sConnInfo","value":sConnInfo}).appendTo(newForm);
	
	if(sUrl == "/front/member/joinStep3.do") {
		$("<input/>").attr({"type":"hidden","id":"userTp","name":"userTp","value":userTp}).appendTo(newForm);
	}

	newForm.appendTo('body');
	newForm.submit();
}*/

//이메일 뒷부분 @ 입력제한
$(document).ready(function() {
    $('#email1').on('keydown', function(e) {
        if (e.key === '@') {
            e.preventDefault();
        }
    });
    $('#email_id').on('keydown', function(e) {
        if (e.key === '@') {
            e.preventDefault();
        }
    });
    $('#email2').on('keydown', function(e) {
        if (e.key === '@') {
            e.preventDefault();
        }
    });
    $('#email_domain').on('keydown', function(e) {
        if (e.key === '@') {
            e.preventDefault();
        }
    });
});

//date yyyy-mm-dd format (2024.06.05. KKH , 2024.07.15. KKH date null 로직 추가)
function DateFormat(date) {
	if(date == null) {
	    var today = new Date();
	    var year = today.getFullYear();
	    var month = String(today.getMonth() + 1).padStart(2, '0');
	    var day = String(today.getDate()).padStart(2, '0');
	    return year + '-' + month + '-' + day;
	} else {
		var year = date.getFullYear();
	    var month = (date.getMonth() + 1).toString().padStart(2, '0');
	    var day = date.getDate().toString().padStart(2, '0');
	    return year + '-' + month + '-' + day;
	}
}


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