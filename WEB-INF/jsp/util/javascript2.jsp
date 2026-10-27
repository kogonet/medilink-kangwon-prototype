<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script type="text/javascript">
${ SCRIPT }
</script>

<c:if test="${ URL ne null }">

	<form name="send_form" method="post" action="${ URL }">

		<c:if test="${ PARAMETER ne null }">
			<c:forEach items="${ PARAMETER }" var="DR">
				<input type="hidden" name="${ DR.key }" value="${ DR.value }" />
			</c:forEach>
		</c:if>

	</form>

    <script type="text/javascript">
        $(document).ready(function(){
            document.getElementById("send_form").submit();
            history.go(-2);
            location.reload();
        });
    </script>
</c:if>