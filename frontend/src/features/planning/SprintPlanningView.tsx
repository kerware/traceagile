import { DndContext, KeyboardSensor, PointerSensor, useDraggable, useDroppable, useSensor, useSensors, type DragEndEvent } from '@dnd-kit/core';
import { ActionIcon, Alert, Badge, Button, Card, Group, Loader, Paper, Progress, ScrollArea, Select, SimpleGrid, Stack, Text, TextInput, Title, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconArrowLeft, IconArrowRight, IconGripVertical, IconLock, IconPlayerPlay, IconSearch } from '@tabler/icons-react';
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { useReadyBacklog, useReplaceScope, useSprint, useSprints, useStartSprint, type SprintDetail } from '../../api/planning';
import { PriorityBadge, TypeBadge } from '../requirements/Badges';
import { VerificationBadge } from '../traceability/VerificationBadge';
import { loadColor, PLANNING_STATUS_COLORS, shortDate } from './model';
import { CloseSprintModal } from './PlanningModals';
import { useCanPlan } from './permissions';

const PLANNABLE = ['USER_STORY', 'TECHNICAL_ENABLER', 'BUSINESS_RULE', 'NON_FUNCTIONAL'];

interface PlanCard {
  key: string;
  title: string;
  type: string;
  priority: string;
  storyPoints?: number;
  status: string;
  verificationStatus?: string;
  outcome?: string;
}

/**
 * F-PLN-05 planification d'un sprint : backlog prêt à gauche, périmètre à droite, ajout par
 * glisser-déposer (ou boutons, accessibles au clavier) ; jauge charge / capacité. F-PLN-06 démarrer, clôturer.
 */
export function SprintPlanningView({ project, sprintKey, onSprint }: { project: string; sprintKey: string | null; onSprint: (key: string) => void }) {
  const { t } = useTranslation();
  const { data: sprints, isLoading } = useSprints(project);
  const { data: detail } = useSprint(project, sprintKey);

  if (isLoading) return <Loader />;
  if (!sprints || sprints.length === 0) return <Text c="dimmed">{t('planning.noSprintYet')}</Text>;

  return (
    <Stack>
      <Select
        label={t('planning.sprint')}
        data={sprints.map((s) => ({ value: s.key, label: `${s.key} — ${s.name} (${t(`planningStatus.${s.status}`)})` }))}
        value={sprintKey}
        onChange={(key) => key && onSprint(key)}
        allowDeselect={false}
        w={420}
        data-testid="planning-sprint-select"
      />
      {detail && <SprintBoard key={detail.sprint.key} project={project} detail={detail} openScopes={sprints.filter((s) => s.status !== 'CLOSED' && s.key !== detail.sprint.key).flatMap((s) => s.requirementKeys)} />}
    </Stack>
  );
}

