/**
 * Accessibility controls - Font size and display preferences
 */

class AccessibilityControls {
  constructor() {
    this.fontSizes = ['normal', 'large', 'xlarge'];
    this.currentFontSize = 'normal';

    this.init();
  }

  init() {
    // Load saved preferences
    this.loadPreferences();

    // Bind event handlers to all accessibility buttons
    document.querySelectorAll('.a11y-btn').forEach(btn => {
      btn.addEventListener('click', () => this.handleAction(btn.dataset.action));
    });

    // Update button states
    this.updateButtons();
  }

  loadPreferences() {
    try {
      const saved = localStorage.getItem('a11y-font-size');
      if (saved && this.fontSizes.includes(saved)) {
        this.currentFontSize = saved;
        this.applyFontSize();
      }
    } catch (e) {
      // localStorage not available
    }
  }

  savePreferences() {
    try {
      localStorage.setItem('a11y-font-size', this.currentFontSize);
    } catch (e) {
      // localStorage not available
    }
  }

  handleAction(action) {
    switch (action) {
      case 'font-decrease':
        this.decreaseFontSize();
        break;
      case 'font-reset':
        this.resetFontSize();
        break;
      case 'font-increase':
        this.increaseFontSize();
        break;
    }
  }

  decreaseFontSize() {
    const currentIndex = this.fontSizes.indexOf(this.currentFontSize);
    if (currentIndex > 0) {
      this.currentFontSize = this.fontSizes[currentIndex - 1];
      this.applyFontSize();
      this.savePreferences();
      this.updateButtons();
    }
  }

  resetFontSize() {
    this.currentFontSize = 'normal';
    this.applyFontSize();
    this.savePreferences();
    this.updateButtons();
  }

  increaseFontSize() {
    const currentIndex = this.fontSizes.indexOf(this.currentFontSize);
    if (currentIndex < this.fontSizes.length - 1) {
      this.currentFontSize = this.fontSizes[currentIndex + 1];
      this.applyFontSize();
      this.savePreferences();
      this.updateButtons();
    }
  }

  applyFontSize() {
    const html = document.documentElement;

    // Remove all font size classes
    html.classList.remove('a11y-font-large', 'a11y-font-xlarge');

    // Apply current font size class
    if (this.currentFontSize === 'large') {
      html.classList.add('a11y-font-large');
    } else if (this.currentFontSize === 'xlarge') {
      html.classList.add('a11y-font-xlarge');
    }
  }

  updateButtons() {
    document.querySelectorAll('.a11y-btn').forEach(btn => {
      const action = btn.dataset.action;

      // Update active state for reset button
      if (action === 'font-reset') {
        btn.classList.toggle('active', this.currentFontSize === 'normal');
      }

      // Update disabled state for decrease/increase buttons
      if (action === 'font-decrease') {
        btn.disabled = this.currentFontSize === 'normal';
      }
      if (action === 'font-increase') {
        btn.disabled = this.currentFontSize === 'xlarge';
      }
    });
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new AccessibilityControls());
} else {
  new AccessibilityControls();
}
