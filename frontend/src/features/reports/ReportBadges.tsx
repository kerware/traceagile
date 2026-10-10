import { Badge } from '@mantine/core';
import { IconLock } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import type { Verdict } from '../../api/reports';
import { VERDICT_COLORS } from './model';

/** §9.2 verdict : Go, Go sous réserve, No go. */
export function VerdictBadge({ verdict, testId }: { verdict?: Verdict | null; testId?: string }) {
  const { t } = useTranslation();
  if (!verdict) return null;
  return (
    <Badge color={VERDICT_COLORS[verdict]} variant="filled" data-testid={testId} data-verdict={verdict}>
      {t(`verdict.${verdict}`)}
    </Badge>
  );
}

/** F-RPT-04 instantané figé. */
export function FrozenBadge({ testId }: { testId?: string }) {
  const { t } = useTranslation();
  return (
    <Badge color="gray" variant="light" leftSection={<IconLock size={12} />} data-testid={testId}>
      {t('reports.frozen')}
    </Badge>
  );
}
