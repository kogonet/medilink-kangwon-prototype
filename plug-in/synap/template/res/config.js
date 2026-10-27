function initLocalSynap(){
window.localSynap = {}
// LocalSynap
window.localSynap.config = {
    // zoom 범위
    // default: [25, 50, 100, 150, 200]
    "ZOOM_LIST": [],
    // 문서명(title) show(true)/hide(false)
    // default: false
    "isShowTitle": false,
    // 헤더 show(true)/hide(false)
    // default: show
    "isShowHeader": true,
    // 정보메뉴 show(true)/hide(false),
    // default: show
    "isShowInfo": true,
    // 회사/기관 이름
    // default: hide
    "companyName":'',
    // 인쇄 방지 사용 true(사용) / false(미사용)
    // default: false
    "preventPrint": false,
    // 복사 허용 true(사용) / false(미사용)
    // 복사방지하려면 false로 설정
    // default: true
    "allowCopy": true,
    // 시트 최소 사이즈(넓이, 높이)
    // 단위 : 픽셀(px)
    // 범위 : [0, 0] ~ [100000, 100000]
    // default: 원래 시트 크기가 적용됨
    "sheetMinSize": []
};
return window.localSynap;
}
// for view Ctrl NameSpace
function getSynapPageObject() {
	var obj = window;
	while(!(obj.localSynap) && obj != window.top) {
		try {
			if (obj.parent.localSynap) {}
		} catch(e) {
			return initLocalSynap();
		}
		obj = obj.parent;
	}
	if (obj.localSynap) {
		return obj.localSynap;
	}
	else {
		return initLocalSynap();
	}
}
var localSynap = getSynapPageObject();