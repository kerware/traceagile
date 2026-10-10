import { Alert, Anchor, Badge, Card, Group, Loader, Progress, RingProgress, SimpleGrid, Stack, Table, Text, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import { ApiError, errorMessage } from '../../api/errors';
import { useProject } from '../../api/queries';
import { useDashboard, type Dashboard } from '../../api/reports';
import { ColumnChart, LineChart } from '../../components/charts/Charts';
import { Forbidden } from '../../components/Forbidden';
import { RunStatusBadge } from '../automation/RunBadges';
import type { RunStatus } from '../automation/types';
import { EXECUTION_COLORS, SEVERITY_COLORS } from '../campaigns/model';
import { shortDate, percentLabel } from './model';

/** §13.2 /p/:key/dashboard — widgets (F-RPT-01) et graphiques (F-RPT-02) du §9.1. */
export function DashboardPage() {
  const { t } = useTranslation();
  const key = useParams().key!;
  const project = useProject(key);
  const { data, error, isLoading } = useDashboard(key);

  if (isLoading || project.isLoading) return <Loader />;
  if ((error instanceof ApiError && error.status === 403) || (project.error instanceof ApiError && project.error.status === 403)) return <Forbidden />;
  if (error || !data) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  return (
    <Stack data-testid="dashboard">
      <Title order={2}>{t('dashboard.welcome', { name: project.data?.name ?? key })}</Title>
      <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }}>
        <ActiveSprintCard project={key} data={data} />
        <CoverageCard data={data} />
        <LastCampaignCard project={key} data={data} />
        <DefectsCard project={key} data={data} />
        <SessionsCard project={key} data={data} />
        <RunsCard project={key} data={data} />
      </SimpleGrid>
      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <Card withBorder data-testid="chart-burndown">
          <Title order={5}>{t('dashboard.burndown', { sprint: data.activeSprint?.key ?? '' })}</Title>
          {data.burndown?.length ? (
            <LineChart label={t('dashboard.burndown', { sprint: data.activeSprint?.key ?? '' })} categories={data.burndown.map((p) => shortDate(p.label))}
              series={[
                { name: t('dashboard.remaining'), values: data.burndown.map((p) => p.actual), color: 'var(--mantine-color-blue-6)' },
                { name: t('dashboard.ideal'), values: data.burndown.map((p) => p.reference), color: 'var(--mantine-color-gray-5)' },
              ]} />
          ) : (
            <Text c="dimmed" size="sm">{t('dashboard.noActiveSprint')}</Text>
          )}
        </Card>
        <Card withBorder data-testid="chart-burnup">
          <Title order={5}>{t('dashboard.burnup', { release: data.releaseKey ?? '' })}</Title>
          {data.burnup?.length ? (
            <LineChart label={t('dashboard.burnup', { release: data.releaseKey ?? '' })} categories={data.burnup.map((p) => p.label ?? '')}
              series={[
                { name: t('dashboard.done'), values: data.burnup.map((p) => p.actual), color: 'var(--mantine-color-teal-6)' },
                { name: t('dashboard.total'), values: data.burnup.map((p) => p.reference), color: 'var(--mantine-color-gray-5)' },
              ]} />
          ) : (
            <Text c="dimmed" size="sm">{t('dashboard.noRelease')}</Text>
          )}
        </Card>
        <Card withBorder data-testid="chart-pass-rate">
          <Title order={5}>{t('dashboard.passRateTrend')}</Title>
          {data.automatedTrend?.length ? (
            <ColumnChart label={t('dashboard.passRateTrend')} categories={data.automatedTrend.map((r) => r.key ?? '')}
              series={[{ name: t('dashboard.passRate'), values: data.automatedTrend.map((r) => r.passRate), color: 'var(--mantine-color-green-6)' }]} />
          ) : (
            <Text c="dimmed" size="sm">{t('dashboard.noRuns')}</Text>
          )}
        </Card>
        <Card withBorder data-testid="chart-defects-by-sprint">
          <Title order={5}>{t('dashboard.defectsBySprint')}</Title>
          {data.defectsBySprint?.length ? (
            <ColumnChart label={t('dashboard.defectsBySprint')} categories={data.defectsBySprint.map((s) => s.key ?? '')}
              series={[
                { name: t('dashboard.opened'), values: data.defectsBySprint.map((s) => s.defectsCreated), color: 'var(--mantine-color-red-6)' },
                { name: t('dashboard.closed'), values: data.defectsBySprint.map((s) => s.defectsClosed), color: 'var(--mantine-color-gray-6)' },
              ]} />
          ) : (
            <Text c="dimmed" size="sm">{t('dashboard.noRelease')}</Text>
          )}
        </Card>
      </SimpleGrid>
    </Stack>
  );
}

