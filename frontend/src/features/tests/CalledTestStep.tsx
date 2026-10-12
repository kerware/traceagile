import { Anchor, Badge, Group, Select, SimpleGrid, Stack, Text, TextInput } from '@mantine/core';
import { IconCornerDownRight } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useTestCase, useTestList } from '../../api/testcases';
import type { StepDraft } from './draft';

/**
 * ADR-0018 pas qui appelle un autre cas de test manuel : choix de l'appelé, valeur de chacun de ses
 * paramètres (texte fixe ou ${nom} d'un paramètre de ce test ; vide = défaut ou paramètre de même nom).
 * ADR-0029 l'appel peut désigner par son nom un jeu de données de l'appelé (« Comptes › standard_user »).
 */
export function CalledTestStep({ project, testKey, step, position, onChange, readOnly }: {
  project: string;
  testKey: string | null;
  step: StepDraft;
  position: number;
  onChange: (patch: Partial<StepDraft>) => void;
  readOnly: boolean;
}) {
  const { t } = useTranslation();
  const [search, setSearch] = useState('');
  const { data: candidates } = useTestList(project, { kind: ['MANUAL'], q: search || undefined }, 0, 'key,asc');
  const { data: called } = useTestCase(project, step.calledTestKey || null);
  const options = (candidates?.content ?? [])
    .filter((c) => c.key !== testKey && c.status !== 'OBSOLETE')
    .map((c) => ({ value: c.key, label: `${c.key} — ${c.title}` }));
  if (step.calledTestKey && !options.some((o) => o.value === step.calledTestKey)) {
    options.unshift({ value: step.calledTestKey, label: `${step.calledTestKey} — ${step.calledTestTitle ?? called?.title ?? ''}` });
  }
  const values = step.callParameters ?? {};
  // ADR-0029 jeux nommés de l'appelé : « jeu › ligne », valeurs relues à l'exécution
  const rows = (called?.dataSets ?? []).flatMap((dataSet) =>
    dataSet.rows.map((row, r) => ({
      value: `${dataSet.name}|${dataSet.rowNames[r]}`,
      label: `${dataSet.name} › ${dataSet.rowNames[r]}`,
      values: Object.fromEntries(Object.entries(row).map(([name, value]) => [name, String(value ?? '')])) as Record<string, string>,
    })),
  );
  const selected = step.callDataSet ? rows.find((r) => r.value.toLowerCase() === `${step.callDataSet}|${step.callRow}`.toLowerCase()) : undefined;

  return (
    <Stack gap={6} flex={1}>
      <Group gap={6}>
        <Badge color="grape" variant="light" leftSection={<IconCornerDownRight size={12} />}>
          {t('steps.call')}
        </Badge>
        {step.calledTestKey && (
          <Anchor component={Link} to={`/p/${project}/tests/${step.calledTestKey}`} size="xs" target="_blank">
            {t('steps.openCalled')}
          </Anchor>
        )}
      </Group>
      <Select
        label={t('steps.calledTest')}
        placeholder={t('steps.calledTestPlaceholder')}
        data={options}
        value={step.calledTestKey || null}
        onChange={(key) => onChange({ calledTestKey: key ?? '', calledTestTitle: options.find((o) => o.value === key)?.label.split(' — ')[1], callParameters: {}, callDataSet: '', callRow: '' })}
        searchable
        onSearchChange={setSearch}
        disabled={readOnly}
        data-testid={`step-called-${position}`}
      />
      {called && rows.length > 0 && (
        <Select
          size="xs"
          label={t('steps.callDataSet')}
          description={t('steps.callDataSetHint')}
          placeholder={t('steps.callDataSetPlaceholder')}
          data={rows.map((r) => ({ value: r.value, label: r.label }))}
          value={selected?.value ?? null}
          onChange={(value) => {
            const [dataSet, row] = value ? value.split('|') : ['', ''];
            onChange({ callDataSet: dataSet, callRow: row });
          }}
          clearable
          disabled={readOnly}
          data-testid={`step-call-dataset-${position}`}
        />
      )}
      {called && called.parameters.length > 0 && (
        <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="xs" data-testid={`step-call-parameters-${position}`}>
          {called.parameters.map((p) => (
            <TextInput
              key={p.name}
              size="xs"
              label={`\${${p.name}}`}
              placeholder={selected?.values[p.name] || p.defaultValue || t('steps.inherit')}
              value={values[p.name] ?? ''}
              onChange={(e) => onChange({ callParameters: { ...values, [p.name]: e.currentTarget.value } })}
              disabled={readOnly}
              data-testid={`step-call-${position}-${p.name}`}
            />
          ))}
        </SimpleGrid>
      )}
      {called && (
        <Text size="xs" c="dimmed">
          {t('steps.calledSteps', { count: called.steps.length })}
        </Text>
      )}
    </Stack>
  );
}
