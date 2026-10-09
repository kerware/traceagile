import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import { renderRoutes } from '../../test/render';
import { page, server, TESTER } from '../../test/server';
import { testDetail, testSummary } from '../../test/testcases';
import { useAuthStore } from '../auth/authStore';
import { TestsPage } from './TestsPage';

const routes = [{ path: '/p/:key/tests', element: <TestsPage /> }];

const DEVELOPER: Schemas['MeResponse'] = { ...TESTER, login: 'dev', projects: [{ key: 'SHOP', name: 'Boutique', role: 'DEVELOPER' }] };

function serveRepository(requests: URL[] = []) {
  server.use(
    http.get('/api/v1/projects/SHOP/test-cases', ({ request }) => {
      requests.push(new URL(request.url));
      return HttpResponse.json(page([testSummary('TC-1', { title: 'Ajouter au panier', automationCandidate: true }), testSummary('TC-2', { kind: 'AUTOMATED', technique: 'API', framework: 'REST Assured' })]));
    }),
    http.get('/api/v1/projects/SHOP/test-cases/tree', ({ request }) =>
      HttpResponse.json(
        new URL(request.url).searchParams.get('groupBy') === 'feature'
          ? [{ name: 'Livraison', tests: [testSummary('TC-5', { kind: 'AUTOMATED', technique: 'BDD' })] }]
          : [{ name: 'Panier', tests: [testSummary('TC-1')] }, { name: '', tests: [testSummary('TC-2')] }],
      ),
    ),
    http.get('/api/v1/reference/frameworks', () =>
      HttpResponse.json([{ technique: 'API', name: 'REST Assured', position: 1 }, { technique: 'BDD', name: 'Cucumber-JVM', position: 1 }]),
    ),
    http.get('/api/v1/projects/SHOP/requirements/tree', () => HttpResponse.json([])),
  );
}

