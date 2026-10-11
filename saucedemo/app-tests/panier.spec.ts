import { expect, test } from '@playwright/test';
import { ouvrirCatalogue } from '../support/swaglabs';

/**
 * Feature « Panier » (SWAG REQ-11, REQ-12). Le second test échoue réellement : avec le compte
 * problem_user, le bouton « Remove » du catalogue reste sans effet (anomalie connue, suivie dans
 * TraceAgile). Le tag @fail le fait aussi échouer sur le simulateur d'exécution de TraceAgile.
 */
test.describe('Panier', () => {
  test('visualise le contenu du panier', { tag: '@REQ-11' }, async ({ page }) => {
    await ouvrirCatalogue(page);
    await page.getByTestId('add-to-cart-sauce-labs-backpack').click();
    await page.getByTestId('add-to-cart-sauce-labs-bike-light').click();
    await expect(page.getByTestId('shopping-cart-badge')).toHaveText('2');
    await page.getByTestId('shopping-cart-link').click();
    await expect(page.getByTestId('title')).toHaveText('Your Cart');
    await expect(page.getByTestId('inventory-item')).toHaveCount(2);
    await expect(page.getByTestId('inventory-item-name')).toHaveText(['Sauce Labs Backpack', 'Sauce Labs Bike Light']);
    await expect(page.getByTestId('item-quantity')).toHaveText(['1', '1']);
    await expect(page.getByTestId('inventory-item-price')).toHaveText(['$29.99', '$9.99']);
    await page.getByTestId('continue-shopping').click();
    await expect(page.getByTestId('title')).toHaveText('Products');
  });

  test('problem_user retire un produit depuis le catalogue @fail', { tag: '@REQ-12' }, async ({ page }) => {
    await ouvrirCatalogue(page, 'problem_user');
    await page.getByTestId('add-to-cart-sauce-labs-backpack').click();
    await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');
    await page.getByTestId('remove-sauce-labs-backpack').click();
    await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });
  });
});
