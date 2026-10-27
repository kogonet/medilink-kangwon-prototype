<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
/**************************************************
 * @desc    : 좌표 미등록 데이터 지오코딩 배치 - 실행 결과
 **************************************************/
%>
<body>
<!-- sub_contents_wrap -->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

	<h4 class="sub_tit_h4">지오코딩 배치 실행 결과</h4>

	<!-- 요약 -->
	<div class="n_table_sty01 n_list01 mb15">
		<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1">
			<colgroup>
				<col width="25%"/>
				<col width="25%"/>
				<col width="25%"/>
				<col width="25%"/>
			</colgroup>
			<thead>
				<tr>
					<th class="center">구분</th>
					<th class="center">대상</th>
					<th class="center">성공</th>
					<th class="center">실패</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="center">예방접종 위탁의료기관</td>
					<td class="center"><c:out value="${vaccinationTotal}"/></td>
					<td class="center"><c:out value="${vaccinationSuccess}"/></td>
					<td class="center"><c:out value="${vaccinationFail}"/></td>
				</tr>
				<tr>
					<td class="center">의료기관 평가</td>
					<td class="center"><c:out value="${evaluationTotal}"/></td>
					<td class="center"><c:out value="${evaluationSuccess}"/></td>
					<td class="center"><c:out value="${evaluationFail}"/></td>
				</tr>
			</tbody>
		</table>
	</div>
	<!-- // 요약 -->

	<!-- 상세 리스트 -->
	<div class="n_table_sty01 n_list01">
		<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1">
			<colgroup>
				<col width="15%"/>
				<col width="7%"/>
				<col width="20%"/>
				<col width="*"/>
				<col width="8%"/>
				<col width="12%"/>
				<col width="12%"/>
			</colgroup>
			<thead>
				<tr>
					<th class="center">구분</th>
					<th class="center">번호</th>
					<th class="center">기관명</th>
					<th class="center">주소</th>
					<th class="center">결과</th>
					<th class="center">위도</th>
					<th class="center">경도</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${resultList}" var="row">
					<tr>
						<td class="center"><c:out value="${row.category}"/></td>
						<td class="center"><c:out value="${row.rnum}"/></td>
						<td style="text-align:left;"><c:out value="${row.name}"/></td>
						<td style="text-align:left;"><c:out value="${row.addr}"/></td>
						<td class="center"><c:out value="${row.status}"/></td>
						<td class="center"><c:out value="${row.wgs84Lat}"/></td>
						<td class="center"><c:out value="${row.wgs84Lon}"/></td>
					</tr>
				</c:forEach>
				<c:if test="${fn:length(resultList) eq 0}"><tr><td class="center" colspan="7">좌표 미등록 대상이 없습니다.</td></tr></c:if>
			</tbody>
		</table>
	</div>
	<!-- // 상세 리스트 -->

	</div>
	<!-- //sub_contents_area -->
</div>
<!-- sub_contents_wrap -->
</body>
