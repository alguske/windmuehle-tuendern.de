(() => {
  if (!navigator.clipboard) return;

  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('.copy-btn');
    if (!btn) return;

    const value = btn.dataset.copy;
    if (!value) return;

    try {
      await navigator.clipboard.writeText(value);
      const originalLabel = btn.getAttribute('aria-label');
      btn.classList.add('copy-btn--copied');
      btn.setAttribute('aria-label', btn.dataset.copiedLabel || 'Copied');
      setTimeout(() => {
        btn.classList.remove('copy-btn--copied');
        if (originalLabel) btn.setAttribute('aria-label', originalLabel);
      }, 1800);
    } catch (_) {
      // Clipboard denied — value is selectable.
    }
  });
})();
