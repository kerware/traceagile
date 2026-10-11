import { expect, test } from '@playwright/test';
import { Api, calendrier, capturer, connexion, elements, fermerNotifications, noterEtat, P } from './outils';

/**
 * Guide § 5 et § 6 — sprint 1 « Connexion et catalogue » : release de deux sprints, planification,
 * campagne de recette du sprint (sélection par les exigences du sprint, jeu de données décliné),
 * exécution manuelle pas à pas, run automatisé sur le serveur d'exécution, clôture du sprint et
 * bilan figé.
 */
test('Sprint 1 : planification, recette manuelle et automatisée, clôture', async ({ page, request }) => {
  const po = await Api.de(request, 'po');
  const qa = await Api.de(request, 'qa1');
  const { sprint1, sprint2 } = calendrier();

  await test.step('Le PO crée la release 1.0 et ses deux sprints (API)', async () => {
    const release = await po.post('/releases', { name: 'Swag Labs 1.0', goal: 'Connexion, catalogue et panier (la commande viendra en 1.1)',
      startDate: sprint1.debut, endDate: sprint2.fin });
    expect(release.key).toBe('REL-1');
    await po.post('/sprints', { name: 'Sprint 1 — Connexion et catalogue', goal: 'Se connecter et parcourir le catalogue',
      startDate: sprint1.debut, endDate: sprint1.fin, capacityPoints: 13, releaseKey: 'REL-1' });
    await po.post('/sprints', { name: 'Sprint 2 — Panier', goal: 'Ajouter, visualiser et retirer des produits du panier',
      startDate: sprint2.debut, endDate: sprint2.fin, capacityPoints: 10, releaseKey: 'REL-1' });
  });

  await test.step('Il planifie le sprint 1 depuis l’écran de planification et le démarre', async () => {
    await connexion(page, 'po');
    await page.goto(`/p/${P}/planning?tab=sprint&sprint=SPR-1`);
    await expect(page.getByTestId('sprint-status')).toHaveText('Planifié');
    for (const cle of ['REQ-3', 'REQ-4', 'REQ-6', 'REQ-7', 'REQ-8']) {
      await page.getByTestId(`plan-add-${cle}`).click();
      await expect(page.getByTestId(`sprint-item-${cle}`)).toBeVisible();
    }
    await expect(page.getByTestId('capacity-label')).toContainText('12 / 13');
    await capturer(page, 'planification-sprint-1');
    await page.getByTestId('sprint-start').click();
    await expect(page.getByTestId('sprint-status')).toHaveText('Actif');
  });

  await test.step('Le testeur crée la campagne « Recette sprint 1 »', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/campaigns`);
    await page.getByTestId('campaign-new').click();
    await page.getByTestId('campaign-name').fill('Recette sprint 1');
    // périmètre « Sprint » et sprint actif proposés d'office
    await expect(page.getByTestId('campaign-scope')).toHaveValue('Sprint');
    await expect(page.getByTestId('campaign-target')).toHaveValue(/^SPR-1 —/);
    await page.getByTestId('campaign-environment').fill('recette');
    await page.getByTestId('campaign-build').fill('1.0.0-s1');
    await page.getByTestId('campaign-folder').fill('Release 1.0/Recettes de sprint');
    await capturer(page, 'campagne-creer', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('campaign-submit').click();
    await expect(page.getByTestId('campaign-page')).toBeVisible();
    noterEtat({ campagneSprint1: 'CMP-1' });
  });

  await test.step('Il sélectionne les tests des exigences du sprint : TC-1 est décliné sur les 3 lignes de son jeu', async () => {
    await page.getByTestId('selection-strategy').click();
    await page.getByRole('option', { name: 'Tests des exigences du sprint' }).click();
    await page.getByTestId('selection-submit').click();
    await expect(page.getByTestId('selection-result')).toContainText('tests ajoutés');
    for (const ligne of [1, 2, 3]) await expect(page.getByTestId(`item-TC-1-${ligne}`)).toBeVisible();
    await expect(page.getByTestId('item-TC-7')).toHaveCount(0);
  });

  await test.step('Le test d’API (lié à une ENF transverse) est ajouté à la main ; TC-1 est affecté à qa1', async () => {
    await qa.post('/campaigns/CMP-1/items/select', { strategy: 'MANUAL', testKeys: ['TC-7'] });
    for (const element of await elements(qa, 'CMP-1')) {
      if (element.test.key === 'TC-1') await qa.patch(`/campaign-items/${element.id}`, { assignee: 'qa1' });
    }
    await page.reload();
    await expect(page.getByTestId('item-TC-7')).toBeVisible();
    await fermerNotifications(page);
    await capturer(page, 'campagne-selection', undefined, { pleinePage: true });
  });

  await test.step('qa1 joue la ligne 1 de TC-1 depuis « Mes exécutions » : paramètres remplacés', async () => {
    await page.goto(`/p/${P}/my-executions`);
    await expect(page.getByTestId('my-executions')).toBeVisible();
    await page.getByTestId('run-TC-1').first().click();
    await expect(page.getByTestId('step-action')).toContainText('Ouvrir https://www.saucedemo.com');
    await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('step-action')).toContainText('standard_user');
    await capturer(page, 'execution-pas-a-pas');
    await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('execution-status')).toHaveText('Réussi');
  });

  await test.step('Lignes 2 et 3 du jeu de données (API) : locked_out_user refusé, problem_user accepté', async () => {
    for (const element of await elements(qa, 'CMP-1')) {
      if (element.test.key !== 'TC-1' || element.attempts > 0) continue;
      const execution = await qa.post(`/campaign-items/${element.id}/executions`);
      for (const position of [1, 2]) await qa.put(`/executions/${execution.id}/steps/${position}`, { status: 'PASSED' });
    }
  });

  await test.step('Le développeur lance les tests automatisés sur le simulateur ; résultats en temps réel', async () => {
    await connexion(page, 'dev');
    await page.goto(`/p/${P}/campaigns/CMP-1`);
    await page.getByTestId('launch-open').click();
    // résultats reproductibles : le simulateur, pas le serveur d'exécution réel (ADR-0026)
    await page.getByTestId('launch-server').click();
    await page.getByRole('option', { name: /^Simulateur/ }).click();
    await expect(page.getByTestId('launch-submit')).toContainText('Lancer 5 tests');
    await capturer(page, 'run-lancer', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('launch-submit').click();
    await expect(page.getByTestId('run-page')).toBeVisible();
    await expect(page.getByTestId('run-status')).toHaveAttribute('data-status', 'COMPLETED', { timeout: 90_000 });
    await fermerNotifications(page);
    await capturer(page, 'run-sprint-1');
  });

  await test.step('La campagne du sprint 1 est terminée : 100 % de réussite', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/campaigns/CMP-1`);
    await expect(page.getByTestId('campaign-progress')).toBeVisible();
    await capturer(page, 'campagne-sprint-1-resultats', undefined, { pleinePage: true });
    await page.getByTestId('campaign-complete').click();
    await expect(page.getByTestId('campaign-page')).toContainText('Terminée');
  });

  await test.step('Le PO passe les stories validées à « Terminée » ; REQ-8 depuis l’interface, avec la DoD', async () => {
    for (const cle of ['REQ-3', 'REQ-4', 'REQ-6', 'REQ-7']) {
      await po.post(`/requirements/${cle}/status`, { status: 'DONE', acknowledgeUnmet: true });
    }
    await connexion(page, 'po');
    await page.goto(`/p/${P}/requirements/REQ-8`);
    await expect(page.getByTestId('requirement-verification')).toHaveAttribute('data-status', 'VALIDATED');
    await page.getByTestId('status-menu').click();
    await page.getByTestId('status-option-DONE').click();
    const dialogue = page.getByRole('dialog');
    await expect(dialogue.getByTestId('status-confirm')).toBeVisible();
    await capturer(page, 'exigence-dod', dialogue, { marge: 10 });
    if (await dialogue.getByTestId('status-acknowledge').count()) await dialogue.getByTestId('status-acknowledge').check();
    await dialogue.getByTestId('status-confirm').click();
    await expect(page.getByTestId('status-menu')).toContainText('Terminée');
  });

  await test.step('Le PO clôt le sprint 1 : toutes les stories sont terminées ; le bilan est figé', async () => {
    await page.goto(`/p/${P}/planning?tab=sprint&sprint=SPR-1`);
    await page.getByTestId('sprint-close').click();
    await expect(page.getByTestId('close-sprint-submit')).toBeVisible();
    await capturer(page, 'sprint-cloture', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('close-sprint-submit').click();
    await expect(page.getByTestId('sprint-status')).toHaveText('Clos');
    const rapports = (await po.get('/reports')) as { key: string; frozen: boolean }[];
    expect(rapports.find((r) => r.frozen)?.key).toBe('RPT-1');
  });
});
