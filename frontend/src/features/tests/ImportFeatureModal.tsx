import { Alert, Button, Group, Input, List, Modal, Select, Stack, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ApiError, errorMessage } from '../../api/errors';
import { useFrameworks, useImportFeatures } from '../../api/testcases';

interface FileError {
  file: string;
  errors: { line: number; message: string }[];
}

/** F-AUT-05 / F-AUT-07 import de fichiers .feature (ou d'un zip) : un test BDD par scénario. */
export function ImportFeatureModal({ project, opened, onClose }: { project: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const importFeatures = useImportFeatures(project);
  const { data: frameworks } = useFrameworks();
  const [files, setFiles] = useState<File[]>([]);
  const [framework, setFramework] = useState<string | null>(null);
  const [failure, setFailure] = useState<string | null>(null);
  const [fileErrors, setFileErrors] = useState<FileError[]>([]);
  const [warnings, setWarnings] = useState<string[]>([]);

  const close = () => {
    setFiles([]);
    setFailure(null);
    setFileErrors([]);
    setWarnings([]);
    onClose();
  };

  const submit = async () => {
    setFailure(null);
    setFileErrors([]);
    try {
      const result = await importFeatures.mutateAsync({ files, framework: framework ?? undefined });
      notifications.show({ color: 'green', message: t('featureImport.done', { created: result.created.length, updated: result.updated.length }) });
      if (result.warnings.length > 0) setWarnings(result.warnings);
      else close();
    } catch (error) {
      setFailure(errorMessage(error, t('errors.generic')));
      if (error instanceof ApiError && Array.isArray(error.problem.fileErrors)) setFileErrors(error.problem.fileErrors as FileError[]);
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('featureImport.title')} size="lg">
      <Stack>
        <Text size="sm" c="dimmed">
          {t('featureImport.help')}
        </Text>
        <Input.Wrapper label={t('featureImport.files')} id="feature-files">
          <input
            id="feature-files"
            type="file"
            multiple
            accept=".feature,.zip"
            onChange={(e) => setFiles(Array.from(e.currentTarget.files ?? []))}
            data-testid="feature-files-input"
          />
        </Input.Wrapper>
        <Select
          label={t('featureImport.framework')}
          data={(frameworks ?? []).filter((f) => f.technique === 'BDD').map((f) => f.name)}
          value={framework}
          onChange={setFramework}
          clearable
        />
        {failure && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        {fileErrors.map((f) => (
          <Alert key={f.file} color="red" title={f.file}>
            <List size="sm">
              {f.errors.map((e, i) => (
                <List.Item key={i}>
                  {t('criteria.line', { line: e.line })} : {e.message}
                </List.Item>
              ))}
            </List>
          </Alert>
        ))}
        {warnings.length > 0 && (
          <Alert color="yellow" title={t('test.warnings')} data-testid="feature-import-warnings">
            <List size="sm">
              {warnings.map((w) => (
                <List.Item key={w}>{w}</List.Item>
              ))}
            </List>
          </Alert>
        )}
        <Group justify="flex-end">
          <Button onClick={submit} disabled={files.length === 0} loading={importFeatures.isPending} data-testid="feature-import-submit">
            {t('featureImport.submit')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
