import { Alert, Button, Group, Modal, Select, Stack } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useMoveRequirement, useRequirementTree, type RequirementDetail } from '../../api/requirements';
import { allowedParentTypes, flatten } from './model';

/** F-REQ-02 changement de parent ; le serveur vérifie le §3.3-1 (types autorisés, pas de cycle). */
export function MoveModal({
  project,
  requirement,
  opened,
  onClose,
}: {
  project: string;
  requirement: RequirementDetail;
  opened: boolean;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const { data: tree } = useRequirementTree(project);
  const move = useMoveRequirement(project);
  const [parentKey, setParentKey] = useState<string | null>(requirement.parent?.key ?? null);
  const [failure, setFailure] = useState<string | null>(null);
  const allowed = allowedParentTypes(requirement.type);
  const candidates = flatten(tree ?? []).filter((n) => allowed.includes(n.type) && n.key !== requirement.key);

  const submit = () => {
    setFailure(null);
    move.mutate(
      { key: requirement.key, parentKey },
      {
        onSuccess: () => {
          notifications.show({ message: t('backlog.moved', { key: requirement.key }) });
          onClose();
        },
        onError: (e) => setFailure(errorMessage(e, t('errors.generic'))),
      },
    );
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('requirement.moveTitle', { key: requirement.key })}>
      <Stack>
        <Select
          label={t('requirement.newParent')}
          placeholder={t('requirement.noParent')}
          data={candidates.map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
          value={parentKey}
          onChange={setParentKey}
          searchable
          clearable={requirement.type !== 'USER_STORY'}
          data-testid="move-parent"
        />
        {failure && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('requirement.cancel')}
          </Button>
          <Button onClick={submit} loading={move.isPending} data-testid="move-submit">
            {t('requirement.move')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
