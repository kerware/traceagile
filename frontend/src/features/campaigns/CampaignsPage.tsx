import { Alert, Anchor, Autocomplete, Button, Card, Grid, Group, Loader, Modal, Select, SimpleGrid, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { IconGripVertical, IconPlus } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useCampaignFolders, useCampaigns, useCreateCampaign, type CampaignScope } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { useReleases, useSprints } from '../../api/planning';
import { CampaignStatusBadge, ProgressBar } from './CampaignBadges';
import { CAMPAIGN_DRAG_TYPE, CampaignFolderTree } from './CampaignFolderTree';
import { useCanManageCampaigns } from './permissions';
import { useShortcuts } from '../../components/search/useShortcuts';

/** Dossier sélectionné dans l'arbre : la campagne y est rangée, directement ou dans un sous-dossier. */
function within(folder: string | null | undefined, root: string | null): boolean {
  return root === null || (!!folder && (folder === root || folder.startsWith(`${root}/`)));
}

/** §13.2 /p/:key/campaigns — arbre des dossiers (ADR-0018), liste des campagnes et création (F-CMP-01). */
export function CampaignsPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const { data: all, isLoading } = useCampaigns(project);
  const canManage = useCanManageCampaigns(project);
  const [creating, setCreating] = useState<{ folder: string | null } | null>(null);
  const [folder, setFolder] = useState<string | null>(null);
  // §13.3 N : nouvelle campagne (dans le dossier affiché)
  useShortcuts({ n: () => setCreating({ folder }) }, canManage);
  const data = all?.filter((c) => within(c.folder, folder));

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('campaigns.title')}</Title>
        {canManage && (
          <Button leftSection={<IconPlus size={16} />} onClick={() => setCreating({ folder })} data-testid="campaign-new">
            {t('campaigns.new')}
          </Button>
        )}
      </Group>
      {isLoading && <Loader />}
      <Grid>
        <Grid.Col span={{ base: 12, lg: 3 }}>
          <Card withBorder p="xs">
            <CampaignFolderTree project={project} campaigns={all ?? []} selected={folder} onSelect={setFolder} canManage={canManage}
              onCreateCampaign={(f) => setCreating({ folder: f })} />
          </Card>
        </Grid.Col>
        <Grid.Col span={{ base: 12, lg: 9 }}>
      {folder && (
        <Text size="sm" c="dimmed" mb="xs" data-testid="campaign-folder-current">
          {t('campaignFolders.current', { path: folder })}
        </Text>
      )}
      {data && data.length === 0 && <Text c="dimmed">{folder ? t('campaignFolders.emptyFolder') : t('campaigns.empty')}</Text>}
      {data && data.length > 0 && (
        <Table striped highlightOnHover data-testid="campaign-list">
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('campaigns.key')}</Table.Th>
              <Table.Th>{t('campaigns.name')}</Table.Th>
              <Table.Th>{t('campaigns.scope')}</Table.Th>
              <Table.Th>{t('campaigns.target')}</Table.Th>
              <Table.Th>{t('campaigns.status')}</Table.Th>
              <Table.Th w={260}>{t('campaigns.progress')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {data.map((c) => (
              <Table.Tr key={c.key} data-testid={`campaign-row-${c.key}`} draggable={canManage}
                onDragStart={(e) => {
                  e.dataTransfer.setData(CAMPAIGN_DRAG_TYPE, c.key);
                  e.dataTransfer.effectAllowed = 'move';
                }}
                style={canManage ? { cursor: 'grab' } : undefined}>
                <Table.Td>
                  <Group gap={4} wrap="nowrap">
                    {canManage && <IconGripVertical size={14} color="var(--mantine-color-dimmed)" />}
                    <Anchor component={Link} to={`/p/${project}/campaigns/${c.key}`} ff="monospace" fw={600}>
                      {c.key}
                    </Anchor>
                  </Group>
                </Table.Td>
                <Table.Td>
                  {c.name}
                  {c.folder && c.folder !== folder && (
                    <Text size="xs" c="dimmed">
                      {c.folder}
                    </Text>
                  )}
                </Table.Td>
                <Table.Td>
                  {t(`campaignScope.${c.scopeType}`)}
                  {c.sprintKey ? ` ${c.sprintKey}` : c.releaseKey ? ` ${c.releaseKey}` : ''}
                </Table.Td>
                <Table.Td>
                  <Text size="sm">{[c.environment, c.buildVersion].filter(Boolean).join(' · ') || '—'}</Text>
                </Table.Td>
                <Table.Td>
                  <CampaignStatusBadge status={c.status} />
                </Table.Td>
                <Table.Td>
                  <ProgressBar progress={c.progress} />
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
        </Grid.Col>
      </Grid>
      <CreateCampaignModal project={project} opened={creating !== null} folder={creating?.folder ?? null} onClose={() => setCreating(null)} />
    </Stack>
  );
}

/** F-CMP-01 campagne de sprint, de release ou de régression, environnement et build. */
function CreateCampaignModal({ project, opened, folder, onClose }: { project: string; opened: boolean; folder: string | null; onClose: () => void }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const create = useCreateCampaign(project);
  const { data: sprints } = useSprints(project);
  const { data: releases } = useReleases(project);
  const { data: folders } = useCampaignFolders(project);
  const [form, setForm] = useState({ name: '', scopeType: 'SPRINT' as CampaignScope, target: null as string | null, environment: 'recette', buildVersion: '', folder: '' });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      const active = sprints?.find((s) => s.status === 'ACTIVE');
      setForm({ name: active ? t('campaigns.defaultName', { sprint: active.key }) : '', scopeType: 'SPRINT', target: active?.key ?? null, environment: 'recette', buildVersion: '', folder: folder ?? '' });
      setError(null);
    }
  }, [opened, sprints, t, folder]);

  const submit = async () => {
    setError(null);
    try {
      const created = await create.mutateAsync({
        name: form.name.trim(),
        scopeType: form.scopeType,
        sprintKey: form.scopeType === 'SPRINT' ? form.target ?? undefined : undefined,
        releaseKey: form.scopeType === 'RELEASE' ? form.target ?? undefined : undefined,
        environment: form.environment.trim() || undefined,
        buildVersion: form.buildVersion.trim() || undefined,
        folder: form.folder.trim() || undefined,
      });
      onClose();
      navigate(`/p/${project}/campaigns/${created.campaign.key}`);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  const targets =
    form.scopeType === 'SPRINT'
      ? (sprints ?? []).filter((s) => s.status !== 'CLOSED').map((s) => ({ value: s.key, label: `${s.key} — ${s.name}` }))
      : (releases ?? []).filter((r) => r.status !== 'CLOSED').map((r) => ({ value: r.key, label: `${r.key} — ${r.name}` }));

  return (
    <Modal opened={opened} onClose={onClose} title={t('campaigns.new')} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <TextInput label={t('campaigns.name')} required value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} data-testid="campaign-name" />
        <SimpleGrid cols={2}>
          <Select
            label={t('campaigns.scope')}
            data={(['SPRINT', 'RELEASE', 'REGRESSION'] as CampaignScope[]).map((s) => ({ value: s, label: t(`campaignScope.${s}`) }))}
            value={form.scopeType}
            onChange={(scopeType) => scopeType && setForm({ ...form, scopeType: scopeType as CampaignScope, target: null })}
            allowDeselect={false}
            data-testid="campaign-scope"
          />
          {form.scopeType !== 'REGRESSION' && (
            <Select label={form.scopeType === 'SPRINT' ? t('planning.sprint') : t('planning.release')} data={targets} value={form.target}
              onChange={(target) => setForm({ ...form, target })} required data-testid="campaign-target" />
          )}
          <TextInput label={t('campaigns.environment')} value={form.environment} onChange={(e) => setForm({ ...form, environment: e.currentTarget.value })} data-testid="campaign-environment" />
          <TextInput label={t('campaigns.build')} value={form.buildVersion} onChange={(e) => setForm({ ...form, buildVersion: e.currentTarget.value })} data-testid="campaign-build" />
        </SimpleGrid>
        <Autocomplete label={t('campaignFolders.folder')} description={t('campaignFolders.folderHint')} data={folders ?? []} value={form.folder}
          onChange={(value) => setForm({ ...form, folder: value })} data-testid="campaign-folder" />
        <Card withBorder p="xs">
          <Text size="xs" c="dimmed">
            {t('campaigns.createHint')}
          </Text>
        </Card>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={create.isPending} disabled={!form.name.trim() || (form.scopeType !== 'REGRESSION' && !form.target)} data-testid="campaign-submit">
            {t('planning.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
