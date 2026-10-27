<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : IP허용관리  목록
 **************************************************/
%>
<head>
	<script type="text/javascript">
		$(document).ready(function(){
			
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
	                $("#frm").attr("action", "<c:url value='/admmgr/manage/ipLookerList.do'/>");
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
			$("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerList.do'/>");
			$("#frm").submit();
		}
		//상세
		function fn_Detail(seq){
			$("#seq").val(seq);
			$("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerView.do'/>");
			$("#frm").submit();
		}
		//등록
		function fn_Regist(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerRegist.do'/>");
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
				$("#frm").attr("action","<c:url value='/admmgr/manage/ipLookerDeleteProc.do'/>");
				$("#frm").submit();
			}
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="GET">
	<input type="hidden" id="seq" name="seq"/>
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
							<option value="START_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이피</option>
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
				<!-- record_cnt -->
				<label for="record_10" class="form_chip md"><input type="radio" id="record_10" name="record_cnt" value="10"><span>10개</span></label>
				<label for="record_30" class="form_chip md"><input type="radio" id="record_30" name="record_cnt" value="30"><span>30개</span></label>
				<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt" value="50"><span>50개</span></label>
				<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt" value="100"><span>100개</span></label>
				<!-- // record_cnt -->
			</div>
		</div>
		<!-- 상단 정보 -->
		
		<!-- 리스트 -->
		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="3%"/>
					<col width="5%"/>
					<col width="*"/>
					<col width="*"/>
					<col width="8%"/>
					<col width="15%"/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th class="center"><span>번호</span></th>
						<th class="center"><span>시작 IP</span></th>
						<th class="center"><span>종료 IP</span></th>
						<th class="center"><span>승인여부</span></th>
						<th class="center"><span>등록일</span></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${rList.SEQ}"/>"/></td>
							<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
							<td class="center">										
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.SEQ}');"><c:out value="${rList.START_IP}"/></a>
							</td>
							<td class="center">										
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.SEQ}');"><c:out value="${rList.END_IP}"/></a>
							</td>
							<td class="center">										
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.SEQ}');">
									<c:choose>
										<c:when test="${rList.APP_YN eq 'Y'}">
											<span class="av_link av_green center">승인</span>
										</c:when>
										<c:otherwise>
											<span class="av_link av_red center">미승인</span>
										</c:otherwise>
									</c:choose>
								</a>
							</td>
							<td class="center">										
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.SEQ}');"><c:out value="${rList.REG_DTM}"/></a>
							</td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td colspan="6">등록된 게시글이 없습니다.</td></tr></c:if>
				</tbody>
			</table>
		</div>
		<!-- 리스트 -->
			
		<!-- table_footer -->
		<div class="table_footer">
		
			<div class="pagination_wrap">
				<div id="pageList"><c:out value="${PAGING_HTML}" escapeXml="false"/></div>
			</div>
			<!-- <p class="btn_section fix">
				<span class="lft_btn_section"><a class="btn1_ty1" href="javascript:void(0);" onclick="javascript:fn_Delete();"><em>삭제</em></a></span>
				<span class="rit_btn_section"><a class="btn1_ty4" href="javascript:void(0);" onclick="javascript:fn_Regist();"><em>등록</em></a></span>
			</p> -->
		</div>
		<!-- table_footer -->
		
		</div>
		<!--sub_contents_area-->
		
	</div>
	<!-- // sub_contents_wrap -->
	
</form>
</body>