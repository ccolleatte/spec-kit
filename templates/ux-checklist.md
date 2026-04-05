# UX Checklist: [FEATURE NAME]

**Purpose**: Validate user-facing feature against WCAG AA, friction, responsive, and loading/error UX criteria.
**Created**: [DATE]
**Feature**: [Link to spec.md]
**Trigger**: Run `/ux-ui-designer-pro` review OR use as DoD checklist before Phase 3 implementation.

**Note**: This checklist covers the 6 UX Requirements (UX-001..UX-006) defined in `spec-template.md`. Skip if feature is non user-facing (document reason in spec.md).

---

## Accessibility (WCAG 2.1 AA)

- [ ] UX001 Color contrast ≥ 4.5:1 for text, ≥ 3:1 for UI components and graphics (tool: axe DevTools or WebAIM)
- [ ] UX002 All interactive elements reachable by keyboard (tab order logical, no traps)
- [ ] UX003 `focus-visible:` ring present on all interactive elements (never `outline-none` alone)
- [ ] UX004 Animations wrapped in `motion-safe:` variant (respects `prefers-reduced-motion`)
- [ ] UX005 Semantic HTML used (`<button>`, `<nav>`, `<main>`, `<form>`) — not generic `<div>`
- [ ] UX006 ARIA attributes applied where needed: `aria-busy`, `role="alert"`, `role="status"`, `aria-label` on icon-only buttons

## Friction Analysis

- [ ] UX007 Primary action reachable in ≤ 3 clicks from entry point
- [ ] UX008 User feedback on interaction < 200ms (loading state, hover, active)
- [ ] UX009 Error recovery inline (no blocking modals, no redirects to error page except fatal)
- [ ] UX010 Required fields marked explicitly; errors near the field, not at page top only
- [ ] UX011 No dark patterns (hidden costs, forced consent, confirm-shaming)

## Responsive Design

- [ ] UX012 Layout tested at 320px (mobile S), 768px (tablet), 1024px (laptop), 1440px (desktop)
- [ ] UX013 Touch targets ≥ 44×44px on mobile (buttons, links, form controls)
- [ ] UX014 No horizontal scroll at any supported breakpoint
- [ ] UX015 Text remains readable at 200% zoom (no overlap, no truncation)

## Loading & Error States

- [ ] UX016 Skeleton or loading indicator matches final layout structure (no layout shift on load)
- [ ] UX017 Error boundaries present (`error.tsx`) with actionable recovery (retry / go home / contact)
- [ ] UX018 Empty states designed (first-time user, zero results, permission denied) — not just blank

---

## Notes

- Check items off as validated: `[x]`
- Document findings inline or in `ux-review.md` next to this checklist
- Items UX001..UX006 are blocking for Phase 3 (implementation)
- Items UX007..UX018 are recommended — non-blocking but tracked

---

## Verification tools

- **Automated**: axe DevTools, WAVE, Lighthouse (Accessibility score target ≥ 90)
- **Manual**: keyboard-only navigation, screen reader (NVDA/JAWS/VoiceOver), 200% zoom
- **Responsive**: Chrome DevTools device mode at 4 breakpoints

---

**Source**: Derived from `ux-ui-designer-pro` skill (WCAG 2.1 AA, 6 friction categories, 4 breakpoints).
