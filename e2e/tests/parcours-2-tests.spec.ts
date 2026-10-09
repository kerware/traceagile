import { expect, test, type Page } from '@playwright/test';
import { connexion } from './support';

/**
 * Lot 2 — critère de fin : création des trois types de test et génération BDD depuis un critère.
 * Parcours §15.3 étape 2 : « Le testeur génère un test BDD depuis un critère, crée une charte
 * exploratoire liée, les sélectionne dans une campagne. » La sélection en campagne viendra au lot 5.
 */
test('Parcours 2 : le testeur crée les trois types de test et génère un test BDD depuis un critère', async ({ page }) => {
  const suffixe = Date.now();

  await test.step('Le testeur se connecte et ouvre le référentiel de tests', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/tests');
    await expect(page.getByRole('heading', { name: 'Référentiel de tests' })).toBeVisible();
  });

  await test.step('Il crée un test manuel avec deux pas et le passe à « Prêt »', async () => {
    await creerTest(page, 'Manuel', `Bon de retrait en magasin ${suffixe}`);
    await page.getByTestId('step-add').click();
    await page.getByTestId('step-action-1').fill('Payer une commande avec retrait en magasin');
    await page.getByTestId('step-expected-1').fill('Un bon de retrait est envoyé par e-mail');
    await page.getByTestId('step-add').click();
    await page.getByTestId('step-action-2').fill('Présenter le bon au magasin');
    await page.getByTestId('step-expected-2').fill('La commande est remise');
    await page.getByTestId('test-save').click();
    await expect(page.getByText(/version 2/)).toBeVisible();
    await page.getByTestId('test-status-menu').click();
    await page.getByTestId('test-status-option-READY').click();
    await expect(page.getByTestId('test-status-menu')).toContainText('Prêt');
  });

  let cleCharte = '';
  await test.step('Il crée une charte exploratoire liée à la story « Choisir le mode de livraison »', async () => {
    await creerTest(page, 'Exploratoire', `Explorer le retrait en magasin ${suffixe}`, 'Choisir le mode de livraison');
    await page.getByTestId('charter-explore').fill('le retrait en magasin');
    await page.getByTestId('charter-with').fill('des magasins fermés et des commandes partielles');
    await page.getByTestId('charter-to-discover').fill('les commandes bloquées');
    await expect(page.getByTestId('charter-preview')).toHaveText(
      'Explorer le retrait en magasin avec des magasins fermés et des commandes partielles pour découvrir les commandes bloquées.',
    );
    await page.getByTestId('test-save').click();
    await page.getByRole('tab', { name: /Exigences liées/ }).click();
    await expect(page.getByTestId('link-requirement-0')).toHaveValue(/REQ-\d+ — Choisir le mode de livraison/);
    await page.getByTestId('test-status-menu').click();
    await page.getByTestId('test-status-option-READY').click();
    await expect(page.getByTestId('test-status-menu')).toContainText('Prêt');
    cleCharte = (await page.getByTestId('test-key').textContent())!.trim();
  });

  await test.step('Il crée un test automatisé API', async () => {
    await creerTest(page, 'Automatisé', `API retrait magasin ${suffixe}`, undefined, 'API');
    await page.getByTestId('automation-identifier').fill('StorePickupApiTest#voucherSent');
    await page.getByTestId('test-save').click();
    await expect(page.getByText('Test enregistré').or(page.getByText(/version 2/))).toBeVisible();
  });

  let cleTestBdd = '';
  await test.step('Sur une story, il génère un test BDD depuis un critère Gherkin (F-REQ-11)', async () => {
    await page.goto('/p/SHOP/backlog?view=list&q=frais de livraison avant paiement');
    await page.getByTestId(/requirement-row-REQ-/).first().click();
    await page.getByRole('tab', { name: /Critères/ }).click();
    await page.getByTestId('criterion-generate-1').click();
    const notification = page.getByText(/Test BDD généré : TC-\d+/);
    await expect(notification).toBeVisible();
    cleTestBdd = (await notification.textContent())!.match(/TC-\d+/)![0];
    await page.getByRole('tab', { name: 'Tests liés' }).click();
    await expect(page.getByTestId(`linked-test-${cleTestBdd}`)).toContainText('critères #1');
  });

  await test.step('Le test BDD généré porte le scénario et les tags @REQ / @AC dans l’éditeur Gherkin', async () => {
    await page.goto(`/p/SHOP/tests/${cleTestBdd}`);
    const editeur = page.getByTestId('gherkin-editor');
    await expect(editeur.locator('.monaco-editor')).toBeVisible();
    await expect(editeur).toContainText('@AC-');
    await expect(page.getByTestId('gherkin-valid')).toBeVisible();
  });

  await test.step('Il passe le test BDD à « Prêt »', async () => {
    await page.goto(`/p/SHOP/tests/${cleTestBdd}`);
    await page.getByTestId('test-status-menu').click();
    await page.getByTestId('test-status-option-READY').click();
    await expect(page.getByTestId('test-status-menu')).toContainText('Prêt');
  });

  await test.step('Il crée une campagne de régression et y sélectionne le test BDD et la charte (F-CMP-02)', async () => {
    await page.goto('/p/SHOP/campaigns');
    await page.getByTestId('campaign-new').click();
    await page.getByTestId('campaign-name').fill(`Régression retrait ${suffixe}`);
    await page.getByTestId('campaign-scope').click();
    await page.getByRole('option', { name: 'Régression' }).click();
    await page.getByTestId('campaign-submit').click();
    await expect(page.getByTestId('campaign-page')).toBeVisible();
    await page.getByTestId('selection-strategy').click();
    await page.getByRole('option', { name: 'Sélection manuelle' }).click();
    for (const cle of [cleTestBdd, cleCharte]) {
      await page.getByTestId('selection-tests').fill(cle);
      await page.getByRole('option', { name: new RegExp(`^${cle} —`) }).click();
    }
    await page.getByTestId('selection-submit').click();
    await expect(page.getByTestId('selection-result')).toContainText('2 tests ajoutés');
    await expect(page.getByTestId(`item-${cleTestBdd}`)).toContainText('Serveur d');
    await expect(page.getByTestId(`item-${cleCharte}`)).toBeVisible();
  });
});

async function creerTest(page: Page, nature: string, titre: string, exigence?: string, technique?: string) {
  await page.goto('/p/SHOP/tests');
  await page.getByTestId('tests-new').click();
  await page.getByRole('dialog').getByText(nature, { exact: true }).click();
  await page.getByTestId('test-title-input').fill(titre);
  if (technique) {
    await page.getByTestId('test-technique-input').click();
    await page.getByRole('option', { name: technique, exact: true }).click();
  }
  if (exigence) {
    await page.getByTestId('test-requirement-input').fill(exigence);
    await page.getByRole('option', { name: new RegExp(`— ${exigence}$`) }).click();
  }
  await page.getByTestId('test-create-submit').click();
  await expect(page.getByTestId('test-title')).toHaveText(titre);
}
