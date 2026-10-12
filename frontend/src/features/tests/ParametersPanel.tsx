import { ActionIcon, Badge, Button, Fieldset, Group, Paper, Stack, Table, Text, TextInput, Tooltip } from '@mantine/core';
import { IconCopy, IconPlus, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { DataSetGrid } from './DataSetGrid';
import type { DataSetDraft, ParameterDraft, TestDraft } from './draft';
import { mergeParameters, PARAMETER_NAME, stepVariables } from './model';

/**
 * ADR-0013 paramètres du test (détectés dans les pas d'un test manuel sous la forme ${nom}, ou
 * déclarés) et jeux de données nommés : une colonne par paramètre, une ligne par exécution.
 */
export function ParametersPanel({ manual, typed, draft, onChange, readOnly }: { manual: boolean; typed: boolean; draft: TestDraft; onChange: (patch: Partial<TestDraft>) => void; readOnly: boolean }) {
  const { t } = useTranslation();
  const [newName, setNewName] = useState('');
  const detected = manual ? stepVariables(draft.steps) : [];
  const rows = mergeParameters(draft.parameters, detected, manual);
  const columns = rows.map((p) => p.name);
  const defaults = Object.fromEntries(rows.map((p) => [p.name, p.defaultValue]));

  const candidate = newName.trim();
  const nameError = candidate && !PARAMETER_NAME.test(candidate) ? t('parameters.nameInvalid') : candidate && columns.includes(candidate) ? t('parameters.nameDuplicated') : null;

  /** Modifier un paramètre détecté le déclare (il garde sa valeur par défaut et sa description). */
  const updateParameter = (name: string, patch: Partial<ParameterDraft>) => {
    const exists = draft.parameters.some((p) => p.name === name);
    const parameters = exists
      ? draft.parameters.map((p) => (p.name === name ? { ...p, ...patch } : p))
      : [...draft.parameters, { name, defaultValue: '', description: '', ...patch }];
    onChange({ parameters });
  };
  const addParameter = () => {
    onChange({ parameters: [...draft.parameters, { name: candidate, defaultValue: '', description: '' }] });
    setNewName('');
  };
  const removeParameter = (name: string) =>
    onChange({
      parameters: draft.parameters.filter((p) => p.name !== name),
      dataSets: draft.dataSets.map((d) => ({ ...d, rows: d.rows.map((row) => Object.fromEntries(Object.entries(row).filter(([key]) => key !== name))) })),
    });

  const setDataSets = (dataSets: DataSetDraft[]) => onChange({ dataSets });
  const updateDataSet = (index: number, patch: Partial<DataSetDraft>) => setDataSets(draft.dataSets.map((d, i) => (i === index ? { ...d, ...patch } : d)));
  const freeName = (base: string) => {
    const taken = new Set(draft.dataSets.map((d) => d.name.toLowerCase()));
    let n = draft.dataSets.length + 1;
    while (taken.has(`${base} ${n}`.toLowerCase())) n += 1;
    return `${base} ${n}`;
  };
  const duplicateNames = new Set(
    draft.dataSets.map((d) => d.name.trim().toLowerCase()).filter((name, i, all) => all.indexOf(name) !== i),
  );

  return (
    <Fieldset legend={t('parameters.title')} data-testid="parameters-panel">
      <Stack>
        <Text size="xs" c="dimmed">
          {manual ? t('parameters.hintManual') : t('parameters.hint')}
        </Text>
        {rows.length > 0 && (
          <Table data-testid="parameters-table">
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('parameters.name')}</Table.Th>
                <Table.Th>{t('parameters.defaultValue')}</Table.Th>
                <Table.Th>{t('parameters.description')}</Table.Th>
                {!readOnly && <Table.Th w={40} />}
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {rows.map((p) => (
                <Table.Tr key={p.name} data-testid={`param-row-${p.name}`}>
                  <Table.Td>
                    <Group gap={6} wrap="nowrap">
                      <Text size="sm" ff="monospace">
                        {p.name}
                      </Text>
                      {p.detected && (
                        <Badge size="xs" variant="light" data-testid={`param-detected-${p.name}`}>
                          {t('parameters.detected')}
                        </Badge>
                      )}
                      {p.unused && (
                        <Tooltip label={t('parameters.unusedHint')}>
                          <Badge size="xs" variant="light" color="orange" data-testid={`param-unused-${p.name}`}>
                            {t('parameters.unused')}
                          </Badge>
                        </Tooltip>
                      )}
                    </Group>
                  </Table.Td>
                  <Table.Td p={2}>
                    <TextInput variant="unstyled" px={6} aria-label={`${t('parameters.defaultValue')} ${p.name}`} value={p.defaultValue} onChange={(e) => updateParameter(p.name, { defaultValue: e.currentTarget.value })} readOnly={readOnly} data-testid={`param-default-${p.name}`} />
                  </Table.Td>
                  <Table.Td p={2}>
                    <TextInput variant="unstyled" px={6} aria-label={`${t('parameters.description')} ${p.name}`} value={p.description} onChange={(e) => updateParameter(p.name, { description: e.currentTarget.value })} readOnly={readOnly} data-testid={`param-description-${p.name}`} />
                  </Table.Td>
                  {!readOnly && (
                    <Table.Td>
                      <Tooltip label={p.detected ? t('parameters.removeDetected') : t('parameters.remove')}>
                        <ActionIcon variant="subtle" color="red" disabled={p.detected} onClick={() => removeParameter(p.name)} aria-label={t('parameters.remove')} data-testid={`param-remove-${p.name}`}>
                          <IconTrash size={14} />
                        </ActionIcon>
                      </Tooltip>
                    </Table.Td>
                  )}
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}
        {!readOnly && (
          <Group align="flex-start">
            <TextInput
              size="xs"
              placeholder={t('parameters.newName')}
              aria-label={t('parameters.newName')}
              value={newName}
              onChange={(e) => setNewName(e.currentTarget.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && candidate && !nameError) addParameter();
              }}
              error={nameError}
              data-testid="param-new"
            />
            <Button size="xs" variant="light" leftSection={<IconPlus size={14} />} disabled={!candidate || !!nameError} onClick={addParameter} data-testid="param-add">
              {t('parameters.add')}
            </Button>
          </Group>
        )}

        <Text size="sm" fw={600} mt="sm">
          {t('parameters.dataSets')}
        </Text>
        {draft.dataSets.length === 0 && (
          <Text size="sm" c="dimmed">
            {t('parameters.noDataSet')}
          </Text>
        )}
        {draft.dataSets.map((set, index) => (
          <Paper key={index} withBorder p="xs" data-testid={`dataset-${index}`}>
            <Stack gap="xs">
              <Group justify="space-between" wrap="nowrap">
                <TextInput
                  size="xs"
                  flex={1}
                  maw={320}
                  aria-label={t('parameters.dataSetName')}
                  value={set.name}
                  onChange={(e) => updateDataSet(index, { name: e.currentTarget.value })}
                  readOnly={readOnly}
                  error={!set.name.trim() ? t('parameters.dataSetNameRequired') : duplicateNames.has(set.name.trim().toLowerCase()) ? t('parameters.dataSetNameDuplicated') : null}
                  data-testid={`dataset-name-${index}`}
                />
                <Text size="xs" c="dimmed">
                  {t('parameters.rows', { count: set.rows.length })}
                </Text>
                {!readOnly && (
                  <Group gap={2} wrap="nowrap">
                    <Tooltip label={t('parameters.duplicateDataSet')}>
                      <ActionIcon variant="subtle" onClick={() => setDataSets([...draft.dataSets.slice(0, index + 1), { name: freeName(set.name), rows: set.rows.map((r) => ({ ...r })), rowNames: [...set.rowNames] }, ...draft.dataSets.slice(index + 1)])} aria-label={t('parameters.duplicateDataSet')} data-testid={`dataset-duplicate-${index}`}>
                        <IconCopy size={16} />
                      </ActionIcon>
                    </Tooltip>
                    <Tooltip label={t('parameters.removeDataSet')}>
                      <ActionIcon variant="subtle" color="red" onClick={() => setDataSets(draft.dataSets.filter((_, i) => i !== index))} aria-label={t('parameters.removeDataSet')} data-testid={`dataset-remove-${index}`}>
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Tooltip>
                  </Group>
                )}
              </Group>
              <DataSetGrid testId={`dataset-${index}`} columns={columns} defaults={defaults} rows={set.rows} names={set.rowNames}
                onChange={(next, names) => updateDataSet(index, { rows: next, rowNames: names })} readOnly={readOnly} typed={typed} />
            </Stack>
          </Paper>
        ))}
        {!readOnly && (
          <Group>
            <Button size="xs" variant="default" leftSection={<IconPlus size={14} />} onClick={() => setDataSets([...draft.dataSets, { name: freeName(t('parameters.dataSetBase')), rows: [], rowNames: [] }])} data-testid="dataset-add">
              {t('parameters.addDataSet')}
            </Button>
          </Group>
        )}
      </Stack>
    </Fieldset>
  );
}
