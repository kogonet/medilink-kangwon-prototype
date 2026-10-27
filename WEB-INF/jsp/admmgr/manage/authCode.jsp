<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 코드 관리
 **************************************************/
%>
<c:set var="rootCode" value="000000000000000"/>
<c:set var="userMap" value="${str:getMapAdminUserInfo(pageContext.request)}"/>
<head>
<link rel="stylesheet" href="<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/zTreeStyle.css'/>" type="text/css">
	<style type="text/css">
		body.dragging, body.dragging *{
		  cursor: move !important;
		}
		.dragged{
		  position: absolute;
		  opacity: 0.5;
		  z-index: 2000;
		}
		.authSortList li:nth-child(even){background:#f7f7f7;}
		.authSortList li{
			line-height:30px;
			cursor:pointer;
			text-align:center;
			height:30px;
			background:#fff;  color:#333; font-size:14px;  padding:2px 10px; font-weight:normal; border:1px solid #ddd;
		}
		.ztree li span.button.pIcon01_ico_open{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_open.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.pIcon01_ico_close{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_close.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.pIcon02_ico_open, 
		.ztree li span.button.pIcon02_ico_close{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/2.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon01_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/3.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon02_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/4.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon03_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/5.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon04_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/6.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon05_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/7.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon06_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/8.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.bh_on_rev_loader {
			position: absolute;
			z-index: 200;
			left: 0;
			top: 0;
			width: 100%;
			height: 100%;
			text-align: center;
			background: rgba(0, 0, 0, 0.8);
		}
		.bh_on_rev_loader .bh_on_rev_inner {
			padding-top: 120px;
		}
		.bh_on_rev_loader img {
		
		}
		.bh_on_rev_loader strong {
			display: block;
			padding: 15px 0;
			color: #bebebe;
			font-weight: 500;
		}
	</style>
	<script type="text/javascript" src="<c:url value='/plug-in/jquery-sortable.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/plugin/tooltip.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/plugin/utility.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/authCode.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/plug-in/zTree_v3-master//js/jquery.ztree.core.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/plug-in/zTree_v3-master//js/jquery.ztree.excheck.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			$("div.loader_wrap").hide();
			$("#siteCd").val("<c:out value='${userMap.siteCd}'/>");
			if ( $("#siteCd").val() != '001000000000000' || "<c:out value='${userMap.authCd}'/>" != '001000000' ) {
				authCode.select(null,$("#siteCd").val(),1);
				$("li.borad_area").eq(0).hide();
				$("li.borad_area").css("width", "100%");
			}
			
			var adjustment;
			$("ol.authSortList").sortable({
				group: 'authSortList',
				pullPlaceholder : false,
				// animation on drop
				onDrop : function($item,container,_super){
					var $clonedItem = $('<li/>').css({height:0});
					$item.before($clonedItem);
					$clonedItem.animate({'height':$item.height()});
					$item.animate($clonedItem.position(),function(){
						$clonedItem.detach();
						_super($item, container);
					});
				},
				// set $item relative to cursor position
				onDragStart : function($item,container,_super){
					var offset = $item.offset(),
					pointer = container.rootGroup.pointer;
					adjustment = {
						left : pointer.left - offset.left,
						top  : pointer.top - offset.top
					};
					_super($item, container);
				},
				onDrag : function($item,position){
					$item.css({
						left : position.left - adjustment.left,
						top  : position.top - adjustment.top
					});
				}
			});
			
			/* fn_LoadTree();
			key = $("#treeword");
			key.bind("focus", focusKey).bind("blur", blurKey).bind("propertychange",searchNode).bind("input",searchNode); */
		});

		//저장
		function fn_Regist(depth){
			//초기화
			$("#frm").find("input[name=authCd]").remove();
			var objList = $("ol.authSortList li");

			if(!$("#dept"+depth+"Chg").is(":checked")){
				alert("정렬순서 변경을 체크해 주세요.");
				return false;
			}

			if( objList.length == 0 ){
				alert("갱신할 메뉴가 없습니다.");
				return false;
			}
			if( confirm("현재 정렬 순서대로 갱신할까요?") ){
				$("div.loader_wrap").show();
				//[1]등록/수정될 목록 추출 및 hidden생성
				$("#authCodeSort_"+depth+" li").each(function(idx){
					if( $(this).find("input[name=li_authCd]").length > 0 ){
						$("#frm").append("<input type='hidden' name='authCd' value='"+$(this).find("input[name=li_authCd]").val()+"'>");
					}
				});
				console.log($("#frm").serialize());
				$.ajax({
					url     : "<c:url value='/admmgr/manage/authSortUpdateProcAjax.do'/>",
					type    : "POST",
					data    : $("#frm").serialize(),
					success : function(data){
						alert(data);
						$("div.loader_wrap").hide();
					}
				});
			}
		}
		
		var lastValue = "", nodeList = [], fontCss = {};

		//[트리Fn]검색 후 폰트 변경
		function getFontCss(treeId, treeNode) {
			return (!!treeNode.highlight) ? {
				color : "#A60000",
				"font-weight" : "bold"
			} : {
				color : "#333",
				"font-weight" : "normal"
			};
		}
		//[트리 Fn] 노드 검색 시 이벤트 1
		function focusKey(e) {
			if (key.hasClass("empty")) {
				key.removeClass("empty");
			}
		}
		//[트리 Fn] 노드 검색 시 이벤트 2
		function blurKey(e) {
			if (key.get(0).value === "") {
				key.addClass("empty");
			}
		}
		//[트리 Fn] 노드 검색 후 필터
		function filter(node) {
			return !node.isParent && node.isFirstNode;
		}
		/* //[트리 Fn] 노드 검색 후 노드 텍스트 변경
		function updateNodes(highlight) {
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			for (var i = 0, l = nodeList.length; i < l; i++) {
				nodeList[i].highlight = highlight;
				zTree.updateNode(nodeList[i]);
			}
		}
		//[트리 Fn] 노드 검색
		function searchNode(e) {
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			var value = $.trim(key.get(0).value);
			var keyType = "name";
			if (key.hasClass("empty")) {
				value = "";
			}
			if (lastValue === value)
				return;
			lastValue = value;
			if (value === "")
				return;
			updateNodes(false);
			nodeList = zTree.getNodesByParamFuzzy(keyType, value);
			updateNodes(true);
		} */

		//[트리 Fn] 트리 클릭
		function onClick(e, treeId, node) {
			if (node.level > 0) {
				if (!node.noLink) {
					//$("#btnRegist").show();
					$("#menuCd").val(node.id);
					$("#menuNm").val(node.name);
					var arrMenuPath = new Array();
					$.each(node.getPath(), function(idx) {
						arrMenuPath.push($(this)[0].name);
					});
					var strMenuPath = arrMenuPath.toString();
					strMenuPath = strMenuPath.replaceAll(",", " > ");
					$("#menuPath").val(strMenuPath);
					//console.log(node.getPath());
					//console.log(node.getParentNode());
					fn_Search();
				} else {
					$("#menuCd").val("");
					$("#menuNm").val("");
					$("#menuPath").val("");
					//$("#btnRegist").hide();
					fn_RefreshList(true);
				}
			} else {
				$("#menuCd").val("");
				$("#menuNm").val("");
				$("#menuPath").val("");
				//$("#btnRegist").hide();
				fn_RefreshList(true);
			}
			//console.log(node);
		}
		//[트리 Fn] 사이트 변경시 트리 갱신
		function fn_LoadTree(e){

			var arrList = $("#menuCd").val().split(",");

			var setting = {
					check: {
						enable: true,
					},
					data: {
						simpleData: {
							enable: true
						}
					},
				view: {
					fontCss: getFontCss,
					showLine: true,
					selectedMulti: false,
					dblClickExpand: false
				}/*
					,
	 			 callback: {
					onClick: this.onClick,
					onCheck:function(e,treeId, node){
						 if(node.checked == true){
							 arrList.push(node.id);
		                        console.log(arrList);
		                    }else{
		                        var indexCh=arrList.indexOf(node.id);
		                        if(indexCh != -1){
		                        	arrList.splice(indexCh,1);
		                        }
		                        console.log(arrList);
		                    }
		                },

			   		fn_Regist:this.fn_Regist
	 			 }
				*/
	 		};
			//시스템 메뉴(관리자 모드)
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/authMenuAjax.do'/>",
				data : {"siteCd":$("#siteCd").val(),"menuTp":"ADMIN", "menuRole":"01"},
				dataType : "text",
				success : function(data){
					onebtnchk=0;
					//console.log(data); return false;
					var rJson = $.parseJSON(data);
					var arrJson = new Array();
					
					$.each(rJson,function(idx){
						var rData = $(this)[0];
						var objJson = new Object();
						var strIcon = "";
						var bNoLink = false;
						objJson.id   = rData.MENU_CD;
						objJson.pId  = rData.P_MENU_CD;
						objJson.name = rData.MENU_NM;
						objJson.noLink = bNoLink;
						arrJson.push(objJson);
					});

	 				var arrList = $("#menuCd").val().split(",");
	 				//console.log(arrList);
	 				//console.log(arrJson);

	 				for(var i=0; i<arrJson.length; i++){
	 					for(var j=0; j <arrList.length; j++){
								if(arrJson[i].id === arrList[j]){
									//console.log("arrJson[i].id === arrList[j] : " + arrJson[i].id);
									arrJson[i].checked = true;
							}
						}
					}
	 				//console.log(arrJson);
	 				//console.log(arrList);
	 				$.fn.zTree.init($("#zTree"),setting,arrJson);
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
			//관리자 메뉴(일반 모드)
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/authMenuAjax.do'/>",
				data : {"siteCd":$("#siteCd").val(),"menuTp":"ADMIN", "menuRole":"02"},
				dataType : "text",
				success : function(data){
					onebtnchk=0;
					//console.log(data); return false;
					var rJson = $.parseJSON(data);
					var arrJson = new Array();
					$.each(rJson,function(idx){
						var rData = $(this)[0];
						var objJson = new Object();
						var strIcon = "";
						var bNoLink = false;
						objJson.id   = rData.MENU_CD;
						objJson.pId  = rData.P_MENU_CD;
						objJson.name = rData.MENU_NM;
						objJson.noLink = bNoLink;
						arrJson.push(objJson);
					});

	 				var arrList = $("#menuCd").val().split(",");
	 				//console.log(arrList);
	 				//console.log(arrJson);

	 				for(var i=0; i<arrJson.length; i++){
	 					for(var j=0; j <arrList.length; j++){
								if(arrJson[i].id === arrList[j]){
									//console.log("arrJson[i].id === arrList[j] : " + arrJson[i].id);
									arrJson[i].checked = true;
							}
						}
					}
	 				//console.log(arrJson);
	 				//console.log(arrList);
	 				$.fn.zTree.init($("#zTree2"),setting,arrJson);
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//시스템 메뉴
		//[트리 Fn] 트리 모두 펼치기
		function fn_ZTreeExpandAll() {
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			zTree.expandAll(true);
		}
		//[트리 Fn] 트리 모두 닫기
		function fn_ZTreeCollapseAll() {
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			zTree.expandAll(false);
		}
		
		//관리자 메뉴
		//[트리 Fn] 트리 모두 펼치기
		function fn_ZTreeExpandAll2() {
			var zTree = $.fn.zTree.getZTreeObj("zTree2");
			zTree.expandAll(true);
		}
		//[트리 Fn] 트리 모두 닫기
		function fn_ZTreeCollapseAll2() {
			var zTree = $.fn.zTree.getZTreeObj("zTree2");
			zTree.expandAll(false);
		}

		/* //[트리 Fn] 리프레쉬
		function fn_ZTreeRefresh() {
			$("#siteCd").trigger("change");
			var timer = setInterval(function() {
				var zTree = $.fn.zTree.getZTreeObj("zTree");
				var node = zTree.getNodeByParam("id", $("#menuCd").val());
				zTree.selectNode(node);
				clearInterval(timer);
			}, 500);
		} */

		//트리 등록버튼 KDW 20200702.
		//버그수정.MOOK.2021.01.13.
		function fn_Save(){
			var zTree = $.fn.zTree.getZTreeObj("zTree");
		    var nodes = zTree.getNodes();
		    
			var zTree2 = $.fn.zTree.getZTreeObj("zTree2");
		    var nodes2 = zTree2.getNodes();
		    var arrList = [];
		    //console.log(nodes);
			//전체 노드 정보에서 체크드된 노드 정보만 추출 : menu_cd만
			//array -> .toString()
			//시스템 메뉴
			for( var i=0; i<nodes.length; i++ ){
				if( nodes[i].checked ){
					//2Depth
					if( nodes[i].children != undefined ){
						for( var j=0; j<nodes[i].children.length; j++ ){
							if( nodes[i].children[j].checked ){
								//3Depth
								if( nodes[i].children[j].children != undefined ){
									for( var k=0; k < nodes[i].children[j].children.length; k++ ){
										if( nodes[i].children[j].children[k].checked ){
											//4Depth [2024.01.22]
											if( nodes[i].children[j].children[k].children != undefined ){
												for( var l=0; l < nodes[i].children[j].children[k].children.length; l++ ){
													if( nodes[i].children[j].children[k].children[l].checked ){
														//5Depth [2024.01.22]
														if( nodes[i].children[j].children[k].children[l].children != undefined ){
															for( var m=0; m < nodes[i].children[j].children[k].children[l].children.length; m++ ){
																if( nodes[i].children[j].children[k].children[l].children[m].checked ){
																	arrList.push(nodes[i].children[j].children[k].children[l].children[m].id);
																}
															}
														}
														arrList.push(nodes[i].children[j].children[k].children[l].id);
													}
												}
											}
											arrList.push(nodes[i].children[j].children[k].id);
										}
									}
								}
								arrList.push(nodes[i].children[j].id);
							}
						}
					}
					arrList.push(nodes[i].id);
				}
			}
			
			//관리자 메뉴
			for( var i=0; i<nodes2.length; i++ ){
				if( nodes2[i].checked ){
					//2Depth
					if( nodes2[i].children != undefined ){
						for( var j=0; j<nodes2[i].children.length; j++ ){
							if( nodes2[i].children[j].checked ){
								//3Depth
								if( nodes2[i].children[j].children != undefined ){
									for( var k=0; k < nodes2[i].children[j].children.length; k++ ){
										if( nodes2[i].children[j].children[k].checked ){
											//4Depth [2024.01.22]
											if( nodes2[i].children[j].children[k].children != undefined ){
												for( var l=0; l < nodes2[i].children[j].children[k].children.length; l++ ){
													if( nodes2[i].children[j].children[k].children[l].checked ){
														//5Depth [2024.01.22]
														if( nodes2[i].children[j].children[k].children[l].children != undefined ){
															for( var m=0; m < nodes2[i].children[j].children[k].children[l].children.length; m++ ){
																if( nodes2[i].children[j].children[k].children[l].children[m].checked ){
																	arrList.push(nodes2[i].children[j].children[k].children[l].children[m].id);
																}
															}
														}
														arrList.push(nodes2[i].children[j].children[k].children[l].id);
													}
												}
											}
											arrList.push(nodes2[i].children[j].children[k].id);
										}
									}
								}
								arrList.push(nodes2[i].children[j].id);
							}
						}
					}
					arrList.push(nodes2[i].id);
				}
			}
			console.log("arrList : " + arrList);
			$("#menuCd").val(arrList);
			$("#frm").append("<input type='hidden' name='authDc' value='"+$("#authDc").val()+"'/>");
			$("#frm").append("<input type='hidden' name='authCd' value='"+$("#code").text()+"'/>");
			$("#frm").attr("action","<c:url value='/admmgr/manage/authCodeLayerRegistProc.do'/>").submit();
		}

		var key;
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
<input type="hidden" id="siteCd" name="siteCd"/>
<input type="hidden" id="menuCd" name="menuCd"/>
<input type="hidden" id="authCode" name="authCode"/>
</form>
	<div class="loader_wrap" style="display: none;">
		<div class="loader"></div>
		<p>변경사항 적용중입니다.<br/>잠시만 기다려주세요.</p>
	</div>
	<div class="listview_grid_wrap">
		<!-- list_grid_wrap -->
		<div class="list_grid_wrap wd620">
			<ul class="sitecod_con_flex">
				<li class="borad_area" style="flex:0; flex-basis: 270px;">
					<div class="all_ad_title">
						<p class="title_01">사이트 목록</p>
					</div>
					<div class="sitecod_con">
						<table id="authCode_0" class="code_table">
							<colgroup>
								<col width="90%"/>
								<col width="10%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">사이트명</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach items="${str:getSiteList()}" var="siteList" varStatus="status">
									<c:if test="${siteList.SITE_CD eq '001000000000000'}">
										<tr>
											<td><c:out value="${siteList.SITE_NM}"/></td>
											<td onclick="javascript:authCode.select(this,'<c:out value="${siteList.SITE_CD}"/>',1, null);">
												<img src="<c:url value='/common/admmgr/images/layout_n/icon_accept.svg'/>" class="select_icon" alt="선택">
											</td>
										</tr>
									</c:if>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</li>
				<li class="borad_area">
					<div class="all_ad_title">
						<p class="title_01">권한 목록</p>
						<p class="title_02">
							<input type="button" value="정렬순서 저장" onclick="javascript:fn_Regist('1'); return false;" style="width: 100px;">&nbsp;&nbsp;&nbsp;
							<input type="checkbox" class="depthChgChk" id="dept1Chg" style="width:18px;" onclick="authCode.sortChk(this, 1);"><label for="dept1Chg" style="color: white;">정렬순서 변경</label>
						</p>
					</div>
					<div class="sitecod_con">
						<table id="authCode_1" class="code_table">
							<colgroup>
								<col width="80%"/>
								<col width="10%"/>
								<col width="10%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">권한명</th> 
									<th class="center">삭제</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tfoot>
								<tr><td class="bd_green_color" colspan="4"><span onclick="authCode.addClick(this);">이곳을 클릭하여 새로운 권한을 등록하세요.</span></td></tr>
							</tfoot>
							<tbody></tbody>
						</table>
						<ol class="authSortList" id="authCodeSort_1"></ol>
					</div>
				</li>
			</ul>
		</div>
		<!-- // list_grid_wrap -->
		
		<!-- view_grid_wrap : 우측 상세정보 영역 -->
		<div id="detail_info" class="view_grid_wrap" style="width:calc(100% - 620px);">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">권한 설정</h6>
			</div>
			<!-- // table_header -->
			
			<div class="n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
					<colgroup>
						<col width="20%"/>
						<col width="30%"/>
						<col width="20%"/>
						<col width="30%"/>
					</colgroup>
					<tbody>
						<tr>
							<th>권한코드</th>
							<td id="code" class="tx_lft"></td>
							<th>권한명</th>
							<td id="name" class="tx_lft"></td>
						</tr>
							
						<tr>
							<th>권한설명</th>
							<td colspan="3"><textarea id="authDc" name="authDc" class="form_textarea" style="height:40px;" maxlength="100"><c:out value='${rMap.AUTH_DC}'/></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="n_table_sty01 n_view01 mt10 flx" style="display: flex; align-items: flex-start; gap: 10px;">	
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
					<colgroup>
						<col width="*"/>
					</colgroup>
					<tbody>
							<tr>
								<th>
									<div class="flx jc_between">
										<p>메뉴 권한 : 일반 모드</p>
										<div>
											<a href="#" class="btn primary xsm" onclick="javascript:fn_ZTreeExpandAll2();" style="display: none;">전체보기</a>
											<a href="#" class="btn secondary xsm" onclick="javascript:fn_ZTreeCollapseAll2();" style="display: none;">줄여보기</a>
										</div>
									</div>
								</th>
							</tr>
							<tr>
								<td valign="top">
									<ul id="zTree2" class="ztree"></ul>
								</td>
							</tr>
					</tbody>
				</table>
				
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
					<colgroup>
						<col width="*"/>
					</colgroup>
					<tbody>
							<tr>
								<th>
									<div class="flx jc_between">
										<p>메뉴 권한 : 관리자 모드</p>
										<div>
											<a href="#" class="btn primary xsm" onclick="javascript:fn_ZTreeExpandAll();" style="display: none;">전체보기</a>
											<a href="#" class="btn secondary xsm" onclick="javascript:fn_ZTreeCollapseAll();" style="display: none;">줄여보기</a>
										</div>
									</div>
								</th>
							</tr>
							<tr>
								<td valign="top">
									<ul id="zTree" class="ztree"></ul>
								</td>
							</tr>
					</tbody>
				</table>
				
			</div>
			
			<div class="page_btn_wrap">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Save();" style="display: none;"><span>등록</span></a>
				</div>
			</div>
			
		</div>
		<!-- // view_grid_wrap : 우측 상세정보 영역 -->
		
	</div>
</body>