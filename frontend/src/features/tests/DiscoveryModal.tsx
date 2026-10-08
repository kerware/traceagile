import { Alert, Button, Group, Input, List, Modal, Stack, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useDiscovery } from '../../api/testcases';

/** F-AUT-08 import d'un rapport de découverte (tests du dépôt). */
export function DiscoveryModal({ project, opened, onClose }: { project: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const discovery = useDiscovery(project);
  const [file, setFile] = useState<File | null>(null);
  const [failure, setFailure] = useState<string | null>(null);
  const [result, setResult] = useState<Schemas['DiscoveryResponse'] | null>(null);

  const close = () => {
    setFile(null);
    setFailure(null);
    setResult(null);
    onClose();
  };

  const submit = async () => {
    if (!file) return;
    setFailure(null);
    let report: Schemas['DiscoveryReport'];
    try {
      report = JSON.parse(await file.text()) as Schemas['DiscoveryReport'];
    } catch {
      setFailure(t('discovery.invalidJson'));
      return;
    }
    try {
      const response = await discovery.mutateAsync(report);
      notifications.show({
        color: 'green',
        message: t('discovery.done', { created: response.created.length, updated: response.updated.length, disappeared: response.disappeared.length }),
      });
      setResult(response);
    } catch (error) {
      setFailure(errorMessage(error, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('discovery.title')} size="lg">
      <Stack>
        <Text size="sm" c="dimmed">
          {t('discovery.help')}
        </Text>
        <Input.Wrapper label={t('discovery.file')} id="discovery-file">
          <input id="discovery-file" type="file" accept=".json,application/json" onChange={(e) => setFile(e.currentTarget.files?.[0] ?? null)} data-testid="discovery-file-input" />
        </Input.Wrapper>
        {failure && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        {result && (
          <Alert color={result.disappeared.length > 0 || result.warnings.length > 0 ? 'yellow' : 'green'} data-testid="discovery-result">
            <Text size="sm">{t('discovery.done', { created: result.created.length, updated: result.updated.length, disappeared: result.disappeared.length })}</Text>
            {result.disappeared.length > 0 && <Text size="sm">{t('tests.missing')} : {result.disappeared.join(', ')}</Text>}
            <List size="sm">
              {result.warnings.map((w) => (
                <List.Item key={w}>{w}</List.Item>
              ))}
            </List>
          </Alert>
        )}
        <Group justify="flex-end">
          <Button onClick={submit} disabled={!file} loading={discovery.isPending} data-testid="discovery-submit">
            {t('discovery.submit')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
