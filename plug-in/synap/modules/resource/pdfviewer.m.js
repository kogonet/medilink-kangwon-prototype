var textAreaList = {};
var pageAreaList = [];
var xml = "";
var ratio = 1;
var currentPage = 1;
//var PAGE_NUMBER = 9;
var scrollTopValue = 0;
var xmlPages = [];
var thumWidth = 55;
var thumHeight = 75;
var imgExt = "png";
//var AJAX_URL = '';
var enableScrollEvent = true;
var isFocus = false;
var AjaxNum = 99999;
var isAjaxCall = false;
var pageLayout = 0;


var RATIO_NUMBERS = {
	curIndex : 3,
	numbers : [0.25, 0.5, 0.75, 1, 1.5, 2, 2.5],
	increaseRatio : function(){
		if (0 <= this.curIndex && this.curIndex < 6) {
			++this.curIndex;
		}
		return this.numbers[this.curIndex];
	},
	reduceRatio : function() {
		if (0 < this.curIndex && this.curIndex <= 6) {
			--this.curIndex;
		}
		return this.numbers[this.curIndex];
	},
	setRatioIndex : function(_ratio) {
		for (var i=0; i<this.numbers.length; i++) {
			if (this.numbers[i] > _ratio) {
				this.curIndex = i;
				break;
			}
		}
	}
};
/*
function resizeView() {
  pageElem = $('#page');
  var currentPageElem = $(xmlPages[currentPage - 1]);
  var pageSize = {'w':parseInt(currentPageElem.attr('w'), 10),
                  'h':parseInt(currentPageElem.attr('h'), 10)};
  if (pageSize.w * $(window).height() > $(window).width() * pageSize.h ) {
    pageElem.width(($(window).width() - 40) + 'px')
            .height((($(window).width() - 40) / pageSize.w * pageSize.h) + 'px');
  } else {
    pageElem.width((($(window).height() - 20) / pageSize.h * pageSize.w) + 'px')
            .height(($(window).height() - 20) + 'px');
  }
}
*/
function resizeView() {
  pageElem = $('#page');
  var currentPageElem = $(xmlPages[currentPage - 1]);
    localSynap.originalWidth = parseInt(currentPageElem.attr('w'), 10);
    localSynap.originalHeight = parseInt(currentPageElem.attr('h'), 10);
    localSynap.slideRatio = localSynap.originalHeight / localSynap.originalWidth;

  var currentWidth = $(window).width(),currentHeight = $(window).height();
  currentHeight -= 20;
	if (!localSynap.fullScreenMode) {
		currentHeight -= (getHeaderHeight());
	}
	
	zoomRatio = currentWidth / localSynap.originalWidth;
	if (localSynap.slideRatio > currentHeight / currentWidth) {
		zoomRatio = currentHeight / localSynap.originalHeight;
	}
	//zoomRatio *= 0.95;
	pageElem.width(localSynap.originalWidth * zoomRatio);
	pageElem.height(localSynap.originalHeight * zoomRatio);
}

function initLayout() {
}

function initEvent() {
  //$(document).scroll(function(){$('#footerButtons').css('top', $(window).height() - $('#footerButtons'). +  $(document).scrollTop());})
}

function loadPage() {
  $(xmlPages).each(function(pageIndex, element) {
      var tag = '<a href="#' + (pageIndex + 1) + 'page" title="page' + (pageIndex + 1) + '"><li><em class="icon listTxt">' + (pageIndex + 1) + '</em><span class="lH1">' + $(element).attr('title') + '</span></li></a>';
    $('#documentList').append(tag);
  });
  $('#documentList > *').each( function(index, elem) {
    var i = index + 1;
    elem.onclick = function(e) {
      e.preventDefault();
      movePage(i);
    };
  });
  changePaperPageNumber(1);
}


function getImgPositionData(addr)
{
	$.ajax(
		{
			type: "GET",
			url: addr,
			async: false,
			dataType: ($.browser.msie) ? "text" : "xml",
			error: function(data){
	  			//alert('Error occurred loading the XML');
	 		},
			success:function(data) {

				if (typeof data === "string") {
					xml = new ActiveXObject("Microsoft.XMLDOM");
					xml.async = false;
					xml.loadXML(data);
				} else {
					xml = data;
				}

				xmlPages = $(xml).find("page");
			}
		}
	);

// 크롬 지원을 위한 부분
//	if ($.browser.msie) {
//			var xml = new ActiveXObject("Microsoft.XMLDOM");
//			xml.loadXML(xmlData);
//			xmlPages = $(xml).find("page");
//	} else {
//		xmlPages = $(xmlData).find("page");
//	}
}




$(window).resize(function() {
	resizeView();
});

function changePaperPageNumber(pageNum) {
	//$("#paper-page-number").html(pageNum + ' / ' + PAGE_NUMBER);
	$(".prNavCurrent").html(pageNum);
  $('#documentList > *').removeClass('selected');
  $('#documentList > *:nth-child(' + (pageNum) + ')')
  	.addClass('selected');

	currentPage = pageNum;
}

function image_error(obj)
{
	obj.style.display = 'none';
	var name = $(obj)[0].id;
	var num = parseInt($(obj)[0].name);
	if(AjaxNum > num) {
		AjaxNum = num;
	}
}


var onLoadImg = function(obj){
	var name = $(obj)[0].id;
	var num = parseInt($(obj)[0].name);

	$('#page-area'+num).show();
	$('#content_area'+num).addClass("content_area");
	obj.style.display = 'block';
}

