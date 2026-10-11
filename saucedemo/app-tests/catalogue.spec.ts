import { expect, test } from '@playwright/test';
import { ouvrirCatalogue } from '../support/swaglabs';

/** Feature « Catalogue » (SWAG REQ-6 à REQ-8). */
test.describe('Catalogue', () => {
  test.beforeEach(async ({ page }) => {
    await ouvrirCatalogue(page);
  });

  test('affiche les six produits du catalogue', { tag: '@REQ-6' }, async ({ page }) => {
    await expect(page.getByTestId('inventory-item')).toHaveCount(6);
    await expect(page.getByTestId('inventory-item-name').first()).toHaveText('Sauce Labs Backpack');
  });

  test('trie les produits par prix croissant', { tag: '@REQ-7' }, async ({ page }) => {
    await page.getByTestId('product-sort-container').selectOption('lohi');
    const prix = (await page.getByTestId('inventory-item-price').allInnerTexts()).map((p) => Number(p.replace('$', '')));
    expect(prix).toEqual([...prix].sort((a, b) => a - b));
    await expect(page.getByTestId('inventory-item-name').first()).toHaveText('Sauce Labs Onesie');
  });

  test('ouvre la fiche d’un produit', { tag: '@REQ-8' }, async ({ page }) => {
    await page.getByTestId('item-0-title-link').click();
    await expect(page).toHaveURL(/inventory-item\.html\?id=0$/);
    await expect(page.getByTestId('back-to-products')).toBeVisible();
    await expect(page.getByTestId('inventory-item-name')).toHaveText('Sauce Labs Bike Light');
    await expect(page.getByTestId('inventory-item-price')).toHaveText('$9.99');
    await page.getByTestId('back-to-products').click();
    await expect(page.getByTestId('title')).toHaveText('Products');
  });
});
