import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { useAuthStore } from '../auth/authStore';
import { renderRoutes } from '../../test/render';
import { detail, node, summary } from '../../test/requirements';
import { ADMIN, page, problem, server } from '../../test/server';
import { BacklogPage } from './BacklogPage';

const routes = [{ path: '/p/:key/backlog', element: <BacklogPage /> }];

function withRequirements(requests: URL[]) {
  server.use(
    http.get('/api/v1/projects/SHOP/requirements', ({ request }) => {
      requests.push(new URL(request.url));
      return HttpResponse.json(page([summary('REQ-3', { title: 'Livraison gratuite', storyPoints: 13, needsSplitting: true }), summary('REQ-4')]));
    }),
    http.get('/api/v1/projects/SHOP/requirements/tree', () =>
      HttpResponse.json([node('REQ-1', { title: 'Catalogue', children: [node('REQ-2', { type: 'FEATURE', title: 'Recherche', parentKey: 'REQ-1' })] })]),
    ),
  );
}

describe('§13.2 /p/:key/backlog — Backlog (F-REQ-01)', () => {
  it('vue liste : lignes avec clé, statut et alerte « à découper »', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    withRequirements([]);
    renderRoutes(routes, '/p/SHOP/backlog?view=list');

    const row = await screen.findByTestId('requirement-row-REQ-3');
    expect(within(row).getByText('Livraison gratuite')).toBeInTheDocument();
    expect(within(row).getByText('Brouillon')).toBeInTheDocument();
    expect(within(row).getByTestId('split-alert')).toBeInTheDocument();
  });

  it('F-REQ-01 filtres et F-REQ-04 recherche reflétés dans l’URL et transmis à l’API', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    const requests: URL[] = [];
    withRequirements(requests);
    const { router } = renderRoutes(routes, '/p/SHOP/backlog?view=list&type=USER_STORY');

    await screen.findByTestId('requirement-row-REQ-3');
    await userEvent.type(screen.getByTestId('backlog-search'), 'livraison{enter}');

    await waitFor(() => expect(router.state.location.search).toContain('q=livraison'));
    await waitFor(() => expect(requests.at(-1)?.searchParams.get('q')).toBe('livraison'));
    expect(requests.at(-1)?.searchParams.getAll('type')).toEqual(['USER_STORY']);
  });

  it('vue arbre : épic > feature, repliable', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    withRequirements([]);
    renderRoutes(routes, '/p/SHOP/backlog');

    expect(await screen.findByTestId('tree-node-REQ-1')).toBeInTheDocument();
    expect(screen.getByTestId('tree-node-REQ-2')).toBeInTheDocument();

    await userEvent.click(screen.getByTestId('tree-toggle-REQ-1'));
    expect(screen.queryByTestId('tree-node-REQ-2')).not.toBeInTheDocument();
  });

  it('F-REQ-23 import CSV : affiche les erreurs par ligne', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    withRequirements([]);
    server.use(
      http.post('/api/v1/projects/SHOP/requirements/import', () =>
        HttpResponse.json(
          { status: 422, code: 'CSV_INVALID', detail: '1 ligne(s) en erreur, rien n’a été importé.', lineErrors: [{ line: 3, message: 'Type inconnu' }] },
          { status: 422 },
        ),
      ),
    );
    renderRoutes(routes, '/p/SHOP/backlog');

    await userEvent.click(await screen.findByTestId('backlog-import'));
    const file = new File(['type;title\nX;Y\n'], 'backlog.csv', { type: 'text/csv' });
    await userEvent.upload(screen.getByTestId('csv-file-input'), file);
    await userEvent.click(screen.getByTestId('csv-submit'));

    expect(await screen.findByText('Type inconnu')).toBeInTheDocument();
    expect(screen.getByTestId('csv-error-line-3')).toBeInTheDocument();
  });

  it('§3.3-1 création : une user story exige un parent', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    withRequirements([]);
    let body: unknown;
    server.use(
      http.post('/api/v1/projects/SHOP/requirements', async ({ request }) => {
        body = await request.json();
        return problem(422, 'REQ_PARENT_REQUIRED', 'Une USER_STORY doit avoir un parent FEATURE ou EPIC.');
      }),
    );
    renderRoutes(routes, '/p/SHOP/backlog');

    await userEvent.click(await screen.findByTestId('backlog-new'));
    await userEvent.type(screen.getByTestId('requirement-title-input'), 'Orpheline');
    await userEvent.click(screen.getByTestId('requirement-create-submit'));

    expect(await screen.findByText('Une user story doit avoir une feature ou une épic parente.')).toBeInTheDocument();
    expect(body).toBeUndefined();
  });

  it('menu contextuel de l’arbre : exigence enfant (type et parent pré-remplis) et test lié', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    withRequirements([]);
    server.use(http.get('/api/v1/reference/frameworks', () => HttpResponse.json([])));
    renderRoutes(routes, '/p/SHOP/backlog');

    fireEvent.contextMenu(await screen.findByTestId('tree-node-REQ-1'));
    await userEvent.click(await screen.findByTestId('menu-add-child'));
    expect(await screen.findByTestId('requirement-type-input')).toHaveValue('Feature');
    expect(screen.getByTestId('requirement-parent-input')).toHaveValue('REQ-1 — Catalogue');
    await userEvent.keyboard('{Escape}');

    await userEvent.click(screen.getByTestId('tree-node-REQ-2-menu'));
    await userEvent.click(await screen.findByTestId('menu-add-test'));
    expect(await screen.findByTestId('test-requirement-input')).toHaveValue('REQ-2 — Recherche');
  });

  it('vue tableau : user stories et ENF en trois colonnes ; le menu « ⋯ » passe une story en sprint à « Terminée » après la DoD', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    const requests: URL[] = [];
    let changed: unknown;
    server.use(
      http.get('/api/v1/projects/SHOP/requirements', ({ request }) => {
        const url = new URL(request.url);
        requests.push(url);
        const statuses = url.searchParams.getAll('status');
        if (statuses.includes('IN_SPRINT')) return HttpResponse.json(page([summary('REQ-5', { status: 'IN_SPRINT', title: 'Payer par carte', storyPoints: 5 })]));
        if (statuses.includes('DONE')) return HttpResponse.json(page([summary('REQ-6', { status: 'ACCEPTED', type: 'NON_FUNCTIONAL', title: 'Temps de réponse' })]));
        return HttpResponse.json(page([summary('REQ-3', { title: 'Livraison gratuite', storyPoints: 3 }), summary('REQ-4', { status: 'READY', storyPoints: 2 })]));
      }),
      http.get('/api/v1/projects/SHOP/requirements/REQ-5', () => HttpResponse.json(detail('REQ-5', { status: 'IN_SPRINT', allowedTransitions: ['READY', 'DONE', 'OBSOLETE'] }))),
      http.get('/api/v1/projects/SHOP/requirements/REQ-5/checklists', () => HttpResponse.json({ dor: [], dod: [] })),
      http.post('/api/v1/projects/SHOP/requirements/REQ-5/status', async ({ request }) => {
        changed = await request.json();
        return HttpResponse.json(detail('REQ-5', { status: 'DONE' }));
      }),
    );
    renderRoutes(routes, '/p/SHOP/backlog?view=board');

    expect(await within(await screen.findByTestId('board-column-todo')).findByTestId('board-card-REQ-3')).toBeInTheDocument();
    expect(screen.getByTestId('board-count-todo')).toHaveTextContent('2');
    expect(within(screen.getByTestId('board-column-todo')).getByText('5 pts')).toBeInTheDocument();
    expect(await within(screen.getByTestId('board-column-doing')).findByTestId('board-card-REQ-5')).toBeInTheDocument();
    expect(await within(screen.getByTestId('board-column-done')).findByTestId('board-card-REQ-6')).toBeInTheDocument();
    expect(requests[0]?.searchParams.getAll('type')).toEqual(['USER_STORY', 'NON_FUNCTIONAL']);
    expect(requests.map((r) => r.searchParams.getAll('status').join(','))).toEqual(
      expect.arrayContaining(['DRAFT,TO_REFINE,READY', 'IN_SPRINT', 'DONE,ACCEPTED']));

    await userEvent.click(screen.getByTestId('board-menu-REQ-5'));
    await userEvent.click(await screen.findByTestId('board-move-REQ-5-done'));
    await userEvent.click(await screen.findByTestId('status-confirm'));

    await waitFor(() => expect(changed).toEqual({ status: 'DONE', acknowledgeUnmet: false }));
  });
});
