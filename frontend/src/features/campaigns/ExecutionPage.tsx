import { Alert, Anchor, Badge, Button, Card, Group, Loader, Paper, Select, SimpleGrid, Stack, Text, Textarea, Title, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconArrowLeft, IconArrowRight, IconBug, IconLock, IconRefresh } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useExecution, useOverrideExecution, useRecordStep, useStartExecution, type ExecutionDetail, type ExecutionStatus } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { DefectStatusBadge, ExecutionStatusBadge, SeverityBadge } from './CampaignBadges';
import { DefectFromExecutionModal } from './DefectFromExecutionModal';
import { currentStepIndex, duration, EXECUTION_COLORS, FINAL_STATUSES, STEP_STATUSES } from './model';
import { useCanExecute } from './permissions';

/**
 * §13.2 /p/:key/executions/:id — exécution manuelle : pas un par un avec statut et résultat obtenu
 * (F-EXE-01), statut déduit ou forcé avec commentaire (F-EXE-02), anomalie depuis un pas en échec
 * (F-EXE-03), tentatives (F-EXE-04).
 */
export function ExecutionPage() {
  const { t } = useTranslation();
  const { key: project, id } = useParams() as { key: string; id: string };
  const { data, isLoading, error } = useExecution(project, id);

  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  return <ExecutionView key={data.id} project={project} execution={data} />;
}