function AjaxHandler() {	
	if( isAjaxCall == false ) {
		isAjaxCall = true;
		if( AjaxNum < PAGE_NUMBER ) {
			AjaxImage(AJAX_URL, AjaxNum);	
		}
	}
}

function initEvent() {
  
  $(parent.document).scroll(function(e) {
	var currentPos = $(parent.document).scrollTop();
	var imageHeight = $(".pageImage").outerHeight(true);
	var cruuentPage = Math.round(currentPos/imageHeight)+2;
  	if( cruuentPage >= AjaxNum ) {
		AjaxHandler();
		AjaxNum = cruuentPage+INIT_IMAGE_LIMIT+1;
		if( PAGE_NUMBER < AjaxNum )
			AjaxNum = PAGE_NUMBER;
  	}  	
  });
  
  $(document).scroll(function(e) {
  	var currentPos = $(document).scrollTop();
	var imageHeight = $(".pageImage").outerHeight(true);
	var cruuentPage = Math.round(currentPos/imageHeight)+2;
  	if( cruuentPage >= AjaxNum ) {
		AjaxHandler();
		AjaxNum = cruuentPage+INIT_IMAGE_LIMIT+1;
		if( PAGE_NUMBER < AjaxNum )
			AjaxNum = PAGE_NUMBER;
  	}  	
  });
 
}

function AjaxImage(addr, pageNum) {
  // Preload images
	$.ajax(
			{
				type: "POST",
				url: addr,
				async: true,
				data: {pdf:FILENAME, sp:pageNum},
				dataType: "text",
				error: function(data){
					//alert('error')
		 		},
		 		complate : function(data){
		 			//alert('complate')
		 		},
				success:function(data) {
					var end = pageNum+INIT_IMAGE_LIMIT;
					end = end > PAGE_NUMBER ? PAGE_NUMBER : end;

					for( var i = pageNum; i <= end; i++ ){
						var elImg = new Image();
						// PDFium 수정
						//var src = PATH + '/'+i+'.jpg';
						var src = PATH + '/'+i+'.'+imgExt;
						elImg.src = src;
					}

					if( end < AjaxNum ) {
						AjaxImage(AJAX_URL, end+1);
					}else{
						if( end >= PAGE_NUMBER ) {
							AjaxNum =  PAGE_NUMBER;
						}
						isAjaxCall = false;
					}
				}
			}
		);
}
function createPageElement(idNum) { 
	var html = '<div id="page-area' + idNum + '" class="page-element goog-inline-block">';
		html += '<div><div id="highlight_pane' + idNum + '"></div><div id="content_area'+idNum+'" ><div class="pageImage">';
		html +='<img id="page' + idNum +'" name="'+idNum+'" src="'+PATH+'/' + (idNum + 1) +'.'+imgExt+'"  width="100%" unselectable="on" title="page'+ (idNum + 1) +'" onload="onLoadImg(this)" onerror="image_error(this)"/>';
	   	html +='</div></div></div></div>'; //onError="javascript:image_error(this);" onerror="onErrorImg(this)" onload="onLoadImg('+ (idNum + 1) +')"
	return html;
}
function loadImage(pageNum) {
	for (var i=0; i<pageNum; i++) {
		$("#img-center-pane").append(createPageElement(i));
		if( AjaxNum != 99999 ) {
			break;
		}
	}
}
function AjaxImageSingle(addr, pageNum) {
	$.ajax(
			{
				type: "POST",
				url: addr,
				async: true,
				data: {pdf:FILENAME, sp:pageNum},
				dataType: "text",					
				error: function(data){
					//alert('error')		  			
		 		},
		 		complate : function(data){
		 			//alert('complate')
		 		},
				success:function(data) {
					var end = pageNum+INIT_IMAGE_LIMIT;
					end = end > PAGE_NUMBER ? PAGE_NUMBER : end;
					
					for( var i = pageNum; i <= end; i++ ){
						var number = Date.parse(new Date().toString());
						var elImg = document.getElementById('page'+(i-1));
						var src = PATH + '/'+i+'.'+imgExt+'?c='+number;
						elImg.src = src;
					}
					
					if( end < AjaxNum ) {
						AjaxImage(AJAX_URL, end+1);
					}else{						
						if( end >= PAGE_NUMBER ) {
							AjaxNum =  PAGE_NUMBER;
						}
						isAjaxCall = false;
					}
				}
			}
		);
}
// ie select 막기
function returnEventFalse(e){
    var event = e || window.event ;
    event.returnValue = false;
}
function returnEventTrue(e){
    var event = e || window.event ;
    event.returnValue = true;
}

function movePage(idx) {
  if (idx <= PAGE_NUMBER && idx > 0) {
    $('#page').attr('src', PATH + '/' + (idx) + '.' +imgExt);
    changePaperPageNumber(idx);
  }
}

function movePagePrev() {
  movePage(currentPage - 1);
}
function movePageNext() {
  movePage(currentPage + 1);
}

$(document).ready(function() {
	document.ondragstart = returnEventFalse;
  document.onselectstart = returnEventFalse;
	getImgPositionData(PATH+"/"+FILENAME+".xml");
	initLayout();
  if (mode == "single") {
    loadImage(PAGE_NUMBER);
  }
  loadPage();
	$(".prNavTotal").html(PAGE_NUMBER);
  initEvent();
});
