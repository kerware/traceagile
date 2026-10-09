import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { RequirementDetail } from '../../api/requirements';
import { renderElement } from '../../test/render';
import { detail } from '../../test/requirements';
import { ADMIN, page, server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { RequirementDetailView } from './RequirementDetailView';

const URL = '/api/v1/projects/SHOP/requirements/REQ-3';

function serve(requirement: RequirementDetail) {
  server.use(
    http.get(URL, () => HttpResponse.json(requirement)),
    http.get('/api/v1/projects/SHOP/requirements/tree', () => HttpResponse.json([])),
    http.get(`${URL}/checklists`, () =>
      HttpResponse.json({
        dor: [
          { id: 'i1', label: 'Au moins un critère d’acceptation', rule: 'HAS_ACCEPTANCE_CRITERION', automatic: true, outcome: 'SATISFIED' },
          { id: 'i3', label: 'Story comprise et acceptée par l’équipe', automatic: false, outcome: 'UNSATISFIED' },
        ],
        dod: [{ id: 'i4', label: 'Tous les tests liés passés', rule: 'ALL_LINKED_TESTS_PASSED', automatic: true, outcome: 'NOT_EVALUATED' }],
      }),
    ),
  );
}

function view() {
  return renderElement(<RequirementDetailView project="SHOP" requirementKey="REQ-3" />);
}

describe('§13.2 fiche exigence', () => {
  it('F-REQ-05 / F-REQ-07 affiche la phrase de la story et l’alerte « à découper »', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3', { storyPoints: 13, needsSplitting: true }));
    view();

    expect(await screen.findByTestId('story-sentence')).toHaveTextContent(
      'En tant que client, je veux la livraison offerte afin de commander plus.',
    );
    expect(screen.getByTestId('split-warning')).toBeInTheDocument();
  });

  it('§12 PATCH : seuls les champs modifiés sont envoyés, avec If-Match', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    let body: unknown;
    let ifMatch: string | null = null;
    server.use(
      http.patch(URL, async ({ request }) => {
        body = await request.json();
        ifMatch = request.headers.get('If-Match');
        return HttpResponse.json(detail('REQ-3', { title: 'Livraison offerte', version: 3 }));
      }),
    );
    view();

    const title = await screen.findByTestId('field-title');
    await userEvent.clear(title);
    await userEvent.type(title, 'Livraison offerte');
    await userEvent.click(screen.getByTestId('requirement-save'));

    await waitFor(() => expect(body).toEqual({ title: 'Livraison offerte' }));
    expect(ifMatch).toBe('"2"');
  });

  it('F-REQ-20 passage à READY : liste de contrôle, confirmation des items manuels', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    let sent: unknown;
    server.use(
      http.post(`${URL}/status`, async ({ request }) => {
        sent = await request.json();
        return HttpResponse.json(detail('REQ-3', { status: 'READY' }));
      }),
    );
    view();

    await userEvent.click(await screen.findByTestId('status-menu'));
    await userEvent.click(await screen.findByTestId('status-option-READY'));

    const dialog = await screen.findByRole('dialog');
    expect(await within(dialog).findByText('Story comprise et acceptée par l’équipe')).toBeInTheDocument();
    const confirm = within(dialog).getByTestId('status-confirm');
    expect(confirm).toBeDisabled();
    await userEvent.click(within(dialog).getByTestId('status-acknowledge'));
    await userEvent.click(confirm);

    await waitFor(() => expect(sent).toEqual({ status: 'READY', acknowledgeUnmet: true }));
  });

  it('F-REQ-07 INVEST coché par un testeur', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(detail('REQ-3'));
    let body: Record<string, boolean> | undefined;
    server.use(
      http.put(`${URL}/invest`, async ({ request }) => {
        body = (await request.json()) as Record<string, boolean>;
        return HttpResponse.json(detail('REQ-3'));
      }),
    );
    view();

    await userEvent.click(await screen.findByTestId('invest-testable'));

    await waitFor(() => expect(body?.testable).toBe(true));
    expect(body?.small).toBe(false);
    expect(screen.queryByTestId('requirement-save')).not.toBeInTheDocument();
  });
});

