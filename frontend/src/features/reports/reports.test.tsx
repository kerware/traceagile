import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import type { Dashboard, ReportDefinition, ReportDetail, ReportSummary } from '../../api/reports';
import type { Schemas } from '../../api/client';
import { labelIndexes, niceMax, polylines } from '../../components/charts/geometry';
import { renderRoutes } from '../../test/render';
import { problem, server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { DashboardPage } from '../dashboard/DashboardPage';
import { percentLabel, shortDate } from '../dashboard/model';
import { appliesTo, move, toggle } from './model';
import { ReportPage } from './ReportPage';
import { ReportsPage } from './ReportsPage';

const P = '/api/v1/projects/SHOP';
const PO: Schemas['MeResponse'] = { ...TESTER, login: 'po', projects: [{ key: 'SHOP', name: 'Boutique', role: 'PRODUCT_OWNER' }] };
const VIEWER: Schemas['MeResponse'] = { ...TESTER, login: 'viewer', projects: [{ key: 'SHOP', name: 'Boutique', role: 'VIEWER' }] };

const sprintReview: ReportDefinition = {
  id: 'd-1', name: 'Bilan de sprint', scopeType: 'SPRINT', sections: ['SUMMARY', 'DELIVERY', 'COVERAGE', 'EXECUTION', 'EXPLORATORY', 'DEFECTS', 'RISKS', 'RECOMMENDATION'],
  defaultFormat: 'PDF', includeCharts: true, includeDetails: false, builtIn: true,
};
const quality: ReportDefinition = {
  id: 'd-2', name: 'Synthèse qualité', description: 'Pour le comité', scopeType: 'SPRINT', sections: ['COVERAGE', 'DEFECT_LIST'], defaultFormat: 'DOCX',
  includeCharts: true, includeDetails: true, builtIn: false,
};
const summary = (overrides: Partial<ReportSummary> = {}): ReportSummary => ({
  key: 'RPT-2', title: 'Bilan de sprint — SPR-2 — Sprint 2', definitionName: 'Bilan de sprint', scopeType: 'SPRINT', scope: 'sprint:SPR-2',
  scopeLabel: 'SPR-2 — Sprint 2', verdict: 'NO_GO', computedVerdict: 'NO_GO', frozen: false, createdAt: '2026-10-20T08:00:00Z', createdBy: 'po', ...overrides,
});
const detail = (overrides: Partial<ReportSummary> = {}, extra: Partial<ReportDetail> = {}): ReportDetail => ({
  report: summary(overrides), sections: sprintReview.sections, includeCharts: true, includeDetails: false, data: {}, ...extra,
});
const sprints = [
  { key: 'SPR-1', name: 'Sprint 1', status: 'CLOSED' },
  { key: 'SPR-2', name: 'Sprint 2', status: 'ACTIVE' },
];

describe('ADR-0023 règles d’affichage des rapports et des graphiques', () => {
  it('sections : applicables au périmètre, ajout en fin, retrait, ordre', () => {
    expect(appliesTo('REGRESSION', 'SPRINT')).toBe(false);
    expect(appliesTo('BURNDOWN', 'RELEASE')).toBe(true);
    expect(appliesTo('SPRINT_TREND', 'PROJECT')).toBe(true);
    expect(toggle(['SUMMARY'], 'COVERAGE')).toEqual(['SUMMARY', 'COVERAGE']);
    expect(toggle(['SUMMARY', 'COVERAGE'], 'SUMMARY')).toEqual(['COVERAGE']);
    expect(move(['SUMMARY', 'COVERAGE', 'DEFECTS'], 'DEFECTS', -1)).toEqual(['SUMMARY', 'DEFECTS', 'COVERAGE']);
    expect(move(['SUMMARY', 'COVERAGE'], 'SUMMARY', -1)).toEqual(['SUMMARY', 'COVERAGE']);
  });

  it('F-RPT-02 graphiques : échelle lisible, courbe interrompue par un jour futur, libellés espacés', () => {
    expect(niceMax([0, 13, 7])).toBe(20);
    expect(niceMax([0.4])).toBe(0.5);
    expect(niceMax([])).toBe(1);
    expect(polylines([5, 4, null, null], (i) => i, (v) => v)).toEqual(['0.0,5.0 1.0,4.0']);
    expect(polylines([5, null, 3], (i) => i, (v) => v)).toEqual(['0.0,5.0', '2.0,3.0']);
    expect(labelIndexes(14, 8)).toEqual([0, 2, 4, 6, 8, 10, 12, 13]);
    expect(shortDate('2026-10-14')).toBe('14/10');
    expect(percentLabel(87.5)).toBe('88 %');
    expect(percentLabel(undefined)).toBe('—');
  });
});

describe('§9.1 /p/:key/dashboard — widgets (F-RPT-01) et graphiques (F-RPT-02)', () => {
  it('sprint actif, couverture, dernière campagne, anomalies, sessions, runs, burndown interrompu à aujourd’hui', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const dashboard: Dashboard = {
      activeSprint: { key: 'SPR-2', name: 'Sprint 2', goal: 'Payer en ligne', startDate: '2026-10-12', endDate: '2026-10-25', daysLeft: 5, donePoints: 8,
        committedPoints: 13 },
      sprintCoverage: { scope: 'sprint:SPR-2', design: { numerator: 3, denominator: 4, percent: 75 }, validation: { numerator: 1, denominator: 4, percent: 25 } },
      releaseCoverage: { scope: 'release:REL-1', design: { percent: 80 }, validation: { percent: 60 } },
      lastCampaign: { key: 'CMP-2', name: 'Recette SPR-2', status: 'IN_PROGRESS', total: 10, byStatus: { PASSED: 4, FAILED: 1, NOT_RUN: 5 } },
      openDefectsBySeverity: { BLOCKER: 1, CRITICAL: 0, MAJOR: 2, MINOR: 1, TRIVIAL: 0 },
      weekSessions: { sessions: 3, minutes: 190, debriefed: 2, awaitingApproval: 1 },
      lastRuns: [{ key: 'RUN-3', status: 'COMPLETED', campaignKey: 'CMP-2', total: 4, passed: 3, failed: 1, passRate: 75 }],
      burndown: [{ label: '2026-10-12', actual: 13, reference: 13 }, { label: '2026-10-13', actual: 8, reference: 6.5 }, { label: '2026-10-14', reference: 0 }],
      releaseKey: 'REL-1',
      burnup: [{ label: 'SPR-1', actual: 9, reference: 30 }, { label: 'SPR-2', actual: 17, reference: 30 }],
      automatedTrend: [{ key: 'RUN-1', passRate: 50 }, { key: 'RUN-2', passRate: 100 }],
      defectsBySprint: [{ key: 'SPR-1', defectsCreated: 3, defectsClosed: 2 }],
    };
    server.use(http.get(`${P}/dashboard`, () => HttpResponse.json(dashboard)), http.get(`${P}`, () => HttpResponse.json({ key: 'SHOP', name: 'Boutique' })));
    renderRoutes([{ path: '/p/:key/dashboard', element: <DashboardPage /> }], '/p/SHOP/dashboard');

    expect(await screen.findByTestId('widget-sprint-days')).toHaveTextContent('5 jours restants');
    expect(screen.getByTestId('widget-sprint-points')).toHaveTextContent('8 / 13 points terminés');
    expect(screen.getByTestId('coverage-validation-Sprint')).toHaveTextContent('25 %');
    expect(screen.getByTestId('widget-campaign-FAILED')).toHaveTextContent('1');
    expect(screen.getByTestId('widget-defects-BLOCKER')).toHaveTextContent('1');
    expect(screen.getByTestId('widget-sessions-count')).toHaveTextContent('3');
    expect(screen.getByTestId('widget-run-RUN-3')).toHaveTextContent('3 / 4 réussis');
    const burndown = screen.getByTestId('chart-burndown');
    expect(burndown.querySelectorAll('polyline[data-series="Restant"]')).toHaveLength(1);
    expect(burndown.querySelector('polyline[data-series="Restant"]')?.getAttribute('points')?.split(' ')).toHaveLength(2);
    expect(screen.getByTestId('chart-defects-by-sprint').querySelectorAll('rect')).toHaveLength(2);
  });
});

