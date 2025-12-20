# MASTER PROMPT: Unified Card with Shader Header v2.0

> **Proje:** NeuraByte Labs Card Redesign
> **Branch:** `feature/unified-card-header`
> **Base:** v5.0 "Digital Renaissance"
> **Hedef:** Shader scene'leri 3D kart header'ı olarak entegre et

---

## ONAYLANAN KARARLAR

| Soru | Karar | Açıklama |
|------|-------|----------|
| **Layout** | 1B | 3D floating kartlar KORUNUR + shader header eklenir |
| **Background** | 2A | Subtle particles only (neural network kaldırılır) |
| **Tıklama** | 3B | Sadece "Launch →" tıklanabilir, kartlar drag/physics ile interaktif |
| **Header Height** | 4C | 200px (prominent) |

---

## VISION STATEMENT

```
"3D uzayda süzülen kartlar - her biri kendi shader evrenini
header'ında taşıyor. Sürükle, fırlat, etkileşime gir.
Launch butonu ile projeye atla."
```

---

## ARCHITECTURE

### Hybrid Approach: 3D Cards + Embedded Shaders

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   [Subtle Particle Background]                              │
│                                                             │
│         ┌─────────────────────────┐                        │
│         │ ╔═════════════════════╗ │                        │
│         │ ║   SHADER HEADER     ║ │  ← 200px, kartın İÇİNDE│
│         │ ║   (WebGL texture)   ║ │                        │
│         │ ╚═════════════════════╝ │                        │
│         │ ┌─────────────────────┐ │                        │
│         │ │ ● Live   Category   │ │  ← Card content        │
│         │ │ TITLE               │ │                        │
│         │ │ Description...      │ │                        │
│         │ │ [Tags]              │ │                        │
│         │ │ Launch →            │ │  ← SADECE bu tıklanır  │
│         │ └─────────────────────┘ │                        │
│         └─────────────────────────┘                        │
│              ↑                                              │
│         [3D Card Mesh - Draggable, Physics]                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## TECHNICAL IMPLEMENTATION

### 1. Card Mesh with Shader Header Texture

```javascript
class UnifiedCard {
  constructor(scene, data, index) {
    this.data = data;
    this.scene = scene;

    // Create shader render target for this card's header
    this.headerRenderTarget = new THREE.WebGLRenderTarget(512, 256);
    this.headerScene = new THREE.Scene();
    this.headerCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

    // Project-specific shader material for header
    this.headerMaterial = new THREE.ShaderMaterial({
      uniforms: {
        uTime: { value: 0 },
        uHover: { value: 0 },
        uClick: { value: 0 }
      },
      fragmentShader: SHADERS[data.id]
    });

    // Fullscreen quad for header rendering
    const headerQuad = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      this.headerMaterial
    );
    this.headerScene.add(headerQuad);

    // Main card material - uses header texture
    this.cardMaterial = new THREE.ShaderMaterial({
      uniforms: {
        uTime: { value: 0 },
        uHover: { value: 0 },
        uHeaderTexture: { value: this.headerRenderTarget.texture },
        uHeaderHeight: { value: 0.4 } // 200px / 500px total ≈ 0.4
      },
      vertexShader: CARD_VERTEX_SHADER,
      fragmentShader: CARD_FRAGMENT_SHADER,
      transparent: true
    });

    // Card mesh (existing geometry from v5.0)
    this.mesh = new THREE.Mesh(
      new THREE.PlaneGeometry(16, 20), // Taller to accommodate header
      this.cardMaterial
    );

    // ... rest of physics, drag, etc. from v5.0
  }

  updateHeader(time) {
    this.headerMaterial.uniforms.uTime.value = time;
    this.headerMaterial.uniforms.uHover.value = this.hoverIntensity;
    this.headerMaterial.uniforms.uClick.value = this.clickPulse;

    // Render header to texture
    this.renderer.setRenderTarget(this.headerRenderTarget);
    this.renderer.render(this.headerScene, this.headerCamera);
    this.renderer.setRenderTarget(null);
  }
}
```

### 2. Card Fragment Shader (with Header)

```glsl
uniform float uTime;
uniform float uHover;
uniform sampler2D uHeaderTexture;
uniform float uHeaderHeight; // 0.4 = 40% of card is header

varying vec2 vUv;

void main() {
    vec2 uv = vUv;

    // Header region (top 40%)
    if (uv.y > (1.0 - uHeaderHeight)) {
        // Map UV to header texture
        vec2 headerUv = vec2(
            uv.x,
            (uv.y - (1.0 - uHeaderHeight)) / uHeaderHeight
        );
        vec4 headerColor = texture2D(uHeaderTexture, headerUv);

        // Fade transition at bottom of header
        float fade = smoothstep(1.0 - uHeaderHeight, 1.0 - uHeaderHeight + 0.05, uv.y);
        gl_FragColor = mix(vec4(0.067, 0.067, 0.075, 0.95), headerColor, fade);
    }
    // Body region (bottom 60%)
    else {
        // Card body - dark surface with subtle pattern
        vec3 bodyColor = vec3(0.067, 0.067, 0.075);

        // Subtle border glow on hover
        float border = smoothstep(0.02, 0.0, min(min(uv.x, 1.0-uv.x), min(uv.y, 1.0-uv.y)));
        bodyColor += vec3(0.98, 0.75, 0.14) * border * uHover * 0.3;

        gl_FragColor = vec4(bodyColor, 0.95);
    }
}
```

### 3. HTML Labels (Overlay on 3D Cards)

