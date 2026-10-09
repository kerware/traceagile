import { expect, test, type Page } from '@playwright/test';
import { connexion } from './support';

/**
 * Non-régression : après avoir ouvert une fiche dans le panneau latéral (§13.1) puis navigué
 * (« Ouvrir en pleine page », lien interne), la page doit toujours défiler à la molette.
 */
async function defile(page: Page) {
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.mouse.move(700, 500);
  // Le verrou de défilement du panneau est levé à la fin de sa transition de fermeture : on
  // refait le geste comme un utilisateur, la page doit finir par défiler.
  await expect(async () => {
    await page.mouse.wheel(0, 600);
    expect(await page.evaluate(() => window.scrollY)).toBeGreaterThan(0);
  }).toPass({ timeout: 5000 });
}

test('le défilement vertical reste possible après le panneau latéral', async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 700 });
  await connexion(page, 'admin');

  await test.step('Backlog en liste, fiche ouverte dans le panneau puis en pleine page', async () => {
    await page.goto('/p/SHOP/backlog?view=list');
    await page.getByTestId('requirement-row-REQ-3').click();
    await expect(page.getByTestId('requirement-detail')).toBeVisible();
    await page.getByTestId('drawer-open-full').click();
    await expect(page.getByTestId('requirement-title')).toBeVisible();
    await defile(page);
  });

  await test.step('Retour au backlog après fermeture du panneau', async () => {
    await page.goto('/p/SHOP/backlog?view=list');
    await page.getByTestId('requirement-row-REQ-3').click();
    await expect(page.getByTestId('requirement-detail')).toBeVisible();
    await page.keyboard.press('Escape');
    await expect(page.getByTestId('requirement-detail')).toBeHidden();
    await defile(page);
  });

  await test.step('Référentiel de tests, fiche en panneau puis en pleine page', async () => {
    await page.goto('/p/SHOP/tests?view=list');
    await page.getByTestId('test-row-TC-1').click();
    await expect(page.getByTestId('test-detail')).toBeVisible();
    await page.getByTestId('test-drawer-open-full').click();
    await expect(page.getByTestId('test-title')).toBeVisible();
    await defile(page);
  });
});
