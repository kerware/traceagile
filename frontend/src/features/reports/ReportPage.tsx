import { Alert, Anchor, Badge, Button, Card, Group, Loader, Stack, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconGavel, IconLock, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { useDeleteReport, useFreezeReport, useReport, useReportHtml, type ReportDetail } from '../../api/reports';
import { ConfirmModal } from '../../components/Dialogs';
import { useCanOverrideVerdict, useCanWriteReports } from './model';
import { FrozenBadge, VerdictBadge } from './ReportBadges';
import { VerdictModal } from './ReportModals';
import { ExportMenu } from './ReportsPage';

/** §13.2 /p/:key/reports/:rk — lien permanent d'un rapport (F-RPT-04) : affichage web, exports, gel, verdict du PO (§9.2). */
export function ReportPage() {
  const { t } = useTranslation();
  const { key: project, rk } = useParams() as { key: string; rk: string };
  const { data, isLoading, error } = useReport(project, rk);
  if (isLoading) return <Loader />;
  if (error || !data) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  return <ReportView project={project} detail={data} />;
}

function ReportView({ project, detail }: { project: string; detail: ReportDetail }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const report = detail.report;
  const canWrite = useCanWriteReports(project);
  const canVerdict = useCanOverrideVerdict(project);
  const freeze = useFreezeReport(project, report.key);
  const remove = useDeleteReport(project);
  const [verdictOpen, setVerdictOpen] = useState(false);
  const [confirm, setConfirm] = useState<'freeze' | 'delete' | null>(null);
  const version = `${report.verdict ?? ''}-${report.frozen}-${detail.verdictAt ?? ''}`;
  const html = useReportHtml(project, report.key, version);

  return (
    <Stack data-testid="report-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={4}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace">
              {report.key}
            </Badge>
            <Title order={2} data-testid="report-title">
              {report.title}
            </Title>
            <VerdictBadge verdict={report.verdict} testId="report-verdict" />
            {report.frozen && <FrozenBadge testId="report-frozen" />}
          </Group>
          <Text size="sm" c="dimmed">
            <Anchor component={Link} to={`/p/${project}/reports`} size="sm">
              {t('reports.pageTitle')}
            </Anchor>
            {` · ${report.definitionName} · ${report.scopeLabel} · ${t('reports.generatedBy', {
              at: new Date(report.createdAt).toLocaleString(),
              by: report.createdBy ?? '—',
            })}`}
            {report.frozen && report.frozenAt ? ` · ${t('reports.frozenOn', { at: new Date(report.frozenAt).toLocaleString(), by: report.frozenBy ?? '—' })}` : ''}
          </Text>
        </Stack>
        <Group>
          <ExportMenu project={project} reportKey={report.key} label />
          {canVerdict && report.computedVerdict && (
            <Button variant="light" leftSection={<IconGavel size={16} />} onClick={() => setVerdictOpen(true)} data-testid="report-verdict-edit">
              {t('reports.editVerdict')}
            </Button>
          )}
          {canWrite && !report.frozen && (
            <Button variant="light" color="gray" leftSection={<IconLock size={16} />} onClick={() => setConfirm('freeze')} data-testid="report-freeze">
              {t('reports.freeze')}
            </Button>
          )}
          {canWrite && !report.frozen && (
            <Button variant="subtle" color="red" leftSection={<IconTrash size={16} />} onClick={() => setConfirm('delete')} data-testid="report-delete">
              {t('common.delete')}
            </Button>
          )}
        </Group>
      </Group>

      {detail.verdictOverride && (
        <Alert color="orange" title={t('reports.verdictOverridden', { by: detail.verdictBy ?? '—' })} data-testid="report-verdict-comment">
          {t('reports.computedWas', { verdict: report.computedVerdict ? t(`verdict.${report.computedVerdict}`) : '—' })} — {detail.verdictComment}
        </Alert>
      )}

      <Card withBorder p={0} style={{ overflow: 'hidden' }}>
        {html.isLoading && <Loader m="md" />}
        {html.error && <Alert color="red">{errorMessage(html.error, t('errors.generic'))}</Alert>}
        {html.data && (
          <iframe title={report.title} srcDoc={html.data} sandbox="" style={{ width: '100%', height: '75vh', border: 0, background: 'white' }}
            data-testid="report-frame" />
        )}
      </Card>

      <VerdictModal project={project} reportKey={report.key} opened={verdictOpen} onClose={() => setVerdictOpen(false)} current={report.verdict}
        computed={report.computedVerdict} />
      <ConfirmModal opened={confirm === 'freeze'} title={t('reports.freezeTitle')} message={t('reports.freezeMessage')} confirmLabel={t('reports.freeze')}
        onConfirm={() => freeze.mutateAsync()} onClose={() => setConfirm(null)} />
      <ConfirmModal opened={confirm === 'delete'} title={t('reports.deleteTitle')} message={t('reports.deleteMessage', { key: report.key })}
        confirmLabel={t('common.delete')}
        onConfirm={() => remove.mutateAsync(report.key).then(() => {
          notifications.show({ color: 'green', message: t('reports.deleted', { key: report.key }) });
          navigate(`/p/${project}/reports`);
        })}
        onClose={() => setConfirm(null)} />
    </Stack>
  );
}
