import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { ExecutionServer, RunDetail, ServerChoice } from '../../api/automation';
import type { CampaignDetail } from '../../api/campaigns';
import type { Schemas } from '../../api/client';
import { renderElement, renderRoutes } from '../../test/render';
import { ADMIN, server, TESTER } from '../../test/server';
import { AdminExecutionServersPage } from '../admin/AdminExecutionServersPage';
import { useAuthStore } from '../auth/authStore';
import { CampaignPage } from '../campaigns/CampaignPage';
import { guessFormat, isFinal, progressPercent } from './model';
import { RunPage } from './RunPage';

const P = '/api/v1/projects/SHOP';
const DEV: Schemas['MeResponse'] = { ...TESTER, login: 'dev', projects: [{ key: 'SHOP', name: 'Boutique', role: 'DEVELOPER' }] };
const api = (key: string, technique: 'API' | 'UI', flaky = false) => ({
  key, title: `Test ${key}`, kind: 'AUTOMATED' as const, technique, status: 'READY' as const, priority: 'MUST' as const, currentVersion: 1, ...(flaky ? { flaky } : {}),
});
const counts = { total: 2, pending: 0, running: 1, passed: 1, failed: 0, error: 0, skipped: 0 };
const campaignRef = { key: 'CMP-1', name: 'Régression', status: 'IN_PROGRESS' as const };

function run(overrides: Partial<RunDetail['run']> = {}, executions: RunDetail['executions'] = []): RunDetail {
  return {
    run: { key: 'RUN-1', status: 'RUNNING', campaign: campaignRef, serverName: 'Simulateur', requestedBy: 'dev', requestedAt: '2026-10-12T09:00:00Z',
      environment: 'recette', buildVersion: '2.0.0', agent: 'sim-agent-1', externalJobId: 'job-1', timeoutMinutes: 30, counts, ...overrides },
    executions,
    cancellable: !['COMPLETED', 'FAILED', 'CANCELLED', 'TIMEOUT'].includes(overrides.status ?? 'RUNNING'),
  };
}

const execution = (key: string, status: RunDetail['executions'][number]['status'], extra: Partial<RunDetail['executions'][number]> = {}) => ({
  id: `e-${key}`, itemId: `i-${key}`, test: api(key, 'API'), technique: 'API' as const, testIdentifier: `CartApiTest#${key}`, status,
  startedAt: '2026-10-12T09:00:01Z', flaky: false, ...extra,
});

describe('§8.5 affichage des runs', () => {
  it('format déduit du fichier, avancement, statuts finaux', () => {
    expect(guessFormat('TEST-CartApiTest.xml')).toBe('JUNIT');
    expect(guessFormat('output.xml')).toBe('ROBOT');
    expect(guessFormat('cucumber-report.json')).toBe('CUCUMBER');
    expect(guessFormat('playwright-results.json')).toBe('PLAYWRIGHT');
    expect(progressPercent({ total: 4, pending: 1, running: 1, passed: 2, failed: 0, error: 0, skipped: 0 })).toBe(50);
    expect(isFinal('TIMEOUT')).toBe(true);
    expect(isFinal('DISPATCHED')).toBe(false);
  });
});

describe('§13.2 /p/:key/runs/:rk — run en temps réel (F-EXE-07), annulation (F-EXE-08), relance des échecs (F-EXE-09)', () => {
  it('un événement temps réel relit le run ; message d’échec, test instable', async () => {
    useAuthStore.getState().setSession('jwt', DEV);
    let finished = false;
    let release: () => void = () => undefined;
    const pushed = new Promise<void>((resolve) => (release = resolve));
    server.use(
      http.get(`${P}/runs/RUN-1`, () =>
        HttpResponse.json(finished
          ? run({ status: 'COMPLETED', counts: { ...counts, running: 0, failed: 1 } }, [execution('TC-1', 'PASSED', { flaky: true }),
              execution('TC-2', 'FAILED', { message: 'AssertionError : total' })])
          : run({}, [execution('TC-1', 'PASSED'), execution('TC-2', 'RUNNING')])),
      ),
      http.get(`${P}/runs/RUN-1/events`, () => {
        const stream = new ReadableStream({
          async start(controller) {
            controller.enqueue(new TextEncoder().encode('event:ready\ndata:{}\n\n'));
            await pushed;
            finished = true;
            controller.enqueue(new TextEncoder().encode('event:run\ndata:{"runKey":"RUN-1"}\n\n'));
            controller.close();
          },
        });
        return new HttpResponse(stream, { headers: { 'Content-Type': 'text/event-stream' } });
      }),
    );
    renderRoutes([{ path: '/p/:key/runs/:rk', element: <RunPage /> }], '/p/SHOP/runs/RUN-1');

    expect(await screen.findByTestId('run-status')).toHaveTextContent('En cours');
    expect(screen.getByTestId('run-cancel')).toBeInTheDocument();
    release();
    await waitFor(() => expect(screen.getByTestId('run-status')).toHaveTextContent('Terminé'));
    expect(screen.getByTestId('run-message-TC-2')).toHaveTextContent('AssertionError : total');
    expect(within(screen.getByTestId('run-test-TC-1')).getByTestId('flaky-badge')).toBeInTheDocument();
    expect(screen.getByTestId('run-rerun-failed')).toHaveTextContent('Relancer l’échec'.replace('’', "'"));
  });

  it('F-EXE-08 annulation ; le testeur ne peut ni annuler ni relancer', async () => {
    useAuthStore.getState().setSession('jwt', DEV);
    let cancelled = false;
    server.use(
      http.get(`${P}/runs/RUN-1`, () => HttpResponse.json(cancelled ? run({ status: 'CANCELLED' }) : run())),
      http.post(`${P}/runs/RUN-1/cancel`, () => {
        cancelled = true;
        return HttpResponse.json(run({ status: 'CANCELLED' }));
      }),
    );
    renderRoutes([{ path: '/p/:key/runs/:rk', element: <RunPage /> }], '/p/SHOP/runs/RUN-1');
    await userEvent.click(await screen.findByTestId('run-cancel'));
    await waitFor(() => expect(screen.getByTestId('run-status')).toHaveTextContent('Annulé'));

    useAuthStore.getState().setSession('jwt', TESTER);
    renderRoutes([{ path: '/p/:key/runs/:rk', element: <RunPage /> }], '/p/SHOP/runs/RUN-1');
    await screen.findAllByTestId('run-status');
    expect(screen.queryAllByTestId('run-cancel')).toHaveLength(0);
  });
});

