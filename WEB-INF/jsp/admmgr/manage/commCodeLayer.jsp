<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
/**************************************************
 * @desc    : 코드 관리 레이어
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
	<form id="regiform" method="POST" action="<c:url value='/admmgr/manage/commCodeLayerRegistProc.do'/>" onsubmit="return checkForm(this)">
		<input type="hidden" name="code" value="<c:out value='${rMap.CODE}'/>"/>
		<input type="hidden" name="siteCd" value="<c:out value='${rMap.SITE_CD}'/>"/>
		<!--common_wrapper-->
		<div class="common_wrapper pop_common_wrapper">
			
            <!--body_wrapper-->
            <div class="body_wrapper">
    
                <!-- pop_wrapper -->
                <div class="pop_wrapper">
                    <!-- pop_inner -->
                    <div class="pop_inner">
                        <!-- 컨텐츠 영역 -->
                        <div class="pop_con_section">
                            <div class="con_list_wrap" >
                                    
                                       <table cellspacing="0" cellpadding="0" border="0" summary="게시판 리스트" class="tbl_ty2">
                                           <colgroup>
												<col width="30%"/>
												<col width="70%"/>
											</colgroup>
                                        	<tbody>
												<tr>
													<th>코드</th>
													<td><c:out value='${rMap.CODE}'/></td>
												</tr>
												<tr>
													<th>코드명</th>
													<td><c:out value='${rMap.CODE_NM}'/></td>
												</tr>
												<tr>
													<th>코드설명</th>
													<td><textarea id="codeDc" name="codeDc" class="input_text" style="height:100px;" maxlength="100"><c:out value='${rMap.CODE_DC}'/></textarea></td>
												</tr>
                                           </tbody>
                                       </table>

                                        <p class="btn_section fix" style="height:36px;">
                                            <span class="rit_btn_section">
                                                <a class="btn1_ty4" href="javascript:void(0);" onclick="javavscript:fn_Regist();"><em>등록</em></a>
                                            </span>
                                        </p>
                                </div>
                        </div>
                        <!-- // 컨텐츠 영역 -->
                    </div>
                    <!-- pop_inner -->
    
                </div>	
                <!-- // pop_wrapper -->
                    
    
            </div>
            <!--/body_wrapper-->
    
        </div>
        <!--/common_wrapper-->
	</form>
</body>