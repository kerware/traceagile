import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { CampaignDetail, CampaignSummary, DefectSummary, ExecutionDetail, RequirementDefect, TracedExecution } from '../../api/campaigns';
import { renderElement, renderRoutes } from '../../test/render';
import { page, server, TESTER } from '../../test/server';
import { testDetail, testSummary } from '../../test/testcases';
import { useAuthStore } from '../auth/authStore';
import { TestCaseDetailView } from '../tests/TestCaseDetailView';
import { CampaignPage } from './CampaignPage';
import { CampaignsPage } from './CampaignsPage';
import { ExecutionPage } from './ExecutionPage';
import { RequirementDefectsPanel, TestDefectsPanel, TestExecutionsPanel } from './RequirementRunsPanels';

/** ADR-0018 jeux de données en campagne, appel de cas de test, dossiers de campagnes, traçabilité des anomalies. */

const P = '/api/v1/projects/SHOP';
const test1 = { key: 'TC-1', title: 'Ajouter un produit', kind: 'MANUAL' as const, status: 'READY' as const, priority: 'MUST' as const, currentVersion: 1, durationMin: 10 };
const progress = { total: 1, byStatus: { NOT_RUN: 1 }, executed: 0, executedPercent: 0, passRate: 0 };
const summary = (key: string, name: string, folder?: string): CampaignSummary => ({
  key, name, scopeType: 'REGRESSION', status: 'PLANNED', progress, version: 0, ...(folder ? { folder } : {}),
});
const defect = (key: string, requirementKeys: string[] = []): DefectSummary => ({
  key, title: `Anomalie ${key}`, severity: 'MAJOR', status: 'OPEN', requirementKeys, executionCount: 1, createdAt: '2026-10-09T09:00:00Z', version: 0,
});
const run: TracedExecution = {
  id: 'e1', test: test1, campaign: { key: 'CMP-1', name: 'Recette SPR-1', status: 'IN_PROGRESS' }, attempt: 2, status: 'FAILED',
  startedAt: '2026-10-09T09:00:00Z', origin: 'MANUAL', executedBy: 'qa1', dataSetName: 'Recette', dataSetRow: 1,
};

describe('ADR-0018 traçabilité des anomalies et fiche test', () => {
  it('anomalies d’une exigence : rattachée ou trouvée par traçabilité, rattachement en un clic', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let linked = false;
    const rows = (): RequirementDefect[] => [
      { defect: defect('DEF-2', linked ? ['REQ-2'] : []), linked, viaTests: ['TC-1'] },
      { defect: defect('DEF-1', ['REQ-2']), linked: true, viaTests: [] },
    ];
    server.use(
      http.get(`${P}/requirements/REQ-2/defects`, () => HttpResponse.json(rows())),
      http.post(`${P}/requirements/REQ-2/defects/DEF-2`, () => {
        linked = true;
        return HttpResponse.json({});
      }),
    );
    renderElement(<RequirementDefectsPanel project="SHOP" requirementKey="REQ-2" />);

    const traced = await screen.findByTestId('requirement-defect-DEF-2');
    expect(traced).toHaveTextContent('via TC-1');
    expect(traced).toHaveTextContent('Par traçabilité');
    expect(within(screen.getByTestId('requirement-defect-DEF-1')).getByText('Rattachée')).toBeInTheDocument();
    await userEvent.click(within(traced).getByTestId('link-defect-DEF-2'));
    await waitFor(() => expect(screen.getByTestId('requirement-defect-DEF-2')).toHaveTextContent('Rattachée'));
    expect(screen.queryByTestId('link-defect-DEF-2')).not.toBeInTheDocument();
  });

  it('fiche test : toutes les exécutions (campagne, tentative, ligne de jeu) et les anomalies', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    server.use(
      http.get(`${P}/test-cases/TC-1/executions`, () => HttpResponse.json([run])),
      http.get(`${P}/test-cases/TC-1/defects`, () => HttpResponse.json([defect('DEF-3', ['REQ-2'])])),
    );
    renderElement(
      <>
        <TestExecutionsPanel project="SHOP" testKey="TC-1" />
        <TestDefectsPanel project="SHOP" testKey="TC-1" />
      </>,
    );

    expect(await screen.findByTestId('test-executions')).toHaveTextContent('CMP-1');
    expect(screen.getByTestId('test-executions')).toHaveTextContent('Recette #2');
    expect(await screen.findByTestId('test-defects')).toHaveTextContent('DEF-3');
    expect(screen.getByTestId('test-defects')).toHaveTextContent('REQ-2');
  });
});

