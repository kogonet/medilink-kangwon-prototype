<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 사이트 코드 관리 레이어
 **************************************************/
%>
<head>
	<script type="text/javascript">
		function checkForm( form ){
			/*
			if( !form.codeVal.value.trim() ){
				alert( "코드값을 입력해주세요." );
				form.codeVal.focus();
				return false;
			}
			*/
			return true;
		}
		function fn_Regist(){
			$("#regiform").submit();
		}
	</script>
</head>
<body>
	<form id="regiform" method="POST" action="<c:url value='/admmgr/manage/siteCodeLayerRegistProc.do'/>" onsubmit="return checkForm(this)">
		<input type="hidden" name="siteCd" value="<c:out value='${rMap.SITE_CD}'/>"/>
		
		
		
		<div class="con_list_wrap" >
       		<h6 class="sub_tit_h6 fix"><em>정보 설정</em></h6>
       		
       		<div class="n_table_sty01 n_view01 mt10">
               <table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
                   	<colgroup>
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody>
						<tr>
							<th>사이트 코드</th>
							<td class="tx_lft"><c:out value='${rMap.SITE_CD}'/></td>
						</tr>
						<tr>
							<th>사이트명</th>
							<td class="tx_lft"><c:out value='${rMap.SITE_NM}'/></td>
						</tr>
						<tr>
							<th>URL</th>
							<td><input type="text" class="form_text w100" id="url" name="url" value="<c:out value='${rMap.URL}'/>" style="width:calc(100% - 20px);"/></td>
						</tr>
					</tbody>
                </table>
			</div>
			
            <div class="page_btn_wrap jc_between mt20">
            	<div class="lft"></div>
               	<div class="btn_wrap rgt">
                   	<!-- <input type="submit" name="ctl00" value="등록" class="btn1_ty4"/> -->
                   	<a class="btn_n_add" href="javascript:void(0);" onclick="javavscript:fn_Regist();"><em>등록</em></a>
               	</div>
            </div>
    
        </div>
        <!--/common_wrapper-->
	</form>
</body>