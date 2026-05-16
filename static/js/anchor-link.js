(() => {
  const labels = window.galleryAnchorLabels || { copy: 'Copy link', copied: 'Copied' };
  const sections = document.querySelectorAll('section.gallery-section[id]');
  if (!sections.length) return;

  sections.forEach((section) => {
    const h3 = section.querySelector('h3');
    if (!h3 || section.querySelector('.anchor-link')) return;

    const url = `${location.origin}${location.pathname}#${section.id}`;
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'anchor-link';
    btn.setAttribute('aria-label', labels.copy);
    btn.title = labels.copy;
    btn.innerHTML = '<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.07 0l3-3a5 5 0 0 0-7.07-7.07l-1.5 1.5"/><path d="M14 11a5 5 0 0 0-7.07 0l-3 3a5 5 0 0 0 7.07 7.07l1.5-1.5"/></svg>';

    btn.addEventListener('click', async (e) => {
      e.preventDefault();
      history.replaceState(null, '', `#${section.id}`);
      try {
        if (navigator.clipboard) {
          await navigator.clipboard.writeText(url);
        }
        btn.classList.add('anchor-link--copied');
        btn.setAttribute('aria-label', labels.copied);
        btn.title = labels.copied;
        setTimeout(() => {
          btn.classList.remove('anchor-link--copied');
          btn.setAttribute('aria-label', labels.copy);
          btn.title = labels.copy;
        }, 1800);
      } catch (_) {
        // clipboard denied — anchor still updated in URL
      }
    });

    const header = document.createElement('div');
    header.className = 'gallery-section-header';
    h3.parentNode.insertBefore(header, h3);
    header.appendChild(h3);
    header.appendChild(btn);
  });
})();
