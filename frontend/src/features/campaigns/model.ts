import type { CampaignStatus, DefectSeverity, DefectStatus, ExecutionStatus, StepResult, Strategy } from '../../api/campaigns';

/** Règles d'affichage des campagnes, exécutions et anomalies (§8.3, §8.4, §8.6). */

export const CAMPAIGN_STATUS_COLORS: Record<CampaignStatus, string> = { PLANNED: 'blue', IN_PROGRESS: 'green', COMPLETED: 'gray', ABORTED: 'red' };

export const EXECUTION_COLORS: Record<ExecutionStatus, string> = {
  NOT_RUN: 'gray',
  RUNNING: 'blue',
  PASSED: 'green',
  FAILED: 'red',
  BLOCKED: 'orange',
  SKIPPED: 'gray',
  ERROR: 'grape',
};

/** Statuts qu'un pas peut recevoir, dans l'ordre des boutons (F-EXE-01). */
export const STEP_STATUSES: ExecutionStatus[] = ['PASSED', 'FAILED', 'BLOCKED', 'SKIPPED'];

/** Statuts qu'on peut forcer (F-EXE-02). */
export const FINAL_STATUSES: ExecutionStatus[] = ['PASSED', 'FAILED', 'BLOCKED', 'SKIPPED', 'ERROR'];

export const STRATEGIES: Strategy[] = ['SPRINT_REQUIREMENTS', 'TAG', 'IMPACT', 'MANUAL', 'FAILED_IN_CAMPAIGN'];

export const SEVERITIES: DefectSeverity[] = ['BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'TRIVIAL'];
export const SEVERITY_COLORS: Record<DefectSeverity, string> = { BLOCKER: 'red', CRITICAL: 'orange', MAJOR: 'yellow', MINOR: 'blue', TRIVIAL: 'gray' };
export const DEFECT_STATUSES: DefectStatus[] = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED'];
export const DEFECT_STATUS_COLORS: Record<DefectStatus, string> = { OPEN: 'red', IN_PROGRESS: 'orange', RESOLVED: 'teal', CLOSED: 'gray', REJECTED: 'dark' };

/** F-EXE-01 pas à afficher : le premier pas non joué, sinon le dernier. */
export function currentStepIndex(steps: StepResult[]): number {
  const index = steps.findIndex((s) => s.status === 'NOT_RUN');
  return index >= 0 ? index : Math.max(0, steps.length - 1);
}

/** Durée lisible (min / s). */
export function duration(ms?: number | null): string {
  if (ms === undefined || ms === null) return '—';
  const seconds = Math.round(ms / 1000);
  if (seconds < 60) return `${seconds} s`;
  const minutes = Math.floor(seconds / 60);
  return minutes < 60 ? `${minutes} min ${seconds % 60} s` : `${Math.floor(minutes / 60)} h ${minutes % 60} min`;
}

/** F-CMP-05 charge lisible en heures et minutes. */
export function minutes(total: number): string {
  if (total < 60) return `${total} min`;
  return `${Math.floor(total / 60)} h${total % 60 ? ` ${String(total % 60).padStart(2, '0')}` : ''}`;
}
