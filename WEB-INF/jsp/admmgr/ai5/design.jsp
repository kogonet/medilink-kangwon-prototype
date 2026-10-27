<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
/**************************************************
 * @desc    : AI 상담5 답변 디자인 (Ai5DesignAdmin.page, 2026-10-16 답변 템플릿 빌더 4단계)
 *            문구·디자인 값 편집 → 임시 저장 → 같은 화면 미리보기(iframe) → 게시, 이력 불러오기
 *            편집 폼은 design-admin.js 가 /admmgr/ai5/designData.do 의 편집 항목 목록으로 그린다.
 *            [틀] 탭: 블록 HTML 틀·CSS 편집, publisher 폴더 파일 세트 가져오기 (2026-10-21 CMS 블록 템플릿 1단계)
 *            [틀] 탭 블록별 여러 틀·변수/행 필드 칩, [할당] 탭: 출처 × 블록 → 틀 (2026-10-21 2~4단계)
 *            UI 개선 (2026-10-23): 맨 위 탭(답변 편집·틀 관리·할당·이력) + 왼쪽 블록 목록, 단계 표시 상태 바,
 *            게시 전 변경 요약 창, 문구·디자인 검색·"바뀐 것만"·그룹 접기, 미리보기 폭(모바일·태블릿·PC)·바뀐 곳 강조
 **************************************************/
