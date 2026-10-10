import { Badge, Button, Group, Loader, NumberInput, Paper, Stack, Table, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useMeasurements, useRecordMeasurement, type Measurement } from '../../api/workshop';
import { KeyLink } from '../../components/keys/KeyLink';
import { useAuthStore } from '../auth/authStore';

const OUTCOME_COLORS: Record<Measurement['outcome'], string> = { TARGET_MET: 'green', THRESHOLD_MET: 'yellow', NOT_MET: 'red', UNKNOWN: 'gray' };

/** Saisir une mesure : qui crée ou modifie des tests (testeur, développeur, administrateur). */
function useCanMeasure(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (user?.systemAdmin) return true;
  const role = user?.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'TESTER' || role === 'DEVELOPER';
}

/** F-REQ-18 valeurs mesurées d'une ENF : dernière mesure comparée au seuil et à la cible, historique, saisie. */
export function MeasurementsPanel({ project, requirementKey, threshold, target, unit }: { project: string; requirementKey: string; threshold?: string;
  target?: string; unit?: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useMeasurements(project, requirementKey);
  const record = useRecordMeasurement(project, requirementKey);
  const canMeasure = useCanMeasure(project);
  const [value, setValue] = useState<number | string>('');
  const last = data?.[0];
  const submit = () =>
    record.mutate(Number(value), {
      onSuccess: () => setValue(''),
      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
    });

  return (
    <Paper withBorder p="sm" data-testid="measurements">
      <Stack gap="xs">
        <Group justify="space-between">
          <Title order={6}>{t('measurements.title')}</Title>
          <Text size="xs" c="dimmed">
            {t('measurements.limits', { threshold: threshold || '—', target: target || '—', unit: unit ?? '' })}
          </Text>
        </Group>
        {isLoading && <Loader size="xs" />}
        {last ? (
          <Group gap="xs" data-testid="measurement-last">
            <Text fz={22} fw={700}>
              {last.value} {last.unit ?? ''}
            </Text>
            <Badge color={OUTCOME_COLORS[last.outcome]} data-outcome={last.outcome}>
              {t(`measurements.outcome.${last.outcome}`)}
            </Badge>
          </Group>
        ) : (
          !isLoading && (
            <Text size="sm" c="dimmed">
              {t('measurements.none')}
            </Text>
          )
        )}
        {!!data?.length && (
          <Table fz="xs">
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('measurements.date')}</Table.Th>
                <Table.Th>{t('measurements.value')}</Table.Th>
                <Table.Th>{t('measurements.source')}</Table.Th>
                <Table.Th>{t('measurements.result')}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {data.map((m, index) => (
                <Table.Tr key={index}>
                  <Table.Td>{new Date(m.measuredAt).toLocaleString()}</Table.Td>
                  <Table.Td>
                    {m.value} {m.unit ?? ''}
                    {m.metric ? ` (${m.metric})` : ''}
                  </Table.Td>
                  <Table.Td>
                    {m.testKey ? (
                      <Group gap={4}>
                        <KeyLink project={project} itemKey={m.testKey} size="xs" />
                        {m.runKey && <KeyLink project={project} itemKey={m.runKey} size="xs" />}
                      </Group>
                    ) : (
                      t('measurements.manual', { by: m.createdBy ?? '—' })
                    )}
                  </Table.Td>
                  <Table.Td>
                    <Badge size="xs" color={OUTCOME_COLORS[m.outcome]} variant="light">
                      {t(`measurements.outcome.${m.outcome}`)}
                    </Badge>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}
        {canMeasure && (
          <Group align="flex-end" gap="xs">
            <NumberInput size="xs" label={t('measurements.newValue')} value={value} onChange={setValue} decimalSeparator="," rightSection={unit}
              w={160} data-testid="measurement-input" />
            <Button size="xs" onClick={submit} disabled={value === ''} loading={record.isPending} data-testid="measurement-submit">
              {t('measurements.record')}
            </Button>
          </Group>
        )}
      </Stack>
    </Paper>
  );
}
