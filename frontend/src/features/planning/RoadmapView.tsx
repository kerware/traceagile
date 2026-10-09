import { ActionIcon, Badge, Box, Button, Card, Group, Loader, Menu, Progress, Stack, Text, Title, Tooltip, UnstyledButton } from '@mantine/core';
import { IconCalendarPlus, IconDots, IconFileAnalytics, IconLock, IconPencil, IconPlus, IconWand } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCloseRelease, useReleases, useSprints, type ReleaseResponse, type SprintSummary } from '../../api/planning';
import { ConfirmModal } from '../../components/Dialogs';
import { loadColor, looseSprints, PLANNING_STATUS_COLORS, shortDate, span } from './model';
import { GenerateSprintsModal, ReleaseModal, ReleaseReportModal, SprintModal } from './PlanningModals';
import { useCanPlan } from './permissions';

/**
 * F-PLN-02 feuille de route : frise chronologique de chaque release et de ses sprints, avec pour
 * chaque sprint sa charge et son taux de validation ; création, génération et clôture (F-PLN-01, F-PLN-03).
 */
export function RoadmapView({ project, onOpenSprint }: { project: string; onOpenSprint: (key: string) => void }) {
  const { t } = useTranslation();
  const { data: releases, isLoading } = useReleases(project);
  const { data: sprints } = useSprints(project);
  const canPlan = useCanPlan(project);
  const closeRelease = useCloseRelease(project);
  const [releaseModal, setReleaseModal] = useState<{ release: ReleaseResponse | null } | null>(null);
  const [generateFor, setGenerateFor] = useState<ReleaseResponse | null>(null);
  const [closing, setClosing] = useState<ReleaseResponse | null>(null);
  const [report, setReport] = useState<ReleaseResponse | null>(null);
  const [sprintModal, setSprintModal] = useState<{ sprint: SprintSummary | null; release: string | null } | null>(null);

  if (isLoading || !releases) return <Loader />;
  const loose = looseSprints(sprints ?? [], releases);

  return (
    <Stack>
      {canPlan && (
        <Group>
          <Button leftSection={<IconPlus size={16} />} onClick={() => setReleaseModal({ release: null })} data-testid="release-new">
            {t('planning.newRelease')}
          </Button>
          <Button variant="default" leftSection={<IconCalendarPlus size={16} />} onClick={() => setSprintModal({ sprint: null, release: null })} data-testid="sprint-new">
            {t('planning.newSprint')}
          </Button>
        </Group>
      )}
      {releases.length === 0 && loose.length === 0 && <Text c="dimmed">{t('planning.empty')}</Text>}
      {releases.map((release) => (
        <Card key={release.key} withBorder data-testid={`release-${release.key}`}>
          <Group justify="space-between" align="flex-start" mb="sm">
            <Stack gap={2}>
              <Group gap="xs">
                <Badge variant="filled" ff="monospace">
                  {release.key}
                </Badge>
                <Title order={4}>{release.name}</Title>
                <Badge color={PLANNING_STATUS_COLORS[release.status]} variant="light" data-testid={`release-status-${release.key}`}>
                  {t(`planningStatus.${release.status}`)}
                </Badge>
              </Group>
              <Text size="sm" c="dimmed">
                {shortDate(release.startDate)} → {shortDate(release.endDate)}
                {release.goal ? ` · ${release.goal}` : ''}
              </Text>
            </Stack>
            <Group gap="xs">
              {release.status === 'CLOSED' && (
                <Button size="xs" variant="light" leftSection={<IconFileAnalytics size={14} />} onClick={() => setReport(release)} data-testid={`release-report-${release.key}`}>
                  {t('planning.report')}
                </Button>
              )}
              {canPlan && release.status !== 'CLOSED' && (
                <>
                  <Button size="xs" variant="light" leftSection={<IconWand size={14} />} onClick={() => setGenerateFor(release)} data-testid={`release-generate-${release.key}`}>
                    {t('planning.generate')}
                  </Button>
                  <Menu position="bottom-end">
                    <Menu.Target>
                      <ActionIcon variant="default" aria-label={t('planning.actions')} data-testid={`release-menu-${release.key}`}>
                        <IconDots size={16} />
                      </ActionIcon>
                    </Menu.Target>
                    <Menu.Dropdown>
                      <Menu.Item leftSection={<IconPencil size={14} />} onClick={() => setReleaseModal({ release })}>
                        {t('planning.edit')}
                      </Menu.Item>
                      <Menu.Item leftSection={<IconCalendarPlus size={14} />} onClick={() => setSprintModal({ sprint: null, release: release.key })}>
                        {t('planning.addSprint')}
                      </Menu.Item>
                      <Menu.Item leftSection={<IconLock size={14} />} color="orange" onClick={() => setClosing(release)} data-testid={`release-close-${release.key}`}>
                        {t('planning.closeRelease')}
                      </Menu.Item>
                    </Menu.Dropdown>
                  </Menu>
                </>
              )}
            </Group>
          </Group>
          {release.sprints.length === 0 ? (
            <Text size="sm" c="dimmed">
              {t('planning.noSprint')}
            </Text>
          ) : (
            <Box pos="relative" h={92} style={{ background: 'var(--mantine-color-gray-light)', borderRadius: 6 }} data-testid={`timeline-${release.key}`}>
              <TodayMarker from={release.startDate} to={release.endDate} />
              {release.sprints.map((sprint) => {
                const { left, width } = span(sprint.startDate, sprint.endDate, release.startDate, release.endDate);
                return (
                  <Box key={sprint.key} pos="absolute" top={6} bottom={6} style={{ left: `calc(${left}% + 2px)`, width: `calc(${width}% - 4px)` }}>
                    <SprintBlock sprint={sprint} onOpen={() => onOpenSprint(sprint.key)} />
                  </Box>
                );
              })}
            </Box>
          )}
        </Card>
      ))}
      {loose.length > 0 && (
        <Card withBorder data-testid="loose-sprints">
          <Title order={5} mb="sm">
            {t('planning.looseSprints')}
          </Title>
          <Group>
            {loose.map((sprint) => (
              <Box key={sprint.key} w={220} h={80}>
                <SprintBlock sprint={sprint} onOpen={() => onOpenSprint(sprint.key)} />
              </Box>
            ))}
          </Group>
        </Card>
      )}

      <ReleaseModal project={project} opened={!!releaseModal} release={releaseModal?.release} onClose={() => setReleaseModal(null)} />
      <GenerateSprintsModal project={project} release={generateFor} onClose={() => setGenerateFor(null)} />
      <SprintModal project={project} opened={!!sprintModal} sprint={sprintModal?.sprint} defaultRelease={sprintModal?.release} releases={releases} onClose={() => setSprintModal(null)} />
      <ReleaseReportModal release={report} onClose={() => setReport(null)} />
      <ConfirmModal
        opened={!!closing}
        title={t('planning.closeRelease')}
        message={closing ? t('planning.closeReleaseConfirm', { key: closing.key, name: closing.name }) : ''}
        confirmLabel={t('planning.closeRelease')}
        onClose={() => setClosing(null)}
        onConfirm={async () => {
          if (closing) {
            const closed = await closeRelease.mutateAsync(closing.key);
            setReport(closed);
          }
        }}
      />
    </Stack>
  );
}

