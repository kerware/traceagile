import { Button, Card, Code, Group, Loader, PasswordInput, SimpleGrid, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconTrash } from '@tabler/icons-react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { dateTime, getJson, send, type GitCredential, type Settings } from '../api';

/** Paramètres : identifiants des dépôts Git privés, informations du serveur et de son lancement. */
export function SettingsPage() {
  const client = useQueryClient();
  const { data: settings } = useQuery({ queryKey: ['settings'], queryFn: () => getJson<Settings>('/api/admin/settings') });
  const { data: credentials } = useQuery({ queryKey: ['git-credentials'], queryFn: () => getJson<GitCredential[]>('/api/admin/git-credentials') });
  const [form, setForm] = useState({ host: '', username: '', secret: '' });
  const save = useMutation({
    mutationFn: () => send('PUT', '/api/admin/git-credentials', form),
    onSuccess: () => {
      notifications.show({ color: 'teal', message: `Identifiants enregistrés pour ${form.host}` });
      setForm({ host: '', username: '', secret: '' });
      return client.invalidateQueries({ queryKey: ['git-credentials'] });
    },
    onError: (e: Error) => notifications.show({ color: 'red', message: e.message }),
  });
  const remove = useMutation({
    mutationFn: (host: string) => send('DELETE', `/api/admin/git-credentials/${encodeURIComponent(host)}`),
    onSuccess: () => client.invalidateQueries({ queryKey: ['git-credentials'] }),
  });

  return (
    <Stack>
      <Title order={2}>Paramètres</Title>
      <Card withBorder>
        <Title order={4} mb="xs">
          Dépôts Git privés
        </Title>
        <Text size="sm" c="dimmed" mb="sm">
          Pour cloner un dépôt privé en HTTPS, enregistrez un utilisateur et un jeton d'accès personnel (lecture seule) par hôte. Le jeton n'est jamais réaffiché
          ni écrit dans les journaux.
        </Text>
        <Group align="flex-end" wrap="wrap">
          <TextInput label="Hôte" placeholder="github.com" value={form.host} onChange={(e) => setForm({ ...form, host: e.currentTarget.value })}
            data-testid="git-host" />
          <TextInput label="Utilisateur" value={form.username} onChange={(e) => setForm({ ...form, username: e.currentTarget.value })} data-testid="git-user" />
          <PasswordInput label="Jeton d'accès" value={form.secret} onChange={(e) => setForm({ ...form, secret: e.currentTarget.value })} w={260}
            data-testid="git-secret" />
          <Button onClick={() => save.mutate()} loading={save.isPending} disabled={!form.host.trim() || !form.username.trim() || !form.secret.trim()}
            data-testid="git-save">
            Enregistrer
          </Button>
        </Group>
        {(credentials ?? []).length > 0 && (
          <Table mt="md" data-testid="git-credentials">
            <Table.Tbody>
              {(credentials ?? []).map((c) => (
                <Table.Tr key={c.host}>
                  <Table.Td>
                    <Code>{c.host}</Code>
                  </Table.Td>
                  <Table.Td>{c.username}</Table.Td>
                  <Table.Td>
                    <Text size="xs" c="dimmed">
                      modifié le {dateTime(c.updatedAt)}
                    </Text>
                  </Table.Td>
                  <Table.Td ta="right">
                    <Button size="compact-sm" variant="subtle" color="red" leftSection={<IconTrash size={14} />} onClick={() => remove.mutate(c.host)}>
                      Supprimer
                    </Button>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}
      </Card>

      <Card withBorder>
        <Title order={4} mb="sm">
          Serveur
        </Title>
        {!settings ? (
          <Loader size="sm" />
        ) : (
          <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="xs" data-testid="server-settings">
            <Info label="Nom" value={settings.serverName} />
            <Info label="Version" value={settings.version} />
            <Info label="Système" value={`${settings.platform} (${settings.architecture}), Java ${settings.javaVersion}`} />
            <Info label="Agents (tests simultanés)" value={`${settings.agents}`} />
            <Info label="Rétention des jobs" value={`${settings.retentionDays} jours`} />
            <Info label="Administrateur" value={settings.adminUser} />
            <Info label="Données" value={settings.dataDir} mono />
            <Info label="Outils" value={settings.toolsDir} mono />
          </SimpleGrid>
        )}
        <Text size="xs" c="dimmed" mt="md">
          Ces réglages se changent au lancement : variables EXECUTION_SERVER_AGENTS, EXECUTION_SERVER_RETENTION_DAYS, EXECUTION_SERVER_DATA_DIR,
          EXECUTION_SERVER_TOOLS_DIR, EXECUTION_SERVER_ADMIN_USER / _PASSWORD, ou options --execution-server.agents=8 de java -jar.
        </Text>
      </Card>

      <Card withBorder>
        <Title order={4} mb="xs">
          Appairage avec TraceAgile
        </Title>
        <Text size="sm">
          Dans TraceAgile : Administration › Serveurs d'exécution › Ajouter, adresse <Code>{window.location.origin}</Code>, puis « Appairer » avec les
          identifiants de l'administrateur de ce serveur (TraceAgile demande lui-même un jeton) ou avec un jeton émis dans l'onglet Jetons. TraceAgile doit
          pouvoir joindre ce serveur, et ce serveur doit pouvoir joindre TraceAgile (webhooks).
        </Text>
      </Card>
    </Stack>
  );
}

function Info({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <Stack gap={0}>
      <Text size="xs" c="dimmed">
        {label}
      </Text>
      <Text size="sm" ff={mono ? 'monospace' : undefined} style={{ wordBreak: 'break-all' }}>
        {value}
      </Text>
    </Stack>
  );
}
