import type { TestCaseDetail, TestCasePatch } from '../../api/testcases';

/**
 * Brouillon de l'onglet Définition : l'éditeur modifie une copie du test, puis seuls les champs
 * changés partent dans le merge-patch (une chaîne vide efface la valeur).
 */
export interface StepDraft {
  action: string;
  expectedResult: string;
  testData: string;
  /** ADR-0018 pas d'appel d'un autre cas de test. */
  calledTestKey?: string;
  calledTestTitle?: string;
  callParameters?: Record<string, string>;
  /** ADR-0029 jeu de données nommé de l'appelé (nom du jeu, nom de la ligne). */
  callDataSet?: string;
  callRow?: string;
}

export interface ParameterDraft {
  name: string;
  defaultValue: string;
  description: string;
}

export interface DataSetDraft {
  name: string;
  rows: Record<string, unknown>[];
  /** ADR-0029 nom de chaque ligne (vide : le serveur prend la première valeur de la ligne). */
  rowNames: string[];
}

export interface TestDraft {
  title: string;
  objective: string;
  description: string;
  priority: TestCaseDetail['priority'];
  tags: string[];
  estimatedDurationMin: number | '';
  folder: string;
  automationCandidate: boolean;
  automationJustification: string;
  steps: StepDraft[];
  /** ADR-0013 paramètres déclarés (les ${nom} des pas s'y ajoutent à l'affichage). */
  parameters: ParameterDraft[];
  dataSets: DataSetDraft[];
  explore: string;
  with: string;
  toDiscover: string;
  areas: string[];
  heuristics: string[];
  timeboxMin: number;
  setupNotes: string;
  targetedRisk: string;
  technique: string;
  framework: string;
  language: string;
  repositoryUrl: string;
  branch: string;
  path: string;
  testIdentifier: string;
  gherkinSource: string;
  configuration: Record<string, unknown>;
  executionTags: string[];
  environmentRequirements: Record<string, string>;
}

const COMMON: (keyof TestDraft)[] = ['title', 'objective', 'description', 'priority', 'tags', 'estimatedDurationMin', 'folder', 'parameters', 'dataSets'];
const BY_KIND: Record<TestCaseDetail['kind'], (keyof TestDraft)[]> = {
  MANUAL: ['automationCandidate', 'automationJustification', 'steps'],
  EXPLORATORY: ['explore', 'with', 'toDiscover', 'areas', 'heuristics', 'timeboxMin', 'setupNotes', 'targetedRisk'],
  AUTOMATED: ['technique', 'framework', 'language', 'repositoryUrl', 'branch', 'path', 'testIdentifier', 'gherkinSource',
    'configuration', 'executionTags', 'environmentRequirements'],
};

export function toDraft(test: TestCaseDetail): TestDraft {
  const c = test.charter;
  const a = test.automation;
  return {
    title: test.title,
    objective: test.objective ?? '',
    description: test.description ?? '',
    priority: test.priority,
    tags: test.tags,
    estimatedDurationMin: test.estimatedDurationMin ?? '',
    folder: test.folder ?? '',
    automationCandidate: test.automationCandidate,
    automationJustification: test.automationJustification ?? '',
    steps: test.steps.map((s) =>
      s.calledTest
        ? { action: s.action ?? '', expectedResult: s.expectedResult ?? '', testData: s.testData ?? '', calledTestKey: s.calledTest.key, calledTestTitle: s.calledTest.title, callParameters: { ...s.callParameters },
            callDataSet: s.callDataSet ?? '', callRow: s.callRow ?? '' }
        : { action: s.action ?? '', expectedResult: s.expectedResult ?? '', testData: s.testData ?? '' },
    ),
    // Un paramètre seulement détecté, sans détail, n'est pas « déclaré » : il disparaît avec son ${nom}.
    parameters: test.parameters
      .filter((p) => !p.detected || p.defaultValue || p.description)
      .map((p) => ({ name: p.name, defaultValue: p.defaultValue ?? '', description: p.description ?? '' })),
    dataSets: test.dataSets.map((d) => ({ name: d.name, rows: d.rows, rowNames: [...d.rowNames] })),
    explore: c?.explore ?? '',
    with: c?.with ?? '',
    toDiscover: c?.toDiscover ?? '',
    areas: c?.areas ?? [],
    heuristics: c?.heuristics ?? [],
    timeboxMin: c?.timeboxMin ?? 90,
    setupNotes: c?.setupNotes ?? '',
    targetedRisk: c?.targetedRisk ?? '',
    technique: a?.technique ?? '',
    framework: a?.framework ?? '',
    language: a?.language ?? '',
    repositoryUrl: a?.repositoryUrl ?? '',
    branch: a?.branch ?? '',
    path: a?.path ?? '',
    testIdentifier: a?.testIdentifier ?? '',
    gherkinSource: a?.gherkinSource ?? '',
    configuration: a?.configuration ?? {},
    executionTags: a?.executionTags ?? [],
    environmentRequirements: a?.environmentRequirements ?? {},
  };
}

/** Champs modifiés, au format merge-patch. */
export function toPatch(kind: TestCaseDetail['kind'], initial: TestDraft, draft: TestDraft): TestCasePatch {
  const patch: Record<string, unknown> = {};
  [...COMMON, ...BY_KIND[kind]].forEach((field) => {
    if (JSON.stringify(initial[field]) === JSON.stringify(draft[field])) return;
    const value = draft[field];
    if (field === 'steps') {
      patch.steps = draft.steps.map((s) =>
        s.calledTestKey !== undefined
          ? {
              action: s.action.trim() || null,
              expectedResult: s.expectedResult.trim() || null,
              testData: null,
              calledTestKey: s.calledTestKey || null,
              callParameters: Object.fromEntries(Object.entries(s.callParameters ?? {}).filter(([, v]) => v.trim() !== '')),
              callDataSet: s.callDataSet || null,
              callRow: s.callRow || null,
            }
          : { action: s.action, expectedResult: s.expectedResult.trim() || null, testData: s.testData.trim() || null },
      );
    } else if (field === 'parameters') {
      patch.parameters = draft.parameters.map((p) => ({ name: p.name, defaultValue: p.defaultValue || null, description: p.description.trim() || null }));
    } else if (field === 'estimatedDurationMin') {
      patch.estimatedDurationMin = value === '' ? null : value;
    } else if (typeof value === 'string') {
      patch[field] = value.trim() === '' ? null : value;
    } else {
      patch[field] = value;
    }
  });
  return patch as TestCasePatch;
}

export function isDirty(kind: TestCaseDetail['kind'], initial: TestDraft, draft: TestDraft): boolean {
  return Object.keys(toPatch(kind, initial, draft)).length > 0;
}
