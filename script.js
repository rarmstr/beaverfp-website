// Beaver FP website

document.addEventListener('DOMContentLoaded', function () {

  /* ---------------- FAQ accordion ---------------- */
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');
    if (!question) return;

    question.addEventListener('click', () => {
      const willOpen = !item.classList.contains('active');

      faqItems.forEach(other => {
        other.classList.remove('active');
        const btn = other.querySelector('.faq-question');
        if (btn) btn.setAttribute('aria-expanded', 'false');
      });

      if (willOpen) {
        item.classList.add('active');
        question.setAttribute('aria-expanded', 'true');
      }
    });
  });

  /* ---------------- Smooth scrolling ---------------- */
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const href = this.getAttribute('href');
      if (href === '#' || href.length <= 1) return;

      const target = document.querySelector(href);
      if (!target) return;

      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  /* ---------------- Demo video ----------------
     Muted and silent by default. Autoplays only when it scrolls into view,
     and only if the visitor hasn't asked for reduced motion — otherwise it
     waits behind its poster until they press play. */
  const video = document.getElementById('demoVideo');
  const toggle = document.getElementById('videoToggle');
  const sound = document.getElementById('videoSound');
  const frame = video ? video.closest('.video-frame') : null;

  if (video && toggle && frame) {
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    const setPlaying = playing => {
      frame.classList.toggle('is-playing', playing);
      toggle.setAttribute('aria-label', playing ? 'Pause the tour' : 'Play the tour');
    };

    toggle.addEventListener('click', () => {
      if (video.paused) {
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });

    video.addEventListener('play', () => setPlaying(true));
    video.addEventListener('pause', () => setPlaying(false));

    /* Sound. Autoplay only works muted, so the video always starts muted and
       this is the only way to the narration. Unmuting also starts playback —
       asking for sound on a stopped video and getting silence reads as broken. */
    if (sound) {
      const label = sound.querySelector('.video-sound-label');

      const setMuted = muted => {
        video.muted = muted;
        sound.setAttribute('aria-pressed', String(!muted));
        sound.setAttribute('aria-label', muted ? 'Turn sound on' : 'Turn sound off');
        if (label) label.textContent = muted ? 'Sound off' : 'Sound on';
      };

      setMuted(true);

      sound.addEventListener('click', () => {
        const turningOn = video.muted;
        setMuted(!turningOn);
        if (turningOn) {
          video.volume = 1;
          if (video.paused) video.play().catch(() => {});
        }
      });

      // Keep the button honest if anything else changes the volume.
      video.addEventListener('volumechange', () => {
        const muted = video.muted || video.volume === 0;
        sound.setAttribute('aria-pressed', String(!muted));
        if (label) label.textContent = muted ? 'Sound off' : 'Sound on';
      });
    }

    if (!reduceMotion && 'IntersectionObserver' in window) {
      // Autoplay when it scrolls into view, but never fight a deliberate pause:
      // only resume playback the observer itself stopped.
      let pausedByScroll = false;

      toggle.addEventListener('click', () => { pausedByScroll = false; });

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            if (video.paused && (pausedByScroll || video.currentTime === 0)) {
              pausedByScroll = false;
              video.play().catch(() => {}); // autoplay may be blocked; poster stays
            }
          } else if (!video.paused) {
            pausedByScroll = true;
            video.pause();
          }
        });
      }, { threshold: 0.4 });

      observer.observe(video);
    }
  }

  /* ---------------- Screenshot modal ---------------- */
  const modal = document.getElementById('imageModal');
  const modalImg = document.getElementById('modalImage');
  const closeBtn = document.querySelector('.modal-close');

  if (modal && modalImg && closeBtn) {
    let lastFocused = null;

    const openModal = img => {
      lastFocused = document.activeElement;
      modalImg.src = img.dataset.full || img.currentSrc || img.src;
      modalImg.alt = img.alt;
      modal.classList.add('show');
      document.body.style.overflow = 'hidden';
      closeBtn.focus();
    };

    const closeModal = () => {
      modal.classList.remove('show');
      document.body.style.overflow = '';
      modalImg.removeAttribute('src');
      if (lastFocused) lastFocused.focus();
    };

    document.querySelectorAll('.shot-button').forEach(button => {
      button.addEventListener('click', () => {
        const img = button.querySelector('img');
        if (img) openModal(img);
      });
    });

    closeBtn.addEventListener('click', closeModal);

    modal.addEventListener('click', e => {
      if (e.target === modal) closeModal();
    });

    document.addEventListener('keydown', e => {
      if (e.key === 'Escape' && modal.classList.contains('show')) closeModal();
    });
  }
});
