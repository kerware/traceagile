import {
  Alert,
  Anchor,
  Badge,
  Button,
  Card,
  Code,
  Drawer,
  Group,
  List,
  Loader,
  Modal,
  MultiSelect,
  ScrollArea,
  SimpleGrid,
  Stack,
  Text,
  ThemeIcon,
  Title,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconDownload, IconHandFinger, IconRefresh, IconWand } from '@tabler/icons-react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { dateTime, getJson, getText, send, type PlanStep, type ToolState } from '../api';
import { ToolStatusBadge } from '../components/Badges';

const CATEGORIES = ['Prérequis', 'Navigateur', 'Robot Framework', 'Python', 'Java', 'Performance'];

const FRAMEWORKS = ['Playwright', 'Cypress', 'Selenium', 'Robot Framework', 'pytest', 'JUnit 5', 'REST Assured', 'Cucumber-JVM', 'Cucumber-JS', 'Gatling'];

/** Outils de test : détection, installation (avec dépendances), aide, journal, assistant par framework. */
export function ToolsPage() {
  const client = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['tools'],
    queryFn: () => getJson<ToolState[]>('/api/admin/tools'),
    refetchInterval: (query) => (query.state.data?.some((t) => t.status === 'INSTALLING' || t.status === 'QUEUED') ? 2000 : false),
  });
  const detect = useMutation({
    mutationFn: () => send<ToolState[]>('POST', '/api/admin/tools/detect'),
    onSuccess: (states) => client.setQueryData(['tools'], states),
  });
  const install = useMutation({
    mutationFn: (id: string) => send<{ queued: string[] }>('POST', `/api/admin/tools/${id}/install?withDependencies=true`),
    onSuccess: (result) => {
      notifications.show({ color: 'blue', message: `Installation lancée : ${(result?.queued ?? []).join(', ')}` });
      return client.invalidateQueries({ queryKey: ['tools'] });
    },
    onError: (e: Error) => notifications.show({ color: 'red', title: 'Installation impossible', message: e.message, autoClose: 10000 }),
  });
  const [details, setDetails] = useState<string | null>(null);
  const [assistant, setAssistant] = useState(false);

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">{(error as Error)?.message}</Alert>;
  const selected = data.find((t) => t.tool.id === details) ?? null;

  return (
    <Stack>
      <Group justify="space-between">
        <Stack gap={2}>
          <Title order={2}>Outils</Title>
          <Text size="sm" c="dimmed">
            Les outils s'installent dans le dossier des outils du serveur, sans droits d'administrateur. Les prérequis de la machine sont détectés et expliqués.
          </Text>
        </Stack>
        <Group>
          <Button variant="default" leftSection={<IconRefresh size={16} />} loading={detect.isPending} onClick={() => detect.mutate()} data-testid="tools-detect">
            Détecter à nouveau
          </Button>
          <Button leftSection={<IconWand size={16} />} onClick={() => setAssistant(true)} data-testid="tools-assistant">
            Assistant d'installation
          </Button>
        </Group>
      </Group>

      {CATEGORIES.map((category) => {
        const tools = data.filter((t) => t.tool.category === category);
        if (tools.length === 0) return null;
        return (
          <Stack key={category} gap="xs">
            <Title order={4}>{category}</Title>
            <SimpleGrid cols={{ base: 1, sm: 2, xl: 3 }}>
              {tools.map((state) => (
                <ToolCard key={state.tool.id} state={state} onDetails={() => setDetails(state.tool.id)}
                  onInstall={() => install.mutate(state.tool.id)} installing={install.isPending && install.variables === state.tool.id} />
              ))}
            </SimpleGrid>
          </Stack>
        );
      })}

      <Drawer opened={!!selected} onClose={() => setDetails(null)} position="right" size="xl" title={selected?.tool.name}>
        {selected && <ToolDetails state={selected} all={data} />}
      </Drawer>
      <Modal opened={assistant} onClose={() => setAssistant(false)} size="lg" title="Assistant d'installation">
        <Assistant onInstall={(id) => install.mutateAsync(id)} />
      </Modal>
    </Stack>
  );
}

