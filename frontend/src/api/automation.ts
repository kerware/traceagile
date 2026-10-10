import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useRef, useState } from 'react';
import { campaignKeys } from './campaigns';
import { api, authorizedFetch, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';
import { requirementKeys } from './requirements';
import { testKeys } from './testcases';
import { traceKeys } from './traceability';

/** Hooks TanStack Query de l'exécution automatisée : serveurs (§10, ADR-0020), runs (§8.5), import (F-EXE-10). */

export type ExecutionServer = Schemas['ServerResponse'];
export type ServerChoice = Schemas['ServerChoice'];
export type ServerStatus = ExecutionServer['status'];
export type RunSummary = Schemas['RunSummaryResponse'];
export type RunDetail = Schemas['RunDetail'];
export type RunExecution = Schemas['RunExecutionResponse'];
export type RunStatus = RunSummary['status'];
export type ReportImport = Schemas['ReportImportResponse'];
export type ReportFormat = 'JUNIT' | 'JEST' | 'CUCUMBER' | 'ROBOT' | 'PLAYWRIGHT';
export type RunArtifact = Schemas['RunArtifactResponse'];
export type ArtifactKind = RunArtifact['kind'];

export const automationKeys = {
  servers: ['execution-servers'] as const,
  choices: (project: string) => ['execution-servers', project] as const,
  all: (project: string) => ['runs', project] as const,
  campaign: (project: string, campaignKey: string) => ['runs', project, 'campaign', campaignKey] as const,
  run: (project: string, runKey: string) => ['runs', project, 'run', runKey] as const,
  logs: (project: string, runKey: string) => ['runs', project, 'logs', runKey] as const,
  artifacts: (project: string, runKey: string) => ['runs', project, 'artifacts', runKey] as const,
  artifact: (project: string, runKey: string, name: string) => ['runs', project, 'artifact', runKey, name] as const,
};

/** Un résultat change la campagne, la couverture, les exigences et les tests (instables). */
function useInvalidate(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: automationKeys.all(project) }),
      client.invalidateQueries({ queryKey: campaignKeys.all(project) }),
      client.invalidateQueries({ queryKey: traceKeys.all(project) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
      client.invalidateQueries({ queryKey: testKeys.all(project) }),
    ]);
}

// ---------------------------------------------------------------- serveurs (administration)

export function useExecutionServers() {
  return useQuery({ queryKey: automationKeys.servers, queryFn: async () => unwrap(await api.GET('/api/v1/execution-servers')) });
}

function useServerMutation<T>(fn: (input: T) => Promise<unknown>) {
  const client = useQueryClient();
  return useMutation({ mutationFn: fn, onSuccess: () => client.invalidateQueries({ queryKey: ['execution-servers'] }) });
}

export function useCreateServer() {
  return useServerMutation(async (body: Schemas['CreateServerRequest']) => unwrap(await api.POST('/api/v1/execution-servers', { body })));
}

export function useUpdateServer() {
  return useServerMutation(async ({ id, ...body }: Schemas['UpdateServerRequest'] & { id: string }) =>
    unwrap(await api.PATCH('/api/v1/execution-servers/{id}', { params: { path: { id } }, body })),
  );
}

export function useDeleteServer() {
  return useServerMutation(async (id: string) => {
    const result = await api.DELETE('/api/v1/execution-servers/{id}', { params: { path: { id } } });
    if (!result.response.ok) unwrap(result as never);
  });
}

/** ADR-0020 jeton émis par le serveur : demandé avec les identifiants de son administrateur, ou saisi. */
export function usePairServer() {
  return useServerMutation(async ({ id, ...body }: Schemas['PairServerRequest'] & { id: string }) =>
    unwrap(await api.POST('/api/v1/execution-servers/{id}/pair', { params: { path: { id } }, body })),
  );
}

export function useUnpairServer() {
  return useServerMutation(async (id: string) => unwrap(await api.POST('/api/v1/execution-servers/{id}/unpair', { params: { path: { id } } })));
}

export function useTestServerConnection() {
  return useServerMutation(async (id: string) =>
    unwrap(await api.POST('/api/v1/execution-servers/{id}/test-connection', { params: { path: { id } } })),
  );
}

/** F-EXE-06 serveurs proposés au lancement. */
export function useServerChoices(project: string, enabled = true) {
  return useQuery({
    queryKey: automationKeys.choices(project),
    enabled,
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/execution-servers', { params: { path: { projectKey: project } } })),
  });
}

// ---------------------------------------------------------------- runs

export function useCampaignRuns(project: string, campaignKey: string) {
  return useQuery({
    queryKey: automationKeys.campaign(project, campaignKey),
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/campaigns/{campaignKey}/runs', { params: { path: { projectKey: project, campaignKey } } }),
      ),
  });
}

export function useRun(project: string, runKey: string) {
  return useQuery({
    queryKey: automationKeys.run(project, runKey),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/runs/{runKey}', { params: { path: { projectKey: project, runKey } } })),
  });
}

/** F-EXE-06 « Lancer sur… ». */
export function useLaunchRun(project: string, campaignKey: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['LaunchRunRequest']) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/campaigns/{campaignKey}/runs', { params: { path: { projectKey: project, campaignKey } }, body }),
      ),
    onSuccess: invalidate,
  });
}

export function useCancelRun(project: string, runKey: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async () => unwrap(await api.POST('/api/v1/projects/{projectKey}/runs/{runKey}/cancel', { params: { path: { projectKey: project, runKey } } })),
    onSuccess: invalidate,
  });
}

/** F-EXE-09 relance des échecs. */
export function useRerunFailed(project: string, runKey: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async () =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/runs/{runKey}/rerun-failed', { params: { path: { projectKey: project, runKey } } })),
    onSuccess: invalidate,
  });
}

