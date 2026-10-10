import { ActionIcon, Anchor, Badge, Button, Group, Loader, MultiSelect, Select, Stack, Table, Text, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconCheck, IconCompass, IconLink, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import type { RequirementDetail } from '../../api/requirements';
import { useLinkedTests, useTestList } from '../../api/testcases';
import { useCreateLink, useDeleteLink, useReviewLink, type LinkType } from '../../api/traceability';
import { GenerateChartersModal } from '../exploratory/GenerateChartersModal';
import { KindBadge, TechniqueBadge, TestStatusBadge } from '../tests/Badges';
import { useTestWriteKinds } from '../tests/permissions';
import { LINK_TYPES } from '../traceability/model';

/**
 * §13.2 fiche exigence, onglet « Tests liés » : lier un test depuis l'exigence (F-TRA-01), avec son
 * type (F-TRA-02) et les critères vérifiés (F-TRA-03) ; alerte de suspicion et revue (§3.3-7).
 */
export function LinkedTestsPanel({ project, requirement }: { project: string; requirement: RequirementDetail }) {
  const { t } = useTranslation();
  const { data, isLoading } = useLinkedTests(project, requirement.key);
  const writableKinds = useTestWriteKinds(project);
  const create = useCreateLink(project);
  const remove = useDeleteLink(project);
  const review = useReviewLink(project);
  const [search, setSearch] = useState('');
  const { data: candidates } = useTestList(project, { q: search || undefined }, 0, 'key,asc');
  const [testKey, setTestKey] = useState<string | null>(null);
  const [linkType, setLinkType] = useState<LinkType>('VERIFIES');
  const [criteria, setCriteria] = useState<string[]>([]);
  const [generating, setGenerating] = useState(false);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  const linked = new Set((data ?? []).map((test) => test.key));
  const options = (candidates?.content ?? [])
    .filter((test) => !linked.has(test.key) && writableKinds.includes(test.kind))
    .map((test) => ({ value: test.key, label: `${test.key} — ${test.title}` }));

  const submit = () =>
    testKey &&
    create.mutate(
      { testKey, requirementKey: requirement.key, linkType, criterionPositions: criteria.map(Number) },
      {
        onSuccess: () => {
          notifications.show({ color: 'green', message: t('traceability.linked', { test: testKey, requirement: requirement.key }) });
          setTestKey(null);
          setCriteria([]);
        },
        onError: fail,
      },
    );

  return (
    <Stack>
      {writableKinds.includes('EXPLORATORY') && requirement.status !== 'OBSOLETE' && (
        <Group justify="flex-end">
          <Button variant="light" color="grape" leftSection={<IconCompass size={16} />} onClick={() => setGenerating(true)} data-testid="generate-charters">
            {t('generateCharters.action')}
          </Button>
          <GenerateChartersModal project={project} requirementKey={requirement.key} opened={generating} onClose={() => setGenerating(false)} />
        </Group>
      )}
      {writableKinds.length > 0 && requirement.status !== 'OBSOLETE' && (
        <Group align="flex-end" data-testid="link-test-form">
          <Select
            label={t('linkedTests.addTest')}
            placeholder={t('linkedTests.searchTest')}
            data={options}
            value={testKey}
            onChange={setTestKey}
            searchable
            searchValue={search}
            onSearchChange={setSearch}
            filter={({ options: all }) => all}
            nothingFoundMessage={t('linkedTests.noCandidate')}
            w={360}
            data-testid="link-test-select"
          />
          <Select
            label={t('traceability.linkType')}
            data={LINK_TYPES.map((type) => ({ value: type, label: t(`linkType.${type}`) }))}
            value={linkType}
            onChange={(value) => value && setLinkType(value as LinkType)}
            allowDeselect={false}
            w={200}
            data-testid="link-type-select"
          />
          {requirement.criteria.length > 0 && (
            <MultiSelect
              label={t('linkedTests.criteriaLabel')}
              data={requirement.criteria.map((c) => ({ value: String(c.position), label: `#${c.position} ${c.content.slice(0, 50)}` }))}
              value={criteria}
              onChange={setCriteria}
              w={260}
              data-testid="link-criteria-select"
            />
          )}
          <Button leftSection={<IconLink size={16} />} onClick={submit} disabled={!testKey} loading={create.isPending} data-testid="link-test-submit">
            {t('linkedTests.link')}
          </Button>
        </Group>
      )}
      {isLoading && <Loader />}
      {data && data.length === 0 && <Text c="dimmed">{t('linkedTests.empty')}</Text>}
      {data && data.length > 0 && (
        <Table data-testid="linked-tests">
          <Table.Tbody>
            {data.map((test) => {
              const writable = writableKinds.includes(test.kind);
              return (
                <Table.Tr key={test.key} data-testid={`linked-test-${test.key}`}>
                  <Table.Td>
                    <Anchor component={Link} to={`/p/${project}/tests/${test.key}`} ff="monospace" fw={600}>
                      {test.key}
                    </Anchor>
                  </Table.Td>
                  <Table.Td>{test.title}</Table.Td>
                  <Table.Td>
                    <Group gap={4}>
                      <KindBadge kind={test.kind} />
                      <TechniqueBadge technique={test.technique} />
                    </Group>
                  </Table.Td>
                  <Table.Td>
                    <Group gap={4}>
                      <TestStatusBadge status={test.status} />
                      {test.suspect && (
                        <Tooltip label={t('traceability.suspectHint')}>
                          <Badge color="violet" variant="light" leftSection={<IconAlertTriangle size={10} />} data-testid={`linked-suspect-${test.key}`}>
                            {t('traceability.suspect')}
                          </Badge>
                        </Tooltip>
                      )}
                    </Group>
                  </Table.Td>
                  <Table.Td>
                    <Badge variant="light">{t(`linkType.${test.linkType}`)}</Badge>
                  </Table.Td>
                  <Table.Td>
                    {test.criterionPositions.length > 0 && (
                      <Text size="xs" c="dimmed">
                        {t('linkedTests.criteria', { list: test.criterionPositions.map((p) => `#${p}`).join(', ') })}
                      </Text>
                    )}
                  </Table.Td>
                  <Table.Td>
                    {writable && (
                      <Group gap={2} wrap="nowrap" justify="flex-end">
                        {test.suspect && (
                          <Tooltip label={t('traceability.markReviewed')}>
                            <ActionIcon variant="subtle" color="violet" onClick={() => review.mutate(test.linkId, { onError: fail })}
                              aria-label={t('traceability.markReviewed')} data-testid={`linked-review-${test.key}`}>
                              <IconCheck size={16} />
                            </ActionIcon>
                          </Tooltip>
                        )}
                        <Tooltip label={t('traceability.deleteLink')}>
                          <ActionIcon variant="subtle" color="red" onClick={() => remove.mutate(test.linkId, { onError: fail })}
                            aria-label={t('traceability.deleteLink')} data-testid={`linked-unlink-${test.key}`}>
                            <IconTrash size={16} />
                          </ActionIcon>
                        </Tooltip>
                      </Group>
                    )}
                  </Table.Td>
                </Table.Tr>
              );
            })}
          </Table.Tbody>
        </Table>
      )}
    </Stack>
  );
}
