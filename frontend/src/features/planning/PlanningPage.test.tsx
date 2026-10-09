import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import type { ReleaseResponse, SprintDetail, SprintSummary } from '../../api/planning';
import { renderRoutes } from '../../test/render';
import { summary } from '../../test/requirements';
import { ADMIN, page, server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { PlanningPage } from './PlanningPage';

const routes = [{ path: '/p/:key/planning', element: <PlanningPage /> }];
const P = '/api/v1/projects/SHOP';
const PO: Schemas['MeResponse'] = { ...TESTER, login: 'po', projects: [{ key: 'SHOP', name: 'Boutique', role: 'PRODUCT_OWNER' }] };

function sprint(key: string, overrides: Partial<SprintSummary> = {}): SprintSummary {
  return {
    key, name: `Sprint ${key.slice(4)}`, startDate: '2026-10-12', endDate: '2026-10-25', status: 'PLANNED', capacityPoints: 20,
    releaseKey: 'REL-1', loadPoints: 0, loadPercent: 0, overCapacity: false, donePoints: 0, requirementCount: 0, requirementKeys: [], version: 0,
    ...overrides,
  };
}

const SPRINTS = [
  sprint('SPR-1', { status: 'CLOSED', startDate: '2026-09-28', endDate: '2026-10-11', loadPoints: 13, loadPercent: 65, donePoints: 8, validationRate: 85 }),
  sprint('SPR-2', { status: 'ACTIVE', loadPoints: 18, loadPercent: 90, requirementKeys: ['REQ-3'] }),
  sprint('SPR-3', { startDate: '2026-10-26', endDate: '2026-11-08' }),
];
const RELEASE: ReleaseResponse = {
  key: 'REL-1', name: 'Version 2.0', goal: 'Paiement', startDate: '2026-09-28', endDate: '2026-11-08', status: 'ACTIVE', sprints: SPRINTS, version: 0,
};

function serve(detail?: SprintDetail) {
  server.use(
    http.get(`${P}/releases`, () => HttpResponse.json([RELEASE])),
    http.get(`${P}/sprints`, () => HttpResponse.json(SPRINTS)),
    http.get(`${P}/sprints/:key`, ({ params }) =>
      HttpResponse.json(detail ?? { sprint: SPRINTS.find((s) => s.key === params.key)!, scope: [], nextSprintKey: 'SPR-3' }),
    ),
    http.get(`${P}/requirements`, () =>
      HttpResponse.json(page([summary('REQ-3', { status: 'READY', storyPoints: 5 }), summary('REQ-7', { status: 'READY', title: 'Payer par carte', storyPoints: 8 })])),
    ),
  );
}

describe('§13.2 /p/:key/planning — feuille de route (F-PLN-02)', () => {
  it('frise des sprints de la release avec statut, charge et taux de validation', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    serve();
    renderRoutes(routes, '/p/SHOP/planning');

    const release = await screen.findByTestId('release-REL-1');
    expect(within(release).getByText('Version 2.0')).toBeInTheDocument();
    expect(within(screen.getByTestId('sprint-block-SPR-1')).getByText('Clos')).toBeInTheDocument();
    expect(screen.getByTestId('sprint-validation-SPR-1')).toHaveTextContent('validation 85 %');
    expect(screen.getByTestId('release-new')).toBeInTheDocument();
  });

  it('§2.2 le testeur consulte sans pouvoir planifier', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    renderRoutes(routes, '/p/SHOP/planning');

    await screen.findByTestId('release-REL-1');
    expect(screen.queryByTestId('release-new')).not.toBeInTheDocument();
    expect(screen.queryByTestId('release-generate-REL-1')).not.toBeInTheDocument();
  });

  it('F-PLN-01 créer une release puis générer 3 sprints de 2 semaines', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve();
    const bodies: unknown[] = [];
    server.use(
      http.post(`${P}/releases`, async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json({ ...RELEASE, key: 'REL-2', sprints: [] }, { status: 201 });
      }),
      http.post(`${P}/releases/REL-1/generate-sprints`, async ({ request }) => {
        bodies.push(await request.json());
        return HttpResponse.json(RELEASE);
      }),
    );
    renderRoutes(routes, '/p/SHOP/planning');

    await userEvent.click(await screen.findByTestId('release-new'));
    await userEvent.type(screen.getByTestId('release-name'), 'Version 3.0');
    await userEvent.type(screen.getByTestId('release-start'), '2026-11-09');
    await userEvent.type(screen.getByTestId('release-end'), '2026-12-20');
    await userEvent.click(screen.getByTestId('release-submit'));
    await waitFor(() => expect(bodies[0]).toEqual({ name: 'Version 3.0', startDate: '2026-11-09', endDate: '2026-12-20' }));

    await userEvent.click(screen.getByTestId('release-generate-REL-1'));
    await userEvent.click(await screen.findByTestId('generate-submit'));
    await waitFor(() => expect(bodies[1]).toEqual({ count: 3, durationWeeks: 2 }));
  });

  it('cliquer sur un sprint ouvre sa planification', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    serve();
    const { router } = renderRoutes(routes, '/p/SHOP/planning');

    await userEvent.click(await screen.findByTestId('sprint-block-SPR-3'));
    await waitFor(() => expect(router.state.location.search).toContain('sprint=SPR-3'));
  });
});

