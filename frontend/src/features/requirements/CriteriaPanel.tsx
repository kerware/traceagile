import { ActionIcon, Alert, Badge, Button, Group, List, Paper, SegmentedControl, Stack, Text, Textarea, Tooltip } from '@mantine/core';
import { useDebouncedValue } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconArrowDown, IconArrowUp, IconCheck, IconFlask, IconPencil, IconPlus, IconTrash } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { ApiError, errorMessage } from '../../api/errors';
import {
  useAddCriterion,
  useDeleteCriterion,
  useReorderCriteria,
  useUpdateCriterion,
  validateGherkin,
  type Criterion,
  type CriterionFormat,
  type RequirementDetail,
} from '../../api/requirements';
import { useGenerateTest } from '../../api/testcases';
import { useTestWriteKinds } from '../tests/permissions';
import { GherkinView } from './GherkinView';

type Validation = Schemas['GherkinValidationResponse'];

/** F-REQ-09 liste ordonnée des critères ; F-REQ-10 Gherkin validé à la frappe. */
export function CriteriaPanel({
  project,
  requirement,
  canContribute,
}: {
  project: string;
  requirement: RequirementDetail;
  canContribute: boolean;
}) {
  const { t } = useTranslation();
  const [adding, setAdding] = useState(false);
  const [editing, setEditing] = useState<string | null>(null);
  const add = useAddCriterion(project, requirement.key);
  const update = useUpdateCriterion(project);
  const remove = useDeleteCriterion(project);
  const reorder = useReorderCriteria(project, requirement.key);
  const generate = useGenerateTest(project);
  const canGenerate = useTestWriteKinds(project).includes('AUTOMATED');
  const editable = canContribute && requirement.status !== 'OBSOLETE';
  const notifyError = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  const move = (index: number, delta: number) => {
    const ids = requirement.criteria.map((c) => c.id);
    const [moved] = ids.splice(index, 1);
    ids.splice(index + delta, 0, moved!);
    reorder.mutate(ids, { onError: notifyError });
  };

  return (
    <Stack>
      {requirement.criteria.length === 0 && !adding && <Text c="dimmed">{t('criteria.empty')}</Text>}
      {requirement.criteria.map((criterion, index) =>
        editing === criterion.id ? (
          <CriterionEditor
            key={criterion.id}
            initial={criterion}
            saving={update.isPending}
            onCancel={() => setEditing(null)}
            onSave={(format, content) =>
              update.mutateAsync({ criterion, patch: { format, content } }).then(() => setEditing(null))
            }
          />
        ) : (
          <Paper key={criterion.id} withBorder p="sm" data-testid={`criterion-${criterion.position}`}>
            <Group justify="space-between" align="flex-start" wrap="nowrap">
              <Stack gap={6} flex={1}>
                <Group gap="xs">
                  <Badge variant="default" size="sm">
                    #{criterion.position}
                  </Badge>
                  <Badge size="sm" color={criterion.format === 'GHERKIN' ? 'teal' : 'gray'}>
                    {t(`criteria.${criterion.format}`)}
                  </Badge>
                  <Badge size="sm" variant="light" color={criterion.status === 'VERIFIED' ? 'green' : criterion.status === 'FAILED' ? 'red' : 'gray'}>
                    {t(`criteria.statusLabel.${criterion.status}`)}
                  </Badge>
                </Group>
                {criterion.format === 'GHERKIN' ? <GherkinView source={criterion.content} /> : <Text style={{ whiteSpace: 'pre-wrap' }}>{criterion.content}</Text>}
                {criterion.format === 'GHERKIN' && canGenerate && (
                  <Group>
                    <Button
                      size="xs"
                      variant="light"
                      leftSection={<IconFlask size={14} />}
                      loading={generate.isPending && generate.variables === criterion.id}
                      onClick={() =>
                        generate.mutate(criterion.id, {
                          onSuccess: (tests) =>
                            notifications.show({ color: 'green', message: t('generate.done', { keys: tests.map((test) => test.key).join(', ') }) }),
                          onError: notifyError,
                        })
                      }
                      data-testid={`criterion-generate-${criterion.position}`}
                    >
                      {t('generate.button')}
                    </Button>
                  </Group>
                )}
              </Stack>
              {editable && (
                <Group gap={2} wrap="nowrap">
                  <Tooltip label={t('criteria.up')}>
                    <ActionIcon variant="subtle" disabled={index === 0} onClick={() => move(index, -1)} aria-label={t('criteria.up')}>
                      <IconArrowUp size={16} />
                    </ActionIcon>
                  </Tooltip>
                  <Tooltip label={t('criteria.down')}>
                    <ActionIcon variant="subtle" disabled={index === requirement.criteria.length - 1} onClick={() => move(index, 1)} aria-label={t('criteria.down')}>
                      <IconArrowDown size={16} />
                    </ActionIcon>
                  </Tooltip>
                  <Tooltip label={t('criteria.edit')}>
                    <ActionIcon variant="subtle" onClick={() => setEditing(criterion.id)} aria-label={t('criteria.edit')} data-testid={`criterion-edit-${criterion.position}`}>
                      <IconPencil size={16} />
                    </ActionIcon>
                  </Tooltip>
                  <Tooltip label={t('criteria.delete')}>
                    <ActionIcon variant="subtle" color="red" onClick={() => remove.mutate(criterion.id, { onError: notifyError })} aria-label={t('criteria.delete')}>
                      <IconTrash size={16} />
                    </ActionIcon>
                  </Tooltip>
                </Group>
              )}
            </Group>
          </Paper>
        ),
      )}
      {adding && (
        <CriterionEditor
          saving={add.isPending}
          onCancel={() => setAdding(false)}
          onSave={(format, content) => add.mutateAsync({ format, content }).then(() => setAdding(false))}
        />
      )}
      {editable && !adding && (
        <Group>
          <Button variant="light" leftSection={<IconPlus size={16} />} onClick={() => setAdding(true)} data-testid="criterion-add">
            {t('criteria.add')}
          </Button>
        </Group>
      )}
    </Stack>
  );
}

