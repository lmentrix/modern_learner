# Modern Learner Design Schema

This document describes the current visual system implemented in the app and should be treated as the design baseline for future UI work.

## Product Style

Modern Learner uses a dark, polished, editorial interface with soft glass surfaces, neon-violet highlights, and mint success accents. The overall tone is focused, premium, and slightly futuristic rather than playful or overly corporate.

Core visual traits:

- Dark-first interface with layered surface depth
- Large geometric headlines with quieter body copy
- Rounded cards, pills, and buttons
- Soft glow and blur instead of heavy borders
- Accent-led interaction states, especially violet for action and mint for progress

## Source of Truth

Current implementation source files:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_text_styles.dart`

Implementation note:

- `AppTheme.dark` is the active theme source of truth for runtime typography.
- `AppTextStyles` exists as a static helper, but its values do not fully match `AppTheme.dark`. If typography is refactored, align those two files.

## Typography

### Font Pairing

- Display and headline font: `Space Grotesk`
- Body, label, and supporting UI font: `Inter`

### Typography Intent

- `Space Grotesk` is used for product personality, headers, section titles, and prominent numeric moments.
- `Inter` is used for readability, form fields, metadata, chips, and supporting copy.

### Type Scale

The active scale comes from `AppTheme.dark`:

| Token | Font | Size | Weight | Typical usage |
|---|---|---:|---:|---|
| `displayLarge` | Space Grotesk | 52 | 700 | Hero titles, large landing headings |
| `displayMedium` | Space Grotesk | 40 | 700 | Major section hero moments |
| `displaySmall` | Space Grotesk | 32 | 600 | Large screen titles |
| `headlineLarge` | Space Grotesk | 28 | 600 | Page titles |
| `headlineMedium` | Space Grotesk | 24 | 600 | Section headers |
| `headlineSmall` | Space Grotesk | 20 | 600 | Card titles |
| `titleLarge` | Space Grotesk | 18 | 600 | Compact feature headings |
| `titleMedium` | Space Grotesk | 16 | 500 | Secondary titles |
| `bodyLarge` | Inter | 16 | 400 | Main reading text |
| `bodyMedium` | Inter | 14 | 400 | Support text, descriptions |
| `labelLarge` | Inter | 12 | 600 | Small labels, pill text |
| `labelMedium` | Inter | 11 | 600 | Dense metadata |

### Typography Rules

- Use `Space Grotesk` for headings only. Avoid long paragraphs in that font.
- Use `Inter` for any paragraph, field, helper text, or compact navigation label.
- Use tighter tracking on display text and wider tracking on labels and pills.
- Headline copy should feel short and sharp. Supporting copy should stay calm and readable.

## Color System

### Core Palette

| Token | Hex | Role |
|---|---|---|
| `surface` | `#0C0E17` | Default app background |
| `surfaceContainerLowest` | `#000000` | Deepest background moments |
| `surfaceContainerLow` | `#11131D` | Low-emphasis cards and panels |
| `surfaceContainer` | `#171924` | Standard elevated surface |
| `surfaceContainerHigh` | `#1C1F2B` | Inputs and active containers |
| `surfaceContainerHighest` | `#21253A` | Stronger elevated blocks |
| `surfaceBright` | `#22263A` | Brightest neutral panel state |
| `primary` | `#B1A0FF` | Main brand accent |
| `primaryDim` | `#7E51FF` | Stronger action accent and glow |
| `primaryContainer` | `#2A1F5C` | Deep violet container |
| `onPrimary` | `#340090` | Text on bright violet surfaces |
| `secondary` | `#929BFA` | Secondary accent / supporting metric |
| `tertiary` | `#B1FFCE` | Success, progress, completion |
| `tertiaryContainer` | `#00FFA3` | Bright mint highlight |
| `onSurface` | `#F0F0FD` | Primary text |
| `onSurfaceVariant` | `#AAAAB7` | Secondary text |
| `outlineVariant` | `#464752` | Hairline borders and separators |
| `error` | `#FF6E84` | Error and destructive feedback |

### Gradients

Defined gradients:

- `primaryGradient`: `#7E51FF -> #B1A0FF`
- `tertiaryGradient`: `#00FFA3 -> #B1FFCE`

Usage guidance:

