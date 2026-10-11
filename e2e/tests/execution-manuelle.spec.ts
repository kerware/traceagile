import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * Lot 5 — critère de fin : un test manuel exécuté en échec crée une anomalie liée (F-CMP-01,
 * F-CMP-02, F-CMP-04, F-EXE-01 à F-EXE-03). Le test de départ est créé par l'API (suffixe horodaté).
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  return (await response.json()).accessToken as string;
}

test('Exécution manuelle : un échec crée une anomalie liée au test et à l’exigence', async ({ page, request }) => {
  const suffixe = Date.now().toString().slice(-6);
  const qa = { Authorization: `Bearer ${await jeton(request, 'qa1')}` };
  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers: qa })).json();
  type Noeud = { key: string; type: string; children: Noeud[] };
  const story = (arbre as Noeud[]).flatMap((e) => e.children).flatMap((f) => f.children).find((n) => n.type === 'USER_STORY')!;
  const cas = await (await request.post('/api/v1/projects/SHOP/test-cases', {
    headers: qa,
    data: {
      kind: 'MANUAL', title: `Paiement refusé ${suffixe}`, estimatedDurationMin: 5,
      steps: [{ action: 'Payer avec la carte ${carte}', expectedResult: 'Le paiement est refusé' }, { action: 'Lire le message', expectedResult: 'Le message explique le refus' }],
      parameters: [{ name: 'carte', defaultValue: '4000 0000 0000 0002' }],
      links: [{ requirementKey: story.key, linkType: 'VERIFIES' }],
    },
  })).json();
  await request.post(`/api/v1/projects/SHOP/test-cases/${cas.key}/status`, { headers: qa, data: { status: 'READY' } });

  await test.step('Le testeur crée une campagne de régression (recette, build 2.0.1)', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/campaigns');
    await page.getByTestId('campaign-new').click();
    await page.getByTestId('campaign-name').fill(`Régression paiement ${suffixe}`);
    await page.getByTestId('campaign-scope').click();
    await page.getByRole('option', { name: 'Régression' }).click();
    await page.getByTestId('campaign-build').fill('2.0.1');
    await page.getByTestId('campaign-submit').click();
    await expect(page.getByTestId('campaign-page')).toBeVisible();
  });

  await test.step('Il sélectionne le test et se l’affecte', async () => {
    await page.getByTestId('selection-strategy').click();
    await page.getByRole('option', { name: 'Sélection manuelle' }).click();
    await page.getByTestId('selection-tests').fill(cas.key);
    await page.getByRole('option', { name: new RegExp(`^${cas.key} —`) }).click();
    await page.getByTestId('selection-submit').click();
    await expect(page.getByTestId('selection-result')).toContainText('1 test ajouté');
    await page.getByTestId(`assignee-${cas.key}`).click();
    // attendre l'enregistrement : la navigation suivante annulerait la requête en cours
    const affectation = page.waitForResponse((r) => r.url().includes('/campaign-items/') && r.request().method() === 'PATCH');
    await page.getByRole('option', { name: /Quentin/ }).click();
    expect((await affectation).status()).toBe(200);
    await expect(page.getByTestId('workload-qa1')).toContainText('5 min');
  });

  await test.step('Dans « Mes exécutions », il lance le test : le paramètre ${carte} est remplacé', async () => {
    await page.goto('/p/SHOP/my-executions');
    await page.getByTestId(`run-${cas.key}`).click();
    await expect(page.getByTestId('step-action')).toHaveText('Payer avec la carte 4000 0000 0000 0002');
  });

  await test.step('Le pas 1 réussit, le pas 2 échoue avec le résultat obtenu', async () => {
    await page.getByTestId('step-PASSED').click();
    await expect(page.getByTestId('step-action')).toHaveText('Lire le message');
    await page.getByTestId('step-actual').fill('Message « Erreur 500 »');
    await page.getByTestId('step-FAILED').click();
    await expect(page.getByTestId('execution-status')).toHaveText('Échoué');
  });

  let anomalie = '';
  await test.step('Il crée l’anomalie pré-remplie depuis le pas en échec (F-EXE-03)', async () => {
    await page.getByTestId('create-defect').click();
    await expect(page.getByTestId('defect-description')).toHaveValue(/\*\*Obtenu\*\* : Message « Erreur 500 »/);
    await page.getByTestId('defect-submit').click();
    const notification = page.getByText(/Anomalie DEF-\d+ créée/);
    await expect(notification).toBeVisible();
    anomalie = (await notification.textContent())!.match(/DEF-\d+/)![0];
    await expect(page.getByTestId(`linked-defect-${anomalie}`)).toBeVisible();
  });

  await test.step('L’anomalie apparaît sur la fiche de l’exigence, qui est « En échec »', async () => {
    await page.goto(`/p/SHOP/requirements/${story.key}`);
    await expect(page.getByTestId('requirement-verification')).toHaveAttribute('data-status', 'FAILED');
    await page.getByTestId('tab-defects').click();
    await expect(page.getByTestId('requirement-defects')).toContainText(anomalie);
  });
});
