# Design Schema — EduFlow Learning App

> Style · UI/UX · Interactivity · Professionalism · Minimalism

---

## 1. Brand Identity

**Name archetype:** Clean, friendly, growth-oriented EdTech  
**Personality pillars:** Approachable · Structured · Motivating · Calm  
**Audience:** Self-directed learners aged 18–40, mobile-first  
**Single product truth:** _Progress feels good when it's visible._

---

## 2. Color System

### Core Palette

| Token                    | Hex       | Role                                       |
| ------------------------ | --------- | ------------------------------------------ |
| `--color-bg`             | `#F7F5FF` | App background (soft lavender white)       |
| `--color-surface`        | `#FFFFFF` | Cards, sheets, modals                      |
| `--color-primary`        | `#A78BFA` | Primary brand purple — CTAs, active states |
| `--color-primary-light`  | `#E9D5FF` | Tinted card fills, progress backgrounds    |
| `--color-accent-green`   | `#BBF0D9` | Success, Tech & Software category card     |
| `--color-accent-yellow`  | `#FDE68A` | Hours tracker card, warmth accent          |
| `--color-accent-teal`    | `#A7F3D0` | Secondary data — July column, chart fill   |
| `--color-splash`         | `#C4B5FD` | Onboarding splash background               |
| `--color-text-primary`   | `#1A1A2E` | Headings, body copy                        |
| `--color-text-secondary` | `#6B7280` | Labels, meta copy, category tags           |
| `--color-text-inverse`   | `#FFFFFF` | Text on dark/filled surfaces               |
| `--color-border`         | `#E5E7EB` | Dividers, card outlines                    |
| `--color-star`           | `#F59E0B` | Rating stars                               |

### Usage Rules

- **Never** use more than 2 accent colors per screen.
- Category cards alternate between `--color-accent-green` and `--color-primary-light`; never repeat adjacent.
- The splash screen uses `--color-splash` as a full-bleed fill — nowhere else.
- Yellow (`--color-accent-yellow`) is reserved for the Hours metric only; it signals time.

---

## 3. Typography

### Typeface Roles

| Role               | Family                | Weight        | Size Scale |
| ------------------ | --------------------- | ------------- | ---------- |
| Display / Hero     | **Plus Jakarta Sans** | 800 ExtraBold | 28–36px    |
| Section Heading    | **Plus Jakarta Sans** | 700 Bold      | 20–24px    |
| Card Title         | **Plus Jakarta Sans** | 600 SemiBold  | 16–18px    |
| Body / Description | **Inter**             | 400 Regular   | 14px       |
| Label / Tag / Meta | **Inter**             | 500 Medium    | 11–12px    |
| Data / Number      | **Plus Jakarta Sans** | 700 Bold      | 32–48px    |

### Type Scale (Base 16px)

```
--text-xs:   11px / 1.4  — tags, timestamps
--text-sm:   13px / 1.5  — meta, captions
--text-base: 15px / 1.6  — body copy, descriptions
--text-md:   18px / 1.4  — card titles
--text-lg:   22px / 1.3  — section headings
--text-xl:   28px / 1.2  — screen headings
--text-2xl:  36px / 1.1  — hero display
--text-data: 44px / 1.0  — stat numbers (lessons / hours)
```

### Rules

- Sentence case throughout (never ALL CAPS except icon badges).
- Numbers in data contexts use tabular figures (`font-variant-numeric: tabular-nums`).
- Line length cap: 60 characters for body copy; 32 for card titles.

---

## 4. Spacing System

8px base unit. All spacing values are multiples of 4px.

```
--space-1:   4px
--space-2:   8px
--space-3:  12px
--space-4:  16px
--space-5:  20px
--space-6:  24px
--space-8:  32px
--space-10: 40px
--space-12: 48px
--space-16: 64px
```

### Layout

| Region                    | Value                    |
| ------------------------- | ------------------------ |
| Screen horizontal padding | `--space-6` (24px)       |
| Card internal padding     | `--space-5` (20px)       |
| Card gap (between cards)  | `--space-4` (16px)       |
| Section gap               | `--space-8` (32px)       |
| Icon-to-label gap         | `--space-2` (8px)        |
| Avatar overlap            | `-8px` (negative margin) |

---

## 5. Shape & Elevation

### Border Radius

