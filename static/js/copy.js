(() => {
  if (!navigator.clipboard) return;

  const findFeedback = (btn) => {
    const parent = btn.parentElement;
    if (!parent) return null;
    return parent.querySelector('.copy-feedback, .contact-card__feedback');
  };

  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('.copy-btn');
    if (!btn) return;

    const value = btn.dataset.copy;
    if (!value) return;

    try {
      await navigator.clipboard.writeText(value);
      const originalLabel = btn.getAttribute('aria-label');
      const copiedLabel = btn.dataset.copiedLabel || 'Copied';

      btn.classList.add('copy-btn--copied');
      btn.setAttribute('aria-label', copiedLabel);

      const feedback = findFeedback(btn);
      if (feedback) feedback.textContent = copiedLabel;

      setTimeout(() => {
        btn.classList.remove('copy-btn--copied');
        if (originalLabel) btn.setAttribute('aria-label', originalLabel);
        if (feedback) feedback.textContent = '';
      }, 1800);
    } catch (_) {
      // Clipboard denied — value is selectable.
    }
  });
})();
