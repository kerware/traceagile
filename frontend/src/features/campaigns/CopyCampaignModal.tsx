import { Alert, Button, Checkbox, Group, Modal, SegmentedControl, Select, SimpleGrid, Stack, Text, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useCopyCampaign, type CampaignDetail, type CampaignScope, type ExecutionStatus } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { useReleases, useSprints } from '../../api/planning';
import { ExecutionStatusBadge } from './CampaignBadges';
import { RESULT_STATUSES } from './model';

type Mode = 'ALL' | 'RESULTS';

/**
 * ADR-0017 dupliquer une campagne, ou en générer une avec les tests dont le dernier résultat est
 * l'un des statuts cochés (par défaut : les échecs). Ouvre la nouvelle campagne.
 */
export function CopyCampaignModal({ project, detail, opened, onClose }: { project: string; detail: CampaignDetail; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const copy = useCopyCampaign(project, detail.campaign.key);
  const { data: sprints } = useSprints(project);
  const { data: releases } = useReleases(project);
  const source = detail.campaign;
  const byStatus = source.progress.byStatus as Partial<Record<ExecutionStatus, number>>;
  const failures = (byStatus.FAILED ?? 0) + (byStatus.ERROR ?? 0);
  const initial = () => ({
    mode: (failures > 0 ? 'RESULTS' : 'ALL') as Mode,
    name: failures > 0 ? t('copy.defaultRerunName', { name: source.name }) : t('copy.defaultName', { name: source.name }),
    scopeType: source.scopeType,
    target: (source.sprintKey ?? source.releaseKey ?? null) as string | null,
    environment: source.environment ?? '',
    buildVersion: source.buildVersion ?? '',
    statuses: ['FAILED', 'ERROR'] as ExecutionStatus[],
    keepAssignees: true,
  });
  const [form, setForm] = useState(initial);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setForm(initial());
      setError(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [opened]);

  const count = form.mode === 'ALL' ? source.progress.total : form.statuses.reduce((n, s) => n + (byStatus[s] ?? 0), 0);

  const submit = async () => {
    setError(null);
    try {
      const result = await copy.mutateAsync({
        name: form.name.trim(),
        scopeType: form.scopeType,
        sprintKey: form.scopeType === 'SPRINT' ? form.target ?? undefined : undefined,
        releaseKey: form.scopeType === 'RELEASE' ? form.target ?? undefined : undefined,
        environment: form.environment.trim() || undefined,
        buildVersion: form.buildVersion.trim() || undefined,
        statuses: form.mode === 'RESULTS' ? form.statuses : undefined,
        keepAssignees: form.keepAssignees,
      });
      onClose();
      notifications.show({
        color: result.skipped.length ? 'yellow' : 'green',
        message:
          t('copy.done', { count: result.copied.length, key: result.campaign.campaign.key }) +
          (result.skipped.length ? ` ${t('copy.skipped', { list: result.skipped.map((s) => s.testKey).join(', ') })}` : ''),
      });
      navigate(`/p/${project}/campaigns/${result.campaign.campaign.key}`);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  const targets =
    form.scopeType === 'SPRINT'
      ? (sprints ?? []).map((s) => ({ value: s.key, label: `${s.key} — ${s.name}` }))
      : (releases ?? []).map((r) => ({ value: r.key, label: `${r.key} — ${r.name}` }));

  return (
    <Modal opened={opened} onClose={onClose} title={t('copy.title', { key: source.key })} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <SegmentedControl
          value={form.mode}
          onChange={(mode) => setForm({ ...form, mode: mode as Mode })}
          data={[
            { value: 'ALL', label: t('copy.modeAll') },
            { value: 'RESULTS', label: t('copy.modeResults') },
          ]}
          data-testid="copy-mode"
        />
        {form.mode === 'RESULTS' && (
          <Checkbox.Group value={form.statuses} onChange={(statuses) => setForm({ ...form, statuses: statuses as ExecutionStatus[] })} label={t('copy.statuses')}>
            <Group mt={4} data-testid="copy-statuses">
              {RESULT_STATUSES.map((s) => (
                <Checkbox
                  key={s}
                  value={s}
                  data-testid={`copy-status-${s}`}
                  label={
                    <Group gap={4}>
                      <ExecutionStatusBadge status={s} /> <Text size="sm">({byStatus[s] ?? 0})</Text>
                    </Group>
                  }
                />
              ))}
            </Group>
          </Checkbox.Group>
        )}
        <TextInput label={t('campaigns.name')} required value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} data-testid="copy-name" />
        <SimpleGrid cols={2}>
          <Select
            label={t('campaigns.scope')}
            data={(['SPRINT', 'RELEASE', 'REGRESSION'] as CampaignScope[]).map((s) => ({ value: s, label: t(`campaignScope.${s}`) }))}
            value={form.scopeType}
            onChange={(scopeType) => scopeType && setForm({ ...form, scopeType: scopeType as CampaignScope, target: null })}
            allowDeselect={false}
            data-testid="copy-scope"
          />
          {form.scopeType !== 'REGRESSION' && (
            <Select label={form.scopeType === 'SPRINT' ? t('planning.sprint') : t('planning.release')} data={targets} value={form.target}
              onChange={(target) => setForm({ ...form, target })} required data-testid="copy-target" />
          )}
          <TextInput label={t('campaigns.environment')} value={form.environment} onChange={(e) => setForm({ ...form, environment: e.currentTarget.value })} data-testid="copy-environment" />
          <TextInput label={t('campaigns.build')} value={form.buildVersion} onChange={(e) => setForm({ ...form, buildVersion: e.currentTarget.value })} data-testid="copy-build" />
        </SimpleGrid>
        <Checkbox label={t('copy.keepAssignees')} checked={form.keepAssignees} onChange={(e) => setForm({ ...form, keepAssignees: e.currentTarget.checked })} data-testid="copy-keep-assignees" />
        <Text size="sm" c="dimmed" data-testid="copy-count">
          {t('copy.count', { count })} {t('copy.hint')}
        </Text>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button
            onClick={submit}
            loading={copy.isPending}
            disabled={!form.name.trim() || (form.scopeType !== 'REGRESSION' && !form.target) || (form.mode === 'RESULTS' && form.statuses.length === 0)}
            data-testid="copy-submit"
          >
            {form.mode === 'ALL' ? t('copy.submitAll') : t('copy.submitResults')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
