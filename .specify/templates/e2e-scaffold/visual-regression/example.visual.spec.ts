/**
 * Visual Regression Tests — Scaffold
 *
 * Captures baseline screenshots for pixel-perfect comparison
 * across viewports and themes.
 *
 * Baseline generation:  npm run test:visual-update
 * Baseline validation:  npm run test:visual
 *
 * Adapt the beforeEach to your app's auth and navigation.
 */

import { test, expect } from '@playwright/test';
// import { loginAsTestUser } from '../helpers/auth-helpers';

test.describe('Visual regression — [PAGE_NAME]', () => {
  test.beforeEach(async ({ page }) => {
    // Authenticate if needed
    // await loginAsTestUser(page, 'visual-test@example.com');

    // Navigate to the target page
    await page.goto('/');

    // Wait for page content to be ready
    // await expect(page.getByTestId('[READY_INDICATOR]')).toBeVisible({ timeout: 10_000 });

    // Let animations settle
    await page.waitForTimeout(500);
  });

  // --- Viewport tests ---

  test('Desktop 1280px — Light mode', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page).toHaveScreenshot('[PAGE]-desktop-light.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  test('Tablet 768px — Light mode', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page).toHaveScreenshot('[PAGE]-tablet-light.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  test('Mobile 375px — Light mode', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await expect(page).toHaveScreenshot('[PAGE]-mobile-light.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  // --- Theme tests ---

  test('Desktop 1280px — Dark mode', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 720 });

    // Enable dark mode via media query emulation
    await page.emulateMedia({ colorScheme: 'dark' });
    await page.waitForTimeout(300);

    await expect(page).toHaveScreenshot('[PAGE]-desktop-dark.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  // --- Component-specific tests ---
  // Add tests for individual components that need visual stability:
  //
  // test('Component — [NAME] default state', async ({ page }) => {
  //   const component = page.getByTestId('[COMPONENT_TESTID]');
  //   await expect(component).toHaveScreenshot('[COMPONENT]-default.png', {
  //     animations: 'disabled',
  //   });
  // });
});
