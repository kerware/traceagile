import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, type Schemas } from './client';
import { unwrap } from './errors';
import { requirementKeys } from './requirements';
import { traceKeys } from './traceability';

/** Hooks TanStack Query de la planification : releases et sprints (§8.1, §8.2, §12). */

export type ReleaseResponse = Schemas['ReleaseResponse'];
export type SprintSummary = Schemas['SprintSummary'];
export type SprintDetail = Schemas['SprintDetail'];
export type ScopeItem = Schemas['ScopeItemResponse'];
export type PlanningStatus = SprintSummary['status'];
export type CloseAction = Schemas['CloseDecisionRequest']['action'];

export const planningKeys = {
  all: (project: string) => ['planning', project] as const,
  releases: (project: string) => ['planning', project, 'releases'] as const,
  sprints: (project: string) => ['planning', project, 'sprints'] as const,
  sprint: (project: string, key: string) => ['planning', project, 'sprint', key] as const,
  ready: (project: string) => ['planning', project, 'ready'] as const,
};

/** La planification change les statuts des exigences et les périmètres de couverture. */
function useInvalidate(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: planningKeys.all(project) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
      client.invalidateQueries({ queryKey: traceKeys.all(project) }),
    ]);
}

/** F-PLN-02 feuille de route. */
export function useReleases(project: string) {
  return useQuery({
    queryKey: planningKeys.releases(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/releases', { params: { path: { projectKey: project } } })),
  });
}

export function useSprints(project: string) {
  return useQuery({
    queryKey: planningKeys.sprints(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/sprints', { params: { path: { projectKey: project } } })),
  });
}

export function useSprint(project: string, key: string | null) {
  return useQuery({
    queryKey: planningKeys.sprint(project, key ?? ''),
    enabled: !!key,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/sprints/{key}', { params: { path: { projectKey: project, key: key ?? '' } } })),
  });
}

/** F-PLN-05 colonne de gauche : exigences prêtes du backlog (rang). */
export function useReadyBacklog(project: string) {
  return useQuery({
    queryKey: planningKeys.ready(project),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements', {
          params: { path: { projectKey: project }, query: { status: ['READY'], page: 0, size: 200, sort: ['rank,asc'] } },
        }),
      ),
  });
}

export function useCreateRelease(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateReleaseRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/releases', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

export function useUpdateRelease(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, patch }: { key: string; patch: Schemas['UpdateReleaseRequest'] }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/releases/{key}', {
          params: { path: { projectKey: project, key } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

/** F-PLN-01 génération de sprints. */
export function useGenerateSprints(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, body }: { key: string; body: Schemas['GenerateSprintsRequest'] }) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/releases/{key}/generate-sprints', { params: { path: { projectKey: project, key } }, body })),
    onSuccess: invalidate,
  });
}

/** F-PLN-03 clôture d'une release (bilan figé). */
export function useCloseRelease(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/releases/{key}/close', { params: { path: { projectKey: project, key } } })),
    onSuccess: invalidate,
  });
}

export function useCreateSprint(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateSprintRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sprints', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

export function useUpdateSprint(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, patch }: { key: string; patch: Schemas['UpdateSprintRequest'] }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/sprints/{key}', {
          params: { path: { projectKey: project, key } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

/** F-PLN-05 périmètre ordonné ; mise à jour optimiste annulée en cas d'erreur (§11.4). */
export function useReplaceScope(project: string, key: string) {
  const client = useQueryClient();
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (requirementKeys: string[]) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/sprints/{key}/scope', {
          params: { path: { projectKey: project, key } },
          body: { requirementKeys },
        }),
      ),
    onMutate: async (requirementKeys: string[]) => {
      await client.cancelQueries({ queryKey: planningKeys.sprint(project, key) });
      const previous = client.getQueryData<SprintDetail>(planningKeys.sprint(project, key));
      return { previous, requirementKeys };
    },
    onError: (_error, _keys, context) => {
      if (context?.previous) client.setQueryData(planningKeys.sprint(project, key), context.previous);
    },
    onSuccess: async (data) => {
      client.setQueryData(planningKeys.sprint(project, key), data);
      await invalidate();
    },
  });
}

/** F-PLN-06 démarrage. */
export function useStartSprint(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sprints/{key}/start', { params: { path: { projectKey: project, key } } })),
    onSuccess: invalidate,
  });
}

/** F-PLN-06 clôture avec une décision par story non terminée. */
export function useCloseSprint(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, decisions }: { key: string; decisions: { requirementKey: string; action: CloseAction }[] }) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sprints/{key}/close', { params: { path: { projectKey: project, key } }, body: { decisions } })),
    onSuccess: invalidate,
  });
}