function ToolCard({ state, onDetails, onInstall, installing }: { state: ToolState; onDetails: () => void; onInstall: () => void; installing: boolean }) {
  const busy = state.status === 'INSTALLING' || state.status === 'QUEUED';
  return (
    <Card withBorder data-testid={`tool-${state.tool.id}`}>
      <Stack gap={6} h="100%">
        <Group justify="space-between" wrap="nowrap" align="flex-start">
          <Text fw={650}>{state.tool.name}</Text>
          <ToolStatusBadge status={state.status} />
        </Group>
        <Text size="sm" c="dimmed">
          {state.tool.description}
        </Text>
        {state.version && (
          <Text size="sm">
            Version <Code>{state.version}</Code>
          </Text>
        )}
        {state.tool.frameworks.length > 0 && (
          <Group gap={4}>
            {state.tool.frameworks.map((f) => (
              <Badge key={f} size="xs" variant="outline" tt="none">
                {f}
              </Badge>
            ))}
          </Group>
        )}
        {state.missingDependencies.length > 0 && state.status !== 'INSTALLED' && (
          <Text size="xs" c="orange">
            Nécessite d'abord : {state.missingDependencies.join(', ')}
          </Text>
        )}
        {state.status === 'FAILED' && state.message && (
          <Text size="xs" c="red" lineClamp={2}>
            {state.message}
          </Text>
        )}
        <Group mt="auto" pt="xs" gap="xs">
          {state.installable && (
            <Button size="xs" leftSection={<IconDownload size={14} />} onClick={onInstall} loading={installing || busy}
              variant={state.status === 'INSTALLED' ? 'default' : 'filled'} data-testid={`tool-install-${state.tool.id}`}>
              {state.status === 'INSTALLED' ? 'Réinstaller' : state.missingDependencies.length > 0 ? 'Installer avec ses dépendances' : 'Installer'}
            </Button>
          )}
          {!state.installable && state.status !== 'INSTALLED' && (
            <Badge color="orange" variant="light" leftSection={<IconHandFinger size={12} />} tt="none">
              Installation manuelle
            </Badge>
          )}
          <Button size="xs" variant="subtle" onClick={onDetails} data-testid={`tool-details-${state.tool.id}`}>
            Aide et journal
          </Button>
        </Group>
      </Stack>
    </Card>
  );
}

function ToolDetails({ state, all }: { state: ToolState; all: ToolState[] }) {
  const busy = state.status === 'INSTALLING' || state.status === 'QUEUED';
  const { data: log } = useQuery({
    queryKey: ['tool-log', state.tool.id],
    queryFn: () => getText(`/api/admin/tools/${state.tool.id}/log`),
    refetchInterval: busy ? 1500 : false,
  });
  return (
    <Stack>
      <Group>
        <ToolStatusBadge status={state.status} />
        {state.version && <Code>{state.version}</Code>}
        <Text size="xs" c="dimmed">
          Détecté le {dateTime(state.checkedAt)}
        </Text>
      </Group>
      <Alert color="cyan" variant="light" title="Aide">
        <Text size="sm">{state.tool.help}</Text>
        <Anchor href={state.tool.docs} target="_blank" rel="noopener" size="sm">
          Documentation officielle
        </Anchor>
      </Alert>
      {state.tool.dependencies.length > 0 && (
        <Stack gap={4}>
          <Text fw={600} size="sm">
            Dépendances
          </Text>
          <List size="sm" spacing={4}>
            {state.tool.dependencies.map((d) => {
              const dependency = all.find((t) => t.tool.id === d);
              return (
                <List.Item key={d} icon={
                  <ThemeIcon size={18} radius="xl" color={dependency?.status === 'INSTALLED' ? 'teal' : 'gray'}>
                    <IconCheck size={12} />
                  </ThemeIcon>
                }>
                  {dependency?.tool.name ?? d} {dependency?.version ? `(${dependency.version})` : '— absent'}
                </List.Item>
              );
            })}
          </List>
        </Stack>
      )}
      {state.script && (
        <Stack gap={4}>
          <Text fw={600} size="sm">
            Commandes exécutées par l'installation
          </Text>
          <Code block style={{ whiteSpace: 'pre-wrap' }} data-testid="tool-script">
            {state.script}
          </Code>
        </Stack>
      )}
      <Stack gap={4}>
        <Text fw={600} size="sm">
          Journal de la dernière installation {state.installStartedAt && `(${dateTime(state.installStartedAt)})`}
        </Text>
        <ScrollArea h={320} type="auto" style={{ border: '1px solid var(--mantine-color-default-border)', borderRadius: 8 }}>
          <Code block style={{ whiteSpace: 'pre-wrap', minHeight: 300 }} data-testid="tool-log">
            {log || 'Aucune installation lancée depuis ce serveur.'}
          </Code>
        </ScrollArea>
      </Stack>
    </Stack>
  );
}

