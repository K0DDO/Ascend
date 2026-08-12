# Ascend Design System

Visual language reference: **Subbery** (matte / liquid glass), **not** a class-name copy.
All tokens live under Ascend names and are accessed via `context.ascendTheme`.

**Forbidden in features:**

```dart
Container(color: Color(0xFFE67F73));
```

**Required:**

```dart
context.ascendTheme.colors.primary;
context.ascendTheme.spacing.lg;
context.ascendTheme.radius.lg;
```

---

## Philosophy

Premium · calm · focused · intelligent · modern · slightly playful · technical  
Adult gamification — never childish Duolingo-cartoon energy.

Theme modes: **Light / Dark / System**.  
**Accent is independent** of brightness mode.

---

## Token modules

| Module | Responsibility |
|--------|----------------|
| `AscendTheme` | ThemeExtension bundling all tokens |
| `AscendColors` | Semantic + accent-derived colors |
| `AscendSpacing` | 4-based spacing scale |
| `AscendRadius` | Corner radii |
| `AscendTypography` | Text styles (custom premium font, not Inter/Roboto default as brand voice) |
| `AscendGlass` | Blur, fills, borders for glass surfaces |
| `AscendAnimations` | Durations + curves |

---

## Spacing (`AscendSpacing`)

| Token | px | Use |
|-------|-----|-----|
| xxs | 4 | Micro gaps |
| xs | 8 | Icon gaps |
| sm | 12 | Dense rows |
| md | 16 | Hotbar inset |
| lg | 24 | Page horizontal padding |
| xl | 32 | Empty states |
| xxl | 48 | Section breathing |

Bottom list inset above hotbar: ~128.  
Hotbar bottom gap: `safeArea + 8`.

---

## Radius (`AscendRadius`)

| Token | px |
|-------|-----|
| sm | 14 |
| md | 20 |
| lg | 28 |
| xl | 36 |
| pill | 999 |

---

## Colors (`AscendColors`)

Default accent seed (coral family, Ascend-owned): `#E67F73`  
Accent presets may expand later (mint, sky, …) — architecture mirrors Subbery’s seed approach.

Semantic roles (required):

| Role | Purpose |
|------|---------|
| primary / secondary | Brand actions |
| success / warning / error / info | Feedback |
| muted | Secondary text |
| background / backgroundEnd | Gradient scaffold |
| surface | Elevated non-glass |
| glass | Glass fill base |
| border | Hairline / glass border |
| glow | Soft accent glow |
| foreground | Primary text |

Light bg anchors (from reference, accent-lerped): `#F0E4DE` → `#E8D9D4`  
Dark: `#171519` → `#211B22`  
Foreground light `#291C1C` / dark `#FFF8F5`.

Success `#6F9F7C` · Warning `#C3975B` · Error `#C56F75` (adjust with accent subtly).

---

## Glass (`AscendGlass`)

| Param | Guidance |
|-------|----------|
| blur | ~15–24 sigma (strength-aware) |
| border width | 0.8 |
| shadow blur | 24–28 |
| shadow offset Y | 9–11 |
| recipe | single BackdropFilter · matte, no refraction circus |

Components to build: `AscendGlassSurface`, `AscendGlassCard`, `AscendGlassButton`, `AscendHotbar`.

---

## Typography (`AscendTypography`)

Use a distinctive pair (e.g. display + text) — **not** Inter/Roboto/Arial as brand identity.  
Final font files chosen in Flutter foundation phase; scale aligned to reference:

| Style | Size | Weight | Tracking |
|-------|------|--------|----------|
| displayLarge | 52 | w700 | -2.2 |
| displaySmall | 36 | w700 | -1.4 |
| headlineMedium | 26 | w700 | -0.7 |
| titleLarge | 20 | w700 | -0.3 |
| titleMedium | 16 | w600 | — |
| bodyLarge | 16 | w500 | — |
| bodyMedium | 14 | w500 | — |
| labelLarge | 15 | w700 | — |
| labelSmall | 10–12 | w600–700 | hotbar |

---

## Animations (`AscendAnimations`)

Default curve: `Curves.easeOutCubic`.

| ms | Use |
|----|-----|
| 100–130 | Press scale |
| 240 | Hotbar icon |
| 280–320 | Pill slide / section size |
| 350–900 | Sheets (distance-based) |

Card flip: local animation only — no network on flip.

---

## Hotbar

| Spec | Value |
|------|-------|
| Height | 72 |
| Horizontal inset | 16 |
| Shape | pill |
| Surface | glass |
| Tabs | Home, Learn, Knowledge, Progress, Profile |
| Selected | animated icon + pill indicator |

AI Interview is **not** a tab.

---

## Home composition (first polished screen)

One focused composition, not a 30-chart dashboard:

1. Greeting + streak  
2. Daily goal + Start learning CTA  
3. Weak areas (few)  
4. Course progress (compact)  
5. Next goal + readiness bar  

Glass cards, soft gradients, floating hotbar.
