import {
  Alert,
  Anchor,
  Badge,
  Button,
  Card,
  Group,
  Loader,
  NumberInput,
  Progress,
  Rating,
  SegmentedControl,
  SimpleGrid,
  Stack,
  TagsInput,
  Text,
  Textarea,
  Title,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconBug, IconCheck, IconFlag, IconPlayerPause, IconPlayerPlay, IconPlus } from '@tabler/icons-react';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import {
  fetchNoteDefectDraft,
  useAddNote,
  useApproveDebrief,
  useConvertNote,
  useDebrief,
  useFinishSession,
  useFollowUpCharters,
  useSession,
  useUpdateSession,
  type NoteType,
  type SessionDetail,
  type SessionNote,
} from '../../api/exploratory';
import { ExecutionStatusBadge } from '../campaigns/CampaignBadges';
import { DefectDraftModal } from '../campaigns/DefectFromExecutionModal';
import { useTestWriteKinds } from '../tests/permissions';
import { AUTOSAVE_MS, clock, NOTE_COLORS, NOTE_TYPES, noteTypeForShortcut, SESSION_STATE_COLORS, tbsTotal, useCanApproveDebrief } from './model';

/**
 * §13.2 /p/:key/sessions/:id — session exploratoire : mission, chronomètre (F-EXP-05), notes
 * horodatées et brouillon sauvegardé (F-EXP-06, F-EXP-10), BUG → anomalie (F-EXP-07), fin TBS
 * (F-EXP-09), débriefing PROOF, approbation et chartes de suivi (F-EXP-11 à F-EXP-13).
 */
export function SessionPage() {
  const { t } = useTranslation();
  const { key: project, id } = useParams() as { key: string; id: string };
  const { data: session, isLoading, error, dataUpdatedAt } = useSession(project, id);

  if (isLoading) return <Loader />;
  if (error || !session) return <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>;
  const open = session.state === 'RUNNING' || session.state === 'PAUSED';

  return (
    <Stack data-testid="session-page">
      <Group justify="space-between" align="flex-start">
        <Stack gap={2}>
          <Group gap="xs">
            <Badge variant="filled" ff="monospace">
              {session.charter.key}
            </Badge>
            <Title order={2}>{session.charter.title}</Title>
            <Badge color={SESSION_STATE_COLORS[session.state]} data-testid="session-state">
              {t(`sessionState.${session.state}`)}
            </Badge>
          </Group>
          <Text size="sm" c="dimmed">
            <Anchor component={Link} to={`/p/${project}/campaigns/${session.campaign.key}`} size="sm">
              {session.campaign.key} {session.campaign.name}
            </Anchor>
            {' · '}
            {t('session.attempt', { n: session.attempt, tester: session.tester })}
          </Text>
        </Stack>
        {!open && <ExecutionStatusBadge status={session.status} testId="session-status" />}
      </Group>

      <Card withBorder data-testid="session-mission">
        <Text fw={600}>{session.missionSentence}</Text>
        <Group gap="xs" mt="xs">
          {session.areas.map((a) => (
            <Badge key={a} variant="light">
              {a}
            </Badge>
          ))}
          {session.heuristics.map((h) => (
            <Badge key={h} variant="outline" color="grape">
              {h}
            </Badge>
          ))}
        </Group>
        {session.setupNotes && (
          <Text size="sm" c="dimmed" mt="xs">
            {session.setupNotes}
          </Text>
        )}
      </Card>

      {open && <Timer project={project} session={session} fetchedAt={dataUpdatedAt} />}
      <Notes project={project} session={session} />
      {open && session.owner && <FinishForm project={project} session={session} />}
      {!open && <Summary session={session} />}
      {!open && <Debrief project={project} session={session} />}
    </Stack>
  );
}

