import type { TestCaseDetail, TestCasePatch } from '../../api/testcases';

/**
 * Brouillon de l'onglet Définition : l'éditeur modifie une copie du test, puis seuls les champs
 * changés partent dans le merge-patch (une chaîne vide efface la valeur).
 */
export interface StepDraft {
  action: string;
  expectedResult: string;
  testData: string;
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
  manualDataSet: Record<string, string>[];
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
  dataSet: Record<string, unknown>[];
  parameters: Record<string, unknown>;
  executionTags: string[];
  environmentRequirements: Record<string, string>;
}

const COMMON: (keyof TestDraft)[] = ['title', 'objective', 'description', 'priority', 'tags', 'estimatedDurationMin', 'folder'];
const BY_KIND: Record<TestCaseDetail['kind'], (keyof TestDraft)[]> = {
  MANUAL: ['automationCandidate', 'automationJustification', 'steps', 'manualDataSet'],
  EXPLORATORY: ['explore', 'with', 'toDiscover', 'areas', 'heuristics', 'timeboxMin', 'setupNotes', 'targetedRisk'],
  AUTOMATED: ['technique', 'framework', 'language', 'repositoryUrl', 'branch', 'path', 'testIdentifier', 'gherkinSource', 'dataSet',
    'parameters', 'executionTags', 'environmentRequirements'],
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
    steps: test.steps.map((s) => ({ action: s.action, expectedResult: s.expectedResult ?? '', testData: s.testData ?? '' })),
    manualDataSet: test.manualDataSet,
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
    dataSet: a?.dataSet ?? [],
    parameters: a?.parameters ?? {},
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
      patch.steps = draft.steps.map((s) => ({ action: s.action, expectedResult: s.expectedResult.trim() || null, testData: s.testData.trim() || null }));
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
