import { Stack, Tabs, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useParams, useSearchParams } from 'react-router-dom';
import { useSprints } from '../../api/planning';
import { defaultSprint } from './model';
import { RoadmapView } from './RoadmapView';
import { SprintPlanningView } from './SprintPlanningView';

/** §13.2 /p/:key/planning — feuille de route (F-PLN-02) et planification de sprint (F-PLN-05). */
export function PlanningPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const { data: sprints } = useSprints(project);
  const tab = params.get('tab') === 'sprint' ? 'sprint' : 'roadmap';
  const sprintKey = params.get('sprint') ?? defaultSprint(sprints ?? []);

  const update = (changes: Record<string, string | null>) => {
    const next = new URLSearchParams(params);
    Object.entries(changes).forEach(([name, value]) => (value ? next.set(name, value) : next.delete(name)));
    setParams(next, { replace: true });
  };

  return (
    <Stack>
      <Title order={2}>{t('planning.title')}</Title>
      <Tabs value={tab} onChange={(value) => update({ tab: value === 'sprint' ? 'sprint' : null })} keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="roadmap" data-testid="planning-tab-roadmap">
            {t('planning.roadmap')}
          </Tabs.Tab>
          <Tabs.Tab value="sprint" data-testid="planning-tab-sprint">
            {t('planning.sprintPlanning')}
          </Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="roadmap" pt="md">
          <RoadmapView project={project} onOpenSprint={(key) => update({ tab: 'sprint', sprint: key })} />
        </Tabs.Panel>
        <Tabs.Panel value="sprint" pt="md">
          <SprintPlanningView project={project} sprintKey={sprintKey} onSprint={(key) => update({ sprint: key })} />
        </Tabs.Panel>
      </Tabs>
    </Stack>
  );
}