/** F-EXP-05 chronomètre : temps actif du serveur + temps écoulé depuis la lecture (si en marche). */
function Timer({ project, session, fetchedAt }: { project: string; session: SessionDetail; fetchedAt: number }) {
  const { t } = useTranslation();
  const update = useUpdateSession(project, session.id);
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, []);
  const running = session.state === 'RUNNING';
  const elapsed = session.elapsedSeconds + (running ? Math.max(0, (now - fetchedAt) / 1000) : 0);
  const percent = Math.min(100, (elapsed / (session.timeboxMin * 60)) * 100);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  return (
    <Card withBorder data-testid="session-timer">
      <Group justify="space-between">
        <Stack gap={0}>
          <Text size="xl" fw={700} ff="monospace" data-testid="session-elapsed">
            {clock(elapsed)}
          </Text>
          <Text size="xs" c="dimmed">
            {t('session.timebox', { minutes: session.timeboxMin })}
          </Text>
        </Stack>
        {session.owner && (
          <Button
            variant="light"
            color={running ? 'yellow' : 'green'}
            leftSection={running ? <IconPlayerPause size={16} /> : <IconPlayerPlay size={16} />}
            onClick={() => update.mutate({ paused: running }, { onError: fail })}
            loading={update.isPending}
            data-testid="session-toggle"
          >
            {running ? t('session.pause') : t('session.resume')}
          </Button>
        )}
      </Group>
      <Progress value={percent} color={elapsed > session.timeboxMin * 60 ? 'orange' : 'blue'} mt="xs" />
    </Card>
  );
}

/** F-EXP-06 notes horodatées (Ctrl+1 à Ctrl+5) ; F-EXP-10 brouillon sauvegardé toutes les 10 s et à la perte de focus. */
function Notes({ project, session }: { project: string; session: SessionDetail }) {
  const { t } = useTranslation();
  const add = useAddNote(project, session.id);
  const update = useUpdateSession(project, session.id);
  const open = session.state === 'RUNNING' || session.state === 'PAUSED';
  const editable = open && session.owner;
  const [type, setType] = useState<NoteType>('NOTE');
  const [text, setText] = useState(session.draft ?? '');
  const saved = useRef(session.draft ?? '');
  const [converting, setConverting] = useState<SessionNote | null>(null);

  const saveDraft = () => {
    if (!editable || text === saved.current) return;
    saved.current = text;
    update.mutate({ draft: text });
  };
  const latest = useRef(saveDraft);
  latest.current = saveDraft;
  useEffect(() => {
    if (!editable) return;
    const timer = window.setInterval(() => latest.current(), AUTOSAVE_MS);
    return () => window.clearInterval(timer);
  }, [editable]);

  const submit = () => {
    if (!text.trim()) return;
    add.mutate(
      { type, text: text.trim() },
      {
        onSuccess: () => {
          setText('');
          saved.current = '';
        },
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );
  };

  return (
    <Card withBorder data-testid="session-notes">
      <Title order={5} mb="xs">
        {t('session.notes', { count: session.notes.length })}
      </Title>
      {editable && (
        <Stack gap="xs" mb="md">
          <SegmentedControl
            value={type}
            onChange={(v) => setType(v as NoteType)}
            data={NOTE_TYPES.map((n, i) => ({ value: n, label: `${t(`noteType.${n}`)} · ${i + 1}` }))}
            data-testid="note-type"
          />
          <Textarea
            autosize
            minRows={2}
            placeholder={t('session.notePlaceholder')}
            value={text}
            onChange={(e) => setText(e.currentTarget.value)}
            onBlur={saveDraft}
            onKeyDown={(e) => {
              const shortcut = noteTypeForShortcut(e);
              if (shortcut) {
                e.preventDefault();
                setType(shortcut);
              } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                e.preventDefault();
                submit();
              }
            }}
            data-testid="note-text"
          />
          <Group justify="space-between">
            <Text size="xs" c="dimmed">
              {t('session.noteHint')}
            </Text>
            <Button leftSection={<IconPlus size={14} />} size="xs" onClick={submit} loading={add.isPending} disabled={!text.trim()} data-testid="note-add">
              {t('session.addNote')}
            </Button>
          </Group>
        </Stack>
      )}
      {session.notes.length === 0 && <Text c="dimmed" size="sm">{t('session.noNotes')}</Text>}
      <Stack gap={6}>
        {session.notes.map((n, index) => (
          <Group key={n.id} gap="xs" wrap="nowrap" align="flex-start" data-testid={`note-${index + 1}`}>
            <Text size="xs" ff="monospace" c="dimmed" w={48}>
              {n.offsetLabel}
            </Text>
            <Badge color={NOTE_COLORS[n.type]} variant="light" w={92}>
              {t(`noteType.${n.type}`)}
            </Badge>
            <Text size="sm" flex={1} style={{ whiteSpace: 'pre-wrap' }}>
              {n.text}
            </Text>
            {n.defect ? (
              <Anchor component={Link} to={`/p/${project}/defects?selected=${n.defect.key}`} size="sm" ff="monospace" data-testid={`note-defect-${index + 1}`}>
                {n.defect.key}
              </Anchor>
            ) : (
              n.type === 'BUG' &&
              session.owner && (
                <Button size="compact-xs" color="red" variant="light" leftSection={<IconBug size={12} />} onClick={() => setConverting(n)}
                  data-testid={`note-convert-${index + 1}`}>
                  {t('session.toDefect')}
                </Button>
              )
            )}
          </Group>
        ))}
      </Stack>
      {converting && <ConvertNote project={project} session={session} note={converting} onClose={() => setConverting(null)} />}
    </Card>
  );
}

