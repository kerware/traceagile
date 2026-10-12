import { expect, test } from '@playwright/test';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { Api, capturer, connexion, elements, fermerNotifications, IMAGES, P, RACINE_SAUCEDEMO, SERVEUR, sqlDemo } from './outils';

/**
 * Guide § 7 à § 10 — sprint 2 « Panier » (sprint actif) : exécution manuelle en échec et anomalie
 * créée depuis le pas avec la capture du défaut, test qui en appelle un autre (TC-13 déroule TC-1),
 * session exploratoire (notes, bogue converti en
 * anomalie, TBS, débriefing PROOF approuvé par le PO), run automatisé avec un échec et ses
 * artefacts, mesure de l'ENF de performance, import du rapport JUnit réel de saucedemo/app-tests.
 */
const JUNIT = join(RACINE_SAUCEDEMO, 'results', 'junit-saucedemo.xml');

/**
 * Horaires « mockés » de la session de TC-12 (le scénario la joue en quelques secondes) : début à 15 h
 * (heure de Paris, jour de la génération), notes réparties sur l'heure, 55 min actives pour 60 prévues,
 * débriefing à 16 h 10 et approbation à 16 h 25.
 */
const SESSION_TC12 = `with s as (
    select x.id, x.execution_id from exploratory_sessions x join executions e on e.id = x.execution_id
    join test_cases t on t.id = e.test_case_id join projects p on p.id = t.project_id
    where p.project_key = '${P}' and t.test_key = 'TC-12'),
  base as (select (current_date + time '15:00') at time zone 'Europe/Paris' as t0)`;
const DECALAGES_NOTES = [252, 760, 1590, 2280, 3060]; // 04:12, 12:40, 26:30, 38:00, 51:00
const DUREE_ACTIVE = 55 * 60;

