var FrameLayer = {
	width: 0,
	height: 0,
	src: 0,
	scolling: "no",
	parentReload : false,
	open: function (src, width, height, scolling, parameter, parentReload) {
		FrameLayer.src = src;					//경로
		FrameLayer.width = width;			//가로 크기
		FrameLayer.height = height;		//세로 크기
		FrameLayer.scolling = scolling;		//스크롤링
		//MOOK.2021.12.25.레이어 갱신시 부모창 정보 변경을 위한 추가
		if( parentReload != undefined && parentReload != null ){
			FrameLayer.parentReload = parentReload;
		}
		//배경 생성
		FrameLayer.setBackground();
		//Iframe 생성
		FrameLayer.setIframe(parameter);
	},
	setBackground: function () {
		var width = $(document).width();
		var height = $(document).height();
		var html = "<div id='frameLayer_bg' onclick='javascript:FrameLayer.close();' style='position:absolute; width: " + width + "px; height: " + height + "px; top:0; left:0; z-index:9999; background-color: #000; opacity: 0.5; filter: alpha(opacity=50);'></div>";

		$("body").append(html);
	},
	setIframe: function ( parameter ) {
		var scrollTop = $(document).scrollTop();
		var marginTop = (FrameLayer.height / 2) - scrollTop;
		var marginLeft = (FrameLayer.width / 2);
		if (marginTop >= 0) {
			marginTop = "-" + marginTop;
		} else {
			marginTop = Math.abs(marginTop);
		}
		var flagName = "flag" + String(Math.floor(Math.random() * (9999 - 1000 + 1)) + 1000);

		//var html = "<div id='frameLayer_layer' style='z-index:2000; position: absolute;  top:10%; left:10%; overflow-x: hidden;'>";
		//html += "<iframe width='" + FrameLayer.width + "' height='" + FrameLayer.height + "' id='frameLayer_frame' src='" + FrameLayer.src + "' frameborder='0' marginwidth='0' marginheight='0' scrolling='no' allowTransparency='true'></iframe>";
		//html += "</div>";

		//var html = "<div id='frameLayer_layer' style='z-index:91; position: absolute; top: 50%; left:50%; margin-top:" + marginTop + "px; margin-left:-" + marginLeft + "px; width:" + FrameLayer.width + "px; max-height:800px; overflow: hidden;'>";
		//html += "<iframe onload='autoResize(this)' width='" + FrameLayer.width + "' height='" + FrameLayer.height + "' id='frameLayer_frame' src='" + FrameLayer.src + "' frameborder='0' marginwidth='0' marginheight='0' scrolling='" + FrameLayer.scolling + "' allowTransparency='true'></iframe>";
		//html += "</div>";

		var html = "<div id='frameLayer_layer' style='z-index:10000; position:absolute; top:50%; left:50%; border-radius:15px; margin-top:" + marginTop + "px; margin-left:-" + marginLeft + "px; width:" + FrameLayer.width + "px; max-height:800px; overflow:hidden;'>";
		html += "<iframe style='border:0; background-color: transparent; width:" + FrameLayer.width + "px; height:" + FrameLayer.height + "px;' width='" + FrameLayer.width + "' height='" + FrameLayer.height + "' name='frameLayer_frame' id='frameLayer_frame' src='#' frameborder='0' marginwidth='0' marginheight='0' scrolling='" + FrameLayer.scolling + "' allowTransparency='true'></iframe>";
		html += "</div>";

		// Post Temp Form
		html += "<form id='" + flagName + "_form' action='" + FrameLayer.src + "' target='frameLayer_frame' method='post'>";

		if( parameter ){
	  		for(var k in parameter){
	  			html += "<input type='hidden' name='" + k + "' value='" + parameter[k] + "' />";
	  		}
		}
		html += "</form>";

		$("body").append(html);
		$( "#" + flagName + "_form" ).get(0).submit();
		$( "#" + flagName + "_form" ).remove();
	},
	close: function () {
		console.log("close["+FrameLayer.parentReload+"]");
		if( FrameLayer.parentReload ){
			console.log("parent.location.reload start");
			parent.location.reload();
			console.log("parent.location.reload end");
		}
		parent.$("body").removeClass("overflow");
		parent.$(".body_wrapper").removeClass("overflow");

		if ($("#frameLayer_bg").length == 0) parent.$("#frameLayer_bg").remove();
		else $("#frameLayer_bg").remove();

		if ($("#frameLayer_layer").length == 0) parent.$("#frameLayer_layer").remove();
		else $("#frameLayer_layer").remove();


	}

}