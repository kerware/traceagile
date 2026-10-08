import { closestCenter, DndContext, KeyboardSensor, PointerSensor, useSensor, useSensors, type DragEndEvent } from '@dnd-kit/core';
import { SortableContext, sortableKeyboardCoordinates, useSortable, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { ActionIcon, Badge, Box, Group, Loader, Stack, Text, Tooltip, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconChevronDown, IconChevronRight, IconGripVertical } from '@tabler/icons-react';
import { useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { requirementKeys, useMoveRequirement, useRequirementTree, type RequirementTreeNode } from '../../api/requirements';
import { PriorityBadge, StatusBadge, TypeBadge } from './Badges';
import { reorder } from './reorder';

/**
 * F-REQ-01 vue arbre repliable (épic > feature > story) ; F-REQ-02 / F-REQ-03 glisser-déposer
 * entre frères. Le changement de parent passe par l'action « Déplacer… » de la fiche.
 */
export function RequirementTree({
  project,
  onSelect,
  canWrite,
}: {
  project: string;
  onSelect: (key: string) => void;
  canWrite: boolean;
}) {
  const { t } = useTranslation();
  const client = useQueryClient();
  const { data, isLoading } = useRequirementTree(project);
  const move = useMoveRequirement(project);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }));

  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('backlog.emptyBacklog')}</Text>;

  const toggle = (key: string) =>
    setCollapsed((current) => {
      const next = new Set(current);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });

  const onDragEnd = ({ active, over }: DragEndEvent) => {
    if (!over) return;
    const parentKey = (active.data.current?.parentKey as string | null) ?? null;
    if (parentKey !== ((over.data.current?.parentKey as string | null) ?? null)) return;
    const siblings = parentKey === null ? data : findNode(data, parentKey)?.children ?? [];
    const result = reorder(siblings.map((n) => n.key), String(active.id), String(over.id));
    if (!result) return;
    // §11.4 mise à jour optimiste, annulée en cas d'erreur.
    const previous = data;
    client.setQueryData(requirementKeys.tree(project), reorderSiblings(data, parentKey, result.ordered));
    move.mutate(
      { key: String(active.id), parentKey, afterKey: result.afterKey, beforeKey: result.beforeKey },
      {
        onSuccess: () => notifications.show({ message: t('backlog.moved', { key: String(active.id) }) }),
        onError: (error) => {
          client.setQueryData(requirementKeys.tree(project), previous);
          notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) });
        },
      },
    );
  };

  return (
    <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={onDragEnd}>
      <Box data-testid="requirement-tree" role="tree" aria-label={t('backlog.tree')}>
        <Siblings nodes={data} parentKey={null} depth={0} {...{ collapsed, toggle, onSelect, canWrite }} />
      </Box>
    </DndContext>
  );
}

interface NodeProps {
  collapsed: Set<string>;
  toggle: (key: string) => void;
  onSelect: (key: string) => void;
  canWrite: boolean;
}

function Siblings({ nodes, parentKey, depth, ...props }: NodeProps & { nodes: RequirementTreeNode[]; parentKey: string | null; depth: number }) {
  return (
    <SortableContext items={nodes.map((n) => n.key)} strategy={verticalListSortingStrategy}>
      <Stack gap={2}>
        {nodes.map((node) => (
          <TreeNode key={node.key} node={node} parentKey={parentKey} depth={depth} {...props} />
        ))}
      </Stack>
    </SortableContext>
  );
}

function TreeNode({ node, parentKey, depth, collapsed, toggle, onSelect, canWrite }: NodeProps & { node: RequirementTreeNode; parentKey: string | null; depth: number }) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: node.key,
    data: { parentKey },
    disabled: !canWrite,
  });
  const open = !collapsed.has(node.key);
  const hasChildren = node.children.length > 0;

  return (
    <Box ref={setNodeRef} style={{ transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.6 : 1 }}>
      <Group gap={6} wrap="nowrap" pl={depth * 24} py={4} role="treeitem" aria-expanded={hasChildren ? open : undefined} data-testid={`tree-node-${node.key}`}>
        {canWrite && (
          <ActionIcon variant="subtle" size="sm" aria-label={t('backlog.dragHandle')} {...attributes} {...listeners}>
            <IconGripVertical size={14} />
          </ActionIcon>
        )}
        <ActionIcon
          variant="subtle"
          size="sm"
          onClick={() => toggle(node.key)}
          disabled={!hasChildren}
          aria-label={open ? t('backlog.collapse') : t('backlog.expand')}
          data-testid={`tree-toggle-${node.key}`}
        >
          {hasChildren && (open ? <IconChevronDown size={14} /> : <IconChevronRight size={14} />)}
        </ActionIcon>
        <UnstyledButton onClick={() => onSelect(node.key)} data-testid={`tree-open-${node.key}`}>
          <Group gap={8} wrap="nowrap">
            <Text ff="monospace" fw={600} size="sm">
              {node.key}
            </Text>
            <TypeBadge type={node.type} />
            <Text size="sm">{node.title}</Text>
          </Group>
        </UnstyledButton>
        <StatusBadge status={node.status} />
        <PriorityBadge priority={node.priority} />
        {node.storyPoints != null && (
          <Badge variant="default" size="sm">
            {node.storyPoints} pts
          </Badge>
        )}
        {node.needsSplitting && (
          <Tooltip label={t('requirement.splitHint')}>
            <IconAlertTriangle size={16} color="var(--mantine-color-orange-6)" aria-label={t('requirement.split')} />
          </Tooltip>
        )}
      </Group>
      {hasChildren && open && (
        <Siblings nodes={node.children} parentKey={node.key} depth={depth + 1} {...{ collapsed, toggle, onSelect, canWrite }} />
      )}
    </Box>
  );
}

function findNode(nodes: RequirementTreeNode[], key: string): RequirementTreeNode | undefined {
  for (const node of nodes) {
    if (node.key === key) return node;
    const found = findNode(node.children, key);
    if (found) return found;
  }
  return undefined;
}

function reorderSiblings(nodes: RequirementTreeNode[], parentKey: string | null, ordered: string[]): RequirementTreeNode[] {
  const sort = (list: RequirementTreeNode[]) => ordered.map((key) => list.find((n) => n.key === key)!);
  if (parentKey === null) return sort(nodes);
  return nodes.map((node) =>
    node.key === parentKey
      ? { ...node, children: sort(node.children) }
      : { ...node, children: reorderSiblings(node.children, parentKey, ordered) },
  );
}
