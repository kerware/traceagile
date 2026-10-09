import { expect, type Locator, type Page } from '@playwright/test';

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

/** Glisser-déposer pour dnd-kit : appui, déplacement progressif, relâchement au centre de la cible. */
export async function glisser(page: Page, poignee: Locator, cible: Locator) {
  const depart = (await poignee.boundingBox())!;
  const arrivee = (await cible.boundingBox())!;
  await page.mouse.move(depart.x + depart.width / 2, depart.y + depart.height / 2);
  await page.mouse.down();
  await page.mouse.move(depart.x + depart.width / 2 + 10, depart.y + depart.height / 2, { steps: 3 });
  await page.mouse.move(arrivee.x + arrivee.width / 2, arrivee.y + arrivee.height / 2, { steps: 15 });
  await page.mouse.up();
}
