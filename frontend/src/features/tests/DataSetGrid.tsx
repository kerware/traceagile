import { ActionIcon, Button, Group, Input, Table, Text, TextInput } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { parseCell } from './model';

/**
 * Jeu de données éditable en grille (§6.1 DATA_DRIVEN, F-MAN-01). Colonnes imposées (variables
 * d'un test manuel) ou libres ; avec {@code typed}, nombres et booléens sont reconnus.
 */
export function DataSetGrid({
  label,
  columns: fixedColumns,
  rows,
  onChange,
  readOnly,
  typed = false,
}: {
  label: string;
  columns?: string[];
  rows: Record<string, unknown>[];
  onChange: (rows: Record<string, unknown>[]) => void;
  readOnly: boolean;
  typed?: boolean;
}) {
  const { t } = useTranslation();
  const [extraColumns, setExtraColumns] = useState<string[]>([]);
  const [newColumn, setNewColumn] = useState('');
  const columns = fixedColumns ?? [...new Set([...rows.flatMap((r) => Object.keys(r)), ...extraColumns])];

  const setCell = (rowIndex: number, column: string, value: string) =>
    onChange(rows.map((row, i) => (i === rowIndex ? { ...row, [column]: typed ? parseCell(value) : value } : row)));
  const addRow = () => onChange([...rows, Object.fromEntries(columns.map((c) => [c, '']))]);
  const removeColumn = (column: string) => {
    setExtraColumns((list) => list.filter((c) => c !== column));
    onChange(rows.map((row) => Object.fromEntries(Object.entries(row).filter(([key]) => key !== column))));
  };

  return (
    <Input.Wrapper label={label}>
      <Table withTableBorder withColumnBorders data-testid="dataset-grid">
        <Table.Thead>
          <Table.Tr>
            <Table.Th w={40}>#</Table.Th>
            {columns.map((column) => (
              <Table.Th key={column}>
                <Group gap={4} wrap="nowrap">
                  {column}
                  {!fixedColumns && !readOnly && (
                    <ActionIcon size="xs" variant="subtle" color="red" onClick={() => removeColumn(column)} aria-label={t('grid.removeColumn')}>
                      <IconTrash size={12} />
                    </ActionIcon>
                  )}
                </Group>
              </Table.Th>
            ))}
            {!readOnly && <Table.Th w={40} />}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {rows.length === 0 && (
            <Table.Tr>
              <Table.Td colSpan={columns.length + 2}>
                <Text size="sm" c="dimmed">
                  {t('grid.empty')}
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
                    value={row[column] === undefined || row[column] === null ? '' : String(row[column])}
                    onChange={(e) => setCell(rowIndex, column, e.currentTarget.value)}
                    readOnly={readOnly}
                    data-testid={`grid-cell-${rowIndex}-${column}`}
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
          <Button size="xs" variant="light" leftSection={<IconPlus size={14} />} onClick={addRow} disabled={columns.length === 0} data-testid="grid-add-row">
            {t('grid.addRow')}
          </Button>
          {!fixedColumns && (
            <>
              <TextInput size="xs" placeholder={t('grid.column')} value={newColumn} onChange={(e) => setNewColumn(e.currentTarget.value)} data-testid="grid-new-column" />
              <Button
                size="xs"
                variant="default"
                disabled={!newColumn.trim() || columns.includes(newColumn.trim())}
                onClick={() => {
                  setExtraColumns((list) => [...list, newColumn.trim()]);
                  setNewColumn('');
                }}
                data-testid="grid-add-column"
              >
                {t('grid.addColumn')}
              </Button>
            </>
          )}
        </Group>
      )}
    </Input.Wrapper>
  );
}
