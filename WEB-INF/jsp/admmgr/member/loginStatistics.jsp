<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="str" uri="http://customTag.com/jsp/str"%>
<%
/**
 * @author		: KKH
 * @since		: 2024. 07. 12.
 * @version		: 1.0
 * @description	: 로그관리 > 로그통계
 * @function	: 
 * @see			: 
 * 
 * <pre>
 * [Modification Information]
 * 수정일				수정자			수정내용
 * ------------------------------------------------------
 * 2024. 07. 12.	KKH				1. 최초생성
 * </pre>
 */
 %>
<style>
	.chart_section{ box-sizing: border-box; border: 1px black solid; }
	.log_chart_div .chart_section { width: calc(100% / 2 - 5px)!important;}
    .chart_section>div{min-width:100% !important;}
    .highcharts-root,
    .highcharts-container {width:100% !important; min-width:100% !important;}
	.input_button_em {display: flex; width: 100%; gap:8px;}
	.input_button_em button {padding: 4px 8px; background-color: #a7c2f7; font-weight: bold;}
	.log_chart_div {display: flex; gap:8px; margin-top: 12px;}
</style>
<script type="text/javascript" src="<c:url value='/common/admmgr/js/highcharts/highcharts.js'/>"></script>
<script>
	$(document).ready(function() {		
		<%-- [검색] --%>
		/* $("#btnSearch").click(function() {
			if(check_date()) {
				$("#frm").attr("action","<c:url value='/admmgr/member/loginStatistics.do'/>");
				$("#frm").submit();
			};
		}); */
		
		<%-- chart --%>
		let loginCntArr = JSON.parse('<c:out value="${jsonList01}" escapeXml="false"/>');
		loginCntArr.reverse();
		// 변수 선언
		let dailyDateArr = []; // date
		let dailyTotalArr = []; // total
		//device
		let dailyPCArr = []; // PC
		let dailyMOBILEArr = []; // MOBILE
		//browser
		let dailyIEArr = []; // IE
		let dailyEDGArr = []; // EDG
		let dailyCHROMEArr = []; // CHROME
		let dailyOPERAArr = []; // OPERA
		let dailySAFARIArr = []; // SAFARI
		let dailyETCArr = []; // ETC
		
		loginCntArr.forEach(function(item) {
			dailyDateArr.push(item.LOGIN_DATE);
			dailyTotalArr.push(item.LOGIN_TOTAL_CNT);
			//device
			dailyPCArr.push(item.LOGIN_PC_CNT);
			dailyMOBILEArr.push(item.LOGIN_MOBILE_CNT);
			//browser
			dailyIEArr.push(item.LOGIN_IE_CNT)
			dailyEDGArr.push(item.LOGIN_EDGE_CNT)
			dailyCHROMEArr.push(item.LOGIN_CHROME_CNT)
			dailyOPERAArr.push(item.LOGIN_OPERA_CNT)
			dailySAFARIArr.push(item.LOGIN_SAFARI_CNT)
			dailyETCArr.push(item.LOGIN_ETC_CNT)
		});
		
		// total
		let totalSeries = [{name: 'PC',data: dailyPCArr,zIndex: 1}
							, {name: 'MOBILE',data: dailyMOBILEArr,zIndex: 1}
							, {name: 'Internet Explorer',data: dailyIEArr,zIndex: 1}
							, {name: 'Microsoft Edge',data: dailyEDGArr,zIndex: 1}
							, {name: 'Chrome',data: dailyCHROMEArr,zIndex: 1}
							, {name: 'Opera',data: dailyOPERAArr,zIndex: 1}
							, {name: 'Safari', data: dailySAFARIArr,zIndex: 1}
							, {name: '기타',data: dailyETCArr,zIndex: 1}
							, {name: '총 방문자 수',type: 'column',yAxis: 0,data: dailyTotalArr}];
		
		// 기기별 
		let loginDeviceSereis = [{ name: 'PC',data: dailyPCArr}
								, {name: 'MOBILE',data: dailyMOBILEArr}];
		
		// 브라우저별
		let loginBrowserSereis = [{name: 'Internet Explorer',data: dailyIEArr}
								, {name: 'Microsoft Edge',data: dailyEDGArr}
								, {name: 'Chrome',data: dailyCHROMEArr}
								, {name: 'Opera',data: dailyOPERAArr}
								, {name: 'Safari', data: dailySAFARIArr}
								, {name: '기타',data: dailyETCArr}]; 
		
		// total-chart
		loginChart('loginChart', 'line', '일별 로그인 통계 (Total)', '로그인 수' , dailyDateArr, totalSeries);
		loginChart('loginChart_01', 'line', '접속 기기별 로그인 통계', '로그인 수' , dailyDateArr, loginDeviceSereis);
		loginChart('loginChart_02', 'column', '브라우저별 로그인 통계', '로그인 수' , dailyDateArr, loginBrowserSereis);
		
		//chart 
		/* 차트가 많아지면 보기 힘들어서 함수로 빼기...(예정)
		Highcharts.chart('loginChart', {
	        chart: {
	            type: 'line'
	        },
	        title: {
	            text: '일별 로그인 통계',
	            style: {
		        	fontWeight: 'bold'
		        }
	        },
	        xAxis: {
	            categories: dailyDateArr
	        },
	        yAxis: {
	            title: {
	                text: '로그인 수'
	            }
	        },
	        series: [{
	            name: '로그인(기본)',
	            data: dailyBasicArr,
	            zIndex: 1
	        },{
	            name: '로그인(카카오)',
	            data: dailyKAKAOArr,
	            zIndex: 1
	        },{
	            name: '로그인(네이버)',
	            data: dailyNAVERArr,
	            zIndex: 1
	        },{
	            name: 'PC',
	            data: dailyPCArr,
	            zIndex: 1
	        }, {
	            name: 'MOBILE',
	            data: dailyMOBILEArr,
	            zIndex: 1
	        }, {
	            name: 'Internet Explorer',
	            data: dailyIEArr,
	            zIndex: 1
	        }, {
	            name: 'Microsoft Edge',
	            data: dailyEDGArr,
	            zIndex: 1
	        }, {
	            name: 'Chrome',
	            data: dailyCHROMEArr,
	            zIndex: 1
	        }, {
	            name: 'Opera',
	            data: dailyOPERAArr,
	            zIndex: 1
	        }, {
	            name: 'Safari',
	            data: dailySAFARIArr,
	            zIndex: 1
	        }, {
	            name: '기타',
	            data: dailyETCArr,
	            zIndex: 1
	        }, {
	            name: '총 방문자 수',
	            type: 'column',
	            yAxis: 0,
	            data: dailyTotalArr
	        }], 
	        credits: [{
		    	enabled: true
		    }]
	    });
		*/
		<%-- 기간 필터링 버튼 --%>
		// filtering - date button click
		$(".input_button_em button").click(function() {
			var today = new Date();
		    var startDate = new Date();
		    var endDate = new Date();
			
		 	// button type 에 따라 처리
		    switch (this.value) {
		        case "a": // 1주일
		            startDate.setDate(today.getDate() - 6); // 현재일로부터 7일 전
		            break;
		        case "b": // 1개월
		            startDate.setMonth(today.getMonth() - 1); // 현재월로부터 1개월 전
		            break;
		        case "c": // 3개월
		            startDate.setMonth(today.getMonth() - 3); // 현재월로부터 3개월 전
		            break;
		        case "d": // 6개월
		            startDate.setMonth(today.getMonth() - 6); // 현재월로부터 6개월 전
		            break;
		        case "e": // 1년
		            startDate.setFullYear(today.getFullYear() - 1); // 현재년도로부터 1년 전
		            break;
		    }
		    // endDate는 항상 현재일로 설정
		    endDate = today;
		    
		    // form전송
			$("#s_date_start").val(DateFormat(startDate));
			$("#s_date_end").val(DateFormat(endDate));
			$("#frm").attr("action","<c:url value='/admmgr/member/loginStatistics.do'/>");
			$("#frm").submit();
		});
		
		
	});
	<%-- 날짜체크 --%>
	function check_date() {
		var st = $("#s_date_start").val();
		var et = $("#s_date_end").val();
		if(st != "" && et != "") {
			if(st > et) {
				alert("조회 시작일자는 종료일자 이후의 날은 조회가 불가능합니다.");
				return false;
			}
			return true;
		}
		return true;
	};
	
	function fn_Search() {
		if(check_date()) {
			$("#frm").attr("action","<c:url value='/admmgr/member/loginStatistics.do'/>");
			$("#frm").submit();
		}
		return false;
	};
	
	/* 로그관리 > 로그 통계 (2024-07-25) */
	function loginChart(chartId, type, title, y_title, dateArr, series) {
		if (type != 'pie') {
			//chart
			Highcharts.chart(chartId, {
		        chart: {
		            type: type
		        },
		        title: {
		            text: title,
		            style: {
			        	fontWeight: 'bold'
			        }
		        },
		        xAxis: {
		            categories: dateArr
		        },
		        yAxis: {
		            title: {
		                text: y_title
		            }
		        },
		        series: series, 
		        credits: [{
			    	enabled: true
			    }]
		    });
		} else {
			// pie chart
			Highcharts.chart(chartId, {
			    chart: {
			        plotBackgroundColor: null,
			        plotBorderWidth: null,
			        plotShadow: false,
			        type: type
			    },
			    title: {
		            text: title,
		            style: {
			        	fontWeight: 'bold'
			        }
		        },
			    tooltip: {
			        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
			    },
			    accessibility: {
			        point: {
			            valueSuffix: '%'
			        }
			    },
			    plotOptions: {
			        pie: {
			            allowPointSelect: true,
			            cursor: 'pointer',
			            dataLabels: {
			                enabled: false
			            },
			            showInLegend: true
			        }
			    },
			    series: series
			});
		}
		
	}
</script>


<form id="frm" name="frm" method="POST">
<!-- 검색 -->
<div class="search_form_wrap mb10">
	<div class="search_form_inner">
		<div class="filter_form">
			<div>
				<%-- <label>검색조건</label>
				<select id="searchfield" name="searchfield" class="form_select md" title="검색조건 선택">
					<option value="ALL">전체</option>
					<option value="USER_ID" ${ param.searchfield eq 'USER_ID' ? "selected='selected'" : "" }>아이디</option>
					<option value="USER_NM" ${ param.searchfield eq 'USER_NM' ? "selected='selected'" : "" }>성명</option>
					<option value="EMAIL" ${ param.searchfield eq 'EMAIL' ? "selected='selected'" : "" }>이메일</option>
				</select>
				<input type="text" id="searchword" name="searchword" class="form_text md wd300" value="<c:out value="${param.searchword}"/>" placeholder="검색어를 입력해 주세요"/> --%>
			</div>

			<div>
				<label>기간설정</label>
				<div>
					<span class="form_date">
						<input type="text" id="s_date_start" name="s_date_start" placeholder="시작일 입력" class="form_text wd140" value="<c:out value="${(not empty param.s_date_start) ? param.s_date_start :  s_date_start}"/>" onclick="calendar(event,'s_date_start','yyyy-mm-dd')">
						<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_start').trigger('click');">
					</span>
					~
					<span class="form_date">
						<input type="text" id="s_date_end" name="s_date_end" placeholder="종료일 입력" class="form_text wd140" value="<c:out value="${(not empty param.s_date_end) ? param.s_date_end :  s_date_end}"/>" onclick="calendar(event,'s_date_end','yyyy-mm-dd')" >
						<input type="button" class="btn_form_date" onclick="javascript:$('#s_date_end').trigger('click');">
					</span>
				</div>
				
				<!-- date button group  -->
				<div>
					<em class="input_button_em">
						<button type="button" value="a">1주일</button>
						<button type="button" value="b">1개월</button>
						<button type="button" value="c">3개월</button>
						<button type="button" value="d">6개월</button>
						<button type="button" value="e">1년</button>
					</em>
				</div>
				
			</div>

			<input type="button" class="btn_ico_search" title="검색" onClick="javascript:fn_Search(); return false;"/>
		</div>
	</div>
</div>
<!-- // 검색 -->



<div class="tit_btn_wrap">
	<div class="chart_section">
		<div id="loginChart"></div>
	</div>
	<div class="log_chart_div">
		<div class="chart_section">
			<div id="loginChart_01"></div>
		</div>
		<div class="chart_section">
			<div id="loginChart_02"></div>
		</div>
		<!-- <div class="chart_section">
			<div id="loginChart_03"></div>
		</div> -->
	</div>
</div>

</form>
</body>