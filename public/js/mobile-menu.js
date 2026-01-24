/**
 * Mobile menu - Hamburger menu with focus trap and accessibility
 */

class MobileMenu {
  constructor() {
    this.menuBtn = document.querySelector('.mobile-menu-btn');
    this.menu = document.getElementById('mobile-menu');
    this.overlay = document.querySelector('.mobile-overlay');
    this.isOpen = false;
    this.previouslyFocused = null;

    if (this.menuBtn && this.menu) {
      this.init();
    }
  }

  init() {
    // Toggle menu on button click
    this.menuBtn.addEventListener('click', () => this.toggle());

    // Close on overlay click
    this.overlay?.addEventListener('click', () => this.close());

    // Keyboard navigation
    document.addEventListener('keydown', (e) => this.handleKeyboard(e));

    // Close menu on resize if viewport becomes larger
    window.addEventListener('resize', () => {
      if (window.innerWidth > 768 && this.isOpen) {
        this.close();
      }
    });

    // Close menu when clicking a link
    this.menu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => this.close());
    });
  }

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    this.isOpen = true;
    this.previouslyFocused = document.activeElement;

    // Update ARIA attributes
    this.menuBtn.setAttribute('aria-expanded', 'true');
    this.menu.setAttribute('aria-hidden', 'false');
    this.menu.classList.add('active');
    this.overlay?.classList.add('active');

    // Prevent body scroll
    document.body.style.overflow = 'hidden';

    // Focus first menu item
    const firstLink = this.menu.querySelector('a');
    if (firstLink) {
      firstLink.focus();
    }

    // Setup focus trap
    this.trapFocus();
  }

  close() {
    this.isOpen = false;

    // Update ARIA attributes
    this.menuBtn.setAttribute('aria-expanded', 'false');
    this.menu.setAttribute('aria-hidden', 'true');
    this.menu.classList.remove('active');
    this.overlay?.classList.remove('active');

    // Restore body scroll
    document.body.style.overflow = '';

    // Restore focus
    if (this.previouslyFocused) {
      this.previouslyFocused.focus();
    }
  }

  handleKeyboard(e) {
    if (!this.isOpen) return;

    if (e.key === 'Escape') {
      this.close();
    }
  }

  trapFocus() {
    const focusableElements = this.menu.querySelectorAll(
      'a, button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])'
    );

    if (focusableElements.length === 0) return;

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    const handleTab = (e) => {
      if (!this.isOpen || e.key !== 'Tab') return;

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
    };

    this.menu.addEventListener('keydown', handleTab);
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new MobileMenu());
} else {
  new MobileMenu();
}
