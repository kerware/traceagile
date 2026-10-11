/**
 * Client de l'API d'administration (ADR-0026). Les identifiants de l'administrateur sont gardés pour
 * l'onglet (sessionStorage) et envoyés en HTTP Basic ; un 401 renvoie à la connexion.
 */
const KEY = 'execution-server.auth';

export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string | undefined,
    message: string,
  ) {
    super(message);
  }
}

export function credentials(): string | null {
  try {
    return sessionStorage.getItem(KEY);
  } catch {
    return null;
  }
}

/** user:mot de passe en Base64 (UTF-8). */
export function basic(user: string, password: string): string {
  return btoa(String.fromCharCode(...new TextEncoder().encode(`${user}:${password}`)));
}

export function saveCredentials(user: string, password: string) {
  const token = basic(user, password);
  try {
    sessionStorage.setItem(KEY, token);
  } catch {
    // stockage indisponible : la session ne survivra pas au rechargement
  }
  memory = token;
}

export function clearCredentials() {
  memory = null;
  try {
    sessionStorage.removeItem(KEY);
  } catch {
    // rien à effacer
  }
}

let memory: string | null = null;
let onUnauthorized: () => void = () => undefined;

export function setUnauthorizedHandler(handler: () => void) {
  onUnauthorized = handler;
}

function authorization(): Record<string, string> {
  const token = memory ?? credentials();
  return token ? { Authorization: `Basic ${token}` } : {};
}

async function request(path: string, init: RequestInit = {}): Promise<Response> {
  const response = await fetch(path, { ...init, headers: { ...authorization(), ...(init.headers ?? {}) } });
  if (response.status === 401) {
    onUnauthorized();
    throw new ApiError(401, 'ADMIN_REQUIRED', 'Identifiants refusés.');
  }
  if (!response.ok) {
    let code: string | undefined;
    let message = `Erreur ${response.status}`;
    try {
      const body = await response.json();
      code = body.code;
      message = body.message ?? message;
    } catch {
      // corps non JSON
    }
    throw new ApiError(response.status, code, message);
  }
  return response;
}

export async function getJson<T>(path: string): Promise<T> {
  return (await request(path)).json() as Promise<T>;
}

export async function getText(path: string): Promise<string> {
  return (await request(path)).text();
}

