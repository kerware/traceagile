import { Alert, Anchor, Badge, Button, Card, Code, Group, Loader, ScrollArea, SimpleGrid, Stack, Table, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlayerStop, IconRefresh, IconRepeat } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useCancelRun, useLiveRun, useRerunFailed, useRun, useRunLogs, type RunDetail } from '../../api/automation';
import { errorMessage } from '../../api/errors';
import { ExecutionStatusBadge } from '../campaigns/CampaignBadges';
import { duration } from '../campaigns/model';
import { TechniqueBadge } from '../tests/Badges';
import { useCanLaunchRuns } from './model';
import { FlakyBadge, RunProgress, RunStatusBadge } from './RunBadges';

/** §13.2 /p/:key/runs/:rk — run automatisé : statut en temps réel (F-EXE-07), tests, journaux, annulation, relance des échecs. */
export function RunPage() {
  const { t } = useTranslation();
  const { key: project, rk } = useParams() as { key: string; rk: string };
  const { data, isLoading, error } = useRun(project, rk);
  useLiveRun(project, rk);

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  return <RunView project={project} detail={data} />;
}

function RunView({ project, detail }: { project: string; detail: RunDetail }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const run = detail.run;
  const canLaunch = useCanLaunchRuns(project);
  const cancel = useCancelRun(project, run.key);
  const rerun = useRerunFailed(project, run.key);
  const [logsOpen, setLogsOpen] = useState(false);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const failures = run.counts.failed + run.counts.error;

  return (
    <Stack data-testid="run-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={2}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace">
              {run.key}
            </Badge>
            <Title order={2}>{t('runs.title', { server: run.serverName })}</Title>
            <RunStatusBadge status={run.status} testId="run-status" />
          </Group>
          <Text size="sm" c="dimmed">
            <Anchor component={Link} to={`/p/${project}/campaigns/${run.campaign.key}`} size="sm">
              {run.campaign.key} {run.campaign.name}
            </Anchor>
            {` · ${t('campaigns.environment')} : ${run.environment ?? '—'} · ${t('campaigns.build')} : ${run.buildVersion ?? '—'}`}
            {run.agent ? ` · ${t('runs.agent', { agent: run.agent })}` : ''}
            {run.rerunOf ? ` · ${t('runs.rerunOf', { key: run.rerunOf })}` : ''}
          </Text>
          <Text size="xs" c="dimmed">
            {t('runs.requested', { by: run.requestedBy ?? '—', at: new Date(run.requestedAt).toLocaleString() })}
            {run.externalJobId ? ` · job ${run.externalJobId}` : ''}
          </Text>
        </Stack>
        {canLaunch && (
          <Group>
            {detail.cancellable && (
              <Button color="red" variant="light" leftSection={<IconPlayerStop size={16} />} onClick={() => cancel.mutate(undefined, { onError: fail })}
                loading={cancel.isPending} data-testid="run-cancel">
                {t('runs.cancel')}
              </Button>
            )}
            {!detail.cancellable && failures > 0 && (
              <Button leftSection={<IconRepeat size={16} />} onClick={() => rerun.mutate(undefined, {
                onSuccess: (r) => navigate(`/p/${project}/runs/${r.run.key}`),
                onError: fail,
              })} loading={rerun.isPending} data-testid="run-rerun-failed">
                {t('runs.rerunFailed', { count: failures })}
              </Button>
            )}
          </Group>
        )}
      </Group>

      {run.errorMessage && (
        <Alert color={run.status === 'CANCELLED' ? 'orange' : 'red'} data-testid="run-error">
          {run.errorCode ? `${run.errorCode} : ` : ''}
          {run.errorMessage}
        </Alert>
      )}

      <Card withBorder>
        <RunProgress counts={run.counts} />
      </Card>

      <Table striped data-testid="run-executions">
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t('campaigns.test')}</Table.Th>
            <Table.Th>{t('runs.identifier')}</Table.Th>
            <Table.Th>{t('runs.status')}</Table.Th>
            <Table.Th>{t('runs.duration')}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {detail.executions.map((e) => (
            <Table.Tr key={e.id} data-testid={`run-test-${e.test.key}`}>
              <Table.Td>
                <Group gap={6} wrap="nowrap">
                  <Anchor component={Link} to={`/p/${project}/tests/${e.test.key}`} ff="monospace" fw={600} size="sm">
                    {e.test.key}
                  </Anchor>
                  <TechniqueBadge technique={e.technique} />
                  <Text size="sm">{e.test.title}</Text>
                  {e.flaky && <FlakyBadge />}
                </Group>
                {e.message && (
                  <Code block mt={4} c="red" style={{ whiteSpace: 'pre-wrap', maxHeight: 120, overflow: 'auto' }} data-testid={`run-message-${e.test.key}`}>
                    {e.message}
                  </Code>
                )}
              </Table.Td>
              <Table.Td>
                <Text size="xs" ff="monospace">
                  {e.testIdentifier ?? '—'}
                </Text>
              </Table.Td>
              <Table.Td>
                <ExecutionStatusBadge status={e.status} testId={`run-status-${e.test.key}`} />
              </Table.Td>
              <Table.Td>
                <Text size="sm">{duration(e.durationMs)}</Text>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>

      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <Card withBorder>
          <Group justify="space-between">
            <Title order={5}>{t('runs.logs')}</Title>
            <Button size="xs" variant="subtle" leftSection={<IconRefresh size={14} />} onClick={() => setLogsOpen(true)} data-testid="run-logs-load">
              {logsOpen ? t('runs.refreshLogs') : t('runs.showLogs')}
            </Button>
          </Group>
          {logsOpen && <Logs project={project} runKey={run.key} />}
        </Card>
        {run.reportUrl && (
          <Card withBorder>
            <Title order={5}>{t('runs.artifacts')}</Title>
            <Text size="sm" c="dimmed" mt="xs">
              {t('runs.reportAt')}
            </Text>
            <Code>{run.reportUrl}</Code>
          </Card>
        )}
      </SimpleGrid>
    </Stack>
  );
}

function Logs({ project, runKey }: { project: string; runKey: string }) {
  const { t } = useTranslation();
  const { data, isFetching } = useRunLogs(project, runKey, true);
  if (isFetching && !data) return <Loader size="sm" />;
  return (
    <ScrollArea h={240} mt="xs" data-testid="run-logs">
      <Code block>{data || t('runs.noLogs')}</Code>
    </ScrollArea>
  );
}
