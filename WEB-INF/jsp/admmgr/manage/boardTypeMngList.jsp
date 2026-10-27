<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 게시판 속성 관리
 **************************************************/
%>
<head>
<style type="text/css">
.search_board_form > ul > li{width: auto;}
</style>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript">
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").attr("checked",true);
			}else{
				$("input[name=chk]").attr("checked",false);
			}
		}
		function fn_Search(){
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngList.do'/>");
			$("#frm").submit();
		}
		function fn_Detail(boardMngNo){
			$("#boardMngNo").val(boardMngNo);
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngView.do'/>");
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngWrite.do'/>");
			$("#frm").submit();
		}
		//삭제
		function fn_Delete(){
			var checkedCnt = 0;
			$("input[name=chk]").each(function(){
				if( $(this).is(":checked") ){
					checkedCnt++;
				}
			});
			if( checkedCnt == 0 ){
				alert("삭제할 항목을 선택해 주세요.");
				return false;
			}
			if( confirm("선택된 항목을 삭제하겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/manage/boardTypeMngDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
<input type="hidden" id="boardMngNo" name="boardMngNo"/>
<!--sub_contents_wrap-->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

		<!-- 검색 -->
		<div class="search_form_wrap mb10">
			<div class="search_form_inner">
				<div class="filter_form">
					<div>
						<label>검색조건</label>
						<select id="searchfield" name="searchfield" class="form_select md" title="조건 선택" style="width: 100px;">
							<option value="ALL">전체</option>
							<option value="TITLE" ${ param.searchfield eq 'TITLE' ? "selected='selected'" : "" }>게시판명</option>
							<option value="CONTS" ${ param.searchfield eq 'CONTS' ? "selected='selected'" : "" }>게시판설명</option>
						</select>
						<input type="text" id="searchword" name="searchword" class="form_text md wd300" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
					</div>
					<div>
						<label>등록일자</label>
						<div>
							<span class="form_date">
								<input type="text" id="s_date_start" name="s_date_start" placeholder="시작일 입력" class="form_text wd140" value="<c:out value="${param.s_date_start}"/>" onclick="calendar(event,'s_date_start','yyyy-mm-dd')">
								<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_start').trigger('click');">
							</span>
							~
							<span class="form_date">
								<input type="text" id="s_date_end" name="s_date_end" placeholder="종료일 입력" class="form_text wd140" value="<c:out value="${param.s_date_end}"/>" onclick="calendar(event,'s_date_end','yyyy-mm-dd')" >
								<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_end').trigger('click');">
							</span>
						</div>
					</div>

					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>

				</div>
			</div>
		</div>
		<!-- // 검색 -->

		<!--리스트 시작-->
		<div class="n_table_sty01 n_list01 mt10">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="3%"/>
					<col width="6%"/>
					<col width="6%"/>
					<col width="*"/>
					<col width="10%"/>
					<col width="6%"/>
					<col width="10%"/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th><span>관리번호</span></th>
						<th><span>게시판번호</span></th>
						<th><span>게시판명</span></th>
						<th><span>게시판목록구분</span></th>
						<th><span>등록자</span></th>
						<th><span>등록일시</span></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${rList.BOARD_MNG_NO}"/>"/></td>
							<td><fmt:formatNumber value="${PAGING_NUM - status.index}" groupingUsed="true"/></td>
							<td>${rList.BOARD_MNG_NO}</td>
							<td style="text-align:left;"><a href="javascript:fn_Detail('<c:out value="${rList.BOARD_MNG_NO}"/>');"><c:out value="${rList.BOARD_NM}"/></a></td>
							<td><c:out value="${rList.BOARD_LIST_TYPE}"/></td>
							<td><c:out value="${ empty rList.MDF_NM ? rList.MDF_ID : rList.MDF_NM }"/></td>
							<td><c:out value="${rList.MDF_DT}"/></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}">
						<tr><td colspan="13">등록된 게시물이 없습니다.</td></tr>
					</c:if>
				</tbody>
			</table>
		</div>

		<div class="table_footer">
			<div class="btn_wrap lft">
				<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
			</div>

			<div class="pagination_wrap">
				<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
			</div>

			<div class="btn_wrap rgt">
				<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
			</div>

		</div>


	</div>
	<!--// sub_contents_area-->

</div>
<!--/ sub_contents_wrap-->
</form>
</body>