import type { TestCaseDetail, TestCaseSummary } from '../api/testcases';

/** Données d'exemple des tests front du référentiel de tests. */

export function testSummary(key: string, overrides: Partial<TestCaseSummary> = {}): TestCaseSummary {
  return {
    key,
    kind: 'MANUAL',
    title: `Test ${key}`,
    status: 'DRAFT',
    priority: 'SHOULD',
    tags: [],
    currentVersion: 1,
    automationCandidate: false,
    missingInRepository: false,
    ...overrides,
  };
}

export function testDetail(key: string, overrides: Partial<TestCaseDetail> = {}): TestCaseDetail {
  return {
    id: '00000000-0000-0000-0000-0000000000c1',
    key,
    kind: 'MANUAL',
    title: 'Ajouter au panier',
    priority: 'SHOULD',
    status: 'DRAFT',
    allowedTransitions: ['READY', 'OBSOLETE'],
    tags: [],
    currentVersion: 1,
    automationCandidate: false,
    steps: [{ id: 's1', position: 1, action: 'Ouvrir la fiche', expectedResult: 'La fiche s’affiche' }],
    parameters: [],
    dataSets: [],
    requirements: [],
    warnings: [],
    version: 3,
    createdAt: '2026-10-08T10:00:00Z',
    createdBy: 'qa1',
    updatedAt: '2026-10-08T10:00:00Z',
    updatedBy: 'qa1',
    ...overrides,
  };
}
