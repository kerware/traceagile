import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import type { CharterProposal, ExploratoryMetrics, SessionDetail, SessionSummary } from '../../api/exploratory';
import { renderElement, renderRoutes } from '../../test/render';
import { page, server, TESTER } from '../../test/server';
import { testSummary } from '../../test/testcases';
import { useAuthStore } from '../auth/authStore';
import { ExploratoryPage } from './ExploratoryPage';
import { GenerateChartersModal } from './GenerateChartersModal';
import { clock, noteTypeForShortcut, tbsTotal } from './model';
import { SessionPage } from './SessionPage';

const P = '/api/v1/projects/SHOP';
const PO: Schemas['MeResponse'] = { ...TESTER, login: 'po', projects: [{ key: 'SHOP', name: 'Boutique', role: 'PRODUCT_OWNER' }] };
const charter = { key: 'TC-21', title: 'Explorer la recherche', kind: 'EXPLORATORY' as const, status: 'READY' as const, priority: 'MUST' as const, currentVersion: 1 };
const campaign = { key: 'CMP-2', name: 'Recette SPR-2', status: 'IN_PROGRESS' as const };

function session(overrides: Partial<SessionDetail> = {}): SessionDetail {
  return {
    id: 'e1', itemId: 'i1', charter, missionSentence: 'Explorer la recherche avec des accents pour découvrir les résultats manquants.',
    areas: ['Recherche', 'Tri'], heuristics: ['Goldilocks'], timeboxMin: 60, campaign, attempt: 1, tester: 'qa1', state: 'RUNNING',
    status: 'RUNNING', startedAt: '2026-10-12T09:00:00Z', elapsedSeconds: 125, serverTime: '2026-10-12T09:02:05Z', notes: [], areasCovered: [],
    defects: [], owner: true, version: 0, ...overrides,
  };
}

const route = [{ path: '/p/:key/sessions/:id', element: <SessionPage /> }];

describe('§5.2 affichage des sessions', () => {
  it('chronomètre, raccourcis Ctrl+1 à Ctrl+5, total TBS', () => {
    expect(clock(125)).toBe('02:05');
    expect(clock(3_725)).toBe('1:02:05');
    expect(noteTypeForShortcut({ ctrlKey: true, metaKey: false, key: '4' })).toBe('BUG');
    expect(noteTypeForShortcut({ ctrlKey: false, metaKey: false, key: '4' })).toBeNull();
    expect(noteTypeForShortcut({ ctrlKey: true, metaKey: false, key: '6' })).toBeNull();
    expect(tbsTotal({ testPct: 60, bugPct: 30, setupPct: 10 })).toBe(100);
  });
});

