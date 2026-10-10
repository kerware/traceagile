import type { ReportFormat, ReportScopeType, ReportSection, Verdict } from '../../api/reports';
import { useAuthStore } from '../auth/authStore';

/** Règles d'affichage des rapports (§9, ADR-0023). */

/** Toutes les sections, dans l'ordre proposé par défaut. */
export const SECTIONS: ReportSection[] = [
  'SUMMARY', 'DELIVERY', 'BURNDOWN', 'COVERAGE', 'EXECUTION', 'EXPLORATORY', 'DEFECTS', 'RISKS', 'SPRINT_TREND', 'REGRESSION', 'NFR',
  'REQUIREMENTS', 'DEFECT_LIST', 'TEST_RESULTS', 'RECOMMENDATION',
];

/** Sections réservées à certains périmètres (miroir de ReportSection côté serveur). */
const SCOPES: Partial<Record<ReportSection, ReportScopeType[]>> = {
  BURNDOWN: ['SPRINT', 'RELEASE'],
  SPRINT_TREND: ['RELEASE', 'PROJECT'],
  REGRESSION: ['RELEASE'],
};

export function appliesTo(section: ReportSection, scope: ReportScopeType): boolean {
  return SCOPES[section]?.includes(scope) ?? true;
}

export const FORMATS: ReportFormat[] = ['PDF', 'DOCX', 'XLSX', 'HTML', 'MARKDOWN', 'CSV', 'JSON'];
export const SCOPE_TYPES: ReportScopeType[] = ['SPRINT', 'RELEASE', 'PROJECT'];

export const VERDICT_COLORS: Record<Verdict, string> = { GO: 'green', GO_WITH_RESERVATIONS: 'orange', NO_GO: 'red' };

/**
 * Ordre d'édition des sections : les choisies dans leur ordre, puis les autres applicables. Déplacer
 * une section choisie la permute avec sa voisine choisie.
 */
export function move(selected: ReportSection[], section: ReportSection, delta: -1 | 1): ReportSection[] {
  const index = selected.indexOf(section);
  const target = index + delta;
  if (index < 0 || target < 0 || target >= selected.length) return selected;
  const next = [...selected];
  next[index] = selected[target] as ReportSection;
  next[target] = section;
  return next;
}

/** Bascule une section : ajoutée en fin, ou retirée. */
export function toggle(selected: ReportSection[], section: ReportSection): ReportSection[] {
  return selected.includes(section) ? selected.filter((s) => s !== section) : [...selected, section];
}

function useRole(project: string) {
  const user = useAuthStore((s) => s.user);
  return { admin: !!user?.systemAdmin, role: user?.projects.find((p) => p.key === project)?.role };
}

/** ADR-0023 définitions, génération, gel : administrateur, PO, testeur. */
export function useCanWriteReports(project: string): boolean {
  const { admin, role } = useRole(project);
  return admin || role === 'ADMINISTRATOR' || role === 'PRODUCT_OWNER' || role === 'TESTER';
}

/** §9.2 verdict « modifiable par le PO » (et l'administrateur). */
export function useCanOverrideVerdict(project: string): boolean {
  const { admin, role } = useRole(project);
  return admin || role === 'ADMINISTRATOR' || role === 'PRODUCT_OWNER';
}

/** §9.2 règles du verdict : administrateur du projet. */
export function useCanEditVerdictRules(project: string): boolean {
  const { admin, role } = useRole(project);
  return admin || role === 'ADMINISTRATOR';
}