function ConvertNote({ project, session, note, onClose }: { project: string; session: SessionDetail; note: SessionNote; onClose: () => void }) {
  const { t } = useTranslation();
  const convert = useConvertNote(project, session.id, note.id);
  return (
    <DefectDraftModal project={project} title={t('session.toDefectTitle')} opened onClose={onClose}
      load={() => fetchNoteDefectDraft(project, session.id, note.id)} create={(form) => convert.mutateAsync(form)} creating={convert.isPending} />
  );
}

/** F-EXP-09 fin de session : répartition TBS (100 %), zones couvertes, statut. */
function FinishForm({ project, session }: { project: string; session: SessionDetail }) {
  const { t } = useTranslation();
  const finish = useFinishSession(project, session.id);
  const [opened, setOpened] = useState(false);
  const [tbs, setTbs] = useState({ testPct: 70, bugPct: 20, setupPct: 10 });
  const [areas, setAreas] = useState<string[]>(session.areas);
  const [status, setStatus] = useState<'PASSED' | 'FAILED' | 'BLOCKED'>('PASSED');
  const total = tbsTotal(tbs);

  if (!opened) {
    return (
      <Group justify="flex-end">
        <Button
          leftSection={<IconFlag size={16} />}
          onClick={() => {
            // une note BUG suggère une session en échec ; le testeur peut changer
            setStatus(session.notes.some((n) => n.type === 'BUG') ? 'FAILED' : 'PASSED');
            setOpened(true);
          }}
          data-testid="session-finish-open"
        >
          {t('session.finish')}
        </Button>
      </Group>
    );
  }
  const submit = () =>
    finish.mutate({ ...tbs, areasCovered: areas, status }, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) });

  return (
    <Card withBorder data-testid="session-finish">
      <Title order={5} mb="xs">
        {t('session.finish')}
      </Title>
      <Stack>
        <SimpleGrid cols={3}>
          {(['testPct', 'bugPct', 'setupPct'] as const).map((field) => (
            <NumberInput key={field} label={t(`session.tbs.${field}`)} suffix=" %" min={0} max={100} value={tbs[field]}
              onChange={(v) => setTbs({ ...tbs, [field]: Number(v) || 0 })} data-testid={`tbs-${field}`} />
          ))}
        </SimpleGrid>
        <Text size="sm" c={total === 100 ? 'dimmed' : 'red'} data-testid="tbs-total">
          {t('session.tbsTotal', { total })}
        </Text>
        <TagsInput label={t('session.areasCovered')} description={t('session.areasHint')} data={session.areas} value={areas} onChange={setAreas}
          data-testid="session-areas" />
        <SegmentedControl
          value={status}
          onChange={(v) => setStatus(v as typeof status)}
          data={(['PASSED', 'FAILED', 'BLOCKED'] as const).map((s) => ({ value: s, label: t(`executionStatus.${s}`) }))}
          data-testid="session-result"
        />
        <Text size="xs" c="dimmed">
          {t(`session.resultHint.${status}`)}
        </Text>
        <Group justify="flex-end">
          <Button variant="default" onClick={() => setOpened(false)}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={finish.isPending} disabled={total !== 100} data-testid="session-finish-submit">
            {t('session.finishSubmit')}
          </Button>
        </Group>
      </Stack>
    </Card>
  );
}

