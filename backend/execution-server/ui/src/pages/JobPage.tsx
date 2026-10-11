import { Alert, Anchor, Badge, Button, Card, Code, Group, Image, Loader, Modal, ScrollArea, SimpleGrid, Stack, Table, Tabs, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconDownload, IconPlayerStop } from '@tabler/icons-react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { blob, dateTime, duration, getJson, getText, jobDuration, send, size, type Artifact, type JobDetail } from '../api';
import { JobStatusBadge, TestStatusBadge } from '../components/Badges';

/** Détail d'un job : tests (statut, tentatives, métriques, message), journal en direct, artefacts. */
export function JobPage() {
  const { id } = useParams() as { id: string };
  const client = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['job', id],
    queryFn: () => getJson<JobDetail>(`/api/admin/jobs/${id}`),
    refetchInterval: (query) => (query.state.data && ['RUNNING', 'ACCEPTED'].includes(query.state.data.job.status) ? 1500 : false),
  });
  const running = data ? ['RUNNING', 'ACCEPTED'].includes(data.job.status) : false;
  const { data: logs } = useQuery({ queryKey: ['job-logs', id], queryFn: () => getText(`/api/admin/jobs/${id}/logs`), refetchInterval: running ? 1500 : false });
  const cancel = useMutation({
    mutationFn: () => send('POST', `/api/admin/jobs/${id}/cancel`),
    onSuccess: () => {
      notifications.show({ color: 'orange', message: 'Annulation demandée : les processus en cours sont arrêtés.' });
      return client.invalidateQueries({ queryKey: ['job', id] });
    },
    onError: (e: Error) => notifications.show({ color: 'red', message: e.message }),
  });
  const [preview, setPreview] = useState<Artifact | null>(null);

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">Job introuvable : {(error as Error)?.message}</Alert>;
  const { job, tests, artifacts } = data;

  return (
    <Stack data-testid="job-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={4}>
          <Anchor component={Link} to="/jobs" size="sm">
            ← Jobs
          </Anchor>
          <Group gap="sm">
            <Title order={2} ff="monospace">
              {job.runId}
            </Title>
            <JobStatusBadge status={job.status} />
          </Group>
          <Text size="sm" c="dimmed">
            {job.id} · {[job.project, job.campaign, job.environment, job.buildVersion].filter(Boolean).join(' · ')} · jeton « {job.tokenLabel} »
          </Text>
        </Stack>
        {running && (
          <Button color="red" variant="light" leftSection={<IconPlayerStop size={16} />} loading={cancel.isPending} onClick={() => cancel.mutate()}
            data-testid="job-cancel">
            Annuler le job
          </Button>
        )}
      </Group>

      <SimpleGrid cols={{ base: 2, md: 5 }}>
        <Fact label="Tests" value={`${job.total}`} />
        <Fact label="Réussis" value={`${job.passed}`} color="teal" />
        <Fact label="Échoués / erreurs" value={`${job.failed} / ${job.errored}`} color={job.failed + job.errored > 0 ? 'red' : undefined} />
        <Fact label="Durée" value={duration(jobDuration(job))} />
        <Fact label="Parallélisme" value={`${job.parallelism} · ${job.retryFailed} reprise(s)`} />
      </SimpleGrid>
      <Card withBorder p="sm">
        <Text size="sm">
          <b>Dépôt</b> : {job.repositoryUrl ? <Code>{job.repositoryUrl}</Code> : 'aucun'} {job.branch && <>branche <Code>{job.branch}</Code></>}
          {' · '}
          <b>Agent</b> : {job.agent ?? '—'} · <b>Reçu</b> : {dateTime(job.submittedAt)} · <b>Fin</b> : {dateTime(job.endedAt)}
        </Text>
        {job.errorMessage && (
          <Alert color="red" mt="sm">
            {job.errorMessage}
          </Alert>
        )}
      </Card>

      <Tabs defaultValue="tests" keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="tests">Tests ({tests.length})</Tabs.Tab>
          <Tabs.Tab value="logs">Journal</Tabs.Tab>
          <Tabs.Tab value="artifacts">Artefacts ({artifacts.length})</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="tests" pt="md">
          <Table.ScrollContainer minWidth={860}>
            <Table verticalSpacing="sm" data-testid="job-tests">
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Test</Table.Th>
                  <Table.Th>Framework</Table.Th>
                  <Table.Th>Résultat</Table.Th>
                  <Table.Th ta="right">Durée</Table.Th>
                  <Table.Th>Détail</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {tests.map((test) => (
                  <Table.Tr key={test.id} data-testid={`job-test-${test.spec.testKey}`}>
                    <Table.Td>
                      <Text ff="monospace" fw={600} size="sm">
                        {test.spec.testKey}
                      </Text>
                      <Text size="xs" c="dimmed" style={{ wordBreak: 'break-word' }}>
                        {test.spec.testIdentifier ?? '—'}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Text size="sm">{test.spec.framework ?? '—'}</Text>
                      <Text size="xs" c="dimmed" ff="monospace">
                        {test.spec.path ?? ''}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Group gap={6}>
                        <TestStatusBadge status={test.status} />
                        {test.attempts > 1 && (
                          <Badge variant="outline" color="orange" size="sm">
                            {test.attempts} tentatives
                          </Badge>
                        )}
                      </Group>
                    </Table.Td>
                    <Table.Td ta="right" style={{ fontVariantNumeric: 'tabular-nums' }}>
                      {duration(test.durationMs)}
                    </Table.Td>
                    <Table.Td maw={380}>
                      {Object.keys(test.metrics).length > 0 && (
                        <Group gap={6} mb={4}>
                          {Object.entries(test.metrics).map(([name, value]) => (
                            <Badge key={name} variant="light" color="indigo" tt="none">
                              {name} {value.toLocaleString('fr-FR')}
                            </Badge>
                          ))}
                        </Group>
                      )}
                      {test.message && (
                        <Text size="xs" c={test.status === 'PASSED' ? 'dimmed' : 'red'} lineClamp={3} title={test.message}>
                          {test.message}
                        </Text>
                      )}
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          </Table.ScrollContainer>
        </Tabs.Panel>
        <Tabs.Panel value="logs" pt="md">
          <ScrollArea h={460} type="auto" style={{ border: '1px solid var(--mantine-color-default-border)', borderRadius: 8 }}>
            <Code block data-testid="job-logs" style={{ whiteSpace: 'pre-wrap', minHeight: 440 }}>
              {logs || 'Journal vide.'}
            </Code>
          </ScrollArea>
        </Tabs.Panel>
        <Tabs.Panel value="artifacts" pt="md">
          <Table data-testid="job-artifacts">
            <Table.Tbody>
              {artifacts.map((artifact) => (
                <Table.Tr key={artifact.name}>
                  <Table.Td>
                    <Badge variant="light" color={artifact.kind === 'SCREENSHOT' ? 'red' : 'gray'}>
                      {artifact.kind}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    {artifact.contentType.startsWith('image/') ? (
                      <Anchor component="button" ff="monospace" size="sm" onClick={() => setPreview(artifact)}>
                        {artifact.name}
                      </Anchor>
                    ) : (
                      <Text ff="monospace" size="sm">
                        {artifact.name}
                      </Text>
                    )}
                  </Table.Td>
                  <Table.Td>
                    <Text size="xs" c="dimmed">
                      {size(artifact.size)}
                    </Text>
                  </Table.Td>
                  <Table.Td ta="right">
                    <Button size="compact-sm" variant="subtle" leftSection={<IconDownload size={14} />} onClick={() => download(job.id, artifact.name)}>
                      Télécharger
                    </Button>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Tabs.Panel>
      </Tabs>
      <Modal opened={!!preview} onClose={() => setPreview(null)} title={preview?.name} size="xl">
        {preview && <ArtifactImage jobId={job.id} name={preview.name} />}
      </Modal>
    </Stack>
  );
}

function Fact({ label, value, color }: { label: string; value: string; color?: string }) {
  return (
    <Card withBorder p="sm">
      <Text size="xs" c="dimmed" tt="uppercase" fw={600}>
        {label}
      </Text>
      <Text fw={700} size="lg" c={color} style={{ fontVariantNumeric: 'tabular-nums' }}>
        {value}
      </Text>
    </Card>
  );
}

function ArtifactImage({ jobId, name }: { jobId: string; name: string }) {
  const [url, setUrl] = useState<string | null>(null);
  useEffect(() => {
    let objectUrl: string | null = null;
    blob(`/api/admin/jobs/${jobId}/artifacts/${encodeURIComponent(name)}`).then((b) => {
      objectUrl = URL.createObjectURL(b);
      setUrl(objectUrl);
    });
    return () => {
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [jobId, name]);
  return url ? <Image src={url} alt={name} /> : <Loader />;
}

async function download(jobId: string, name: string) {
  const content = await blob(`/api/admin/jobs/${jobId}/artifacts/${encodeURIComponent(name)}`);
  const url = URL.createObjectURL(content);
  const link = document.createElement('a');
  link.href = url;
  link.download = name;
  link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
