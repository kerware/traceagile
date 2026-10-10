import { ActionIcon, Badge, Box, Group, Stack, Text, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconChevronDown, IconChevronRight, IconFolder, IconFolderOpen, IconFolderPlus, IconForms, IconPlus, IconStack2, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useCampaignFolders,
  useCreateCampaignFolder,
  useDeleteCampaignFolder,
  useMoveCampaign,
  useMoveCampaignFolder,
  type CampaignSummary,
} from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { ConfirmModal, PromptModal } from '../../components/Dialogs';
import { DIVIDER, type NodeMenuItem } from '../../components/tree/menuItems';
import { NodeMenuRow } from '../../components/tree/NodeMenu';
import { buildFolderTree, type FolderNode } from '../tests/model';

/** Type MIME du glisser-déposer d'une campagne vers un dossier. */
export const CAMPAIGN_DRAG_TYPE = 'application/x-traceagile-campaign';

type Dialog = { type: 'newFolder'; parent: string | null } | { type: 'renameFolder'; path: string } | { type: 'deleteFolder'; path: string };

/**
 * ADR-0018 arbre des dossiers de campagnes : sélection d'un dossier (filtre de la liste, sous-dossiers
 * compris), menu contextuel (créer, renommer, supprimer) et dépôt d'une campagne glissée depuis la liste.
 */
