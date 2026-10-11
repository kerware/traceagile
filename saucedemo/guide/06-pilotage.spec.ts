import { expect, test } from '@playwright/test';
import { Api, capturer, connexion, fermerNotifications, P } from './outils';

/**
 * Guide § 11 à § 14 — piloter la qualité : traçabilité (matrice, couverture, orphelins, impact et
 * suspicion), anomalies, tableau de bord, bilans et rapports (verdict, modèles, exports), puis les
 * aides à la navigation (recherche, aperçu des clés, raccourcis, notifications, thème sombre).
 */
test('Pilotage : traçabilité, anomalies, tableau de bord, rapports, ergonomie', async ({ page, request }) => {
  const po = await Api.de(request, 'po');

  await test.step('Matrice de traçabilité du projet : exigences × tests, statut de vérification', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/traceability`);
    await expect(page.getByTestId('matrix')).toBeVisible();
    await capturer(page, 'tracabilite-matrice', undefined, { pleinePage: true });
    await page.goto(`/p/${P}/traceability?scope=requirement:REQ-9`);
    await expect(page.getByTestId('matrix-status-REQ-12')).toHaveAttribute('data-status', 'FAILED');
    await capturer(page, 'tracabilite-matrice-panier', page.getByTestId('matrix'), { marge: 8 });
  });

  await test.step('Couverture et exigences orphelines (la commande n’a pas de test)', async () => {
    await page.goto(`/p/${P}/traceability?tab=coverage`);
    await expect(page.getByTestId('coverage-table')).toBeVisible();
    await capturer(page, 'tracabilite-couverture', undefined, { pleinePage: true });
    await page.goto(`/p/${P}/traceability?tab=orphans`);
    await expect(page.getByText('Valider la commande')).toBeVisible();
    await capturer(page, 'tracabilite-orphelins');
  });

  await test.step('Fiche d’une story : arbre de traçabilité, exécutions et anomalies', async () => {
    await page.goto(`/p/${P}/requirements/REQ-12`);
    await page.getByTestId('tab-traceability').click();
    await expect(page.getByTestId('trace-tree')).toBeVisible();
    await capturer(page, 'exigence-arbre-tracabilite', page.getByTestId('requirement-detail'));
    await page.getByTestId('tab-defects').click();
    await expect(page.getByTestId('requirement-defects')).toContainText('DEF-1');
    await capturer(page, 'exigence-anomalies', page.getByTestId('requirement-detail'));
    await page.goto(`/p/${P}/tests/TC-1`);
    await page.getByTestId('test-tab-executions').click();
    await expect(page.getByTestId('test-executions')).toContainText('Comptes');
    await capturer(page, 'test-executions-jeu-de-donnees', page.getByTestId('test-detail'));
  });

  await test.step('Le PO précise la fiche produit : les tests liés deviennent suspects (impact)', async () => {
    await po.patch('/requirements/REQ-8', { title: 'Consulter la fiche détaillée d’un produit' });
    await page.goto(`/p/${P}/traceability?tab=impact&requirement=REQ-8`);
    await expect(page.getByTestId('impact-tests')).toContainText('TC-6');
    await capturer(page, 'tracabilite-impact');
    await page.getByTestId('impact-review-TC-6').click();
    await expect(page.getByTestId('impact-review-TC-6')).toHaveCount(0);
  });

  await test.step('Anomalies : liste, fiche, cycle de vie, pièces jointes', async () => {
    await page.goto(`/p/${P}/defects`);
    await expect(page.getByTestId('defect-row-DEF-2')).toBeVisible();
    await capturer(page, 'anomalies-liste');
    await page.getByTestId('defect-row-DEF-1').click();
    await expect(page.getByTestId('defect-panel')).toBeVisible();
    await expect(page.getByTestId('defect-attachments')).toContainText('sd-defaut-problem-user.png');
    await capturer(page, 'anomalie-fiche', page.getByTestId('defect-panel'), { marge: 6 });
  });

  await test.step('Tableau de bord du PO', async () => {
    await connexion(page, 'po');
    await page.goto(`/p/${P}/dashboard`);
    await expect(page.getByTestId('widget-sprint')).toContainText('SPR-2');
    await expect(page.getByTestId('chart-burndown').locator('svg')).toBeVisible();
    await capturer(page, 'tableau-de-bord', undefined, { pleinePage: true });
  });

  await test.step('Bilan du sprint 1, figé à la clôture', async () => {
    await page.goto(`/p/${P}/reports/RPT-1`);
    await expect(page.getByTestId('report-frozen')).toBeVisible();
    await expect(page.frameLocator('[data-testid=report-frame]').getByRole('heading', { name: '1. Synthèse' })).toBeVisible();
    await capturer(page, 'rapport-sprint-1-fige');
  });

  await test.step('Le PO génère le bilan du sprint 2 : verdict calculé, puis tranché avec un commentaire', async () => {
    await page.goto(`/p/${P}/reports`);
    await page.getByTestId('report-generate').click();
    await expect(page.getByTestId('generate-scope')).toHaveValue(/^SPR-2/);
    await capturer(page, 'rapport-generer', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('generate-submit').click();
    await expect(page.getByTestId('report-page')).toBeVisible();
    await expect(page.getByTestId('report-verdict')).toHaveAttribute('data-verdict', /^(NO_GO|GO_WITH_RESERVATIONS)$/);
    await expect(page.frameLocator('[data-testid=report-frame]').getByRole('heading', { name: '1. Synthèse' })).toBeVisible();
    await capturer(page, 'rapport-sprint-2');
    const bilan = page.frameLocator('[data-testid=report-frame]');
    await bilan.locator('body').evaluate(() => window.scrollTo(0, 0));
    await page.getByTestId('report-verdict-edit').click();
    await page.getByTestId('verdict-select').click();
    await page.getByRole('option', { name: 'Go sous réserve' }).click();
    await page.getByTestId('verdict-comment').fill('Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.');
    await capturer(page, 'rapport-verdict', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('verdict-submit').click();
    await expect(page.getByTestId('report-verdict-comment')).toBeVisible();
    const cle = (await page.locator('[data-testid=report-page] .mantine-Badge-root').first().innerText()).trim();
    await page.getByTestId(`export-${cle}`).click();
    await expect(page.getByTestId(`export-${cle}-PDF`)).toBeVisible();
    await capturer(page, 'rapport-exports');
    await page.keyboard.press('Escape');
  });

  await test.step('Modèles de rapport et règles de verdict', async () => {
    await page.goto(`/p/${P}/reports?tab=definitions`);
    await page.getByTestId('definition-new').click();
    await page.getByTestId('definition-name').fill('Comité qualité Swag Labs');
    await page.getByTestId('definition-toggle-BURNDOWN').click();
    await page.getByTestId('definition-toggle-DEFECT_LIST').click();
    await page.getByTestId('definition-format').click();
    await page.getByRole('option', { name: 'PDF' }).click();
    await capturer(page, 'rapport-modele', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('definition-submit').click();
    await expect(page.getByTestId('definition-Comité qualité Swag Labs')).toBeVisible();
    await page.goto(`/p/${P}/reports?tab=rules`);
    await expect(page.getByTestId('verdict-rules')).toBeVisible();
    await capturer(page, 'rapport-regles-verdict', page.getByTestId('verdict-rules'), { marge: 10 });
    await page.goto(`/p/${P}/reports`);
    await expect(page.getByTestId('reports-table')).toBeVisible();
    await capturer(page, 'rapports-liste');
  });

  await test.step('Recherche globale Ctrl+K, aperçu d’une clé, aide des raccourcis', async () => {
    await page.goto(`/p/${P}/dashboard`);
    await expect(page.getByTestId('dashboard')).toBeVisible();
    await page.keyboard.press('ControlOrMeta+k');
    await page.getByTestId('search-input').fill('panier');
    await expect(page.getByTestId('search-hit-REQ-11')).toBeVisible();
    await capturer(page, 'recherche');
    await page.keyboard.press('Escape');
    await page.goto(`/p/${P}/campaigns/CMP-2`);
    await page.getByTestId('key-TC-10').first().hover();
    await expect(page.getByTestId('key-preview-TC-10')).toBeVisible();
    await capturer(page, 'apercu-cle', page.getByTestId('key-preview-TC-10'), { marge: 40 });
    await page.goto(`/p/${P}/dashboard`);
    await expect(page.getByTestId('dashboard')).toBeVisible();
    await page.keyboard.press('Shift+?');
    await expect(page.getByTestId('shortcuts-help')).toBeVisible();
    await capturer(page, 'raccourcis', page.getByRole('dialog'), { marge: 10 });
    await page.keyboard.press('Escape');
  });

  await test.step('Notifications de qa1 (mention, exécutions affectées) et thème sombre', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/dashboard`);
    await page.getByTestId('notifications').click();
    await expect(page.getByRole('menu')).toBeVisible();
    await capturer(page, 'notifications', page.getByRole('menu'), { marge: 40 });
    await page.keyboard.press('Escape');
    await fermerNotifications(page);
    await page.getByTestId('theme-toggle').click();
    await page.waitForTimeout(500);
    await capturer(page, 'theme-sombre');
    await page.getByTestId('theme-toggle').click();
  });

  await test.step('Un lecteur consulte sans pouvoir modifier', async () => {
    await connexion(page, 'viewer');
    await page.goto(`/p/${P}/tests/TC-2`);
    await expect(page.getByTestId('test-read-only')).toBeVisible();
    await capturer(page, 'lecteur-lecture-seule', page.getByTestId('test-detail'));
  });
});
