import { expect, test, type APIRequestContext } from '@playwright/test';
import { connexion, glisser, MOT_DE_PASSE_DEMO } from './support';

/**
 * Lot 4 — critère de fin : une release de 3 sprints créée et planifiée depuis l'interface
 * (F-PLN-01, F-PLN-02, F-PLN-05). Deux stories prêtes sont créées par l'API, avec un suffixe.
 */
async function jeton(request: APIRequestContext, login: string): Promise<string> {
  const response = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE_DEMO } });
  return (await response.json()).accessToken as string;
}

test('Planification : release de 3 sprints créée, générée et planifiée par glisser-déposer', async ({ page, request }) => {
  const suffixe = Date.now().toString().slice(-6);
  const nom = `Version ${suffixe}`;
  const po = { Authorization: `Bearer ${await jeton(request, 'po')}` };
  const arbre = await (await request.get('/api/v1/projects/SHOP/requirements/tree', { headers: po })).json();
  const feature = arbre.flatMap((e: { children: { key: string; type: string }[] }) => e.children).find((n: { type: string }) => n.type === 'FEATURE');
  const stories: string[] = [];
  for (const [titre, points] of [[`Story planifiée A ${suffixe}`, 8], [`Story planifiée B ${suffixe}`, 13]] as const) {
    const story = await (await request.post('/api/v1/projects/SHOP/requirements', {
      headers: po,
      data: { type: 'USER_STORY', title: titre, parentKey: feature.key, storyPoints: points, criteria: [{ format: 'TEXT', content: 'OK' }] },
    })).json();
    await request.post(`/api/v1/projects/SHOP/requirements/${story.key}/status`, { headers: po, data: { status: 'READY', acknowledgeUnmet: true } });
    stories.push(story.key);
  }

  await test.step('Le PO crée la release « Version … » sur six semaines', async () => {
    await connexion(page, 'po');
    await page.goto('/p/SHOP/planning');
    await page.getByTestId('release-new').click();
    await page.getByTestId('release-name').fill(nom);
    await page.getByTestId('release-goal').fill('Fidélité client');
    await page.getByTestId('release-start').fill('2030-01-07');
    await page.getByTestId('release-end').fill('2030-02-17');
    await page.getByTestId('release-submit').click();
    await expect(page.getByText(nom)).toBeVisible();
  });

  const release = page.locator('[data-testid^="release-REL-"]').filter({ hasText: nom });
  await test.step('Il génère 3 sprints de 2 semaines : la frise affiche les trois sprints', async () => {
    await release.getByRole('button', { name: 'Générer des sprints' }).click();
    await page.getByTestId('generate-capacity').fill('15');
    await page.getByTestId('generate-submit').click();
    await expect(release.locator('[data-testid^="sprint-block-"]')).toHaveCount(3);
  });

  await test.step('Il ouvre le premier sprint et y glisse deux stories prêtes : la jauge dépasse la capacité', async () => {
    await release.locator('[data-testid^="sprint-block-"]').first().click();
    await expect(page.getByTestId('sprint-status')).toHaveText('Planifié');
    for (const cle of stories) {
      await page.getByTestId('ready-search').fill(cle);
      await glisser(page, page.getByTestId(`drag-${cle}`), page.getByTestId('column-sprint'));
      await expect(page.getByTestId(`sprint-item-${cle}`)).toBeVisible();
    }
    await expect(page.getByTestId('capacity-label')).toHaveText('21 / 15 points (140 %)');
    await expect(page.getByTestId('over-capacity')).toBeVisible();
  });

  await test.step('Il renvoie une story au backlog avec le bouton ←', async () => {
    await page.getByTestId(`plan-remove-${stories[1]}`).click();
    await expect(page.getByTestId('capacity-label')).toHaveText('8 / 15 points (53 %)');
    await expect(page.getByTestId('over-capacity')).toHaveCount(0);
  });
});
