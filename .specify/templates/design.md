# Design Tokens: [PROJECT NAME]

<!--
  Purpose: Plain-text design token file readable by any LLM or design tool before UI generation.
  Place at: project root or feature directory for feature-scoped overrides.
  Usage: Reference in /speckit.specify prompts and any prototyping or code generation session (Claude Design, Google Stitch, v0, Figma, or any LLM-assisted tool).
  
  Skip sections that don't apply — remove them entirely, don't leave as "N/A".
-->

## Color

```
primary:    #[hex]    /* Main action, CTA buttons */
secondary:  #[hex]    /* Supporting elements */
accent:     #[hex]    /* Highlights, badges, tags */
neutral:    #[hex]    /* Borders, dividers, subtle bg */
background: #[hex]    /* Page background */
surface:    #[hex]    /* Card / panel background */
error:      #[hex]    /* Error states */
success:    #[hex]    /* Success / confirmation */
warning:    #[hex]    /* Warning states */
text:       #[hex]    /* Body text */
text-muted: #[hex]    /* Secondary / disabled text */
```

## Typography

```
font-family-base:    [font name, fallback stack]
font-family-heading: [font name, fallback stack]
font-family-mono:    [font name, fallback stack]

/* Type scale (rem, base 16px) */
text-xs:   0.75rem  /* 12px */
text-sm:   0.875rem /* 14px */
text-base: 1rem     /* 16px */
text-lg:   1.125rem /* 18px */
text-xl:   1.25rem  /* 20px */
text-2xl:  1.5rem   /* 24px */
text-3xl:  1.875rem /* 30px */
text-4xl:  2.25rem  /* 36px */

font-weight-normal: 400
font-weight-medium: 500
font-weight-semibold: 600
font-weight-bold: 700
```

## Spacing

```
/* 4px base grid */
space-1:  0.25rem  /* 4px  */
space-2:  0.5rem   /* 8px  */
space-3:  0.75rem  /* 12px */
space-4:  1rem     /* 16px */
space-5:  1.25rem  /* 20px */
space-6:  1.5rem   /* 24px */
space-8:  2rem     /* 32px */
space-10: 2.5rem   /* 40px */
space-12: 3rem     /* 48px */
space-16: 4rem     /* 64px */
```

## Border Radius

```
radius-sm:   0.25rem  /* 4px  — inputs, badges */
radius-md:   0.5rem   /* 8px  — cards, panels */
radius-lg:   0.75rem  /* 12px — modals, dialogs */
radius-xl:   1rem     /* 16px — sheets */
radius-full: 9999px   /* pills, avatars */
```

## Shadows

```
shadow-sm: 0 1px 2px rgba(0,0,0,0.05)
shadow-md: 0 4px 6px rgba(0,0,0,0.07)
shadow-lg: 0 10px 15px rgba(0,0,0,0.10)
```

## Breakpoints

```
sm:  640px   /* Mobile landscape */
md:  768px   /* Tablet */
lg:  1024px  /* Laptop */
xl:  1280px  /* Desktop */
2xl: 1536px  /* Wide */
```

## Component Rules

<!--
  Optional: document component-level constraints that go beyond tokens.
  Example: button height, icon size, input padding, avatar size.
-->

```
button-height-sm:  32px
button-height-md:  40px
button-height-lg:  48px
input-height:      40px
icon-size-sm:      16px
icon-size-md:      20px
icon-size-lg:      24px
avatar-sm:         32px
avatar-md:         40px
avatar-lg:         56px
```

## Accessibility Rules

```
/* WCAG 2.1 AA minimum — enforce in every generation */
min-contrast-text:       4.5:1
min-contrast-ui:         3:1
min-touch-target:        44px × 44px
focus-ring:              2px solid primary, offset 2px
motion-safe:             respect prefers-reduced-motion
```

---

*Plain-text design token format — readable by any LLM or code generation tool.*
