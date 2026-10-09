import type { RequirementTreeNode } from '../../api/requirements';
import type { ExecutionStatus, LinkType, MatrixCell, VerificationStatus } from '../../api/traceability';

/** Règles d'affichage de la traçabilité (§7). */

/** §7.3 couleurs des pastilles de statut de vérification. */
export const VERIFICATION_COLORS: Record<VerificationStatus, string> = {
  NOT_COVERED: 'gray',
  NOT_RUN: 'blue',
  IN_PROGRESS: 'yellow',
  VALIDATED: 'green',
  FAILED: 'red',
  BLOCKED: 'orange',
  SUSPECT: 'violet',
};

export const VERIFICATION_STATUSES = Object.keys(VERIFICATION_COLORS) as VerificationStatus[];

export const LINK_TYPES: LinkType[] = ['VERIFIES', 'PARTIALLY_VERIFIES', 'RELATES_TO'];

/** F-TRA-04 abréviation du type de lien dans une cellule (même code que l'export F-TRA-08). */
export const LINK_CODES: Record<LinkType, string> = { VERIFIES: 'V', PARTIALLY_VERIFIES: 'PV', RELATES_TO: 'R' };

export const RESULT_COLORS: Record<ExecutionStatus, string> = {
  NOT_RUN: 'gray',
  RUNNING: 'blue',
  PASSED: 'green',
  FAILED: 'red',
  BLOCKED: 'orange',
  SKIPPED: 'gray',
  ERROR: 'grape',
};

/** Couleur d'une cellule : suspect > dernier résultat > type de lien. */
export function cellColor(cell: MatrixCell): string {
  if (cell.suspect) return 'violet';
  if (cell.lastResult) return RESULT_COLORS[cell.lastResult];
  return cell.linkType === 'RELATES_TO' ? 'gray' : 'teal';
}

/** §7.2 périmètres disponibles : le projet, puis chaque épic et feature (releases et sprints au lot 4). */
export function scopeOptions(tree: RequirementTreeNode[], projectLabel: string): { value: string; label: string }[] {
  const options = [{ value: 'project', label: projectLabel }];
  const walk = (nodes: RequirementTreeNode[], depth: number) =>
    nodes.forEach((node) => {
      if (node.type === 'EPIC' || node.type === 'FEATURE') {
        options.push({ value: `requirement:${node.key}`, label: `${'  '.repeat(depth)}${node.key} — ${node.title}` });
        walk(node.children, depth + 1);
      }
    });
  walk(tree, 0);
  return options;
}

/** Pourcentage lisible dans la langue de l'interface (« — » si le périmètre est vide). */
export function percent(value: number | null | undefined, locale = 'fr'): string {
  return value === undefined || value === null ? '—' : `${new Intl.NumberFormat(locale, { maximumFractionDigits: 1 }).format(value)} %`;
}
