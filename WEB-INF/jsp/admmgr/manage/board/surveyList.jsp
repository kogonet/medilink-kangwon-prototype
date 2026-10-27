<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 설문조사  목록
 **************************************************/
%>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
	<script type="text/javascript">
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").prop("checked",true);
			}else{
				$("input[name=chk]").prop("checked",false);
			}
		}
		//검색
		function fn_Search(){
			if( !fn_ValidateSearchDate("s_date_start","s_date_end") ){
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyList.do'/>")
			$("#frm").submit();
		}
		//상세보기
		function fn_Detail(basic_seq){
			$("#basic_seq").val( basic_seq );
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyView.do'/>")
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyRegist.do'/>");
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
				$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		// 엑셀 다운로드
		function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/surveyDown.do'/>");
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
	                $("#frm").attr("action", "<c:url value='/admmgr/manage/board/surveyList.do'/>");
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
	<input type="hidden" id="basic_seq" name="basic_seq"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${ record_cnt }"/>
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
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
									<option value="TITLE" ${ param.searchfield eq 'TITLE' ? "selected='selected'" : "" }>제목</option>
									<option value="CONTENTS" ${ param.searchfield eq 'CONTENTS' ? "selected='selected'" : "" }>내용</option>
						</select>
						<input type="text" id="searchword" name="searchword" class="form_text md wd300" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/>
					</div>
					
					<div>
						<label>분류</label>
						<select id="gubun" name="gubun" class="form_select md" title="분류 선택">
							<option value="">분류</option>
							<c:forEach items="${categoryList}" var="categoryList" varStatus="status">
								<option value="${categoryList.CODE}" ${ categoryList.CODE eq param.gubun ? "selected='selected'" : "" } >${categoryList.CODE_NM}</option>
							</c:forEach>
						</select>
					</div>

					<div>
						<label>설문기간</label>
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
					
					<div>
						<label>진행상태</label>
						<select id="progress" name="progress" class="form_select md" title="진행상태">
							<option value="">진행상태</option>
									<option value="BEFORE" ${ param.progress eq 'BEFORE' ? "selected='selected'" : "" }>진행예정</option> 
									<option value="NOW" ${ param.progress eq 'NOW' ? "selected='selected'" : "" }>진행중</option>
									<option value="AFTER" ${ param.progress eq 'AFTER' ? "selected='selected'" : "" }>설문완료</option>
						</select>
					</div>
					
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
		</div>
		<!-- // 검색 -->

		<!-- 상단 정보 -->
		<div class="table_header flx jc_between mb5">
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
					<col width="3%"/>
					<col width="8%"/>
					<col width="12%"/>
					<col width="20%"/>
					<col width="10%"/>
					<col width="10%"/>
					<col width="7%"/>
					<col width="7%"/>
					<col width="7%"/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th class="center"><span>번호</span></th>
						<th class="center"><span>분류</span></th>
						<th class="center"><span>제목</span></th>
						<th class="center"><span>기간</span></th>
						<th class="center"><span>진행상태</span></th>
						<th class="center"><span>사용여부</span></th>
						<th class="center"><span>참여자수</span></th>
						<th class="center"><span>결과보기</span></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${rList.BASIC_SEQ}"/>"/></td>
							<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
							<td class="center"><c:out value="${rList.GUBUN_NM}"/></td>
							<td class="center"><a href="javascript:void(0);" onclick="javascript:fn_Detail('<c:out value="${rList.BASIC_SEQ}"/>');"><c:out value="${rList.TITLE}"/></a></td>
							<td class="center"><c:out value="${rList.STR_DD}"/> ~ <c:out value="${rList.END_DD}"/></td>
							<td class="center">
								<%-- <c:out value="${rList.STATE_TXT}"/> --%>
								<c:choose>
									<c:when test="${rList.STATE_TXT eq '진행중'}">
										<span class="av_link av_blue center">진행중</span>
									</c:when>
								</c:choose>
							</td>
							<td class="center">${rList.OPEN_YN eq 'Y' ? '예' : '아니오' }</td>
							<td class="center"><c:out value="${rList.CNT}"/></td>
							<td class="center">
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('<c:out value="${rList.BASIC_SEQ}"/>');">
								[선택]
								</a>
							</td>
						</tr>							
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="9">등록된 게시글이 없습니다.</td></tr></c:if>
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

			<div class="btn_wrap rgt">
				<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
			</div>
		</div>
		<!-- // table_footer -->

		

		</div>
		<!--sub_contents_area-->

	</div>
	<!-- // sub_contents_wrap -->

</form>
</body>