%>
<head>
<style>
	/* CMS 색상 변수 사용 → 다크 테마 대응. 이 화면 전용 강조색은 아래 --ad4-* 로만 쓴다 */
	#ad4 { --ad4-chg:#E8590C; --ad4-chg-bg:#FFF4E6; --ad4-err:#C92A2A; --ad4-err-bg:#FFF5F5; --ad4-ok:#2B8A3E; --ad4-ok-bg:#EBFBEE;
		--ad4-pri:#3B5BDB; --ad4-pri-bg:#EDF2FF; --ad4-warn:#B35C00; --ad4-flash:#FFF3BF; --ad4-soft:var(--bg-color08); }
	body[data-theme="dark"] #ad4 { --ad4-chg:#FF922B; --ad4-chg-bg:rgba(255,146,43,.14); --ad4-err:#FF8787; --ad4-err-bg:rgba(255,135,135,.12);
		--ad4-ok:#69DB7C; --ad4-ok-bg:rgba(105,219,124,.12); --ad4-pri:#748FFC; --ad4-pri-bg:rgba(116,143,252,.16); --ad4-warn:#FFC078;
		--ad4-flash:rgba(255,212,59,.22); --ad4-soft:rgba(255,255,255,.04); }
	#ad4 { font-size:13px; color:var(--txt-color); }
	#ad4 code { font-family:Consolas, "D2Coding", monospace; }

	/* 상태 바: 단계 표시 · 상태 · 메모 · 저장/게시 */
	.ad4_bar { position:sticky; top:0; z-index:5; display:flex; flex-wrap:wrap; align-items:center; gap:8px 12px; padding:10px 14px; border:1px solid var(--bd-color06); background:var(--bg-color06); }
	.ad4_steps { display:flex; align-items:center; gap:2px; margin:0; padding:0; list-style:none; }
	.ad4_steps li { display:flex; align-items:center; gap:5px; padding:3px 9px; border-radius:999px; font-size:12px; color:var(--txt-color10); white-space:nowrap; }
	.ad4_steps li::before { content:""; width:7px; height:7px; border-radius:50%; background:var(--bd-color06); }
	.ad4_steps li + li { margin-left:14px; position:relative; }
	.ad4_steps li + li::after { content:"›"; position:absolute; left:-12px; color:var(--txt-color10); }
	.ad4_steps li.is-done { color:var(--txt-color03); } .ad4_steps li.is-done::before { background:var(--ad4-ok); }
	.ad4_steps li.is-cur { background:var(--ad4-pri-bg); color:var(--ad4-pri); font-weight:700; } .ad4_steps li.is-cur::before { background:var(--ad4-pri); }
	.ad4_steps li.is-cur.is-dirty { background:var(--ad4-chg-bg); color:var(--ad4-chg); } .ad4_steps li.is-cur.is-dirty::before { background:var(--ad4-chg); }
	.ad4_bar .ad4_state { margin-right:auto; font-size:12px; color:var(--txt-color03); line-height:1.6; }
	.ad4_bar .ad4_state strong { color:var(--txt-color); font-weight:600; }
	.ad4_bar .ad4_state .ad4_ver { color:var(--txt-color10); font-size:11px; }
	.ad4_bar .ad4_dirty { color:var(--ad4-chg); font-weight:600; }
	.ad4_kbd { margin-left:4px; padding:0 3px; border:1px solid currentColor; border-radius:3px; font-size:10px; opacity:.6; }
	.ad4_msg { margin:8px 0 0; padding:8px 12px; border:1px solid var(--bd-color06); font-size:12px; line-height:1.6; }
	.ad4_msg.is-error { border-color:var(--ad4-err); background:var(--ad4-err-bg); color:var(--ad4-err); }
	.ad4_msg.is-ok { border-color:var(--ad4-ok); background:var(--ad4-ok-bg); color:var(--ad4-ok); }
	.ad4_msg ul { margin:4px 0 0 16px; } .ad4_msg li { list-style:disc; }

	/* 맨 위 탭 */
	.ad4_mtabs { display:flex; gap:2px; margin:14px 0 0; border-bottom:1px solid var(--bd-color06); }
	.ad4_mtabs button { position:relative; padding:8px 16px; border:0; background:none; color:var(--txt-color03); font-size:14px; cursor:pointer; }
	.ad4_mtabs button.is-on { color:var(--txt-color); font-weight:700; }
	.ad4_mtabs button.is-on::after { content:""; position:absolute; left:8px; right:8px; bottom:-1px; height:3px; background:var(--ad4-pri); }
	.ad4_num { margin-left:4px; padding:0 6px; border-radius:999px; background:var(--ad4-chg-bg); color:var(--ad4-chg); font-size:11px; font-weight:700; }
	.ad4_num:empty { display:none; }

	/* 편집 | 폭 손잡이 | 미리보기 */
	.ad4_wrap { display:flex; align-items:stretch; margin-top:12px; }
	.ad4_edit { flex:1 1 58%; min-width:0; display:flex; align-items:flex-start; gap:12px; }
	.ad4_body { flex:1; min-width:0; }
	.ad4_prev { flex:1 1 42%; min-width:0; position:sticky; top:62px; align-self:flex-start; border:1px solid var(--bd-color06); }
	.ad4_ptool { display:flex; flex-wrap:wrap; align-items:center; gap:8px; padding:6px 8px; border-bottom:1px solid var(--bd-color06); background:var(--bg-color06); }
	.ad4_ptool .ad4_chk { margin-left:auto; }
	.ad4_pstage { overflow:auto; background:#EEF1F7; }
	.ad4_prev iframe { display:block; width:100%; margin:0 auto; height:calc(100vh - 180px); min-height:520px; border:0; background:#EEF1F7; transition:width .2s; }
	.ad4_seg { display:inline-flex; border:1px solid var(--bd-color06); }
	.ad4_seg button { padding:2px 10px; border:0; background:none; color:var(--txt-color03); font-size:12px; cursor:pointer; }
	.ad4_seg button + button { border-left:1px solid var(--bd-color06); }
	.ad4_seg button.is-on { background:var(--ad4-pri-bg); color:var(--ad4-pri); font-weight:700; }
	label.ad4_chk { display:inline-flex; align-items:center; gap:4px; font-size:12px; color:var(--txt-color); cursor:pointer; }
	.ad4_split { flex:0 0 14px; position:relative; cursor:col-resize; touch-action:none; outline:none; }
	.ad4_split::before { content:""; position:absolute; top:0; bottom:0; left:6px; width:2px; background:var(--bd-color06); }
	.ad4_split:hover::before, .ad4_split:focus-visible::before, .ad4_wrap.is-dragging .ad4_split::before { left:5px; width:4px; background:var(--ad4-pri); }
	.ad4_split_grip { position:sticky; top:calc(50vh - 20px); display:block; width:8px; height:40px; margin-left:3px; border-radius:4px; background:var(--bg-color06); border:1px solid var(--bd-color06); box-sizing:border-box; }
	.ad4_wrap.is-dragging { cursor:col-resize; user-select:none; }
	.ad4_wrap.is-dragging iframe { pointer-events:none; }

	/* 왼쪽 블록 목록 */
	.ad4_blist { flex:0 0 200px; position:sticky; top:62px; max-height:calc(100vh - 80px); overflow:auto; padding:6px; border:1px solid var(--bd-color06); background:var(--bg-color06); box-sizing:border-box; }
	.ad4_blist input { width:100%; height:28px; margin:0 0 4px; box-sizing:border-box; font-size:12px; }
	.ad4_blist h6 { margin:10px 6px 2px; font-size:11px; font-weight:600; color:var(--txt-color10); }
	.ad4_blist button { display:flex; align-items:center; gap:6px; width:100%; padding:5px 8px; border:0; background:none; color:var(--txt-color02); font-size:13px; text-align:left; cursor:pointer; }
	.ad4_blist button:hover { background:var(--ad4-soft); }
	.ad4_blist button.is-on { background:var(--ad4-pri-bg); color:var(--ad4-pri); font-weight:700; }
	.ad4_blist button .ad4_bname { flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
	.ad4_blist button .ad4_btag { font-size:10px; font-weight:400; color:var(--txt-color10); }
	.ad4_blist button .ad4_bnum { min-width:16px; padding:0 5px; border-radius:999px; background:var(--ad4-chg); color:#fff; font-size:10px; font-weight:700; line-height:16px; text-align:center; }
	.ad4_blist button .ad4_bnum.is-tpl { background:var(--ad4-pri-bg); color:var(--ad4-pri); }
	.ad4_blist button.is-flash { animation:ad4-flash 1.2s ease-out; }

	/* 블록 머리 · 문구/디자인 · 검색 줄 */
	.ad4_head { display:flex; flex-wrap:wrap; align-items:center; gap:6px 8px; margin:0 0 10px; }
	.ad4_head h5 { margin:0; font-size:16px; font-weight:700; color:var(--txt-color); }
	.ad4_head > code { font-size:11px; color:var(--txt-color10); }
	.ad4_head .ad4_reset_block { margin-left:auto; }
	.ad4_tag { padding:0 7px; border:1px solid var(--bd-color06); border-radius:999px; font-size:11px; color:var(--txt-color03); line-height:18px; }
	.ad4_tag.is-tpl { border-color:transparent; background:var(--ad4-pri-bg); color:var(--ad4-pri); }
	.ad4_pick_from { font-size:11px; color:var(--ad4-chg); }
	.ad4_sub { display:flex; gap:4px; margin:0 0 8px; border-bottom:1px solid var(--bd-color06); }
	.ad4_sub button { padding:6px 14px; border:1px solid transparent; border-bottom:0; background:none; color:var(--txt-color03); font-size:13px; cursor:pointer; }
	.ad4_sub button.is-on { border-color:var(--bd-color06); background:var(--bg-color06); color:var(--txt-color); font-weight:700; margin-bottom:-1px; }
	.ad4_sub button .ad4_subn { margin-left:3px; font-size:11px; color:var(--txt-color10); font-weight:400; }
	.ad4_sub button .ad4_subc { margin-left:3px; font-size:11px; color:var(--ad4-chg); font-weight:700; }
	.ad4_tools { display:flex; flex-wrap:wrap; align-items:center; gap:8px; margin:0 0 10px; }
	.ad4_tools input[type=search] { flex:1; min-width:160px; height:28px; box-sizing:border-box; font-size:12px; }

	/* 보기별로 보이는 것 (data-view) */
	#ad4 .ad4_only { display:none; }
	#ad4[data-view="edit"] .ad4_only.is-edit, #ad4[data-view="tpl"] .ad4_only.is-tpl, #ad4[data-view="hist"] .ad4_only.is-hist { display:block; }
	#ad4[data-view="edit"] .ad4_tools.ad4_only.is-edit, #ad4[data-view="edit"] .ad4_sub.ad4_only.is-edit, #ad4[data-view="edit"] .ad4_head.ad4_only, #ad4[data-view="tpl"] .ad4_head.ad4_only { display:flex; }
	#ad4[data-view="assign"] .ad4_blist, #ad4[data-view="hist"] .ad4_blist { display:none; }

	/* 문구 */
	.ad4_note { font-size:12px; color:var(--txt-color03); }
	.ad4_item { margin:0 0 8px; padding:10px 12px; border:1px solid var(--bd-color06); }
	.ad4_item.is-pubdiff { box-shadow:inset 3px 0 0 var(--ad4-chg); }
	.ad4_item_head { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin-bottom:6px; font-size:12px; color:var(--txt-color03); }
	.ad4_item_head strong { font-size:13px; color:var(--txt-color); }
	.ad4_item_head code { font-size:11px; color:var(--txt-color10); }
	.ad4_item_head .ad4_grow { flex:1; }
	.ad4_item textarea { display:block; width:100%; min-height:36px; box-sizing:border-box; font-size:13px; line-height:1.6; resize:vertical; overflow:hidden; }
	.ad4_vars { display:flex; flex-wrap:wrap; align-items:center; gap:4px; margin-top:6px; }
	.ad4_vars > em { font-style:normal; font-size:11px; color:var(--txt-color10); }
	.ad4_vars span { padding:1px 8px; border:1px solid var(--bd-color06); border-radius:999px; font-family:Consolas, monospace; font-size:12px; color:var(--txt-color03); cursor:pointer; }
	.ad4_vars span:hover { border-color:var(--ad4-pri); color:var(--ad4-pri); }
	.ad4_was { margin:6px 0 0; padding:4px 8px; background:var(--ad4-soft); font-size:12px; color:var(--txt-color10); line-height:1.5; }
	.ad4_was del { color:var(--txt-color10); }
	.ad4_none { padding:24px 12px; border:1px dashed var(--bd-color06); text-align:center; color:var(--txt-color03); font-size:12px; }

	/* 디자인 묶음 (접을 수 있음) */
	.ad4_group { margin:0 0 8px; padding:0; border:1px solid var(--bd-color06); }
	.ad4_group.is-pubdiff { box-shadow:inset 3px 0 0 var(--ad4-chg); }
	.ad4_group > h6 { margin:0 0 8px; font-size:13px; font-weight:600; color:var(--txt-color); }
	.ad4_group_head { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin:0; padding:8px 12px; list-style:none; cursor:pointer; }
	.ad4_group_head::-webkit-details-marker { display:none; }
	summary.ad4_group_head::before { content:"▸"; color:var(--txt-color10); transition:transform .15s; }
	details.ad4_group[open] > summary.ad4_group_head::before { transform:rotate(90deg); }
	.ad4_group_head h6 { margin:0; font-size:13px; font-weight:600; color:var(--txt-color); }
	.ad4_group_head .ad4_sum { flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:11px; color:var(--txt-color10); }
	.ad4_group_head .ad4_reset { margin-left:auto; }
	div.ad4_group { padding:0 12px 12px; }
	div.ad4_group > .ad4_group_head { padding:8px 0; cursor:default; }
	.ad4_gbody { padding:0 12px 12px; }
	.ad4_props { display:grid; grid-template-columns:repeat(auto-fill, minmax(180px, 1fr)); gap:8px 12px; }
	.ad4_prop { display:flex; flex-direction:column; gap:2px; font-size:12px; color:var(--txt-color03); }
	.ad4_prop .ad4_in { display:flex; gap:4px; align-items:center; }
	.ad4_prop input[type=text], .ad4_prop input[type=number], .ad4_prop select { width:100%; height:28px; box-sizing:border-box; font-size:12px; }
	.ad4_prop input[type=color] { flex:0 0 30px; width:30px; height:28px; padding:0; border:1px solid var(--bd-color06); background:none; }
	.ad4_prop.is-changed > span:first-child { color:var(--ad4-chg); font-weight:600; }
	.ad4_prop .ad4_pubv { font-size:11px; color:var(--txt-color10); }
	.ad4_prop input.is-bad { border-color:var(--ad4-err); background:var(--ad4-err-bg); }
	.ad4_changed { color:var(--ad4-chg); font-size:11px; font-weight:600; }
	.ad4_badge { padding:0 6px; border-radius:3px; background:var(--ad4-err-bg); color:var(--ad4-err); font-size:11px; font-weight:600; line-height:18px; }
	.ad4_count { font-size:11px; color:var(--ad4-chg); }
	.ad4_count.is-none { color:var(--txt-color03); }
	.btn.is-disabled { opacity:.45; pointer-events:none; }
	.ad4_group, .ad4_item { scroll-margin:70px; transition:box-shadow .2s; }
	.ad4_group.is-sel, .ad4_item.is-sel { border-color:var(--ad4-pri); box-shadow:0 0 0 2px var(--ad4-pri-bg); }
	.ad4_group.is-flash, .ad4_item.is-flash, .ad4_head.is-flash { animation:ad4-flash 1.2s ease-out; }
	@keyframes ad4-flash { 0%, 40% { background:var(--ad4-flash); } 100% { background:transparent; } }

	/* 틀 관리 */
	.ad4_use { display:flex; align-items:center; gap:10px; margin:0 0 8px; padding:10px 12px; border:1px solid var(--bd-color06); background:var(--bg-color06); }
	.ad4_use strong { display:block; font-size:13px; }
	.ad4_use .ad4_note { margin:2px 0 0; }
	.ad4_switch { position:relative; flex:0 0 38px; width:38px; height:20px; cursor:pointer; }
	.ad4_switch input { position:absolute; opacity:0; width:100%; height:100%; margin:0; cursor:pointer; }
	.ad4_switch span { position:absolute; inset:0; border-radius:999px; background:var(--bd-color06); transition:background .15s; pointer-events:none; }
	.ad4_switch span::after { content:""; position:absolute; top:3px; left:3px; width:14px; height:14px; border-radius:50%; background:#fff; transition:left .15s; }
	.ad4_switch input:checked + span { background:var(--ad4-pri); }
	.ad4_switch input:checked + span::after { left:21px; }
	.ad4_switch input:disabled + span { opacity:.45; }
	.ad4_switch input:focus-visible + span { outline:2px solid var(--ad4-pri); outline-offset:2px; }
	.ad4_pub { margin:0 0 12px; padding:8px 12px; border:1px dashed var(--bd-color06); font-size:12px; color:var(--txt-color03); line-height:1.6; }
	.ad4_pub summary { cursor:pointer; }
	.ad4_pub ul { margin:2px 0 0 16px; } .ad4_pub li { list-style:disc; }
	.ad4_pub .is-err { color:var(--ad4-err); }
	.ad4_tpl_on { display:inline-flex; align-items:center; gap:4px; margin-bottom:8px; font-size:12px; color:var(--txt-color); }
	.ad4_code { width:100%; box-sizing:border-box; font-family:Consolas, "D2Coding", monospace; font-size:12px; line-height:1.5; white-space:pre; tab-size:2; }
	.ad4_code.is-html { min-height:240px; }
	.ad4_code.is-css { min-height:140px; }
	.ad4_slots { display:flex; flex-wrap:wrap; gap:4px; margin:4px 0 8px; }
	.ad4_slots button { padding:1px 8px; border:1px solid var(--bd-color06); border-radius:10px; background:none; color:var(--txt-color); font-size:11px; cursor:pointer; }
	.ad4_slots button:disabled { color:var(--txt-color03); cursor:not-allowed; }
	.ad4_slots .ad4_chip_title { align-self:center; min-width:48px; font-size:11px; font-weight:600; color:var(--txt-color03); }
	.ad4_tpl_msgs { margin:6px 0 0; font-size:12px; line-height:1.6; }
	.ad4_tpl_msgs li { list-style:disc; margin-left:16px; }
	.ad4_tpl_msgs .is-err { color:var(--ad4-err); }
	.ad4_tpl_msgs .is-warn { color:var(--ad4-warn); }
	.ad4_tpl_bar { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin:0 0 8px; }
	.ad4_tpl_bar select { max-width:100%; }
	.ad4_help { margin:0 0 14px; padding:8px 12px; border:1px dashed var(--bd-color06); font-size:12px; }
	.ad4_help summary { cursor:pointer; font-weight:600; color:var(--txt-color); }
	.ad4_help p { margin:6px 0 0; }
	.ad4_help code { font-size:11px; color:var(--txt-color); }

	/* 할당 */
	.ad4_flow { display:flex; flex-wrap:wrap; align-items:center; gap:4px 6px; margin:0 0 10px; font-size:12px; color:var(--txt-color03); }
	.ad4_flow span { padding:2px 8px; background:var(--ad4-soft); border:1px solid var(--bd-color06); }
	.ad4_flow b { color:var(--ad4-pri); margin-right:3px; }
	.ad4_assign { width:100%; margin:0 0 4px; border-collapse:collapse; font-size:13px; }
	.ad4_assign th, .ad4_assign td { padding:5px 6px; border-bottom:1px solid var(--bd-color06); text-align:left; vertical-align:middle; }
	.ad4_assign th { font-size:12px; font-weight:600; color:var(--txt-color03); }
	.ad4_assign tr.is-set td { background:var(--ad4-pri-bg); }
	.ad4_assign td code { font-size:10px; color:var(--txt-color03); }
	.ad4_assign select { width:100%; height:28px; font-size:12px; }
	.ad4_cond { display:flex; flex-wrap:wrap; align-items:center; gap:4px; padding:6px 0; border-bottom:1px dashed var(--bd-color06); font-size:12px; }
	.ad4_cond select, .ad4_cond input { height:28px; font-size:12px; }
	.ad4_cond input { width:110px; }

	/* 게시 전 확인 · 이력 비교 창 */
	.ad4_dlg { position:fixed; inset:0; z-index:1000; display:flex; align-items:center; justify-content:center; padding:16px; background:rgba(0,0,0,.45); }
	.ad4_dlg[hidden] { display:none; }
	.ad4_dlg_box { display:flex; flex-direction:column; width:min(780px, 100%); max-height:calc(100vh - 32px); border:1px solid var(--bd-color06); background:var(--bg-color06); box-shadow:0 12px 40px rgba(0,0,0,.25); }
	.ad4_dlg_box > header { padding:14px 18px 10px; border-bottom:1px solid var(--bd-color06); }
	.ad4_dlg_box > header h5 { margin:0; font-size:16px; font-weight:700; }
	.ad4_dlg_box > header p { margin:4px 0 0; font-size:12px; color:var(--txt-color03); }
	.ad4_dlg_body { overflow:auto; padding:10px 18px; }
	.ad4_dlg_box > footer { display:flex; flex-wrap:wrap; align-items:center; gap:8px; padding:10px 18px; border-top:1px solid var(--bd-color06); }
	.ad4_dlg_box > footer input { flex:1; min-width:200px; }
	.ad4_dblock { margin:0 0 12px; }
	.ad4_dblock h6 { margin:0 0 4px; font-size:13px; font-weight:700; }
	.ad4_drow { display:grid; grid-template-columns:200px 1fr; gap:8px; padding:5px 0; border-bottom:1px solid var(--bd-color06); font-size:12px; line-height:1.5; }
	.ad4_drow > span:first-child { color:var(--txt-color03); }
	.ad4_drow del { padding:0 3px; background:var(--ad4-err-bg); color:var(--ad4-err); white-space:pre-wrap; word-break:break-all; }
	.ad4_drow ins { padding:0 3px; background:var(--ad4-ok-bg); color:var(--ad4-ok); text-decoration:none; white-space:pre-wrap; word-break:break-all; }
	.ad4_dot { display:inline-block; width:10px; height:10px; margin-right:3px; border:1px solid var(--bd-color06); vertical-align:-1px; }

	@media (max-width: 1280px) {
		.ad4_wrap { flex-direction:column; gap:14px; }
		.ad4_prev { position:static; width:100%; }
		.ad4_split { display:none; }
	}
	@media (max-width: 760px) {
		.ad4_edit { flex-direction:column; }
		.ad4_blist { position:static; flex-basis:auto; width:100%; max-height:220px; }
		.ad4_drow { grid-template-columns:1fr; }
	}
</style>
</head>

<div class="sub_contents_wrap">
	<div class="sub_contents_area">
		<h4 class="sub_tit_h4"></h4>
		<div class="noti_area mt0">
			<p class="noti_text"><em>AI 상담5 답변의 문구와 디자인을 고칩니다. 임시 저장 → 미리보기로 확인 → 게시 순서로 반영되며, 게시하면 1분 안에 모든 서버에 적용됩니다.</em></p>
			<p class="noti_text"><em>값을 비우면 기본 모양을 씁니다.</em></p>
		</div>

		<div id="ad4" class="mt10" data-view="edit"
			data-data="<c:url value='/admmgr/ai5/designData.do'/>"
			data-save="<c:url value='/admmgr/ai5/designSave.do'/>"
			data-publish="<c:url value='/admmgr/ai5/designPublish.do'/>"
			data-load="<c:url value='/admmgr/ai5/designLoad.do'/>"
			data-css="<c:url value='/admmgr/ai5/designCss.do'/>"
			data-import="<c:url value='/admmgr/ai5/designImport.do'/>">
			<div class="ad4_bar">
				<ol class="ad4_steps" id="ad4Steps" aria-label="진행 단계"></ol>
				<div class="ad4_state" id="ad4State">불러오는 중…</div>
				<input type="text" id="ad4Memo" class="form_text wd320" maxlength="500" placeholder="메모 (무엇을 바꿨는지, 게시 이력에 남습니다)"/>
				<a href="#" class="btn secondary sm" id="ad4Save" title="Ctrl+S">임시 저장<span class="ad4_kbd">Ctrl+S</span></a>
				<a href="#" class="btn secondary sm" id="ad4Preview" title="편집 중인 값으로 미리보기를 다시 그립니다 (평소에는 자동으로 다시 그립니다)">미리보기 새로 그리기</a>
				<a href="#" class="btn primary sm" id="ad4Publish">게시…</a>
			</div>
			<div id="ad4Msg"></div>

			<div class="ad4_mtabs" role="tablist">
				<button type="button" class="is-on" data-view="edit">답변 편집<span class="ad4_num" id="ad4NumEdit"></span></button>
				<button type="button" data-view="tpl">틀 관리<span class="ad4_num" id="ad4NumTpl"></span></button>
				<button type="button" data-view="assign">할당<span class="ad4_num" id="ad4NumAssign"></span></button>
				<button type="button" data-view="hist">이력</button>
			</div>

			<div class="ad4_wrap">
				<div class="ad4_edit">
					<nav class="ad4_blist" id="ad4Blocks" aria-label="블록"></nav>
					<div class="ad4_body">
						<div class="ad4_only is-tpl">
							<div class="ad4_use">
								<label class="ad4_switch" title="블록 틀로 답변을 그립니다: [틀 관리]에서 만든 틀, 하나도 없으면 publisher 폴더(pt-ai/gwtpax5/publisher) 파일 틀. 틀이 없는 블록은 지금 디자인으로 그립니다">
									<input type="checkbox" id="ad4Publisher" aria-label="틀 사용"/><span></span>
								</label>
								<div>
									<strong id="ad4UseText">틀 사용</strong>
									<p class="ad4_note">켜면 틀이 있는 블록은 틀로 그립니다 (그 블록의 디자인 값은 걸리지 않습니다). 틀이 없는 블록은 지금 디자인으로 그립니다.</p>
								</div>
							</div>
							<div class="ad4_pub" id="ad4Pub"></div>
						</div>
						<div class="ad4_head ad4_only" id="ad4Head"></div>
						<div class="ad4_sub ad4_only is-edit" role="tablist">
							<button type="button" class="is-on" data-tab="text">문구</button>
							<button type="button" data-tab="style">디자인</button>
						</div>
						<div class="ad4_tools ad4_only is-edit">
							<input type="search" id="ad4Q" class="form_text" placeholder="항목 찾기 (이름·키·내용)" aria-label="항목 찾기"/>
							<label class="ad4_chk" title="기본값이나 게시본과 다른 항목만 보입니다"><input type="checkbox" id="ad4Only"/> 바뀐 것만</label>
							<a href="#" class="btn secondary xsm" id="ad4Fold">모두 접기</a>
						</div>
						<div id="ad4Panel"></div>
						<div class="ad4_only is-hist">
							<div class="n_table_sty01 n_list01">
								<table cellpadding="0" cellspacing="0" border="0" class="tbl_ty1" summary="AI 상담5 답변 디자인 게시 이력">
									<colgroup><col width="9%"/><col width="17%"/><col width="12%"/><col width="12%"/><col width="*"/><col width="16%"/></colgroup>
									<thead>
										<tr><th class="center">상태</th><th class="center">게시 일시</th><th class="center">버전</th><th class="center">게시자</th><th>메모</th><th class="center">비교 · 불러오기</th></tr>
									</thead>
									<tbody id="ad4History"><tr><td colspan="6" class="center">불러오는 중…</td></tr></tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div class="ad4_split" id="ad4Split" role="separator" aria-orientation="vertical" aria-label="편집·미리보기 폭 조절" tabindex="0" title="드래그해서 폭 조절 (더블클릭: 기본, 키보드 ←/→)"><span class="ad4_split_grip"></span></div>
				<div class="ad4_prev">
					<div class="ad4_ptool">
						<div class="ad4_seg" id="ad4Device" role="group" aria-label="미리보기 폭">
							<button type="button" data-w="mobile">모바일</button>
							<button type="button" data-w="tablet">태블릿</button>
							<button type="button" data-w="pc" class="is-on">PC</button>
						</div>
						<label class="ad4_chk" title="게시본과 다른 문구·디자인·틀이 들어간 자리를 점선으로 표시합니다"><input type="checkbox" id="ad4Marks" checked/> 바뀐 곳 강조</label>
					</div>
					<div class="ad4_pstage">
						<iframe id="ad4Frame" title="답변 디자인 미리보기" src="<c:url value='/gwtpax/ai5-design-preview.do'/>"></iframe>
					</div>
				</div>
			</div>

			<div class="ad4_dlg" id="ad4Dlg" hidden role="dialog" aria-modal="true" aria-labelledby="ad4DlgTitle">
				<div class="ad4_dlg_box">
					<header><h5 id="ad4DlgTitle"></h5><p id="ad4DlgSub"></p></header>
					<div class="ad4_dlg_body" id="ad4DlgBody"></div>
					<footer>
						<input type="text" id="ad4DlgMemo" class="form_text" maxlength="500" placeholder="메모 (선택, 게시 이력에 남습니다)"/>
						<a href="#" class="btn secondary sm" id="ad4DlgCancel">닫기</a>
						<a href="#" class="btn primary sm" id="ad4DlgOk">게시</a>
					</footer>
				</div>
			</div>
		</div>
	</div>
</div>
<script src="<c:url value='/pt-ai/gwtpax5/js/design-admin.js'/>"></script>