export async function send<T>(method: string, path: string, body?: unknown): Promise<T | null> {
  const response = await request(path, {
    method,
    headers: body === undefined ? {} : { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  return text ? (JSON.parse(text) as T) : null;
}

/** Contenu binaire (artefact) pour l'afficher ou le télécharger sans exposer les identifiants dans une URL. */
export async function blob(path: string): Promise<Blob> {
  return (await request(path)).blob();
}

export async function login(user: string, password: string): Promise<void> {
  const token = basic(user, password);
  const response = await fetch('/api/admin/me', { headers: { Authorization: `Basic ${token}` } });
  if (!response.ok) {
    throw new ApiError(response.status, 'ADMIN_REQUIRED', 'Identifiant ou mot de passe incorrect.');
  }
  saveCredentials(user, password);
}

// ----------------------------------------------------------------------------------------------- types

export type JobStatus = 'ACCEPTED' | 'RUNNING' | 'COMPLETED' | 'CANCELLED' | 'INTERRUPTED';
export type TestStatus = 'PENDING' | 'RUNNING' | 'PASSED' | 'FAILED' | 'ERROR' | 'SKIPPED';

export interface Job {
  id: string;
  tokenId: string;
  tokenLabel: string;
  runId: string;
  project: string | null;
  campaign: string | null;
  environment: string | null;
  buildVersion: string | null;
  repositoryUrl: string | null;
  branch: string | null;
  status: JobStatus;
  agent: string | null;
  timeoutMinutes: number;
  parallelism: number;
  retryFailed: number;
  submittedAt: string;
  startedAt: string | null;
  endedAt: string | null;
  total: number;
  passed: number;
  failed: number;
  errored: number;
  skipped: number;
  errorMessage: string | null;
}

export interface TestRow {
  id: number;
  position: number;
  spec: {
    executionId: string;
    testKey: string;
    technique: string | null;
    framework: string | null;
    path: string | null;
    testIdentifier: string | null;
    parameters: Record<string, unknown>;
    dataSet: Record<string, unknown>;
  };
  status: TestStatus;
  attempts: number;
  durationMs: number | null;
  message: string | null;
  startedAt: string | null;
  endedAt: string | null;
  metrics: Record<string, number>;
}

export interface Artifact {
  jobId: string;
  name: string;
  contentType: string;
  kind: string;
  executionId: string | null;
  size: number;
}

export interface JobDetail {
  job: Job;
  tests: TestRow[];
  artifacts: Artifact[];
}

export type ToolStatus = 'INSTALLED' | 'MISSING' | 'INSTALLING' | 'QUEUED' | 'FAILED';

export interface ToolState {
  tool: {
    id: string;
    name: string;
    category: string;
    description: string;
    prerequisite: boolean;
    dependencies: string[];
    frameworks: string[];
    help: string;
    docs: string;
  };
  status: ToolStatus;
  version: string | null;
  message: string | null;
  installable: boolean;
  checkedAt: string | null;
  installStartedAt: string | null;
  installEndedAt: string | null;
  missingDependencies: string[];
  script: string | null;
}

export interface PlanStep {
  toolId: string;
  name: string;
  status: ToolStatus;
  action: 'INSTALL' | 'NONE' | 'MANUAL';
  help: string;
}

export interface Dashboard {
  live: { runningJobs: number; busyAgents: number; agents: number; pendingTests: number };
  week: { jobs: number; tests: number; passed: number; failed: number; errors: number; passRate: number | null; averageJobMs: number | null };
  days: { day: string; jobs: number; passed: number; failed: number; errors: number }[];
  frameworks: { framework: string; tests: number; passed: number; passRate: number | null; averageMs: number | null }[];
  failing: { testKey: string; identifier: string | null; project: string | null; failures: number; lastFailure: string | null }[];
  toolsInstalled: number;
  toolsTotal: number;
  platform: string;
}

export interface TokenInfo {
  tokenId: string;
  label: string;
  hint: string;
  createdAt: string;
  lastUsedAt: string | null;
  revokedAt: string | null;
}

export interface IssuedToken {
  tokenId: string;
  token: string;
  webhookSecret: string;
  label: string;
  createdAt: string;
}

export interface Settings {
  serverName: string;
  version: string;
  platform: string;
  architecture: string;
  javaVersion: string;
  agents: number;
  retentionDays: number;
  dataDir: string;
  toolsDir: string;
  adminUser: string;
}

export interface GitCredential {
  host: string;
  username: string;
  updatedAt: string;
}

// ------------------------------------------------------------------------------------------- formats

export function duration(ms: number | null | undefined): string {
  if (ms === null || ms === undefined) return '—';
  if (ms < 1000) return `${ms} ms`;
  const seconds = Math.round(ms / 100) / 10;
  if (seconds < 60) return `${seconds.toLocaleString('fr-FR')} s`;
  const minutes = Math.floor(seconds / 60);
  return `${minutes} min ${Math.round(seconds % 60)} s`;
}

export function dateTime(value: string | null | undefined): string {
  return value ? new Date(value).toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'medium' }) : '—';
}

export function size(bytes: number): string {
  if (bytes < 1024) return `${bytes} o`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toLocaleString('fr-FR', { maximumFractionDigits: 1 })} Ko`;
  return `${(bytes / 1024 / 1024).toLocaleString('fr-FR', { maximumFractionDigits: 1 })} Mo`;
}

/** Durée d'un job : de son démarrage à sa fin (ou à maintenant s'il tourne). */
export function jobDuration(job: Pick<Job, 'startedAt' | 'endedAt'>, now = Date.now()): number | null {
  if (!job.startedAt) return null;
  return (job.endedAt ? Date.parse(job.endedAt) : now) - Date.parse(job.startedAt);
}