```javascript
createLabel() {
    const label = document.createElement('div');
    label.className = 'card-label';
    label.innerHTML = `
        <div class="card-label-inner">
            <div class="label-spacer"></div>  <!-- 200px spacer for header -->
            <span class="card-status ${this.data.status === 'live' ? 'status-live' : 'status-coming'}">
                ${this.data.status === 'live' ? 'Live' : 'Coming'}
            </span>
            <div class="card-category">${this.data.category}</div>
            <h3 class="card-title">${this.data.title}</h3>
            <p class="card-description">${this.data.description}</p>
            <div class="card-tech">
                ${this.data.tech.map(t => `<span class="tech-tag">${t}</span>`).join('')}
            </div>
            ${this.data.url
                ? `<a href="${this.data.url}" class="card-link" target="_blank">Launch →</a>`
                : `<span class="card-link card-link-disabled">Coming Soon</span>`
            }
        </div>
    `;
    // ... position tracking from v5.0
}
```

### 4. CSS Updates

```css
/* Card label with header spacer */
.card-label-inner {
    background: transparent; /* WebGL handles background now */
    backdrop-filter: none;
    border: none;
    padding: 0;
    min-width: 280px;
    pointer-events: none;
}

/* Spacer for shader header area */
.label-spacer {
    height: 200px; /* Match uHeaderHeight */
    pointer-events: none;
}

/* Content area */
.card-content {
    padding: 20px;
    pointer-events: auto;
}

/* Only Launch link is clickable */
.card-link {
    pointer-events: auto;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--spinoza-yellow);
    text-decoration: none;
    font-size: 0.8rem;
    font-weight: 500;
    font-family: var(--font-mono);
    transition: gap 0.2s, color 0.2s;
    padding: 8px 16px;
    background: rgba(251, 191, 36, 0.1);
    border-radius: 8px;
    border: 1px solid rgba(251, 191, 36, 0.2);
}

.card-link:hover {
    gap: 12px;
    color: #fde68a;
    background: rgba(251, 191, 36, 0.2);
    border-color: rgba(251, 191, 36, 0.4);
}

.card-link-disabled {
    pointer-events: none;
    color: var(--neutral-600);
    background: rgba(113, 113, 122, 0.1);
    border-color: rgba(113, 113, 122, 0.2);
}
```

### 5. Simplified Background (Subtle Particles)

```glsl
// Replace neural network with subtle particles
uniform float uTime;
varying vec2 vUv;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = vUv;
    vec3 color = vec3(0.008, 0.015, 0.035); // Deep void

    // Floating particles
    for (float i = 0.0; i < 30.0; i++) {
        vec2 pos = vec2(
            random(vec2(i, 0.0)),
            fract(random(vec2(0.0, i)) + uTime * 0.015 * (0.3 + random(vec2(i, i)) * 0.7))
        );

        float dist = length(uv - pos);
        float particle = smoothstep(0.015, 0.003, dist);
        float twinkle = sin(uTime * 1.5 + i * 2.0) * 0.5 + 0.5;

        color += vec3(0.98, 0.75, 0.14) * particle * twinkle * 0.25;
    }

    // Very subtle vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.3;
    color *= vignette;

    gl_FragColor = vec4(color, 1.0);
}
```

---

## INTERACTION MODEL

```
┌─────────────────────────────────────────────────────────┐
│  DRAG & PHYSICS (Preserved from v5.0)                   │
│  ─────────────────────────────────────                  │
│  • Kartları sürükleyebilirsin                          │
│  • Fırlatınca physics ile hareket eder                 │
│  • Kartlar birbirine çarpabilir                        │
│  • Conatus sistemi aktif (spawn children)              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  HOVER (Enhanced)                                       │
│  ─────────────────                                      │
│  • Shader header AKTIFLEŞIR (uHover → 1.0)            │
│  • Border glow intensifies                             │
│  • Card mesh'te subtle glow                            │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  CLICK: "Launch →" ONLY                                 │
│  ──────────────────────                                 │
│  • Sadece Launch butonu tıklanabilir                   │
│  • Glow pulse efekti                                   │
│  • window.open(url, '_blank')                          │
│  • Disabled kartlarda "Coming Soon" (no action)        │
└─────────────────────────────────────────────────────────┘
```

---

## IMPLEMENTATION PHASES

### Phase 1: Render Target Setup
- [ ] Create per-card WebGLRenderTarget for header
- [ ] Render project shader to texture
- [ ] Verify texture quality (512x256 or higher)

### Phase 2: Card Shader Integration
- [ ] Modify card fragment shader to sample header texture
- [ ] Implement header/body regions with fade transition
- [ ] Add hover glow to card body region

### Phase 3: Label Updates
- [ ] Add 200px spacer to card labels
- [ ] Remove background from labels (WebGL handles it)
- [ ] Make only "Launch →" clickable

### Phase 4: Background Simplification
- [ ] Replace neural network with subtle particles
- [ ] Reduce visual complexity
- [ ] Ensure cards remain focal point

### Phase 5: Polish & Test
- [ ] Performance optimization (8 render targets)
- [ ] Hover/click feedback tuning
- [ ] Mobile responsiveness
- [ ] Link verification

---

## SUCCESS CRITERIA

- [ ] 3D floating physics cards preserved
- [ ] Each card has 200px shader header (embedded)
- [ ] Hover activates ONLY that card's header shader
- [ ] Only "Launch →" button navigates
- [ ] Drag/throw physics works as before
- [ ] Subtle particle background (no neural network)
- [ ] 60 FPS performance
- [ ] All links work correctly

---

*Master Prompt v2.0 | Approved Design Decisions*
*Branch: feature/unified-card-header*
