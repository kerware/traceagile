/** Règles d'affichage du tableau de bord (§9.1). */

/** « 2026-10-14 » → « 14/10 ». */
export function shortDate(iso: string | undefined): string {
  if (!iso) return '';
  const [, month, day] = iso.split('-');
  return `${day}/${month}`;
}

/** Pourcentage arrondi à l'unité, « — » sans valeur. */
export function percentLabel(value: number | null | undefined): string {
  return typeof value === 'number' ? `${Math.round(value)} %` : '—';
}
