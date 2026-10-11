import { defineConfig, devices } from '@playwright/test';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

/**
 * Tests réels de l'application de démonstration www.saucedemo.com (Swag Labs), jusqu'à la
 * visualisation du panier : le parcours de commande (checkout) n'est pas encore développé.
 * Le rapport JUnit `results/junit-saucedemo.xml` est importé dans TraceAgile par le scénario du guide.
 */
export default defineConfig({
  // hors du dossier synchronisé (OneDrive verrouille les traces en cours d'écriture)
  outputDir: join(tmpdir(), 'traceagile-saucedemo', 'app'),
  testDir: './app-tests',
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  workers: 2,
  reporter: [
    ['list'],
    ['junit', { outputFile: 'results/junit-saucedemo.xml' }],
    ['html', { open: 'never', outputFolder: 'results/rapport-saucedemo' }],
  ],
  use: {
    baseURL: 'https://www.saucedemo.com',
    // les éléments de Swag Labs portent un attribut data-test
    testIdAttribute: 'data-test',
    locale: 'en-US',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } } }],
});
