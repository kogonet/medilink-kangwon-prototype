<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**************************************************
 * @desc    : 대시보드
 **************************************************/
%>
<fmt:formatDate var="nowDate" value="<%=new java.util.Date()%>" pattern="yyyyMMdd"/>
<head>
	<link rel="stylesheet" type="text/css" href="<c:url value='/common/admmgr/css/dashboard.css'/>"/>
	<script type="text/javascript">
	$(document).ready(function(){
		var date = new Date();
		
		var year = date.getFullYear();
		var month = String(date.getMonth() + 1).padStart(2, "0");
		var day = String(date.getDate()).padStart(2, "0");
		
		var thisMonth = month.toString().padStart(2, "0");
		var lastMonth = (month - 1).toString().padStart(2, "0");
		
		var formattedDate = year + "-" + month + "-" + day;
		
		$(".memberWith").text((lastMonth == "00" ? "12" : lastMonth) + "월 대비 " + thisMonth + "월");
		
		var CONN_MONTH_JSON = $.parseJSON( '${ CONN_MONTH_JSON }' );
		setTopData( "connUD", "connWith", "hc_mntr3", "#cb2369", CONN_MONTH_JSON );
		
		setPieData( "topMenuCnt", "hc_mntr4", "인기 컨텐츠 TOP.5", 30 );
	});
	
	function setTopData(udId, withId, graphId, graphColor, json) {

		// 2개월치 데이터가 축적되면 진행
		if (json.length > 1) {

			var bfMonth = String(json[json.length - 2].YYYYMM);
			var currMonth = String(json[json.length - 1].YYYYMM);
			$("#" + withId).text(bfMonth.substr(-2) + "월 대비 " + currMonth.substr(-2) + "월");

			var bfCnt = Number(json[json.length - 2].CNT);
			var currCnt = Number(json[json.length - 1].CNT);
			if (bfCnt > currCnt) {
				$("#" + udId).addClass("down");
				$("#" + udId).html("<b>▼</b> " + Math.abs(Math.floor((currCnt - bfCnt) / bfCnt * 100)) + "%");
			} else if (bfMonth == currMonth) {

			} else {
				$("#" + udId).addClass("up");
				$("#" + udId).html("<b>▲</b> " + Math.floor((currCnt - bfCnt) / bfCnt * 100) + "%");
			}

			// 그래프
			Highcharts.chart(graphId, {
				colors: [graphColor],
				credits: { enabled: false },
				chart: { type: 'area' },
				title: { text: null },
				accessibility: {
					announceNewData: {
						enabled: false
					}
				},
				xAxis: {
					type: 'category'
				},
				yAxis: {
					title: {
						text: null
					}
				},
				legend: {
					enabled: false
				},
				plotOptions: {
					series: {
						borderWidth: 0,
						dataLabels: {
							enabled: false,
							format: '{point.y:.1f}%'
						}
					}
				},
				tooltip: {
					headerFormat: '',
					pointFormat: '<span style="color:{point.color}; font-size:11px">{point.name}</span>:<strong>{point.y}명</strong>'
				},
				series: [{
					data: $(json).map(function () {
						return { "name": String(this.YYYYMM).substr(-2) + "월", "y": Number(this.CNT) };
					}).get()
				}]
			});

		} else {

			$("#" + graphId).html("<div style='text-align: center; margin: 33px 8px 0 0'>최소 2개월치 데이터가 축적되어야<br/>그래프 표시가 가능합니다.</div>");

		}

	}
	
	function setPieData(sqlId, eleId, seriesNm, day) {

		setTimeout(function () {
			$.ajax({
				url: "/admmgr/main/dashboardChartProc.do",
				type: "POST",
				data: { "day": day, "sqlId": sqlId },
				success: function (data) {
					
					$("#" + eleId).empty();
					
					var json = $.parseJSON(data);
					var graphArr = [];
					var totCnt = 0;

					// 버튼 유효성
					$("#" + eleId + "_FavBtn li").removeClass("on");
					$("#" + eleId + "_FavBtn" + day).addClass("on");
					
					for (var i = 0; i < json.length && i < 5; i++) {
						graphArr.push({
							name: json[i].TXT,
							y: Number(json[i].CNT),
							color: ['#ec4188', '#2031ac', '#20cfd4', '#158be9', '#7143bf'][i]
						});
						totCnt += Number(json[i].CNT);
					}

					Highcharts.chart(eleId, {
						colors: ['#ec4188', '#2031ac', '#20cfd4', '#158be9', '#7143bf'],
						credits: { enabled: false },
						chart: {
							plotBackgroundColor: null,
							plotBorderWidth: 0,
							plotShadow: false,
							margin: [20, 20, 0, 0],
							spacing: [20, 0, 0, 0]
						},
						title: {
							text: seriesNm,
							verticalAlign: 'top',
							align: 'center'
						},
						tooltip: {
							headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
							pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span><b>{point.y:f}명</b><br/><br/>'
						},
						plotOptions: {
							pie: {
								allowPointSelect: false,
								cursor: 'pointer',
								dataLabels: {
									enabled: true,
									distance: -30,
									format: '{point.y:.f}%',
									style: {
										color: 'white',
										textOutline: '1px contrast'
									}
								},
								showInLegend: true,
								startAngle: 0,
								endAngle: 0
							}
						},
						legend: {
							layout: 'vertical',
							align: 'right',
							verticalAlign: 'bottom',
							itemMarginBottom: 0,
							symbol: 'square',
							itemStyle: {
								color: '#9498a1',
								fontWeight: 'normal'
							}
						},
						series: [{
							type: 'pie',
							name: seriesNm,
							colorByPoint: true,
							size: '80%',
							innerSize: '30%',
							data: graphArr
						}]
					});

				}
			});
		}, 300);
	}

	
	/* function setPieData(sqlId, eleId, seriesNm, day) {

		// 로딩 시작
		//$("#" + eleId + "FavLoad").css("display", "");

		setTimeout(function () {

			// 조회
			$.ajax({
				url: "/admmgr/main/dashboardChartProc.do",
				type: "POST",
				data: { "day": day, "sqlId": sqlId },
				success: function (data) {

					// 버튼 유효성
					//$("#" + eleId + "FavBtn li").removeClass("on");
					//$("#" + eleId + "FavBtn" + day).addClass("on");

					// 범례
					var legendHtml = "";
					var json = $.parseJSON(data);
					var graphArr = [];
					var totCnt = 0;
					for (var i = 0, j = json.length; i < j; i++) {

						if (i < 5) {

							graphArr.push(json[i]);
							legendHtml += "<li class='t" + (i + 1) + "'><em>&nbsp;</em> " + json[i].TXT + "</li>";

						}

						totCnt += Number(json[i].CNT);

					}
					$("#" + eleId + "FavLegend").html(legendHtml);

					// 전체 카운트
					$("#" + eleId + "FavCnt").html(totCnt + " <em>명</em>");

					// 차트
					Highcharts.chart(eleId + "FavGraph", {
						colors: ['#002f6f', '#126ac5', '#2091e1', '#dd3163', '#abb6c3'],
						chart: {
							plotBackgroundColor: null,
							plotBorderWidth: 0,
							plotShadow: false
						},
						title: {
							text: null
						},
						accessibility: {
							announceNewData: {
								enabled: true
							}
						},
						tooltip: {
							headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
							pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span>: <b>{point.y}명</b><br/>'
						},
						plotOptions: {
							pie: {
								allowPointSelect: false,
								cursor: 'pointer',
								dataLabels: {
									enabled: false,
									format: '{point.y:.1f}%'
								},
								showInLegend: false,
								startAngle: 0,
								endAngle: 0
							}
						},
						series: [
							{
								type: 'pie',
								name: seriesNm,
								colorByPoint: true,
								innerSize: '64%',
								data: $(graphArr).map(function () {
									return { "name": this.TXT, "y": Number(this.CNT), "drilldown": this.TXT };
								}).get()
							}
						]

					});

				}
			});

			// 로딩 종료
			//$("#" + eleId + "FavLoad").css("display", "none");

		}, 300);

	} */
	</script>
