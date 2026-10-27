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
	<style type="text/css">.search_board_form > ul > li{width: auto;}</style>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript">
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").prop("checked",true);
			}else{
				$("input[name=chk]").prop("checked",false);
			}
		}
		function fn_Search(){
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/member/adminConn.do'/>");
			$("#frm").submit();
		}
		// 엑셀 다운로드
		function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/adminConnDown.do'/>");
			$("#frm").submit();
		}
		function fn_radio() {
			var radioSection = $(".radio");
		    var imgElement = $(".btn2_ty3 + em img");

		    if (radioSection.is(":visible")) {
		        radioSection.hide();
		        imgElement.attr("src", "/common/admmgr/images/sub_common/btn_open1.png");
		    } else {
		        radioSection.show();
		        imgElement.attr("src", "/common/admmgr/images/sub_common/btn_close1.png");
		    }
		}
		/*
		//승인
		function fn_Approve(){
			var checkedCnt = 0;
			$("input[name=chk]").each(function(){
				if( $(this).is(":checked") ){
					checkedCnt++;
				}
			});
			if( checkedCnt == 0 ){
				alert("승인할 항목을 선택해 주세요.");
				return false;
			}
			if( confirm("선택된 항목을 승인하겠습니까?") ){
				$("#frm").attr("action","<c:url value='/admmgr/member/comApproveProc.do'/>");
				$("#frm").submit();
			}
		}
		*/
		$(document).ready(function() {
			
			// record_cnt
			var record_cnt = $('#record_cnt').val();
			$('#record_' + record_cnt).attr('checked','checked');
			
			if ( record_cnt != '' ) {
				$(".btn2_ty3 + em img").attr("src", "/common/admmgr/images/sub_common/btn_close1.png");
		        $(".radio").show();
		    }
			
			$("input[name='record_cnt']").change(function() {
	            // 체크된 체크박스의 수를 확인합니다.
	            var chkRadio = $("input[name='record_cnt']:checked");

	            // 체크박스가 선택된 경우 폼을 제출합니다.
	            if (chkRadio.length > 0) {
	            	$("#record_cnt").val($(this).val());
	                $("#frm").attr("action", "<c:url value='/admmgr/member/adminConn.do'/>");
	                $("#frm").submit();
	            }
	        });
			
			//EnterKey
			$("#searchword").on("keydown",function(key){
		        if( key.keyCode == 13 ){
		        	fn_Search();
		        }
		    });
			
		});
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
		
		<div class="search_form_wrap mb15">
			<div class="search_form_inner">
				<div class="filter_form">
					<div>
						<label>검색조건</label>
						<select id="searchfield" name="searchfield" class="form_select md" title="검색조건 선택">
							<%-- <option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option> --%>
							<option value="USER_ID" selected>아이디</option>
						</select>
						<input type="text" id="searchword" name="searchword" class="form_text md wd300" style="width:200px;" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
					</div>
					
					<div>
						<label>등록일자</label>
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
				
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
		</div>
		<!-- // 검색 -->
		
		<!-- 상단 정보 -->
		<div class="table_header mb5">
			<div class="lft">
				<!-- <a class="btn secondary sm" onclick="javascript:fn_radio();"><span>10개</span></a> -->
				<!-- record_cnt -->
				<label for="record_10" class="form_chip md"><input type="radio" id="record_10" name="record_cnt" value="10"><span>10개</span></label>
				<label for="record_30" class="form_chip md"><input type="radio" id="record_30" name="record_cnt" value="30"><span>30개</span></label>
				<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt" value="50"><span>50개</span></label>
				<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt" value="100"><span>100개</span></label>
				<!-- // record_cnt -->
			</div>

			<div class="rgt">
				<a class="btn_icon ico_xls sm" href="javascript:void(0);" onclick="javascript:fn_excelDown()">
					<i class="ico"><img src="/common/admmgr/images/icon/ico_xlsx02.svg" alt="엑셀"></i>
					<!-- <em>엑셀 다운로드</em> -->
				</a>
			</div>
			
		</div>
		<!-- 상단 정보 -->
				
		<!-- 리스트 -->	
		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="7%"/>
					<col width="*"/>
					<col width="10%"/>
					<%-- <col width="10%"/>
					<col width="10%"/> --%>
					<col width="7%"/>
					<col width="10%"/>
				</colgroup>
				<thead>
					<tr>
						<th class="center pr30">번호</th>
						<th class="center"><span>로그</span></th>
						<th class="center"><span>접속 IP</span></th>
						<th class="center"><span>접속 환경</span></th>
						<th class="center"><span>접속 브라우저</span></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td class="center pl0"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
							<%-- <td><fmt:formatNumber value="${rList.RNUM}" groupingUsed="true"/></td> --%>
							<td class="left pl20">
								<span style="color:blue; font-weight:bold;"><c:out value="${rList.USER_NM}"/>(<c:out value="${rList.USER_ID}"/>)</span>님
								<span style="color:orange; font-weight:bold;">[ <c:out value="${rList.REG_DT}"/> ]</span>에
								<c:if test="${not empty rList.PAGE_NM}"><span style="color:#43ab47;"><c:out value="${rList.PAGE_NM}"/></span>&nbsp;메뉴에서</c:if>
								<c:choose>
									<c:when test="${rList.LOG_CD eq 'PROC'}">
										<span style="color:blue; font-weight:bold;"><c:out value="${rList.ACT}"/></span>
									</c:when>
									<c:when test="${rList.LOG_CD eq 'DEL'}">
										<span style="color:red; font-weight:bold;"><c:out value="${rList.ACT}"/></span>
									</c:when>
									<c:otherwise>
										<span style="color:#ac00d5; font-weight:bold;"><c:out value="${rList.ACT}"/></span>
									</c:otherwise>
								</c:choose>
								 을(를) 수행함
							</td>
							<td class="center"><c:out value="${rList.USER_IP}"/></td>
							<%--
							<td><a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.USER_ID}');"><c:out value="${rList.USER_ENG_NM}"/></a></td>
							--%>
							<%-- <td>
								<fmt:parseDate value="${rList.BIRTH}" var="BIRTH" pattern="yyyyMMdd"/>
								<fmt:formatDate value="${BIRTH}" pattern="yyyy.MM.dd"/>
							</td>
							<td>
								<c:choose>
									<c:when test="${rList.GENDER eq 'M'}">남</c:when>
									<c:otherwise>여</c:otherwise>
								</c:choose>
							</td> --%>
							<td class="center"><c:out value="${rList.USER_DV}"/></td>
							<td class="center"><c:out value="${rList.USER_BR}"/></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td colspan="5">등록된 게시글이 없습니다.</td></tr></c:if>
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