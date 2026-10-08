import { Alert, Button, Group, Modal, Select, Stack, Text, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useCreateRequirement, useRequirementTree, type RequirementType } from '../../api/requirements';
import { allowedParentTypes, flatten, REQUIREMENT_TYPES, userStorySentence } from './model';

/** F-REQ-02 création ; F-REQ-05 saisie guidée de la user story ; §3.3-1 parents autorisés. */
export function CreateRequirementModal({
  project,
  opened,
  onClose,
  onCreated,
}: {
  project: string;
  opened: boolean;
  onClose: () => void;
  onCreated?: (key: string) => void;
}) {
  const { t } = useTranslation();
  const create = useCreateRequirement(project);
  const { data: tree } = useRequirementTree(project);
  const [type, setType] = useState<RequirementType>('USER_STORY');
  const [title, setTitle] = useState('');
  const [parentKey, setParentKey] = useState<string | null>(null);
  const [story, setStory] = useState({ asA: '', iWant: '', soThat: '' });
  const [error, setError] = useState<string | null>(null);

  const allowed = allowedParentTypes(type);
  const parents = flatten(tree ?? []).filter((n) => allowed.includes(n.type));

  const reset = () => {
    setTitle('');
    setParentKey(null);
    setStory({ asA: '', iWant: '', soThat: '' });
    setError(null);
  };
  const close = () => {
    reset();
    onClose();
  };

  const submit = async () => {
    setError(null);
    if (!title.trim()) {
      setError(t('auth.required'));
      return;
    }
    if (type === 'USER_STORY' && !parentKey) {
      setError(t('requirement.parentRequired'));
      return;
    }
    try {
      const created = await create.mutateAsync({
        type,
        title: title.trim(),
        parentKey: parentKey ?? undefined,
        ...(type === 'USER_STORY' ? story : {}),
      });
      notifications.show({ color: 'green', message: t('requirement.created', { key: created.key }) });
      close();
      onCreated?.(created.key);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('backlog.new')} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert" data-testid="requirement-create-error">
            {error}
          </Alert>
        )}
        <Select
          label={t('requirement.type')}
          data={REQUIREMENT_TYPES.map((value) => ({ value, label: t(`requirementType.${value}`) }))}
          value={type}
          onChange={(value) => {
            if (value) {
              setType(value as RequirementType);
              setParentKey(null);
            }
          }}
          allowDeselect={false}
          data-testid="requirement-type-input"
        />
        <TextInput
          label={t('requirement.title')}
          required
          maxLength={200}
          value={title}
          onChange={(e) => setTitle(e.currentTarget.value)}
          data-testid="requirement-title-input"
        />
        <Select
          label={t('requirement.parent')}
          placeholder={t('requirement.noParent')}
          data={parents.map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
          value={parentKey}
          onChange={setParentKey}
          disabled={allowed.length === 0}
          searchable
          clearable={type !== 'USER_STORY'}
          required={type === 'USER_STORY'}
          data-testid="requirement-parent-input"
        />
        {type === 'USER_STORY' && (
          <>
            <TextInput label={t('requirement.asA')} value={story.asA} onChange={(e) => setStory({ ...story, asA: e.currentTarget.value })} data-testid="story-as-a-input" />
            <TextInput label={t('requirement.iWant')} value={story.iWant} onChange={(e) => setStory({ ...story, iWant: e.currentTarget.value })} data-testid="story-i-want-input" />
            <TextInput label={t('requirement.soThat')} value={story.soThat} onChange={(e) => setStory({ ...story, soThat: e.currentTarget.value })} data-testid="story-so-that-input" />
            <Text size="sm" c="dimmed" fs="italic" data-testid="story-preview">
              {userStorySentence(story.asA, story.iWant, story.soThat)}
            </Text>
          </>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={close}>
            {t('requirement.cancel')}
          </Button>
          <Button onClick={submit} loading={create.isPending} data-testid="requirement-create-submit">
            {t('requirement.create')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
