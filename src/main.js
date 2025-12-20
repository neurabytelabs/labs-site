/**
 * NeuraByte Labs - Main Entry Point
 * v11.1.3 - Performance & UX Update
 */

import './styles/main.css';
import { LabsApp } from './components/LabsApp.js';
import { Background } from './components/Background.js';

// Initialize app
function init() {
  console.log('[Labs] NeuraByte Labs v11.1.4');
  console.log('[Labs] Masterpiece Shader Edition - Generative Data Art Visuals');

  // Initialize background
  new Background();

  // Initialize main application
  window.labsApp = new LabsApp();


  // Initialize UI components
  initVersionModal();
  initScrollProgress();

  // Loading complete
  document.body.classList.add('loaded');
}

// Scroll Progress Indicator
function initScrollProgress() {
  const progressBar = document.getElementById('scroll-progress');
  if (!progressBar) return;

  const updateProgress = () => {
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
    progressBar.style.width = `${progress}%`;
  };

  window.addEventListener('scroll', updateProgress, { passive: true });
  updateProgress(); // Initial call
}

// Version Modal Logic
function initVersionModal() {
  const badge = document.getElementById('version-badge');
  const modal = document.getElementById('version-modal');
  const closeBtn = modal?.querySelector('.version-modal-close');
  const backdrop = modal?.querySelector('.version-modal-backdrop');

  if (!badge || !modal) return;

  // Open modal
  badge.addEventListener('click', () => {
    modal.classList.add('active');
    modal.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  });

  // Close modal
  const closeModal = () => {
    modal.classList.remove('active');
    modal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  };

  closeBtn?.addEventListener('click', closeModal);
  backdrop?.addEventListener('click', closeModal);

  // ESC key closes modal
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modal.classList.contains('active')) {
      closeModal();
    }
  });
}

// Handle both cases: DOM already ready or not yet
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

// Hot Module Replacement for development
if (import.meta.hot) {
  import.meta.hot.accept();
}
