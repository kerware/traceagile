import { Anchor, Badge, Button, Group, Loader, Table, Text, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconLink } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import {
  useLinkDefectToRequirement,
  useRequirementDefects,
  useRequirementExecutions,
  useTestDefects,
  useTestExecutions,
  type DefectSummary,
  type TracedExecution,
} from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { DefectStatusBadge, ExecutionStatusBadge, SeverityBadge } from './CampaignBadges';
import { useCanUpdateDefects } from './permissions';

/** Exécutions, de la plus récente à la plus ancienne ; {@code showTest} : colonne du test (fiche exigence). */
function ExecutionsTable({ project, data, showTest, testId }: { project: string; data: TracedExecution[]; showTest: boolean; testId: string }) {
  const { t } = useTranslation();
  return (
    <Table striped data-testid={testId}>
      <Table.Tbody>
        {data.map((e) => (
          <Table.Tr key={e.id}>
            <Table.Td>
              <Anchor component={Link} to={`/p/${project}/executions/${e.id}`} ff="monospace" fw={600} size="sm">
                {showTest ? e.test.key : e.campaign.key}
              </Anchor>{' '}
              <Text span size="sm">
                {showTest ? e.test.title : e.campaign.name}
              </Text>
            </Table.Td>
            <Table.Td>
              <Text size="sm">
                {showTest ? `${e.campaign.key} · ` : ''}
                {t('executions.attempt', { n: e.attempt })}
                {e.dataSetName ? ` · ${e.dataSetName} › ${e.dataSetRowName ?? (e.dataSetRow ?? 0) + 1}` : ''}
              </Text>
            </Table.Td>
            <Table.Td>
              <ExecutionStatusBadge status={e.status} />
            </Table.Td>
            <Table.Td>
              <Text size="xs" c="dimmed">
                {new Date(e.endedAt ?? e.startedAt).toLocaleString()} · {e.executedBy ?? '—'}
              </Text>
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}

function DefectCells({ project, d }: { project: string; d: DefectSummary }) {
  return (
    <>
      <Table.Td>
        <Group gap={6}>
          <Anchor component={Link} to={`/p/${project}/defects?selected=${d.key}`} ff="monospace" fw={600} size="sm">
            {d.key}
          </Anchor>
          <Text size="sm">{d.title}</Text>
        </Group>
      </Table.Td>
      <Table.Td>
        <SeverityBadge severity={d.severity} />
      </Table.Td>
      <Table.Td>
        <DefectStatusBadge status={d.status} />
      </Table.Td>
    </>
  );
}

/** §13.2 fiche exigence, onglet « Exécutions » : exécutions des tests liés, de la plus récente à la plus ancienne. */
export function RequirementExecutionsPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useRequirementExecutions(project, requirementKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noExecution')}</Text>;
  return <ExecutionsTable project={project} data={data} showTest testId="requirement-executions" />;
}

/**
 * §13.2 / ADR-0018 fiche exigence, onglet « Anomalies » : anomalies rattachées, puis celles trouvées
 * par traçabilité (exécutions des tests liés), qu'on peut rattacher d'un clic.
 */
export function RequirementDefectsPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useRequirementDefects(project, requirementKey);
  const canUpdate = useCanUpdateDefects(project);
  const link = useLinkDefectToRequirement(project, requirementKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noDefect')}</Text>;
  return (
    <Table striped data-testid="requirement-defects">
      <Table.Tbody>
        {data.map(({ defect: d, linked, viaTests }) => (
          <Table.Tr key={d.key} data-testid={`requirement-defect-${d.key}`}>
            <DefectCells project={project} d={d} />
            <Table.Td>
              <Group gap={6} justify="flex-end">
                {viaTests.length > 0 && (
                  <Text size="xs" c="dimmed">
                    {t('requirementRuns.via', { tests: viaTests.join(', ') })}
                  </Text>
                )}
                {linked ? (
                  <Badge size="sm" variant="light" color="blue">
                    {t('requirementRuns.linked')}
                  </Badge>
                ) : (
                  <Tooltip label={t('requirementRuns.tracedHint')}>
                    <Badge size="sm" variant="outline" color="gray">
                      {t('requirementRuns.traced')}
                    </Badge>
                  </Tooltip>
                )}
                {!linked && canUpdate && (
                  <Button size="compact-xs" variant="light" leftSection={<IconLink size={12} />} loading={link.isPending && link.variables === d.key}
                    onClick={() => link.mutate(d.key, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) })}
                    data-testid={`link-defect-${d.key}`}>
                    {t('requirementRuns.link')}
                  </Button>
                )}
              </Group>
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}

/** ADR-0018 fiche test, onglet « Exécutions » : toutes ses tentatives, toutes campagnes confondues. */
export function TestExecutionsPanel({ project, testKey }: { project: string; testKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useTestExecutions(project, testKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noTestExecution')}</Text>;
  return <ExecutionsTable project={project} data={data} showTest={false} testId="test-executions" />;
}

/** ADR-0018 fiche test, onglet « Anomalies » : anomalies liées à ses exécutions. */
export function TestDefectsPanel({ project, testKey }: { project: string; testKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useTestDefects(project, testKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noTestDefect')}</Text>;
  return (
    <Table striped data-testid="test-defects">
      <Table.Tbody>
        {data.map((d) => (
          <Table.Tr key={d.key}>
            <DefectCells project={project} d={d} />
            <Table.Td>
              <Text size="xs" c="dimmed">
                {d.requirementKeys.join(', ') || '—'}
              </Text>
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}
