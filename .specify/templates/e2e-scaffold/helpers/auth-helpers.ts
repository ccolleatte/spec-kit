/**
 * Auth Test Helpers — Scaffold
 *
 * Skeleton for E2E authentication. Adapt to your auth system:
 * - JWT: generate test tokens directly (bypass login flow)
 * - Session: inject session cookie via storageState
 * - OAuth: use test accounts with pre-seeded tokens
 *
 * The directLogin pattern (inject token + navigate) is ~25x faster
 * than UI-based login for test setup.
 */

import type { Page } from '@playwright/test';

// --- Adapt these to your auth system ---

const BASE_URL = 'http://localhost:[FRONTEND_PORT]';
const AUTH_STORAGE_KEY = 'auth-token'; // localStorage key for your auth token

/**
 * Login as test user via direct token injection
 *
 * Bypasses UI login flow for speed. Generate a valid token
 * server-side or use a pre-seeded test account.
 *
 * @param page - Playwright Page
 * @param email - Test user email
 *
 * @example
 * test.beforeEach(async ({ page }) => {
 *   await loginAsTestUser(page, 'test@example.com');
 * });
 */
export async function loginAsTestUser(
  page: Page,
  email: string
): Promise<void> {
  // Option 1: Direct token injection (fastest)
  // Replace with your token generation logic
  const token = await generateTestToken(email);

  await page.goto(BASE_URL);
  await page.evaluate(
    ({ key, value }) => {
      localStorage.setItem(key, value);
    },
    { key: AUTH_STORAGE_KEY, value: token }
  );

  // Reload to pick up the token
  await page.reload({ waitUntil: 'domcontentloaded' });
}

/**
 * Logout test user — clear auth state
 */
export async function logoutTestUser(page: Page): Promise<void> {
  await page.evaluate((key) => {
    localStorage.removeItem(key);
  }, AUTH_STORAGE_KEY);
  await page.reload();
}

/**
 * Clean up test user after tests
 *
 * Adapt to your user management system (Prisma, Supabase, etc.)
 */
export async function deleteTestUser(_email: string): Promise<void> {
  // TODO: Implement cleanup via your DB client
  // Example with Prisma:
  // await prisma.user.delete({ where: { email } });
}

// --- Internal helpers ---

/**
 * Generate a test JWT or session token
 *
 * Replace with your actual token generation.
 * For JWT: use the same secret as your backend with extended expiry.
 */
async function generateTestToken(email: string): Promise<string> {
  // TODO: Replace with your token generation
  // Example with jsonwebtoken:
  //
  // import jwt from 'jsonwebtoken';
  // return jwt.sign(
  //   { email, role: 'USER' },
  //   process.env.JWT_SECRET!,
  //   { expiresIn: '2h', algorithm: 'HS256' }
  // );

  // Placeholder — remove after implementing
  return `test-token-${email}-${Date.now()}`;
}
