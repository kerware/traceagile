import { expect, test } from '@playwright/test';
import { connexion, glisser } from './support';

/**
 * Parcours §15.3 étape 1 — « Le PO crée une story avec deux critères Gherkin, la passe à READY,
 * l'ajoute à SPR-2. »
 */
test('Parcours 1 : le PO crée une story avec deux critères Gherkin, la passe à « Prête » et l’ajoute à SPR-2', async ({ page }) => {
  const titre = `Retrait en magasin ${Date.now()}`;
  let cle = '';

  await test.step('Le PO se connecte et ouvre le backlog du projet SHOP', async () => {
    await connexion(page, 'po');
    await page.goto('/p/SHOP/backlog');
    await expect(page.getByRole('heading', { name: 'Backlog' })).toBeVisible();
  });

  await test.step('Il crée la user story sous la feature « Livraison »', async () => {
    await page.getByTestId('backlog-new').click();
    await page.getByTestId('requirement-title-input').fill(titre);
    await page.getByTestId('requirement-parent-input').click();
    await page.getByRole('option', { name: /— Livraison$/ }).click();
    await page.getByTestId('story-as-a-input').fill('client');
    await page.getByTestId('story-i-want-input').fill('retirer ma commande en magasin');
    await page.getByTestId('story-so-that-input').fill('économiser les frais de livraison');
    await expect(page.getByTestId('story-preview')).toHaveText(
      'En tant que client, je veux retirer ma commande en magasin afin de économiser les frais de livraison.',
    );
    await page.getByTestId('requirement-create-submit').click();
    await expect(page.getByTestId('requirement-title')).toHaveText(titre);
    cle = (await page.getByTestId('requirement-key').textContent())!.trim();
  });

  await test.step('Il l’estime à 5 points', async () => {
    await page.getByTestId('field-points').click();
    await page.getByRole('option', { name: '5', exact: true }).click();
    await page.getByTestId('requirement-save').click();
    await expect(page.getByText('Modifications enregistrées')).toBeVisible();
  });

  await test.step('Il ajoute deux critères d’acceptation en Gherkin français', async () => {
    await page.getByRole('tab', { name: /Critères/ }).click();
    await ajouterCritereGherkin(page, [
      'Scénario: commande prête en magasin',
      '  Étant donné une commande payée avec retrait en magasin',
      '  Quand le magasin la prépare',
      '  Alors je reçois un SMS « Commande prête »',
    ]);
    await ajouterCritereGherkin(page, [
      'Scénario: retrait sans frais',
      '  Étant donné un panier de 30 €',
      '  Quand je choisis le retrait en magasin',
      '  Alors les frais de livraison sont de 0 €',
    ]);
    await expect(page.getByTestId('gherkin-view')).toHaveCount(2);
  });

  await test.step('Il la passe à « Prête » en confirmant l’item manuel de la Definition of Ready', async () => {
    await page.getByTestId('status-menu').click();
    await page.getByTestId('status-option-READY').click();
    const dialogue = page.getByRole('dialog');
    await expect(dialogue.getByText("Au moins un critère d'acceptation")).toBeVisible();
    await dialogue.getByTestId('status-acknowledge').check();
    await dialogue.getByTestId('status-confirm').click();
    await expect(page.getByTestId('status-menu')).toContainText('Prête');
  });

  await test.step('Une version v1 a été figée au passage à « Prête » (F-REQ-21)', async () => {
    await page.getByRole('tab', { name: 'Versions' }).click();
    await expect(page.getByTestId('versions-table')).toContainText('v1');
    await expect(page.getByTestId('versions-table')).toContainText('Passage à READY');
  });

  await test.step('Il ouvre la planification de SPR-2 (sprint actif) et y glisse la story', async () => {
    await page.goto('/p/SHOP/planning?tab=sprint&sprint=SPR-2');
    await expect(page.getByTestId('sprint-status')).toHaveText('Actif');
    await page.getByTestId('ready-search').fill(titre);
    const enregistrement = page.waitForResponse((r) => r.url().endsWith('/sprints/SPR-2/scope') && r.request().method() === 'PUT');
    await glisser(page, page.getByTestId(`drag-${cle}`), page.getByTestId('column-sprint'));
    const reponse = await enregistrement;
    expect(reponse.status(), await reponse.text()).toBe(200);
    await expect(page.getByTestId(`sprint-item-${cle}`)).toBeVisible();
  });

  await test.step('Le sprint étant actif, la story passe « En sprint »', async () => {
    await page.goto(`/p/SHOP/requirements/${cle}`);
    await expect(page.getByTestId('status-menu')).toContainText('En sprint');
  });
});

async function ajouterCritereGherkin(page: import('@playwright/test').Page, lignes: string[]) {
  await page.getByTestId('criterion-add').click();
  const editeur = page.getByTestId('criterion-editor');
  await editeur.getByText('Gherkin', { exact: true }).click();
  await editeur.getByTestId('criterion-content').fill(lignes.join('\n'));
  await expect(editeur.getByTestId('gherkin-valid')).toBeVisible();
  await editeur.getByTestId('criterion-save').click();
  await expect(editeur).toHaveCount(0);
}
