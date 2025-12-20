# NeuraByte Labs - LLM Navigation Index

> **Project:** NeuraByte Labs Portfolio Site
> **Version:** 11.2.0 (Cognitive Forge Era)
> **Stack:** Vite + Three.js r169 + GSAP + GLSL

---

## Quick Start

```bash
npm install     # Install dependencies
npm run dev     # Start dev server (http://localhost:3000)
npm run build   # Production build to dist/
npm run preview # Preview production build
```

---

## Architecture Overview

```
labs-site/
├── index.html              # Minimal HTML shell
├── package.json            # Vite + Three.js r169 + GSAP
├── vite.config.js          # GLSL plugin config
├── public/
│   └── favicon.svg         # N logo
└── src/
    ├── main.js             # Entry point
    ├── components/
    │   ├── Background.js   # Subtle particles system
    │   ├── CardScene.js    # Three.js shader renderer
    │   └── LabsApp.js      # Main app controller
    ├── shaders/
    │   ├── index.js        # Shader exports
    │   ├── spinozaos.glsl  # Fluid/Volumetric Data (Refik Anadol Style)
    │   ├── lithosphere.glsl # N-body physics
    │   ├── boardroom.glsl  # AI personas
    │   ├── nexus.glsl      # Forge energy
    │   ├── oracle.glsl     # All-seeing eye
    │   ├── engram.glsl     # Memory cards
    │   ├── manifesto.glsl  # Renaissance manuscript
    │   └── voice.glsl      # Sound waves
    ├── data/
    │   └── projects.json   # 8 project definitions
    └── styles/
        └── main.css        # Sharp corners theme
```

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Vanilla JS + Vite | LLM-friendly, no framework lock-in |
| 3D Library | Three.js r169 | TSL support, latest features |
| Animation | GSAP + ScrollTrigger | Industry standard, performant |
| Styling | CSS Variables | Design tokens, theming |
| **Corners** | **Sharp (0-2px)** | **NeuraByte brand identity** |
| **Visuals** | **Generative Data Art** | **Refik Anadol inspired aesthetics** |
| **UX** | **Unified Card** | **Embedded interactive shader headers** |

---

## File Purposes

### `/src/components/CardScene.js`
WebGL shader renderer for project cards. Handles:
- Three.js scene setup (orthographic camera)
- Shader material with uTime, uHover, uClick, uMouse uniforms
- Smooth hover transitions & dormant state (0.2x speed)
- Click pulse triggering

### `/src/components/Background.js`
Global subtle particle system.
- Three.js PointsMaterial
- Floating motion logic

### `/src/components/LabsApp.js`
Main application controller. Handles:
- Dynamic card generation from projects.json
- Shader initialization for all cards
- GSAP scroll animations
- Window resize handling

### `/src/shaders/*.glsl`
Each project has a unique fragment shader:
- `spinozaos.glsl` - **NEW:** 3D Curl Noise, Volumetric Density, Synaptic Flashes, Click Pulse.
- `lithosphere.glsl` - 3-body gravitational dance
- `boardroom.glsl` - 5 AI personas, speaking indicator
- `nexus.glsl` - Digital forge, energy streams
- `oracle.glsl` - All-seeing eye, scenario rays
- `engram.glsl` - Floating memory cards, neural paths
- `manifesto.glsl` - Renaissance manuscript, glowing runes
- `voice.glsl` - Sound waves, frequency bars

### `/src/data/projects.json`
Project metadata:
```json
{
  "id": "string",       // Matches shader filename
  "title": "string",
  "category": "string",
  "description": "string",
  "tech": ["array"],
  "status": "live|dev",
  "url": "string|null"
}
```

---

## Common Tasks

### Add a new project
1. Add entry to `src/data/projects.json`
2. Create `src/shaders/{id}.glsl`
3. Export in `src/shaders/index.js`

### Modify card styling
Edit `src/styles/main.css`:
- `.project-card` - Card container
- `.card-shader` - Canvas wrapper (200px height)
- `.card-content` - Text content
- Design tokens in `:root`

### Change animations
- Card entrance: `LabsApp.js` → `setupScrollAnimations()`
- Hover effects: `CardScene.js` → `setHover()`
- Shader animation: Individual `.glsl` files

---

## Shader Uniforms

All shaders receive these uniforms:
```glsl
uniform float uTime;   // Elapsed time (seconds)
uniform float uHover;  // 0.0 to 1.0 (smooth hover)
uniform float uClick;  // 0.0 to 1.0 (decaying pulse)
uniform vec2 uMouse;   // Normalized mouse position
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| three | ^0.169.0 | WebGL/shaders |
| gsap | ^3.12.5 | Animation |
| vite | ^5.4.11 | Build tool |
| vite-plugin-glsl | ^1.3.0 | GLSL imports |

---

## Deployment

Production build outputs to `dist/`. Deploy to:
- Coolify container
- Static hosting (Vercel, Netlify)
- CDN

```bash
npm run build
# dist/ contains optimized assets
```

---

*Last updated: 2025-12-20*