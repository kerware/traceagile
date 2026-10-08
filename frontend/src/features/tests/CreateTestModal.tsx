import { Alert, Button, Group, Modal, SegmentedControl, Select, Stack, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useRequirementTree } from '../../api/requirements';
import { useCreateTest, useFrameworks, type TestKind, type TestTechnique } from '../../api/testcases';
import { flatten } from '../requirements/model';
import { TECHNIQUES } from './model';

/** Lot 2 : création des trois natures de test (§3.1) ; framework proposé par la donnée de référence (F-AUT-01). */
export function CreateTestModal({
  project,
  opened,
  onClose,
  kinds,
  onCreated,
}: {
  project: string;
  opened: boolean;
  onClose: () => void;
  kinds: TestKind[];
  onCreated?: (key: string) => void;
}) {
  const { t } = useTranslation();
  const create = useCreateTest(project);
  const { data: frameworks } = useFrameworks();
  const { data: tree } = useRequirementTree(project);
  const [kind, setKind] = useState<TestKind>(kinds[0] ?? 'MANUAL');
  const [title, setTitle] = useState('');
  const [technique, setTechnique] = useState<TestTechnique | null>(null);
  const [framework, setFramework] = useState<string | null>(null);
  const [folder, setFolder] = useState('');
  const [requirement, setRequirement] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (kinds.length > 0 && !kinds.includes(kind)) setKind(kinds[0]!);
  }, [kinds, kind]);

  const frameworkOptions = (frameworks ?? []).filter((f) => f.technique === technique).map((f) => f.name);

  const close = () => {
    setTitle('');
    setTechnique(null);
    setFramework(null);
    setFolder('');
    setRequirement(null);
    setError(null);
    onClose();
  };

  const submit = async () => {
    setError(null);
    if (!title.trim()) return setError(t('auth.required'));
    if (kind === 'AUTOMATED' && !technique) return setError(t('test.technique') + ' : ' + t('auth.required'));
    try {
      const created = await create.mutateAsync({
        kind,
        title: title.trim(),
        ...(kind === 'AUTOMATED' ? { technique: technique!, framework: framework ?? undefined } : {}),
        ...(folder.trim() ? { folder: folder.trim() } : {}),
        ...(requirement ? { links: [{ requirementKey: requirement, linkType: 'VERIFIES' as const }] } : {}),
      });
      notifications.show({ color: 'green', message: t('test.created', { key: created.key }) });
      close();
      onCreated?.(created.key);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('tests.new')} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <SegmentedControl
          value={kind}
          onChange={(value) => setKind(value as TestKind)}
          data={kinds.map((k) => ({ value: k, label: t(`testKind.${k}`) }))}
          aria-label={t('test.kind')}
          data-testid="test-kind-input"
        />
        <TextInput label={t('test.title')} required maxLength={200} value={title} onChange={(e) => setTitle(e.currentTarget.value)} data-testid="test-title-input" />
        {kind === 'AUTOMATED' && (
          <Group grow>
            <Select
              label={t('test.technique')}
              required
              data={TECHNIQUES.map((value) => ({ value, label: t(`technique.${value}`) }))}
              value={technique}
              onChange={(value) => {
                setTechnique(value as TestTechnique | null);
                setFramework((frameworks ?? []).find((f) => f.technique === value)?.name ?? null);
              }}
              data-testid="test-technique-input"
            />
            <Select label={t('test.framework')} data={frameworkOptions} value={framework} onChange={setFramework} disabled={!technique} data-testid="test-framework-input" />
          </Group>
        )}
        <TextInput label={t('test.folder')} description={t('test.folderHint')} value={folder} onChange={(e) => setFolder(e.currentTarget.value)} data-testid="test-folder-input" />
        <Select
          label={t('test.requirement')}
          data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
          value={requirement}
          onChange={setRequirement}
          searchable
          clearable
          data-testid="test-requirement-input"
        />
        <Group justify="flex-end">
          <Button variant="default" onClick={close}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={create.isPending} data-testid="test-create-submit">
            {t('test.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
