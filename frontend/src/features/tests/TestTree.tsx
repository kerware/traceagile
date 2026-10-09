import { ActionIcon, Badge, Box, Group, Loader, Stack, Text, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import {
  IconChevronDown,
  IconChevronRight,
  IconExternalLink,
  IconEye,
  IconFolder,
  IconFolderPlus,
  IconFolderShare,
  IconForms,
  IconListCheck,
  IconPlus,
  IconStack2,
  IconTrash,
} from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useCreateFolder, useDeleteFolder, useDeleteTest, useMoveFolder, useMoveTest, useTestFolders, useTestTree, type TestCaseSummary, type TestKind } from '../../api/testcases';
import { ConfirmModal, PromptModal } from '../../components/Dialogs';
import { DIVIDER, type NodeMenuItem } from '../../components/tree/menuItems';
import { NodeMenuRow } from '../../components/tree/NodeMenu';
import { KindBadge, TechniqueBadge, TestStatusBadge } from './Badges';
import { buildFolderTree, type FolderNode } from './model';

type Dialog =
  | { type: 'newFolder'; parent: string | null }
  | { type: 'renameFolder'; path: string }
  | { type: 'deleteFolder'; path: string }
  | { type: 'moveTest'; test: TestCaseSummary }
  | { type: 'deleteTest'; test: TestCaseSummary };

/**
 * §13.2 référentiel « par dossier » (dossiers imbriqués « a/b », vides compris — ADR-0013) ou « par
 * feature » ; menu contextuel (clic droit ou « ⋯ ») pour créer un test ou un dossier sur un nœud.
 */
