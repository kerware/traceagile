import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import type { Comment, ExampleMap, Measurement } from '../../api/workshop';
import { AttachmentsPanel } from '../../components/attachments/AttachmentsPanel';
import { routeOf, splitKeys } from '../../components/keys/keys';
import { rehypeKeyLinks } from '../../components/markdown/keyLinks';
import { renderElement, renderRoutes } from '../../test/render';
import { ADMIN, server, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { AppLayout } from '../../layouts/AppLayout';
import { CommentsPanel } from './CommentsPanel';
import { ExampleMappingPanel } from './ExampleMappingPanel';
import { MeasurementsPanel } from './MeasurementsPanel';

const P = '/api/v1/projects/SHOP';
const PO: Schemas['MeResponse'] = { ...TESTER, login: 'po', projects: [{ key: 'SHOP', name: 'Boutique', role: 'PRODUCT_OWNER' }] };
const VIEWER: Schemas['MeResponse'] = { ...TESTER, login: 'viewer', projects: [{ key: 'SHOP', name: 'Boutique', role: 'VIEWER' }] };

const comment = (overrides: Partial<Comment> = {}): Comment => ({
  id: 'c-1', author: 'qa1', text: 'Et pour un panier de 50 € pile ?', question: true, open: true, createdAt: '2026-10-20T08:00:00Z', ...overrides,
});
const map = (overrides: Partial<ExampleMap> = {}): ExampleMap => ({
  storyKey: 'REQ-2', storyTitle: 'Calculer les frais de port', asA: 'client', iWant: 'connaître les frais', soThat: 'décider',
  rules: [{
    rule: { id: 'r-1', kind: 'RULE', text: 'Livraison gratuite dès 50 €', position: 1 },
    examples: [{ id: 'e-1', kind: 'EXAMPLE', ruleId: 'r-1', text: 'Panier de 50 € : offerte', position: 1 }],
  }],
  questions: [comment(), comment({ id: 'c-2', text: 'DOM-TOM ?', open: false, resolvedBy: 'po' })],
  openQuestions: 1,
  ...overrides,
});

describe('ADR-0024 clés cliquables', () => {
  it('reconnaît les clés, calcule la route de leur fiche et les rend cliquables dans le Markdown (hors liens et code)', () => {
    expect(splitKeys('Voir REQ-12 et TC-4.')).toEqual([
      { text: 'Voir ', key: false }, { text: 'REQ-12', key: true }, { text: ' et ', key: false }, { text: 'TC-4', key: true }, { text: '.', key: false },
    ]);
    expect(routeOf('SHOP', 'DEF-3')).toBe('/p/SHOP/defects?selected=DEF-3');
    expect(routeOf('SHOP', 'RPT-1')).toBe('/p/SHOP/reports/RPT-1');
    expect(routeOf('SHOP', 'XYZ-1')).toBeNull();
    const tree = { type: 'root', children: [
      { type: 'element', tagName: 'p', children: [{ type: 'text', value: 'Lié à REQ-2' }] },
      { type: 'element', tagName: 'code', children: [{ type: 'text', value: 'REQ-3' }] },
    ] };
    rehypeKeyLinks('SHOP')()(tree as never);
    expect(JSON.stringify(tree.children[0])).toContain('"href":"/p/SHOP/requirements/REQ-2"');
    expect(JSON.stringify(tree.children[1])).not.toContain('href');
  });
});

describe('§4.4 atelier Example Mapping (F-REQ-13, F-REQ-14)', () => {
  it('quatre colonnes ; le testeur ajoute une règle, convertit un exemple, mais pas une règle ; résout une question', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const calls: { url: string; body: unknown }[] = [];
    server.use(
      http.get(`${P}/requirements/REQ-2/example-map`, () => HttpResponse.json(map())),
      http.post(`${P}/requirements/REQ-2/example-cards`, async ({ request }) => {
        calls.push({ url: 'card', body: await request.json() });
        return HttpResponse.json({ id: 'r-2', kind: 'RULE', text: 'x', position: 2 }, { status: 201 });
      }),
      http.post(`${P}/example-cards/e-1/convert`, () => {
        calls.push({ url: 'convert', body: null });
        return HttpResponse.json({ card: { id: 'e-1', kind: 'EXAMPLE', text: 'x', position: 1, convertedTo: 'Critère 2' }, criterionPosition: 2 },
          { status: 201 });
      }),
      http.post(`${P}/comments/c-1/resolve`, async ({ request }) => {
        calls.push({ url: 'resolve', body: await request.json() });
        return HttpResponse.json(comment({ open: false }));
      }),
    );
    renderElement(<ExampleMappingPanel project="SHOP" requirementKey="REQ-2" />);

    expect(await screen.findByTestId('em-story')).toHaveTextContent('Calculer les frais de port');
    expect(screen.getByTestId('open-questions')).toHaveTextContent('1 question ouverte');
    expect(screen.getByTestId('em-examples-1')).toHaveTextContent('Panier de 50 € : offerte');
    expect(screen.getByTestId('em-question-DOM-TOM ?')).toHaveTextContent('Résolue par po');

    await userEvent.type(screen.getByTestId('em-add-rule'), 'Frais de 4,90 € sinon{Enter}');
    await waitFor(() => expect(calls).toContainEqual({ url: 'card', body: { kind: 'RULE', text: 'Frais de 4,90 € sinon' } }));

    await userEvent.click(within(screen.getByTestId('em-card-Livraison gratuite dès 50 €')).getByTestId('em-card-menu'));
    expect(screen.queryByTestId('em-convert')).not.toBeInTheDocument();
    await userEvent.keyboard('{Escape}');
    await userEvent.click(within(screen.getByTestId('em-card-Panier de 50 € : offerte')).getByTestId('em-card-menu'));
    await userEvent.click(await screen.findByTestId('em-convert'));
    await waitFor(() => expect(calls.map((c) => c.url)).toContain('convert'));
    expect(await screen.findByText('Critère 2 créé (Gherkin à compléter)')).toBeInTheDocument();

    await userEvent.click(within(screen.getByTestId('em-question-Et pour un panier de 50 € pile ?')).getByTestId('em-resolve'));
    await waitFor(() => expect(calls).toContainEqual({ url: 'resolve', body: { resolved: true } }));
  });

  it('le PO peut convertir une règle en règle métier ; le lecteur ne voit aucune action', async () => {
    useAuthStore.getState().setSession('jwt', PO);
    server.use(http.get(`${P}/requirements/REQ-2/example-map`, () => HttpResponse.json(map())));
    renderElement(<ExampleMappingPanel project="SHOP" requirementKey="REQ-2" />);
    await userEvent.click(within(await screen.findByTestId('em-card-Livraison gratuite dès 50 €')).getByTestId('em-card-menu'));
    expect(await screen.findByTestId('em-convert')).toHaveTextContent('Convertir en règle métier');

    useAuthStore.getState().setSession('jwt', VIEWER);
    renderElement(<ExampleMappingPanel project="SHOP" requirementKey="REQ-2" />);
    // le changement d'utilisateur s'applique aussi au premier panneau : plus aucune action
    await screen.findAllByTestId('em-story');
    await waitFor(() => expect(screen.queryAllByTestId('em-add-rule')).toHaveLength(0));
    expect(screen.queryAllByTestId('em-card-menu')).toHaveLength(0);
  });
});

