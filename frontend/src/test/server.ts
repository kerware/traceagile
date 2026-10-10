import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import type { Schemas } from '../api/client';

export const ADMIN: Schemas['MeResponse'] = {
  id: '00000000-0000-0000-0000-000000000001',
  login: 'admin',
  email: 'admin@traceagile.demo',
  displayName: 'Administrateur',
  systemAdmin: true,
  projects: [{ key: 'SHOP', name: 'Boutique en ligne', role: 'ADMINISTRATOR' }],
};

export const TESTER: Schemas['MeResponse'] = {
  id: '00000000-0000-0000-0000-000000000002',
  login: 'qa1',
  email: 'qa1@traceagile.demo',
  displayName: 'Quentin Testeur',
  systemAdmin: false,
  projects: [{ key: 'SHOP', name: 'Boutique en ligne', role: 'TESTER' }],
};

export const SHOP: Schemas['ProjectResponse'] = {
  id: '00000000-0000-0000-0000-0000000000a1',
  key: 'SHOP',
  name: 'Boutique en ligne',
  description: 'Démo',
  archived: false,
  memberCount: 6,
  myRole: 'ADMINISTRATOR',
  version: 0,
  createdAt: '2026-10-08T10:00:00Z',
  createdBy: 'system',
};

export function problem(status: number, code: string, detail: string, errors?: Record<string, string>) {
  return HttpResponse.json({ status, code, detail, errors }, { status, headers: { 'Content-Type': 'application/problem+json' } });
}

export function page<T>(content: T[]) {
  return { content, page: 0, size: 200, totalElements: content.length };
}

/** Gestionnaires par défaut ; chaque test peut les surcharger avec server.use(...). */
export const handlers = [
  http.post('/api/v1/auth/refresh', () => problem(401, 'AUTH_REFRESH_INVALID', 'Session expirée')),
  http.get('/api/v1/projects', () => HttpResponse.json(page([SHOP]))),
  // Données de référence lues par des fenêtres toujours montées (création de test, arbre des dossiers).
  http.get('/api/v1/reference/frameworks', () => HttpResponse.json([])),
  http.get('/api/v1/projects/:key/test-folders', () => HttpResponse.json([])),
  http.get('/api/v1/projects/:key/test-cases', () => HttpResponse.json(page([]))),
  http.get('/api/v1/projects/:key/requirements/tree', () => HttpResponse.json([])),
  // Runs automatisés de la page campagne et leur flux temps réel (fermé aussitôt).
  http.get('/api/v1/projects/:key/campaigns/:ck/runs', () => HttpResponse.json([])),
  http.get('/api/v1/projects/:key/campaigns/:ck/run-events', () => new HttpResponse('', { headers: { 'Content-Type': 'text/event-stream' } })),
  http.get('/api/v1/projects/:key/runs/:rk/artifacts', () => HttpResponse.json([])),
  // ADR-0024 barre supérieure (notifications), pièces jointes, recherche : vides par défaut.
  http.get('/api/v1/projects/:key/notifications', () =>
    HttpResponse.json({ myTests: 0, sessionsToApprove: 0, blockingDefects: 0, failedRuns: 0 }),
  ),
  http.get('/api/v1/projects/:key/attachments', () => HttpResponse.json([])),
  http.get('/api/v1/projects/:key/search', () => HttpResponse.json([])),
  // Tableau de bord (page d'accueil d'un projet), vide par défaut.
  http.get('/api/v1/projects/:key/dashboard', () =>
    HttpResponse.json({ openDefectsBySeverity: {}, lastRuns: [], burndown: [], burnup: [], automatedTrend: [], defectsBySprint: [] }),
  ),
  http.get('/api/v1/projects/:key/runs/:rk/events', () => new HttpResponse('', { headers: { 'Content-Type': 'text/event-stream' } })),
];

export const server = setupServer(...handlers);
