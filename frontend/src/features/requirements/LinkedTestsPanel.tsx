import { Anchor, Badge, Group, Loader, Table, Text } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useLinkedTests } from '../../api/testcases';
import { KindBadge, TechniqueBadge, TestStatusBadge } from '../tests/Badges';

/** §13.2 fiche exigence, onglet « Tests liés » (F-TRA-01, F-TRA-03). */
export function LinkedTestsPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useLinkedTests(project, requirementKey);
  if (isLoading) return <Loader />;
  if (!data || data.length === 0) return <Text c="dimmed">{t('linkedTests.empty')}</Text>;
  return (
    <Table data-testid="linked-tests">
      <Table.Tbody>
        {data.map((test) => (
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
              <TestStatusBadge status={test.status} />
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
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  );
}
