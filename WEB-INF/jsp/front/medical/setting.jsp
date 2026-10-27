<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * aed.jsp
 * @desc    : AED 위치 - hospitalList.jsp와 동일한 지도보기(등급 없음, 단일 마커색)/목록보기 토글 패턴.
 *            tb_ai_aed는 admMapDataExport 배치가 gubun="aed"로 medical_map_data.js에 함께 내보내고,
 *            지도/목록 렌더링은 공용 MedicalAIMap 모듈이 그대로 처리한다(08-19, 리스트 전용에서 전환).
 *            08-19 이전 리스트 전용 버전은 aed.jsp_bak20260819(지도없음) 참고.
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>AED 위치 - 메디링크 강원</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@8.2.0/ol.css">
<link rel="stylesheet" href="/common/front/kor/css/style.css">
</head>
<body>
<div class="wrap">
	강원 TP SETTING
</div>
</body>
</html>