describe('ADR-0018 appel d’un cas de test comme pas', () => {
  it('ajoute un appel, choisit le test appelé et la valeur de ses paramètres ; le PATCH envoie l’appel', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let body: Record<string, unknown> | undefined;
    server.use(
      http.get(`${P}/test-cases/TC-1`, () => HttpResponse.json(testDetail('TC-1', { calledBy: ['TC-8'] }))),
      http.get(`${P}/test-cases/TC-5`, () =>
        HttpResponse.json(testDetail('TC-5', { title: 'Se connecter', parameters: [{ name: 'login', defaultValue: 'invité', detected: true }] })),
      ),
      http.get(`${P}/test-cases`, () => HttpResponse.json(page([testSummary('TC-1'), testSummary('TC-5', { title: 'Se connecter', status: 'READY' })]))),
      http.get('/api/v1/reference/frameworks', () => HttpResponse.json([])),
      http.patch(`${P}/test-cases/TC-1`, async ({ request }) => {
        body = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json(testDetail('TC-1'));
      }),
    );
    renderElement(<TestCaseDetailView project="SHOP" testKey="TC-1" />);

    expect(await screen.findByTestId('test-called-by')).toHaveTextContent('TC-8');
    await userEvent.click(screen.getByTestId('step-add-call'));
    await userEvent.click(screen.getByTestId('step-called-2'));
    expect(screen.queryByRole('option', { name: /^TC-1 —/ })).not.toBeInTheDocument();
    await userEvent.click(await screen.findByRole('option', { name: 'TC-5 — Se connecter' }));
    await userEvent.type(await screen.findByTestId('step-call-2-login'), '${{client}');
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() =>
      expect(body?.steps).toEqual([
        { action: 'Ouvrir la fiche', expectedResult: 'La fiche s’affiche', testData: null },
        { action: null, expectedResult: null, testData: null, calledTestKey: 'TC-5', callParameters: { login: '${client}' } },
      ]),
    );
  });

  it('exécution : un pas déroulé depuis un test appelé affiche sa provenance', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const execution: ExecutionDetail = {
      id: 'e1', itemId: 'i1', test: test1, campaign: { key: 'CMP-1', name: 'Recette SPR-1', status: 'IN_PROGRESS' },
      attempt: 1, testCaseVersion: 1, status: 'RUNNING', derivedStatus: 'RUNNING', statusOverridden: false, startedAt: '2026-10-09T09:00:00Z', origin: 'MANUAL',
      parameterValues: {}, defects: [], editable: true, dataSets: [],
      attempts: [{ id: 'e1', attempt: 1, status: 'RUNNING', startedAt: '2026-10-09T09:00:00Z', origin: 'MANUAL' }],
      steps: [
        { position: 1, action: 'Saisir alice', expectedResult: 'Champ rempli', status: 'NOT_RUN', calledFrom: 'TC-5 Se connecter' },
        { position: 2, action: 'Payer', expectedResult: 'Payé', status: 'NOT_RUN' },
      ],
    };
    server.use(http.get(`${P}/executions/e1`, () => HttpResponse.json(execution)));
    renderRoutes([{ path: '/p/:key/executions/:id', element: <ExecutionPage /> }], '/p/SHOP/executions/e1');

    expect(await screen.findByTestId('step-called-from')).toHaveTextContent('TC-5 Se connecter');
    expect(screen.getByTestId('step-nav-1')).toHaveTextContent('↳ TC-5 Se connecter');
    expect(screen.getByTestId('step-nav-2')).not.toHaveTextContent('↳');
  });
});

