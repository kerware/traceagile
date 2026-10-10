import { Alert, Badge, Button, Card, Group, Loader, Modal, PasswordInput, SegmentedControl, Stack, Switch, Text, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconKey, IconPlugConnected, IconPlus, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useCreateServer,
  useDeleteServer,
  useExecutionServers,
  usePairServer,
  useTestServerConnection,
  useUpdateServer,
  type ExecutionServer,
} from '../../api/automation';
import { errorMessage } from '../../api/errors';
import { SERVER_STATUS_COLORS } from '../automation/model';
import { TechniqueBadge } from '../tests/Badges';
import { AdminTabs } from './AdminTabs';

/**
 * §13.2 /admin/execution-servers — serveurs d'exécution (§10). ADR-0020 appairage : le serveur émet le
 * jeton d'accès et le secret de signature des webhooks ; TraceAgile ne les affiche jamais.
 */
export function AdminExecutionServersPage() {
  const { t } = useTranslation();
  const { data, isLoading } = useExecutionServers();
  const create = useCreateServer();
  const [form, setForm] = useState({ name: '', baseUrl: '' });
  const [pairing, setPairing] = useState<ExecutionServer | null>(null);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  return (
    <Stack>
      <AdminTabs value="execution-servers" />
      <Text size="sm" c="dimmed">
        {t('servers.intro')}
      </Text>
      {isLoading && <Loader />}
      <Stack data-testid="server-list">
        {(data ?? []).map((server) => (
          <ServerCard key={server.id} server={server} onPair={() => setPairing(server)} />
        ))}
        {data && data.length === 0 && <Text c="dimmed">{t('servers.none')}</Text>}
      </Stack>
      <Card withBorder>
        <Title order={5} mb="xs">
          {t('servers.add')}
        </Title>
        <Group align="flex-end">
          <TextInput label={t('servers.name')} value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} data-testid="server-name" />
          <TextInput label={t('servers.baseUrl')} placeholder="https://execution.example.com" w={360} value={form.baseUrl}
            onChange={(e) => setForm({ ...form, baseUrl: e.currentTarget.value })} data-testid="server-url" />
          <Button leftSection={<IconPlus size={16} />} disabled={!form.name.trim() || !form.baseUrl.trim()} loading={create.isPending}
            onClick={() => create.mutate(form, { onSuccess: () => setForm({ name: '', baseUrl: '' }), onError: fail })} data-testid="server-create">
            {t('servers.create')}
          </Button>
        </Group>
      </Card>
      {pairing && <PairModal server={pairing} onClose={() => setPairing(null)} />}
    </Stack>
  );
}

function ServerCard({ server, onPair }: { server: ExecutionServer; onPair: () => void }) {
  const { t } = useTranslation();
  const test = useTestServerConnection();
  const update = useUpdateServer();
  const remove = useDeleteServer();
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  return (
    <Card withBorder data-testid={`server-${server.name}`}>
      <Group justify="space-between" align="flex-start">
        <Stack gap={4}>
          <Group gap="xs">
            <Text fw={700}>{server.name}</Text>
            <Badge color={SERVER_STATUS_COLORS[server.status]} data-testid={`server-status-${server.name}`}>
              {t(`serverStatus.${server.status}`)}
            </Badge>
            {server.serverVersion && <Badge variant="outline">v{server.serverVersion}</Badge>}
          </Group>
          <Text size="sm" ff="monospace">
            {server.baseUrl}
          </Text>
          <Text size="xs" c="dimmed" data-testid={`server-token-${server.name}`}>
            {server.paired
              ? t('servers.paired', { hint: server.tokenHint, id: server.tokenId ?? '—', at: server.pairedAt ? new Date(server.pairedAt).toLocaleString() : '—' })
              : t('servers.unpaired')}
          </Text>
          {server.lastError && (
            <Text size="xs" c="red">
              {server.lastError}
            </Text>
          )}
          <Group gap={4}>
            {server.techniques.map((tech) => (
              <TechniqueBadge key={tech} technique={tech} />
            ))}
            {server.agents > 0 && <Text size="xs" c="dimmed">{t('servers.agents', { count: server.agents })}</Text>}
          </Group>
          {server.lastHeartbeat && (
            <Text size="xs" c="dimmed">
              {t('servers.heartbeat', { at: new Date(server.lastHeartbeat).toLocaleString() })}
            </Text>
          )}
        </Stack>
        <Stack gap="xs" align="flex-end">
          <Group gap="xs">
            <Button size="xs" variant="light" leftSection={<IconKey size={14} />} onClick={onPair} data-testid={`server-pair-${server.name}`}>
              {server.paired ? t('servers.repair') : t('servers.pair')}
            </Button>
            <Button size="xs" variant="default" leftSection={<IconPlugConnected size={14} />} disabled={!server.paired} loading={test.isPending}
              onClick={() => test.mutate(server.id, { onError: fail })} data-testid={`server-test-${server.name}`}>
              {t('servers.test')}
            </Button>
            <Button size="xs" variant="subtle" color="red" leftSection={<IconTrash size={14} />}
              onClick={() => remove.mutate(server.id, { onError: fail })}>
              {t('servers.delete')}
            </Button>
          </Group>
          <Switch label={t('servers.enabled')} checked={server.enabled} onChange={(e) => update.mutate({ id: server.id, enabled: e.currentTarget.checked }, { onError: fail })} />
        </Stack>
      </Group>
    </Card>
  );
}

