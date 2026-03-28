/**
 * Accessibility (A11y) Testing Helpers
 *
 * Automated accessibility testing via axe-core:
 * - checkA11y: run axe scan on page or region
 * - assertNoA11yViolations: assert zero violations (with impact filters)
 * - checkContrastRatio: calculate WCAG contrast ratio
 * - assertWCAGContrast: assert WCAG AA compliance
 *
 * Requirements:
 *   npm install -D @axe-core/playwright
 *
 * @see https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright
 */

import type { Page } from '@playwright/test';
import { expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import type { AxeResults, Result as AxeViolation } from 'axe-core';

/**
 * Run axe accessibility scan
 */
export async function checkA11y(
  page: Page,
  options?: {
    include?: string[];
    exclude?: string[];
    excludeFormContrast?: boolean;
  }
): Promise<AxeResults> {
  let builder = new AxeBuilder({ page });

  if (options?.include) {
    builder = builder.include(options.include);
  }
  if (options?.exclude) {
    builder = builder.exclude(options.exclude);
  }
  if (options?.excludeFormContrast) {
    builder = builder.disableRules(['color-contrast']);
  }

  return await builder.analyze();
}

/**
 * Assert zero accessibility violations
 *
 * @example
 * // Strict — fail on any violation
 * await assertNoA11yViolations(page);
 *
 * @example
 * // Lenient — allow moderate/minor
 * await assertNoA11yViolations(page, {
 *   allowedImpacts: ['moderate', 'minor'],
 * });
 */
export async function assertNoA11yViolations(
  page: Page,
  options?: {
    include?: string[];
    exclude?: string[];
    allowedImpacts?: ('critical' | 'serious' | 'moderate' | 'minor')[];
    excludeFormContrast?: boolean;
  }
): Promise<void> {
  const results = await checkA11y(page, {
    include: options?.include,
    exclude: options?.exclude,
    excludeFormContrast: options?.excludeFormContrast,
  });

  const allowedImpacts = options?.allowedImpacts ?? [];
  const violations = results.violations.filter((v) => {
    const impact = v.impact as
      | 'critical'
      | 'serious'
      | 'moderate'
      | 'minor'
      | undefined;
    return impact && !allowedImpacts.includes(impact);
  });

  if (violations.length > 0) {
    const msg = formatViolations(violations);
    expect(violations, msg).toHaveLength(0);
  }
}

/**
 * Calculate WCAG contrast ratio for an element
 */
export async function checkContrastRatio(
  page: Page,
  selector: string
): Promise<number> {
  const results = await new AxeBuilder({ page })
    .include([selector])
    .withRules(['color-contrast'])
    .analyze();

  const violated = results.violations.find((r) => r.id === 'color-contrast');
  if (violated?.nodes.length) {
    const data = violated.nodes[0].any[0]?.data as {
      contrastRatio?: number;
    };
    return data?.contrastRatio ?? 0;
  }

  const passed = results.passes.find((r) => r.id === 'color-contrast');
  if (passed?.nodes.length) {
    const data = passed.nodes[0].any[0]?.data as { contrastRatio?: number };
    return data?.contrastRatio ?? 4.5;
  }

  return 0;
}

/**
 * Assert WCAG AA contrast (4.5:1 normal, 3:1 large text)
 */
export async function assertWCAGContrast(
  page: Page,
  selector: string,
  isLargeText = false
): Promise<void> {
  const ratio = await checkContrastRatio(page, selector);
  const threshold = isLargeText ? 3.0 : 4.5;
  expect(
    ratio,
    `WCAG AA contrast for '${selector}': ${ratio}:1 (min ${threshold}:1)`
  ).toBeGreaterThanOrEqual(threshold);
}

// --- Internal ---

function formatViolations(violations: AxeViolation[]): string {
  const lines = [`Found ${violations.length} accessibility violation(s):`, ''];
  violations.forEach((v, i) => {
    lines.push(`${i + 1}. [${v.impact?.toUpperCase()}] ${v.help}`);
    lines.push(`   ${v.helpUrl}`);
    lines.push(`   Affected: ${v.nodes.length} element(s)`);
    v.nodes.slice(0, 3).forEach((n) => {
      lines.push(`   - ${n.html.substring(0, 80)}...`);
    });
    if (v.nodes.length > 3) {
      lines.push(`   ... and ${v.nodes.length - 3} more`);
    }
    lines.push('');
  });
  return lines.join('\n');
}

export type { AxeResults, AxeViolation };
export type A11yViolation = AxeViolation;
