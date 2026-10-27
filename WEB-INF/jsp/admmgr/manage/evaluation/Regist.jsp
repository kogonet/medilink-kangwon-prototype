<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 의료기관 평가 정보 관리 - 등록/수정
 **************************************************/
%>
<head>
	<script type="text/javascript">
		function fn_Regist(){
			if( $("#orgnm").val().trim() == "" ){
				alert("기관명을 입력해주세요.");
				$("#orgnm").focus();
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/evaluation/RegistProc.do'/>").submit();
		}
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/evaluation/List.do'/>").submit();
		}
		//주소로 좌표 재검색
		function fn_GeocodeLookup(){
			var addr = $("#orgAddr").val().trim();
			if( addr == "" ){
				alert("주소를 먼저 입력해주세요.");
				return false;
			}
			$.ajax({
				type: "POST",
				url: "<c:url value='/admmgr/manage/geocode/LookupProc.do'/>",
				data: { addr: addr },
				dataType: "json",
				success: function(data){
					if( data.result == "success" ){
						$("#wgs84Lat").val(data.lat);
						$("#wgs84Lon").val(data.lon);
						alert("좌표를 찾았습니다. 필요 시 값을 직접 수정한 뒤 저장하세요.");
					} else {
						alert("좌표를 찾지 못했습니다. 직접 입력해주세요.");
					}
				},
				error: function(){
					alert("좌표 조회 중 오류가 발생했습니다.");
				}
			});
		}
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="rnum" name="rnum" value="<c:out value="${rMap.rnum}"/>"/>
	<div class="sub_contents_wrap">
		<div class="sub_contents_area">

			<h4 class="sub_tit_h4"></h4>

			<div class="table_header">
				<h4 class="sub_tit_h4 fix"><em>의료기관 평가 정보 ${(not empty rMap.rnum)?'수정':'등록'}</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span></h4>
			</div>

			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="의료기관 평가 정보 등록" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>기관명 <em class="point">&nbsp;</em></th>
							<td>
								<input type="text" id="orgnm" name="orgnm" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.orgnm}"/>"/>
							</td>
							<th>기관구분</th>
							<td>
								<input type="text" id="orgcd" name="orgcd" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.orgcd}"/>"/>
							</td>
						</tr>
						<tr>
							<th>인증여부</th>
							<td>
								<input type="text" id="certified" name="certified" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.certified}"/>"/>
							</td>
							<th>인증번호</th>
							<td>
								<input type="text" id="orgnum" name="orgnum" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.orgnum}"/>"/>
							</td>
						</tr>
						<tr>
							<th>소재지</th>
							<td colspan="3">
								<input type="text" id="orgAddr" name="orgAddr" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.orgAddr}"/>"/>
							</td>
						</tr>
						<tr>
							<th>유효기간</th>
							<td>
								<input type="text" id="expnYmd" name="expnYmd" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.expnYmd}"/>"/>
							</td>
							<th>중간현장조사</th>
							<td>
								<input type="text" id="sceneSurvey" name="sceneSurvey" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.sceneSurvey}"/>"/>
							</td>
						</tr>
						<tr>
							<th>운영시간</th>
							<td colspan="3">
								<input type="time" id="openTime" name="openTime" class="form_text" style="width:140px;" value="<c:out value="${empty rMap ? '09:00' : rMap.openTime}"/>"/>
								~
								<input type="time" id="closeTime" name="closeTime" class="form_text" style="width:140px;" value="<c:out value="${empty rMap ? '18:00' : rMap.closeTime}"/>"/>
							</td>
						</tr>
						<tr>
							<th>좌표(위도/경도)</th>
							<td colspan="3">
								위도 <input type="text" id="wgs84Lat" name="wgs84Lat" class="form_text" style="width:150px;" value="<c:out value="${rMap.wgs84Lat}"/>" placeholder="자동 지오코딩"/>
								&nbsp;경도 <input type="text" id="wgs84Lon" name="wgs84Lon" class="form_text" style="width:150px;" value="<c:out value="${rMap.wgs84Lon}"/>" placeholder="자동 지오코딩"/>
								<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_GeocodeLookup();"><span>주소로 좌표 재검색</span></a>
								<p style="margin-top:5px;font-size:12px;color:#888;">비워두면 저장 시 주소 기반으로 자동 지오코딩됩니다. 값을 입력하면 그 값이 그대로 저장되며, 이후 저장 시에도 자동으로 재계산되지 않습니다.</p>
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>

		</div>
	</div>
</form>
</body>
