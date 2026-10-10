import { expect, test } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * Lot 9 (§4.4, §13.1, §13.3, ADR-0024) : le PO anime un atelier Example Mapping sur une nouvelle story ;
 * la question ouverte bloque « Prête » jusqu'à sa résolution ; la recherche Ctrl+K retrouve la story ;
 * l'aide des raccourcis s'ouvre avec « ? ». Story créée par l'API (suffixe horodaté).
 */
test('Atelier Example Mapping, question bloquante, recherche Ctrl+K et raccourcis', async ({ page, request }) => {
  test.setTimeout(120_000);
  const suffixe = Date.now().toString().slice(-6);
  const login = await request.post('/api/v1/auth/login', { data: { login: 'po', password: MOT_DE_PASSE_DEMO } });
  const headers = { Authorization: `Bearer ${(await login.json()).accessToken as string}` };
  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers })).json();
  const feature = arbre.flatMap((e: { children: { key: string; type: string }[] }) => e.children).find((n: { type: string }) => n.type === 'FEATURE');
  const story = await (await request.post('/api/v1/projects/SHOP/requirements', {
    headers,
    data: { type: 'USER_STORY', title: `Retirer en magasin ${suffixe}`, parentKey: feature.key, storyPoints: 3, asA: 'client', iWant: 'retirer ma commande en magasin',
      criteria: [{ format: 'TEXT', content: 'Le magasin est choisi à la commande' }] },
  })).json();

  await test.step('Le PO ouvre l’atelier et pose règle, exemples et question', async () => {
    await connexion(page, 'po');
    await page.goto(`/p/SHOP/requirements/${story.key}`);
    await page.getByTestId('tab-example-mapping').click();
    await expect(page.getByTestId('em-story')).toContainText(`Retirer en magasin ${suffixe}`);
    await page.getByTestId('em-add-rule').fill('Retrait gratuit dès le lendemain 10 h');
    await page.getByTestId('em-add-rule').press('Enter');
    await page.getByTestId('em-add-example-1').fill('Commande passée lundi 18 h : retrait mardi 10 h');
    await page.getByTestId('em-add-example-1').press('Enter');
    await page.getByTestId('em-add-question').fill('Et le dimanche ?');
    await page.getByTestId('em-add-question').press('Enter');
    await expect(page.getByTestId('open-questions')).toContainText('1 question ouverte');
  });

  await test.step('L’exemple devient un critère Gherkin à compléter', async () => {
    await page.getByTestId('em-card-Commande passée lundi 18 h : retrait mardi 10 h').getByTestId('em-card-menu').click();
    await page.getByTestId('em-convert').click();
    await expect(page.getByText('Critère 2 créé (Gherkin à compléter)')).toBeVisible();
    await page.getByTestId('tab-criteria').click();
    await expect(page.getByText('Scénario: Commande passée lundi 18 h : retrait mardi 10 h')).toBeVisible();
  });

  await test.step('La question ouverte bloque « Prête » ; résolue, elle ne bloque plus', async () => {
    const pret = await request.post(`/api/v1/projects/SHOP/requirements/${story.key}/status`, { headers, data: { status: 'READY' } });
    expect(pret.status()).toBe(422);
    expect(JSON.stringify(await pret.json())).toContain('question(s) ouverte(s)');
    await page.getByTestId('tab-example-mapping').click();
    await page.getByTestId('em-question-Et le dimanche ?').getByTestId('em-resolve').click();
    await expect(page.getByTestId('open-questions')).toHaveCount(0);
  });

  await test.step('Ctrl+K retrouve la story ; Entrée ouvre sa fiche ; « ? » affiche l’aide', async () => {
    await page.goto('/p/SHOP/dashboard');
    await expect(page.getByTestId('dashboard')).toBeVisible();
    await page.keyboard.press('ControlOrMeta+k');
    await page.getByTestId('search-input').fill(`magasin ${suffixe}`);
    await expect(page.getByTestId(`search-hit-${story.key}`)).toBeVisible();
    await page.keyboard.press('Enter');
    await expect(page).toHaveURL(new RegExp(`/requirements/${story.key}$`));
    await page.locator('body').click({ position: { x: 5, y: 300 } });
    await page.keyboard.press('Shift+?');
    await expect(page.getByTestId('shortcuts-help')).toContainText('Pas courant en échec');
  });
});
