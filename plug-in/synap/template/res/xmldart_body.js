// xmldart_body.js
console.log ( 'xmldart_body.js' );

window.onload = function() {
    localSynap.browser_height = window.innerHeight;
    if (localSynap.browser_height == undefined) {
        localSynap.browser_height = screen.height;
    }

    if (BROWSER.MOBILE.isIOS()) {
        localSynap.browser_height *= 1.5; // iOS 일 경우 scale 문제로 1.5배 적용
    }
}

// 복사 방지
localSynap.killCopyContent = function() {
    if(BROWSER.isMobile()) {
        var mainContainer = document.getElementById('container');
        var contentBody = document.getElementById('content_body');
        stopBrowserEvent(mainContainer);		
        stopBrowserEvent(contentBody);
    } else {
        stopBrowserEvent(document);
    }	
}

// 현재 문서(xhtml)으로부터 원본 파일명을 구한다. wm.decrypt() 에서 사용
localSynap.getFileName = function() {
    var url = document.location.pathname;
    url = url.split('/').pop(); // xxxx.xml.view.xhtml
    url = url.substr(0, url.lastIndexOf(".")); // xxxx.xml.view
    return url.substr(0, url.lastIndexOf(".")); // xxxx.xml
}

function wmXml() {
    wm.decrypt(jsValue, "xmldart");
    wm.setTile(true);
}

// content가 로드된 후 동작시킬 함수
localSynap.contentReadyFunc = function() {
    if(jsValue != "") {
        if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
            wmXml();
        }
        else {
            $("body").empty();
            return;
        }
    }

    window.onscroll = function(e){
        localSynap.onScroll && localSynap.onScroll(e);
    }

    if( localSynap.config && !localSynap.config.allowCopy ){
        localSynap.killCopyContent();
    }
}

function appendWM() {
    var	boardWidth = getMaxWidth("table");
    var	boardHeight = document.getElementById('content_body').offsetHeight;
    wm.appendWM_cell(boardWidth, boardHeight);
}

// DOCUMENT READY FUNC
$(document).ready(function() {
    localSynap.contentReadyFunc();
    if(jsValue!=""){
        if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
            appendWM();
            $("#container").css("visibility","visible");
        }
        else {
            alert("Not support current browser");
        }
    }
});
