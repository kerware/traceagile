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

/** ADR-0013 nom de paramètre : lettres sans accent, chiffres, « _ », « - », « . ». */
export const PARAMETER_NAME = /^[A-Za-z0-9_.-]{1,60}$/;

export interface ParameterRow {
  name: string;
  defaultValue: string;
  description: string;
  /** Présent dans les pas ({@code ${nom}}). */
  detected: boolean;
  /** Déclaré mais absent des pas d'un test manuel. */
  unused: boolean;
}

/** Même règle que le back-end : d'abord les paramètres détectés dans les pas, puis les autres déclarés. */
export function mergeParameters(declared: { name: string; defaultValue: string; description: string }[], detected: string[], manual: boolean): ParameterRow[] {
  const byName = new Map(declared.map((p) => [p.name, p]));
  const rows: ParameterRow[] = detected.map((name) => ({
    name,
    defaultValue: byName.get(name)?.defaultValue ?? '',
    description: byName.get(name)?.description ?? '',
    detected: true,
    unused: false,
  }));
  declared
    .filter((p) => !detected.includes(p.name))
    .forEach((p) => rows.push({ ...p, detected: false, unused: manual }));
  return rows;
}

export interface FolderNode<T> {
  path: string;
  name: string;
  tests: T[];
  children: FolderNode<T>[];
  /** Nombre de tests du dossier et de ses sous-dossiers. */
  total: number;
}

/** §13.2 / ADR-0013 arbre des dossiers « a/b/c » (les ancêtres sans test direct sont créés). */
export function buildFolderTree<T>(groups: { name: string; tests: T[] }[]): { roots: FolderNode<T>[]; unclassified: T[] } {
  const byPath = new Map<string, FolderNode<T>>();
  const roots: FolderNode<T>[] = [];
  const node = (path: string): FolderNode<T> => {
    const existing = byPath.get(path);
    if (existing) return existing;
    const slash = path.lastIndexOf('/');
    const created: FolderNode<T> = { path, name: path.slice(slash + 1), tests: [], children: [], total: 0 };
    byPath.set(path, created);
    if (slash < 0) roots.push(created);
    else node(path.slice(0, slash)).children.push(created);
    return created;
  };
  let unclassified: T[] = [];
  groups.forEach((group) => {
    if (!group.name) unclassified = group.tests;
    else node(group.name).tests.push(...group.tests);
  });
  const finish = (nodes: FolderNode<T>[]): number => {
    nodes.sort((a, b) => a.name.localeCompare(b.name, undefined, { sensitivity: 'base' }));
    return nodes.reduce((sum, n) => {
      n.total = n.tests.length + finish(n.children);
      return sum + n.total;
    }, 0);
  };
  finish(roots);
  return { roots, unclassified };
}
