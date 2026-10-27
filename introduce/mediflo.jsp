<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>메디링크 강원 제품소개서 — Midnight Signal</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<script src="deck_stage.js"></script>
<style>
:root{--bg:#07122B;--panel:#0E1D40;--panel2:#13254F;--line:rgba(160,190,255,.16);--ink:#F2F5FB;--sub:#93A3C4;--acc:#4FD1FF;--alert:#FF5D4F;}
html,body{margin:0;background:#000}
deck-stage section{background:var(--bg);color:var(--ink);font-family:'Noto Sans KR',sans-serif;letter-spacing:-0.02em;position:relative;overflow:hidden}
.mono{font-family:'JetBrains Mono','Noto Sans KR',monospace;letter-spacing:0}
.abs{position:absolute}
.hdr{position:absolute;left:120px;right:120px;top:72px;height:44px;display:flex;justify-content:space-between;align-items:center}
.hdr .l{display:flex;align-items:center;gap:18px;font-size:24px;font-weight:700;white-space:nowrap}
.hdr .l>*{flex:none}
.badge{border:1px solid var(--acc);color:var(--acc);padding:6px 14px;font-size:20px}
.hdr .en{color:var(--sub);font-weight:400;font-size:20px;letter-spacing:.08em}
.hdr img{width:160px;height:auto;display:block}
.ttl{position:absolute;left:120px;top:190px;font-size:68px;font-weight:900;line-height:1.24;letter-spacing:-0.045em;margin:0}
.ttl em{font-style:normal;color:var(--acc)}
.lead{font-size:28px;color:var(--sub);line-height:1.6;margin:0}
.grid{display:grid;gap:2px;background:var(--line)}
.card{background:var(--panel);padding:44px 40px;display:flex;flex-direction:column}
.num{font-size:22px;color:var(--acc)}
.h3{font-size:36px;font-weight:700;line-height:1.3;margin:0}
.p{font-size:24px;color:var(--sub);line-height:1.6;margin:14px 0 0}
.tag{font-size:20px;color:var(--acc);border-top:1px solid var(--line);padding-top:18px;margin-top:auto;line-height:1.5}
.pg{position:absolute;right:120px;bottom:56px;font-size:20px;color:var(--sub)}
.foot{position:absolute;left:120px;bottom:56px;font-size:20px;color:var(--sub)}
.chip{display:inline-block;border:1px solid var(--line);padding:8px 16px;font-size:22px;color:var(--ink);margin:0 8px 10px 0;background:var(--panel2)}
.photo{background-size:cover;background-position:center}
</style>
</head>
<body>
<deck-stage width="1920" height="1080">

<!-- 01 Cover -->
<section data-label="01 표지">
  <img class="abs" src="assets/cover-b.png" style="left:0;top:0;width:1920px;height:1080px">
  <img class="abs" src="assets/logo.svg" style="right:120px;top:96px;width:230px">
  <div class="abs" style="right:120px;top:350px;text-align:right">
    <div class="mono" style="font-size:24px;color:var(--acc);letter-spacing:.1em">AI MEDICAL PORTAL FOR GANGWON</div>
    <div style="font-size:124px;font-weight:900;line-height:1.1;margin-top:36px;letter-spacing:-0.045em">메디링크 강원</div>
    <div style="font-size:124px;font-weight:300;line-height:1.1;letter-spacing:-0.045em">제품소개서</div>
    <div style="font-size:34px;color:var(--sub);margin-top:44px">강원도민의 건강, 묻고 잇고 찾는 AI 의료 포털</div>
  </div>
  <div class="abs" style="left:120px;right:120px;bottom:80px;display:flex;justify-content:space-between;font-size:22px;color:var(--sub);border-top:1px solid var(--line);padding-top:24px">
    <span>강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업 공급기업 서비스</span>
  </div>
</section>

<!-- 02 Intro -->
<section data-label="02 서비스 소개">
  <div class="abs photo" style="left:0;top:0;width:760px;height:1080px;background-image:url(assets/senior-phone.jpeg);background-position:center 30%"></div>
  <div class="hdr" style="left:880px"><div class="l"><span class="badge mono">01</span><span>서비스 소개</span><span class="en">ABOUT</span></div><img src="assets/logo.svg"></div>
  <div class="abs" style="left:880px;top:250px;width:920px">
    <div style="font-size:30px;font-weight:500;color:var(--sub)">강원도민의 건강, 묻고 잇고 찾는</div>
    <div style="font-size:96px;font-weight:900;letter-spacing:-0.045em;line-height:1.15;margin-top:16px">메디링크 <span style="color:var(--acc)">강원</span></div>
    <div style="font-size:30px;font-weight:700;margin-top:64px;color:var(--acc)">자연어 질문에서 가까운 의료기관까지</div>
    <div style="font-size:40px;font-weight:500;line-height:1.55;margin-top:24px">일상 언어로 묻고,<br>공공데이터 기반 답변을 받고,<br>가까운 의료기관으로 연결됩니다.</div>
  </div>
  <div class="abs" style="left:880px;right:120px;bottom:80px;border-top:1px solid var(--line);padding-top:24px;display:flex;justify-content:space-between;align-items:center">
    <span style="font-size:22px;color:var(--sub)">강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업 공급기업 서비스</span>
    <span class="mono" style="font-size:20px;color:var(--sub)">02</span>
  </div>
</section>

<!-- 03 Problem -->
<section data-label="03 해결할 문제">
  <div class="hdr"><div class="l"><span class="badge mono">02</span><span>해결할 문제</span><span class="en">PROBLEM</span></div><img src="assets/logo.svg"></div>
  <h1 class="ttl">의료 정보는 많지만<br><em>도민에게는 찾기 어렵다</em></h1>
  <div class="abs grid" style="left:120px;right:120px;top:500px;bottom:120px;grid-template-columns:repeat(4,1fr)">
    <div class="card"><div class="num mono">/01</div><div style="margin-top:auto"><p class="h3">흩어진 정보</p><p class="p">병원·약국·응급실 정보가 기관별로 흩어져 있어 필요한 정보를 따로 찾아야 합니다.</p></div></div>
    <div class="card"><div class="num mono">/02</div><div style="margin-top:auto"><p class="h3">부족한 판단 근거</p><p class="p">증상에서 진료과, 병원 선택까지 이어지는 과정에 판단 근거가 부족합니다.</p></div></div>
    <div class="card"><div class="num mono">/03</div><div style="margin-top:auto"><p class="h3">지역마다 다른<br>이동 여건</p><p class="p">산간·원거리 지역에서는 이동 거리와 응급 대응 여건이 중요한 변수입니다.</p></div></div>
    <div class="card"><div class="num mono">/04</div><div style="margin-top:auto"><p class="h3">급할수록 중요한<br>최신성</p><p class="p">지금 이용할 수 있는 곳을 판단하려면 정확한 최신 정보가 필요합니다.</p></div></div>
  </div>
  <div class="pg mono">03</div>
</section>

<!-- 04 Flow -->
<section data-label="04 서비스 흐름">
  <div class="hdr"><div class="l"><span class="badge mono">03</span><span>서비스 흐름</span><span class="en">QUESTION → EVIDENCE → ACTION</span></div><img src="assets/logo.svg"></div>
  <h1 class="ttl">질문 한 번으로<br><em>다음 행동까지</em> 안내합니다</h1>
  <div class="abs grid" style="left:120px;width:1220px;top:500px;bottom:120px;grid-template-columns:repeat(3,1fr)">
    <div class="card"><div class="mono" style="font-size:64px;color:var(--acc);line-height:1">01</div><p class="h3" style="margin-top:40px">자연어로 질문</p><p class="p">병원, 질병, 응급 상황을 일상 언어로 묻습니다.</p><div class="tag">궁금한 내용을 그대로 입력</div></div>
    <div class="card"><div class="mono" style="font-size:64px;color:var(--acc);line-height:1">02</div><p class="h3" style="margin-top:40px">근거로 답변</p><p class="p">AI가 공공데이터를 근거로 필요한 정보를 안내합니다.</p><div class="tag">답변의 근거 확인</div></div>
    <div class="card" style="background:var(--acc);color:var(--bg)"><div class="mono" style="font-size:64px;line-height:1">03</div><p class="h3" style="margin-top:40px">다음 행동 연결</p><p class="p" style="color:var(--bg)">인근 의료기관과 전화, 길찾기, 응급 연결을 제시합니다.</p><div class="tag" style="color:var(--bg);border-color:rgba(7,18,43,.25)">정보 확인에서 이용까지</div></div>
  </div>
  <div class="abs photo" style="right:120px;width:420px;top:500px;bottom:120px;background-image:url(assets/phone-app.jpeg)"></div>
  <div class="pg mono" style="right:auto;left:1380px">04</div>
</section>

<!-- 05 Search -->
<section data-label="05 탐색 방식">
  <div class="hdr"><div class="l"><span class="badge mono">04</span><span>탐색 방식</span><span class="en">SYMPTOM · REGION · DEPARTMENT</span></div><img src="assets/logo.svg"></div>
  <h1 class="ttl">세 가지 탐색 방식으로<br><em>원하는 정보에 닿는다</em></h1>
  <div class="abs grid" style="left:120px;right:120px;top:500px;bottom:120px;grid-template-columns:repeat(3,1fr)">
    <div class="card">
      <div class="num mono">SYMPTOM</div>
      <p class="h3" style="margin-top:28px">증상 검색</p>
      <p class="p">28개 건강 주제를 바탕으로 필요한 건강 정보를 찾습니다.</p>
      <div style="margin-top:auto"><span class="chip">건강문제</span><span class="chip">치료법</span><span class="chip">검사법</span><span class="chip">생활관리</span></div>
    </div>
    <div class="card">
      <div class="num mono">REGION</div>
      <p class="h3" style="margin-top:28px">지역 검색</p>
      <p class="p">강원 시군을 기준으로 생활권에 맞는 정보를 탐색합니다.</p>
      <div style="margin-top:auto"><span class="chip">춘천</span><span class="chip">원주</span><span class="chip">강릉</span><span class="chip">홍천</span><span class="chip">평창</span><span class="chip">양구</span></div>
    </div>
    <div class="card">
      <div class="num mono">DEPARTMENT</div>
      <p class="h3" style="margin-top:28px">진료과 검색</p>
      <p class="p">필요한 진료과를 기준으로 의료기관을 찾습니다.</p>
      <div style="margin-top:auto"><span class="chip">내과</span><span class="chip">소아청소년과</span><span class="chip">피부과</span><span class="chip">치과</span><span class="chip">한의원</span></div>
    </div>
  </div>
  <div class="pg mono">05</div>
</section>

<!-- 06 Integrated -->
<section data-label="06 통합 정보">
  <div class="hdr"><div class="l"><span class="badge mono">05</span><span>통합 정보</span><span class="en">CORE FEATURES</span></div><img src="assets/logo.svg"></div>
  <div class="abs" style="left:120px;top:190px;width:640px">
    <h1 style="font-size:68px;font-weight:900;line-height:1.24;letter-spacing:-0.045em;margin:0">병·의원, 질병정보,<br>약국을<br><span style="color:var(--acc)">한곳에서 찾는다</span></h1>
    <p class="lead" style="margin-top:40px">흩어진 의료 탐색의 기본 기능을<br>하나의 포털로 모았습니다.</p>
  </div>
  <div class="abs grid" style="left:880px;right:120px;top:190px;grid-template-columns:1fr">
    <div class="card" style="flex-direction:row;align-items:center;padding:52px 48px;gap:48px"><div class="mono" style="font-size:22px;color:var(--acc);width:60px">A</div><div style="flex:1"><p class="h3" style="font-size:40px">병·의원 찾기</p><p class="p">지역·진료과별로 의료기관을 탐색합니다.</p></div></div>
    <div class="card" style="flex-direction:row;align-items:center;padding:52px 48px;gap:48px"><div class="mono" style="font-size:22px;color:var(--acc);width:60px">B</div><div style="flex:1"><p class="h3" style="font-size:40px">질병 정보</p><p class="p">증상별 건강 정보를 확인합니다.</p></div></div>
    <div class="card" style="flex-direction:row;align-items:center;padding:52px 48px;gap:48px"><div class="mono" style="font-size:22px;color:var(--acc);width:60px">C</div><div style="flex:1"><p class="h3" style="font-size:40px">약국 찾기</p><p class="p">가까운 약국을 확인합니다.</p></div></div>
  </div>
  <div class="abs" style="left:880px;right:120px;bottom:120px;border:1px solid var(--acc);padding:26px 32px;font-size:26px;display:flex;gap:20px;align-items:center">
    <span class="mono" style="color:var(--acc);font-size:20px">SOURCE</span><span>모든 결과에 출처와 갱신 시각을 표기합니다.</span>
  </div>
  <div class="pg mono" style="right:auto;left:120px">06</div>
</section>

<!-- 07 ER LIVE -->
<section data-label="07 응급실 LIVE">
  <div class="hdr"><div class="l"><span class="badge mono">06</span><span>응급실 LIVE</span><span class="en">REAL-TIME ER</span></div><img src="assets/logo.svg"></div>
  <div class="abs" style="left:120px;top:190px;width:780px">
    <div style="display:inline-flex;align-items:center;gap:12px;font-size:22px;font-weight:700;color:var(--alert);border:1px solid var(--alert);padding:8px 16px"><span style="width:12px;height:12px;border-radius:6px;background:var(--alert);display:inline-block"></span>LIVE</div>
    <h1 style="font-size:68px;font-weight:900;line-height:1.22;margin:32px 0 0;letter-spacing:-0.045em">지금 갈 수 있는 곳을<br><span style="color:var(--acc)">실시간으로</span> 확인한다</h1>
    <p class="lead" style="margin-top:36px">국립중앙의료원 공공데이터 실시간 연계로<br>응급실 병상 가용 현황을 제공합니다.</p>
    <div class="mono" style="font-size:20px;color:var(--sub);margin-top:56px;letter-spacing:.08em">빠른 전화 연결</div>
    <div class="grid" style="grid-template-columns:repeat(3,1fr);margin-top:16px">
      <div class="card" style="padding:28px;background:var(--alert)"><div style="font-size:44px;font-weight:900">119</div><div style="font-size:20px;margin-top:6px">화재·구조·구급</div></div>
      <div class="card" style="padding:28px"><div style="font-size:44px;font-weight:900">1339</div><div style="font-size:20px;color:var(--sub);margin-top:6px">응급의료 상담</div></div>
      <div class="card" style="padding:28px"><div style="font-size:40px;font-weight:900;white-space:nowrap">1577-1000</div><div style="font-size:20px;color:var(--sub);margin-top:6px">보건복지상담</div></div>
    </div>
  </div>
  <div class="abs" style="right:120px;top:190px;width:820px;bottom:120px;background:var(--panel);border:1px solid var(--line);padding:48px;box-sizing:border-box;display:flex;flex-direction:column">
    <div class="mono" style="display:flex;justify-content:space-between;font-size:20px;color:var(--sub)"><span>ER BED STATUS · 예시 화면</span><span>갱신 14:32</span></div>
    <div class="abs photo" style="left:48px;right:48px;top:100px;height:250px;background-image:url(assets/ambulance.jpeg);opacity:.85"></div>
    <div style="margin-top:300px"></div>
    <div style="display:flex;align-items:center;border-top:1px solid var(--line);padding:22px 0"><div style="flex:1"><div style="font-size:30px;font-weight:700">강원대학교병원</div><div style="font-size:20px;color:var(--sub)">춘천</div></div><div style="font-size:56px;font-weight:900;color:var(--acc)">7</div><div style="font-size:20px;color:var(--sub);margin-left:12px;width:50px">병상</div></div>
    <div style="display:flex;align-items:center;border-top:1px solid var(--line);padding:22px 0"><div style="flex:1"><div style="font-size:30px;font-weight:700">원주세브란스기독병원</div><div style="font-size:20px;color:var(--sub)">원주</div></div><div style="font-size:56px;font-weight:900;color:var(--acc)">4</div><div style="font-size:20px;color:var(--sub);margin-left:12px;width:50px">병상</div></div>
    <div style="display:flex;align-items:center;border-top:1px solid var(--line);padding:22px 0"><div style="flex:1"><div style="font-size:30px;font-weight:700">강릉아산병원</div><div style="font-size:20px;color:var(--sub)">강릉</div></div><div style="font-size:56px;font-weight:900;color:var(--alert)">2</div><div style="font-size:20px;color:var(--sub);margin-left:12px;width:50px">병상</div></div>
    <div style="margin-top:30px;font-size:20px;color:var(--sub);line-height:1.5">병상 현황은 수시로 변동됩니다. 정보를 확인하고 이용 전 문의가 필요합니다.</div>
  </div>
  <div class="pg mono" style="right:auto;left:120px">07</div>
</section>

<!-- 08 AI Assistant -->
<section data-label="08 AI 상담 도우미">
  <div class="hdr"><div class="l"><span class="badge mono">07</span><span>AI 상담 도우미</span><span class="en">CONVERSATIONAL GUIDE</span></div><img src="assets/logo.svg"></div>
  <h1 class="ttl">AI 상담 도우미가<br><em>질문에서 행동까지</em> 잇는다</h1>
  <div class="abs" style="left:120px;width:1100px;top:500px;bottom:120px;display:flex;flex-direction:column;gap:2px;background:var(--line)">
    <div class="card" style="flex:1;flex-direction:row;gap:40px;align-items:center;padding:32px 40px"><div class="mono" style="font-size:22px;color:var(--acc);width:120px">01 질문</div><div style="flex:1"><div style="font-size:30px;font-weight:700">질문을 받습니다</div><div style="font-size:26px;margin-top:10px;color:var(--acc)">“우리 지역에서 지금 진료 중인 의원을 찾고 싶어요.”</div></div></div>
    <div class="card" style="flex:1;flex-direction:row;gap:40px;align-items:center;padding:32px 40px"><div class="mono" style="font-size:22px;color:var(--acc);width:120px">02 안내</div><div style="flex:1"><div style="font-size:30px;font-weight:700">필요한 정보를 안내합니다</div><div style="font-size:24px;margin-top:10px;color:var(--sub)">지역별 진료 중인 의원 확인으로 이어지도록 대화형으로 안내합니다.</div></div></div>
    <div class="card" style="flex:1;flex-direction:row;gap:40px;align-items:center;padding:32px 40px"><div class="mono" style="font-size:22px;color:var(--acc);width:120px">03 행동</div><div style="flex:1"><div style="font-size:30px;font-weight:700">후속 행동을 제안합니다</div><div style="font-size:24px;margin-top:10px;color:var(--sub)">기관 정보를 확인한 뒤 전화나 길찾기로 이어집니다.</div></div></div>
  </div>
  <div class="abs" style="right:120px;width:540px;top:500px;bottom:120px;background:var(--acc);color:var(--bg);padding:48px;box-sizing:border-box;display:flex;flex-direction:column">
    <div class="mono" style="font-size:20px;letter-spacing:.08em">판단은 전문가 몫</div>
    <div style="margin-top:auto;font-size:84px;font-weight:900;line-height:1.1;letter-spacing:-0.045em">AI는<br>안내자</div>
    <div style="font-size:24px;margin-top:24px;line-height:1.5;font-weight:500">진단이 아닌 안내에<br>역할을 한정합니다.</div>
  </div>
  <div class="pg mono">08</div>
</section>

<!-- 09 Trust -->
<section data-label="09 신뢰의 기반">
  <div class="hdr"><div class="l"><span class="badge mono">08</span><span>신뢰의 기반</span><span class="en">DESIGN PRINCIPLES</span></div><img src="assets/logo.svg"></div>
  <div class="abs" style="left:120px;top:190px;width:600px">
    <h1 style="font-size:68px;font-weight:900;line-height:1.24;letter-spacing:-0.045em;margin:0">네 가지 강점이<br><span style="color:var(--acc)">신뢰를 만든다</span></h1>
    <p class="lead" style="margin-top:40px">메디링크 강원의<br>서비스 설계 원칙</p>
  </div>
  <div class="abs grid" style="left:820px;right:120px;top:190px;bottom:120px;grid-template-columns:1fr 1fr">
    <div class="card"><div class="num mono">/01 EVIDENCE</div><div style="margin-top:auto"><p class="h3">근거 중심</p><p class="p">국가 공공데이터를 기반으로 출처·갱신 시각을 공개합니다.</p></div></div>
    <div class="card"><div class="num mono">/02 ACTION</div><div style="margin-top:auto"><p class="h3">행동 중심</p><p class="p">정보 확인에서 전화·길안내·응급 연결까지 다음 행동으로 이어집니다.</p></div></div>
    <div class="card"><div class="num mono">/03 LOCAL</div><div style="margin-top:auto"><p class="h3">지역 맥락</p><p class="p">시군 생활권, 이동 거리, 지역 응급 여건을 우선합니다.</p></div></div>
    <div class="card"><div class="num mono">/04 RESPECT</div><div style="margin-top:auto"><p class="h3">전문 판단 존중</p><p class="p">진단이 아닌 안내를 제공합니다. 의료적 판단은 전문가의 영역입니다.</p></div></div>
  </div>
  <div class="pg mono" style="right:auto;left:120px">09</div>
</section>

<!-- 10 Outcome -->
<section data-label="10 기대효과와 확장">
  <div class="hdr"><div class="l"><span class="badge mono">09</span><span>기대효과와 확장</span><span class="en">OUTCOME</span></div><img src="assets/logo.svg"></div>
  <h1 class="ttl">실증으로 확인할 가치<br><em>도민 편익과 사업 확장성</em></h1>
  <div class="abs grid" style="left:120px;right:120px;top:500px;height:300px;grid-template-columns:1fr 1fr">
    <div class="card"><div class="num mono">BENEFIT</div><p class="h3" style="margin-top:24px">도민 편익</p><p class="p" style="font-size:28px;color:var(--ink)">의료 접근성 향상과 응급 대응 시간 단축 기대</p><div style="margin-top:auto;font-size:20px;color:var(--sub)">* 기대효과이며, 실증 수치는 추후 보완합니다.</div></div>
    <div class="card"><div class="num mono">SCALE</div><p class="h3" style="margin-top:24px">사업 확장성</p><p class="p" style="font-size:28px;color:var(--ink)">바이오·헬스케어 AX 실증 모델로<br>타 시군·기관 및 병원 확장 가능</p></div>
  </div>
  <div class="abs" style="left:120px;right:120px;bottom:120px;height:140px;background:var(--acc);color:var(--bg);display:flex;align-items:center;justify-content:space-between;padding:0 56px;box-sizing:border-box">
    <div style="display:flex;align-items:baseline;gap:32px"><span class="mono" style="font-size:22px;letter-spacing:.08em">CONTACT</span><span style="font-size:40px;font-weight:900">(주)센텀인터넷</span></div>
    <span style="font-size:48px;font-weight:900;letter-spacing:0">031-261-7093</span>
  </div>
  <div class="pg mono">10</div>
</section>

</deck-stage>
</body>
</html>