describe('F-REQ-09 / F-REQ-10 critères d’acceptation', () => {
  it('affiche les erreurs Gherkin à la frappe et refuse l’enregistrement', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    server.use(
      http.post('/api/v1/gherkin/validate', () =>
        HttpResponse.json({ valid: false, language: 'fr', errors: [{ line: 2, column: 3, message: 'expected: #Step, got Truc' }] }),
      ),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: /Critères/ }));
    await userEvent.click(screen.getByTestId('criterion-add'));
    await userEvent.click(screen.getByText('Gherkin'));
    await userEvent.type(screen.getByTestId('criterion-content'), 'Scénario: x{enter}Truc');

    expect(await screen.findByText(/expected: #Step, got Truc/)).toBeInTheDocument();
    expect(screen.getByText('ligne 2')).toBeInTheDocument();
    expect(screen.getByTestId('criterion-save')).toBeDisabled();
  });

  it('ajoute un critère texte', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    let body: unknown;
    server.use(
      http.post(`${URL}/acceptance-criteria`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json({ id: 'c1', position: 1, format: 'TEXT', content: 'Le total est affiché', status: 'TO_VERIFY', version: 0 }, { status: 201 });
      }),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: /Critères/ }));
    await userEvent.click(screen.getByTestId('criterion-add'));
    await userEvent.type(screen.getByTestId('criterion-content'), 'Le total est affiché');
    await userEvent.click(screen.getByTestId('criterion-save'));

    await waitFor(() => expect(body).toEqual({ format: 'TEXT', content: 'Le total est affiché' }));
  });
});

describe('F-REQ-21 / F-REQ-22 versions et historique', () => {
  it('compare deux versions côte à côte', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3', { currentVersion: 2 }));
    server.use(
      http.get(`${URL}/versions`, () =>
        HttpResponse.json([
          { versionNumber: 2, createdAt: '2026-10-08T11:00:00Z', createdBy: 'po', snapshot: { title: 'Livraison offerte' } },
          { versionNumber: 1, changeComment: 'Passage à READY', createdAt: '2026-10-08T10:00:00Z', createdBy: 'po', snapshot: { title: 'Livraison gratuite' } },
        ]),
      ),
      http.get(`${URL}/versions/1/diff/2`, () =>
        HttpResponse.json([{ field: 'title', before: 'Livraison gratuite', after: 'Livraison offerte' }]),
      ),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: 'Versions' }));

    const diff = await screen.findByTestId('version-diff');
    expect(within(diff).getByText('Titre')).toBeInTheDocument();
    expect(within(diff).getByText('Livraison gratuite')).toBeInTheDocument();
    expect(within(diff).getByText('Livraison offerte')).toBeInTheDocument();
  });

  it('liste les événements d’audit', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    server.use(
      http.get(`${URL}/history`, () =>
        HttpResponse.json(
          page([{ action: 'UPDATED', actor: 'po', timestamp: '2026-10-08T10:00:00Z', changes: [{ field: 'priority', before: 'SHOULD', after: 'MUST' }] }]),
        ),
      ),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: 'Historique' }));

    const history = await screen.findByTestId('history');
    expect(within(history).getByText('Modification')).toBeInTheDocument();
    expect(within(history).getByText(/par po/)).toBeInTheDocument();
    expect(within(history).getByText('MUST')).toBeInTheDocument();
  });
});

