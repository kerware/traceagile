import { Alert, Anchor, Badge, Button, Group, Loader, Menu, Modal, Stack, Tabs, Text, Title } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconChevronDown, IconDots, IconTrash } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router-dom';
import { ApiError, errorMessage } from '../../api/errors';
import { useChangeTestStatus, useDeleteTest, useTestCase, type TestCaseDetail } from '../../api/testcases';
import { Forbidden } from '../../components/Forbidden';
import { KindBadge, TechniqueBadge, TestStatusBadge } from './Badges';
import { DefinitionTab } from './DefinitionTab';
import { useTestWriteKinds } from './permissions';
import { TestHistoryPanel, TestVersionsPanel } from './TestVersionsPanel';
import { TestLinksTab } from './TestLinksTab';
import { TestDefectsPanel, TestExecutionsPanel } from '../campaigns/RequirementRunsPanels';

/** §13.2 fiche test : définition selon la nature, exigences liées, exécutions (lot 5), versions, historique. */
export function TestCaseDetailView({ project, testKey }: { project: string; testKey: string }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data: test, error, isLoading } = useTestCase(project, testKey);
  const writable = useTestWriteKinds(project);
  const remove = useDeleteTest(project);
  const [deleting, deleteModal] = useDisclosure(false);

  if (isLoading) return <Loader />;
  if (error instanceof ApiError && error.status === 403) return <Forbidden />;
  if (!test) return <Alert color="gray">{t('test.notFound')}</Alert>;
  const canWrite = writable.includes(test.kind) && test.status !== 'OBSOLETE';

  const onDelete = () =>
    remove.mutate(test.key, {
      onSuccess: () => {
        notifications.show({ message: t('test.deleted', { key: test.key }) });
        deleteModal.close();
        navigate(`/p/${project}/tests`);
      },
      onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
    });

  return (
    <Stack data-testid="test-detail">
      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Stack gap={4}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace" data-testid="test-key">
              {test.key}
            </Badge>
            <KindBadge kind={test.kind} />
            <TechniqueBadge technique={test.automation?.technique} />
            <Badge variant="default" data-testid="test-version">
              {t('test.version', { number: test.currentVersion })}
            </Badge>
          </Group>
          <Title order={3} data-testid="test-title">
            {test.title}
          </Title>
          {test.calledBy.length > 0 && (
            <Group gap={4} data-testid="test-called-by">
              <Text size="xs" c="dimmed">
                {t('test.calledBy')} :
              </Text>
              {test.calledBy.map((key) => (
                <Anchor key={key} component={Link} to={`/p/${project}/tests/${key}`} size="xs" ff="monospace">
                  {key}
                </Anchor>
              ))}
            </Group>
          )}
        </Stack>
        <Group wrap="nowrap">
          <TestStatusMenu project={project} test={test} canWrite={writable.includes(test.kind)} />
          {canWrite && (
            <Menu position="bottom-end">
              <Menu.Target>
                <Button variant="default" leftSection={<IconDots size={16} />}>
                  {t('requirement.actions')}
                </Button>
              </Menu.Target>
              <Menu.Dropdown>
                <Menu.Item color="red" leftSection={<IconTrash size={14} />} onClick={deleteModal.open} data-testid="test-delete">
                  {t('test.delete')}
                </Menu.Item>
              </Menu.Dropdown>
            </Menu>
          )}
        </Group>
      </Group>
      {!canWrite && (
        <Alert color="gray" data-testid="test-read-only">
          {t('test.readOnly')}
        </Alert>
      )}

      <Tabs defaultValue="definition" keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="definition">{t('test.tabs.definition')}</Tabs.Tab>
          <Tabs.Tab value="requirements">
            {t('test.tabs.requirements')} ({test.requirements.length})
          </Tabs.Tab>
          <Tabs.Tab value="executions" data-testid="test-tab-executions">
            {t('test.tabs.executions')}
          </Tabs.Tab>
          <Tabs.Tab value="defects" data-testid="test-tab-defects">
            {t('test.tabs.defects')}
          </Tabs.Tab>
          <Tabs.Tab value="versions">{t('test.tabs.versions')}</Tabs.Tab>
          <Tabs.Tab value="history">{t('test.tabs.history')}</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="definition" pt="md">
          <DefinitionTab key={`${test.key}-${test.version}`} project={project} test={test} canWrite={canWrite} />
        </Tabs.Panel>
        <Tabs.Panel value="requirements" pt="md">
          <TestLinksTab project={project} test={test} canWrite={canWrite} />
        </Tabs.Panel>
        <Tabs.Panel value="executions" pt="md">
          <TestExecutionsPanel project={project} testKey={test.key} />
        </Tabs.Panel>
        <Tabs.Panel value="defects" pt="md">
          <TestDefectsPanel project={project} testKey={test.key} />
        </Tabs.Panel>
        <Tabs.Panel value="versions" pt="md">
          <TestVersionsPanel project={project} testKey={test.key} />
        </Tabs.Panel>
        <Tabs.Panel value="history" pt="md">
          <TestHistoryPanel project={project} testKey={test.key} />
        </Tabs.Panel>
      </Tabs>

      <Modal opened={deleting} onClose={deleteModal.close} title={t('test.delete')}>
        <Stack>
          <Text>{t('test.deleteConfirm', { key: test.key })}</Text>
          <Group justify="flex-end">
            <Button variant="default" onClick={deleteModal.close}>
              {t('test.cancel')}
            </Button>
            <Button color="red" onClick={onDelete} loading={remove.isPending} data-testid="test-delete-confirm">
              {t('test.delete')}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Stack>
  );
}

/** §3.2 statut d'un test ; READY exige un test exécutable (refus explicite de l'API sinon). */
function TestStatusMenu({ project, test, canWrite }: { project: string; test: TestCaseDetail; canWrite: boolean }) {
  const { t } = useTranslation();
  const change = useChangeTestStatus(project);
  if (!canWrite || test.allowedTransitions.length === 0) return <TestStatusBadge status={test.status} />;
  return (
    <Menu position="bottom-end">
      <Menu.Target>
        <Button variant="default" rightSection={<IconChevronDown size={14} />} data-testid="test-status-menu" aria-label={t('test.changeStatus')}>
          <TestStatusBadge status={test.status} />
        </Button>
      </Menu.Target>
      <Menu.Dropdown>
        {test.allowedTransitions.map((status) => (
          <Menu.Item
            key={status}
            data-testid={`test-status-option-${status}`}
            onClick={() =>
              change.mutate(
                { key: test.key, status },
                {
                  onSuccess: () => notifications.show({ color: 'green', message: t('test.statusChanged', { key: test.key, status: t(`testStatus.${status}`) }) }),
                  onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
                },
              )
            }
          >
            {t(`testStatus.${status}`)}
          </Menu.Item>
        ))}
      </Menu.Dropdown>
    </Menu>
  );
}
