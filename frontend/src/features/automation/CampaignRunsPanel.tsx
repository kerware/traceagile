import { Anchor, Button, Card, Group, Stack, Table, Text, Title } from '@mantine/core';
import { IconFileImport, IconRocket } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useCampaignRuns, useLiveCampaignRuns } from '../../api/automation';
import type { CampaignDetail } from '../../api/campaigns';
import { ImportReportModal } from './ImportReportModal';
import { LaunchRunModal } from './LaunchRunModal';
import { useCanImportResults, useCanLaunchRuns } from './model';
import { RunProgress, RunStatusBadge } from './RunBadges';

/**
 * §13.2 campagne : runs automatisés (F-EXE-06, temps réel F-EXE-07), « Lancer sur… » et import de
 * rapports (F-EXE-10). Affiché quand la campagne a des tests automatisés ou des runs.
 */
export function CampaignRunsPanel({ project, detail }: { project: string; detail: CampaignDetail }) {
  const { t } = useTranslation();
  const campaignKey = detail.campaign.key;
  const { data: runs } = useCampaignRuns(project, campaignKey);
  useLiveCampaignRuns(project, campaignKey);
  const canLaunch = useCanLaunchRuns(project);
  const canImport = useCanImportResults(project);
  const [launching, setLaunching] = useState(false);
  const [importing, setImporting] = useState(false);
  const open = detail.campaign.status === 'PLANNED' || detail.campaign.status === 'IN_PROGRESS';
  const automated = detail.items.some((i) => i.test.kind === 'AUTOMATED');
  if (!automated && (runs ?? []).length === 0 && !canImport) return null;

  return (
    <Card withBorder data-testid="campaign-runs">
      <Group justify="space-between" mb="xs">
        <Title order={5}>{t('runs.panel', { count: runs?.length ?? 0 })}</Title>
        {open && (
          <Group gap="xs">
            {canImport && (
              <Button size="xs" variant="default" leftSection={<IconFileImport size={14} />} onClick={() => setImporting(true)} data-testid="import-open">
                {t('import.action')}
              </Button>
            )}
            {canLaunch && automated && (
              <Button size="xs" leftSection={<IconRocket size={14} />} onClick={() => setLaunching(true)} data-testid="launch-open">
                {t('runs.launchOn')}
              </Button>
            )}
          </Group>
        )}
      </Group>
      {(runs ?? []).length === 0 ? (
        <Text size="sm" c="dimmed">
          {t('runs.none')}
        </Text>
      ) : (
        <Table>
          <Table.Tbody>
            {(runs ?? []).slice(0, 8).map((run) => (
              <Table.Tr key={run.key} data-testid={`campaign-run-${run.key}`}>
                <Table.Td w={90}>
                  <Anchor component={Link} to={`/p/${project}/runs/${run.key}`} ff="monospace" fw={600} size="sm">
                    {run.key}
                  </Anchor>
                </Table.Td>
                <Table.Td w={130}>
                  <RunStatusBadge status={run.status} />
                </Table.Td>
                <Table.Td>
                  <Stack gap={2}>
                    <RunProgress counts={run.counts} />
                  </Stack>
                </Table.Td>
                <Table.Td w={220}>
                  <Text size="xs" c="dimmed">
                    {run.serverName} · {new Date(run.requestedAt).toLocaleString()}
                  </Text>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}
      <LaunchRunModal project={project} detail={detail} opened={launching} onClose={() => setLaunching(false)} />
      <ImportReportModal project={project} campaignKey={campaignKey} opened={importing} onClose={() => setImporting(false)} />
    </Card>
  );
}
