<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : AI-건강정보 관리 - 등록/수정
 *            tb_ai_health_info(마스터) 1건 + tb_ai_health_detail(상세, pt_num=마스터.rnum) N건을
 *            한 화면에서 함께 등록/수정한다. 상세의 구분(CNTNTS_CL_NM)은 레코드마다 제각각이라
 *            고정 선택목록 대신 자유 입력 + 기존값 자동완성(datalist)으로 처리한다.
 **************************************************/
%>
<head>
	<style type="text/css">
		.detail_row{border:1px solid #d2d2d2;border-radius:4px;padding:12px;margin-bottom:10px;background:#fff;}
		.detail_row .row_head{display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;flex-wrap:wrap;}
		.detail_row textarea{width:calc(100% - 20px);height:130px;}
		.detail_row .img_preview img{max-height:150px;max-width:100%;border:1px solid #eee;margin-top:6px;}
	</style>
	<script type="text/javascript">
		var CLSN_MAP = JSON.parse(document.getElementById("clsnMapJson").value || "{}");

		function fn_Regist(){
			if( $("#name").val().trim() == "" ){
				alert("건강정보명을 입력해주세요.");
				$("#name").focus();
				return false;
			}
			$("#frm").attr("action","<c:url value='/admmgr/manage/health/RegistProc.do'/>").submit();
		}
		function fn_List(){
			$("#frm").attr("action","<c:url value='/admmgr/manage/health/List.do'/>").submit();
		}

		// 구분(CNTNTS_CL_NM) 입력 시 기존에 쓰이던 분류코드(CNTNTSCLSN)를 자동으로 채워준다(비어있을 때만).
		function fn_AutoClsn(input){
			var $row = $(input).closest(".detail_row");
			var $clsn = $row.find("input[name='detailClsn']");
			if( $clsn.val().trim() != "" ){
				return;
			}
			var mapped = CLSN_MAP[ $(input).val() ];
			if( mapped ){
				$clsn.val(mapped);
			}
		}

		// 내용이 이미지 URL 한 줄이면 바로 아래에 미리보기를 보여준다.
		function fn_TogglePreview(textarea){
			var $row = $(textarea).closest(".detail_row");
			var $preview = $row.find(".img_preview");
			var val = $(textarea).val().trim();
			if( /^https?:\/\/\S+$/i.test(val) ){
				$preview.html('<img src="' + val + '" onerror="this.style.display=\'none\';"/>');
			} else {
				$preview.empty();
			}
		}

		function fn_Renumber(){
			$("#detailList .detail_row").each(function(index){
				$(this).find(".row_no").text(index + 1);
			});
		}

		function fn_AddRow(){
			var no = $("#detailList .detail_row").length + 1;
			var $row = $(""
				+ "<div class='detail_row'>"
				+ "  <div class='row_head'>"
				+ "    <div>"
				+ "      <b class='row_no'>" + no + "</b>번 항목 &nbsp;&nbsp;"
				+ "      구분 <input type='text' name='detailClNm' class='form_text' list='clNmDatalist' style='width:160px;' value='' onchange='fn_AutoClsn(this);'/>"
				+ "      &nbsp;분류코드 <input type='text' name='detailClsn' class='form_text' style='width:80px;' value=''/>"
				+ "    </div>"
				+ "    <div>"
				+ "      <a class='btn_n_modi' href='javascript:void(0);' onclick='fn_MoveRow(this,-1);'><span>위로</span></a>"
				+ "      <a class='btn_n_modi' href='javascript:void(0);' onclick='fn_MoveRow(this,1);'><span>아래로</span></a>"
				+ "      <a class='btn_n_del' href='javascript:void(0);' onclick='fn_RemoveRow(this);'><span>삭제</span></a>"
				+ "    </div>"
				+ "  </div>"
				+ "  <textarea name='detailClCn' class='form_textarea' oninput='fn_TogglePreview(this);' onchange='fn_TogglePreview(this);'></textarea>"
				+ "  <div class='img_preview'></div>"
				+ "</div>");
			$("#detailList").append($row);
			fn_Renumber();
		}

		function fn_RemoveRow(btn){
			$(btn).closest(".detail_row").remove();
			fn_Renumber();
		}

		function fn_MoveRow(btn, dir){
			var $row = $(btn).closest(".detail_row");
			if( dir < 0 ){
				var $prev = $row.prev(".detail_row");
				if( $prev.length > 0 ){
					$row.insertBefore($prev);
				}
			} else {
				var $next = $row.next(".detail_row");
				if( $next.length > 0 ){
					$row.insertAfter($next);
				}
			}
			fn_Renumber();
		}

		$(document).ready(function(){
			// 최초 등록 화면(상세가 하나도 없을 때)은 빈 행 1개를 기본으로 보여준다.
			if( $("#detailList .detail_row").length == 0 ){
				fn_AddRow();
			}
			// 서버에서 렌더링된 기존 행들도 이미지 URL이면 미리보기를 켜준다.
			$("#detailList textarea").each(function(){
				fn_TogglePreview(this);
			});
		});
	</script>
</head>
<body>
<form id="frm" name="frm" method="POST">
	<input type="hidden" id="rnum" name="rnum" value="<c:out value="${rMap.rnum}"/>"/>
	<input type="hidden" id="clsnMapJson" value="<c:out value="${clsnMapJson}"/>"/>

	<datalist id="divDatalist">
		<c:forEach items="${divList}" var="d">
			<option value="<c:out value="${d}"/>"/>
		</c:forEach>
	</datalist>
	<datalist id="clNmDatalist">
		<c:forEach items="${clNmList}" var="c">
			<option value="<c:out value="${c}"/>"/>
		</c:forEach>
	</datalist>

	<div class="sub_contents_wrap">
		<div class="sub_contents_area">

			<div class="table_header">
				<h4 class="sub_tit_h4 fix"><em>AI-건강정보 ${(not empty rMap.rnum)?'수정':'등록'}</em>
				<span><b class="ico_point">&nbsp;</b> 는 필수 입력사항 입니다.</span></h4>
			</div>

			<div class="n_table_sty01 n_view01 mt10">
				<table cellspacing="0" cellpadding="0" border="0" summary="AI-건강정보 등록" class="tbl_ty2">
					<colgroup>
						<col width="20%">
						<col width="30%">
						<col width="20%">
						<col width="30%">
					</colgroup>
					<tbody>
						<tr>
							<th>건강정보명 <em class="point">&nbsp;</em></th>
							<td>
								<input type="text" id="name" name="name" class="form_text" style="width:calc(100% - 20px);" value="<c:out value="${rMap.name}"/>" maxlength="200"/>
							</td>
							<th>구분</th>
							<td>
								<input type="text" id="div" name="div" class="form_text" list="divDatalist" style="width:calc(100% - 20px);" value="<c:out value="${rMap['div']}"/>" maxlength="30"/>
							</td>
						</tr>
						<tr>
							<th>질병관리청 콘텐츠 일련번호</th>
							<td colspan="3">
								<input type="text" id="id" name="id" class="form_text" style="width:150px;" value="<c:out value="${rMap.id}"/>"/>
								<p style="margin-top:5px;font-size:12px;color:#888;">질병관리청 건강정보 제공 API의 원본 콘텐츠 일련번호입니다. 직접 등록하는 정보는 비워두어도 됩니다.</p>
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="n_table_sty01 n_view01 mt20">
				<div class="table_header flx jc_between mb5">
					<h6 class="sub_tit_h6">상세 내용</h6>
					<a class="btn_n_add" href="javascript:void(0);" onclick="javascript:fn_AddRow();"><span>항목 추가</span></a>
				</div>
				<p style="margin-bottom:8px;font-size:12px;color:#888;">
					구분은 요약문/개요/정의/원인/치료/예방/자주하는 질문/참고문헌 등 콘텐츠마다 다르게 구성됩니다.
					기존에 사용된 값은 입력 시 자동완성으로 제안됩니다. 내용에 이미지 URL 한 줄만 입력하면 바로 아래에 미리보기가 표시됩니다.
					저장 순서는 화면에 보이는 순서 그대로 반영됩니다.
				</p>

				<div id="detailList">
					<c:forEach items="${detailList}" var="d" varStatus="status">
						<div class="detail_row">
							<div class="row_head">
								<div>
									<b class="row_no"><c:out value="${status.index + 1}"/></b>번 항목 &nbsp;&nbsp;
									구분 <input type="text" name="detailClNm" class="form_text" list="clNmDatalist" style="width:160px;" value="<c:out value="${d.clNm}"/>" onchange="fn_AutoClsn(this);"/>
									&nbsp;분류코드 <input type="text" name="detailClsn" class="form_text" style="width:80px;" value="<c:out value="${d.clsn}"/>"/>
								</div>
								<div>
									<a class="btn_n_modi" href="javascript:void(0);" onclick="fn_MoveRow(this,-1);"><span>위로</span></a>
									<a class="btn_n_modi" href="javascript:void(0);" onclick="fn_MoveRow(this,1);"><span>아래로</span></a>
									<a class="btn_n_del" href="javascript:void(0);" onclick="fn_RemoveRow(this);"><span>삭제</span></a>
								</div>
							</div>
							<textarea name="detailClCn" class="form_textarea" oninput="fn_TogglePreview(this);" onchange="fn_TogglePreview(this);"><c:out value="${d.clCn}"/></textarea>
							<div class="img_preview"></div>
						</div>
					</c:forEach>
				</div>
			</div>

			<div class="page_btn_wrap jc_between mt20">
				<div class="lft"></div>
				<div class="rgt">
					<a class="btn_n_save" href="javascript:void(0);" onclick="javascript:fn_Regist();"><span>저장</span></a>
					<a class="btn_n_list" href="javascript:void(0);" onclick="javascript:fn_List();"><span>목록</span></a>
				</div>
			</div>

		</div>
	</div>
</form>
</body>
