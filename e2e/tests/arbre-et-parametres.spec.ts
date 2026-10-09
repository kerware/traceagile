import { expect, test } from '@playwright/test';
import { connexion } from './support';

/**
 * ADR-0013 : depuis l'arbre du référentiel, créer un dossier puis un test dedans par le menu
 * contextuel ; écrire ${parametre} dans un pas, le voir détecté, saisir un jeu de données nommé.
 */
test('menu contextuel de l’arbre, paramètres détectés et jeu de données', async ({ page }) => {
  const suffixe = Date.now().toString().slice(-6);
  const dossier = `Recette ${suffixe}`;
  await connexion(page, 'qa1');

  await test.step('Clic droit sur la racine : nouveau dossier', async () => {
    await page.goto('/p/SHOP/tests');
    await page.getByTestId('tree-root').click({ button: 'right' });
    await page.getByTestId('menu-new-folder').click();
    await page.getByTestId('prompt-input').fill(dossier);
    await page.getByTestId('prompt-submit').click();
    await expect(page.getByTestId(`test-group-${dossier}`)).toContainText('Dossier vide');
  });

  await test.step('Menu « ⋯ » du dossier : nouveau test rangé dans le dossier', async () => {
    await page.getByTestId(`tree-folder-${dossier}-menu`).click();
    await page.getByTestId('menu-new-test').click();
    await expect(page.getByTestId('test-folder-input')).toHaveValue(dossier);
    await page.getByTestId('test-title-input').fill(`Prix affiché ${suffixe}`);
    await page.getByTestId('test-create-submit').click();
    await expect(page.getByTestId('test-detail')).toBeVisible();
  });

  await test.step('Le ${nom-produit} d’un pas devient un paramètre ; jeu de données « Recette »', async () => {
    await page.getByTestId('step-add').click();
    await page.getByTestId('step-action-1').fill('Ouvrir la fiche de ${nom-produit}');
    await expect(page.getByTestId('param-detected-nom-produit')).toBeVisible();
    await page.getByTestId('param-default-nom-produit').fill('Stylo bleu');
    await page.getByTestId('dataset-add').click();
    await page.getByTestId('dataset-name-0').fill('Recette');
    await page.getByTestId('dataset-0-add-row').click();
    await page.getByTestId('dataset-0-cell-0-nom-produit').fill('Cahier A4');
    await page.getByTestId('test-save').click();
    await expect(page.getByText(/version 2/)).toBeVisible();
  });

  await test.step('Après rechargement, paramètre et jeu de données sont conservés ; le test est dans le dossier', async () => {
    await page.reload();
    await expect(page.getByTestId('param-default-nom-produit')).toHaveValue('Stylo bleu');
    await expect(page.getByTestId('dataset-0-cell-0-nom-produit')).toHaveValue('Cahier A4');
    await page.keyboard.press('Escape');
    await expect(page.getByTestId(`test-group-${dossier}`)).toContainText(`Prix affiché ${suffixe}`);
  });
});
