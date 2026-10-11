import { expect, test } from '@playwright/test';
import comptes from '../data/comptes.json' with { type: 'json' };
import { Api, BRANCHE, capturer, connexion, DEPOT, fermerNotifications, P } from './outils';

/**
 * Guide § 4 — le référentiel de tests : un exemple de chaque nature et de chaque technique.
 * - manuels : TC-1 (jeu de données « Comptes », 3 lignes), TC-2 (révèle le défaut de problem_user) ;
 * - automatisés Playwright de saucedemo/app-tests : TC-3 piloté par les données (même jeu « Comptes »),
 *   TC-4 à TC-6 (UI), TC-7 (API), TC-8 (BDD généré depuis le critère Gherkin de REQ-10),
 *   TC-9 et TC-10 (UI), TC-11 (performance, lié à l'ENF REQ-16) ;
 * - exploratoire : TC-12, charte sur le panier.
 * Les identifiants des tests automatisés sont les noms des tests du rapport JUnit de Playwright.
 */

type Lien = { requirementKey: string; linkType: 'VERIFIES' | 'PARTIALLY_VERIFIES' | 'RELATES_TO' };
const verifie = (...cles: string[]): Lien[] => cles.map((requirementKey) => ({ requirementKey, linkType: 'VERIFIES' }));

const automatise = (titre: string, technique: string, fichier: string, identifiant: string, liens: Lien[], extra: Record<string, unknown> = {}) => ({
  kind: 'AUTOMATED', title: titre, technique, framework: 'Playwright', language: 'TypeScript', repositoryUrl: DEPOT, branch: BRANCHE,
  path: `saucedemo/app-tests/${fichier}`, testIdentifier: identifiant, links: liens, executionTags: ['saucedemo'], ...extra,
});

