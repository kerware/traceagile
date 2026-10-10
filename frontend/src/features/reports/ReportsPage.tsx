import { ActionIcon, Alert, Anchor, Badge, Button, Card, Checkbox, Group, Loader, Menu, NumberInput, SimpleGrid, Stack, Table, Tabs, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCopy, IconDots, IconDownload, IconEdit, IconFileAnalytics, IconPlus, IconTrash } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import {
  downloadReport,
  useDeleteDefinition,
  useDuplicateDefinition,
  useReportDefinitions,
  useReports,
  useUpdateVerdictRules,
  useVerdictRules,
  type ReportDefinition,
  type ReportFormat,
  type VerdictRules,
} from '../../api/reports';
import { ConfirmModal } from '../../components/Dialogs';
import { FORMATS, useCanEditVerdictRules, useCanWriteReports } from './model';
import { FrozenBadge, VerdictBadge } from './ReportBadges';
import { DefinitionModal, GenerateReportModal } from './ReportModals';
import { useShortcuts } from '../../components/search/useShortcuts';

/** §13.2 /p/:key/reports — bilans et rapports générés, modèles configurables, règles du verdict (§9, ADR-0023). */
export function ReportsPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const tab = params.get('tab') ?? 'reports';
  const canWrite = useCanWriteReports(project);
  const [generate, setGenerate] = useState<{ opened: boolean; definitionId?: string | null }>({ opened: false });
  // §13.3 N : générer un rapport
  useShortcuts({ n: () => setGenerate({ opened: true }) }, canWrite);

  return (
    <Stack data-testid="reports-page">
      <Group justify="space-between">
        <Title order={2}>{t('reports.pageTitle')}</Title>
        {canWrite && (
          <Button leftSection={<IconFileAnalytics size={16} />} onClick={() => setGenerate({ opened: true })} data-testid="report-generate">
            {t('reports.generate')}
          </Button>
        )}
      </Group>
      <Tabs value={tab} keepMounted={false} onChange={(v) => setParams(v === 'reports' ? {} : { tab: v ?? 'reports' })}>
        <Tabs.List>
          <Tabs.Tab value="reports" data-testid="reports-tab-reports">
            {t('reports.tabReports')}
          </Tabs.Tab>
          <Tabs.Tab value="definitions" data-testid="reports-tab-definitions">
            {t('reports.tabDefinitions')}
          </Tabs.Tab>
          <Tabs.Tab value="rules" data-testid="reports-tab-rules">
            {t('reports.tabRules')}
          </Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="reports" pt="md">
          <ReportList project={project} />
        </Tabs.Panel>
        <Tabs.Panel value="definitions" pt="md">
          <Definitions project={project} onGenerate={(definitionId) => setGenerate({ opened: true, definitionId })} />
        </Tabs.Panel>
        <Tabs.Panel value="rules" pt="md">
          <RulesPanel project={project} />
        </Tabs.Panel>
      </Tabs>
      <GenerateReportModal project={project} opened={generate.opened} definitionId={generate.definitionId} onClose={() => setGenerate({ opened: false })} />
    </Stack>
  );
}

