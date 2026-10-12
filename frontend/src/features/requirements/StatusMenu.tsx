import { Alert, Button, Checkbox, Group, List, Loader, Menu, Modal, Stack, Text, ThemeIcon } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconChevronDown, IconMinus, IconX } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useChangeStatus, useRequirementChecklists, type RequirementDetail, type RequirementStatus } from '../../api/requirements';
import { StatusBadge } from './Badges';

type Result = Schemas['ChecklistResultResponse'];

/** §3.2 changement de statut ; F-REQ-20 la DoR / DoD est affichée avant READY et DONE. */
export function StatusMenu({ project, requirement, canWrite }: { project: string; requirement: RequirementDetail; canWrite: boolean }) {
  const { t } = useTranslation();
  const [target, setTarget] = useState<RequirementStatus | null>(null);

  if (!canWrite || requirement.allowedTransitions.length === 0) {
    return <StatusBadge status={requirement.status} />;
  }
  return (
    <>
      <Menu position="bottom-end">
        <Menu.Target>
          <Button variant="default" rightSection={<IconChevronDown size={14} />} data-testid="status-menu" aria-label={t('requirement.changeStatus')}>
            <StatusBadge status={requirement.status} />
          </Button>
        </Menu.Target>
        <Menu.Dropdown>
          <Menu.Label>{t('requirement.changeStatus')}</Menu.Label>
          {requirement.allowedTransitions.map((status) => (
            <Menu.Item key={status} onClick={() => setTarget(status)} data-testid={`status-option-${status}`}>
              {t(`requirementStatus.${status}`)}
            </Menu.Item>
          ))}
        </Menu.Dropdown>
      </Menu>
      {target && <StatusChangeModal project={project} requirement={requirement} target={target} onClose={() => setTarget(null)} />}
    </>
  );
}

export function StatusChangeModal({
  project,
  requirement,
  target,
  onClose,
}: {
  project: string;
  requirement: RequirementDetail;
  target: RequirementStatus;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const kind = target === 'READY' ? 'dor' : target === 'DONE' ? 'dod' : null;
  const { data: checklists, isLoading } = useRequirementChecklists(project, requirement.key, kind !== null);
  const change = useChangeStatus(project);
  const [acknowledged, setAcknowledged] = useState(false);
  const [failure, setFailure] = useState<string | null>(null);

  const items: Result[] = kind && checklists ? checklists[kind] : [];
  const blocking = items.filter((i) => i.automatic && i.outcome === 'UNSATISFIED');
  const manualUnmet = items.filter((i) => !i.automatic && i.outcome === 'UNSATISFIED');
  const canConfirm = blocking.length === 0 && (manualUnmet.length === 0 || acknowledged) && !(kind && isLoading);

  const confirm = () =>
    change.mutate(
      { key: requirement.key, status: target, acknowledgeUnmet: acknowledged },
      {
        onSuccess: () => {
          notifications.show({ color: 'green', message: t('statusChange.done', { key: requirement.key, status: t(`requirementStatus.${target}`) }) });
          onClose();
        },
        onError: (e) => setFailure(errorMessage(e, t('errors.generic'))),
      },
    );

  return (
    <Modal opened onClose={onClose} title={t('statusChange.title', { key: requirement.key, status: t(`requirementStatus.${target}`) })}>
      <Stack>
        {kind && (
          <>
            <Text size="sm">{t('statusChange.checklist', { name: t(kind === 'dor' ? 'requirement.dor' : 'requirement.dod') })}</Text>
            {isLoading ? <Loader size="sm" /> : <ChecklistResults items={items} />}
          </>
        )}
        {blocking.length > 0 && (
          <Alert color="red" data-testid="status-blocked">
            {t('statusChange.blocked')}
          </Alert>
        )}
        {blocking.length === 0 && manualUnmet.length > 0 && (
          <Checkbox
            label={t('statusChange.acknowledge')}
            checked={acknowledged}
            onChange={(e) => setAcknowledged(e.currentTarget.checked)}
            data-testid="status-acknowledge"
          />
        )}
        {failure && (
          <Alert color="red" role="alert">
            {failure}
          </Alert>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('requirement.cancel')}
          </Button>
          <Button onClick={confirm} disabled={!canConfirm} loading={change.isPending} data-testid="status-confirm">
            {t('statusChange.confirm')}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** F-REQ-20 résultat de chaque item, avec icône et libellé (§13.3). */
export function ChecklistResults({ items, onToggle }: { items: Result[]; onToggle?: (item: Result, checked: boolean) => void }) {
  const { t } = useTranslation();
  return (
    <List spacing={6} center>
      {items.map((item) => (
        <List.Item
          key={item.id}
          icon={
            <ThemeIcon size={20} radius="xl" color={item.outcome === 'SATISFIED' ? 'green' : item.outcome === 'UNSATISFIED' ? 'red' : 'gray'}>
              {item.outcome === 'SATISFIED' ? <IconCheck size={12} /> : item.outcome === 'UNSATISFIED' ? <IconX size={12} /> : <IconMinus size={12} />}
            </ThemeIcon>
          }
          data-testid={`checklist-item-${item.id}`}
        >
          <Group gap="xs">
            {onToggle && !item.automatic ? (
              <Checkbox
                label={item.label}
                checked={item.outcome === 'SATISFIED'}
                onChange={(e) => onToggle(item, e.currentTarget.checked)}
                data-testid={`checklist-check-${item.id}`}
              />
            ) : (
              <Text size="sm">{item.label}</Text>
            )}
            <Text size="xs" c="dimmed">
              ({item.automatic ? t('requirement.automatic') : t('requirement.manual')} · {t(`outcome.${item.outcome}`)})
            </Text>
          </Group>
        </List.Item>
      ))}
    </List>
  );
}
