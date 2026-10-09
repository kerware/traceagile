import { Alert, Anchor, Badge, Button, Group, Loader, Select, Stack, Table, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconCheck } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { useRequirementTree } from '../../api/requirements';
import { useImpact, useReviewLink } from '../../api/traceability';
import { flatten } from '../requirements/model';
import { KindBadge, TestStatusBadge } from '../tests/Badges';
import { useTestWriteKinds } from '../tests/permissions';

/** F-TRA-07 analyse d'impact : tests à revoir si l'exigence (ou un descendant) change, campagnes en cours. */
export function ImpactView({ project, requirementKey, onRequirement }: { project: string; requirementKey: string | null; onRequirement?: (key: string | null) => void }) {
  const { t } = useTranslation();
  const { data: tree } = useRequirementTree(project);
  const { data, isLoading } = useImpact(project, requirementKey);
  const writableKinds = useTestWriteKinds(project);
  const review = useReviewLink(project);

  return (
    <Stack>
      {onRequirement && (
        <Select
          label={t('impact.requirement')}
          placeholder={t('impact.pick')}
          data={flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }))}
          value={requirementKey}
          onChange={onRequirement}
          searchable
          clearable
          w={480}
          data-testid="impact-requirement"
        />
      )}
      {requirementKey && isLoading && <Loader />}
      {data && (
        <>
          <Text size="sm" data-testid="impact-summary">
            {t('impact.summary', { count: data.tests.length, suspect: data.tests.filter((i) => i.suspect).length })}
          </Text>
          {data.tests.length > 0 && (
            <Table striped data-testid="impact-tests">
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>{t('impact.test')}</Table.Th>
                  <Table.Th>{t('impact.via')}</Table.Th>
                  <Table.Th>{t('traceability.linkType')}</Table.Th>
                  <Table.Th>{t('impact.status')}</Table.Th>
                  <Table.Th />
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {data.tests.map((item) => (
                  <Table.Tr key={`${item.test.key}-${item.via.key}`} data-testid={`impact-test-${item.test.key}`}>
                    <Table.Td>
                      <Group gap={6} wrap="nowrap">
                        <Anchor component={Link} to={`/p/${project}/tests/${item.test.key}`} ff="monospace" fw={600} size="sm">
                          {item.test.key}
                        </Anchor>
                        <KindBadge kind={item.test.kind} />
                        <Text size="sm">{item.test.title}</Text>
                      </Group>
                    </Table.Td>
                    <Table.Td>
                      <Text size="sm" ff="monospace">
                        {item.via.key}
                      </Text>
                    </Table.Td>
                    <Table.Td>
                      <Badge variant="light">{t(`linkType.${item.linkType}`)}</Badge>
                    </Table.Td>
                    <Table.Td>
                      <Group gap={4}>
                        <TestStatusBadge status={item.test.status} />
                        {item.suspect && (
                          <Badge color="violet" variant="light" leftSection={<IconAlertTriangle size={10} />}>
                            {t('traceability.suspect')}
                          </Badge>
                        )}
                      </Group>
                    </Table.Td>
                    <Table.Td>
                      {item.suspect && writableKinds.includes(item.test.kind) && (
                        <Button size="xs" variant="light" color="violet" leftSection={<IconCheck size={14} />} loading={review.isPending}
                          onClick={() => review.mutate(item.linkId, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) })}
                          data-testid={`impact-review-${item.test.key}`}>
                          {t('traceability.markReviewed')}
                        </Button>
                      )}
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          )}
          <Alert color="gray" title={t('impact.campaigns')}>
            {data.campaigns.length === 0 ? t('impact.noCampaigns') : data.campaigns.map((c) => `${c.key} ${c.name}`).join(', ')}
          </Alert>
        </>
      )}
    </Stack>
  );
}
