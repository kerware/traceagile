import { Alert, Anchor, Badge, Button, Card, Group, Loader, Select, SimpleGrid, Stack, Table, Tabs, TagsInput, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlayerPlay } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useCampaigns, useMyExecutions } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import {
  useExploratoryMetrics,
  useHeuristics,
  useSessions,
  useSetHeuristics,
  useStartSession,
  type SessionState,
  type SessionSummary,
} from '../../api/exploratory';
import { useReleases, useSprints } from '../../api/planning';
import { useTestList } from '../../api/testcases';
import { ExecutionStatusBadge } from '../campaigns/CampaignBadges';
import { useCanExecute } from '../campaigns/permissions';
import { TestStatusBadge } from '../tests/Badges';
import { useTestWriteKinds } from '../tests/permissions';
import { clock, SESSION_STATE_COLORS } from './model';

/** §13.2 /p/:key/exploratory — chartes, sessions à faire et en cours, sessions à débriefer, métriques (§5.4). */
export function ExploratoryPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  return (
    <Stack data-testid="exploratory-page">
      <Title order={2}>{t('exploratory.title')}</Title>
      <Tabs defaultValue="sessions" keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="sessions" data-testid="exploratory-tab-sessions">{t('exploratory.sessions')}</Tabs.Tab>
          <Tabs.Tab value="charters" data-testid="exploratory-tab-charters">{t('exploratory.charters')}</Tabs.Tab>
          <Tabs.Tab value="metrics" data-testid="exploratory-tab-metrics">{t('exploratory.metrics')}</Tabs.Tab>
          <Tabs.Tab value="heuristics" data-testid="exploratory-tab-heuristics">{t('exploratory.heuristics')}</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="sessions" pt="md">
          <Sessions project={project} />
        </Tabs.Panel>
        <Tabs.Panel value="charters" pt="md">
          <Charters project={project} />
        </Tabs.Panel>
        <Tabs.Panel value="metrics" pt="md">
          <Metrics project={project} />
        </Tabs.Panel>
        <Tabs.Panel value="heuristics" pt="md">
          <Heuristics project={project} />
        </Tabs.Panel>
      </Tabs>
    </Stack>
  );
}

function Sessions({ project }: { project: string }) {
  const { t } = useTranslation();
  return (
    <Stack>
      <ToDo project={project} />
      <SessionList project={project} states={['RUNNING', 'PAUSED']} title={t('exploratory.inProgress')} testId="sessions-in-progress" />
      <SessionList project={project} states={['FINISHED']} title={t('exploratory.toDebrief')} testId="sessions-to-debrief" />
      <SessionList project={project} states={['DEBRIEFED']} title={t('exploratory.debriefed')} testId="sessions-debriefed" />
    </Stack>
  );
}

/** F-EXP-05 mes chartes à jouer dans les campagnes ouvertes. */
function ToDo({ project }: { project: string }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const canExecute = useCanExecute(project);
  const { data } = useMyExecutions(project);
  const start = useStartSession(project);
  const items = (data ?? []).filter((i) => i.test.kind === 'EXPLORATORY' && (i.lastStatus === 'NOT_RUN' || i.lastStatus === 'RUNNING'));
  if (!canExecute) return null;
  return (
    <Card withBorder data-testid="sessions-todo">
      <Title order={5} mb="xs">
        {t('exploratory.todo', { count: items.length })}
      </Title>
      {items.length === 0 && <Text c="dimmed" size="sm">{t('exploratory.noTodo')}</Text>}
      <Stack gap={4}>
        {items.map((item) => (
          <Group key={item.itemId} justify="space-between" data-testid={`todo-${item.test.key}`}>
            <Text size="sm">
              <Text span ff="monospace" fw={600}>
                {item.test.key}
              </Text>{' '}
              {item.test.title} · {item.campaign.key}
            </Text>
            <Button size="xs" leftSection={<IconPlayerPlay size={14} />} loading={start.isPending && start.variables === item.itemId}
              onClick={() =>
                item.lastStatus === 'RUNNING' && item.latestExecutionId
                  ? navigate(`/p/${project}/sessions/${item.latestExecutionId}`)
                  : start.mutate(item.itemId, {
                      onSuccess: (s) => navigate(`/p/${project}/sessions/${s.id}`),
                      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
                    })
              }
              data-testid={`start-${item.test.key}`}>
              {item.lastStatus === 'RUNNING' ? t('campaigns.resume') : t('exploratory.start')}
            </Button>
          </Group>
        ))}
      </Stack>
    </Card>
  );
}

