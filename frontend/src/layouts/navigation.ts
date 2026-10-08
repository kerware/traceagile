import type { Me } from '../features/auth/authStore';

export type NavId =
  | 'dashboard'
  | 'backlog'
  | 'tests'
  | 'exploratory'
  | 'planning'
  | 'campaigns'
  | 'myExecutions'
  | 'traceability'
  | 'defects'
  | 'reports'
  | 'administration';

/** §13.2 Écrans d'un projet, dans l'ordre du menu §13.1, avec le lot qui les livre (§16.2). */
export const PROJECT_SCREENS: ReadonlyArray<{ id: NavId; path: string; lot: number }> = [
  { id: 'dashboard', path: 'dashboard', lot: 8 },
  { id: 'backlog', path: 'backlog', lot: 1 },
  { id: 'tests', path: 'tests', lot: 2 },
  { id: 'exploratory', path: 'exploratory', lot: 6 },
  { id: 'planning', path: 'planning', lot: 4 },
  { id: 'campaigns', path: 'campaigns', lot: 5 },
  { id: 'myExecutions', path: 'my-executions', lot: 5 },
  { id: 'traceability', path: 'traceability', lot: 3 },
  { id: 'defects', path: 'defects', lot: 5 },
  { id: 'reports', path: 'reports', lot: 8 },
];

export interface NavItem {
  id: NavId;
  to: string;
}

/** §13.1 Menu latéral : entrées du projet courant, puis Administration selon le rôle. */
export function navigationFor(projectKey: string | null, user: Me): NavItem[] {
  const items: NavItem[] = projectKey
    ? PROJECT_SCREENS.map((s) => ({ id: s.id, to: `/p/${projectKey}/${s.path}` }))
    : [];
  if (user.systemAdmin) {
    items.push({ id: 'administration', to: '/admin' });
  }
  return items;
}
