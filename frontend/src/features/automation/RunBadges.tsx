import { Badge, Group, Progress, Text, Tooltip } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { RunStatus } from '../../api/automation';
import { RUN_STATUS_COLORS, progressPercent } from './model';
import type { RunCountsLike } from './types';

export function RunStatusBadge({ status, testId }: { status: RunStatus; testId?: string }) {
  const { t } = useTranslation();
  return (
    <Badge color={RUN_STATUS_COLORS[status]} variant="light" data-testid={testId} data-status={status}>
      {t(`runStatus.${status}`)}
    </Badge>
  );
}

/** F-EXE-11 test instable. */
export function FlakyBadge() {
  const { t } = useTranslation();
  return (
    <Tooltip label={t('runs.flakyHint')}>
      <Badge size="xs" color="yellow" variant="outline" data-testid="flaky-badge">
        {t('runs.flaky')}
      </Badge>
    </Tooltip>
  );
}

/** Avancement et résultats d'un run. */
export function RunProgress({ counts }: { counts: RunCountsLike }) {
  const { t } = useTranslation();
  const total = Math.max(1, counts.total);
  return (
    <div data-testid="run-progress">
      <Progress.Root size="lg">
        <Progress.Section value={(counts.passed / total) * 100} color="green" />
        <Progress.Section value={(counts.failed / total) * 100} color="red" />
        <Progress.Section value={(counts.error / total) * 100} color="grape" />
        <Progress.Section value={(counts.skipped / total) * 100} color="gray" />
        <Progress.Section value={(counts.running / total) * 100} color="blue" animated />
      </Progress.Root>
      <Group gap="md" mt={4}>
        <Text size="xs" c="dimmed">
          {t('runs.done', { percent: progressPercent(counts), total: counts.total })}
        </Text>
        <Text size="xs" c="green">
          {t('runs.passed', { count: counts.passed })}
        </Text>
        <Text size="xs" c="red">
          {t('runs.failed', { count: counts.failed })}
        </Text>
        {counts.error > 0 && (
          <Text size="xs" c="grape">
            {t('runs.error', { count: counts.error })}
          </Text>
        )}
        {counts.skipped > 0 && (
          <Text size="xs" c="dimmed">
            {t('runs.skipped', { count: counts.skipped })}
          </Text>
        )}
        {counts.pending + counts.running > 0 && (
          <Text size="xs" c="blue">
            {t('runs.inFlight', { count: counts.pending + counts.running })}
          </Text>
        )}
      </Group>
    </div>
  );
}