function ExecutionView({ project, execution }: { project: string; execution: ExecutionDetail }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const canExecute = useCanExecute(project);
  const editable = execution.editable && canExecute;
  const record = useRecordStep(project, execution.id);
  const restart = useStartExecution(project);
  const [index, setIndex] = useState(() => currentStepIndex(execution.steps));
  const [actual, setActual] = useState('');
  const [defectOpen, setDefectOpen] = useState(false);
  const step = execution.steps[index];
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  useEffect(() => setActual(step?.actualResult ?? ''), [step?.position, step?.actualResult]);

  const decide = (status: ExecutionStatus) => {
    if (!step) return;
    record.mutate(
      { position: step.position, status, actualResult: actual || undefined },
      { onSuccess: () => status !== 'FAILED' && index < execution.steps.length - 1 && setIndex(index + 1), onError: fail },
    );
  };
  const newAttempt = () =>
    restart.mutate(
      { itemId: execution.itemId, dataSetName: execution.dataSetName ?? undefined, row: execution.dataSetRow ?? undefined },
      { onSuccess: (e) => navigate(`/p/${project}/executions/${e.id}`), onError: fail },
    );
  const final = execution.status !== 'RUNNING' && execution.status !== 'NOT_RUN';
  const hasFailure = execution.steps.some((s) => s.status === 'FAILED') || execution.status === 'FAILED';

  return (
    <Stack data-testid="execution-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={2}>
          <Group gap="xs">
            <Anchor component={Link} to={`/p/${project}/tests/${execution.test.key}`} ff="monospace" fw={700}>
              {execution.test.key}
            </Anchor>
            <Title order={3}>{execution.test.title}</Title>
            <ExecutionStatusBadge status={execution.status} testId="execution-status" />
            {execution.statusOverridden && (
              <Badge variant="outline" color="gray" size="sm">
                {t('executions.overridden')}
              </Badge>
            )}
          </Group>
          <Text size="sm" c="dimmed">
            <Anchor component={Link} to={`/p/${project}/campaigns/${execution.campaign.key}`} size="sm">
              {execution.campaign.key} {execution.campaign.name}
            </Anchor>
            {` · ${t('campaigns.environment')} : ${execution.campaign.environment ?? '—'} · ${t('campaigns.build')} : ${execution.campaign.buildVersion ?? '—'}`}
            {` · ${t('executions.version', { version: execution.testCaseVersion })}`}
            {execution.dataSetName && ` · ${t('executions.dataRow', { name: execution.dataSetName, row: (execution.dataSetRow ?? 0) + 1 })}`}
          </Text>
        </Stack>
        <Group>
          {execution.attempts.map((a) => (
            <Anchor key={a.id} component={Link} to={`/p/${project}/executions/${a.id}`} data-testid={`attempt-${a.attempt}`}>
              <Badge variant={a.id === execution.id ? 'filled' : 'light'} color={EXECUTION_COLORS[a.status]}>
                {t('executions.attempt', { n: a.attempt })}
              </Badge>
            </Anchor>
          ))}
          {canExecute && final && execution.editable && (
            <Button size="xs" variant="light" leftSection={<IconRefresh size={14} />} onClick={newAttempt} loading={restart.isPending} data-testid="execution-rerun">
              {t('executions.newAttempt')}
            </Button>
          )}
        </Group>
      </Group>

      {!execution.editable && (
        <Alert color="gray" icon={<IconLock size={16} />} data-testid="execution-readonly">
          {t('executions.readOnly')}
        </Alert>
      )}

      {execution.steps.length === 0 ? (
        <Alert color="gray">{execution.comment ?? t('executions.noSteps')}</Alert>
      ) : (
        <SimpleGrid cols={{ base: 1, md: 3 }} spacing="md">
          <Stack gap={4} data-testid="step-list">
            {execution.steps.map((s, i) => (
              <UnstyledButton key={s.position} onClick={() => setIndex(i)} data-testid={`step-nav-${s.position}`}>
                <Paper withBorder p={6} style={{ borderColor: i === index ? 'var(--mantine-color-blue-5)' : undefined, borderWidth: i === index ? 2 : 1 }}>
                  <Group gap={6} wrap="nowrap">
                    <Badge variant="default" size="sm">
                      {s.position}
                    </Badge>
                    <Stack gap={0} flex={1} miw={0}>
                      {s.calledFrom && (
                        <Text size="xs" c="grape" truncate>
                          ↳ {s.calledFrom}
                        </Text>
                      )}
                      <Text size="sm" truncate>
                        {s.action}
                      </Text>
                    </Stack>
                    <ExecutionStatusBadge status={s.status} testId={`step-status-badge-${s.position}`} />
                  </Group>
                </Paper>
              </UnstyledButton>
            ))}
          </Stack>
          {step && (
            <Card withBorder style={{ gridColumn: 'span 2' }} data-testid="current-step">
              <Group justify="space-between" mb="xs">
                <Text fw={700}>{t('executions.stepOf', { n: step.position, total: execution.steps.length })}</Text>
                <ExecutionStatusBadge status={step.status} />
              </Group>
              <Stack gap="xs">
                {step.calledFrom && (
                  <Badge color="grape" variant="light" data-testid="step-called-from">
                    ↳ {step.calledFrom}
                  </Badge>
                )}
                <Field label={t('steps.action')} value={step.action} testId="step-action" />
                <Field label={t('steps.expected')} value={step.expectedResult} testId="step-expected" />
                {step.testData && <Field label={t('steps.data')} value={step.testData} />}
                <Textarea label={t('executions.actual')} autosize minRows={2} value={actual} onChange={(e) => setActual(e.currentTarget.value)}
                  disabled={!editable} data-testid="step-actual" />
                {editable && (
                  <Group>
                    {STEP_STATUSES.map((status) => (
                      <Button key={status} color={EXECUTION_COLORS[status]} variant={step.status === status ? 'filled' : 'light'} onClick={() => decide(status)}
                        loading={record.isPending && record.variables?.status === status} data-testid={`step-${status}`}>
                        {t(`executionStatus.${status}`)}
                      </Button>
                    ))}
                  </Group>
                )}
                <Group justify="space-between">
                  <Button variant="subtle" leftSection={<IconArrowLeft size={14} />} disabled={index === 0} onClick={() => setIndex(index - 1)}>
                    {t('executions.previous')}
                  </Button>
                  {step.status === 'FAILED' && canExecute && (
                    <Button color="red" variant="light" leftSection={<IconBug size={16} />} onClick={() => setDefectOpen(true)} data-testid="create-defect">
                      {t('defects.createFromExecution')}
                    </Button>
                  )}
                  <Button variant="subtle" rightSection={<IconArrowRight size={14} />} disabled={index === execution.steps.length - 1} onClick={() => setIndex(index + 1)}>
                    {t('executions.next')}
                  </Button>
                </Group>
              </Stack>
            </Card>
          )}
        </SimpleGrid>
      )}

      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <OverrideCard project={project} execution={execution} editable={editable} />
        <Card withBorder data-testid="execution-defects">
          <Group justify="space-between" mb="xs">
            <Title order={6}>{t('executions.defects')}</Title>
            {hasFailure && canExecute && execution.steps.length === 0 && (
              <Button size="xs" color="red" variant="light" leftSection={<IconBug size={14} />} onClick={() => setDefectOpen(true)} data-testid="create-defect">
                {t('defects.createFromExecution')}
              </Button>
            )}
          </Group>
          {execution.defects.length === 0 && (
            <Text size="sm" c="dimmed">
              {t('executions.noDefect')}
            </Text>
          )}
          {execution.defects.map((d) => (
            <Group key={d.key} gap={6} data-testid={`linked-defect-${d.key}`}>
              <Anchor component={Link} to={`/p/${project}/defects?selected=${d.key}`} ff="monospace" fw={600} size="sm">
                {d.key}
              </Anchor>
              <SeverityBadge severity={d.severity} />
              <Text size="sm">{d.title}</Text>
              <DefectStatusBadge status={d.status} />
            </Group>
          ))}
          <Text size="xs" c="dimmed" mt="sm">
            {t('executions.timing', { by: execution.executedBy ?? '—', duration: duration(execution.durationMs) })}
          </Text>
        </Card>
      </SimpleGrid>
      <DefectFromExecutionModal project={project} executionId={execution.id} opened={defectOpen} onClose={() => setDefectOpen(false)} />
    </Stack>
  );
}

