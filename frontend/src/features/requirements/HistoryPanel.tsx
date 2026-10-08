import { Loader, Text, Timeline } from '@mantine/core';
import { IconHistory } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { useHistory } from '../../api/requirements';

/** F-REQ-22 historique : AuditEvent de l'exigence (NF-16 qui, quand, quoi). */
export function HistoryPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { data, isLoading } = useHistory(project, requirementKey);
  return <HistoryTimeline data={data} isLoading={isLoading} />;
}

/** Frise des AuditEvent d'une entité (exigence, test…). */
export function HistoryTimeline({ data, isLoading }: { data?: Schemas['PageResponseAuditEventResponse']; isLoading: boolean }) {
  const { t, i18n } = useTranslation();
  if (isLoading) return <Loader />;
  if (!data || data.content.length === 0) return <Text c="dimmed">{t('history.empty')}</Text>;
  return (
    <Timeline bulletSize={22} lineWidth={2} data-testid="history">
      {data.content.map((event, index) => (
        <Timeline.Item key={index} bullet={<IconHistory size={12} />} title={t(`history.actions.${event.action}`)}>
          <Text size="xs" c="dimmed">
            {t('history.by', { actor: event.actor ?? '—' })} · {new Date(event.timestamp).toLocaleString(i18n.language)}
          </Text>
          {event.changes.map((change) => (
            <Text key={change.field} size="sm">
              <Text span fw={600}>
                {t(`fieldNames.${change.field}`, { defaultValue: change.field })}
              </Text>{' '}
              : <Text span td="line-through" c="dimmed">{change.before ?? '—'}</Text> → <Text span>{change.after ?? '—'}</Text>
            </Text>
          ))}
        </Timeline.Item>
      ))}
    </Timeline>
  );
}
