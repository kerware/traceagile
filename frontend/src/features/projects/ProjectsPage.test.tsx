import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { renderRoutes } from '../../test/render';
import { ADMIN, page, problem, server, SHOP, TESTER } from '../../test/server';
import { useAuthStore } from '../auth/authStore';
import { ProjectsPage } from './ProjectsPage';

const routes = [
  { path: '/projects', element: <ProjectsPage /> },
  { path: '/p/:key/dashboard', element: <div>Tableau de bord du projet</div> },
];

describe('§13.2 /projects — Liste des projets', () => {
  it("affiche une carte par projet visible, avec le rôle de l'utilisateur", async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    server.use(http.get('/api/v1/projects', () => HttpResponse.json(page([{ ...SHOP, myRole: 'TESTER' }]))));
    renderRoutes(routes, '/projects');

    const card = await screen.findByTestId('project-card-SHOP');
    expect(within(card).getByText('Boutique en ligne')).toBeInTheDocument();
    expect(within(card).getByText('Testeur / QA')).toBeInTheDocument();
    expect(screen.queryByTestId('project-create')).not.toBeInTheDocument();
  });

  it('ouvre le projet au clic', async () => {
    useAuthStore.getState().setSession('jwt', TESTER);
    renderRoutes(routes, '/projects');

    await userEvent.click(await screen.findByTestId('project-open-SHOP'));

    expect(await screen.findByText('Tableau de bord du projet')).toBeInTheDocument();
  });
});

describe("Lot 0 — critère de fin : création d'un projet par l'administrateur", () => {
  it("crée le projet et l'ajoute à la liste", async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    const created = { ...SHOP, id: 'x', key: 'CRM', name: 'Relation client', memberCount: 0, myRole: undefined };
    let projects = [SHOP];
    let body: unknown;
    server.use(
      http.get('/api/v1/projects', () => HttpResponse.json(page(projects))),
      http.post('/api/v1/projects', async ({ request }) => {
        body = await request.json();
        projects = [created, SHOP];
        return HttpResponse.json(created, { status: 201 });
      }),
    );
    renderRoutes(routes, '/projects');

    await userEvent.click(await screen.findByTestId('project-create'));
    await userEvent.type(screen.getByTestId('project-key-input'), 'crm');
    await userEvent.type(screen.getByTestId('project-name-input'), 'Relation client');
    await userEvent.click(screen.getByTestId('project-save'));

    expect(await screen.findByTestId('project-card-CRM')).toBeInTheDocument();
    expect(body).toEqual({ key: 'CRM', name: 'Relation client', description: '' });
  });

  it('§3.1 refuse une clé invalide côté client', async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    renderRoutes(routes, '/projects');

    await userEvent.click(await screen.findByTestId('project-create'));
    await userEvent.type(screen.getByTestId('project-key-input'), 'AB');
    await userEvent.type(screen.getByTestId('project-name-input'), 'Trop court');
    await userEvent.click(screen.getByTestId('project-save'));

    expect(await screen.findByText('3 à 10 lettres majuscules (A-Z)')).toBeInTheDocument();
  });

  it("affiche le conflit de clé renvoyé par l'API (409)", async () => {
    useAuthStore.getState().setSession('jwt', ADMIN);
    server.use(
      http.post('/api/v1/projects', () => problem(409, 'PROJECT_KEY_TAKEN', 'La clé « SHOP » est déjà utilisée.')),
    );
    renderRoutes(routes, '/projects');

    await userEvent.click(await screen.findByTestId('project-create'));
    await userEvent.type(screen.getByTestId('project-key-input'), 'SHOP');
    await userEvent.type(screen.getByTestId('project-name-input'), 'Doublon');
    await userEvent.click(screen.getByTestId('project-save'));

    expect(await screen.findByText('La clé « SHOP » est déjà utilisée.')).toBeInTheDocument();
  });
});
