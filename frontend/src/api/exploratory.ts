import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { campaignKeys } from './campaigns';
import { api, type Schemas } from './client';
import { unwrap } from './errors';
import { requirementKeys } from './requirements';
import { testKeys } from './testcases';
import { traceKeys } from './traceability';

/** Hooks TanStack Query des tests exploratoires (§5) : sessions, chartes proposées, heuristiques, métriques. */

export type SessionDetail = Schemas['SessionDetail'];
export type SessionSummary = Schemas['SessionSummary'];
export type SessionNote = Schemas['SessionNoteResponse'];
export type SessionState = SessionDetail['state'];
export type NoteType = SessionNote['type'];
export type CharterProposal = Schemas['CharterProposalResponse'];
export type ExploratoryMetrics = Schemas['ExploratoryMetricsResponse'];

export const exploratoryKeys = {
  all: (project: string) => ['exploratory', project] as const,
  session: (project: string, id: string) => ['exploratory', project, 'session', id] as const,
  sessions: (project: string, states: SessionState[]) => ['exploratory', project, 'sessions', states] as const,
  proposals: (project: string, key: string) => ['exploratory', project, 'proposals', key] as const,
  heuristics: (project: string) => ['exploratory', project, 'heuristics'] as const,
  metrics: (project: string, scope: string) => ['exploratory', project, 'metrics', scope] as const,
};

const path = (project: string, id: string) => ({ params: { path: { projectKey: project, id } } });

/** Une session change aussi la campagne, la couverture, les statuts d'exigences et les anomalies. */
function useInvalidate(project: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: exploratoryKeys.all(project) }),
      client.invalidateQueries({ queryKey: campaignKeys.all(project) }),
      client.invalidateQueries({ queryKey: traceKeys.all(project) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
    ]);
}

/** Met la session renvoyée par une action en cache, puis rafraîchit le reste. */
function useSessionUpdate(project: string, id: string) {
  const client = useQueryClient();
  const invalidate = useInvalidate(project);
  return (session: SessionDetail) => {
    client.setQueryData(exploratoryKeys.session(project, id), session);
    return invalidate();
  };
}

// ---------------------------------------------------------------- sessions

export function useSession(project: string, id: string) {
  return useQuery({
    queryKey: exploratoryKeys.session(project, id),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/sessions/{id}', path(project, id))),
  });
}

export function useSessions(project: string, states: SessionState[]) {
  return useQuery({
    queryKey: exploratoryKeys.sessions(project, states),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/sessions', { params: { path: { projectKey: project }, query: { state: states } } })),
  });
}

/** F-EXP-05 démarrer une session sur une charte de campagne. */
export function useStartSession(project: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (itemId: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/campaign-items/{id}/sessions', path(project, itemId))),
    onSuccess: invalidate,
  });
}

/** F-EXP-05 pause / reprise ; F-EXP-10 sauvegarde du brouillon. */
export function useUpdateSession(project: string, id: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (patch: Schemas['SessionPatchRequest']) =>
      unwrap(
        await api.PATCH('/api/v1/projects/{projectKey}/sessions/{id}', {
          ...path(project, id),
          body: patch,
          headers: { 'Content-Type': 'application/merge-patch+json' },
        }),
      ),
    onSuccess: (session) => client.setQueryData(exploratoryKeys.session(project, id), session),
  });
}

/** F-EXP-06 note horodatée. */
export function useAddNote(project: string, id: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (body: Schemas['SessionNoteRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/notes', { ...path(project, id), body })),
    onSuccess: () => client.invalidateQueries({ queryKey: exploratoryKeys.session(project, id) }),
  });
}

export async function fetchNoteDefectDraft(project: string, id: string, noteId: string) {
  return unwrap(
    await api.GET('/api/v1/projects/{projectKey}/sessions/{id}/notes/{noteId}/defect-draft', {
      params: { path: { projectKey: project, id, noteId } },
    }),
  );
}

/** F-EXP-07 note BUG → anomalie. */
export function useConvertNote(project: string, id: string, noteId: string) {
  const invalidate = useInvalidate(project);
  return useMutation({
    mutationFn: async (body: Schemas['CreateDefectRequest']) =>
      unwrap(
        await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/notes/{noteId}/defects', {
          params: { path: { projectKey: project, id, noteId } },
          body,
        }),
      ),
    onSuccess: invalidate,
  });
}

/** F-EXP-09 fin de session. */
export function useFinishSession(project: string, id: string) {
  const update = useSessionUpdate(project, id);
  return useMutation({
    mutationFn: async (body: Schemas['FinishSessionRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/finish', { ...path(project, id), body })),
    onSuccess: update,
  });
}

/** F-EXP-11 débriefing PROOF. */
export function useDebrief(project: string, id: string) {
  const update = useSessionUpdate(project, id);
  return useMutation({
    mutationFn: async (body: Schemas['DebriefRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/debrief', { ...path(project, id), body })),
    onSuccess: update,
  });
}

/** F-EXP-13 approbation. */
export function useApproveDebrief(project: string, id: string) {
  const update = useSessionUpdate(project, id);
  return useMutation({
    mutationFn: async () => unwrap(await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/debrief/approve', path(project, id))),
    onSuccess: update,
  });
}

/** F-EXP-12 chartes de suivi depuis l'Outlook. */
export function useFollowUpCharters(project: string, id: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (missions: string[]) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/sessions/{id}/follow-up-charters', { ...path(project, id), body: { missions } })),
    onSuccess: () => client.invalidateQueries({ queryKey: testKeys.all(project) }),
  });
}

// ---------------------------------------------------------------- chartes, heuristiques, métriques

/** F-EXP-04 chartes proposées depuis une exigence. */
export function useCharterProposals(project: string, requirementKey: string, enabled: boolean) {
  return useQuery({
    queryKey: exploratoryKeys.proposals(project, requirementKey),
    enabled,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/charter-proposals', {
          params: { path: { projectKey: project, key: requirementKey } },
        }),
      ),
  });
}

/** F-EXP-02 heuristiques suggérées et propres au projet. */
export function useHeuristics(project: string) {
  return useQuery({
    queryKey: exploratoryKeys.heuristics(project),
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/heuristics', { params: { path: { projectKey: project } } })),
  });
}

export function useSetHeuristics(project: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (custom: string[]) =>
      unwrap(await api.PUT('/api/v1/projects/{projectKey}/heuristics', { params: { path: { projectKey: project } }, body: { custom } })),
    onSuccess: (data) => client.setQueryData(exploratoryKeys.heuristics(project), data),
  });
}

/** §5.4 scope : « project », « campaign:CMP-n », « sprint:SPR-n », « release:REL-n ». */
export function useExploratoryMetrics(project: string, scope: string) {
  return useQuery({
    queryKey: exploratoryKeys.metrics(project, scope),
    placeholderData: keepPreviousData,
    queryFn: async () =>
      unwrap(
        await api.GET('/api/v1/projects/{projectKey}/exploratory/metrics', {
          params: { path: { projectKey: project }, query: scope === 'project' ? {} : { scope } },
        }),
      ),
  });
}
