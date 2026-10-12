import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { renderElement } from '../../test/render';
import { server } from '../../test/server';
import { AdminGitPage } from './AdminGitPage';

const KERWARE = {
  id: 's1', name: 'kerware', baseUrl: 'https://github.com/kerware', authType: 'TOKEN', username: 'bot', hasSecret: true, projects: [{
    id: 'p1', sourceId: 's1', name: 'saucedemo-e2e', label: 'kerware / saucedemo-e2e', defaultBranch: 'master',
    cloneUrl: 'https://github.com/kerware/saucedemo-e2e', webUrl: 'https://github.com/kerware/saucedemo-e2e', version: 0,
  }],
};

describe('ADR-0030 /admin/git — dépôts Git', () => {
  it('liste les dépôts et leurs projets, déclare un dépôt à jeton et ajoute un projet', async () => {
    const posted: unknown[] = [];
    server.use(
      http.get('/api/v1/git-sources', () => HttpResponse.json([KERWARE])),
      http.post('/api/v1/git-sources', async ({ request }) => {
        posted.push(await request.json());
        return HttpResponse.json({ ...KERWARE, id: 's2', name: 'interne', projects: [] }, { status: 201 });
      }),
      http.post('/api/v1/git-sources/:id/projects', async ({ request, params }) => {
        posted.push({ source: params.id, ...((await request.json()) as object) });
        return HttpResponse.json(KERWARE.projects[0], { status: 201 });
      }),
    );
    renderElement(<AdminGitPage />);

    expect(await screen.findByTestId('git-project-kerware / saucedemo-e2e')).toHaveTextContent('https://github.com/kerware/saucedemo-e2e');
    expect(screen.getByTestId('git-auth-kerware')).toHaveTextContent('Jeton · bot');

    await userEvent.type(screen.getByTestId('git-source-name'), 'interne');
    await userEvent.type(screen.getByTestId('git-source-url'), 'https://gitlab.example.org/qa');
    await userEvent.click(screen.getByRole('radio', { name: 'Jeton' }));
    await userEvent.type(screen.getByTestId('git-source-secret'), 'glpat-secret');
    await userEvent.click(screen.getByTestId('git-source-create'));
    await userEvent.type(screen.getByTestId('git-project-name-kerware'), 'api-tests');
    await userEvent.click(screen.getByTestId('git-project-add-kerware'));

    await waitFor(() => expect(posted).toEqual([
      { name: 'interne', baseUrl: 'https://gitlab.example.org/qa', authType: 'TOKEN', secret: 'glpat-secret' },
      { source: 's1', name: 'api-tests' },
    ]));
  });
});
