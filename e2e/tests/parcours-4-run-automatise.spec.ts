import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * Parcours 4 (§15.3) — critère de fin du lot 7 : le développeur lance un run automatisé sur le
 * simulateur ; les résultats arrivent en temps réel ; un test « @fail » échoue et rend l'exigence
 * rouge dans la matrice ; ses artefacts (copie d'écran, traces, JUnit, Jest) sont consultables
 * (ADR-0021). Le simulateur est appairé par un jeton qu'il a lui-même émis (ADR-0020).
 * Story, tests et campagne sont créés par l'API (suffixe horodaté).
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  expect(response.ok()).toBeTruthy();
  return (await response.json()).accessToken as string;
}

test('Parcours 4 : run automatisé sur le simulateur, résultats en temps réel, exigence rouge', async ({ page, request }) => {
  test.setTimeout(120_000);
  const suffixe = Date.now().toString().slice(-6);
  const po = { Authorization: `Bearer ${await jeton(request, 'po')}` };
  const qa = { Authorization: `Bearer ${await jeton(request, 'qa1')}` };
  const dev = { Authorization: `Bearer ${await jeton(request, 'dev')}` };

  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers: po })).json();
  const feature = arbre.flatMap((epic: { children: { key: string; type: string }[] }) => epic.children).find((n: { type: string }) => n.type === 'FEATURE');
  const story = await (await request.post('/api/v1/projects/SHOP/requirements', {
    headers: po,
    data: { type: 'USER_STORY', title: `Story automatisée ${suffixe}`, parentKey: feature.key, criteria: [{ format: 'TEXT', content: 'Le total est juste' }] },
  })).json();
  const tests: { key: string }[] = [];
  for (const identifiant of [`CartApiTest#total @fail ${suffixe}`, `CartApiTest#ajout ${suffixe}`]) {
    const cas = await (await request.post('/api/v1/projects/SHOP/test-cases', {
      headers: dev,
      data: {
        kind: 'AUTOMATED', title: `API panier ${identifiant}`, technique: 'API', repositoryUrl: 'https://git.example.com/shop/tests.git',
        branch: 'main', path: 'src/test/java', testIdentifier: identifiant, links: [{ requirementKey: story.key, linkType: 'VERIFIES' }],
      },
    })).json();
    await request.post(`/api/v1/projects/SHOP/test-cases/${cas.key}/status`, { headers: qa, data: { status: 'READY' } });
    tests.push(cas);
  }
  const [echec] = tests;
  const campagne = await (await request.post('/api/v1/projects/SHOP/campaigns', {
    headers: qa, data: { name: `Run automatisé ${suffixe}`, scopeType: 'REGRESSION', environment: 'recette', buildVersion: '2.1.0' },
  })).json();
  await request.post(`/api/v1/projects/SHOP/campaigns/${campagne.campaign.key}/items/select`, {
    headers: qa, data: { strategy: 'MANUAL', testKeys: tests.map((t) => t.key) },
  });

  await test.step('Le simulateur est appairé (jeton émis par le serveur) et en ligne', async () => {
    await expect.poll(async () => {
      const serveurs = await (await request.get('/api/v1/projects/SHOP/execution-servers', { headers: dev })).json();
      return serveurs.some((s: { name: string; usable: boolean; status: string }) => s.name === 'Simulateur' && s.usable && s.status === 'ONLINE');
    }, { timeout: 60_000, intervals: [2_000] }).toBe(true);
  });

  await test.step('Le développeur lance les deux tests sur le simulateur', async () => {
    await connexion(page, 'dev');
    await page.goto(`/p/SHOP/campaigns/${campagne.campaign.key}`);
    await page.getByTestId('launch-open').click();
    await expect(page.getByTestId('launch-submit')).toHaveText('Lancer 2 tests');
    // deux serveurs déclarés (simulateur et serveur réel, ADR-0026) : le simulateur est choisi
    await page.getByTestId('launch-server').click();
    await page.getByRole('option', { name: /^Simulateur/ }).click();
    await expect(page.getByTestId('launch-server')).toHaveValue(/Simulateur/);
    await page.getByTestId('launch-submit').click();
    await expect(page.getByTestId('run-page')).toBeVisible();
  });

  await test.step('Les résultats arrivent en temps réel ; le test @fail échoue', async () => {
    await expect(page.getByTestId('run-status')).toHaveAttribute('data-status', 'COMPLETED', { timeout: 45_000 });
    await expect(page.getByTestId(`run-status-${echec!.key}`)).toHaveAttribute('data-status', 'FAILED');
    await expect(page.getByTestId(`run-message-${echec!.key}`)).toContainText('AssertionError');
    await page.getByTestId('run-logs-load').click();
    await expect(page.getByTestId('run-logs')).toContainText(echec!.key);
  });

  await test.step('Artefacts (ADR-0021) : copie d’écran de l’échec, traces système, JUnit XML et Jest JSON', async () => {
    const capture = `screenshot-${echec!.key}.png`;
    for (const nom of [capture, 'system.log', 'junit.xml', 'jest.json']) {
      await expect(page.getByTestId(`run-artifact-${nom}`)).toBeVisible();
    }
    await page.getByTestId(`run-screenshot-${echec!.key}`).click();
    await expect(page.getByTestId('screenshot-image')).toBeVisible();
    await expect.poll(() => page.getByTestId('screenshot-image').evaluate((img: HTMLImageElement) => img.naturalWidth)).toBeGreaterThan(0);
    await page.keyboard.press('Escape');
    const telechargement = page.waitForEvent('download');
    await page.getByTestId('run-artifact-download-junit.xml').click();
    expect((await telechargement).suggestedFilename()).toBe('junit.xml');
  });

  await test.step('L’exigence est rouge dans la matrice de traçabilité', async () => {
    await page.goto(`/p/SHOP/traceability?scope=requirement:${feature.key}&tests=all&kind=AUTOMATED`);
    await expect(page.getByTestId(`matrix-status-${story.key}`)).toHaveAttribute('data-status', 'FAILED');
  });
});
