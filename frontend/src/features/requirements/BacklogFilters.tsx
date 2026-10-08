import { Button, Group, MultiSelect, TextInput } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { RequirementFilters } from '../../api/requirements';
import { hasFilters } from './filters';
import { PRIORITIES, REQUIREMENT_STATUSES, REQUIREMENT_TYPES, RISK_LEVELS } from './model';

/** F-REQ-01 barre de filtres de la vue liste. */
export function BacklogFilters({
  filters,
  onChange,
}: {
  filters: RequirementFilters;
  onChange: (changes: Record<string, string | string[] | null>) => void;
}) {
  const { t } = useTranslation();
  const options = (values: string[], prefix: string) => values.map((value) => ({ value, label: t(`${prefix}.${value}`) }));

  return (
    <Group align="flex-end" data-testid="backlog-filters">
      <MultiSelect
        label={t('backlog.filterType')}
        data={options(REQUIREMENT_TYPES, 'requirementType')}
        value={filters.type ?? []}
        onChange={(value) => onChange({ type: value })}
        clearable
        w={220}
        data-testid="filter-type"
      />
      <MultiSelect
        label={t('backlog.filterStatus')}
        data={options(REQUIREMENT_STATUSES, 'requirementStatus')}
        value={filters.status ?? []}
        onChange={(value) => onChange({ status: value })}
        clearable
        w={200}
        data-testid="filter-status"
      />
      <MultiSelect
        label={t('backlog.filterPriority')}
        data={options(PRIORITIES, 'priority')}
        value={filters.priority ?? []}
        onChange={(value) => onChange({ priority: value })}
        clearable
        w={180}
        data-testid="filter-priority"
      />
      <MultiSelect
        label={t('backlog.filterRisk')}
        data={options(RISK_LEVELS, 'risk')}
        value={filters.risk ?? []}
        onChange={(value) => onChange({ risk: value })}
        clearable
        w={180}
        data-testid="filter-risk"
      />
      <TextInput
        label={t('backlog.filterTag')}
        defaultValue={filters.tag ?? ''}
        onBlur={(e) => onChange({ tag: e.currentTarget.value.trim() || null })}
        onKeyDown={(e) => {
          if (e.key === 'Enter') onChange({ tag: e.currentTarget.value.trim() || null });
        }}
        w={140}
        data-testid="filter-tag"
      />
      {hasFilters(filters) && (
        <Button
          variant="subtle"
          onClick={() => onChange({ type: null, status: null, priority: null, risk: null, tag: null, q: null })}
          data-testid="filters-reset"
        >
          {t('backlog.resetFilters')}
        </Button>
      )}
    </Group>
  );
}
