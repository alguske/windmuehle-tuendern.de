/**
 * Back to top button - Shows when scrolling up past the threshold.
 * Hides when scrolling down or near the top.
 */

class BackToTop {
  constructor() {
    this.button = document.querySelector('.back-to-top');
    this.threshold = 300;
    this.deltaMin = 5; // ignore jitter
    this.isVisible = false;
    this.ticking = false;
    this.lastScrollY = window.scrollY;

    if (this.button) {
      this.init();
    }
  }

  init() {
    this.button.addEventListener('click', () => this.scrollToTop());
    window.addEventListener('scroll', () => this.handleScroll(), { passive: true });
  }

  handleScroll() {
    if (!this.ticking) {
      window.requestAnimationFrame(() => {
        this.checkVisibility();
        this.ticking = false;
      });
      this.ticking = true;
    }
  }

  checkVisibility() {
    const currentY = window.scrollY;
    const delta = currentY - this.lastScrollY;

    if (Math.abs(delta) < this.deltaMin) return;

    const scrollingUp = delta < 0;
    const pastThreshold = currentY > this.threshold;
    const shouldShow = scrollingUp && pastThreshold;

    if (shouldShow !== this.isVisible) {
      this.isVisible = shouldShow;
      this.button.hidden = !shouldShow;
    }

    this.lastScrollY = currentY;
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });

    // Focus on skip-to-content link or main content for accessibility
    const skipLink = document.querySelector('.skip-to-content');
    if (skipLink) {
      skipLink.focus();
    }
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new BackToTop());
} else {
  new BackToTop();
}
