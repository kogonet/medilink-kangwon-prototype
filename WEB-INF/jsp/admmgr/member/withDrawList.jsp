<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 탈퇴회원 
 **************************************************/
%>
<head>
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
			$("#frm").attr("action","<c:url value='/admmgr/member/withDrawList.do'/>");
			$("#frm").submit();
		}
		
		//상세
		function fn_Detail(userId){
			
			$.ajax({
				type : 'get',
				url : '/admmgr/member/withdrawView.do',
				data : {userId : userId},
				dataType : 'json',
				success : function(data) {
					if(data) {
						
						var withdrawTp;
						
						if(data.WITHDRAW_TP === "Basic") {
							withdrawTp = "일반회원";
						} else {
							withdrawTp = "평가위원";
						}
						
						$("#userId").text(data.USER_ID);
						$("#hpNo").text(data.HP_NO);
						$("#withdrawTp").text(withdrawTp);
						$("#joinDt").text(data.JOIN_DTM);
						$("#withdrawDt").text(data.WITHDRAW_DTM);
						$("#withdrawDesc").text(data.WITHDRAW_DESC);
						
					}else {
						alert("실패");
					}
				},
				error : function(request,status,error){
					alert("처리 중 오류가 발생되었습니다.error:"+error+"request:"+request+"status:"+status);
				}
			});
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
				$("#frm").attr("action","<c:url value='/admmgr/member/withDrawDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		
		// 엑셀 다운로드
		function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/withDrawListDown.do'/>");
			$("#frm").submit();
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
	                $("#frm").attr("action", "<c:url value='/admmgr/member/withDrawList.do'/>");
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
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="siteCd" name="siteCd" value="001000000000000"/>
	<input type="hidden" id="userTp" name="userTp" value="${userTp}"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${ record_cnt }"/>

<!-- listview_grid_wrap : 전체 레이아웃을 flex로 -->
<div class="listview_grid_wrap">	
	<!-- list_grid_wrap -->
	<div class="list_grid_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
		
		
			<!-- 검색 -->
			<div class="search_form_wrap mb15">
				<div class="search_form_inner">
					<div class="filter_form">
						<div>
							<label>검색조건</label>
							<select id="searchfield" name="searchfield" class="form_select md" title="검색조건 선택">
								<option value="ALL">전체</option>
								<option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option>
								<%-- <option value="USER_NM" ${ param.searchfield eq 'USER_NM' ? "selected='selected'" : "" }>성명</option>
								<option value="EMAIL" ${ param.searchfield eq 'EMAIL' ? "selected='selected'" : "" }>이메일</option> --%>
							</select>
							<input type="text" id="searchword" name="searchword" class="form_text md wd200" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
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
		
		<!-- 상단 정보 -->
			<div class="table_header mb5">
				<div class="lft">
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
					<col width="3%"/>
					<col width=""/>
					<col width=""/>
					<col width=""/>
					<col width=""/>
					<col width=""/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th class="center"><span>번호</span></th>
						<th class="center"><span>아이디</span></th>
						<th class="center"><span>회원유형</span></th>
						<th class="center"><span>가입일시</span></th>
						<th class="center"><span>탈퇴일시</span></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${str:getReverseXSS(rList.USER_ID)}"/>"/></td>
							<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
							<td class="center"><a href="javascript:void(0);" onclick="javascript:fn_Detail('<c:out value="${rList.USER_ID}"/>');"><c:out value="${str:getReverseXSS(rList.USER_ID)}"/></a></td>
							<td class="center">
								<c:choose>
									<c:when test="${rList.WITHDRAW_TP eq 'Basic'}">
										일반회원
									</c:when>
									<c:otherwise>
										평가위원
									</c:otherwise>
								</c:choose>
							</td>
							<td class="center"><c:out value="${rList.JOIN_DTM}"/></td>
							<td class="center"><c:out value="${rList.WITHDRAW_DTM}"/></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="5">등록된 탈퇴회원이 없습니다.</td></tr></c:if>
				</tbody>
			</table>
		</div>
		<!-- 리스트 -->
		
		<!-- table_footer -->	
		<div class="table_footer">
			<div class="btn_wrap lft">
				<a class="btn_n_del" href="javascript:void(0);" onclick="javascript:fn_Delete();"><span>삭제</span></a>
			</div>
			<div class="pagination_wrap">
				<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
			</div>
		</div>
		<!-- // table_footer -->
			
			
				
		</div>
		<!-- sub_contents_area-->
		
	</div>
	<!-- // list_grid_wrap -->

	<!-- view_grid_wrap : 우측 상세정보 영역 -->
	<div id="detail_info" class="view_grid_wrap">
		<!-- table_header -->
		<div class="box_tit">
			<h6 class="title">탈퇴회원 정보 상세</h6>
		</div>
		<!-- // table_header -->
		
		<div class="table_wrap n_table_sty01 n_view01">
			<table cellspacing="0" cellpadding="0" border="0" summary="게시판 뷰" class="tbl_ty2">
				<colgroup>
					<col width="15%"/>
					<col width="35%"/>
					<col width="15%"/>
					<col width="35%"/>
				</colgroup>
				<tbody>
					<tr>
						<th>아이디</th>
						<td id="userId"></td>
						<th>핸드폰번호</th>
						<td id="hpNo"></td>
					</tr>
					<%-- <tr>
						<th>이름(국문)</th>
						<td><c:out value="${str:getReverseXSS(rMap.USER_NM)}"/></td>
					</tr> --%>
					<%-- <tr>
						<th>이메일</th>
						<td colspan="3"><c:out value="${str:getReverseXSS(rMap.EMAIL)}"/></td>
					</tr> --%>
					<tr>
						<th>회원유형</th>
						<td colspan="3" id="withdrawTp"></td>
					</tr>
					<tr>
						<th>가입일자</th>
						<td id="joinDt"></td>
						<th>탈퇴일자</th>
						<td id="withdrawDt"></td>
					</tr>
					<tr>
						<th>탈퇴 사유</th>
						<td colspan="3" id="withdrawDesc"></td>
					</tr>
				</tbody>
			</table>
		</div>
		
		<div class="page_btn_wrap jc_between">
			<div class="rgt">
				<!-- <a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>수정</span></a> -->
			</div>
		</div>
	</div>
	<!-- // view_grid_wrap : 우측 상세정보 영역 -->	

</div>	
<!-- // listview_grid_wrap : 전체 레이아웃을 flex로-->

</form>
</body>