function SessionList({ project, states, title, testId }: { project: string; states: SessionState[]; title: string; testId: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useSessions(project, states);
  return (
    <Card withBorder data-testid={testId}>
      <Title order={5} mb="xs">
        {title} ({data?.length ?? 0})
      </Title>
      {isLoading && <Loader size="sm" />}
      {data && data.length === 0 && <Text c="dimmed" size="sm">{t('exploratory.none')}</Text>}
      {data && data.length > 0 && (
        <Table striped>
          <Table.Tbody>
            {data.map((s) => (
              <SessionRow key={s.id} project={project} session={s} />
            ))}
          </Table.Tbody>
        </Table>
      )}
    </Card>
  );
}

function SessionRow({ project, session: s }: { project: string; session: SessionSummary }) {
  const { t } = useTranslation();
  return (
    <Table.Tr data-testid={`session-row-${s.charter.key}-${s.attempt}`}>
      <Table.Td>
        <Anchor component={Link} to={`/p/${project}/sessions/${s.id}`} ff="monospace" fw={600} size="sm">
          {s.charter.key}
        </Anchor>{' '}
        <Text span size="sm">
          {s.charter.title}
        </Text>
      </Table.Td>
      <Table.Td>
        <Text size="sm">
          {s.campaign.key} · {t('session.attemptShort', { n: s.attempt })} · {s.tester}
        </Text>
      </Table.Td>
      <Table.Td>
        <Text size="sm" ff="monospace">
          {s.durationMin !== undefined && s.durationMin !== null ? `${s.durationMin} / ${s.timeboxMin} min` : clock(s.elapsedSeconds)}
        </Text>
      </Table.Td>
      <Table.Td>
        <Group gap={4}>
          <Badge color={SESSION_STATE_COLORS[s.state]} variant="light">
            {t(`sessionState.${s.state}`)}
          </Badge>
          {s.state !== 'RUNNING' && s.state !== 'PAUSED' && <ExecutionStatusBadge status={s.status} />}
          {s.state === 'FINISHED' && (
            <Badge variant="outline" color={s.debriefed ? 'blue' : 'orange'}>
              {s.debriefed ? t('exploratory.awaitingApproval') : t('exploratory.debriefMissing')}
            </Badge>
          )}
        </Group>
      </Table.Td>
      <Table.Td>
        <Text size="xs" c="dimmed">
          {t('exploratory.notesCount', { count: s.notes })}
          {s.bugs > 0 && ` · ${t('exploratory.bugsCount', { count: s.bugs })}`}
          {s.feelings ? ` · ${'★'.repeat(s.feelings)}` : ''}
        </Text>
      </Table.Td>
    </Table.Tr>
  );
}

function Charters({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useTestList(project, { kind: ['EXPLORATORY'] }, 0, 'key,asc');
  if (isLoading) return <Loader />;
  return (
    <Stack gap="xs">
      <Text size="sm" c="dimmed">
        {t('exploratory.chartersHint')}
      </Text>
      <Table striped data-testid="charter-list">
        <Table.Tbody>
          {(data?.content ?? []).map((c) => (
            <Table.Tr key={c.key}>
              <Table.Td>
                <Anchor component={Link} to={`/p/${project}/tests/${c.key}`} ff="monospace" fw={600} size="sm">
                  {c.key}
                </Anchor>
              </Table.Td>
              <Table.Td>{c.title}</Table.Td>
              <Table.Td>
                <TestStatusBadge status={c.status} />
              </Table.Td>
              <Table.Td>
                <Text size="xs" c="dimmed">
                  {t('exploratory.executions', { count: c.executionCount })}
                </Text>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
    </Stack>
  );
}

/** §5.4 métriques par projet, campagne, sprint ou release. */
function Metrics({ project }: { project: string }) {
  const { t } = useTranslation();
  const [scope, setScope] = useState('project');
  const { data: campaigns } = useCampaigns(project);
  const { data: sprints } = useSprints(project);
  const { data: releases } = useReleases(project);
  const { data: m, error } = useExploratoryMetrics(project, scope);
  const options = [
    { group: t('exploratory.scopeProject'), items: [{ value: 'project', label: t('exploratory.wholeProject') }] },
    { group: t('exploratory.scopeReleases'), items: (releases ?? []).map((r) => ({ value: `release:${r.key}`, label: `${r.key} — ${r.name}` })) },
    { group: t('exploratory.scopeSprints'), items: (sprints ?? []).map((s) => ({ value: `sprint:${s.key}`, label: `${s.key} — ${s.name}` })) },
    { group: t('exploratory.scopeCampaigns'), items: (campaigns ?? []).map((c) => ({ value: `campaign:${c.key}`, label: `${c.key} — ${c.name}` })) },
  ].filter((g) => g.items.length > 0);
  const value = (v: number | null | undefined, suffix = '') => (v === undefined || v === null ? '—' : `${v}${suffix}`);

  return (
    <Stack>
      <Select label={t('exploratory.scope')} data={options} value={scope} onChange={(v) => v && setScope(v)} allowDeselect={false} w={360} searchable
        data-testid="metrics-scope" />
      {error && <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>}
      {m && (
        <SimpleGrid cols={{ base: 2, md: 4 }} data-testid="metrics">
          <Metric label={t('exploratory.m.sessions')} value={String(m.sessions)} hint={t('exploratory.m.sessionsHint', { inProgress: m.inProgress, debriefed: m.debriefed })} testId="m-sessions" />
          <Metric label={t('exploratory.m.duration')} value={`${m.totalMinutes} min`} hint={t('exploratory.m.durationHint', { average: value(m.averageMinutes), target: value(m.averageTimeboxMin) })} testId="m-duration" />
          <Metric label={t('exploratory.m.vsTarget')} value={value(m.durationVsTargetPct, ' %')} testId="m-target" />
          <Metric label={t('exploratory.m.tbs')} value={m.averageTbs ? `${m.averageTbs.testPct} / ${m.averageTbs.bugPct} / ${m.averageTbs.setupPct}` : '—'} hint={t('exploratory.m.tbsHint')} testId="m-tbs" />
          <Metric label={t('exploratory.m.defectsPerHour')} value={value(m.defectsPerHour)} testId="m-defects" />
          <Metric label={t('exploratory.m.charters')} value={`${m.chartersExecuted} / ${m.chartersPlanned}`} hint={t('exploratory.m.chartersHint')} testId="m-charters" />
          <Metric label={t('exploratory.m.confidence')} value={value(m.averageConfidence, ' / 5')} testId="m-confidence" />
          <Metric label={t('exploratory.m.toApprove')} value={String(m.awaitingApproval)} testId="m-approve" />
        </SimpleGrid>
      )}
      {m && (
        <Card withBorder data-testid="m-never-explored">
          <Text size="sm" fw={600} mb={4}>
            {t('exploratory.m.neverExplored')}
          </Text>
          {m.neverExploredAreas.length === 0 ? (
            <Text size="sm" c="dimmed">{t('exploratory.m.allExplored')}</Text>
          ) : (
            <Group gap={4}>
              {m.neverExploredAreas.map((a) => (
                <Badge key={a} color="orange" variant="light">
                  {a}
                </Badge>
              ))}
            </Group>
          )}
        </Card>
      )}
    </Stack>
  );
}

function Metric({ label, value, hint, testId }: { label: string; value: string; hint?: string; testId: string }) {
  return (
    <Card withBorder p="sm" data-testid={testId}>
      <Text size="xs" c="dimmed">
        {label}
      </Text>
      <Text size="xl" fw={700}>
        {value}
      </Text>
      {hint && (
        <Text size="xs" c="dimmed">
          {hint}
        </Text>
      )}
    </Card>
  );
}

/** F-EXP-02 heuristiques suggérées et propres au projet. */
function Heuristics({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data } = useHeuristics(project);
  const save = useSetHeuristics(project);
  const canWrite = useTestWriteKinds(project).includes('EXPLORATORY');
  const [custom, setCustom] = useState<string[]>([]);
  useEffect(() => {
    if (data) setCustom(data.custom);
  }, [data]);
  if (!data) return <Loader />;
  return (
    <Stack maw={720}>
      <Text size="sm">{t('exploratory.suggestedHeuristics')}</Text>
      <Group gap={4}>
        {data.suggested.map((h) => (
          <Badge key={h} variant="outline" color="grape">
            {h}
          </Badge>
        ))}
      </Group>
      <TagsInput label={t('exploratory.customHeuristics')} description={t('exploratory.customHeuristicsHint')} value={custom} onChange={setCustom}
        disabled={!canWrite} data-testid="custom-heuristics" />
      {canWrite && (
        <Group justify="flex-end">
          <Button onClick={() => save.mutate(custom, {
            onSuccess: () => notifications.show({ color: 'green', message: t('exploratory.heuristicsSaved') }),
            onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
          })} loading={save.isPending} data-testid="heuristics-save">
            {t('test.save')}
          </Button>
        </Group>
      )}
    </Stack>
  );
}
