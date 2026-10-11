import type { JobStatus, TestStatus, ToolStatus } from '../api';

export const JOB_STATUS: Record<JobStatus, { label: string; color: string }> = {
  ACCEPTED: { label: 'En file', color: 'gray' },
  RUNNING: { label: 'En cours', color: 'blue' },
  COMPLETED: { label: 'Terminé', color: 'teal' },
  CANCELLED: { label: 'Annulé', color: 'orange' },
  INTERRUPTED: { label: 'Interrompu', color: 'red' },
};

export const TEST_STATUS: Record<TestStatus, { label: string; color: string }> = {
  PENDING: { label: 'En attente', color: 'gray' },
  RUNNING: { label: 'En cours', color: 'blue' },
  PASSED: { label: 'Réussi', color: 'teal' },
  FAILED: { label: 'Échoué', color: 'red' },
  ERROR: { label: 'Erreur', color: 'grape' },
  SKIPPED: { label: 'Ignoré', color: 'gray' },
};

export const TOOL_STATUS: Record<ToolStatus, { label: string; color: string }> = {
  INSTALLED: { label: 'Installé', color: 'teal' },
  MISSING: { label: 'Absent', color: 'gray' },
  QUEUED: { label: 'En file', color: 'blue' },
  INSTALLING: { label: 'Installation…', color: 'blue' },
  FAILED: { label: 'Échec', color: 'red' },
};
