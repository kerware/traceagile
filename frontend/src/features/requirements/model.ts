import type { Priority, RequirementStatus, RequirementTreeNode, RequirementType, RiskLevel } from '../../api/requirements';

/** Règles d'affichage des exigences, alignées sur le domaine back-end (§3, §4). */

export const REQUIREMENT_TYPES: RequirementType[] = [
  'EPIC', 'FEATURE', 'USER_STORY', 'BUSINESS_RULE', 'NON_FUNCTIONAL', 'TECHNICAL_ENABLER',
];
export const REQUIREMENT_STATUSES: RequirementStatus[] = [
  'DRAFT', 'TO_REFINE', 'READY', 'IN_SPRINT', 'DONE', 'ACCEPTED', 'REJECTED', 'OBSOLETE',
];
export const PRIORITIES: Priority[] = ['MUST', 'SHOULD', 'COULD', 'WONT'];
export const RISK_LEVELS: RiskLevel[] = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
export const NFR_CATEGORIES = [
  'PERFORMANCE', 'SECURITY', 'USABILITY', 'RELIABILITY', 'COMPATIBILITY', 'MAINTAINABILITY', 'PORTABILITY', 'ACCESSIBILITY',
] as const;

/** F-REQ-06 points d'estimation. */
export const FIBONACCI = [1, 2, 3, 5, 8, 13, 21];

/** F-REQ-07 alerte « Story à découper ». */
export function needsSplitting(points: number | null | undefined): boolean {
  return points != null && points >= 13;
}

/** F-REQ-05 phrase de la user story (même règle que le back-end). */
export function userStorySentence(asA?: string | null, iWant?: string | null, soThat?: string | null): string {
  const a = asA?.trim();
  const w = iWant?.trim();
  const s = soThat?.trim();
  if (!a && !w && !s) return '';
  let sentence = `En tant que ${a || '…'}, je veux ${w || '…'}`;
  if (s) sentence += ` afin de ${s}`;
  return `${sentence}.`;
}

/** §3.3-1 types de parent autorisés. */
export function allowedParentTypes(type: RequirementType): RequirementType[] {
  switch (type) {
    case 'EPIC':
      return [];
    case 'FEATURE':
      return ['EPIC'];
    case 'USER_STORY':
    case 'TECHNICAL_ENABLER':
      return ['FEATURE', 'EPIC'];
    default:
      return REQUIREMENT_TYPES;
  }
}

/** Liste à plat de l'arbre, dans l'ordre d'affichage. */
export function flatten(nodes: RequirementTreeNode[]): RequirementTreeNode[] {
  return nodes.flatMap((n) => [n, ...flatten(n.children)]);
}

/** Couleurs toujours accompagnées d'un libellé (§13.3). */
export const STATUS_COLORS: Record<RequirementStatus, string> = {
  DRAFT: 'gray',
  TO_REFINE: 'yellow',
  READY: 'blue',
  IN_SPRINT: 'indigo',
  DONE: 'teal',
  ACCEPTED: 'green',
  REJECTED: 'red',
  OBSOLETE: 'dark',
};

export const TYPE_COLORS: Record<RequirementType, string> = {
  EPIC: 'grape',
  FEATURE: 'violet',
  USER_STORY: 'blue',
  BUSINESS_RULE: 'orange',
  NON_FUNCTIONAL: 'cyan',
  TECHNICAL_ENABLER: 'gray',
};

export const PRIORITY_COLORS: Record<Priority, string> = { MUST: 'red', SHOULD: 'orange', COULD: 'blue', WONT: 'gray' };

export const RISK_COLORS: Record<RiskLevel, string> = { LOW: 'green', MEDIUM: 'yellow', HIGH: 'orange', CRITICAL: 'red' };
