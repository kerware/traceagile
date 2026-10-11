import { defineConfig, devices } from '@playwright/test';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

/**
 * Scénario du guide d'utilisation : construit le projet SWAG dans TraceAgile (pile Docker Compose
 * démarrée ; les runs sont joués par le serveur d'exécution réel, ADR-0026) et capture les écrans
 * dans docs/guide/images. Les fichiers de guide/ s'exécutent dans l'ordre de leur numéro.
 */
export default defineConfig({
  // hors du dossier synchronisé (OneDrive verrouille les traces en cours d'écriture)
  outputDir: join(tmpdir(), 'traceagile-saucedemo', 'guide'),
  testDir: './guide',
  // les runs réels (npm ci, navigateurs, tests de saucedemo) prennent plusieurs minutes
  timeout: 1_200_000,
  expect: { timeout: 15_000 },
  workers: 1,
  fullyParallel: false,
  // chaque fichier dépend des données du précédent
  maxFailures: 1,
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'results/rapport-guide' }]],
  use: {
    baseURL: process.env.TRACEAGILE_URL ?? 'http://localhost:3000',
    locale: 'fr-FR',
    timezoneId: 'Europe/Paris',
    colorScheme: 'light',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'guide', use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 } }],
});
