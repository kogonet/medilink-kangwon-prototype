<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
/**************************************************
 * @desc    : 컨텐츠 상세
 **************************************************/
%>
<head>

</head>
<body>
	<div class="errorWrap">
		<section class="error">
			<p class="img"><img src="<c:url value="/common/admmgr/images/sub_common/ico_empty01.svg"/>" alt="죄송합니다. 현재 서비스가 원활하지 않습니다..." /></p>
			<p class="title">404 Error</p>
			<p class="txt">죄송합니다. 현재 서비스가 원할하지 않습니다.</p>
			<div class="btnGroup">
				<%--
				<a href="javascript:void(0);" class="btn" onclick="history.back();">뒤로가기</a>
				--%>
				<c:set var="nowUri" value="${requestScope['javax.servlet.forward.servlet_path']}"/>
				<%-- <c:choose>
					<c:when test="${nowUri.indexOf('/front/') > -1}"><a href="<c:url value='/front/'/>" class="btn btnPost">홈으로 가기</a></c:when>
					<c:when test="${nowUri.indexOf('/official/') > -1}"><a href="<c:url value='/official/'/>" class="btn btnPost">홈으로 가기</a></c:when>
					<c:when test="${nowUri.indexOf('/admmgr/') > -1}"><a href="<c:url value='/admmgr/'/>" class="btn btnPost">홈으로 가기</a></c:when>
				</c:choose> --%>
			</div>
		</section>
	</div>
</body>