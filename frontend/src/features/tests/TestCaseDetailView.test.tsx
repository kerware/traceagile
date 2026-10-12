import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { TestCaseDetail } from '../../api/testcases';
import { renderElement } from '../../test/render';
import { server, TESTER } from '../../test/server';
import { testDetail } from '../../test/testcases';
import { useAuthStore } from '../auth/authStore';
import { TestCaseDetailView } from './TestCaseDetailView';

const URL = '/api/v1/projects/SHOP/test-cases/TC-1';

function serve(test: TestCaseDetail) {
  server.use(
    http.get(URL, () => HttpResponse.json(test)),
    http.get('/api/v1/reference/frameworks', () => HttpResponse.json([{ technique: 'BDD', name: 'Cucumber-JVM', position: 1 }])),
    http.get('/api/v1/projects/SHOP/heuristics', () => HttpResponse.json({ suggested: ['SFDIPOT'], custom: ['RCRCRC'] })),
    http.get('/api/v1/projects/SHOP/requirements/REQ-2', () =>
      HttpResponse.json({ key: 'REQ-2', criteria: [] }),
    ),
    http.get('/api/v1/projects/SHOP/requirements/tree', () =>
      HttpResponse.json([{ key: 'REQ-2', type: 'FEATURE', title: 'Panier', status: 'DRAFT', priority: 'MUST', riskLevel: 'HIGH', rank: 'a', criteriaCount: 0, needsSplitting: false, children: [] }]),
    ),
  );
}

function view() {
  return renderElement(<TestCaseDetailView project="SHOP" testKey="TC-1" />);
}

function capturePatch() {
  const sent: { body?: Record<string, unknown>; ifMatch?: string | null } = {};
  server.use(
    http.patch(URL, async ({ request }) => {
      sent.body = (await request.json()) as Record<string, unknown>;
      sent.ifMatch = request.headers.get('If-Match');
      return HttpResponse.json(testDetail('TC-1', { currentVersion: 2, version: 4 }));
    }),
  );
  return sent;
}

describe('F-MAN-01 test manuel', () => {
  it('ajoute, duplique et réordonne des pas ; le PATCH envoie les pas avec If-Match', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1'));
    const sent = capturePatch();
    view();

    await userEvent.click(await screen.findByTestId('step-add'));
    await userEvent.type(screen.getByTestId('step-action-2'), 'Cliquer « Ajouter »');
    await userEvent.click(screen.getByTestId('step-duplicate-1'));
    await userEvent.click(screen.getByTestId('step-up-3'));
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body?.steps).toEqual([
      { action: 'Ouvrir la fiche', expectedResult: 'La fiche s’affiche', testData: null },
      { action: 'Cliquer « Ajouter »', expectedResult: null, testData: null },
      { action: 'Ouvrir la fiche', expectedResult: 'La fiche s’affiche', testData: null },
    ]));
    expect(sent.ifMatch).toBe('"3"');
    expect(await screen.findByText(/version 2/)).toBeInTheDocument();
  });

  it('F-MAN-01 détecte les ${nom} des pas comme paramètres ; jeux de données nommés (ADR-0013)', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', { parameters: [{ name: 'devise', defaultValue: 'EUR', detected: false }] }));
    const sent = capturePatch();
    view();

    const action = await screen.findByTestId('step-action-1');
    await userEvent.clear(action);
    // « {{ » saisit une accolade littérale avec user-event.
    await userEvent.type(action, 'Ouvrir ${{nom-produit}');
    expect(await screen.findByTestId('param-detected-nom-produit')).toBeInTheDocument();
    expect(screen.getByTestId('param-unused-devise')).toBeInTheDocument();
    expect(screen.getByTestId('param-remove-nom-produit')).toBeDisabled();
    await userEvent.type(screen.getByTestId('param-default-nom-produit'), 'Stylo');

    await userEvent.click(screen.getByTestId('dataset-add'));
    await userEvent.clear(screen.getByTestId('dataset-name-0'));
    await userEvent.type(screen.getByTestId('dataset-name-0'), 'Recette');
    await userEvent.click(screen.getByTestId('dataset-0-add-row'));
    await userEvent.type(screen.getByTestId('dataset-0-cell-0-nom-produit'), 'Cahier');
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body?.dataSets).toEqual([{ name: 'Recette', rows: [{ 'nom-produit': 'Cahier', devise: '' }], rowNames: [''] }]));
    expect(sent.body?.parameters).toEqual([
      { name: 'devise', defaultValue: 'EUR', description: null },
      { name: 'nom-produit', defaultValue: 'Stylo', description: null },
    ]);
  });

  it('ADR-0013 supprimer un paramètre déclaré retire sa colonne ; nom invalide refusé', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', {
      parameters: [{ name: 'a', detected: false }, { name: 'b', detected: false }],
      dataSets: [{ name: 'Recette', rows: [{ a: '1', b: '2' }], rowNames: ['Nominal'] }],
    }));
    const sent = capturePatch();
    view();

    await userEvent.type(await screen.findByTestId('param-new'), 'avec espace');
    expect(screen.getByTestId('param-add')).toBeDisabled();
    await userEvent.click(screen.getByTestId('param-remove-b'));
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body?.dataSets).toEqual([{ name: 'Recette', rows: [{ a: '1' }], rowNames: ['Nominal'] }]));
    expect(sent.body?.parameters).toEqual([{ name: 'a', defaultValue: null, description: null }]);
  });
});

