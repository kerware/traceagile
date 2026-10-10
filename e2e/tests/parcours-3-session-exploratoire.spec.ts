import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * Parcours 3 (§15.3) — critère de fin du lot 6 : le testeur exécute une charte (notes, un BUG converti
 * en anomalie), termine la session (TBS), saisit le débriefing PROOF, que le PO approuve.
 * La charte et sa campagne sont créées par l'API (suffixe horodaté) pour rejouer sur la même base.
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  return (await response.json()).accessToken as string;
}

test('Parcours 3 : session exploratoire, BUG converti en anomalie, débriefing approuvé par le PO', async ({ page, request }) => {
  const suffixe = Date.now().toString().slice(-6);
  const qa = { Authorization: `Bearer ${await jeton(request, 'qa1')}` };
  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers: qa })).json();
  type Noeud = { key: string; type: string; children: Noeud[] };
  const story = (arbre as Noeud[]).flatMap((e) => e.children).flatMap((f) => f.children).find((n) => n.type === 'USER_STORY')!;
  const charte = await (await request.post('/api/v1/projects/SHOP/test-cases', {
    headers: qa,
    data: {
      kind: 'EXPLORATORY', title: `Explorer le filtre prix ${suffixe}`, explore: 'le filtre par prix', with: 'des bornes extrêmes',
      toDiscover: 'les résultats incohérents', timeboxMin: 60, areas: ['Filtres', 'Tri'], heuristics: ['Goldilocks'],
      links: [{ requirementKey: story.key, linkType: 'VERIFIES' }],
    },
  })).json();
  await request.post(`/api/v1/projects/SHOP/test-cases/${charte.key}/status`, { headers: qa, data: { status: 'READY' } });
  const campagne = await (await request.post('/api/v1/projects/SHOP/campaigns', {
    headers: qa, data: { name: `Exploration ${suffixe}`, scopeType: 'REGRESSION' },
  })).json();
  const selection = await (await request.post(`/api/v1/projects/SHOP/campaigns/${campagne.campaign.key}/items/select`, {
    headers: qa, data: { strategy: 'MANUAL', testKeys: [charte.key] },
  })).json();
  await request.patch(`/api/v1/projects/SHOP/campaign-items/${selection.campaign.items[0].id}`, {
    headers: { ...qa, 'Content-Type': 'application/merge-patch+json' }, data: { assignee: 'qa1' },
  });

  await test.step('Dans « Exploratoire », le testeur démarre la session de sa charte', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/exploratory');
    await page.getByTestId(`start-${charte.key}`).click();
    await expect(page.getByTestId('session-mission')).toContainText('Explorer le filtre par prix avec des bornes extrêmes');
    await expect(page.getByTestId('session-state')).toHaveText('En cours');
  });

  await test.step('Il prend des notes horodatées ; Ctrl+4 marque un bogue', async () => {
    await page.getByTestId('note-text').fill('Prix minimum 0 accepté');
    await page.getByTestId('note-add').click();
    await expect(page.getByTestId('note-1')).toContainText('Prix minimum 0 accepté');
    await page.getByTestId('note-text').fill('Un prix maximum négatif affiche tous les produits');
    await page.getByTestId('note-text').press('Control+4');
    await page.getByTestId('note-text').press('Control+Enter');
    await expect(page.getByTestId('note-2')).toContainText('Bogue');
  });

  let anomalie = '';
  await test.step('Le BUG devient une anomalie pré-remplie, liée à la story', async () => {
    await page.getByTestId('note-convert-2').click();
    await expect(page.getByTestId('defect-title')).toHaveValue(new RegExp(`${charte.key} .* : Un prix maximum négatif`));
    await page.getByTestId('defect-submit').click();
    const notification = page.getByText(/Anomalie DEF-\d+ créée/);
    await expect(notification).toBeVisible();
    anomalie = (await notification.textContent())!.match(/DEF-\d+/)![0];
    await expect(page.getByTestId('note-defect-2')).toHaveText(anomalie);
  });

  await test.step('Il termine la session : TBS 60 / 30 / 10, statut « Échoué »', async () => {
    await page.getByTestId('session-finish-open').click();
    await page.getByTestId('tbs-testPct').fill('60');
    await page.getByTestId('tbs-bugPct').fill('30');
    await page.getByTestId('tbs-setupPct').fill('10');
    await expect(page.getByTestId('tbs-total')).toContainText('100 %');
    await page.getByTestId('session-finish-submit').click();
    await expect(page.getByTestId('session-state')).toHaveText('Terminée');
    await expect(page.getByTestId('session-status')).toHaveText('Échoué');
  });

  await test.step('Il saisit le débriefing PROOF', async () => {
    await page.getByTestId('proof-past').fill('Bornes du filtre prix explorées');
    await page.getByTestId('proof-results').fill(`Un bogue : ${anomalie}`);
    await page.getByTestId('proof-outlook').fill('Explorer le tri par prix');
    const trois = await page.getByTestId('proof-feelings').getByRole('radio', { name: '3' }).getAttribute('id');
    await page.locator(`label[for="${trois}"]`).click();
    await page.getByTestId('proof-submit').click();
    await expect(page.getByText('Débriefing enregistré')).toBeVisible();
  });

  await test.step('Le PO approuve le débriefing : la session est « Débriefée »', async () => {
    const url = page.url();
    await connexion(page, 'po');
    await page.goto(url);
    await expect(page.getByTestId('proof-view')).toContainText('Bornes du filtre prix explorées');
    await page.getByTestId('debrief-approve').click();
    await expect(page.getByTestId('session-state')).toHaveText('Débriefée');
    await expect(page.getByTestId('session-approved')).toContainText('po');
  });

  await test.step('L’anomalie figure sur la fiche de la story', async () => {
    await page.goto(`/p/SHOP/requirements/${story.key}`);
    await page.getByTestId('tab-defects').click();
    await expect(page.getByTestId('requirement-defects')).toContainText(anomalie);
  });
});
