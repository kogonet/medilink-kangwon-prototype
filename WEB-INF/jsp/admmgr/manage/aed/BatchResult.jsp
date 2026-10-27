<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * @desc    : AED 배치 - 실행 결과
 **************************************************/
%>
<body>
<!-- sub_contents_wrap -->
<div class="sub_contents_wrap">
	<!--sub_contents_area-->
	<div class="sub_contents_area">

	<h4 class="sub_tit_h4">AED 배치 실행 결과</h4>

	<p class="mb15">국립중앙의료원 API 강원특별자치도분 <c:out value="${apiCnt}"/>건 수신 · 저장 성공 <c:out value="${insertCnt}"/>건 · 실패 <c:out value="${failCnt}"/>건</p>

	<c:if test="${apiCnt eq 0}">
		<p class="mb15">API 응답이 없습니다. 서비스키/네트워크 상태를 확인해 주세요.</p>
	</c:if>

	</div>
	<!-- //sub_contents_area -->
</div>
<!-- sub_contents_wrap -->
</body>
