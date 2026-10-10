import { Alert, Badge, Button, Card, Checkbox, Group, Loader, Modal, Stack, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useCharterProposals, type CharterProposal } from '../../api/exploratory';
import { useCreateTest } from '../../api/testcases';

/**
 * F-EXP-04 « Générer des chartes » depuis une exigence : une proposition par critère d'acceptation et
 * par ENF transverse applicable ; le testeur coche celles qu'il valide, les autres sont rejetées.
 */
export function GenerateChartersModal({ project, requirementKey, opened, onClose }: { project: string; requirementKey: string; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const { data, isLoading, error } = useCharterProposals(project, requirementKey, opened);
  const create = useCreateTest(project);
  const [selected, setSelected] = useState<number[]>([]);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (opened && data) setSelected(data.map((_, i) => i));
  }, [opened, data]);

  const toggle = (index: number) => setSelected((s) => (s.includes(index) ? s.filter((i) => i !== index) : [...s, index]));

  const submit = async () => {
    if (!data) return;
    setBusy(true);
    const created: string[] = [];
    try {
      for (const index of selected) {
        const p: CharterProposal = data[index]!;
        const test = await create.mutateAsync({
          kind: 'EXPLORATORY',
          title: p.title,
          explore: p.explore,
          with: p.with,
          toDiscover: p.toDiscover,
          areas: p.areas,
          heuristics: p.heuristics,
          links: p.requirementKeys.map((key) => ({
            requirementKey: key,
            linkType: 'VERIFIES' as const,
            criterionPositions: key === requirementKey && p.criterionPosition ? [p.criterionPosition] : [],
          })),
        });
        created.push(test.key);
      }
      notifications.show({ color: 'green', message: t('generateCharters.created', { count: created.length, keys: created.join(', ') }) });
      onClose();
    } catch (e) {
      notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('generateCharters.title', { key: requirementKey })} size="xl">
      <Stack>
        {isLoading && <Loader />}
        {error && <Alert color="red">{errorMessage(error, t('errors.generic'))}</Alert>}
        {data && data.length === 0 && <Text c="dimmed">{t('generateCharters.none')}</Text>}
        {data?.map((p, index) => (
          <Card key={index} withBorder p="sm" data-testid={`proposal-${index + 1}`}>
            <Group align="flex-start" wrap="nowrap">
              <Checkbox checked={selected.includes(index)} onChange={() => toggle(index)} mt={2} aria-label={p.title} data-testid={`proposal-check-${index + 1}`} />
              <Stack gap={2} flex={1}>
                <Group gap="xs">
                  <Badge variant="light" color={p.source === 'NFR' ? 'grape' : 'blue'}>
                    {p.source === 'NFR' ? t('generateCharters.fromNfr') : t('generateCharters.fromCriterion', { n: p.criterionPosition })}
                  </Badge>
                  <Text fw={600} size="sm">
                    {p.title}
                  </Text>
                </Group>
                <Text size="sm" c="dimmed">
                  {`${t('charter.explore')} ${p.explore} ${t('charter.with')} ${p.with} ${t('charter.toDiscover')} ${p.toDiscover}.`}
                </Text>
                <Text size="xs" c="dimmed">
                  {[...p.heuristics, ...p.requirementKeys].join(' · ')}
                </Text>
              </Stack>
            </Group>
          </Card>
        ))}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={busy} disabled={selected.length === 0} data-testid="proposals-submit">
            {t('generateCharters.submit', { count: selected.length })}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
