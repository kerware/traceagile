import { ActionIcon, Button, Group, Loader, Paper, Select, SimpleGrid, Stack, Text, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconArrowDown, IconArrowUp, IconPlus, IconTrash } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useProjects } from '../../api/queries';
import { useProjectChecklists, useReplaceChecklist, type ChecklistRule } from '../../api/requirements';
import { AdminTabs } from './AdminTabs';

const RULES: ChecklistRule[] = ['HAS_ACCEPTANCE_CRITERION', 'ESTIMATED', 'HAS_LINKED_TEST', 'ALL_LINKED_TESTS_PASSED', 'NO_BLOCKING_DEFECT_OPEN'];

type Item = Schemas['ChecklistItemRequest'];

/** §13.2 /admin — F-REQ-19 Definition of Ready et Definition of Done de chaque projet. */
export function AdminChecklistsPage() {
  const { t } = useTranslation();
  const { data: projects } = useProjects();
  const [project, setProject] = useState<string | null>(null);
  const { data, isLoading } = useProjectChecklists(project);

  return (
    <Stack>
      <AdminTabs value="checklists" />
      <Select
        label={t('checklistAdmin.project')}
        data={(projects?.content ?? []).map((p) => ({ value: p.key, label: `${p.key} — ${p.name}` }))}
        value={project}
        onChange={setProject}
        w={320}
        data-testid="checklists-project"
      />
      {!project && <Text c="dimmed">{t('checklistAdmin.chooseProject')}</Text>}
      {project && isLoading && <Loader />}
      {project && data && (
        <SimpleGrid cols={{ base: 1, lg: 2 }}>
          <ChecklistEditor key={`${project}-dor`} project={project} kind="DOR" initial={data.dor} />
          <ChecklistEditor key={`${project}-dod`} project={project} kind="DOD" initial={data.dod} />
        </SimpleGrid>
      )}
    </Stack>
  );
}

function ChecklistEditor({ project, kind, initial }: { project: string; kind: 'DOR' | 'DOD'; initial: Schemas['ChecklistItemResponse'][] }) {
  const { t } = useTranslation();
  const replace = useReplaceChecklist(project);
  const [items, setItems] = useState<Item[]>([]);

  useEffect(() => {
    setItems(initial.map((i) => ({ id: i.id, label: i.label, rule: i.rule })));
  }, [initial]);

  const change = (index: number, patch: Partial<Item>) => setItems((list) => list.map((item, i) => (i === index ? { ...item, ...patch } : item)));
  const swap = (index: number, delta: number) =>
    setItems((list) => {
      const next = [...list];
      [next[index], next[index + delta]] = [next[index + delta]!, next[index]!];
      return next;
    });

  const save = () =>
    replace.mutate(
      { kind, items: items.filter((i) => i.label.trim()) },
      {
        onSuccess: () => notifications.show({ color: 'green', message: t('checklistAdmin.saved') }),
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );

  return (
    <Paper withBorder p="md" data-testid={`checklist-editor-${kind}`}>
      <Stack>
        <Title order={4}>{t(kind === 'DOR' ? 'requirement.dor' : 'requirement.dod')}</Title>
        {items.map((item, index) => (
          <Group key={item.id ?? `new-${index}`} wrap="nowrap" align="flex-end">
            <TextInput flex={1} label={index === 0 ? t('checklistAdmin.label') : undefined} value={item.label} maxLength={200} onChange={(e) => change(index, { label: e.currentTarget.value })} />
            <Select
              w={260}
              label={index === 0 ? t('checklistAdmin.rule') : undefined}
              data={[{ value: 'MANUAL', label: t('checklistRule.MANUAL') }, ...RULES.map((r) => ({ value: r, label: t(`checklistRule.${r}`) }))]}
              value={item.rule ?? 'MANUAL'}
              onChange={(value) => change(index, { rule: value === 'MANUAL' || !value ? undefined : (value as ChecklistRule) })}
              allowDeselect={false}
            />
            <ActionIcon variant="subtle" disabled={index === 0} onClick={() => swap(index, -1)} aria-label={t('criteria.up')}>
              <IconArrowUp size={16} />
            </ActionIcon>
            <ActionIcon variant="subtle" disabled={index === items.length - 1} onClick={() => swap(index, 1)} aria-label={t('criteria.down')}>
              <IconArrowDown size={16} />
            </ActionIcon>
            <ActionIcon variant="subtle" color="red" onClick={() => setItems((list) => list.filter((_, i) => i !== index))} aria-label={t('admin.remove')}>
              <IconTrash size={16} />
            </ActionIcon>
          </Group>
        ))}
        <Group>
          <Button variant="default" leftSection={<IconPlus size={16} />} onClick={() => setItems((list) => [...list, { label: '' }])}>
            {t('checklistAdmin.add')}
          </Button>
          <Button onClick={save} loading={replace.isPending} data-testid={`checklist-save-${kind}`}>
            {t('checklistAdmin.save')}
          </Button>
        </Group>
      </Stack>
    </Paper>
  );
}
