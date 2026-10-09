import { Alert, Badge, Button, Group, Loader, Menu, Modal, Stack, Tabs, Text, Title } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconCopy, IconDots, IconHourglass, IconSitemap, IconTrash } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { ApiError, errorMessage } from '../../api/errors';
import { useDeleteRequirement, useDuplicateRequirement, useRequirement } from '../../api/requirements';
import { Forbidden } from '../../components/Forbidden';
import { useCanContribute, useCanWriteRequirements } from './permissions';
import { TypeBadge } from './Badges';
import { CriteriaPanel } from './CriteriaPanel';
import { DetailTab } from './DetailTab';
import { HistoryPanel } from './HistoryPanel';
import { TraceTreePanel } from '../traceability/TraceTreePanel';
import { VerificationBadge } from '../traceability/VerificationBadge';
import { LinkedTestsPanel } from './LinkedTestsPanel';
import { MoveModal } from './MoveModal';
import { StatusMenu } from './StatusMenu';
import { VersionsPanel } from './VersionsPanel';

/** Onglets des lots suivants (§13.2) : emplacement réservé avec le lot de livraison. */
const LATER_TABS = [
  { value: 'exampleMapping', lot: 9 },
  { value: 'executions', lot: 5 },
  { value: 'defects', lot: 5 },
  { value: 'comments', lot: 9 },
] as const;

/**
 * §13.2 fiche exigence : onglets Détail, Critères, Example Mapping, Tests liés, Exécutions,
 * Anomalies, Versions, Historique, Commentaires. Utilisée en panneau latéral et en pleine page.
 */
export function RequirementDetailView({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data: requirement, error, isLoading } = useRequirement(project, requirementKey);
  const canWrite = useCanWriteRequirements(project);
  const canContribute = useCanContribute(project);
  const duplicate = useDuplicateRequirement(project);
  const remove = useDeleteRequirement(project);
  const [moving, moveModal] = useDisclosure(false);
  const [deleting, deleteModal] = useDisclosure(false);

  if (isLoading) return <Loader />;
  if (error instanceof ApiError && error.status === 403) return <Forbidden />;
  if (!requirement) return <Alert color="gray">{t('requirement.notFound')}</Alert>;

  const onDuplicate = () =>
    duplicate.mutate(requirement.key, {
      onSuccess: (copy) => notifications.show({ color: 'green', message: t('requirement.duplicated', { key: copy.key }) }),
      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
    });

  const onDelete = () =>
    remove.mutate(requirement.key, {
      onSuccess: () => {
        notifications.show({ message: t('requirement.deleted', { key: requirement.key }) });
        deleteModal.close();
        navigate(`/p/${project}/backlog`);
      },
      onError: (e) => {
        deleteModal.close();
        notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
      },
    });

  return (
    <Stack data-testid="requirement-detail">
      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Stack gap={4}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace" data-testid="requirement-key">
              {requirement.key}
            </Badge>
            <TypeBadge type={requirement.type} />
            <VerificationBadge status={requirement.verificationStatus} testId="requirement-verification" />
            {requirement.currentVersion > 0 && (
              <Badge variant="default">{t('versions.version', { number: requirement.currentVersion })}</Badge>
            )}
          </Group>
          <Title order={3} data-testid="requirement-title">
            {requirement.title}
          </Title>
          <Text size="xs" c="dimmed">
            {t('requirement.metadata', { createdBy: requirement.createdBy ?? '—', version: requirement.version })}
          </Text>
        </Stack>
        <Group wrap="nowrap">
          <StatusMenu project={project} requirement={requirement} canWrite={canWrite} />
          {canWrite && (
            <Menu position="bottom-end">
              <Menu.Target>
                <Button variant="default" leftSection={<IconDots size={16} />} data-testid="requirement-actions">
                  {t('requirement.actions')}
                </Button>
              </Menu.Target>
              <Menu.Dropdown>
                <Menu.Item leftSection={<IconCopy size={14} />} onClick={onDuplicate} data-testid="action-duplicate">
                  {t('requirement.duplicate')}
                </Menu.Item>
                <Menu.Item leftSection={<IconSitemap size={14} />} onClick={moveModal.open} data-testid="action-move">
                  {t('requirement.move')}
                </Menu.Item>
                <Menu.Item color="red" leftSection={<IconTrash size={14} />} onClick={deleteModal.open} data-testid="action-delete">
                  {t('requirement.delete')}
                </Menu.Item>
              </Menu.Dropdown>
            </Menu>
          )}
        </Group>
      </Group>

      <Tabs defaultValue="detail" keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="detail">{t('requirement.tabs.detail')}</Tabs.Tab>
          <Tabs.Tab value="criteria" data-testid="tab-criteria">
            {t('requirement.tabs.criteria')} ({requirement.criteria.length})
          </Tabs.Tab>
          <Tabs.Tab value="tests" data-testid="tab-tests">
            {t('requirement.tabs.tests')}
          </Tabs.Tab>
          <Tabs.Tab value="traceability" data-testid="tab-traceability">
            {t('requirement.tabs.traceability')}
          </Tabs.Tab>
          {LATER_TABS.map((tab) => (
            <Tabs.Tab key={tab.value} value={tab.value} c="dimmed">
              {t(`requirement.tabs.${tab.value}`)}
            </Tabs.Tab>
          ))}
          <Tabs.Tab value="versions">{t('requirement.tabs.versions')}</Tabs.Tab>
          <Tabs.Tab value="history">{t('requirement.tabs.history')}</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="detail" pt="md">
          <DetailTab project={project} requirement={requirement} canWrite={canWrite} canContribute={canContribute} />
        </Tabs.Panel>
        <Tabs.Panel value="criteria" pt="md">
          <CriteriaPanel project={project} requirement={requirement} canContribute={canContribute} />
        </Tabs.Panel>
        <Tabs.Panel value="tests" pt="md">
          <LinkedTestsPanel project={project} requirement={requirement} />
        </Tabs.Panel>
        <Tabs.Panel value="traceability" pt="md">
          <TraceTreePanel project={project} requirementKey={requirement.key} />
        </Tabs.Panel>
        {LATER_TABS.map((tab) => (
          <Tabs.Panel key={tab.value} value={tab.value} pt="md">
            <Alert color="gray" icon={<IconHourglass size={16} />}>
              {t('requirement.laterLot', { lot: tab.lot })}
            </Alert>
          </Tabs.Panel>
        ))}
        <Tabs.Panel value="versions" pt="md">
          <VersionsPanel project={project} requirement={requirement} canWrite={canWrite} />
        </Tabs.Panel>
        <Tabs.Panel value="history" pt="md">
          <HistoryPanel project={project} requirementKey={requirement.key} />
        </Tabs.Panel>
      </Tabs>

      <MoveModal project={project} requirement={requirement} opened={moving} onClose={moveModal.close} />
      <Modal opened={deleting} onClose={deleteModal.close} title={t('requirement.delete')}>
        <Stack>
          <Text>{t('requirement.deleteConfirm', { key: requirement.key })}</Text>
          <Group justify="flex-end">
            <Button variant="default" onClick={deleteModal.close}>
              {t('requirement.cancel')}
            </Button>
            <Button color="red" onClick={onDelete} loading={remove.isPending} data-testid="delete-confirm">
              {t('requirement.delete')}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Stack>
  );
}
