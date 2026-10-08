import { MantineProvider } from '@mantine/core';
import { Notifications } from '@mantine/notifications';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react';
import type { ReactElement } from 'react';
import { createMemoryRouter, RouterProvider, type RouteObject } from 'react-router-dom';
import { routerFuture } from '../routes/routes';
import { theme } from '../theme';

/** Rend des routes dans les mêmes fournisseurs que l'application, à partir d'une URL initiale. */
export function renderRoutes(routes: RouteObject[], initialPath: string) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  const router = createMemoryRouter(routes, { initialEntries: [initialPath], future: routerFuture });
  const result = render(
    // env="test" : Mantine désactive transitions et portails.
    <MantineProvider theme={theme} env="test">
      <Notifications />
      <QueryClientProvider client={client}>
        <RouterProvider router={router} future={{ v7_startTransition: true }} />
      </QueryClientProvider>
    </MantineProvider>,
  );
  return { ...result, router };
}

export function renderElement(element: ReactElement, path = '/') {
  return renderRoutes([{ path: '*', element }], path);
}
