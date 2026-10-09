import type { PlanningStatus, ReleaseResponse, ScopeItem, SprintSummary } from '../../api/planning';

/** Règles d'affichage de la planification (§8.1, §8.2). */

export const PLANNING_STATUS_COLORS: Record<PlanningStatus, string> = { PLANNED: 'blue', ACTIVE: 'green', CLOSED: 'gray' };

/** Une story est terminée pour la clôture si elle est DONE ou ACCEPTED (et hors jeu si rejetée / obsolète). */
export function needsDecision(item: ScopeItem): boolean {
  return !['DONE', 'ACCEPTED', 'REJECTED', 'OBSOLETE'].includes(item.status);
}

/** F-PLN-05 couleur de la jauge charge / capacité : alerte au-delà de 100 %. */
export function loadColor(percent?: number | null): string {
  if (percent === undefined || percent === null) return 'gray';
  if (percent > 100) return 'red';
  if (percent >= 85) return 'orange';
  return 'teal';
}

const DAY = 86_400_000;

function days(date: string): number {
  return Date.parse(`${date}T00:00:00Z`) / DAY;
}

/** F-PLN-02 position d'une période sur la frise d'une release, en % de sa durée. */
export function span(start: string, end: string, from: string, to: string): { left: number; width: number } {
  const total = days(to) - days(from) + 1;
  const left = ((days(start) - days(from)) / total) * 100;
  const width = ((days(end) - days(start) + 1) / total) * 100;
  return { left: Math.max(0, left), width: Math.min(100 - Math.max(0, left), width) };
}

/** Sprint par défaut de l'écran de planification : l'actif, sinon le premier planifié, sinon le dernier. */
export function defaultSprint(sprints: SprintSummary[]): string | null {
  return (sprints.find((s) => s.status === 'ACTIVE') ?? sprints.find((s) => s.status === 'PLANNED') ?? sprints.at(-1))?.key ?? null;
}

/** Sprints hors release (feuille de route). */
export function looseSprints(sprints: SprintSummary[], releases: ReleaseResponse[]): SprintSummary[] {
  const attached = new Set(releases.flatMap((r) => r.sprints.map((s) => s.key)));
  return sprints.filter((s) => !attached.has(s.key));
}

/** Format court d'une date ISO (jj/mm). */
export function shortDate(date: string, locale = 'fr'): string {
  return new Intl.DateTimeFormat(locale, { day: '2-digit', month: '2-digit', timeZone: 'UTC' }).format(new Date(`${date}T00:00:00Z`));
}
