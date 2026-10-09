import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { CampaignDetail, DefectDetail, ExecutionDetail, MyExecution } from '../../api/campaigns';
import type { Schemas } from '../../api/client';
import { renderRoutes } from '../../test/render';
import { server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { CampaignPage } from './CampaignPage';
import { DefectsPage } from './DefectsPage';
import { ExecutionPage } from './ExecutionPage';
import { currentStepIndex, duration, minutes } from './model';
import { MyExecutionsPage } from './MyExecutionsPage';

const P = '/api/v1/projects/SHOP';
const VIEWER: Schemas['MeResponse'] = { ...TESTER, login: 'viewer', projects: [{ key: 'SHOP', name: 'Boutique', role: 'VIEWER' }] };
const routes = [
  { path: '/p/:key/campaigns/:ck', element: <CampaignPage /> },
  { path: '/p/:key/executions/:id', element: <ExecutionPage /> },
  { path: '/p/:key/my-executions', element: <MyExecutionsPage /> },
  { path: '/p/:key/defects', element: <DefectsPage /> },
];

const test1 = { key: 'TC-1', title: 'Ajouter un produit', kind: 'MANUAL' as const, status: 'READY' as const, priority: 'MUST' as const, currentVersion: 1, durationMin: 10 };
const progress = { total: 2, byStatus: { NOT_RUN: 1, FAILED: 1 }, executed: 1, executedPercent: 50, passRate: 0 };
const CAMPAIGN: CampaignDetail = {
  campaign: { key: 'CMP-1', name: 'Recette SPR-1', scopeType: 'SPRINT', sprintKey: 'SPR-1', environment: 'recette', buildVersion: '2.0.0-rc1', status: 'IN_PROGRESS', progress, version: 0 },
  items: [
    { id: 'i1', position: 1, test: test1, testCaseVersion: 1, executedByServer: false, riskScore: 16, lastStatus: 'NOT_RUN', attempts: 0 },
    { id: 'i2', position: 2, test: { ...test1, key: 'TC-3', title: 'API panier', kind: 'AUTOMATED', technique: 'API' }, testCaseVersion: 1, executedByServer: true, riskScore: 12, lastStatus: 'FAILED', attempts: 1, latestExecutionId: 'x2' },
  ],
  workload: [{ tests: 1, manualMinutes: 10, exploratoryMinutes: 0, unestimated: 0 }],
};

const EXECUTION: ExecutionDetail = {
  id: 'e1', itemId: 'i1', test: test1, campaign: { key: 'CMP-1', name: 'Recette SPR-1', environment: 'recette', buildVersion: '2.0.0-rc1', status: 'IN_PROGRESS' },
  attempt: 1, testCaseVersion: 1, status: 'RUNNING', derivedStatus: 'RUNNING', statusOverridden: false, startedAt: '2026-10-09T09:00:00Z', origin: 'MANUAL',
  parameterValues: {}, defects: [], editable: true, dataSets: [],
  attempts: [{ id: 'e1', attempt: 1, status: 'RUNNING', startedAt: '2026-10-09T09:00:00Z', origin: 'MANUAL' }],
  steps: [
    { position: 1, action: 'Ouvrir la fiche', expectedResult: 'La fiche s’affiche', status: 'NOT_RUN' },
    { position: 2, action: 'Ajouter au panier', expectedResult: 'Total 2,50 €', status: 'NOT_RUN' },
  ],
};

function serveCampaign() {
  server.use(
    http.get(`${P}/campaigns/CMP-1`, () => HttpResponse.json(CAMPAIGN)),
    http.get(`${P}/testers`, () => HttpResponse.json([{ login: 'qa1', displayName: 'Quentin' }, { login: 'qa2', displayName: 'Quitterie' }])),
    http.get(`${P}/campaigns`, () => HttpResponse.json([CAMPAIGN.campaign])),
    http.get(`${P}/sprints`, () => HttpResponse.json([])),
    http.get(`${P}/requirements/tree`, () => HttpResponse.json([])),
  );
}

describe('§13.2 /p/:key/campaigns/:ck — campagne (F-CMP-02 à F-CMP-05)', () => {
  it('avancement, score de risque, serveur d’exécution pour les automatisés, charge par testeur', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveCampaign();
    renderRoutes(routes, '/p/SHOP/campaigns/CMP-1');

    const row = await screen.findByTestId('item-TC-3');
    expect(within(row).getByText('Serveur d’exécution'.replace('’', "'"))).toBeInTheDocument();
    expect(within(row).getByText('12')).toBeInTheDocument();
    expect(screen.getByTestId('campaign-progress')).toHaveTextContent('1 / 2 tests exécutés');
    expect(screen.getByTestId('workload-unassigned')).toHaveTextContent('10 min');
  });

  it('F-CMP-02 sélection par tag : requête et compte rendu (ajoutés, ignorés)', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveCampaign();
    let body: unknown;
    server.use(
      http.post(`${P}/campaigns/CMP-1/items/select`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json({ added: ['TC-2'], skipped: [{ testKey: 'TC-4', reason: 'NOT_READY_DRAFT' }], campaign: CAMPAIGN });
      }),
    );
    renderRoutes(routes, '/p/SHOP/campaigns/CMP-1');

    await userEvent.click(await screen.findByTestId('selection-strategy'));
    await userEvent.click(await screen.findByRole('option', { name: 'Tests par tag' }));
    await userEvent.type(screen.getByTestId('selection-tag'), 'smoke');
    await userEvent.click(screen.getByTestId('selection-submit'));

    await waitFor(() => expect(body).toEqual({ strategy: 'TAG', tag: 'smoke' }));
    expect(await screen.findByTestId('selection-result')).toHaveTextContent('1 test ajouté · ignorés : TC-4 (pas prêt)');
  });

  it('F-CMP-04 affectation d’un test manuel ; F-CMP-03 tri par risque', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serveCampaign();
    const calls: unknown[] = [];
    server.use(
      http.patch(`${P}/campaign-items/i1`, async ({ request }) => {
        calls.push(await request.json());
        return HttpResponse.json(CAMPAIGN.items[0]);
      }),
      http.post(`${P}/campaigns/CMP-1/items/sort-by-risk`, () => {
        calls.push('sort');
        return HttpResponse.json(CAMPAIGN);
      }),
    );
    renderRoutes(routes, '/p/SHOP/campaigns/CMP-1');

    await userEvent.click(await screen.findByTestId('assignee-TC-1'));
    await userEvent.click(await screen.findByRole('option', { name: 'Quitterie' }));
    await userEvent.click(screen.getByTestId('sort-by-risk'));

    await waitFor(() => expect(calls).toEqual([{ assignee: 'qa2' }, 'sort']));
  });

  it('§2.2 le lecteur consulte sans sélectionner ni exécuter', async () => {
    useAuthStore.getState().setSession('jwt', VIEWER);
    serveCampaign();
    renderRoutes(routes, '/p/SHOP/campaigns/CMP-1');

    await screen.findByTestId('item-TC-1');
    expect(screen.queryByTestId('selection-panel')).not.toBeInTheDocument();
    expect(screen.queryByTestId('execute-TC-1')).not.toBeInTheDocument();
  });
});

