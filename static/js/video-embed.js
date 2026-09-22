/**
 * Two-click YouTube embed - swaps the poster for the player on click, so no
 * request reaches Google until the visitor has asked for the video.
 */

class VideoEmbed {
  constructor(container) {
    this.container = container;
    this.videoId = container.dataset.youtubeId;
    this.trigger = container.querySelector('.video-embed-trigger');

    if (this.trigger && this.videoId) {
      this.trigger.addEventListener('click', () => this.play());
    }
  }

  play() {
    const frame = document.createElement('iframe');
    frame.className = 'video-embed-frame';
    frame.src = `https://www.youtube-nocookie.com/embed/${this.videoId}?autoplay=1&rel=0`;
    frame.title = this.container.dataset.title;
    frame.allow = 'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture';
    frame.allowFullscreen = true;

    this.trigger.replaceWith(frame);
    frame.focus();
  }
}

// Initialize on DOM ready
function initVideoEmbeds() {
  document.querySelectorAll('.video-embed').forEach((el) => new VideoEmbed(el));
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initVideoEmbeds);
} else {
  initVideoEmbeds();
}
