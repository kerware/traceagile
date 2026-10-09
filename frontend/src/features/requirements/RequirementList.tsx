import { closestCenter, DndContext, KeyboardSensor, PointerSensor, useSensor, useSensors, type DragEndEvent } from '@dnd-kit/core';
import { SortableContext, sortableKeyboardCoordinates, useSortable, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { ActionIcon, Badge, Group, Loader, Pagination, Table, Text, Tooltip, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconArrowsSort, IconGripVertical, IconSortAscending, IconSortDescending } from '@tabler/icons-react';
import { useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import {
  requirementKeys,
  useMoveRequirement,
  useRequirementList,
  type RequirementFilters,
  type RequirementSummary,
} from '../../api/requirements';
import { hasFilters } from './filters';
import { PriorityBadge, RiskBadge, StatusBadge, TypeBadge } from './Badges';
import { VerificationBadge } from '../traceability/VerificationBadge';
import { reorder } from './reorder';

type Page = Schemas['PageResponseRequirementSummary'];
type SortableColumn = 'key' | 'title' | 'type' | 'status' | 'priority' | 'storyPoints' | 'riskLevel';

/** F-REQ-01 vue liste paginée côté serveur, triable ; F-REQ-03 glisser-déposer quand elle est triée par rang. */
export function RequirementList({
  project,
  filters,
  page,
  sort,
  onSort,
  onPage,
  onSelect,
  canWrite,
}: {
  project: string;
  filters: RequirementFilters;
  page: number;
  sort: string;
  onSort: (sort: string) => void;
  onPage: (page: number) => void;
  onSelect: (key: string) => void;
  canWrite: boolean;
}) {
  const { t } = useTranslation();
  const client = useQueryClient();
  const { data, isLoading } = useRequirementList(project, filters, page, sort);
  const move = useMoveRequirement(project);
  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }));
  const draggable = canWrite && sort === 'rank,asc' && !hasFilters(filters);
  const queryKey = requirementKeys.list(project, filters, page, sort);

  const onDragEnd = ({ active, over }: DragEndEvent) => {
    if (!data || !over) return;
    const result = reorder(data.content.map((r) => r.key), String(active.id), String(over.id));
    if (!result) return;
    const moved = data.content.find((r) => r.key === active.id)!;
    // §11.4 mise à jour optimiste, annulée en cas d'erreur.
    const previous = client.getQueryData<Page>(queryKey);
    client.setQueryData<Page>(queryKey, {
      ...data,
      content: result.ordered.map((key) => data.content.find((r) => r.key === key)!),
    });
    move.mutate(
      { key: moved.key, parentKey: moved.parentKey ?? null, afterKey: result.afterKey, beforeKey: result.beforeKey },
      {
        onSuccess: () => notifications.show({ message: t('backlog.moved', { key: moved.key }) }),
        onError: (error) => {
          client.setQueryData(queryKey, previous);
          notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) });
        },
      },
    );
  };

  const header = (column: SortableColumn, label: string) => {
    const [property, direction] = sort.split(',');
    const active = property === column;
    const Icon = !active ? IconArrowsSort : direction === 'desc' ? IconSortDescending : IconSortAscending;
    return (
      <Table.Th>
        <UnstyledButton
          onClick={() => onSort(`${column},${active && direction === 'asc' ? 'desc' : 'asc'}`)}
          data-testid={`sort-${column}`}
        >
          <Group gap={4} wrap="nowrap">
            {label}
            <Icon size={14} />
          </Group>
        </UnstyledButton>
      </Table.Th>
    );
  };

  if (isLoading) return <Loader />;
  if (!data || data.content.length === 0) return <Text c="dimmed">{t('backlog.empty')}</Text>;

  return (
    <>
      <Group justify="space-between">
        <Text size="sm" c="dimmed">
          {t('backlog.total', { count: data.totalElements })}
        </Text>
        {canWrite && !draggable && (
          <Text size="xs" c="dimmed">
            {t('backlog.dragDisabled')}
          </Text>
        )}
      </Group>
      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={onDragEnd}>
        <Table striped highlightOnHover data-testid="requirement-list">
          <Table.Thead>
            <Table.Tr>
              {draggable && <Table.Th w={32} />}
              {header('key', t('backlog.columns.key'))}
              {header('title', t('backlog.columns.title'))}
              {header('type', t('backlog.columns.type'))}
              {header('status', t('backlog.columns.status'))}
              {header('priority', t('backlog.columns.priority'))}
              {header('storyPoints', t('backlog.columns.points'))}
              {header('riskLevel', t('backlog.columns.risk'))}
              <Table.Th>{t('backlog.columns.criteria')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            <SortableContext items={data.content.map((r) => r.key)} strategy={verticalListSortingStrategy}>
              {data.content.map((requirement) => (
                <Row key={requirement.key} requirement={requirement} draggable={draggable} onSelect={onSelect} />
              ))}
            </SortableContext>
          </Table.Tbody>
        </Table>
      </DndContext>
      {data.totalElements > data.size && (
        <Pagination
          total={Math.ceil(data.totalElements / data.size)}
          value={page + 1}
          onChange={(value) => onPage(value - 1)}
          data-testid="backlog-pagination"
        />
      )}
    </>
  );
}

function Row({
  requirement,
  draggable,
  onSelect,
}: {
  requirement: RequirementSummary;
  draggable: boolean;
  onSelect: (key: string) => void;
}) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: requirement.key,
    disabled: !draggable,
  });
  return (
    <Table.Tr
      ref={setNodeRef}
      style={{ transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.6 : 1, cursor: 'pointer' }}
      onClick={() => onSelect(requirement.key)}
      data-testid={`requirement-row-${requirement.key}`}
    >
      {draggable && (
        <Table.Td onClick={(e) => e.stopPropagation()}>
          <ActionIcon variant="subtle" aria-label={t('backlog.dragHandle')} {...attributes} {...listeners} data-testid={`drag-${requirement.key}`}>
            <IconGripVertical size={16} />
          </ActionIcon>
        </Table.Td>
      )}
      <Table.Td ff="monospace" fw={600}>
        {requirement.key}
      </Table.Td>
      <Table.Td>
        <Group gap={6} wrap="nowrap">
          <Text size="sm">{requirement.title}</Text>
          {requirement.needsSplitting && (
            <Tooltip label={t('requirement.splitHint')}>
              <Badge color="orange" size="xs" leftSection={<IconAlertTriangle size={10} />} data-testid="split-alert">
                {t('requirement.split')}
              </Badge>
            </Tooltip>
          )}
        </Group>
      </Table.Td>
      <Table.Td>
        <TypeBadge type={requirement.type} />
      </Table.Td>
      <Table.Td>
        <Group gap={6} wrap="nowrap">
          <StatusBadge status={requirement.status} />
          <VerificationBadge status={requirement.verificationStatus} compact testId={`verification-${requirement.key}`} />
        </Group>
      </Table.Td>
      <Table.Td>
        <PriorityBadge priority={requirement.priority} />
      </Table.Td>
      <Table.Td>{requirement.storyPoints ?? '—'}</Table.Td>
      <Table.Td>
        <RiskBadge risk={requirement.riskLevel} />
      </Table.Td>
      <Table.Td>{requirement.criteriaCount}</Table.Td>
    </Table.Tr>
  );
}
