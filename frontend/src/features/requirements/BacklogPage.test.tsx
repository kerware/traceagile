import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { useAuthStore } from '../auth/authStore';
import { renderRoutes } from '../../test/render';
import { node, summary } from '../../test/requirements';
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
});
