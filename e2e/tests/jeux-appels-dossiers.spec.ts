import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * ADR-0018 — un test qui appelle un cas de test réutilisable est décliné sur les lignes de son jeu de
 * données dans une campagne rangée en dossier ; à l'exécution, les pas de l'appelé sont déroulés avec
 * les valeurs de la ligne ; la fiche test montre l'exécution. Données créées par l'API (suffixe horodaté).
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  return (await response.json()).accessToken as string;
}

test('Jeu de données en campagne, appel de cas de test, dossiers de campagnes', async ({ page, request }) => {
  const suffixe = Date.now().toString().slice(-6);
  const dossier = `E2E ${suffixe}`;
  const qa = { Authorization: `Bearer ${await jeton(request, 'qa1')}` };
  const appele = await (await request.post('/api/v1/projects/SHOP/test-cases', {
    headers: qa,
    data: {
      kind: 'MANUAL', title: `Se connecter ${suffixe}`,
      steps: [{ action: 'Saisir ${login}', expectedResult: 'Connecté en tant que ${login}' }],
      parameters: [{ name: 'login', defaultValue: 'invité' }],
    },
  })).json();
  const appelant = await (await request.post('/api/v1/projects/SHOP/test-cases', {
    headers: qa,
    data: {
      kind: 'MANUAL', title: `Commander ${suffixe}`, estimatedDurationMin: 5,
      steps: [{ calledTestKey: appele.key, callParameters: { login: '${client}' } }, { action: 'Payer', expectedResult: 'Paiement accepté' }],
      parameters: [{ name: 'client', defaultValue: 'alice' }],
      dataSets: [{ name: 'Clients', rows: [{ client: 'bob' }, { client: 'carol' }] }],
    },
  })).json();
  expect(appelant.steps[0].calledTest.key).toBe(appele.key);
  await request.post(`/api/v1/projects/SHOP/test-cases/${appelant.key}/status`, { headers: qa, data: { status: 'READY' } });

  await test.step('Le testeur crée une campagne dans un nouveau dossier', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/campaigns');
    await page.getByTestId('campaign-new').click();
    await page.getByTestId('campaign-name').fill(`Commandes ${suffixe}`);
    await page.getByTestId('campaign-scope').click();
    await page.getByRole('option', { name: 'Régression' }).click();
    await page.getByTestId('campaign-folder').fill(`${dossier}/Paiement`);
    await page.getByTestId('campaign-submit').click();
    await expect(page.getByTestId('campaign-folder-path')).toHaveText(`${dossier} › Paiement`);
  });

  await test.step('Il sélectionne le test : il est décliné d’office sur les deux lignes du jeu « Clients » (ADR-0022)', async () => {
    await page.getByTestId('selection-strategy').click();
    await page.getByRole('option', { name: 'Sélection manuelle' }).click();
    await page.getByTestId('selection-tests').fill(appelant.key);
    await page.getByRole('option', { name: new RegExp(`^${appelant.key} —`) }).click();
    await page.getByTestId('selection-submit').click();
    await expect(page.getByTestId(`item-${appelant.key}-1`)).toBeVisible();
    await expect(page.getByTestId(`item-${appelant.key}-2`)).toBeVisible();
  });

  await test.step('La ligne « carol » s’exécute : pas de l’appelé déroulés avec client = carol', async () => {
    await page.getByTestId(`execute-${appelant.key}-2`).click();
    await expect(page.getByTestId('step-action')).toHaveText('Saisir carol');
    await expect(page.getByTestId('step-called-from')).toContainText(appele.key);
    await expect(page.getByTestId('step-nav-2')).toContainText('Payer');
  });

  await test.step('La fiche du test montre l’exécution ; l’appelé liste son appelant', async () => {
    await page.goto(`/p/SHOP/tests/${appelant.key}`);
    await page.getByTestId('test-tab-executions').click();
    await expect(page.getByTestId('test-executions')).toContainText('Clients › carol');
    await page.goto(`/p/SHOP/tests/${appele.key}`);
    await expect(page.getByTestId('test-called-by')).toContainText(appelant.key);
  });

  await test.step('L’arbre des campagnes filtre sur le dossier', async () => {
    await page.goto('/p/SHOP/campaigns');
    await page.getByTestId(`campaign-folder-select-${dossier}`).click();
    await expect(page.getByTestId('campaign-list').locator('tbody tr')).toHaveCount(1);
    await expect(page.getByTestId('campaign-list')).toContainText(`Commandes ${suffixe}`);
  });
});
