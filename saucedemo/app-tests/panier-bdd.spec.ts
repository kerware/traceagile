import { expect } from '@playwright/test';
import { fileURLToPath } from 'node:url';
import { Etapes, jouerFeature } from '../support/gherkin';
import { ouvrirCatalogue, slug } from '../support/swaglabs';

/**
 * Story « Ajouter un produit au panier » (SWAG REQ-10) : le scénario Gherkin du critère d'acceptation
 * n° 1, exécuté par Playwright. Le test BDD correspondant est généré dans TraceAgile depuis ce critère.
 */
const etapes = new Etapes();

etapes.definir(/^je suis connecté en tant que "([^"]+)"$/, async (page, utilisateur) => {
  await ouvrirCatalogue(page, utilisateur);
});

etapes.definir(/^j['’]ajoute le produit "([^"]+)" au panier$/, async (page, produit) => {
  await page.getByTestId(`add-to-cart-${slug(produit)}`).click();
});

etapes.definir(/^le badge du panier affiche "(\d+)"$/, async (page, nombre) => {
  await expect(page.getByTestId('shopping-cart-badge')).toHaveText(nombre);
});

etapes.definir(/^le panier contient "([^"]+)" au prix de "([^"]+)"$/, async (page, produit, prix) => {
  await page.getByTestId('shopping-cart-link').click();
  const ligne = page.getByTestId('inventory-item').filter({ hasText: produit });
  await expect(ligne).toHaveCount(1);
  await expect(ligne.getByTestId('inventory-item-price')).toHaveText(prix);
});

jouerFeature(fileURLToPath(new URL('../features/panier.feature', import.meta.url)), etapes);
