import { ActionIcon, Alert, Button, Checkbox, Group, Modal, Paper, SegmentedControl, Select, Stack, Switch, Text, TextInput, Textarea } from '@mantine/core';
import { IconArrowDown, IconArrowUp } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { useReleases, useSprints } from '../../api/planning';
import {
  useGenerateReport,
  useOverrideVerdict,
  useReportDefinitions,
  useSaveDefinition,
  type ReportDefinition,
  type ReportFormat,
  type ReportScopeType,
  type ReportSection,
  type Verdict,
} from '../../api/reports';
import { appliesTo, FORMATS, move, SCOPE_TYPES, SECTIONS, toggle } from './model';

/** ADR-0023 création ou modification d'une définition de rapport : périmètre, sections ordonnées, format, options. */
export function DefinitionModal({ project, opened, onClose, definition }: { project: string; opened: boolean; onClose: () => void;
  definition: ReportDefinition | null }) {
  const { t } = useTranslation();
  const save = useSaveDefinition(project);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [scopeType, setScopeType] = useState<ReportScopeType>('SPRINT');
  const [selected, setSelected] = useState<ReportSection[]>([]);
  const [format, setFormat] = useState<ReportFormat>('PDF');
  const [charts, setCharts] = useState(true);
  const [details, setDetails] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!opened) return;
    setName(definition?.name ?? '');
    setDescription(definition?.description ?? '');
    setScopeType(definition?.scopeType ?? 'SPRINT');
    setSelected(definition?.sections ?? ['SUMMARY', 'COVERAGE', 'EXECUTION', 'DEFECTS']);
    setFormat(definition?.defaultFormat ?? 'PDF');
    setCharts(definition?.includeCharts ?? true);
    setDetails(definition?.includeDetails ?? false);
    setError(null);
  }, [opened, definition]);

  const changeScope = (value: ReportScopeType) => {
    setScopeType(value);
    setSelected((current) => current.filter((s) => appliesTo(s, value)));
  };
  const available = SECTIONS.filter((s) => appliesTo(s, scopeType) && !selected.includes(s));
  const submit = () =>
    save.mutate(
      { id: definition?.id, name, description, scopeType, sections: selected, defaultFormat: format, includeCharts: charts, includeDetails: details },
      { onSuccess: onClose, onError: (e) => setError(errorMessage(e, t('errors.generic'))) },
    );

  return (
    <Modal opened={opened} onClose={onClose} title={definition ? t('reports.editDefinition') : t('reports.newDefinition')} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert" data-testid="definition-error">
            {error}
          </Alert>
        )}
        <TextInput label={t('reports.name')} value={name} onChange={(e) => setName(e.currentTarget.value)} required data-testid="definition-name" />
        <Textarea label={t('reports.description')} value={description} onChange={(e) => setDescription(e.currentTarget.value)} autosize minRows={2}
          data-testid="definition-description" />
        <Stack gap={4}>
          <Text size="sm" fw={500}>
            {t('reports.scopeType')}
          </Text>
          <SegmentedControl value={scopeType} onChange={(v) => changeScope(v as ReportScopeType)} data-testid="definition-scope"
            data={SCOPE_TYPES.map((s) => ({ value: s, label: t(`reportScope.${s}`) }))} />
        </Stack>
        <Stack gap={4}>
          <Text size="sm" fw={500}>
            {t('reports.sections')}
          </Text>
          <Text size="xs" c="dimmed">
            {t('reports.sectionsHelp')}
          </Text>
          <Paper withBorder p="xs">
            <Stack gap={4}>
              {selected.map((section, index) => (
                <Group key={section} justify="space-between" wrap="nowrap" data-testid={`definition-section-${section}`}>
                  <Checkbox checked label={`${index + 1}. ${t(`reportSection.${section}`)}`} onChange={() => setSelected(toggle(selected, section))}
                    data-testid={`definition-toggle-${section}`} />
                  <Group gap={2}>
                    <ActionIcon variant="subtle" size="sm" disabled={index === 0} onClick={() => setSelected(move(selected, section, -1))}
                      aria-label={t('steps.up')} data-testid={`definition-up-${section}`}>
                      <IconArrowUp size={14} />
                    </ActionIcon>
                    <ActionIcon variant="subtle" size="sm" disabled={index === selected.length - 1} onClick={() => setSelected(move(selected, section, 1))}
                      aria-label={t('steps.down')} data-testid={`definition-down-${section}`}>
                      <IconArrowDown size={14} />
                    </ActionIcon>
                  </Group>
                </Group>
              ))}
              {available.map((section) => (
                <Checkbox key={section} checked={false} label={t(`reportSection.${section}`)} onChange={() => setSelected(toggle(selected, section))}
                  c="dimmed" data-testid={`definition-toggle-${section}`} />
              ))}
            </Stack>
          </Paper>
        </Stack>
        <Select label={t('reports.defaultFormat')} value={format} onChange={(v) => v && setFormat(v as ReportFormat)} allowDeselect={false}
          data={FORMATS.map((f) => ({ value: f, label: t(`exportFormat.${f}`) }))} data-testid="definition-format" />
        <Group>
          <Switch label={t('reports.includeCharts')} checked={charts} onChange={(e) => setCharts(e.currentTarget.checked)} data-testid="definition-charts" />
          <Switch label={t('reports.includeDetails')} checked={details} onChange={(e) => setDetails(e.currentTarget.checked)}
            data-testid="definition-details" />
        </Group>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button onClick={submit} loading={save.isPending} disabled={!name.trim() || selected.length === 0} data-testid="definition-submit">
            {t('common.save')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** ADR-0023 génération d'un rapport : définition, sprint ou release visé, titre facultatif. */
export function GenerateReportModal({ project, opened, onClose, definitionId }: { project: string; opened: boolean; onClose: () => void;
  definitionId?: string | null }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const definitions = useReportDefinitions(project);
  const sprints = useSprints(project);
  const releases = useReleases(project);
  const generate = useGenerateReport(project);
  const [id, setId] = useState<string | null>(null);
  const [scopeKey, setScopeKey] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [error, setError] = useState<string | null>(null);
  const definition = definitions.data?.find((d) => d.id === id) ?? null;

  useEffect(() => {
    if (!opened) return;
    setId(definitionId ?? definitions.data?.find((d) => d.builtIn && d.scopeType === 'SPRINT')?.id ?? definitions.data?.[0]?.id ?? null);
    setTitle('');
    setError(null);
  }, [opened, definitionId, definitions.data]);

  useEffect(() => {
    if (!definition) return;
    if (definition.scopeType === 'SPRINT') {
      const list = sprints.data ?? [];
      setScopeKey(list.find((s) => s.status === 'ACTIVE')?.key ?? list[0]?.key ?? null);
    } else if (definition.scopeType === 'RELEASE') {
      const list = releases.data ?? [];
      setScopeKey(list.find((r) => r.status !== 'CLOSED')?.key ?? list[0]?.key ?? null);
    } else {
      setScopeKey(null);
    }
  }, [definition, sprints.data, releases.data]);

  const scopes =
    definition?.scopeType === 'SPRINT'
      ? (sprints.data ?? []).map((s) => ({ value: s.key, label: `${s.key} — ${s.name} (${t(`planningStatus.${s.status}`)})` }))
      : definition?.scopeType === 'RELEASE'
        ? (releases.data ?? []).map((r) => ({ value: r.key, label: `${r.key} — ${r.name}` }))
        : [];
  const submit = () =>
    generate.mutate(
      { definitionId: id ?? '', scopeKey: scopeKey ?? undefined, title: title.trim() || undefined },
      {
        onSuccess: (report) => {
          onClose();
          navigate(`/p/${project}/reports/${report.report.key}`);
        },
        onError: (e) => setError(errorMessage(e, t('errors.generic'))),
      },
    );

  return (
    <Modal opened={opened} onClose={onClose} title={t('reports.generate')}>
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <Select label={t('reports.definition')} value={id} onChange={setId} allowDeselect={false} data-testid="generate-definition"
          data={(definitions.data ?? []).map((d) => ({ value: d.id, label: d.name }))} />
        {definition && definition.scopeType !== 'PROJECT' && (
          <Select label={t(`reportScope.${definition.scopeType}`)} value={scopeKey} onChange={setScopeKey} allowDeselect={false} data={scopes}
            data-testid="generate-scope" />
        )}
        <TextInput label={t('reports.title')} placeholder={t('reports.titlePlaceholder')} value={title} onChange={(e) => setTitle(e.currentTarget.value)}
          data-testid="generate-title" />
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button onClick={submit} loading={generate.isPending} disabled={!id || (definition?.scopeType !== 'PROJECT' && !scopeKey)}
            data-testid="generate-submit">
            {t('reports.generateSubmit')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** §9.2 le PO modifie le verdict, avec un commentaire obligatoire, ou revient au verdict calculé. */
export function VerdictModal({ project, reportKey, opened, onClose, current, computed }: { project: string; reportKey: string; opened: boolean;
  onClose: () => void; current?: Verdict | null; computed?: Verdict | null }) {
  const { t } = useTranslation();
  const override = useOverrideVerdict(project, reportKey);
  const [verdict, setVerdict] = useState<string>('COMPUTED');
  const [comment, setComment] = useState('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!opened) return;
    setVerdict(current && current !== computed ? current : 'COMPUTED');
    setComment('');
    setError(null);
  }, [opened, current, computed]);

  const computedChoice = verdict === 'COMPUTED';
  const submit = () =>
    override.mutate(
      { verdict: computedChoice ? undefined : (verdict as Verdict), comment: comment.trim() || undefined },
      { onSuccess: onClose, onError: (e) => setError(errorMessage(e, t('errors.generic'))) },
    );

  return (
    <Modal opened={opened} onClose={onClose} title={t('reports.verdictTitle')}>
      <Stack>
        {error && (
          <Alert color="red" role="alert" data-testid="verdict-error">
            {error}
          </Alert>
        )}
        <Select label={t('reports.verdict')} value={verdict} onChange={(v) => v && setVerdict(v)} allowDeselect={false} data-testid="verdict-select"
          data={[
            { value: 'COMPUTED', label: t('reports.computedVerdict', { verdict: computed ? t(`verdict.${computed}`) : '—' }) },
            ...(['GO', 'GO_WITH_RESERVATIONS', 'NO_GO'] as Verdict[]).map((v) => ({ value: v, label: t(`verdict.${v}`) })),
          ]} />
        {!computedChoice && (
          <Textarea label={t('reports.verdictComment')} value={comment} onChange={(e) => setComment(e.currentTarget.value)} required autosize minRows={3}
            data-testid="verdict-comment" />
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button onClick={submit} loading={override.isPending} disabled={!computedChoice && !comment.trim()} data-testid="verdict-submit">
            {t('common.save')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
