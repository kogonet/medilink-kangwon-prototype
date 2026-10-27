<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 게시판 목록
 **************************************************/
%>
<head>
	<script src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/frameLayer.js'/>"></script>
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
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/List${boardMngNo}.do'/>");
			$("#frm").submit();
		}
		//상세
		function fn_Detail(boardMngNo,boardNo){
			$("#boardMngNo").val(boardMngNo);
			$("#boardNo").val(boardNo);
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/View${boardMngNo}.do'/>");
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/Regist${boardMngNo}.do'/>");
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
				$("#frm").attr("action","<c:url value='/admmgr/manage/board/Delete${boardMngNo}Proc.do'/>");
				$("#frm").submit();
			}
		}
		// 엑셀 다운로드
		/* function fn_excelDown(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/board/basicDown.do'/>");
			$("#frm").submit();
		}  */
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
	                $("#frm").attr("action", "<c:url value='/admmgr/manage/board/List${boardMngNo}.do'/>"); 
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
	<input type="hidden" id="boardMngNo" name="boardMngNo" value="${boardMngNo}"/> 
	<input type="hidden" id="boardNo" name="boardNo"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${record_cnt}"/>
	
	<!-- sub_contents_wrap -->
	<div class="sub_contents_wrap">
		<!--sub_contents_area-->
		<div class="sub_contents_area">
		
		<!-- 타이틀 -->
		<h4 class="sub_tit_h4">
		</h4>
		<!-- 타이틀 -->
		
		<!-- 검색 -->
		<div class="search_form_wrap mb15">
			<div class="search_form_inner">
				<div class="filter_form">
					<div>
						<label>검색조건</label>
						<select id="searchfield" name="searchfield" class="form_select md" title="검색조건 선택">
							<option value="ALL">전체</option>
							<option value="TITLE" ${ param.searchfield eq 'TITLE' ? "selected='selected'" : "" }>제목</option>
							<option value="CONTS" ${ param.searchfield eq 'CONTS' ? "selected='selected'" : "" }>내용</option>
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

			<!-- <div class="rgt">
				<a class="btn_icon ico_xls sm" href="javascript:void(0);" onclick="javascript:fn_excelDown()">
					<i class="ico"><img src="/common/admmgr/images/icon/ico_xlsx02.svg" alt="엑셀"></i>
					<em>엑셀 다운로드</em>
				</a>
			</div> -->
		</div>
		<!-- 상단 정보 -->
		
		<!-- 리스트 -->
		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="3%"/>
					<col width="10%"/>
					<col width="*"/>
					<col width="8%"/>
					<col width="10%"/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th class="center">번호</th>
						<th class="center">제목</th>
						<th class="center">작성자</th>
						<th class="center">등록일시</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${rList.BOARD_MNG_NO}"/>:<c:out value="${rList.BOARD_NO}"/>"/></td>
							<td class="center"><fmt:formatNumber value="${START_REC+status.index}" groupingUsed="true"/></td>
							<td class="center" style="text-align:left;">
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.BOARD_MNG_NO}','${rList.BOARD_NO}');">
									<c:out value="${str:getReverseXSS(rList.TITLE)}"/>
								</a>
							</td>
							<td class="center"><c:out value="${rList.REG_NM}"/></td>
							<td class="center"><c:out value="${rList.REG_DTM}"/></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="5">등록된 게시글이 없습니다.</td></tr></c:if>
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
		<!-- //sub_contents_area -->
	</div>
	<!-- sub_contents_wrap -->
</form>
</body>