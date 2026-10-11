import { MantineProvider } from '@mantine/core';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { App } from './App';
import { basic, clearCredentials, duration, jobDuration } from './api';

function renderApp(path = '/') {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <MantineProvider>
      <QueryClientProvider client={client}>
        <MemoryRouter initialEntries={[path]}>
          <App />
        </MemoryRouter>
      </QueryClientProvider>
    </MantineProvider>,
  );
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
}

const DASHBOARD = {
  live: { runningJobs: 1, busyAgents: 2, agents: 4, pendingTests: 3 },
  week: { jobs: 5, tests: 40, passed: 36, failed: 3, errors: 1, passRate: 90, averageJobMs: 65000 },
  days: [{ day: '2026-10-11', jobs: 5, passed: 36, failed: 3, errors: 1 }],
  frameworks: [{ framework: 'Playwright', tests: 30, passed: 28, passRate: 93.3, averageMs: 2400 }],
  failing: [{ testKey: 'TC-10', identifier: 'Panier › retrait @fail', project: 'SWAG', failures: 3, lastFailure: '2026-10-11T10:00:00Z' }],
  toolsInstalled: 6,
  toolsTotal: 16,
  platform: 'LINUX',
};

describe('ADR-0026 interface du serveur d’exécution', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    clearCredentials();
  });

  it('connexion de l’administrateur en HTTP Basic, puis tableau de bord (activité, réussite, tests en échec)', async () => {
    const fetchMock = vi.fn(async (url: string, init?: RequestInit) => {
      const auth = (init?.headers as Record<string, string> | undefined)?.Authorization;
      if (auth !== `Basic ${basic('admin', 'executeur')}`) return json({ code: 'ADMIN_REQUIRED' }, 401);
      if (url === '/api/admin/me') return json({ user: 'admin', serverName: 'executeur-recette' });
      if (url === '/api/admin/dashboard') return json(DASHBOARD);
      if (url.startsWith('/api/admin/jobs')) return json([]);
      return json({}, 404);
    });
    vi.stubGlobal('fetch', fetchMock);
    renderApp();
    await userEvent.type(screen.getByTestId('login-password'), 'faux');
    await userEvent.click(screen.getByTestId('login-submit'));
    expect(await screen.findByTestId('login-error')).toHaveTextContent('Identifiant ou mot de passe incorrect');
    await userEvent.clear(screen.getByTestId('login-password'));
    await userEvent.type(screen.getByTestId('login-password'), 'executeur');
    await userEvent.click(screen.getByTestId('login-submit'));
    expect(await screen.findByTestId('kpi-agents')).toHaveTextContent('2 / 4');
    expect(screen.getByTestId('kpi-pass-rate')).toHaveTextContent('90 %');
    expect(screen.getByTestId('failing-tests')).toHaveTextContent('SWAG · TC-10');
    expect(screen.getByTestId('tools-installed')).toHaveTextContent('6 / 16');
    expect(await screen.findByTestId('server-name')).toHaveTextContent('executeur-recette');
  });

  it('un 401 en cours de session ramène à la connexion', async () => {
    sessionStorage.setItem('execution-server.auth', basic('admin', 'ancien'));
    vi.stubGlobal('fetch', vi.fn(async () => json({ code: 'ADMIN_REQUIRED' }, 401)));
    renderApp('/jobs');
    await waitFor(() => expect(screen.getByTestId('login-submit')).toBeInTheDocument());
  });

  it('formats : durées et durée d’un job en cours', () => {
    expect(duration(850)).toBe('850 ms');
    expect(duration(65_000)).toBe('1 min 5 s');
    expect(duration(null)).toBe('—');
    expect(jobDuration({ startedAt: '2026-10-11T10:00:00Z', endedAt: null }, Date.parse('2026-10-11T10:00:30Z'))).toBe(30_000);
  });
});