/** ADR-0020 deux façons d'obtenir le jeton émis par le serveur. */
function PairModal({ server, onClose }: { server: ExecutionServer; onClose: () => void }) {
  const { t } = useTranslation();
  const pair = usePairServer();
  const [mode, setMode] = useState<'credentials' | 'token'>('credentials');
  const [form, setForm] = useState({ adminUser: '', adminPassword: '', token: '', webhookSecret: '', tokenId: '' });
  const [error, setError] = useState<string | null>(null);
  const submit = async () => {
    setError(null);
    try {
      const body = mode === 'credentials'
        ? { id: server.id, adminUser: form.adminUser, adminPassword: form.adminPassword }
        : { id: server.id, token: form.token, webhookSecret: form.webhookSecret, tokenId: form.tokenId || undefined };
      await pair.mutateAsync(body);
      notifications.show({ color: 'green', message: t('servers.pairedDone', { name: server.name }) });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };
  const valid = mode === 'credentials' ? form.adminUser.trim() && form.adminPassword : form.token.trim() && form.webhookSecret.trim();
  return (
    <Modal opened onClose={onClose} title={t('servers.pairTitle', { name: server.name })} size="lg">
      <Stack>
        {error && <Alert color="red">{error}</Alert>}
        <SegmentedControl value={mode} onChange={(v) => setMode(v as typeof mode)}
          data={[{ value: 'credentials', label: t('servers.modeCredentials') }, { value: 'token', label: t('servers.modeToken') }]} data-testid="pair-mode" />
        <Text size="sm" c="dimmed">
          {mode === 'credentials' ? t('servers.credentialsHint') : t('servers.tokenHint')}
        </Text>
        {mode === 'credentials' ? (
          <>
            <TextInput label={t('servers.adminUser')} value={form.adminUser} onChange={(e) => setForm({ ...form, adminUser: e.currentTarget.value })}
              autoComplete="off" data-testid="pair-admin-user" />
            <PasswordInput label={t('servers.adminPassword')} value={form.adminPassword} onChange={(e) => setForm({ ...form, adminPassword: e.currentTarget.value })}
              autoComplete="new-password" data-testid="pair-admin-password" />
          </>
        ) : (
          <>
            <PasswordInput label={t('servers.token')} value={form.token} onChange={(e) => setForm({ ...form, token: e.currentTarget.value })}
              autoComplete="off" data-testid="pair-token" />
            <PasswordInput label={t('servers.webhookSecret')} value={form.webhookSecret} onChange={(e) => setForm({ ...form, webhookSecret: e.currentTarget.value })}
              autoComplete="off" data-testid="pair-secret" />
            <TextInput label={t('servers.tokenId')} value={form.tokenId} onChange={(e) => setForm({ ...form, tokenId: e.currentTarget.value })} />
          </>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={pair.isPending} disabled={!valid} data-testid="pair-submit">
            {t('servers.pairSubmit')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
