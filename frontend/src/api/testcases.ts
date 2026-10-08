import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../features/auth/authStore';
import { api, refreshSession, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';
import { requirementKeys } from './requirements';

/** Hooks TanStack Query du référentiel de tests (§12 Cas de test, Gherkin, référentiels). */

export type TestCaseSummary = Schemas['TestCaseSummary'];
export type TestCaseDetail = Schemas['TestCaseDetail'];
export type TestKind = TestCaseDetail['kind'];
export type TestCaseStatus = TestCaseDetail['status'];
export type TestTechnique = NonNullable<TestCaseSummary['technique']>;
export type TestCasePatch = Schemas['TestCaseFieldsRequest'];
export type CreateTestCase = Schemas['CreateTestCaseRequest'];
export type LinkType = Schemas['LinkRequest']['linkType'];

/** §12 filtres du référentiel, reflétés dans l'URL. */
export interface TestFilters {
  kind?: TestKind[];
  technique?: TestTechnique[];
  status?: TestCaseStatus[];
  tag?: string;
  requirement?: string;
  orphan?: boolean;
  automationCandidate?: boolean;
  q?: string;
}

export const testKeys = {
  all: (project: string) => ['tests', project] as const,
  list: (project: string, filters: TestFilters, page: number, sort: string) => ['tests', project, 'list', filters, page, sort] as const,
  tree: (project: string, groupBy: string) => ['tests', project, 'tree', groupBy] as const,
  detail: (project: string, key: string) => ['tests', project, 'detail', key] as const,
  versions: (project: string, key: string) => ['tests', project, 'detail', key, 'versions'] as const,
  diff: (project: string, key: string, from: number, to: number) => ['tests', project, 'detail', key, 'diff', from, to] as const,
  history: (project: string, key: string) => ['tests', project, 'detail', key, 'history'] as const,
  linked: (project: string, requirement: string) => ['tests', project, 'linked', requirement] as const,
  frameworks: ['frameworks'] as const,
};

function useInvalidate(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: testKeys.all(project) }),
      // DoR / DoD « au moins un test lié » et onglet « Tests liés » des exigences.
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
    ]);
}

export function useTestList(project: string, filters: TestFilters, page: number, sort: string) {
  return useQuery({
    queryKey: testKeys.list(project, filters, page, sort),
    placeholderData: keepPreviousData,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/test-cases', {
          params: { path: { projectKey: project }, query: { ...filters, page, size: 50, sort: [sort] } },
        }),
      ),
  });
}

export function useTestTree(project: string, groupBy: 'folder' | 'feature') {
  return useQuery({
    queryKey: testKeys.tree(project, groupBy),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/test-cases/tree', { params: { path: { projectKey: project }, query: { groupBy } } })),
  });
}

export function useTestCase(project: string, key: string | null) {
  return useQuery({
    queryKey: testKeys.detail(project, key ?? ''),
    enabled: key !== null,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/test-cases/{key}', { params: { path: { projectKey: project, key: key ?? '' } } })),
  });
}

export function useCreateTest(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: CreateTestCase) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/test-cases', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

/** §12 PATCH merge-patch avec If-Match ; la réponse porte les avertissements des tags Gherkin. */
export function useUpdateTest(project: string) {
  const client = useQueryClient();
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ test, patch }: { test: TestCaseDetail; patch: TestCasePatch }) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/test-cases/{key}', {
          params: { path: { projectKey: project, key: test.key }, header: { 'If-Match': `"${test.version}"` } },
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: async (data) => {
      await invalidate();
      // Conserve la réponse (avertissements compris) jusqu'au prochain rechargement.
      client.setQueryData(testKeys.detail(project, data.key), data);
    },
  });
}

export function useDeleteTest(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/test-cases/{key}', { params: { path: { projectKey: project, key } } });
      if (!result.response.ok) throw new ApiError(result.response.status, result.error as Problem | undefined);
    },
    onSuccess: invalidate,
  });
}

