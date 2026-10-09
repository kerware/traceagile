import { Alert, Button, Group, Modal, NumberInput, SegmentedControl, Select, Stack, Table, Text, Textarea, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import {
  useCloseSprint,
  useCreateRelease,
  useCreateSprint,
  useGenerateSprints,
  useUpdateRelease,
  useUpdateSprint,
  type CloseAction,
  type ReleaseResponse,
  type SprintDetail,
  type SprintSummary,
} from '../../api/planning';
import { needsDecision } from './model';

function ErrorAlert({ error }: { error: string | null }) {
  return error ? (
    <Alert color="red" role="alert">
      {error}
    </Alert>
  ) : null;
}

/** F-PLN-01 créer ou modifier une release (nom, objectif, dates). */
export function ReleaseModal({ project, opened, release, onClose }: { project: string; opened: boolean; release?: ReleaseResponse | null; onClose: () => void }) {
  const { t } = useTranslation();
  const create = useCreateRelease(project);
  const update = useUpdateRelease(project);
  const [form, setForm] = useState({ name: '', goal: '', startDate: '', endDate: '' });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setForm({ name: release?.name ?? '', goal: release?.goal ?? '', startDate: release?.startDate ?? '', endDate: release?.endDate ?? '' });
      setError(null);
    }
  }, [opened, release]);

  const submit = async () => {
    setError(null);
    try {
      const body = { name: form.name.trim(), goal: form.goal.trim() || undefined, startDate: form.startDate, endDate: form.endDate };
      const saved = release ? await update.mutateAsync({ key: release.key, patch: body }) : await create.mutateAsync(body);
      notifications.show({ color: 'green', message: t(release ? 'planning.releaseSaved' : 'planning.releaseCreated', { key: saved.key }) });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={release ? t('planning.editRelease', { key: release.key }) : t('planning.newRelease')}>
      <Stack>
        <ErrorAlert error={error} />
        <TextInput label={t('planning.name')} required maxLength={120} value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} data-testid="release-name" />
        <Textarea label={t('planning.goal')} autosize minRows={2} value={form.goal} onChange={(e) => setForm({ ...form, goal: e.currentTarget.value })} data-testid="release-goal" />
        <Group grow>
          <TextInput type="date" label={t('planning.startDate')} required value={form.startDate} onChange={(e) => setForm({ ...form, startDate: e.currentTarget.value })} data-testid="release-start" />
          <TextInput type="date" label={t('planning.endDate')} required value={form.endDate} onChange={(e) => setForm({ ...form, endDate: e.currentTarget.value })} data-testid="release-end" />
        </Group>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} disabled={!form.name.trim() || !form.startDate || !form.endDate} loading={create.isPending || update.isPending} data-testid="release-submit">
            {release ? t('planning.save') : t('planning.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** F-PLN-01 générer N sprints de 1 à 4 semaines, sans chevauchement. */
export function GenerateSprintsModal({ project, release, onClose }: { project: string; release: ReleaseResponse | null; onClose: () => void }) {
  const { t } = useTranslation();
  const generate = useGenerateSprints(project);
  const [count, setCount] = useState<number | string>(3);
  const [weeks, setWeeks] = useState('2');
  const [startDate, setStartDate] = useState('');
  const [capacity, setCapacity] = useState<number | string>('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (release) {
      setStartDate('');
      setError(null);
    }
  }, [release]);

  const submit = async () => {
    if (!release) return;
    setError(null);
    try {
      const saved = await generate.mutateAsync({
        key: release.key,
        body: { count: Number(count), durationWeeks: Number(weeks), startDate: startDate || undefined, capacityPoints: capacity === '' ? undefined : Number(capacity) },
      });
      notifications.show({ color: 'green', message: t('planning.generated', { count: Number(count), key: saved.key }) });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={!!release} onClose={onClose} title={release ? t('planning.generateTitle', { key: release.key }) : ''}>
      <Stack>
        <ErrorAlert error={error} />
        <NumberInput label={t('planning.sprintCount')} min={1} max={26} value={count} onChange={setCount} data-testid="generate-count" />
        <div>
          <Text size="sm" fw={500} mb={4}>
            {t('planning.duration')}
          </Text>
          <SegmentedControl
            value={weeks}
            onChange={setWeeks}
            data={['1', '2', '3', '4'].map((w) => ({ value: w, label: t('planning.weeks', { count: Number(w) }) }))}
            data-testid="generate-weeks"
          />
        </div>
        <TextInput type="date" label={t('planning.generateStart')} description={t('planning.generateStartHint')} value={startDate} onChange={(e) => setStartDate(e.currentTarget.value)} data-testid="generate-start" />
        <NumberInput label={t('planning.capacity')} min={0} max={1000} value={capacity} onChange={setCapacity} data-testid="generate-capacity" />
        <Text size="xs" c="dimmed">
          {t('planning.generateHint')}
        </Text>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={generate.isPending} data-testid="generate-submit">
            {t('planning.generate')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** F-PLN-04 créer ou modifier un sprint, rattaché ou non à une release. */
export function SprintModal({ project, opened, sprint, releases, defaultRelease, onClose }: {
  project: string;
  opened: boolean;
  sprint?: SprintSummary | null;
  releases: ReleaseResponse[];
  defaultRelease?: string | null;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const create = useCreateSprint(project);
  const update = useUpdateSprint(project);
  const [form, setForm] = useState({ name: '', goal: '', startDate: '', endDate: '', capacity: '' as number | string, releaseKey: null as string | null });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setForm({
        name: sprint?.name ?? '',
        goal: sprint?.goal ?? '',
        startDate: sprint?.startDate ?? '',
        endDate: sprint?.endDate ?? '',
        capacity: sprint?.capacityPoints ?? '',
        releaseKey: sprint ? sprint.releaseKey ?? null : defaultRelease ?? null,
      });
      setError(null);
    }
  }, [opened, sprint, defaultRelease]);

  const submit = async () => {
    setError(null);
    const capacityPoints = form.capacity === '' ? undefined : Number(form.capacity);
    try {
      if (sprint) {
        await update.mutateAsync({
          key: sprint.key,
          patch: { name: form.name.trim(), goal: form.goal.trim() || undefined, startDate: form.startDate, endDate: form.endDate, capacityPoints, releaseKey: form.releaseKey ?? undefined },
        });
      } else {
        await create.mutateAsync({ name: form.name.trim(), goal: form.goal.trim() || undefined, startDate: form.startDate, endDate: form.endDate, capacityPoints, releaseKey: form.releaseKey ?? undefined });
      }
      notifications.show({ color: 'green', message: t('planning.sprintSaved') });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={sprint ? t('planning.editSprint', { key: sprint.key }) : t('planning.newSprint')}>
      <Stack>
        <ErrorAlert error={error} />
        <TextInput label={t('planning.name')} required maxLength={120} value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} data-testid="sprint-name" />
        <Textarea label={t('planning.goal')} autosize minRows={2} value={form.goal} onChange={(e) => setForm({ ...form, goal: e.currentTarget.value })} />
        <Group grow>
          <TextInput type="date" label={t('planning.startDate')} required value={form.startDate} onChange={(e) => setForm({ ...form, startDate: e.currentTarget.value })} data-testid="sprint-start" />
          <TextInput type="date" label={t('planning.endDate')} required value={form.endDate} onChange={(e) => setForm({ ...form, endDate: e.currentTarget.value })} data-testid="sprint-end" />
        </Group>
        <Group grow>
          <NumberInput label={t('planning.capacity')} min={0} max={1000} value={form.capacity} onChange={(capacity) => setForm({ ...form, capacity })} data-testid="sprint-capacity" />
          <Select
            label={t('planning.release')}
            data={releases.filter((r) => r.status !== 'CLOSED').map((r) => ({ value: r.key, label: `${r.key} — ${r.name}` }))}
            value={form.releaseKey}
            onChange={(releaseKey) => setForm({ ...form, releaseKey })}
            clearable
            data-testid="sprint-release"
          />
        </Group>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} disabled={!form.name.trim() || !form.startDate || !form.endDate} loading={create.isPending || update.isPending} data-testid="sprint-submit">
            {sprint ? t('planning.save') : t('planning.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** F-PLN-06 clôture : renvoyer au backlog ou reporter sur le sprint suivant chaque story non terminée. */
export function CloseSprintModal({ project, detail, opened, onClose }: { project: string; detail: SprintDetail; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const close = useCloseSprint(project);
  const pending = detail.scope.filter(needsDecision);
  const [actions, setActions] = useState<Record<string, CloseAction>>({});
  const [error, setError] = useState<string | null>(null);
  const next = detail.nextSprintKey;

  useEffect(() => {
    if (opened) {
      setActions(Object.fromEntries(pending.map((item) => [item.key, next ? 'NEXT_SPRINT' : 'BACKLOG'])));
      setError(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [opened, detail.sprint.key]);

  const submit = async () => {
    setError(null);
    try {
      await close.mutateAsync({ key: detail.sprint.key, decisions: pending.map((item) => ({ requirementKey: item.key, action: actions[item.key] ?? 'BACKLOG' })) });
      notifications.show({ color: 'green', message: t('planning.sprintClosed', { key: detail.sprint.key }) });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('planning.closeSprintTitle', { key: detail.sprint.key })} size="lg">
      <Stack>
        <ErrorAlert error={error} />
        {pending.length === 0 ? (
          <Text size="sm">{t('planning.allDone')}</Text>
        ) : (
          <>
            <Text size="sm">{next ? t('planning.closeHint', { next }) : t('planning.closeHintNoNext')}</Text>
            <Table>
              <Table.Tbody>
                {pending.map((item) => (
                  <Table.Tr key={item.key} data-testid={`close-item-${item.key}`}>
                    <Table.Td>
                      <Text size="sm" ff="monospace" fw={600}>
                        {item.key}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Text size="sm">{item.title}</Text>
                    </Table.Td>
                    <Table.Td>
                      <SegmentedControl
                        size="xs"
                        value={actions[item.key] ?? 'BACKLOG'}
                        onChange={(value) => setActions({ ...actions, [item.key]: value as CloseAction })}
                        data={[
                          { value: 'BACKLOG', label: t('planning.toBacklog') },
                          { value: 'NEXT_SPRINT', label: next ? t('planning.toNext', { next }) : t('planning.noNext'), disabled: !next },
                        ]}
                        data-testid={`close-action-${item.key}`}
                      />
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          </>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button color="orange" onClick={submit} loading={close.isPending} data-testid="close-sprint-submit">
            {t('planning.closeSprint')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** F-PLN-03 bilan figé d'une release clôturée (lecture seule). */
export function ReleaseReportModal({ release, onClose }: { release: ReleaseResponse | null; onClose: () => void }) {
  const { t } = useTranslation();
  const report = (release?.closingReport ?? {}) as {
    closedAt?: string;
    committedPoints?: number;
    donePoints?: number;
    sprints?: { key: string; name: string; committedPoints: number; donePoints: number; validationRate?: number | null }[];
    coverage?: Record<string, number | null>;
  };
  return (
    <Modal opened={!!release} onClose={onClose} title={release ? t('planning.reportTitle', { key: release.key }) : ''} size="lg">
      {release && (
        <Stack data-testid="release-report">
          <Text size="sm" c="dimmed">
            {t('planning.closedAt', { date: report.closedAt ? new Date(report.closedAt).toLocaleString() : '—' })}
          </Text>
          <Text size="sm">{t('planning.reportPoints', { done: report.donePoints ?? 0, committed: report.committedPoints ?? 0 })}</Text>
          <Table>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('planning.sprint')}</Table.Th>
                <Table.Th ta="right">{t('planning.committed')}</Table.Th>
                <Table.Th ta="right">{t('planning.done')}</Table.Th>
                <Table.Th ta="right">{t('coverage.validation')}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {(report.sprints ?? []).map((s) => (
                <Table.Tr key={s.key}>
                  <Table.Td>
                    {s.key} — {s.name}
                  </Table.Td>
                  <Table.Td ta="right">{s.committedPoints}</Table.Td>
                  <Table.Td ta="right">{s.donePoints}</Table.Td>
                  <Table.Td ta="right">{s.validationRate === null || s.validationRate === undefined ? '—' : `${s.validationRate} %`}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
          <Group gap="lg">
            {Object.entries(report.coverage ?? {}).map(([name, value]) => (
              <Text key={name} size="sm">
                {t(`coverage.${name}`)} : <b>{value === null || value === undefined ? '—' : `${value} %`}</b>
              </Text>
            ))}
          </Group>
        </Stack>
      )}
    </Modal>
  );
}
