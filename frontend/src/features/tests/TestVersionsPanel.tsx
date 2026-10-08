import { Group, Loader, Select, Stack, Table, Text, Title } from '@mantine/core';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTestHistory, useTestVersionDiff, useTestVersions } from '../../api/testcases';
import { HistoryTimeline } from '../requirements/HistoryPanel';

/** F-AUT-10 versions d'un test (créées à chaque modification significative) et comparaison. */
export function TestVersionsPanel({ project, testKey }: { project: string; testKey: string }) {
  const { t, i18n } = useTranslation();
  const { data: versions, isLoading } = useTestVersions(project, testKey);
  const [from, setFrom] = useState<number | null>(null);
  const [to, setTo] = useState<number | null>(null);
  useEffect(() => {
    if (versions && versions.length >= 2 && from === null && to === null) {
      setFrom(versions[1]!.versionNumber);
      setTo(versions[0]!.versionNumber);
    }
  }, [versions, from, to]);
  const { data: diff } = useTestVersionDiff(project, testKey, from, to);

  if (isLoading) return <Loader />;
  const options = (versions ?? []).map((v) => ({ value: String(v.versionNumber), label: t('test.version', { number: v.versionNumber }) }));

  return (
    <Stack>
      <Table data-testid="test-versions-table">
        <Table.Tbody>
          {versions?.map((v) => (
            <Table.Tr key={v.versionNumber}>
              <Table.Td fw={600}>{t('test.version', { number: v.versionNumber })}</Table.Td>
              <Table.Td>{v.createdBy}</Table.Td>
              <Table.Td>{new Date(v.createdAt).toLocaleString(i18n.language)}</Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
      {(versions?.length ?? 0) >= 2 && (
        <>
          <Title order={5}>{t('versions.compare')}</Title>
          <Group>
            <Select label={t('versions.from')} data={options} value={from === null ? null : String(from)} onChange={(v) => setFrom(v ? Number(v) : null)} allowDeselect={false} />
            <Select label={t('versions.to')} data={options} value={to === null ? null : String(to)} onChange={(v) => setTo(v ? Number(v) : null)} allowDeselect={false} />
          </Group>
          {diff && diff.length === 0 && <Text c="dimmed">{t('versions.noDiff')}</Text>}
          {diff && diff.length > 0 && (
            <Table withColumnBorders data-testid="test-version-diff">
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>{t('versions.field')}</Table.Th>
                  <Table.Th>{t('test.version', { number: from })}</Table.Th>
                  <Table.Th>{t('test.version', { number: to })}</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {diff.map((change) => (
                  <Table.Tr key={change.field}>
                    <Table.Td fw={600}>{t(`fieldNames.${change.field}`, { defaultValue: change.field })}</Table.Td>
                    <Table.Td style={{ whiteSpace: 'pre-wrap', background: 'var(--mantine-color-red-light)' }}>{change.before ?? '—'}</Table.Td>
                    <Table.Td style={{ whiteSpace: 'pre-wrap', background: 'var(--mantine-color-green-light)' }}>{change.after ?? '—'}</Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          )}
        </>
      )}
    </Stack>
  );
}

/** NF-16 historique d'un test. */
export function TestHistoryPanel({ project, testKey }: { project: string; testKey: string }) {
  const { data, isLoading } = useTestHistory(project, testKey);
  return <HistoryTimeline data={data} isLoading={isLoading} />;
}
