/**
 * common.js
 */

// paging - front
function G_MovePage(pageNo){
	var moveUrl = $(location).attr("pathname");
	var objForm = $("<form/>").attr({
		"id"     : "GLOVAL_PAGE_FORM",
		"name"   : "GLOVAL_PAGE_FORM",
		"action" : moveUrl,
		"target" : "_self",
		"method" : "POST"
	});
	$("<input/>").attr({"type":"hidden","id":"origin_search_keyword","name":"origin_search_keyword","value":$("#origin_search_keyword").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"searchfield","name":"searchfield","value":$("#searchfield").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"type","name":"type","value":$("#type").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"category","name":"category","value":$("#category").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"input_text","name":"input_text","value":$("#input_text").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"record_cnt","name":"record_cnt","value":$("#record_cnt").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"course_layout_type","name":"course_layout_type","value":$("#course_layout_type").val()}).appendTo(objForm);
	
	
/*	
	$("<input/>").attr({"type":"hidden","id":"sDateEnd","name":"sDateEnd","value":$("input[name=sDateEnd]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_date_start","name":"s_date_start","value":$("input[name=s_date_start]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_date_end","name":"s_date_end","value":$("input[name=s_date_end]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"largeCategory","name":"largeCategory","value":$("#largeCategory").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"middleCategory","name":"middleCategory","value":$("#middleCategory").val()}).appendTo(objForm);

	$("<input/>").attr({"type":"hidden","id":"s_eval_tp_1","name":"s_eval_tp_1","value":$("input[name=s_eval_tp_1]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_eval_status_cd","name":"s_eval_status_cd","value":$("input[name=s_eval_status_cd]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_org_nm_1","name":"s_org_nm_1","value":$("input[name=s_org_nm_1]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_assign_tp","name":"s_assign_tp","value":$("input[name=s_assign_tp]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"s_assign_nm_1","name":"s_assign_nm_1","value":$("input[name=s_assign_nm_1]").val()}).appendTo(objForm);

	
	
	if( $("input[name=noticeNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"noticeNo","name":"noticeNo","value":$("input[name=noticeNo]").val()}).appendTo(objForm);
	if( $("input[name=assignNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"assignNo","name":"assignNo","value":$("input[name=assignNo]").val()}).appendTo(objForm);
	if( $("input[name=assignAppNo]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"assignAppNo","name":"assignAppNo","value":$("input[name=assignAppNo]").val()}).appendTo(objForm);
	if( $("input[name=assignAppConfigNo]").length > 0 )			$("<input/>").attr({"type":"hidden","id":"assignAppConfigNo","name":"assignAppConfigNo","value":$("input[name=assignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=stepNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"stepNo","name":"stepNo","value":$("input[name=stepNo]").val()}).appendTo(objForm);
	if( $("input[name=layerStepYn]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"layerStepYn","name":"layerStepYn","value":$("input[name=layerStepYn]").val()}).appendTo(objForm);
	if( $("input[name=subTabNo]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"subTabNo","name":"subTabNo","value":$("input[name=subTabNo]").val()}).appendTo(objForm);
	if( $("input[name=resultUrl]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"resultUrl","name":"resultUrl","value":$("input[name=resultUrl]").val()}).appendTo(objForm);
	if( $("input[name=configTp]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"configTp","name":"configTp","value":$("input[name=configTp]").val()}).appendTo(objForm);
	if( $("input[name=pre_pAssignAppConfigNo]").length > 0 )	$("<input/>").attr({"type":"hidden","id":"pre_pAssignAppConfigNo","name":"pre_pAssignAppConfigNo","value":$("input[name=pre_pAssignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=pAssignAppConfigNo]").length > 0 )		$("<input/>").attr({"type":"hidden","id":"pAssignAppConfigNo","name":"pAssignAppConfigNo","value":$("input[name=pAssignAppConfigNo]").val()}).appendTo(objForm);
	if( $("input[name=assignDtlNm]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"assignDtlNm","name":"assignDtlNm","value":$("input[name=assignDtlNm]").val()}).appendTo(objForm);
	if( $("input[name=assignTp]").length > 0 )					$("<input/>").attr({"type":"hidden","id":"assignTp","name":"assignTp","value":$("input[name=assignTp]").val()}).appendTo(objForm);
	if( $("input[name=layerIndex]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"layerIndex","name":"layerIndex","value":$("input[name=layerIndex]").val()}).appendTo(objForm);
	if( $("input[name=selectorIndex]").length > 0 )				$("<input/>").attr({"type":"hidden","id":"selectorIndex","name":"selectorIndex","value":$("input[name=selectorIndex]").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"list_show_cnt","name":"list_show_cnt","value":$("#list_show_cnt").val()}).appendTo(objForm);
	$("<input/>").attr({"type":"hidden","id":"noticeNo","name":"noticeNo","value":$("#noticeNo").val()}).appendTo(objForm);
 */
	
	$("<input/>").attr({"type":"hidden","id":"page","name":"page","value":pageNo}).appendTo(objForm);
	
	
	$(document.body).append(objForm);
	objForm.submit();
}

