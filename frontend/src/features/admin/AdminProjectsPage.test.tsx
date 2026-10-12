import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import { renderElement } from '../../test/render';
import { page, server } from '../../test/server';
import { AdminProjectsPage } from './AdminProjectsPage';

const SWAG = { id: '00000000-0000-0000-0000-000000000010', key: 'SWAG', name: 'Swag Labs', archived: false, memberCount: 2, version: 0 } as Schemas['ProjectResponse'];

describe('§2.2 /admin — membres d’un projet', () => {
  it('indique sous chaque membre ce que son profil permet et ne permet pas', async () => {
    server.use(
      http.get('/api/v1/projects', () => HttpResponse.json(page([SWAG]))),
      http.get('/api/v1/users', () => HttpResponse.json(page([]))),
      http.get('/api/v1/projects/SWAG/members', () =>
        HttpResponse.json([
          { login: 'qa1', displayName: 'Quentin Testeur', role: 'TESTER' },
          { login: 'dev', displayName: 'Dev Eloppeur', role: 'DEVELOPER' },
        ]),
      ),
    );
    renderElement(<AdminProjectsPage />);

    await userEvent.click(await screen.findByTestId('admin-members-SWAG'));

    const testeur = await screen.findByTestId('member-rights-0');
    expect(testeur).toHaveTextContent('Peut écrire tous les tests');
    expect(testeur).toHaveTextContent('Ne peut pas');
    expect(testeur).toHaveTextContent('lancer de run automatisé');
    expect(screen.getByTestId('member-rights-1')).toHaveTextContent('lancer les runs automatisés');

    await userEvent.click(screen.getByTestId('member-role-0'));
    await userEvent.click(await screen.findByRole('option', { name: 'Lecteur' }));
    expect(within(screen.getByTestId('members-editor')).getByTestId('member-rights-0')).toHaveTextContent('Peut tout consulter');
  });
});
