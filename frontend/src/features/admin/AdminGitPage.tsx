import { ActionIcon, Anchor, Badge, Button, Card, Code, Group, Loader, Modal, PasswordInput, SegmentedControl, Stack, Table, Text, Textarea, TextInput, Title, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconBrandGit, IconEdit, IconPlus, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import {
  useAddGitProject,
  useCreateGitSource,
  useDeleteGitProject,
  useDeleteGitSource,
  useGitSources,
  useUpdateGitSource,
  type GitAuthType,
  type GitSource,
} from '../../api/git';
import { AdminTabs } from './AdminTabs';

interface SourceForm {
  name: string;
  baseUrl: string;
  description: string;
  authType: GitAuthType;
  username: string;
  secret: string;
}

const EMPTY: SourceForm = { name: '', baseUrl: '', description: '', authType: 'NONE', username: '', secret: '' };

/**
 * ADR-0030 /admin/git — dépôts Git déclarés pour toute l'instance (compte ou organisation, public ou
 * authentifié par jeton ou clé SSH) et leurs projets, proposés dans les fiches de tests automatisés.
 * Le secret n'est jamais réaffiché : on le remplace en en saisissant un nouveau.
 */
export function AdminGitPage() {
  const { t } = useTranslation();
  const { data, isLoading } = useGitSources();
  const create = useCreateGitSource();
  const [form, setForm] = useState<SourceForm>(EMPTY);
  const [editing, setEditing] = useState<GitSource | null>(null);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  return (
    <Stack>
      <AdminTabs value="git" />
      <Text size="sm" c="dimmed" maw={760}>
        {t('git.intro')}
      </Text>
      {isLoading && <Loader />}
      <Stack data-testid="git-sources">
        {(data ?? []).map((source) => (
          <SourceCard key={source.id} source={source} onEdit={() => setEditing(source)} />
        ))}
        {data && data.length === 0 && <Text c="dimmed">{t('git.none')}</Text>}
      </Stack>
      <Card withBorder>
        <Title order={5} mb="xs">
          {t('git.addSource')}
        </Title>
        <SourceFields form={form} onChange={setForm} creating />
        <Group mt="sm">
          <Button leftSection={<IconPlus size={16} />} disabled={!form.name.trim() || !form.baseUrl.trim()} loading={create.isPending}
            onClick={() => create.mutate(payload(form), { onSuccess: () => setForm(EMPTY), onError: fail })} data-testid="git-source-create">
            {t('git.create')}
          </Button>
        </Group>
      </Card>
      {editing && <EditModal source={editing} onClose={() => setEditing(null)} />}
    </Stack>
  );
}

function payload(form: SourceForm) {
  return {
    name: form.name.trim(),
    baseUrl: form.baseUrl.trim(),
    description: form.description.trim() || undefined,
    authType: form.authType,
    username: form.authType === 'TOKEN' ? form.username.trim() || undefined : undefined,
    secret: form.authType === 'NONE' ? undefined : form.secret || undefined,
  };
}

function SourceFields({ form, onChange, creating, hasSecret }: { form: SourceForm; onChange: (form: SourceForm) => void; creating?: boolean; hasSecret?: boolean }) {
  const { t } = useTranslation();
  const set = (patch: Partial<SourceForm>) => onChange({ ...form, ...patch });
  const secretHint = hasSecret ? t('git.secretKept') : undefined;
  return (
    <Stack gap="xs">
      <Group align="flex-start" grow>
        <TextInput label={t('git.name')} placeholder="kerware" value={form.name} onChange={(e) => set({ name: e.currentTarget.value })}
          required={creating} data-testid="git-source-name" />
        <TextInput label={t('git.baseUrl')} description={t('git.baseUrlHint')} placeholder="https://github.com/kerware" value={form.baseUrl}
          onChange={(e) => set({ baseUrl: e.currentTarget.value })} required={creating} data-testid="git-source-url" />
      </Group>
      <TextInput label={t('git.description')} value={form.description} onChange={(e) => set({ description: e.currentTarget.value })} data-testid="git-source-description" />
      <Stack gap={4}>
        <Text size="sm" fw={500}>
          {t('git.auth')}
        </Text>
        <SegmentedControl
          value={form.authType}
          onChange={(value) => set({ authType: value as GitAuthType, secret: '' })}
          data={[
            { value: 'NONE', label: t('git.authType.NONE') },
            { value: 'TOKEN', label: t('git.authType.TOKEN') },
            { value: 'SSH_KEY', label: t('git.authType.SSH_KEY') },
          ]}
          data-testid="git-source-auth"
        />
      </Stack>
      {form.authType === 'TOKEN' && (
        <Group align="flex-start" grow>
          <TextInput label={t('git.username')} description={t('git.usernameHint')} placeholder="x-access-token" value={form.username}
            onChange={(e) => set({ username: e.currentTarget.value })} data-testid="git-source-username" />
          <PasswordInput label={t('git.token')} description={secretHint ?? t('git.tokenHint')} value={form.secret}
            onChange={(e) => set({ secret: e.currentTarget.value })} autoComplete="new-password" data-testid="git-source-secret" />
        </Group>
      )}
      {form.authType === 'SSH_KEY' && (
        <Textarea label={t('git.sshKey')} description={secretHint ?? t('git.sshKeyHint')} placeholder="-----BEGIN OPENSSH PRIVATE KEY-----" autosize minRows={3} maxRows={8}
          value={form.secret} onChange={(e) => set({ secret: e.currentTarget.value })} styles={{ input: { fontFamily: 'monospace', fontSize: 12 } }}
          data-testid="git-source-secret" />
      )}
    </Stack>
  );
}

function AuthBadge({ source }: { source: GitSource }) {
  const { t } = useTranslation();
  const colors: Record<GitAuthType, string> = { NONE: 'gray', TOKEN: 'blue', SSH_KEY: 'grape' };
  return (
    <Badge variant="light" color={colors[source.authType]} data-testid={`git-auth-${source.name}`}>
      {source.authType === 'TOKEN' && source.username ? `${t(`git.authType.${source.authType}`)} · ${source.username}` : t(`git.authType.${source.authType}`)}
    </Badge>
  );
}

function SourceCard({ source, onEdit }: { source: GitSource; onEdit: () => void }) {
  const { t } = useTranslation();
  const remove = useDeleteGitSource();
  const addProject = useAddGitProject();
  const removeProject = useDeleteGitProject();
  const [project, setProject] = useState({ name: '', defaultBranch: '' });
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const web = source.baseUrl.startsWith('http');

  return (
    <Card withBorder data-testid={`git-source-${source.name}`}>
      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Stack gap={2}>
          <Group gap="xs">
            <IconBrandGit size={18} />
            <Title order={4}>{source.name}</Title>
            <AuthBadge source={source} />
          </Group>
          {web ? (
            <Anchor href={source.baseUrl} target="_blank" size="sm" ff="monospace">
              {source.baseUrl}
            </Anchor>
          ) : (
            <Text size="sm" ff="monospace">
              {source.baseUrl}
            </Text>
          )}
          {source.description && (
            <Text size="sm" c="dimmed">
              {source.description}
            </Text>
          )}
        </Stack>
        <Group gap={4} wrap="nowrap">
          <Tooltip label={t('common.edit')}>
            <ActionIcon variant="subtle" onClick={onEdit} aria-label={t('common.edit')} data-testid={`git-source-edit-${source.name}`}>
              <IconEdit size={16} />
            </ActionIcon>
          </Tooltip>
          <Tooltip label={t('common.delete')}>
            <ActionIcon variant="subtle" color="red" onClick={() => remove.mutate(source.id, { onError: fail })} aria-label={t('common.delete')}
              data-testid={`git-source-delete-${source.name}`}>
              <IconTrash size={16} />
            </ActionIcon>
          </Tooltip>
        </Group>
      </Group>
      <Table mt="sm" withTableBorder data-testid={`git-projects-${source.name}`}>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t('git.project')}</Table.Th>
            <Table.Th w={160}>{t('git.defaultBranch')}</Table.Th>
            <Table.Th>{t('git.cloneUrl')}</Table.Th>
            <Table.Th w={40} />
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {source.projects.length === 0 && (
            <Table.Tr>
              <Table.Td colSpan={4}>
                <Text size="sm" c="dimmed">
                  {t('git.noProject')}
                </Text>
              </Table.Td>
            </Table.Tr>
          )}
          {source.projects.map((p) => (
            <Table.Tr key={p.id} data-testid={`git-project-${p.label}`}>
              <Table.Td>
                {p.webUrl ? (
                  <Anchor href={p.webUrl} target="_blank" fw={600}>
                    {p.name}
                  </Anchor>
                ) : (
                  <Text fw={600}>{p.name}</Text>
                )}
              </Table.Td>
              <Table.Td>{p.defaultBranch ?? '—'}</Table.Td>
              <Table.Td>
                <Code>{p.cloneUrl}</Code>
              </Table.Td>
              <Table.Td>
                <ActionIcon variant="subtle" color="red" onClick={() => removeProject.mutate(p.id, { onError: fail })} aria-label={t('common.delete')}
                  data-testid={`git-project-delete-${p.label}`}>
                  <IconTrash size={14} />
                </ActionIcon>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
      <Group mt="xs" align="flex-end">
        <TextInput size="xs" label={t('git.projectName')} placeholder="saucedemo-e2e" value={project.name}
          onChange={(e) => setProject({ ...project, name: e.currentTarget.value })} data-testid={`git-project-name-${source.name}`} />
        <TextInput size="xs" label={t('git.defaultBranch')} placeholder="main" value={project.defaultBranch}
          onChange={(e) => setProject({ ...project, defaultBranch: e.currentTarget.value })} data-testid={`git-project-branch-${source.name}`} />
        <Button size="xs" variant="light" leftSection={<IconPlus size={14} />} disabled={!project.name.trim()} loading={addProject.isPending}
          onClick={() => addProject.mutate({ sourceId: source.id, name: project.name.trim(), defaultBranch: project.defaultBranch.trim() || undefined },
            { onSuccess: () => setProject({ name: '', defaultBranch: '' }), onError: fail })}
          data-testid={`git-project-add-${source.name}`}>
          {t('git.addProject')}
        </Button>
      </Group>
    </Card>
  );
}

function EditModal({ source, onClose }: { source: GitSource; onClose: () => void }) {
  const { t } = useTranslation();
  const update = useUpdateGitSource();
  const [form, setForm] = useState<SourceForm>({
    name: source.name, baseUrl: source.baseUrl, description: source.description ?? '', authType: source.authType, username: source.username ?? '', secret: '',
  });
  const keepsSecret = source.hasSecret && form.authType === source.authType;
  const save = () =>
    update.mutate({ id: source.id, ...payload(form) }, {
      onSuccess: () => {
        notifications.show({ color: 'green', message: t('git.saved', { name: form.name }) });
        onClose();
      },
      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
    });
  return (
    <Modal opened onClose={onClose} title={t('git.editSource', { name: source.name })} size="lg">
      <SourceFields form={form} onChange={setForm} hasSecret={keepsSecret} />
      <Group justify="flex-end" mt="md">
        <Button variant="default" onClick={onClose}>
          {t('common.cancel')}
        </Button>
        <Button onClick={save} loading={update.isPending} data-testid="git-source-save">
          {t('common.save')}
        </Button>
      </Group>
    </Modal>
  );
}
