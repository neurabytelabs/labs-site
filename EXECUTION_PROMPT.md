# EXECUTION PROMPT: Labs v6.0 "Unified Cards"

> Master Prompt'tan türetildi. Bu prompt step-by-step implementasyon sağlar.

---

## CURRENT STATE ANALYSIS

**Mevcut Sorunlar:**
1. 3D kartlar (WebGL mesh) ve HTML labels AYRI
2. Shader scene'ler tüm viewport'ta, kartların arkasında
3. Hover state global, sadece tek kart değil
4. Click handling karışık (drag vs click)

**Hedef:**
- TEK unified card component
- Scene + Content = 1 Card
- Per-card hover/click interaction

---

## IMPLEMENTATION PLAN

### Step 1: New Card Structure

```html
<div class="unified-cards-grid">
  <article class="unified-card" data-project="nexus" data-url="https://...">
    <div class="card-scene">
      <canvas class="scene-canvas"></canvas>
      <div class="scene-overlay"></div>
    </div>
    <div class="card-body">
      <span class="card-status status-live">Live</span>
      <span class="card-category">Developer Tools</span>
      <h3 class="card-title">NEXUS AI Forge</h3>
      <p class="card-desc">Ultimate AI-augmented developer tool...</p>
      <div class="card-tags">
        <span>Rust</span><span>Multi-AI</span><span>CLI</span>
      </div>
      <a href="https://..." class="card-launch" target="_blank">
        Launch <span class="arrow">→</span>
      </a>
    </div>
    <div class="card-glow"></div>
  </article>
  <!-- Repeat for all 8 cards -->
</div>
```

### Step 2: CSS Layout

```css
.unified-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  max-width: 1400px;
  margin: 0 auto;
  padding: 40px 24px;
}

.unified-card {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  background: rgba(17, 17, 19, 0.95);
  border: 1px solid rgba(251, 191, 36, 0.15);
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.unified-card:hover {
  transform: translateY(-12px) scale(1.02);
  border-color: rgba(251, 191, 36, 0.6);
  box-shadow:
    0 25px 50px rgba(0, 0, 0, 0.5),
    0 0 40px rgba(251, 191, 36, 0.15),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.card-scene {
  width: 100%;
  height: 200px;
  position: relative;
  overflow: hidden;
}

.scene-canvas {
  width: 100%;
  height: 100%;
  display: block;
}

.card-body {
  padding: 24px;
  position: relative;
}

.card-glow {
  position: absolute;
  inset: 0;
  pointer-events: none;
  opacity: 0;
  background: radial-gradient(circle at var(--glow-x, 50%) var(--glow-y, 50%),
    rgba(251, 191, 36, 0.4) 0%,
    transparent 70%);
  transition: opacity 0.3s;
}

.unified-card.clicking .card-glow {
  opacity: 1;
  animation: glowPulse 0.5s ease-out;
}

@keyframes glowPulse {
  0% { opacity: 0; transform: scale(0.8); }
  50% { opacity: 1; }
  100% { opacity: 0; transform: scale(1.2); }
}
```

### Step 3: Per-Card Shader System

Her kart için küçük bir shader renderer:

```javascript
class CardShaderScene {
  constructor(canvas, projectId) {
    this.canvas = canvas;
    this.projectId = projectId;
    this.isHovered = false;
    this.isClicked = false;
    this.hoverIntensity = 0;
    this.clickPulse = 0;

    this.init();
  }

  init() {
    // Minimal Three.js setup per card
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      alpha: true,
      antialias: false // Performance
    });

    this.scene = new THREE.Scene();
    this.camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

    // Fullscreen quad with project-specific shader
    this.material = new THREE.ShaderMaterial({
      uniforms: {
        uTime: { value: 0 },
        uHover: { value: 0 },
        uClick: { value: 0 },
        uResolution: { value: new THREE.Vector2() }
      },
      vertexShader: VERTEX_SHADER,
      fragmentShader: this.getFragmentShader()
    });

    const geometry = new THREE.PlaneGeometry(2, 2);
    this.mesh = new THREE.Mesh(geometry, this.material);
    this.scene.add(this.mesh);

    this.resize();
  }

  getFragmentShader() {
    // Return project-specific shader based on this.projectId
    return SHADERS[this.projectId] || SHADERS.default;
  }

  setHovered(value) {
    this.isHovered = value;
  }

  triggerClick() {
    this.clickPulse = 1.0;
  }

  update(time) {
    // Smooth hover transition
    const targetHover = this.isHovered ? 1.0 : 0.0;
    this.hoverIntensity += (targetHover - this.hoverIntensity) * 0.1;

    // Click pulse decay
    this.clickPulse *= 0.92;

    this.material.uniforms.uTime.value = time;
    this.material.uniforms.uHover.value = this.hoverIntensity;
    this.material.uniforms.uClick.value = this.clickPulse;

    this.renderer.render(this.scene, this.camera);
  }

  resize() {
    const rect = this.canvas.getBoundingClientRect();
    this.renderer.setSize(rect.width, rect.height, false);
    this.material.uniforms.uResolution.value.set(rect.width, rect.height);
  }
}
```

