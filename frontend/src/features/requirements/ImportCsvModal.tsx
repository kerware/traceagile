import { Alert, Button, Group, Input, Modal, Stack, Table, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconFileTypeCsv } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ApiError, errorMessage } from '../../api/errors';
import { useImportCsv } from '../../api/requirements';

interface LineError {
  line: number;
  message: string;
}

/** F-REQ-23 import CSV d'exigences, tout ou rien, avec les erreurs par ligne. */
export function ImportCsvModal({ project, opened, onClose }: { project: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const importCsv = useImportCsv(project);
  const [file, setFile] = useState<File | null>(null);
  const [failure, setFailure] = useState<string | null>(null);
  const [lineErrors, setLineErrors] = useState<LineError[]>([]);

  const close = () => {
    setFile(null);
    setFailure(null);
    setLineErrors([]);
    onClose();
  };

  const submit = async () => {
    if (!file) return;
    setFailure(null);
    setLineErrors([]);
    try {
      const result = await importCsv.mutateAsync(file);
      notifications.show({ color: 'green', message: t('csv.imported', { count: result.created.length }) });
      close();
    } catch (error) {
      setFailure(errorMessage(error, t('errors.generic')));
      if (error instanceof ApiError && Array.isArray(error.problem.lineErrors)) {
        setLineErrors(error.problem.lineErrors as LineError[]);
      }
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('csv.title')} size="lg">
      <Stack>
        <Text size="sm" c="dimmed">
          {t('csv.help')}
        </Text>
        <Input.Wrapper label={t('csv.file')} id="csv-file">
          <Group gap="xs">
            <IconFileTypeCsv size={18} />
            <input
              id="csv-file"
              type="file"
              accept=".csv,text/csv"
              onChange={(e) => setFile(e.currentTarget.files?.[0] ?? null)}
              data-testid="csv-file-input"
            />
          </Group>
        </Input.Wrapper>
        {failure && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        {lineErrors.length > 0 && (
          <Table data-testid="csv-errors">
            <Table.Thead>
              <Table.Tr>
                <Table.Th w={80}>{t('csv.line')}</Table.Th>
                <Table.Th>{t('csv.errors')}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {lineErrors.map((e) => (
                <Table.Tr key={e.line} data-testid={`csv-error-line-${e.line}`}>
                  <Table.Td>{e.line}</Table.Td>
                  <Table.Td>{e.message}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}
        <Group justify="flex-end">
          <Button onClick={submit} disabled={!file} loading={importCsv.isPending} data-testid="csv-submit">
            {t('csv.submit')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
