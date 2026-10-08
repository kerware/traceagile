import { Navigate, type RouteObject } from 'react-router-dom';
import { ComingSoon } from '../components/ComingSoon';
import { NotFound } from '../components/NotFound';
import { RequireAuth } from '../features/auth/RequireAuth';
import { RequireSystemAdmin } from '../features/auth/RequireSystemAdmin';
import { AppLayout } from '../layouts/AppLayout';
import { PROJECT_SCREENS } from '../layouts/navigation';

/** Écrans déjà livrés ; les autres affichent leur lot de livraison. */
const DELIVERED = ['dashboard', 'backlog', 'tests'];

export const routerFuture = {
  v7_relativeSplatPath: true,
  v7_fetcherPersist: true,
  v7_normalizeFormMethod: true,
  v7_partialHydration: true,
  v7_skipActionErrorRevalidation: true,
} as const;

/** §13.2 Écrans ; chargement paresseux par fonctionnalité (§11.4). */
export const appRoutes: RouteObject[] = [
  {
    path: '/login',
    lazy: () => import('../features/auth/LoginPage').then((m) => ({ Component: m.LoginPage })),
  },
  {
    element: (
      <RequireAuth>
        <AppLayout />
      </RequireAuth>
    ),
    children: [
      { index: true, element: <Navigate to="/projects" replace /> },
      {
        path: 'projects',
        lazy: () => import('../features/projects/ProjectsPage').then((m) => ({ Component: m.ProjectsPage })),
      },
      {
        path: 'p/:key',
        children: [
          { index: true, element: <Navigate to="dashboard" replace /> },
          {
            path: 'dashboard',
            lazy: () => import('../features/dashboard/DashboardPage').then((m) => ({ Component: m.DashboardPage })),
          },
          {
            path: 'backlog',
            lazy: () => import('../features/requirements/BacklogPage').then((m) => ({ Component: m.BacklogPage })),
          },
          {
            path: 'requirements/:rk',
            lazy: () => import('../features/requirements/RequirementPage').then((m) => ({ Component: m.RequirementPage })),
          },
          {
            path: 'tests',
            lazy: () => import('../features/tests/TestsPage').then((m) => ({ Component: m.TestsPage })),
          },
          {
            path: 'tests/:tk',
            lazy: () => import('../features/tests/TestCasePage').then((m) => ({ Component: m.TestCasePage })),
          },
          // Écrans des lots suivants : emplacement réservé indiquant le lot de livraison.
          ...PROJECT_SCREENS.filter((s) => !DELIVERED.includes(s.id)).map((screen) => ({
            path: `${screen.path}/*`,
            element: <ComingSoon screen={screen.id} lot={screen.lot} />,
          })),
        ],
      },
      {
        path: 'admin',
        element: <RequireSystemAdmin />,
        children: [
          { index: true, element: <Navigate to="users" replace /> },
          {
            path: 'users',
            lazy: () => import('../features/admin/AdminUsersPage').then((m) => ({ Component: m.AdminUsersPage })),
          },
          {
            path: 'projects',
            lazy: () => import('../features/admin/AdminProjectsPage').then((m) => ({ Component: m.AdminProjectsPage })),
          },
          {
            path: 'checklists',
            lazy: () => import('../features/admin/AdminChecklistsPage').then((m) => ({ Component: m.AdminChecklistsPage })),
          },
          {
            path: 'references',
            lazy: () => import('../features/admin/AdminReferencesPage').then((m) => ({ Component: m.AdminReferencesPage })),
          },
        ],
      },
      { path: '*', element: <NotFound /> },
    ],
  },
];