function SprintBoard({ project, detail, openScopes }: { project: string; detail: SprintDetail; openScopes: string[] }) {
  const { t } = useTranslation();
  const sprint = detail.sprint;
  const planner = useCanPlan(project);
  const canPlan = planner && sprint.status !== 'CLOSED';
  const { data: backlog } = useReadyBacklog(project);
  const replace = useReplaceScope(project, sprint.key);
  const start = useStartSprint(project);
  const [closing, setClosing] = useState(false);
  const [search, setSearch] = useState('');
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 4 } }), useSensor(KeyboardSensor));

  const scopeKeys = (replace.isPending && replace.variables) || detail.scope.map((item) => item.key);
  const taken = new Set([...scopeKeys, ...openScopes]);
  const ready: PlanCard[] = (backlog?.content ?? [])
    .filter((r) => PLANNABLE.includes(r.type) && !taken.has(r.key))
    .filter((r) => !search || `${r.key} ${r.title}`.toLowerCase().includes(search.toLowerCase()));
  const byKey = new Map<string, PlanCard>([...(backlog?.content ?? []), ...detail.scope].map((r) => [r.key, r as PlanCard]));
  const scope = scopeKeys.map((key) => byKey.get(key)).filter((c): c is PlanCard => !!c);

  const save = (keys: string[]) =>
    replace.mutate(keys, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) });
  const add = (key: string) => save([...scopeKeys, key]);
  const remove = (key: string) => save(scopeKeys.filter((k) => k !== key));
  const onDragEnd = ({ active, over }: DragEndEvent) => {
    const key = String(active.id);
    const from = active.data.current?.from as string;
    if (!over || over.id === from) return;
    if (over.id === 'sprint') add(key);
    if (over.id === 'backlog') remove(key);
  };

  return (
    <Stack>
      <Card withBorder data-testid="sprint-header">
        <Group justify="space-between" align="flex-start">
          <Stack gap={2}>
            <Group gap="xs">
              <Badge variant="filled" ff="monospace">
                {sprint.key}
              </Badge>
              <Title order={4}>{sprint.name}</Title>
              <Badge color={PLANNING_STATUS_COLORS[sprint.status]} variant="light" data-testid="sprint-status">
                {t(`planningStatus.${sprint.status}`)}
              </Badge>
              {sprint.releaseKey && <Badge variant="default">{sprint.releaseKey}</Badge>}
            </Group>
            <Text size="sm" c="dimmed">
              {shortDate(sprint.startDate)} → {shortDate(sprint.endDate)}
              {sprint.goal ? ` · ${sprint.goal}` : ''}
            </Text>
          </Stack>
          {planner && (
            <Group>
              {sprint.status === 'PLANNED' && (
                <Button
                  leftSection={<IconPlayerPlay size={16} />}
                  loading={start.isPending}
                  onClick={() =>
                    start.mutate(sprint.key, {
                      onSuccess: () => notifications.show({ color: 'green', message: t('planning.started', { key: sprint.key }) }),
                      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
                    })
                  }
                  data-testid="sprint-start"
                >
                  {t('planning.startSprint')}
                </Button>
              )}
              {sprint.status === 'ACTIVE' && (
                <Button color="orange" leftSection={<IconLock size={16} />} onClick={() => setClosing(true)} data-testid="sprint-close">
                  {t('planning.closeSprint')}
                </Button>
              )}
            </Group>
          )}
        </Group>
        <Stack gap={4} mt="sm" data-testid="capacity-gauge">
          <Group justify="space-between">
            <Text size="sm" fw={600}>
              {t('planning.load')}
            </Text>
            <Text size="sm" data-testid="capacity-label">
              {sprint.capacityPoints != null
                ? t('planning.loadOf', { load: sprint.loadPoints, capacity: sprint.capacityPoints, percent: sprint.loadPercent ?? 0 })
                : t('planning.loadNoCapacity', { load: sprint.loadPoints })}
            </Text>
          </Group>
          <Progress value={Math.min(100, sprint.loadPercent ?? 0)} color={loadColor(sprint.loadPercent)} size="lg" />
          {sprint.overCapacity && (
            <Alert color="red" icon={<IconAlertTriangle size={16} />} py={6} data-testid="over-capacity">
              {t('planning.overCapacity', { over: sprint.loadPoints - (sprint.capacityPoints ?? 0) })}
            </Alert>
          )}
        </Stack>
      </Card>

      <DndContext sensors={sensors} onDragEnd={onDragEnd}>
        <SimpleGrid cols={2}>
          <Column id="backlog" title={t('planning.readyBacklog', { count: ready.length })} enabled={canPlan}
            header={<TextInput size="xs" leftSection={<IconSearch size={14} />} placeholder={t('planning.searchReady')} value={search} onChange={(e) => setSearch(e.currentTarget.value)} data-testid="ready-search" />}>
            {ready.length === 0 && (
              <Text size="sm" c="dimmed">
                {t('planning.noReady')}
              </Text>
            )}
            {ready.map((card) => (
              <ItemCard key={card.key} project={project} card={card} from="backlog" enabled={canPlan}
                action={canPlan && (
                  <Tooltip label={t('planning.addToSprint')}>
                    <ActionIcon variant="light" onClick={() => add(card.key)} aria-label={t('planning.addToSprint')} data-testid={`plan-add-${card.key}`}>
                      <IconArrowRight size={16} />
                    </ActionIcon>
                  </Tooltip>
                )} />
            ))}
          </Column>
          <Column id="sprint" title={t('planning.sprintScope', { count: scope.length })} enabled={canPlan}>
            {scope.length === 0 && (
              <Text size="sm" c="dimmed">
                {canPlan ? t('planning.dropHere') : t('planning.emptyScope')}
              </Text>
            )}
            {scope.map((card) => (
              <ItemCard key={card.key} project={project} card={card} from="sprint" enabled={canPlan}
                action={canPlan ? (
                  <Tooltip label={t('planning.removeFromSprint')}>
                    <ActionIcon variant="subtle" onClick={() => remove(card.key)} aria-label={t('planning.removeFromSprint')} data-testid={`plan-remove-${card.key}`}>
                      <IconArrowLeft size={16} />
                    </ActionIcon>
                  </Tooltip>
                ) : card.outcome && card.outcome !== 'PLANNED' ? (
                  <Badge size="sm" variant="light" data-testid={`outcome-${card.key}`}>
                    {t(`scopeOutcome.${card.outcome}`)}
                  </Badge>
                ) : null} />
            ))}
          </Column>
        </SimpleGrid>
      </DndContext>
      <CloseSprintModal project={project} detail={detail} opened={closing} onClose={() => setClosing(false)} />
    </Stack>
  );
}

