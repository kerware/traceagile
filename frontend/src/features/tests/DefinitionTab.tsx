import { Alert, Button, Checkbox, Group, List, NumberInput, Select, Stack, TagsInput, Textarea, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useUpdateTest, type TestCaseDetail } from '../../api/testcases';
import { PRIORITIES } from '../requirements/model';
import { AutomationEditor } from './AutomationEditor';
import { CharterEditor } from './CharterEditor';
import { isDirty, toDraft, toPatch, type TestDraft } from './draft';
import { ManualStepsEditor } from './ManualStepsEditor';

/** Onglet Définition : champs communs puis éditeur propre à la nature (pas, charte ou automatisation). */
export function DefinitionTab({ project, test, canWrite }: { project: string; test: TestCaseDetail; canWrite: boolean }) {
  const { t } = useTranslation();
  const update = useUpdateTest(project);
  const [initial] = useState(() => toDraft(test));
  const [draft, setDraft] = useState<TestDraft>(initial);
  const change = (patch: Partial<TestDraft>) => setDraft((current) => ({ ...current, ...patch }));
  const dirty = isDirty(test.kind, initial, draft);
  const readOnly = !canWrite;

  const save = async () => {
    try {
      const saved = await update.mutateAsync({ test, patch: toPatch(test.kind, initial, draft) });
      notifications.show({
        color: 'green',
        message: saved.currentVersion > test.currentVersion ? t('test.versionBumped', { number: saved.currentVersion }) : t('test.saved'),
      });
    } catch (error) {
      notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) });
    }
  };

  return (
    <Stack>
      {test.warnings.length > 0 && (
        <Alert color="yellow" icon={<IconAlertTriangle size={16} />} title={t('test.warnings')} data-testid="test-warnings">
          <List size="sm">
            {test.warnings.map((w) => (
              <List.Item key={w}>{w}</List.Item>
            ))}
          </List>
        </Alert>
      )}
      <TextInput label={t('test.title')} required maxLength={200} value={draft.title} onChange={(e) => change({ title: e.currentTarget.value })} disabled={readOnly} data-testid="test-field-title" />
      <Textarea label={t('test.objective')} autosize minRows={1} value={draft.objective} onChange={(e) => change({ objective: e.currentTarget.value })} disabled={readOnly} />
      <Group grow align="flex-start">
        <Select
          label={t('test.priority')}
          data={PRIORITIES.map((p) => ({ value: p, label: t(`priority.${p}`) }))}
          value={draft.priority}
          onChange={(value) => value && change({ priority: value as TestDraft['priority'] })}
          allowDeselect={false}
          disabled={readOnly}
        />
        <NumberInput label={t('test.duration')} min={1} max={10000} value={draft.estimatedDurationMin} onChange={(value) => change({ estimatedDurationMin: value === '' ? '' : Number(value) })} disabled={readOnly} />
        <TextInput label={t('test.folder')} description={t('test.folderHint')} value={draft.folder} onChange={(e) => change({ folder: e.currentTarget.value })} disabled={readOnly} />
      </Group>
      <TagsInput label={t('test.tags')} value={draft.tags} onChange={(tags) => change({ tags })} disabled={readOnly} />
      <Textarea label={t('test.description')} autosize minRows={2} value={draft.description} onChange={(e) => change({ description: e.currentTarget.value })} disabled={readOnly} />

      {test.kind === 'MANUAL' && (
        <>
          <ManualStepsEditor draft={draft} onChange={change} readOnly={readOnly} />
          <Group align="flex-end">
            <Checkbox
              label={t('test.automationCandidate')}
              checked={draft.automationCandidate}
              onChange={(e) => change({ automationCandidate: e.currentTarget.checked })}
              disabled={readOnly}
              data-testid="test-candidate"
            />
            {draft.automationCandidate && (
              <TextInput flex={1} label={t('test.automationJustification')} required value={draft.automationJustification} onChange={(e) => change({ automationJustification: e.currentTarget.value })} disabled={readOnly} />
            )}
          </Group>
        </>
      )}
      {test.kind === 'EXPLORATORY' && <CharterEditor draft={draft} onChange={change} readOnly={readOnly} />}
      {test.kind === 'AUTOMATED' && <AutomationEditor project={project} test={test} draft={draft} onChange={change} readOnly={readOnly} />}

      {canWrite && (
        <Group justify="flex-end">
          <Button variant="default" onClick={() => setDraft(initial)} disabled={!dirty}>
            {t('test.cancel')}
          </Button>
          <Button onClick={save} disabled={!dirty} loading={update.isPending} data-testid="test-save">
            {t('test.save')}
          </Button>
        </Group>
      )}
    </Stack>
  );
}
