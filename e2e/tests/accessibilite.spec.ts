import AxeBuilder from '@axe-core/playwright';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';
import { connexion, MOT_DE_PASSE_DEMO } from './support';

/**
 * NF-10 / ADR-0024 : contrôle axe-core (WCAG 2.1 A et AA) des écrans principaux, en clair et en sombre.
 * Critère de fin du lot 9 : aucune violation « critical » ni « serious » ; les autres sont jointes au
 * rapport Playwright.
 */
async function premiereCle(request: APIRequestContext, chemin: string, champ = 'key'): Promise<string> {
  const login = await request.post('/api/v1/auth/login', { data: { login: 'po', password: MOT_DE_PASSE_DEMO } });
  const token = (await login.json()).accessToken as string;
  const reponse = await (await request.get(`/api/v1/projects/SHOP/${chemin}`, { headers: { Authorization: `Bearer ${token}` } })).json();
  const liste = Array.isArray(reponse) ? reponse : reponse.content;
  return liste[0][champ] as string;
}

async function controler(page: Page, nom: string) {
  // pas de « networkidle » : les pages temps réel gardent un flux SSE ouvert
  await page.waitForLoadState('load');
  await page.waitForTimeout(1500);
  // l'iframe du rapport (srcdoc isolé, origine opaque) n'est pas analysable par axe : c'est le document exporté, pas l'application
  const resultat = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa']).exclude('[data-testid="report-frame"]').analyze();
  const graves = resultat.violations.filter((v) => v.impact === 'critical' || v.impact === 'serious');
  await test.info().attach(`axe-${nom}.json`, {
    body: JSON.stringify(resultat.violations.map((v) => ({ id: v.id, impact: v.impact, aide: v.help, noeuds: v.nodes.length })), null, 2),
    contentType: 'application/json',
  });
  expect(graves.map((v) => `${v.id} (${v.impact}) : ${v.help} — ${v.nodes.slice(0, 3).map((n) => n.target.join(' ')).join(' | ')}`), nom).toEqual([]);
}

test('NF-10 écrans principaux sans violation WCAG 2.1 AA critique ou sérieuse', async ({ page, request }) => {
  test.setTimeout(300_000);
  const exigence = await premiereCle(request, 'requirements?type=USER_STORY&size=1');
  const testCase = await premiereCle(request, 'test-cases?size=1');
  const rapport = await premiereCle(request, 'reports');

  await test.step('Connexion', async () => {
    await page.goto('/login');
    await controler(page, 'connexion');
    await connexion(page, 'po');
  });

  const ecrans: [string, string][] = [
    ['projets', '/projects'],
    ['tableau-de-bord', '/p/SHOP/dashboard'],
    ['backlog', '/p/SHOP/backlog'],
    ['exigence', `/p/SHOP/requirements/${exigence}`],
    ['tests', '/p/SHOP/tests'],
    ['test', `/p/SHOP/tests/${testCase}`],
    ['exploratoire', '/p/SHOP/exploratory'],
    ['planification', '/p/SHOP/planning'],
    ['campagnes', '/p/SHOP/campaigns'],
    ['campagne', '/p/SHOP/campaigns/CMP-2'],
    ['mes-executions', '/p/SHOP/my-executions'],
    ['tracabilite', '/p/SHOP/traceability'],
    ['anomalies', '/p/SHOP/defects'],
    ['rapports', '/p/SHOP/reports'],
    ['rapport', `/p/SHOP/reports/${rapport}`],
  ];
  for (const [nom, chemin] of ecrans) {
    await test.step(`Écran ${nom}`, async () => {
      await page.goto(chemin);
      await controler(page, nom);
    });
  }

  await test.step('Thème sombre : tableau de bord et backlog', async () => {
    await page.goto('/p/SHOP/dashboard');
    await page.getByTestId('theme-toggle').click();
    await controler(page, 'tableau-de-bord-sombre');
    await page.goto('/p/SHOP/backlog');
    await controler(page, 'backlog-sombre');
    await page.getByTestId('theme-toggle').click();
  });
});
