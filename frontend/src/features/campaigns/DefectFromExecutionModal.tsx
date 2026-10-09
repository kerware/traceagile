import { Alert, Button, Group, Loader, Modal, MultiSelect, Select, Stack, Textarea, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { fetchDefectDraft, useCreateDefectFromExecution, type DefectSeverity } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { useRequirementTree } from '../../api/requirements';
import { flatten } from '../requirements/model';
import { SEVERITIES } from './model';

/** F-EXE-03 « Créer une anomalie » pré-remplie : étapes, attendu, obtenu, environnement, build ; exigences du test. */
export function DefectFromExecutionModal({ project, executionId, opened, onClose }: { project: string; executionId: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const create = useCreateDefectFromExecution(project, executionId);
  const { data: tree } = useRequirementTree(project);
  const [form, setForm] = useState<{ title: string; description: string; severity: DefectSeverity; requirementKeys: string[] } | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!opened) return;
    setForm(null);
    setError(null);
    fetchDefectDraft(project, executionId)
      .then((draft) => setForm({ title: draft.title, description: draft.description, severity: draft.severity, requirementKeys: draft.requirementKeys }))
      .catch((e) => setError(errorMessage(e, t('errors.generic'))));
  }, [opened, project, executionId, t]);

  const submit = async () => {
    if (!form) return;
    setError(null);
    try {
      const created = await create.mutateAsync(form);
      notifications.show({ color: 'green', message: t('defects.created', { key: created.defect.key }) });
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('defects.createFromExecution')} size="xl">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        {!form && !error && <Loader />}
        {form && (
          <>
            <TextInput label={t('defects.title')} required maxLength={200} value={form.title} onChange={(e) => setForm({ ...form, title: e.currentTarget.value })} data-testid="defect-title" />
            <Group grow>
              <Select label={t('defects.severity')} data={SEVERITIES.map((s) => ({ value: s, label: t(`severity.${s}`) }))} value={form.severity}
                onChange={(severity) => severity && setForm({ ...form, severity: severity as DefectSeverity })} allowDeselect={false} data-testid="defect-severity" />
              <MultiSelect label={t('defects.requirements')} data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
                value={form.requirementKeys} onChange={(requirementKeys) => setForm({ ...form, requirementKeys })} searchable data-testid="defect-requirements" />
            </Group>
            <Textarea label={t('defects.description')} autosize minRows={8} maxRows={18} value={form.description}
              onChange={(e) => setForm({ ...form, description: e.currentTarget.value })} data-testid="defect-description" />
            <Group justify="flex-end">
              <Button variant="default" onClick={onClose}>
                {t('test.cancel')}
              </Button>
              <Button color="red" onClick={submit} loading={create.isPending} disabled={!form.title.trim()} data-testid="defect-submit">
                {t('defects.create')}
              </Button>
            </Group>
          </>
        )}
      </Stack>
    </Modal>
  );
}
