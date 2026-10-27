<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib prefix="page" uri="http://www.opensymphony.com/sitemesh/page"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="com.ctit.vo.UserAdminVO"%>
<%
/**************************************************
 * @desc    : 레이아웃-관리자
 **************************************************/
 %>
<%
	/*
	if( request.getAttribute("SCRIPT") != null ){
		out.println("<decorator:body/>");
		return;
	}
	*/
	//로그인 유무 확인
	UserAdminVO user = new UserAdminVO(request);
	if( user == null ){
		out.println("<script type='text/javascript'>");
		out.println("alert('로그인 후 이용가능합니다.\\n로그인 해 주세요');");
		out.println("parent.location.href='/member/login.do';");
		out.println("</script>");
	}
%>
<!doctype html>
<html lang="ko" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta charset="utf-8">
	<meta http-equiv="Content-Script-Type" content="text/javascript">
	<meta http-equiv="Content-Style-Type" content="text/css">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>대한민국 감염병 극복 지원 사업 CMS</title>
	<link rel="shortcut icon" href="<c:url value='/common/admmgr/images/ico/favicon.ico'/>"/>
	<link rel="icon" href="<c:url value='/common/admmgr/images/ico/favicon.ico'/>"/>
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/css/default.css'/>"/>
	<%-- <link type="text/css" rel="stylesheet" href="<c:url value='/common/css/jquery-ui.css'/>"> --%>
	<link type="text/css" rel="stylesheet" href="<c:url value='/common/admmgr/css/loading.css'/>"/>
	<%-- <link type="text/css" rel="stylesheet" href="<c:url value='/common/css/dtree.css'/>"/> --%>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/jquery.min.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/jquery-migrate.min.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/design.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/common.js'/>"></script>
	<%-- <script type="text/javascript" src="<c:url value='/common/js/input_chk.js'/>"></script> --%>
	<%-- <script type="text/javascript" src="<c:url value='/common/js/dtree.js'/>"></script> --%>
	<%-- <script type="text/javascript" src="./common/js/dtree.js"></script> --%>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/CommonUtil.c3r-custom.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/calendar.js'/>"></script>
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/Sortable/1.14.0/Sortable.min.js"></script>
	<script type="text/javascript" src="<c:url value='/common/admmgr/js/highcharts/highcharts.js'/>"></script>
	<decorator:head/>
</head>
<body>
	<div class="pop_body_wrap">
		<div class="pop_body">
			<div class="pop_wrapper">
				
					<decorator:body/>
				
			</div>
		</div>
	</div>
</body>
</html>