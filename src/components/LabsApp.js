/**
 * LabsApp - Main application controller
 * v12.0.0 - Static Cards Edition (No WebGL)
 * Manages project cards with CSS gradients and subtle animations
 */

import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import projects from '../data/projects.json';

gsap.registerPlugin(ScrollTrigger);

// Icon SVG definitions
const icons = {
  brain: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"/>
    <path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"/>
  </svg>`,
  sun: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="12" r="4"/>
    <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>
  </svg>`,
  globe: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="12" r="10"/>
    <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
    <path d="M2 12h20"/>
  </svg>`,
  users: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
    <circle cx="9" cy="7" r="4"/>
    <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
  </svg>`,
  terminal: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <polyline points="4 17 10 11 4 5"/>
    <line x1="12" y1="19" x2="20" y2="19"/>
  </svg>`,
  eye: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
    <circle cx="12" cy="12" r="3"/>
  </svg>`,
  chip: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <rect x="4" y="4" width="16" height="16" rx="2"/>
    <rect x="9" y="9" width="6" height="6"/>
    <path d="M9 1v3M15 1v3M9 20v3M15 20v3M20 9h3M20 14h3M1 9h3M1 14h3"/>
  </svg>`,
  book: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
  </svg>`,
  mic: `<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z"/>
    <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
    <line x1="12" y1="19" x2="12" y2="22"/>
  </svg>`
};

export class LabsApp {
  constructor() {
    this.init();
  }

  init() {
    this.createProjectCards();
    this.setupScrollAnimations();
    this.setupResizeHandler();

    console.log('[LabsApp] Initialized with', projects.length, 'projects');
  }

  createProjectCards() {
    const container = document.getElementById('projects-container');
    if (!container) {
      console.error('[LabsApp] Projects container not found');
      return;
    }

    projects.forEach((project, index) => {
      const card = this.createCard(project, index);
      container.appendChild(card);
    });
  }

  createCard(project, index) {
    const card = document.createElement('article');
    card.className = 'project-card';
    card.dataset.projectId = project.id;
    card.dataset.category = project.category;
    card.style.setProperty('--index', index);

    const statusClass = project.status === 'live' ? 'status-live' : 'status-dev';
    const statusText = project.status === 'live' ? 'LIVE' : 'IN DEV';
    const iconSvg = icons[project.icon] || icons.brain;

    card.innerHTML = `
      <div class="card-visual" style="--gradient: ${project.gradient}">
        <div class="visual-noise"></div>
        <div class="card-icon">
          ${iconSvg}
        </div>
      </div>
      <div class="card-content">
        <header>
          <div class="project-meta">
            <span class="card-category">${project.category}</span>
            <span class="card-status ${statusClass}">${statusText}</span>
          </div>
          <h3 class="card-title">${project.title}</h3>
        </header>
        <p class="card-description">${project.description}</p>
        <footer class="card-footer">
          <div class="card-tech">
            ${project.tech.map(t => `<span class="tech-tag">${t}</span>`).join('')}
          </div>
          ${project.url ? `
            <a href="${project.url}" target="_blank" rel="noopener" class="card-link">
              <span>Explore</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M7 17L17 7M17 7H7M17 7V17"/>
              </svg>
            </a>
          ` : ''}
        </footer>
      </div>
    `;

    // Click on card opens URL if exists
    if (project.url) {
      card.addEventListener('click', (e) => {
        if (!e.target.closest('.card-link')) {
          window.open(project.url, '_blank', 'noopener');
        }
      });
    }

    return card;
  }

  setupScrollAnimations() {
    // Stagger card entrance - immediate animation on load
    gsap.fromTo('.project-card',
      { y: 40, opacity: 0 },
      {
        y: 0,
        opacity: 1,
        duration: 0.6,
        stagger: 0.08,
        ease: 'power2.out',
        delay: 0.2
      }
    );

    // Header parallax on scroll
    gsap.to('.hero-title', {
      y: -30,
      opacity: 0.5,
      scrollTrigger: {
        trigger: '.hero',
        start: 'top top',
        end: 'bottom top',
        scrub: 1
      }
    });
  }

  setupResizeHandler() {
    let resizeTimeout;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        ScrollTrigger.refresh();
      }, 250);
    });
  }

  destroy() {
    ScrollTrigger.getAll().forEach(t => t.kill());
  }
}

export default LabsApp;
