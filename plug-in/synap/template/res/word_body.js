// word_body.js
console.log( 'word_body.js');

localSynap = (function() {
    var wordWM = {
        mark : undefined,
        load : function() {
            if(!jsValue.length) {
                return true;
            }
            if(!(BROWSER.PC.isIE() && BROWSER.VERSION.IE()<=9)) {
                wm.decrypt(jsValue, "word");
                this.mark = wm.getWM();
            } else {
                $("body").empty();
                alert("Not support current browser");
                return false;
            }
            return true;
        },
        append : function(curPageElem) {
            if(this.mark) {
                var $page = $(curPageElem);
                var boardHeight = $page.height()+parseInt($page.css("padding-top"))+parseInt($page.css("padding-bottom"));
                var boardWidth = $page.width()+parseInt($page.css("padding-left"))+parseInt($page.css("padding-right"));
                var board = wm.makeWB(boardWidth,boardHeight, false);
                curPageElem.appendChild(board);
            }
        }
    }
    
    var hdrFtr = {
        hdrState : {
            list : {},
            height : {},
            lastBasic : {},
            lastEven : {},
            lastOdd : {},
            SYNAP_STR : 'synap_word_header',
            SYNAP_EVEN_STR : 'synap_word_header_even',
            SYNAP_ODD_STR : 'synap_word_header_odd',
            SYNAP_BASIC_STR : 'synap_word_header_basic',
            SYNAP_FIRST_STR : 'synap_word_header_first',
        },
        ftrState : {
            list : {},
            height : {},
            lastBasic : {},
            lastEven : {},
            lastOdd : {},
            SYNAP_STR : 'synap_word_footer',
            SYNAP_EVEN_STR : 'synap_word_footer_even',
            SYNAP_ODD_STR : 'synap_word_footer_odd',
            SYNAP_BASIC_STR : 'synap_word_footer_basic',
            SYNAP_FIRST_STR : 'synap_word_footer_first',
        },
        getState : function(isHeader){
            return (isHeader)? this.hdrState:this.ftrState;
        },
        setOverflowFooterForHWP : function(state, id, footer) {
            var curHeight = wordUtil.getPxToPt(parseInt(footer.css('height')));
            var cssBottom = wordUtil.getPxToPt(parseInt(footer.css('bottom')));
            var footerHeight = wordUtil.getPxToPt(parseInt(footer.css('max-height'))) - cssBottom;
            if((curHeight - footerHeight) >= 0) {
                var bottom = cssBottom-(curHeight - footerHeight) >= 0 ? cssBottom-(curHeight - footerHeight) : 0;
                $(state.list[id].find('div')[0]).css('bottom', bottom+'pt');
            }
        },
        appendHdrFtrList : function () {
            // 머리글 본문, 높이 리스트 만들기
            var state = this.getState(true);
            var searchStr = "."+state.SYNAP_STR;
            var lists = $(searchStr);
            for(var i = 0, len=lists.length ; i < len ; i++) {
                var $list = $(lists[i]);
                var id = $list.attr("id");
                state.list[id] = $list.clone();
                if(wordUtil.isMsWord() || wordUtil.isOdt()) {
                    state.height[id] = wordUtil.getPxToPt(parseInt($list.outerHeight(true)));
                }
            }
            state.list.length = lists.length;
            // 바닥글 본문, 높이 리스트 만들기
            state = this.getState(false);
            searchStr = "."+state.SYNAP_STR;
            lists = $(searchStr);
            for(var i = 0, len=lists.length ; i < len ; i++) {
                var $list = $(lists[i]);
                var id = $list.attr("id");
                state.list[id] = $list.clone();
                if(wordUtil.isMsWord() || wordUtil.isOdt()) {
                    state.height[id] = wordUtil.getPxToPt(parseInt($list.outerHeight(true))) + wordUtil.getPxToPt(parseInt($list.css('bottom')));
                    state.list[id].css('bottom','0pt').css('min-height', state.height[id]+'pt');
                } else if(!wordUtil.isHwp97()) {
                    //hwp2k, hml
                    this.setOverflowFooterForHWP(state, id, $($list.find('div')[0]));
                }
            }
            state.list.length = lists.length;
        },
        updateHdrFtrHeight : function() {
            var getSectionNum = function(className) {
                return parseInt(className.substr(className.lastIndexOf('_')+1));
            }
            var getExceptSection = function(className) {
                return className.substr(0, className.lastIndexOf('_')+1);
            }
            var setHeight = function(isHeader) {
                var state=hdrFtr.getState(isHeader);
                for(var i in state.list) {
                    if(i === 'length') {
                        continue
                    }
                    if(wordUtil.isMsWord() || wordUtil.isOdt()) {
                        $('#hidden_section').append(state.list[i].clone());
                        var findObj = $('#hidden_section').find('#'+i);
                        if (isHeader){
                            state.height[i] = wordUtil.getPxToPt(parseInt(findObj.outerHeight(true)));
                        }else{
                            state.height[i] = wordUtil.getPxToPt(parseInt(findObj.outerHeight(true))) + wordUtil.getPxToPt(parseInt(findObj.css('bottom')));
                            state.list[i].css('bottom','0pt').css('min-height', state.height[i]+'pt');
                        }
                    } else {
                        var className = state.list[i].attr('class');
                        if(pageLoader.getSectionNum() != getSectionNum(className)) {
                            state.list[i].attr('class', getExceptSection(className)+pageLoader.getSectionNum());
                            if (!isHeader) {
                                var visibleDiv = $(state.list[i].find('div')[0]);
                                visibleDiv.attr('class', getExceptSection(className).split(' ')[1]+pageLoader.getSectionNum()+'_visible');
                                hdrFtr.setOverflowFooterForHWP(state, state.list[i].attr("id"), visibleDiv);
                            }
                        }
                    }
                }
            }
            setHeight(true);
            setHeight(false);
        },
        getHeaderFooterForHWP : function(pageNum, pageDiv, isHeader) {
            var state=this.getState(isHeader);
            if(wordUtil.isHwp97()) {
                return state.list[state.SYNAP_STR];
            }
            var maxParaId = function (lists) {
                return parseInt($(lists[lists.length-1]).attr("id"));
            }
            var updateLastHdrFtr = function(lastObj, paraId, id, page) {
                lastObj.paraId = paraId;
                lastObj.headerId = paraId + "_"+id;
                lastObj.index = $(page).find("#"+lastObj.headerId+"_mark").index();
            }
            var getHdrFtrId = function(pageNum, lastEven, lastOdd, lastBasic) {
                var isValidHF = function(obj) {
                    return !(obj.paraId === undefined || obj.headerId === undefined || obj.index === undefined);
                }
                var getId = function(hfObj1, hfObj2) {
                    var rs = 0;
                    if(isValidHF(hfObj1) && isValidHF(hfObj2)) {
                        if(hfObj1.paraId > hfObj2.paraId) {
                            rs = hfObj1.headerId;
                        } else if(hfObj1.paraId < hfObj2.paraId) {
                            rs = hfObj2.headerId;
                        } else {
                            rs = hfObj1.index > hfObj2.index ? hfObj1.headerId : hfObj2.headerId;
                        }
                    } else if(isValidHF(hfObj1)) {
                        rs = hfObj1.headerId;
                    } else if(isValidHF(hfObj2)) {
                        rs = hfObj2.headerId;
                    }
                    return rs;
                }
                return (pageNum%2 === 0) ? getId(lastEven, lastBasic) : getId(lastOdd, lastBasic);
            }
            // 지금 이후 페이지를 위해 mark가 있으면 다 찾아놔야함
            var even = maxParaId($(pageDiv).find("."+state.SYNAP_EVEN_STR));
            var odd = maxParaId($(pageDiv).find("."+state.SYNAP_ODD_STR));
            var basic = maxParaId($(pageDiv).find("."+state.SYNAP_BASIC_STR));
            if(even > 0) {
                updateLastHdrFtr(state.lastEven, even, state.SYNAP_EVEN_STR, pageDiv);
            }
            if(odd > 0) {
                updateLastHdrFtr(state.lastOdd, odd, state.SYNAP_ODD_STR, pageDiv);
            }
            if(basic > 0) {
                updateLastHdrFtr(state.lastBasic, basic, state.SYNAP_BASIC_STR, pageDiv);
            }
            var hdrFtrNode = state.list[getHdrFtrId(pageNum, state.lastEven, state.lastOdd, state.lastBasic)];
            return hdrFtrNode;
        },
        getHeaderFooterForMS : function(pageNum, isHeader, isFirstPage) {
            var state=this.getState(isHeader);
            var getFirstId = function(isFirstPage) {
                return (isFirstPage) ? pageLoader.getSectionNum() + '_'+state.SYNAP_FIRST_STR : undefined;
            }
            var getEvenOddId = function(pageNum) {
                return (pageNum%2 === 0) ? pageLoader.getSectionNum() + '_'+state.SYNAP_EVEN_STR : pageLoader.getSectionNum() + '_'+state.SYNAP_ODD_STR;
            }
            var header = state.list[getFirstId(isFirstPage)];
            if(header && header.length) {
                return header;
            }
            header = state.list[getEvenOddId(pageNum)];
            if(header && header.length) {
                return header;
            }
            var id = pageLoader.getSectionNum() + '_'+state.SYNAP_BASIC_STR;
            if(state.list[id] && state.list[id].length) {
                return state.list[id];
            }
            return undefined;
        },
        getHeaderHeight : function(id) {
            return this.hdrState.height[id];
        },
        getFooterHeight : function(id) {
            return this.ftrState.height[id];
        },
    }
    
    var pageLoader = {
        loadState : {
            reTry : 0,
            isAppend : false,
            refreshTimer : null,
            filesPageCount : 0,
            curFileNum : 1,
        },
        documentState : {
            totalPage : 1,
            curPage : 1,
            fileResultDir : undefined,
            fileType : undefined,
            fileName : undefined,
            pageInfo : new Array(),
            paging : false,
            firstPageInSection : true,    // 해당 시점에 섹션의 첫페이지 여부
            continuousPage : false,
        },
        pageState : {
            curSectionNum : 1,
            prevMarginBottom : 0,
            curHeight : 0,
            initCurHeight : function() {
                if(!wordUtil.isMsWord()) {
                    return 0;
                }
                var header = pageLoader.getHeader(pageLoader.getFirstPageInSection(), pageLoader.getCurPage());
                this.curHeight = header ? hdrFtr.getHeaderHeight($(header).attr('id')) : 0;
            },
            initPageHeight : function() {
                var info = pageLoader.getCurPageInfo();
                info.adjustHeightPt = info.heightPt;
                if(!(wordUtil.isMsWord() || wordUtil.isOdt())) {
                    return; 
                }
                var header = pageLoader.getHeader(pageLoader.getFirstPageInSection(), pageLoader.getCurPage());
                if(!header) {
                    // 머리글이 없는 경우 해당 크기만큼 여백을 지정해야한다.
                    info.adjustHeightPt += info.marginTopPt - info.originMarginTopPt;
                }
                info.adjustHeightPt -= pageLoader.getFooterOverlapHeight(pageLoader.getFirstPageInSection(), pageLoader.getCurPage());
            },
            contentList : [],
        },
        setPageInfo : function() {
            var parseStyle = function(styles, info) {
                var setPadding = function(info, styles, index) {
                    if(parseInt(styles[index+4])) {
                        info.marginTopPt = parseInt(styles[index+1]);
                        info.marginRightPt = parseInt(styles[index+2]);
                        info.marginBottomPt = parseInt(styles[index+3]);
                        info.marginLeftPt = parseInt(styles[index+4]);
                        return 4;
                    } else if(parseInt(styles[index+3])) {
                        info.marginTopPt = parseInt(styles[index+1]);
                        info.marginLeftPt = parseInt(styles[index+2]);
                        info.marginRightPt = parseInt(styles[index+2]);
                        info.marginBottomPt = parseInt(styles[index+3]);
                        return 3;
                    } else if(parseInt(styles[index+2])) {
                        info.marginTopPt = parseInt(styles[index+1]);
                        info.marginLeftPt = parseInt(styles[index+2]);
                        info.marginRightPt = parseInt(styles[index+2]);
                        info.marginBottomPt = parseInt(styles[index+1]);
                        return 2;
                    }
                    info.marginTopPt = parseInt(styles[index+1]);
                    info.marginLeftPt = parseInt(styles[index+1]);
                    info.marginRightPt = parseInt(styles[index+1]);
                    info.marginBottomPt = parseInt(styles[index+1]);
                    return 1;
                }
                for(var i=0, len=styles.length; i<len; i++) {
                    if(styles[i] === 'min-height:') {
                        info.heightPt = parseInt(styles[i+1]);
                        i++;
                    } else if(styles[i] === 'min-width:') {
                        info.widthPt = parseInt(styles[i+1]);
                        i++;
                    } else if(styles[i] === 'margin-top:') {
                        info.originMarginTopPt = parseInt(styles[i+1]);
                        i++;
                    } else if(styles[i] === 'padding:') {
                        i+=setPadding(info, styles, i);
                    }
                }
            }
            var hasSelector = function(selector) {
                return (/^.page[0-9]*$/.test(selector) || (/^.info_page[0-9]+$/.test(selector)));
            }
            var getPageNo = function(selector) {
                if (selector === '.page') {
                    return 0;
                } else if(selector.substr(0,10) === '.info_page') {
                    return parseInt(selector.substr(10))-1;
                } else if(selector.substr(0,5) === '.page') {
                    return parseInt(selector.substr(5))-1;
                }
                return this.documentState.pageInfo.length;
            }
            for(var i=0, max=document.styleSheets.length; i<max; i++) {
                var styleSheet = document.styleSheets[i];
                for(var j=0, len=styleSheet.rules.length; j<len; j++){
                    var rule = styleSheet.rules[j];
                    if(!(hasSelector(rule.selectorText))) {
                        continue;
                    }
                    var pageIndex = getPageNo(rule.selectorText);
                    var info = this.documentState.pageInfo[pageIndex] ? this.documentState.pageInfo[pageIndex]
                                                                  : this.documentState.pageInfo[this.documentState.pageInfo.push({})-1];
                    parseStyle(rule.cssText.split(' '), info);
                    
                }
            }
            // ms 또는 odt인 경우만 페이지에 따라 높이가 변경될 수 있음
            if(wordUtil.isMsWord() || wordUtil.isOdt()) {
                for(var i=0, max=this.documentState.pageInfo.length; i<max; i++) {
                    var info = this.documentState.pageInfo[i];
                    // 머리글이 있는 경우 페이지 높이가 머리글이 있는 것을 가정하고 css가 생성되기 때문에
                    // 실제 본문의 높이는 머리글이 본문을 넘어서지 않은 값이어 함.
                    info.heightPt = (info.marginTopPt > info.originMarginTopPt) ? info.heightPt-(info.marginTopPt-info.originMarginTopPt) : info.heightPt;
                }
            }
        },
        changeSection : function() {
            this.pageState.curSectionNum++;
            $('#hidden_section').css('width', this.getPageWidth()+'pt');
            hdrFtr.updateHdrFtrHeight();
            this.pageState.initPageHeight();
        },
        appendHdrFtr : function(pageDiv, pageNum, isFirstPage) {
            if(hdrFtr.hdrState.list.length > 0) {
                var tag = this.getHeader(isFirstPage, pageNum, pageDiv);
                if(tag) {
                    $(pageDiv).prepend($(tag).clone());
                }
            }
            if(hdrFtr.ftrState.list.length > 0) {
                var tag = this.getFooter(isFirstPage, pageNum, pageDiv);
                if(tag) {
                    $(pageDiv).prepend($(tag).clone());
                }
            }
        },
        pageBreaker : function(div) {
            this.composePage(div);
            this.increasePage();
            this.documentState.totalPage++;
            this.pageState.curHeight = 0;
            $('#content_body').append('<div class="pagebreaker">&#160;</div>');
            var sectionbreaker = this.isContinuousPage();
            if(this.isContinuousPage()) {
                this.documentState.continuousPage = false;
                this.changeSection();
            }
            div = document.createElement('div');
            $(div).attr('id', 'div_page');
            $(div).attr('class', this.getPageClassName(sectionbreaker));
            this.pageState.initPageHeight();
            this.pageState.initCurHeight();
            return div;
        },
        makePage : function(p, div) {
            var pHeight = wordUtil.getPxToPt(parseInt(p.outerHeight(true)));
            if(wordUtil.isMsWord()) {
                //문단 높이 계산시 margin-top과 bottom이 겹치는 부분을 빼야함.(hwp와 odt는 포함되지 않는 규칙)
                pHeight -= Math.min(wordUtil.getPxToPt(parseInt(p.css('margin-top'))), this.pageState.prevMarginBottom);
                this.pageState.prevMarginBottom = wordUtil.getPxToPt(parseInt(p.css('margin-bottom')));
            }
            var oldCurHeight = this.pageState.curHeight;
            if ( ((p[0].tagName.toLowerCase() === 'div') && (p.css('position') === 'absolute'
                || ( p.css('z-index') !== 'auto' && p.css('z-index') !== 0 )
                || p.css('float') === 'left'
                || p.css('float') === 'right')) 
                || (p[0].tagName.toLowerCase() === 'table' && p.css('position') === 'absolute') ) {
                pHeight = 0;
            }
            if(p.hasClass(hdrFtr.hdrState.SYNAP_STR) || p.hasClass(hdrFtr.ftrState.SYNAP_STR)) {
                return div;
            }
            this.pageState.curHeight += pHeight;
            if(this.getPageHeight() < parseInt(this.pageState.curHeight)
                && oldCurHeight > this.getPageHeight()/2 ) {
                div = this.pageBreaker(div);
                this.pageState.curHeight += pHeight;
            }
            this.pageState.contentList.push(p);
            return div;
        },
        readHidden : function(hiddenContent, div) {
            var pageJump = function(splitSectionBreak){
                // PRJAM-7286 구역나누기(다음 홀/짝수 페이지부터)처리 추가
                if((splitSectionBreak == "evenpage" && pageLoader.documentState.curPage % 2 === 1)       // 구역나누기(다음 짝수페이지부터) + 다음페이지가 홀수일때
                || (splitSectionBreak == "oddpage" && pageLoader.documentState.curPage % 2 === 0)) {     // 구역나누기(다음 홀수페이지부터) + 다음페이지가 짝수일때
                    pageLoader.documentState.curPage++; // 한 페이지 건너뛰기
                }
            }
            hiddenContent.children().each(function() {
                var elem = $(this);
                var className = this.className.toLowerCase();
                var splitSectionBreak = className.split('_');
                var isSectionBreak = splitSectionBreak[0] ==='sectionbreaker';
                if( className === 'pagebreaker' || isSectionBreak) {
                    div = pageLoader.pageBreaker(div);
                    if(isSectionBreak) {
                        pageLoader.documentState.firstPageInSection = true;
                        pageJump(splitSectionBreak[1]);
                        pageLoader.changeSection();
                        $(div).attr('class', pageLoader.getPageClassName(true));
                    }
                } else if(className === 'continoussection') {
                    pageLoader.documentState.continuousPage = true;
                }else{
                    div = pageLoader.makePage(elem, div);
                }
                elem.remove();
            });
            return div;
        },
        composePage : function(page) {
            this.setPageStyle(page);
            for(var i=0, len=this.pageState.contentList.length; i<len; i++) {
                if (this.pageState.contentList[i].hasClass(hdrFtr.hdrState.SYNAP_STR)
                    || this.pageState.contentList[i].hasClass(hdrFtr.ftrState.SYNAP_STR)) {
                    continue;
                }
                $(page).append(this.pageState.contentList[i]);
            }
            var header = wordUtil.isHwp() ? this.getHeader(undefined, this.getCurPage(), page) : this.getHeader(this.getFirstPageInSection(), this.getCurPage());
            if(header) {
                $(page).prepend(header.clone());
            }
            var footer = wordUtil.isHwp() ? this.getFooter(undefined, this.getCurPage(), page) : this.getFooter(this.getFirstPageInSection(), this.getCurPage());
            if(footer) {
                $(page).append(footer.clone());
            }
            $(page).find('.pagenumber').text(this.getCurPage());
            document.getElementById('content_body').appendChild(page);
            wordWM.append(page);
            this.pageState.contentList = new Array();
        },
        appendContent : function(contents) {
            $('#hidden_section').append(contents);
            $('#hidden_section').css('display', '');
            var page = document.createElement('div');
            page.id = 'div_page';
            page.className = this.getPageClassName((this.getCurPage() == 1));
            if(pageLoader.documentState.fileType === 'hwpml'
                || pageLoader.documentState.fileType === 'hwpx'
                || pageLoader.documentState.fileType === 'hwp2k') {
                pageLoader.setSingleLine();
            }
            // 페이징이 안된 상태에서 hwp97, hwp2k는 div_page에 본문 내용이 모두 다 있음
            var hiddenContent = $('#hidden_section >  #div_page');
            if(!hiddenContent.length) {
                hiddenContent = $('#hidden_section');
            }
            var loop_cnt = 0;
            // ie9이하에서 hidden 노드의 append()타임이 느려서 타이밍이 안맞는 문제 발생 처리
            while(hiddenContent.children().length && loop_cnt<10){
                page = this.readHidden(hiddenContent, page);
                loop_cnt++;
            }
            if((this.loadState.curFileNum === this.loadState.filesPageCount)
                && this.pageState.contentList.length) {
                this.composePage(page);
                $('.totalnumber').text(this.getPageSize());
            }
            $('#hidden_section').css('display', 'none');
        },
        loadPageError : function(xhr, ajaxOptions, thrownError) {
            this.loadState.isAppend = false;
            if(this.loadState.curFileNum >= this.loadState.filesPageCount) {
                this.loadState.refreshTimer = setTimeout('localSynap.loadPage();', 1000);
            }else{
                this.loadState.refreshTimer = setTimeout('localSynap.loadPage();', 500);
            }
        },
        killCopyImage : function () {
            // PRJAM-4316 이미지 복사방지
            localSynap = getSynapPageObject();
            if(localSynap.config && !localSynap.config.allowCopy && BROWSER.isMobile()) {
                $(('#content_body img[src]')).each(function() {
                    stopBrowserEvent(this);
                });
            }
        },  
        loadPageMake : function() {
            clearTimeout(this.loadState.refreshTimer);
            if(!this.loadState.isAppend && this.loadState.curFileNum <= this.loadState.filesPageCount) {
                this.loadState.isAppend = true;
                $.ajax({
                    type : 'GET',
                    async : true,
                    url : encodeURI(wordUtil.getContentFileName()),
                    dataType : 'html',
                    success : function(contents) {
                        contents = wordUtil.getContents(contents);
                        wordUtil.attemptToAddContentWithinRetryCnt(function(contents) {
                            pageLoader.appendContent(contents);
                        }, [contents], pageLoader, wordUtil.isHwp97() ? 'page' : 'page1', 10, contents);
                    },
                    error : function(xhr, ajaxOptions, thrownError) {
                        pageLoader.loadPageError(xhr, ajaxOptions, thrownError);
                    }
                });
            } else if(this.loadState.curFileNum === (this.loadState.filesPageCount+1)) {
                this.loadState.curFileNum++;
                this.loadLastPage();
            }
        },
        loadPageAlreadyMake : function() {
            clearTimeout(this.loadState.refreshTimer);
            if(!this.loadState.isAppend && this.loadState.curFileNum <= this.loadState.filesPageCount) {
                this.loadState.isAppend = true;
                $.ajax({
                    type : 'GET',
                    async : true,
                    url : encodeURI(wordUtil.getContentFileName()),
                    dataType : 'html',
                    success : function(contents) {
                        contents = wordUtil.getContents(contents);
                        wordUtil.attemptToAddContentWithinRetryCnt(function(contents, pageLoader, wordUtil, hdrFtr, wordWM) {
                            $('#content_body').append(contents);

                            if(pageLoader.loadState.curFileNum === 1) {
                                pageLoader.documentState.totalPage = pageLoader.loadState.filesPageCount;
                                $("."+hdrFtr.hdrState.SYNAP_STR).remove();
                                $("."+hdrFtr.ftrState.SYNAP_STR).remove();
                            }
                            var curPageElem = wordUtil.getLastPage();
                            if(!wordUtil.isHwp97()) {
                                var className = $(curPageElem).attr("class");
                                var prevSectionNum = pageLoader.getSectionNum();
                                pageLoader.pageState.curSectionNum = parseInt(className.substr(className.lastIndexOf('page')+4));
                                if(prevSectionNum != pageLoader.getSectionNum()) {
                                    hdrFtr.updateHdrFtrHeight();
                                }
                            }
                            pageLoader.appendHdrFtr(curPageElem, pageLoader.getCurPage(), pageLoader.getFirstPageInSection());
                            $(curPageElem).find('.pagenumber').text(pageLoader.getCurPage());
                            $(curPageElem).find('.totalnumber').text(pageLoader.getPageSize());
                            wordWM.append(curPageElem);
                            
                            pageLoader.setSingleLine();
                            pageLoader.increasePage();
                        }, [contents, pageLoader, wordUtil, hdrFtr, wordWM], pageLoader, 'page1', 10);
                    },
                    error : function(xhr, ajaxOptions, thrownError) {
                        pageLoader.loadPageError(xhr, ajaxOptions, thrownError);
                    }
                });
            } else if(this.loadState.curFileNum === (this.loadState.filesPageCount+1)) {
                this.increasePage();
                this.loadState.curFileNum++;
                this.documentState.totalPage = this.loadState.filesPageCount;
                this.loadLastPage();
            }
        },
        loadLastPage : function() {
            removeSpinner();
            if (BROWSER.isMobile()){
            	wordbody.changeAndroid2Footer();
            }
            localSynap.completed = 1;
            localSynap.onLoadBody && localSynap.onLoadBody();
        },
        loadHdrFtr : function() {
            $.ajax({
                type : 'GET',
                async : false,
                url : encodeURI(wordUtil.getContentFileName()),
                dataType : 'html',
                success : function(contents) {
                    contents = wordUtil.getContents(contents);
                    $('#hidden_section').append(contents);
                    $('#hidden_section').css('display', '');
                    hdrFtr.appendHdrFtrList();
                    $('#hidden_section').empty();
                    $('#hidden_section').css('display', 'none');
                },
                error : function(xhr, ajaxOptions, thrownError) {
                    pageLoader.loadPageError(xhr, ajaxOptions, thrownError);
                }
            });
        },
        // hwp 문단 - 한 줄로 입력, 테이블 안의 문단에서 '한줄로 입력' 설정되어 있으면 자간을 조정해서 한 줄로 되게 한다.
        setSingleLine : function () {
            $('p.synap-single-line-display').each(function(index, elem){
                var getDoubleLineHeight = function() {
                    if(!pageLoader.documentState.paging) {
                        var $pp = $('#hidden_section').prepend('<div id="synap-single-line"></div>');
                        $pp = $('#synap-single-line').prepend(elem.cloneNode(true));
                        var doubleLineHeight = $pp.outerHeight() * 2 - 1; // IE 1Line : 26, 2Line : 51 case fix
                        $pp.remove();
                        return doubleLineHeight;
                    }
                    // hwp, hwpx isPaging
                    var $pp = $('#hidden_section').prepend(elem.cloneNode(true));
                    var doubleLineHeight = $pp.outerHeight() * 2 - 1; // IE 1Line : 26, 2Line : 51 case fix
                    $pp.empty();
                    return doubleLineHeight;
                }
                var doubleLineHeight = getDoubleLineHeight();
                $(elem).removeClass('synap-single-line-display');
                var initHeight = $(elem).outerHeight();
                if( initHeight < doubleLineHeight) {
                    return;
                }
                var s = parseFloat($(elem).find('span').css('letter-spacing')), e = -1;
                while( $(elem).outerHeight() >= doubleLineHeight && e > -30){
                    e *= 2;
                    $(elem).find('span').css('letter-spacing', s + e + 'pt');
                }
                if( $(elem).outerHeight() == initHeight ){ // Single-line view fail
                    console.log && console.log('single-line-process Error');
                    $(elem).find('span').css('letter-spacing', s + 'pt');
                    return;
                }
                var mid = (s+e)/2.0;
                while( s - mid > 0.05 ){
                    $(elem).find('span').css('letter-spacing', mid + 'pt');
                    if( $(elem).outerHeight() < doubleLineHeight ){
                        e = mid;
                    }else{
                        s = mid;
                    }
                    mid = (s+e) / 2;
                }
                $(elem).find('span').css('letter-spacing', e + 'pt');
            });
        },
        setPageStyle : function(div) {
            if(!(wordUtil.isMsWord() || wordUtil.isOdt()) || wordUtil.isAdjustPageHeight()) {
                return;
            }
            if(!this.getHeader(this.getFirstPageInSection(), this.getCurPage())) {
                $(div).css("padding-top", this.getOriginMarginTop()+"pt");
            }
            var overlap = this.getFooterOverlapHeight(this.getFirstPageInSection(), this.getCurPage());
            if(overlap > 0) {
                $(div).css("padding-bottom", (overlap+this.getMarginBottom())+"pt");
            }
            $(div).css("min-height", this.getPageHeight()+"pt");
        },
        getFooterOverlapHeight : function(isFirstPage, pageNum) {
            var overlapArea = 0;
            var footer = this.getFooter(isFirstPage, pageNum);
            if(!footer) {
                return 0;
            }
            var footerId = footer.attr('id');
            //바닥글 높이 + bottom값이 여백보다 작으면 계산할 필요가 없음(여백에 포함되므로 content영역을 침범하지 않는다)
            if(hdrFtr.getFooterHeight(footerId) > this.getMarginBottom()) {
                //바닥글 높이 + bottom값이 여백보다 크면 공통된 부분만큼 계산(content영역을 침범하는 만큼 계산)
                overlapArea = hdrFtr.getFooterHeight(footerId) - this.getMarginBottom();
            }
            return overlapArea;
        },
        getHeader : function(isFirstPage, pageNum, pageDiv) {
            var header = pageDiv ? hdrFtr.getHeaderFooterForHWP(pageNum, pageDiv, true) : hdrFtr.getHeaderFooterForMS(pageNum, true, isFirstPage)
            if(pageDiv && pageDiv.getAttribute('class').indexOf('hide_header') > -1) {
                return undefined;
            }
            return header && (header.children().length > 0) ? header : undefined;
        },
        getFooter : function(isFirstPage, pageNum, pageDiv) {
            var footer = pageDiv ? hdrFtr.getHeaderFooterForHWP(pageNum, pageDiv, false) : hdrFtr.getHeaderFooterForMS(pageNum, false, isFirstPage);
            if(pageDiv && pageDiv.getAttribute('class').indexOf('hide_footer') > -1) {
                return undefined;
            }
            return footer && (footer.children().length > 0) ? footer : undefined;
        },
        getSectionNum : function() {
            return this.pageState.curSectionNum;
        },
        getCurPage : function() {
            return this.documentState.curPage;
        },
        getCurPageInfo : function() {
            return this.documentState.pageInfo[this.getSectionNum()-1];
        },
        getPageWidth : function() {
            return this.getCurPageInfo().widthPt;
        },
        getPageHeight : function() {
            var info = this.getCurPageInfo();
            return info.adjustHeightPt ? info.adjustHeightPt : info.heightPt;
        },
        getMarginTop : function() {
            return this.getCurPageInfo().marginTopPt;
        },
        getOriginMarginTop : function() {
            return this.getCurPageInfo().originMarginTopPt;
        },
        getMarginLeft : function() {
            return this.getCurPageInfo().marginLeftPt;
        },
        getMarginRight : function() {
            return this.getCurPageInfo().marginRightPt;
        },
        getMarginBottom : function() {
            return this.getCurPageInfo().marginBottomPt;
        },
        getPageSize : function() {
            return this.documentState.totalPage;
        },
        getPageClassName : function(isSectionBreaker) {
            var pageBackground = isSectionBreaker ? (this.getCurPage()%2==1 ? "odd_f_" : "even_f_") : (this.getCurPage()%2==1 ? "odd_fe_" : "even_fe_");
            pageBackground += this.pageState.curSectionNum;
            // hwp97만 page, 나머지 포맷은 구역정보가 있음.
            return wordUtil.isHwp97() ? 'inner page' : 'inner ' + pageBackground + ' page' + this.pageState.curSectionNum;
        },
        increasePage : function() {
            this.documentState.curPage++;
            this.documentState.firstPageInSection = false;
        },
        getFirstPageInSection : function() {
            return this.documentState.firstPageInSection;
        },
        isContinuousPage : function() {
            return this.documentState.continuousPage;
        }
    }
    
    var wordUtil = {
        getContentFileName : function() {
            return wordbody.getFileResultDir().split('/').pop() + '/' + pageLoader.loadState.curFileNum + '.html';
        },
        removeElements : function(parentElement, removeClassName) {
            var removeElements = document.getElementsByClassName(removeClassName);
            removeElements.forEach(function(elem) {
                parentElement.removeChild(elem);
            });
        },
        getLastPage : function() {
            var pages = document.getElementsByClassName('inner');
            return pages[pages.length-1];
        },
        getContents : function(contents) {
            if(pageLoader.loadState.curFileNum === pageLoader.loadState.filesPageCount) {
                for(var lx=14; lx<32; lx++) {
                    if(contents.substr(contents.length-lx, 7) === "</body>") {
                        contents = contents.substring(0, contents.length-lx);
                        break;
                    }
                }
            }
            return contents;
        },
        getPtToPx : function (size_pt){
            return (size_pt * (96/72));
        },
        getPxToPt : function (size_px){
            return (size_px * (72/96));
        },
        isHwp : function() {
            return (pageLoader.documentState.fileType === 'hwp2k') || (pageLoader.documentState.fileType === 'hwpml') || (pageLoader.documentState.fileType === 'hwpx') || this.isHwp97();
        },
        isHwp97 : function() {
            return (pageLoader.documentState.fileType === 'hwp97');
        },
        isMsWord : function() {
            return (pageLoader.documentState.fileType === 'doc') || (pageLoader.documentState.fileType === 'docx');
        },
        isOdt : function() {
            return (pageLoader.documentState.fileType === 'odt');
        },
        isAdjustPageHeight : function() {
            var info = pageLoader.getCurPageInfo();
            return (info.adjustHeightPt === info.heightPt);
        },
        attemptToAddContentWithinRetryCnt : function (appendContentFun, appendContentFunArgs, pageLoader, className, retryCnt) {
            try {
                appendContentFun.apply(null, appendContentFunArgs);

                pageLoader.loadState.curFileNum++;
                pageLoader.loadState.isAppend = false;
                pageLoader.killCopyImage();
            } catch(e) {
                pageLoader.loadState.isAppend = false;
                pageLoader.loadState.reTry++;
                console.log('error='+e);
            }
            if (pageLoader.loadState.reTry < retryCnt){
                if(pageLoader.loadState.curFileNum >= pageLoader.loadState.filesPageCount) {
                    pageLoader.loadState.refreshTimer = setTimeout('localSynap.loadPage();', 1000);
                } else {
                    loadSpinner('content_body', className);
                    pageLoader.loadState.refreshTimer = setTimeout('localSynap.loadPage();', 500);
                }
            } else {
                removeSpinner();
                alert('This is an invalid file.');
            }
        }
    }
    
    var wordbody = {
        getXml : function() {
            var xmlUrl = this.getFileName() + '.xml';
            $.ajax({
                type : 'GET',
                async : false,
                url : xmlUrl,
                dataType : 'xml',
                success : function(xmlDoc) {
                    pageLoader.documentState.fileType = $(xmlDoc).find('file_type').text().toLowerCase();
                    pageLoader.documentState.fileName = $(xmlDoc).find('file_name').text();
                    pageLoader.documentState.paging = ($(xmlDoc).find('paging').text() === 'true');
                    pageLoader.loadState.filesPageCount = parseInt($(xmlDoc).find('filespage_cnt').text());
                },
                error : function(error) {
                    console.log('Error : xml load fail!');
                }
            });
        },
        contentReadyFunc : function() {
            window.onscroll = function(e){
                localSynap.onScroll && localSynap.onScroll(e);
            }        
            this.getXml();
            if(!wordWM.load()) {
                return;
            }
            pageLoader.setPageInfo() // stylesheet rule의 구역정보(페이지 높이 등) 가져오기
            pageLoader.loadHdrFtr();
            if(self==top) {
                $(".containBg").css("background-color","#ebf1f5");
                $("#content_body").css("background-color","#ebf1f5");
            }
            if(localSynap.config && !localSynap.config.allowCopy){
                var content_body = document.getElementById('content_body');
                stopBrowserEvent(content_body);
            }
            pageLoader.pageState.initCurHeight();
            pageLoader.pageState.initPageHeight();
            this.loadPage();
        },
        loadPage : function() {
            pageLoader.documentState.paging ? pageLoader.loadPageAlreadyMake() : pageLoader.loadPageMake();
        },
        getFileName : function() {
            if(!pageLoader.documentState.fileName) {
                var url = document.location.pathname;
                url = url.split('/').pop(); // xxxx.hwp.view.xhtml
                url = url.substr(0, url.lastIndexOf(".")); // xxxx.hwp.view
                pageLoader.documentState.fileName = url.substr(0, url.lastIndexOf("."));
            }
            return pageLoader.documentState.fileName;
        },
        getFileType : function() {
            return pageLoader.documentState.fileType;
        },
        getFileResultDir : function() {
            if(!pageLoader.documentState.fileResultDir) {
                var url = document.location.pathname;
                pageLoader.documentState.fileResultDir = url.substr(0, url.lastIndexOf('/')+1) + this.getFileName() + '.files';
            }
            return pageLoader.documentState.fileResultDir;
        },
        changeAndroid2Footer : function () {
            if (typeof localSynap.resize =='function'){
                localSynap.resize(); // 다 그리고 난 후에 브라우저가 header를 다시 그릴 수 있도록 해야함
            }
        },
        getPageSize : function () {
            return pageLoader.getPageSize();
        }
    }
    return $.extend(localSynap, wordbody);
})();

$(document).ready(function() {
    localSynap.contentReadyFunc();
});
