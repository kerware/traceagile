import { Anchor, Badge, Breadcrumbs, Card, Group, Loader, Stack, Text, Title } from '@mantine/core';
import { IconAlertTriangle } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useTraceTree, type TraceNode } from '../../api/traceability';
import { TypeBadge } from '../requirements/Badges';
import { KindBadge, TestStatusBadge } from '../tests/Badges';
import { ImpactView } from './ImpactView';
import { VerificationBadge } from './VerificationBadge';

/**
 * F-TRA-05 arbre de traçabilité d'une exigence : parents, enfants, critères, tests, dernières
 * exécutions, anomalies (lot 5) ; F-TRA-07 analyse d'impact.
 */
export function TraceTreePanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useTraceTree(project, requirementKey);
  if (isLoading || !data) return <Loader />;

  return (
    <Stack data-testid="trace-tree">
      <Group justify="space-between">
        <Breadcrumbs separator="›">
          {data.ancestors.map((a) => (
            <Group key={a.key} gap={4} wrap="nowrap">
              <VerificationBadge status={a.verificationStatus} compact />
              <Anchor component={Link} to={`/p/${project}/requirements/${a.key}`} size="sm" ff="monospace">
                {a.key}
              </Anchor>
            </Group>
          ))}
          <Text size="sm" ff="monospace" fw={700}>
            {data.requirement.key}
          </Text>
        </Breadcrumbs>
        <VerificationBadge status={data.requirement.verificationStatus} testId="trace-status" />
      </Group>

      {data.requirement.children.length > 0 && (
        <Card withBorder>
          <Title order={6} mb="xs">
            {t('traceTree.children')}
          </Title>
          <Stack gap={2}>
            {data.requirement.children.map((child) => (
              <ChildNode key={child.key} project={project} node={child} depth={0} />
            ))}
          </Stack>
        </Card>
      )}

      <Card withBorder data-testid="trace-criteria">
        <Title order={6} mb="xs">
          {t('traceTree.criteria')}
        </Title>
        {data.criteria.length === 0 && (
          <Text size="sm" c="dimmed">
            {t('traceTree.noCriteria')}
          </Text>
        )}
        <Stack gap={6}>
          {data.criteria.map((c) => (
            <Group key={c.position} gap={6} wrap="nowrap" align="flex-start" data-testid={`trace-criterion-${c.position}`}>
              <Badge variant="default" size="sm">
                #{c.position}
              </Badge>
              <Badge size="sm" variant="light" color={c.status === 'VERIFIED' ? 'green' : c.status === 'FAILED' ? 'red' : 'gray'}>
                {t(`criteria.statusLabel.${c.status}`)}
              </Badge>
              <Text size="sm" lineClamp={2} flex={1}>
                {c.content}
              </Text>
              <Group gap={4}>
                {c.testKeys.length === 0 ? (
                  <Text size="xs" c="orange">
                    {t('traceTree.noTest')}
                  </Text>
                ) : (
                  c.testKeys.map((key) => (
                    <Anchor key={key} component={Link} to={`/p/${project}/tests/${key}`} size="xs" ff="monospace">
                      {key}
                    </Anchor>
                  ))
                )}
              </Group>
            </Group>
          ))}
        </Stack>
      </Card>

      <Card withBorder data-testid="trace-tests">
        <Title order={6} mb="xs">
          {t('traceTree.tests')}
        </Title>
        {data.tests.length === 0 && (
          <Text size="sm" c="dimmed">
            {t('linkedTests.empty')}
          </Text>
        )}
        <Stack gap={6}>
          {data.tests.map((item) => (
            <Group key={item.test.key} gap={6} wrap="nowrap">
              <Anchor component={Link} to={`/p/${project}/tests/${item.test.key}`} ff="monospace" fw={600} size="sm">
                {item.test.key}
              </Anchor>
              <KindBadge kind={item.test.kind} />
              <Text size="sm" flex={1}>
                {item.test.title}
              </Text>
              <Badge variant="light" size="sm">
                {t(`linkType.${item.linkType}`)}
              </Badge>
              <TestStatusBadge status={item.test.status} />
              {item.suspect && (
                <Badge color="violet" variant="light" size="sm" leftSection={<IconAlertTriangle size={10} />}>
                  {t('traceability.suspect')}
                </Badge>
              )}
              <Text size="xs" c="dimmed" w={130} ta="right">
                {item.test.lastResult ? t(`executionStatus.${item.test.lastResult}`) : t('traceTree.neverExecuted')}
              </Text>
            </Group>
          ))}
        </Stack>
      </Card>

      <Card withBorder>
        <Title order={6} mb="xs">
          {t('traceTree.defects')}
        </Title>
        <Text size="sm" c="dimmed">
          {data.defects.length === 0 ? t('traceTree.noDefects') : data.defects.map((d) => `${d.key} ${d.title}`).join(', ')}
        </Text>
      </Card>

      <Card withBorder data-testid="trace-impact">
        <Title order={6} mb="xs">
          {t('impact.title')}
        </Title>
        <ImpactView project={project} requirementKey={requirementKey} />
      </Card>
    </Stack>
  );
}

function ChildNode({ project, node, depth }: { project: string; node: TraceNode; depth: number }) {
  return (
    <>
      <Group gap={6} pl={depth * 16} wrap="nowrap">
        <VerificationBadge status={node.verificationStatus} compact />
        <Anchor component={Link} to={`/p/${project}/requirements/${node.key}`} size="sm" ff="monospace">
          {node.key}
        </Anchor>
        <TypeBadge type={node.type} />
        <Text size="sm">{node.title}</Text>
      </Group>
      {node.children.map((child) => (
        <ChildNode key={child.key} project={project} node={child} depth={depth + 1} />
      ))}
    </>
  );
}
