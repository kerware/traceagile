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
];

export const server = setupServer(...handlers);
