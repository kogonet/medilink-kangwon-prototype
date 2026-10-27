<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
/**************************************************
 * @desc    : 컨텐츠 목록
 **************************************************/
%>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<link rel="stylesheet" href="<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/zTreeStyle.css'/>" type="text/css">
	<style type="text/css">
		.ztree li span.button.pIcon01_ico_open{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_open.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.pIcon01_ico_close{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/1_close.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.pIcon02_ico_open, .ztree li span.button.pIcon02_ico_close{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/2.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon01_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/3.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon02_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/4.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon03_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/5.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon04_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/6.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon05_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/7.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		.ztree li span.button.icon06_ico_docu{margin-right:2px; background: url(<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/8.png"/>) no-repeat scroll 0 0 transparent; vertical-align:top; *vertical-align:middle}
		
	</style>
	<script type="text/javascript" src="<c:url value='/plug-in/zTree_v3-master//js/jquery.ztree.core.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript">
		var lastValue = "", nodeList = [], fontCss = {};
		//[트리Fn]검색 후 폰트 변경
		function getFontCss(treeId,treeNode){
			return (!!treeNode.highlight) ? {color:"#A60000", "font-weight":"bold"} : {color:"#333", "font-weight":"normal"};
		}
		//[트리 Fn] 노드 검색 시 이벤트 1
		function focusKey(e){
			if(key.hasClass("empty")){
				key.removeClass("empty");
			}
		}
		//[트리 Fn] 노드 검색 시 이벤트 2
		function blurKey(e){
			if(key.get(0).value === ""){
				key.addClass("empty");
			}
		}
		//[트리 Fn] 노드 검색 후 필터
		function filter(node){
			return !node.isParent && node.isFirstNode;
		}
		//[트리 Fn] 노드 검색 후 노드 텍스트 변경
		function updateNodes(highlight){
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			for( var i=0, l=nodeList.length; i<l; i++){
				nodeList[i].highlight = highlight;
				zTree.updateNode(nodeList[i]);
			}
		}
		//[트리 Fn] 노드 검색
		function searchNode(e){
			var zTree = $.fn.zTree.getZTreeObj("zTree");
			var value = $.trim(key.get(0).value);
			var keyType = "name";
			if(key.hasClass("empty")){
				value = "";
			}
			if(lastValue === value) return;
			lastValue = value;
			if(value === "") return;
			updateNodes(false);
			nodeList = zTree.getNodesByParamFuzzy(keyType,value);
			updateNodes(true);
		}
		//[목록Fn]우측 결과 목록 초기화
		function fn_RefreshList(bResult){
			//console.log("=============>>> "+bResult);
			$("#rTbody").find("tr").remove();	//리스트 초기화
			$("#pageList").children().remove(); //페이징 초기화
			if( bResult ){
				$("#rTbody").append("<tr id=\"tdNoData\"><td colspan=\"8\" class=\"center\"><div class=\"con_empty\"><p class=\"empty_txt\">등록된 게시물이 없습니다.</p></div></td></tr>");
				if( $("#menuCd").val() != "" )	$("#btnRegist").show();
			}else{
				$("#btnRegist").hide();
			}
		}
		//[트리 Fn] 트리 클릭
		function onClick(e,treeId,node){
			//console.log(node);
			if( node.level > 0 ){
				if( !node.noLink ){
					//$("#btnRegist").show();
					$("#menuCd").val(node.id);
					$("#menuNm").val(node.name);
					var arrMenuPath = new Array();
					$.each(node.getPath(),function(idx){
						arrMenuPath.push($(this)[0].name);
					});
					var strMenuPath = arrMenuPath.toString();
					strMenuPath = strMenuPath.replaceAll(","," > ");
					$("#menuPath").val(strMenuPath);
					//console.log(node.getPath());
					//console.log(node.getParentNode());
					fn_Search();
				}else{
					$("#menuCd").val("");
					$("#menuNm").val("");
					$("#menuPath").val("");
					//$("#btnRegist").hide();
					fn_RefreshList(true);
				}
			}else{
				//최상위 노드가 컨텐츠 타입일시
				if( node.menuType == "001001002" ){
					$("#menuCd").val(node.id);
					$("#menuNm").val(node.name);
					var arrMenuPath = new Array();
					$.each(node.getPath(),function(idx){
						arrMenuPath.push($(this)[0].name);
					});
					var strMenuPath = arrMenuPath.toString();
					strMenuPath = strMenuPath.replaceAll(","," > ");
					$("#menuPath").val(strMenuPath);
					//console.log(node.getPath());
					//console.log(node.getParentNode());
					fn_Search();
				}else{
					$("#menuCd").val("");
					$("#menuNm").val("");
					$("#menuPath").val("");
					//$("#btnRegist").hide();
					fn_RefreshList(true);
				}

			}
			//console.log(node);
		}
		//[트리 Fn] 사이트 변경시 트리 갱신
		function fn_ChangeSite(obj){
			$("div.loader_wrap").show();
			fn_RefreshList(true);
			var setting = {
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
				},
				callback: {
					//onNodeCreated: this.onNodeCreated,
					//beforeClick: this.beforeClick,
					onClick: this.onClick
				}
			};
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/contsMenuAjax.do'/>",
				data : {"siteCd":$(obj).val()},
				dataType : "text",
				success : function(data){
					onebtnchk=0;
					//console.log(data);
					var rJson = $.parseJSON(data);
					var arrJson = new Array();
					$.each(rJson,function(idx){
						var rData = $(this)[0];
						var objJson = new Object();
						var strIcon = "";
						var bNoLink = false;

						//메뉴코드 맨 앞자리가 0인것은 관리자메뉴이므로 컨텐츠관리 메뉴에 표시되면 안됨
						if(rData.MENU_CD.substring(0, 1) != "0"){
							console.log(rData.CHILD_CNT);
							//하위 노드가 없을 때
							if( Number(rData.CHILD_CNT) == 0 ){
								//메뉴타입이 콘텐츠일시
								if( rData.MENU_TP == "001001002" ){
									bNoLink = false;
									//콘텐츠가 매핑되어 있을시
									if( Number(rData.CONTS_CNT) > 0 ){
										//console.log("메뉴매핑됨["+rData+"]");
										strIcon = "<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_y.png'/>";
									//콘텐츠가 매핑안되어 있을시
									}else{
										strIcon = "<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_n.png'/>";
									}
								//메뉴타입이 콘텐츠가 아닐시
								}else{
									bNoLink = true;
									strIcon = "<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_no_map.png'/>";
								}
							//하위노드가 있을 때
							}else{
								//메뉴타입이 콘텐츠일시
								if( rData.MENU_TP == "001001002" ){
									bNoLink = false;
									//콘텐츠가 매핑되어 있을시
									if( Number(rData.CONTS_CNT) > 0 ){
										strIcon = "<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_y.png'/>";
									//콘텐츠가 매핑안되어 있을시
									}else{
										strIcon = "<c:url value='/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_n.png'/>";
									}
								}else{
									bNoLink = true;
								}
							}
							objJson.id   = rData.MENU_CD;
							objJson.pId  = rData.P_MENU_CD;
							objJson.name = rData.MENU_NM;
							objJson.menuType = rData.MENU_TP;//메뉴타입도 매핑함.
							objJson.icon = strIcon;
							objJson.noLink = bNoLink;
							arrJson.push(objJson);
						}
					});
					//return false;
					$.fn.zTree.init($("#zTree"),setting,arrJson);
					$("div.loader_wrap").hide();
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
					$("div.bh_on_rev_loader").hide();
				}
			});
		}
		//[트리 Fn] 트리 모두 펼치기
		function fn_ZTreeExpandAll(){
			var zTree = $.fn.zTree.getZTreeObj("zTree");
		    zTree.expandAll(true);
		}
		//[트리 Fn] 트리 모두 닫기
		function fn_ZTreeCollapseAll(){
			var zTree = $.fn.zTree.getZTreeObj("zTree");
		    zTree.expandAll(false);
		}
		//[트리 Fn] 리프레쉬
		function fn_ZTreeRefresh(){
			$("#siteCd").trigger("change");
			var timer = setInterval(function(){
				var zTree = $.fn.zTree.getZTreeObj("zTree");
				var node = zTree.getNodeByParam("id",$("#menuCd").val());
				zTree.selectNode(node);
				clearInterval(timer);
			},500);
		}
		var key;
		$(document).ready(function(){
			$("div.loader_wrap").hide();//로딩바 숨김
			$("#btnRegist").hide();//등록 버튼 숨김
			$("#siteCd").trigger("change");
			key = $("#treeword");
			key.bind("focus", focusKey)
			.bind("blur", blurKey)
			.bind("propertychange", searchNode)
			.bind("input", searchNode);
		});


		var recordcnt;//페이지당레코드수
		var totalrecordcnt;// 총레코드수
		var blockcnt;// 블록당페이지수
		var num;// 번호
		var nowblock;// 현재블록
		var totalblockcnt;// 총블록수
		var totalpagecnt;// 총페이지수

		function fn_IntOverflow(val){
			var result = Number(val);
			if( result < 0 )	return 0;
			return result;
		}

		//[페이징 Fn]시작레코드번호
		function fn_get_start_record(page){
			var _page = fn_IntOverflow( (( page - 1 ) * recordcnt) +1 );
			return _page;
		}
		//[페이징 Fn]읽을 레코드 수
		function fn_get_end_record(page){
			var _page = fn_IntOverflow( page * recordcnt );
			return _page;
		}
		//[페이징 Fn]시작페이지번호
		function fn_get_startpage(page){
			var _page = fn_IntOverflow( (( nowblock - 1 ) * blockcnt) + 1 );
			return Number(_page);
		}
		//[페이징 Fn]끝페이지번호
		function fn_get_endpage(page){
			var endpage;
			if( nowblock == totalblockcnt ) {
				endpage = totalpagecnt;
			} else {
				endpage = nowblock * blockcnt;
			}
			var _page = fn_IntOverflow( endpage );
			return Number(_page);
		}
		//[페이징 Fn]페이지 이동
		function fn_MovePage(page){
			var pageIndex  = Number(page)-1;
			var pageSize   = Number($("#pageSize").val());
			var startIndex = (pageIndex*pageSize)+1;
			var endIndex   = Number(page)*pageSize;
			$("#page").val(page);
			$("#pageStart").val(startIndex);
			$("#pageEnd").val(endIndex);
			fn_Search();
		}

		//[목록 Fn]페이징
		function fn_MakePaging(){
			//[2] 페이징 계산
			recordcnt    = Number($("#pageSize").val());	//페이지당 나타낼 게시물
			blockcnt     = Number($("#pageSize").val());	//블록당 나타낼 페이지수
			var page     = Number($("#page").val());		//현재 페이지
			var totalcnt = Number($("#rows").val());		//총 게시물수
			num       = fn_IntOverflow( totalcnt - ((page-1)*recordcnt) );
			var _nowblock = Math.ceil( page / blockcnt );	//현재 블록
			nowblock = fn_IntOverflow( _nowblock );
			totalrecordcnt = Number($("#rows").val());;	//총 게시물수
			var _totalpagecnt = Math.ceil( totalrecordcnt / recordcnt );	//총 페이지수
			totalpagecnt = fn_IntOverflow( _totalpagecnt );
			var _totalblockcnt = Math.ceil( totalpagecnt / blockcnt );	//총 블록수
			totalblockcnt = fn_IntOverflow( _totalblockcnt );

			//[3] 페이징 그리기
			var imgPath     = "/common/admmgr/images/";
			var pageContext = "${pageContext.request.contextPath}";
			var target      = "";
			if( page == 0 ) page = 1;
			var startpage = fn_get_startpage(page);
			var endpage   = fn_get_endpage(page);
			var pageHtml = "";

			//[3-1]페이징 앞(좌) 버튼
			pageHtml += "<ul id='leftnav'>";
			if( page != 1 ){
				pageHtml += "<li><a href=\"javascript:fn_MovePage(1);\"><img src='"+pageContext+imgPath+"sub_common/btn_ppre.png' alt='처음 페이지'/></a></li>";
			}
			if( nowblock != 1 ) {
				var tmpPageNo = (nowblock-1)*blockcnt;
				pageHtml += "<li><a href=\"javascript:fn_MovePage("+tmpPageNo+");\"><img src='"+pageContext+imgPath+"sub_common/btn_pre.png' alt='이전 페이지'/></a></li>";
			}
			pageHtml += "</ul>";

			//[3-2]페이징 숫자
			pageHtml += "<ol>";
			for( var i=startpage; i<=endpage; i++ ){
				if( page == i ){
					pageHtml += "<li><strong>"+i+"</strong></li>";
				}else{
					pageHtml += "<li><a href=\"javascript:fn_MovePage("+i+");\">"+i+"</a></li>";
				}
			}
			pageHtml += "</ol>";

			//[3-3]페이징 뒤(우) 버튼
			pageHtml += "<ul id='rightnav'>";
			if( nowblock != totalblockcnt ) {
				var tmpPageNo = (nowblock*blockcnt)+1;
				pageHtml += "<li><a href=\"javascript:fn_MovePage("+tmpPageNo+");\"><img src='"+pageContext+imgPath+"sub_common/btn_nxt.png' alt='다음 페이지'/></a></li>";
			}
			view = "<li><a href='%s'><img src='"+pageContext+imgPath+"sub_common/btn_nnxt.png' alt='마지막 페이지'/></a></li>";
			if( nowblock != totalblockcnt ) {
				pageHtml += "<li><a href=\"javascript:fn_MovePage("+totalpagecnt+");\"><img src='"+pageContext+imgPath+"sub_common/btn_nnxt.png' alt='마지막 페이지'/></a></li>";
			}
			pageHtml += "</ul>";
			$("#pageList").append(pageHtml);

		}
		//[목록 Fn]목록 갱신
		function fn_Search(){
			var objTbody = $("#rTbody");
			//페이지 시작/종료 index 계산
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/contsHistListAjax.do'/>",
				data : {"siteCd":$("#siteCd").val(),"menuCd":$("#menuCd").val(),"pageStart":$("#pageStart").val(),"pageEnd":$("#pageEnd").val()},
				dataType : "text",
				success : function(data){
					onebtnchk=0;
					//console.log(data);
					//return false;
					var rJson = $.parseJSON(data);
					//var rJson = JSON.stringify(data);
					//return false;
					//console.log(rJson);
					if( rJson.rList != undefined && rJson.rList != null ){
						if( rJson.rList.length > 0 ){
							fn_RefreshList(false);
							var strHtml = "";
							$.each(rJson.rList,function(idx){
								var rData = $(this)[0];
								strHtml += "<tr>";
								strHtml += "<td>"+rData.RNUM+"</td>";
								strHtml += "<td>"+rData.CONTS_VER+"</td>";
								strHtml += "<td>"+rData.SITE_NM+"</td>";
								strHtml += "<td style='text-align:left'><a href=\"javascript:void(0);\" onclick=\"javascript:fn_Detail('"+rData.SITE_CD+"','"+rData.MENU_CD+"','"+rData.CONTS_VER+"');\">"+rData.TITLE+"</td>";
								strHtml += "<td>"+rData.MDF_ID+"</td>";
								strHtml += "<td>"+rData.MDF_DT+"</td>";
								if( rData.CONTS_VER == rData.CONTS_VER_NOW ){
									strHtml += "<td>현재 적용 컨텐츠</td>";
								}else{
									strHtml += "<td><button class=\"btn secondary xsm wd80\" href=\"javascript:void(0);\" onclick=\"javascript:fn_UpdateCurrConts('"+rData.SITE_CD+"','"+rData.MENU_CD+"','"+rData.CONTS_VER+"');\"><span>적용</span></button></td>";
								}
								strHtml += "<td><button class=\"btn primary xsm wd80\" href=\"javascript:void(0);\" onclick=\"javascript:fn_HistPreView('"+rData.SITE_CD+"','"+rData.MENU_CD+"','"+rData.CONTS_VER+"');\"><span>미리보기</span></button></td>";
								strHtml += "</tr>";
							});
							objTbody.append(strHtml);
							$("#rows").val(rJson.rows);
							fn_MakePaging();
						}else{
							fn_RefreshList(true);
						}
					}else{
						fn_RefreshList(true);
					}
				},
				error : function(request,status,error){
					onebtnchk=0;
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				}
			});
		}
		//등록화면 레이어 팝업
		function fn_Regist(){
			FrameLayer.open("<c:url value='/admmgr/manage/contsWriteLayer.do'/>",800,700,"yes",{
				"siteCd"   : $("#siteCd option:selected").val(),
				"siteNm"   : $("#siteCd option:selected").text(),
				"menuCd"   : $("#menuCd").val(),
				"menuNm"   : $("#menuNm").val(),
				"menuPath" : $("#menuPath").val()
			});
		}
		//수정화면 레이어 팝업
		function fn_Detail(siteCd,menuCd,contsVer){
			FrameLayer.open("<c:url value='/admmgr/manage/contsWriteLayer.do'/>",800,700,"yes",{
				"siteCd"   : siteCd,
				"menuCd"   : menuCd,
				"contsVer" : contsVer
			});
		}
		//적용
		function fn_UpdateCurrConts(siteCd,menuCd,contsVer){
			if( confirm("선택한 버젼으로 적용 하시겠습니까?") ){
				$.ajax({
					type : "POST",
					url  : "<c:url value='/admmgr/manage/contsUpdateCurrContsProcAjax.do'/>",
					data : {"siteCd":siteCd,"menuCd":menuCd,"contsVer":contsVer},
					dataType : "text",
					success : function(data){
						onebtnchk=0;
						if( data == "OK" ){
							alert("적용 되었습니다.");
							fn_Search();
						}else{
							alert("적용 중 오류가 발생되었습니다.");
						}
					},
					error : function(request,status,error){
						onebtnchk=0;
						alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
					}
				});
			}
		}
		//미리보기
		function fn_HistPreView(siteCd,menuCd,contsVer){
			var array = {"siteCd":siteCd,"menuCd":menuCd,"contsVer":contsVer};
			var popWidth  = window.screen.width;
			var popHeight = window.screen.height;
			if( Number(siteCd) > 10000000 ){
				popWidth  = popWidth/2;
				//popHeight = popHeight/2;
			}
			G_PostPopupOpen("PreViewPop","<c:url value='/admmgr/manage/contsViewPop.do'/>",popWidth,popHeight,array);
		}
	</script>
