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
<head>
	<style type="text/css">
		body.dragging, body.dragging *{
		  cursor: move !important;
		}
		.dragged{
		  position: absolute;
		  opacity: 0.5;
		  z-index: 2000;
		}
		.commSortList li:nth-child(even){background:#f7f7f7;}
		.commSortList li{
			line-height:30px;
			cursor:pointer;
			text-align:center;
			height:30px;
			background:#fff;  color:#333; font-size:14px;  padding:2px 10px; font-weight:normal; border:1px solid #ddd;
		}
	</style>
	<script type="text/javascript" src="<c:url value='/plug-in/jquery-sortable.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/plugin/tooltip.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/plugin/utility.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/commCode.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			$("div.loader_wrap").hide();
			
			var adjustment;
			$("ol.commSortList").sortable({
				group: 'commSortList',
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
		});
		
		function fn_ChangeSite(obj){
			var siteCd = $(obj).val();
			
			// -- 사이트 선택 -- 선택 시
			if($("#siteCode option:eq(0)").val() == siteCd) {
				$("#commCode_1").attr("pCode", "");
				commCode.selectSite(obj,siteCd,"",1);
				
			// 사이트 선택 시
			} else {
				commCode.selectSite(obj,siteCd,"000000000",1);
			}
		}
		
		//저장
		function fn_Regist(depth){
			//초기화
			$("#frm").find("input[name=commCode]").remove();
			var objList = $("ol.commSortList li");

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
				$("#siteCd").val(commCode.siteCd);
				//[1]등록/수정될 목록 추출 및 hidden생성
				$("#commCodeSort_"+depth+" li").each(function(idx){
					if( $(this).find("input[name=li_commCode]").length > 0 ){
						$("#frm").append("<input type='hidden' name='commCode' value='"+$(this).find("input[name=li_commCode]").val()+"'>");
					}
				});

				$.ajax({
					url     : "<c:url value='/admmgr/manage/commSortUpdateProcAjax.do'/>",
					type    : "POST",
					data    : $("#frm").serialize(),
					success : function(data){
						alert(data);
						$("div.loader_wrap").hide();
					}
				});
			}
		}
		
		function fn_Save() {
			$.ajax({
				type : "POST",
				url  : "<c:url value='/admmgr/manage/commCodeRegistProcAjax.do'/>",
				data : { "siteCd" : $("#siteCode").val(), "code" : $("#code").text(), "codeDc" : $("#codeDc").val() },
				dataType : "text",
				success : function(data){
					alert("등록 되었습니다.");
				},
				error :function(request, status, error){
					alert("처리 중 오류가 발생되었습니다.\nerror:"+error+"request:"+request+"status:"+status);
				} 
			});
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="siteCd" name="siteCd"/>
</form>
	<div class="loader_wrap" style="display: none;">
		<div class="loader"></div>
		<p>변경사항 적용중입니다.<br/>잠시만 기다려주세요.</p>
	</div>

	<p class="btn_section fix">
		<span>사이트 선택 : </span>&nbsp;&nbsp;
		<select id="siteCode" name="siteCode" class="form_select wd270" title="사이트 선택" onChange="javascript:fn_ChangeSite(this);">
			<option>-- 사이트 선택 --</option>
			<c:forEach items="${str:getSiteList()}" var="siteList" varStatus="status">
				<option value="<c:out value="${siteList.SITE_CD}"/>"><c:out value="${siteList.SITE_NM}"/></option>
			</c:forEach>
		</select>
	</p>
	
	<br>
	
	<div class="listview_grid_wrap" style="height: calc(100vh - 260px);">
		
		<!-- list_grid_wrap -->
		<div class="list_grid_wrap wd760">
			<ul class="sitecod_con_flex" style="gap:4px;">
				<%-- <li class="borad_area">
					<div class="all_ad_title">
						<p class="title_01">사이트 목록</p>
					</div>
					<div class="sitecod_con">
						<table id="commCode_0" class="code_table">
							<colgroup>
								<col width="80%"/>
								<col width="20%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">사이트명</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach items="${str:getSiteList()}" var="siteList" varStatus="status">
									<tr>
										<td><c:out value="${siteList.SITE_NM}"/></td>
										<td onclick="javascript:commCode.selectSite(this,'<c:out value="${siteList.SITE_CD}"/>','<c:out value="${siteList.SITE_CD}"/>',1);">
											<img src="<c:url value='/common/admmgr/images/layout_n/icon_accept.svg'/>" class="select_icon" alt="선택">
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</li> --%>
				<li class="borad_area">
					<div class="all_ad_title">
						<p class="title_01">대분류</p>
						<p class="title_02">
							<input type="button" value="정렬순서 저장" onclick="javascript:fn_Regist('1'); return false;" style="width: 100px;"/>
							&nbsp;&nbsp;&nbsp;
							<label for="dept1Chg" style="color: white;"><input type="checkbox" class="depthChgChk" id="dept1Chg" style="width:18px;" onclick="commCode.sortChk(this, 1);">정렬순서 변경</label>
						</p>
					</div>
					<div class="sitecod_con">
						<table id="commCode_1" class="code_table">
							<colgroup>
								<col width="66%"/>
								<col width="17%"/>
								<col width="17%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">코드명</th>
									<th class="center">삭제</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tfoot>
								<tr><td class="bd_green_color" colspan="3"><span onclick="commCode.addClick(this);">이곳을 클릭하여 새로운 코드를 등록하세요.</span></td></tr>
							</tfoot>
							<tbody></tbody>
						</table>
						<ol class="commSortList" id="commCodeSort_1"></ol>
					</div>
				</li>
				<li class="borad_area">
					<div class="all_ad_title">
						<p class="title_01">중분류</p>
						<p class="title_02">
							<input type="button" value="정렬순서 저장" onclick="javascript:fn_Regist('2'); return false;" style="width: 100px;">&nbsp;&nbsp;&nbsp;
							<label for="dept2Chg" style="color: white;"><input type="checkbox" class="depthChgChk" id="dept2Chg" style="width:18px;" onclick="commCode.sortChk(this, 2);">정렬순서 변경</label>
						</p>
					</div>
					<div class="sitecod_con">
						<table id="commCode_2" class="code_table">
							<colgroup>
								<col width="66%"/>
								<col width="17%"/>
								<col width="17%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">코드명</th>
									<th class="center">삭제</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tfoot>
								<tr><td class="bd_green_color" colspan="3"><span onclick="commCode.addClick(this);">이곳을 클릭하여 새로운 코드를 등록하세요.</span></td></tr>
							</tfoot>
							<tbody></tbody>
						</table>
						<ol class="commSortList" id="commCodeSort_2"></ol>
					</div>
				</li>
				<li class="borad_area mr0">
					<div class="all_ad_title">
						<p class="title_01">소분류 1</p>
						<p class="title_02">
							<input type="button" value="정렬순서 저장" onclick="javascript:fn_Regist('3'); return false;" style="width: 100px;">&nbsp;&nbsp;&nbsp;
							<label for="dept3Chg" style="color: white;"><input type="checkbox" class="depthChgChk" id="dept3Chg" style="width:18px;" onclick="commCode.sortChk(this, 3);">정렬순서 변경</label>
						</p>
					</div>
					<div class="sitecod_con">
						<table id="commCode_3" class="code_table">
							<colgroup>
								<col width="66%"/>
								<col width="17%"/>
								<col width="17%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">코드명</th>
									<th class="center">삭제</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tfoot>
								<tr><td class="bd_green_color" colspan="3"><span onclick="commCode.addClick(this);">이곳을 클릭하여 새로운 코드를 등록하세요.</span></td></tr>
							</tfoot>
							<tbody></tbody>
						</table>
						<ol class="commSortList" id="commCodeSort_3"></ol>
					</div>
				</li>
			</ul>
		</div>
		<!-- // list_grid_wrap -->
		
		<!-- view_grid_wrap : 우측 상세정보 영역 -->
		<div id="detail_info" class="view_grid_wrap" style="width:calc(100% - 760px);">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">코드 설정</h6>
			</div>
			<!-- // table_header -->
			
			<div class="table_wrap n_table_sty01 n_view01">
				<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
					<colgroup>
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody id="viewBody">
						<tr>
							<th>코드</th>
							<td id="code"></td>
						</tr>
						<tr>
							<th>코드명</th>
							<td id="codeNm"></td>
						</tr>
						<tr>
							<th>코드설명</th>
							<td><textarea id="codeDc" name="codeDc" class="form_textarea w100" style="height:100px; resize: none;" maxlength="100"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Save();" style="display: none;"><span>등록</span></a>
				</div>
			</div>
			
		</div>
		<!-- // view_grid_wrap : 우측 상세정보 영역 -->
		
	</div>
</body>