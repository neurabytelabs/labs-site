/**
 * CardScene - Three.js WebGL shader renderer for project cards
 * Creates animated shader backgrounds with hover interaction
 */

import * as THREE from 'three';
import { vertexShader } from '../shaders/index.js';

export class CardScene {
  constructor(canvas, fragmentShader) {
    this.canvas = canvas;
    this.fragmentShader = fragmentShader;
    this.isHovered = false;
    this.targetHover = 0;
    this.currentHover = 0;
    this.mouse = new THREE.Vector2(0.5, 0.5);
    this.clock = new THREE.Clock();
    this.isRunning = false;

    this.init();
  }

  init() {
    // Get dimensions with fallback
    const rect = this.canvas.getBoundingClientRect();
    const width = rect.width || 340;
    const height = rect.height || 180;

    // Renderer
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      antialias: true,
      alpha: true
    });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Scene & Camera
    this.scene = new THREE.Scene();
    this.camera = new THREE.OrthographicCamera(-0.5, 0.5, 0.5, -0.5, 0.1, 10);
    this.camera.position.z = 1;

    // Shader Material
    this.uniforms = {
      uTime: { value: 0 },
      uHover: { value: 0 },
      uClick: { value: 0 },
      uMouse: { value: new THREE.Vector2(0.5, 0.5) }
    };

    this.material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader: this.fragmentShader,
      uniforms: this.uniforms
    });

    // Plane Geometry
    this.geometry = new THREE.PlaneGeometry(1, 1);
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);

    // Event Listeners
    this.setupEventListeners();
  }

  setupEventListeners() {
    const card = this.canvas.closest('.project-card');
    if (card) {
      card.addEventListener('mouseenter', () => this.setHover(true));
      card.addEventListener('mouseleave', () => this.setHover(false));
      card.addEventListener('mousemove', (e) => this.updateMouse(e));
      
      const link = card.querySelector('.card-link');
      if (link) {
        link.addEventListener('click', (e) => {
           // Visual pulse
           this.triggerClick();
        });
      }
    }
  }

  setHover(isHovered) {
    this.isHovered = isHovered;
    this.targetHover = isHovered ? 1 : 0;
  }

  triggerClick() {
    this.uniforms.uClick.value = 1;
    // Decay is handled in animate
  }

  updateMouse(e) {
    const rect = this.canvas.getBoundingClientRect();
    this.mouse.x = (e.clientX - rect.left) / rect.width;
    this.mouse.y = 1 - (e.clientY - rect.top) / rect.height;
  }

  resize() {
    const rect = this.canvas.getBoundingClientRect();
    const width = rect.width || 340;
    const height = rect.height || 180;

    this.renderer.setSize(width, height);
    this.canvas.width = width;
    this.canvas.height = height;
  }

  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.animate();
  }

  stop() {
    this.isRunning = false;
  }

  animate() {
    if (!this.isRunning) return;

    // Smooth hover transition
    this.currentHover += (this.targetHover - this.currentHover) * 0.1;
    
    // Click pulse decay
    if (this.uniforms.uClick.value > 0.01) {
        this.uniforms.uClick.value *= 0.92;
    } else {
        this.uniforms.uClick.value = 0;
    }

    // Time management: slow down when not hovered
    const dt = this.clock.getDelta();
    // If hovered, normal speed (1.0). If dormant, 0.2 speed.
    const timeScale = this.isHovered ? 1.0 : 0.2;
    this.uniforms.uTime.value += dt * timeScale;

    this.uniforms.uHover.value = this.currentHover;
    this.uniforms.uMouse.value.copy(this.mouse);

    // Render
    this.renderer.render(this.scene, this.camera);

    requestAnimationFrame(() => this.animate());
  }

  dispose() {
    this.stop();
    this.geometry.dispose();
    this.material.dispose();
    this.renderer.dispose();
  }
}

export default CardScene;
