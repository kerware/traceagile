import { Code, Group, ScrollArea, SegmentedControl, Stack, Switch, Text, Title } from '@mantine/core';
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { getText } from '../api';

/** Journal du serveur (fin du fichier), filtré par niveau, rafraîchi en direct si demandé. */
export function LogsPage() {
  const [level, setLevel] = useState('');
  const [live, setLive] = useState(true);
  const { data } = useQuery({
    queryKey: ['server-logs', level],
    queryFn: () => getText(`/api/admin/logs?lines=800${level ? `&level=${level}` : ''}`),
    refetchInterval: live ? 3000 : false,
  });
  const lines = data ? data.split('\n') : [];

  return (
    <Stack>
      <Title order={2}>Journaux du serveur</Title>
      <Group justify="space-between">
        <SegmentedControl value={level} onChange={setLevel} data-testid="logs-level"
          data={[
            { value: '', label: 'Tout' },
            { value: 'WARN,ERROR', label: 'Avertissements et erreurs' },
            { value: 'ERROR', label: 'Erreurs' },
          ]} />
        <Switch label="Suivi en direct" checked={live} onChange={(e) => setLive(e.currentTarget.checked)} />
      </Group>
      <Text size="xs" c="dimmed">
        {lines.length} ligne(s) — les journaux de chaque job sont sur la page du job.
      </Text>
      <ScrollArea h="65vh" type="auto" style={{ border: '1px solid var(--mantine-color-default-border)', borderRadius: 8 }}>
        <Code block data-testid="server-logs" style={{ whiteSpace: 'pre-wrap', minHeight: '64vh' }}>
          {data || 'Journal vide.'}
        </Code>
      </ScrollArea>
    </Stack>
  );
}
