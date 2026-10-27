function gcd(a,b) {
	var t;
	while(b) {
		a %= b;
		t=a; a=b; b=t;
	}
	return a;
}

function applyAlignBottom(obj, slideHeight){
	var nObjHeight = obj.clientHeight / slideHeight * 100;
	var nHeight = parseFloat(obj.style.height);
	var su = nObjHeight - nHeight;
	if(su > 0){
		obj.style.top = (parseFloat(obj.style.top) - su) + '%';
	}
}

function applyAlignCenter(obj, slideHeight){
	var nObjHeight = obj.clientHeight / slideHeight * 100;
	var nHeight = parseFloat(obj.style.height);
	var su = nObjHeight - nHeight;
	if(su > 0){
		obj.style.top = (parseFloat(obj.style.top) - (su / 2)) + '%';
	}
}

function applyTextBoxAlign(slideHeight){
	var objs = $('.AlignBottom');
	var nCount = objs.length;
	for (var i = 0; i < nCount; i++) {
		applyAlignBottom(objs[i], slideHeight);
	}
	var objs = $('.AlignCenter');
	var nCount = objs.length;
	for (var i = 0; i < nCount; i++) {
		applyAlignCenter(objs[i], slideHeight);
	}
}

function initFunction()
{
	var coordsize;
	slide_obj = $('slide, p\\:slide');
	if (slide_obj.length == 0) {
		coordsize = [localSynap.originalWidth, localSynap.originalHeight];
	} else {
		coordsize = slide_obj.attr('coordsize').split(',');
	}
	setVSlide(parseInt(coordsize[0]), parseInt(coordsize[1]));
	if ( BROWSER.PC.isIE() ) {
		applyTextBoxAlign($(window).height());
	}else{
		applyTextBoxAlign(self.innerHeight);
	}
	window.onresize = function() {
		resizeSlide();
	};
}


var originalWidth;
var originalHeight;
var originalFontSize;
var rx, ry;

function resizeSlide() {
	var currentWidth, currentHeight;
	var slideDiv = document.getElementById('slide');
	if (slideDiv.length == 0) {
		return;
	}
	var m = 1;
	if ( BROWSER.isMobile() ) {
		m = document.documentElement.clientWidth / rx;
	}else {
		m = $(window).width() / rx;
	}

	slideDiv.style.width = (rx * m) + 'px';
	slideDiv.style.height = (ry * m) + 'px';
	currentWidth = slideDiv.clientWidth;
	currentHeight = slideDiv.clientHeight;

	var zoomRatio = currentWidth*1. / originalWidth;
	if( currentHeight < originalHeight * zoomRatio ) {
		zoomRatio = currentHeight*1. / originalHeight;
	}

	var newFontSize = originalFontSize * zoomRatio;
	if( !BROWSER.PC.isIE() ) newFontSize *= 0.94;
	if( newFontSize < 1 ) newFontSize = 1;
	if( BROWSER.PC.isIE() ) {
		slideDiv.style.fontSize = newFontSize + 'px';
	} else {
		slideDiv.style.fontSize = newFontSize + 'px';
	}
}

// 로딩할때 한번만 슬라이드 크기에서 비율을 구한다.
function setVSlide(docWidth, docHeight) {
	var slideDiv = document.getElementById('slide');
	originalFontSize = parseInt(slideDiv.style.fontSize);
	if(docWidth == null) originalWidth = slideDiv.clientWidth;
	else originalWidth = docWidth;

	if(docHeight == null) originalHeight = slideDiv.clientHeight;
	else originalHeight = docHeight;
	
	rx = docWidth/gcd(docWidth,docHeight);
	ry = docHeight/gcd(docWidth,docHeight);

	resizeSlide();
}
// 슬라이드 스킨, body 공용 함수 End

function contentReadyFunc() {
	if(jsValue != "") {
		if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
			wmXml();
		}
		else {
			$("body").empty();
			alert("Not support current browser");
			return;
		}
	}
	initFunction();
	window.onresize = function() {
		resizeSlide();
	};
	$(window).on('orientationchange', function() {
		resizeSlide()
	});
	
	if( localSynap.config && !localSynap.config.allowCopy ){
		var slide = document.getElementById('slide');
		stopBrowserEvent(slide);
	}
	localSynap.onLoadBody && localSynap.onLoadBody();
	if(jsValue != "") {
		if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
			appendWM();
		}
	}
}

function getXml(fileName) {
	xmlUrl = '../' + fileName + '.xml';
	$.ajax({
		type: 'GET',
		async: false,
		url: xmlUrl,
		dataType: 'xml',
		success: parseXML
	});
};

function parseXML(xml) {
	localSynap.infoXml = xml;
	localSynap.originalWidth = parseInt($(localSynap.infoXml).find('width').text());
	localSynap.originalHeight = parseInt($(localSynap.infoXml).find('height').text());
	if(jsValue != "") {
		if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
			wm.decrypt(jsValue, "slide");
		}
	}
}

function addLoadEventListener(){
	if( window.addEventListener ){
		// IE 9버전 미만의 브라우저를 제외한 브라우저의 지원 코드
		window.addEventListener("DOMContentLoaded", contentReadyFunc);
	} else if( window.attachEvent ){
		// IE 9버전 미만
		document.attachEvent("onreadystatechange", function(){
			if(document.readyState === "complete"){
				contentReadyFunc();
			}
		});
	} else{
		// load event를 받지 못하는 경우
		setTimeout(contentReadyFunc, 1000);
	}
}

function getUrlExt(url){
	var strUrl = url.substr(url.lastIndexOf('/') + 1);
	var extName = strUrl.substr(strUrl.lastIndexOf(".")+1, strUrl.length);
	return extName;
}
function getUrlName(url){
	var strUrl = url.substr(url.lastIndexOf('/') + 1);
	return strUrl;
}

function getFileName() {
	var lastIndex = document.location.pathname.lastIndexOf('/');
	var startPos = document.location.pathname.lastIndexOf('/', lastIndex-1) + 1;
	var lastPos = lastIndex - startPos - 6; //.files
	return document.location.pathname.substr(startPos, lastPos);
}

function wmXml() {
	getXml(getFileName());
}

function appendWM() {
	localSynap.mark = wm.getWM();
	if(localSynap.mark != null) {
		var resizeScaleRatio = 2;
		var slideWidth = localSynap.originalWidth * resizeScaleRatio;
		var slideHeight = localSynap.originalHeight * resizeScaleRatio;
		var board = wm.makeWB(slideWidth, slideHeight, false);
		$("#slide").append(board);

		$(window).resize(function() {			
			var zoomRatio = $(window).width() / localSynap.originalWidth;
			wm.boardResize(board,slideWidth,slideHeight,zoomRatio/resizeScaleRatio);
			//모바일,edge에서 회전하면 offset의 위치가 변경되는 문제를 확인
			//강제로 0,0으로 변경한다.
			$(".wb").offset({top:0,left:0});
		}).resize();
	}
}

addLoadEventListener();
