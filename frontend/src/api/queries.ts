import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, type Schemas } from './client';
import { unwrap } from './errors';

/** Hooks TanStack Query de l'administration (§12). */

export const queryKeys = {
  projects: ['projects'] as const,
  project: (key: string) => ['projects', key] as const,
  members: (key: string) => ['projects', key, 'members'] as const,
  users: ['users'] as const,
};

export function useProjects() {
  return useQuery({
    queryKey: queryKeys.projects,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects', { params: { query: { size: 200, sort: ['key,asc'] } } })),
  });
}

export function useProject(key: string) {
  return useQuery({
    queryKey: queryKeys.project(key),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{key}', { params: { path: { key } } })),
  });
}

export function useCreateProject() {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (body: Schemas['CreateProjectRequest']) => unwrap(await api.POST('/api/v1/projects', { body })),
    onSuccess: () => client.invalidateQueries({ queryKey: queryKeys.projects }),
  });
}

export function useMembers(key: string | null) {
  return useQuery({
    queryKey: queryKeys.members(key ?? ''),
    enabled: key !== null,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{key}/members', { params: { path: { key: key ?? '' } } })),
  });
}

export function useReplaceMembers(key: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (body: Schemas['MemberRequest'][]) =>
      unwrap(await api.PUT('/api/v1/projects/{key}/members', { params: { path: { key } }, body })),
    onSuccess: () => client.invalidateQueries({ queryKey: queryKeys.projects }),
  });
}

export function useUsers() {
  return useQuery({
    queryKey: queryKeys.users,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/users', { params: { query: { size: 200, sort: ['login,asc'] } } })),
  });
}

export function useCreateUser() {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (body: Schemas['CreateUserRequest']) => unwrap(await api.POST('/api/v1/users', { body })),
    onSuccess: () => client.invalidateQueries({ queryKey: queryKeys.users }),
  });
}

/** §12 PATCH avec If-Match : la version connue est envoyée pour le verrou optimiste. */
export function useUpdateUser() {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({ user, patch }: { user: Schemas['UserResponse']; patch: Schemas['UpdateUserRequest'] }) =>
      unwrap(
        await api.PATCH('/api/v1/users/{id}', {
          params: { path: { id: user.id }, header: { 'If-Match': `"${user.version}"` } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: () => client.invalidateQueries({ queryKey: queryKeys.users }),
  });
}