function ActiveSprintCard({ project, data }: { project: string; data: Dashboard }) {
  const { t } = useTranslation();
  const sprint = data.activeSprint;
  return (
    <Card withBorder data-testid="widget-sprint">
      <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
        {t('dashboard.activeSprint')}
      </Text>
      {sprint ? (
        <Stack gap={6} mt="xs">
          <Anchor component={Link} to={`/p/${project}/planning?sprint=${sprint.key}`} fw={600}>
            {sprint.key} — {sprint.name}
          </Anchor>
          {sprint.goal && (
            <Text size="sm" c="dimmed" lineClamp={2}>
              {sprint.goal}
            </Text>
          )}
          <Text size="sm" data-testid="widget-sprint-days">
            {t('dashboard.daysLeft', { count: sprint.daysLeft ?? 0 })}
          </Text>
          <Progress value={sprint.committedPoints ? ((sprint.donePoints ?? 0) * 100) / sprint.committedPoints : 0} />
          <Text size="sm" data-testid="widget-sprint-points">
            {t('dashboard.points', { done: sprint.donePoints ?? 0, committed: sprint.committedPoints ?? 0 })}
          </Text>
        </Stack>
      ) : (
        <Text c="dimmed" size="sm" mt="xs">
          {t('dashboard.noActiveSprint')}
        </Text>
      )}
    </Card>
  );
}