describe('§13.2 commentaires (ADR-0024)', () => {
  it('pose une question, seul l’auteur modifie ou supprime son commentaire, les clés citées sont des liens', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let posted: unknown = null;
    server.use(
      http.get(`${P}/requirements/REQ-2/comments`, () => HttpResponse.json([
        comment({ id: 'c-9', author: 'po', text: 'Voir REQ-7 pour les seuils', question: false, open: false }),
        comment({ id: 'c-1', author: 'qa1' }),
      ])),
      http.post(`${P}/requirements/REQ-2/comments`, async ({ request }) => {
        posted = await request.json();
        return HttpResponse.json(comment({ id: 'c-3' }), { status: 201 });
      }),
    );
    renderElement(<CommentsPanel project="SHOP" requirementKey="REQ-2" requirementId="req-2" />);

    const others = await screen.findByTestId('comment-c-9');
    expect(within(others).queryByTestId('comment-edit')).not.toBeInTheDocument();
    // le rendu Markdown est chargé à la demande : délai plus long sous charge
    await waitFor(() => expect(within(others).getByRole('link', { name: 'REQ-7' })).toHaveAttribute('href', '/p/SHOP/requirements/REQ-7'),
      { timeout: 5000 });
    expect(within(screen.getByTestId('comment-c-1')).getByTestId('comment-edit')).toBeInTheDocument();
    expect(screen.getByTestId('comment-question-open')).toHaveTextContent('Question ouverte');

    await userEvent.type(screen.getByTestId('comment-input'), 'Quel transporteur ?');
    await userEvent.click(screen.getByTestId('comment-question'));
    await userEvent.click(screen.getByTestId('comment-submit'));
    await waitFor(() => expect(posted).toEqual({ text: 'Quel transporteur ?', question: true }));
  });
});

