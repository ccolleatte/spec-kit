/**
 * Base Page Object Model
 *
 * Common functionality for all page objects:
 * - Navigation with configurable routing (hash or path-based)
 * - Console error capture and assertion
 * - Accessibility checks via axe-core
 * - Screenshot and loading helpers
 *
 * Extend this class for each page in your application.
 *
 * @example
 * class DashboardPage extends BasePage {
 *   async waitForReady() {
 *     await this.page.getByTestId('dashboard').waitFor();
 *   }
 * }
 */

import { Page, Locator, expect } from '@playwright/test';
import {
  checkA11y,
  assertNoA11yViolations,
  checkContrastRatio,
  assertWCAGContrast,
} from '../helpers/a11y-helpers.js';
import type { A11yViolation } from '../helpers/a11y-helpers.js';

export type RoutingMode = 'hash' | 'path';

export class BasePage {
  readonly page: Page;
  readonly baseURL: string;
  readonly routing: RoutingMode;

  // Console error tracking
  private consoleErrors: string[] = [];

  constructor(
    page: Page,
    options?: { baseURL?: string; routing?: RoutingMode }
  ) {
    this.page = page;
    this.baseURL = options?.baseURL ?? 'http://localhost:[FRONTEND_PORT]';
    this.routing = options?.routing ?? 'path';

    // Capture console errors automatically
    this.page.on('console', (msg) => {
      if (msg.type() === 'error') {
        const text = msg.text();
        // Exclude common noise
        if (!this.isExcludedError(text)) {
          this.consoleErrors.push(text);
        }
      }
    });
  }

  /**
   * Override to add project-specific console error exclusions
   */
  protected isExcludedError(text: string): boolean {
    const excludePatterns = [
      /Download the React DevTools/i,
      /Failed to load resource.*401/i,
      /net::ERR_CONNECTION_REFUSED/i,
    ];
    return excludePatterns.some((p) => p.test(text));
  }

  /**
   * Navigate to a path
   */
  async goto(path: string) {
    const url =
      this.routing === 'hash'
        ? `${this.baseURL}/#${path}`
        : `${this.baseURL}${path}`;
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });
  }

  /**
   * Wait for navigation to complete
   */
  async waitForNavigation() {
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Click and wait for navigation
   */
  async clickAndNavigate(selector: string | Locator) {
    const locator =
      typeof selector === 'string' ? this.page.locator(selector) : selector;
    await locator.click();
    await this.waitForNavigation();
  }

  /**
   * Wait for loading indicator to disappear
   */
  async waitForLoading(testId = 'loading') {
    const loading = this.page.getByTestId(testId);
    await expect(loading).toBeHidden({ timeout: 10_000 });
  }

  /**
   * Take a debug screenshot
   */
  async screenshot(name: string) {
    await this.page.screenshot({
      path: `tests/screenshots/${name}.png`,
      fullPage: true,
    });
  }

  /**
   * Get current URL path
   */
  getCurrentPath(): string {
    const url = new URL(this.page.url());
    if (this.routing === 'hash') {
      const hash = url.hash;
      return hash.startsWith('#') ? hash.slice(1) : hash;
    }
    return url.pathname;
  }

  /**
   * Assert current path
   */
  async assertPath(expectedPath: string) {
    if (this.routing === 'hash') {
      await expect(this.page).toHaveURL(`${this.baseURL}/#${expectedPath}`);
    } else {
      await expect(this.page).toHaveURL(`${this.baseURL}${expectedPath}`);
    }
  }

  // --- Console error assertions ---

  /**
   * Assert no console errors occurred during test
   */
  assertNoConsoleErrors(): void {
    expect(
      this.consoleErrors,
      `Unexpected console errors:\n${this.consoleErrors.join('\n')}`
    ).toHaveLength(0);
  }

  /**
   * Clear accumulated console errors (reset mid-test)
   */
  clearConsoleErrors(): void {
    this.consoleErrors = [];
  }

  // --- Accessibility assertions ---

  /**
   * Check accessibility and assert zero violations
   *
   * @example
   * await page.checkAccessibility(); // strict
   * await page.checkAccessibility({ allowedImpacts: ['moderate', 'minor'] });
   */
  async checkAccessibility(options?: {
    include?: string[];
    exclude?: string[];
    allowedImpacts?: ('critical' | 'serious' | 'moderate' | 'minor')[];
    excludeFormContrast?: boolean;
  }): Promise<void> {
    await assertNoA11yViolations(this.page, options);
  }

  /**
   * Get violations without throwing (for inspection/logging)
   */
  async getAccessibilityViolations(options?: {
    include?: string[];
    exclude?: string[];
  }): Promise<A11yViolation[]> {
    const results = await checkA11y(this.page, options);
    return results.violations;
  }

  /**
   * Assert WCAG AA contrast ratio for an element
   */
  async checkWCAGContrast(
    selector: string,
    isLargeText = false
  ): Promise<void> {
    await assertWCAGContrast(this.page, selector, isLargeText);
  }

  /**
   * Get contrast ratio (non-throwing)
   */
  async getContrastRatio(selector: string): Promise<number> {
    return await checkContrastRatio(this.page, selector);
  }
}
