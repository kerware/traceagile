import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';
import { requirementKeys } from './requirements';
import { testKeys } from './testcases';
import { traceKeys } from './traceability';

/** Hooks TanStack Query des campagnes (§8.3), exécutions (§8.4) et anomalies (§8.6). */

export type CampaignSummary = Schemas['CampaignSummary'];
export type CampaignDetail = Schemas['CampaignDetail'];
export type CampaignItem = Schemas['ItemResponse'];
export type CampaignStatus = CampaignSummary['status'];
export type CampaignScope = CampaignSummary['scopeType'];
export type SelectRequest = Schemas['SelectRequest'];
export type Strategy = SelectRequest['strategy'];
export type ExecutionDetail = Schemas['ExecutionDetail'];
export type StepResult = Schemas['StepResultResponse'];
export type MyExecution = Schemas['MyExecutionResponse'];
export type DefectSummary = Schemas['DefectSummary'];
export type DefectDetail = Schemas['DefectDetail'];
export type DefectSeverity = DefectSummary['severity'];
export type DefectStatus = DefectSummary['status'];
export type ExecutionStatus = StepResult['status'];

export const campaignKeys = {
  all: (project: string) => ['campaigns', project] as const,
  list: (project: string) => ['campaigns', project, 'list'] as const,
  detail: (project: string, key: string) => ['campaigns', project, 'detail', key] as const,
  testers: (project: string) => ['campaigns', project, 'testers'] as const,
  mine: (project: string) => ['campaigns', project, 'mine'] as const,
  execution: (project: string, id: string) => ['campaigns', project, 'execution', id] as const,
  defects: (project: string, filters: DefectFilters) => ['campaigns', project, 'defects', filters] as const,
  defect: (project: string, key: string) => ['campaigns', project, 'defect', key] as const,
  requirementExecutions: (project: string, key: string) => ['campaigns', project, 'requirement-executions', key] as const,
  requirementDefects: (project: string, key: string) => ['campaigns', project, 'requirement-defects', key] as const,
};

export interface DefectFilters {
  status?: DefectStatus[];
  severity?: DefectSeverity[];
  q?: string;
}

/** Une exécution ou une anomalie change avancement, couverture, statuts des exigences et compteurs des tests. */
function useInvalidate(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: campaignKeys.all(project) }),
      client.invalidateQueries({ queryKey: traceKeys.all(project) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
      client.invalidateQueries({ queryKey: testKeys.all(project) }),
    ]);
}

const path = (project: string) => ({ path: { projectKey: project } });

// ---------------------------------------------------------------- campagnes

export function useCampaigns(project: string) {
  return useQuery({
    queryKey: campaignKeys.list(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/campaigns', { params: path(project) })),
  });
}

export function useCampaign(project: string, key: string) {
  return useQuery({
    queryKey: campaignKeys.detail(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/campaigns/{key}', { params: { path: { projectKey: project, key } } })),
  });
}

export function useTesters(project: string) {
  return useQuery({
    queryKey: campaignKeys.testers(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/testers', { params: path(project) })),
  });
}

export function useCreateCampaign(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateCampaignRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns', { params: path(project), body })),
    onSuccess: invalidate,
  });
}

/** Démarrer, terminer, abandonner. */
export function useCampaignAction(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (action: 'start' | 'complete' | 'abort') => {
      const params = { params: { path: { projectKey: project, key } } };
      if (action === 'start') return unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns/{key}/start', params));
      if (action === 'complete') return unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns/{key}/complete', params));
      return unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns/{key}/abort', params));
    },
    onSuccess: invalidate,
  });
}

/** F-CMP-02 sélection cumulable. */
export function useSelectTests(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: SelectRequest) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns/{key}/items/select', { params: { path: { projectKey: project, key } }, body })),
    onSuccess: invalidate,
  });
}

export function useSortByRisk(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async () =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/campaigns/{key}/items/sort-by-risk', { params: { path: { projectKey: project, key } } })),
    onSuccess: invalidate,
  });
}

export function useReorderItems(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (itemIds: string[]) =>
      unwrap(await api.PUT('/api/v1/projects/{projectKey}/campaigns/{key}/items/order', { params: { path: { projectKey: project, key } }, body: { itemIds } })),
    onSuccess: invalidate,
  });
}

