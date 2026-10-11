import { expect, type Page } from '@playwright/test';

/** Mot de passe commun des comptes de Swag Labs (affiché sur la page de connexion). */
export const MOT_DE_PASSE = 'secret_sauce';

/** Se connecte à Swag Labs ; ne vérifie pas l'arrivée sur le catalogue (un compte peut être refusé). */
export async function seConnecter(page: Page, utilisateur: string) {
  await page.goto('/');
  await page.getByTestId('username').fill(utilisateur);
  await page.getByTestId('password').fill(MOT_DE_PASSE);
  await page.getByTestId('login-button').click();
}

/** Se connecte et attend le catalogue. */
export async function ouvrirCatalogue(page: Page, utilisateur = 'standard_user') {
  await seConnecter(page, utilisateur);
  await expect(page.getByTestId('title')).toHaveText('Products');
}

/** Identifiant data-test d'un produit : « Sauce Labs Backpack » → « sauce-labs-backpack ». */
export function slug(produit: string): string {
  return produit.toLowerCase().replace(/[^a-z0-9.]+/g, '-').replace(/(^-|-$)/g, '');
}