describe('F-PLN-05 / F-PLN-06 planification d’un sprint', () => {
  const detail: SprintDetail = {
    sprint: { ...SPRINTS[1]!, loadPoints: 23, loadPercent: 115, overCapacity: true, requirementKeys: ['REQ-3'] },
    scope: [{ key: 'REQ-3', title: 'Rechercher', type: 'USER_STORY', status: 'IN_SPRINT', priority: 'MUST', storyPoints: 5, outcome: 'PLANNED', verificationStatus: 'NOT_RUN' }],
    nextSprintKey: 'SPR-3',
  };

  it('backlog prêt à gauche, périmètre à droite, ajout au sprint ; jauge et alerte au-delà de 100 %', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    serve(detail);
    let body: unknown;
    server.use(
      http.put(`${P}/sprints/SPR-2/scope`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(detail);
      }),
    );
    renderRoutes(routes, '/p/SHOP/planning?tab=sprint');

    expect(await screen.findByTestId('sprint-item-REQ-3')).toBeInTheDocument();
    expect(await screen.findByTestId('backlog-item-REQ-7')).toBeInTheDocument();
    expect(screen.queryByTestId('backlog-item-REQ-3')).not.toBeInTheDocument();
    expect(screen.getByTestId('capacity-label')).toHaveTextContent('23 / 20 points (115 %)');
    expect(screen.getByTestId('over-capacity')).toHaveTextContent('Capacité dépassée de 3 points.');

    await userEvent.click(screen.getByTestId('plan-add-REQ-7'));
    await waitFor(() => expect(body).toEqual({ requirementKeys: ['REQ-3', 'REQ-7'] }));
  });

  it('clôture : chaque story non terminée est reportée (défaut s’il existe un sprint suivant) ou renvoyée au backlog', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    serve(detail);
    let body: unknown;
    server.use(
      http.post(`${P}/sprints/SPR-2/close`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json({ ...detail, sprint: { ...detail.sprint, status: 'CLOSED' } });
      }),
    );
    renderRoutes(routes, '/p/SHOP/planning?tab=sprint&sprint=SPR-2');

    await userEvent.click(await screen.findByTestId('sprint-close'));
    expect(await screen.findByTestId('close-item-REQ-3')).toBeInTheDocument();
    await userEvent.click(screen.getByText('Backlog'));
    await userEvent.click(screen.getByTestId('close-sprint-submit'));

    await waitFor(() => expect(body).toEqual({ decisions: [{ requirementKey: 'REQ-3', action: 'BACKLOG' }] }));
  });

  it('démarrer un sprint planifié', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    serve();
    let started = false;
    server.use(
      http.post(`${P}/sprints/SPR-3/start`, () => {
        started = true;
        return HttpResponse.json({ sprint: { ...SPRINTS[2]!, status: 'ACTIVE' }, scope: [], nextSprintKey: null });
      }),
    );
    renderRoutes(routes, '/p/SHOP/planning?tab=sprint&sprint=SPR-3');

    await userEvent.click(await screen.findByTestId('sprint-start'));
    await waitFor(() => expect(started).toBe(true));
  });
});
