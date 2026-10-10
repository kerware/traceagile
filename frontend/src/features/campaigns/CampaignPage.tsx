import { ActionIcon, Alert, Anchor, Badge, Button, Card, Group, Loader, MultiSelect, Select, SimpleGrid, Stack, Table, Text, TextInput, Title, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconArrowDown, IconArrowUp, IconCheck, IconCopy, IconFolderShare, IconPlayerPlay, IconPlayerStop, IconSortDescending, IconTrash, IconX } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import {
  useAssign,
  useCampaign,
  useCampaignAction,
  useCampaignFolders,
  useMoveCampaign,
  useCampaigns,
  useRemoveItem,
  useReorderItems,
  useSelectTests,
  useSortByRisk,
  useStartExecution,
  useTesters,
  type CampaignDetail,
  type CampaignItem,
  type ExecutionStatus,
  type Strategy,
} from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { PromptModal } from '../../components/Dialogs';
import { useSprints } from '../../api/planning';
import { useRequirementTree } from '../../api/requirements';
import { useTestList } from '../../api/testcases';
import { flatten } from '../requirements/model';
import { KindBadge } from '../tests/Badges';
import { CampaignStatusBadge, ExecutionStatusBadge, ProgressBar } from './CampaignBadges';
import { CopyCampaignModal } from './CopyCampaignModal';
import { ItemDataSetCell } from './ItemDataSetCell';
import { itemSuffix, minutes, RESULT_STATUSES, STRATEGIES } from './model';
import { useCanExecute, useCanManageCampaigns } from './permissions';

/**
 * §13.2 /p/:key/campaigns/:ck — sélection des tests (F-CMP-02), ordre par risque (F-CMP-03),
 * affectation (F-CMP-04), charge (F-CMP-05), avancement par statut, exécution (F-EXE-01).
 */
export function CampaignPage() {
  const { t } = useTranslation();
  const { key: project, ck } = useParams() as { key: string; ck: string };
  const { data, isLoading, error } = useCampaign(project, ck);
  const canManage = useCanManageCampaigns(project);
  const action = useCampaignAction(project, ck);
  const [copying, setCopying] = useState(false);
  const [filing, setFiling] = useState(false);
  const { data: folders } = useCampaignFolders(project);
  const moveCampaign = useMoveCampaign(project);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  const c = data.campaign;
  const open = c.status === 'PLANNED' || c.status === 'IN_PROGRESS';

  return (
    <Stack data-testid="campaign-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={2}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace">
              {c.key}
            </Badge>
            <Title order={2}>{c.name}</Title>
            <CampaignStatusBadge status={c.status} />
          </Group>
          {c.folder && (
            <Anchor component={Link} to={`/p/${project}/campaigns`} size="xs" c="dimmed" data-testid="campaign-folder-path">
              {c.folder.split('/').join(' › ')}
            </Anchor>
          )}
          <Text size="sm" c="dimmed">
            {t(`campaignScope.${c.scopeType}`)}
            {c.sprintKey ? ` ${c.sprintKey}` : c.releaseKey ? ` ${c.releaseKey}` : ''} · {t('campaigns.environment')} : {c.environment ?? '—'} ·{' '}
            {t('campaigns.build')} : {c.buildVersion ?? '—'}
            {c.plannedStart ? ` · ${c.plannedStart} → ${c.plannedEnd ?? ''}` : ''}
          </Text>
        </Stack>
        {canManage && (
          <Group>
            <Button leftSection={<IconFolderShare size={16} />} variant="subtle" onClick={() => setFiling(true)} data-testid="campaign-file">
              {t('campaignFolders.file')}
            </Button>
            <Button leftSection={<IconCopy size={16} />} variant="default" onClick={() => setCopying(true)} data-testid="campaign-copy">
              {t('copy.action')}
            </Button>
            {open && c.status === 'PLANNED' && (
              <Button leftSection={<IconPlayerPlay size={16} />} variant="light" onClick={() => action.mutate('start', { onError: fail })} data-testid="campaign-start">
                {t('campaigns.start')}
              </Button>
            )}
            {open && (
              <>
                <Button leftSection={<IconCheck size={16} />} onClick={() => action.mutate('complete', { onError: fail })} data-testid="campaign-complete">
                  {t('campaigns.complete')}
                </Button>
                <Button leftSection={<IconPlayerStop size={16} />} color="red" variant="subtle" onClick={() => action.mutate('abort', { onError: fail })} data-testid="campaign-abort">
                  {t('campaigns.abort')}
                </Button>
              </>
            )}
          </Group>
        )}
      </Group>
      <ProgressBar progress={c.progress} />
      {canManage && open && <SelectionPanel project={project} detail={data} />}
      <ItemsTable project={project} detail={data} editable={canManage && open} />
      <Workload detail={data} />
      {canManage && <CopyCampaignModal project={project} detail={data} opened={copying} onClose={() => setCopying(false)} />}
      <PromptModal
        opened={filing}
        title={t('campaignFolders.fileTitle', { key: c.key })}
        label={t('tree.folderPath')}
        description={t('campaignFolders.fileHint')}
        initialValue={c.folder ?? ''}
        suggestions={folders ?? []}
        submitLabel={t('tree.apply')}
        onClose={() => setFiling(false)}
        onSubmit={async (folder) => {
          await moveCampaign.mutateAsync({ key: c.key, folder: folder.trim() || null });
        }}
      />
    </Stack>
  );
}

