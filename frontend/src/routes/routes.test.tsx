import { screen } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../api/client';
import { renderRoutes } from '../test/render';
import { ADMIN, server, TESTER } from '../test/server';
import { appRoutes } from './routes';

function sessionCookieFor(user: Schemas['MeResponse']) {
  server.use(
    http.post('/api/v1/auth/refresh', () =>
      HttpResponse.json({ accessToken: 'jwt', tokenType: 'Bearer', expiresIn: 900, user }),
    ),
  );
}

describe("§13 routage et garde d'authentification", () => {
  it('redirige un visiteur non connecté vers /login', async () => {
    const { router } = renderRoutes(appRoutes, '/projects');

    expect(await screen.findByTestId('login-submit')).toBeInTheDocument();
    expect(router.state.location.pathname).toBe('/login');
  });

  it('restaure la session depuis le cookie de rafraîchissement (rechargement de page)', async () => {
    sessionCookieFor(ADMIN);
    renderRoutes(appRoutes, '/projects');

    expect(await screen.findByTestId('project-card-SHOP')).toBeInTheDocument();
    expect(screen.getByTestId('user-menu')).toHaveTextContent('Administrateur');
  });

  it("§2.2 refuse /admin à un utilisateur qui n'est pas administrateur système", async () => {
    sessionCookieFor(TESTER);
    renderRoutes(appRoutes, '/admin/users');

    expect(await screen.findByText("Vous n'avez pas les droits nécessaires pour cette action.")).toBeInTheDocument();
  });

  it('§13.2 /p/:key ouvre le tableau de bord du projet', async () => {
    sessionCookieFor(ADMIN);
    server.use(http.get('/api/v1/projects/SHOP', () => HttpResponse.json({ key: 'SHOP', name: 'Boutique en ligne' })));
    const { router } = renderRoutes(appRoutes, '/p/SHOP');

    expect(await screen.findByTestId('nav-dashboard')).toBeInTheDocument();
    expect(router.state.location.pathname).toBe('/p/SHOP/dashboard');
  });
});