function CoverageCard({ data }: { data: Dashboard }) {
  const { t } = useTranslation();
  const rows = [
    { label: t('dashboard.sprint'), coverage: data.sprintCoverage },
    { label: t('dashboard.release'), coverage: data.releaseCoverage },
  ];
  return (
    <Card withBorder data-testid="widget-coverage">
      <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
        {t('dashboard.coverage')}
      </Text>
      <Table mt="xs">
        <Table.Thead>
          <Table.Tr>
            <Table.Th />
            <Table.Th>{t('dashboard.design')}</Table.Th>
            <Table.Th>{t('dashboard.validation')}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {rows.map((r) => (
            <Table.Tr key={r.label}>
              <Table.Td>{r.label}</Table.Td>
              <Table.Td>{percentLabel(r.coverage?.design?.percent)}</Table.Td>
              <Table.Td data-testid={`coverage-validation-${r.label}`}>{percentLabel(r.coverage?.validation?.percent)}</Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
    </Card>
  );
}

function LastCampaignCard({ project, data }: { project: string; data: Dashboard }) {
  const { t } = useTranslation();
  const campaign = data.lastCampaign;
  const entries = Object.entries(campaign?.byStatus ?? {});
  const total = campaign?.total ?? 0;
  return (
    <Card withBorder data-testid="widget-campaign">
      <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
        {t('dashboard.lastCampaign')}
      </Text>
      {campaign ? (
        <Group mt="xs" wrap="nowrap" align="center">
          <RingProgress size={110} thickness={14} label={<Text ta="center" size="sm" fw={700}>{total}</Text>}
            sections={entries.map(([status, n]) => ({
              value: total ? (n * 100) / total : 0,
              color: EXECUTION_COLORS[status as keyof typeof EXECUTION_COLORS] ?? 'gray',
              tooltip: `${t(`executionStatus.${status}`)} : ${n}`,
            }))} />
          <Stack gap={2}>
            <Anchor component={Link} to={`/p/${project}/campaigns/${campaign.key}`} fw={600} size="sm">
              {campaign.key} {campaign.name}
            </Anchor>
            {entries.map(([status, n]) => (
              <Text key={status} size="xs" data-testid={`widget-campaign-${status}`}>
                <Badge size="xs" variant="dot" color={EXECUTION_COLORS[status as keyof typeof EXECUTION_COLORS] ?? 'gray'}>
                  {t(`executionStatus.${status}`)}
                </Badge>{' '}
                {n}
              </Text>
            ))}
          </Stack>
        </Group>
      ) : (
        <Text c="dimmed" size="sm" mt="xs">
          {t('dashboard.noCampaign')}
        </Text>
      )}
    </Card>
  );
}

function DefectsCard({ project, data }: { project: string; data: Dashboard }) {
  const { t } = useTranslation();
  const entries = Object.entries(data.openDefectsBySeverity ?? {});
  const max = Math.max(1, ...entries.map(([, n]) => n));
  return (
    <Card withBorder data-testid="widget-defects">
      <Group justify="space-between">
        <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
          {t('dashboard.openDefects')}
        </Text>
        <Anchor component={Link} to={`/p/${project}/defects`} size="xs">
          {t('dashboard.seeAll')}
        </Anchor>
      </Group>
      <Stack gap={6} mt="xs">
        {entries.map(([severity, n]) => (
          <Group key={severity} gap="xs" wrap="nowrap">
            <Text size="xs" w={70}>
              {t(`severity.${severity}`)}
            </Text>
            <Progress value={(n * 100) / max} color={SEVERITY_COLORS[severity as keyof typeof SEVERITY_COLORS]} style={{ flex: 1 }} />
            <Text size="xs" w={20} ta="right" data-testid={`widget-defects-${severity}`}>
              {n}
            </Text>
          </Group>
        ))}
      </Stack>
    </Card>
  );
}

function SessionsCard({ project, data }: { project: string; data: Dashboard }) {
  const { t } = useTranslation();
  const week = data.weekSessions;
  return (
    <Card withBorder data-testid="widget-sessions">
      <Group justify="space-between">
        <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
          {t('dashboard.weekSessions')}
        </Text>
        <Anchor component={Link} to={`/p/${project}/exploratory`} size="xs">
          {t('dashboard.seeAll')}
        </Anchor>
      </Group>
      <Group mt="xs" gap="xl">
        <Stack gap={0}>
          <Text fz={28} fw={700} data-testid="widget-sessions-count">
            {week?.sessions ?? 0}
          </Text>
          <Text size="xs" c="dimmed">
            {t('dashboard.sessions')}
          </Text>
        </Stack>
        <Stack gap={0}>
          <Text fz={28} fw={700}>
            {week?.minutes ?? 0}
          </Text>
          <Text size="xs" c="dimmed">
            {t('dashboard.minutes')}
          </Text>
        </Stack>
      </Group>
      <Text size="xs" c="dimmed" mt="xs">
        {t('dashboard.debriefed', { debriefed: week?.debriefed ?? 0, pending: week?.awaitingApproval ?? 0 })}
      </Text>
    </Card>
  );
}

function RunsCard({ project, data }: { project: string; data: Dashboard }) {
  const { t } = useTranslation();
  const runs = data.lastRuns ?? [];
  return (
    <Card withBorder data-testid="widget-runs">
      <Text size="xs" tt="uppercase" c="dimmed" fw={700}>
        {t('dashboard.lastRuns')}
      </Text>
      {runs.length === 0 ? (
        <Text c="dimmed" size="sm" mt="xs">
          {t('dashboard.noRuns')}
        </Text>
      ) : (
        <Table mt="xs">
          <Table.Tbody>
            {runs.map((run) => (
              <Table.Tr key={run.key} data-testid={`widget-run-${run.key}`}>
                <Table.Td>
                  <Anchor component={Link} to={`/p/${project}/runs/${run.key}`} size="sm" ff="monospace">
                    {run.key}
                  </Anchor>
                </Table.Td>
                <Table.Td>
                  <RunStatusBadge status={run.status as RunStatus} />
                </Table.Td>
                <Table.Td>
                  <Text size="xs">{t('dashboard.runResult', { passed: run.passed ?? 0, total: run.total ?? 0 })}</Text>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
    </Card>
  );
}
