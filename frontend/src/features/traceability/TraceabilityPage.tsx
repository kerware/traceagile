import { Stack, Tabs, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useParams, useSearchParams } from 'react-router-dom';
import type { TestKind } from '../../api/testcases';
import type { MatrixOptions } from '../../api/traceability';
import { CoverageView } from './CoverageView';
import { ImpactView } from './ImpactView';
import { MatrixView } from './MatrixView';
import { OrphansView } from './OrphansView';

const TABS = ['matrix', 'coverage', 'orphans', 'impact'] as const;
type Tab = (typeof TABS)[number];

/**
 * §13.2 /p/:key/traceability — matrice (F-TRA-04, F-TRA-08), couverture (§7.2), orphelins
 * (F-TRA-06) et analyse d'impact (F-TRA-07). Onglet et options dans l'URL.
 */
export function TraceabilityPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const tab: Tab = TABS.includes(params.get('tab') as Tab) ? (params.get('tab') as Tab) : 'matrix';
  const scope = params.get('scope') ?? 'project';
  const options: MatrixOptions = { scope, allTests: params.get('tests') === 'all', kind: params.getAll('kind') as TestKind[] };

  const update = (changes: Record<string, string | string[] | null>) => {
    const next = new URLSearchParams(params);
    Object.entries(changes).forEach(([name, value]) => {
      next.delete(name);
      if (Array.isArray(value)) value.forEach((v) => next.append(name, v));
      else if (value) next.set(name, value);
    });
    setParams(next, { replace: true });
  };

  return (
    <Stack>
      <Title order={2}>{t('traceability.title')}</Title>
      <Tabs value={tab} onChange={(value) => update({ tab: value === 'matrix' ? null : value })} keepMounted={false}>
        <Tabs.List>
          {TABS.map((name) => (
            <Tabs.Tab key={name} value={name} data-testid={`traceability-tab-${name}`}>
              {t(`traceability.tabs.${name}`)}
            </Tabs.Tab>
          ))}
        </Tabs.List>
        <Tabs.Panel value="matrix" pt="md">
          <MatrixView
            project={project}
            options={options}
            onOptions={(o) => update({ scope: o.scope === 'project' ? null : o.scope ?? null, tests: o.allTests ? 'all' : null, kind: o.kind ?? [] })}
          />
        </Tabs.Panel>
        <Tabs.Panel value="coverage" pt="md">
          <CoverageView project={project} scope={scope} onScope={(s) => update({ scope: s === 'project' ? null : s })} />
        </Tabs.Panel>
        <Tabs.Panel value="orphans" pt="md">
          <OrphansView project={project} />
        </Tabs.Panel>
        <Tabs.Panel value="impact" pt="md">
          <ImpactView project={project} requirementKey={params.get('requirement')} onRequirement={(key) => update({ requirement: key })} />
        </Tabs.Panel>
      </Tabs>
    </Stack>
  );
}
