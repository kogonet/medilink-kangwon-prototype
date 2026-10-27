/**
 * log.js
 */
function setCookie() {
	var previousResolution = getCookie("resolution");
	
	if (!previousResolution) {
        // 쿠키가 없는 경우, 현재 해상도를 설정
        saveResolutionToCookie();
    }
}
function getCookie(name) {
    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    if (match) {
        return decodeURIComponent(match[2]);
    }
    return null;
}
function saveResolutionToCookie() {
    var currentResolution = window.screen.width + "x" + window.screen.height;
    var previousResolution = getCookie("resolution");

    // 이전 해상도와 현재 해상도가 다를 경우에만 쿠키 업데이트
    if (previousResolution !== currentResolution) {
        // 쿠키에 저장 (7일 동안 유지)
        var expires = new Date();
        expires.setTime(expires.getTime() + (7 * 24 * 60 * 60 * 1000)); 
        document.cookie = "resolution=" + encodeURIComponent(currentResolution) + "; expires=" + expires.toUTCString() + "; path=/";
    }
}