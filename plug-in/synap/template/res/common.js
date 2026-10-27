
// common.js
if(!window.console) {
window.console = {};
window.console.log = function(str) {};
window.console.dir = function(str) {};
}

// 복사방지 스크립트 Start
function stopDefaultEvent(sEvent, el, fn) {
	if (el.addEventListener) {
		el.addEventListener(sEvent, fn);
	} else {
		if (el.attachEvent) {
			el.attachEvent("on" + sEvent, fn);
		}
	}
}

function stopEvent(e) {
	e = e || window.event;

	if (typeof e.preventDefault != "undefined") e.preventDefault();
	if (typeof e.stopPropagation != "undefined") e.stopPropagation();

	e.returnValue = false;
	return false;
}

function stopMobileTouchEvent(el) {
	if(typeof el.setAttribute != 'undefined' && el.tagName !== 'body') {
		el.setAttribute('style', el.getAttribute('style') + '-webkit-touch-callout:none;-webkit-user-select:none;-khtml-user-select:none;-moz-user-select:none;user-select:none;-webkit-tap-highlight-color:rgba(0,0,0,0);');
	}else if( typeof el.setAttribute != 'undefined' && el.tagName === 'body' ){
		el.setAttribute('style', el.getAttribute('style') + '-webkit-touch-callout:none;-webkit-user-select:none;-khtml-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;-webkit-tap-highlight-color:rgba(0,0,0,0);');
	}
}

function stopBrowserEvent(el) {
	stopDefaultEvent("selectstart", el, stopEvent);
	stopDefaultEvent("dragstart", el, stopEvent);
	stopDefaultEvent("contextmenu", el, stopEvent);
	// 모바일에서 필요한 이벤트 stopDefaultEvent("mousedown", el, stopEvent);	
	stopMobileTouchEvent(el);
}

// 복사방지 스크립트 End

// IMG ERROR
function image_error(obj) {
	obj.title = 'Not suppported image format.';
	obj.style.visibility = 'hidden';
} 

function loadSpinner(targetId, pageClassName){
	$('.loading_spinner').remove();
		
	var opts = {
	  lines: 11 // The number of lines to draw
	, length: 0 // The length of each line
	, width: 12 // The line thickness
	, radius: 30 // The radius of the inner circle
	, scale: 1.25 // Scales overall size of the spinner
	, corners: 0.5 // Corner roundness (0..1)
	, color: '#435c85' // #rgb or #rrggbb or array of colors
	, opacity: 0.25 // Opacity of the lines
	, rotate: 0 // The rotation offset
	, direction: 1 // 1: clockwise, -1: counterclockwise
	, speed: 5 // Rounds per second
	, trail: 65 // Afterglow percentage
	, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
	, zIndex: 2e9 // The z-index (defaults to 2000000000)
	, className: 'spinner' // The CSS class to assign to the spinner
	, top: '50%' // Top position relative to parent
	, left: '50%' // Left position relative to parent
	, shadow: false // Whether to render a shadow
	, hwaccel: false // Whether to use hardware acceleration
	, position: 'absolute' // Element positioning
	}
	var target = document.createElement('div'); target.setAttribute('id', 'div_page'); target.setAttribute('class', 'inner loading_spinner ' + pageClassName);
	document.getElementById(targetId).appendChild(target);
	var spinner = new Spinner(opts).spin(target);
}

function removeSpinner(){
	$('.loading_spinner').remove();
}

// 문자열을 HTML특수문자로 변환해준다.
function encodeHTML(str) {
    var el = document.createElement("div");
    el.innerText = el.textContent = str;
    str = el.innerHTML;
    return str;
}

function getPtToPx(size_pt){
	return (size_pt * (96/72));
}

function getPxToPt(size_px){
	return (size_px * (72/96));
}

/**
 * selector 중에서 가장 큰 width를 구한다
 * @param selector	css 선택자
 * @returns 		최대 width값
 */
function getMaxWidth(selector) {
	var highestWidth = 0;
	$(selector).each(function() { 
		var element_width = $(this).width();
		if(element_width > highestWidth) {
			highestWidth = element_width;
		}
	});
	return highestWidth;
}

// IE8이하에 없어서 구현한다
if (!Array.indexOf) {
    Array.prototype.indexOf = function (obj, start) {
        for (var i = (start || 0); i < this.length; i++) {
            if (this[i] == obj) {
                return i;
            }
        }
        return -1;
    }
}

// convert array value to UTF8 String
function arrToString(arr) {
	if (!arr) {
		return arr;
	}
	var result = "";
	var c1, c2, c3, c4, shift;
	for (var i = 0; i < arr.length;) {
		c1 = arr[i++];
		shift = c1 >> 4;
		if (shift < 8) {
			result += String.fromCharCode(c1);
		} else if (shift == 12 || shift == 13) {
			c2 = arr[i++];
			result += String.fromCharCode(((c1 & 0x1F) << 6) | (c2 & 0x3F));
		} else if (shift == 14) {
			c2 = arr[i++];
			c3 = arr[i++];
			result += String.fromCharCode(
				((c1 & 0x0F) << 12) |
				((c2 & 0x3F) << 6) |
				((c3 & 0x3F) << 0)
			);
		} else if(shift == 15){ // surrogate 
			c2 = arr[i++];
			c3 = arr[i++];
			c4 = arr[i++];
			result += String.fromCodePoint(
				((c1 & 0x07) << 18) |
				((c2 & 0x3F) << 12) |
				((c3 & 0x3F) << 6) |
				(c4 & 0x3F)
			);
		}
	}
	return result;
}

function preventPrint() {
	if (localSynap.config && localSynap.config.preventPrint) {
		
		var head = document.getElementsByTagName('head')[0];

		if (head != null){
			var style_tag = document.createElement('style');
			style_tag.type = 'text/css';

			if (BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9) {
				style_tag.styleSheet.cssText = "@media print{ body { display:none; } }"
			}else {
				style_tag.textContent = "@media print{ body { display:none; } }"
			}
			head.appendChild(style_tag);
		}
	}
}

// 스킨 사용 유무에 상관 없이 인쇄방지 동작을 지원하기 위하여, 특이케이스로 common.js에서 함수를 호출하게 되었습니다.
// 왠만하면 common.js에서는 공통으로 사용되는 함수를 정의만하고, 다른 스크립트에서 호출하도록 합시다.   
$(document).ready(function(){
	preventPrint();
});

// 유닛테스트용
if (typeof exports !== "undefined") {
    exports.localSynap = localSynap;
}