describe('F-EXP-01 / F-EXP-02 charte exploratoire', () => {
  it('aperçu de la mission et durée cible', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', { kind: 'EXPLORATORY', steps: [], charter: { missionSentence: '', areas: [], heuristics: [], timeboxMin: 90 } }));
    const sent = capturePatch();
    view();

    await userEvent.type(await screen.findByTestId('charter-explore'), 'le panier');
    await userEvent.type(screen.getByTestId('charter-to-discover'), 'les incohérences');
    expect(screen.getByTestId('charter-preview')).toHaveTextContent('Explorer le panier pour découvrir les incohérences.');
    await userEvent.click(screen.getByText('60 min'));
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body).toMatchObject({ explore: 'le panier', toDiscover: 'les incohérences', timeboxMin: 60 }));
  });
});

describe('§6 test automatisé', () => {
  it('BDD : la source Gherkin est envoyée ; les avertissements de tags sont affichés (F-AUT-06)', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', {
      kind: 'AUTOMATED', steps: [],
      automation: { technique: 'BDD', framework: 'Cucumber-JVM', gherkinSource: 'Fonctionnalité: x', configuration: {}, executionTags: [], environmentRequirements: {}, keywords: [], missingInRepository: false },
    }));
    server.use(
      http.post('/api/v1/gherkin/validate', () => HttpResponse.json({ valid: true, language: 'fr', errors: [] })),
      http.patch(URL, () =>
        HttpResponse.json(testDetail('TC-1', {
          kind: 'AUTOMATED', steps: [], warnings: ['Tag @REQ-99 : exigence inconnue dans le projet SHOP.'],
          automation: { technique: 'BDD', framework: 'Cucumber-JVM', gherkinSource: 'x', configuration: {}, executionTags: [], environmentRequirements: {}, keywords: [], missingInRepository: false },
        })),
      ),
    );
    view();

    const editor = await screen.findByTestId('gherkin-editor');
    await userEvent.type(editor, '{enter}  @REQ-99');
    await userEvent.click(screen.getByTestId('test-save'));

    expect(await screen.findByText('Tag @REQ-99 : exigence inconnue dans le projet SHOP.')).toBeInTheDocument();
  });

  it('§6.1 jeux de données d’un test automatisé : valeurs typées, configuration technique séparée', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', {
      kind: 'AUTOMATED', steps: [], parameters: [{ name: 'montant', detected: false }],
      automation: { technique: 'DATA_DRIVEN', framework: 'JUnit 5', configuration: {}, executionTags: [], environmentRequirements: {}, keywords: [], missingInRepository: false },
    }));
    const sent = capturePatch();
    view();

    await userEvent.click(await screen.findByTestId('dataset-add'));
    expect(screen.getByText('Configuration technique (JSON)')).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('dataset-0-add-row'));
    await userEvent.type(screen.getByTestId('dataset-0-cell-0-montant'), '49.99');
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body?.dataSets).toEqual([{ name: 'Jeu 1', rows: [{ montant: 49.99 }], rowNames: [''] }]));
  });

  it('ADR-0030 choisit le projet d’un dépôt Git déclaré : le PATCH envoie le projet, pas l’adresse', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    server.use(http.get('/api/v1/git-sources', () => HttpResponse.json([{
      id: 's1', name: 'kerware', baseUrl: 'https://github.com/kerware', authType: 'NONE', hasSecret: false, projects: [{
        id: 'p1', sourceId: 's1', name: 'saucedemo-e2e', label: 'kerware / saucedemo-e2e', defaultBranch: 'master',
        cloneUrl: 'https://github.com/kerware/saucedemo-e2e', webUrl: 'https://github.com/kerware/saucedemo-e2e', version: 0,
      }],
    }])));
    serve(testDetail('TC-1', {
      kind: 'AUTOMATED', steps: [],
      automation: { technique: 'UI', framework: 'Playwright', repositoryUrl: 'https://git.example.com/ancien.git', configuration: {}, executionTags: [],
        environmentRequirements: {}, keywords: [], missingInRepository: false },
    }));
    const sent = capturePatch();
    view();

    expect(await screen.findByTestId('automation-repository-url')).toHaveValue('https://git.example.com/ancien.git');
    await userEvent.click(screen.getByTestId('automation-git-project'));
    await userEvent.click(await screen.findByRole('option', { name: 'kerware / saucedemo-e2e' }));
    expect(screen.getByTestId('automation-clone-url')).toHaveTextContent('https://github.com/kerware/saucedemo-e2e');
    expect(screen.getByTestId('automation-branch')).toHaveAttribute('placeholder', 'master');
    await userEvent.click(screen.getByTestId('test-save'));

    await waitFor(() => expect(sent.body?.gitProjectId).toBe('p1'));
    expect(sent.body).not.toHaveProperty('repositoryUrl');
  });

  it('F-AUT-08 signale un test absent du dépôt', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1', {
      kind: 'AUTOMATED', steps: [],
      automation: { technique: 'UNIT', framework: 'JUnit 5', testIdentifier: 'CartTest#total', configuration: {}, executionTags: [], environmentRequirements: {}, keywords: [], missingInRepository: true },
    }));
    view();

    expect(await screen.findByTestId('missing-in-repository')).toBeInTheDocument();
  });
});