export function useChangeTestStatus(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ key, status }: { key: string; status: TestCaseStatus }) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/test-cases/{key}/status', {
          params: { path: { projectKey: project, key } },
          body: { status },
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useReplaceTestLinks(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (links: Schemas['LinkRequest'][]) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/test-cases/{key}/requirements', {
          params: { path: { projectKey: project, key } },
          body: links,
        }),
      ),
    onSuccess: invalidate,
  });
}

export function useTestVersions(project: string, key: string) {
  return useQuery({
    queryKey: testKeys.versions(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/test-cases/{key}/versions', { params: { path: { projectKey: project, key } } })),
  });
}

export function useTestVersionDiff(project: string, key: string, from: number | null, to: number | null) {
  return useQuery({
    queryKey: testKeys.diff(project, key, from ?? 0, to ?? 0),
    enabled: from !== null && to !== null && from !== to,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/test-cases/{key}/versions/{from}/diff/{to}', {
          params: { path: { projectKey: project, key, from: from ?? 0, to: to ?? 0 } },
        }),
      ),
  });
}

export function useTestHistory(project: string, key: string) {
  return useQuery({
    queryKey: testKeys.history(project, key),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/test-cases/{key}/history', {
          params: { path: { projectKey: project, key }, query: { size: 100 } },
        }),
      ),
  });
}

/** F-REQ-11 « Générer un test BDD » depuis un critère Gherkin. */
export function useGenerateTest(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (criterionId: string) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/acceptance-criteria/{id}/generate-test', {
          params: { path: { projectKey: project, id: criterionId } },
        }),
      ),
    onSuccess: invalidate,
  });
}

/** Onglet « Tests liés » d'une exigence. */
export function useLinkedTests(project: string, requirementKey: string) {
  return useQuery({
    queryKey: testKeys.linked(project, requirementKey),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/test-cases', {
          params: { path: { projectKey: project, key: requirementKey } },
        }),
      ),
  });
}

/** F-AUT-04 étapes déjà utilisées dans le projet (autocomplétion de l'éditeur Gherkin). */
export async function fetchSteps(project: string, q?: string) {
  return unwrap(await api.GET('/api/v1/projects/{projectKey}/gherkin/steps', { params: { path: { projectKey: project }, query: { q } } }));
}

export function useFrameworks() {
  return useQuery({
    queryKey: testKeys.frameworks,
    staleTime: 5 * 60_000,
    queryFn: async () => unwrap(await api.GET('/api/v1/reference/frameworks')),
  });
}

export function useReplaceFrameworks() {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({ technique, names }: { technique: TestTechnique; names: string[] }) =>
      unwrap(await api.PUT('/api/v1/reference/frameworks/{technique}', { params: { path: { technique } }, body: names })),
    onSuccess: () => client.invalidateQueries({ queryKey: testKeys.frameworks }),
  });
}

export function useImportFeatures(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ files, framework }: { files: File[]; framework?: string }) => {
      const body = new FormData();
      files.forEach((file) => body.append('files', file));
      return unwrap(
        await api.POST('/api/v1/projects/{projectKey}/test-cases/import-feature', {
          params: { path: { projectKey: project }, query: { framework } },
          body: body as unknown as { files: string[] },
          bodySerializer: (value) => value as unknown as FormData,
        }),
      );
    },
    onSuccess: invalidate,
  });
}

export function useDiscovery(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (report: Schemas['DiscoveryReport']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/test-cases/discovery', { params: { path: { projectKey: project } }, body: report })),
    onSuccess: invalidate,
  });
}

/** F-AUT-07 téléchargement du zip des .feature (jeton Bearer requis). */
export async function downloadFeatures(project: string, keys?: string[]) {
  const query = new URLSearchParams();
  keys?.forEach((k) => query.append('keys', k));
  const url = `${window.location.origin}/api/v1/projects/${project}/test-cases/export-feature?${query.toString()}`;
  const send = () => fetch(url, { headers: { Authorization: `Bearer ${useAuthStore.getState().accessToken ?? ''}` } });
  let response = await send();
  if (response.status === 401 && (await refreshSession())) response = await send();
  if (!response.ok) throw new ApiError(response.status, undefined);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(await response.blob());
  link.download = `${project}-features.zip`;
  link.click();
  URL.revokeObjectURL(link.href);
}