describe('§13.2 /p/:key/reports — rapports générés, modèles, génération (ADR-0023)', () => {
  it('liste avec verdict et état figé ; génération du bilan du sprint actif puis ouverture du rapport', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let body: unknown = null;
    server.use(
      http.get(`${P}/reports`, () => HttpResponse.json([summary({ key: 'RPT-1', scope: 'sprint:SPR-1', frozen: true, verdict: 'GO_WITH_RESERVATIONS' })])),
      http.get(`${P}/report-definitions`, () => HttpResponse.json([sprintReview, quality])),
      http.get(`${P}/sprints`, () => HttpResponse.json(sprints)),
      http.get(`${P}/releases`, () => HttpResponse.json([])),
      http.post(`${P}/reports`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json(detail(), { status: 201 });
      }),
      http.get(`${P}/reports/RPT-2`, () => HttpResponse.json(detail())),
      http.get(`${P}/reports/RPT-2/export`, () => new HttpResponse('<html><body><h1>Bilan</h1></body></html>', { headers: { 'Content-Type': 'text/html' } })),
    );
    renderRoutes([{ path: '/p/:key/reports', element: <ReportsPage /> }, { path: '/p/:key/reports/:rk', element: <ReportPage /> }], '/p/SHOP/reports');

    const row = await screen.findByTestId('report-row-RPT-1');
    expect(within(row).getByTestId('report-verdict-RPT-1')).toHaveTextContent('Go sous réserve');
    expect(row).toHaveTextContent('Figé');

    await userEvent.click(screen.getByTestId('report-generate'));
    await waitFor(() => expect(screen.getByTestId('generate-scope')).toHaveValue('SPR-2 — Sprint 2 (Actif)'));
    await userEvent.click(screen.getByTestId('generate-submit'));
    expect(await screen.findByTestId('report-page')).toBeInTheDocument();
    expect(body).toEqual({ definitionId: 'd-1', scopeKey: 'SPR-2' });
    expect(await screen.findByTestId('report-frame')).toHaveAttribute('srcdoc', expect.stringContaining('<h1>Bilan</h1>'));
  });

  it('modèles : nouveau modèle avec sections ordonnées ; le modèle intégré se duplique mais ne se modifie pas', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let created: Record<string, unknown> | null = null;
    server.use(
      http.get(`${P}/reports`, () => HttpResponse.json([])),
      http.get(`${P}/report-definitions`, () => HttpResponse.json([sprintReview, quality])),
      http.post(`${P}/report-definitions`, async ({ request }) => {
        created = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json({ ...quality, id: 'd-3' }, { status: 201 });
      }),
    );
    renderRoutes([{ path: '/p/:key/reports', element: <ReportsPage /> }], '/p/SHOP/reports?tab=definitions');

    await userEvent.click(await screen.findByTestId('definition-menu-Bilan de sprint'));
    expect(await screen.findByTestId('definition-duplicate')).toBeInTheDocument();
    expect(screen.queryByTestId('definition-edit')).not.toBeInTheDocument();
    await userEvent.keyboard('{Escape}');

    await userEvent.click(screen.getByTestId('definition-new'));
    await userEvent.type(screen.getByTestId('definition-name'), 'Comité qualité');
    await userEvent.click(screen.getByTestId('definition-toggle-EXECUTION'));
    await userEvent.click(screen.getByTestId('definition-toggle-BURNDOWN'));
    await userEvent.click(screen.getByTestId('definition-up-BURNDOWN'));
    await userEvent.click(screen.getByTestId('definition-submit'));
    await waitFor(() => expect(created).not.toBeNull());
    expect(created).toMatchObject({ name: 'Comité qualité', scopeType: 'SPRINT', sections: ['SUMMARY', 'COVERAGE', 'BURNDOWN', 'DEFECTS'],
      defaultFormat: 'PDF', includeCharts: true, includeDetails: false });
  });

  it('le lecteur consulte la liste et les règles du verdict sans pouvoir générer ni les modifier', async () => {
    useAuthStore.getState().setSession('jwt', VIEWER);
    server.use(
      http.get(`${P}/reports`, () => HttpResponse.json([])),
      http.get(`${P}/verdict-rules`, () => HttpResponse.json({ goMinValidation: 95, reservedMinValidation: 80, goForbidsCriticalDefects: true,
        goRequiresCriticalRequirements: true, reservedForbidsBlockerDefects: true })),
    );
    renderRoutes([{ path: '/p/:key/reports', element: <ReportsPage /> }], '/p/SHOP/reports?tab=rules');
    expect(await screen.findByTestId('rules-go')).toBeDisabled();
    expect(screen.getByTestId('rules-go')).toHaveValue('95 %');
    expect(screen.queryByTestId('rules-save')).not.toBeInTheDocument();
    expect(screen.queryByTestId('report-generate')).not.toBeInTheDocument();
  });
});

