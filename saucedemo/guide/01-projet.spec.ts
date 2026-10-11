import { expect, test } from '@playwright/test';
import { Api, capturer, connexion, noterEtat, P, SERVEUR } from './outils';

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

  await test.step('Les serveurs d’exécution (réel et simulateur) sont appairés et en ligne', async () => {
    await expect.poll(async () => {
      const serveurs = (await admin.get('/execution-servers')) as { name: string; usable: boolean; status: string }[];
      return [SERVEUR, 'Simulateur'].every((nom) => serveurs.some((s) => s.name === nom && s.usable && s.status === 'ONLINE'));
    }, { timeout: 120_000, intervals: [3_000] }).toBe(true);
    await page.goto('/admin/execution-servers');
    await expect(page.getByTestId(`server-status-${SERVEUR}`)).toBeVisible();
    await capturer(page, 'admin-serveurs-execution');
  });

  await test.step('La page Projets montre la carte du nouveau projet', async () => {
    await page.goto('/projects');
    await capturer(page, 'projets', page.getByTestId(`project-card-${P}`), { marge: 12 });
  });
});