/** F-CMP-04 affectation ({@code null} : désaffecter). */
export function useAssign(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ id, assignee }: { id: string; assignee: string | null }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/campaign-items/{id}', {
          params: { path: { projectKey: project, id } },
          body: { assignee } as Schemas['ItemPatchRequest'],
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useRemoveItem(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/campaign-items/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) throw new ApiError(result.response.status, result.error as Problem | undefined);
    },
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- exécutions

/** F-EXE-01 « Mes tests à exécuter ». */
export function useMyExecutions(project: string) {
  return useQuery({
    queryKey: campaignKeys.mine(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/my-executions', { params: path(project) })),
  });
}

export function useExecution(project: string, id: string) {
  return useQuery({
    queryKey: campaignKeys.execution(project, id),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/executions/{id}', { params: { path: { projectKey: project, id } } })),
  });
}

/** F-EXE-01 / F-EXE-04 nouvelle tentative. */
export function useStartExecution(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ itemId, dataSetName, row }: { itemId: string; dataSetName?: string; row?: number }) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/campaign-items/{id}/executions', {
          params: { path: { projectKey: project, id: itemId } },
          body: { dataSetName, row },
        }),
      ),
    onSuccess: invalidate,
  });
}

function useExecutionUpdate(project: string) {
  const client = useQueryClient();
  const invalidate = useInvalidate(project);
  return async (data: ExecutionDetail) => {
    client.setQueryData(campaignKeys.execution(project, data.id), data);
    await invalidate();
  };
}

export function useRecordStep(project: string, id: string) {
  const onSuccess = useExecutionUpdate(project);
  return useMutation({
    mutationFn: async ({ position, status, actualResult }: { position: number; status: ExecutionStatus; actualResult?: string }) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/executions/{id}/steps/{position}', {
          params: { path: { projectKey: project, id, position } },
          body: { status, actualResult },
        }),
      ),
    onSuccess,
  });
}

/** F-EXE-02 statut forcé avec commentaire. */
export function useOverrideExecution(project: string, id: string) {
  const onSuccess = useExecutionUpdate(project);
  return useMutation({
    mutationFn: async ({ status, comment }: { status: ExecutionStatus; comment?: string }) =>
      unwrap(await api.PATCH('/api/v1/projects/{projectKey}/executions/{id}', { params: { path: { projectKey: project, id } }, body: { status, comment } })),
    onSuccess,
  });
}

export async function fetchDefectDraft(project: string, id: string) {
  return unwrap(await api.GET('/api/v1/projects/{projectKey}/executions/{id}/defect-draft', { params: { path: { projectKey: project, id } } }));
}

/** F-EXE-03 anomalie liée à l'exécution. */
export function useCreateDefectFromExecution(project: string, id: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateDefectRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/executions/{id}/defects', { params: { path: { projectKey: project, id } }, body })),
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- anomalies

export function useDefects(project: string, filters: DefectFilters) {
  return useQuery({
    queryKey: campaignKeys.defects(project, filters),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/defects', {
          params: { path: { projectKey: project }, query: { status: filters.status, severity: filters.severity, q: filters.q || undefined } },
        }),
      ),
  });
}

export function useDefect(project: string, key: string | null) {
  return useQuery({
    queryKey: campaignKeys.defect(project, key ?? ''),
    enabled: !!key,
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/defects/{key}', { params: { path: { projectKey: project, key: key ?? '' } } })),
  });
}

export function useCreateDefect(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateDefectRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/defects', { params: path(project), body })),
    onSuccess: invalidate,
  });
}

export function useUpdateDefect(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, patch }: { key: string; patch: Schemas['UpdateDefectRequest'] }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/defects/{key}', {
          params: { path: { projectKey: project, key } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- fiche exigence

export function useRequirementExecutions(project: string, key: string) {
  return useQuery({
    queryKey: campaignKeys.requirementExecutions(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/executions', { params: { path: { projectKey: project, key } } })),
  });
}

export function useRequirementDefects(project: string, key: string) {
  return useQuery({
    queryKey: campaignKeys.requirementDefects(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/defects', { params: { path: { projectKey: project, key } } })),
  });
}
