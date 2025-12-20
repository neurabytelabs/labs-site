# NeuraByte Labs - Unified Card Design Meeting
## "Card Header Integration" Sprint Planning

**Tarih:** 2025-12-20
**Branch:** `feature/unified-card-header`
**Base:** v5.0 "Digital Renaissance" (commit: `d911556`)

---

## TOPLANTI KATILIMCILARI

### Design Team
| Rol | Codename | Sorumluluk |
|-----|----------|------------|
| **Design System Architect** | "The Geometrist" | SpinozaOS tokens, 8pt grid, component structure |
| **Visual Design Lead** | "The Illuminator" | Color, typography, visual hierarchy |
| **Motion Design Director** | "The Choreographer" | Animation timing, easing, transitions |

### Animation Team
| Rol | Codename | Sorumluluk |
|-----|----------|------------|
| **WebGL Specialist** | "The Shader Whisperer" | Three.js, GLSL shaders, performance |
| **Animation Scout** | "The Collector" | Animation patterns, micro-interactions |

### UX Team
| Rol | Codename | Sorumluluk |
|-----|----------|------------|
| **UX Architect** | "The Pathfinder" | User flows, interaction patterns |
| **Interaction Designer** | "The Conductor" | Hover, click, feedback states |

---

## PROBLEM STATEMENT

### Mevcut Durum (v5.0)
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    [3D Shader Scene - ARKADA, tam ekran]               │
│                                                         │
│         ┌─────────────────┐                            │
│         │   HTML Card     │  ← Kartlar scene'in        │
│         │   (floating)    │    ÖNÜNDE, ayrı katman     │
│         └─────────────────┘                            │
│                                                         │
└─────────────────────────────────────────────────────────┘

Sorunlar:
- Shader scene'ler kartlardan AYRI
- Görsel bağlantı zayıf
- Hangi shader hangi karta ait belirsiz
```

### Hedef Durum
```
┌─────────────────────────────────────┐
│ ╔═════════════════════════════════╗ │
│ ║   SHADER SCENE (HEADER)         ║ │  ← Kartın PARÇASI
│ ║   Proje-spesifik animasyon      ║ │
│ ╚═════════════════════════════════╝ │
│ ┌─────────────────────────────────┐ │
│ │ ● Live      Developer Tools     │ │
│ │ NEXUS AI FORGE                  │ │
│ │ Description...                  │ │
│ │ [Tags]                          │ │
│ │ Launch →                        │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

Hedefler:
- Shader scene kart HEADER'ı olarak
- TEK unified component
- Görsel + içerik = bütünleşik deneyim
```

---

## TASARIM KARARLARI

### 1. Card Anatomy (The Geometrist)

```
┌────────────────────────────────────────┐
│                                        │
│   ┌────────────────────────────────┐   │
│   │                                │   │  SCENE HEADER
│   │     [WebGL Canvas]             │   │  Height: 160-200px
│   │     Proje-spesifik shader      │   │  Border-radius: 16px 16px 0 0
│   │                                │   │
│   └────────────────────────────────┘   │
│   ┌────────────────────────────────┐   │
│   │ ● Status        Category       │   │  CARD BODY
│   │                                │   │  Padding: 24px
│   │ TITLE                          │   │  Background: surface
│   │ Description text here...       │   │
│   │                                │   │
│   │ [Tag] [Tag] [Tag]             │   │
│   │                                │   │
│   │ Launch →                       │   │
│   └────────────────────────────────┘   │
│                                        │
│   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░   │  CONATUS BAR (optional)
│                                        │
└────────────────────────────────────────┘

Card Container:
- Border-radius: 16px (SpinozaOS token)
- Border: 1px solid rgba(251, 191, 36, 0.15)
- Background: rgba(17, 17, 19, 0.95)
- Box-shadow: hover state'de aktif
```

### 2. Scene Header Specs (The Shader Whisperer)

```
Scene Canvas:
- Width: 100%
- Height: 180px (desktop), 140px (mobile)
- Aspect ratio: ~16:9 or fluid