describe('F-REQ-18 valeurs mesurées d’une ENF', () => {
  it('dernière mesure et son verdict, historique avec le test et le run d’origine, saisie d’une mesure', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    let recorded: unknown = null;
    const measurements: Measurement[] = [
      { value: 1200, unit: 'ms', metric: 'p95Ms', testKey: 'TC-31', runKey: 'RUN-2', measuredAt: '2026-10-20T09:00:00Z', outcome: 'THRESHOLD_MET' },
    ];
    server.use(
      http.get(`${P}/requirements/REQ-40/measurements`, () => HttpResponse.json(measurements)),
      http.post(`${P}/requirements/REQ-40/measurements`, async ({ request }) => {
        recorded = await request.json();
        return HttpResponse.json({ ...measurements[0], value: 700, outcome: 'TARGET_MET' }, { status: 201 });
      }),
    );
    renderElement(<MeasurementsPanel project="SHOP" requirementKey="REQ-40" threshold="1500" target="800" unit="ms" />);
    expect(await screen.findByTestId('measurement-last')).toHaveTextContent('1200 ms');
    expect(screen.getByTestId('measurement-last').querySelector('[data-outcome]')).toHaveAttribute('data-outcome', 'THRESHOLD_MET');
    expect(screen.getByTestId('measurements')).toHaveTextContent('seuil 1500 · cible 800 ms');
    expect(screen.getByTestId('key-RUN-2')).toBeInTheDocument();
    await userEvent.type(screen.getByTestId('measurement-input'), '700');
    await userEvent.click(screen.getByTestId('measurement-submit'));
    await waitFor(() => expect(recorded).toEqual({ value: 700 }));
  });
});

describe('ADR-0024 pièces jointes', () => {
  it('liste, téléversement d’un fichier, collage d’une image ; sans droit, ni ajout ni suppression', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    const uploads: string[] = [];
    server.use(
      http.get(`${P}/attachments`, () => HttpResponse.json([{ id: 'a-1', targetType: 'EXECUTION_STEP', targetId: 's-1', fileName: 'trace.log',
        contentType: 'text/plain', size: 12, image: false, createdAt: '2026-10-20T08:00:00Z' }])),
      // jsdom ne transmet pas le FormData à MSW (incompatibilité jsdom / undici) : on vérifie la requête et son porteur
      http.post(`${P}/attachments`, ({ request }) => {
        const url = new URL(request.url);
        uploads.push(`${url.searchParams.get('targetType')}:${url.searchParams.get('targetId')}`);
        return HttpResponse.json({}, { status: 201 });
      }),
    );
    renderElement(<AttachmentsPanel project="SHOP" target="EXECUTION_STEP" targetId="s-1" canWrite pasteZone />);
    expect(await screen.findByTestId('attachment-trace.log')).toBeInTheDocument();
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    await userEvent.upload(input, new File(['x'], 'ecran.png', { type: 'image/png' }));
    await waitFor(() => expect(uploads).toEqual(['EXECUTION_STEP:s-1']));
    const pasted = new File(['y'], 'image.png', { type: 'image/png' });
    fireEvent.paste(screen.getByTestId('attachments'), { clipboardData: { files: [pasted] } });
    await waitFor(() => expect(uploads).toHaveLength(2));

    renderElement(<AttachmentsPanel project="SHOP" target="EXECUTION_STEP" targetId="s-1" canWrite={false} testId="readonly" />);
    await within(await screen.findByTestId('readonly')).findByTestId('attachment-trace.log');
    expect(screen.queryByTestId('readonly-add')).not.toBeInTheDocument();
  });
});

describe('§13.1 / §13.3 barre supérieure : recherche Ctrl+K, aide « ? », sprint actif, notifications', () => {
  it('Ctrl+K ouvre la recherche ; Entrée ouvre le résultat choisi ; « ? » affiche l’aide ; notifications et sprint actif', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    server.use(
      http.get(`${P}/search`, ({ request }) => HttpResponse.json(new URL(request.url).searchParams.get('q') === 'pai'
        ? [{ type: 'REQUIREMENT', key: 'REQ-1', title: 'Paiement', detail: 'FEATURE' }, { type: 'DEFECT', key: 'DEF-1', title: 'Paiement refusé', detail: 'BLOCKER' }]
        : [])),
      http.get(`${P}/notifications`, () => HttpResponse.json({ activeSprintKey: 'SPR-2', activeSprintName: 'Sprint 2', myTests: 3, sessionsToApprove: 1,
        blockingDefects: 2, failedRuns: 0 })),
    );
    const { router } = renderRoutes([{ path: '/', element: <AppLayout />, children: [
      { path: 'p/:key/dashboard', element: <div>Tableau</div> },
      { path: 'p/:key/defects', element: <div data-testid="defects-route">Anomalies</div> },
    ] }], '/p/SHOP/dashboard');

    expect(await screen.findByTestId('active-sprint')).toHaveTextContent('SPR-2 — Sprint 2');
    await userEvent.click(screen.getByTestId('notifications'));
    expect(await screen.findByTestId('notification-myTests')).toHaveTextContent('3');
    await userEvent.keyboard('{Escape}');

    await userEvent.keyboard('{Control>}k{/Control}');
    await userEvent.type(await screen.findByTestId('search-input'), 'pai');
    expect(await screen.findByTestId('search-hit-DEF-1')).toHaveTextContent('Paiement refusé');
    await userEvent.keyboard('{ArrowDown}{Enter}');
    await waitFor(() => expect(router.state.location.pathname).toBe('/p/SHOP/defects'));
    expect(router.state.location.search).toBe('?selected=DEF-1');

    await userEvent.keyboard('?');
    expect(await screen.findByTestId('shortcuts-help')).toHaveTextContent('Pas courant en échec');
  });
});
