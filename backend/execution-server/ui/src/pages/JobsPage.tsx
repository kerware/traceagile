import { Alert, Anchor, Group, Loader, Progress, SegmentedControl, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { useDebouncedValue } from '@mantine/hooks';
import { IconSearch } from '@tabler/icons-react';
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { dateTime, duration, getJson, jobDuration, type Job } from '../api';
import { JobStatusBadge } from '../components/Badges';

/** Jobs reçus : filtre par statut et par texte (run, projet, campagne, jeton) ; rafraîchi toutes les 3 s. */
export function JobsPage() {
  const [status, setStatus] = useState('');
  const [text, setText] = useState('');
  const [query] = useDebouncedValue(text, 300);
  const params = new URLSearchParams();
  if (status) params.set('status', status);
  if (query) params.set('q', query);
  const { data, isLoading, error } = useQuery({
    queryKey: ['jobs', status, query],
    queryFn: () => getJson<Job[]>(`/api/admin/jobs?${params}`),
    refetchInterval: 3000,
  });

  return (
    <Stack>
      <Title order={2}>Jobs</Title>
      <Group justify="space-between" wrap="wrap">
        <SegmentedControl value={status} onChange={setStatus} data-testid="jobs-status"
          data={[
            { value: '', label: 'Tous' },
            { value: 'RUNNING', label: 'En cours' },
            { value: 'COMPLETED', label: 'Terminés' },
            { value: 'CANCELLED', label: 'Annulés' },
            { value: 'INTERRUPTED', label: 'Interrompus' },
          ]} />
        <TextInput placeholder="Run, projet, campagne, jeton…" leftSection={<IconSearch size={16} />} value={text}
          onChange={(e) => setText(e.currentTarget.value)} w={320} aria-label="Rechercher un job" data-testid="jobs-search" />
      </Group>
      {isLoading && <Loader />}
      {error && <Alert color="red">{(error as Error).message}</Alert>}
      {data && data.length === 0 && (
        <Text c="dimmed">Aucun job. Les runs lancés depuis TraceAgile sur ce serveur apparaîtront ici en temps réel.</Text>
      )}
      {data && data.length > 0 && (
        <Table.ScrollContainer minWidth={820}>
          <Table striped highlightOnHover data-testid="jobs-table">
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Run</Table.Th>
                <Table.Th>Projet / campagne</Table.Th>
                <Table.Th>Statut</Table.Th>
                <Table.Th>Résultats</Table.Th>
                <Table.Th>Reçu</Table.Th>
                <Table.Th ta="right">Durée</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {data.map((job) => {
                const done = job.passed + job.failed + job.errored + job.skipped;
                return (
                  <Table.Tr key={job.id} data-testid={`job-row-${job.id}`}>
                    <Table.Td>
                      <Anchor component={Link} to={`/jobs/${job.id}`} ff="monospace" fw={600}>
                        {job.runId}
                      </Anchor>
                      <Text size="xs" c="dimmed" ff="monospace">
                        {job.id} · {job.tokenLabel}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Text size="sm">{[job.project, job.campaign].filter(Boolean).join(' · ') || '—'}</Text>
                      <Text size="xs" c="dimmed">
                        {[job.environment, job.buildVersion].filter(Boolean).join(' · ')}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <JobStatusBadge status={job.status} />
                    </Table.Td>
                    <Table.Td miw={180}>
                      <Progress.Root size="md" aria-label={`${done} test(s) sur ${job.total} terminés`}>
                        <Progress.Section value={job.total ? (100 * job.passed) / job.total : 0} color="teal" />
                        <Progress.Section value={job.total ? (100 * job.failed) / job.total : 0} color="red" />
                        <Progress.Section value={job.total ? (100 * job.errored) / job.total : 0} color="grape" />
                        <Progress.Section value={job.total ? (100 * job.skipped) / job.total : 0} color="gray" />
                      </Progress.Root>
                      <Text size="xs" c="dimmed" mt={2}>
                        {job.passed} réussi(s) · {job.failed} échec(s) · {job.errored} erreur(s) / {job.total}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Text size="sm">{dateTime(job.submittedAt)}</Text>
                    </Table.Td>
                    <Table.Td ta="right" style={{ fontVariantNumeric: 'tabular-nums' }}>
                      {duration(jobDuration(job))}
                    </Table.Td>
                  </Table.Tr>
                );
              })}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
      )}
    </Stack>
  );
}