test('Tests : manuels avec jeu de données, automatisés, BDD généré, charte exploratoire', async ({ page, request }) => {
  const qa = await Api.de(request, 'qa1');
  const dev = await Api.de(request, 'dev');
  const creer = async (api: Api, test: Record<string, unknown>, cleAttendue: string) => {
    const cree = await api.post('/test-cases', test);
    expect(cree.key, String(test.title)).toBe(cleAttendue);
    await qa.post(`/test-cases/${cree.key}/status`, { status: 'READY' });
  };

  await test.step('Le testeur écrit les deux tests manuels (API)', async () => {
    await creer(qa, {
      kind: 'MANUAL', title: 'Se connecter avec les comptes de démonstration', folder: 'Authentification', priority: 'MUST', estimatedDurationMin: 3,
      objective: 'Vérifier l’accès au catalogue selon le type de compte.',
      steps: [
        { action: 'Ouvrir https://www.saucedemo.com', expectedResult: 'La page de connexion « Swag Labs » s’affiche' },
        { action: 'Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »', expectedResult: '${resultat_attendu}' },
      ],
      parameters: [
        { name: 'utilisateur', defaultValue: 'standard_user' },
        { name: 'resultat_attendu', defaultValue: 'Le catalogue « Products » s’affiche' },
      ],
      dataSets: [{ name: 'Comptes', rows: comptes.map((c) => ({
        utilisateur: c.utilisateur,
        resultat_attendu: c.resultat === 'catalogue' ? 'Le catalogue « Products » s’affiche' : `Message « ${c.message} »`,
      })) }],
      automationCandidate: true, automationJustification: 'Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.',
      links: verifie('REQ-3', 'REQ-4'),
    }, 'TC-1');
    await creer(qa, {
      kind: 'MANUAL', title: 'Retirer un produit depuis le catalogue et le panier', folder: 'Panier', priority: 'MUST', estimatedDurationMin: 5,
      steps: [
        { action: 'Se connecter avec ${utilisateur}', expectedResult: 'Le catalogue s’affiche' },
        { action: 'Cliquer « Add to cart » sur Sauce Labs Backpack', expectedResult: 'Le badge du panier affiche 1' },
        { action: 'Ouvrir le panier', expectedResult: 'Sauce Labs Backpack est listé : quantité 1, $29.99' },
        { action: 'Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack', expectedResult: 'Le badge du panier disparaît' },
      ],
      parameters: [{ name: 'utilisateur', defaultValue: 'problem_user' }],
      links: [{ requirementKey: 'REQ-11', linkType: 'PARTIALLY_VERIFIES' }, { requirementKey: 'REQ-12', linkType: 'VERIFIES' }],
    }, 'TC-2');
  });

  await test.step('Le développeur référence les tests Playwright du dépôt (API)', async () => {
    await creer(dev, automatise('Connexion pilotée par les données', 'DATA_DRIVEN', 'authentification.spec.ts',
      'Authentification › connexion avec chaque compte du jeu de données', verifie('REQ-3', 'REQ-4'), {
        folder: 'Authentification',
        parameters: [{ name: 'utilisateur', defaultValue: 'standard_user' }, { name: 'resultat', defaultValue: 'catalogue' }, { name: 'message', defaultValue: '' }],
        dataSets: [{ name: 'Comptes', rows: comptes }],
        executionTags: ['saucedemo', 'regression'],
      }), 'TC-3');
    await creer(dev, automatise('Catalogue : six produits affichés', 'UI', 'catalogue.spec.ts', 'Catalogue › affiche les six produits du catalogue',
      verifie('REQ-6'), { folder: 'Catalogue', executionTags: ['saucedemo', 'smoke'] }), 'TC-4');
    await creer(dev, automatise('Catalogue : tri par prix croissant', 'UI', 'catalogue.spec.ts', 'Catalogue › trie les produits par prix croissant',
      verifie('REQ-7'), { folder: 'Catalogue' }), 'TC-5');
    await creer(dev, automatise('Catalogue : fiche produit', 'UI', 'catalogue.spec.ts', 'Catalogue › ouvre la fiche d’un produit',
      verifie('REQ-8'), { folder: 'Catalogue' }), 'TC-6');
    await creer(dev, automatise('Contrat HTTP : manifeste et icônes', 'API', 'api.spec.ts', 'Contrat HTTP › expose le manifeste PWA et ses icônes',
      verifie('REQ-17'), { folder: 'API', executionTags: ['saucedemo', 'smoke'] }), 'TC-7');
  });

  await test.step('Le testeur génère le test BDD depuis le critère Gherkin de REQ-10', async () => {
    await connexion(page, 'qa1');
    await page.goto(`/p/${P}/requirements/REQ-10`);
    await page.getByTestId('tab-criteria').click();
    await expect(page.getByTestId('criterion-generate-1')).toBeVisible();
    await capturer(page, 'bdd-critere-generer', page.getByTestId('criterion-1'), { marge: 8 });
    await page.getByTestId('criterion-generate-1').click();
    await expect(page.getByText('Test BDD généré : TC-8')).toBeVisible();
    await qa.post('/test-cases/TC-8/status', { status: 'READY' });
    // le scénario est joué par Playwright (exécuteur Gherkin de saucedemo/app-tests/panier-bdd.spec.ts)
    await qa.patch('/test-cases/TC-8', { folder: 'Panier', framework: 'Playwright', repositoryUrl: DEPOT, branch: BRANCHE,
      path: 'saucedemo/features/panier.feature' });
    await page.goto(`/p/${P}/tests/TC-8`);
    await expect(page.getByTestId('gherkin-editor').locator('.monaco-editor')).toBeVisible();
    await expect(page.getByTestId('gherkin-valid')).toBeVisible();
    await fermerNotifications(page);
    await capturer(page, 'bdd-test-genere');
  });

  await test.step('Le développeur référence les tests du panier et de performance (API)', async () => {
    await creer(dev, automatise('Panier : visualiser le contenu', 'UI', 'panier.spec.ts', 'Panier › visualise le contenu du panier',
      verifie('REQ-11'), { folder: 'Panier', executionTags: ['saucedemo', 'smoke'] }), 'TC-9');
    await creer(dev, automatise('Panier : retrait par problem_user', 'UI', 'panier.spec.ts', 'Panier › problem_user retire un produit depuis le catalogue @fail',
      verifie('REQ-12'), { folder: 'Panier' }), 'TC-10');
    await creer(dev, automatise('Performance : chargement du catalogue', 'PERFORMANCE', 'performance.spec.ts', 'Performance › temps de chargement du catalogue',
      verifie('REQ-16'), { folder: 'Performance', configuration: { iterations: 5, seuilMs: 3000 } }), 'TC-11');
  });

  await test.step('Le testeur rédige la charte exploratoire du panier (API)', async () => {
    await creer(qa, {
      kind: 'EXPLORATORY', title: 'Explorer le panier', folder: 'Panier', priority: 'MUST',
      explore: 'le panier', with: 'les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur',
      toDiscover: 'les écarts entre le badge, les boutons du catalogue et le contenu du panier', timeboxMin: 60,
      areas: ['Panier', 'Catalogue'], heuristics: ['CRUD', 'Goldilocks'], targetedRisk: 'Panier faux au moment de commander',
      links: verifie('REQ-11', 'REQ-12'),
    }, 'TC-12');
  });

  await test.step('Fiches des tests : pas et jeu de données, automatisation, charte', async () => {
    await page.goto(`/p/${P}/tests/TC-1`);
    await expect(page.getByTestId('manual-steps')).toBeVisible();
    await capturer(page, 'test-manuel-pas', page.getByTestId('manual-steps'), { marge: 8 });
    await page.getByTestId('parameters-panel').scrollIntoViewIfNeeded();
    await capturer(page, 'test-manuel-jeu-de-donnees', page.getByTestId('parameters-panel'), { marge: 8 });
    await page.goto(`/p/${P}/tests/TC-3`);
    await expect(page.getByTestId('automation-identifier')).toBeVisible();
    await capturer(page, 'test-automatise');
    await page.goto(`/p/${P}/tests/TC-12`);
    await expect(page.getByTestId('charter-editor')).toBeVisible();
    await capturer(page, 'test-charte', page.getByTestId('charter-editor'), { marge: 8 });
  });

  await test.step('Le référentiel de tests', async () => {
    await page.goto(`/p/${P}/tests`);
    await expect(page.getByTestId('test-row-TC-12').or(page.getByTestId('tree-test-TC-12'))).toBeVisible();
    await capturer(page, 'tests-referentiel', undefined, { pleinePage: true });
  });
});
