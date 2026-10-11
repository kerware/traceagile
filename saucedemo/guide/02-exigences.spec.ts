import { expect, test } from '@playwright/test';
import { Api, capturer, connexion, fermerNotifications, P } from './outils';

/**
 * Guide § 3 — le PO décrit le besoin : un épic, quatre features, dix stories (dont celles de la
 * commande, non développées), deux exigences non fonctionnelles ; critères en texte et en Gherkin,
 * Definition of Ready, atelier Example Mapping et commentaires. Les clés REQ-1 à REQ-17 sont
 * déterministes sur un projet neuf (elles sont citées par les tests de saucedemo/app-tests).
 */
const gherkinAjout = [
  'Scénario: Ajouter un produit au panier depuis le catalogue',
  '  Étant donné que je suis connecté en tant que "standard_user"',
  '  Quand j\'ajoute le produit "Sauce Labs Backpack" au panier',
  '  Alors le badge du panier affiche "1"',
  '  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"',
].join('\n');

type Exigence = Record<string, unknown> & { type: string; title: string };

const story = (titre: string, parent: string, points: number, asA: string, iWant: string, soThat: string, criteres: string[], extra: Record<string, unknown> = {}): Exigence => ({
  type: 'USER_STORY', title: titre, parentKey: parent, storyPoints: points, asA, iWant, soThat, priority: 'MUST', riskLevel: 'MEDIUM',
  criteria: criteres.map((c) => (c.startsWith('Scénario:') ? { format: 'GHERKIN', content: c } : { format: 'TEXT', content: c })),
  ...extra,
});

