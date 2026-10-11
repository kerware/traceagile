import { Alert, Anchor, Card, Group, Loader, Progress, SimpleGrid, Stack, Table, Text, Title } from '@mantine/core';
import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { dateTime, duration, getJson, type Dashboard, type Job } from '../api';
import { JobStatusBadge } from '../components/Badges';
import { DayChart } from '../components/DayChart';

/** Suivi : activité en direct, 7 derniers jours, série quotidienne, frameworks, tests en échec, outils. */
export function DashboardPage() {
  const { data, isLoading, error } = useQuery({ queryKey: ['dashboard'], queryFn: () => getJson<Dashboard>('/api/admin/dashboard'), refetchInterval: 5000 });
  const { data: jobs } = useQuery({ queryKey: ['jobs', 'recent'], queryFn: () => getJson<Job[]>('/api/admin/jobs?limit=6'), refetchInterval: 5000 });

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">Tableau de bord indisponible : {(error as Error)?.message}</Alert>;
  const busy = data.live.agents === 0 ? 0 : Math.round((100 * data.live.busyAgents) / data.live.agents);

  return (
    <Stack data-testid="dashboard">
      <Title order={2}>Tableau de bord</Title>
      <SimpleGrid cols={{ base: 1, xs: 2, md: 4 }}>
        <Kpi label="Jobs en cours" value={data.live.runningJobs} hint={`${data.live.pendingTests} test(s) en attente`} testId="kpi-running" />
        <Card withBorder data-testid="kpi-agents">
          <Text size="xs" tt="uppercase" fw={600} c="dimmed">
            Agents occupés
          </Text>
          <Text fz={28} fw={700} style={{ fontVariantNumeric: 'tabular-nums' }}>
            {data.live.busyAgents} / {data.live.agents}
          </Text>
          <Progress value={busy} mt={6} aria-label={`Agents occupés : ${busy} %`} />
        </Card>
        <Kpi label="Taux de réussite (7 j)" value={data.week.passRate === null ? '—' : `${data.week.passRate.toLocaleString('fr-FR')} %`}
          hint={`${data.week.passed} réussis, ${data.week.failed} échoués, ${data.week.errors} erreurs`} testId="kpi-pass-rate"
          color={data.week.passRate === null ? undefined : data.week.passRate >= 90 ? 'teal' : data.week.passRate >= 70 ? 'orange' : 'red'} />
        <Kpi label="Jobs (7 j)" value={data.week.jobs} hint={`${data.week.tests} tests · durée moyenne ${duration(data.week.averageJobMs)}`} testId="kpi-jobs" />
      </SimpleGrid>

      <Card withBorder>
        <Title order={4} mb="sm">
          Tests exécutés par jour
        </Title>
        <DayChart days={data.days} />
      </Card>

      <SimpleGrid cols={{ base: 1, lg: 2 }}>
        <Card withBorder>
          <Group justify="space-between" mb="sm">
            <Title order={4}>Derniers jobs</Title>
            <Anchor component={Link} to="/jobs" size="sm">
              Tous les jobs
            </Anchor>
          </Group>
          {(jobs ?? []).length === 0 ? (
            <Text c="dimmed" size="sm">
              Aucun job reçu. Appairez ce serveur dans TraceAgile (Administration › Serveurs d'exécution) puis lancez un run.
            </Text>
          ) : (
            <Table verticalSpacing={6} data-testid="recent-jobs">
              <Table.Tbody>
                {(jobs ?? []).map((job) => (
                  <Table.Tr key={job.id}>
                    <Table.Td>
                      <Anchor component={Link} to={`/jobs/${job.id}`} ff="monospace" size="sm">
                        {job.runId}
                      </Anchor>
                      <Text size="xs" c="dimmed">
                        {dateTime(job.submittedAt)}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <JobStatusBadge status={job.status} />
                    </Table.Td>
                    <Table.Td ta="right" style={{ fontVariantNumeric: 'tabular-nums' }}>
                      <Text size="sm">
                        {job.passed}/{job.total}
                      </Text>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          )}
        </Card>
        <Card withBorder>
          <Title order={4} mb="sm">
            Tests les plus en échec (30 j)
          </Title>
          {data.failing.length === 0 ? (
            <Text c="dimmed" size="sm">
              Aucun échec sur 30 jours.
            </Text>
          ) : (
            <Table verticalSpacing={6} data-testid="failing-tests">
              <Table.Tbody>
                {data.failing.map((test) => (
                  <Table.Tr key={test.testKey}>
                    <Table.Td>
                      <Text size="sm" ff="monospace" fw={600}>
                        {test.project ? `${test.project} · ` : ''}
                        {test.testKey}
                      </Text>
                      <Text size="xs" c="dimmed" lineClamp={1}>
                        {test.identifier ?? '—'}
                      </Text>
                    </Table.Td>
                    <Table.Td ta="right">
                      <Text size="sm" c="red" fw={600}>
                        {test.failures} échec(s)
                      </Text>
                      <Text size="xs" c="dimmed">
                        {dateTime(test.lastFailure)}
                      </Text>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          )}
        </Card>
      </SimpleGrid>

      <SimpleGrid cols={{ base: 1, lg: 2 }}>
        <Card withBorder>
          <Title order={4} mb="sm">
            Par framework (30 j)
          </Title>
          {data.frameworks.length === 0 ? (
            <Text c="dimmed" size="sm">
              Pas encore de test exécuté.
            </Text>
          ) : (
            <Table data-testid="framework-stats">
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Framework</Table.Th>
                  <Table.Th ta="right">Tests</Table.Th>
                  <Table.Th ta="right">Réussite</Table.Th>
                  <Table.Th ta="right">Durée moyenne</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {data.frameworks.map((f) => (
                  <Table.Tr key={f.framework}>
                    <Table.Td>{f.framework}</Table.Td>
                    <Table.Td ta="right">{f.tests}</Table.Td>
                    <Table.Td ta="right">{f.passRate === null ? '—' : `${f.passRate.toLocaleString('fr-FR')} %`}</Table.Td>
                    <Table.Td ta="right">{duration(f.averageMs)}</Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          )}
        </Card>
        <Card withBorder>
          <Group justify="space-between" mb="sm">
            <Title order={4}>Outils</Title>
            <Anchor component={Link} to="/tools" size="sm">
              Gérer les outils
            </Anchor>
          </Group>
          <Text fz={28} fw={700} data-testid="tools-installed">
            {data.toolsInstalled} / {data.toolsTotal}
          </Text>
          <Text size="sm" c="dimmed">
            outils détectés sur cette machine ({data.platform.toLowerCase()})
          </Text>
          <Progress value={data.toolsTotal === 0 ? 0 : (100 * data.toolsInstalled) / data.toolsTotal} mt="sm" color="teal"
            aria-label="Part des outils installés" />
        </Card>
      </SimpleGrid>
    </Stack>
  );
}

function Kpi({ label, value, hint, testId, color }: { label: string; value: React.ReactNode; hint: string; testId: string; color?: string }) {
  return (
    <Card withBorder data-testid={testId}>
      <Text size="xs" tt="uppercase" fw={600} c="dimmed">
        {label}
      </Text>
      <Text fz={28} fw={700} c={color} style={{ fontVariantNumeric: 'tabular-nums' }}>
        {value}
      </Text>
      <Text size="xs" c="dimmed">
        {hint}
      </Text>
    </Card>
  );
}
