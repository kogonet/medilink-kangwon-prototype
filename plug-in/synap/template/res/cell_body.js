// Todo... 차트 관련 변수를 채워야함
// cell_body.js
console.log ( 'cell_body.js' );
var	chart_startIdx = 0;
var	chart_endIdx = 0;
var	chart_svgPath = '';

function initDefault() {

}

// CHART
localSynap.chart_startIdx = 0;
localSynap.chart_endIdx = 0;
localSynap.chart_svgPath = '';
localSynap.browser_height = null;
localSynap.interval_id = null;

localSynap.updateChartInfo = function(startIdx, endIdx, svgPath) {
	localSynap.chart_startIdx = startIdx;
	localSynap.chart_endIdx = endIdx;
	localSynap.chart_svgPath = svgPath;
};

window.onload = function() {
	//getInnerHeight -> docviewer.js=>synapScroll.js
	localSynap.browser_height = window.innerHeight;
	if (localSynap.browser_height == undefined) {
		localSynap.browser_height = screen.height;
	}

	if (BROWSER.MOBILE.isIOS()) {
		localSynap.browser_height *= 1.5; // iOS 일 경우 scale 문제로 1.5배 적용
	}

	if (localSynap.chart_endIdx != 0){
		localSynap.interval_id = window.setInterval(localSynap.scrolling_chart, 1000);
	}
	drawCmtLine();
};

localSynap.interval_chart = function() {
	var i = localSynap.chart_startIdx;
	var chart_id = "chart"+i;
	var chart_obj = document.getElementById(chart_id);

	if (chart_obj != undefined) {
		var url = chart_id + '.xml.svg';
		if(chart_svgPath!="") {
			url = chart_svgPath + '/' + url;
		}

		var chart_top    = chart_obj.offsetTop;
		var chart_width  = chart_obj.offsetWidth;
		var chart_height = chart_obj.offsetHeight;

		localSynap.dynamic_loding_chart(chart_obj, chart_width, chart_height, url);
	}

	localSynap.chart_startIdx += 1;
	if (localSynap.chart_startIdx > localSynap.chart_endIdx) {
		window.clearInterval(localSynap.interval_id);
	}
};

localSynap.scrolling_chart = function() {
	var now_scroll = $(document).scrollTop();

	for(var i = localSynap.chart_startIdx; i <= localSynap.chart_endIdx; i++) {
		var chart_id = "chart"+i;
		var chart_obj = document.getElementById(chart_id);
		if (chart_obj != undefined) {
			var url = chart_id + '.xml.svg';
			if(chart_svgPath!="") {
				url = chart_svgPath + '/' + url;
			}

			var chart_top    = chart_obj.offsetTop;
			var chart_width  = chart_obj.offsetWidth;
			var chart_height = chart_obj.offsetHeight;

			if (chart_top > now_scroll - localSynap.browser_height && chart_top < now_scroll + localSynap.browser_height) {
				localSynap.dynamic_loding_chart(chart_obj, chart_width, chart_height, url);
			}
		}
	}

	if($('.synap_loading_chart').length == 0) {
		window.clearInterval(localSynap.interval_id);
	}
};

localSynap.dynamic_loding_chart = function(chart_obj, width, height, url) {
	// 차트 동적 로딩 IE object 태그 제거
	if ($(chart_obj).attr('class') == "synap_loading_chart") {
		chart_obj.innerHTML = "<object type='image/svg+xml' class='svg' width='"+(width+1)+"px' height='"+(height+1)+"px' align='middle' data='"+url+"'></object>";
		$(chart_obj).attr('class','');
	}
};

localSynap.killCopyContent = function() {
	if(BROWSER.isMobile()) {
		var mainContainer = document.getElementById('container');
		var mainTable = document.getElementById('mainTable');
		stopBrowserEvent(mainContainer);		
		stopBrowserEvent(mainTable);
	} else {
		stopBrowserEvent(document);
	}	
};

localSynap.updateValid = function() {
	var loadCellMaximum = 100;
	
	var $td = $('#mainTable').find('table td');
	var length = $td.length;
	var loadCell = function(s , e){
		return function(){
			if( s >= length ) {
				localSynap.onLoadBody && localSynap.onLoadBody();
				return;
			}
			if( e >= length ) e = length;
			for( var j = s ; j < e ; j ++ ){
				if( $td.eq(j).width() === 0 ){
					$td.eq(j).find('span').css('white-space', 'nowrap');
				}
			}
			setTimeout(loadCell(s + loadCellMaximum, e + loadCellMaximum), 10);
		}
	};
	loadCell(0, loadCellMaximum)();
};

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

	if (!(typeof localSynap.updateValid == "undefined")) {
		localSynap.updateValid();
	}
	initDefault();
	if (!(typeof localSynap.updateChartInfo == "undefined")) {
		localSynap.updateChartInfo(chart_startIdx, chart_endIdx, chart_svgPath);	
	}
	
	if( localSynap.config && !localSynap.config.allowCopy ){
		localSynap.killCopyContent();
	}
	
	localSynap.bodyReadySkinFunc && localSynap.bodyReadySkinFunc();
};