```
--radius-sm:   8px   — tags, small chips
--radius-md:  16px   — icon containers, input fields
--radius-lg:  20px   — cards
--radius-xl:  28px   — large category cards
--radius-pill: 999px — buttons, avatar stacks, badges
```

### Shadow (Elevation)

```
--shadow-card:   0 2px 12px rgba(0,0,0,0.06)
--shadow-raised: 0 4px 24px rgba(0,0,0,0.10)
--shadow-float:  0 8px 32px rgba(167,139,250,0.18)  /* purple tint for CTA/FAB */
```

- Cards sit at `--shadow-card` at rest.
- Active / pressed cards elevate to `--shadow-raised`.
- The circular CTA button (arrow) uses `--shadow-float`.

---

## 6. Component Library

### 6.1 Buttons

**Primary CTA (Dark)**

- Background: `#1A1A2E`
- Text: `#FFFFFF`
- Padding: `16px 32px`
- Border radius: `--radius-pill`
- Font: Plus Jakarta Sans 600, 15px

**Arrow FAB (Circle)**

- Size: `48×48px`
- Background: `--color-primary-light`
- Icon: `→` in `--color-primary`
- Border radius: `--radius-pill`
- Shadow: `--shadow-float`

**Ghost / Navigation Button**

- Background: `transparent`
- Border: none
- Color: `--color-text-secondary`
- Used for back arrows, overflow menus

---

### 6.2 Cards

**Course Card**

```
Background:    --color-accent-green or --color-primary-light (alternating)
Padding:       --space-5 (20px)
Border-radius: --radius-xl (28px)
Shadow:        --shadow-card
Contents:
  ┌─────────────────────────────┐
  │ [Icon box]       ☆ Rating   │
  │                             │
  │ Category tag (sm, muted)    │
  │ Course title (md, bold)     │
  │                             │
  │ [Avatar stack]  5+    [→]   │
  └─────────────────────────────┘
Icon box: 40×40px, white bg, --radius-md, --shadow-card
Arrow button: 44×44px, white bg, --radius-pill
```

**Stat Card (Lessons / Hours)**

```
Width:         ~48% (side by side, --space-3 gap)
Padding:       --space-5
Border-radius: --radius-xl
Lessons card:  Background --color-accent-green
Hours card:    Background --color-accent-yellow
Contents:
  [Icon]  Label
  [Large number]  [↗ Arrow]
```

---

### 6.3 Progress Bar Chart

Monthly bar layout (May / June / July):

- Each month = a tall rounded pill (`--radius-pill`)
- Fill is a nested colored oval rising from bottom
- Colors: May = yellow (`--color-accent-yellow`), June = purple (`--color-primary`), July = teal (`--color-accent-teal`)
- Badge circle (dark, white text) sits at the top of each fill
- Label (n lessons) inside the fill, white text, centered
- Month label below bar in `--color-text-secondary`

---

### 6.4 Avatar Stack

- Avatar size: `32×32px`, border-radius: `--radius-pill`
- Overlap: `-8px` per avatar
- Count badge: `+N` pill in `--color-bg`, `--color-text-secondary`, 12px font

---

### 6.5 Icon Containers

- Size: `40–48px` square
- Background: `#FFFFFF`
- Border-radius: `--radius-md`
- Shadow: `--shadow-card`
- Icon color: `--color-text-primary` or `--color-primary`

---

### 6.6 Navigation & Header

**Top bar pattern (inner screens):**

- Left: circular back button (ghost, `--radius-pill`, white bg)
- Title: centered, Plus Jakarta Sans 700 20px
- Right: overflow (`⋮`) ghost icon button

**Home header:**

- Left: Avatar (40px) + "Hello [Name]" + XP progress bar
- Right: Bell icon in circle button

---

## 7. Interaction & Motion

### Principles

- **Instant feedback** on tap (≤16ms visual response).
- **No decorative animation** — every motion encodes meaning.
- Respect `prefers-reduced-motion`: disable transitions, freeze idle animations.

### Micro-interactions

| Element         | Trigger       | Behaviour                                                   |
| --------------- | ------------- | ----------------------------------------------------------- |
| Course card     | Tap           | Scale down to `0.97`, shadow deepens → release springs back |
| Arrow FAB       | Tap           | Brief pulse scale `1.0 → 1.12 → 1.0` (80ms total)           |
| Progress bar    | Screen enter  | Bars fill from 0% upward, staggered 80ms per column         |
| Rating star     | Hover / focus | Star fills amber with 120ms ease                            |
| Bottom nav icon | Select        | Icon scales `1.0 → 1.2`, label fades in over 150ms          |

