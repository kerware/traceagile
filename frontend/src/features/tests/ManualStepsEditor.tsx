import { ActionIcon, Badge, Button, Fieldset, Group, Paper, Stack, Text, Textarea, Tooltip } from '@mantine/core';
import { IconArrowDown, IconArrowUp, IconCopy, IconPlus, IconTrash } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { DataSetGrid } from './DataSetGrid';
import type { StepDraft, TestDraft } from './draft';
import { stepVariables } from './model';

/** F-MAN-01 pas ordonnés (réordonner, dupliquer) et variables ${nom} alimentées par un jeu de données. */
export function ManualStepsEditor({ draft, onChange, readOnly }: { draft: TestDraft; onChange: (patch: Partial<TestDraft>) => void; readOnly: boolean }) {
  const { t } = useTranslation();
  const steps = draft.steps;
  const variables = stepVariables(steps);
  const setSteps = (next: StepDraft[]) => onChange({ steps: next });
  const updateStep = (index: number, patch: Partial<StepDraft>) => setSteps(steps.map((s, i) => (i === index ? { ...s, ...patch } : s)));
  const move = (index: number, delta: number) => {
    const next = [...steps];
    [next[index], next[index + delta]] = [next[index + delta]!, next[index]!];
    setSteps(next);
  };

  return (
    <Fieldset legend={t('steps.title')} data-testid="manual-steps">
      <Stack>
        {steps.length === 0 && <Text c="dimmed" size="sm">{t('steps.empty')}</Text>}
        {steps.map((step, index) => {
          const position = index + 1;
          return (
            <Paper key={index} withBorder p="xs" data-testid={`step-${position}`}>
              <Group align="flex-start" wrap="nowrap">
                <Badge variant="default" mt={28}>
                  {position}
                </Badge>
                <Textarea flex={2} label={t('steps.action')} autosize minRows={1} value={step.action} onChange={(e) => updateStep(index, { action: e.currentTarget.value })} disabled={readOnly} data-testid={`step-action-${position}`} />
                <Textarea flex={2} label={t('steps.expected')} autosize minRows={1} value={step.expectedResult} onChange={(e) => updateStep(index, { expectedResult: e.currentTarget.value })} disabled={readOnly} data-testid={`step-expected-${position}`} />
                <Textarea flex={1} label={t('steps.data')} autosize minRows={1} value={step.testData} onChange={(e) => updateStep(index, { testData: e.currentTarget.value })} disabled={readOnly} data-testid={`step-data-${position}`} />
                {!readOnly && (
                  <Group gap={2} wrap="nowrap" mt={26}>
                    <Tooltip label={t('steps.up')}>
                      <ActionIcon variant="subtle" disabled={index === 0} onClick={() => move(index, -1)} aria-label={t('steps.up')} data-testid={`step-up-${position}`}>
                        <IconArrowUp size={16} />
                      </ActionIcon>
                    </Tooltip>
                    <Tooltip label={t('steps.down')}>
                      <ActionIcon variant="subtle" disabled={index === steps.length - 1} onClick={() => move(index, 1)} aria-label={t('steps.down')} data-testid={`step-down-${position}`}>
                        <IconArrowDown size={16} />
                      </ActionIcon>
                    </Tooltip>
                    <Tooltip label={t('steps.duplicate')}>
                      <ActionIcon variant="subtle" onClick={() => setSteps([...steps.slice(0, index + 1), { ...step }, ...steps.slice(index + 1)])} aria-label={t('steps.duplicate')} data-testid={`step-duplicate-${position}`}>
                        <IconCopy size={16} />
                      </ActionIcon>
                    </Tooltip>
                    <Tooltip label={t('steps.remove')}>
                      <ActionIcon variant="subtle" color="red" onClick={() => setSteps(steps.filter((_, i) => i !== index))} aria-label={t('steps.remove')} data-testid={`step-remove-${position}`}>
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Tooltip>
                  </Group>
                )}
              </Group>
            </Paper>
          );
        })}
        {!readOnly && (
          <Group>
            <Button variant="light" leftSection={<IconPlus size={16} />} onClick={() => setSteps([...steps, { action: '', expectedResult: '', testData: '' }])} data-testid="step-add">
              {t('steps.add')}
            </Button>
          </Group>
        )}
        {variables.length > 0 && (
          <Stack gap="xs">
            <Group gap="xs">
              <Text size="sm" fw={600}>
                {t('steps.variables')}
              </Text>
              {variables.map((v) => (
                <Badge key={v} variant="light" data-testid={`variable-${v}`}>
                  ${'{'}
                  {v}
                  {'}'}
                </Badge>
              ))}
            </Group>
            <Text size="xs" c="dimmed">
              {t('steps.variablesHint')}
            </Text>
            <DataSetGrid
              label={t('steps.dataSet')}
              columns={variables}
              rows={draft.manualDataSet}
              onChange={(rows) => onChange({ manualDataSet: rows as Record<string, string>[] })}
              readOnly={readOnly}
            />
          </Stack>
        )}
      </Stack>
    </Fieldset>
  );
}
