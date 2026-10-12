import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../features/auth/authStore';
import { api, refreshSession, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';

/** Hooks TanStack Query des exigences (§12 Exigences, Critères, DoR / DoD, versions). */

export type RequirementSummary = Schemas['RequirementSummary'];
export type RequirementDetail = Schemas['RequirementDetail'];
export type RequirementTreeNode = Schemas['RequirementTreeNode'];
export type RequirementType = RequirementDetail['type'];
export type RequirementStatus = RequirementDetail['status'];
export type Priority = RequirementDetail['priority'];
export type RiskLevel = RequirementDetail['riskLevel'];
export type NfrCategory = NonNullable<RequirementDetail['category']>;
export type Criterion = Schemas['CriterionResponse'];
export type CriterionFormat = Criterion['format'];
export type RequirementPatch = Schemas['RequirementFieldsRequest'];
export type ChecklistRule = NonNullable<Schemas['ChecklistItemResponse']['rule']>;

/** F-REQ-01 filtres reflétés dans l'URL (§11.4). */
export interface RequirementFilters {
  type?: RequirementType[];
  status?: RequirementStatus[];
  priority?: Priority[];
  risk?: RiskLevel[];
  tag?: string;
  q?: string;
  /** §12 / ADR-0024 statut de vérification calculé. */
  verification?: VerificationStatus[];
}

export type VerificationStatus = Schemas['RequirementSummary']['verificationStatus'];

export const requirementKeys = {
  all: (project: string) => ['requirements', project] as const,
  list: (project: string, filters: RequirementFilters, page: number, sort: string) =>
    ['requirements', project, 'list', filters, page, sort] as const,
  tree: (project: string) => ['requirements', project, 'tree'] as const,
  detail: (project: string, key: string) => ['requirements', project, 'detail', key] as const,
  checklists: (project: string, key: string) => ['requirements', project, 'detail', key, 'checklists'] as const,
  versions: (project: string, key: string) => ['requirements', project, 'detail', key, 'versions'] as const,
  diff: (project: string, key: string, from: number, to: number) =>
    ['requirements', project, 'detail', key, 'diff', from, to] as const,
  history: (project: string, key: string) => ['requirements', project, 'detail', key, 'history'] as const,
  projectChecklists: (project: string) => ['checklists', project] as const,
};

const PAGE_SIZE = 50;

/** Colonnes du tableau du backlog : statuts regroupés (rejetées et obsolètes non affichées). */
export const BOARD_COLUMNS = {
  todo: ['DRAFT', 'TO_REFINE', 'READY'],
  doing: ['IN_SPRINT'],
  done: ['DONE', 'ACCEPTED'],
} as const satisfies Record<string, readonly RequirementStatus[]>;
export type BoardColumn = keyof typeof BOARD_COLUMNS;
const BOARD_TYPES: RequirementType[] = ['USER_STORY', 'NON_FUNCTIONAL'];
/** Plafond par colonne (taille de page maximale de l'API). */
export const BOARD_LIMIT = 200;

/** Vue tableau du backlog : user stories et exigences non fonctionnelles, une requête par colonne, par rang. */
export function useRequirementBoard(project: string, column: BoardColumn) {
  const filters: RequirementFilters = { type: BOARD_TYPES, status: [...BOARD_COLUMNS[column]] };
  return useQuery({
    queryKey: requirementKeys.list(project, filters, 0, 'rank,asc'),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements', {
          params: { path: { projectKey: project }, query: { ...filters, page: 0, size: BOARD_LIMIT, sort: ['rank,asc'] } },
        }),
      ),
  });
}

export function useRequirementList(project: string, filters: RequirementFilters, page: number, sort: string) {
  return useQuery({
    queryKey: requirementKeys.list(project, filters, page, sort),
    placeholderData: keepPreviousData,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements', {
          params: { path: { projectKey: project }, query: { ...filters, page, size: PAGE_SIZE, sort: [sort] } },
        }),
      ),
  });
}

export function useRequirementTree(project: string) {
  return useQuery({
    queryKey: requirementKeys.tree(project),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/tree', { params: { path: { projectKey: project } } })),
  });
}

export function useRequirement(project: string, key: string | null) {
  return useQuery({
    queryKey: requirementKeys.detail(project, key ?? ''),
    enabled: key !== null,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}', {
          params: { path: { projectKey: project, key: key ?? '' } },
        }),
      ),
  });
}

/** Invalide tout ce qui concerne les exigences du projet (listes, arbre, fiches). */
function useInvalidate(project: string) {
  const client = useQueryClient();
  return () => client.invalidateQueries({ queryKey: requirementKeys.all(project) });
}

export function useCreateRequirement(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateRequirementRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/requirements', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

/** §12 PATCH merge-patch avec If-Match : seuls les champs modifiés sont envoyés. */
export function useUpdateRequirement(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ requirement, patch }: { requirement: RequirementDetail; patch: RequirementPatch }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/requirements/{key}', {
          params: {
            path: { projectKey: project, key: requirement.key },
            header: { 'If-Match': `"${requirement.version}"` },
          },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

export interface MoveVariables {
  key: string;
  parentKey: string | null;
  afterKey?: string;
  beforeKey?: string;
}

/** F-REQ-02 / F-REQ-03 déplacement ; l'appelant applique la mise à jour optimiste (§11.4). */
export function useMoveRequirement(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, parentKey, afterKey, beforeKey }: MoveVariables) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/move', {
          params: { path: { projectKey: project, key } },
          body: { parentKey: parentKey ?? undefined, afterKey, beforeKey },
        }),
      ),
    onSettled: invalidate,
  });
}