Shader Requirements:
- Her proje için MEVCUT shader'lar korunacak
- uHover uniform: 0.0 (idle) → 1.0 (hover)
- uClick uniform: pulse decay for click feedback
- Performance: 60fps hedef, low-power preference

Transition Zone:
- Scene → Body arası gradient overlay
- Height: 40-60px
- Smooth blend into card body
```

### 3. Interaction States (The Conductor)

```
IDLE STATE:
┌──────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░ │  Scene: Yavaş/subtle animasyon
│ ░░░  Dormant  ░░░░░░ │  uHover: 0.0
│ ░░░░░░░░░░░░░░░░░░░░ │  Border: default
├──────────────────────┤
│ Card content...      │
└──────────────────────┘

HOVER STATE:
┌──────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  Scene: AKTIF animasyon
│ ▓▓▓  ACTIVE  ▓▓▓▓▓▓▓ │  uHover: 1.0
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  Border: glow
├──────────────────────┤  Transform: translateY(-8px)
│ Card content...      │  Shadow: elevated
└──────────────────────┘

CLICK STATE:
┌──────────────────────┐
│ ████████████████████ │  Scene: PULSE burst
│ ███  BURST!  ███████ │  uClick: 1.0 → decay
│ ████████████████████ │  Radial glow from click point
├──────────────────────┤
│ Card content...      │  → Navigate after 300ms
└──────────────────────┘
```

### 4. Animation Timing (The Choreographer)

```css
/* Hover transition */
.card {
  transition:
    transform 0.4s cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 0.4s ease,
    border-color 0.3s ease;
}

/* Scene activation */
uHover lerp rate: 0.08 (smooth ~12 frames to full)

/* Click pulse decay */
uClick *= 0.88 per frame (~30 frames to near-zero)

/* Glow animation */
@keyframes glowPulse {
  0% { opacity: 0; transform: scale(0.8); }
  30% { opacity: 1; }
  100% { opacity: 0; transform: scale(1.4); }
}
duration: 500ms
easing: cubic-bezier(0.16, 1, 0.3, 1)
```

### 5. Layout Strategy (The Pathfinder)

```
DESKTOP (>1024px):
┌─────────┐ ┌─────────┐ ┌─────────┐
│  Card   │ │  Card   │ │  Card   │
│   1     │ │   2     │ │   3     │
└─────────┘ └─────────┘ └─────────┘
┌─────────┐ ┌─────────┐ ┌─────────┐
│  Card   │ │  Card   │ │  Card   │
│   4     │ │   5     │ │   6     │
└─────────┘ └─────────┘ └─────────┘
┌─────────┐ ┌─────────┐
│  Card   │ │  Card   │
│   7     │ │   8     │
└─────────┘ └─────────┘

Grid: auto-fit, minmax(340px, 1fr)
Gap: 28px
Max-width: 1200px
Centered with auto margins

TABLET (768-1024px):
2 columns

MOBILE (<768px):
1 column, full width cards
Scene height reduced to 140px
```

---

## AÇIK SORULAR

### Design Team'e
1. **Q:** Kartlar hala 3D mı olacak yoksa flat grid mi?
   - **Option A:** Flat grid (scrollable, no 3D physics)
   - **Option B:** 3D floating ama shader kartın içinde

2. **Q:** Background'da neural network kalacak mı?
   - **Option A:** Sadece subtle particles/grid
   - **Option B:** Full neural network (mevcut)

### Animation Team'e
3. **Q:** 8 ayrı WebGL context performance sorunu yaratır mı?
   - **Mitigation:** `powerPreference: 'low-power'`
   - **Alternative:** Single canvas with render targets

### UX Team'e
4. **Q:** Kartlara tıklama mı yoksa sadece Launch butonuna mı?
   - **Current v5.0:** Tüm kart tıklanabilir
   - **Consideration:** Accidental clicks?

---

## SONRAKI ADIMLAR

1. [ ] Tasarım kararları için onay
2. [ ] Master prompt oluştur
3. [ ] Prototype (tek kart)
4. [ ] Review & iterate
5. [ ] Full implementation
6. [ ] QA & deploy

---

*Meeting Document v1.0 | NeuraByte Labs Design Sprint*
