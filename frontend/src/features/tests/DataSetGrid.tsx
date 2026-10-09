import { ActionIcon, Button, Group, Table, Text, TextInput } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { parseCell } from './model';

/**
 * Lignes d'un jeu de données (ADR-0013) : une colonne par paramètre du test, une ligne par
 * exécution ; une cellule vide prend la valeur par défaut. Avec {@code typed} (tests automatisés),
 * nombres et booléens sont reconnus.
 */
export function DataSetGrid({
  testId,
  columns,
  defaults,
  rows,
  onChange,
  readOnly,
  typed = false,
}: {
  testId: string;
  columns: string[];
  defaults: Record<string, string>;
  rows: Record<string, unknown>[];
  onChange: (rows: Record<string, unknown>[]) => void;
  readOnly: boolean;
  typed?: boolean;
}) {
  const { t } = useTranslation();
  const setCell = (rowIndex: number, column: string, value: string) =>
    onChange(rows.map((row, i) => (i === rowIndex ? { ...row, [column]: typed ? parseCell(value) : value } : row)));
  const addRow = () => onChange([...rows, Object.fromEntries(columns.map((c) => [c, '']))]);

  return (
    <div>
      <Table withTableBorder withColumnBorders data-testid={`${testId}-grid`}>
        <Table.Thead>
          <Table.Tr>
            <Table.Th w={40}>#</Table.Th>
            {columns.map((column) => (
              <Table.Th key={column}>{column}</Table.Th>
            ))}
            {!readOnly && <Table.Th w={40} />}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {rows.length === 0 && (
            <Table.Tr>
              <Table.Td colSpan={columns.length + 2}>
                <Text size="sm" c="dimmed">
                  {columns.length === 0 ? t('grid.noColumns') : t('grid.empty')}
                </Text>
              </Table.Td>
            </Table.Tr>
          )}
          {rows.map((row, rowIndex) => (
            <Table.Tr key={rowIndex}>
              <Table.Td>{rowIndex + 1}</Table.Td>
              {columns.map((column) => (
                <Table.Td key={column} p={2}>
                  <TextInput
                    variant="unstyled"
                    px={6}
                    aria-label={`${column} ${rowIndex + 1}`}
                    placeholder={defaults[column] || undefined}
                    value={row[column] === undefined || row[column] === null ? '' : String(row[column])}
                    onChange={(e) => setCell(rowIndex, column, e.currentTarget.value)}
                    readOnly={readOnly}
                    data-testid={`${testId}-cell-${rowIndex}-${column}`}
                  />
                </Table.Td>
              ))}
              {!readOnly && (
                <Table.Td>
                  <ActionIcon variant="subtle" color="red" onClick={() => onChange(rows.filter((_, i) => i !== rowIndex))} aria-label={t('grid.removeRow')}>
                    <IconTrash size={14} />
                  </ActionIcon>
                </Table.Td>
              )}
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
      {!readOnly && (
        <Group mt="xs">
          <Button size="xs" variant="light" leftSection={<IconPlus size={14} />} onClick={addRow} disabled={columns.length === 0} data-testid={`${testId}-add-row`}>
            {t('grid.addRow')}
          </Button>
        </Group>
      )}
    </div>
  );
}