describe('§13.2 /p/:key/executions/:id — exécution pas à pas (F-EXE-01 à F-EXE-03)', () => {
  it('un pas réussi passe au suivant ; un pas en échec propose de créer l’anomalie pré-remplie', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let current = EXECUTION;
    const puts: unknown[] = [];
    let defect: unknown;
    server.use(
      http.get(`${P}/executions/e1`, () => HttpResponse.json(current)),
      http.put(`${P}/executions/e1/steps/:position`, async ({ request, params }) => {
        const body = (await request.json()) as { status: string; actualResult?: string };
        puts.push({ position: Number(params.position), ...body });
        current = {
          ...current,
          status: body.status === 'FAILED' ? 'FAILED' : current.status,
          steps: current.steps.map((s) => (s.position === Number(params.position) ? { ...s, status: body.status as never, actualResult: body.actualResult } : s)),
        };
        return HttpResponse.json(current);
      }),
      http.get(`${P}/executions/e1/defect-draft`, () =>
        HttpResponse.json({ title: 'TC-1 Ajouter un produit : échec au pas 2', description: '**Obtenu** : Total 0 €', severity: 'MAJOR', requirementKeys: ['REQ-2'] }),
      ),
      http.post(`${P}/executions/e1/defects`, async ({ request }) => {
        defect = await request.json();
        return HttpResponse.json({ defect: { key: 'DEF-1' } } as unknown as DefectDetail, { status: 201 });
      }),
      http.get(`${P}/requirements/tree`, () => HttpResponse.json([])),
    );
    renderRoutes(routes, '/p/SHOP/executions/e1');

    expect(await screen.findByTestId('step-action')).toHaveTextContent('Ouvrir la fiche');
    await userEvent.click(screen.getByTestId('step-PASSED'));
    await waitFor(() => expect(screen.getByTestId('step-action')).toHaveTextContent('Ajouter au panier'));
    await userEvent.type(screen.getByTestId('step-actual'), 'Total 0 €');
    await userEvent.click(screen.getByTestId('step-FAILED'));
    await waitFor(() => expect(puts).toEqual([{ position: 1, status: 'PASSED' }, { position: 2, status: 'FAILED', actualResult: 'Total 0 €' }]));

    await userEvent.click(await screen.findByTestId('create-defect'));
    expect(await screen.findByTestId('defect-title')).toHaveValue('TC-1 Ajouter un produit : échec au pas 2');
    await userEvent.click(screen.getByTestId('defect-submit'));
    await waitFor(() => expect(defect).toMatchObject({ title: 'TC-1 Ajouter un produit : échec au pas 2', severity: 'MAJOR', requirementKeys: ['REQ-2'] }));
  });

  it('F-EXE-02 statut forcé avec commentaire ; tentative ancienne en lecture seule', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let patch: unknown;
    server.use(
      http.get(`${P}/executions/e1`, () => HttpResponse.json(EXECUTION)),
      http.patch(`${P}/executions/e1`, async ({ request }) => {
        patch = await request.json();
        return HttpResponse.json({ ...EXECUTION, status: 'BLOCKED', statusOverridden: true, comment: 'Recette indisponible' });
      }),
      http.get(`${P}/executions/e0`, () => HttpResponse.json({ ...EXECUTION, id: 'e0', editable: false })),
    );
    const { router } = renderRoutes(routes, '/p/SHOP/executions/e1');

    await userEvent.click(await screen.findByTestId('override-status'));
    await userEvent.click(await screen.findByRole('option', { name: 'Bloqué' }));
    await userEvent.type(screen.getByTestId('override-comment'), 'Recette indisponible');
    await userEvent.click(screen.getByTestId('override-submit'));
    await waitFor(() => expect(patch).toEqual({ status: 'BLOCKED', comment: 'Recette indisponible' }));

    await router.navigate('/p/SHOP/executions/e0');
    expect(await screen.findByTestId('execution-readonly')).toBeInTheDocument();
    expect(screen.queryByTestId('step-PASSED')).not.toBeInTheDocument();
  });
});

