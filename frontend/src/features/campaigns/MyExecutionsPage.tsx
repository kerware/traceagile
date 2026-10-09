import { Anchor, Button, Group, Loader, SegmentedControl, Select, Stack, Table, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlayerPlay } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMyExecutions, useStartExecution, type MyExecution } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { KindBadge } from '../tests/Badges';
import { ExecutionStatusBadge } from './CampaignBadges';
import { minutes } from './model';
import { useCanExecute } from './permissions';

/** §13.2 /p/:key/my-executions — F-EXE-01 « Mes tests à exécuter » dans les campagnes ouvertes. */
export function MyExecutionsPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const { data, isLoading } = useMyExecutions(project);
  const [filter, setFilter] = useState<'todo' | 'all'>('todo');
  const items = (data ?? []).filter((i) => filter === 'all' || i.lastStatus === 'NOT_RUN' || i.lastStatus === 'RUNNING');
  const total = items.reduce((sum, i) => sum + (i.test.durationMin ?? 0), 0);

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('myExecutions.title')}</Title>
        <SegmentedControl value={filter} onChange={(v) => setFilter(v as 'todo' | 'all')}
          data={[{ value: 'todo', label: t('myExecutions.todo') }, { value: 'all', label: t('myExecutions.all') }]} data-testid="my-filter" />
      </Group>
      {isLoading && <Loader />}
      {data && items.length === 0 && <Text c="dimmed">{t('myExecutions.empty')}</Text>}
      {items.length > 0 && (
        <>
          <Text size="sm" c="dimmed">
            {t('myExecutions.summary', { count: items.length, duration: minutes(total) })}
          </Text>
          <Table striped data-testid="my-executions">
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('myExecutions.campaign')}</Table.Th>
                <Table.Th>{t('campaigns.test')}</Table.Th>
                <Table.Th>{t('myExecutions.duration')}</Table.Th>
                <Table.Th>{t('campaigns.lastResult')}</Table.Th>
                <Table.Th />
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {items.map((item) => (
                <Row key={item.itemId} project={project} item={item} />
              ))}
            </Table.Tbody>
          </Table>
        </>
      )}
    </Stack>
  );
}

function Row({ project, item }: { project: string; item: MyExecution }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const canExecute = useCanExecute(project);
  const start = useStartExecution(project);
  const rows = item.dataSets.flatMap((d) => Array.from({ length: d.rows }, (_, i) => ({ value: `${d.name}|${i}`, label: t('executions.dataRow', { name: d.name, row: i + 1 }) })));
  const [row, setRow] = useState<string | null>(null);

  const go = () => {
    if (item.lastStatus === 'RUNNING' && item.latestExecutionId) {
      navigate(`/p/${project}/executions/${item.latestExecutionId}`);
      return;
    }
    const [dataSetName, index] = row ? row.split('|') : [undefined, undefined];
    start.mutate(
      { itemId: item.itemId, dataSetName, row: index === undefined ? undefined : Number(index) },
      { onSuccess: (e) => navigate(`/p/${project}/executions/${e.id}`), onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) },
    );
  };

  return (
    <Table.Tr data-testid={`my-item-${item.test.key}`}>
      <Table.Td>
        <Anchor component={Link} to={`/p/${project}/campaigns/${item.campaign.key}`} size="sm">
          {item.campaign.key}
        </Anchor>
        <Text size="xs" c="dimmed">
          {[item.campaign.environment, item.campaign.buildVersion].filter(Boolean).join(' · ')}
        </Text>
      </Table.Td>
      <Table.Td>
        <Group gap={6} wrap="nowrap">
          <Text ff="monospace" fw={600} size="sm">
            {item.test.key}
          </Text>
          <KindBadge kind={item.test.kind} />
          <Text size="sm">{item.test.title}</Text>
        </Group>
      </Table.Td>
      <Table.Td>{item.test.durationMin ? minutes(item.test.durationMin) : '—'}</Table.Td>
      <Table.Td>
        {item.latestExecutionId ? (
          <Anchor component={Link} to={`/p/${project}/executions/${item.latestExecutionId}`}>
            <ExecutionStatusBadge status={item.lastStatus} />
          </Anchor>
        ) : (
          <ExecutionStatusBadge status={item.lastStatus} />
        )}
      </Table.Td>
      <Table.Td>
        {canExecute && item.test.kind === 'MANUAL' && (
          <Group gap={4} justify="flex-end" wrap="nowrap">
            {rows.length > 0 && item.lastStatus !== 'RUNNING' && (
              <Select size="xs" w={180} placeholder={t('executions.defaultValues')} data={rows} value={row} onChange={setRow} clearable data-testid={`dataset-${item.test.key}`} />
            )}
            <Button size="xs" leftSection={<IconPlayerPlay size={14} />} onClick={go} loading={start.isPending} data-testid={`run-${item.test.key}`}>
              {item.lastStatus === 'RUNNING' ? t('campaigns.resume') : item.attempts > 0 ? t('campaigns.rerun') : t('campaigns.execute')}
            </Button>
          </Group>
        )}
        {item.test.kind === 'EXPLORATORY' && (
          <Text size="xs" c="dimmed">
            {t('myExecutions.sessionsLater')}
          </Text>
        )}
      </Table.Td>
    </Table.Tr>
  );
}