function wmXml() {
	wm.decrypt(jsValue, "cell");
	wm.setTile(true);
}

function appendWM() {
    var	boardWidth = $("#mainTable").width();
    var	boardHeight = $("#mainTable").height();
    wm.appendWM_cell(boardWidth, boardHeight);
}

function drawLine(targetCell, targetCmt) {
	var headSize = 6;
	var draw = function(x, y, width, height, isSlash, isHeadEnd) {
		var svg = document.createElementNS("http://www.w3.org/2000/svg","svg");
		svg.setAttribute("width", width);
		svg.setAttribute("height", height);
		svg.style.position = 'absolute';
		svg.style.overflow = 'visible';
		svg.style.left = x + 'px';
		svg.style.top = y + 'px';
		svg.style.pointerEvents = 'none';
		
		var def = document.createElementNS("http://www.w3.org/2000/svg","defs");
		svg.appendChild(def);
		var marker = document.createElementNS("http://www.w3.org/2000/svg","marker");
		marker.id = "head";
		marker.setAttribute("markerWidth", headSize);
		marker.setAttribute("markerHeight", headSize);
		marker.setAttribute("refX", "0");
		marker.setAttribute("refY", headSize/2);
		marker.setAttribute("orient", "auto");
		def.appendChild(marker);
		var polygon = document.createElementNS("http://www.w3.org/2000/svg","polygon");
		polygon.setAttribute("points", "0 0, " + headSize + " " + headSize/2 + ", 0 " + headSize);
		marker.appendChild(polygon);
		
		var line = document.createElementNS("http://www.w3.org/2000/svg","line");
		line.setAttribute("stroke", "rgb(0,0,0)");
		line.setAttribute("stroke-width", 1);
		line.setAttribute("marker-end", "url(#head)");
		
		if (isSlash) { // slash
			if(isHeadEnd) {
				line.setAttribute("x1", "0");
				line.setAttribute("y1", "100%");
				line.setAttribute("x2", "100%");
				line.setAttribute("y2", "0");
			} else {
				line.setAttribute("x1", "100%");
				line.setAttribute("y1", "0");
				line.setAttribute("x2", "0");
				line.setAttribute("y2", "100%");
			}
		} else { // backslash
			if(isHeadEnd) {
				line.setAttribute("x1", "0");
				line.setAttribute("y1", "0");
				line.setAttribute("x2", "100%");
				line.setAttribute("y2", "100%");
			} else {
				line.setAttribute("x1", "100%");
				line.setAttribute("y1", "100%");
				line.setAttribute("x2", "0");
				line.setAttribute("y2", "0");
			}
		}
		svg.appendChild(line);
		document.body.appendChild(svg);
	}
	var startX = targetCell.offsetLeft + targetCell.offsetWidth;
	var startY = targetCell.offsetTop;
	var endX = targetCmt.offsetLeft;
	var endY = targetCmt.offsetTop;
	var cmtWidth = targetCmt.offsetWidth;
	var cmtHeight = targetCmt.offsetHeight;
	if(startX < endX) {
		var slashWidth = endX - startX;
		var slashHeight = Math.abs(startY - endY);
		draw(startX, Math.min(startY, endY), slashWidth, slashHeight, startY > endY, false);
	} else {
		var slashWidth = Math.abs(startX - (endX + cmtWidth));
		if(startY > endY + cmtHeight) {
			var slashHeight = Math.abs(startY - (endY + cmtHeight));
			if(startX > endX + cmtWidth) {
				draw(endX + cmtWidth - headSize, endY + cmtHeight - headSize/2, slashWidth, slashHeight, false, true);
			} else {
				draw(startX, endY + cmtHeight - headSize/2, slashWidth, slashHeight, true, false);
			}
		} else {
			var slashHeight = Math.abs(endY - startY);
			if(startX > endX + cmtWidth) {
				draw(endX + cmtWidth - headSize, startY + headSize/2, slashWidth, slashHeight, true, true);
			} else {
				draw(startX, startY + headSize/2, slashWidth, slashHeight, false, false);
			}
		}
	}
}

function drawCmtLine() {
	var cmtCells = document.getElementsByClassName("commentCell");
	for(var i = 0; i < cmtCells.length; i++) {
		var cmtId = cmtCells[i].id.substring("mark_".length);
		var targetCmt = document.getElementById(cmtId);
		var targetCell = cmtCells[i].parentNode;
		targetCmt.style.display !== "none" && drawLine(targetCell, targetCmt.childNodes[0]);
	}
}

// DOCUMENT READY FUNC
$(document).ready(function() {
	localSynap.contentReadyFunc();
	if(jsValue!=""){
		if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
			appendWM();
			$("#mainTable").css("visibility","visible");
		}
		else {
			alert("Not support current browser");
		}
	}
});
