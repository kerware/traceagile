import type { TestCaseStatus, TestKind, TestTechnique } from '../../api/testcases';

/** Règles d'affichage du référentiel de tests (§3.1, §6). */

export const TEST_KINDS: TestKind[] = ['MANUAL', 'EXPLORATORY', 'AUTOMATED'];
export const TEST_STATUSES: TestCaseStatus[] = ['DRAFT', 'READY', 'NEEDS_UPDATE', 'OBSOLETE'];
export const TECHNIQUES: TestTechnique[] = ['BDD', 'UNIT', 'UI', 'API', 'KEYWORD', 'DATA_DRIVEN', 'PERFORMANCE', 'CONTRACT'];
export const TIMEBOXES = [60, 90, 120];
/** F-EXP-02 heuristiques suggérées (extensibles par projet au lot 6). */
export const HEURISTICS = ['SFDIPOT', 'FEW HICCUPPS', 'CRUD', 'Goldilocks', 'Tours de Whittaker'];

export const KIND_COLORS: Record<TestKind, string> = { MANUAL: 'blue', EXPLORATORY: 'grape', AUTOMATED: 'teal' };
export const TEST_STATUS_COLORS: Record<TestCaseStatus, string> = {
  DRAFT: 'gray',
  READY: 'green',
  NEEDS_UPDATE: 'orange',
  OBSOLETE: 'dark',
};

/** F-EXP-01 même règle que le back-end. */
export function charterSentence(explore?: string | null, withWhat?: string | null, toDiscover?: string | null): string {
  const e = explore?.trim();
  const w = withWhat?.trim();
  const d = toDiscover?.trim();
  if (!e && !w && !d) return '';
  let sentence = `Explorer ${e || '…'}`;
  if (w) sentence += ` avec ${w}`;
  return `${sentence} pour découvrir ${d || '…'}.`;
}

const VARIABLE = /\$\{([\w.-]+)}/g;

/** F-MAN-01 variables ${nom} utilisées dans les pas. */
export function stepVariables(steps: { action?: string | null; expectedResult?: string | null; testData?: string | null }[]): string[] {
  const names = new Set<string>();
  steps.forEach((step) =>
    [step.action, step.expectedResult, step.testData].forEach((text) => {
      for (const match of (text ?? '').matchAll(VARIABLE)) names.add(match[1]!);
    }),
  );
  return [...names];
}

/** Valeur saisie dans une cellule de jeu de données automatisé : nombre, booléen ou texte. */
export function parseCell(value: string): string | number | boolean {
  const trimmed = value.trim();
  if (trimmed === '') return '';
  if (trimmed === 'true' || trimmed === 'false') return trimmed === 'true';
  if (/^-?\d+(\.\d+)?$/.test(trimmed)) return Number(trimmed);
  return value;
}
