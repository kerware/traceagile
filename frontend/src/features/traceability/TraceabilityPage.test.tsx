import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import type { MatrixResponse } from '../../api/traceability';
import { renderRoutes } from '../../test/render';
import { node } from '../../test/requirements';
import { server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { TraceabilityPage } from './TraceabilityPage';

const routes = [{ path: '/p/:key/traceability', element: <TraceabilityPage /> }];
const P = '/api/v1/projects/SHOP';

const VIEWER: Schemas['MeResponse'] = { ...TESTER, login: 'viewer', projects: [{ key: 'SHOP', name: 'Boutique', role: 'VIEWER' }] };

const MATRIX: MatrixResponse = {
  scope: 'project',
  requirements: [
    { key: 'REQ-1', title: 'Panier', type: 'EPIC', status: 'DRAFT', depth: 0, leaf: false, verificationStatus: 'SUSPECT' },
    { key: 'REQ-3', title: 'Ajouter au panier', type: 'USER_STORY', status: 'READY', parentKey: 'REQ-1', depth: 1, leaf: true, verificationStatus: 'SUSPECT' },
    { key: 'REQ-4', title: 'Vider le panier', type: 'USER_STORY', status: 'DRAFT', parentKey: 'REQ-1', depth: 1, leaf: true, verificationStatus: 'NOT_COVERED' },
  ],
  tests: [
    { key: 'TC-1', title: 'Ajouter', kind: 'MANUAL', status: 'NEEDS_UPDATE' },
    { key: 'TC-2', title: 'Vider', kind: 'MANUAL', status: 'READY' },
  ],
  cells: [
    { requirementKey: 'REQ-3', testKey: 'TC-1', linkId: 'l1', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [1], suspect: true, version: 0 },
  ],
};

function serve(requests: URL[] = []) {
  server.use(
    http.get(`${P}/traceability/matrix`, ({ request }) => {
      requests.push(new URL(request.url));
      return HttpResponse.json(MATRIX);
    }),
    http.get(`${P}/requirements/tree`, () =>
      HttpResponse.json([node('REQ-1', { title: 'Panier', children: [node('REQ-3', { type: 'USER_STORY', title: 'Ajouter au panier', parentKey: 'REQ-1' })] })]),
    ),
  );
}

describe('§13.2 /p/:key/traceability — matrice (F-TRA-04)', () => {
  it('lignes dans l’ordre de l’arbre avec leur statut, colonnes de tests, cellule suspecte', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    renderRoutes(routes, '/p/SHOP/traceability');

    const row = await screen.findByTestId('matrix-row-REQ-3');
    expect(within(row).getByText('Ajouter au panier')).toBeInTheDocument();
    expect(screen.getByTestId('matrix-status-REQ-3')).toHaveAttribute('data-status', 'SUSPECT');
    expect(screen.getByTestId('matrix-test-TC-2')).toBeInTheDocument();
    expect(screen.getByTestId('matrix-cell-REQ-3-TC-1')).toHaveTextContent('V');
  });

  it('F-TRA-01 clic sur une cellule vide : lien « vérifie » créé', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    let body: unknown;
    server.use(
      http.post(`${P}/trace-links`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json({ id: 'l2', testKey: 'TC-2', requirementKey: 'REQ-4', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [], suspect: false, version: 0 }, { status: 201 });
      }),
    );
    renderRoutes(routes, '/p/SHOP/traceability');

    await userEvent.click(await screen.findByTestId('matrix-cell-REQ-4-TC-2'));

    await waitFor(() => expect(body).toEqual({ requirementKey: 'REQ-4', testKey: 'TC-2', linkType: 'VERIFIES' }));
  });

  it('F-TRA-02 / §3.3-7 cellule liée : changer le type, marquer revu', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    let patched: unknown;
    let reviewed = false;
    server.use(
      http.patch(`${P}/trace-links/l1`, async ({ request }) => {
        patched = await request.json();
        return HttpResponse.json({ ...MATRIX.cells[0], id: 'l1', testKey: 'TC-1', requirementKey: 'REQ-3', linkType: 'PARTIALLY_VERIFIES' });
      }),
      http.post(`${P}/trace-links/l1/review`, () => {
        reviewed = true;
        return HttpResponse.json({ id: 'l1', testKey: 'TC-1', requirementKey: 'REQ-3', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [1], suspect: false, version: 1 });
      }),
    );
    renderRoutes(routes, '/p/SHOP/traceability');

    await userEvent.click(await screen.findByTestId('matrix-cell-REQ-3-TC-1'));
    expect(await screen.findByTestId('link-suspect')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('link-review'));
    await waitFor(() => expect(reviewed).toBe(true));

    await userEvent.click(screen.getByTestId('matrix-cell-REQ-3-TC-1'));
    await userEvent.click(await screen.findByText('Vérifie partiellement'));
    await waitFor(() => expect(patched).toEqual({ linkType: 'PARTIALLY_VERIFIES' }));
  });

  it('options dans l’URL et transmises à l’API : périmètre, tous les tests', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const requests: URL[] = [];
    serve(requests);
    const { router } = renderRoutes(routes, '/p/SHOP/traceability?scope=requirement:REQ-1');

    await screen.findByTestId('matrix-row-REQ-3');
    expect(requests.at(-1)?.searchParams.get('scope')).toBe('requirement:REQ-1');
    await userEvent.click(screen.getByTestId('matrix-all-tests'));

    await waitFor(() => expect(router.state.location.search).toContain('tests=all'));
    await waitFor(() => expect(requests.at(-1)?.searchParams.get('tests')).toBe('all'));
  });

  it('§2.2 un lecteur ne crée pas de lien : cellules vides inertes', async () => {
    useAuthStore.getState().setSession('jwt', VIEWER);
    serve();
    renderRoutes(routes, '/p/SHOP/traceability');

    await screen.findByTestId('matrix-row-REQ-4');
    expect(screen.queryByTestId('matrix-cell-REQ-4-TC-2')).not.toBeInTheDocument();
  });
});