const ACTION_LABEL: Record<PlanStep['action'], { label: string; color: string }> = {
  NONE: { label: 'Déjà installé', color: 'teal' },
  INSTALL: { label: 'À installer', color: 'blue' },
  MANUAL: { label: 'À installer à la main', color: 'orange' },
};

/** Choix des frameworks → plan ordonné (prérequis, dépendances, outils) → installation en un clic. */
function Assistant({ onInstall }: { onInstall: (id: string) => Promise<unknown> }) {
  const [frameworks, setFrameworks] = useState<string[]>(['Playwright']);
  const { data: plan, isFetching } = useQuery({
    queryKey: ['plan', frameworks],
    queryFn: () => getJson<PlanStep[]>(`/api/admin/tools/plan?${frameworks.map((f) => `frameworks=${encodeURIComponent(f)}`).join('&')}`),
    enabled: frameworks.length > 0,
  });
  const [running, setRunning] = useState(false);
  const manual = (plan ?? []).filter((s) => s.action === 'MANUAL');
  const toInstall = (plan ?? []).filter((s) => s.action === 'INSTALL');

  return (
    <Stack>
      <MultiSelect label="Frameworks utilisés par vos tests" data={FRAMEWORKS} value={frameworks} onChange={setFrameworks} searchable
        data-testid="assistant-frameworks" />
      {isFetching && <Loader size="sm" />}
      {plan && (
        <List spacing="xs" data-testid="assistant-plan" type="ordered">
          {plan.map((step) => (
            <List.Item key={step.toolId}>
              <Group gap="xs">
                <Text size="sm" fw={600}>
                  {step.name}
                </Text>
                <Badge size="sm" variant="light" color={ACTION_LABEL[step.action].color}>
                  {ACTION_LABEL[step.action].label}
                </Badge>
              </Group>
              {step.action === 'MANUAL' && (
                <Text size="xs" c="dimmed">
                  {step.help}
                </Text>
              )}
            </List.Item>
          ))}
        </List>
      )}
      {manual.length > 0 && (
        <Alert color="orange" variant="light">
          Installez d'abord à la main : {manual.map((s) => s.name).join(', ')}, puis cliquez sur « Détecter à nouveau ».
        </Alert>
      )}
      <Button disabled={toInstall.length === 0 || manual.length > 0} loading={running} data-testid="assistant-install"
        onClick={async () => {
          setRunning(true);
          try {
            for (const step of toInstall) {
              await onInstall(step.toolId);
            }
          } finally {
            setRunning(false);
          }
        }}>
        {toInstall.length === 0 ? 'Rien à installer' : `Installer ${toInstall.length} outil(s)`}
      </Button>
    </Stack>
  );
}
