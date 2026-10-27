<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 코드 관리 레이어
 **************************************************/
%>
<head>
<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
<link rel="stylesheet" href="<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/zTreeStyle.css'/>"
	type="text/css">
<style type="text/css">
.ztree li span.button.pIcon01_ico_open {
	margin-right: 2px;
	background:
		url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_open.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.pIcon01_ico_close {
	margin-right: 2px;
	background:
		url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_close.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.pIcon02_ico_open, .ztree li span.button.pIcon02_ico_close
	{
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/2.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon01_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/3.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon02_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/4.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon03_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/5.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon04_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/6.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon05_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/7.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
.ztree li span.button.icon06_ico_docu {
	margin-right: 2px;
	background: url(/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/8.png)
		no-repeat scroll 0 0 transparent;
	vertical-align: top;
	*vertical-align: middle
}
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
<script type="text/javascript" src="<c:url value='/plug-in/zTree_v3-master//js/jquery.ztree.core.js'/>"></script>
<script type="text/javascript" src="<c:url value='/plug-in/zTree_v3-master//js/jquery.ztree.excheck.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
<script type="text/javascript">
	function checkForm( form ){
		/*
		if( !form.codeVal.value.trim() ){
			alert( "코드값을 입력해주세요." );
			form.codeVal.focus();
			return false;
		}
		*/
		return true;
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
	function fn_Regist(){
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
		$("#regiform").attr("action","<c:url value='/admmgr/manage/authCodeLayerRegistProc.do'/>").submit();
	}

	var key;
	$(document).ready(function(){
		//$("div.bh_on_rev_loader").hide();//로딩바 숨김
		//$("#btnRegist").hide();//등록 버튼 숨김
		//fn_ChangeSite();
		fn_LoadTree();
		key = $("#treeword");
		key.bind("focus", focusKey).bind("blur", blurKey).bind("propertychange",searchNode).bind("input",searchNode);
	});
</script>
</head>
<body>
	<form id="regiform" method="POST" action="<c:url value='/admmgr/manage/authCodeLayerRegistProc.do'/>">
		<input type="hidden" id="authCd" name="authCd" value="<c:out value='${rMap.AUTH_CD}'/>"/>
		<input type="hidden" id="siteCd" name="siteCd" value="<c:out value='${rMap.SITE_CD}'/>"/>
		<input type="hidden" id="menuCd" name="menuCd" value="<c:out value='${rMap.MENU_CD}'/>" />
	
		<div class="pop_con_section">
			<h6 class="sub_tit_h6 fix"><em>정보 설정</em></h6>
			<div class="n_table_sty01 n_view01 mt10 flx" style="display: flex; align-items: flex-start; gap: 10px;">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
					<colgroup>
						<col width="25%"/>
						<col width="35%"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
							<th>권한코드</th>
							<td class="tx_lft"><c:out value='${rMap.AUTH_CD}'/></td>
							<th>권한명</th>
							<td class="tx_lft"><c:out value='${rMap.AUTH_NM}'/></td>
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
									메뉴 권한 : 관리자 모드
									<a href="#" class="btn primary xsm" onclick="javascript:fn_ZTreeExpandAll();">전체보기</a>
									<a href="#" class="btn secondary xsm" onclick="javascript:fn_ZTreeCollapseAll();">줄여보기</a>
								</th>
							</tr>
							<tr>
								<td valign="top">
									<ul id="zTree" class="ztree"></ul>
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
									메뉴 권한 : 일반 모드
									<a href="#" class="btn primary xsm" onclick="javascript:fn_ZTreeExpandAll2();">전체보기</a>
									<a href="#" class="btn secondary xsm" onclick="javascript:fn_ZTreeCollapseAll2();">줄여보기</a>
								</th>
							</tr>
							<tr>
								<td valign="top">
									<ul id="zTree2" class="ztree"></ul>
								</td>
							</tr>
					</tbody>
				</table>
			</div>
			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_add" href="javascript:void(0);" onclick="javavscript:fn_Regist();"><em>등록</em></a>
				</div>
			</div>
		</div>
							
	</form>
</body>