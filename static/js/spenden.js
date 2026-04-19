(() => {
  const buttons = document.querySelectorAll('.copy-btn');
  if (!buttons.length || !navigator.clipboard) return;

  buttons.forEach((btn) => {
    btn.addEventListener('click', async () => {
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
        // Clipboard denied — fall back silently; the value is selectable.
      }
    });
  });
})();
