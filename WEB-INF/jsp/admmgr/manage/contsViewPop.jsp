<!-- default -->
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="com.ctit.helper.IDao"%>
<%@ page import="com.ctit.helper.Cvt"%>
<%@ page import="com.ctit.helper.CDao"%>
<%@ page import="com.ctit.vo.MenuCodeVO"%>

<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.apache.commons.lang.ArrayUtils"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib prefix="page" uri="http://www.opensymphony.com/sitemesh/page"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 컨텐츠 미리보기
 **************************************************/
%>
<!doctype html>
<html lang="ko" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8">
    <!-- <meta name="naver-site-verification" content="849c04934bea773f229f28c0e13b1c2352c041ae"/> -->
    <meta http-equiv="Content-Script-Type" content="text/javascript">
    <meta http-equiv="Content-Style-Type" content="text/css">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="센텀인터넷CMS">
	<meta name="keywords" content="센텀인터넷CMS">
    <title>센텀인터넷CMS</title>
    <link rel="shortcut icon" href="/common/front/kor/images/favicon.ico" type="image/X-icon">
    <link rel="icon" href="/common/front/kor/images/favicon.png" type="image/X-icon">
    <link rel="stylesheet" href="/common/front/kor/css/swiper-bundle.min.css">
    <link rel="stylesheet" href="/common/front/kor/css/default.css">
    <script type="text/javascript" src="/common/front/kor/js/jquery-1.11.2.min.js"></script>
    <script type="text/javascript" src="/common/front/kor/js/swiper-bundle.min.js"></script>
    <script type="text/javascript" src="/common/front/kor/js/design.js"></script>
    <script type="text/javascript" src="/common/admmgr/js/common.js"></script>
    <script type="text/javascript" src="<c:url value="/common/admmgr/js/file/CtitFile-custom.js"/>"></script>
</head>
<body>

	<!--body_wrapper-->
	<div class="body_wrapper">
		<!--common_wrapper-->
		<div class="common_wrapper">

			<!--sub_container_wrapper-->
			<div class="sub_container_wrapper">

				<div class="sub_contents_section">

		            <!-- 미리보기 : article -->
		            <c:set var="convUrl1" value="${url1}"/>
					<c:set var="convUrl2" value="${url2}"/>
					<c:if test="${not empty convUrl1}">
					<c:set var="convUrl1"><a href="${convUrl1}" target="_blank">${convUrl1}</a></c:set>
					</c:if>
					<c:if test="${not empty convUrl2}">
					<c:set var="convUrl2"><a href="${convUrl2}" target="_blank">${convUrl2}</a></c:set>
					</c:if>
					<c:set var="convConts" value="${conts}"/>
					<c:set var="convConts" value="${fn:replace(convConts,'{URL1}',convUrl1)}"/>
					<c:set var="convConts" value="${fn:replace(convConts,'{URL2}',convUrl2)}"/>
					${convConts}
		            <!--// 미리보기 : article -->

				</div>
			</div>
			<!--/sub_container_wrapper-->


		</div>
		<!--/common_wrapper-->
	</div>
	<!--/body_wrapper-->
</body>
</html>