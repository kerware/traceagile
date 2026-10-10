import type { ArtifactKind, ReportFormat, RunCountsLike, RunStatus, ServerStatus } from './types';
import { useAuthStore } from '../auth/authStore';

/** Règles d'affichage de l'exécution automatisée (§8.5, §10). */

export const RUN_STATUS_COLORS: Record<RunStatus, string> = {
  QUEUED: 'gray',
  DISPATCHED: 'blue',
  RUNNING: 'cyan',
  COMPLETED: 'green',
  FAILED: 'red',
  CANCELLED: 'orange',
  TIMEOUT: 'grape',
};

export const SERVER_STATUS_COLORS: Record<ServerStatus, string> = {
  UNPAIRED: 'gray',
  UNKNOWN: 'gray',
  ONLINE: 'green',
  OFFLINE: 'red',
  UNAUTHORIZED: 'orange',
};

export const REPORT_FORMATS: ReportFormat[] = ['JUNIT', 'JEST', 'CUCUMBER', 'ROBOT', 'PLAYWRIGHT'];

/** F-EXE-10 format déduit de l'extension et du nom du fichier (modifiable). */
export function guessFormat(fileName: string): ReportFormat {
  const name = fileName.toLowerCase();
  if (name.endsWith('.xml')) return name.includes('output') || name.includes('robot') ? 'ROBOT' : 'JUNIT';
  if (name.includes('jest')) return 'JEST';
  if (name.includes('playwright') || name.includes('results')) return 'PLAYWRIGHT';
  return 'CUCUMBER';
}

/** ADR-0021 ordre d'affichage des artefacts : copies d'écran, traces, résultats, rapport. */
export const ARTIFACT_ORDER: ArtifactKind[] = ['SCREENSHOT', 'SYSTEM_TRACE', 'JUNIT', 'JEST', 'REPORT', 'OTHER'];

/** Taille lisible d'un artefact. */
export function fileSize(bytes?: number | null): string {
  if (bytes == null) return '';
  if (bytes < 1024) return `${bytes} o`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} Ko`;
  return `${(bytes / 1024 / 1024).toFixed(1)} Mo`;
}

/** Run terminé ? */
export function isFinal(status: RunStatus): boolean {
  return status === 'COMPLETED' || status === 'FAILED' || status === 'CANCELLED' || status === 'TIMEOUT';
}

/** Part des tests terminés (barre de progression). */
export function progressPercent(counts: RunCountsLike): number {
  return counts.total === 0 ? 0 : Math.round(((counts.total - counts.pending - counts.running) / counts.total) * 100);
}

/** §2.2 « Lancer des runs automatisés » : développeur et administrateur. */
export function useCanLaunchRuns(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;
  if (user.systemAdmin) return true;
  const role = user.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'DEVELOPER';
}

/** F-EXE-10 importer des résultats : qui exécute ou lance des runs. */
export function useCanImportResults(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;
  if (user.systemAdmin) return true;
  const role = user.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'DEVELOPER' || role === 'TESTER';
}
