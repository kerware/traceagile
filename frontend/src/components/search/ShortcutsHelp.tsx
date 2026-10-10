import { Group, Kbd, Modal, Stack, Table, Text } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { SHORTCUTS } from './shortcuts';

/** §13.3 aide des raccourcis clavier ({@code ?}). */
export function ShortcutsHelp({ opened, onClose }: { opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  return (
    <Modal opened={opened} onClose={onClose} title={t('shortcuts.title')} size="lg">
      <Stack>
        <Text size="sm" c="dimmed">
          {t('shortcuts.intro')}
        </Text>
        <Table data-testid="shortcuts-help">
          <Table.Tbody>
            {SHORTCUTS.map((s) => (
              <Table.Tr key={s.id}>
                <Table.Td w={160}>
                  <Group gap={4}>
                    {s.keys.map((k) => (
                      <Kbd key={k}>{k}</Kbd>
                    ))}
                  </Group>
                </Table.Td>
                <Table.Td>{t(`shortcuts.${s.id}`)}</Table.Td>
                <Table.Td>
                  <Text size="xs" c="dimmed">
                    {t(`shortcuts.where.${s.where}`)}
                  </Text>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      </Stack>
    </Modal>
  );
}
