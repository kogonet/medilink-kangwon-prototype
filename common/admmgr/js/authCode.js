/**************************************************
 * @desc   : 사이트 코드 관리
 **************************************************/
var authCode = {
	//imgPath : G_Util.getContextPath()+"/common/admmgr/images",
	imgPath : "/common/admmgr/images",
	siteCd : "",
	select : function( oThis, siteCd, depth, authCd ){

		//선택버튼이 존재한다면,
		if( oThis != null ){
			//해당 테이블 내의 아이콘을 정상화 한다.
			$("#authCode_"+(Number(depth) - 1)+" .select_icon").each(function(idx,obj){
				$(obj).attr("src",authCode.imgPath+"/layout_n/icon_accept.svg");
			});
			//해당 버튼만 아이콘을 변경한다.
			$(oThis).find("img").attr("src",authCode.imgPath+"/layout_n/action_forward.svg");
		}
		/*
		//마지막 Depth일때
		if( Number(depth) == 4){
			return;
		}
		*/
		//하위 테이블 초기화
		var real_depth = Number(depth) - 1;
		for( var i = 3, j = real_depth; i > j; i-- ){
			$("#authCode_"+i).attr("authCd","");
			$("#authCode_"+i+" tbody").html("");
		}

		if(real_depth == 0) {
			$("#authCode_0").attr("siteCd",siteCd);
		}
		
		//해당 테이블에 코드 설정
		//$("#authCode_"+depth).attr("authCd", authCd);
		authCode.siteCd = siteCd;
		$("#siteCd").val(authCode.siteCd);
		//console.log(authCd);
		//조회  Ajax
		$.ajax({
			url     : "authCodeSelect.do",
			type    : "POST",
			//data    : {"authCd":authCd,"depth":depth},
			data    : {"siteCd":siteCd, "authCd":authCd},
			success : function(data){ authCode.selectResult(data,depth); }
		});

	},
	selectResult : function(data, depth){
		//선택시 다음 Table에 값을 할당하기 위해 +1을 해준다.
		var select_depth = depth+1;

		//TR html
		var html = "<tr authCd='{authCd}'>";
		html += "<td class='tx_a_left'><span onclick='authCode.modifyClick( this );'>{authNm}</span></td>";	//코드명
		/*html += "<td><img src='"+authCode.imgPath+"/layout_n/cog.svg' alt='설정' onclick='FrameLayer.open( \"./authCodeLayer.do\",950,550,\"yes\",{\"authCd\":\"{authCd}\",\"siteCd\":\""+authCode.siteCd+"\"});'/></td>";*/	 //설정
		html += "<td><img src='"+authCode.imgPath+"/layout_n/action_stop.svg' onclick='authCode.remove( this );' alt='삭제' /></td>";											             //삭제
		//html += "<td onclick='authCode.select(this,\"{authCd}\","+select_depth+" );'><img src='"+authCode.imgPath+"/layout_n/icon_accept.svg' class='select_icon' alt='선택' /></td>";	 //선택
		html += "<td onclick='authCode.select(this,\""+authCode.siteCd+"\","+select_depth+",\"{authCd}\" );'><img src='"+authCode.imgPath+"/layout_n/icon_accept.svg' class='select_icon' alt='선택' /></td>";	 //선택
		html += "</tr>";

		var data_arr = $.parseJSON(data);
		//console.log(data_arr);
		var json;
		var cache_html = "";	//table에 Append하기 전에 현재 변수에 캐쉬한다.
		for( var i = 0, j = data_arr.length; i < j; i++){
			json = data_arr[i];
			var new_html = html.replace("{authNm}",json.authNm).replaceAll("{authCd}",json.authCd);
			cache_html += new_html;
		}
		//해당 테이블에 Append한다.
		$("#authCode_"+depth+" tbody").append(cache_html);
		
		// info
		if(depth == 2) {
			// ajax
			$.ajax({
				type : "POST",
				url  : "/admmgr/manage/menuCodeByAuthAjax.do",
				data : {"siteCd":authCode.siteCd,"authCd":json.authCd},
				dataType : "text",
				success : function(data){
					var rJson = $.parseJSON(data);
					console.log(rJson);
					
					$("#code").text(rJson[0].AUTH_CD);
					$("#name").text(rJson[0].AUTH_NM);
					$("#authDc").val(rJson[0].AUTH_DC);
					$("#menuCd").val(rJson[0].MENU_CD);
					$("#authCode").val(json.authCd);
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				},
				complete : function(){
					$(".btn").show();
					$(".btn_n_add").show();
					
					fn_LoadTree();
					key = $("#treeword");
					key.bind("focus", focusKey).bind("blur", blurKey);
				}
			});
			
		}
		
	},
	add : function(oThis){
		var table = $(oThis).parents("table");				//테이블 개체
		var depth = Number(table.attr("id").split('_')[1]);	//단계
		var authNm = oThis.value;							//코드 명
		var siteCd = $("#authCode_0").attr("siteCd");
		console.log(siteCd);
		//유효성
		if( siteCd == undefined ) {
			alert("사이트를 선택해주세요.");
			return;
		}
		if( !authNm.trim()){
			alert("코드를 입력해주세요.");
			return;
		}
		//console.log("{ 'authNm': '"+authCd_NM+"', 'authCd': '"+authCd+"', 'depth': '"+depth+"' }");
		//등록  Ajax
		$.ajax({
			url     : "authCodeAppend.do",
			type    : "POST",
			data    : {"authNm":authNm,"depth":depth,"siteCd":authCode.siteCd},
			success : function(data){ authCode.selectResult(data, depth); }
		});
		//input을 text로 변경
		oThis.blur();
	},
	addClick : function(oThis){
		var input_html = "<input type='text' htip='Enter키: 등록, ESC키: 취소' onkeydown='authCode.keyCheck(event,\"add\")'/> ";
		var txt_html = "<span onclick='authCode.addClick(this);'>이곳을 클릭하여 새로운 코드를 등록하세요.</span>";
		//Add
		$(oThis).parent().html(input_html).find("input").eq(0).htip("show").focus().bind("blur",function(evt){
			//텍스트 처리
			var td = $(evt.currentTarget).parent();
			$(td).html(txt_html);
		});
	},
	remove : function(oThis){
		if( !confirm("정말 삭제하시겠습니까?")) return;

		var tr = $(oThis).parents("tr");
		var authCd = tr.attr("authCd");

		//삭제  Ajax
		$.ajax({
			url     : "authCodeRemove.do",
			type    : "POST",
			data    : {"authCd":authCd,"siteCd":authCode.siteCd},
			success : function(data){
				//선택 유무
				var choice = (tr.find("td:last img").eq(0).attr("src").indexOf("icon_accept") == -1) ? "Y":"N";

				//하위 테이블 초기화
				if( choice == "Y"){

					//하위 테이블 초기화
					var depth = Number(tr.parents("table").attr("id").split("_")[1]);
					for( var i = 3, j = depth; i > j; i--){
						$("#authCode_"+i).attr("authCd", "");
						$("#authCode_"+i+" tbody").html("");
					}
				}
				//TR삭제
				tr.remove();
				
				// 선택 되어있는 것이 삭제 될 때
				if($("#authCode").val() !== undefined && $("#authCode").val() === authCd) {
					$.fn.zTree.destroy();
					
					$(".btn").hide();
					$(".btn_n_add").hide();
				}
			}
		});
	},
	modifyClick : function(oThis){
		var tr = $(oThis).parents("tr");	//Tr 개체
		var authCd = tr.attr("authCd");			//코드
		var authNm = $(oThis).text();		//코드 명

		//TD html
		var html = "<td class='bd_line_right bd_line_left' colspan='4'>";
		html += "<input type='text' htip='Enter키: 수정, ESC키: 취소' onkeydown='authCode.keyCheck( event, \"modify\" )' value='"+authNm+"' />";
		html += "</td>";

		//해당 TR선택 유무
		var choice = (tr.find("td:last img").eq(0).attr("src").indexOf("icon_accept") == -1) ? "Y":"N";
		tr.attr("choice", choice);

		//TD변경
		tr.html(html).find("input").eq(0).htip("show").focus().bind("blur",function(evt){
			var data = {"authCd":authCd,"authNm":authNm};
			var input = evt.currentTarget;
			authCode.modifyResult(input, data);
		});
	},
	modify : function(oThis){
		var tr = $(oThis).parents("tr");	//Tr 개체
		var authCd = tr.attr("authCd");		//코드
		var authNm = oThis.value;			//코드 명
		if( !authNm ){
			alert("수정할 코드명을 입력해주세요.");
			return;
		}
		//수정  Ajax
		$.ajax({
			url     : "authCodeModify.do",
			type    : "POST",
			data    : {"authCd":authCd,"authNm":authNm,"siteCd":authCode.siteCd},
			success : function(data){ authCode.modifyResult(oThis, data); }
		});
	},
	modifyResult : function(oThis, data){
		var tr = $(oThis).parents("tr");			//Tr 개체
		var table = $(tr).parents("table");			//Table 개체
		var depth = table.attr("id").split("_")[1];	//Depth
		var select_depth = Number(depth)+1;			//선택되었을때 전달할 Depth
		var choice = tr.attr("choice");				//선택 유무
		var icon_src = (choice == "Y") ? "action_forward":"icon_accept";
		var authCd = tr.attr("authCd");
		var authNm = oThis.value;
		tr.removeAttr("choice");

		var json = null;
		if( $.type(data) == "string") json = $.parseJSON(data);
		else json = data;

		//TR html
		var html = "<td class='tx_a_left'><span onclick='authCode.modifyClick( this );'>{authNm}</span></td>";	//코드명
		html += "<td><img src='"+authCode.imgPath+"/layout_n/action_stop.svg' onclick='authCode.remove( this );' alt='삭제' /></td>";				                                    //삭제
		html += "<td onclick='authCode.select( this,\""+ authCode.siteCd +"\", {DEPTH}, \"{authCd}\" );'><img src='"+authCode.imgPath+"/layout_n/"+icon_src+".svg' class='select_icon' alt='선택' /></td>";	    //선택

		//html replace
		var new_html = html.replace("{authNm}", json.authNm).replaceAll("{authCd}", json.authCd).replace("{DEPTH}", select_depth);

		//html 변경
		tr.html(new_html);
		
		// 선택 되어있는 것이 이름 변경 되었을 때
		if(authCd == $("#code").text()) {
			$("#name").text(authNm);
		}
	},
	keyCheck : function(evt, type){
		var keyCode = $(evt).keyCode();
		var target = evt.currentTarget || evt.target || evt.srcElement;

		if( keyCode == "13"){
			//ToolTip 사라지기
			$(target).htip("hide");
			//등록
			if( type == "add" ){
				authCode.add(target);
			//수정
			}else if( type == "modify" ){
				authCode.modify(target);
			}

		}else if( keyCode == "27" ){
			//취소
			target.blur();
		}
	},
	move : function(type, depth){
		$("#authCode_"+depth+" img.select_icon").each(function(idx, obj){
			if( $(obj).attr("src").indexOf("icon_accept") == -1 ){
				//Up
				if( type == "up") authCode.up(obj, depth);
				//Down
				else authCode.down(obj, depth);
			}
		});
	},
	up : function(obj, depth){
		var tr = $(obj).parents("tr");
		if( tr.index() == 0 ){
			alert("더이상, 상단으로 이동할 수 없습니다.");
		}else{
			var authCd = tr.attr("authCd");
			$.ajax({
				url     : "authCodeMove.do",
				type    : "POST",
				data    : {"authCd":authCd,"depth":depth,"type":"up","siteCd":authCode.siteCd},
				success : function(){
					tr.insertBefore(tr.prev());
				}
			});
		}
	},
	down : function(obj, depth){
		var tr = $(obj).parents("tr");
		var table = $(tr).parents("table");
		var rowLength = $(table).rowLength();

		if( tr.index() >= rowLength - 3){
			alert("더이상, 하단으로 이동할 수 없습니다.");
		}else{
			var authCd = tr.attr("authCd");
			$.ajax({
				url     : "authCodeMove.do",
				type    : "POST",
				data    : {"authCd":authCd,"depth":depth,"type":"down","siteCd":authCode.siteCd},
				success : function(){
					tr.insertAfter(tr.next());
				}
			});
		}
	},
	sortChk : function(oThis, depth){
		//정렬순서 변경 체크
		if($(oThis).is(":checked")){
			if($("#authCode_"+Number(depth)+" > tbody > tr").length == 0){
				alert("변경 할 목록이 없습니다.");
				$(oThis).prop("checked", false);
				return false;
			}
			authCode.uiChangeProc(oThis, depth, true, false);
		}else{
			authCode.uiChangeProc(oThis, depth, false, true);
		}

		//체크버튼을 loop하여 다른버튼들이 체크되어져있다면 체크 취소
		$(".depthChgChk").each(function(idx){
			if($(this).is(":checked") && $(this).attr("id") != $(oThis).attr("id")){
				$(this).prop("checked", false);
				//체크 취소에 대한 UI변경을 하되 authCode.select는 호출하지 않기위해 마지막 변수로 false 전달
				authCode.uiChangeProc(this, (idx+1), false, false);
			}
		});
	},
	uiChangeProc : function(oThis, depth, boolChk, boolselect){
		//전렬순서 변경 체크에 따른 UI 변경
		if(boolChk){
			//table의 tr 목록을 drag and drop 가능 한 ol 태그로 복사 후 tr 요소 삭제 
			$("#authCode_"+Number(depth)+" > tbody > tr").each(function(idx,obj){
				var strHtml = "";
				strHtml += "<li code='"+$(this).attr("authcd")+"'>";
				strHtml += "<input type='hidden' name='li_authCd' value='"+$(this).attr("authcd")+"'/>";
				strHtml += "<span style='text-align:center;'>"+$(this).children("td").children("span").text()+"</span>";
				strHtml += "</li>";
				$("#authCodeSort_"+depth).append(strHtml);
			});
			authCode.tableSet(true, depth);
		}else{
			//체크 취소 시 authCode.select 호출로 tr 목록 재생성
			//boolselect은 다른 메뉴의 정렬순서 변경 중복체크를 막기 위해 true 일때만 tr목록 조회
			if(boolselect) authCode.select(null,$("#siteCd").val(),depth, null);
			authCode.tableSet(false, depth);
		}
	},
	tableSet : function(chkYn, depth){
		//정렬순서 변경 체크에 따라 table 요소 세팅
		//설정, 삭제, 선택 문구와 tfoot, tbody 가리기
		if(chkYn){
			$("#authCode_"+depth+" > thead > tr > th").eq(0).attr("colspan", 4);
			$("#authCode_"+depth+" > thead > tr > th").eq(1).hide();
			$("#authCode_"+depth+" > thead > tr > th").eq(2).hide();
			$("#authCode_"+depth+" > thead > tr > th").eq(3).hide();

			$("#authCode_"+depth+" > tbody").hide();
			$("#authCode_"+depth+" > tfoot").hide();
		}else{
			//설정, 삭제, 선택 문구와 tfoot, tbody 표시하기
			$("#authCodeSort_"+depth+" > li").remove();
			$("#authCode_"+depth+" > thead > tr > th").eq(0).attr("colspan", 1);
			$("#authCode_"+depth+" > thead > tr > th").eq(1).show();
			$("#authCode_"+depth+" > thead > tr > th").eq(2).show();
			$("#authCode_"+depth+" > thead > tr > th").eq(3).show();

			$("#authCode_"+depth+" > tbody").show();
			$("#authCode_"+depth+" > tfoot").show();

		}
	}

}