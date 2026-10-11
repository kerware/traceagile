import { expect, test } from '@playwright/test';
import { capturer } from './outils';

/**
 * Guide § 1 — l'application testée, Swag Labs (www.saucedemo.com), jusqu'au panier. La capture du
 * défaut de problem_user est reprise comme pièce jointe de l'anomalie dans TraceAgile.
 */
const SAUCE = 'https://www.saucedemo.com';

test.use({ testIdAttribute: 'data-test', viewport: { width: 1280, height: 720 } });

test('Swag Labs : connexion, catalogue, fiche produit, panier et défaut de problem_user', async ({ page }) => {
  const seConnecter = async (utilisateur: string) => {
    await page.context().clearCookies();
    await page.goto(SAUCE);
    // Swag Labs garde le panier dans le localStorage
    await page.evaluate(() => localStorage.clear());
    await page.getByTestId('username').fill(utilisateur);
    await page.getByTestId('password').fill('secret_sauce');
  };

  await test.step('Page de connexion et compte verrouillé', async () => {
    await page.goto(SAUCE);
    await capturer(page, 'sd-connexion');
    await seConnecter('locked_out_user');
    await page.getByTestId('login-button').click();
    await expect(page.getByTestId('error')).toBeVisible();
    await capturer(page, 'sd-compte-verrouille', page.locator('.login-box'), { marge: 8 });
  });

  await test.step('Catalogue, fiche produit, panier', async () => {
    await seConnecter('standard_user');
    await page.getByTestId('login-button').click();
    await expect(page.getByTestId('inventory-item')).toHaveCount(6);
    await page.getByTestId('add-to-cart-sauce-labs-backpack').click();
    await page.getByTestId('add-to-cart-sauce-labs-bike-light').click();
    await capturer(page, 'sd-catalogue');
    await page.getByTestId('item-0-title-link').click();
    await expect(page.getByTestId('back-to-products')).toBeVisible();
    await capturer(page, 'sd-fiche-produit');
    await page.getByTestId('shopping-cart-link').click();
    await expect(page.getByTestId('inventory-item')).toHaveCount(2);
    await capturer(page, 'sd-panier');
  });

  await test.step('problem_user : « Remove » sur le catalogue reste sans effet', async () => {
    await seConnecter('problem_user');
    await page.getByTestId('login-button').click();
    await page.getByTestId('add-to-cart-sauce-labs-backpack').click();
    await page.getByTestId('remove-sauce-labs-backpack').click();
    await page.waitForTimeout(1000);
    await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');
    await capturer(page, 'sd-defaut-problem-user');
  });
});
