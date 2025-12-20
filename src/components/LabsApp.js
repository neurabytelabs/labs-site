/**
 * LabsApp - Main application controller
 * Manages project cards, scroll animations, and interactions
 */

import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { CardScene } from './CardScene.js';
import { shaders } from '../shaders/index.js';
import projects from '../data/projects.json';

gsap.registerPlugin(ScrollTrigger);

export class LabsApp {
  constructor() {
    this.cardScenes = new Map();
    this.init();
  }

  init() {
    this.createProjectCards();
    this.initShaders();
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
    card.style.setProperty('--index', index);

    const statusClass = project.status === 'live' ? 'status-live' : 'status-dev';
    const statusText = project.status === 'live' ? 'LIVE' : 'IN DEV';

    card.innerHTML = `
      <div class="card-shader">
        <canvas class="shader-canvas" data-shader="${project.id}"></canvas>
      </div>
      <div class="card-content">
        <div class="card-header">
          <span class="card-category">${project.category}</span>
          <span class="card-status ${statusClass}">${statusText}</span>
        </div>
        <h3 class="card-title">${project.title}</h3>
        <p class="card-description">${project.description}</p>
        <div class="card-tech">
          ${project.tech.map(t => `<span class="tech-tag">${t}</span>`).join('')}
        </div>
        ${project.url ? `
          <a href="${project.url}" target="_blank" rel="noopener" class="card-link">
            <span>Explore</span>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M4 12L12 4M12 4H6M12 4V10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </a>
        ` : ''}
      </div>
    `;

    return card;
  }

  initShaders() {
    const canvases = document.querySelectorAll('.shader-canvas');

    canvases.forEach(canvas => {
      const shaderId = canvas.dataset.shader;
      const fragmentShader = shaders[shaderId];

      if (!fragmentShader) {
        console.warn(`[LabsApp] Shader not found: ${shaderId}`);
        return;
      }

      try {
        const scene = new CardScene(canvas, fragmentShader);
        this.cardScenes.set(shaderId, scene);
        scene.start();
      } catch (error) {
        console.error(`[LabsApp] Shader init failed: ${shaderId}`, error);
      }
    });

    console.log('[LabsApp] Initialized', this.cardScenes.size, 'shader scenes');
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
        this.cardScenes.forEach(scene => scene.resize());
        ScrollTrigger.refresh();
      }, 250);
    });
  }

  destroy() {
    this.cardScenes.forEach(scene => scene.dispose());
    this.cardScenes.clear();
    ScrollTrigger.getAll().forEach(t => t.kill());
  }
}

export default LabsApp;
