import { Select } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useRequirementTree } from '../../api/requirements';
import { scopeOptions } from './model';

/** §7.2 périmètre : projet, épic ou feature (releases et sprints au lot 4). */
export function ScopeSelect({ project, value, onChange }: { project: string; value: string; onChange: (scope: string) => void }) {
  const { t } = useTranslation();
  const { data: tree } = useRequirementTree(project);
  return (
    <Select
      label={t('traceability.scope')}
      description={t('traceability.scopeHint')}
      data={scopeOptions(tree ?? [], t('traceability.wholeProject'))}
      value={value}
      onChange={(scope) => onChange(scope ?? 'project')}
      allowDeselect={false}
      searchable
      w={360}
      data-testid="scope-select"
    />
  );
}
