import { Anchor, Group, Loader, Table, Text } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useRequirementDefects, useRequirementExecutions } from '../../api/campaigns';
import { DefectStatusBadge, ExecutionStatusBadge, SeverityBadge } from './CampaignBadges';

/** §13.2 fiche exigence, onglet « Exécutions » : exécutions des tests liés, de la plus récente à la plus ancienne. */
export function RequirementExecutionsPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useRequirementExecutions(project, requirementKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noExecution')}</Text>;
  return (
    <Table striped data-testid="requirement-executions">
      <Table.Tbody>
        {data.map((e) => (
          <Table.Tr key={e.id}>
            <Table.Td>
              <Anchor component={Link} to={`/p/${project}/executions/${e.id}`} ff="monospace" fw={600} size="sm">
                {e.test.key}
              </Anchor>{' '}
              <Text span size="sm">
                {e.test.title}
              </Text>
            </Table.Td>
            <Table.Td>
              <Text size="sm">
                {e.campaign.key} · {t('executions.attempt', { n: e.attempt })}
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

/** §13.2 fiche exigence, onglet « Anomalies ». */
export function RequirementDefectsPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useRequirementDefects(project, requirementKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('requirementRuns.noDefect')}</Text>;
  return (
    <Table striped data-testid="requirement-defects">
      <Table.Tbody>
        {data.map((d) => (
          <Table.Tr key={d.key}>
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
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}