function SprintBlock({ sprint, onOpen }: { sprint: SprintSummary; onOpen: () => void }) {
  const { t } = useTranslation();
  const color = PLANNING_STATUS_COLORS[sprint.status];
  return (
    <Tooltip label={`${sprint.name} · ${shortDate(sprint.startDate)} → ${shortDate(sprint.endDate)}${sprint.goal ? ` · ${sprint.goal}` : ''}`} multiline w={280}>
      <UnstyledButton
        onClick={onOpen}
        w="100%"
        h="100%"
        p={6}
        data-testid={`sprint-block-${sprint.key}`}
        style={{
          borderRadius: 6,
          border: `1px solid var(--mantine-color-${color}-5)`,
          background: `var(--mantine-color-${color}-light)`,
          overflow: 'hidden',
        }}
      >
        <Group gap={4} wrap="nowrap" justify="space-between">
          <Text size="xs" fw={700} ff="monospace">
            {sprint.key}
          </Text>
          <Text size="xs" c={color} fw={600} truncate>
            {t(`planningStatus.${sprint.status}`)}
          </Text>
        </Group>
        <Text size="xs" truncate>
          {sprint.name}
        </Text>
        <Progress value={Math.min(100, sprint.loadPercent ?? 0)} color={loadColor(sprint.loadPercent)} size="xs" mt={2} />
        <Group gap={4} wrap="nowrap" justify="space-between">
          <Text size="xs" c="dimmed">
            {sprint.loadPoints}
            {sprint.capacityPoints != null ? ` / ${sprint.capacityPoints}` : ''} pts
          </Text>
          <Text size="xs" c="dimmed" data-testid={`sprint-validation-${sprint.key}`}>
            {t('planning.validationShort', { rate: sprint.validationRate === null || sprint.validationRate === undefined ? '—' : `${sprint.validationRate} %` })}
          </Text>
        </Group>
      </UnstyledButton>
    </Tooltip>
  );
}

function TodayMarker({ from, to }: { from: string; to: string }) {
  const today = new Date().toISOString().slice(0, 10);
  if (today < from || today > to) return null;
  const { left } = span(today, today, from, to);
  return <Box pos="absolute" top={0} bottom={0} w={2} bg="red.6" style={{ left: `${left}%`, zIndex: 1 }} aria-hidden />;
}