describe('§13.2 /p/:key/sessions/:id — session exploratoire (F-EXP-05 à F-EXP-13)', () => {
  it('F-EXP-05 / F-EXP-06 / F-EXP-10 chronomètre, pause, note BUG par Ctrl+4, brouillon sauvegardé à la perte de focus', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const patches: unknown[] = [];
    let note: unknown;
    server.use(
      http.get(`${P}/sessions/e1`, () => HttpResponse.json(session())),
      http.patch(`${P}/sessions/e1`, async ({ request }) => {
        const body = (await request.json()) as Record<string, unknown>;
        patches.push(body);
        return HttpResponse.json(session(body.paused ? { state: 'PAUSED' } : { draft: body.draft as string }));
      }),
      http.post(`${P}/sessions/e1/notes`, async ({ request }) => {
        note = await request.json();
        return HttpResponse.json({ id: 'n1', type: 'BUG', offsetSeconds: 130, offsetLabel: '02:10', text: 'x', notedAt: '2026-10-12T09:02:10Z' }, { status: 201 });
      }),
    );
    renderRoutes(route, '/p/SHOP/sessions/e1');

    expect(await screen.findByTestId('session-mission')).toHaveTextContent('Explorer la recherche avec des accents');
    expect(screen.getByTestId('session-elapsed')).toHaveTextContent(/^02:0[5-9]$/);
    const text = screen.getByTestId('note-text');
    await userEvent.type(text, 'Les guillemets cassent la page');
    fireEvent.keyDown(text, { key: '4', ctrlKey: true });
    fireEvent.blur(text);
    await waitFor(() => expect(patches).toContainEqual({ draft: 'Les guillemets cassent la page' }));
    fireEvent.keyDown(text, { key: 'Enter', ctrlKey: true });
    await waitFor(() => expect(note).toEqual({ type: 'BUG', text: 'Les guillemets cassent la page' }));

    await userEvent.click(screen.getByTestId('session-toggle'));
    await waitFor(() => expect(patches).toContainEqual({ paused: true }));
    expect(await screen.findByTestId('session-state')).toHaveTextContent('En pause');
  });

  it('F-EXP-09 fin : la répartition TBS doit totaliser 100 ; zones et statut envoyés', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let body: unknown;
    const finished = session({ state: 'FINISHED', status: 'BLOCKED', durationMin: 42, tbs: { testPct: 50, bugPct: 20, setupPct: 30 }, areasCovered: ['Recherche', 'Tri'] });
    server.use(
      http.get(`${P}/sessions/e1`, () => HttpResponse.json(body ? finished : session())),
      http.post(`${P}/sessions/e1/finish`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(finished);
      }),
    );
    renderRoutes(route, '/p/SHOP/sessions/e1');

    await userEvent.click(await screen.findByTestId('session-finish-open'));
    await userEvent.clear(screen.getByTestId('tbs-testPct'));
    await userEvent.type(screen.getByTestId('tbs-testPct'), '50');
    expect(screen.getByTestId('tbs-total')).toHaveTextContent('80 %');
    expect(screen.getByTestId('session-finish-submit')).toBeDisabled();
    await userEvent.clear(screen.getByTestId('tbs-setupPct'));
    await userEvent.type(screen.getByTestId('tbs-setupPct'), '30');
    await userEvent.click(screen.getByText('Bloqué'));
    await userEvent.click(screen.getByTestId('session-finish-submit'));

    await waitFor(() => expect(body).toEqual({ testPct: 50, bugPct: 20, setupPct: 30, areasCovered: ['Recherche', 'Tri'], status: 'BLOCKED' }));
    expect(await screen.findByTestId('session-summary')).toHaveTextContent('42 min (cible 60 min)');
  });

  it('F-EXP-07 note BUG → anomalie pré-remplie ; F-EXP-11 débriefing PROOF du testeur', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const finished = session({
      state: 'FINISHED', status: 'FAILED', durationMin: 55, tbs: { testPct: 60, bugPct: 30, setupPct: 10 }, areasCovered: ['Recherche'],
      notes: [{ id: 'n1', type: 'BUG', offsetSeconds: 900, offsetLabel: '15:00', text: 'Erreur 500 sur « " »', notedAt: '2026-10-12T09:15:00Z' }],
    });
    let defect: unknown;
    let proof: unknown;
    server.use(
      http.get(`${P}/sessions/e1`, () => HttpResponse.json(finished)),
      http.get(`${P}/requirements/tree`, () => HttpResponse.json([])),
      http.get(`${P}/sessions/e1/notes/n1/defect-draft`, () =>
        HttpResponse.json({ title: 'TC-21 Explorer la recherche : Erreur 500', description: '**Constat**', severity: 'MAJOR', requirementKeys: ['REQ-2'] }),
      ),
      http.post(`${P}/sessions/e1/notes/n1/defects`, async ({ request }) => {
        defect = await request.json();
        return HttpResponse.json({ defect: { key: 'DEF-7' } }, { status: 201 });
      }),
      http.post(`${P}/sessions/e1/debrief`, async ({ request }) => {
        proof = await request.json();
        return HttpResponse.json({ ...finished, proof: { ...(proof as object), outlookItems: [] } });
      }),
    );
    renderRoutes(route, '/p/SHOP/sessions/e1');

    await userEvent.click(await screen.findByTestId('note-convert-1'));
    expect(await screen.findByTestId('defect-title')).toHaveValue('TC-21 Explorer la recherche : Erreur 500');
    await userEvent.click(screen.getByTestId('defect-submit'));
    await waitFor(() => expect(defect).toMatchObject({ title: 'TC-21 Explorer la recherche : Erreur 500', severity: 'MAJOR', requirementKeys: ['REQ-2'] }));

    expect(screen.getByTestId('proof-submit')).toBeDisabled();
    await userEvent.type(screen.getByTestId('proof-past'), 'Recherche parcourue');
    await userEvent.type(screen.getByTestId('proof-results'), 'Une erreur 500');
    await userEvent.type(screen.getByTestId('proof-outlook'), 'Explorer le tri');
    const four = within(screen.getByTestId('proof-feelings')).getByRole('radio', { name: '4' }) as HTMLInputElement;
    await userEvent.click(four.labels![0]!);
    await waitFor(() => expect(screen.getByTestId('proof-submit')).toBeEnabled());
    await userEvent.click(screen.getByTestId('proof-submit'));
    await waitFor(() => expect(proof).toEqual({ past: 'Recherche parcourue', results: 'Une erreur 500', obstacles: '', outlook: 'Explorer le tri', feelings: 4 }));
  });

  it('F-EXP-13 le PO approuve le débriefing ; F-EXP-12 l’Outlook crée une charte de suivi', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    const debriefed = session({
      owner: false, state: 'FINISHED', status: 'PASSED', durationMin: 50, tbs: { testPct: 70, bugPct: 20, setupPct: 10 }, areasCovered: ['Recherche'],
      proof: { past: 'Recherche', results: 'RAS', outlook: 'Explorer le tri', feelings: 4, outlookItems: ['Explorer le tri'] },
    });
    let approved = false;
    let missions: unknown;
    server.use(
      http.get(`${P}/sessions/e1`, () => HttpResponse.json(approved ? { ...debriefed, state: 'DEBRIEFED', approvedBy: 'po' } : debriefed)),
      http.post(`${P}/sessions/e1/debrief/approve`, () => {
        approved = true;
        return HttpResponse.json({ ...debriefed, state: 'DEBRIEFED', approvedBy: 'po' });
      }),
      http.post(`${P}/sessions/e1/follow-up-charters`, async ({ request }) => {
        missions = await request.json();
        return HttpResponse.json({ created: ['TC-60'] }, { status: 201 });
      }),
    );
    renderRoutes(route, '/p/SHOP/sessions/e1');

    expect(await screen.findByTestId('proof-view')).toHaveTextContent('RAS');
    expect(screen.queryByTestId('proof-submit')).not.toBeInTheDocument();
    await userEvent.click(screen.getByTestId('debrief-approve'));
    expect(await screen.findByTestId('session-approved')).toHaveTextContent('Approuvé par po');
    // le PO n'écrit pas de tests : pas de charte de suivi
    expect(screen.queryByTestId('follow-up-1')).not.toBeInTheDocument();

    useAuthStore.getState().setSession('jwt', { ...TESTER, login: 'qa2' });
    renderRoutes(route, '/p/SHOP/sessions/e1');
    const buttons = await screen.findAllByTestId('follow-up-1');
    await userEvent.click(buttons[buttons.length - 1]!);
    await waitFor(() => expect(missions).toEqual({ missions: ['Explorer le tri'] }));
    expect(await screen.findByText('TC-60')).toBeInTheDocument();
  });
});

