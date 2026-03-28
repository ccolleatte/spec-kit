/**
 * Smoke Tests — Scaffold
 *
 * Minimal health checks that must pass before any other E2E test.
 * Validates that the application loads, renders, and navigates
 * without critical errors.
 *
 * Run:  npx playwright test tests/e2e/smoke.spec.ts
 */

import { test, expect } from '@playwright/test';
// import { loginAsTestUser } from '../helpers/auth-helpers';

test.describe('Smoke tests', () => {
  test('Home page loads and renders', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/.+/); // Page has a title
    await expect(page.locator('body')).toBeVisible();
  });

  test('No critical console errors on load', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Filter out known non-critical errors
    const critical = errors.filter(
      (e) =>
        !e.includes('net::ERR_') &&
        !e.includes('Failed to load resource') &&
        !e.includes('Download the React DevTools')
    );

    expect(critical, `Critical console errors:\n${critical.join('\n')}`).toHaveLength(0);
  });

  test('Navigation between main routes works', async ({ page }) => {
    // Adapt these routes to your application
    const routes = ['/', '/about'];

    for (const route of routes) {
      const response = await page.goto(route);
      expect(response?.status(), `Route ${route} returned non-200`).toBeLessThan(400);
    }
  });

  // --- Authenticated smoke tests ---
  // Uncomment after configuring auth-helpers
  //
  // test('Authenticated user can access dashboard', async ({ page }) => {
  //   await loginAsTestUser(page, 'smoke-test@example.com');
  //   await page.goto('/dashboard');
  //   await expect(page.getByTestId('dashboard')).toBeVisible({ timeout: 10_000 });
  // });

  // --- Accessibility baseline ---

  test('Home page has no critical a11y violations', async ({ page }) => {
    // Requires: npm install -D @axe-core/playwright
    let AxeBuilder: typeof import('@axe-core/playwright').default;
    try {
      AxeBuilder = (await import('@axe-core/playwright')).default;
    } catch {
      test.skip(true, '@axe-core/playwright not installed');
      return;
    }

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page }).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === 'critical' || v.impact === 'serious'
    );

    expect(
      critical,
      `Critical a11y violations:\n${critical.map((v) => `[${v.impact}] ${v.help}`).join('\n')}`
    ).toHaveLength(0);
  });
});