describe('§7.2 couverture, F-TRA-06 orphelins, F-TRA-07 impact', () => {
  const indicator = (numerator: number, denominator: number) => ({ numerator, denominator, percent: denominator ? (numerator * 100) / denominator : undefined });

  it('les cinq indicateurs et le détail par exigence', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    server.use(
      http.get(`${P}/coverage`, () =>
        HttpResponse.json({
          scope: 'project', design: indicator(1, 2), criteria: indicator(1, 4), execution: indicator(0, 1), validation: indicator(0, 1),
          riskWeighted: indicator(4, 6),
          requirements: [{ key: 'REQ-3', title: 'Ajouter au panier', type: 'USER_STORY', depth: 1, leaf: true, riskLevel: 'HIGH', verificationStatus: 'NOT_RUN', coveringTests: 1, executedTests: 0, passedTests: 0 }],
        }),
      ),
    );
    renderRoutes(routes, '/p/SHOP/traceability?tab=coverage');

    expect(await screen.findByTestId('indicator-design-value')).toHaveTextContent('50 %');
    expect(screen.getByTestId('indicator-riskWeighted-value')).toHaveTextContent('66,7 %');
    expect(within(screen.getByTestId('coverage-row-REQ-3')).getByText('Non exécutée')).toBeInTheDocument();
  });

  it('orphelins : exigences sans test, tests sans exigence, automatisés jamais exécutés', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    server.use(
      http.get(`${P}/traceability/orphans`, () =>
        HttpResponse.json({
          requirementsWithoutTests: [{ key: 'REQ-4', title: 'Vider le panier', type: 'USER_STORY', status: 'DRAFT', riskLevel: 'MEDIUM' }],
          testsWithoutRequirement: [{ key: 'TC-9', title: 'Orphelin', kind: 'MANUAL', status: 'READY' }],
          defectsWithoutRequirement: [],
          automatedNeverExecuted: [{ key: 'TC-12', title: 'API', kind: 'AUTOMATED', technique: 'API', status: 'READY' }],
        }),
      ),
    );
    renderRoutes(routes, '/p/SHOP/traceability?tab=orphans');

    expect(await within(await screen.findByTestId('orphans-requirements')).findByText('REQ-4')).toBeInTheDocument();
    expect(within(screen.getByTestId('orphans-tests')).getByText('TC-9')).toBeInTheDocument();
    expect(within(screen.getByTestId('orphans-never-executed')).getByText('TC-12')).toBeInTheDocument();
  });

  it('impact : tests à revoir, suspicion, revue', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    let reviewed = false;
    server.use(
      http.get(`${P}/requirements/REQ-1/impact`, () =>
        HttpResponse.json({
          requirement: { key: 'REQ-1', title: 'Panier', type: 'EPIC', status: 'DRAFT', riskLevel: 'MEDIUM' },
          tests: [{ test: { key: 'TC-1', title: 'Ajouter', kind: 'MANUAL', status: 'NEEDS_UPDATE' },
            via: { key: 'REQ-3', title: 'Ajouter au panier', type: 'USER_STORY', status: 'READY', riskLevel: 'HIGH' }, linkId: 'l1', linkType: 'VERIFIES', suspect: true }],
          campaigns: [],
        }),
      ),
      http.post(`${P}/trace-links/l1/review`, () => {
        reviewed = true;
        return HttpResponse.json({ id: 'l1', testKey: 'TC-1', requirementKey: 'REQ-3', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [], suspect: false, version: 1 });
      }),
    );
    renderRoutes(routes, '/p/SHOP/traceability?tab=impact&requirement=REQ-1');

    expect(await screen.findByTestId('impact-summary')).toHaveTextContent('1 test à revoir');
    await userEvent.click(screen.getByTestId('impact-review-TC-1'));
    await waitFor(() => expect(reviewed).toBe(true));
  });
});
