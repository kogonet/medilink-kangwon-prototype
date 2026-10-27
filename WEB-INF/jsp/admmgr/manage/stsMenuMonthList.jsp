<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 시스템 로그
 **************************************************/
%>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			
			//EnterKey
			$("#searchword").on("keydown",function(key){
		        if( key.keyCode == 13 ){
		        	fn_Search();
		        }
		    });
			
		});
		
		function monthSearch(year, month, dir){
			
			month = Number(month);
			if( dir == "P" ) month = month-1;
			else if( dir == "N" ) month = month+1;
			
			if(month==0){
				year = parseInt(year)-1;
				month = 12;
			}
			if(month > 12){
				year = parseInt(year)+1;
				month = 1;
			}
			
			if( month < 10 ) month = "0" + String(month);
			
			var regMonth = String(year) + "-" + String(month);
			
			location.href = "./stsMenuMonthList.do?regMonth=" + regMonth;
			
		}
		
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").prop("checked",true);
			}else{
				$("input[name=chk]").prop("checked",false);
			}
		}
		function fn_Search(){
			if( !fn_ValidateSearchDate("startDate","endDate") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/stsMenuMonthList.do'/>");
			$("#frm").submit();
		}
		
	</script>
	<style type="text/css">
		.radio .ch {
			margin-right: 15px;
			font-size: 18px;
		}
		.radio .ch span {
			margin-left: 5px;
		}
		.radio .ch input {
			transform: scale(1.5);
		}
	</style>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="siteCd" name="siteCd" value="001000000000000"/>
	<input type="hidden" id="userId" name="userId"/>
	<input type="hidden" id="userTp" name="userTp" value="${userTp}"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${ record_cnt }"/>
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
		
		<!-- 타이틀 -->
		<h4 class="sub_tit_h4 fix">
			<c:choose>
				<c:when test="${fn:toUpperCase(userTp) eq 'BASIC'}"><em>일반 회원 목록</em></c:when>
				<c:when test="${fn:toUpperCase(userTp) eq 'STUDY'}"><em>연구자 회원 목록</em></c:when>
				<c:when test="${fn:toUpperCase(userTp) eq 'EVAL'}"><em>평가위원 회원 목록</em></c:when>
			</c:choose>
		</h4>
		<!-- 타이틀 -->
		
		<%-- <div class="search_form_wrap mb15">
			<div class="search_form_inner">
				<div class="filter_form">
					<div>
						<label>검색조건</label>
						<select id="searchfield" name="searchfield" class="form_select md" title="검색조건 선택">
							<option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option>
							<option value="USER_ID" selected>아이디</option>
						</select>
						<input type="text" id="searchword" name="searchword" class="form_text md wd300" style="width:200px;" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
					</div>
					
					<div>
						<label>일자</label>
						<span class="form_date">
							<input type="text" id="startDate" name="startDate" placeholder="시작일 입력" class="form_text wd140" value="<c:out value="${startDate}"/>" onclick="calendar(event,'startDate','yyyy-mm-dd')">
								<input type="button" class="btn_form_date" onclick="javascript:$('#startDate').trigger('click');">
						</span>
						 ~
						<span class="form_date">
							<input type="text" id="endDate" name="endDate" placeholder="종료일 입력" class="form_text wd140" value="<c:out value="${endDate}"/>" onclick="calendar(event,'endDate','yyyy-mm-dd')" >
								<input type="button" class="btn_form_date" onclick="javascript:$('#endDate').trigger('click');">
						</span>
					</div>
				
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
		</div> --%>
		<!-- // 검색 -->
		
		<!-- 상단 정보 -->
		<!-- <div class="table_header mb5">
			<div class="lft">
				<a class="btn secondary sm" onclick="javascript:fn_radio();"><span>10개</span></a>
				record_cnt
				<label for="record_10" class="form_chip md"><input type="radio" id="record_10" name="record_cnt" value="10"><span>10개</span></label>
				<label for="record_30" class="form_chip md"><input type="radio" id="record_30" name="record_cnt" value="30"><span>30개</span></label>
				<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt" value="50"><span>50개</span></label>
				<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt" value="100"><span>100개</span></label>
				// record_cnt
			</div>

			<div class="rgt">
				<a class="btn_icon ico_xls sm" href="javascript:void(0);" onclick="javascript:fn_excelDown()">
					<i class="ico"><img src="/common/admmgr/images/icon/ico_xlsx02.svg" alt="엑셀"></i>
					<em>엑셀 다운로드</em>
				</a>
			</div>
			
		</div> -->
		<!-- 상단 정보 -->

		<!-- 리스트 -->	
		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="2%"/>
					<col width="10%"/>
					<col width="10%"/>						
				</colgroup>
				<thead>
					<tr>							
						<th class="center pr30">순위</th>
						<th class="center"><span>메뉴명</span></th>
						<th class="center"><span>집계 카운트</span></th>
					</tr>
				</thead>
				<tbody>
					<c:set var="sum" value="0" />
					<c:forEach items="${rList}" var="rList" varStatus="status">
						
						<c:set var="sum" value="${ rList.CNT + sum }" />
						
						<tr>								
							<td class="center">${ status.count }</td>
							<td class="center">${ rList.MENU_NM }</td>
							<td class="center"><fmt:formatNumber value="${rList.CNT}" pattern="#,###"/></td>
						</tr>
					</c:forEach>
					
					<c:if test="${ sum > 0 }">
						<tr>
							<td colspan="2" class="center">합계</td>
							<td class="center"><fmt:formatNumber value="${sum}" pattern="#,###"/></td>
						</tr>
					</c:if>
					
					<c:if test="${fn:length(rList) eq 0}">
						<tr><td colspan="3" class="center">등록된 집계현황이 없습니다.</td></tr>
					</c:if>
				</tbody>
			</table>
		</div>
		<!-- 리스트 -->
		
		<!-- table_footer -->
		<div class="table_footer">
			<div class="pagination_wrap">
				<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
			</div>
		</div>
		<!-- // table_footer -->

			
			
		</div>
		<!--sub_contents_area-->
		
	</div>
	<!-- sub_contents_wrap -->
	
</form>