</head>
<body>
<%-- Ajax Paging Form --%>
<form id="pageFrm" name="pageFrm" method="POST">
	<input type="hidden" id="pageStart" name="pageStart" value="1"/>
	<input type="hidden" id="pageEnd" name="pageEnd" value="10"/>
	<input type="hidden" id="pageSize" name="pageSize" value="10"/>
	<input type="hidden" id="page" name="page" value="1"/>
	<input type="hidden" id="rows" name="rows"/>
</form>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="menuCd" name="menuCd"/>
	<input type="hidden" id="menuNm" name="menuNm"/>
	<input type="hidden" id="menuPath" name="menuPath"/>
	<input type="hidden" id="contsVer" name="contsVer"/>
</form>

<!--sub_contents_wrap-->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

		<!-- treemenu_con_area -->
		<div class="treemenu_con_area fix">
			<!--로딩 바-->
			<div class="loader_wrap" style="display: none;">
				<div class="loader"></div>
				<p>메뉴정보를 조회중입니다.<br/>잠시만 기다려주세요.</p>
			</div>
			<!--/로딩 바-->
			<!-- treemenu_lft_area -->
			<div class="treemenu_lft_area">
				<!-- treemenu_top_area -->
				<div class="treemenu_top_area">
					<select id="siteCd" name="siteCd" class="form_select wd200" title="사이트 선택" onChange="javascript:fn_ChangeSite(this);">
						<c:forEach items="${siteList}" var="siteList" varStatus="status">
							<c:if test="${siteList.SITE_CD ne '001000000000000'}">
							<option value="<c:out value="${siteList.SITE_CD}"/>" ${(param.siteCd eq siteList.SITE_CD)?"selected='selected'":""}><c:out value="${siteList.SITE_NM}"/></option>
							</c:if>
						</c:forEach>
					</select>
					<%-- <input type="text" id="treeword" name="treeword" class="input_text_n" style="width:165px;" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
					<a href="#" class="btn_search"></a> --%>
				</div>
				<!-- // treemenu_top_area -->
				<!-- zTreeDemoBackground -->
				<div class="zTreeDemoBackground left">
					<!-- treemenu_tab -->
					<ul class="treemenu_tab">
						<li class="flx">
							<a href="#" class="btn secondary" onclick="javascript:fn_ZTreeExpandAll();"><span>전체보기</span></a>
							<a href="#" class="btn secondary ml5" onclick="javascript:fn_ZTreeCollapseAll();"><span>줄여보기</span></a>
						</li>
					</ul>
					<!-- // treemenu_tab -->
					<ul id="zTree" class="ztree mt30"></ul>
				</div>
				<!-- // zTreeDemoBackground -->
			</div>
			<!-- // treemenu_lft_area -->

			<!-- treemenu_rgt_area -->
			<div class="treemenu_rgt_area">
					<div class="search_list_table">

					<div class="noti_area mt0">
						<p class="noti_text"><em>수정시 컨텐츠 버전이 올라가고 목록</em>이 추가됩니다.<br/>
						<p class="noti_text">
							<img src="<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_y.png"/>"/> : 컨텐츠 메뉴(컨텐츠 등록됨)
							&nbsp;&nbsp;&nbsp;
							<img src="<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_map_n.png"/>"/> : 컨텐츠 메뉴(컨텐츠 등록 필요)
							&nbsp;&nbsp;&nbsp;
							<img src="<c:url value="/plug-in/zTree_v3-master/css/zTreeStyle/img/diy/diy_conts_no_map.png"/>"/> : 컨텐츠 메뉴 아님(컨텐츠 등록 불가)
							&nbsp;&nbsp;&nbsp;
						</p>
					</div>

					<!--리스트 시작-->
					<div class="n_table_sty01 n_list01 mt10">
						<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
							<colgroup>
								<col width="5%"/>
								<col width="5%"/>
								<col width="15%"/>
								<col width="%"/>
								<col width="7%"/>
								<col width="12%"/>
								<col width="10%"/>
								<col width="10%"/>
							</colgroup>
							<thead>
								<tr>
									<th>번호</th>
									<th><span>버젼</span></th>
									<th><span>사이트명</span></th>
									<th><span>컨텐츠명</span></th>
									<th><span>작성자</span></th>
									<th><span>등록일시</span></th>
									<th><span>현재적용</span></th>
									<th><span>미리보기</span></th>
								</tr>
							</thead>
							<tbody id="rTbody"></tbody>
						</table>
					</div>

					<div class="table_footer">
						<!-- pagination -->
						<div class="pagination_wrap">
							<div id="pageList"></div>
						</div>
						<!-- // pagination -->

						<span class="btn_wrap rgt">
							<a id="btnRegist" class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
						</span>
					
					</div>
					
					<!--/리스트 끝-->

				</div>
				<!--// sub_contents_area-->

			</div>
			<!-- // treemenu_rgt_area -->
		</div>
		<!-- // treemenu_con_area -->
	
	</div>
	<!-- // sub_contents_area -->

</div>
<!-- // sub_contents_wrap -->
</body>