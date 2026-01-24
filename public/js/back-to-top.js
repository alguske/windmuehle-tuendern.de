/**
 * Back to top button - Shows after scrolling down
 */

class BackToTop {
  constructor() {
    this.button = document.querySelector('.back-to-top');
    this.threshold = 300; // pixels to scroll before showing
    this.isVisible = false;
    this.ticking = false;

    if (this.button) {
      this.init();
    }
  }

  init() {
    // Click handler
    this.button.addEventListener('click', () => this.scrollToTop());

    // Scroll handler with throttling
    window.addEventListener('scroll', () => this.handleScroll(), { passive: true });

    // Initial check
    this.checkVisibility();
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
    const shouldShow = window.scrollY > this.threshold;

    if (shouldShow !== this.isVisible) {
      this.isVisible = shouldShow;
      this.button.hidden = !shouldShow;
    }
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
