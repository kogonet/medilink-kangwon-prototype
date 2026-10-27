// console.log( 'watermark.js' );

function tileFormat(type) {
    return type === "cell" || type === "xmldart";
}

function subdirFormat(type) {
    return type === "word" || type === "xmldart";
}

var rect = (function(){
    var rectObj = {};
    var orgRect = { x1 : 0, x2 : 0, y1 : 0, y2 : 0, degree : 0 };
    var boundingRect = {
        x1 : Number.POSITIVE_INFINITY,
        x2 : Number.NEGATIVE_INFINITY,
        y1 : Number.POSITIVE_INFINITY,
        y2 : Number.NEGATIVE_INFINITY
    };
    rectObj.setRect = function(_x1, _x2, _y1, _y2, _degree) {
        orgRect.x1 = _x1;
        orgRect.x2 = _x2;
        orgRect.y1 = _y1;
        orgRect.y2 = _y2;
        orgRect.degree = _degree;
    };
    rectObj.getPivot = function() { // 회전 중점
        var minX = Math.min(orgRect.x1, orgRect.x2);
        var minY = Math.min(orgRect.y1, orgRect.y2);
        var maxX = Math.max(orgRect.x1, orgRect.x2);
        var maxY = Math.max(orgRect.y1, orgRect.y2);

        return {
            x: maxX - ((maxX - minX) / 2),
            y: maxY - ((maxY - minY) / 2)
        }
    }
    rectObj.rotatePoint = function(pivot, point, cos, sin) {
        return {
          x: (cos * (point.x - pivot.x)) - (sin * (point.y - pivot.y)) + pivot.x,
          y: (sin * (point.x - pivot.x)) + (cos * (point.y - pivot.y)) + pivot.y
        };
    }
    rectObj.calcBoundingBox = function(pivot) {
        var radians = orgRect.degree * (Math.PI / 180);
        var cos = Math.cos(radians);
        var sin = Math.sin(radians);

        var points = [
            {x : orgRect.x1, y : orgRect.y1},
            {x : orgRect.x1, y : orgRect.y2},
            {x : orgRect.x2, y : orgRect.y1},
            {x : orgRect.x2, y : orgRect.y2}
        ]
        
        for(var i = 0; i < points.length; i++) {
            var rotatedPoint = this.rotatePoint(pivot, points[i], cos, sin);

            boundingRect.x1 = Math.min(boundingRect.x1, rotatedPoint.x);
            boundingRect.y1 = Math.min(boundingRect.y1, rotatedPoint.y);
            boundingRect.x2 = Math.max(boundingRect.x2, rotatedPoint.x);
            boundingRect.y2 = Math.max(boundingRect.y2, rotatedPoint.y);
        }
    };
    rectObj.getBoundingBox = function(x1, x2, y1, y2, degree) {
        rect.setRect(x1, x2, y1, y2, degree);
        rect.calcBoundingBox(rect.getPivot());
        return boundingRect;
    }
    return rectObj;
}());

