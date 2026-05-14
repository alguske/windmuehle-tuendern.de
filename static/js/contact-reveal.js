(() => {
  const cards = document.querySelectorAll('.contact-card[data-reveal-card]');
  if (!cards.length) return;

  const decode = (v) => {
    try { return v ? atob(v) : ''; } catch (_) { return ''; }
  };

  cards.forEach((card) => {
    const trigger = card.querySelector('.contact-card__reveal');
    const tpl = card.querySelector('.contact-card__revealed-tpl');
    if (!trigger || !tpl) return;

    trigger.addEventListener('click', () => {
      const display = decode(card.dataset.display);
      const tel = decode(card.dataset.tel);
      const wa = decode(card.dataset.wa);
      const copyLabel = card.dataset.copyLabel || 'Copy';

      const frag = tpl.content.cloneNode(true);

      const numBtn = frag.querySelector('.contact-card__number');
      if (numBtn) {
        numBtn.textContent = display;
        numBtn.dataset.copy = display;
        numBtn.setAttribute('aria-label', `${display} — ${copyLabel}`);
      }

      const callLink = frag.querySelector('.btn-call');
      if (callLink && tel) callLink.href = 'tel:' + tel;

      const waLink = frag.querySelector('.btn-whatsapp');
      if (waLink) {
        if (wa) waLink.href = 'https://wa.me/' + wa;
        else waLink.remove();
      }

      trigger.setAttribute('aria-expanded', 'true');
      trigger.replaceWith(frag);

      // Move focus to the revealed number so keyboard / SR users land there.
      const revealed = card.querySelector('.contact-card__number');
      if (revealed) revealed.focus();
    }, { once: true });
  });
})();
