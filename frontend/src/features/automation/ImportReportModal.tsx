import { Alert, Badge, Button, Checkbox, Group, Input, Modal, Select, Stack, Table, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useImportReport, type ReportFormat, type ReportImport } from '../../api/automation';
import { errorMessage } from '../../api/errors';
import { ExecutionStatusBadge } from '../campaigns/CampaignBadges';
import { duration } from '../campaigns/model';
import { guessFormat, REPORT_FORMATS } from './model';

/**
 * F-EXE-10 import d'un rapport (JUnit XML, Cucumber JSON, Robot output.xml, Playwright JSON) :
 * aperçu du rapprochement (identifiant ou tag d'exigence), création facultative des inconnus, puis import.
 */
export function ImportReportModal({ project, campaignKey, opened, onClose }: { project: string; campaignKey: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const importReport = useImportReport(project, campaignKey);
  const [file, setFile] = useState<File | null>(null);
  const [format, setFormat] = useState<ReportFormat>('JUNIT');
  const [preview, setPreview] = useState<ReportImport | null>(null);
  const [createUnknown, setCreateUnknown] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setFile(null);
      setPreview(null);
      setError(null);
    }
  }, [opened]);

  const analyse = async (selected: File | null, chosen: ReportFormat) => {
    setPreview(null);
    setError(null);
    if (!selected) return;
    try {
      setPreview(await importReport.mutateAsync({ file: selected, format: chosen, apply: false, createUnknown: false }));
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  const apply = async () => {
    if (!file) return;
    try {
      const result = await importReport.mutateAsync({ file, format, apply: true, createUnknown });
      notifications.show({
        color: 'green',
        message: t('import.done', { count: result.recorded }) + (result.created.length ? ` ${t('import.createdTests', { keys: result.created.join(', ') })}` : ''),
      });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  const unknown = preview?.lines.filter((l) => !l.testKey).length ?? 0;
  const recordable = (preview?.lines.length ?? 0) - (createUnknown ? 0 : unknown);

  return (
    <Modal opened={opened} onClose={onClose} title={t('import.title', { key: campaignKey })} size="xl">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <Group align="flex-end">
          <Input.Wrapper label={t('import.file')} description={t('import.filePlaceholder')} id="report-file" w={320}>
            <input
              id="report-file"
              type="file"
              accept=".xml,.json"
              onChange={(e) => {
                const f = e.currentTarget.files?.[0] ?? null;
                setFile(f);
                const guessed = f ? guessFormat(f.name) : format;
                setFormat(guessed);
                void analyse(f, guessed);
              }}
              data-testid="import-file"
            />
          </Input.Wrapper>
          <Select label={t('import.format')} data={REPORT_FORMATS.map((f) => ({ value: f, label: t(`reportFormat.${f}`) }))} value={format}
            onChange={(v) => {
              if (!v) return;
              setFormat(v as ReportFormat);
              void analyse(file, v as ReportFormat);
            }}
            allowDeselect={false} w={220} data-testid="import-format" />
        </Group>
        {preview && (
          <>
            <Text size="sm" data-testid="import-summary">
              {t('import.summary', { total: preview.lines.length, matched: preview.lines.length - unknown, unknown })}
            </Text>
            <Table striped data-testid="import-lines">
              <Table.Tbody>
                {preview.lines.map((line, index) => (
                  <Table.Tr key={index}>
                    <Table.Td>
                      <Text size="sm">{line.name}</Text>
                      <Text size="xs" c="dimmed" ff="monospace">
                        {line.identifier}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <ExecutionStatusBadge status={line.status} />
                    </Table.Td>
                    <Table.Td>
                      <Text size="xs">{duration(line.durationMs)}</Text>
                    </Table.Td>
                    <Table.Td>
                      {line.testKey ? (
                        <Badge variant="light" color="blue">
                          {line.testKey} · {t(`import.matchedBy.${line.matchedBy}`)}
                        </Badge>
                      ) : (
                        <Badge variant="outline" color="orange">
                          {t('import.unknown')}
                          {line.requirementKeys.length > 0 ? ` · ${line.requirementKeys.join(', ')}` : ''}
                        </Badge>
                      )}
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
            {unknown > 0 && (
              <Checkbox label={t('import.createUnknown', { count: unknown })} checked={createUnknown} onChange={(e) => setCreateUnknown(e.currentTarget.checked)}
                data-testid="import-create-unknown" />
            )}
          </>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={apply} loading={importReport.isPending} disabled={!preview || recordable === 0} data-testid="import-submit">
            {t('import.submit', { count: recordable })}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
