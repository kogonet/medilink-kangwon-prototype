<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 관리자 메뉴
 **************************************************/
%>
<head>
	<style>
	#upload td {background-color: var(--bg-color09);}
	</style>
	<script type="text/javascript">
		$(document).ready(function(){
			/** 파일 체크 **/
			var permit_ext = [ "jpg", "jpeg", "png", "svg" ];
			$('#fileNo1').change(function() {
				
				var fileNm = $('#fileNo1').val().split('\\').pop().toLowerCase();
				var ext = fileNm.split('.').pop();
				var fileSize = this.files[0].size;
				
				//1. 확장자 체크
				if($.inArray(ext, permit_ext) == -1){
					$('#fileNo1').val('');
					alert(ext + " 확장자는 업로드 불가능합니다.");
					return false;
				}
				
				//2. 파일용량 제한
				const maxSize = 1024*1024*5;	// 5MB
				if(fileSize > maxSize){
					$('#fileNo1').val('');
					alert("파일크기는 " + maxSize/1024/1024 +"MB 까지 가능합니다.");
					return false;
				}
				console.log(fileSize);
				if(fileSize > 0) {
					const file = $(this)[0].files[0]; // 선택한 파일 가져오기
		            const previewImage = $("#previewImage"); // 미리보기 이미지 요소
		            const tag = $("#upload");
		            
		            if (file) {
		            	tag.show();
		            	
		                const reader = new FileReader(); // FileReader 객체 생성
		                reader.onload = function(e) {
		                	previewImage.attr("src", e.target.result); // 이미지 소스를 설정
		                    previewImage.show(); // 이미지를 표시
		                };
		                reader.readAsDataURL(file); // 파일 내용을 읽어 Data URL로 변환
		            } else {
		            	tag.hide();
		            	
		            	previewImage.attr("src", '').hide();
		            	tag.hide(); // 파일이 없으면 미리보기 숨기기
		            }
				}
				
			});
		});
		
		function fn_Regist(){
			
			var iconNm = $("#iconNm").val();
			var icon = $("#fileNo1").val();
			
			// 텍스트 값 존재 여부 확인
		    if (!iconNm) {
		        alert("아이콘 이름을 입력해 주세요.");
		        return false;
		    }

		    // 파일 존재 여부 확인
		    if (!icon) {
		        alert("파일을 선택해 주세요.");
		        return false;
		    }
			
			$("#frm").attr("action", "/admmgr/manage/menuIconLayerProc.do").submit();
		}
	</script>
</head>
<body>
	<form id="frm" name="frm" method="POST" enctype="multipart/form-data">
		<input type="hidden" name="siteCd" value="<c:out value='${siteCd}'/>"/>
		
		<div class="con_list_wrap" >
       		<h6 class="sub_tit_h6 fix"><em>아이콘 등록</em></h6>
       		<br><br>
       		<div class="n_table_sty01 n_view01 mt10">
               <table cellspacing="0" cellpadding="0" border="0" summary="아이콘 등록" class="tbl_ty2">
                   	<colgroup>
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody>
						<tr>
							<th>아이콘 이름</th>
							<td class="tx_lft">
								<input type="text" class="form_text w100" id="iconNm" name="iconNm"/>
							</td>
						</tr>
						<tr>
							<th>아이콘</th>
							<td>
								<input type="file" id="fileNo1" name="fileNo1" accept=".jpg, .jpeg, .png, .svg"/><br>
								<em class="c_sky">※ 파일은 [  jpg, jpeg, png, svg  ] 만 가능 합니다.</em><br/>
								<em class="c_red" style="background: none; width: auto;">※ 이미지는 24x24(px) 기준입니다.</em>
							</td>
						</tr>
						<tr id="upload" style="display:none; height: 55px;">
							<th>아이콘 미리보기</th>
							<td>
								<img id="previewImage" src="" alt="미리보기 이미지" style="display: none; width: 24px; height: 24px;">
							</td>
						</tr>
					</tbody>
                </table>
			</div>
			<br><br>
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