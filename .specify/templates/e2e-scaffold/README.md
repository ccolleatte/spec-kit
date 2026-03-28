# E2E scaffold — spec-kit template

Scaffold Playwright E2E complet : config, Page Object Model, helpers accessibilite, visual regression, smoke tests.

Extrait et generalise depuis un projet production (52 specs, 17k lignes, 93% pass rate).

## Contenu

```
e2e-scaffold/
├── playwright.config.ts              # Config Playwright parametree
├── pages/
│   └── base.page.ts                  # Page Object Model (navigation, a11y, console errors)
├── helpers/
│   ├── auth-helpers.ts               # Squelette auth (directLogin pattern)
│   └── a11y-helpers.ts               # axe-core : scan, assertions WCAG AA, contraste
├── visual-regression/
│   └── example.visual.spec.ts        # Viewports (desktop/tablet/mobile) + themes (light/dark)
├── e2e/
│   └── smoke.spec.ts                 # Health check minimal (load, console, navigation, a11y)
└── README.md
```

## Installation

```bash
# 1. Copier le scaffold dans votre projet
cp -r .specify/templates/e2e-scaffold/* tests/

# 2. Installer les dependances
npm install -D @playwright/test @axe-core/playwright
npx playwright install chromium

# 3. Adapter les placeholders
#    Chercher [FRONTEND_PORT], [BACKEND_PORT], [PAGE_NAME], etc.
```

Ou via le script `setup-e2e.ps1` :

```powershell
pwsh .specify/scripts/powershell/setup-e2e.ps1 -Scaffold
```

## Placeholders a adapter

| Placeholder | Description | Exemple |
|-------------|-------------|---------|
| `[FRONTEND_PORT]` | Port du serveur de dev frontend | `5173` |
| `[BACKEND_PORT]` | Port du backend (si monorepo) | `3001` |
| `[PAGE_NAME]` | Nom de la page pour les screenshots | `dashboard` |
| `[PAGE]` | Prefixe fichier screenshot | `dashboard` |
| `[READY_INDICATOR]` | data-testid indiquant que la page est prete | `dashboard-loaded` |
| `[COMPONENT_TESTID]` | data-testid du composant a capturer | `wri-gauge` |

## Scripts npm a ajouter

```json
{
  "test:e2e": "playwright test",
  "test:e2e:headed": "playwright test --headed",
  "test:e2e:debug": "playwright test --debug",
  "test:e2e:report": "playwright show-report",
  "test:visual": "playwright test ./tests/visual-regression/",
  "test:visual-update": "playwright test ./tests/visual-regression/ --update-snapshots",
  "test:a11y": "playwright test ./tests/e2e/smoke.spec.ts -g 'a11y'"
}
```

## Workflow visual regression

1. **Generer les baselines** : `npm run test:visual-update`
2. **Valider** : `npm run test:visual` (compare pixel par pixel)
3. **Apres modification UI** : relancer `test:visual-update` et commiter les nouveaux PNG
4. **Tolerance** : `maxDiffPixels: 100`, `threshold: 0.2` (configurable dans `playwright.config.ts`)

## Etendre le scaffold

### Ajouter une page

```typescript
// tests/pages/dashboard.page.ts
import { BasePage } from './base.page.js';
import { expect } from '@playwright/test';

export class DashboardPage extends BasePage {
  async waitForReady() {
    await expect(this.page.getByTestId('dashboard')).toBeVisible({ timeout: 10_000 });
  }

  async getScore(): Promise<string> {
    return await this.page.getByTestId('score-value').textContent() ?? '';
  }
}
```

### Ajouter un helper

Placer dans `tests/helpers/` et importer dans les specs ou dans `base.page.ts`.

### Auth : pattern directLogin

Le `auth-helpers.ts` fourni utilise le pattern directLogin (injection token via `localStorage.setItem`) qui est 25x plus rapide que le login via UI. Adapter `generateTestToken()` a votre systeme d'auth.

## Provenance

Generalise depuis le projet Unrest (React + tRPC + Prisma, production).
Patterns valides sur 52 specs E2E, 4 specs visual regression, 15 baselines.