function Column({ id, title, enabled, header, children }: { id: string; title: string; enabled: boolean; header?: ReactNode; children: ReactNode }) {
  const { setNodeRef, isOver } = useDroppable({ id, disabled: !enabled });
  return (
    <Paper withBorder p="sm" ref={setNodeRef} data-testid={`column-${id}`}
      style={{ background: isOver ? 'var(--mantine-color-teal-light)' : undefined, transition: 'background 120ms' }}>
      <Stack gap="xs">
        <Text fw={700}>{title}</Text>
        {header}
        <ScrollArea.Autosize mah={560}>
          <Stack gap={6}>{children}</Stack>
        </ScrollArea.Autosize>
      </Stack>
    </Paper>
  );
}

function ItemCard({ project, card, from, enabled, action }: { project: string; card: PlanCard; from: string; enabled: boolean; action: ReactNode }) {
  const { t } = useTranslation();
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({ id: card.key, data: { from }, disabled: !enabled });
  return (
    <Paper
      ref={setNodeRef}
      withBorder
      p={6}
      data-testid={`${from}-item-${card.key}`}
      style={{ transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined, opacity: isDragging ? 0.7 : 1, zIndex: isDragging ? 10 : undefined, position: 'relative' }}
    >
      <Group gap={6} wrap="nowrap">
        {enabled && (
          <ActionIcon variant="subtle" size="sm" color="gray" aria-label={t('planning.drag')} {...attributes} {...listeners} data-testid={`drag-${card.key}`} style={{ cursor: 'grab' }}>
            <IconGripVertical size={14} />
          </ActionIcon>
        )}
        <Text size="sm" ff="monospace" fw={600} component={Link} to={`/p/${project}/requirements/${card.key}`} c="inherit" td="none">
          {card.key}
        </Text>
        <TypeBadge type={card.type as never} />
        <Text size="sm" flex={1} truncate title={card.title}>
          {card.title}
        </Text>
        {card.verificationStatus && <VerificationBadge status={card.verificationStatus as never} compact />}
        <PriorityBadge priority={card.priority as never} />
        <Badge variant="default" size="sm">
          {card.storyPoints ?? '—'} pts
        </Badge>
        {action}
      </Group>
    </Paper>
  );
}