### Step 4: Interaction Handler

```javascript
class UnifiedCardsManager {
  constructor() {
    this.cards = [];
    this.scenes = new Map();
    this.init();
  }

  init() {
    document.querySelectorAll('.unified-card').forEach(card => {
      const canvas = card.querySelector('.scene-canvas');
      const projectId = card.dataset.project;
      const url = card.dataset.url;

      // Create shader scene for this card
      const scene = new CardShaderScene(canvas, projectId);
      this.scenes.set(card, scene);

      // Hover events
      card.addEventListener('mouseenter', () => {
        scene.setHovered(true);
      });

      card.addEventListener('mouseleave', () => {
        scene.setHovered(false);
      });

      // Click with glow effect
      card.addEventListener('click', (e) => {
        // Don't navigate if clicking on the link (it handles itself)
        if (e.target.closest('.card-launch')) return;

        // Trigger glow
        scene.triggerClick();
        card.classList.add('clicking');

        // Update glow position
        const rect = card.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * 100;
        const y = ((e.clientY - rect.top) / rect.height) * 100;
        card.style.setProperty('--glow-x', `${x}%`);
        card.style.setProperty('--glow-y', `${y}%`);

        // Navigate after animation
        setTimeout(() => {
          card.classList.remove('clicking');
          if (url) window.open(url, '_blank');
        }, 300);
      });
    });

    this.animate();
  }

  animate() {
    const time = performance.now() * 0.001;

    this.scenes.forEach(scene => {
      scene.update(time);
    });

    requestAnimationFrame(() => this.animate());
  }
}
```

### Step 5: Simplified Shaders (CSS-based Alternative)

Eğer 8 WebGL context performans sorunu yaratırsa, CSS animasyonlarla fallback:

```css
/* CSS-only animated backgrounds */
.card-scene[data-project="nexus"] {
  background: linear-gradient(180deg, #0a0a0a, #0d1117);
  position: relative;
  overflow: hidden;
}

.card-scene[data-project="nexus"]::before {
  content: '';
  position: absolute;
  inset: 0;
  background:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 20px,
      rgba(0, 255, 65, 0.03) 20px,
      rgba(0, 255, 65, 0.03) 21px
    );
  animation: matrixScroll 20s linear infinite;
  opacity: 0.3;
  transition: opacity 0.3s;
}

.unified-card:hover .card-scene[data-project="nexus"]::before {
  opacity: 1;
  animation-duration: 2s;
}

@keyframes matrixScroll {
  0% { transform: translateY(0); }
  100% { transform: translateY(100px); }
}
```

---

## FILES TO CREATE/MODIFY

1. **index.html** - Complete rewrite with unified card structure
2. **Remove** - Scattered card-labels system
3. **Remove** - 3D card meshes (optional, keep for background effect)

---

## EXECUTION ORDER

1. [ ] Read current index.html structure
2. [ ] Create new unified card HTML
3. [ ] Create new CSS for unified cards
4. [ ] Decide: WebGL per-card OR CSS animations
5. [ ] Implement chosen approach
6. [ ] Add click glow effect
7. [ ] Verify all links work
8. [ ] Test performance
9. [ ] Deploy

---

*Execution Prompt v1.0 | Ready for implementation*
