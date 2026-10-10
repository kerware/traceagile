import { Badge, Card, Group, Loader, SimpleGrid, Stack, Text, Title } from '@mantine/core';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useOrphans } from '../../api/traceability';
import { TypeBadge } from '../requirements/Badges';
import { KindBadge, TechniqueBadge } from '../tests/Badges';
import { KeyLink } from '../../components/keys/KeyLink';

/** F-TRA-06 rapport des orphelins. */
export function OrphansView({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useOrphans(project);
  if (isLoading || !data) return <Loader />;

  return (
    <SimpleGrid cols={{ base: 1, md: 2 }}>
      <Section title={t('orphans.requirements')} count={data.requirementsWithoutTests.length} testId="orphans-requirements">
        {data.requirementsWithoutTests.map((r) => (
          <Group key={r.key} gap={6} wrap="nowrap">
            <KeyLink project={project} itemKey={r.key} />
            <TypeBadge type={r.type} />
            <Text size="sm">{r.title}</Text>
          </Group>
        ))}
      </Section>
      <Section title={t('orphans.tests')} count={data.testsWithoutRequirement.length} testId="orphans-tests">
        {data.testsWithoutRequirement.map((test) => (
          <Group key={test.key} gap={6} wrap="nowrap">
            <KeyLink project={project} itemKey={test.key} />
            <KindBadge kind={test.kind} />
            <Text size="sm">{test.title}</Text>
          </Group>
        ))}
      </Section>
      <Section title={t('orphans.neverExecuted')} count={data.automatedNeverExecuted.length} testId="orphans-never-executed">
        {data.automatedNeverExecuted.map((test) => (
          <Group key={test.key} gap={6} wrap="nowrap">
            <KeyLink project={project} itemKey={test.key} />
            <TechniqueBadge technique={test.technique} />
            <Text size="sm">{test.title}</Text>
          </Group>
        ))}
      </Section>
      <Section title={t('orphans.defects')} count={data.defectsWithoutRequirement.length} testId="orphans-defects" note={t('orphans.defectsLater')}>
        {data.defectsWithoutRequirement.map((d) => (
          <Text key={d.key} size="sm">
            {d.key} — {d.title}
          </Text>
        ))}
      </Section>
    </SimpleGrid>
  );
}

function Section({ title, count, testId, note, children }: { title: string; count: number; testId: string; note?: string; children: ReactNode }) {
  const { t } = useTranslation();
  return (
    <Card withBorder data-testid={testId}>
      <Group justify="space-between" mb="xs">
        <Title order={5}>{title}</Title>
        <Badge color={count > 0 ? 'orange' : 'green'} variant="light">
          {count}
        </Badge>
      </Group>
      <Stack gap={4} mah={360} style={{ overflowY: 'auto' }}>
        {count === 0 && (
          <Text size="sm" c="dimmed">
            {note ?? t('orphans.none')}
          </Text>
        )}
        {children}
      </Stack>
    </Card>
  );
}
