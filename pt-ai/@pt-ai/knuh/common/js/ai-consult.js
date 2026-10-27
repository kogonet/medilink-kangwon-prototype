/**
 * AI 상담 — 빠른검색 패널 열기/닫기
 */
(function () {
  "use strict";

  var MOBILE_BP = 880;

  var panelOpen = window.innerWidth >= MOBILE_BP;
  var chatBusy = false;

  var els = {};

  function isMobile() {
    return window.innerWidth < MOBILE_BP;
  }

  function updatePanel() {
    var mobile = isMobile();
    var open = panelOpen;

    els.main.classList.toggle("kp-main--panel", open && !mobile);
    els.panel.classList.toggle("is-open", open);
    els.panel.setAttribute("aria-hidden", open ? "false" : "true");

    if (els.body) {
      els.body.classList.toggle("is-panel-open", open);
    }

    if (els.scrim) {
      if (mobile && open) {
        els.scrim.removeAttribute("hidden");
      } else {
        els.scrim.setAttribute("hidden", "");
      }
    }

    if (els.btnPanel) {
      els.btnPanel.classList.toggle("is-open", open);
      els.btnPanel.setAttribute("aria-pressed", open ? "true" : "false");
      els.btnPanel.setAttribute("aria-expanded", open ? "true" : "false");
      els.btnPanel.setAttribute(
        "aria-label",
        open ? "빠른검색 닫기" : "빠른검색 열기"
      );
    }
  }

  function togglePanel() {
    panelOpen = !panelOpen;
    updatePanel();
  }

  function closePanel() {
    if (!panelOpen) return;
    panelOpen = false;
    updatePanel();
  }

  function clearAccordionTransition(list) {
    if (list._accOnTransitionEnd) {
      list.removeEventListener("transitionend", list._accOnTransitionEnd);
      list._accOnTransitionEnd = null;
    }
  }

  function setAccordionOpen(list, chev, head, open) {
    var inner = list.querySelector(".kp-acc__inner");
    if (!inner) return;

    clearAccordionTransition(list);

    if (open) {
      list.classList.add("is-open");
      if (chev) chev.classList.add("is-open");
      head.setAttribute("aria-expanded", "true");

      list.style.maxHeight = "0px";
      requestAnimationFrame(function () {
        requestAnimationFrame(function () {
          list.style.maxHeight = inner.scrollHeight + "px";
        });
      });

      list._accOnTransitionEnd = function (e) {
        if (e.target !== list || e.propertyName !== "max-height") return;
        if (!list.classList.contains("is-open")) return;
        list.style.maxHeight = "none";
        clearAccordionTransition(list);
      };
      list.addEventListener("transitionend", list._accOnTransitionEnd);
      return;
    }

    if (chev) chev.classList.remove("is-open");
    head.setAttribute("aria-expanded", "false");

    list.style.maxHeight = list.scrollHeight + "px";
    requestAnimationFrame(function () {
      requestAnimationFrame(function () {
        list.style.maxHeight = "0px";
      });
    });

    list._accOnTransitionEnd = function (e) {
      if (e.target !== list || e.propertyName !== "max-height") return;
      list.classList.remove("is-open");
      list.style.maxHeight = "";
      clearAccordionTransition(list);
    };
    list.addEventListener("transitionend", list._accOnTransitionEnd);
  }

  function initAccordions() {
    var panelBody = document.querySelector(".kp-panel__body");
    if (!panelBody) return;

    panelBody.querySelectorAll(".kp-acc").forEach(function (acc) {
      var head = acc.querySelector(".kp-acc__head");
      var list = acc.querySelector(".kp-acc__list");
      if (!head || !list) return;

      head.setAttribute("aria-expanded", list.classList.contains("is-open") ? "true" : "false");
    });

    panelBody.addEventListener("click", function (e) {
      var head = e.target.closest(".kp-acc__head");
      if (!head || !panelBody.contains(head)) return;

      var acc = head.closest(".kp-acc");
      if (!acc) return;

      var list = acc.querySelector(".kp-acc__list");
      var chev = acc.querySelector(".kp-acc__chev");
      if (!list) return;

      var willOpen = !list.classList.contains("is-open");
      /* 열 때만 다른 아코디언 닫기 */
      if (willOpen) {
        panelBody.querySelectorAll(".kp-acc__list.is-open").forEach(function (otherList) {
          if (otherList === list) return;
          var otherAcc = otherList.closest(".kp-acc");
          if (!otherAcc) return;
          var otherHead = otherAcc.querySelector(".kp-acc__head");
          var otherChev = otherAcc.querySelector(".kp-acc__chev");
          if (otherHead) setAccordionOpen(otherList, otherChev, otherHead, false);
        });
      }
      setAccordionOpen(list, chev, head, willOpen);
    });

    var firstAcc = panelBody.querySelector(".kp-acc");
    if (firstAcc) {
      var firstHead = firstAcc.querySelector(".kp-acc__head");
      var firstList = firstAcc.querySelector(".kp-acc__list");
      var firstChev = firstAcc.querySelector(".kp-acc__chev");
      if (firstHead && firstList && !firstList.classList.contains("is-open")) {
        setAccordionOpen(firstList, firstChev, firstHead, true);
      } else if (firstHead && firstList && firstList.classList.contains("is-open")) {
        var firstInner = firstList.querySelector(".kp-acc__inner");
        if (firstInner) {
          firstList.style.maxHeight = firstInner.scrollHeight + "px";
          requestAnimationFrame(function () {
            firstList.style.maxHeight = "none";
          });
        }
      }
    }
  }

  function initTabs() {
    var tablist = document.querySelector(".kp-tabs");
    if (!tablist) return;

    var panelMap = {
      "panel-dept":     "acc-dept",
      "panel-center":   "acc-center",
      "panel-clinic":   "acc-clinic",
      "panel-rsv":      "acc-rsv",
      "panel-hospital": "acc-hospital",
      "panel-health":   "acc-health",
      "panel-about":    "acc-about"
    };

    function closeAllAccordions() {
      var panelBody = document.querySelector(".kp-panel__body");
      if (!panelBody) return;
      panelBody.querySelectorAll(".kp-acc__list.is-open").forEach(function (openList) {
        var acc = openList.closest(".kp-acc");
        if (!acc) return;
        var h = acc.querySelector(".kp-acc__head");
        var c = acc.querySelector(".kp-acc__chev");
        if (h) setAccordionOpen(openList, c, h, false);
      });
    }

    function expandAcc(accId) {
      var group = document.getElementById(accId);
      if (!group) return;
      /* 다른 아코디언 먼저 닫기 */
      closeAllAccordions();
      var head = group.querySelector(".kp-acc__head");
      var list = group.querySelector(".kp-acc__list");
      var chev = group.querySelector(".kp-acc__chev");
      if (head && list) {
        setAccordionOpen(list, chev, head, true);
      }
      var panelBody = document.querySelector(".kp-panel__body");
      if (panelBody) {
        panelBody.scrollTo({ top: 0, behavior: "smooth" });
      }
    }

    tablist.addEventListener("click", function (e) {
      var tab = e.target.closest(".kp-tab");
      if (!tab || !tablist.contains(tab)) return;

      tablist.querySelectorAll(".kp-tab").forEach(function (btn) {
        var active = btn === tab;
        btn.classList.toggle("is-active", active);
        btn.setAttribute("aria-selected", active ? "true" : "false");
      });

      var panelId = tab.getAttribute("data-panel");
      if (panelId && panelMap[panelId]) expandAcc(panelMap[panelId]);
    });
  }

  function getComposerInputMinHeight(input) {
    var composer = input.closest(".kp-composer");
    if (!composer) return 0;

    if (composer.classList.contains("kp-composer--big")) {
      var minHeight = window.getComputedStyle(composer).getPropertyValue("--kp-composer-big-input-min").trim();
      var parsed = parseFloat(minHeight);
      return parsed > 0 ? parsed : 96;
    }

    return 0;
  }

  function resetDockComposerInput(input) {
    if (!input) return;
    input.style.removeProperty("min-height");
    input.style.removeProperty("height");
  }

  function resizeComposerInput(input) {
    if (!input) return;

    var composer = input.closest(".kp-composer");
    if (composer && composer.classList.contains("kp-composer--dock")) {
      resetDockComposerInput(input);
      return;
    }

    var minHeight = getComposerInputMinHeight(input);
    var maxHeight = 160;

    if (minHeight > 0) {
      input.style.minHeight = minHeight + "px";
    } else {
      input.style.minHeight = "";
    }

    input.style.height = "auto";
    var nextHeight = Math.max(minHeight, input.scrollHeight);
    input.style.height = Math.min(nextHeight, maxHeight) + "px";
  }

  function updateComposerSendState(input, btn) {
    if (!input || !btn || chatBusy) return;
    btn.disabled = input.value.trim().length === 0;
  }

  function refreshComposerSendStates() {
    if (!els.composerInputs) return;
    els.composerInputs.forEach(function (input) {
      var composer = input.closest(".kp-composer");
      var btn = composer ? composer.querySelector(".kp-composer__send") : null;
      if (btn) {
        btn.setAttribute("aria-label", "전송");
        updateComposerSendState(input, btn);
      }
    });
  }

  function setComposerBusy(busy) {
    document.querySelectorAll(".kp-composer__input").forEach(function (input) {
      input.disabled = busy;
    });
    document.querySelectorAll(".kp-composer__send").forEach(function (btn) {
      if (busy) {
        btn.disabled = false;
        btn.setAttribute("aria-label", "중단");
      } else {
        btn.setAttribute("aria-label", "전송");
      }
    });
    if (!busy) {
      refreshComposerSendStates();
    }
  }

  function initComposerSend() {
    els.composerInputs = document.querySelectorAll(".kp-composer__input");
    els.composerSends = document.querySelectorAll(".kp-composer__send");
    els.dockInput = document.getElementById("dock-input");
    els.dockSend = document.getElementById("dock-send");

    els.composerInputs.forEach(function (input) {
      var composer = input.closest(".kp-composer");
      var btn = composer ? composer.querySelector(".kp-composer__send") : null;

      input.addEventListener("input", function () {
        resizeComposerInput(input);
        updateComposerSendState(input, btn);
      });

      resizeComposerInput(input);
      updateComposerSendState(input, btn);
    });

    window.requestAnimationFrame(function () {
      els.composerInputs.forEach(resizeComposerInput);
    });

    window.addEventListener("resize", function () {
      els.composerInputs.forEach(resizeComposerInput);
    });
  }

  function scrollChatToBottom() {
    if (!els.chatScroll) return;
    requestAnimationFrame(function () {
      els.chatScroll.scrollTop = els.chatScroll.scrollHeight;
    });
  }

  function setAnswerBusy(busy) {
    chatBusy = !!busy;
    setComposerBusy(chatBusy);
  }

  var answerDecorateQueue = [];
  var answerDecorateScheduled = false;

  function getAnswerBody(el) {
    if (!el) return null;
    if (el.classList && el.classList.contains("kp-answer-card__body")) return el;
    return el.closest ? el.closest(".kp-answer-card__body") : null;
  }

  function isSourceHeadingText(text) {
    return /^\s*(출처|참고\s*자료|참고|Source|Sources)\s*[:：]?/i.test(String(text || "").trim());
  }

  function isSourceLabelOnly(text) {
    return /^\s*(출처|참고\s*자료|참고|Source|Sources)\s*[:：]?\s*$/i.test(String(text || "").trim());
  }

  function isSourceCandidate(el) {
    if (!el || !el.textContent) return false;
    if (isSourceHeadingText(el.textContent)) return true;
    if ((el.tagName === "UL" || el.tagName === "OL") && el.firstElementChild) {
      return isSourceHeadingText(el.firstElementChild.textContent);
    }
    return false;
  }

  function decorateAnswerBody(body) {
    if (!body || body.dataset.knuhDecorating === "true") return;
    body.dataset.knuhAnswerStyle = "sample";
    if (body.querySelector(":scope > .kp-answer-source-box")) return;

    var children = Array.prototype.slice.call(body.children).filter(function (el) {
      return !/^(SCRIPT|STYLE|TEMPLATE)$/i.test(el.tagName || "");
    });
    var sourceIndex = -1;

    children.some(function (el, index) {
      if (isSourceCandidate(el)) {
        sourceIndex = index;
        return true;
      }
      if (el.tagName === "HR" && children[index + 1] && isSourceCandidate(children[index + 1])) {
        sourceIndex = index;
        return true;
      }
      return false;
    });

    if (sourceIndex < 0) return;

    body.dataset.knuhDecorating = "true";
    var box = document.createElement("section");
    box.className = "kp-answer-source-box";
    box.setAttribute("aria-label", "출처");
    body.insertBefore(box, children[sourceIndex]);

    children.slice(sourceIndex).forEach(function (el) {
      if (el.tagName === "HR") {
        el.remove();
        return;
      }
      if (isSourceHeadingText(el.textContent)) {
        el.classList.add("kp-answer-source-title");
        if (isSourceLabelOnly(el.textContent)) {
          el.classList.add("kp-answer-source-title--label");
        }
      }
      box.appendChild(el);
    });

    delete body.dataset.knuhDecorating;
  }

  function flushAnswerDecorations() {
    var queue = answerDecorateQueue.slice();
    answerDecorateQueue = [];
    answerDecorateScheduled = false;
    queue.forEach(decorateAnswerBody);
  }

  function queueAnswerDecoration(body) {
    if (!body || answerDecorateQueue.indexOf(body) >= 0) return;
    answerDecorateQueue.push(body);
    if (answerDecorateScheduled) return;
    answerDecorateScheduled = true;
    requestAnimationFrame(flushAnswerDecorations);
  }

  function initAnswerDecoration() {
    document.querySelectorAll(".kp-answer-card__body").forEach(queueAnswerDecoration);
    var chat = document.getElementById("chat");
    if (!chat || !window.MutationObserver) return;

    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        var target = mutation.target.nodeType === 1 ? mutation.target : mutation.target.parentElement;
        var body = getAnswerBody(target);
        if (body) queueAnswerDecoration(body);
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType !== 1) return;
          var addedBody = getAnswerBody(node);
          if (addedBody) queueAnswerDecoration(addedBody);
          node.querySelectorAll && node.querySelectorAll(".kp-answer-card__body").forEach(queueAnswerDecoration);
        });
      });
    });

    observer.observe(chat, {
      childList: true,
      characterData: true,
      subtree: true
    });
  }

  function normalizeQueryLabel(query) {
    if (/교육이수|수료점수|납부 현황/.test(query)) {
      return "교육이수 · 납부 현황 조회";
    }
    if (/보수교육비.*환불|환불.*보수교육비/.test(query)) {
      return "보수교육비 환불 조건";
    }
    if (/면허신고확인서|면허.*출력/.test(query)) {
      return "면허신고확인서 출력 방법";
    }
    return query;
  }

  function getAnswerType(query) {
    if (/교육이수|수료점수|납부 현황/.test(query)) {
      return "member-status";
    }
    if (/환불|회비.*금액|교육비.*금액|금액.*교육비/.test(query)) {
      return "refund";
    }
    if (/면허|신고|출력|확인서/.test(query)) {
      return "license";
    }
    return "license";
  }

  function renderAnswer(type) {
    var body = document.getElementById("chat-answer-body");
    var tplMap = {
      refund: "tpl-answer-refund",
      license: "tpl-answer-license",
      "member-status": "tpl-answer-member-status",
    };
    var tplId = tplMap[type] || "tpl-answer-license";
    var tpl = document.getElementById(tplId);
    if (!body || !tpl) return;
    body.innerHTML = "";
    body.appendChild(tpl.content.cloneNode(true));
  }

  function goHome(e) {
    if (e) e.preventDefault();
    if (!els.main) return;
    if (window.PT_AI_CHAT && typeof window.PT_AI_CHAT.resetForHome === "function") {
      window.PT_AI_CHAT.resetForHome();
    }
    setComposerBusy(false);
    els.main.classList.remove("kp-main--chat");
  }

  function startChat(query, answerType) {
    var text = (query || "").trim();
    if (!text || !els.main) return;

    if (window.PT_AI_CHAT && typeof window.PT_AI_CHAT.startChat === "function") {
      window.PT_AI_CHAT.startChat(text, answerType);
      return;
    }

    if (els.chatUserText) {
      els.chatUserText.textContent = normalizeQueryLabel(text);
    }

    renderAnswer(answerType || getAnswerType(text));
    els.main.classList.add("kp-main--chat");
    if (els.dockInput) {
      resetDockComposerInput(els.dockInput);
    }
    scrollChatToBottom();
  }

  function initChat() {
    els.chatUserText = document.getElementById("chat-user-text");
    els.chatScroll = document.getElementById("chat-scroll");
    var app = document.querySelector(".kp-app");
    if (!app) return;

    var btnCopy = document.getElementById("btn-answer-copy");
    if (btnCopy) {
      btnCopy.addEventListener("click", function () {
        var body = document.getElementById("chat-answer-body");
        if (!body) return;
        var text = body.innerText.trim();
        if (!text) return;
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text);
        }
      });
    }

    app.addEventListener("click", function (e) {
      var vote = e.target.closest(".kp-answer-card__vote");
      if (vote) {
        var group = vote.closest(".kp-answer-card__feedback");
        if (group) {
          group.querySelectorAll(".kp-answer-card__vote").forEach(function (btn) {
            btn.classList.remove("is-on");
          });
          vote.classList.add("is-on");
        }
        return;
      }

      var answerRow = e.target.closest(".kp-answer-row");
      if (answerRow) {
        e.preventDefault();
        return;
      }

      var shortcut = e.target.closest(".kp-shortcut, .kp-composer-chip");
      if (shortcut && shortcut.getAttribute("href") === "#") {
        e.preventDefault();
        return;
      }

      var guideBtn = e.target.closest(".kp-guide-panel__btn, .kp-guide-panel__status-cta, .kp-acc__grid-btn");
      if (guideBtn) {
        startChat(
          guideBtn.getAttribute("data-query") || guideBtn.textContent.trim(),
          guideBtn.getAttribute("data-answer-type")
        );
        return;
      }

      var qitem = e.target.closest(".kp-qitem");
      if (qitem) {
        var query = window.PT_AI_CHAT && typeof window.PT_AI_CHAT.getQuickSearchQuery === "function"
          ? window.PT_AI_CHAT.getQuickSearchQuery(qitem)
          : (qitem.getAttribute("data-query") || qitem.textContent);
        startChat(query);
        return;
      }

      var composerSend = e.target.closest(".kp-composer__send");
      if (composerSend) {
        if (chatBusy) {
          if (window.PT_AI_CHAT && typeof window.PT_AI_CHAT.abortChatRequest === "function") {
            window.PT_AI_CHAT.abortChatRequest();
          }
          return;
        }
        var emptyInput = document.querySelector(".kp-empty .kp-composer__input");
        if (composerSend.closest(".kp-empty") && emptyInput) {
          startChat(emptyInput.value);
          return;
        }
        if (composerSend.id === "dock-send" && els.dockInput) {
          startChat(els.dockInput.value);
          els.dockInput.value = "";
          resizeComposerInput(els.dockInput);
          updateComposerSendState(els.dockInput, els.dockSend);
        }
      }
    });

    els.composerInputs = document.querySelectorAll(".kp-composer__input");
    els.composerInputs.forEach(function (input) {
      input.addEventListener("keydown", function (e) {
        if (e.key !== "Enter" || e.shiftKey) return;
        e.preventDefault();
        var text = input.value.trim();
        if (!text) return;
        startChat(text);
        if (input.id === "dock-input") {
          input.value = "";
          resizeComposerInput(input);
          updateComposerSendState(input, els.dockSend);
        }
      });
    });
  }

  function initGuideSlide() {
    var viewport = document.getElementById("guide-slide-viewport");
    var dotsWrap = document.getElementById("guide-slide-dots");
    var btnPrev = document.getElementById("guide-slide-prev");
    var btnNext = document.getElementById("guide-slide-next");
    if (!viewport || !dotsWrap) return;

    var panels = viewport.querySelectorAll(".kp-guide-panel");
    if (!panels.length) return;

    var dots = [];
    var activeIndex = 0;
    var isAnimating = false;
    var scrollEndTimer = null;
    var resizeTimer = null;

    function getVisibleCount() {
      var visible = parseInt(
        window.getComputedStyle(viewport).getPropertyValue("--guide-visible"),
        10
      );
      return visible > 0 ? visible : 1;
    }

    function getPageCount() {
      return Math.max(1, panels.length - getVisibleCount() + 1);
    }

    function getMaxIndex() {
      return getPageCount() - 1;
    }

    function clampIndex(index) {
      return Math.max(0, Math.min(index, getMaxIndex()));
    }

    function buildDots() {
      var pageCount = getPageCount();
      dotsWrap.innerHTML = "";

      for (var i = 0; i < pageCount; i++) {
        var dot = document.createElement("button");
        dot.type = "button";
        dot.setAttribute("role", "tab");
        dot.setAttribute("aria-label", i + 1 + "번째");
        dot.addEventListener("click", function (pageIndex) {
          return function () {
            scrollToIndex(pageIndex);
          };
        }(i));
        dotsWrap.appendChild(dot);
      }

      dots = dotsWrap.querySelectorAll("button");
    }

    function updateNavState(index) {
      if (btnPrev) btnPrev.disabled = index <= 0;
      if (btnNext) btnNext.disabled = index >= getMaxIndex();
    }

    function setActive(index) {
      activeIndex = clampIndex(index);
      dots.forEach(function (dot, i) {
        var on = i === activeIndex;
        dot.classList.toggle("is-active", on);
        dot.setAttribute("aria-selected", on ? "true" : "false");
      });
      updateNavState(activeIndex);
    }

    function getNearestIndex() {
      var scrollLeft = viewport.scrollLeft;
      var nearest = 0;
      var minDiff = Infinity;
      var maxIndex = getMaxIndex();

      for (var i = 0; i <= maxIndex; i++) {
        var diff = Math.abs(panels[i].offsetLeft - scrollLeft);
        if (diff < minDiff) {
          minDiff = diff;
          nearest = i;
        }
      }

      return nearest;
    }

    function finishScroll() {
      isAnimating = false;
      var index = getNearestIndex();
      var maxScroll = panels[getMaxIndex()].offsetLeft;

      if (viewport.scrollLeft > maxScroll + 2) {
        viewport.scrollTo({ left: maxScroll, behavior: "smooth" });
        index = getMaxIndex();
      }

      setActive(index);
    }

    function scrollToIndex(index, smooth) {
      var panel = panels[clampIndex(index)];
      if (!panel) return;

      isAnimating = true;
      setActive(clampIndex(index));

      viewport.scrollTo({
        left: panel.offsetLeft,
        behavior: smooth === false ? "auto" : "smooth",
      });

      window.clearTimeout(scrollEndTimer);
      scrollEndTimer = window.setTimeout(finishScroll, smooth === false ? 32 : 420);
    }

    function goPrev() {
      scrollToIndex(activeIndex - 1);
    }

    function goNext() {
      scrollToIndex(activeIndex + 1);
    }

    function handleResize() {
      window.clearTimeout(resizeTimer);
      resizeTimer = window.setTimeout(function () {
        var prevIndex = activeIndex;
        buildDots();
        scrollToIndex(clampIndex(prevIndex), false);
        setActive(clampIndex(prevIndex));
      }, 120);
    }

    if (btnPrev) {
      btnPrev.addEventListener("click", goPrev);
    }

    if (btnNext) {
      btnNext.addEventListener("click", goNext);
    }

    viewport.addEventListener(
      "scroll",
      function () {
        if (isAnimating) return;
        window.requestAnimationFrame(function () {
          setActive(getNearestIndex());
        });
      },
      { passive: true }
    );

    viewport.addEventListener("scrollend", finishScroll, { passive: true });

    viewport.addEventListener("touchstart", function () {
      isAnimating = false;
    }, { passive: true });

    viewport.addEventListener("touchend", function () {
      window.clearTimeout(scrollEndTimer);
      scrollEndTimer = window.setTimeout(finishScroll, 120);
    }, { passive: true });

    window.addEventListener("resize", handleResize);

    buildDots();
    setActive(0);
  }

  function bindEvents() {
    if (els.btnPanel) {
      els.btnPanel.addEventListener("click", togglePanel);
    }

    if (els.btnPanelClose) {
      els.btnPanelClose.addEventListener("click", closePanel);
    }

    if (els.scrim) {
      els.scrim.addEventListener("click", closePanel);
    }

    els.btnBackHome = document.getElementById("btn-back-home");
    if (els.btnBackHome) {
      els.btnBackHome.addEventListener("click", goHome);
    }

    els.btnDockHome = document.getElementById("dock-btn-home");
    if (els.btnDockHome) {
      els.btnDockHome.addEventListener("click", goHome);
    }

    window.addEventListener("resize", updatePanel);
  }

  function init() {
    els.body = document.getElementById("kp-body");
    els.main = document.getElementById("main");
    els.panel = document.getElementById("panel");
    els.scrim = document.getElementById("scrim");
    els.btnPanel = document.getElementById("btn-panel");
    els.btnPanelClose = document.getElementById("btn-panel-close");

    if (!els.main || !els.panel) return;

    panelOpen = window.innerWidth >= MOBILE_BP;
    if (window.PT_AI_CHAT && typeof window.PT_AI_CHAT.init === "function") {
      window.PT_AI_CHAT.init({
        onBusyChange: setAnswerBusy,
        onScroll: scrollChatToBottom,
        onChatActivated: function () {
          if (els.main) els.main.classList.add("kp-main--chat");
        },
        onShowLoading: function (body) {
          body.innerHTML = '<p class="kp-answer-status">답변을 생성하고 있습니다...</p>';
        },
        onShowError: function (body, message) {
          var safe = window.PT_AI_RENDER ? window.PT_AI_RENDER.escapeHtml(message) : String(message || "오류가 발생했습니다.");
          body.innerHTML = '<p class="kp-answer-status kp-answer-status--error">' + safe + "</p>";
        },
        onShowAborted: function (body) {
          var notice = document.createElement("p");
          notice.className = "kp-answer-status";
          notice.textContent = "답변 생성이 중단되었습니다.";
          body.appendChild(notice);
        }
      });
    }
    bindEvents();
    initTabs();
    initAccordions();
    initComposerSend();
    initChat();
    initAnswerDecoration();
    initGuideSlide();
    updatePanel();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
