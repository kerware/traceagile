import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * Lot 3 (§7) : lier un test depuis la matrice (F-TRA-04), voir la suspicion après modification de
 * l'exigence (§3.3-7), la lever par la revue, consulter couverture (§7.2) et arbre (F-TRA-05).
 * Les données de départ (story et test) sont créées par l'API, avec un suffixe horodaté.
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  expect(response.ok()).toBeTruthy();
  return (await response.json()).accessToken as string;
}

test('Traçabilité : lien depuis la matrice, suspicion, revue, couverture', async ({ page, request }) => {
  const suffixe = Date.now().toString().slice(-6);
  const po = { Authorization: `Bearer ${await jeton(request, 'po')}` };
  const qa = { Authorization: `Bearer ${await jeton(request, 'qa1')}` };

  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers: po })).json();
  const feature = arbre.flatMap((epic: { children: { key: string; type: string }[] }) => epic.children).find((n: { type: string }) => n.type === 'FEATURE');
  const story = await (await request.post('/api/v1/projects/SHOP/requirements', {
    headers: po,
    data: { type: 'USER_STORY', title: `Story tracée ${suffixe}`, parentKey: feature.key, criteria: [{ format: 'TEXT', content: 'Le résultat est tracé' }] },
  })).json();
  const cas = await (await request.post('/api/v1/projects/SHOP/test-cases', {
    headers: qa,
    data: { kind: 'MANUAL', title: `Test tracé ${suffixe}`, steps: [{ action: 'Vérifier', expectedResult: 'OK' }] },
  })).json();
  await request.post(`/api/v1/projects/SHOP/test-cases/${cas.key}/status`, { headers: qa, data: { status: 'READY' } });
  const cellule = `matrix-cell-${story.key}-${cas.key}`;

  await test.step('Le testeur ouvre la matrice de la feature avec tous les tests manuels', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/SHOP/traceability?scope=requirement:${feature.key}&tests=all&kind=MANUAL`);
    await expect(page.getByTestId(`matrix-status-${story.key}`)).toHaveAttribute('data-status', 'NOT_COVERED');
  });

  await test.step('Un clic sur la case vide lie le test à la story (« vérifie »)', async () => {
    await page.getByTestId(cellule).click();
    await expect(page.getByTestId(cellule)).toHaveText('V');
    await expect(page.getByTestId(`matrix-status-${story.key}`)).toHaveAttribute('data-status', 'NOT_RUN');
  });

  await test.step('Le PO modifie le titre de la story : le lien devient suspect', async () => {
    await connexion(page, 'po');
    await page.goto(`/p/SHOP/requirements/${story.key}`);
    await page.getByTestId('field-title').fill(`Story tracée ${suffixe} (précisée)`);
    await page.getByTestId('requirement-save').click();
    await expect(page.getByTestId('requirement-verification')).toHaveAttribute('data-status', 'SUSPECT');
  });

  await test.step('Le testeur revoit le test depuis la matrice : l’alerte disparaît', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/SHOP/traceability?scope=requirement:${feature.key}&tests=all&kind=MANUAL`);
    await page.getByTestId(cellule).click();
    await expect(page.getByTestId('link-suspect')).toBeVisible();
    await page.getByTestId('link-review').click();
    await expect(page.getByTestId(`matrix-status-${story.key}`)).toHaveAttribute('data-status', 'NOT_RUN');
  });

  await test.step('Couverture de la feature et arbre de traçabilité de la story', async () => {
    await page.getByTestId('traceability-tab-coverage').click();
    await expect(page.getByTestId('indicator-design-value')).toContainText('%');
    await expect(page.getByTestId(`coverage-row-${story.key}`)).toContainText('Non exécutée');
    await page.goto(`/p/SHOP/requirements/${story.key}`);
    await page.getByTestId('tab-traceability').click();
    await expect(page.getByTestId('trace-tests')).toContainText(cas.key);
    await expect(page.getByTestId('trace-impact')).toContainText('1 test à revoir');
  });

  await test.step('Export CSV de la matrice (F-TRA-08)', async () => {
    await page.goto(`/p/SHOP/traceability?scope=requirement:${feature.key}`);
    const telechargement = page.waitForEvent('download');
    await page.getByTestId('matrix-export-csv').click();
    expect((await telechargement).suggestedFilename()).toBe('SHOP-matrice.csv');
  });
});
