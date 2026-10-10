import { Badge, Card, Group, Loader, SimpleGrid, Stack, Table, Text, Tooltip } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useCoverage, type IndicatorResponse } from '../../api/traceability';
import { percent } from './model';
import { ScopeSelect } from './ScopeSelect';
import { VerificationBadge } from './VerificationBadge';
import { LabeledProgress } from '../../components/LabeledProgress';

const INDICATORS = ['design', 'criteria', 'execution', 'validation', 'riskWeighted'] as const;

/** §7.2 les cinq indicateurs de couverture d'un périmètre, puis le détail par exigence. */
export function CoverageView({ project, scope, onScope }: { project: string; scope: string; onScope: (scope: string) => void }) {
  const { t } = useTranslation();
  const { data, isLoading } = useCoverage(project, scope === 'project' ? undefined : scope);

  return (
    <Stack>
      <ScopeSelect project={project} value={scope} onChange={onScope} />
      {isLoading && <Loader />}
      {data && (
        <>
          <SimpleGrid cols={{ base: 1, sm: 2, lg: 5 }}>
            {INDICATORS.map((name) => (
              <IndicatorCard key={name} name={name} indicator={data[name]} />
            ))}
          </SimpleGrid>
          <Table striped data-testid="coverage-table">
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('traceability.requirement')}</Table.Th>
                <Table.Th>{t('traceability.verification')}</Table.Th>
                <Table.Th>{t('backlog.columns.risk')}</Table.Th>
                <Table.Th ta="right">{t('traceability.coveringTests')}</Table.Th>
                <Table.Th ta="right">{t('traceability.executedTests')}</Table.Th>
                <Table.Th ta="right">{t('traceability.passedTests')}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {data.requirements.map((r) => (
                <Table.Tr key={r.key} data-testid={`coverage-row-${r.key}`}>
                  <Table.Td>
                    <Group gap={6} pl={r.depth * 16} wrap="nowrap">
                      <Text ff="monospace" size="sm" fw={r.leaf ? 500 : 700} component={Link} to={`/p/${project}/requirements/${r.key}`} c="inherit" td="none">
                        {r.key}
                      </Text>
                      <Text size="sm" fw={r.leaf ? 400 : 600}>
                        {r.title}
                      </Text>
                    </Group>
                  </Table.Td>
                  <Table.Td>
                    <VerificationBadge status={r.verificationStatus} />
                  </Table.Td>
                  <Table.Td>
                    <Badge variant="default" size="sm">
                      {t(`risk.${r.riskLevel}`)}
                    </Badge>
                  </Table.Td>
                  <Table.Td ta="right">{r.leaf || r.coveringTests > 0 ? r.coveringTests : ''}</Table.Td>
                  <Table.Td ta="right">{r.leaf || r.coveringTests > 0 ? r.executedTests : ''}</Table.Td>
                  <Table.Td ta="right">{r.leaf || r.coveringTests > 0 ? r.passedTests : ''}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </>
      )}
    </Stack>
  );
}

function IndicatorCard({ name, indicator }: { name: (typeof INDICATORS)[number]; indicator: IndicatorResponse }) {
  const { t, i18n } = useTranslation();
  const value = indicator.percent ?? 0;
  const color = value >= 80 ? 'green' : value >= 50 ? 'yellow' : 'red';
  return (
    <Card withBorder data-testid={`indicator-${name}`}>
      <Tooltip label={t(`coverage.formula.${name}`)} multiline w={300}>
        <Text size="sm" fw={600}>
          {t(`coverage.${name}`)}
        </Text>
      </Tooltip>
      <Text size="xl" fw={700} data-testid={`indicator-${name}-value`}>
        {percent(indicator.percent, i18n.language)}
      </Text>
      <LabeledProgress value={value} color={color} mt={4} label={t(`coverage.${name}`)} />
      <Text size="xs" c="dimmed" mt={4}>
        {new Intl.NumberFormat(i18n.language, { maximumFractionDigits: 1 }).format(indicator.numerator)} / {indicator.denominator}
      </Text>
    </Card>
  );
}
