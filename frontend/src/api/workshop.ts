import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, authorizedFetch, type Schemas } from './client';
import { ApiError, unwrap, type Problem } from './errors';
import { requirementKeys } from './requirements';

/**
 * Hooks du lot 9 (ADR-0024) : commentaires et atelier Example Mapping (§4.4), valeurs mesurées des ENF
 * (F-REQ-18), pièces jointes, recherche globale, aperçu des clés, notifications.
 */

export type Comment = Schemas['CommentResponse'];
export type ExampleMap = Schemas['ExampleMapResponse'];
export type ExampleCard = Schemas['ExampleCardResponse'];
export type Measurement = Schemas['NfrMeasurementResponse'];
export type Attachment = Schemas['AttachmentResponse'];
export type AttachmentTarget = Attachment['targetType'];
export type SearchHit = Schemas['SearchHit'];
export type ItemType = SearchHit['type'];
export type Notifications = Schemas['NotificationsResponse'];

export const workshopKeys = {
  comments: (project: string, key: string) => ['workshop', project, 'comments', key] as const,
  map: (project: string, key: string) => ['workshop', project, 'map', key] as const,
  measurements: (project: string, key: string) => ['workshop', project, 'measurements', key] as const,
  attachments: (project: string, target: string, ids: string[]) => ['attachments', project, target, ...ids] as const,
  search: (project: string, q: string) => ['search', project, q] as const,
  item: (project: string, key: string) => ['search', project, 'item', key] as const,
  notifications: (project: string) => ['notifications', project] as const,
};

// ---------------------------------------------------------------- commentaires et atelier

function useWorkshopInvalidate(project: string, key: string) {
  const client = useQueryClient();
  return () =>
    Promise.all([
      client.invalidateQueries({ queryKey: workshopKeys.comments(project, key) }),
      client.invalidateQueries({ queryKey: workshopKeys.map(project, key) }),
      client.invalidateQueries({ queryKey: requirementKeys.all(project) }),
    ]);
}

export function useComments(project: string, key: string) {
  return useQuery({
    queryKey: workshopKeys.comments(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/comments', { params: { path: { projectKey: project, key } } })),
  });
}

export function useAddComment(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async (body: Schemas['CommentRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/comments', { params: { path: { projectKey: project, key } }, body })),
    onSuccess: invalidate,
  });
}

export function useEditComment(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async ({ id, text }: { id: string; text: string }) =>
      unwrap(await api.PUT('/api/v1/projects/{projectKey}/comments/{id}', { params: { path: { projectKey: project, id } }, body: { text } })),
    onSuccess: invalidate,
  });
}

export function useDeleteComment(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/comments/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) unwrap(result as never);
    },
    onSuccess: invalidate,
  });
}

/** F-REQ-14 / F-REQ-15 résoudre une question (ou la rouvrir). */
export function useResolveComment(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async ({ id, resolved }: { id: string; resolved: boolean }) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/comments/{id}/resolve', { params: { path: { projectKey: project, id } }, body: { resolved } })),
    onSuccess: invalidate,
  });
}

/** F-REQ-13 les quatre colonnes de l'atelier. */
export function useExampleMap(project: string, key: string) {
  return useQuery({
    queryKey: workshopKeys.map(project, key),
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/example-map', { params: { path: { projectKey: project, key } } })),
  });
}

export function useAddCard(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async (body: Schemas['ExampleCardRequest']) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/example-cards', { params: { path: { projectKey: project, key } }, body })),
    onSuccess: invalidate,
  });
}

export function useEditCard(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async ({ id, text }: { id: string; text: string }) =>
      unwrap(await api.PUT('/api/v1/projects/{projectKey}/example-cards/{id}', { params: { path: { projectKey: project, id } }, body: { text } })),
    onSuccess: invalidate,
  });
}

export function useDeleteCard(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/example-cards/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) unwrap(result as never);
    },
    onSuccess: invalidate,
  });
}

