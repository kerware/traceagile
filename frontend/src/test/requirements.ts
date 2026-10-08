import type { RequirementDetail, RequirementSummary, RequirementTreeNode } from '../api/requirements';

/** Données d'exemple des tests front des exigences. */

export function summary(key: string, overrides: Partial<RequirementSummary> = {}): RequirementSummary {
  return {
    key,
    type: 'USER_STORY',
    title: `Titre ${key}`,
    status: 'DRAFT',
    priority: 'SHOULD',
    riskLevel: 'MEDIUM',
    storyPoints: 3,
    tags: [],
    parentKey: 'REQ-2',
    rank: key,
    criteriaCount: 1,
    needsSplitting: false,
    version: 0,
    ...overrides,
  };
}

export function node(key: string, overrides: Partial<RequirementTreeNode> = {}): RequirementTreeNode {
  return {
    key,
    type: 'EPIC',
    title: `Titre ${key}`,
    status: 'DRAFT',
    priority: 'SHOULD',
    riskLevel: 'MEDIUM',
    rank: key,
    criteriaCount: 0,
    needsSplitting: false,
    children: [],
    ...overrides,
  };
}

export function detail(key: string, overrides: Partial<RequirementDetail> = {}): RequirementDetail {
  return {
    id: `00000000-0000-0000-0000-${key.replace(/\D/g, '').padStart(12, '0')}`,
    key,
    type: 'USER_STORY',
    title: 'Livraison gratuite',
    description: undefined,
    userStory: { asA: 'client', iWant: 'la livraison offerte', soThat: 'commander plus', sentence: 'En tant que client, je veux la livraison offerte afin de commander plus.' },
    priority: 'SHOULD',
    storyPoints: 5,
    needsSplitting: false,
    status: 'DRAFT',
    allowedTransitions: ['TO_REFINE', 'READY', 'REJECTED', 'OBSOLETE'],
    riskLevel: 'MEDIUM',
    planguage: {},
    transverse: false,
    tags: ['panier'],
    currentVersion: 0,
    parent: { key: 'REQ-2', type: 'FEATURE', title: 'Livraison', status: 'DRAFT' },
    children: [],
    invest: { independent: false, negotiable: false, valuable: false, estimable: false, small: false, testable: false },
    criteria: [],
    applicableTransverseNfrs: [],
    version: 2,
    createdAt: '2026-10-08T10:00:00Z',
    createdBy: 'po',
    updatedAt: '2026-10-08T10:00:00Z',
    updatedBy: 'po',
    ...overrides,
  };
}