test('Exigences : backlog, critères, DoR, ENF, atelier et commentaires', async ({ page, request }) => {
  const po = await Api.de(request, 'po');
  const creer = async (exigence: Exigence, cleAttendue: string) => {
    const cree = await po.post('/requirements', exigence);
    expect(cree.key, exigence.title).toBe(cleAttendue);
  };

  await test.step('Le PO crée l’épic, les features et les stories (API)', async () => {
    await creer({ type: 'EPIC', title: 'Acheter en ligne sur Swag Labs', priority: 'MUST',
      description: 'Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.' }, 'REQ-1');
    await creer({ type: 'FEATURE', title: 'Authentification', parentKey: 'REQ-1', priority: 'MUST' }, 'REQ-2');
    await creer(story('Se connecter avec un compte valide', 'REQ-2', 3, 'client', 'me connecter avec mon identifiant et mon mot de passe', 'accéder au catalogue', [
      'Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s\'affiche',
      'Le compte problem_user accède lui aussi au catalogue.',
    ], { riskLevel: 'HIGH' }), 'REQ-3');
    await creer(story('Refuser un compte verrouillé', 'REQ-2', 2, 'responsable sécurité', 'que les comptes verrouillés ne puissent pas se connecter', 'protéger la boutique', [
      'Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.',
    ]), 'REQ-4');
    await creer({ type: 'FEATURE', title: 'Catalogue', parentKey: 'REQ-1', priority: 'MUST' }, 'REQ-5');
    await creer(story('Consulter le catalogue des produits', 'REQ-5', 3, 'client', 'voir les produits avec leur prix', 'choisir mes achats', [
      'Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».',
    ]), 'REQ-6');
    await creer(story('Trier le catalogue', 'REQ-5', 2, 'client', 'trier les produits par nom ou par prix', 'trouver plus vite ce qui m’intéresse', [
      'Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.',
    ], { priority: 'SHOULD', riskLevel: 'LOW' }), 'REQ-7');
    await creer(story('Consulter la fiche d’un produit', 'REQ-5', 2, 'client', 'ouvrir la fiche détaillée d’un produit', 'lire sa description complète', [
      'La fiche affiche le nom, la description, le prix et un bouton « Back to products ».',
    ], { priority: 'SHOULD', riskLevel: 'LOW' }), 'REQ-8');
    await creer({ type: 'FEATURE', title: 'Panier', parentKey: 'REQ-1', priority: 'MUST' }, 'REQ-9');
    await creer(story('Ajouter un produit au panier', 'REQ-9', 3, 'client', 'ajouter un produit au panier depuis le catalogue', 'le commander plus tard', [
      gherkinAjout, 'Le bouton « Add to cart » devient « Remove ».',
    ], { riskLevel: 'HIGH' }), 'REQ-10');
    await creer(story('Visualiser le contenu du panier', 'REQ-9', 3, 'client', 'voir le contenu de mon panier', 'vérifier mes achats avant de commander', [
      'Le panier liste chaque produit avec sa quantité, sa description et son prix.',
      '« Continue Shopping » ramène au catalogue sans vider le panier.',
    ], { riskLevel: 'HIGH' }), 'REQ-11');
    await creer(story('Retirer un produit du panier', 'REQ-9', 2, 'client', 'retirer un produit ajouté par erreur', 'ne garder que ce que je veux acheter', [
      '« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.',
    ]), 'REQ-12');
    await creer({ type: 'FEATURE', title: 'Commande', parentKey: 'REQ-1', priority: 'SHOULD',
      description: 'Parcours de commande (checkout) : **non développé** dans la release 1.0.' }, 'REQ-13');
    await creer(story('Saisir les informations de livraison', 'REQ-13', 5, 'client', 'saisir mon nom et mon code postal', 'être livré', [
      'Le prénom, le nom et le code postal sont obligatoires.',
    ], { priority: 'SHOULD' }), 'REQ-14');
  });

  await test.step('Il crée la story « Valider la commande » depuis le backlog', async () => {
    await connexion(page, 'po');
    await page.goto(`/p/${P}/backlog`);
    await page.getByTestId('backlog-new').click();
    await page.getByTestId('requirement-title-input').fill('Valider la commande');
    await page.getByTestId('requirement-parent-input').click();
    await page.getByRole('option', { name: /— Commande$/ }).click();
    await page.getByTestId('story-as-a-input').fill('client');
    await page.getByTestId('story-i-want-input').fill('vérifier le récapitulatif et valider ma commande');
    await page.getByTestId('story-so-that-input').fill('recevoir mes produits');
    await expect(page.getByTestId('story-preview')).toContainText('En tant que client');
    await capturer(page, 'exigence-creer-story', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('requirement-create-submit').click();
    await expect(page.getByTestId('requirement-key')).toHaveText('REQ-15');
  });

  await test.step('Il décrit les deux exigences non fonctionnelles (Planguage)', async () => {
    await creer({ type: 'NON_FUNCTIONAL', title: 'Temps de chargement du catalogue', parentKey: 'REQ-1', category: 'PERFORMANCE', transverse: true,
      scale: 'Délai entre le clic « Login » et l’affichage des six produits', measurementMethod: 'p95 de 5 connexions successives (test Playwright de performance)',
      minimumThreshold: '3000', target: '1000', unit: 'ms', priority: 'MUST' }, 'REQ-16');
    await creer({ type: 'NON_FUNCTIONAL', title: 'Contrat HTTP du site', parentKey: 'REQ-1', category: 'RELIABILITY', transverse: true,
      scale: 'Part des ressources publiques servies conformément (page, manifeste, icônes)', measurementMethod: 'Test d’API sans navigateur',
      minimumThreshold: '100', target: '100', unit: '%', priority: 'SHOULD' }, 'REQ-17');
    await page.goto(`/p/${P}/requirements/REQ-16`);
    await expect(page.getByTestId('nfr-fields')).toBeVisible();
    await capturer(page, 'exigence-enf-planguage', page.getByTestId('nfr-fields'), { marge: 12 });
  });

  await test.step('Les stories développées passent à « Prête » ; REQ-12 depuis l’interface, avec la DoR', async () => {
    for (const cle of ['REQ-3', 'REQ-4', 'REQ-6', 'REQ-7', 'REQ-8', 'REQ-10', 'REQ-11']) {
      await po.post(`/requirements/${cle}/status`, { status: 'READY', acknowledgeUnmet: true });
    }
    await page.goto(`/p/${P}/requirements/REQ-12`);
    await page.getByTestId('status-menu').click();
    await page.getByTestId('status-option-READY').click();
    const dialogue = page.getByRole('dialog');
    await expect(dialogue.getByTestId('status-acknowledge')).toBeVisible();
    await capturer(page, 'exigence-dor', dialogue, { marge: 10 });
    await dialogue.getByTestId('status-acknowledge').check();
    await dialogue.getByTestId('status-confirm').click();
    await expect(page.getByTestId('status-menu')).toContainText('Prête');
  });

  await test.step('Fiche d’une story : phrase utilisateur, INVEST, critères Gherkin, versions', async () => {
    await page.goto(`/p/${P}/requirements/REQ-10`);
    await expect(page.getByTestId('requirement-detail')).toBeVisible();
    await fermerNotifications(page);
    await capturer(page, 'exigence-fiche-story');
    await page.getByTestId('tab-criteria').click();
    await expect(page.getByTestId('gherkin-view')).toBeVisible();
    await capturer(page, 'exigence-criteres-gherkin', page.getByTestId('requirement-detail'));
    await page.getByRole('tab', { name: 'Versions' }).click();
    await expect(page.getByTestId('versions-table')).toContainText('v1');
    await capturer(page, 'exigence-versions', page.getByTestId('requirement-detail'));
  });

  await test.step('Atelier Example Mapping sur « Saisir les informations de livraison »', async () => {
    await page.goto(`/p/${P}/requirements/REQ-14`);
    await page.getByTestId('tab-example-mapping').click();
    await expect(page.getByTestId('em-story')).toBeVisible();
    const ajouter = async (champ: string, texte: string) => {
      await page.getByTestId(champ).fill(texte);
      await page.getByTestId(champ).press('Enter');
      await expect(page.getByText(texte, { exact: true })).toBeVisible();
    };
    await ajouter('em-add-rule', 'Prénom, nom et code postal sont obligatoires');
    await ajouter('em-add-example-1', 'Code postal vide : « Error: Postal Code is required »');
    await ajouter('em-add-example-1', 'Jean / Dupont / 75001 : passage au récapitulatif');
    await ajouter('em-add-rule', 'Le bouton « Cancel » ramène au panier');
    await ajouter('em-add-example-2', 'Annulation : le panier garde ses 2 produits');
    await ajouter('em-add-question', 'Le format du code postal est-il contrôlé ?');
    await expect(page.getByTestId('open-questions')).toContainText('1 question ouverte');
    await capturer(page, 'atelier-example-mapping', page.getByTestId('example-mapping'), { marge: 8 });
  });

  await test.step('Commentaire avec mention sur « Visualiser le contenu du panier »', async () => {
    await page.goto(`/p/${P}/requirements/REQ-11`);
    await page.getByTestId('tab-comments').click();
    await page.getByTestId('comment-input').fill('@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).');
    await page.getByTestId('comment-submit').click();
    await expect(page.getByTestId('comments-panel')).toContainText('Continue Shopping');
    await capturer(page, 'exigence-commentaires', page.getByTestId('comments-panel'), { marge: 8 });
  });

  await test.step('Le backlog : arbre et liste', async () => {
    await page.goto(`/p/${P}/backlog`);
    await expect(page.getByTestId('requirement-tree')).toContainText('Valider la commande');
    await capturer(page, 'backlog-arbre', undefined, { pleinePage: true });
    await page.goto(`/p/${P}/backlog?view=list`);
    await expect(page.getByTestId('requirement-list')).toBeVisible();
    await capturer(page, 'backlog-liste', undefined, { pleinePage: true });
  });
});