export function CampaignFolderTree({ project, campaigns, selected, onSelect, canManage, onCreateCampaign }: {
  project: string;
  campaigns: CampaignSummary[];
  selected: string | null;
  onSelect: (folder: string | null) => void;
  canManage: boolean;
  onCreateCampaign: (folder: string | null) => void;
}) {
  const { t } = useTranslation();
  const { data: folders } = useCampaignFolders(project);
  const create = useCreateCampaignFolder(project);
  const move = useMoveCampaignFolder(project);
  const remove = useDeleteCampaignFolder(project);
  const moveCampaign = useMoveCampaign(project);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const [dialog, setDialog] = useState<Dialog | null>(null);
  const [over, setOver] = useState<string | null>(null);

  const groups = [
    ...(folders ?? []).map((path) => ({ name: path, tests: [] as CampaignSummary[] })),
    ...Object.entries(
      campaigns.reduce<Record<string, CampaignSummary[]>>((acc, c) => {
        (acc[c.folder ?? ''] ??= []).push(c);
        return acc;
      }, {}),
    ).map(([name, list]) => ({ name, tests: list })),
  ];
  const { roots, unclassified } = buildFolderTree(groups);
  const done = (message: string) => notifications.show({ color: 'green', message });
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const toggle = (path: string) =>
    setCollapsed((current) => {
      const next = new Set(current);
      if (next.has(path)) next.delete(path);
      else next.add(path);
      return next;
    });

  const drop = (folder: string | null) => (e: React.DragEvent) => {
    e.preventDefault();
    setOver(null);
    const key = e.dataTransfer.getData(CAMPAIGN_DRAG_TYPE);
    if (!key) return;
    moveCampaign.mutate({ key, folder }, { onSuccess: () => done(t('campaignFolders.campaignMoved', { key, folder: folder ?? t('campaignFolders.root') })), onError: fail });
  };
  const dropTarget = (id: string, folder: string | null) =>
    canManage
      ? {
          onDragOver: (e: React.DragEvent) => {
            if (e.dataTransfer.types.includes(CAMPAIGN_DRAG_TYPE)) {
              e.preventDefault();
              setOver(id);
            }
          },
          onDragLeave: () => setOver((current) => (current === id ? null : current)),
          onDrop: drop(folder),
        }
      : {};

  const items = (path: string | null, total: number): NodeMenuItem[] =>
    canManage
      ? [
          { key: 'new-campaign', label: t('campaignFolders.newCampaign'), icon: <IconPlus size={14} />, onClick: () => onCreateCampaign(path) },
          { key: 'new-folder', label: path ? t('tree.newSubfolder') : t('tree.newFolder'), icon: <IconFolderPlus size={14} />, onClick: () => setDialog({ type: 'newFolder', parent: path }) },
          ...(path
            ? [
                DIVIDER('d1'),
                { key: 'rename-folder', label: t('tree.renameFolder'), icon: <IconForms size={14} />, onClick: () => setDialog({ type: 'renameFolder', path }) },
                {
                  key: 'delete-folder',
                  label: total > 0 ? t('campaignFolders.deleteNotEmpty') : t('tree.deleteFolder'),
                  icon: <IconTrash size={14} />,
                  color: 'red',
                  disabled: total > 0,
                  onClick: () => setDialog({ type: 'deleteFolder', path }),
                },
              ]
            : []),
        ]
      : [];

  const row = (id: string, folder: string | null, label: string, icon: React.ReactNode, count: number, menu: NodeMenuItem[], toggleable: boolean, open: boolean) => (
    <Box
      {...dropTarget(id, folder)}
      style={{
        borderRadius: 4,
        background: over === id ? 'var(--mantine-color-blue-light)' : selected === folder && folder !== null ? 'var(--mantine-color-gray-light)' : undefined,
        outline: over === id ? '1px dashed var(--mantine-color-blue-5)' : undefined,
      }}
    >
      <NodeMenuRow testId={`campaign-folder-${id}`} label={t('tree.actions', { name: label })} items={menu}>
        {toggleable ? (
          <ActionIcon variant="subtle" size="sm" onClick={() => toggle(id)} aria-label={label}>
            {open ? <IconChevronDown size={14} /> : <IconChevronRight size={14} />}
          </ActionIcon>
        ) : (
          <Box w={22} />
        )}
        <UnstyledButton onClick={() => onSelect(folder)} data-testid={`campaign-folder-select-${id}`} style={{ flex: 1, minWidth: 0 }} title={label}>
          <Group gap={6} wrap="nowrap">
            {icon}
            <Text size="sm" fw={selected === folder ? 700 : 500} truncate>
              {label}
            </Text>
          </Group>
        </UnstyledButton>
        <Badge variant="default" size="sm">
          {count}
        </Badge>
      </NodeMenuRow>
    </Box>
  );

  const node = (n: FolderNode<CampaignSummary>, depth: number): React.ReactNode => {
    const open = !collapsed.has(n.path);
    return (
      <Box key={n.path} pl={depth ? 18 : 0} role="treeitem" aria-expanded={open}>
        {row(n.path, n.path, n.name, selected === n.path ? <IconFolderOpen size={16} /> : <IconFolder size={16} />, n.total, items(n.path, n.total), n.children.length > 0, open)}
        {open && n.children.length > 0 && <Stack gap={2} role="group">{n.children.map((c) => node(c, depth + 1))}</Stack>}
      </Box>
    );
  };

  return (
    <Stack gap={2} data-testid="campaign-folder-tree">
      {row('root', null, t('campaignFolders.all'), <IconStack2 size={16} />, campaigns.length, items(null, 0), false, true)}
      {/* NF-10 le rôle « tree » ne contient que des nœuds (treeitem) */}
      <Stack gap={2} role="tree" aria-label={t('campaignFolders.tree')}>
        {roots.map((n) => node(n, 0))}
      </Stack>
      {unclassified.length > 0 && roots.length > 0 && (
        <Text size="xs" c="dimmed" pl={28}>
          {t('campaignFolders.unclassified', { count: unclassified.length })}
        </Text>
      )}
      {canManage && (
        <Text size="xs" c="dimmed" mt="xs">
          {t('campaignFolders.dragHint')}
        </Text>
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
          const created = await create.mutateAsync(parent ? `${parent}/${name}` : name);
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
          const moved = await move.mutateAsync({ from: dialog.path, to });
          if (selected && (selected === dialog.path || selected.startsWith(`${dialog.path}/`))) onSelect(moved.path + selected.slice(dialog.path.length));
          done(t('campaignFolders.folderMoved', { path: moved.path, count: moved.movedCampaigns }));
        }}
      />
      <ConfirmModal
        opened={dialog?.type === 'deleteFolder'}
        title={t('tree.deleteFolder')}
        message={dialog?.type === 'deleteFolder' ? t('tree.deleteFolderConfirm', { path: dialog.path }) : ''}
        confirmLabel={t('tree.delete')}
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          if (dialog?.type !== 'deleteFolder') return;
          await remove.mutateAsync(dialog.path);
          if (selected && (selected === dialog.path || selected.startsWith(`${dialog.path}/`))) onSelect(null);
        }}
      />
    </Stack>
  );
}