describe('§13.2 campagne : « Lancer sur… » (F-EXE-06) et import de rapports (F-EXE-10)', () => {
  const detail: CampaignDetail = {
    campaign: { key: 'CMP-1', name: 'Régression', scopeType: 'REGRESSION', status: 'IN_PROGRESS', version: 0,
      progress: { total: 3, byStatus: { NOT_RUN: 3 }, executed: 0, executedPercent: 0, passRate: 0 } },
    items: [
      { id: 'i1', position: 1, test: api('TC-1', 'API', true), testCaseVersion: 1, executedByServer: true, riskScore: 9, lastStatus: 'PASSED', attempts: 1, dataSetValues: {}, dataSets: [] },
      { id: 'i2', position: 2, test: api('TC-2', 'API'), testCaseVersion: 1, executedByServer: true, riskScore: 9, lastStatus: 'NOT_RUN', attempts: 0, dataSetValues: {}, dataSets: [] },
      { id: 'i3', position: 3, test: api('TC-3', 'UI'), testCaseVersion: 1, executedByServer: true, riskScore: 9, lastStatus: 'NOT_RUN', attempts: 0, dataSetValues: {}, dataSets: [] },
    ],
    workload: [],
  };
  const choices: ServerChoice[] = [
    { id: 's1', name: 'Simulateur', status: 'ONLINE', techniques: ['API', 'BDD'], usable: true },
    { id: 's2', name: 'Ferme UI', status: 'ONLINE', techniques: ['API', 'UI'], usable: true },
  ];

  function serve() {
    server.use(
      http.get(`${P}/campaigns/CMP-1`, () => HttpResponse.json(detail)),
      http.get(`${P}/testers`, () => HttpResponse.json([])),
      http.get(`${P}/campaigns`, () => HttpResponse.json([])),
      http.get(`${P}/campaign-folders`, () => HttpResponse.json([])),
      http.get(`${P}/sprints`, () => HttpResponse.json([])),
      http.get(`${P}/releases`, () => HttpResponse.json([])),
      http.get(`${P}/execution-servers`, () => HttpResponse.json(choices)),
      http.get(`${P}/runs/RUN-7`, () => HttpResponse.json(run({ key: 'RUN-7' }))),
    );
  }

  it('F-EXE-06 tous les tests cochés ; seul un serveur compatible avec toutes leurs techniques est proposé ; ouverture du run', async () => {
    useAuthStore.getState().setSession('jwt', DEV);
    serve();
    let body: unknown;
    server.use(http.post(`${P}/campaigns/CMP-1/runs`, async ({ request }) => {
      body = await request.json();
      return HttpResponse.json(run({ key: 'RUN-7', status: 'DISPATCHED' }), { status: 201 });
    }));
    renderRoutes([{ path: '/p/:key/campaigns/:ck', element: <CampaignPage /> }, { path: '/p/:key/runs/:rk', element: <RunPage /> }], '/p/SHOP/campaigns/CMP-1');

    expect(within(await screen.findByTestId('item-TC-1')).getByTestId('flaky-badge')).toBeInTheDocument();
    await userEvent.click(await screen.findByTestId('launch-open'));
    expect(await screen.findByTestId('launch-submit')).toHaveTextContent('Lancer 3 tests');
    await waitFor(() => expect(screen.getByTestId('launch-server')).toHaveValue('Ferme UI — En ligne'));
    await userEvent.click(screen.getByTestId('launch-item-TC-3'));
    await userEvent.click(screen.getByTestId('launch-server'));
    await userEvent.click(await screen.findByRole('option', { name: 'Simulateur — En ligne' }));
    await userEvent.click(screen.getByTestId('launch-submit'));

    await waitFor(() => expect(body).toEqual({ serverId: 's1', itemIds: ['i1', 'i2'], timeoutMinutes: 30 }));
    expect(await screen.findByTestId('run-page')).toHaveTextContent('RUN-7');
  });

  it('F-EXE-10 import : aperçu du rapprochement, création des inconnus, application', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve();
    const calls: URL[] = [];
    server.use(http.post(`${P}/campaigns/CMP-1/imports`, ({ request }) => {
      const url = new URL(request.url);
      calls.push(url);
      const lines = [
        { name: 'add', identifier: 'com.shop.CartApiTest#add', status: 'PASSED', durationMs: 400, requirementKeys: [], testKey: 'TC-1', matchedBy: 'IDENTIFIER' },
        { name: 'pay', identifier: 'com.shop.CheckoutTest#pay', status: 'FAILED', durationMs: 1200, message: 'refusé', requirementKeys: ['REQ-9'] },
      ];
      return HttpResponse.json(url.searchParams.get('apply') === 'true'
        ? { lines, created: ['TC-9'], recorded: 2, applied: true }
        : { lines, created: [], recorded: 0, applied: false });
    }));
    renderRoutes([{ path: '/p/:key/campaigns/:ck', element: <CampaignPage /> }], '/p/SHOP/campaigns/CMP-1');

    expect(screen.queryByTestId('launch-open')).not.toBeInTheDocument();
    await userEvent.click(await screen.findByTestId('import-open'));
    await userEvent.upload(screen.getByTestId('import-file'), new File(['<testsuite/>'], 'junit.xml', { type: 'application/xml' }));
    expect(await screen.findByTestId('import-summary')).toHaveTextContent('2 résultats : 1 rapprochés, 1 inconnus.');
    expect(screen.getByTestId('import-lines')).toHaveTextContent('TC-1 · identifiant');
    expect(screen.getByTestId('import-lines')).toHaveTextContent('Inconnu · REQ-9');
    expect(screen.getByTestId('import-submit')).toHaveTextContent('Importer 2 résultats');
    await userEvent.click(screen.getByTestId('import-create-unknown'));
    expect(screen.getByTestId('import-submit')).toHaveTextContent('Importer 1 résultat');
    await userEvent.click(screen.getByTestId('import-create-unknown'));
    await userEvent.click(screen.getByTestId('import-submit'));

    await waitFor(() => expect(calls).toHaveLength(2));
    expect(calls[0]!.searchParams.get('format')).toBe('JUNIT');
    expect(calls[0]!.searchParams.get('apply')).toBe('false');
    expect(calls[1]!.searchParams.get('apply')).toBe('true');
    expect(calls[1]!.searchParams.get('createUnknown')).toBe('true');
    expect(await screen.findByText(/2 résultats importés\. Tests créés : TC-9\./)).toBeInTheDocument();
  });
});

