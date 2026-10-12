import { expect, test } from '@playwright/test';
import { capturer, EXECUTEUR_MOT_DE_PASSE, EXECUTEUR_URL, lireEtat, SANS_CAPTURES } from './outils';

/**
 * Guide § 15 — le serveur d'exécution réel (ADR-0026) : tableau de bord de suivi, jobs reçus de
 * TraceAgile (le run du sprint 2), outils installés à chaud et assistant d'installation, jetons.
 */
test.use({ baseURL: EXECUTEUR_URL });
// étape de captures seulement
test.skip(SANS_CAPTURES, 'génération de la démo sans captures');

test('Serveur d’exécution : suivi, jobs, outils, jetons', async ({ page }) => {
  await test.step('Connexion de l’administrateur du serveur', async () => {
    await page.goto('/');
    await page.getByTestId('login-password').fill(EXECUTEUR_MOT_DE_PASSE);
    await capturer(page, 'es-connexion', page.locator('form'), { marge: 12 });
    await page.getByTestId('login-submit').click();
    await expect(page.getByTestId('dashboard')).toBeVisible();
  });

  await test.step('Tableau de bord : activité, taux de réussite, tests par jour, tests en échec', async () => {
    await expect(page.getByTestId('failing-tests')).toContainText('TC-10');
    await capturer(page, 'es-tableau-de-bord', undefined, { pleinePage: true });
  });

  await test.step('Jobs reçus de TraceAgile ; détail du run du sprint 2', async () => {
    await page.goto('/jobs');
    await expect(page.getByTestId('jobs-table')).toBeVisible();
    await capturer(page, 'es-jobs');
    const projet = String(lireEtat().projet ?? 'SWAG');
    await page.getByTestId('jobs-search').fill(`${projet}/RUN-2`);
    // le serveur garde les jobs des générations précédentes : le plus récent est en tête
    await page.getByRole('link', { name: `${projet}/RUN-2` }).first().click();
    await expect(page.getByTestId('job-tests')).toContainText('TC-10');
    await capturer(page, 'es-job', undefined, { pleinePage: true });
    await page.getByRole('tab', { name: 'Journal' }).click();
    await expect(page.getByTestId('job-logs')).toContainText('npx playwright test');
    await capturer(page, 'es-job-journal', page.getByTestId('job-logs'));
    await page.getByRole('tab', { name: /Artefacts/ }).click();
    await page.getByRole('button', { name: 'screenshot-TC-10.png' }).click();
    await expect(page.getByRole('img', { name: 'screenshot-TC-10.png' })).toBeVisible();
    await page.waitForTimeout(500);
    await capturer(page, 'es-copie-ecran', page.getByRole('dialog'), { marge: 8 });
    await page.keyboard.press('Escape');
  });

  await test.step('Outils : prérequis détectés, outils installés à chaud, aide et journal, assistant', async () => {
    await page.goto('/tools');
    await expect(page.getByTestId('tool-playwright')).toBeVisible();
    await capturer(page, 'es-outils', undefined, { pleinePage: true });
    await page.getByTestId('tool-details-robotframework').click();
    await expect(page.getByTestId('tool-script')).toBeVisible();
    await capturer(page, 'es-outil-aide', page.getByRole('dialog'));
    await page.keyboard.press('Escape');
    await page.getByTestId('tools-assistant').click();
    const champ = page.getByRole('dialog').getByRole('textbox');
    for (const framework of ['Robot Framework', 'Cypress', 'Gatling']) {
      await champ.fill(framework);
      await page.getByRole('option', { name: framework, exact: true }).click();
    }
    await page.getByRole('dialog').getByText('Assistant d\'installation').click();
    await expect(page.getByTestId('assistant-plan')).toContainText('Robot Framework');
    await page.waitForTimeout(500);
    await capturer(page, 'es-assistant', page.getByRole('dialog'), { marge: 8 });
    await page.keyboard.press('Escape');
  });

  await test.step('Jetons de sécurité', async () => {
    await page.goto('/tokens');
    await expect(page.getByTestId('tokens-table')).toContainText('TraceAgile');
    await capturer(page, 'es-jetons');
  });
});