var wm = (function(){
    var waterMarkObj = null;
    var property = {
        flieType : undefined,
        type : undefined,
        rotate : 0,
        tile : false,
        alpha : 0,
        left: 50,
        top: 50,
        width : 0,
        height : 0,
        textProperty : {
            string : undefined,
            font : undefined,
            fontColor : undefined,
            fontSize : undefined,
            align : "center"
        },
        imageProperty : {
            imgUrl : undefined,
            imgData : undefined,
        },
        tileSpacing: 0
    };
    var waterMark = {
        decrypt : function (str, type) {
            var arr = [];
            var decodeText = "";
            if(window.atob) {
                decodeText = atob(str);
            }
            else {
                var decodeBase64 = function(s) {
                    var e={},i,b=0,c,x,l=0,a,r='',w=String.fromCharCode,L=s.length;
                    var A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
                    for(i=0;i<64;i++){e[A.charAt(i)]=i;}
                    for(x=0;x<L;x++){
                        c=e[s.charAt(x)];b=(b<<6)+c;l+=6;
                        while(l>=8){((a=(b>>>(l-=8))&0xff)||(x<(L-2)))&&(r+=w(a));}
                    }
                    return r;
                };
                decodeText = decodeBase64(str);
            }
            
            for(var i = 0 ; i < decodeText.length-16 ; i++){
                arr.push(decodeText.charCodeAt(i+16) ^ decodeText.charCodeAt(i%16));
            }
            var decryptData = arrToString(arr);
            property.fileType = type;
            var jsonData = JSON.parse(decryptData);
            wm.parseJSON(jsonData);
        },
        // getXml : function (xmlUrl, fileType) {
        //     property.fileType = fileType;
            // $.ajax({
            //     type: 'GET',
            //     async: false,
            //     url: xmlUrl,
            //     dataType: 'xml',
            //     success: function(xmlDoc) {
            //         wm.parseXML(xmlDoc);
            //     },
            //     error: function (error) {
            //         console.log('Error : xml load fail!');
			// 	}
            // });
        // },
        isValid : function(value, defalut_value) {
            return  !(value === undefined || value === defalut_value);
        },
        isValidRange : function(value, min, max) {
            if(typeof(value) === 'number') {
                return min <= value && value <= max;
            }
            return false;
        },
        parseJSON : function(obj) {
            var infoXml = obj[0];
            property.tile = infoXml.hasOwnProperty("tile") ? infoXml["tile"] : property.tile;
            if(!property.tile) {
                property.left = wm.isValidRange(infoXml["left"], 0, 100) ? infoXml["left"] : property.left;
                property.top = wm.isValidRange(infoXml["top"], 0, 100) ? infoXml["top"] : property.top;
            }
            property.type = infoXml.hasOwnProperty("text") ? "text" : "image";
            var default_tileSpacing = 0;
            if(property.type === "text") {
                var fontName = infoXml["textFont"].toLowerCase();
                property.textProperty.font = fontName == "serif" ? "바탕체, BatangChe, Times New Roman, serif" : "굴림체, GulimChe, Arial, sans-serif";
                property.textProperty.fontColor = infoXml["textColor"];
                property.textProperty.fontSize = infoXml["textSize"];
                property.textProperty.string = infoXml["text"];
                property.textProperty.align = wm.isValid(infoXml["textAlign"], "center") ? infoXml["textAlign"] : property.textProperty.align;
                default_tileSpacing = wm.isValid(infoXml["tileSpacing"], -1) ? infoXml["tileSpacing"] : getPtToPx(property.textProperty.fontSize/2);
            }
            else if(property.type === "image") {
                if(infoXml.hasOwnProperty("imageData")) {
                    property.imageProperty.imgData = infoXml["imageData"];
                } else if(infoXml.hasOwnProperty("imagePath")) {
                    var imgName = infoXml["imagePath"].split("/");
                    var imgExt = imgName[imgName.length-1].split(".");
                    var imgPath = "wmImage." + imgExt[imgExt.length-1];
                    if(subdirFormat(property.fileType)) {
                        property.imageProperty.imgUrl = localSynap.getFileName() + ".files/" + imgPath;
                    }
                    else {
                        property.imageProperty.imgUrl = imgPath;
                    }
                }
                property.width = infoXml["width"] > 0 ? infoXml["width"] : 400;
                property.height = infoXml["height"] > 0 ? infoXml["height"] : 560;
            }
            if(property.tile || tileFormat(property.fileType)) {
                property.tileSpacing = wm.isValid(infoXml["tileSpacing"], -1) ? infoXml["tileSpacing"] : default_tileSpacing;
            }
            property.rotate = parseInt(infoXml["rotate"]) % 360;
            property.alpha = 1 - (parseFloat(infoXml["alpha"]) / 100);
        },
        getWM : function() {
            if(waterMarkObj === null) {
                wm.makeWM();
            }
            return waterMarkObj;
        },
        /**
        * cell과 xmldart 포맷 문서에서 watermark를 붙이는 함수. 워터마크를 4000px * 4000px 단위로 나눠서 적용한다
        * @boardWidth	워터마크를 적용할 컨텐츠 영역의 너비
        * @boardHeight	워터마크를 적용할 컨텐츠 영역의 높이
        */ 
        appendWM_cell : function(boardWidth, boardHeight) {
            localSynap.mark = wm.getWM();
            if(localSynap.mark != null && tileFormat(property.fileType)) {
                var maxLength = 4000;
                var originWidth = boardWidth;
                var originHeight = boardHeight;

                var top = 0;
                var left = 0;

                var repeatWidth = originWidth > maxLength ? maxLength : boardWidth;
                var repeatHeight = originHeight > maxLength ? maxLength : boardHeight;

                appendWB = function(parentNode, isSecondRepeat) {
                    var clone = wm.makeWB(repeatWidth,repeatHeight, isSecondRepeat);
                    $(clone).css("top",top).css("left",left);
                    $(parentNode).append(clone);
                    boardWidth -= repeatWidth;
                    left += repeatWidth;
                };

                repeatBoard = function() {
                    var fragment = document.createDocumentFragment();
                    while(boardHeight > 0) {
                        while(boardWidth > 0) {
                            if(boardWidth < repeatWidth) {
                                repeatWidth = boardWidth;
                            }
                            if(boardHeight < repeatHeight) {
                                repeatHeight = boardHeight;
                            }
                            appendWB(fragment, left!==0);
                        }
                        boardHeight -= repeatHeight;
                        left = 0;
                        boardWidth = originWidth;
                        repeatWidth = originWidth > maxLength ? maxLength : boardWidth;
                        top += repeatHeight
                    }
                    $("#container").append(fragment);
                };

                //먼저 보이는 영역부터 생성한다.
                var container = document.getElementById("container");
                appendWB(container, false);

                setTimeout(function() {
                    repeatBoard();
                },1000);
            }
        },
        makeWM : function() {
            waterMarkObj = document.createElement("div");
            stopBrowserEvent(waterMarkObj)
            if(property.type === "text") {
                $(waterMarkObj).css("float","left")
                               .css("word-wrap","normal")
                               .css("font-weight","bold")
                               .css("text-align",property.textProperty.align)
                               .css("color","#"+property.textProperty.fontColor)
                               .css("font-size",property.textProperty.fontSize+"pt")
                               .css("font-family",property.textProperty.font);
                var preTag = document.createElement("pre");
                preTag.className = "wt";
                $(preTag).text(property.textProperty.string);
                $(preTag).css("font-weight","bold")
                         .css("font-family",property.textProperty.font)
                         .css("font-size",property.textProperty.fontSize+"pt")
                         .css("color","#"+property.textProperty.fontColor)
                         .css("text-align","inherit")
                         .css("position","static")
                         .css("line-height","normal")
                         .css("margin","0px");
                $(waterMarkObj).append(preTag);
                setSize(preTag);
                $(preTag).css("opacity",property.alpha);
            }
            else if(property.type === "image") {
                waterMarkObj.className = "wm";
                $(waterMarkObj).css("float","left")
                               .css("width",property.width)
                               .css("height",property.height)
                               .css("text-align","center");
                var img = document.createElement("img");
                img.className = "wi";
                img.src = property.imageProperty.imgUrl !== undefined ? property.imageProperty.imgUrl : "data:image/png;base64," + property.imageProperty.imgData;
                $(img).css("width",property.width)
                      .css("height",property.height)
                      .css("opacity",property.alpha);
                $(waterMarkObj).append(img);
                setSize(waterMarkObj);
            }
        },
        getScreenWidth : function() {
            if(BROWSER.isMobile()) {
                var viewPortWidth = 1000; // cell의 뷰포트는 width가 1000 고정
                return viewPortWidth;
            }
            return screen.availWidth;
        },
        getScreenHeight : function() {
            if(BROWSER.isMobile()) {
                var viewPortWidth = 1000;
                var isLandScape = screen.availWidth > screen.availHeight;
                var availWidth = isLandScape ? screen.availHeight : screen.availWidth;
                var availHeight = isLandScape ? screen.availWidth : screen.availHeight
                var deviceHeight = (availHeight * viewPortWidth) / availWidth;
                return parseInt(deviceHeight);
            }
            var whiteSpace = window.outerHeight-window.innerHeight;
            return screen.availHeight-whiteSpace;
        },
        makeWB : function(parentWidth, parentHeight, isSecondRepeat) {
            var minimumWidth = parentWidth;
            var minimumHeight = parentHeight;
            if(tileFormat(property.fileType)) {
                var screenWidth = wm.getScreenWidth();
                minimumWidth = (screenWidth > parentWidth) && !isSecondRepeat ? screenWidth : parentWidth;
                var screenHeight = wm.getScreenHeight();
                minimumHeight = (screenHeight > parentHeight) && !isSecondRepeat ? screenHeight : parentHeight;
            }
            var waterMarkBoard = document.createElement("div");
            waterMarkBoard.className = "wb";
            waterMarkBoard.id = "wb";
            $(waterMarkBoard).css("height",minimumHeight)
                             .css("width",minimumWidth)
                             .css("position","absolute")
                             .css("top","0pt")
                             .css("left","0pt")
                             .css("right","0pt")
                             .css("bottom","0pt")
                             .css("z-index","4000000000")
                             .css("overflow","hidden");

            if(property.tile) {
                var rotateBoard = wm.makeRB(minimumWidth, minimumHeight);
                $(waterMarkBoard).append(rotateBoard);
            }else {
                wm.setPosition(waterMarkBoard, minimumWidth, minimumHeight);
            }

            return waterMarkBoard;
        },
        setTile : function(rep) {
            property.tile = rep;
        },
        boardResize : function(board, slideWidth, slideHeight, zoomRatio) {
            $(board).width(slideWidth); 
            $(board).height(slideHeight);
            $(board).css('transform', 'scale(' + zoomRatio + ')')
                    .css('transform-origin', "0px 0px");
        },
        //회전된 사각형의 가로,세로를 구함
        getRotateLength : function(currentWidth, currentHeight) {
            var deg2radians = Math.PI * 2 / 360;
            var rad = (360-property.rotate) * deg2radians;
            //0~90 or 181~270
            if((property.rotate >= 0 && property.rotate <= 90) || (property.rotate >= 181 && property.rotate <= 270)) {
                rad = (360-property.rotate) * deg2radians;
            }
            //91~180 or 271~360
            else if((property.rotate >= 91 && property.rotate <= 180) || (property.rotate >= 271 && property.rotate <= 360)) {
                rad = property.rotate * deg2radians;
            }
            var costheta = Math.cos(rad);
            var sintheta = Math.sin(rad);
            //회전에 따른 사각형 가로 세로 계산을 위한 좌표값
            var a = -currentWidth/2;
            var b = currentHeight/2;
            var x = -currentWidth/2;
            var y = -currentHeight/2;
            var bb = a*sintheta + b*costheta;
            var xx = x*costheta - y*sintheta;
            var rotateWidth = Math.abs(xx)*2;
            var rotateHeight = Math.abs(bb)*2;
            return [rotateWidth, rotateHeight];
        },
        makeRB : function(parentWidth, parentHeight) {
            var length = wm.getRotateLength(parentWidth, parentHeight);
            var rotateWidth = length[0];
            var rotateHeight = length[1];

            var rotateBoard = document.createElement("div");
            rotateBoard.className = "rotateBoard";
            $(rotateBoard).css("width",rotateWidth)
                          .css("height",rotateHeight)
                          .css("transform","rotate("+property.rotate+"deg)");

            $(rotateBoard).css("margin-left",(parentWidth - rotateWidth) / 2)
                          .css("margin-top",(parentHeight - rotateHeight) / 2);
            
            repeatCol(rotateBoard, rotateWidth, rotateHeight);
            return rotateBoard;
        },
        setPosition : function(waterMarkBoard, parentWidth, parentHeight) {
            var boundingBox = rect.getBoundingBox(0, property.width, 0, property.height, property.rotate);
            // 기준점
            var startX = -boundingBox.x1;
            var startY = -boundingBox.y1;
            var boundingBoxWidth = boundingBox.x2 - boundingBox.x1;
            var boundingBoxHeight = boundingBox.y2 - boundingBox.y1;
            var totalWidth = parentWidth - boundingBoxWidth;
            var totalHeight = parentHeight - boundingBoxHeight;
            var clone = $(waterMarkObj).clone();
            $(clone).css("position","absolute")
                    .css("top", startY + totalHeight * property.top / 100)
                    .css("left", startX + totalWidth * property.left / 100)
                    .css("transform","rotate("+property.rotate+"deg)");
            $(waterMarkBoard).append(clone);
        }
    };
    setSize = function(obj) {
        var clone = $(obj).clone();
        var body = document.getElementsByTagName("body")[0];
        $(clone).css("visibility","hidden")
                .css("width","")
                .css("float","left");
        if(property.type === "text") {
            $(body).append(clone);
            property.width = $(clone).width();
            property.height = $(clone).height();
        }
        if(property.tileSpacing != 0) {
            $(waterMarkObj).css("padding",property.tileSpacing)
        }
        $(waterMarkObj).css("width",property.width)
                       .css("height",property.height);
        $(clone).remove();
    };
    setCenter = function(board, parentWidth, parentHeight) {
        var clone = $(waterMarkObj).clone();
        $(clone).css("position","absolute")
                .css("top", parentHeight/2 - (property.height/2+property.tileSpacing))
                .css("left",parentWidth/2 - (property.width/2+property.tileSpacing));
        $(board).append(clone);
    };
    repeatRow = function(parentWidth) {
        var row = document.createElement("div");
        row.style.height = (property.height + property.tileSpacing*2);
        row.style.width = parentWidth;
        while(parentWidth > 0){
            var clone = $(waterMarkObj).clone();
            var calcWidth = property.width + property.tileSpacing*2
            if(parentWidth > calcWidth) {
                $(row).append(clone);
            }
            else {
                var availWidth = parentWidth - (property.tileSpacing*2);
                if(availWidth > 0){
                    $(clone).css("width", availWidth);
                    $(row).append(clone);
                }
            }
            parentWidth -= calcWidth;
        }
        return row;
    };
    repeatCol = function(board, parentWidth, parentHeight) {
        var row = repeatRow(parentWidth);
        var rowHeight = (property.height + property.tileSpacing*2);
        while(parentHeight > 0) {
            var clone = $(row).clone();
            if(parentHeight > rowHeight) {
                parentHeight -= rowHeight;
            }
            else {
                $(clone).css("height",parentHeight);
                parentHeight -= rowHeight;
            }
            $(board).append(clone);
        }
    };
    return waterMark;
}());