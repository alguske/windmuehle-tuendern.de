/**
 * Lightbox - Image viewer with keyboard navigation
 */

class Lightbox {
  constructor() {
    this.lightbox = document.getElementById('lightbox');
    this.image = this.lightbox?.querySelector('.lightbox-image');
    this.closeBtn = this.lightbox?.querySelector('.lightbox-close');
    this.prevBtn = this.lightbox?.querySelector('.lightbox-prev');
    this.nextBtn = this.lightbox?.querySelector('.lightbox-next');
    this.counter = this.lightbox?.querySelector('.lightbox-counter');
    this.backdrop = this.lightbox?.querySelector('.lightbox-backdrop');

    this.images = [];
    this.currentIndex = 0;
    this.previouslyFocused = null;

    if (this.lightbox) {
      this.init();
    }
  }

  init() {
    // Bind event handlers
    this.closeBtn?.addEventListener('click', () => this.close());
    this.prevBtn?.addEventListener('click', () => this.prev());
    this.nextBtn?.addEventListener('click', () => this.next());
    this.backdrop?.addEventListener('click', () => this.close());

    // Keyboard navigation
    document.addEventListener('keydown', (e) => this.handleKeyboard(e));

    // Find all image galleries and clickable images
    this.setupGalleries();
  }

  setupGalleries() {
    // Add lazy loading to all blog content and gallery images
    document.querySelectorAll('.blog-content img, .post-images img').forEach(img => {
      img.loading = 'lazy';
      img.decoding = 'async';
    });

    // Images in galleries
    document.querySelectorAll('[data-lightbox-gallery]').forEach(gallery => {
      const images = gallery.querySelectorAll('img');
      images.forEach((img, index) => {
        img.style.cursor = 'pointer';
        img.addEventListener('click', () => {
          this.images = Array.from(images).map(i => ({
            src: i.src,
            alt: i.alt
          }));
          this.open(index);
        });
      });
    });

    // Single images with data-lightbox attribute
    document.querySelectorAll('[data-lightbox] img, figure[data-lightbox] img').forEach(img => {
      img.style.cursor = 'pointer';
      img.addEventListener('click', () => {
        this.images = [{ src: img.src, alt: img.alt }];
        this.open(0);
      });
    });

    // Blog content images
    document.querySelectorAll('.blog-content img, .post-images img').forEach(img => {
      img.style.cursor = 'pointer';
      img.addEventListener('click', () => {
        // Collect all images in the blog content
        const parent = img.closest('.blog-content') || img.closest('.post-images');
        const allImages = parent ? Array.from(parent.querySelectorAll('img')) : [img];

        this.images = allImages.map(i => ({
          src: i.src,
          alt: i.alt
        }));

        const index = allImages.indexOf(img);
        this.open(index >= 0 ? index : 0);
      });
    });
  }

  open(index) {
    if (!this.lightbox || this.images.length === 0) return;

    this.currentIndex = index;
    this.previouslyFocused = document.activeElement;

    // Show lightbox
    this.lightbox.hidden = false;
    document.body.style.overflow = 'hidden';

    // Show image
    this.showImage();

    // Focus close button for accessibility
    this.closeBtn?.focus();

    // Trap focus
    this.trapFocus();
  }

  close() {
    if (!this.lightbox) return;

    this.lightbox.hidden = true;
    document.body.style.overflow = '';

    // Restore focus
    if (this.previouslyFocused) {
      this.previouslyFocused.focus();
    }
  }

  prev() {
    if (this.images.length <= 1) return;
    this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
    this.showImage();
  }

  next() {
    if (this.images.length <= 1) return;
    this.currentIndex = (this.currentIndex + 1) % this.images.length;
    this.showImage();
  }

  showImage() {
    const current = this.images[this.currentIndex];
    if (!current || !this.image) return;

    this.image.src = current.src;
    this.image.alt = current.alt || '';

    // Update counter
    if (this.counter) {
      this.counter.textContent = `${this.currentIndex + 1} / ${this.images.length}`;
    }

    // Show/hide prev/next buttons
    const showNav = this.images.length > 1;
    if (this.prevBtn) this.prevBtn.style.display = showNav ? '' : 'none';
    if (this.nextBtn) this.nextBtn.style.display = showNav ? '' : 'none';
    if (this.counter) this.counter.style.display = showNav ? '' : 'none';
  }

  handleKeyboard(e) {
    if (this.lightbox?.hidden) return;

    switch (e.key) {
      case 'Escape':
        this.close();
        break;
      case 'ArrowLeft':
        this.prev();
        break;
      case 'ArrowRight':
        this.next();
        break;
      case 'Tab':
        // Handle focus trap on tab key
        break;
    }
  }

  trapFocus() {
    const focusableElements = this.lightbox.querySelectorAll(
      'button:not([disabled]), [tabindex]:not([tabindex="-1"])'
    );

    if (focusableElements.length === 0) return;

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    this.lightbox.addEventListener('keydown', (e) => {
      if (e.key !== 'Tab') return;

      if (e.shiftKey) {
        if (document.activeElement === firstElement) {
          e.preventDefault();
          lastElement.focus();
        }
      } else {
        if (document.activeElement === lastElement) {
          e.preventDefault();
          firstElement.focus();
        }
      }
    });
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new Lightbox());
} else {
  new Lightbox();
}
