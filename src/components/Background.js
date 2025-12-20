
import * as THREE from 'three';

export class Background {
  constructor() {
    this.canvas = document.createElement('canvas');
    this.canvas.id = 'bg-canvas';
    this.canvas.style.position = 'fixed';
    this.canvas.style.top = '0';
    this.canvas.style.left = '0';
    this.canvas.style.width = '100%';
    this.canvas.style.height = '100%';
    this.canvas.style.zIndex = '-1';
    this.canvas.style.pointerEvents = 'none';
    this.canvas.style.opacity = '0.6';
    document.body.prepend(this.canvas);

    this.init();
  }

  init() {
    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    this.camera.position.z = 5;

    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      alpha: true,
      antialias: false
    });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    this.createParticles();
    this.animate();

    window.addEventListener('resize', () => this.resize());
  }

  createParticles() {
    const geometry = new THREE.BufferGeometry();
    const count = 150;
    const positions = new Float32Array(count * 3);
    const speeds = new Float32Array(count);

    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 15; // x
      positions[i * 3 + 1] = (Math.random() - 0.5) * 15; // y
      positions[i * 3 + 2] = (Math.random() - 0.5) * 10; // z
      speeds[i] = 0.002 + Math.random() * 0.005;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('speed', new THREE.BufferAttribute(speeds, 1));

    const material = new THREE.PointsMaterial({
      color: 0x444455,
      size: 0.05,
      transparent: true,
      opacity: 0.6,
      sizeAttenuation: true
    });

    this.particles = new THREE.Points(geometry, material);
    this.scene.add(this.particles);
  }

  resize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    const positions = this.particles.geometry.attributes.position.array;
    const speeds = this.particles.geometry.attributes.speed.array;

    for (let i = 0; i < positions.length / 3; i++) {
      positions[i * 3 + 1] += speeds[i]; // move up

      if (positions[i * 3 + 1] > 7.5) {
        positions[i * 3 + 1] = -7.5;
      }
    }
    
    this.particles.geometry.attributes.position.needsUpdate = true;
    this.particles.rotation.y += 0.001;

    this.renderer.render(this.scene, this.camera);
  }
}
