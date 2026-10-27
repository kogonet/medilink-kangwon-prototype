<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * @desc    : AI 상담4 답변 디자인 (Ai4DesignAdmin.page, 2026-10-16 답변 템플릿 빌더 4단계)
 *            문구·디자인 값 편집 → 임시 저장 → 같은 화면 미리보기(iframe) → 게시, 이력 불러오기
 *            편집 폼은 design-admin.js 가 /admmgr/ai4/designData.do 의 편집 항목 목록으로 그린다.
 *            [틀] 탭: 블록 HTML 틀·CSS 편집, publisher 폴더 파일 세트 가져오기 (2026-10-21 CMS 블록 템플릿 1단계)
 *            [틀] 탭 블록별 여러 틀·변수/행 필드 칩, [할당] 탭: 출처 × 블록 → 틀 (2026-10-21 2~4단계)
 **************************************************/
%>
<head>
<style>
	/* CMS 색상 변수 사용 → 다크 테마 대응 */
	.ad4_bar { display:flex; flex-wrap:wrap; align-items:center; gap:8px; padding:10px 14px; border:1px solid var(--bd-color06); background:var(--bg-color06); }
	.ad4_bar .ad4_state { margin-right:auto; font-size:12px; color:var(--txt-color03); line-height:1.6; }
	.ad4_bar .ad4_state strong { color:var(--txt-color); font-weight:600; }
	.ad4_bar .ad4_dirty { color:#E8590C; font-weight:600; }
	.ad4_bar label.ad4_chk { display:inline-flex; align-items:center; gap:4px; font-size:12px; color:var(--txt-color); }
	.ad4_msg { margin:8px 0 0; padding:8px 12px; border:1px solid var(--bd-color06); font-size:12px; line-height:1.6; }
	.ad4_msg.is-error { border-color:#FFA8A8; background:#FFF5F5; color:#C92A2A; }
	.ad4_msg.is-ok { border-color:#B2F2BB; background:#EBFBEE; color:#2B8A3E; }
	.ad4_msg ul { margin:4px 0 0 16px; } .ad4_msg li { list-style:disc; }
	.ad4_wrap { display:flex; gap:14px; align-items:flex-start; margin-top:12px; }
	.ad4_edit { flex:1 1 52%; min-width:0; }
	.ad4_prev { flex:1 1 48%; min-width:0; position:sticky; top:10px; }
	.ad4_prev iframe { display:block; width:100%; height:calc(100vh - 140px); min-height:520px; border:1px solid var(--bd-color06); background:#EEF1F7; }
	.ad4_pick { display:flex; gap:8px; align-items:center; margin-bottom:10px; }
	.ad4_tabs { display:flex; gap:4px; margin-bottom:10px; border-bottom:1px solid var(--bd-color06); }
	.ad4_tabs button { padding:6px 14px; border:1px solid transparent; border-bottom:0; background:none; color:var(--txt-color03); font-size:13px; cursor:pointer; }
	.ad4_tabs button.is-on { border-color:var(--bd-color06); background:var(--bg-color06); color:var(--txt-color); font-weight:600; }
	.ad4_item { padding:10px 0; border-bottom:1px dashed var(--bd-color06); }
	.ad4_item_head { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin-bottom:4px; font-size:12px; color:var(--txt-color03); }
	.ad4_item_head code { font-size:11px; color:var(--txt-color); }
	.ad4_item_head .ad4_changed { color:#E8590C; font-weight:600; }
	.ad4_item textarea { width:100%; min-height:44px; box-sizing:border-box; font-size:12px; line-height:1.5; }
	.ad4_vars { display:flex; flex-wrap:wrap; gap:4px; margin-top:3px; }
	.ad4_vars span { padding:0 6px; border:1px solid var(--bd-color06); border-radius:8px; font-size:11px; color:var(--txt-color03); cursor:pointer; }
	.ad4_group { margin:0 0 14px; padding:10px 12px; border:1px solid var(--bd-color06); }
	.ad4_group > h6 { margin:0 0 8px; font-size:13px; font-weight:600; color:var(--txt-color); }
	.ad4_props { display:grid; grid-template-columns:repeat(auto-fill, minmax(170px, 1fr)); gap:6px 12px; }
	.ad4_prop { display:flex; flex-direction:column; gap:2px; font-size:11px; color:var(--txt-color03); }
	.ad4_prop .ad4_in { display:flex; gap:4px; align-items:center; }
	.ad4_prop input[type=text], .ad4_prop input[type=number], .ad4_prop select { width:100%; height:26px; box-sizing:border-box; font-size:12px; }
	.ad4_prop input[type=color] { width:30px; height:26px; padding:0; border:1px solid var(--bd-color06); background:none; }
	.ad4_note { font-size:11px; color:var(--txt-color03); }
	.ad4_prot { color:#C92A2A; font-weight:600; }
	.ad4_pub { margin:6px 0 0; font-size:12px; color:var(--txt-color03); line-height:1.6; }
	.ad4_pub summary { cursor:pointer; }
	.ad4_pub ul { margin:2px 0 0 16px; } .ad4_pub li { list-style:disc; }
	.ad4_pub .is-err { color:#C92A2A; }
	/* UI 개선 (2026-10-16): 그룹 머리·배지·초기화, 편집 항목 ↔ 미리보기 강조, 좌우 폭 손잡이 */
	.ad4_pick .ad4_reset_block { margin-left:auto; }
	.ad4_group, .ad4_item { scroll-margin:60px; transition:box-shadow .2s; cursor:default; }
	.ad4_group_head { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin:0 0 8px; }
	.ad4_group_head h6 { margin:0; font-size:13px; font-weight:600; color:var(--txt-color); }
	.ad4_group_head .ad4_reset { margin-left:auto; }
	.ad4_changed { color:#E8590C; font-size:11px; font-weight:600; }
	.ad4_badge { padding:0 6px; border-radius:3px; background:#FFE3E3; color:#C92A2A; font-size:11px; font-weight:600; line-height:18px; }
	.ad4_count { font-size:11px; color:#E8590C; }
	.ad4_count.is-none { color:var(--txt-color03); }
	.btn.is-disabled { opacity:.45; pointer-events:none; }
	.ad4_prop.is-changed > span:first-child { color:#E8590C; font-weight:600; }
	.ad4_prop input.is-bad { border-color:#FA5252; background:#FFF5F5; }
	.ad4_group.is-sel, .ad4_item.is-sel { box-shadow:inset 3px 0 0 #E8590C; }
	.ad4_item.is-sel { padding-left:8px; }
	.ad4_group.is-flash, .ad4_item.is-flash, .ad4_pick.is-flash { animation:ad4-flash 1.2s ease-out; }
	.ad4_pick_from { font-size:11px; color:#E8590C; }
	@keyframes ad4-flash { 0%, 40% { background:#FFF3BF; } 100% { background:transparent; } }
	.ad4_wrap { gap:0; align-items:stretch; }
	.ad4_prev { align-self:flex-start; }
	.ad4_split { flex:0 0 14px; position:relative; cursor:col-resize; touch-action:none; outline:none; }
	.ad4_split::before { content:""; position:absolute; top:0; bottom:0; left:6px; width:2px; background:var(--bd-color06); }
	.ad4_split:hover::before, .ad4_split:focus-visible::before, .ad4_wrap.is-dragging .ad4_split::before { left:5px; width:4px; background:#4C6EF5; }
	.ad4_split_grip { position:sticky; top:calc(50vh - 20px); display:block; width:8px; height:40px; margin-left:3px; border-radius:4px; background:var(--bg-color06); border:1px solid var(--bd-color06); box-sizing:border-box; }
	.ad4_wrap.is-dragging { cursor:col-resize; user-select:none; }
	.ad4_wrap.is-dragging iframe { pointer-events:none; }
	@media (max-width: 1280px) { .ad4_wrap { flex-direction:column; gap:14px; } .ad4_prev { position:static; width:100%; } .ad4_split { display:none; } }
	/* 블록 틀 탭 (CMS 블록 템플릿 1단계, 2026-10-21) */
	.ad4_tpl_on { display:inline-flex; align-items:center; gap:4px; margin-bottom:8px; font-size:12px; color:var(--txt-color); }
	.ad4_code { width:100%; box-sizing:border-box; font-family:Consolas, "D2Coding", monospace; font-size:12px; line-height:1.5; white-space:pre; tab-size:2; }
	.ad4_code.is-html { min-height:240px; }
	.ad4_code.is-css { min-height:140px; }
	.ad4_slots { display:flex; flex-wrap:wrap; gap:4px; margin:4px 0 8px; }
	.ad4_slots button { padding:1px 8px; border:1px solid var(--bd-color06); border-radius:10px; background:none; color:var(--txt-color); font-size:11px; cursor:pointer; }
	.ad4_slots button:disabled { color:var(--txt-color03); cursor:not-allowed; }
	.ad4_tpl_msgs { margin:6px 0 0; font-size:12px; line-height:1.6; }
	.ad4_tpl_msgs li { list-style:disc; margin-left:16px; }
	.ad4_tpl_msgs .is-err { color:#C92A2A; }
	.ad4_tpl_msgs .is-warn { color:#B35C00; }
	/* 틀 여러 개·칩·도움말·할당 탭 (CMS 블록 템플릿 2~4단계, 2026-10-21) */
	.ad4_tpl_bar { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin:0 0 8px; }
	.ad4_tpl_bar select { max-width:100%; }
	.ad4_slots .ad4_chip_title { align-self:center; min-width:48px; font-size:11px; font-weight:600; color:var(--txt-color03); }
	.ad4_help { margin:0 0 14px; padding:8px 12px; border:1px dashed var(--bd-color06); font-size:12px; }
	.ad4_help summary { cursor:pointer; font-weight:600; color:var(--txt-color); }
	.ad4_help p { margin:6px 0 0; }
	.ad4_help code { font-size:11px; color:var(--txt-color); }
	.ad4_assign { width:100%; border-collapse:collapse; font-size:12px; }
	.ad4_assign th, .ad4_assign td { padding:4px 6px; border-bottom:1px solid var(--bd-color06); text-align:left; vertical-align:middle; }
	.ad4_assign td code { font-size:10px; color:var(--txt-color03); }
	.ad4_assign select { width:100%; height:26px; font-size:12px; }
	.ad4_cond { display:flex; flex-wrap:wrap; align-items:center; gap:4px; padding:6px 0; border-bottom:1px dashed var(--bd-color06); font-size:12px; }
	.ad4_cond select, .ad4_cond input { height:26px; font-size:12px; }
	.ad4_cond input { width:110px; }
</style>
</head>

<div class="sub_contents_wrap">
	<div class="sub_contents_area">
		<h4 class="sub_tit_h4"></h4>
		<div class="noti_area mt0">
			<p class="noti_text"><em>AI 상담4 답변의 문구와 디자인을 고칩니다. 임시 저장 → 미리보기로 확인 → 게시 순서로 반영되며, 게시하면 1분 안에 모든 서버에 적용됩니다.</em></p>
			<p class="noti_text"><em>값을 비우면 기본 모양을 씁니다.</em></p>
		</div>

		<div id="ad4" class="mt10"
			data-data="<c:url value='/admmgr/ai4/designData.do'/>"
			data-save="<c:url value='/admmgr/ai4/designSave.do'/>"
			data-publish="<c:url value='/admmgr/ai4/designPublish.do'/>"
			data-load="<c:url value='/admmgr/ai4/designLoad.do'/>"
			data-css="<c:url value='/admmgr/ai4/designCss.do'/>"
			data-import="<c:url value='/admmgr/ai4/designImport.do'/>">
			<div class="ad4_bar">
				<div class="ad4_state" id="ad4State">불러오는 중…</div>
				<input type="text" id="ad4Memo" class="form_text wd320" maxlength="500" placeholder="메모 (무엇을 바꿨는지)"/>
				<label class="ad4_chk" title="블록 틀로 답변을 그립니다: 이 화면 [틀] 탭에서 만든 틀, 하나도 없으면 publisher 폴더(pt-ai/gwtpax4/publisher) 파일 틀. 틀이 없는 블록은 지금 디자인으로 그립니다">
					<input type="checkbox" id="ad4Publisher"/> 틀 사용
				</label>
				<a href="#" class="btn secondary sm" id="ad4Save">임시 저장</a>
				<a href="#" class="btn secondary sm" id="ad4Preview">미리보기</a>
				<a href="#" class="btn primary sm" id="ad4Publish">게시</a>
			</div>
			<div class="ad4_pub" id="ad4Pub"></div>
			<div id="ad4Msg"></div>

			<div class="ad4_wrap">
				<div class="ad4_edit">
					<div class="ad4_pick">
						<label for="ad4Block" class="ad4_note">편집할 블록</label>
						<select id="ad4Block" class="form_select md" title="편집할 블록"></select>
						<a href="#" class="btn secondary xsm ad4_reset_block" id="ad4ResetBlock" title="고른 블록의 문구와 디자인 값을 모두 기본값으로 되돌립니다">이 블록 전체 초기화</a>
					</div>
					<div class="ad4_tabs" role="tablist">
						<button type="button" class="is-on" data-tab="text">문구</button>
						<button type="button" data-tab="style">디자인</button>
						<button type="button" data-tab="template">틀</button>
						<button type="button" data-tab="assign">할당</button>
					</div>
					<div id="ad4Panel"></div>
				</div>
				<div class="ad4_split" id="ad4Split" role="separator" aria-orientation="vertical" aria-label="편집·미리보기 폭 조절" tabindex="0" title="드래그해서 폭 조절 (더블클릭: 기본, 키보드 ←/→)"><span class="ad4_split_grip"></span></div>
				<div class="ad4_prev">
					<iframe id="ad4Frame" title="답변 디자인 미리보기" src="<c:url value='/gwtpax/ai4-design-preview.do'/>"></iframe>
				</div>
			</div>

			<div class="table_header mt20 mb5">
				<h6 class="sub_tit_h6">게시 이력</h6>
			</div>
			<div class="n_table_sty01 n_list01">
				<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="AI 상담4 답변 디자인 게시 이력">
					<colgroup><col width="8%"/><col width="16%"/><col width="12%"/><col width="12%"/><col width="*"/><col width="10%"/></colgroup>
					<thead>
						<tr><th class="center">상태</th><th class="center">게시 일시</th><th class="center">버전</th><th class="center">게시자</th><th>메모</th><th class="center">불러오기</th></tr>
					</thead>
					<tbody id="ad4History"><tr><td colspan="6" class="center">불러오는 중…</td></tr></tbody>
				</table>
			</div>
		</div>
	</div>
</div>
<script src="<c:url value='/pt-ai/gwtpax4/js/design-admin.js'/>"></script>