function CriterionEditor({
  initial,
  saving,
  onSave,
  onCancel,
}: {
  initial?: Criterion;
  saving: boolean;
  onSave: (format: CriterionFormat, content: string) => Promise<unknown>;
  onCancel: () => void;
}) {
  const { t } = useTranslation();
  const [format, setFormat] = useState<CriterionFormat>(initial?.format ?? 'TEXT');
  const [content, setContent] = useState(initial?.content ?? '');
  const [debounced] = useDebouncedValue(content, 400);
  const [validation, setValidation] = useState<Validation | null>(null);
  const [failure, setFailure] = useState<string | null>(null);

  useEffect(() => {
    if (format !== 'GHERKIN' || !debounced.trim()) {
      setValidation(null);
      return;
    }
    let cancelled = false;
    validateGherkin(debounced)
      .then((result) => !cancelled && setValidation(result))
      .catch(() => !cancelled && setValidation(null));
    return () => {
      cancelled = true;
    };
  }, [format, debounced]);

  const pending = format === 'GHERKIN' && (debounced !== content || validation === null);
  const invalid = format === 'GHERKIN' && validation !== null && !validation.valid;

  const save = async () => {
    setFailure(null);
    try {
      await onSave(format, content.trim());
    } catch (error) {
      setFailure(errorMessage(error, t('errors.generic')));
      if (error instanceof ApiError && Array.isArray(error.problem.gherkinErrors)) {
        setValidation({ valid: false, language: '', errors: error.problem.gherkinErrors as Validation['errors'] });
      }
    }
  };

  return (
    <Paper withBorder p="sm" data-testid="criterion-editor">
      <Stack>
        <SegmentedControl
          value={format}
          onChange={(value) => setFormat(value as CriterionFormat)}
          data={[
            { value: 'TEXT', label: t('criteria.TEXT') },
            { value: 'GHERKIN', label: t('criteria.GHERKIN') },
          ]}
          aria-label={t('criteria.format')}
          data-testid="criterion-format"
        />
        <Textarea
          label={t('criteria.content')}
          description={format === 'GHERKIN' ? t('criteria.gherkinHint') : undefined}
          autosize
          minRows={format === 'GHERKIN' ? 5 : 2}
          value={content}
          onChange={(e) => setContent(e.currentTarget.value)}
          styles={format === 'GHERKIN' ? { input: { fontFamily: 'var(--mantine-font-family-monospace)' } } : undefined}
          data-testid="criterion-content"
        />
        {format === 'GHERKIN' && validation?.valid && (
          <Text size="sm" c="green" data-testid="gherkin-valid">
            <IconCheck size={14} /> {t('criteria.valid', { language: validation.language })}
          </Text>
        )}
        {invalid && (
          <Alert color="red" title={t('criteria.invalid')} data-testid="gherkin-errors">
            <List size="sm">
              {validation.errors.map((error) => (
                <List.Item key={`${error.line}-${error.column}-${error.message}`}>
                  <Badge size="xs" variant="outline" color="red" mr={6}>
                    {t('criteria.line', { line: error.line })}
                  </Badge>
                  {error.message}
                </List.Item>
              ))}
            </List>
          </Alert>
        )}
        {failure && !invalid && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onCancel}>
            {t('criteria.cancel')}
          </Button>
          <Button onClick={save} disabled={!content.trim() || invalid || pending} loading={saving} data-testid="criterion-save">
            {t('criteria.save')}
          </Button>
        </Group>
      </Stack>
    </Paper>
  );
}