function Summary({ session }: { session: SessionDetail }) {
  const { t } = useTranslation();
  return (
    <Card withBorder data-testid="session-summary">
      <SimpleGrid cols={{ base: 1, sm: 3 }}>
        <Stack gap={2}>
          <Text size="xs" c="dimmed">
            {t('session.duration')}
          </Text>
          <Text fw={600}>{t('session.durationValue', { minutes: session.durationMin ?? 0, timebox: session.timeboxMin })}</Text>
        </Stack>
        {session.tbs && (
          <Stack gap={2}>
            <Text size="xs" c="dimmed">
              TBS
            </Text>
            <Progress.Root size="lg">
              <Progress.Section value={session.tbs.testPct} color="blue">
                <Progress.Label>T {session.tbs.testPct}</Progress.Label>
              </Progress.Section>
              <Progress.Section value={session.tbs.bugPct} color="red">
                <Progress.Label>B {session.tbs.bugPct}</Progress.Label>
              </Progress.Section>
              <Progress.Section value={session.tbs.setupPct} color="gray">
                <Progress.Label>S {session.tbs.setupPct}</Progress.Label>
              </Progress.Section>
            </Progress.Root>
          </Stack>
        )}
        <Stack gap={2}>
          <Text size="xs" c="dimmed">
            {t('session.areasCovered')}
          </Text>
          <Group gap={4}>
            {session.areasCovered.length === 0 ? '—' : session.areasCovered.map((a) => <Badge key={a} variant="light">{a}</Badge>)}
          </Group>
        </Stack>
      </SimpleGrid>
    </Card>
  );
}

