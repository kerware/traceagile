import createClient from 'openapi-fetch';
import { useAuthStore } from '../features/auth/authStore';
import type { components, paths } from './schema';

export type Schemas = components['schemas'];

const AUTH_PATH = '/api/v1/auth/';

let refreshing: Promise<boolean> | null = null;

/**
 * §11.1 Renouvelle le jeton d'accès à partir du cookie de rafraîchissement HttpOnly.
 * Les appels simultanés partagent la même requête.
 */
export function refreshSession(): Promise<boolean> {
  refreshing ??= (async () => {
    try {
      const response = await fetch(`${window.location.origin}${AUTH_PATH}refresh`, {
        method: 'POST',
        credentials: 'same-origin',
      });
      if (!response.ok) {
        useAuthStore.getState().clear();
        return false;
      }
      const body = (await response.json()) as Schemas['TokenResponse'];
      useAuthStore.getState().setSession(body.accessToken, body.user);
      return true;
    } catch {
      useAuthStore.getState().clear();
      return false;
    } finally {
      refreshing = null;
    }
  })();
  return refreshing;
}

function newCorrelationId(): string {
  return globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

/**
 * Ajoute le jeton Bearer et l'identifiant de corrélation (NF-15) ; sur un 401, tente un
 * rafraîchissement unique puis rejoue la requête.
 */
async function authFetch(request: Request): Promise<Response> {
  const retry = request.clone();
  const token = useAuthStore.getState().accessToken;
  const correlationId = newCorrelationId();
  if (token) request.headers.set('Authorization', `Bearer ${token}`);
  request.headers.set('X-Correlation-Id', correlationId);

  const response = await fetch(request);
  if (response.status !== 401 || !token || new URL(request.url).pathname.startsWith(AUTH_PATH)) {
    return response;
  }
  if (!(await refreshSession())) return response;
  retry.headers.set('Authorization', `Bearer ${useAuthStore.getState().accessToken}`);
  retry.headers.set('X-Correlation-Id', correlationId);
  return fetch(retry);
}

/** fetch authentifié hors du client typé (texte, flux SSE) : même jeton et même rafraîchissement. */
export function authorizedFetch(path: string, init: RequestInit = {}): Promise<Response> {
  return authFetch(new Request(`${window.location.origin}${path}`, { ...init, credentials: 'same-origin' }));
}

/** Client typé généré depuis l'OpenAPI du back-end (§11.1, ADR-0007). */
export const api = createClient<paths>({
  baseUrl: window.location.origin,
  fetch: authFetch,
  credentials: 'same-origin',
});
