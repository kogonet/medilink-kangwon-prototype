<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 응급 의료기관 정보 관리 - 목록
 **************************************************/
%>
<head>
	<script type="text/javascript">
		function fn_CheckAll(obj){
			if( $(obj).is(":checked") ){
				$("input[name=chk]").attr("checked",true);
			}else{
				$("input[name=chk]").attr("checked",false);
			}
		}
		function fn_Search(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/List.do'/>");
			$("#frm").submit();
		}
		function fn_Detail(rnum){
			$("#rnum").val(rnum);
			$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/View.do'/>");
			$("#frm").submit();
		}
		function fn_Regist(){
			$("#rnum").val("");
			$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/Regist.do'/>");
			$("#frm").submit();
		}
		//지도 데이터 내보내기(medical_map_data.js 갱신)
		function fn_MapExport(){
			if( confirm("지도 데이터를 다시 내보내시겠습니까?\n(등록/수정/삭제 내용이 지도에 반영됩니다)") ){
				location.href = "<c:url value='/admmgr/manage/mapdata/ExportProc.do'/>";
			}
		}
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
				$("#frm").attr("action","<c:url value='/admmgr/manage/emergency/DeleteProc.do'/>");
				$("#frm").submit();
			}
		}
		$(document).ready(function() {
			var record_cnt = $('#record_cnt').val();
			$('#record_' + record_cnt).attr('checked','checked');

			$("input[name='record_cnt']").change(function() {
	            var chkRadio = $("input[name='record_cnt']:checked");
	            if (chkRadio.length > 0) {
	            	$("#record_cnt").val($(this).val());
	                $("#frm").attr("action", "<c:url value='/admmgr/manage/emergency/List.do'/>");
	                $("#frm").submit();
	            }
	        });

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
	<input type="hidden" id="rnum" name="rnum"/>
	<input type="hidden" id="record_cnt" name="record_cnt" value="${record_cnt}"/>

	<div class="sub_contents_wrap">
		<div class="sub_contents_area">

		<h4 class="sub_tit_h4"></h4>

		<div class="search_form_wrap mb15">
			<div class="search_form_inner">
				<div class="filter_form">
					<div>
						<label>검색조건</label>
						<input type="text" id="searchword" name="searchword" class="form_text md wd300" value="<c:out value="${param.searchword}"/>" placeholder="기관명을 입력해 주세요"/>
					</div>
					<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
				</div>
			</div>
		</div>

		<div class="table_header flx jc_between mb5">
			<div class="lft">
				<label for="record_10" class="form_chip md"><input type="radio" id="record_10" name="record_cnt" value="10"><span>10개</span></label>
				<label for="record_30" class="form_chip md"><input type="radio" id="record_30" name="record_cnt" value="30"><span>30개</span></label>
				<label for="record_50" class="form_chip md"><input type="radio" id="record_50" name="record_cnt" value="50"><span>50개</span></label>
				<label for="record_100" class="form_chip md"><input type="radio" id="record_100" name="record_cnt" value="100"><span>100개</span></label>
			</div>
		</div>

		<div class="n_table_sty01 n_list01">
			<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" id="normal">
				<colgroup>
					<col width="3%"/>
					<col width="6%"/>
					<col width="24%"/>
					<col width="13%"/>
					<col width="*"/>
					<col width="13%"/>
					<col width="12%"/>
				</colgroup>
				<thead>
					<tr>
						<th><input type="checkbox" onclick="javascript:fn_CheckAll(this);"></th>
						<th class="center">번호</th>
						<th class="center">기관명</th>
						<th class="center">분류</th>
						<th class="center">주소</th>
						<th class="center">응급실전화</th>
						<th class="center">운영시간</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rList}" var="rList" varStatus="status">
						<tr>
							<td><input type="checkbox" name="chk" value="<c:out value="${rList.rnum}"/>"/></td>
							<td class="center"><fmt:formatNumber value="${PAGING_NUM-status.index}" groupingUsed="true"/></td>
							<td style="text-align:left;">
								<a href="javascript:void(0);" onclick="javascript:fn_Detail('${rList.rnum}');">
									<c:out value="${rList.dutyName}"/>
								</a>
							</td>
							<td class="center"><c:out value="${rList.dutyEmclsName}"/></td>
							<td style="text-align:left;"><c:out value="${rList.dutyAddr}"/></td>
							<td class="center"><c:out value="${rList.dutyTel3}"/></td>
							<td class="center"><c:out value="${rList.openTime}"/> ~ <c:out value="${rList.closeTime}"/></td>
						</tr>
					</c:forEach>
					<c:if test="${fn:length(rList) eq 0}"><tr><td class="center" colspan="7">등록된 정보가 없습니다.</td></tr></c:if>
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
				<a class="btn_n_modi" href="javascript:void(0);" onclick="javascript:fn_MapExport();"><span>지도 데이터 내보내기</span></a>
				<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>등록</span></a>
			</div>
		</div>

		</div>
	</div>
</form>
</body>