/** F-EXP-11 PROOF ; F-EXP-13 approbation par un autre utilisateur ; F-EXP-12 chartes de suivi depuis l'Outlook. */
function Debrief({ project, session }: { project: string; session: SessionDetail }) {
  const { t } = useTranslation();
  const debrief = useDebrief(project, session.id);
  const approve = useApproveDebrief(project, session.id);
  const followUp = useFollowUpCharters(project, session.id);
  const canApprove = useCanApproveDebrief(project);
  const canWriteCharters = useTestWriteKinds(project).includes('EXPLORATORY');
  const editable = session.owner && session.state === 'FINISHED';
  const [form, setForm] = useState({
    past: session.proof?.past ?? '',
    results: session.proof?.results ?? '',
    obstacles: session.proof?.obstacles ?? '',
    outlook: session.proof?.outlook ?? '',
    feelings: session.proof?.feelings ?? 0,
  });
  const [followed, setFollowed] = useState<Record<string, string>>({});
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  const createFollowUp = (mission: string) =>
    followUp.mutate([mission], {
      onSuccess: (r) => {
        setFollowed((current) => ({ ...current, [mission]: r.created[0]! }));
        notifications.show({ color: 'green', message: t('session.followUpCreated', { key: r.created[0] }) });
      },
      onError: fail,
    });

  return (
    <Card withBorder data-testid="session-debrief">
      <Group justify="space-between" mb="xs">
        <Title order={5}>{t('session.debrief')}</Title>
        {session.state === 'DEBRIEFED' && (
          <Badge color="green" leftSection={<IconCheck size={12} />} data-testid="session-approved">
            {t('session.approvedBy', { by: session.approvedBy })}
          </Badge>
        )}
      </Group>
      {editable ? (
        <Stack>
          {(['past', 'results', 'obstacles', 'outlook'] as const).map((field) => (
            <Textarea key={field} label={t(`session.proof.${field}`)} description={t(`session.proofHint.${field}`)} autosize minRows={2}
              required={field === 'past' || field === 'results'} value={form[field]} onChange={(e) => setForm({ ...form, [field]: e.currentTarget.value })}
              data-testid={`proof-${field}`} />
          ))}
          <Stack gap={2}>
            <Text size="sm" fw={500}>
              {t('session.proof.feelings')}
            </Text>
            <Rating value={form.feelings} onChange={(feelings) => setForm({ ...form, feelings })} data-testid="proof-feelings" />
          </Stack>
          <Group justify="flex-end">
            <Button onClick={() => debrief.mutate(form, { onError: fail, onSuccess: () => notifications.show({ color: 'green', message: t('session.debriefSaved') }) })}
              loading={debrief.isPending} disabled={!form.past.trim() || !form.results.trim() || form.feelings < 1} data-testid="proof-submit">
              {session.proof ? t('session.debriefUpdate') : t('session.debriefSubmit')}
            </Button>
          </Group>
        </Stack>
      ) : session.proof ? (
        <SimpleGrid cols={{ base: 1, sm: 2 }} data-testid="proof-view">
          {(['past', 'results', 'obstacles', 'outlook'] as const).map((field) => (
            <Stack key={field} gap={2}>
              <Text size="xs" c="dimmed">
                {t(`session.proof.${field}`)}
              </Text>
              <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>
                {session.proof?.[field] ?? '—'}
              </Text>
            </Stack>
          ))}
          <Stack gap={2}>
            <Text size="xs" c="dimmed">
              {t('session.proof.feelings')}
            </Text>
            <Rating value={session.proof.feelings} readOnly />
          </Stack>
        </SimpleGrid>
      ) : (
        <Text c="dimmed" size="sm">
          {t('session.noDebrief')}
        </Text>
      )}

      {session.state === 'FINISHED' && session.proof && !session.owner && canApprove && (
        <Group justify="flex-end" mt="md">
          <Button color="green" leftSection={<IconCheck size={16} />} onClick={() => approve.mutate(undefined, { onError: fail })} loading={approve.isPending}
            data-testid="debrief-approve">
            {t('session.approve')}
          </Button>
        </Group>
      )}
      {session.state === 'FINISHED' && session.proof && session.owner && (
        <Text size="xs" c="dimmed" mt="sm">
          {t('session.awaitingApproval')}
        </Text>
      )}

      {session.proof && session.proof.outlookItems.length > 0 && canWriteCharters && (
        <Stack gap={4} mt="md" data-testid="session-follow-up">
          <Text size="sm" fw={500}>
            {t('session.followUp')}
          </Text>
          {session.proof.outlookItems.map((mission, index) => (
            <Group key={mission} gap="xs">
              <Text size="sm" flex={1}>
                {mission}
              </Text>
              {followed[mission] ? (
                <Anchor component={Link} to={`/p/${project}/tests/${followed[mission]}`} size="sm" ff="monospace">
                  {followed[mission]}
                </Anchor>
              ) : (
                <Button size="compact-xs" variant="light" onClick={() => createFollowUp(mission)} loading={followUp.isPending && followUp.variables?.[0] === mission}
                  data-testid={`follow-up-${index + 1}`}>
                  {t('session.createCharter')}
                </Button>
              )}
            </Group>
          ))}
        </Stack>
      )}
    </Card>
  );
}
