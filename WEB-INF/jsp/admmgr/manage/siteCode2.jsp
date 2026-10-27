<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 사이트 코드 관리
 **************************************************/
%>
<c:set var="rootCode" value="000000000000000"/>
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
		.siteSortList li:nth-child(even){background:#f7f7f7;}
		.siteSortList li{
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
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/siteCode.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			$("div.loader_wrap").hide();
			$("#rootCode").val("<c:out value='${rootCode}'/>");
			siteCode.select(null,"<c:out value='${rootCode}'/>",1);

			var adjustment;
			$("ol.siteSortList").sortable({
				group: 'siteSortList',
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

		//저장
		function fn_Regist(depth){
			//초기화
			$("#frm").find("input[name=siteCode]").remove();
			var objList = $("ol.siteSortList li");

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
				$("#pCode").val($("#siteCode_"+depth).attr("pcode"));
				//[1]등록/수정될 목록 추출 및 hidden생성
				$("#siteCodeSort_"+depth+" li").each(function(idx){
					if( $(this).find("input[name=li_siteCode]").length > 0 ){
						$("#frm").append("<input type='hidden' name='siteCode' value='"+$(this).find("input[name=li_siteCode]").val()+"'>");
					}
				});

				$.ajax({
					url     : "<c:url value='/admmgr/manage/siteSortUpdateProcAjax.do'/>",
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
				url  : "<c:url value='/admmgr/manage/siteCodeRegistProcAjax.do'/>",
				data : { "siteCd" : $("#siteCd").text(), "url" : $("#url").val() },
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
<input type="hidden" id="rootCode" name="rootCode"/>
</form>
	<div class="loader_wrap" style="display: none;">
		<div class="loader"></div>
		<p>변경사항 적용중입니다.<br/>잠시만 기다려주세요.</p>
	</div>
	<div class="listview_grid_wrap">
		<!-- list_grid_wrap -->
		<div class="list_grid_wrap wd500">
			<ul class="sitecod_con_flex">
				<li class="borad_area" style="width:100%">
					<div class="all_ad_title">
						<p class="title_01">사이트 목록</p>
						<p class="title_02">
							<input type="button" value="정렬순서 저장" onclick="javascript:fn_Regist('1'); return false;" style="width: 100px;">&nbsp;&nbsp;&nbsp;
							<label for="dept1Chg" style="color: white;"><input type="checkbox" class="depthChgChk" id="dept1Chg" style="width:18px;" onclick="siteCode.sortChk(this, 1);">정렬순서 변경</label>
						</p>
					</div>
					<div class="sitecod_con">
						<table id="siteCode_1" class="code_table">
							<colgroup>
								<col width="80%"/>
								<col width="10%"/>
								<col width="10%"/>
							</colgroup>
							<thead>
								<tr>
									<th class="center">사이트명</th>
									<th class="center">삭제</th>
									<th class="center">선택</th>
								</tr>
							</thead>
							<tfoot>
								<tr><td class="bd_green_color" colspan="4"><span onclick="siteCode.addClick(this);">이곳을 클릭하여 새로운 사이트를 등록하세요.</span></td></tr>
							</tfoot>
							<tbody></tbody>
						</table>
						<ol class="siteSortList" id="siteCodeSort_1"></ol>
					</div>
				</li>
			</ul>
		</div>
		<!-- // list_grid_wrap -->
		
		<!-- view_grid_wrap : 우측 상세정보 영역 -->
		<div id="detail_info" class="view_grid_wrap" style="width:calc(100% - 500px);">
			<!-- table_header -->
			<div class="box_tit">
				<h6 class="title">사이트 설정</h6>
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
							<th>
								사이트 코드
								<!-- <div class="tooltip">
									<button class="tooltip_icon"></button>
									<div class="tooltip_inner">
										<div class="tooltip_con">
											아이디는 수정할 수 없습니다. 
										</div>
										<button class="tooltip_close"></button>
										<span class="tooltip_arrow"></span>
									</div>
								</div> -->
							</th>
							<td id="siteCd"></td>
						</tr>
						<tr>
							<th>사이트명</th>
							<td id="siteNm"></td>
						</tr>
						<tr>
							<th>URL</th>
							<td><input type="text" class="form_text w100" id="url" name="url"/></td>
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