export function useDuplicateRequirement(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/duplicate', {
          params: { path: { projectKey: project, key } },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useDeleteRequirement(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/requirements/{key}', {
        params: { path: { projectKey: project, key } },
      });
      if (!result.response.ok) throw new ApiError(result.response.status, result.error as Problem | undefined);
    },
    onSuccess: invalidate,
  });
}

export function useChangeStatus(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, status, acknowledgeUnmet }: { key: string; status: RequirementStatus; acknowledgeUnmet: boolean }) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/status', {
          params: { path: { projectKey: project, key } },
          body: { status, acknowledgeUnmet },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useSetInvest(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, invest }: { key: string; invest: Schemas['InvestDto'] }) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/requirements/{key}/invest', {
          params: { path: { projectKey: project, key } },
          body: invest,
        }),
      ),
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- DoR / DoD

export function useRequirementChecklists(project: string, key: string, enabled = true) {
  return useQuery({
    queryKey: requirementKeys.checklists(project, key),
    enabled,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/checklists', {
          params: { path: { projectKey: project, key } },
        }),
      ),
  });
}

export function useCheckItem(project: string, key: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({ itemId, checked }: { itemId: string; checked: boolean }) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/requirements/{key}/checklists/{itemId}', {
          params: { path: { projectKey: project, key, itemId } },
          body: { checked },
        }),
      ),
    onSuccess: (data) => client.setQueryData(requirementKeys.checklists(project, key), data),
  });
}

export function useProjectChecklists(project: string | null) {
  return useQuery({
    queryKey: requirementKeys.projectChecklists(project ?? ''),
    enabled: project !== null,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/checklists', { params: { path: { projectKey: project ?? '' } } })),
  });
}

export function useReplaceChecklist(project: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({ kind, items }: { kind: 'DOR' | 'DOD'; items: Schemas['ChecklistItemRequest'][] }) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/checklists/{kind}', {
          params: { path: { projectKey: project, kind } },
          body: items,
        }),
      ),
    onSuccess: () => client.invalidateQueries({ queryKey: requirementKeys.projectChecklists(project) }),
  });
}

// ---------------------------------------------------------------- critères

export function useAddCriterion(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateCriterionRequest']) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/acceptance-criteria', {
          params: { path: { projectKey: project, key } },
          body,
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useUpdateCriterion(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ criterion, patch }: { criterion: Criterion; patch: Schemas['UpdateCriterionRequest'] }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/acceptance-criteria/{id}', {
          params: { path: { projectKey: project, id: criterion.id }, header: { 'If-Match': `"${criterion.version}"` } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useDeleteCriterion(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/acceptance-criteria/{id}', {
        params: { path: { projectKey: project, id } },
      });
      if (!result.response.ok) throw new ApiError(result.response.status, result.error as Problem | undefined);
    },
    onSuccess: invalidate,
  });
}

export function useReorderCriteria(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (ids: string[]) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/requirements/{key}/acceptance-criteria/order', {
          params: { path: { projectKey: project, key } },
          body: { ids },
        }),
      ),
    onSuccess: invalidate,
  });
}

/** F-REQ-10 validation Gherkin côté serveur, appelée à la frappe (avec anti-rebond). */
export async function validateGherkin(source: string) {
  return unwrap(await api.POST('/api/v1/gherkin/validate', { body: { source } }));
}

// ---------------------------------------------------------------- versions, historique

export function useVersions(project: string, key: string) {
  return useQuery({
    queryKey: requirementKeys.versions(project, key),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/versions', {
          params: { path: { projectKey: project, key } },
        }),
      ),
  });
}

export function useFreezeVersion(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (comment: string) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/versions', {
          params: { path: { projectKey: project, key } },
          body: { comment: comment || undefined },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useVersionDiff(project: string, key: string, from: number | null, to: number | null) {
  return useQuery({
    queryKey: requirementKeys.diff(project, key, from ?? 0, to ?? 0),
    enabled: from !== null && to !== null && from !== to,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/versions/{from}/diff/{to}', {
          params: { path: { projectKey: project, key, from: from ?? 0, to: to ?? 0 } },
        }),
      ),
  });
}

export function useHistory(project: string, key: string) {
  return useQuery({
    queryKey: requirementKeys.history(project, key),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/history', {
          params: { path: { projectKey: project, key }, query: { size: 100 } },
        }),
      ),
  });
}

// ---------------------------------------------------------------- import / export (F-REQ-23)

export function useImportCsv(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (file: File) => {
      const body = new FormData();
      body.append('file', file);
      return unwrap(
        await api.POST('/api/v1/projects/{projectKey}/requirements/import', {
          params: { path: { projectKey: project } },
          // openapi-fetch transmet le FormData tel quel (le navigateur fixe la frontière multipart).
          body: body as unknown as { file: string },
          bodySerializer: (value) => value as unknown as FormData,
        }),
      );
    },
    onSuccess: invalidate,
  });
}

/** Télécharge l'export CSV du backlog filtré (jeton Bearer requis, d'où un fetch plutôt qu'un lien). */
export async function downloadCsv(project: string, filters: RequirementFilters) {
  const query = new URLSearchParams();
  Object.entries(filters).forEach(([name, value]) => {
    if (Array.isArray(value)) value.forEach((v) => query.append(name, v));
    else if (value) query.append(name, value);
  });
  const url = `${window.location.origin}/api/v1/projects/${project}/requirements/export?${query.toString()}`;
  const send = () =>
    fetch(url, { headers: { Authorization: `Bearer ${useAuthStore.getState().accessToken ?? ''}` } });
  let response = await send();
  if (response.status === 401 && (await refreshSession())) response = await send();
  if (!response.ok) throw new ApiError(response.status, undefined);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(await response.blob());
  link.download = `${project}-backlog.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}
