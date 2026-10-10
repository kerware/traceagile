import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, authorizedFetch, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';

/** Hooks TanStack Query des bilans, du tableau de bord et des rapports configurables (§9, ADR-0023). */

export type Dashboard = Schemas['Dashboard'];
export type ReportDefinition = Schemas['ReportDefinitionResponse'];
export type ReportDefinitionInput = Schemas['ReportDefinitionRequest'];
export type ReportSummary = Schemas['ReportSummaryResponse'];
export type ReportDetail = Schemas['ReportDetailResponse'];
export type ReportSection = ReportDefinition['sections'][number];
export type ReportScopeType = ReportDefinition['scopeType'];
export type ReportFormat = ReportDefinition['defaultFormat'];
export type Verdict = NonNullable<ReportSummary['verdict']>;
export type VerdictRules = Schemas['VerdictRulesDto'];

export const reportKeys = {
  all: (project: string) => ['reports', project] as const,
  dashboard: (project: string) => ['reports', project, 'dashboard'] as const,
  definitions: (project: string) => ['reports', project, 'definitions'] as const,
  list: (project: string) => ['reports', project, 'list'] as const,
  detail: (project: string, key: string) => ['reports', project, 'detail', key] as const,
  html: (project: string, key: string, version: string) => ['reports', project, 'html', key, version] as const,
  rules: (project: string) => ['reports', project, 'rules'] as const,
};

function useInvalidate(project: string) {
  const client = useQueryClient();
  return () => client.invalidateQueries({ queryKey: reportKeys.all(project) });
}

/** F-RPT-01 / F-RPT-02 widgets et graphiques. */
export function useDashboard(project: string) {
  return useQuery({
    queryKey: reportKeys.dashboard(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/dashboard', { params: { path: { projectKey: project } } })),
  });
}

// ---------------------------------------------------------------- définitions

export function useReportDefinitions(project: string) {
  return useQuery({
    queryKey: reportKeys.definitions(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/report-definitions', { params: { path: { projectKey: project } } })),
  });
}

export function useSaveDefinition(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ id, ...body }: ReportDefinitionInput & { id?: string }) =>
      id
        ? unwrap(await api.PUT('/api/v1/projects/{projectKey}/report-definitions/{id}', { params: { path: { projectKey: project, id } }, body }))
        : unwrap(await api.POST('/api/v1/projects/{projectKey}/report-definitions', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

export function useDuplicateDefinition(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (id: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/report-definitions/{id}/duplicate', { params: { path: { projectKey: project, id } } })),
    onSuccess: invalidate,
  });
}

export function useDeleteDefinition(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/report-definitions/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) unwrap(result as never);
    },
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- rapports générés

export function useReports(project: string) {
  return useQuery({
    queryKey: reportKeys.list(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/reports', { params: { path: { projectKey: project } } })),
  });
}

export function useReport(project: string, key: string) {
  return useQuery({
    queryKey: reportKeys.detail(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/reports/{reportKey}', { params: { path: { projectKey: project, reportKey: key } } })),
  });
}

export function useGenerateReport(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['GenerateReportRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/reports', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}

export function useFreezeReport(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async () =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/reports/{reportKey}/freeze', { params: { path: { projectKey: project, reportKey: key } } })),
    onSuccess: invalidate,
  });
}

/** §9.2 verdict modifié par le PO ({@code verdict} absent = verdict calculé). */
export function useOverrideVerdict(project: string, key: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['VerdictRequest']) =>
      unwrap(
        await api.PUT('/api/v1/projects/{projectKey}/reports/{reportKey}/verdict', { params: { path: { projectKey: project, reportKey: key } }, body }),
      ),
    onSuccess: invalidate,
  });
}

export function useDeleteReport(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (key: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/reports/{reportKey}', { params: { path: { projectKey: project, reportKey: key } } });
      if (!result.response.ok) unwrap(result as never);
    },
    onSuccess: invalidate,
  });
}

/** F-RPT-03 réponse d'un export (le jeton Bearer passe en en-tête : pas de simple lien). */
async function exportResponse(project: string, key: string, format: string, download: boolean): Promise<Response> {
  const response = await authorizedFetch(`/api/v1/projects/${project}/reports/${key}/export?format=${format.toLowerCase()}&download=${download}`);
  if (!response.ok) {
    let problem: unknown = undefined;
    try {
      problem = await response.json();
    } catch {
      // corps vide ou non JSON
    }
    throw new ApiError(response.status, problem as Problem | undefined);
  }
  return response;
}

const EXTENSIONS: Record<ReportFormat, string> = { HTML: 'html', PDF: 'pdf', DOCX: 'docx', XLSX: 'xlsx', MARKDOWN: 'md', CSV: 'csv', JSON: 'json' };

/** F-RPT-03 enregistre l'export sous « RPT-n.ext ». */
export async function downloadReport(project: string, key: string, format: ReportFormat) {
  const blob = await (await exportResponse(project, key, format, true)).blob();
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${key}.${EXTENSIONS[format]}`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(url), 1_000);
}

/** F-RPT-03 affichage web : le rendu HTML du rapport (même gabarit que le PDF), relu à chaque changement. */
export function useReportHtml(project: string, key: string, version: string) {
  return useQuery({
    queryKey: reportKeys.html(project, key, version),
    queryFn: async () => (await exportResponse(project, key, 'HTML', false)).text(),
  });
}

// ---------------------------------------------------------------- règles de verdict

export function useVerdictRules(project: string) {
  return useQuery({
    queryKey: reportKeys.rules(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/verdict-rules', { params: { path: { projectKey: project } } })),
  });
}

export function useUpdateVerdictRules(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: VerdictRules) =>
      unwrap(await api.PUT('/api/v1/projects/{projectKey}/verdict-rules', { params: { path: { projectKey: project } }, body })),
    onSuccess: invalidate,
  });
}