- Use `primaryGradient` for primary CTAs, highlighted avatars, active chips, and the center nav action.
- Use `tertiary` and `tertiaryGradient` for completion, XP, positive learning feedback, and correct-answer states.
- Use raw red only for destructive actions or failure states.
- Feature-specific accent colors are acceptable in Explore, but they should sit on top of the dark system rather than replace it.

## Surface Schema

### Backgrounds

- Default page background: `AppColors.surface`
- Top header fade: darker top edge blending into `surface`
- Avoid flat pure-black full-screen layouts unless the screen is intentionally modal or cinematic

### Cards

Primary card styles in the codebase:

- Small utility cards: radius `16`
- Standard panels: radius `20`
- Main content cards: radius `24`
- Spotlight and hero cards: radius `28-30`
- Pills and badges: radius `100` or `999`

### Glass Treatment

Shared glass card behavior:

- Background uses `surfaceContainer` with transparency
- Blur usually sits around `16-20`
- Borders are subtle, often top/left glow lines around `0.5`
- Depth comes from opacity, blur, and glow rather than thick outlines

## Components

### Buttons

- Primary buttons use `primaryGradient`
- Standard primary button height: `56`
- Common radius: `18`
- Text should usually be `Space Grotesk`, bold, and high contrast
- Primary buttons can use soft violet glow shadows

### Inputs

- Filled dark input background: `surfaceContainerHigh`
- Radius: `16`
- Default border: muted `outlineVariant`
- Focus border: `primary` at `1.5`
- Error border and helper text: `error`

### Navigation

- Bottom navigation uses a blurred translucent bar over the dark surface
- Inactive icons and labels use `onSurfaceVariant`
- Active states use `primary`
- The center create action is circular, gradient-filled, and visually elevated

### Pills, Chips, and Badges

- Use pill radii (`100` or `999`)
- Small uppercase `Inter` with heavier weight works best
- Active pills can use the primary gradient
- Inactive pills should remain on dark surfaces with subtle borders

### Progress and Achievement States

- Use mint (`tertiary`, `tertiaryContainer`) for completed, correct, rewarded, or streak-related feedback
- Use violet for active progression and navigation emphasis
- Use coral red only for mistakes, errors, or destructive confirmation

## Layout and Spacing

Observed spacing patterns:

- Page horizontal padding: `20` on mobile, `28` on wider layouts
- Tight stack spacing: `6-10`
- Normal stack spacing: `12-18`
- Section spacing: `20-28`
- Hero or auth spacing: `36-48`

Layout guidance:

- Prefer strong vertical rhythm over dense dashboards
- Let large cards breathe with generous top and bottom spacing
- Use safe areas consistently on top-level pages
- Keep dense information inside cards rather than directly on the page background

## Motion and Effects

Current motion language in the app:

- Short opacity transitions around `200ms`
- Toast and panel entrance around `380-500ms`
- Progress or shimmer animations around `1400-1500ms`
- Curves are usually smooth and eased, not spring-heavy

Motion guidance:

- Motion should feel calm and polished, not bouncy
- Use animation to reveal progress, focus, or achievement
- Avoid excessive simultaneous motion on content-heavy screens

## Screen-Level Style Summary

### Auth

- Minimal composition
- Strong vertical spacing
- Large centered brand mark
- Clear single-column form layout

### Home

- Warm welcome header with top fade
- Glass cards for overview content
- Strong emphasis on progress and streaks

### Explore

- More expressive, content-led accent usage
- Editorial cards and spotlight surfaces
- Still grounded in the dark base palette

### Progress

- Dense structured content on dark surfaces
- Mint and violet used to communicate learning state
- Cards and chips organize roadmap detail into readable chunks

## Usage Rules For Future UI

- Start every new screen from `AppColors` and `AppTheme.dark` before adding raw values.
- Use `Space Grotesk` for hierarchy and `Inter` for reading.
- Reuse the existing radius language: `16`, `20`, `24`, `30`, and `999`.
- Prefer translucent dark surfaces over flat gray boxes.
- Keep primary actions violet, positive outcomes mint, and destructive outcomes coral red.
- If a screen needs a custom accent, layer it on top of the existing dark system and keep text contrast high.

## Recommended Next Cleanup

If the team wants a stricter design system, the next practical step is to consolidate:

1. Typography tokens into one file
2. Radius and spacing constants into shared theme tokens
3. Repeated component treatments such as pills, glass cards, and gradient buttons into reusable widgets
