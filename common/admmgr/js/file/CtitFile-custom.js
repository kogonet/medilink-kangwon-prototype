/* Coa 파일 다운로드 컴포넌트 초기화 (길어서 따로 분리)*/
/* item_size : 파일 1개당 최대 용량(byte). 생략 시 기존값 2000000000 (메디링크 공지사항 mnoticeRegist.jsp 는 10MB = 10485760) */
function Coa_InitCustom(area_id, folder_nm, file_type, callback_fn, colum_nm, item_size) {
	Coa.FileCollection = [],
	Coa.Init({
		"error": function (res) {
			console.log(res);
		},
		"complete": function (res) {
			for (var i = 0, j = res.length; i < j; i++) {
				var data = $.parseJSON(res[i]);
				
				var inputs = [
				    { name: 'file_path', value: data.FILE_PATH },
				    { name: 'file_type', value: data.FILE_TYPE },
				    { name: 'origin_nm', value: data.ORIGIN_NM },
				    { name: 'uuid_nm'  , value: data.UUID_NM   },
				    { name: 'file_size', value: data.FILE_SIZE },
				];

				//폼에 추가
				AppendInputHidden(inputs, 'frm');
				AppendInputHidden(inputs, 'historyForm'); //연혁 추가용
			}
			if ( callback_fn instanceof Function ) {
				$("#columNm").val(colum_nm);
				callback_fn();
			}
		},
		"data": {
			"folder_nm" : folder_nm,
			"file_type" : file_type
		},
		"area_id": area_id,
		"upload_url": "/commonFile/fileUpload.do",
		"item_size": item_size ? item_size : 2000000000,
		"is_upload_btn": false,
		"is_delete_btn": true ,
		"permit_ext": [ "zip" , "pdf" , "jpg" , "jpeg" , "png" , "bmp" , "hwp" , "doc" , "docx" , "xls" , "xlsx" , "ppt" , "pptx" , "hwpx"] ,
		"no_permit_ext": [ "exe" , "dll" , "bat" , "java" , "jsp" , "html" , "htm" , "asp" , "cs" , "css" , "js" , "aspx" , "ascx" , "php" , "sql" , "msi"]
	});
	
}

/* input hidden 추가 */
function AppendInputHidden(inputs, form_nm){
	inputs.forEach(function(item) {
	    var input = document.createElement('input');
	    input.type = 'hidden';
	    input.name = item.name;
	    input.value = item.value;
	    $("#" + form_nm).append(input);
	});
}

/* 파일 다운로드 */
function fileDownload(fileNo, fileSeq) {
	
	$("form#filedownloadForm").remove();
	
	//[1]Validate
	if( G_IsEmpty(fileNo) || G_IsEmpty(fileSeq) ){
		alert("파일 다운로드에 실패하였습니다.");
		return false;
	}
	
	//[2]다운로드를 위한 가상폼 생성
	var oFileForm = $("<form/>",{
		id     : "filedownloadForm",
		name   : "filedownloadForm",
		target : "_self",
		method : "POST",
		action : "/commonFile/fileDownload.do"
	});
	oFileForm.append("<input type='hidden' id='fileNo' name='fileNo' value='" + fileNo + "'/>");
	oFileForm.append("<input type='hidden' id='fileSeq' name='fileSeq' value='" + fileSeq + "'/>");
	$("body").append(oFileForm);
	oFileForm.submit();
	
}

/* 논리적 파일 삭제 */
function fileDeleteLogi(obj, fileNo, fileSeq) {
	var rmvObj = $(obj).closest("tr");
	var fileBody = $(obj).closest("tbody");
	
	//[1]Validate
	if( G_IsEmpty(fileNo) || G_IsEmpty(fileSeq) ){
		alert("파일 삭제에 실패하였습니다.");
		return false;
	}
	//[2]파일삭제 ajax
	if ( confirm("파일을 삭제하시겠습니까?") ) {
		$.ajax({
		    url         : "/commonFile/fileLogicalDelete.do",
		    type        : "POST",
		    dataType    : "json",
		    traditional : true,
		    data        : {
		    	"fileNo" : fileNo,
		    	"fileSeq": fileSeq
		    },
		    error       : function(e){
		    	//console.log(e);
		        alert("파일 삭제에 실패하였습니다."+e.status);
		        return false;
		    },
		    success     : function(result){
		    	if ( result ) {
		    		rmvObj.remove();
		    		if ( fileBody.children().length == 0 ) {
		    			fileBody.html("<tr><th class='center' colspan='2'>등록된 파일이 없습니다.</th></tr>");
		    		}
		    	} else {
		    		console.log (result);
		    		alert("파일 삭제에 실패하였습니다.");
		    	}
		    }
		});
	}
	
}

/* 물리적 파일 삭제 */
function fileDeletePhysi(obj, fileNo, fileSeq) {
	
	var rmvObj = $(obj).closest("tr");
	var fileBody = $(obj).closest("tbody");
	
	//[1]Validate
	if( G_IsEmpty(fileNo) || G_IsEmpty(fileSeq) ){
		alert("파일 삭제에 실패하였습니다.");
		return false;
	}
	//[2]파일삭제 ajax
	if ( confirm("파일을 삭제하시겠습니까?") ) {
		$.ajax({
		    url         : "/commonFile/filePhysicalDelete.do",
		    type        : "POST",
		    dataType    : "json",
		    traditional : true,
		    data        : {
		    	"fileNo" : fileNo,
		    	"fileSeq": fileSeq
		    },
		    error       : function(e){
		    	//console.log(e);
		        alert("파일 삭제에 실패하였습니다."+e.status);
		        return false;
		    },
		    success     : function(result){
		    	if ( result ) {
		    		rmvObj.remove();
		    		if ( fileBody.children().length == 0 ) {
		    			fileBody.html("<tr><th class='center' colspan='2'>등록된 파일이 없습니다.</th></tr>");
		    		}
		    	} else {
		    		console.log (result);
		    		alert("파일 삭제에 실패하였습니다.");
		    	}
		    }
		});
	}
	
}

function fileDeleteLogi2(obj, fileNo, fileSeq, fileNum) {
    var rmvObj = $(obj).closest("tr");
    var fileBody = $(obj).closest("tbody");

    // [1] Validate
    if (G_IsEmpty(fileNo) || G_IsEmpty(fileSeq)) {
        alert("파일 삭제에 실패하였습니다.");
        return false;
    }

    // [2] 파일삭제 ajax
    if (confirm("파일을 삭제하시겠습니까?")) {
        $.ajax({
            url: "/commonFile/fileLogicalDelete.do",
            type: "POST",
            dataType: "json",
            traditional: true,
            data: {
                "fileNo": fileNo,
                "fileSeq": fileSeq
            },
            error: function (e) {
                alert("파일 삭제에 실패하였습니다." + e.status);
                return false;
            },
            success: function (result) {
                if (result) {
                    // rmvObj.remove(); // tr 전체 삭제 대신 내용 교체
                    rmvObj.html(`
                        <td colspan="2">
		                    <div class="td_wrap">
		                        <input type="file" id="${fileNum}" name="${fileNum}" accept=".xls, .xlsx, .pdf, .ppt, .pptx, .zip">
		                    </div>
		                </td>
                    `);
                } else {
                    console.log(result);
                    alert("파일 삭제에 실패하였습니다.");
                }
            }
        });
    }
}