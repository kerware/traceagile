import { DndContext, KeyboardSensor, PointerSensor, useDraggable, useDroppable, useSensor, useSensors, type DragEndEvent } from '@dnd-kit/core';
import { ActionIcon, Badge, Group, Loader, Menu, Paper, ScrollArea, SimpleGrid, Stack, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconDots, IconGripVertical } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  BOARD_COLUMNS,
  BOARD_LIMIT,
  useRequirement,
  useRequirementBoard,
  type BoardColumn,
  type RequirementStatus,
  type RequirementSummary,
} from '../../api/requirements';
import { VerificationBadge } from '../traceability/VerificationBadge';
import { PriorityBadge, StatusBadge, TypeBadge } from './Badges';
import { StatusChangeModal } from './StatusMenu';

const COLUMNS: BoardColumn[] = ['todo', 'doing', 'done'];
/** Statut visé quand une carte arrive dans une colonne (la DoR / DoD s'affiche avant Prête et Terminée). */
const TARGET: Record<BoardColumn, RequirementStatus> = { todo: 'READY', doing: 'IN_SPRINT', done: 'DONE' };

/**
 * Vue tableau du backlog : user stories et exigences non fonctionnelles en trois colonnes (À faire,
 * En cours, Terminée). Glisser une carte, ou son menu « ⋯ », change le statut avec les mêmes contrôles
 * que la fiche (transitions autorisées, DoR, DoD).
 */
export function BacklogBoard({ project, canWrite, onSelect }: { project: string; canWrite: boolean; onSelect: (key: string) => void }) {
  const [move, setMove] = useState<{ key: string; column: BoardColumn } | null>(null);
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 4 } }), useSensor(KeyboardSensor));
  const onDragEnd = ({ active, over }: DragEndEvent) => {
    const from = active.data.current?.column as BoardColumn | undefined;
    const to = over?.id as BoardColumn | undefined;
    if (to && from && to !== from) setMove({ key: String(active.id), column: to });
  };

  return (
    <DndContext sensors={sensors} onDragEnd={onDragEnd}>
      <SimpleGrid cols={{ base: 1, md: 3 }} spacing="md" data-testid="backlog-board">
        {COLUMNS.map((column) => (
          <BoardColumnView key={column} project={project} column={column} canWrite={canWrite} onSelect={onSelect}
            onMove={(key, to) => setMove({ key, column: to })} />
        ))}
      </SimpleGrid>
      {move && <MoveDialog project={project} requirementKey={move.key} column={move.column} onClose={() => setMove(null)} />}
    </DndContext>
  );
}

function BoardColumnView({ project, column, canWrite, onSelect, onMove }: {
  project: string; column: BoardColumn; canWrite: boolean; onSelect: (key: string) => void; onMove: (key: string, to: BoardColumn) => void;
}) {
  const { t } = useTranslation();
  const { data, isLoading } = useRequirementBoard(project, column);
  const { setNodeRef, isOver } = useDroppable({ id: column, disabled: !canWrite });
  const cards = data?.content ?? [];
  const points = cards.reduce((sum, c) => sum + (c.storyPoints ?? 0), 0);
  return (
    <Paper withBorder p="sm" ref={setNodeRef} data-testid={`board-column-${column}`}
      style={{ background: isOver ? 'var(--mantine-color-teal-light)' : 'var(--mantine-color-default-hover)', transition: 'background 120ms' }}>
      <Stack gap="xs">
        <Group justify="space-between" wrap="nowrap">
          <Text fw={700}>{t(`backlog.board.${column}`)}</Text>
          <Group gap={4}>
            <Badge variant="light" data-testid={`board-count-${column}`}>
              {data?.totalElements ?? 0}
            </Badge>
            <Badge variant="default">{t('backlog.board.points', { count: points })}</Badge>
          </Group>
        </Group>
        <Text size="xs" c="dimmed">
          {BOARD_COLUMNS[column].map((s) => t(`requirementStatus.${s}`)).join(' · ')}
        </Text>
        {isLoading && <Loader size="sm" />}
        <ScrollArea.Autosize mah="calc(100vh - 280px)">
          <Stack gap={6}>
            {cards.map((card) => (
              <BoardCard key={card.key} project={project} card={card} column={column} canWrite={canWrite} onSelect={onSelect} onMove={onMove} />
            ))}
            {!isLoading && cards.length === 0 && (
              <Text size="sm" c="dimmed" ta="center" py="md">
                {t('backlog.board.empty')}
              </Text>
            )}
            {(data?.totalElements ?? 0) > BOARD_LIMIT && (
              <Text size="xs" c="dimmed">
                {t('backlog.board.truncated', { count: BOARD_LIMIT })}
              </Text>
            )}
          </Stack>
        </ScrollArea.Autosize>
      </Stack>
    </Paper>
  );
}

