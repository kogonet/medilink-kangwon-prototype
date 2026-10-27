function initLocalSynap(){
window.localSynap = {}
// LocalSynap
window.localSynap.config = {
	/**
	 * zoom 범위를 설정합니다
	 * default: [25, 50, 100, 150, 200]
	 */
	"ZOOM_LIST": [],

	/**
	 * 웹페이지와 헤더 타이틀 설정합니다.
	 * headerTitle 스킨 헤더에 문서명 표시여부를 설정합니다.
	 * webTitle 웹페이지 제목을 문서명으로 변경할지 여부를 설정합니다.
	 *          웹페이지 제목은 브라우저 탭에 표시됩니다.
	 * default
	 *     headerTitle: false
	 *     webTitle: false
	 */
	"showTitle": {
		"headerTitle": false,
		"webTitle": false,
	},

	/**
	 * 헤더 show(true)/hide(false) 노출 여부를 설정합니다
	 * default: show
	 */
	"isShowHeader": true,

	/**
	 * 모바일 환경에서 헤더를 일정시간 후 숨길지(true) 계속해서 나타낼지(false) 설정합니다.
	 * isShowHeader가 show(true)인 경우에만 동작합니다.
	 * default: hide
	 */
	"headerAutoHide": true,

	/**
	 * 정보메뉴 show(true)/hide(false) 표시 여부를 설정합니다.
	 * default: show
	 */
	"isShowInfo": true,

	/**
	 * 정보메뉴에 표시되는 회사/기관 이름을 설정합니다.
	 * default: show
	 */
	"companyName":'',

	/**
	 * 브라우저 인쇄 방지 사용 true(사용) / false(미사용)을 설정합니다
	 * default: false
	 */
	"preventPrint": false,

	/**
	 * 브라우저 인쇄메뉴 show(true)/hide(false)을 설정합니다. 이미지, PDF, 워드 계열 포맷만 지원
	 * preventPrint 기능과 같이 사용하지 마세요.
	 * default: hide
	 */
	"isShowPrint": false,

	/**
	 * 이미지 변환 - 셀 포맷의 브라우저 인쇄메뉴 show(true)/hide(false)을 설정합니다.
	 * isShowPrint 기능과 같이 사용하세요. 셀 인쇄만 사용하지 않습니다.
	 * preventPrint 기능과 같이 사용하지 마세요.
	 * A4영역보다 크면 브라우저에서 누락시키므로 사용을 권장하지 않습니다.
	 * default: hide
	 */
	"isShowPrintForCell": false,

	/**
	 * PDF 인쇄메뉴 show(true)/hide(false)을 설정합니다.
	 * 서버이고 v2022이면 모든 포맷을 PDF로 만들어서 인쇄할 수 있도록 합니다.
	 * preventPrint 설정에 영향받지 않습니다.
	 * default: hide
	 */
	 "isShowPdfPrint": false,

	/**
	 * 복사 허용 true(사용) / false(미사용)을 설정합니다
	 * 복사방지하려면 false(허용안함)로 설정
	 * default: true
	 */
	"allowCopy": true,

	/**
	 * 시트 최소 사이즈(넓이, 높이)를 설정합니다. 빈 배열로 설정하면 원본 시트 크기를 사용합니다.
	 * 크기를 설정하고 시트크기가 설정한 크기보다 작으면 시트 크기를 넓혀서 표시합니다.
	 * 확장되는 시트영역은 흰색으로 표시됩니다.
	 * 단위 : 픽셀(px)
	 * 범위 : [0, 0] ~ [100000, 100000]
	 * default: 원래 시트 크기가 적용됨
	 */
	"sheetMinSize": [],

	/**
	 * API 호출 시 추가로 보낼 파라메터를 설정합니다.
	 * 오브젝트 형태로, { 'key' : 'value' } 의 형태로 설정합니다.
	 */
	"extraParam": {
	},

	/**
	 * API 호출 시 추가로 보낼 헤더를 설정합니다.
	 * 오브젝트 형태로, { 'key' : 'value' } 의 형태로 설정합니다.
	 */
	"extraHeader": {
	},

	/**
	 * 문서 로드시 발생하는 오류코드에 대한 커스텀 에러 메세지 처리 함수를 설정합니다
	 * @param {number} errCode 숫자 타입의 에러코드가 전송됩니다.
	 * @return {string} 스킨에 표시할 에러 메세지를 반환해야 합니다.
	 */
	"loadErrorHandler": function(errCode) {
		return "";
	},

	/**
	 * contextPath가 파라메터에 없는 경우 사용할 기본 contextPath를 설정합니다.
	 * html모듈용 스킨에서는 rs가 파라메터에 없는 경우 사용할 기본 rs를 설정합니다.
	 */
	"contextPath": "/SynapDocViewServer",

	/**
	 * 데스크탑 모드에서 처음 로딩시 썸네일 표시 여부를 설정합니다.
	 * 썸네일이 열린채로 로딩되게 하려면 true로 설정합니다.
	 * default: false
	 */
	"showThumbnail": false,

	/**
	 * 모바일 모드에서 처음 로딩시 썸네일 표시 여부를 설정합니다.
	 * 썸네일이 열린채로 로딩되게 하려면 true로 설정합니다.
	 * default: false
	 */
	"showThumbnailMobile": false,

	// sns 공유메뉴 show(true)/hide(false),
	// default: hide
	"isShowSns": false,

	// sns 공유기능에서 모바일 카카오톡api키 설정 ex)'abcdefghijklmn12021'
	"kakaoAPIKey": '',

	/**
	 * 컨트롤바가 사라지는 시간을 설정합니다.
	 * 단위: ms
	 * default: 3000
	 */
	"controllbarFadeoutTimeout": 3000,

	/**
	 * 기능바 위치를 설정합니다. 빈 객체로 설정하면 문서 중앙 하단에 위치합니다.
	 * 오브젝트 형태로, { 'key' : 'value' } 의 형태로 설정합니다.
	 * 'left', 'right' 중 택 1, 'top', 'bottom' 중 택 1 하여 설정하여야합니다. 동시 사용 불가
	 * 'left', 'right' 값을 설정하지 않거나, 모두 설정하면 좌우 중앙에 위치되고, top/bottom 값만 적용됩니다.
	 * 	 문서영역의 오른쪽을 기준으로 설정하려면 'right': {px값},
	 * 	 문서영역의 왼쪽을 기준으로 설정하려면 'left':{px값},
	 * 	 화면에서 아래쪽을 기준으로 위치를 설정하려면 'bottom':{px값}, 'top' 사용 불가
	 *	 화면에서 위쪽을 기준으로 위치를 설정하려면 'top':{px값}, 'bottom' 사용 불가 
	 * 	 예시) {'left':'50px', 'top':'0px'}
	 * default: 문서 중앙 하단에 위치
	 */
    "controllbarPosition": {},

	/**
	 * 처음 로딩 시 페이지 맞춤 옵션을 설정합니다.(데스크탑용)
	 * 0 : 페이지 맞춤
	 * 1 : 페이지 너비 맞춤
	 * 2 : 원본크기
	 * default: 0
	 */
	"loadingPageFitType" : 0,

	/**
	 * 처음 로딩 시 페이지 맞춤 옵션을 설정합니다.(모바일용)
	 * 0 : 페이지 맞춤
	 * 1 : 페이지 너비 맞춤
	 * 2 : 원본크기
	 * default: 0
	 */
	"loadingPageFitTypeForMobile" : 0,

	/**
	 * thumbnail 호출 시, 요청할 확장자 
	 * 빈 값(default)일 때 "png" 로 호출합니다.
	 * 문서뷰어 이미지 모듈에서만 동작합니다.
	 * default: ""
	 */
	"thumbnailExt": "",

	/**
	 * 텍스트 표시 및 검색 기능 사용 여부를 설정합니다.
	 * 텍스트 표시 및 검색 기능을 사용하려면 true로 설정합니다.
	 * 미지원 환경 : 모바일 모드(가로 768px 이하), 모바일 기기
	 * default: false
	 */
	"search": false,

	/**
	 * 어노테이션 기능(마커, PDF 내보내기) 활성화 여부를 설정합니다.
	 * 주의 : PDF 문서에 사이냅이 지원하는 어노테이션(사각형, 선, 펜, 메모)외의 어노테이션이 있는 PDF를 변환하면, 이미지에 함께 렌더링 되어 출력됩니다. 이미지에 함께 렌더링된 어노테이션은 수정 불가능합니다.
	 * 문서뷰어 서버에서만 동작합니다.
	 * default: false
	 */
	"useAnnotation": false,

	/**
	 * 본문영역의 툴팁 여부를 설정합니다.
	 * 본문영역의 툴팁을 제거하려면 true로 설정합니다.
	 * default: true
	 */
	"removeContentsAreaTooltip": true,

	/**
	 * PDF 문서의 회전 기능을 사용할 수 있도록 설정합니다.
	 * (주의 : useAnnotation, search 옵션이 켜져있는 경우에는 동작하지 않습니다.)
	 * default: false
	 */
	"rotatePdf": false,

	/**
	 * 브라우저 줌 배율에 관계없이 화면에 맞게 페이지맞춤, 페이지너비맞춤 기능이 동작하도록 설정합니다.
	 * internet explorer, chrome 브라우저에서만 동작합니다.
	 * default: false
	 */
	"fixedPageFit": false,

	/**
	 * 페이지 변환 범위에 따른 로딩방식을 설정합니다.
	 * '부분 변환' 기능은 부분 변환된 페이지 범위만 보여줍니다. 페이지 수는 변환된 시작페이지 번호와 관계없이 무조건 1로 설정됩니다.
	 * (주의 : 동적 변환 서버 사용시 '전체 변환'으로 설정 해야 합니다.)
	 * 0: 전체 변환
	 * 1: 부분 변환
	 * default: 0
	 */
	"loadingRangeType": 0,

	/**
	 * 마커의 초기 스타일을 설정합니다.
	 * 만약 속성값이 유효하지 않을 경우, 문서 뷰어의 기본 값으로 설정됩니다.
	 * 각 속성 별 유효 값은 아래와 같습니다.
	 * * color 		: 'type2' - 'type24'	(각 type에 매칭되는 색상은 매뉴얼을 참고하여 작성하여 주십시오)
	 * * innerColor : 'type1' - 'type24'	(각 type에 매칭되는 색상은 매뉴얼을 참고하여 작성하여 주십시오)
	 * * thickness 	: 1 - 16(px)
	 * * transparency : 0 - 100(주의 : 100을 입력하면 완전 투명해서 어노테이션이 보이지 않습니다.)
	 */
	 "markerStyle": {
		// 'color':'type2',
		// 'innerColor':'type1',
		// 'thickness': 3,
		// 'transparency': 50
	},
	
	/**
	 * 어노테이션 모드 전환시 사용할 도구를 설정합니다.
	 * 가능한 도구 : select, pencil, line, square, memo, freetext, circle, arrowline
	 * default: select
	 */
	"initAnnotType": "select",

	/**
	 * TTS 기능을 설정합니다.
	 * TTS 기능을 사용하려면 true로 설정합니다.
	 * default: false
	 */
	"useTTS": false,

	/**
	 * 배경색 전환 버튼 show(true)/hide(false) 표시 여부를 설정합니다.
	 * default: false
	 */
	"isShowBgColor": false
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

/*
 * 사용자 지정 함수 정의
 * 문서뷰어가 로딩이 되고 난 후에 동작합니다.
 * 끝나는 시점에서 필요한 동작을 정의하거나,
 * 뷰어가 제공하는 페이지 이동과 PDF검색을 정의할 수 있습니다.
 */
/*
localSynap['onLoadBody'] = function() {
	var getParameter = function (param) {
		var returnValue,
			url = location.href,
			parameters = (url.slice(url.indexOf('?') + 1, url.length)).split('&'),
			i,
			varName;
		for (i = 0; i < parameters.length; i = i + 1) {
			varName = parameters[i].split('=')[0];
			if (varName.toUpperCase() === param.toUpperCase()) {
				returnValue = parameters[i].split('=')[1];
				return decodeURIComponent(returnValue);
			}
		}
		return undefined;
	}
	var param = {
		movePage : 'pn',
		search : 'search'
	};
	// 페이지 이동 예시
	// 뷰어 로딩 후 지정된 페이지로 이동
	var pn = getParameter(param.movePage);
	if (pn!=undefined){
		localSynap.movePage && localSynap.movePage(pn);
	}
	// 검색 예시
	// 뷰어 로딩 후 지정된 검색어로 검색
	var keyword = getParameter(param.search);
	if (keyword!=undefined && localSynap.search){
		if(pn!=undefined) {
			localSynap.search(keyword, pn);
		} else {
			localSynap.search(keyword);
		}
	}
};
*/