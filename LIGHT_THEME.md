# Modern Learner Light Theme

This document defines the light theme companion to `DESIGN_SCHEMA.md`. It preserves the same premium, editorial learning product while moving the base from dark glass surfaces to clean, layered bright surfaces.

## Product Style

The light theme should feel crisp, calm, and premium rather than plain. It keeps the violet brand accent and mint success language from the dark theme, but uses ink-like text, soft cool-gray panels, and restrained shadows for depth.

Core visual traits:

- Light-first interface with a cool off-white canvas
- Layered bright surfaces instead of dark glass
- Violet for primary action, active state, and focus
- Green-mint for progress, completion, and success
- Thin cool-gray borders and subtle shadows instead of heavy glow

## Source of Truth

Runtime implementation source files:

- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_theme_controller.dart`
- `lib/core/theme/app_colors.dart`

Implementation note:

- `AppTheme.light` defines the Material light theme.
- `AppThemeController` stores `dark`, `light`, or `system` and drives `MaterialApp.themeMode`.
- Existing custom widgets still use `AppColors` directly in many places. Future cleanup should migrate those surfaces to theme-aware tokens.

## Typography

The light theme uses the same type system as the dark theme:

| Token | Font | Size | Weight | Typical usage |
|---|---|---:|---:|---|
| `displayLarge` | Space Grotesk | 52 | 700 | Hero titles |
| `displayMedium` | Space Grotesk | 40 | 700 | Major section moments |
| `displaySmall` | Space Grotesk | 32 | 600 | Large screen titles |
| `headlineLarge` | Space Grotesk | 28 | 600 | Page titles |
| `headlineMedium` | Space Grotesk | 24 | 600 | Section headers |
| `headlineSmall` | Space Grotesk | 20 | 600 | Card titles |
| `titleLarge` | Space Grotesk | 18 | 600 | Compact headings |
| `titleMedium` | Space Grotesk | 16 | 500 | Secondary titles |
| `bodyLarge` | Inter | 16 | 400 | Main reading text |
| `bodyMedium` | Inter | 14 | 400 | Support text |
| `labelLarge` | Inter | 12 | 600 | Small labels |
| `labelMedium` | Inter | 11 | 600 | Dense metadata |

## Color System

### Core Palette

| Token | Hex | Role |
|---|---|---|
| `surface` | `#F7F7FC` | Default app background |
| `surfaceContainerLowest` | `#FFFFFF` | Cleanest card fill |
| `surfaceContainerLow` | `#F1F2F8` | Low-emphasis panels |
| `surfaceContainer` | `#EBECF5` | Standard elevated surface |
| `surfaceContainerHigh` | `#E3E5F0` | Inputs and active containers |
| `surfaceContainerHighest` | `#D8DAE7` | Strong separators and controls |
| `surfaceBright` | `#FFFFFF` | Brightest floating surface |
| `primary` | `#6D4CFF` | Main brand accent |
| `primaryDim` | `#5334D8` | Strong action accent |
| `primaryContainer` | `#E7E1FF` | Soft violet container |
| `onPrimary` | `#FFFFFF` | Text on violet surfaces |
| `secondary` | `#5661D9` | Secondary accent |
| `tertiary` | `#0C8E61` | Success and progress |
| `tertiaryContainer` | `#CCF6E0` | Soft mint highlight |
| `onSurface` | `#151622` | Primary text |
| `onSurfaceVariant` | `#626475` | Secondary text |
| `outlineVariant` | `#D8DAE7` | Borders and dividers |
| `error` | `#D83A56` | Error and destructive feedback |

### Gradients

- `primaryGradient`: `#5334D8 -> #6D4CFF`
- `tertiaryGradient`: `#CCF6E0 -> #7BE7B0`

Use gradients sparingly in light mode. Prefer solid violet buttons with a small shadow, and reserve gradients for hero moments, active chips, or premium highlights.

## Surface Schema

### Backgrounds

- Default page background: cool off-white `#F7F7FC`
- Header fade: white or very pale violet blending into the page
- Avoid pure white full-screen pages unless they are form-like or modal

### Cards

- Small utility cards: radius `16`
- Standard panels: radius `20`
- Main content cards: radius `24`
- Spotlight cards: radius `28-30`
- Pills and badges: radius `999`

Light cards should use a visible but quiet boundary: a pale border, a soft shadow, or a slightly darker container fill. Do not rely on blur alone.

## Components

### Buttons

- Primary buttons use violet fill or `primaryGradient`
- Text on primary buttons is white
- Standard height remains `56`
- Radius remains `18`
- Shadow should be subtle and violet-tinted

### Inputs

- Fill: `surfaceContainerLow` or `surfaceContainer`
- Border: `outlineVariant`
- Focus: `primary`
- Error: `error`
- Text: `onSurface`

### Navigation

- Bottom navigation uses a translucent white bar with a thin top border
- Inactive icons and labels use `onSurfaceVariant`
- Active states use `primary`
- The center create action remains circular and violet

### Pills, Chips, And Badges

- Active chips use soft violet containers or violet fill
- Inactive chips use white or pale gray surfaces with borders
- Success chips use mint containers with green text

## Profile Screen Guidance

Profile in light mode should keep its current hierarchy:

- Hero/profile header uses a pale violet or white surface with a soft border
- Stats and achievement cards use white cards over the off-white page
- Settings rows use `surfaceContainerLow` and thin dividers
- The appearance sheet should immediately reflect selected theme state
- VIP/premium moments can keep gold accents, but avoid large gold fills

## Usage Rules

- Keep violet as the primary action color.
- Keep mint/green for completion, progress, and positive learning state.
- Keep destructive states coral/red only.
- Use the same spacing and radius system as the dark theme.
- Prefer cool grays over beige or warm cream so the app still feels like Modern Learner.
- Avoid heavy drop shadows; use shallow elevation and clear borders.

## Migration Note

The current app contains many direct `AppColors` references. To make every custom widget fully theme-aware, migrate shared components from static color constants to `Theme.of(context).colorScheme` or a custom `ThemeExtension` in small slices, starting with Profile, Home, and Progress surfaces.
