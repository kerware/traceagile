import { Alert, Button, Group, Loader, Modal, MultiSelect, Select, Stack, Textarea, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { fetchDefectDraft, useCreateDefectFromExecution, type DefectDetail, type DefectSeverity } from '../../api/campaigns';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useRequirementTree } from '../../api/requirements';
import { flatten } from '../requirements/model';
import { SEVERITIES } from './model';

type Draft = Schemas['DefectDraftResponse'];
type DefectForm = { title: string; description: string; severity: DefectSeverity; requirementKeys: string[] };

/**
 * Anomalie pré-remplie à relire avant création : F-EXE-03 depuis une exécution, F-EXP-07 depuis une
 * note BUG de session. {@code load} fournit le brouillon, {@code create} crée l'anomalie liée.
 */
export function DefectDraftModal({ project, title, opened, onClose, load, create, creating, onCreated }: {
  project: string;
  title: string;
  opened: boolean;
  onClose: () => void;
  load: () => Promise<Draft>;
  create: (form: DefectForm) => Promise<DefectDetail>;
  creating: boolean;
  onCreated?: (defect: DefectDetail) => void;
}) {
  const { t } = useTranslation();
  const { data: tree } = useRequirementTree(project);
  const [form, setForm] = useState<DefectForm | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!opened) return;
    setForm(null);
    setError(null);
    load()
      .then((draft) => setForm({ title: draft.title, description: draft.description, severity: draft.severity, requirementKeys: draft.requirementKeys }))
      .catch((e) => setError(errorMessage(e, t('errors.generic'))));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [opened]);

  const submit = async () => {
    if (!form) return;
    setError(null);
    try {
      const created = await create(form);
      notifications.show({ color: 'green', message: t('defects.created', { key: created.defect.key }) });
      onCreated?.(created);
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={title} size="xl">
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
              <Button color="red" onClick={submit} loading={creating} disabled={!form.title.trim()} data-testid="defect-submit">
                {t('defects.create')}
              </Button>
            </Group>
          </>
        )}
      </Stack>
    </Modal>
  );
}

/** F-EXE-03 « Créer une anomalie » pré-remplie : étapes, attendu, obtenu, environnement, build ; exigences du test. */
export function DefectFromExecutionModal({ project, executionId, opened, onClose }: { project: string; executionId: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const create = useCreateDefectFromExecution(project, executionId);
  return (
    <DefectDraftModal project={project} title={t('defects.createFromExecution')} opened={opened} onClose={onClose}
      load={() => fetchDefectDraft(project, executionId)} create={(form) => create.mutateAsync(form)} creating={create.isPending} />
  );
}
