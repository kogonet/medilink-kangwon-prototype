jQuery.fn.htip = function (type) {

	var htip_id = "htipUniqueId";

	//############# 이벤트 바인드 //#############
	//사라지게 하기
	this.bind("blur", function () {

		$("#" + htip_id).css("display", "none");

	});

	//보이게 하기
	this.bind("focus", function () {

		$("#" + htip_id).css("display", "");

	});

	//############# 강제 사라지게 하기 //#############
	if ($("#" + htip_id).length > 0 && type == "hide") {

		$("#" + htip_id).css("display", "none");

	}

	//############# 좌표 설정 //#############
	var offset = this.offset();
	var top = offset.top;
	var left = offset.left;
	var height = this.height();
	top += (height + 5);

	//############# CSS //#############
	var display = (type == "show") ? "" : "none";
	var css = " border: 1px solid gray; padding: 5px; position: absolute; background-color: #f1f1f1; top:" + top + "px; left:" + left + "px; display: " + display + "; ";

	//############# 내용 //#############
	var title = this.attr("htip");
	var html = "<div id='" + htip_id + "' style='" + css + "'>" + title + "</div>";

	//############# 유효성 체크 //#############
	//툴팁 레이어가 존재 한다면,
	if ($("#" + htip_id).length > 0) {

		//style 설정
		$("#" + htip_id).attr("style", css);

		//강제로 보이기
		if (type == "show") {

			$("#" + htip_id).css("display", "");

		}

		return this;

	}

	//############# 추가 //#############
	$("body").append(html);

	return this;

};