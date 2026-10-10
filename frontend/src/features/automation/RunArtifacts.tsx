import { ActionIcon, Alert, Badge, Button, Card, Center, Group, Image, Loader, Modal, Stack, Table, Text, Title, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCamera, IconDownload } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { downloadArtifact, useArtifactImage, useRunArtifacts } from '../../api/automation';
import { errorMessage } from '../../api/errors';
import { ARTIFACT_ORDER, fileSize } from './model';

const KIND_COLORS = { SCREENSHOT: 'red', SYSTEM_TRACE: 'gray', JUNIT: 'blue', JEST: 'grape', REPORT: 'teal', OTHER: 'gray' } as const;

/** ADR-0021 artefacts d'un run : traces système, JUnit XML, Jest JSON, rapport, copies d'écran des échecs. */
export function RunArtifactsCard({ project, runKey, refreshKey }: { project: string; runKey: string; refreshKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading, error } = useRunArtifacts(project, runKey, refreshKey);
  const [shown, setShown] = useState<string | null>(null);
  const artifacts = [...(data ?? [])].sort((a, b) => ARTIFACT_ORDER.indexOf(a.kind) - ARTIFACT_ORDER.indexOf(b.kind) || a.name.localeCompare(b.name));
  const download = (name: string) =>
    downloadArtifact(project, runKey, name).catch((e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }));

  return (
    <Card withBorder data-testid="run-artifacts">
      <Title order={5}>{t('runs.artifacts')}</Title>
      {isLoading && <Loader size="sm" mt="xs" />}
      {error && (
        <Alert color="orange" mt="xs">
          {errorMessage(error, t('errors.generic'))}
        </Alert>
      )}
      {data && artifacts.length === 0 && (
        <Text size="sm" c="dimmed" mt="xs">
          {t('runs.noArtifacts')}
        </Text>
      )}
      {artifacts.length > 0 && (
        <Table mt="xs">
          <Table.Tbody>
            {artifacts.map((a) => (
              <Table.Tr key={a.name} data-testid={`run-artifact-${a.name}`}>
                <Table.Td>
                  <Badge variant="light" color={KIND_COLORS[a.kind]}>
                    {t(`artifactKind.${a.kind}`)}
                  </Badge>
                </Table.Td>
                <Table.Td>
                  <Text size="sm" ff="monospace">
                    {a.name}
                  </Text>
                  {a.testKey && (
                    <Text size="xs" c="dimmed">
                      {a.testKey}
                    </Text>
                  )}
                </Table.Td>
                <Table.Td>
                  <Text size="xs" c="dimmed">
                    {fileSize(a.size)}
                  </Text>
                </Table.Td>
                <Table.Td>
                  <Group gap={4} justify="flex-end" wrap="nowrap">
                    {a.kind === 'SCREENSHOT' && (
                      <Tooltip label={t('runs.showScreenshot')}>
                        <ActionIcon variant="subtle" onClick={() => setShown(a.name)} aria-label={t('runs.showScreenshot')} data-testid={`run-artifact-view-${a.name}`}>
                          <IconCamera size={16} />
                        </ActionIcon>
                      </Tooltip>
                    )}
                    <Tooltip label={t('runs.download')}>
                      <ActionIcon variant="subtle" onClick={() => void download(a.name)} aria-label={t('runs.download')} data-testid={`run-artifact-download-${a.name}`}>
                        <IconDownload size={16} />
                      </ActionIcon>
                    </Tooltip>
                  </Group>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
      <ScreenshotModal project={project} runKey={runKey} name={shown} onClose={() => setShown(null)} />
    </Card>
  );
}

/** ADR-0021 bouton « Copie d'écran » d'un test en échec. */
export function ScreenshotButton({ project, runKey, name, testKey }: { project: string; runKey: string; name: string; testKey: string }) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  return (
    <>
      <Button size="compact-xs" variant="light" color="red" leftSection={<IconCamera size={14} />} onClick={() => setOpen(true)}
        data-testid={`run-screenshot-${testKey}`}>
        {t('runs.screenshot')}
      </Button>
      <ScreenshotModal project={project} runKey={runKey} name={open ? name : null} onClose={() => setOpen(false)} />
    </>
  );
}

function ScreenshotModal({ project, runKey, name, onClose }: { project: string; runKey: string; name: string | null; onClose: () => void }) {
  const { t } = useTranslation();
  const { url, isLoading, error } = useArtifactImage(project, runKey, name);
  return (
    <Modal opened={!!name} onClose={onClose} size="xl" title={name ?? ''} data-testid="screenshot-modal">
      <Stack>
        {isLoading && (
          <Center>
            <Loader />
          </Center>
        )}
        {error && <Alert color="orange">{errorMessage(error, t('errors.generic'))}</Alert>}
        {url && <Image src={url} alt={t('runs.screenshotOf', { name })} data-testid="screenshot-image" />}
        {name && (
          <Group justify="flex-end">
            <Button variant="default" leftSection={<IconDownload size={16} />} onClick={() => void downloadArtifact(project, runKey, name)}>
              {t('runs.download')}
            </Button>
          </Group>
        )}
      </Stack>
    </Modal>
  );
}
