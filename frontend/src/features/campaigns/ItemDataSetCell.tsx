import { ActionIcon, Group, Menu, Select, Text, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconLayoutRows } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { useExpandDataSet, useItemDataSet, type CampaignItem } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { itemSuffix } from './model';

/** Valeurs d'une ligne, pour l'infobulle. */
function describe(values: Record<string, string>): string {
  const entries = Object.entries(values);
  return entries.length === 0 ? '—' : entries.map(([k, v]) => `${k} = ${v}`).join(' · ');
}

/**
 * ADR-0018 jeu de données prévu pour un test manuel de la campagne : choix d'une ligne (modifiable
 * tant que le test n'a pas été exécuté) et déclinaison sur toutes les lignes d'un jeu.
 */
export function ItemDataSetCell({ project, campaignKey, item, editable }: { project: string; campaignKey: string; item: CampaignItem; editable: boolean }) {
  const { t } = useTranslation();
  const bind = useItemDataSet(project);
  const expand = useExpandDataSet(project, campaignKey);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const sfx = itemSuffix(item);

  if (item.test.kind !== 'MANUAL' || item.dataSets.length === 0) {
    return (
      <Text size="sm" c="dimmed">
        —
      </Text>
    );
  }
  const label = item.dataSetName ? t('executions.dataRow', { name: item.dataSetName, row: item.dataSetRowName ?? (item.dataSetRow ?? 0) + 1 }) : t('executions.defaultValues');

  if (!editable || item.attempts > 0) {
    return (
      <Tooltip label={describe(item.dataSetValues)} disabled={!item.dataSetName}>
        <Text size="sm" data-testid={`item-dataset-${item.test.key}${sfx}`}>
          {label}
        </Text>
      </Tooltip>
    );
  }

  const options = [
    { value: '', label: t('executions.defaultValues') },
    ...item.dataSets.flatMap((d) => Array.from({ length: d.rows }, (_, i) => ({ value: `${d.name}|${i}`, label: t('executions.dataRow', { name: d.name, row: d.rowNames[i] ?? i + 1 }) }))),
  ];
  const onChange = (value: string | null) => {
    const [name, row] = value ? value.split('|') : [null, null];
    bind.mutate({ id: item.id, dataSetName: name ?? null, dataSetRow: row === null || row === undefined ? null : Number(row) }, { onError: fail });
  };

  return (
    <Group gap={4} wrap="nowrap">
      <Tooltip label={describe(item.dataSetValues)} disabled={!item.dataSetName}>
        <Select size="xs" w={170} data={options} value={item.dataSetName ? `${item.dataSetName}|${item.dataSetRow ?? 0}` : ''} onChange={onChange}
          allowDeselect={false} data-testid={`item-dataset-${item.test.key}${sfx}`} />
      </Tooltip>
      <Menu position="bottom-end" withinPortal>
        <Menu.Target>
          <Tooltip label={t('campaigns.expandDataSet')}>
            <ActionIcon variant="subtle" size="sm" loading={expand.isPending} aria-label={t('campaigns.expandDataSet')} data-testid={`item-expand-${item.test.key}${sfx}`}>
              <IconLayoutRows size={14} />
            </ActionIcon>
          </Tooltip>
        </Menu.Target>
        <Menu.Dropdown>
          <Menu.Label>{t('campaigns.expandDataSet')}</Menu.Label>
          {item.dataSets.map((d) => (
            <Menu.Item key={d.name} onClick={() => expand.mutate({ id: item.id, dataSetName: d.name }, { onError: fail })} data-testid={`expand-${d.name}`}>
              {t('campaigns.expandRows', { name: d.name, count: d.rows })}
            </Menu.Item>
          ))}
        </Menu.Dropdown>
      </Menu>
    </Group>
  );
}
