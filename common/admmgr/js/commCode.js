/**************************************************
 * @desc   :코드 관리
 **************************************************/
var commCode = {
	//imgPath : G_Util.getContextPath()+"/common/admmgr/images",
	imgPath : "/common/admmgr/images",
	siteCd  : "",
	//사이트 선택시
	selectSite : function( oThis, siteCd, pCode, depth ){
		//선택버튼이 존재한다면,
		if( oThis != null && depth != 1 ){
			//해당 테이블 내의 아이콘을 정상화 한다.
			$("#commCode_"+(Number(depth) - 1)+" .select_icon").each(function(idx,obj){
				$(obj).attr("src",commCode.imgPath+"/layout_n/icon_accept.svg");
			});
			//해당 버튼만 아이콘을 변경한다.
			$(oThis).find("img").attr("src",commCode.imgPath+"/layout_n/action_forward.svg");
		}
		commCode.siteCd = siteCd;
		commCode.select(null,pCode,depth);

		//순서정렬 관련 세팅
		$(".depthChgChk").each(function(idx){
			if($(this).is(":checked")){
				$(this).prop("checked", false);
				commCode.tableSet(false, (idx+1));
			}
		});
	},
	select  : function( oThis, pCode, depth ){
		//선택버튼이 존재한다면,
		if( oThis != null && depth != 1 ){
			//해당 테이블 내의 아이콘을 정상화 한다.
			$("#commCode_"+(Number(depth) - 1)+" .select_icon").each(function(idx,obj){
				$(obj).attr("src",commCode.imgPath+"/layout_n/icon_accept.svg");
			});
			//해당 버튼만 아이콘을 변경한다.
			$(oThis).find("img").attr("src",commCode.imgPath+"/layout_n/action_forward.svg");
		}

		//마지막 Depth일때
		if( Number(depth) == 5){
			return;
		}

		//하위 테이블 초기화
		var real_depth = Number(depth) - 1;
		for( var i = 3, j = real_depth; i > j; i-- ){
			$("#commCode_"+i).attr("pCode", "");
			$("#commCode_"+i+" tbody").html("");
		}

		//해당 테이블에 코드 설정
		$("#commCode_"+depth).attr("pCode", pCode);
		
		//조회  Ajax
		$.ajax({
			url     : "commCodeSelect.do",
			type    : "POST",
			data    : {"pCode":pCode,"depth":depth,"siteCd":commCode.siteCd},
			success : function(data){
				commCode.selectResult(data,depth);
				
				var tr = $(oThis).parents("tr");
				var code = tr.attr("code");
				
				// 오른쪽 정보
				$("#code").text("");
				$("#codeNm").text("");
				$("#codeDc").val("");
				
				$(".btn_n_add").hide();
				
				if(depth !== 2 && code === pCode) {
					
					$.ajax({
						url     : "/admmgr/manage/commCodeForMapAjaxProc.do",
						type    : "POST",
						data    : {"code":code,"siteCd":commCode.siteCd},
						success : function(data){
							var json = $.parseJSON(data);
							//console.log(json);
							$("#code").text(json.CODE);
							$("#codeNm").text(json.CODE_NM);
							$("#codeDc").val(json.CODE_DC);
							
							$(".btn_n_add").show();
						}
					});
					
					
				}
				
				//순서정렬 관련 세팅
				$(".depthChgChk").each(function(idx){
					if($(this).is(":checked")){
						$(this).prop("checked", false);
						commCode.tableSet(false, (idx+1));
					}
				});
			}
		});

	},
	selectResult : function(data, depth){
		//선택시 다음 Table에 값을 할당하기 위해 +1을 해준다.
		var select_depth = depth+1;

		//TR html
		var html = "<tr code='{CODE}'>";
		html += "<td class='tx_a_left'><span onclick='commCode.modifyClick( this );'>{CODE_NM}</span></td>";	//코드명

		if( depth > 1){
			var iHeight = 100;
			if( depth == 2 )		iHeight = 350;
			else if( depth == 3 )	iHeight = 580;
			/*html += "<td><img src='"+commCode.imgPath+"/layout_n/cog.svg' alt='설정' onclick='FrameLayer.open( \"./commCodeLayer.do\",500,350,\"no\",{\"code\":\"{CODE}\",\"siteCd\":\""+commCode.siteCd+"\"});'/></td>";//설정
*/		}

		html += "<td><img src='"+commCode.imgPath+"/layout_n/action_stop.svg' onclick='commCode.remove( this );' alt='삭제' /></td>";											       //삭제
		html += "<td onclick='commCode.select( this, \"{CODE}\","+select_depth+" );'><img src='"+commCode.imgPath+"/layout_n/icon_accept.svg' class='select_icon' alt='선택' /></td>";//선택
		html += "</tr>";

		var data_arr = $.parseJSON(data);
		//console.log(data_arr);
		var cache_html = "";	//table에 Append하기 전에 현재 변수에 캐쉬한다.
		for( var i = 0, j = data_arr.length; i < j; i++){
			var json = data_arr[i];
			var new_html = html.replace("{CODE_NM}", json.codeNm).replaceAll("{CODE}", json.code);
			cache_html += new_html;
		}
		//해당 테이블에 Append한다.
		$("#commCode_"+depth+" tbody").append(cache_html);
	},
	add : function(oThis){
		var table = $(oThis).parents("table");				//테이블 개체
		var depth = Number(table.attr("id").split('_')[1]);	//단계
		var codeNm = oThis.value;							//코드 명
		var pCode = table.attr("pCode");					//상위 코드
		console.log(pCode);
		//유효성
		if( pCode == undefined ) {
			alert("사이트를 선택해주세요.");
			return;
		}
		if( !pCode.trim()){
			alert("상위메뉴를 선택해주세요.");
			return;
		}
		if( !codeNm.trim()){
			alert("코드를 입력해주세요.");
			return;
		}
		//console.log("{ 'codeNm': '"+CODE_NM+"', 'pCode': '"+pCode+"', 'depth': '"+depth+"' }");
		//등록  Ajax
		$.ajax({
			url     : "commCodeAppend.do",
			type    : "POST",
			data    : {"codeNm":codeNm,"pCode":pCode,"depth":depth,"siteCd":commCode.siteCd},
			success : function(data){ commCode.selectResult(data, depth); }
		});
		//input을 text로 변경
		oThis.blur();
	},
	addClick : function(oThis){
		var input_html = "<input type='text' htip='Enter키: 등록, ESC키: 취소' onkeydown='commCode.keyCheck(event,\"add\")'/> ";
		var txt_html = "<span onclick='commCode.addClick(this);'>이곳을 클릭하여 새로운 코드를 등록하세요.</span>";
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
		var code = tr.attr("code");

		//삭제  Ajax
		$.ajax({
			url     : "commCodeRemove.do",
			type    : "POST",
			data    : {"code":code,"siteCd":commCode.siteCd},
			success : function(data){
				//선택 유무
				var choice = (tr.find("td:last img").eq(0).attr("src").indexOf("icon_accept") == -1) ? "Y":"N";

				//하위 테이블 초기화
				if( choice == "Y"){

					//하위 테이블 초기화
					var depth = Number(tr.parents("table").attr("id").split("_")[1]);
					for( var i = 3, j = depth; i > j; i--){
						$("#commCode_"+i).attr("pCode", "");
						$("#commCode_"+i+" tbody").html("");
					}
				}
				//TR삭제
				tr.remove();
				
				// 선택 되어있는 것이 삭제 될 때
				if($("#siteCode").val() === commCode.siteCd) {
					$("#viewBody #code").text("");
					$("#viewBody #codeNm").text("");
					$("#viewBody #codeDc").val("");
					
					$(".btn_n_add").hide();
				}
				
			}
		});
	},
	modifyClick : function(oThis){
		var tr = $(oThis).parents("tr");	//Tr 개체
		var code = tr.attr("code");			//코드
		var codeNm = $(oThis).text();		//코드 명
		
		// 1. td 요소 생성 및 속성 설정
		var td = document.createElement('td');
		td.className = 'bd_line_right bd_line_left';
		td.colSpan = 4;

		// 2. input 요소 생성 및 속성 설정
		var input = document.createElement('input');
		input.type = 'text';
		input.setAttribute('htip', 'Enter키: 수정, ESC키: 취소');
		input.setAttribute('onkeydown','commCode.keyCheck( event, \"modify\" )');
		input.value = codeNm;

		td.appendChild(input);

		//해당 TR선택 유무
		var choice = (tr.find("td:last img").eq(0).attr("src").indexOf("icon_accept") == -1) ? "Y":"N";
		tr.attr("choice", choice);

		//TD변경
		tr.html(td).find("input").eq(0).htip("show").focus().bind("blur",function(evt){
			var data = {"code":code,"codeNm":codeNm};
			var input = evt.currentTarget;
			commCode.modifyResult(input, data);
		});
	},
	modify : function(oThis){
		var tr = $(oThis).parents("tr");	//Tr 개체
		var code = tr.attr("code");			//코드
		var codeNm = oThis.value;			//코드 명
		if( !codeNm ){
			alert("수정할 코드명을 입력해주세요.");
			return;
		}
		//수정  Ajax
		$.ajax({
			url     : "commCodeModify.do",
			type    : "POST",
			data    : {"code":code,"codeNm":codeNm,"siteCd":commCode.siteCd},
			success : function(data){ commCode.modifyResult(oThis, data); }
		});
	},
	modifyResult : function(oThis, data){
		var tr = $(oThis).parents("tr");			//Tr 개체
		var table = $(tr).parents("table");			//Table 개체
		var depth = table.attr("id").split("_")[1];	//Depth
		var select_depth = Number(depth)+1;			//선택되었을때 전달할 Depth
		var choice = tr.attr("choice");				//선택 유무
		var icon_src = (choice == "Y") ? "action_forward":"icon_accept";
		tr.removeAttr("choice");

		var json = null;
		if( $.type(data) == "string") json = $.parseJSON(data);
		else json = data;

		//TR html
		var html = "<td class='tx_a_left'><span onclick='commCode.modifyClick( this );'>{CODE_NM}</span></td>";	//코드명

		/*if( depth > 1){
			html += "<td><img src='"+commCode.imgPath+"/layout_n/cog.svg' alt='설정' onclick='FrameLayer.open( \"./commCodeLayer.do\",500,350,\"no\",{\"code\":\"{CODE}\",\"siteCd\":\""+commCode.siteCd+"\"});'/></td>";	//설정
		}*/

		html += "<td><img src='"+commCode.imgPath+"/layout_n/action_stop.svg' onclick='commCode.remove( this );' alt='삭제' /></td>";				                                    //삭제
		html += "<td onclick='commCode.select( this, \"{CODE}\", {DEPTH} );'><img src='"+commCode.imgPath+"/layout_n/"+icon_src+".svg' class='select_icon' alt='선택' /></td>";	    //선택

		//html replace
		var new_html = html.replace("{CODE_NM}", json.codeNm).replaceAll("{CODE}", json.code).replace("{DEPTH}", select_depth);

		//html 변경
		tr.html(new_html);
		
		// 선택 되어있는 것이 이름 변경 될 때
		if($("#viewBody #code").text() === tr.attr("code")) {
			$("#viewBody #codeNm").text(json.codeNm);
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
				commCode.add(target);
			//수정
			}else if( type == "modify" ){
				commCode.modify(target);
			}

		}else if( keyCode == "27" ){
			//취소
			target.blur();
		}
	},
	move : function(type, depth){
		$("#commCode_"+depth+" img.select_icon").each(function(idx, obj){
			if( $(obj).attr("src").indexOf("icon_accept") == -1 ){
				//Up
				if( type == "up") commCode.up(obj, depth);
				//Down
				else commCode.down(obj, depth);
			}
		});
	},
	up : function(obj, depth){
		var tr = $(obj).parents("tr");
		if( tr.index() == 0 ){
			alert("더이상, 상단으로 이동할 수 없습니다.");
		}else{
			var code = tr.attr("code");
			$.ajax({
				url     : "commCodeMove.do",
				type    : "POST",
				data    : {"code":code,"depth":depth,"type":"up","siteCd":commCode.siteCd},
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
			var code = tr.attr("code");
			$.ajax({
				url     : "commCodeMove.do",
				type    : "POST",
				data    : {"code":code,"depth":depth,"type":"down","siteCd":commCode.siteCd},
				success : function(){
					tr.insertAfter(tr.next());
				}
			});
		}
	},
	sortChk : function(oThis, depth){
		//정렬순서 변경 체크
		if($(oThis).is(":checked")){
			if($("#commCode_"+Number(depth)+" > tbody > tr").length == 0){
				alert("변경 할 목록이 없습니다.");
				$(oThis).prop("checked", false);
				return false;
			}
			commCode.uiChangeProc(oThis, depth, true, false);
		}else{
			commCode.uiChangeProc(oThis, depth, false, true);
		}

		//체크버튼을 loop하여 다른버튼들이 체크되어져있다면 체크 취소
		$(".depthChgChk").each(function(idx){
			if($(this).is(":checked") && $(this).attr("id") != $(oThis).attr("id")){
				$(this).prop("checked", false);
				//체크 취소에 대한 UI변경을 하되 commCode.select는 호출하지 않기위해 마지막 변수로 false 전달
				commCode.uiChangeProc(this, (idx+1), false, false);
			}
		});
	},
	uiChangeProc : function(oThis, depth, boolChk, boolselect){
		//전렬순서 변경 체크에 따른 UI 변경
		if(boolChk){
			//table의 tr 목록을 drag and drop 가능 한 ol 태그로 복사 후 tr 요소 삭제
			$("#commCode_"+Number(depth)+" > tbody > tr").each(function(idx,obj){
				var strHtml = "";
				strHtml += "<li code='"+$(this).attr("code")+"'>";
				strHtml += "<input type='hidden' name='li_commCode' value='"+$(this).attr("code")+"'/>";
				strHtml += "<span style='text-align:center;'>"+$(this).children("td").children("span").text()+"</span>";
				strHtml += "</li>";
				$("#commCodeSort_"+depth).append(strHtml);
			});
			commCode.tableSet(true, depth);
		}else{
			//체크 취소 시 commCode.select 호출로 tr 목록 재생성
			//boolselect은 다른 메뉴의 정렬순서 변경 중복체크를 막기 위해 true 일때만 tr목록 조회
			if(boolselect) commCode.select(null,$("#commCode_"+depth).attr("pcode"),depth);
			commCode.tableSet(false, depth);
		}
	},
	tableSet : function(chkYn, depth){
		//정렬순서 변경 체크에 따라 table 요소 세팅
		//설정, 삭제, 선택 문구와 tfoot, tbody 가리기
		if(chkYn){
			$("#commCode_"+depth+" > thead > tr > th").eq(0).attr("colspan", 4);
			$("#commCode_"+depth+" > thead > tr > th").eq(1).hide();
			$("#commCode_"+depth+" > thead > tr > th").eq(2).hide();
			$("#commCode_"+depth+" > thead > tr > th").eq(3).hide();

			$("#commCode_"+depth+" > tbody").hide();
			$("#commCode_"+depth+" > tfoot").hide();
		}else{
			//설정, 삭제, 선택 문구와 tfoot, tbody 표시하기
			$("#commCodeSort_"+depth+" > li").remove();
			$("#commCode_"+depth+" > thead > tr > th").eq(0).attr("colspan", 1);
			$("#commCode_"+depth+" > thead > tr > th").eq(1).show();
			$("#commCode_"+depth+" > thead > tr > th").eq(2).show();
			$("#commCode_"+depth+" > thead > tr > th").eq(3).show();

			$("#commCode_"+depth+" > tbody").show();
			$("#commCode_"+depth+" > tfoot").show();

		}
	}

}