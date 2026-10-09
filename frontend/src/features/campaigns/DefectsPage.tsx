import { Alert, Anchor, Button, Drawer, Group, Loader, Modal, MultiSelect, Select, Stack, Table, Text, Textarea, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlus, IconSearch } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { useCreateDefect, useDefect, useDefects, useUpdateDefect, type DefectDetail, type DefectSeverity, type DefectStatus } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { useRequirementTree } from '../../api/requirements';
import { flatten } from '../requirements/model';
import { DefectStatusBadge, ExecutionStatusBadge, SeverityBadge } from './CampaignBadges';
import { DEFECT_STATUSES, SEVERITIES } from './model';
import { useCanExecute, useCanUpdateDefects } from './permissions';

/** §13.2 /p/:key/defects — anomalies (F-DEF-01, F-DEF-02) : liste filtrée, fiche, cycle de vie. */
export function DefectsPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const status = params.getAll('status') as DefectStatus[];
  const severity = params.getAll('severity') as DefectSeverity[];
  const [q, setQ] = useState(params.get('q') ?? '');
  const { data, isLoading } = useDefects(project, { status, severity, q: params.get('q') ?? undefined });
  const canCreate = useCanExecute(project);
  const [creating, setCreating] = useState(false);
  const selected = params.get('selected');

  const update = (changes: Record<string, string | string[] | null>) => {
    const next = new URLSearchParams(params);
    Object.entries(changes).forEach(([name, value]) => {
      next.delete(name);
      if (Array.isArray(value)) value.forEach((v) => next.append(name, v));
      else if (value) next.set(name, value);
    });
    setParams(next, { replace: true });
  };

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('defects.title')}</Title>
        {canCreate && (
          <Button leftSection={<IconPlus size={16} />} onClick={() => setCreating(true)} data-testid="defect-new">
            {t('defects.new')}
          </Button>
        )}
      </Group>
      <Group align="flex-end">
        <TextInput leftSection={<IconSearch size={14} />} placeholder={t('defects.search')} value={q} onChange={(e) => setQ(e.currentTarget.value)}
          onKeyDown={(e) => e.key === 'Enter' && update({ q: q || null })} data-testid="defect-search" />
        <MultiSelect placeholder={t('defects.status')} data={DEFECT_STATUSES.map((s) => ({ value: s, label: t(`defectStatus.${s}`) }))} value={status}
          onChange={(v) => update({ status: v })} clearable w={260} data-testid="defect-filter-status" />
        <MultiSelect placeholder={t('defects.severity')} data={SEVERITIES.map((s) => ({ value: s, label: t(`severity.${s}`) }))} value={severity}
          onChange={(v) => update({ severity: v })} clearable w={260} data-testid="defect-filter-severity" />
      </Group>
      {isLoading && <Loader />}
      {data && data.length === 0 && <Text c="dimmed">{t('defects.empty')}</Text>}
      {data && data.length > 0 && (
        <Table striped highlightOnHover data-testid="defect-list">
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('campaigns.key')}</Table.Th>
              <Table.Th>{t('defects.title')}</Table.Th>
              <Table.Th>{t('defects.severity')}</Table.Th>
              <Table.Th>{t('defects.status')}</Table.Th>
              <Table.Th>{t('defects.requirements')}</Table.Th>
              <Table.Th>{t('defects.externalRef')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {data.map((d) => (
              <Table.Tr key={d.key} onClick={() => update({ selected: d.key })} style={{ cursor: 'pointer' }} data-testid={`defect-row-${d.key}`}>
                <Table.Td ff="monospace" fw={600}>
                  {d.key}
                </Table.Td>
                <Table.Td>{d.title}</Table.Td>
                <Table.Td>
                  <SeverityBadge severity={d.severity} />
                </Table.Td>
                <Table.Td>
                  <DefectStatusBadge status={d.status} />
                </Table.Td>
                <Table.Td>
                  <Text size="sm" ff="monospace">
                    {d.requirementKeys.join(', ') || '—'}
                  </Text>
                </Table.Td>
                <Table.Td>{d.externalRef ?? '—'}</Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
      <Drawer opened={!!selected} onClose={() => update({ selected: null })} position="right" size="xl" title={selected}>
        {selected && <DefectPanel project={project} defectKey={selected} />}
      </Drawer>
      <CreateDefectModal project={project} opened={creating} onClose={() => setCreating(false)} onCreated={(key) => update({ selected: key })} />
    </Stack>
  );
}

function DefectPanel({ project, defectKey }: { project: string; defectKey: string }) {
  const { data } = useDefect(project, defectKey);
  if (!data) return <Loader />;
  return <DefectEditor key={`${data.defect.key}-${data.defect.version}`} project={project} detail={data} />;
}

/** Fiche : champs, transitions de statut autorisées (F-DEF-01), exigences, exécutions liées. */
function DefectEditor({ project, detail }: { project: string; detail: DefectDetail }) {
  const { t } = useTranslation();
  const canUpdate = useCanUpdateDefects(project);
  const update = useUpdateDefect(project);
  const { data: tree } = useRequirementTree(project);
  const d = detail.defect;
  const [form, setForm] = useState({
    title: d.title,
    description: detail.description ?? '',
    severity: d.severity,
    status: d.status,
    externalRef: d.externalRef ?? '',
    requirementKeys: d.requirementKeys,
  });

  const save = () => {
    const patch: Record<string, unknown> = {};
    if (form.title !== d.title) patch.title = form.title;
    if (form.description !== (detail.description ?? '')) patch.description = form.description || null;
    if (form.severity !== d.severity) patch.severity = form.severity;
    if (form.status !== d.status) patch.status = form.status;
    if (form.externalRef !== (d.externalRef ?? '')) patch.externalRef = form.externalRef.trim() || null;
    if (JSON.stringify(form.requirementKeys) !== JSON.stringify(d.requirementKeys)) patch.requirementKeys = form.requirementKeys;
    update.mutate(
      { key: d.key, patch },
      {
        onSuccess: () => notifications.show({ color: 'green', message: t('defects.saved', { key: d.key }) }),
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );
  };

  return (
    <Stack data-testid="defect-panel">
      <Group gap="xs">
        <SeverityBadge severity={d.severity} />
        <DefectStatusBadge status={d.status} />
        <Text size="xs" c="dimmed">
          {t('defects.createdBy', { by: d.createdBy ?? '—', date: new Date(d.createdAt).toLocaleString() })}
        </Text>
      </Group>
      <TextInput label={t('defects.title')} value={form.title} onChange={(e) => setForm({ ...form, title: e.currentTarget.value })} disabled={!canUpdate} data-testid="edit-title" />
      <Group grow>
        <Select label={t('defects.severity')} data={SEVERITIES.map((s) => ({ value: s, label: t(`severity.${s}`) }))} value={form.severity}
          onChange={(v) => v && setForm({ ...form, severity: v as DefectSeverity })} allowDeselect={false} disabled={!canUpdate} />
        <Select label={t('defects.status')} data={[d.status, ...detail.allowedTransitions].map((s) => ({ value: s, label: t(`defectStatus.${s}`) }))}
          value={form.status} onChange={(v) => v && setForm({ ...form, status: v as DefectStatus })} allowDeselect={false} disabled={!canUpdate} data-testid="edit-status" />
        <TextInput label={t('defects.externalRef')} description={t('defects.externalRefHint')} value={form.externalRef}
          onChange={(e) => setForm({ ...form, externalRef: e.currentTarget.value })} disabled={!canUpdate} data-testid="edit-external-ref" />
      </Group>
      <MultiSelect label={t('defects.requirements')} data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
        value={form.requirementKeys} onChange={(requirementKeys) => setForm({ ...form, requirementKeys })} searchable disabled={!canUpdate} />
      <Textarea label={t('defects.description')} autosize minRows={6} maxRows={20} value={form.description}
        onChange={(e) => setForm({ ...form, description: e.currentTarget.value })} disabled={!canUpdate} />
      {canUpdate && (
        <Group justify="flex-end">
          <Button onClick={save} loading={update.isPending} data-testid="defect-save">
            {t('test.save')}
          </Button>
        </Group>
      )}
      <Title order={6}>{t('defects.executions')}</Title>
      {detail.executions.length === 0 && (
        <Text size="sm" c="dimmed">
          —
        </Text>
      )}
      {detail.executions.map((e) => (
        <Group key={e.id} gap={6}>
          <Anchor component={Link} to={`/p/${project}/executions/${e.id}`} size="sm">
            {e.testKey} · {e.campaignKey} · {t('executions.attempt', { n: e.attempt })}
          </Anchor>
          <ExecutionStatusBadge status={e.status} />
        </Group>
      ))}
    </Stack>
  );
}

function CreateDefectModal({ project, opened, onClose, onCreated }: { project: string; opened: boolean; onClose: () => void; onCreated: (key: string) => void }) {
  const { t } = useTranslation();
  const create = useCreateDefect(project);
  const { data: tree } = useRequirementTree(project);
  const [form, setForm] = useState({ title: '', description: '', severity: 'MAJOR' as DefectSeverity, requirementKeys: [] as string[] });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setForm({ title: '', description: '', severity: 'MAJOR', requirementKeys: [] });
      setError(null);
    }
  }, [opened]);

  const submit = async () => {
    try {
      const created = await create.mutateAsync({ ...form, description: form.description || undefined });
      onClose();
      onCreated(created.defect.key);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('defects.new')} size="lg">
      <Stack>
        {error && <Alert color="red">{error}</Alert>}
        <TextInput label={t('defects.title')} required value={form.title} onChange={(e) => setForm({ ...form, title: e.currentTarget.value })} data-testid="new-defect-title" />
        <Group grow>
          <Select label={t('defects.severity')} data={SEVERITIES.map((s) => ({ value: s, label: t(`severity.${s}`) }))} value={form.severity}
            onChange={(v) => v && setForm({ ...form, severity: v as DefectSeverity })} allowDeselect={false} />
          <MultiSelect label={t('defects.requirements')} data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
            value={form.requirementKeys} onChange={(requirementKeys) => setForm({ ...form, requirementKeys })} searchable />
        </Group>
        <Textarea label={t('defects.description')} autosize minRows={4} value={form.description} onChange={(e) => setForm({ ...form, description: e.currentTarget.value })} />
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={create.isPending} disabled={!form.title.trim()} data-testid="new-defect-submit">
            {t('defects.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