/** F-REQ-14 règle → règle métier enfant ; exemple → critère Gherkin. */
export function useConvertCard(project: string, key: string) {
  const invalidate = useWorkshopInvalidate(project, key);
  return useMutation({
    mutationFn: async (id: string) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/example-cards/{id}/convert', { params: { path: { projectKey: project, id } } })),
    onSuccess: invalidate,
  });
}

// ---------------------------------------------------------------- mesures des ENF (F-REQ-18)

export function useMeasurements(project: string, key: string, enabled = true) {
  return useQuery({
    queryKey: workshopKeys.measurements(project, key),
    enabled,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/requirements/{key}/measurements', { params: { path: { projectKey: project, key } } })),
  });
}

export function useRecordMeasurement(project: string, key: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (value: number) =>
      unwrap(await api.POST('/api/v1/projects/{projectKey}/requirements/{key}/measurements', { params: { path: { projectKey: project, key } }, body: { value } })),
    onSuccess: () => client.invalidateQueries({ queryKey: workshopKeys.measurements(project, key) }),
  });
}

// ---------------------------------------------------------------- pièces jointes

export function useAttachments(project: string, target: AttachmentTarget, ids: string[]) {
  return useQuery({
    queryKey: workshopKeys.attachments(project, target, ids),
    enabled: ids.length > 0,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/attachments', { params: { path: { projectKey: project }, query: { targetType: target, targetIds: ids } } })),
  });
}

/** Téléversement (fichier choisi ou image collée). */
export function useUploadAttachment(project: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({ target, targetId, file }: { target: AttachmentTarget; targetId: string; file: File }) => {
      const body = new FormData();
      body.append('file', file);
      return unwrap(
        await api.POST('/api/v1/projects/{projectKey}/attachments', {
          params: { path: { projectKey: project }, query: { targetType: target, targetId } },
          body: body as unknown as { file: string },
          bodySerializer: (value) => value as unknown as FormData,
        }),
      );
    },
    onSuccess: () => client.invalidateQueries({ queryKey: ['attachments', project] }),
  });
}

export function useDeleteAttachment(project: string) {
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const result = await api.DELETE('/api/v1/projects/{projectKey}/attachments/{id}', { params: { path: { projectKey: project, id } } });
      if (!result.response.ok) unwrap(result as never);
    },
    onSuccess: () => client.invalidateQueries({ queryKey: ['attachments', project] }),
  });
}

/** Contenu d'une pièce jointe (jeton Bearer en en-tête) : URL d'objet à libérer par l'appelant. */
export async function attachmentUrl(project: string, id: string): Promise<string> {
  const response = await authorizedFetch(`/api/v1/projects/${project}/attachments/${id}/content`);
  if (!response.ok) {
    let problem: unknown = undefined;
    try {
      problem = await response.json();
    } catch {
      // corps vide
    }
    throw new ApiError(response.status, problem as Problem | undefined);
  }
  return URL.createObjectURL(await response.blob());
}

// ---------------------------------------------------------------- recherche, aperçu, notifications

export function useSearch(project: string | null, q: string) {
  return useQuery({
    queryKey: workshopKeys.search(project ?? '', q),
    enabled: !!project && q.trim().length >= 2,
    staleTime: 10_000,
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/search', { params: { path: { projectKey: project ?? '' }, query: { q } } })),
  });
}

export function useItemPreview(project: string, key: string, enabled: boolean) {
  return useQuery({
    queryKey: workshopKeys.item(project, key),
    enabled,
    staleTime: 60_000,
    retry: false,
    queryFn: async () =>
      unwrap(await api.GET('/api/v1/projects/{projectKey}/items/{itemKey}', { params: { path: { projectKey: project, itemKey: key } } })),
  });
}

export function useNotifications(project: string | null) {
  return useQuery({
    queryKey: workshopKeys.notifications(project ?? ''),
    enabled: !!project,
    refetchInterval: 60_000,
    queryFn: async () => unwrap(await api.GET('/api/v1/projects/{projectKey}/notifications', { params: { path: { projectKey: project ?? '' } } })),
  });
}
