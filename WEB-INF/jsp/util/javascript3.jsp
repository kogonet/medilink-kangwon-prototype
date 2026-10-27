<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script type="text/javascript">
${ SCRIPT }
</script>

<c:if test="${ URL ne null }">

	<form name="send_form" method="post" action="${ URL }">

		<input type="hidden" name="questionSeq" value="${ questionSeq }" />

	</form>

	<script type="text/javascript">
		document.send_form.submit();
	</script>
</c:if>