describe('Lot 2 — F-REQ-11 génération d’un test BDD et tests liés', () => {
  it('génère un test BDD depuis un critère Gherkin', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3', {
      criteria: [{ id: 'c1', position: 1, format: 'GHERKIN', content: 'Scénario: seuil\n  Soit un panier', status: 'TO_VERIFY', version: 0 }],
    }));
    let called = false;
    server.use(
      http.post('/api/v1/projects/SHOP/acceptance-criteria/c1/generate-test', () => {
        called = true;
        return HttpResponse.json([{ key: 'TC-7' }], { status: 201 });
      }),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: /Critères/ }));
    await userEvent.click(screen.getByTestId('criterion-generate-1'));

    expect(await screen.findByText('Test BDD généré : TC-7')).toBeInTheDocument();
    expect(called).toBe(true);
  });

  it('le testeur voit les tests liés à l’exigence', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    server.use(
      http.get(`${URL}/test-cases`, () =>
        HttpResponse.json([{ key: 'TC-7', kind: 'AUTOMATED', title: 'Seuil', status: 'DRAFT', technique: 'BDD', linkType: 'VERIFIES', origin: 'GENERATED', criterionPositions: [1] }]),
      ),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: 'Tests liés' }));

    const row = await screen.findByTestId('linked-test-TC-7');
    expect(within(row).getByText('critères #1')).toBeInTheDocument();
    expect(within(row).getByText('BDD (Gherkin)')).toBeInTheDocument();
  });

  it('F-TRA-01 lier un test depuis la fiche exigence, avec type et critères', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(detail('REQ-3'));
    let body: unknown;
    server.use(
      http.get(`${URL}/test-cases`, () => HttpResponse.json([])),
      http.get('/api/v1/projects/SHOP/test-cases', () =>
        HttpResponse.json(page([{ key: 'TC-4', kind: 'MANUAL', title: 'Ajouter un produit', status: 'READY', priority: 'SHOULD', tags: [], currentVersion: 1, automationCandidate: false, missingInRepository: false }])),
      ),
      http.post('/api/v1/projects/SHOP/trace-links', async ({ request }) => {
        body = await request.json();
        return HttpResponse.json({ id: 'l9', testKey: 'TC-4', requirementKey: 'REQ-3', linkType: 'PARTIALLY_VERIFIES', origin: 'MANUAL', criterionPositions: [], suspect: false, version: 0 }, { status: 201 });
      }),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: 'Tests liés' }));
    await userEvent.click(await screen.findByTestId('link-test-select'));
    await userEvent.click(await screen.findByRole('option', { name: 'TC-4 — Ajouter un produit' }));
    await userEvent.click(screen.getByTestId('link-type-select'));
    await userEvent.click(await screen.findByRole('option', { name: 'Vérifie partiellement' }));
    await userEvent.click(screen.getByTestId('link-test-submit'));

    await waitFor(() => expect(body).toEqual({ testKey: 'TC-4', requirementKey: 'REQ-3', linkType: 'PARTIALLY_VERIFIES', criterionPositions: [] }));
  });

  it('§3.3-7 test lié suspect : alerte, revue et suppression du lien', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(detail('REQ-3', { verificationStatus: 'SUSPECT' }));
    const calls: string[] = [];
    server.use(
      http.get(`${URL}/test-cases`, () =>
        HttpResponse.json([{ linkId: 'l7', key: 'TC-7', kind: 'MANUAL', title: 'Seuil', status: 'NEEDS_UPDATE', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [], suspect: true }]),
      ),
      http.post('/api/v1/projects/SHOP/trace-links/l7/review', () => {
        calls.push('review');
        return HttpResponse.json({ id: 'l7', testKey: 'TC-7', requirementKey: 'REQ-3', linkType: 'VERIFIES', origin: 'MANUAL', criterionPositions: [], suspect: false, version: 1 });
      }),
      http.delete('/api/v1/projects/SHOP/trace-links/l7', () => {
        calls.push('delete');
        return new HttpResponse(null, { status: 204 });
      }),
    );
    view();

    expect(await screen.findByTestId('requirement-verification')).toHaveAttribute('data-status', 'SUSPECT');
    await userEvent.click(screen.getByRole('tab', { name: 'Tests liés' }));
    expect(await screen.findByTestId('linked-suspect-TC-7')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('linked-review-TC-7'));
    await userEvent.click(screen.getByTestId('linked-unlink-TC-7'));

    await waitFor(() => expect(calls).toEqual(['review', 'delete']));
  });

  it('F-TRA-05 onglet Traçabilité : parents, critères et leur état, tests liés, impact', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    serve(detail('REQ-3'));
    server.use(
      http.get(`${URL}/trace-tree`, () =>
        HttpResponse.json({
          requirement: { key: 'REQ-3', title: 'Ajouter', type: 'USER_STORY', status: 'READY', verificationStatus: 'NOT_RUN', children: [] },
          ancestors: [{ key: 'REQ-1', title: 'Panier', type: 'EPIC', status: 'DRAFT', verificationStatus: 'NOT_RUN', children: [] }],
          criteria: [{ position: 1, format: 'TEXT', content: 'Le produit est ajouté', status: 'TO_VERIFY', testKeys: ['TC-1'] },
            { position: 2, format: 'TEXT', content: 'Le total change', status: 'TO_VERIFY', testKeys: [] }],
          tests: [{ test: { key: 'TC-1', title: 'Ajouter', kind: 'MANUAL', status: 'READY' }, linkId: 'l1', linkType: 'VERIFIES', origin: 'MANUAL', suspect: false, criterionPositions: [1] }],
          defects: [],
        }),
      ),
      http.get(`${URL}/impact`, () =>
        HttpResponse.json({ requirement: { key: 'REQ-3', title: 'Ajouter', type: 'USER_STORY', status: 'READY', riskLevel: 'MEDIUM' }, tests: [], campaigns: [] }),
      ),
    );
    view();

    await userEvent.click(await screen.findByTestId('tab-traceability'));

    expect(await screen.findByText('REQ-1')).toBeInTheDocument();
    expect(within(screen.getByTestId('trace-criterion-1')).getByText('TC-1')).toBeInTheDocument();
    expect(within(screen.getByTestId('trace-criterion-2')).getByText('aucun test')).toBeInTheDocument();
    expect(within(screen.getByTestId('trace-tests')).getByText('jamais exécuté')).toBeInTheDocument();
    expect(await within(screen.getByTestId('trace-impact')).findByTestId('impact-summary')).toHaveTextContent('0 test à revoir');
  });
});