function ReportList({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data, isLoading, error } = useReports(project);
  if (isLoading) return <Loader />;
  if (error) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  if (!data?.length) {
    return (
      <Text c="dimmed" data-testid="reports-empty">
        {t('reports.empty')}
      </Text>
    );
  }
  return (
    <Table striped data-testid="reports-table">
      <Table.Thead>
        <Table.Tr>
          <Table.Th>{t('reports.key')}</Table.Th>
          <Table.Th>{t('reports.title')}</Table.Th>
          <Table.Th>{t('reports.scope')}</Table.Th>
          <Table.Th>{t('reports.verdict')}</Table.Th>
          <Table.Th>{t('reports.generatedAt')}</Table.Th>
          <Table.Th />
        </Table.Tr>
      </Table.Thead>
      <Table.Tbody>
        {data.map((r) => (
          <Table.Tr key={r.key} data-testid={`report-row-${r.key}`}>
            <Table.Td>
              <Anchor component={Link} to={`/p/${project}/reports/${r.key}`} ff="monospace" fw={600} data-testid={`report-link-${r.key}`}>
                {r.key}
              </Anchor>
            </Table.Td>
            <Table.Td>
              <Group gap={6}>
                <Text size="sm">{r.title}</Text>
                {r.frozen && <FrozenBadge />}
              </Group>
              <Text size="xs" c="dimmed">
                {r.definitionName}
              </Text>
            </Table.Td>
            <Table.Td>
              <Text size="sm">{r.scopeLabel}</Text>
            </Table.Td>
            <Table.Td>
              <VerdictBadge verdict={r.verdict} testId={`report-verdict-${r.key}`} />
            </Table.Td>
            <Table.Td>
              <Text size="xs">{new Date(r.createdAt).toLocaleString()}</Text>
              <Text size="xs" c="dimmed">
                {r.createdBy ?? ''}
              </Text>
            </Table.Td>
            <Table.Td>
              <ExportMenu project={project} reportKey={r.key} />
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}

/** F-RPT-03 export dans l'un des formats (PDF, Word, Excel, HTML, Markdown, CSV, JSON). */
export function ExportMenu({ project, reportKey, label }: { project: string; reportKey: string; label?: boolean }) {
  const { t } = useTranslation();
  const [pending, setPending] = useState<ReportFormat | null>(null);
  const run = async (format: ReportFormat) => {
    setPending(format);
    try {
      await downloadReport(project, reportKey, format);
    } catch (e) {
      notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
    } finally {
      setPending(null);
    }
  };
  return (
    <Menu position="bottom-end" withinPortal>
      <Menu.Target>
        {label ? (
          <Button leftSection={<IconDownload size={16} />} variant="light" loading={!!pending} data-testid={`export-${reportKey}`}>
            {t('reports.export')}
          </Button>
        ) : (
          <ActionIcon variant="subtle" aria-label={t('reports.export')} loading={!!pending} data-testid={`export-${reportKey}`}>
            <IconDownload size={16} />
          </ActionIcon>
        )}
      </Menu.Target>
      <Menu.Dropdown>
        {FORMATS.map((f) => (
          <Menu.Item key={f} onClick={() => void run(f)} data-testid={`export-${reportKey}-${f}`}>
            {t(`exportFormat.${f}`)}
          </Menu.Item>
        ))}
      </Menu.Dropdown>
    </Menu>
  );
}

function Definitions({ project, onGenerate }: { project: string; onGenerate: (id: string) => void }) {
  const { t } = useTranslation();
  const { data, isLoading } = useReportDefinitions(project);
  const canWrite = useCanWriteReports(project);
  const duplicate = useDuplicateDefinition(project);
  const remove = useDeleteDefinition(project);
  const [editing, setEditing] = useState<{ opened: boolean; definition: ReportDefinition | null }>({ opened: false, definition: null });
  const [deleting, setDeleting] = useState<ReportDefinition | null>(null);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  if (isLoading) return <Loader />;
  return (
    <Stack>
      {canWrite && (
        <Group>
          <Button variant="light" leftSection={<IconPlus size={16} />} onClick={() => setEditing({ opened: true, definition: null })}
            data-testid="definition-new">
            {t('reports.newDefinition')}
          </Button>
        </Group>
      )}
      <SimpleGrid cols={{ base: 1, md: 2 }}>
        {(data ?? []).map((d) => (
          <Card key={d.id} withBorder data-testid={`definition-${d.name}`}>
            <Group justify="space-between" align="flex-start" wrap="nowrap">
              <Stack gap={2}>
                <Group gap={6}>
                  <Text fw={600}>{d.name}</Text>
                  {d.builtIn && (
                    <Badge size="xs" variant="light">
                      {t('reports.builtIn')}
                    </Badge>
                  )}
                </Group>
                <Text size="xs" c="dimmed">
                  {t(`reportScope.${d.scopeType}`)} · {t(`exportFormat.${d.defaultFormat}`)}
                </Text>
              </Stack>
              {canWrite && (
                <Menu position="bottom-end" withinPortal>
                  <Menu.Target>
                    <ActionIcon variant="subtle" aria-label={t('reports.actions')} data-testid={`definition-menu-${d.name}`}>
                      <IconDots size={16} />
                    </ActionIcon>
                  </Menu.Target>
                  <Menu.Dropdown>
                    {!d.builtIn && (
                      <Menu.Item leftSection={<IconEdit size={14} />} onClick={() => setEditing({ opened: true, definition: d })}
                        data-testid="definition-edit">
                        {t('common.edit')}
                      </Menu.Item>
                    )}
                    <Menu.Item leftSection={<IconCopy size={14} />} onClick={() => duplicate.mutate(d.id, { onError: fail })} data-testid="definition-duplicate">
                      {t('reports.duplicate')}
                    </Menu.Item>
                    {!d.builtIn && (
                      <Menu.Item color="red" leftSection={<IconTrash size={14} />} onClick={() => setDeleting(d)} data-testid="definition-delete">
                        {t('common.delete')}
                      </Menu.Item>
                    )}
                  </Menu.Dropdown>
                </Menu>
              )}
            </Group>
            {d.description && (
              <Text size="sm" mt="xs">
                {d.description}
              </Text>
            )}
            <Group gap={4} mt="xs">
              {d.sections.map((s, i) => (
                <Badge key={s} size="sm" variant="outline" color="gray">
                  {i + 1}. {t(`reportSection.${s}`)}
                </Badge>
              ))}
            </Group>
            {canWrite && (
              <Group mt="sm">
                <Button size="xs" variant="light" onClick={() => onGenerate(d.id)} data-testid={`definition-generate-${d.name}`}>
                  {t('reports.generateWith')}
                </Button>
              </Group>
            )}
          </Card>
        ))}
      </SimpleGrid>
      <DefinitionModal project={project} opened={editing.opened} definition={editing.definition} onClose={() => setEditing({ opened: false, definition: null })} />
      <ConfirmModal opened={!!deleting} title={t('reports.deleteDefinition')} message={t('reports.deleteDefinitionMessage', { name: deleting?.name ?? '' })}
        confirmLabel={t('common.delete')} onConfirm={() => remove.mutateAsync(deleting?.id ?? '')} onClose={() => setDeleting(null)} />
    </Stack>
  );
}

function RulesPanel({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useVerdictRules(project);
  const canEdit = useCanEditVerdictRules(project);
  const update = useUpdateVerdictRules(project);
  const [rules, setRules] = useState<VerdictRules | null>(null);
  useEffect(() => {
    if (data) setRules(data);
  }, [data]);
  if (isLoading || !rules) return <Loader />;
  const set = (patch: Partial<VerdictRules>) => setRules({ ...rules, ...patch });
  return (
    <Card withBorder maw={640} data-testid="verdict-rules">
      <Stack>
        <Text size="sm" c="dimmed">
          {t('reports.rulesHelp')}
        </Text>
        <Group grow>
          <NumberInput label={t('reports.goMinValidation')} value={rules.goMinValidation} min={0} max={100} suffix=" %" disabled={!canEdit}
            onChange={(v) => set({ goMinValidation: Number(v) })} data-testid="rules-go" />
          <NumberInput label={t('reports.reservedMinValidation')} value={rules.reservedMinValidation} min={0} max={100} suffix=" %" disabled={!canEdit}
            onChange={(v) => set({ reservedMinValidation: Number(v) })} data-testid="rules-reserved" />
        </Group>
        <Checkbox label={t('reports.goForbidsCriticalDefects')} checked={rules.goForbidsCriticalDefects} disabled={!canEdit}
          onChange={(e) => set({ goForbidsCriticalDefects: e.currentTarget.checked })} />
        <Checkbox label={t('reports.goRequiresCriticalRequirements')} checked={rules.goRequiresCriticalRequirements} disabled={!canEdit}
          onChange={(e) => set({ goRequiresCriticalRequirements: e.currentTarget.checked })} />
        <Checkbox label={t('reports.reservedForbidsBlockerDefects')} checked={rules.reservedForbidsBlockerDefects} disabled={!canEdit}
          onChange={(e) => set({ reservedForbidsBlockerDefects: e.currentTarget.checked })} />
        {canEdit && (
          <Group justify="flex-end">
            <Button loading={update.isPending} data-testid="rules-save"
              onClick={() => update.mutate(rules, {
                onSuccess: () => notifications.show({ color: 'green', message: t('reports.rulesSaved') }),
                onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
              })}>
              {t('common.save')}
            </Button>
          </Group>
        )}
      </Stack>
    </Card>
  );
}