export function TestTree({
  project,
  groupBy,
  writableKinds,
  onSelect,
  onCreateTest,
}: {
  project: string;
  groupBy: 'folder' | 'feature';
  writableKinds: TestKind[];
  onSelect: (key: string) => void;
  onCreateTest: (folder: string | null) => void;
}) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data, isLoading } = useTestTree(project, groupBy);
  const { data: folders } = useTestFolders(project);
  const createFolder = useCreateFolder(project);
  const moveFolder = useMoveFolder(project);
  const deleteFolder = useDeleteFolder(project);
  const moveTest = useMoveTest(project);
  const deleteTest = useDeleteTest(project);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const [dialog, setDialog] = useState<Dialog | null>(null);
  const canWrite = writableKinds.length > 0;
  const byFolder = groupBy === 'folder';

  if (isLoading) return <Loader />;

  const toggle = (name: string) =>
    setCollapsed((current) => {
      const next = new Set(current);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });
  const done = (message: string) => notifications.show({ color: 'green', message });

  const folderItems = (path: string | null, total: number): NodeMenuItem[] =>
    canWrite
      ? [
          { key: 'new-test', label: t('tree.newTest'), icon: <IconPlus size={14} />, onClick: () => onCreateTest(path) },
          { key: 'new-folder', label: path ? t('tree.newSubfolder') : t('tree.newFolder'), icon: <IconFolderPlus size={14} />, onClick: () => setDialog({ type: 'newFolder', parent: path }) },
          ...(path
            ? [
                DIVIDER('d1'),
                { key: 'rename-folder', label: t('tree.renameFolder'), icon: <IconForms size={14} />, onClick: () => setDialog({ type: 'renameFolder', path }) },
                {
                  key: 'delete-folder',
                  label: total > 0 ? t('tree.deleteFolderNotEmpty') : t('tree.deleteFolder'),
                  icon: <IconTrash size={14} />,
                  color: 'red',
                  disabled: total > 0,
                  onClick: () => setDialog({ type: 'deleteFolder', path }),
                },
              ]
            : []),
        ]
      : [];

  const testItems = (test: TestCaseSummary): NodeMenuItem[] => {
    const writable = writableKinds.includes(test.kind);
    return [
      { key: 'open-test', label: t('tree.open'), icon: <IconEye size={14} />, onClick: () => onSelect(test.key) },
      { key: 'open-test-full', label: t('tests.openFull'), icon: <IconExternalLink size={14} />, onClick: () => navigate(`/p/${project}/tests/${test.key}`) },
      ...(writable
        ? [
            DIVIDER('d1'),
            { key: 'move-test', label: t('tree.moveTest'), icon: <IconFolderShare size={14} />, onClick: () => setDialog({ type: 'moveTest', test }) },
            { key: 'delete-test', label: t('tree.deleteTest'), icon: <IconTrash size={14} />, color: 'red', onClick: () => setDialog({ type: 'deleteTest', test }) },
          ]
        : []),
    ];
  };

  const testRow = (test: TestCaseSummary) => (
    <NodeMenuRow key={test.key} testId={`tree-test-row-${test.key}`} label={t('tree.actions', { name: test.key })} items={testItems(test)}>
      <UnstyledButton onClick={() => onSelect(test.key)} data-testid={`tree-test-${test.key}`}>
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
    </NodeMenuRow>
  );

  const group = (id: string, label: string, icon: React.ReactNode, count: number, items: NodeMenuItem[], depth: number, content: React.ReactNode) => {
    const open = !collapsed.has(id);
    return (
      <Box key={id} pl={depth * 24} data-testid={`test-group-${id}`} role="treeitem" aria-expanded={open}>
        <NodeMenuRow testId={`tree-folder-${id}`} label={t('tree.actions', { name: label })} items={items}>
          <ActionIcon variant="subtle" size="sm" onClick={() => toggle(id)} aria-label={label}>
            {open ? <IconChevronDown size={14} /> : <IconChevronRight size={14} />}
          </ActionIcon>
          {icon}
          <Text fw={600} size="sm">
            {label}
          </Text>
          <Badge variant="default" size="sm">
            {count}
          </Badge>
        </NodeMenuRow>
        {open && (
          <Stack gap={2} mt={4}>
            {content}
          </Stack>
        )}
      </Box>
    );
  };

  const folderNode = (node: FolderNode<TestCaseSummary>, depth: number): React.ReactNode =>
    group(
      node.path,
      node.name,
      <IconFolder size={16} />,
      node.total,
      folderItems(node.path, node.total),
      depth,
      <>
        {node.children.map((child) => folderNode(child, 1))}
        {node.tests.length > 0 && (
          <Stack gap={2} pl={48}>
            {node.tests.map(testRow)}
          </Stack>
        )}
        {node.total === 0 && (
          <Text size="xs" c="dimmed" pl={48}>
            {t('tree.emptyFolder')}
          </Text>
        )}
      </>,
    );

  const groups = data ?? [];
  const { roots, unclassified } = buildFolderTree(byFolder ? groups : []);
  const empty = groups.length === 0;

  return (
    <Stack gap="xs" data-testid="test-tree" role="tree">
      {byFolder && (
        <NodeMenuRow testId="tree-root" label={t('tree.actions', { name: t('tree.root') })} items={folderItems(null, 0)}>
          <IconStack2 size={16} />
          <Text fw={700} size="sm">
            {t('tree.root')}
          </Text>
        </NodeMenuRow>
      )}
      {empty && <Text c="dimmed">{t('tests.emptyRepository')}</Text>}
      {byFolder ? (
        <>
          {roots.map((node) => folderNode(node, 0))}
          {unclassified.length > 0 &&
            group('', t('tests.unclassified'), <IconFolder size={16} />, unclassified.length, folderItems(null, 0), 0, <Stack gap={2} pl={48}>{unclassified.map(testRow)}</Stack>)}
        </>
      ) : (
        groups.map((g) =>
          group(g.name, g.name || t('tests.unclassified'), <IconListCheck size={16} />, g.tests.length, [], 0, <Stack gap={2} pl={48}>{g.tests.map(testRow)}</Stack>),
        )
      )}

      <PromptModal
        opened={dialog?.type === 'newFolder'}
        title={dialog?.type === 'newFolder' && dialog.parent ? t('tree.newSubfolderIn', { path: dialog.parent }) : t('tree.newFolder')}
        label={t('tree.folderName')}
        description={t('tree.folderNameHint')}
        submitLabel={t('tree.create')}
        onClose={() => setDialog(null)}
        onSubmit={async (name) => {
          const parent = dialog?.type === 'newFolder' ? dialog.parent : null;
          const created = await createFolder.mutateAsync(parent ? `${parent}/${name}` : name);
          done(t('tree.folderCreated', { path: created.path }));
        }}
      />
      <PromptModal
        opened={dialog?.type === 'renameFolder'}
        title={t('tree.renameFolder')}
        label={t('tree.folderPath')}
        description={t('tree.folderPathHint')}
        initialValue={dialog?.type === 'renameFolder' ? dialog.path : ''}
        submitLabel={t('tree.apply')}
        onClose={() => setDialog(null)}
        onSubmit={async (to) => {
          if (dialog?.type !== 'renameFolder') return;
          const moved = await moveFolder.mutateAsync({ from: dialog.path, to });
          done(t('tree.folderMoved', { path: moved.path, count: moved.movedTests }));
        }}
      />
      <ConfirmModal
        opened={dialog?.type === 'deleteFolder'}
        title={t('tree.deleteFolder')}
        message={dialog?.type === 'deleteFolder' ? t('tree.deleteFolderConfirm', { path: dialog.path }) : ''}
        confirmLabel={t('tree.delete')}
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          if (dialog?.type === 'deleteFolder') await deleteFolder.mutateAsync(dialog.path);
        }}
      />
      <PromptModal
        opened={dialog?.type === 'moveTest'}
        title={dialog?.type === 'moveTest' ? t('tree.moveTestTitle', { key: dialog.test.key }) : ''}
        label={t('tree.folderPath')}
        description={t('tree.moveTestHint')}
        initialValue={dialog?.type === 'moveTest' ? (groups.find((g) => g.tests.some((x) => x.key === dialog.test.key))?.name ?? '') : ''}
        suggestions={folders ?? []}
        submitLabel={t('tree.apply')}
        onClose={() => setDialog(null)}
        onSubmit={async (folder) => {
          if (dialog?.type !== 'moveTest') return;
          await moveTest.mutateAsync({ key: dialog.test.key, folder: folder || null });
          done(t('tree.testMoved', { key: dialog.test.key }));
        }}
      />
      <ConfirmModal
        opened={dialog?.type === 'deleteTest'}
        title={t('tree.deleteTest')}
        message={dialog?.type === 'deleteTest' ? t('tree.deleteTestConfirm', { key: dialog.test.key, title: dialog.test.title }) : ''}
        confirmLabel={t('tree.delete')}
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          if (dialog?.type === 'deleteTest') await deleteTest.mutateAsync(dialog.test.key);
        }}
      />
    </Stack>
  );
}
