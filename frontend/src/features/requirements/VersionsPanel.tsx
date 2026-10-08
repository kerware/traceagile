import { Button, Group, Loader, Select, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconSnowflake } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useFreezeVersion, useVersionDiff, useVersions, type RequirementDetail } from '../../api/requirements';

/** F-REQ-21 versions figées (automatiques au passage à « Prête » ou sur demande) et comparaison côte à côte. */
export function VersionsPanel({ project, requirement, canWrite }: { project: string; requirement: RequirementDetail; canWrite: boolean }) {
  const { t, i18n } = useTranslation();
  const { data: versions, isLoading } = useVersions(project, requirement.key);
  const freeze = useFreezeVersion(project, requirement.key);
  const [comment, setComment] = useState('');
  const [from, setFrom] = useState<number | null>(null);
  const [to, setTo] = useState<number | null>(null);

  useEffect(() => {
    if (versions && versions.length >= 2 && from === null && to === null) {
      setFrom(versions[1]!.versionNumber);
      setTo(versions[0]!.versionNumber);
    }
  }, [versions, from, to]);

  const { data: diff } = useVersionDiff(project, requirement.key, from, to);

  if (isLoading) return <Loader />;
  const options = (versions ?? []).map((v) => ({ value: String(v.versionNumber), label: t('versions.version', { number: v.versionNumber }) }));
  const date = (iso: string) => new Date(iso).toLocaleString(i18n.language);

  const onFreeze = () =>
    freeze.mutate(comment, {
      onSuccess: (version) => {
        setComment('');
        notifications.show({ color: 'green', message: t('versions.frozen', { number: version.versionNumber }) });
      },
      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
    });

  return (
    <Stack>
      {canWrite && requirement.status !== 'OBSOLETE' && (
        <Group align="flex-end">
          <TextInput flex={1} label={t('versions.comment')} value={comment} maxLength={500} onChange={(e) => setComment(e.currentTarget.value)} data-testid="version-comment" />
          <Button leftSection={<IconSnowflake size={16} />} onClick={onFreeze} loading={freeze.isPending} data-testid="version-freeze">
            {t('versions.freeze')}
          </Button>
        </Group>
      )}
      <Title order={5}>{t('versions.title')}</Title>
      {versions?.length === 0 ? (
        <Text c="dimmed">{t('versions.empty')}</Text>
      ) : (
        <Table data-testid="versions-table">
          <Table.Tbody>
            {versions?.map((v) => (
              <Table.Tr key={v.versionNumber}>
                <Table.Td fw={600}>{t('versions.version', { number: v.versionNumber })}</Table.Td>
                <Table.Td>{v.changeComment ?? '—'}</Table.Td>
                <Table.Td>{v.createdBy}</Table.Td>
                <Table.Td>{date(v.createdAt)}</Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
      {(versions?.length ?? 0) >= 2 && (
        <>
          <Title order={5}>{t('versions.compare')}</Title>
          <Group>
            <Select label={t('versions.from')} data={options} value={from === null ? null : String(from)} onChange={(v) => setFrom(v ? Number(v) : null)} allowDeselect={false} data-testid="version-from" />
            <Select label={t('versions.to')} data={options} value={to === null ? null : String(to)} onChange={(v) => setTo(v ? Number(v) : null)} allowDeselect={false} data-testid="version-to" />
          </Group>
          {diff && diff.length === 0 && <Text c="dimmed">{t('versions.noDiff')}</Text>}
          {diff && diff.length > 0 && (
            <Table withColumnBorders data-testid="version-diff">
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>{t('versions.field')}</Table.Th>
                  <Table.Th>{t('versions.version', { number: from })}</Table.Th>
                  <Table.Th>{t('versions.version', { number: to })}</Table.Th>
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