test('Sprint 2 : échec manuel, session exploratoire, run automatisé, import JUnit', async ({ page, request }) => {
  expect(existsSync(JUNIT), 'lancer d’abord les tests de saucedemo : npm test (ou npm run tout)').toBeTruthy();
  const po = await Api.de(request, 'po');
  const qa = await Api.de(request, 'qa1');

  await test.step('Le PO planifie et démarre le sprint 2 ; la feuille de route montre les deux sprints', async () => {
    await po.put('/sprints/SPR-2/scope', { requirementKeys: ['REQ-10', 'REQ-11', 'REQ-12'] });
    await po.post('/sprints/SPR-2/start');
    await connexion(page, 'po');
    await page.goto(`/p/${P}/planning`);
    await expect(page.getByTestId('sprint-block-SPR-2')).toBeVisible();
    await capturer(page, 'planification-feuille-de-route', page.getByTestId('release-REL-1'), { marge: 10 });
  });

  await test.step('Le testeur prépare la campagne « Recette sprint 2 » (API) et répartit le travail', async () => {
    const campagne = await qa.post('/campaigns', { name: 'Recette sprint 2', scopeType: 'SPRINT', sprintKey: 'SPR-2', environment: 'recette',
      buildVersion: '1.0.0-s2', folder: 'Release 1.0/Recettes de sprint' });
    expect(campagne.campaign.key).toBe('CMP-2');
    await qa.post('/campaigns/CMP-2/items/select', { strategy: 'SPRINT_REQUIREMENTS' });
    await qa.post('/campaigns/CMP-2/items/select', { strategy: 'MANUAL', testKeys: ['TC-11'] });
    for (const element of await elements(qa, 'CMP-2')) {
      if (element.test.key === 'TC-2') await qa.patch(`/campaign-items/${element.id}`, { assignee: 'qa2' });
      if (element.test.key === 'TC-12' || element.test.key === 'TC-13') await qa.patch(`/campaign-items/${element.id}`, { assignee: 'qa1' });
    }
  });

  await test.step('qa2 exécute TC-2 avec problem_user : connexion de TC-1, puis le pas 5 échoue, la capture est jointe au pas', async () => {
    await connexion(page, 'qa2');
    await page.goto(`/p/${P}/my-executions`);
    await capturer(page, 'mes-executions');
    await page.getByTestId('run-TC-2').click();
    // pas 1 et 2 : ceux de TC-1, joués avec son jeu « Comptes › problem_user »
    await expect(page.getByTestId('step-called-from')).toContainText('TC-1');
    await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('step-action')).toContainText('problem_user');
    for (let pas = 2; pas <= 4; pas++) await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('step-action')).toContainText('Remove');
    await page.getByTestId('step-actual').fill('Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.');
    const selecteur = page.waitForEvent('filechooser');
    await page.getByTestId('step-attachments-add').click();
    await (await selecteur).setFiles(join(IMAGES, 'sd-defaut-problem-user.png'));
    await expect(page.getByTestId('attachment-sd-defaut-problem-user.png')).toBeVisible();
    await page.getByTestId('step-FAILED').click();
    await expect(page.getByTestId('execution-status')).toHaveText('Échoué');
    await page.getByTestId('step-nav-5').click();
    await capturer(page, 'execution-echec');
  });

  await test.step('Elle crée l’anomalie depuis le pas en échec : description pré-remplie, capture reprise', async () => {
    await page.getByTestId('create-defect').click();
    await expect(page.getByTestId('defect-description')).toHaveValue(/Obtenu/);
    await page.getByTestId('defect-title').fill('problem_user : « Remove » sur le catalogue ne retire pas le produit');
    await page.getByTestId('defect-severity').click();
    await page.getByRole('option', { name: 'Majeure' }).click();
    await capturer(page, 'anomalie-depuis-pas', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('defect-submit').click();
    await expect(page.getByText('Anomalie DEF-1 créée')).toBeVisible();
    await expect(page.getByTestId('linked-defect-DEF-1')).toBeVisible();
  });

  await test.step('qa1 joue TC-13 : les pas de TC-1 sont déroulés avec standard_user, puis ceux du panier', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/my-executions`);
    await page.getByTestId('run-TC-13').first().click();
    await expect(page.getByTestId('step-called-from')).toContainText('TC-1');
    await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('step-action')).toContainText('standard_user');
    await capturer(page, 'execution-appel');
    for (let pas = 2; pas <= 4; pas++) await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('execution-status')).toHaveText('Réussi');
    // ligne 2 du jeu « Produits » (API)
    for (const element of await elements(qa, 'CMP-2')) {
      if (element.test.key !== 'TC-13' || element.attempts > 0) continue;
      const execution = await qa.post(`/campaign-items/${element.id}/executions`);
      for (const position of [1, 2, 3, 4]) await qa.put(`/executions/${execution.id}/steps/${position}`, { status: 'PASSED' });
    }
  });

  await test.step('qa1 démarre la session exploratoire de la charte « Explorer le panier »', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/exploratory`);
    await expect(page.getByTestId('start-TC-12')).toBeVisible();
    await capturer(page, 'exploratoire-chartes');
    await page.getByTestId('start-TC-12').click();
    await expect(page.getByTestId('session-state')).toHaveText('En cours');
  });

  await test.step('Elle prend des notes horodatées ; Ctrl+2 question, Ctrl+4 bogue, Ctrl+5 idée', async () => {
    const noter = async (texte: string, raccourci?: string) => {
      await page.getByTestId('note-text').fill(texte);
      if (raccourci) await page.getByTestId('note-text').press(raccourci);
      await page.getByTestId('note-text').press('Control+Enter');
      await expect(page.getByTestId('session-notes')).toContainText(texte);
      // sans captures, la note suivante serait saisie avant que l'ajout ne vide le champ
      await expect(page.getByTestId('note-text')).toHaveValue('');
    };
    await noter('standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue');
    await noter('Retour arrière du navigateur depuis le panier : badge et boutons conservés');
    await noter('problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt', 'Control+4');
    await noter('Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)', 'Control+2');
    await noter('Afficher le total du panier avant le checkout', 'Control+5');
    // horaires de démonstration : notes étalées sur l'heure, chronomètre à 55 min moins 10 s (la session continue)
    sqlDemo(`${SESSION_TC12},
      decalages as (select n.id, (array[${DECALAGES_NOTES.join(', ')}])[row_number() over (order by n.noted_at, n.created_at)] as d
        from session_notes n join s on n.session_id = s.id)
      update session_notes n set offset_seconds = d.d, noted_at = base.t0 + make_interval(secs => d.d) from decalages d, base where n.id = d.id;
      ${SESSION_TC12} update executions e set started_at = base.t0 from s, base where e.id = s.execution_id;
      ${SESSION_TC12} update exploratory_sessions x set active_seconds = ${DUREE_ACTIVE - 10}, resumed_at = now() from s where x.id = s.id;`);
    await page.reload();
    await expect(page.getByTestId('session-notes')).toContainText('51:00');
    await capturer(page, 'session-notes');
  });

  await test.step('Le bogue devient l’anomalie DEF-2, liée à la charte et aux stories', async () => {
    await page.getByTestId('note-convert-3').click();
    await expect(page.getByTestId('defect-title')).toHaveValue(/TC-12/);
    await page.getByTestId('defect-submit').click();
    await expect(page.getByText('Anomalie DEF-2 créée')).toBeVisible();
    await expect(page.getByTestId('note-defect-3')).toHaveText('DEF-2');
    await fermerNotifications(page);
  });

  await test.step('Elle termine la session : TBS 60 / 25 / 15 ; statut déduit « Échoué »', async () => {
    await page.getByTestId('session-finish-open').click();
    await page.getByTestId('tbs-testPct').fill('60');
    await page.getByTestId('tbs-bugPct').fill('25');
    await page.getByTestId('tbs-setupPct').fill('15');
    await expect(page.getByTestId('tbs-total')).toContainText('100 %');
    await capturer(page, 'session-tbs', page.getByTestId('session-finish'), { marge: 10 });
    await page.getByTestId('session-finish-submit').click();
    await expect(page.getByTestId('session-state')).toHaveText('Terminée');
    // fin de démonstration : 55 min actives, session terminée à 15 h 55
    sqlDemo(`${SESSION_TC12} update exploratory_sessions x set active_seconds = ${DUREE_ACTIVE}, resumed_at = null from s where x.id = s.id;
      ${SESSION_TC12} update executions e set ended_at = base.t0 + interval '55 minutes', duration_ms = ${DUREE_ACTIVE * 1000}
        from s, base where e.id = s.execution_id;`);
    await page.reload();
  });

  await test.step('Débriefing PROOF ; le PO l’approuve', async () => {
    await page.getByTestId('proof-past').fill('Ajouts, retraits et navigation arrière avec standard_user et problem_user.');
    await page.getByTestId('proof-results').fill('DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.');
    await page.getByTestId('proof-obstacles').fill('Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.');
    await page.getByTestId('proof-outlook').fill('Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.');
    const quatre = await page.getByTestId('proof-feelings').getByRole('radio', { name: '4' }).getAttribute('id');
    await page.locator(`label[for="${quatre}"]`).click();
    await page.getByTestId('proof-submit').click();
    await expect(page.getByText('Débriefing enregistré')).toBeVisible();
    const url = page.url();
    await connexion(page, 'po');
    await page.goto(url);
    await page.getByTestId('debrief-approve').click();
    await expect(page.getByTestId('session-state')).toHaveText('Débriefée');
    sqlDemo(`${SESSION_TC12} update exploratory_sessions x set debriefed_at = base.t0 + interval '70 minutes',
      approved_at = base.t0 + interval '85 minutes' from s, base where x.id = s.id;`);
    await page.reload();
    await expect(page.getByTestId('session-state')).toHaveText('Débriefée');
    await capturer(page, 'session-debriefee', undefined, { pleinePage: true });
  });

  await test.step('Le développeur lance les tests automatisés du sprint : TC-10 échoue (défaut de problem_user)', async () => {
    await connexion(page, 'dev');
    await page.goto(`/p/${P}/campaigns/CMP-2`);
    await page.getByTestId('launch-open').click();
    // ADR-0026 exécution réelle des tests Playwright de saucedemo par le serveur d'exécution
    await page.getByTestId('launch-server').click();
    await page.getByRole('option', { name: new RegExp(`^${SERVEUR}`) }).click();
    await expect(page.getByTestId('launch-submit')).toContainText('Lancer 4 tests');
    await page.getByTestId('launch-submit').click();
    await expect(page.getByTestId('run-page')).toBeVisible();
    await expect(page.getByTestId('run-status')).toHaveAttribute('data-status', 'COMPLETED', { timeout: 600_000 });
    await expect(page.getByTestId('run-status-TC-10')).toHaveAttribute('data-status', 'FAILED');
    await page.getByTestId('run-logs-load').click();
    await expect(page.getByTestId('run-logs')).toContainText('TC-10');
    await fermerNotifications(page);
    await capturer(page, 'run-sprint-2-echec', undefined, { pleinePage: true });
    await capturer(page, 'run-artefacts', page.getByTestId('run-artifacts'), { marge: 8 });
    await page.getByTestId('run-screenshot-TC-10').click();
    await expect.poll(() => page.getByTestId('screenshot-image').evaluate((img: HTMLImageElement) => img.naturalWidth)).toBeGreaterThan(0);
    await capturer(page, 'run-copie-ecran-echec', page.getByRole('dialog'), { marge: 10 });
    await page.keyboard.press('Escape');
  });

  await test.step('Le test de performance alimente la valeur mesurée de l’ENF « Temps de chargement du catalogue »', async () => {
    await page.goto(`/p/${P}/requirements/REQ-16`);
    await expect(page.getByTestId('measurements')).toContainText('ms');
    await capturer(page, 'enf-mesures', page.getByTestId('measurements'), { marge: 10 });
  });

  await test.step('La chaîne d’intégration continue : import du rapport JUnit réel de Playwright', async () => {
    const ci = await qa.post('/campaigns', { name: 'Intégration continue — main', scopeType: 'RELEASE', releaseKey: 'REL-1', environment: 'ci',
      buildVersion: 'main', folder: 'Release 1.0/Intégration continue' });
    expect(ci.campaign.key).toBe('CMP-3');
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/campaigns/CMP-3`);
    await page.getByTestId('import-open').click();
    await page.getByTestId('import-file').setInputFiles(JUNIT);
    await expect(page.getByTestId('import-summary')).toContainText('9');
    await expect(page.getByTestId('import-lines')).toContainText('TC-10');
    await capturer(page, 'import-junit-apercu', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('import-submit').click();
    await expect(page.getByTestId('item-TC-10')).toBeVisible();
    await fermerNotifications(page);
    await capturer(page, 'campagne-integration-continue', undefined, { pleinePage: true });
  });

  await test.step('La campagne du sprint 2', async () => {
    await page.goto(`/p/${P}/campaigns/CMP-2`);
    await expect(page.getByTestId('campaign-page')).toBeVisible();
    await capturer(page, 'campagne-sprint-2', undefined, { pleinePage: true });
    await page.goto(`/p/${P}/campaigns`);
    await expect(page.getByTestId('campaign-folder-tree')).toBeVisible();
    await capturer(page, 'campagnes-liste');
  });
});
