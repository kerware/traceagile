import { ActionIcon, Badge, Box, Group, Loader, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconChevronDown, IconChevronRight, IconFolder, IconListCheck } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTestTree } from '../../api/testcases';
import { KindBadge, TechniqueBadge, TestStatusBadge } from './Badges';

/** §13.2 référentiel « par dossier » (chemins « a/b ») ou « par feature » (fonctionnalité Gherkin). */
export function TestTree({ project, groupBy, onSelect }: { project: string; groupBy: 'folder' | 'feature'; onSelect: (key: string) => void }) {
  const { t } = useTranslation();
  const { data, isLoading } = useTestTree(project, groupBy);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());

  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('tests.emptyRepository')}</Text>;

  const toggle = (name: string) =>
    setCollapsed((current) => {
      const next = new Set(current);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });

  return (
    <Stack gap="xs" data-testid="test-tree" role="tree">
      {data.map((group) => {
        const open = !collapsed.has(group.name);
        const depth = groupBy === 'folder' && group.name ? group.name.split('/').length - 1 : 0;
        const label = group.name ? (groupBy === 'folder' ? group.name.split('/').at(-1) : group.name) : t('tests.unclassified');
        return (
          <Box key={group.name} pl={depth * 24} data-testid={`test-group-${group.name}`} role="treeitem" aria-expanded={open}>
            <Group gap={6}>
              <ActionIcon variant="subtle" size="sm" onClick={() => toggle(group.name)} aria-label={label}>
                {open ? <IconChevronDown size={14} /> : <IconChevronRight size={14} />}
              </ActionIcon>
              {groupBy === 'folder' ? <IconFolder size={16} /> : <IconListCheck size={16} />}
              <Text fw={600} size="sm">
                {label}
              </Text>
              <Badge variant="default" size="sm">
                {group.tests.length}
              </Badge>
            </Group>
            {open && (
              <Stack gap={2} pl={48} mt={4}>
                {group.tests.map((test) => (
                  <UnstyledButton key={test.key} onClick={() => onSelect(test.key)} data-testid={`tree-test-${test.key}`}>
                    <Group gap={8} wrap="nowrap">
                      <Text ff="monospace" fw={600} size="sm">
                        {test.key}
                      </Text>
                      <KindBadge kind={test.kind} />
                      <TechniqueBadge technique={test.technique} />
                      <Text size="sm">{test.title}</Text>
                      <TestStatusBadge status={test.status} />
                    </Group>
                  </UnstyledButton>
                ))}
              </Stack>
            )}
          </Box>
        );
      })}
    </Stack>
  );
}
