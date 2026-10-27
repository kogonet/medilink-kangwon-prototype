<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
/**************************************************
 * @desc    : 지도용 JS 데이터 파일 내보내기 - 실행 결과
 **************************************************/
%>
<body>
<!-- sub_contents_wrap -->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

	<h4 class="sub_tit_h4">지도 데이터 내보내기 결과</h4>

	<p class="mb15">생성 경로: <c:out value="${exportDir}"/>/<c:out value="${exportAllFile}"/> 외 시군구별 파일 · 총 <c:out value="${totalCnt}"/>건</p>

	<h5 class="sub_tit_h5">데이터셋별 건수 (전체 파일 기준)</h5>
	<div class="n_table_sty01 n_list01">
		<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1">
			<colgroup>
				<col width="30%"/>
				<col width="30%"/>
				<col width="40%"/>
			</colgroup>
			<thead>
				<tr>
					<th class="center">구분(gubun)</th>
					<th class="center">데이터셋</th>
					<th class="center">건수</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${resultList}" var="row">
					<tr>
						<td class="center"><c:out value="${row.gubun}"/></td>
						<td class="center"><c:out value="${row.label}"/></td>
						<td class="center"><c:out value="${row.cnt}"/></td>
					</tr>
				</c:forEach>
				<c:if test="${fn:length(resultList) eq 0}"><tr><td class="center" colspan="3">결과가 없습니다.</td></tr></c:if>
			</tbody>
		</table>
	</div>

	<h5 class="sub_tit_h5 mt15">시군구별 파일 생성 결과</h5>
	<div class="n_table_sty01 n_list01">
		<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1">
			<colgroup>
				<col width="20%"/>
				<col width="50%"/>
				<col width="30%"/>
			</colgroup>
			<thead>
				<tr>
					<th class="center">시군구</th>
					<th class="center">파일명</th>
					<th class="center">건수</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${gugunResultList}" var="row">
					<tr>
						<td class="center"><c:out value="${row.gugun}"/></td>
						<td class="center"><c:out value="${row.fileName}"/></td>
						<td class="center"><c:out value="${row.cnt}"/></td>
					</tr>
				</c:forEach>
				<c:if test="${fn:length(gugunResultList) eq 0}"><tr><td class="center" colspan="3">결과가 없습니다.</td></tr></c:if>
			</tbody>
		</table>
	</div>

	</div>
	<!-- //sub_contents_area -->
</div>
<!-- sub_contents_wrap -->
</body>
