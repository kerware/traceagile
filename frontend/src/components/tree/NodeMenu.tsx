import { ActionIcon, Group, Menu, type GroupProps } from '@mantine/core';
import { IconDots } from '@tabler/icons-react';
import { useState, type ReactNode } from 'react';
import type { NodeMenuItem } from './menuItems';

/**
 * Ligne d'un arbre avec menu contextuel : clic droit sur la ligne ou bouton « ⋯ » (accessible au
 * clavier). Les entrées sont fournies par l'arbre selon le nœud et les droits.
 */
export function NodeMenuRow({
  testId,
  label,
  items,
  children,
  ...rowProps
}: { testId: string; label: string; items: NodeMenuItem[]; children: ReactNode; role?: string; 'aria-expanded'?: boolean } & Omit<GroupProps, 'children'>) {
  const [opened, setOpened] = useState(false);
  const actionable = items.filter((item) => !item.divider);
  return (
    <Group
      gap={6}
      wrap="nowrap"
      {...rowProps}
      data-testid={testId}
      onContextMenu={(event) => {
        if (actionable.length === 0) return;
        event.preventDefault();
        setOpened(true);
      }}
    >
      {children}
      {actionable.length > 0 && (
        <Menu opened={opened} onChange={setOpened} position="bottom-start" shadow="md" withinPortal>
          <Menu.Target>
            <ActionIcon variant="subtle" color="gray" size="sm" aria-label={label} data-testid={`${testId}-menu`}>
              <IconDots size={14} />
            </ActionIcon>
          </Menu.Target>
          <Menu.Dropdown>
            {items.map((item) =>
              item.divider ? (
                <Menu.Divider key={item.key} />
              ) : (
                <Menu.Item key={item.key} leftSection={item.icon} color={item.color} disabled={item.disabled} onClick={item.onClick} data-testid={`menu-${item.key}`}>
                  {item.label}
                </Menu.Item>
              ),
            )}
          </Menu.Dropdown>
        </Menu>
      )}
    </Group>
  );
}
