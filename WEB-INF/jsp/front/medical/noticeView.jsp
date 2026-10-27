<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * noticeView.jsp
 * @desc    : 메디링크 강원 공지사항 - 상세 (frontMedicalBoard.NoticeView)
 *            첨부파일은 공통 다운로드(/commonFile/fileDownload.do)로 POST
 **************************************************/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><c:out value="${str:getReverseXSS(rMap.TITLE)}"/> | 공지사항 | 메디링크 강원</title>
<link rel="stylesheet" href="/common/front/kor/css/landing.css">
<link rel="stylesheet" href="/common/front/kor/css/medical_board.css">
</head>
<body>
<main class="mb_main">
	<div class="mb_inner">

		<header class="mb_head">
			<p class="section_label">Notice</p>
			<p class="mb_title">공지사항</p>
		</header>

		<article>
			<header class="mb_view_head">
				<h1 class="mb_view_title">
					<c:if test="${rMap.TOP_ORDER eq '50'}"><em class="mb_fix_badge">고정</em></c:if>
					<c:out value="${str:getReverseXSS(rMap.TITLE)}"/>
				</h1>
				<div class="mb_view_meta">
					<span><strong>등록일</strong><time datetime="${fn:replace(rMap.REG_DATE, '.', '-')}"><c:out value="${rMap.REG_DATE}"/></time></span>
					<span><strong>조회</strong><fmt:formatNumber value="${rMap.READ_CNT}" groupingUsed="true"/></span>
				</div>
			</header>

			<c:set var="fileList1" value="${str:makeFileList(rMap.FILE_NO_1)}"/>
			<c:if test="${fn:length(fileList1) > 0}">
				<div class="mb_files">
					<p class="mb_files_label">첨부파일</p>
					<ul>
						<c:forEach items="${fileList1}" var="file">
							<li>
								<form method="POST" action="/commonFile/fileDownload.do">
									<input type="hidden" name="fileNo" value="<c:out value="${file.FILE_NO}"/>"/>
									<input type="hidden" name="fileSeq" value="<c:out value="${file.FILE_SEQ}"/>"/>
									<button type="submit" class="mb_file_btn">
										<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
										<span><c:out value="${file.ORIGIN_NM}"/></span>
									</button>
								</form>
							</li>
						</c:forEach>
					</ul>
				</div>
			</c:if>

			<div class="mb_view_body">
				<c:out value="${rMap.CONTS}" escapeXml="false"/>
			</div>
		</article>

		<nav class="mb_move" aria-label="이전글 다음글">
			<c:choose>
				<c:when test="${empty PREV_BOARD_INFO or PREV_BOARD_INFO.BOARD_NO eq 0}">
					<span class="mb_move_link"><em>이전글</em><b>이전 게시글이 없습니다.</b></span>
				</c:when>
				<c:otherwise>
					<a href="/front/medical/noticeView.do?boardNo=${PREV_BOARD_INFO.BOARD_NO}"><em>이전글</em><b><c:out value="${str:getReverseXSS(PREV_BOARD_INFO.TITLE)}"/></b></a>
				</c:otherwise>
			</c:choose>
			<c:choose>
				<c:when test="${empty NEXT_BOARD_INFO or NEXT_BOARD_INFO.BOARD_NO eq 0}">
					<span class="mb_move_link"><em>다음글</em><b>다음 게시글이 없습니다.</b></span>
				</c:when>
				<c:otherwise>
					<a href="/front/medical/noticeView.do?boardNo=${NEXT_BOARD_INFO.BOARD_NO}"><em>다음글</em><b><c:out value="${str:getReverseXSS(NEXT_BOARD_INFO.TITLE)}"/></b></a>
				</c:otherwise>
			</c:choose>
		</nav>

		<div class="mb_btns">
			<a class="mb_btn" href="/front/medical/noticeList.do">목록</a>
		</div>

	</div>
</main>

<%-- 푸터 - 메인(index.jsp)과 동일 마크업 --%>
<footer class="footer_wrap">
	<div class="footer_inner">
		<div class="footer_left">
			<a class="footer_bi" href="/front/medical/index.do"><img src="/common/front/kor/images/medilink-bi-white.svg" alt="메디링크 강원 MediLink Kangwon"></a>
			<nav class="footer_nav" aria-label="하단 메뉴">
				<a href="/front/medical/terms.do">이용약관</a>
				<a href="/front/medical/intro.do">회사소개</a>
				<a href="/front/medical/info.do">정보공개</a>
				<a href="/front/medical/project.do">사업소개</a>
				<a href="/front/medical/directions.do">찾아오시는길</a>
			</nav>
		</div>
		<div class="footer_right">
			<p>주식회사 코고네트웍스 · 한국글로벌헬스케어사업협동조합 사업 자회사</p>
			<p class="footer_copy">&copy; MediLink Kangwon. All rights reserved.</p>
		</div>
		<p class="footer_note">본 서비스의 모든 정보는 국가 공공데이터를 기반으로 하며, 의료적 판단의 최종 결정은 반드시 의료 전문가와 상의하시기 바랍니다.</p>
	</div>
</footer>
</body>
</html>
