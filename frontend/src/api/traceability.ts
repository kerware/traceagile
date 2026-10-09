import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../features/auth/authStore';
import { api, refreshSession, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';
import { requirementKeys } from './requirements';
import { testKeys, type TestKind } from './testcases';

/** Hooks TanStack Query de la traçabilité et de la couverture (§7, §12). */

export type MatrixResponse = Schemas['MatrixResponse'];
export type MatrixCell = Schemas['MatrixCell'];
export type CoverageResponse = Schemas['CoverageResponse'];
export type IndicatorResponse = Schemas['IndicatorResponse'];
export type OrphansResponse = Schemas['OrphansResponse'];
export type TraceTreeResponse = Schemas['TraceTreeResponse'];
export type TraceNode = Schemas['TraceNodeResponse'];
export type ImpactResponse = Schemas['ImpactResponse'];
export type VerificationStatus = Schemas['MatrixRequirement']['verificationStatus'];
export type LinkType = Schemas['CreateLinkRequest']['linkType'];
export type ExecutionStatus = NonNullable<Schemas['TestItem']['lastResult']>;

/** Options de la matrice (F-TRA-04), reflétées dans l'URL. */
export interface MatrixOptions {
  scope?: string;
  allTests?: boolean;
  kind?: TestKind[];
}

export const traceKeys = {
  all: (project: string) => ['traceability', project] as const,
  matrix: (project: string, options: MatrixOptions) => ['traceability', project, 'matrix', options] as const,
  coverage: (project: string, scope?: string) => ['traceability', project, 'coverage', scope ?? 'project'] as const,
  orphans: (project: string) => ['traceability', project, 'orphans'] as const,
  tree: (project: string, key: string) => ['traceability', project, 'tree', key] as const,
  impact: (project: string, key: string) => ['traceability', project, 'impact', key] as const,
};

function query(options: MatrixOptions) {
  return { scope: options.scope || undefined, tests: options.allTests ? 'all' : 'linked', kind: options.kind?.length ? options.kind : undefined };
}

export function useMatrix(project: string, options: MatrixOptions) {
  return useQuery({
    queryKey: traceKeys.matrix(project, options),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/traceability/matrix', { params: { path: { projectKey: project }, query: query(options) } })),
  });
}

export function useCoverage(project: string, scope?: string) {
  return useQuery({
    queryKey: traceKeys.coverage(project, scope),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/coverage', { params: { path: { projectKey: project }, query: { scope: scope || undefined } } })),
  });
}

export function useOrphans(project: string) {
  return useQuery({
    queryKey: traceKeys.orphans(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/traceability/orphans', { params: { path: { projectKey: project } } })),
  });
}

export function useTraceTree(project: string, key: string) {
  return useQuery({
    queryKey: traceKeys.tree(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/trace-tree', { params: { path: { projectKey: project, key } } })),
  });
}

export function useImpact(project: string, key: string | null) {
  return useQuery({
    queryKey: traceKeys.impact(project, key ?? ''),
    enabled: !!key,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/impact', { params: { path: { projectKey: project, key: key ?? '' } } })),
  });
}

/** Un lien change la couverture, les statuts du backlog, les onglets des fiches : tout est rechargé. */
function useInvalidateAll(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: traceKeys.all(project) }),
      client.invalidateQueries({ queryKey: testKeys.all(project) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
    ]);
}

/** F-TRA-01 créer un lien (matrice, fiche exigence). */
export function useCreateLink(project: string) {
  const invalidate = useInvalidateAll(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateLinkRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/trace-links', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

/** F-TRA-02 changer le type d'un lien. */
export function useUpdateLink(project: string) {
  const invalidate = useInvalidateAll(project);
  return useMutation({
    mutationFn: async ({ id, linkType }: { id: string; linkType: LinkType }) =>
      unwrap(await api.PATCH('/api/v1/projects/{projectKey}/trace-links/{id}', { params: { path: { projectKey: project, id } }, body: { linkType } })),
    onSuccess: invalidate,
  });
}

export function useDeleteLink(project: string) {
  const invalidate = useInvalidateAll(project);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/trace-links/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) throw new ApiError(result.response.status, result.error as Problem | undefined);
    },
    onSuccess: invalidate,
  });
}

/** §3.3-7 marquer un lien suspect comme revu. */
export function useReviewLink(project: string) {
  const invalidate = useInvalidateAll(project);
  return useMutation({
    mutationFn: async (id: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/trace-links/{id}/review', { params: { path: { projectKey: project, id } } })),
    onSuccess: invalidate,
  });
}

/** F-TRA-08 export de la matrice (CSV ou PDF), téléchargé par le navigateur. */
export async function downloadMatrix(project: string, format: 'csv' | 'pdf', options: MatrixOptions) {
  const params = new URLSearchParams({ format });
  const q = query(options);
  if (q.scope) params.set('scope', q.scope);
  params.set('tests', q.tests);
  q.kind?.forEach((k) => params.append('kind', k));
  const url = `${window.location.origin}/api/v1/projects/${project}/traceability/matrix/export?${params.toString()}`;
  const send = () => fetch(url, { headers: { Authorization: `Bearer ${useAuthStore.getState().accessToken ?? ''}` } });
  let response = await send();
  if (response.status === 401 && (await refreshSession())) response = await send();
  if (!response.ok) throw new ApiError(response.status, undefined);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(await response.blob());
  link.download = `${project}-matrice.${format}`;
  link.click();
}
