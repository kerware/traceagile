import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import type { Schemas } from '../../api/client';
import { renderElement } from '../../test/render';
import { page, server } from '../../test/server';
import { AdminUsersPage } from './AdminUsersPage';

const QA1: Schemas['UserResponse'] = {
  id: '00000000-0000-0000-0000-000000000002',
  login: 'qa1',
  email: 'qa1@traceagile.demo',
  displayName: 'Quentin Testeur',
  active: true,
  systemAdmin: false,
  version: 3,
  createdAt: '2026-10-08T10:00:00Z',
  updatedAt: '2026-10-08T10:00:00Z',
};

describe('§13.2 /admin — utilisateurs', () => {
  it('liste les utilisateurs', async () => {
    server.use(http.get('/api/v1/users', () => HttpResponse.json(page([QA1]))));
    renderElement(<AdminUsersPage />);

    expect(await screen.findByText('Quentin Testeur')).toBeInTheDocument();
    expect(screen.getByText('qa1@traceagile.demo')).toBeInTheDocument();
  });

  it('§12 désactive un utilisateur avec If-Match (verrou optimiste)', async () => {
    let ifMatch: string | null = null;
    let body: unknown;
    server.use(
      http.get('/api/v1/users', () => HttpResponse.json(page([QA1]))),
      http.patch('/api/v1/users/:id', async ({ request }) => {
        ifMatch = request.headers.get('If-Match');
        body = await request.json();
        return HttpResponse.json({ ...QA1, active: false, version: 4 });
      }),
    );
    renderElement(<AdminUsersPage />);

    await userEvent.click(await screen.findByTestId('user-toggle-active-qa1'));

    await waitFor(() => expect(ifMatch).toBe('"3"'));
    expect(body).toEqual({ active: false });
  });
});
