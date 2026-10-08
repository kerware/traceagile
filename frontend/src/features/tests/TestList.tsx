import { Badge, Group, Loader, Pagination, Table, Text, UnstyledButton } from '@mantine/core';
import { IconArrowsSort, IconSortAscending, IconSortDescending } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { useTestList, type TestCaseSummary, type TestFilters } from '../../api/testcases';
import { PriorityBadge } from '../requirements/Badges';
import { KindBadge, TechniqueBadge, TestStatusBadge } from './Badges';

type SortableColumn = 'key' | 'title' | 'kind' | 'status' | 'priority';

/** §12 liste paginée et triée côté serveur. */
export function TestList({
  project,
  filters,
  page,
  sort,
  onSort,
  onPage,
  onSelect,
}: {
  project: string;
  filters: TestFilters;
  page: number;
  sort: string;
  onSort: (sort: string) => void;
  onPage: (page: number) => void;
  onSelect: (key: string) => void;
}) {
  const { t } = useTranslation();
  const { data, isLoading } = useTestList(project, filters, page, sort);

  const header = (column: SortableColumn, label: string) => {
    const [property, direction] = sort.split(',');
    const active = property === column;
    const Icon = !active ? IconArrowsSort : direction === 'desc' ? IconSortDescending : IconSortAscending;
    return (
      <Table.Th>
        <UnstyledButton onClick={() => onSort(`${column},${active && direction === 'asc' ? 'desc' : 'asc'}`)} data-testid={`test-sort-${column}`}>
          <Group gap={4} wrap="nowrap">
            {label}
            <Icon size={14} />
          </Group>
        </UnstyledButton>
      </Table.Th>
    );
  };

  if (isLoading) return <Loader />;
  if (!data || data.content.length === 0) return <Text c="dimmed">{t('tests.empty')}</Text>;

  return (
    <>
      <Text size="sm" c="dimmed">
        {t('tests.total', { count: data.totalElements })}
      </Text>
      <Table striped highlightOnHover data-testid="test-list">
        <Table.Thead>
          <Table.Tr>
            {header('key', t('tests.columns.key'))}
            {header('title', t('tests.columns.title'))}
            {header('kind', t('tests.columns.kind'))}
            <Table.Th>{t('tests.columns.technique')}</Table.Th>
            {header('status', t('tests.columns.status'))}
            {header('priority', t('tests.columns.priority'))}
            <Table.Th>{t('tests.columns.version')}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {data.content.map((test) => (
            <TestRow key={test.key} test={test} onSelect={onSelect} />
          ))}
        </Table.Tbody>
      </Table>
      {data.totalElements > data.size && (
        <Pagination total={Math.ceil(data.totalElements / data.size)} value={page + 1} onChange={(value) => onPage(value - 1)} />
      )}
    </>
  );
}

function TestRow({ test, onSelect }: { test: TestCaseSummary; onSelect: (key: string) => void }) {
  const { t } = useTranslation();
  return (
    <Table.Tr style={{ cursor: 'pointer' }} onClick={() => onSelect(test.key)} data-testid={`test-row-${test.key}`}>
      <Table.Td ff="monospace" fw={600}>
        {test.key}
      </Table.Td>
      <Table.Td>
        <Group gap={6} wrap="nowrap">
          <Text size="sm">{test.title}</Text>
          {test.automationCandidate && (
            <Badge size="xs" color="violet">
              {t('tests.candidate')}
            </Badge>
          )}
          {test.missingInRepository && (
            <Badge size="xs" color="red">
              {t('tests.missing')}
            </Badge>
          )}
        </Group>
      </Table.Td>
      <Table.Td>
        <KindBadge kind={test.kind} />
      </Table.Td>
      <Table.Td>
        <TechniqueBadge technique={test.technique} />
      </Table.Td>
      <Table.Td>
        <TestStatusBadge status={test.status} />
      </Table.Td>
      <Table.Td>
        <PriorityBadge priority={test.priority} />
      </Table.Td>
      <Table.Td>v{test.currentVersion}</Table.Td>
    </Table.Tr>
  );
}