describe('ADR-0018 jeu de données choisi dans la campagne', () => {
  const detail = (items: CampaignDetail['items']): CampaignDetail => ({
    campaign: { ...summary('CMP-1', 'Recette SPR-1'), status: 'IN_PROGRESS' }, items, workload: [],
  });
  const item = { id: 'i1', position: 1, test: test1, testCaseVersion: 1, executedByServer: false, riskScore: 16, lastStatus: 'NOT_RUN' as const, attempts: 0, dataSetValues: {}, dataSets: [{ name: 'Recette', rows: 2 }] };

  function serve(current: () => CampaignDetail) {
    server.use(
      http.get(`${P}/campaigns/CMP-1`, () => HttpResponse.json(current())),
      http.get(`${P}/testers`, () => HttpResponse.json([])),
      http.get(`${P}/campaigns`, () => HttpResponse.json([])),
      http.get(`${P}/campaign-folders`, () => HttpResponse.json([])),
      http.get(`${P}/sprints`, () => HttpResponse.json([])),
      http.get(`${P}/releases`, () => HttpResponse.json([])),
      http.get(`${P}/requirements/tree`, () => HttpResponse.json([])),
      http.get(`${P}/test-cases`, () => HttpResponse.json(page([]))),
    );
  }

  it('choisit une ligne pour un test puis décline le jeu sur toutes ses lignes', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let current = detail([item]);
    const calls: unknown[] = [];
    serve(() => current);
    server.use(
      http.patch(`${P}/campaign-items/i1`, async ({ request }) => {
        calls.push(await request.json());
        current = detail([{ ...item, dataSetName: 'Recette', dataSetRow: 1, dataSetValues: { produit: 'Cahier' } }]);
        return HttpResponse.json(current.items[0]);
      }),
      http.post(`${P}/campaign-items/i1/expand-data-set`, async ({ request }) => {
        calls.push(await request.json());
        current = detail([
          { ...item, id: 'i0', dataSetName: 'Recette', dataSetRow: 0, dataSetValues: { produit: 'Stylo' } },
          { ...item, position: 2, dataSetName: 'Recette', dataSetRow: 1, dataSetValues: { produit: 'Cahier' } },
        ]);
        return HttpResponse.json(current);
      }),
    );
    renderRoutes([{ path: '/p/:key/campaigns/:ck', element: <CampaignPage /> }], '/p/SHOP/campaigns/CMP-1');

    await userEvent.click(await screen.findByTestId('item-dataset-TC-1'));
    await userEvent.click(await screen.findByRole('option', { name: 'Recette, ligne 2' }));
    await waitFor(() => expect(calls).toEqual([{ dataSetName: 'Recette', dataSetRow: 1 }]));
    expect(await screen.findByTestId('item-TC-1-2')).toBeInTheDocument();

    await userEvent.click(screen.getByTestId('item-expand-TC-1-2'));
    await userEvent.click(await screen.findByTestId('expand-Recette'));
    await waitFor(() => expect(calls[1]).toEqual({ dataSetName: 'Recette' }));
    expect(await screen.findByTestId('item-TC-1-1')).toBeInTheDocument();
    expect(screen.getByTestId('item-TC-1-2')).toBeInTheDocument();
  });

  it('un test déjà exécuté garde sa ligne (lecture seule)', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(() => detail([{ ...item, attempts: 1, lastStatus: 'PASSED', dataSetName: 'Recette', dataSetRow: 0, dataSetValues: { produit: 'Stylo' } }]));
    renderRoutes([{ path: '/p/:key/campaigns/:ck', element: <CampaignPage /> }], '/p/SHOP/campaigns/CMP-1');

    expect(await screen.findByTestId('item-dataset-TC-1-1')).toHaveTextContent('Recette, ligne 1');
    expect(screen.queryByTestId('item-expand-TC-1-1')).not.toBeInTheDocument();
  });
});

describe('ADR-0018 dossiers de campagnes', () => {
  it('arbre des dossiers : filtre de la liste (sous-dossiers compris), nouveau dossier, campagne glissée sur un dossier', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const created: unknown[] = [];
    const moved: unknown[] = [];
    server.use(
      http.get(`${P}/campaigns`, () =>
        HttpResponse.json([summary('CMP-3', 'Régression', 'Version 2.0'), summary('CMP-2', 'Recette SPR-2', 'Version 2.0/Sprints'), summary('CMP-1', 'Hors dossier')]),
      ),
      http.get(`${P}/campaign-folders`, () => HttpResponse.json(['Archives', 'Version 2.0', 'Version 2.0/Sprints'])),
      http.get(`${P}/sprints`, () => HttpResponse.json([])),
      http.get(`${P}/releases`, () => HttpResponse.json([])),
      http.post(`${P}/campaign-folders`, async ({ request }) => {
        created.push(await request.json());
        return HttpResponse.json({ path: 'Version 2.0/Hotfix' }, { status: 201 });
      }),
      http.patch(`${P}/campaigns/CMP-1`, async ({ request }) => {
        moved.push(await request.json());
        return HttpResponse.json({});
      }),
    );
    renderRoutes([{ path: '/p/:key/campaigns', element: <CampaignsPage /> }], '/p/SHOP/campaigns');

    expect(await screen.findByTestId('campaign-folder-Version 2.0')).toHaveTextContent('2');
    expect(screen.getByTestId('campaign-folder-Archives')).toHaveTextContent('0');
    expect(screen.getAllByTestId(/^campaign-row-/)).toHaveLength(3);
    await userEvent.click(screen.getByTestId('campaign-folder-select-Version 2.0'));
    expect(screen.getAllByTestId(/^campaign-row-/).map((r) => r.dataset.testid)).toEqual(['campaign-row-CMP-3', 'campaign-row-CMP-2']);
    expect(screen.getByTestId('campaign-row-CMP-2')).toHaveTextContent('Version 2.0/Sprints');

    await userEvent.click(screen.getByTestId('campaign-folder-Version 2.0-menu'));
    await userEvent.click(await screen.findByTestId('menu-new-folder'));
    await userEvent.type(await screen.findByRole('textbox', { name: /Nom du dossier/ }), 'Hotfix{Enter}');
    await waitFor(() => expect(created).toEqual([{ path: 'Version 2.0/Hotfix' }]));

    await userEvent.click(screen.getByTestId('campaign-folder-select-root'));
    const data = { getData: () => 'CMP-1', setData: () => undefined, types: ['application/x-traceagile-campaign'] };
    const archives = screen.getByTestId('campaign-folder-Archives').parentElement!;
    fireEvent.dragOver(archives, { dataTransfer: data });
    fireEvent.drop(archives, { dataTransfer: data });
    await waitFor(() => expect(moved).toEqual([{ folder: 'Archives' }]));
  });
});
