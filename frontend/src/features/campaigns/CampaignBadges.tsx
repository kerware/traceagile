import { Badge, Group, Progress, Text, Tooltip } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { CampaignStatus, CampaignSummary, DefectSeverity, DefectStatus, ExecutionStatus } from '../../api/campaigns';
import { CAMPAIGN_STATUS_COLORS, DEFECT_STATUS_COLORS, EXECUTION_COLORS, SEVERITY_COLORS } from './model';

export function CampaignStatusBadge({ status }: { status: CampaignStatus }) {
  const { t } = useTranslation();
  return (
    <Badge variant="light" color={CAMPAIGN_STATUS_COLORS[status]} data-testid="campaign-status">
      {t(`campaignStatus.${status}`)}
    </Badge>
  );
}

export function ExecutionStatusBadge({ status, testId }: { status: ExecutionStatus; testId?: string }) {
  const { t } = useTranslation();
  return (
    <Badge variant={status === 'NOT_RUN' ? 'outline' : 'light'} color={EXECUTION_COLORS[status]} data-testid={testId} data-status={status}>
      {t(`executionStatus.${status}`)}
    </Badge>
  );
}

export function SeverityBadge({ severity }: { severity: DefectSeverity }) {
  const { t } = useTranslation();
  return (
    <Badge variant="filled" color={SEVERITY_COLORS[severity]} size="sm">
      {t(`severity.${severity}`)}
    </Badge>
  );
}

export function DefectStatusBadge({ status }: { status: DefectStatus }) {
  const { t } = useTranslation();
  return (
    <Badge variant="light" color={DEFECT_STATUS_COLORS[status]} data-testid="defect-status" data-status={status}>
      {t(`defectStatus.${status}`)}
    </Badge>
  );
}

/** Avancement : une barre segmentée par statut de la dernière tentative. */
export function ProgressBar({ progress }: { progress: CampaignSummary['progress'] }) {
  const { t } = useTranslation();
  const order: ExecutionStatus[] = ['PASSED', 'FAILED', 'BLOCKED', 'ERROR', 'SKIPPED', 'RUNNING'];
  return (
    <div data-testid="campaign-progress">
      <Progress.Root size="lg">
        {order.map((status) => {
          const count = progress.byStatus[status] ?? 0;
          if (!count || !progress.total) return null;
          return (
            <Tooltip key={status} label={`${t(`executionStatus.${status}`)} : ${count}`}>
              <Progress.Section value={(count * 100) / progress.total} color={EXECUTION_COLORS[status]} aria-label={`${t(`executionStatus.${status}`)} : ${count}`} />
            </Tooltip>
          );
        })}
      </Progress.Root>
      <Group gap="md" mt={4}>
        <Text size="xs" c="dimmed">
          {t('campaigns.progressLabel', { executed: progress.executed, total: progress.total })}
        </Text>
        {progress.passRate !== undefined && progress.passRate !== null && (
          <Text size="xs" c="dimmed">
            {t('campaigns.passRate', { rate: progress.passRate })}
          </Text>
        )}
      </Group>
    </div>
  );
}