describe('§13.2 /p/:key/tests — référentiel de tests', () => {
  it('arbre par dossier puis par feature', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveRepository();
    renderRoutes(routes, '/p/SHOP/tests');

    const panier = await screen.findByTestId('test-group-Panier');
    expect(within(panier).getByText('TC-1')).toBeInTheDocument();
    expect(screen.getByText('(non classé)')).toBeInTheDocument();

    await userEvent.click(screen.getByText('Par feature'));
    expect(await screen.findByTestId('test-group-Livraison')).toBeInTheDocument();
  });

  it('§12 filtres dans l’URL et transmis à l’API (nature, orphelins, candidats F-MAN-02)', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const requests: URL[] = [];
    serveRepository(requests);
    const { router } = renderRoutes(routes, '/p/SHOP/tests?view=list&kind=MANUAL');

    const row = await screen.findByTestId('test-row-TC-1');
    expect(within(row).getByText('Candidat')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('filter-orphan'));

    await waitFor(() => expect(router.state.location.search).toContain('orphan=true'));
    await waitFor(() => expect(requests.at(-1)?.searchParams.get('orphan')).toBe('true'));
    expect(requests.at(-1)?.searchParams.getAll('kind')).toEqual(['MANUAL']);
  });

  it('Lot 2 : création d’un test automatisé, framework proposé par la donnée de référence', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveRepository();
    let body: Record<string, unknown> | undefined;
    server.use(
      http.post('/api/v1/projects/SHOP/test-cases', async ({ request }) => {
        body = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json(testDetail('TC-9', { kind: 'AUTOMATED' }), { status: 201 });
      }),
      http.get('/api/v1/projects/SHOP/test-cases/TC-9', () => HttpResponse.json(testDetail('TC-9', { kind: 'AUTOMATED' }))),
    );
    renderRoutes(routes, '/p/SHOP/tests');

    await userEvent.click(await screen.findByTestId('tests-new'));
    await userEvent.click(screen.getByRole('radio', { name: 'Automatisé' }));
    await userEvent.type(screen.getByTestId('test-title-input'), 'API panier');
    await userEvent.click(screen.getByTestId('test-technique-input'));
    await userEvent.click(await screen.findByRole('option', { name: 'API' }));
    await userEvent.click(screen.getByTestId('test-create-submit'));

    await waitFor(() => expect(body).toMatchObject({ kind: 'AUTOMATED', title: 'API panier', technique: 'API', framework: 'REST Assured' }));
  });

  it('§2.2 le développeur ne crée que des tests automatisés', async () => {
    useAuthStore.getState().setSession('jwt', DEVELOPER);
    serveRepository();
    renderRoutes(routes, '/p/SHOP/tests');

    await userEvent.click(await screen.findByTestId('tests-new'));

    expect(screen.queryByRole('radio', { name: 'Manuel' })).not.toBeInTheDocument();
    expect(screen.getByRole('radio', { name: 'Automatisé' })).toBeChecked();
  });

  it('ADR-0013 dossiers imbriqués, vides compris ; menu contextuel : sous-dossier et test rangé dans le dossier', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveRepository();
    let created: unknown;
    server.use(
      http.get('/api/v1/projects/SHOP/test-cases/tree', () =>
        HttpResponse.json([{ name: 'Panier', tests: [testSummary('TC-1')] }, { name: 'Panier/Remises', tests: [] }]),
      ),
      http.get('/api/v1/projects/SHOP/test-folders', () => HttpResponse.json(['Panier', 'Panier/Remises'])),
      http.post('/api/v1/projects/SHOP/test-folders', async ({ request }) => {
        created = await request.json();
        return HttpResponse.json({ path: 'Panier/Promotions' }, { status: 201 });
      }),
    );
    renderRoutes(routes, '/p/SHOP/tests');

    const panier = await screen.findByTestId('test-group-Panier');
    expect(within(panier).getByTestId('test-group-Panier/Remises')).toHaveTextContent('Dossier vide');

    // clic droit sur le dossier
    fireEvent.contextMenu(screen.getByTestId('tree-folder-Panier'));
    expect(await screen.findByTestId('menu-delete-folder')).toBeDisabled();
    await userEvent.click(screen.getByTestId('menu-new-folder'));
    await userEvent.type(await screen.findByTestId('prompt-input'), 'Promotions');
    await userEvent.click(screen.getByTestId('prompt-submit'));
    await waitFor(() => expect(created).toEqual({ path: 'Panier/Promotions' }));

    // bouton « ⋯ » du sous-dossier
    await userEvent.click(screen.getByTestId('tree-folder-Panier/Remises-menu'));
    await userEvent.click(await screen.findByTestId('menu-new-test'));
    expect(await screen.findByTestId('test-folder-input')).toHaveValue('Panier/Remises');
  });

  it('ADR-0013 renommer un dossier ; ranger un test ; le développeur ne range pas un test manuel', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveRepository();
    let moved: unknown;
    let patched: unknown;
    server.use(
      http.get('/api/v1/projects/SHOP/test-folders', () => HttpResponse.json(['Panier'])),
      http.post('/api/v1/projects/SHOP/test-folders/move', async ({ request }) => {
        moved = await request.json();
        return HttpResponse.json({ path: 'Commande/Panier', movedTests: 1 });
      }),
      http.patch('/api/v1/projects/SHOP/test-cases/TC-2', async ({ request }) => {
        patched = await request.json();
        return HttpResponse.json(testDetail('TC-2'));
      }),
    );
    renderRoutes(routes, '/p/SHOP/tests');

    await userEvent.click(await screen.findByTestId('tree-folder-Panier-menu'));
    await userEvent.click(await screen.findByTestId('menu-rename-folder'));
    const input = await screen.findByTestId('prompt-input');
    expect(input).toHaveValue('Panier');
    await userEvent.clear(input);
    await userEvent.type(input, 'Commande/Panier');
    await userEvent.click(screen.getByTestId('prompt-submit'));
    await waitFor(() => expect(moved).toEqual({ from: 'Panier', to: 'Commande/Panier' }));

    await userEvent.click(screen.getByTestId('tree-test-row-TC-2-menu'));
    await userEvent.click(await screen.findByTestId('menu-move-test'));
    await userEvent.type(await screen.findByTestId('prompt-input'), 'Panier');
    await userEvent.click(screen.getByTestId('prompt-submit'));
    await waitFor(() => expect(patched).toEqual({ folder: 'Panier' }));
  });

  it('§2.2 menu d’un test manuel pour le développeur : consultation seulement', async () => {
    useAuthStore.getState().setSession('jwt', DEVELOPER);
    serveRepository();
    server.use(http.get('/api/v1/projects/SHOP/test-folders', () => HttpResponse.json(['Panier'])));
    renderRoutes(routes, '/p/SHOP/tests');

    await userEvent.click(await screen.findByTestId('tree-test-row-TC-1-menu'));
    expect(await screen.findByTestId('menu-open-test')).toBeInTheDocument();
    expect(screen.queryByTestId('menu-move-test')).not.toBeInTheDocument();
    expect(screen.queryByTestId('menu-delete-test')).not.toBeInTheDocument();
  });
});
