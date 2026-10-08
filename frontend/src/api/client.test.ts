import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { useAuthStore } from '../features/auth/authStore';
import { ADMIN, page, server } from '../test/server';
import { api } from './client';

describe("§11.1 client API — jeton d'accès et rafraîchissement", () => {
  it('envoie le jeton Bearer et un X-Correlation-Id (NF-15)', async () => {
    useAuthStore.getState().setSession('jwt-1', ADMIN);
    let headers: Headers | undefined;
    server.use(
      http.get('/api/v1/projects', ({ request }) => {
        headers = request.headers;
        return HttpResponse.json(page([]));
      }),
    );

    await api.GET('/api/v1/projects');

    expect(headers?.get('Authorization')).toBe('Bearer jwt-1');
    expect(headers?.get('X-Correlation-Id')).toBeTruthy();
  });

  it('sur un 401, rafraîchit la session une fois et rejoue la requête', async () => {
    useAuthStore.getState().setSession('expire', ADMIN);
    server.use(
      http.post('/api/v1/auth/refresh', () =>
        HttpResponse.json({ accessToken: 'jwt-2', tokenType: 'Bearer', expiresIn: 900, user: ADMIN }),
      ),
      http.get('/api/v1/projects', ({ request }) =>
        request.headers.get('Authorization') === 'Bearer jwt-2'
          ? HttpResponse.json(page([]))
          : new HttpResponse(null, { status: 401 }),
      ),
    );

    const { response } = await api.GET('/api/v1/projects');

    expect(response.status).toBe(200);
    expect(useAuthStore.getState().accessToken).toBe('jwt-2');
  });

  it('si le rafraîchissement échoue, la session est fermée', async () => {
    useAuthStore.getState().setSession('expire', ADMIN);
    server.use(http.get('/api/v1/projects', () => new HttpResponse(null, { status: 401 })));

    const { response } = await api.GET('/api/v1/projects');

    expect(response.status).toBe(401);
    expect(useAuthStore.getState().status).toBe('anonymous');
  });
});