describe('§13.2 /p/:key/exploratory — chartes, sessions, métriques (§5.4), heuristiques (F-EXP-02)', () => {
  const summary = (overrides: Partial<SessionSummary>): SessionSummary => ({
    id: 'e1', charter, campaign, attempt: 1, tester: 'qa1', state: 'RUNNING', status: 'RUNNING', startedAt: '2026-10-12T09:00:00Z',
    elapsedSeconds: 600, timeboxMin: 60, notes: 2, bugs: 1, debriefed: false, ...overrides,
  });
  const metrics: ExploratoryMetrics = {
    sessions: 5, inProgress: 1, awaitingApproval: 1, debriefed: 4, totalMinutes: 300, averageMinutes: 60, averageTimeboxMin: 70,
    durationVsTargetPct: 85.7, averageTbs: { testPct: 65, bugPct: 20, setupPct: 15 }, defectsPerHour: 0.4, chartersPlanned: 4,
    chartersExecuted: 3, averageConfidence: 3.6, neverExploredAreas: ['Paiement'],
  };

  function serve() {
    let saved: unknown;
    server.use(
      http.get(`${P}/my-executions`, () =>
        HttpResponse.json([{ itemId: 'i9', campaign, test: { ...charter, key: 'TC-24', title: 'Explorer le paiement' }, position: 1, lastStatus: 'NOT_RUN', attempts: 0, dataSets: [] }]),
      ),
      http.get(`${P}/sessions`, ({ request }) => {
        const states = new URL(request.url).searchParams.getAll('state');
        if (states.includes('RUNNING')) return HttpResponse.json([summary({})]);
        if (states.includes('FINISHED')) return HttpResponse.json([summary({ id: 'e2', attempt: 2, state: 'FINISHED', status: 'FAILED', durationMin: 45, debriefed: true, feelings: 3 })]);
        return HttpResponse.json([]);
      }),
      http.get(`${P}/test-cases`, () => HttpResponse.json(page([testSummary('TC-21', { kind: 'EXPLORATORY', title: 'Explorer la recherche' })]))),
      http.get(`${P}/campaigns`, () => HttpResponse.json([])),
      http.get(`${P}/sprints`, () => HttpResponse.json([{ key: 'SPR-1', name: 'Sprint 1' }])),
      http.get(`${P}/releases`, () => HttpResponse.json([])),
      http.get(`${P}/exploratory/metrics`, () => HttpResponse.json(metrics)),
      http.get(`${P}/heuristics`, () => HttpResponse.json({ suggested: ['SFDIPOT'], custom: ['RCRCRC'] })),
      http.put(`${P}/heuristics`, async ({ request }) => {
        saved = await request.json();
        return HttpResponse.json({ suggested: ['SFDIPOT'], custom: (saved as { custom: string[] }).custom });
      }),
    );
    return () => saved;
  }

  it('sessions à faire, en cours, à débriefer ; métriques ; heuristiques du projet', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const saved = serve();
    renderRoutes([{ path: '/p/:key/exploratory', element: <ExploratoryPage /> }], '/p/SHOP/exploratory');

    expect(await screen.findByTestId('todo-TC-24')).toHaveTextContent('Explorer le paiement');
    expect(await screen.findByTestId('session-row-TC-21-1')).toHaveTextContent('10:00');
    expect(await screen.findByTestId('session-row-TC-21-2')).toHaveTextContent('45 / 60 min');
    expect(screen.getByTestId('session-row-TC-21-2')).toHaveTextContent('à approuver');

    await userEvent.click(screen.getByTestId('exploratory-tab-metrics'));
    expect(await screen.findByTestId('m-charters')).toHaveTextContent('3 / 4');
    expect(screen.getByTestId('m-tbs')).toHaveTextContent('65 / 20 / 15');
    expect(screen.getByTestId('m-never-explored')).toHaveTextContent('Paiement');

    await userEvent.click(screen.getByTestId('exploratory-tab-heuristics'));
    await userEvent.type(await screen.findByTestId('custom-heuristics'), 'Persona{Enter}');
    await userEvent.click(screen.getByTestId('heuristics-save'));
    await waitFor(() => expect(saved()).toEqual({ custom: ['RCRCRC', 'Persona'] }));
  });
});