function Field({ label, value, testId }: { label: string; value?: string | null; testId?: string }) {
  return (
    <div>
      <Text size="xs" c="dimmed">
        {label}
      </Text>
      <Text size="sm" style={{ whiteSpace: 'pre-wrap' }} data-testid={testId}>
        {value || '—'}
      </Text>
    </div>
  );
}

/** F-EXE-02 statut forcé avec commentaire obligatoire. */
function OverrideCard({ project, execution, editable }: { project: string; execution: ExecutionDetail; editable: boolean }) {
  const { t } = useTranslation();
  const override = useOverrideExecution(project, execution.id);
  const [status, setStatus] = useState<string | null>(null);
  const [comment, setComment] = useState('');
  return (
    <Card withBorder data-testid="override">
      <Title order={6} mb="xs">
        {t('executions.globalStatus')}
      </Title>
      <Text size="sm">
        {t('executions.derived')} : <ExecutionStatusBadge status={execution.derivedStatus} testId="derived-status" />
      </Text>
      {execution.comment && (
        <Alert mt="xs" color="gray" icon={<IconAlertTriangle size={14} />} p="xs" data-testid="execution-comment">
          {execution.comment}
        </Alert>
      )}
      {editable && (
        <Stack gap="xs" mt="xs">
          <Select label={t('executions.forceStatus')} data={FINAL_STATUSES.map((s) => ({ value: s, label: t(`executionStatus.${s}`) }))} value={status}
            onChange={setStatus} clearable data-testid="override-status" />
          <Textarea label={t('executions.comment')} description={t('executions.commentHint')} autosize minRows={2} value={comment}
            onChange={(e) => setComment(e.currentTarget.value)} data-testid="override-comment" />
          <Group justify="flex-end">
            <Button size="xs" disabled={!status} loading={override.isPending} data-testid="override-submit"
              onClick={() =>
                override.mutate(
                  { status: status as ExecutionStatus, comment: comment || undefined },
                  {
                    onSuccess: () => {
                      setStatus(null);
                      setComment('');
                    },
                    onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
                  },
                )
              }>
              {t('executions.apply')}
            </Button>
          </Group>
        </Stack>
      )}
    </Card>
  );
}
