(function () {
  const root = document.documentElement;
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (!window.gsap || !window.ScrollTrigger || reduced) {
    root.classList.remove('is_motion');
    return;
  }

  gsap.registerPlugin(ScrollTrigger);
  gsap.defaults({ ease: 'power3.out', duration: .9 });
  root.classList.remove('is_motion');

  function reveal(targets, trigger, vars) {
    if (!targets || !targets.length) return;
    gsap.from(targets, Object.assign({
      y: 36,
      autoAlpha: 0,
      stagger: .1,
      scrollTrigger: { trigger: trigger, start: 'top 82%', once: true }
    }, vars));
  }

  const quick = document.querySelector('.quick_wrap');
  const quickFixed = quick && getComputedStyle(quick).position === 'fixed';

  const intro = gsap.timeline({ delay: .15 })
    .from('.hero_label', { y: 24, autoAlpha: 0, duration: .7 })
    .from('.hero_title', { y: 48, autoAlpha: 0 }, '-=.45')
    .from('.search_form', { y: 48, autoAlpha: 0 }, '-=.65')
    .from('.search_form > *', { y: 16, autoAlpha: 0, duration: .6, stagger: .07, clearProps: 'all' }, '-=.6')
    .from('.hero_bottom', { y: 20, autoAlpha: 0, duration: .7 }, '-=.5');

  if (quickFixed) {
    intro.from(quick.children, { x: 32, autoAlpha: 0, duration: .7, stagger: .08, clearProps: 'all' }, '-=.6');
  } else if (quick) {
    reveal(quick.children, quick, { y: 24, duration: .7, scrollTrigger: { trigger: quick, start: 'top 92%', once: true } });
  }

  gsap.set('.hero_image', { scale: 1.06 });
  gsap.to('.hero_image', {
    yPercent: 10,
    ease: 'none',
    scrollTrigger: { trigger: '.hero_wrap', start: 'top top', end: 'bottom top', scrub: true }
  });
  gsap.to('.hero_content', {
    y: -48,
    autoAlpha: .25,
    ease: 'none',
    scrollTrigger: { trigger: '.hero_wrap', start: '35% top', end: 'bottom top', scrub: true }
  });

  if (window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
    const hero = document.querySelector('.hero_wrap');
    const moveX = gsap.quickTo('.hero_image', 'x', { duration: 1.2, ease: 'power2.out' });
    hero.addEventListener('pointermove', function (event) {
      const rect = hero.getBoundingClientRect();
      moveX(((event.clientX - rect.left) / rect.width - .5) * -28);
    });
    hero.addEventListener('pointerleave', function () { moveX(0); });

    document.querySelectorAll('.search_btn, .service_arrow').forEach(function (button) {
      const area = button.closest('.service_item') || button;
      const toX = gsap.quickTo(button, 'x', { duration: .4 });
      const toY = gsap.quickTo(button, 'y', { duration: .4 });
      area.addEventListener('pointermove', function (event) {
        const rect = button.getBoundingClientRect();
        const dx = event.clientX - (rect.left + rect.width / 2);
        const dy = event.clientY - (rect.top + rect.height / 2);
        const reach = area === button ? 1 : Math.max(0, 1 - Math.hypot(dx, dy) / 160);
        toX(dx * .25 * reach);
        toY(dy * .25 * reach);
      });
      area.addEventListener('pointerleave', function () { toX(0); toY(0); });
    });
  }

  document.querySelectorAll('.section_head, .notice_header').forEach(function (head) {
    reveal(head.querySelectorAll('.section_label, .section_title, .section_desc'), head, { stagger: .12 });
  });

  document.querySelectorAll('.service_item').forEach(function (item, index) {
    reveal(item.children, '.service_list', { y: 28, duration: .7, stagger: .07, delay: index * .12 });
  });
  reveal(document.querySelectorAll('.service_live'), '.service_live', { y: 20, scrollTrigger: { trigger: '.service_live', start: 'top 92%', once: true } });

  gsap.from('.ai_chat', { y: 40, autoAlpha: 0, scrollTrigger: { trigger: '.ai_grid', start: 'top 80%', once: true } });
  document.querySelectorAll('.chat_msg').forEach(function (message, index) {
    gsap.from(message, {
      y: 20,
      scale: .94,
      autoAlpha: 0,
      duration: .55,
      delay: .35 + index * .45,
      transformOrigin: message.classList.contains('chat_user') ? '100% 100%' : '0% 100%',
      scrollTrigger: { trigger: '.ai_grid', start: 'top 80%', once: true }
    });
  });
  reveal(document.querySelectorAll('.ai_points li'), '.ai_points', { y: 28, stagger: .14 });

  document.querySelectorAll('.board_column').forEach(function (column, index) {
    reveal(column.querySelectorAll('.board_head, .notice_row, .faq_row'), column, { y: 24, duration: .7, stagger: .07, delay: index * .15 });
  });

  reveal(document.querySelectorAll('.footer_left, .footer_right, .footer_note'), '.footer_wrap', { y: 20, scrollTrigger: { trigger: '.footer_wrap', start: 'top 92%', once: true } });

  window.addEventListener('load', function () { ScrollTrigger.refresh(); });
})();