describe('F-EXP-04 générer des chartes depuis une exigence', () => {
  it('propositions cochées par défaut ; une rejetée ; chaque charte créée est liée au critère ou à l’ENF', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const proposals: CharterProposal[] = [
      { source: 'CRITERION', criterionPosition: 1, title: 'Explorer « Rechercher » : résultats', explore: 'Rechercher', with: 'des données variées', toDiscover: 'x', areas: ['Catalogue'], heuristics: ['SFDIPOT'], requirementKeys: ['REQ-2'] },
      { source: 'CRITERION', criterionPosition: 2, title: 'Explorer « Rechercher » : suggestions', explore: 'Rechercher', with: 'des données variées', toDiscover: 'y', areas: ['Catalogue'], heuristics: ['SFDIPOT'], requirementKeys: ['REQ-2'] },
      { source: 'NFR', title: 'Explorer « Rechercher » : Temps de réponse', explore: 'Rechercher', with: 'des conditions dégradées', toDiscover: 'z', areas: ['Catalogue'], heuristics: ['Goldilocks'], requirementKeys: ['REQ-2', 'REQ-30'] },
    ];
    const created: Record<string, unknown>[] = [];
    server.use(
      http.get(`${P}/requirements/REQ-2/charter-proposals`, () => HttpResponse.json(proposals)),
      http.post(`${P}/test-cases`, async ({ request }) => {
        created.push((await request.json()) as Record<string, unknown>);
        return HttpResponse.json({ key: `TC-${70 + created.length}` }, { status: 201 });
      }),
    );
    renderElement(<GenerateChartersModal project="SHOP" requirementKey="REQ-2" opened onClose={() => undefined} />);

    await waitFor(() => expect(screen.getByTestId('proposals-submit')).toHaveTextContent('Créer 3 chartes'));
    await userEvent.click(screen.getByTestId('proposal-check-2'));
    await userEvent.click(screen.getByTestId('proposals-submit'));

    await waitFor(() => expect(created).toHaveLength(2));
    expect(created[0]).toMatchObject({ kind: 'EXPLORATORY', title: 'Explorer « Rechercher » : résultats', links: [{ requirementKey: 'REQ-2', linkType: 'VERIFIES', criterionPositions: [1] }] });
    expect(created[1]).toMatchObject({
      links: [{ requirementKey: 'REQ-2', criterionPositions: [] }, { requirementKey: 'REQ-30', criterionPositions: [] }],
      heuristics: ['Goldilocks'],
    });
  });
});
