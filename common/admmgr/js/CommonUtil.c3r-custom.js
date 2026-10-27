/***************************************************
 * DESC : 공통 유틸 정리
 **************************************************/
var G_Util = {
	//글자수 Byte 제한 (textAreaId,textLenId,글자수제한수)
	getTextCnt : function(oTextArea,oTextLen,textLimit){
		var str     = $(oTextArea).val();
		var str_len = str.length;
		var iByte = 0;
		var rlen  = 0;
		var one_char = "";
		var str2 = "";
		for( var i=0; i<str_len; i++ ){
			one_char = str.charAt(i);
			if(escape(one_char).length > 4) {
				iByte += 2;//한글2Byte
			}else{
				iByte++;//영문 등 나머지 1Byte
			}
			if(iByte <= textLimit){
				rlen = i+1;//return할 문자열 갯수
			}
		}
		if( iByte > textLimit ){
			alert("최대 " + textLimit + "byte를 초과할 수 없습니다.");
			str2 = str.substr(0,rlen);
			$(oTextArea).val(str2);
			G_Util.getTextCnt(oTextArea,oTextLen,textLimit);
		}else{
			$(oTextLen).text(iByte);
		}
	},
	//글자수 제한 (textAreaId,textLenId,글자수제한수)
	getTextWordCnt : function(oTextArea,oTextLen,textLimit){
		var str     = $(oTextArea).val();
		var str_len = str.length;
		var iByte = 0;
		var iWord = 0;
		var rlen  = 0;
		var one_char = "";
		var str2 = "";
		for( var i=0; i<str_len; i++ ){
			one_char = str.charAt(i);
			if(escape(one_char).length > 4) {
				iByte += 2;//한글2Byte
			}else{
				iByte++;//영문 등 나머지 1Byte
			}
			if(iByte <= textLimit){
				rlen = i+1;//return할 문자열 갯수
			}
		}
		if( iByte > textLimit || rlen > (textLimit/2) ){
			alert("최대 " + (textLimit/2) + "자를 초과할 수 없습니다.");
			str2 = str.substr(0,(textLimit/2));
			$(oTextArea).val(str2);
			G_Util.getTextWordCnt(oTextArea,oTextLen,textLimit);
		}else{
			$(oTextLen).text(rlen);
		}
	},
	//이메일 유효성 체크
    isEmail(email){
        var regEmail = /([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
        if( !regEmail.test(email) ){
            return false;
        }
        return true;
    },
	//생년월일 유효성
    isBirth(birthday){
    	var result = true;
    	var regExp = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(\'\"]/gi;
    	birthday = birthday.replace(regExp,"");
    	if( birthday.length <=8 ){
    		var year   = Number(birthday.substr(0,4)); // 입력한 값의 0~4자리까지 (연)
    	    var month  = Number(birthday.substr(4,2)); // 입력한 값의 4번째 자리부터 2자리 숫자 (월)
    	    var day    = Number(birthday.substr(6,2)); // 입력한 값 6번째 자리부터 2자리 숫자 (일)
    	    var today  = new Date(); // 날짜 변수 선언
    	    var yearNow = today.getFullYear(); // 올해 연도 가져옴

    		// 연도의 경우 1900 보다 작거나 yearNow 보다 크다면 false를 반환합니다.
    	    if( 1900 > year || year > yearNow){
    	    	result = false;
    	    }else if( month < 1 || month > 12 ){
    	    	result = false;
    	    }else if( day < 1 || day > 31 ){
    	    	result = false;
    	    }else if( (month==4 || month==6 || month==9 || month==11) && day==31 ){
    	    	 result = false;
    	    }else if(month == 2 ){
    	       	var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
    	     	if( day>29 || (day==29 && !isleap) ){
    	     		result = false;
    			}
    	    }
    	}else{
    		result = false;
    	}
    	return result;
    },
	//Context Path
	getContextPath : function(){
		var hostIndex = location.href.indexOf( location.host ) + location.host.length;
		return location.href.substring( hostIndex, location.href.indexOf('/', hostIndex + 1) );
	},
	//금액[단독사용금지] : 천단위 콤마 생성
	setComma : function(arg){
		var result = String(arg);
		if( result != "" ){
			result = result.replace(/(\d)(?=(?:\d{3})+(?!\d))/g,"$1,");
		}
		return result;
	},
	//금액[단독사용금지] : 천단위 콤마 제거
	setUnComma : function(arg){
		var result = String(arg);
		if( result != "" ){
			result = result.replace(/[^\d]+/g,"");
		}
		return result;
	},
	//금액 : 입력시 콤마 생성
	inputComma : function(obj){
		var inputValue = $(obj).val();
		$(obj).val(G_Util.setComma(G_Util.setUnComma(inputValue)));
	},
	//숫자만 허용
	inputNumber : function(obj){
		var result = $(obj).val().replace(/[^0-9-]/g,"");
		$(obj).val(result);
	},
	//비율 : 소수점을 포함한 표현
	inputRate : function(obj){
		var tmps = $(obj).val().replace(/[^\.|^0(0)+|^0-9\.]/g,"");
		var arr = tmps.split(".");
		if( arr.length > 2 ){
			tmps = arr[0] + '.' + arr[1];
		}
        $(obj).val(tmps);
	},
	/** []Null체크 **/
	isEmpty : function( pObject, pPostObject ){
		var rValue;
		if( typeof pObject != "undefined" ){
			if( typeof pPostObject != "undefined" ){
				rValue = pObject;
			}else{
				if( pObject != "" && pObject != "null" && pObject != null )	rValue = false;
				else														rValue = true;
			}
		}else{
			if( typeof pPostObject != "undefined" ){
				rValue = pPostObject;
			}else{
				rValue = true;
			}
		}
		return rValue;
	},
	//Post Popup
	postPopup : function(popupName, url, width, height, valueObjects) {
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
}