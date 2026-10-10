import { expect, test } from '@playwright/test';
import { readFile } from 'node:fs/promises';
import { connexion } from './support';

/**
 * ADR-0023 générateur de rapports configurables : le testeur compose un modèle (sections choisies et
 * ordonnées, format Word par défaut), génère le rapport de SPR-2 et l'exporte en Word puis en Excel.
 */
test('Rapport configurable : modèle personnalisé, génération, exports Word et Excel', async ({ page }) => {
  test.setTimeout(90_000);
  const nom = `Comité qualité ${Date.now().toString().slice(-6)}`;

  await test.step('Le testeur crée un modèle : synthèse, burndown, couverture, liste des anomalies ; format Word', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/reports?tab=definitions');
    await page.getByTestId('definition-new').click();
    await page.getByTestId('definition-name').fill(nom);
    // par défaut : synthèse, couverture, exécution, anomalies → on retire exécution et anomalies
    await page.getByTestId('definition-toggle-EXECUTION').click();
    await page.getByTestId('definition-toggle-DEFECTS').click();
    await page.getByTestId('definition-toggle-BURNDOWN').click();
    await page.getByTestId('definition-toggle-DEFECT_LIST').click();
    await page.getByTestId('definition-up-BURNDOWN').click();
    await page.getByTestId('definition-format').click();
    await page.getByRole('option', { name: 'Word (.docx)' }).click();
    await page.getByTestId('definition-submit').click();
    const carte = page.getByTestId(`definition-${nom}`);
    await expect(carte).toContainText('1. Synthèse');
    await expect(carte).toContainText('2. Burndown / burnup');
    await expect(carte).toContainText('3. Couverture');
    await expect(carte).toContainText('4. Liste des anomalies');
  });

  let cle = '';
  await test.step('Il génère le rapport de SPR-2 avec ce modèle', async () => {
    await page.getByTestId(`definition-generate-${nom}`).click();
    await expect(page.getByTestId('generate-definition')).toHaveValue(nom);
    await page.getByTestId('generate-submit').click();
    await expect(page.getByTestId('report-page')).toBeVisible();
    await expect(page.getByTestId('report-title')).toContainText(nom);
    cle = (await page.locator('[data-testid=report-page] .mantine-Badge-root').first().innerText()).trim();
    await expect(page.frameLocator('[data-testid=report-frame]').getByRole('heading', { name: '2. Burndown / burnup' })).toBeVisible();
  });

  for (const [format, extension] of [['DOCX', 'docx'], ['XLSX', 'xlsx']] as const) {
    await test.step(`Il exporte le rapport en ${extension}`, async () => {
      const telechargement = page.waitForEvent('download');
      await page.getByTestId(`export-${cle}`).click();
      await page.getByTestId(`export-${cle}-${format}`).click();
      const fichier = await telechargement;
      expect(fichier.suggestedFilename()).toBe(`${cle}.${extension}`);
      const contenu = await readFile((await fichier.path())!);
      expect(contenu.subarray(0, 2).toString('latin1')).toBe('PK');
    });
  }
});
