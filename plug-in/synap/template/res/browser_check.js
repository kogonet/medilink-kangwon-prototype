function initBROWSER() {
	return {
		NAVIGATOR: {
			appName: undefined,
			userAgent: undefined
		},
		PC: {
			isIE: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.appName == 'Microsoft Internet Explorer');
			},

			isFirefox: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.userAgent.indexOf('Firefox') > -1);
			},

			isChrome: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.userAgent.indexOf('Chrome') > -1);
			},

			isSafari: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.userAgent.indexOf('Safari') > -1);
			},

			isOpera: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.userAgent.indexOf('Opera') > -1);
			},

			isEdge: function () {
				return (!BROWSER.isMobile() && BROWSER.NAVIGATOR.userAgent.indexOf('Edge') > -1);
			}
		},

		MOBILE: {
			isAndroid: function () {
				return (BROWSER.NAVIGATOR.userAgent.indexOf('Android') > -1);
			},

			isIOS: function () {
				return (BROWSER.NAVIGATOR.userAgent.indexOf('iPad') > -1) || (BROWSER.NAVIGATOR.userAgent.indexOf('iPhone') > -1) || (BROWSER.NAVIGATOR.userAgent.indexOf('iPod') > -1);
			},

			isWindowMobile: function () {
				return (BROWSER.NAVIGATOR.userAgent.indexOf('IEMobile') > -1);
			}
		},

		isMobile: function () {
			return BROWSER.MOBILE.isAndroid() || BROWSER.MOBILE.isIOS() || BROWSER.MOBILE.isWindowMobile();
		},

		VERSION: {
			Chrome : function() {
				var ua = BROWSER.NAVIGATOR.userAgent;
				var versionIdx = ua.indexOf('Chrome/') + 7;
				var versionStr = ua.substr(versionIdx);
				versionStr = versionStr.substr(0, versionStr.indexOf('.'));
				try {
					return parseInt(versionStr);
				} catch (e) {
					console.log("Not found chrome version.")
				}
				return 0;
			},
			firefox: function () {
				var ua = BROWSER.NAVIGATOR.userAgent;
				var versionIdx = ua.indexOf('Firefox/') + 8;
				var versionStr = ua.substr(versionIdx);
				versionStr = versionStr.substr(0, versionStr.indexOf('.'));
				try {
					return parseInt(versionStr);
				} catch (e) {
					console.log("Not found firefox version.")
				}
				return 0;
			},
			IE: function () {
				var ua = BROWSER.NAVIGATOR.userAgent;
				// find Trident Engine Version
				var engineIdx = ua.indexOf('Trident/') + 8;
				var engineVerStr = ua.substr(engineIdx);
				engineVerStr = engineVerStr.substr(0, engineVerStr.indexOf('.'));
				try {
					var engineNum = parseInt(engineVerStr);
					if (engineNum == 7) {
						return 11;
					} else if (engineNum == 6) {
						return 10;
					} else if (engineNum == 5) {
						return 9;
					} else if (engineNum == 4) {
						return 8;
					} else if (engineNum == 3) { return 7; }
				} catch (e) {
					console.log("Not found IE version.")
				}

				// find MSIE compatible
				var versionIdx = ua.indexOf('MSIE ') + 5;
				var versionStr = ua.substr(versionIdx);
				versionStr = versionStr.substr(0, versionStr.indexOf('.'));
				try {
					return parseInt(versionStr);
				} catch (e) {
					console.log("Not found IE version.")
				}
				return 0;
			},
			android: function () {
				var ua = BROWSER.NAVIGATOR.userAgent;
				var versionIdx = ua.indexOf('Android ') + 8;
				var versionStr = ua.substr(versionIdx);
				versionStr = versionStr.substr(0, versionStr.indexOf('.'));
				try {
					return parseInt(versionStr);
				} catch (e) {
					console.log("Not found android version.")
				}
				return 0;
			},
			IOS: function () {
				var ua = BROWSER.NAVIGATOR.userAgent;
				//var versionIdx = ua.indexOf('CPU OS ') + 7;
				var versionIdx = ua.indexOf('OS ') + 3;
				var versionStr = ua.substr(versionIdx);
				versionStr = versionStr.substr(0, versionStr.indexOf('_'));
				try {
					return parseInt(versionStr);
				} catch (e) {
					console.log("Not found iOS version.")
				}
				return 0;
			}
		}
	};
}

function initNavigator() {
	BROWSER.NAVIGATOR.appName = navigator.appName;
	BROWSER.NAVIGATOR.userAgent = navigator.userAgent;
}

//initialize
var BROWSER = initBROWSER();
initNavigator();

//only unit test
if (typeof exports !== "undefined") {
	exports.BROWSER = BROWSER;
}