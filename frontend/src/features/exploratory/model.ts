import type { NoteType, SessionState } from '../../api/exploratory';
import { useAuthStore } from '../auth/authStore';

/** Règles d'affichage des sessions exploratoires (§5.2 à §5.4). */

/** F-EXP-06 types de note, dans l'ordre des raccourcis Ctrl+1 à Ctrl+5. */
export const NOTE_TYPES: NoteType[] = ['NOTE', 'QUESTION', 'ISSUE', 'BUG', 'IDEA'];

export const NOTE_COLORS: Record<NoteType, string> = { NOTE: 'gray', QUESTION: 'blue', ISSUE: 'orange', BUG: 'red', IDEA: 'teal' };

export const SESSION_STATE_COLORS: Record<SessionState, string> = { RUNNING: 'green', PAUSED: 'yellow', FINISHED: 'blue', DEBRIEFED: 'gray' };

/** F-EXP-10 sauvegarde automatique du brouillon. */
export const AUTOSAVE_MS = 10_000;

/** « 12:05 », « 1:02:03 ». */
export function clock(totalSeconds: number): string {
  const s = Math.max(0, Math.floor(totalSeconds));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  const mm = String(m).padStart(2, '0');
  const ss = String(sec).padStart(2, '0');
  return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`;
}

/** F-EXP-06 Ctrl+1 à Ctrl+5 → type de note (null sinon). */
export function noteTypeForShortcut(event: { ctrlKey: boolean; metaKey: boolean; key: string }): NoteType | null {
  if (!event.ctrlKey && !event.metaKey) return null;
  const index = Number(event.key) - 1;
  return Number.isInteger(index) && index >= 0 && index < NOTE_TYPES.length ? NOTE_TYPES[index]! : null;
}

/** F-EXP-09 la répartition TBS totalise 100. */
export function tbsTotal(tbs: { testPct: number; bugPct: number; setupPct: number }): number {
  return tbs.testPct + tbs.bugPct + tbs.setupPct;
}

/** F-EXP-13 approbation du débriefing : PO, testeur (responsable des tests) ou administrateur — jamais le testeur de la session. */
export function useCanApproveDebrief(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;
  if (user.systemAdmin) return true;
  const role = user.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'PRODUCT_OWNER' || role === 'TESTER';
}
