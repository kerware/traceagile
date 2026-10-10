export type { ReportFormat, RunStatus, ServerStatus } from '../../api/automation';

/** Comptes d'un run (pour les calculs d'affichage). */
export interface RunCountsLike {
  total: number;
  pending: number;
  running: number;
  passed: number;
  failed: number;
  error: number;
  skipped: number;
}
