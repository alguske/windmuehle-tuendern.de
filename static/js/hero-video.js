/**
 * Hero background video - attaches the source only on wide viewports and when
 * the visitor has not asked for reduced motion. Everyone else keeps the poster
 * image and never downloads the clip.
 */

class HeroVideo {
  constructor() {
    this.video = document.querySelector('.hero-video');
    this.minWidth = 768;

    if (this.video && this.shouldPlay()) {
      this.load();
    }
  }

  shouldPlay() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return false;
    }
    return window.innerWidth > this.minWidth;
  }

  load() {
    const source = document.createElement('source');
    source.src = this.video.dataset.src;
    source.type = 'video/mp4';
    this.video.appendChild(source);
    this.video.load();
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new HeroVideo());
} else {
  new HeroVideo();
}
