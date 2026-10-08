import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { renderRoutes } from '../../test/render';
import { ADMIN, problem, server } from '../../test/server';
import { useAuthStore } from './authStore';
import { LoginPage } from './LoginPage';

const routes = [
  { path: '/login', element: <LoginPage /> },
  { path: '/projects', element: <div>Liste des projets</div> },
];

describe('§13.2 /login — Connexion (lot 0)', () => {
  it('connecte admin et ouvre la liste des projets', async () => {
    let sent: unknown;
    server.use(
      http.post('/api/v1/auth/login', async ({ request }) => {
        sent = await request.json();
        return HttpResponse.json({ accessToken: 'jwt', tokenType: 'Bearer', expiresIn: 900, user: ADMIN });
      }),
    );
    renderRoutes(routes, '/login');

    await userEvent.type(screen.getByTestId('login-input'), 'admin');
    await userEvent.type(screen.getByTestId('password-input'), 'demo');
    await userEvent.click(screen.getByTestId('login-submit'));

    expect(await screen.findByText('Liste des projets')).toBeInTheDocument();
    expect(sent).toEqual({ login: 'admin', password: 'demo' });
    expect(useAuthStore.getState()).toMatchObject({ accessToken: 'jwt', status: 'authenticated' });
  });

  it("affiche le message renvoyé par l'API en cas d'identifiants invalides", async () => {
    server.use(
      http.post('/api/v1/auth/login', () =>
        problem(401, 'AUTH_INVALID_CREDENTIALS', 'Login ou mot de passe incorrect.'),
      ),
    );
    renderRoutes(routes, '/login');

    await userEvent.type(screen.getByTestId('login-input'), 'admin');
    await userEvent.type(screen.getByTestId('password-input'), 'faux');
    await userEvent.click(screen.getByTestId('login-submit'));

    expect(await screen.findByRole('alert')).toHaveTextContent('Login ou mot de passe incorrect.');
    expect(useAuthStore.getState().accessToken).toBeNull();
  });

  it("valide les champs obligatoires sans appeler l'API", async () => {
    renderRoutes(routes, '/login');

    await userEvent.click(screen.getByTestId('login-submit'));

    await waitFor(() => expect(screen.getAllByText('Champ obligatoire')).toHaveLength(2));
  });
});
