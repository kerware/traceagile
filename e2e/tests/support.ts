import { expect, type Page } from '@playwright/test';

/** Mot de passe des comptes du jeu de démonstration (§15.1). */
export const MOT_DE_PASSE_DEMO = 'demo';

/** Se connecte avec un compte de démonstration : admin, po, qa1, qa2, dev ou viewer. */
export async function connexion(page: Page, login: string) {
  await page.goto('/login');
  await page.getByTestId('login-input').fill(login);
  await page.getByTestId('password-input').fill(MOT_DE_PASSE_DEMO);
  await page.getByTestId('login-submit').click();
  await expect(page.getByTestId('user-menu')).toBeVisible();
}