describe('§13.2 /admin/execution-servers — ADR-0020 jeton émis par le serveur', () => {
  it('liste (empreinte du jeton seulement), appairage par les identifiants de l’administrateur du serveur, test de connexion', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    const simulator: ExecutionServer = {
      id: 's1', name: 'Simulateur', baseUrl: 'http://mock-execution-server:8090', authType: 'SERVER_TOKEN', paired: false, status: 'UNPAIRED',
      techniques: [], frameworks: [], environments: [], agents: 0, enabled: true,
    };
    let current = simulator;
    const pairs: unknown[] = [];
    server.use(
      http.get('/api/v1/execution-servers', () => HttpResponse.json([current])),
      http.post('/api/v1/execution-servers/s1/pair', async ({ request }) => {
        pairs.push(await request.json());
        current = { ...simulator, paired: true, tokenHint: 'x9Qk', tokenId: 'tok-1', pairedAt: '2026-10-12T09:00:00Z', status: 'ONLINE',
          techniques: ['API', 'BDD'], agents: 2, serverVersion: '1.0.0' };
        return HttpResponse.json(current);
      }),
    );
    renderElement(<AdminExecutionServersPage />);

    expect(await screen.findByTestId('server-status-Simulateur')).toHaveTextContent('Non appairé');
    expect(screen.getByTestId('server-test-Simulateur')).toBeDisabled();
    await userEvent.click(screen.getByTestId('server-pair-Simulateur'));
    await userEvent.type(await screen.findByTestId('pair-admin-user'), 'admin');
    await userEvent.type(screen.getByTestId('pair-admin-password'), 'simulateur');
    await userEvent.click(screen.getByTestId('pair-submit'));

    await waitFor(() => expect(pairs).toEqual([{ adminUser: 'admin', adminPassword: 'simulateur' }]));
    expect(await screen.findByTestId('server-token-Simulateur')).toHaveTextContent('Jeton …x9Qk (id tok-1)');
    expect(screen.getByTestId('server-status-Simulateur')).toHaveTextContent('En ligne');
  });
});