</head>
<body>

<!-- sub_contents_wrap -->
<!-- <div class="sub_contents_wrap">
    <div class="sub_contents_area"> -->
        <!-- 대시보드 -->
        <div class="dashboard">
            <div class="dashboard_con">
            	
            	<div class="row">

					<div class="dashboard_box">
						<div class="dashboard_box_body">
							<!-- 일반회원 -->
							 <div class="monitor_box ht150">
								<div class="monitor_info_sec">
									<div class="monitor_info_top">
										<p class="monitor_top_tit">일반회원</p>  
										<p class="monitor_top_count"><!-- 230 --><c:out value="${userBasicCount} "/><em>명</em></p>
									</div>
									
									<div class="monitor_info_box">
										<p id="basic" class="monitor_box_tit f_c_r"><b><!-- ▲ --></b><!--  3% --></p> 
										<p class="memberWith monitor_box_dec"><!-- 12월 대비 01월 --></p>
									</div>

								</div>
								<div class="monitor_chart_sec">
									<div id="hc_mntr1" style="width:250px; height:130px;"></div>
								</div>
								<!-- // 일반회원 -->
							</div>
						</div>
					</div>

					<div class="dashboard_box">
						<div class="dashboard_box_body">
							<!-- 평가위원 -->
							 <div class="monitor_box ht150">
								<div class="monitor_info_sec">
									<div class="monitor_info_top">
										<p class="monitor_top_tit">평가위원</p>  
										<p class="monitor_top_count"><!-- 58 --><c:out value="${userEvalCount} "/><em>명</em></p>
									</div>
									
									<div class="monitor_info_box">
										<p id="eval" class="monitor_box_tit f_c_b"><b><!-- ▼ --></b><!--  2% --></p> 
										<p class="memberWith monitor_box_dec"><!-- 12월 대비 01월 --></p>
									</div>

								</div>
								<div class="monitor_chart_sec">
									<div id="hc_mntr2" style="width:250px; height:130px;"></div>
								</div>
								<!-- // 평가위원 -->
							</div>
						</div>
					</div>
					
					
					<%-- <div class="dashboard_box">
                        <div class="dashboard_box_header">
                            <h3 class="tit">FAQ</h3>
                            <div class="etc"><a href="/admmgr/manage/board/List2.do" class="btn4_ty5">더보기</a></div>
                        </div>
                        <div class="dashboard_box_body">
                            <div class="table_wrap">
                                <table class="table_sty01">
                                    <colgroup>
                                        <col style="width:*;">
                                        <col style="width:80px;">
                                        <col style="width:120px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th>제목</th>
                                            <th>등록일</th>
                                            <th>작성자</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                   		<c:forEach var="boardList2" items="${boardList2}">
	                                        <tr>
	                                            <td class="left">${boardList2.TITLE}</td>
	                                            <td>${boardList2.REG_DTM}</td>
	                                            <td>
	                                            	<span>
	                                            		<c:choose>
	                                            			<c:when test="${boardList2.REG_ID eq 'ctit'}">
	                                            				슈퍼관리자
	                                            			</c:when>
	                                            			<c:otherwise>
	                                            				<c:out value="${boardList2.REG_ID}"/>
	                                            			</c:otherwise>
	                                            		</c:choose>
	                                            	</span>
	                                            </td>
	                                        </tr>
                                        </c:forEach>
                                        <c:if test="${fn:length(boardList2) eq 0}">
                                        	<tr>
	                                            <td colspan="3" class="center">
                                                	등록된 게시물이 없습니다.
	                                            </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div> --%>
                        
				</div>

				<div class="row">
					
					<div class="dashboard_box">
						<div class="dashboard_box_body">
							<!-- 총 방문자수 -->
							 <div class="monitor_box ht240">
								<div class="monitor_info_sec">
									<div class="monitor_info_top">
										<p class="monitor_top_tit">총 방문자수</p>  
										<p class="monitor_top_count">230 <em>명</em></p>
									</div>
									
									<div class="monitor_info_box">
										<p id="connUD" class="monitor_box_tit f_c_r"><b>▲</b> 5%</p> 
										<p id="connWith" class="memberWith monitor_box_dec">12월 대비 01월</p>
									</div>

								</div>
								<div class="monitor_chart_sec">
									<div id="hc_mntr3" style="width:360px; height:228px;"></div>
								</div>
								<!-- // 총 방문자수 -->
							</div>
						</div>
					</div>
					
					<div class="dashboard_box">
						<div class="dashboard_box_body">
							<div class="monitor_box ht240">
								<ul id="hc_mntr4_FavBtn" class="monitor_tab tab_row">
									<!-- <li id="one_week" class="on"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_week')"><span>1주</span></a></li> -->
									<li id="hc_mntr4_FavBtn30" class="on"><a href="javascript:void(0)" onclick="setPieData( 'topMenuCnt', 'hc_mntr4', '인기 컨텐츠 TOP.5', 30 );"><span>1개월</span></a></li>
									<li id="hc_mntr4_FavBtn180"><a href="javascript:void(0)" onclick="setPieData( 'topMenuCnt', 'hc_mntr4', '인기 컨텐츠 TOP.5', 180 );"><span>6개월</span></a></li>
									<li id="hc_mntr4_FavBtn365"><a href="javascript:void(0)" onclick="setPieData( 'topMenuCnt', 'hc_mntr4', '인기 컨텐츠 TOP.5', 365 );"><span>1년</span></a></li>
								</ul>
								<div class="monitor_chart_sec">
									<div id="hc_mntr4" style="width:520px; height:228px; margin:0 auto;"></div>
								</div>
							</div>
						</div>
					</div>
					

					<!-- <div class="dashboard_box">
						<div class="dashboard_box_body">
							<div class="monitor_box ht240">
								<ul id="study_tp_list" class="monitor_tab tab_row">
									<li id="one_week" class="on"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_week')"><span>1주</span></a></li>
									<li id="one_month" class="on"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_month')"><span>1개월</span></a></li>
									<li id="six_month"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'six_month')"><span>6개월</span></a></li>
									<li id="one_year"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_year')"><span>1년</span></a></li>
								</ul>
								<div class="monitor_chart_sec">
									<div id="hc_mntr5" style="width:360px; height:228px; margin:0 auto;"></div>
								</div>
							</div>
						</div>
					</div>

					<div class="dashboard_box">
						<div class="dashboard_box_body">
							<div class="monitor_box ht240">
								<ul id="study_tp_list" class="monitor_tab tab_row">
									<li id="one_week" class="on"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_week')"><span>1주</span></a></li>
									<li id="one_month" class="on"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_month')"><span>1개월</span></a></li>
									<li id="six_month"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'six_month')"><span>6개월</span></a></li>
									<li id="one_year"><a href="javascript:void(0)" onclick="fn_SelectRange('study_tp', 'one_year')"><span>1년</span></a></li>
								</ul>
								<div class="monitor_chart_sec">
									<div id="hc_mntr6" style="width:360px; height:228px; margin:0 auto;"></div>
								</div>
							</div>
						</div>
					</div> -->
					
					<%-- <div class="dashboard_box">
                        <div class="dashboard_box_header">
                            <h3 class="tit">언론보도</h3>
                            <div class="etc"><a href="/admmgr/manage/board/List3.do" class="btn4_ty5">더보기</a></div>
                        </div>
                        <div class="dashboard_box_body">
                            <div class="table_wrap">
                                <table class="table_sty01">
                                    <colgroup>
                                        <col style="width:*;">
                                        <col style="width:80px;">
                                        <col style="width:120px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th>제목</th>
                                            <th>등록일</th>
                                            <th>작성자</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                   		<c:forEach var="boardList3" items="${boardList3}">
	                                        <tr>
	                                            <td class="left">${boardList3.TITLE}</td>
	                                            <td>${boardList3.REG_DTM}</td>
	                                            <td>
	                                            	<span>
	                                            		<c:choose>
	                                            			<c:when test="${boardList3.REG_ID eq 'ctit'}">
	                                            				슈퍼관리자
	                                            			</c:when>
	                                            			<c:otherwise>
	                                            				<c:out value="${boardList3.REG_ID}"/>
	                                            			</c:otherwise>
	                                            		</c:choose>
	                                            	</span>
	                                            </td>
	                                        </tr>
                                        </c:forEach>
                                        <c:if test="${fn:length(boardList3) eq 0}">
                                        	<tr>
	                                            <td colspan="3" class="center">
                                                	등록된 게시물이 없습니다.
	                                            </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
					
					<div class="dashboard_box">
                        <div class="dashboard_box_header">
                            <h3 class="tit">자료실</h3>
                            <div class="etc"><a href="/admmgr/manage/board/List5.do" class="btn4_ty5">더보기</a></div>
                        </div>
                        <div class="dashboard_box_body">
                            <div class="table_wrap">
                                <table class="table_sty01">
                                    <colgroup>
                                        <col style="width:*;">
                                        <col style="width:80px;">
                                        <col style="width:120px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th>제목</th>
                                            <th>등록일</th>
                                            <th>작성자</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                   		<c:forEach var="boardList5" items="${boardList5}">
	                                        <tr>
	                                            <td class="left">${boardList5.TITLE}</td>
	                                            <td>${boardList5.REG_DTM}</td>
	                                            <td>
	                                            	<span>
	                                            		<c:choose>
	                                            			<c:when test="${boardList5.REG_ID eq 'ctit'}">
	                                            				슈퍼관리자
	                                            			</c:when>
	                                            			<c:otherwise>
	                                            				<c:out value="${boardList5.REG_ID}"/>
	                                            			</c:otherwise>
	                                            		</c:choose>
	                                            	</span>
	                                            </td>
	                                        </tr>
                                        </c:forEach>
                                        <c:if test="${fn:length(boardList5) eq 0}">
                                        	<tr>
	                                            <td colspan="3" class="center">
                                                	등록된 게시물이 없습니다.
	                                            </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
					
					<div class="dashboard_box">
                        <div class="dashboard_box_header">
                            <h3 class="tit">성과보고서</h3>
                            <div class="etc"><a href="/admmgr/manage/board/List7.do" class="btn4_ty5">더보기</a></div>
                        </div>
                        <div class="dashboard_box_body">
                            <div class="table_wrap">
                                <table class="table_sty01">
                                    <colgroup>
                                        <col style="width:*;">
                                        <col style="width:80px;">
                                        <col style="width:120px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th>제목</th>
                                            <th>등록일</th>
                                            <th>작성자</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                   		<c:forEach var="boardList7" items="${boardList7}">
	                                        <tr>
	                                            <td class="left">${boardList7.TITLE}</td>
	                                            <td>${boardList7.REG_DTM}</td>
	                                            <td>
	                                            	<span>
	                                            		<c:choose>
	                                            			<c:when test="${boardList7.REG_ID eq 'ctit'}">
	                                            				슈퍼관리자
	                                            			</c:when>
	                                            			<c:otherwise>
	                                            				<c:out value="${boardList7.REG_ID}"/>
	                                            			</c:otherwise>
	                                            		</c:choose>
	                                            	</span>
	                                            </td>
	                                        </tr>
                                        </c:forEach>
                                        <c:if test="${fn:length(boardList7) eq 0}">
                                        	<tr>
	                                            <td colspan="3" class="center">
                                                	등록된 게시물이 없습니다.
	                                            </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div> --%>
                    
					
				</div>
            	
            	<c:if test="${dashboardList == null || empty dashboardList }"> 
					<div class="dashoard_empty">
					</div>
            	</c:if>
            
            
            	<c:forEach var="dashboardList" items="${dashboardList }" varStatus="status">
			        <c:choose>
			            <c:when test="${status.index % 3 == 0}"> 
			                <c:if test="${!status.first}"> 
			                    </div> 
			                </c:if>
			                <div class="row"> 
			            </c:when>
			        </c:choose>
			
			        <c:choose>
			            <c:when test="${dashboardList == '01'}">
			                <div class="dashboard_box">
			                    <div class="dashboard_box_header">
			                        <h3 class="tit">일반회원</h3>
			                        <div class="etc"><a href="/admmgr/member/userBasicList.do" class="btn4_ty5">더보기</a></div>
			                    </div>
			                    <div class="dashboard_box_body">
			                        <div class="table_wrap">
			                            <table class="table_sty01">
			                                <colgroup>
			                                    <col style="width:150px;">
			                                    <col style="width:120px;">
			                                    <col style="width:*;">
			                                </colgroup>
			                                <thead>
			                                    <tr>
			                                        <th>아이디</th>
			                                        <th>이름</th>
			                                        <th>이메일</th>
			                                    </tr>
			                                </thead>
			                                <tbody>
			                                    <c:choose>
			                                        <c:when test="${userList == null || userList.size() == 0}">
			                                            <tr>
			                                                <td colspan="3" class="center">
			                                                    	등록된 게시물이 없습니다.
			                                                </td>
			                                            </tr>
			                                        </c:when>
			                                        <c:otherwise>
			                                            <c:forEach var="userList" items="${userList}">
			                                                <tr>
			                                                    <td class="center pl0">${userList.USER_ID }</td>
			                                                    <td>${userList.USER_NM}</td>
			                                                    <td>${userList.EMAIL}</td>
			                                                </tr>
			                                            </c:forEach>
			                                        </c:otherwise>
			                                    </c:choose>
			                                </tbody>
			                            </table>
			                        </div>
			                    </div>
			                </div>
			            </c:when>
			            <c:when test="${dashboardList == '02'}">
			            	<div class="dashboard_box">
		                        <div class="dashboard_box_header">
		                            <h3 class="tit">탈퇴회원</h3>
		                            <div class="etc"><a href="/admmgr/member/withDrawList.do" class="btn4_ty5">더보기</a></div>
		                        </div>
		                        <div class="dashboard_box_body">
		                            <div class="table_wrap">
		                                <table class="table_sty01">
		                                    <colgroup>
		                                        <col style="width:120px;">
		                                        <col style="width:120px;">
		                                        <col style="width:120px;">
		                                    </colgroup>
		                                    <thead>
		                                        <tr>
		                                            <th>아이디</th>
		                                            <th>휴대폰번호</th>
		                                            <th>탈퇴일시</th>
		                                        </tr>
		                                    </thead>
		                                    <tbody>
		                                    	<c:if test="${withDrawUserList == null || withDrawUserList.size() == 0}">
		                                    		<tr>
			                                            <td colspan="3" class="center">
			                                                	등록된 게시물이 없습니다.
			                                            </td>
			                                       	</tr>
		                                    	</c:if>
		                                    	<c:if test="${withDrawUserList.size() != 0}">
		                                    		<c:forEach var="withDrawUserList" items="${withDrawUserList}">
				                                        <tr>
				                                            <td class="center pl0">${withDrawUserList.USER_ID}</td>
				                                            <td>${withDrawUserList.HP_NO}</td>
				                                            <td>${withDrawUserList.WITHDRAW_DTM}</td>
				                                        </tr>
			                                        </c:forEach>
		                                    	</c:if>
		                                    </tbody>
		                                </table>
		                            </div>
		                        </div>
		                    </div>
			            </c:when>
			            <c:when test="${dashboardList == '03'}">
			            	<div class="dashboard_box">
		                        <div class="dashboard_box_header">
		                            <h3 class="tit">관리자</h3>
		                            <div class="etc"><a href="/admmgr/member/adminList.do" class="btn4_ty5">더보기</a></div>
		                        </div>
		                        <div class="dashboard_box_body">
		                            <div class="table_wrap">
		                                <table class="table_sty01">
		                                    <colgroup>
		                                        <col style="width:*;">
		                                        <col style="width:120px;">
		                                        <col style="width:120px;">
		                                    </colgroup>
		                                    <thead>
		                                        <tr>
		                                            <th>아이디</th>
		                                            <th>이름</th>
													<th>권한</th>
		                                        </tr>
		                                    </thead>
		                                    <tbody>
		                                    	<c:choose>
			                                    	<c:when test="${adminList == null || adminList.size() == 0}">
			                                    		<tr>
				                                            <td colspan="3" class="center">
				                                                	등록된 게시물이 없습니다.
				                                            </td>
			                                            </tr>
			                                    	</c:when>
			                                    	<c:otherwise>
			                                    		<c:forEach var="adminList" items="${adminList}">
					                                        <tr>
					                                            <td>${adminList.USER_ID}</td>
					                                            <td>${adminList.USER_NM}</td>
																<td class="center"><span class="bagde c_green">${adminList.AUTH_NM}</span></td>
					                                        </tr>
		                                        		</c:forEach>
			                                    	</c:otherwise>
			                                    </c:choose>
		                                    </tbody>
		                                </table>
		                            </div>
		                        </div>
		                    </div>
			            </c:when>
			            <c:when test="${dashboardList == '04'}">
			            	<div class="dashboard_box">
		                        <div class="dashboard_box_header">
		                            <h3 class="tit">공지사항</h3>
		                            <div class="etc"><a href="/admmgr/manage/board/List1.do" class="btn4_ty5">더보기</a></div>
		                        </div>
		                        <div class="dashboard_box_body">
		                            <div class="table_wrap">
		                                <table class="table_sty01">
		                                    <colgroup>
		                                        <col style="width:*;">
		                                        <col style="width:80px;">
		                                        <col style="width:120px;">
		                                    </colgroup>
		                                    <thead>
		                                        <tr>
		                                            <th>제목</th>
		                                            <th>등록일</th>
		                                            <th>작성자</th>
		                                        </tr>
		                                    </thead>
		                                    <tbody>
		                                    	<c:choose>
			                                    	<c:when test="${boardList1 == null || boardList1.size() == 0}">
			                                    		<tr>
				                                            <td colspan="3" class="center">
				                                                	등록된 게시물이 없습니다.
				                                            </td>
			                                            </tr>
			                                    	</c:when>
			                                    	<c:otherwise>
			                                    		<c:forEach var="boardList1" items="${boardList1}">
					                                        <tr>
					                                            <td class="left">${boardList1.TITLE}</td>
					                                            <td>${boardList1.REG_DTM}</td>
					                                            <td>
					                                            	<span>
					                                            		<c:choose>
					                                            			<c:when test="${boardList1.REG_ID eq 'ctit'}">
					                                            				슈퍼관리자
					                                            			</c:when>
					                                            			<c:otherwise>
					                                            				<c:out value="${boardList1.REG_ID}"/>
					                                            			</c:otherwise>
					                                            		</c:choose>
					                                            	</span>
					                                            </td>
					                                        </tr>
				                                        </c:forEach>
			                                    	</c:otherwise>
			                                    </c:choose>
		                                    </tbody>
		                                </table>
		                            </div>
		                        </div>
		                    </div>
			            </c:when>
			            <c:when test="${dashboardList == '05'}">
			            	<div class="dashboard_box">
		                        <div class="dashboard_box_header">
		                            <h3 class="tit">수요조사</h3>
		                            <div class="etc"><a href="/admmgr/business/needList.do" class="btn4_ty5">더보기</a></div>
		                        </div>
		                        <div class="dashboard_box_body">
		                            <div class="table_wrap">
		                                <table class="table_sty01">
		                                    <colgroup>
		                                        <col style="width:*;">
		                                        <col style="width:80px;">
		                                        <col style="width:120px;">
		                                    </colgroup>
		                                    <thead>
		                                        <tr>
		                                            <th>수요조사명</th>
		                                            <th>등록일</th>
		                                            <th>진행상태</th>
		                                        </tr>
		                                    </thead>
		                                    <tbody>
		                                    	<c:forEach var="needList" items="${needList}">
			                                        <tr>
			                                            <td class="left">${needList.NEED_NM}</td>
			                                            <td>${needList.REG_DTM}</td>
			                                            <td>
			                                            	<fmt:parseDate var="PUBLIC_START_DD" value="${needList.PUBLIC_START_DD}" pattern="yyyy-MM-dd"/>
															<fmt:formatDate var="publicStartDd" value="${PUBLIC_START_DD}" pattern="yyyyMMdd"/>
															<fmt:parseDate var="PUBLIC_END_DD" value="${needList.PUBLIC_END_DD}" pattern="yyyy-MM-dd"/>
															<fmt:formatDate var="publicEndDd" value="${PUBLIC_END_DD}" pattern="yyyyMMdd"/>
															<c:choose>
																<c:when test="${publicStartDd <= nowDate && publicEndDd >= nowDate}"><span class="av_link av_blue center">신청접수중</span></c:when>
																<c:otherwise><span class="av_link av_orange center">신청마감</span></c:otherwise>
															</c:choose>
			                                            </td>
			                                        </tr>
		                                        </c:forEach>
		                                        <c:if test="${fn:length(needList) eq 0}">
		                                        	<tr>
			                                            <td colspan="3" class="center">
		                                                	등록된 게시물이 없습니다.
			                                            </td>
		                                            </tr>
		                                        </c:if>
		                                    	<!-- <tr>
		                                    		<td class="left">감염병 예방 및 대응을 위한 의료 자원 수요조사</td>
		                                    		<td>2024-06-27</td>
		                                    		<td><span class="av_link av_orange center">신청마감</span></td>
		                                    	</tr> -->
		                                    	<!-- <tr>
		                                    		<td class="left">지역별 감염병 대응 역량 조사</td>
		                                    		<td>2023-08-17</td>
		                                    		<td><span class="av_link av_blue center">신청접수중</span></td>
		                                    	</tr>
		                                    	<tr>
		                                    		<td class="left">감염병 진단 장비 및 치료제 수요조사</td>
		                                    		<td>2022-06-13</td>
		                                    		<td><span class="av_link av_orange center">신청마감</span></td>
		                                    	</tr>
		                                    	<tr>
		                                    		<td class="left">감염병 발생에 따른 병원 시설 확충 수요조사</td>
		                                    		<td>2022-02-07</td>
		                                    		<td><span class="av_link av_blue center">신청접수중</span></td>
		                                    	</tr> -->
		                                    </tbody>
		                                </table>
		                            </div>
		                        </div>
		                    </div>
			            </c:when>
			            <c:when test="${dashboardList == '06'}">
			            	<div class="dashboard_box">
		                        <div class="dashboard_box_header">
		                            <h3 class="tit">사업공고</h3>
		                            <div class="etc"><a href="/admmgr/business/noticeList.do" class="btn4_ty5">더보기</a></div>
		                        </div>
		                        <div class="dashboard_box_body">
		                            <div class="table_wrap">
		                                <table class="table_sty01">
		                                    <colgroup>
		                                        <col style="width:*;">
		                                        <col style="width:80px;">
		                                        <col style="width:120px;">
		                                    </colgroup>
		                                    <thead>
		                                        <tr>
		                                            <th>사업공고명</th>
		                                            <th>등록일</th>
		                                            <th>진행상태</th>
		                                        </tr>
		                                    </thead>
		                                    <tbody>
		                                    	<c:forEach var="noticeList" items="${noticeList}">
			                                        <tr>
			                                            <td class="left">${noticeList.NOTICE_NM}</td>
			                                            <td>${noticeList.REG_DTM}</td>
			                                            <td>
			                                            	<fmt:parseDate var="PUBLIC_START_DD" value="${noticeList.PUBLIC_START_DD}" pattern="yyyy-MM-dd"/>
															<fmt:formatDate var="publicStartDd" value="${PUBLIC_START_DD}" pattern="yyyyMMdd"/>
															<fmt:parseDate var="PUBLIC_END_DD" value="${noticeList.PUBLIC_END_DD}" pattern="yyyy-MM-dd"/>
															<fmt:formatDate var="publicEndDd" value="${PUBLIC_END_DD}" pattern="yyyyMMdd"/>
															<c:choose>
																<c:when test="${publicStartDd <= nowDate && publicEndDd >= nowDate}"><span class="av_link av_blue center">공고진행중</span></c:when>
																<c:otherwise><span class="av_link av_orange center">공고마감</span></c:otherwise>
															</c:choose>
			                                            </td>
			                                        </tr>
		                                        </c:forEach>
		                                        <c:if test="${fn:length(noticeList) eq 0}">
		                                        	<tr>
			                                            <td colspan="3" class="center">
		                                                	등록된 게시물이 없습니다.
			                                            </td>
		                                            </tr>
		                                        </c:if>
		                                    	<!-- <tr>
		                                    		<td class="left">감염병 대응 의료기기 및 장비 지원 사업 공고</td>
		                                    		<td>2024-11-25</td>
		                                    		<td><span class="av_link av_blue center">공고진행중</span></td>
		                                    	</tr> -->
		                                    	<!-- <tr>
		                                    		<td class="left">COVID-19 백신 및 치료제 연구개발 지원 사업 공고</td>
		                                    		<td>2024-11-20</td>
		                                    		<td><span class="av_link av_blue center">공고진행중</span></td>
		                                    	</tr>
		                                    	<tr>
		                                    		<td class="left">지역별 감염병 대응 인프라 구축 및 확장 사업 공고</td>
		                                    		<td>2024-09-13</td>
		                                    		<td><span class="av_link av_orange center">공고마감</span></td>
		                                    	</tr>
		                                    	<tr>
		                                    		<td class="left">감염병 예방을 위한 대국민 교육 및 홍보 사업 공고</td>
		                                    		<td>2024-01-24</td>
		                                    		<td><span class="av_link av_orange center">공고마감</span></td>
		                                    	</tr> -->
		                                    </tbody>
		                                </table>
		                            </div>
		                        </div>
		                    </div>
			            </c:when>
			        </c:choose>

			        <c:if test="${status.last}">
			            </div> 
			        </c:if>

			    </c:forEach>
                                   
            </div>
        </div>
        <!-- 대시보드 -->
        
        <script>
        /* 통합 일반 회원 */
		var userBasicCnt = JSON.parse('${userBasicCntJson}');
		console.log(userBasicCnt);
		
	    var userBasicMonths = [];
	    var userBasicCounts = [];

	    // userBasicCnt를 순회하여 월과 회원 수 추출
	    for (var i = 0; i < userBasicCnt.length; i++) {
	        var entry = userBasicCnt[i];
	        var _month = entry.month;  // 월 (예: '2024-10')
	        var memberCount = entry.member_count;  // 회원 수 (예: 0, 2, 4, ...)
			
	        var month = _month.substr(5).startsWith("0") ? _month.substr(6) : _month.substr(5);
	        
	        // months와 memberCounts 배열에 각각 추가
	        userBasicMonths.push(month + "월");
	        userBasicCounts.push(memberCount);
	    }
		
		var thisMonthBasicCount = userBasicCounts[userBasicCounts.length-1]; // 이번 달 회원 수
	    var lastMonthBasicCount = userBasicCounts[userBasicCounts.length-2]; // 저번 달 회원 수
	    
	    var userBasicResult;
	    
	    if (lastMonthBasicCount === 0) {
	    	// 이번달이 -1 이하가 없다는 가정
	        
	        if(lastMonthBasicCount === thisMonthBasicCount) {
	    		// 이번달도 0일 때 0%
		        userBasicResult = "0%";
		        $("#basic").removeClass();
	    	} else {
	    		// 이번달이 0이 아닐 때 100% 증가로 간주
	    		 userBasicResult = "100%";
	 	        $("#basic").attr("class","f_c_r");
	    	}
	        
	    } else {
	        // 저번 달 회원 수가 0이 아닐 때는 증가율 계산 (증감 부호 삭제)
	        userBasicResult = Math.abs((thisMonthBasicCount - lastMonthBasicCount) / lastMonthBasicCount * 100) + "%";
	        
	        // 증가
	        if(lastMonthBasicCount < thisMonthBasicCount) {
	        	$("#basic").attr("class","f_c_r");
	        // 감소
	        } else if (lastMonthBasicCount > thisMonthBasicCount) {
	        	$("#basic").attr("class","f_c_b");
	        // 동일
	        } else {
	        	$("#basic").removeClass();
	        }
	        
	    }
	    
	    if( $("#basic")[0].className === "f_c_r" ) {
	    	$("#basic b").text("▲");
	    } else if ($("#basic")[0].className === "f_c_b") {
	    	$("#basic b").text("▼");
	    } else {
	    	$("#basic b").text("-");
	    }
	    
	    $("#basic").html($("#basic").html() + " " + userBasicResult);
        
        /* 통합 평가 회원 */
		var userEvalCnt = JSON.parse('${userEvalCntJson}');
		console.log(userEvalCnt);
		
	    var userEvalMonths = [];
	    var userEvalCounts = [];

	    // userEvalCnt를 순회하여 월과 회원 수 추출
	    for (var i = 0; i < userEvalCnt.length; i++) {
	        var entry = userEvalCnt[i];
	        var _month = entry.month;  // 월 (예: '2024-10')
	        var memberCount = entry.member_count;  // 회원 수 (예: 0, 2, 4, ...)
			
	        var month = _month.substr(5).startsWith("0") ? _month.substr(6) : _month.substr(5);
	        
	        // months와 memberCounts 배열에 각각 추가
	        userEvalMonths.push(month + "월");
	        userEvalCounts.push(memberCount);
	    }
		
		var thisMonthEvalCount = userEvalCounts[userEvalCounts.length-1]; // 이번 달 회원 수
	    var lastMonthEvalCount = userEvalCounts[userEvalCounts.length-2]; // 저번 달 회원 수
	    
	    var userEvalResult;
	    
	    if (lastMonthEvalCount === 0) {
	    	// 이번달이 -1 이하가 없다는 가정
	        
	        if(lastMonthEvalCount === thisMonthEvalCount) {
	    		// 이번달도 0일 때 0%
		        userEvalResult = "0%";
		        $("#eval").removeClass();
	    	} else {
	    		// 이번달이 0이 아닐 때 100% 증가로 간주
	    		 userEvalResult = "100%";
	 	        $("#eval").attr("class","f_c_r");
	    	}
	        
	    } else {
	        // 저번 달 회원 수가 0이 아닐 때는 증가율 계산
	        userEvalResult = Math.abs((thisMonthEvalCount - lastMonthEvalCount) / lastMonthEvalCount * 100) + "%";
	        
	        // 증가
	        if(lastMonthEvalCount < thisMonthEvalCount) {
	        	$("#eval").attr("class","f_c_r");
	        // 감소
	        } else if (lastMonthEvalCount > thisMonthEvalCount) {
	        	$("#eval").attr("class","f_c_b");
	        // 동일
	        } else {
	        	$("#eval").removeClass();
	        }
	        
	    }
	    
	    if( $("#eval")[0].className === "f_c_r" ) {
	    	$("#eval b").text("▲");
	    } else if ($("#eval")[0].className === "f_c_b") {
	    	$("#eval b").text("▼");
	    } else {
	    	$("#eval b").text("-");
	    }
	    
	    $("#eval").html($("#eval").html() + " " + userEvalResult);
        
		var hc_mntr1 = Highcharts.chart('hc_mntr1', { 
			chart: {
				type: 'line',
				backgroundColor: 'rgba(255, 255, 255, 0)', // 투명한 배경색
				margin: [0, 0, 30, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [0, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			credits: {
				enabled: false // 카피라이트 비활성화
			},
			// 차트의 제목
			title: {
				text: null
			},
			
			// 범례 설정
			legend: {
				enabled: false  // 범례 숨기기
			},

			colors: ['#2031ac'],

			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span>: <b>{point.y:.f}개</b><br/>'
			},
			xAxis: {
				text: null,
				//categories: ['7월', '8월', '9월', '10월', '11월', '12월'],
				categories: userBasicMonths,
				gridLineWidth: 1,         // X축의 그리드 선 두께
				gridLineColor: '#C0C0C0', // X축의 그리드 선 색상
				gridLineDashStyle: 'Dash' // X축의 그리드 선 스타일 (점선)
			},
			yAxis: {
				labels: {
					enabled: false // Y축 값 레이블 숨기기
				},
				title: {
					text: null
				},
				gridLineWidth: 0         // Y축의 그리드 선 두께를 0으로 설정하여 삭제
			},
			series: [
				{
					name: "일반회원",
					//data: [12,12,12,15,9,12],
					data: userBasicCounts,
					dashStyle: 'Dash',
					marker: {
						symbol: 'square',    // 마커를 사각형으로 설정
						fillColor: '#2031ac', // 마커의 내부 색상
						lineWidth: 2,        // 마커의 테두리 두께
						lineColor: '#071263'   // 마커의 테두리 색상
					},
					dataLabels: {
					enabled: true,    // 데이터 레이블 활성화
					format: '{point.y}', // 값 형식 지정
					style: {
						color: '#000000', // 텍스트 색상
						fontSize: '10px'  // 텍스트 크기
					}
				}
				}
			]
		});
	
		var hc_mntr2 = Highcharts.chart('hc_mntr2', {
			chart: {
				type: 'line',
				backgroundColor: 'rgba(255, 255, 255, 0)', // 투명한 배경색
				margin: [0, 0, 30, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [0, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			credits: {
				enabled: false // 카피라이트 비활성화
			},
			// 차트의 제목
			title: {
				text: null
			},
			
			// 범례 설정
			legend: {
				enabled: false  // 범례 숨기기
			},

			colors: ['#20cfd4'],

			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span>: <b>{point.y:.f}개</b><br/>'
			},
			xAxis: {
				text: null,
				//categories: ['7월', '8월', '9월', '10월', '11월', '12월'],
				categories: userEvalMonths,
				gridLineWidth: 1,         // X축의 그리드 선 두께
				gridLineColor: '#C0C0C0', // X축의 그리드 선 색상
				gridLineDashStyle: 'Dash' // X축의 그리드 선 스타일 (점선)
			},
			yAxis: {
				labels: {
					enabled: false // Y축 값 레이블 숨기기
				},
				title: {
					text: null
				},
				gridLineWidth: 0         // Y축의 그리드 선 두께를 0으로 설정하여 삭제
			},
			series: [
				{
					name: "평가위원",
					//data: [5,8,2,10,9,7],
					data: userEvalCounts,
					dashStyle: 'Dash',
					marker: {
						symbol: 'square',    // 마커를 사각형으로 설정
						fillColor: '#20cfd4', // 마커의 내부 색상
						lineWidth: 2,        // 마커의 테두리 두께
						lineColor: '#1cb6ba'   // 마커의 테두리 색상
					},
					dataLabels: {
						enabled: true,    // 데이터 레이블 활성화
						format: '{point.y}', // 값 형식 지정
						style: {
							color: '#000000', // 텍스트 색상
							fontSize: '10px'  // 텍스트 크기
						}
					}
				}
			]
		});

		/* var hc_mntr3 = Highcharts.chart('hc_mntr3', {
			chart: {
				type: 'line',
				backgroundColor: 'rgba(255, 255, 255, 0)', // 투명한 배경색
				margin: [0, 0, 30, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [0, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			credits: {
				enabled: false // 카피라이트 비활성화
			},
			// 차트의 제목
			title: {
				text: null
			},
			
			// 범례 설정
			legend: {
				enabled: false  // 범례 숨기기
			},

			colors: ['#cb2369'],

			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span>: <b>{point.y:.f}개</b><br/>'
			},
			xAxis: {
				text: null,
				categories: ['7월', '8월', '9월', '10월', '11월', '12월'],
				gridLineWidth: 1,         // X축의 그리드 선 두께
				gridLineColor: '#C0C0C0', // X축의 그리드 선 색상
				gridLineDashStyle: 'Dash' // X축의 그리드 선 스타일 (점선)
			},
			yAxis: {
				labels: {
					enabled: false // Y축 값 레이블 숨기기
				},
				title: {
					text: null
				},
				gridLineWidth: 0         // Y축의 그리드 선 두께를 0으로 설정하여 삭제
			},
			series: [
				{
					name: "통합회원",
					data: [33,22,38,15,20,26],
					dashStyle: 'Dash',
					marker: {
						symbol: 'square',    // 마커를 사각형으로 설정
						fillColor: '#ec4188', // 마커의 내부 색상
						lineWidth: 2,        // 마커의 테두리 두께
						lineColor: '#cb2369'   // 마커의 테두리 색상
					},
					dataLabels: {
						enabled: true,    // 데이터 레이블 활성화
						format: '{point.y}', // 값 형식 지정
						style: {
							color: '#000000', // 텍스트 색상
							fontSize: '10px'  // 텍스트 크기
						}
					}
				}
			]
		}); */

		/* var hc_mntr4 = Highcharts.chart('hc_mntr4', {
			colors: ['#ec4188', '#2031ac', '#20cfd4', '#158be9', '#7143bf'],
			chart: {
				plotBackgroundColor: null,
				plotBorderWidth: 0,
				plotShadow: false,
				margin: [20, 20, 0, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [20, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			credits: {
				enabled: false // 카피라이트 비활성화
			},
			title: {
				text: '인기 컨텐츠 TOP.3',
				verticalAlign: 'top',
				align : 'center',
				
			},
			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span><b>{point.y:f}%</b><br/><br/>'
			},
			plotOptions: {
				pie: {
					allowPointSelect: false,
					cursor: 'pointer',
					dataLabels: {
						enabled: true,
						distance: -30,
						format: '{point.y:.f}%',
						style: {
							color: 'white', // Optional: Improve readability
							textOutline: '1px contrast' // Optional: Remove text outline for better visibility
						}
					},
					showInLegend: true,
					startAngle: 0,
					endAngle: 0
				}
			},
			legend: {
				layout: 'vertical',
				align: 'right',
				verticalAlign: 'bottom', // Adjusted to center vertically
				itemMarginBottom: 0, // Optional: Adjust space between legend items
				symbol: 'square',
				itemStyle: {
					color: '#9498a1',
					fontWeight: 'normal'
				}
			},

			series: [
				{
					type: 'pie',
					name: "인기 컨텐츠 TOP.3",
					colorByPoint: true,
					size: '80%',  // Increase the size to 110%
					innerSize: '30%',
					data: [
						{
							name: "공지사항",
							y: 37.5,
							colors: '#ec4188',
						},
						{
							name: "로그인",
							y: 25,
							colors: '#2031ac',

						},
						{
							name: "마이페이지",
							y: 37.5,
							colors: '#20cfd4',

						}
					]
				}
			]
		}); */

		/* var hc_mntr5 = Highcharts.chart('hc_mntr5', {
			colors: ['#ec4188', '#2031ac', '#20cfd4', '#158be9', '#7143bf'],
										credits: {
				enabled: false // 카피라이트 비활성화
			},
			chart: {
				plotBackgroundColor: null,
				plotBorderWidth: 0,
				plotShadow: false,
				margin: [20, 20, 0, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [20, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			title: {
				text: '인기 컨텐츠 TOP.3',
				verticalAlign: 'top',
				align : 'center',
				
			},
			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span><b>{point.y:f}%</b><br/><br/>'
			},
			plotOptions: {
				pie: {
					allowPointSelect: false,
					cursor: 'pointer',
					dataLabels: {
						enabled: true,
						distance: -30,
						format: '{point.y:.f}%',
						style: {
							color: 'white', // Optional: Improve readability
							textOutline: '1px contrast' // Optional: Remove text outline for better visibility
						}
					},
					showInLegend: true,
					startAngle: 0,
					endAngle: 0
				}
			},
			legend: {
				layout: 'vertical',
				align: 'right',
				verticalAlign: 'bottom', // Adjusted to center vertically
				itemMarginBottom: 0, // Optional: Adjust space between legend items
				symbol: 'square',
				itemStyle: {
					color: '#9498a1',
					fontWeight: 'normal'
				}
			},

			series: [
				{
					type: 'pie',
					name: "인기 컨텐츠 TOP.3",
					colorByPoint: true,
					size: '80%',  // Increase the size to 110%
					innerSize: '30%',
					data: [
						{
							name: "기부뉴스",
							y: 37.5,
							colors: '#ec4188',
						},
						{
							name: "언론보도",
							y: 25,
							colors: '#2031ac',

						},
						{
							name: "FAQ",
							y: 37.5,
							colors: '#20cfd4',

						}
					]
				}
			]
		}); */

		/* var hc_mntr6 = Highcharts.chart('hc_mntr6', {
			colors: ['#ec4188', '#2031ac', '#20cfd4', '#158be9', '#7143bf'],
			credits: {
					enabled: false // 카피라이트 비활성화
				},
			chart: {
				plotBackgroundColor: null,
				plotBorderWidth: 0,
				plotShadow: false,
				margin: [20, 20, 0, 0],     // 상, 우, 하, 좌 여백 설정
				spacing: [20, 0, 0, 0]     // 상, 우, 하, 좌 패딩 설정
			},
			title: {
				text: '방문자 수',
				verticalAlign: 'top',
				align : 'center',
				
			},
			accessibility: {
				announceNewData: {
					enabled: true
				}
			},
			tooltip: {
				headerFormat: '<span style="font-size:11px; position:relative; z-index:9;">{series.name}</span><br>',
				pointFormat: '<span style="color:{point.color}; position:relative; z-index:9;">{point.name}</span><b>{point.y:f}%</b><br/><br/>'
			},
			plotOptions: {
				pie: {
					allowPointSelect: false,
					cursor: 'pointer',
					dataLabels: {
						enabled: true,
						distance: -30,
						format: '{point.y:.f}%',
						style: {
							color: 'white', // Optional: Improve readability
							textOutline: '1px contrast' // Optional: Remove text outline for better visibility
						}
					},
					showInLegend: true,
					startAngle: 0,
					endAngle: 0
				}
			},
			legend: {
				layout: 'vertical',
				align: 'right',
				verticalAlign: 'bottom', // Adjusted to center vertically
				itemMarginBottom: 0, // Optional: Adjust space between legend items
				symbol: 'square',
				itemStyle: {
					color: '#9498a1',
					fontWeight: 'normal'
				}
			},

			series: [
				{
					type: 'pie',
					name: "방문자 수",
					colorByPoint: true,
					size: '80%',  // Increase the size to 110%
					innerSize: '30%',
					data: [
						{
							name: "일반회원",
							y: 47.5,
							colors: '#ec4188',
						},
						{
							name: "평가위원",
							y: 52.5,
							colors: '#20cfd4',

						}
					]
				}
			]
		}); */

	</script>
    <!-- </div>
</div> -->
<!-- // sub_contents_wrap -->
</body>