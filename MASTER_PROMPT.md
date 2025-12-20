# LABS CARD REDESIGN - MASTER PROMPT v1.0

> Bu prompt, NeuraByte Labs kartlarının tamamen yeniden tasarlanması için üst düzey bir yönlendirme sağlar.
> Execution prompt'u oluşturup çalıştıracak.

---

## VISION

Labs kartları şu an parçalı: 3D WebGL scene'ler arka planda, HTML kartlar önde.
**YENİ TASARIM:** Her şey TEK bir kart içinde birleşik olacak.

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║                               ║  │
│  ║   INTERACTIVE SHADER SCENE    ║  │  ← Kartın üst kısmı (WebGL canvas)
│  ║   (Hover: Animate)            ║  │
│  ║   (Click: Glow burst)         ║  │
│  ╚═══════════════════════════════╝  │
│                                     │
│  ● Live          Developer Tools    │  ← Status + Category
│                                     │
│  NEXUS AI FORGE                     │  ← Title
│                                     │
│  Ultimate AI-augmented developer    │  ← Description
│  tool. Cross-platform, Rust-powered │
│                                     │
│  [Rust] [Multi-AI] [CLI]           │  ← Tech tags
│                                     │
│  Launch →                           │  ← Clickable link
│                                     │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░  │  ← Conatus bar
└─────────────────────────────────────┘
```

---

## REQUIREMENTS

### 1. UNIFIED CARD STRUCTURE
- Her kart TEK bir DOM element olacak
- Üstte: Mini WebGL canvas (shader scene)
- Altta: Kart içeriği (title, description, tags, link)
- Tüm kart tıklanabilir, link çalışır

### 2. INTERACTIVE ANIMATIONS

**HOVER STATE:**
- Sadece hover edilen kartın shader'ı aktif animasyon oynar
- Diğer kartlar "dormant" (uyuyan) state'de - yavaş/minimal animasyon
- Hover'da kart hafifçe yukarı kalkar (translateY)
- Border glow intensify

**CLICK STATE:**
- Click anında "pulse" efekti - parlaklık burst
- Ripple wave shader'dan yayılır
- Sonra URL yeni sekmede açılır

### 3. SHADER SCENES (Per Project)

| Project | Scene | Hover Animation |
|---------|-------|-----------------|
| SpinozaOS | Sacred Geometry | Geometri döner, parlar |
| Lithosphere | Orbiting Bodies | Gezegenler hızlanır |
| Boardroom | Neural Network | Nöronlar aktifleşir |
| NEXUS | Matrix Code | Kod yağmuru hızlanır |
| ORACLE | Decision Tree | Dallar büyür |
| Engram | Memory Cubes | Küpler döner |
| Manifesto | Knowledge Waves | Dalgalar yoğunlaşır |
| Voice | Audio Waveform | Dalga formu canlanır |

### 4. TECHNICAL APPROACH

**Option A: Individual Mini Canvases**
- Her kart için ayrı küçük Three.js canvas
- Pros: İzole, kolay kontrol
- Cons: Performance (8 ayrı WebGL context)

**Option B: Single Canvas + Render Targets**
- Tek büyük canvas, her kart için render target
- Shader texture olarak kartlara aktarılır
- Pros: Performance
- Cons: Karmaşık

**Option C: CSS + SVG Animations (No WebGL)**
- Pure CSS/SVG animasyonlar
- Pros: Basit, performanslı
- Cons: Shader kalitesi düşer

**RECOMMENDATION:** Option A veya C (proje karmaşıklığına göre)

### 5. CARD LAYOUT

```css
.unified-card {
  display: flex;
  flex-direction: column;
  width: 320px;
  border-radius: 16px;
  overflow: hidden;
  background: rgba(17, 17, 19, 0.9);
  border: 1px solid rgba(251, 191, 36, 0.15);
  transition: all 0.3s ease;
}

.unified-card:hover {
  transform: translateY(-8px);
  border-color: rgba(251, 191, 36, 0.5);
  box-shadow: 0 20px 40px rgba(0,0,0,0.4),
              0 0 30px rgba(251, 191, 36, 0.1);
}

.card-scene {
  width: 100%;
  height: 180px;
  position: relative;
}

.card-content {
  padding: 20px;
}
```

---

## EXECUTION PROMPT

Bu master prompt'u okuduktan sonra, aşağıdaki EXECUTION PROMPT'u oluştur ve çalıştır:

---

# EXECUTION PROMPT: Labs Card Redesign Implementation

## PHASE 1: Cleanup & Preparation
1. Mevcut scattered card system'i analiz et
2. Backup al
3. Yeni unified card structure için plan oluştur

## PHASE 2: Card Component Redesign
1. Unified card HTML structure oluştur
2. CSS Grid/Flexbox layout
3. Her kart için mini canvas placeholder

## PHASE 3: Shader Integration
1. Her proje için shader scene'i canvas'a bağla
2. Hover state: uHover uniform aktifleşir
3. Click state: uClick uniform pulse tetikler

## PHASE 4: Interaction System
1. Hover detection per card
2. Click handler with glow effect
3. URL navigation (target="_blank")

## PHASE 5: Polish & Deploy
1. Performance optimization
2. Mobile responsive
3. Test all links
4. Deploy

---

## SUCCESS CRITERIA

- [ ] 8 unified card, her biri üstte scene + altta content
- [ ] Hover'da sadece ilgili kartın animasyonu aktif
- [ ] Click'te glow burst efekti
- [ ] Tüm linkler çalışır
- [ ] 60 FPS performance
- [ ] Mobile responsive

---

*Master Prompt v1.0 | NeuraByte Labs Card Redesign*