describe('F-TRA-01 exigences liées', () => {
  it('ajoute une exigence et enregistre les liens', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    serve(testDetail('TC-1'));
    let body: unknown;
    server.use(
      http.put(`${URL}/requirements`, async ({ request }) => {
        body = await request.json();
        return HttpResponse.json([]);
      }),
    );
    view();

    await userEvent.click(await screen.findByRole('tab', { name: /Exigences liées/ }));
    expect(screen.getByText(/ce test est orphelin/)).toBeInTheDocument();
    await userEvent.click(screen.getByTestId('link-add'));
    await userEvent.click(screen.getByTestId('link-requirement-0'));
    await userEvent.click(await screen.findByRole('option', { name: /REQ-2/ }));
    await userEvent.click(screen.getByTestId('links-save'));

    await waitFor(() => expect(body).toEqual([{ requirementKey: 'REQ-2', linkType: 'VERIFIES', criterionPositions: [] }]));
  });

  it('lecture seule pour un rôle sans droit d’écriture', async () => {
    useAuthStore.getState().setSession('jwt', { ...TESTER, projects: [{ key: 'SHOP', name: 'Boutique', role: 'VIEWER' }] });
    serve(testDetail('TC-1'));
    view();

    expect(await screen.findByTestId('test-read-only')).toBeInTheDocument();
    expect(screen.queryByTestId('test-save')).not.toBeInTheDocument();
    expect(within(screen.getByTestId('test-detail')).queryByTestId('step-add')).not.toBeInTheDocument();
  });
});