function BoardCard({ project, card, column, canWrite, onSelect, onMove }: {
  project: string; card: RequirementSummary; column: BoardColumn; canWrite: boolean; onSelect: (key: string) => void;
  onMove: (key: string, to: BoardColumn) => void;
}) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({ id: card.key, data: { column }, disabled: !canWrite });
  return (
    <Paper ref={setNodeRef} withBorder p={8} data-testid={`board-card-${card.key}`} data-project={project}
      style={{ transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined, opacity: isDragging ? 0.7 : 1,
        zIndex: isDragging ? 10 : undefined, position: 'relative', cursor: 'pointer' }}
      onClick={() => onSelect(card.key)}>
      <Stack gap={4}>
        <Group gap={6} wrap="nowrap" justify="space-between">
          <Group gap={6} wrap="nowrap">
            {canWrite && (
              <ActionIcon variant="subtle" size="sm" color="gray" aria-label={t('backlog.board.drag')} {...attributes} {...listeners}
                onClick={(e) => e.stopPropagation()} data-testid={`board-drag-${card.key}`} style={{ cursor: 'grab' }}>
                <IconGripVertical size={14} />
              </ActionIcon>
            )}
            <Text size="sm" ff="monospace" fw={600}>
              {card.key}
            </Text>
            <TypeBadge type={card.type} />
          </Group>
          {canWrite && (
            <Menu position="bottom-end" withinPortal>
              <Menu.Target>
                <ActionIcon variant="subtle" size="sm" color="gray" aria-label={t('backlog.board.moveTo')} onClick={(e) => e.stopPropagation()}
                  data-testid={`board-menu-${card.key}`}>
                  <IconDots size={14} />
                </ActionIcon>
              </Menu.Target>
              <Menu.Dropdown onClick={(e) => e.stopPropagation()}>
                <Menu.Label>{t('backlog.board.moveTo')}</Menu.Label>
                {COLUMNS.filter((c) => c !== column).map((c) => (
                  <Menu.Item key={c} onClick={() => onMove(card.key, c)} data-testid={`board-move-${card.key}-${c}`}>
                    {t(`backlog.board.${c}`)}
                  </Menu.Item>
                ))}
              </Menu.Dropdown>
            </Menu>
          )}
        </Group>
        <Text size="sm" lineClamp={2} title={card.title}>
          {card.title}
        </Text>
        <Group gap={4}>
          <StatusBadge status={card.status} />
          <PriorityBadge priority={card.priority} />
          {card.verificationStatus && <VerificationBadge status={card.verificationStatus} compact />}
          {card.storyPoints !== undefined && card.storyPoints !== null && (
            <Badge variant="default" size="sm">
              {card.storyPoints} pts
            </Badge>
          )}
        </Group>
      </Stack>
    </Paper>
  );
}

/** Statut visé par la colonne, avec les contrôles de la fiche ; une transition impossible est expliquée. */
function MoveDialog({ project, requirementKey, column, onClose }: { project: string; requirementKey: string; column: BoardColumn; onClose: () => void }) {
  const { t } = useTranslation();
  const { data: requirement } = useRequirement(project, requirementKey);
  const target = TARGET[column];
  const allowed = requirement?.allowedTransitions.includes(target) ?? false;
  useEffect(() => {
    if (requirement && !allowed) {
      notifications.show({
        color: 'orange',
        message: t('backlog.board.impossible', {
          key: requirementKey,
          from: t(`requirementStatus.${requirement.status}`),
          to: t(`requirementStatus.${target}`),
          allowed: requirement.allowedTransitions.map((s) => t(`requirementStatus.${s}`)).join(', ') || '—',
        }),
      });
      onClose();
    }
  }, [requirement, allowed, requirementKey, target, onClose, t]);
  if (!requirement || !allowed) return null;
  return <StatusChangeModal project={project} requirement={requirement} target={target} onClose={onClose} />;
}