/** F-CMP-02 sélection cumulable des tests. */
function SelectionPanel({ project, detail }: { project: string; detail: CampaignDetail }) {
  const { t } = useTranslation();
  const select = useSelectTests(project, detail.campaign.key);
  const { data: sprints } = useSprints(project);
  const { data: campaigns } = useCampaigns(project);
  const { data: tree } = useRequirementTree(project);
  const [search, setSearch] = useState('');
  const { data: tests } = useTestList(project, { q: search || undefined }, 0, 'key,asc');
  const [strategy, setStrategy] = useState<Strategy>(detail.campaign.scopeType === 'REGRESSION' ? 'TAG' : 'SPRINT_REQUIREMENTS');
  const [sprintKey, setSprintKey] = useState<string | null>(null);
  const [tag, setTag] = useState('');
  const [testKeys, setTestKeys] = useState<string[]>([]);
  const [requirementKeys, setRequirementKeys] = useState<string[]>([]);
  const [campaignKey, setCampaignKey] = useState<string | null>(null);
  const [statuses, setStatuses] = useState<string[]>(['FAILED', 'ERROR']);
  const [result, setResult] = useState<{ added: string[]; skipped: { testKey: string; reason: string }[] } | null>(null);

  const submit = () =>
    select.mutate(
      {
        strategy,
        sprintKey: strategy === 'SPRINT_REQUIREMENTS' ? sprintKey ?? undefined : undefined,
        tag: strategy === 'TAG' ? tag : undefined,
        testKeys: strategy === 'MANUAL' ? testKeys : undefined,
        requirementKeys: strategy === 'IMPACT' ? requirementKeys : undefined,
        campaignKey: strategy === 'FROM_CAMPAIGN' ? campaignKey ?? undefined : undefined,
        statuses: strategy === 'FROM_CAMPAIGN' ? (statuses as ExecutionStatus[]) : undefined,
      },
      {
        onSuccess: (r) => {
          setResult({ added: r.added, skipped: r.skipped });
          setTestKeys([]);
        },
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );

  return (
    <Card withBorder data-testid="selection-panel">
      <Title order={5} mb="xs">
        {t('campaigns.selection')}
      </Title>
      <Group align="flex-end">
        <Select
          label={t('campaigns.strategy')}
          data={STRATEGIES.map((s) => ({ value: s, label: t(`strategy.${s}`) }))}
          value={strategy}
          onChange={(s) => s && setStrategy(s as Strategy)}
          allowDeselect={false}
          w={300}
          data-testid="selection-strategy"
        />
        {strategy === 'SPRINT_REQUIREMENTS' && (
          <Select label={t('planning.sprint')} placeholder={t('campaigns.campaignSprint')} data={(sprints ?? []).map((s) => ({ value: s.key, label: `${s.key} — ${s.name}` }))}
            value={sprintKey} onChange={setSprintKey} clearable w={260} data-testid="selection-sprint" />
        )}
        {strategy === 'TAG' && <TextInput label={t('campaigns.tag')} placeholder="smoke, regression" value={tag} onChange={(e) => setTag(e.currentTarget.value)} data-testid="selection-tag" />}
        {strategy === 'MANUAL' && (
          <MultiSelect
            label={t('campaigns.tests')}
            data={(tests?.content ?? []).map((test) => ({ value: test.key, label: `${test.key} — ${test.title}` }))}
            value={testKeys}
            onChange={setTestKeys}
            searchable
            searchValue={search}
            onSearchChange={setSearch}
            filter={({ options }) => options}
            w={420}
            data-testid="selection-tests"
          />
        )}
        {strategy === 'IMPACT' && (
          <MultiSelect label={t('campaigns.requirements')} placeholder={t('campaigns.impactHint')} data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
            value={requirementKeys} onChange={setRequirementKeys} searchable w={420} data-testid="selection-requirements" />
        )}
        {strategy === 'FROM_CAMPAIGN' && (
          <>
            <Select label={t('campaigns.previousCampaign')} data={(campaigns ?? []).filter((c) => c.key !== detail.campaign.key).map((c) => ({ value: c.key, label: `${c.key} — ${c.name}` }))}
              value={campaignKey} onChange={setCampaignKey} w={300} data-testid="selection-campaign" />
            <MultiSelect label={t('copy.statuses')} data={RESULT_STATUSES.map((s) => ({ value: s, label: t(`executionStatus.${s}`) }))}
              value={statuses} onChange={setStatuses} w={320} data-testid="selection-statuses" />
          </>
        )}
        <Button onClick={submit} loading={select.isPending} data-testid="selection-submit">
          {t('campaigns.add')}
        </Button>
      </Group>
      <Text size="xs" c="dimmed" mt={4}>
        {t(`strategyHint.${strategy}`)}
      </Text>
      {result && (
        <Alert mt="sm" color={result.added.length ? 'green' : 'gray'} withCloseButton onClose={() => setResult(null)} data-testid="selection-result">
          {t('campaigns.selected', { count: result.added.length })}
          {result.skipped.length > 0 &&
            ` · ${t('campaigns.skipped', { list: result.skipped.map((s) => `${s.testKey} (${t(`skipReason.${s.reason.startsWith('NOT_READY') ? 'NOT_READY' : s.reason}`)})`).join(', ') })}`}
        </Alert>
      )}
    </Card>
  );
}

function ItemsTable({ project, detail, editable }: { project: string; detail: CampaignDetail; editable: boolean }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const canExecute = useCanExecute(project);
  const { data: testers } = useTesters(project);
  const assign = useAssign(project);
  const remove = useRemoveItem(project);
  const reorder = useReorderItems(project, detail.campaign.key);
  const sortByRisk = useSortByRisk(project, detail.campaign.key);
  const start = useStartExecution(project);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const items = detail.items;
  const open = detail.campaign.status === 'PLANNED' || detail.campaign.status === 'IN_PROGRESS';

  const move = (index: number, delta: number) => {
    const ids = items.map((i) => i.id);
    [ids[index], ids[index + delta]] = [ids[index + delta]!, ids[index]!];
    reorder.mutate(ids, { onError: fail });
  };
  const execute = (item: CampaignItem) => {
    if (item.lastStatus === 'RUNNING' && item.latestExecutionId) {
      navigate(`/p/${project}/executions/${item.latestExecutionId}`);
      return;
    }
    start.mutate({ itemId: item.id }, { onSuccess: (e) => navigate(`/p/${project}/executions/${e.id}`), onError: fail });
  };

  if (items.length === 0) return <Text c="dimmed">{t('campaigns.noItems')}</Text>;

  return (
    <Stack gap="xs">
      <Group justify="space-between">
        <Title order={5}>{t('campaigns.items', { count: items.length })}</Title>
        {editable && (
          <Button size="xs" variant="light" leftSection={<IconSortDescending size={14} />} onClick={() => sortByRisk.mutate(undefined, { onError: fail })} data-testid="sort-by-risk">
            {t('campaigns.sortByRisk')}
          </Button>
        )}
      </Group>
      <Table striped data-testid="campaign-items">
        <Table.Thead>
          <Table.Tr>
            <Table.Th w={70}>#</Table.Th>
            <Table.Th>{t('campaigns.test')}</Table.Th>
            <Table.Th>
              <Tooltip label={t('campaigns.riskHint')}>
                <span>{t('campaigns.risk')}</span>
              </Tooltip>
            </Table.Th>
            <Table.Th>{t('campaigns.dataSet')}</Table.Th>
            <Table.Th>{t('campaigns.assignee')}</Table.Th>
            <Table.Th>{t('campaigns.lastResult')}</Table.Th>
            <Table.Th />
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {items.map((item, index) => (
            <Table.Tr key={item.id} data-testid={`item-${item.test.key}${itemSuffix(item)}`}>
              <Table.Td>
                <Group gap={2} wrap="nowrap">
                  <Text size="sm" w={22}>
                    {item.position}
                  </Text>
                  {editable && (
                    <>
                      <ActionIcon size="sm" variant="subtle" disabled={index === 0} onClick={() => move(index, -1)} aria-label={t('steps.up')} data-testid={`item-up-${item.test.key}${itemSuffix(item)}`}>
                        <IconArrowUp size={14} />
                      </ActionIcon>
                      <ActionIcon size="sm" variant="subtle" disabled={index === items.length - 1} onClick={() => move(index, 1)} aria-label={t('steps.down')}>
                        <IconArrowDown size={14} />
                      </ActionIcon>
                    </>
                  )}
                </Group>
              </Table.Td>
              <Table.Td>
                <Group gap={6} wrap="nowrap">
                  <Anchor component={Link} to={`/p/${project}/tests/${item.test.key}`} ff="monospace" fw={600} size="sm">
                    {item.test.key}
                  </Anchor>
                  <KindBadge kind={item.test.kind} />
                  <Text size="sm">{item.test.title}</Text>
                  {item.testCaseVersion !== item.test.currentVersion && (
                    <Tooltip label={t('campaigns.versionChanged', { selected: item.testCaseVersion, current: item.test.currentVersion })}>
                      <Badge size="xs" color="orange" variant="light">
                        v{item.testCaseVersion}→v{item.test.currentVersion}
                      </Badge>
                    </Tooltip>
                  )}
                </Group>
              </Table.Td>
              <Table.Td>
                <Badge variant="default">{item.riskScore}</Badge>
              </Table.Td>
              <Table.Td>
                <ItemDataSetCell project={project} campaignKey={detail.campaign.key} item={item} editable={editable} />
              </Table.Td>
              <Table.Td>
                {item.executedByServer ? (
                  <Text size="sm" c="dimmed">
                    {t('campaigns.server')}
                  </Text>
                ) : editable ? (
                  <Select
                    size="xs"
                    w={180}
                    placeholder={t('campaigns.unassigned')}
                    data={(testers ?? []).map((u) => ({ value: u.login, label: u.displayName }))}
                    value={item.assignee?.login ?? null}
                    onChange={(login) => assign.mutate({ id: item.id, assignee: login }, { onError: fail })}
                    clearable
                    data-testid={`assignee-${item.test.key}${itemSuffix(item)}`}
                  />
                ) : (
                  <Text size="sm">{item.assignee?.displayName ?? t('campaigns.unassigned')}</Text>
                )}
              </Table.Td>
              <Table.Td>
                <Group gap={4} wrap="nowrap">
                  {item.latestExecutionId ? (
                    <Anchor component={Link} to={`/p/${project}/executions/${item.latestExecutionId}`}>
                      <ExecutionStatusBadge status={item.lastStatus} testId={`last-status-${item.test.key}${itemSuffix(item)}`} />
                    </Anchor>
                  ) : (
                    <ExecutionStatusBadge status={item.lastStatus} testId={`last-status-${item.test.key}${itemSuffix(item)}`} />
                  )}
                  {item.attempts > 1 && (
                    <Text size="xs" c="dimmed">
                      {t('campaigns.attempts', { count: item.attempts })}
                    </Text>
                  )}
                </Group>
              </Table.Td>
              <Table.Td>
                <Group gap={4} justify="flex-end" wrap="nowrap">
                  {canExecute && open && item.test.kind === 'MANUAL' && (
                    <Button size="xs" variant="light" leftSection={<IconPlayerPlay size={14} />} onClick={() => execute(item)} loading={start.isPending}
                      data-testid={`execute-${item.test.key}${itemSuffix(item)}`}>
                      {item.lastStatus === 'RUNNING' ? t('campaigns.resume') : item.attempts > 0 ? t('campaigns.rerun') : t('campaigns.execute')}
                    </Button>
                  )}
                  {editable && item.attempts === 0 && (
                    <ActionIcon variant="subtle" color="red" onClick={() => remove.mutate(item.id, { onError: fail })} aria-label={t('campaigns.remove')}
                      data-testid={`remove-${item.test.key}${itemSuffix(item)}`}>
                      <IconTrash size={16} />
                    </ActionIcon>
                  )}
                </Group>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
    </Stack>
  );
}

/** F-CMP-05 charge par testeur. */
function Workload({ detail }: { detail: CampaignDetail }) {
  const { t } = useTranslation();
  if (detail.workload.length === 0) return null;
  return (
    <Card withBorder data-testid="workload">
      <Title order={5} mb="xs">
        {t('campaigns.workload')}
      </Title>
      <SimpleGrid cols={{ base: 1, sm: 3, lg: 4 }}>
        {detail.workload.map((w) => (
          <Card key={w.assignee?.login ?? 'none'} withBorder p="xs" data-testid={`workload-${w.assignee?.login ?? 'unassigned'}`}>
            <Group gap={4}>
              {!w.assignee && <IconX size={14} />}
              <Text fw={600} size="sm">
                {w.assignee?.displayName ?? t('campaigns.unassigned')}
              </Text>
            </Group>
            <Text size="xl" fw={700}>
              {minutes(w.manualMinutes + w.exploratoryMinutes)}
            </Text>
            <Text size="xs" c="dimmed">
              {t('campaigns.workloadDetail', { tests: w.tests, manual: minutes(w.manualMinutes), exploratory: minutes(w.exploratoryMinutes) })}
              {w.unestimated > 0 && ` · ${t('campaigns.unestimated', { count: w.unestimated })}`}
            </Text>
          </Card>
        ))}
      </SimpleGrid>
    </Card>
  );
}