describe('F-EXE-01 « Mes exécutions »', () => {
  it('liste les tests affectés et lance une tentative avec une ligne du jeu de données', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const mine: MyExecution[] = [{
      itemId: 'i1', campaign: { key: 'CMP-2', name: 'Recette SPR-2', environment: 'recette', status: 'IN_PROGRESS' }, test: test1, position: 1,
      lastStatus: 'NOT_RUN', attempts: 0, dataSets: [{ name: 'Recette', rows: 2 }],
    }];
    let body: unknown;
    server.use(
      http.get(`${P}/my-executions`, () => HttpResponse.json(mine)),
      http.post(`${P}/campaign-items/i1/executions`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(EXECUTION, { status: 201 });
      }),
      http.get(`${P}/executions/e1`, () => HttpResponse.json(EXECUTION)),
    );
    const { router } = renderRoutes(routes, '/p/SHOP/my-executions');

    expect(await screen.findByTestId('my-item-TC-1')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('dataset-TC-1'));
    await userEvent.click(await screen.findByRole('option', { name: 'Recette, ligne 2' }));
    await userEvent.click(screen.getByTestId('run-TC-1'));

    await waitFor(() => expect(body).toEqual({ dataSetName: 'Recette', row: 1 }));
    await waitFor(() => expect(router.state.location.pathname).toBe('/p/SHOP/executions/e1'));
  });
});

describe('F-DEF-01 anomalies', () => {
  it('filtre par statut dans l’URL ; changement de statut parmi les transitions autorisées', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const requests: URL[] = [];
    let patch: unknown;
    const summary = { key: 'DEF-1', title: 'Total faux', severity: 'CRITICAL' as const, status: 'OPEN' as const, requirementKeys: ['REQ-2'], executionCount: 1, createdAt: '2026-10-09T09:00:00Z', version: 0 };
    server.use(
      http.get(`${P}/defects`, ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json([summary]);
      }),
      http.get(`${P}/defects/DEF-1`, () =>
        HttpResponse.json({ defect: summary, description: 'Étapes…', allowedTransitions: ['IN_PROGRESS', 'RESOLVED', 'REJECTED'], requirements: [{ key: 'REQ-2', title: 'Ajouter' }], executions: [] } satisfies DefectDetail),
      ),
      http.patch(`${P}/defects/DEF-1`, async ({ request }) => {
        patch = await request.json();
        return HttpResponse.json({ defect: { ...summary, status: 'RESOLVED' }, allowedTransitions: [], requirements: [], executions: [] });
      }),
      http.get(`${P}/requirements/tree`, () => HttpResponse.json([])),
    );
    renderRoutes(routes, '/p/SHOP/defects?status=OPEN');

    await userEvent.click(await screen.findByTestId('defect-row-DEF-1'));
    expect(requests[0]!.searchParams.getAll('status')).toEqual(['OPEN']);
    await userEvent.click(await screen.findByTestId('edit-status'));
    await userEvent.click(await screen.findByRole('option', { name: 'Résolue' }));
    await userEvent.click(screen.getByTestId('defect-save'));

    await waitFor(() => expect(patch).toEqual({ status: 'RESOLVED' }));
  });
});

describe('§8 règles d’affichage', () => {
  it('pas courant : le premier non joué, sinon le dernier ; durées lisibles', () => {
    expect(currentStepIndex([{ status: 'PASSED' }, { status: 'NOT_RUN' }] as never)).toBe(1);
    expect(currentStepIndex([{ status: 'PASSED' }, { status: 'FAILED' }] as never)).toBe(1);
    expect(duration(90_000)).toBe('1 min 30 s');
    expect(minutes(130)).toBe('2 h 10');
  });
});