### Transition Defaults

```
--ease-out:    cubic-bezier(0.0, 0.0, 0.2, 1)   /* entrances */
--ease-in:     cubic-bezier(0.4, 0.0, 1, 1)      /* exits */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1) /* bouncy elements */
--duration-fast:   120ms
--duration-base:   200ms
--duration-slow:   350ms
```

### Screen Transitions

- Screen push (navigate forward): slide in from right, `--duration-slow`, `--ease-out`.
- Screen pop (back): slide out to right, `--duration-base`, `--ease-in`.
- Modal / sheet: slide up from bottom, `--duration-slow`, `--ease-spring`.

---

## 8. Iconography

- Style: **Rounded outline**, 1.5px stroke, no fill (except active states).
- Size: `20×20px` in-content; `24×24px` in navigation.
- Active state: stroke becomes filled solid, color `--color-primary`.
- Source: [Lucide Icons](https://lucide.dev) or equivalent rounded set.
- Never mix icon families within one screen.

---

## 9. Imagery & Illustration

- Illustration style: **Flat 3D soft-render** (see onboarding book stack).
  - Light source from top-left.
  - Minimal drop shadow under objects.
  - Palette pulled from app token system (blues, purples).
- Avatars: real photos, circular crop, 1px `--color-border` ring.
- No stock photography backgrounds — illustrations only.
- Decorative sparkles / stars: 4-point star SVG at `opacity: 0.5`, placed sparsely.

---

## 10. Professionalism Rules

1. **No lorem ipsum** — every label, category, and title is production-meaningful.
2. **Rating displayed as decimal** (e.g. 3.5), never as filled/empty stars in dense lists.
3. **Consistent grammar** — category tags are noun phrases, card titles are verb phrases.
4. **Empty states** are instructional: "No courses started yet. Browse topics below." Never blank.
5. **Error states** name the problem and the fix: "Can't load courses. Check your connection and retry."
6. **Numbers ≥ 1000** use locale-aware formatting (e.g. `1,240 learners`).
7. **Loading states** use skeleton screens, not spinners, for content areas.

---

## 11. Minimalism Rules

1. **One primary action per screen** — everything else is secondary.
2. **Maximum two accent colors visible simultaneously** on any given screen.
3. **No decorative borders** — separation is achieved through spacing and background color shifts.
4. **Icon labels are always visible** in navigation (never icon-only on mobile).
5. **Card content hierarchy:** category tag → title → social proof → action. Never reorder.
6. **White space is structure** — do not fill gaps with decorative elements.
7. **Shadow as the only depth signal** — no gradients on interactive surfaces.

---

## 12. Accessibility

| Criterion             | Requirement                                                           |
| --------------------- | --------------------------------------------------------------------- |
| Color contrast (text) | WCAG AA minimum (4.5:1 for body, 3:1 for large text)                  |
| Touch target size     | Minimum `44×44px` for all interactive elements                        |
| Focus indicator       | `2px solid --color-primary` offset `2px`, never removed               |
| Screen reader         | All icons have `aria-label`; decorative elements `aria-hidden="true"` |
| Motion                | All transitions respect `prefers-reduced-motion: reduce`              |
| Font scaling          | Layout holds up to 200% system font size without horizontal scroll    |

---

## 13. Do / Don't

| ✅ Do                                       | ❌ Don't                                       |
| ------------------------------------------- | ---------------------------------------------- |
| Use soft lavender as the app background     | Use pure white `#FFFFFF` as the app background |
| Alternate card colors (green / purple)      | Use the same card color twice in a row         |
| Use Plus Jakarta Sans for all headings      | Mix multiple display typefaces                 |
| Keep illustrations flat-3D and on-brand     | Use photographic backgrounds                   |
| Reserve yellow strictly for time/hours data | Apply yellow to unrelated metrics              |
| Animate bars on scroll-into-view            | Animate on every re-render                     |
| Display ratings as decimals (`3.5`)         | Show a 5-star widget in compact card views     |
| Label every icon in bottom navigation       | Use icon-only nav on mobile                    |

---

_Schema version 1.0 — June 2026_