// 스크롤 효과
$(document).ready(function() {
    // 스크롤 이벤트
    $(window).scroll(function() {
        var scrollTop = $(window).scrollTop();
        var windowHeight = $(window).height();
        
        // 비주얼 영역이 위로 올라가는 효과
        if (scrollTop > 100) {
            $('body').addClass('scrolled');
        } else {
            $('body').removeClass('scrolled');
        }
        
        // 컨텐츠 아이템들이 나타나는 효과
        $('.content_item').each(function() {
            var elementTop = $(this).offset().top;
            var elementBottom = elementTop + $(this).outerHeight();
            var viewportTop = scrollTop;
            var viewportBottom = viewportTop + windowHeight;
            
            if (elementBottom > viewportTop && elementTop < viewportBottom) {
                $(this).addClass('visible');
            }
        });
    });
    
    // 초기 로드 시 첫 번째 아이템은 바로 보이게
    $('.content_item').first().addClass('visible');
    
    // Swiper 초기화
    if (typeof Swiper !== 'undefined') {
        const visualSwiper = new Swiper('.visual_swiper', {
            loop: true,
            autoplay: {
                delay: 10000,
                disableOnInteraction: false,
            },
            navigation: {
                nextEl: '.pagination_next',
                prevEl: '.pagination_prev',
            },
            pagination: {
                el: '.swiper-pagination',
                type: 'fraction',
            },
            effect: 'fade',
            fadeEffect: {
                crossFade: true
            },
            speed: 1000,
        });
        
        // 일시정지 버튼 기능
        const pauseBtn = document.getElementById('pauseBtn');
        let isPaused = false;
        
        pauseBtn.addEventListener('click', function() {
            if (isPaused) {
                visualSwiper.autoplay.start();
                pauseBtn.innerHTML = '⏸';
                isPaused = false;
            } else {
                visualSwiper.autoplay.stop();
                pauseBtn.innerHTML = '▶';
                isPaused = true;
            }
        });
        
        // 컨텐츠 슬라이더 초기화
        const contentSwiper = new Swiper('.content_swiper', {
            loop: true,
            autoplay: {
                delay: 5000,
                disableOnInteraction: false,
            },
            navigation: {
                nextEl: '.content_next',
                prevEl: '.content_prev',
            },
            effect: 'fade',
            fadeEffect: {
                crossFade: true
            },
            speed: 1000,
            on: {
                slideChange: function() {
                    // 페이지네이션 업데이트
                    const navItems = document.querySelectorAll('.content_pagination .nav_item');
                    const currentIndex = this.realIndex % navItems.length;
                    navItems.forEach((item, index) => {
                        item.classList.remove('active');
                        if (index === currentIndex) {
                            item.classList.add('active');
                        }
                    });
                },
                init: function() {
                    // 초기 로드 시 첫 번째 슬라이드 활성화
                    const navItems = document.querySelectorAll('.content_pagination .nav_item');
                    navItems.forEach((item, index) => {
                        item.classList.remove('active');
                        if (index === 0) {
                            item.classList.add('active');
                        }
                    });
                }
            }
        });
        
        // 페이지네이션 클릭 이벤트
        document.querySelectorAll('.content_pagination .nav_item').forEach((item, index) => {
            item.addEventListener('click', function() {
                contentSwiper.slideTo(index);
            });
        });
    }
});