describe('§13.2 /p/:key/reports/:rk — verdict du PO (§9.2), gel (F-RPT-04), exports (F-RPT-03)', () => {
  it('le PO modifie le verdict avec un commentaire obligatoire ; le refus de l’API est affiché', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    let current = detail();
    let sent: unknown = null;
    server.use(
      http.get(`${P}/reports/RPT-2`, () => HttpResponse.json(current)),
      http.get(`${P}/reports/RPT-2/export`, () => new HttpResponse('<p>rapport</p>', { headers: { 'Content-Type': 'text/html' } })),
      http.put(`${P}/reports/RPT-2/verdict`, async ({ request }) => {
        sent = await request.json();
        if ((sent as { comment?: string }).comment === 'refus') return problem(422, 'VERDICT_COMMENT_REQUIRED', 'Expliquez en commentaire');
        current = detail({ verdict: 'GO_WITH_RESERVATIONS' }, { verdictOverride: 'GO_WITH_RESERVATIONS', verdictComment: 'Contournement validé', verdictBy: 'po' });
        return HttpResponse.json(current);
      }),
    );
    renderRoutes([{ path: '/p/:key/reports/:rk', element: <ReportPage /> }], '/p/SHOP/reports/RPT-2');

    expect(await screen.findByTestId('report-verdict')).toHaveTextContent('No go');
    expect(screen.queryByTestId('report-freeze')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('report-verdict-edit'));
    await userEvent.click(screen.getByTestId('verdict-select'));
    await userEvent.click(await screen.findByRole('option', { name: 'Go sous réserve' }));
    expect(screen.getByTestId('verdict-submit')).toBeDisabled();
    await userEvent.type(screen.getByTestId('verdict-comment'), 'refus');
    await userEvent.click(screen.getByTestId('verdict-submit'));
    expect(await screen.findByTestId('verdict-error')).toHaveTextContent('Expliquez en commentaire');
    await userEvent.clear(screen.getByTestId('verdict-comment'));
    await userEvent.type(screen.getByTestId('verdict-comment'), 'Contournement validé');
    await userEvent.click(screen.getByTestId('verdict-submit'));

    await waitFor(() => expect(screen.getByTestId('report-verdict')).toHaveTextContent('Go sous réserve'));
    expect(sent).toEqual({ verdict: 'GO_WITH_RESERVATIONS', comment: 'Contournement validé' });
    expect(screen.getByTestId('report-verdict-comment')).toHaveTextContent('Verdict calculé : No go — Contournement validé');
  });

  it('le testeur fige le rapport ; un rapport figé ne propose plus ni gel ni suppression ; export Word téléchargé', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    Object.assign(URL, { createObjectURL: vi.fn(() => 'blob:rapport'), revokeObjectURL: vi.fn() });
    const save = vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => undefined);
    let frozen = false;
    const exported: string[] = [];
    server.use(
      http.get(`${P}/reports/RPT-2`, () => HttpResponse.json(detail({ frozen, frozenAt: frozen ? '2026-10-25T17:00:00Z' : undefined, frozenBy: 'qa1' }))),
      http.get(`${P}/reports/RPT-2/export`, ({ request }) => {
        exported.push(new URL(request.url).search);
        return new HttpResponse('<p>rapport</p>', { headers: { 'Content-Type': 'text/html' } });
      }),
      http.post(`${P}/reports/RPT-2/freeze`, () => {
        frozen = true;
        return HttpResponse.json(detail({ frozen: true }));
      }),
    );
    renderRoutes([{ path: '/p/:key/reports/:rk', element: <ReportPage /> }], '/p/SHOP/reports/RPT-2');

    expect(screen.queryByTestId('report-verdict-edit')).not.toBeInTheDocument();
    await userEvent.click(await screen.findByTestId('report-freeze'));
    await userEvent.click(await screen.findByTestId('confirm-submit'));
    expect(await screen.findByTestId('report-frozen')).toBeInTheDocument();
    expect(screen.queryByTestId('report-freeze')).not.toBeInTheDocument();
    expect(screen.queryByTestId('report-delete')).not.toBeInTheDocument();

    await userEvent.click(screen.getByTestId('export-RPT-2'));
    await userEvent.click(await screen.findByTestId('export-RPT-2-DOCX'));
    await waitFor(() => expect(exported).toContain('?format=docx&download=true'));
    await waitFor(() => expect(save).toHaveBeenCalled());
    save.mockRestore();
  });
});
