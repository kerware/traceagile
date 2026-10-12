import { expect, test } from '@playwright/test';
import { Api, BRANCHE, capturer, connexion, DEPOT_GIT, EXECUTEUR_MOT_DE_PASSE, EXECUTEUR_URL_DEPUIS_TRACEAGILE, MOT_DE_PASSE, noterEtat, P, PROJET_GIT, SERVEUR } from './outils';

const EQUIPE: [string, string][] = [
  ['po', 'Paula Owner'], ['qa1', 'Quentin Testeur'], ['qa2', 'Quitterie Testeuse'], ['dev', 'Dev Eloppeur'], ['viewer', 'Victor Lecteur'],
];

/**
 * Guide § 2 — l'administrateur crée le projet SWAG, y affecte l'équipe (un rôle par membre) et
 * vérifie que le serveur d'exécution (simulateur) est en ligne.
 */
test('Administration : projet SWAG, membres et serveur d’exécution', async ({ page, request }) => {
  const admin = await Api.de(request, 'admin');
  const reponse = await admin.get('/api/v1/projects?size=200');
  const projets = (Array.isArray(reponse) ? reponse : reponse.content) as { key: string }[];
  expect(projets.map((p) => p.key), `le projet ${P} existe déjà : docker compose down -v, ou GUIDE_PROJET=<autre clé>`).not.toContain(P);
  noterEtat({ projet: P });

  await test.step('Comptes de l’équipe (instance installée hors profil demo : créés s’ils manquent)', async () => {
    const existants = ((await admin.get('/api/v1/users?size=200')).content as { login: string }[]).map((u) => u.login);
    for (const [login, nom] of EQUIPE) {
      if (!existants.includes(login)) {
        await admin.post('/api/v1/users', { login, email: `${login}@traceagile.demo`, displayName: nom, password: MOT_DE_PASSE, systemAdmin: false });
      }
    }
  });

  await test.step('L’administrateur crée le projet depuis la page Projets', async () => {
    await connexion(page, 'admin');
    await page.goto('/projects');
    await page.getByTestId('project-create').click();
    await page.getByTestId('project-key-input').fill(P);
    await page.getByTestId('project-name-input').fill('Swag Labs (saucedemo)');
    await page.getByTestId('project-description-input').fill(
      'Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.',
    );
    await capturer(page, 'admin-creer-projet', page.getByRole('dialog'), { marge: 10 });
    await page.getByTestId('project-save').click();
    await expect(page.getByTestId(`project-card-${P}`)).toBeVisible();
  });

  await test.step('Il affecte l’équipe : PO, deux testeurs, un développeur, un lecteur', async () => {
    await admin.put(`/api/v1/projects/${P}/members`, [
      { login: 'admin', role: 'ADMINISTRATOR' },
      { login: 'po', role: 'PRODUCT_OWNER' },
      { login: 'qa1', role: 'TESTER' },
      { login: 'qa2', role: 'TESTER' },
      { login: 'dev', role: 'DEVELOPER' },
      { login: 'viewer', role: 'VIEWER' },
    ]);
    await page.goto('/admin/projects');
    await page.getByTestId(`admin-members-${P}`).click();
    await expect(page.getByTestId('members-editor')).toBeVisible();
    await capturer(page, 'admin-membres', page.getByTestId('members-editor'), { marge: 12 });
    await page.goto('/admin/users');
    await expect(page.getByTestId('users-table')).toBeVisible();
    await capturer(page, 'admin-utilisateurs');
  });

  await test.step('Les serveurs d’exécution déclarés sont appairés et en ligne', async () => {
    type Serveur = { id: string; name: string; usable: boolean; status: string; paired: boolean };
    let declares = (await admin.get('/api/v1/execution-servers')) as Serveur[];
    if (!declares.some((s) => s.name === SERVEUR)) {
      // instance sans profil demo : le serveur d'exécution est déclaré et appairé avec les identifiants de son administrateur
      const cree = (await admin.post('/api/v1/execution-servers', { name: SERVEUR, baseUrl: EXECUTEUR_URL_DEPUIS_TRACEAGILE })) as Serveur;
      await admin.post(`/api/v1/execution-servers/${cree.id}/pair`, { adminUser: 'admin', adminPassword: EXECUTEUR_MOT_DE_PASSE });
      declares = (await admin.get('/api/v1/execution-servers')) as Serveur[];
    }
    const attendus = declares.map((s) => s.name);
    await expect.poll(async () => {
      const serveurs = (await admin.get('/execution-servers')) as Serveur[];
      return attendus.every((nom) => serveurs.some((s) => s.name === nom && s.usable && s.status === 'ONLINE'));
    }, { timeout: 120_000, intervals: [3_000] }).toBe(true);
    await page.goto('/admin/execution-servers');
    await expect(page.getByTestId(`server-status-${SERVEUR}`)).toBeVisible();
    await capturer(page, 'admin-serveurs-execution');
  });

  await test.step('Il déclare les dépôts Git des tests : le dépôt local des exemples et le compte GitHub kerware', async () => {
    type Depot = { id: string; name: string; projects: { label: string }[] };
    const declarer = async (nom: string, adresse: string, description: string, projet: string, branche: string) => {
      let depot = ((await admin.get('/api/v1/git-sources')) as Depot[]).find((d) => d.name === nom);
      depot ??= (await admin.post('/api/v1/git-sources', { name: nom, baseUrl: adresse, description, authType: 'NONE' })) as Depot;
      if (!depot.projects?.some((p) => p.label === `${nom} / ${projet}`)) {
        await admin.post(`/api/v1/git-sources/${depot.id}/projects`, { name: projet, defaultBranch: branche });
      }
    };
    // dépôt local monté en lecture seule dans le serveur d'exécution : les tests de saucedemo/ de ce dépôt
    await declarer(DEPOT_GIT.nom, DEPOT_GIT.adresse, 'Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)', DEPOT_GIT.projet, BRANCHE);
    // dépôt public sur GitHub (projet de formation Playwright Java)
    await declarer('kerware', 'https://github.com/kerware', 'Projets de formation (GitHub, public)', 'saucedemo-e2e', 'master');
    await page.goto('/admin/git');
    await expect(page.getByTestId(`git-project-${PROJET_GIT}`)).toBeVisible();
    await capturer(page, 'admin-depots-git', undefined, { pleinePage: true });
  });

  await test.step('La page Projets montre la carte du nouveau projet', async () => {
    await page.goto('/projects');
    await capturer(page, 'projets', page.getByTestId(`project-card-${P}`), { marge: 12 });
  });
});