/** F-EXE-07 journaux du job (texte). */
export function useRunLogs(project: string, runKey: string, enabled: boolean) {
  return useQuery({
    queryKey: automationKeys.logs(project, runKey),
    enabled,
    queryFn: async () => {
      const response = await authorizedFetch(`/api/v1/projects/${project}/runs/${runKey}/logs`);
      return response.ok ? response.text() : '';
    },
  });
}

/** ADR-0021 artefacts du run : copies d'écran des échecs, traces système, JUnit XML, Jest JSON, rapport. */
export function useRunArtifacts(project: string, runKey: string, refreshKey?: string) {
  return useQuery({
    queryKey: [...automationKeys.artifacts(project, runKey), refreshKey ?? ''],
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/runs/{runKey}/artifacts', { params: { path: { projectKey: project, runKey } } })),
  });
}

function artifactPath(project: string, runKey: string, name: string, download: boolean) {
  return `/api/v1/projects/${project}/runs/${runKey}/artifacts/${encodeURIComponent(name)}?download=${download}`;
}

/** ADR-0021 contenu d'un artefact (le jeton Bearer passe en en-tête : pas de simple lien). */
export async function fetchArtifact(project: string, runKey: string, name: string, download = false): Promise<Blob> {
  const response = await authorizedFetch(artifactPath(project, runKey, name, download));
  if (!response.ok) {
    let problem: unknown = undefined;
    try {
      problem = await response.json();
    } catch {
      // corps vide ou non JSON
    }
    throw new ApiError(response.status, problem as Problem | undefined);
  }
  return response.blob();
}

/** ADR-0021 enregistre un artefact sous son nom. */
export async function downloadArtifact(project: string, runKey: string, name: string) {
  const blob = await fetchArtifact(project, runKey, name, true);
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = name;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(url), 1_000);
}

/** ADR-0021 copie d'écran affichée dans l'interface : URL d'objet libérée au démontage. */
export function useArtifactImage(project: string, runKey: string, name: string | null) {
  const query = useQuery({
    queryKey: automationKeys.artifact(project, runKey, name ?? ''),
    enabled: !!name,
    staleTime: Infinity,
    queryFn: async () => fetchArtifact(project, runKey, name as string),
  });
  const [url, setUrl] = useState<string | null>(null);
  useEffect(() => {
    if (!query.data) return;
    const objectUrl = URL.createObjectURL(query.data);
    setUrl(objectUrl);
    return () => {
      URL.revokeObjectURL(objectUrl);
      setUrl(null);
    };
  }, [query.data]);
  return { url, isLoading: query.isLoading, error: query.error };
}

/** F-EXE-10 import d'un rapport : aperçu ({@code apply} faux) ou application. */
export function useImportReport(project: string, campaignKey: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async ({ file, format, apply, createUnknown }: { file: File; format: ReportFormat; apply: boolean; createUnknown: boolean }) => {
      const body = new FormData();
      body.append('file', file);
      return unwrap(
        await api.POST('/api/v1/projects/{projectKey}/campaigns/{campaignKey}/imports', {
          params: { path: { projectKey: project, campaignKey }, query: { format, apply, createUnknown } },
          body: body as unknown as { file: string },
          bodySerializer: (value) => value as unknown as FormData,
        }),
      );
    },
    onSuccess: (result) => (result.applied ? invalidate() : undefined),
  });
}

// ---------------------------------------------------------------- temps réel (F-EXE-07)

/**
 * Abonnement Server-Sent Events par fetch (le jeton Bearer passe en en-tête, ce qu'EventSource ne
 * permet pas) : à chaque événement « run », {@code onChange} est appelé ; reconnexion après 3 s.
 */
export function useEventStream(path: string | null, onChange: () => void) {
  const callback = useRef(onChange);
  callback.current = onChange;
  useEffect(() => {
    if (!path) return;
    const controller = new AbortController();
    let retry: number | undefined;
    const connect = async () => {
      try {
        const response = await authorizedFetch(path, { headers: { Accept: 'text/event-stream' }, signal: controller.signal });
        if (!response.ok || !response.body) throw new Error(String(response.status));
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = '';
        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          buffer += decoder.decode(value, { stream: true });
          let index;
          while ((index = buffer.indexOf('\n\n')) >= 0) {
            const block = buffer.slice(0, index);
            buffer = buffer.slice(index + 2);
            if (/^event:\s*run$/m.test(block)) callback.current();
          }
        }
      } catch {
        if (controller.signal.aborted) return;
      }
      if (!controller.signal.aborted) retry = window.setTimeout(connect, 3_000);
    };
    void connect();
    return () => {
      controller.abort();
      window.clearTimeout(retry);
    };
  }, [path]);
}

/** Rafraîchit un run (et sa campagne) à chaque événement temps réel. */
export function useLiveRun(project: string, runKey: string) {
  const client = useQueryClient();
  useEventStream(`/api/v1/projects/${project}/runs/${runKey}/events`, () => {
    void client.invalidateQueries({ queryKey: automationKeys.run(project, runKey) });
    void client.invalidateQueries({ queryKey: campaignKeys.all(project) });
  });
}

/** Rafraîchit les runs et la campagne à chaque événement de ses runs. */
export function useLiveCampaignRuns(project: string, campaignKey: string) {
  const client = useQueryClient();
  useEventStream(`/api/v1/projects/${project}/campaigns/${campaignKey}/run-events`, () => {
    void client.invalidateQueries({ queryKey: automationKeys.campaign(project, campaignKey) });
    void client.invalidateQueries({ queryKey: campaignKeys.detail(project, campaignKey) });
  });
}
