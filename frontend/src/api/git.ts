import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, type Schemas } from './client';
import { unwrap } from './errors';

/** ADR-0030 dépôts Git déclarés (Administration › Dépôts Git) et leurs projets, choisis dans les fiches de tests. */

export type GitSource = Schemas['GitSourceResponse'];
export type GitProject = Schemas['GitProjectResponse'];
export type GitAuthType = GitSource['authType'];
export type GitSourceInput = Schemas['GitSourceRequest'];
export type GitProjectInput = Schemas['GitProjectRequest'];

const gitKeys = { sources: ['git-sources'] as const };

export function useGitSources() {
  return useQuery({ queryKey: gitKeys.sources, queryFn: async () => unwrap(await api.GET('/api/v1/git-sources')) });
}

function useGitMutation<T>(fn: (input: T) => Promise<unknown>) {
  const client = useQueryClient();
  return useMutation({ mutationFn: fn, onSuccess: () => client.invalidateQueries({ queryKey: gitKeys.sources }) });
}

async function noContent(result: { response: Response }) {
  if (!result.response.ok) unwrap(result as never);
}

export function useCreateGitSource() {
  return useGitMutation(async (body: GitSourceInput) => unwrap(await api.POST('/api/v1/git-sources', { body })));
}

export function useUpdateGitSource() {
  return useGitMutation(async ({ id, ...body }: GitSourceInput & { id: string }) =>
    unwrap(await api.PATCH('/api/v1/git-sources/{id}', { params: { path: { id } }, body })),
  );
}

export function useDeleteGitSource() {
  return useGitMutation(async (id: string) => noContent(await api.DELETE('/api/v1/git-sources/{id}', { params: { path: { id } } })));
}

export function useAddGitProject() {
  return useGitMutation(async ({ sourceId, ...body }: GitProjectInput & { sourceId: string }) =>
    unwrap(await api.POST('/api/v1/git-sources/{id}/projects', { params: { path: { id: sourceId } }, body })),
  );
}

export function useUpdateGitProject() {
  return useGitMutation(async ({ id, ...body }: GitProjectInput & { id: string }) =>
    unwrap(await api.PATCH('/api/v1/git-projects/{id}', { params: { path: { id } }, body })),
  );
}

export function useDeleteGitProject() {
  return useGitMutation(async (id: string) => noContent(await api.DELETE('/api/v1/git-projects/{id}', { params: { path: { id } } })));
}
