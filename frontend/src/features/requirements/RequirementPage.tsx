import { Anchor, Stack } from '@mantine/core';
import { IconArrowLeft } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import { RequirementDetailView } from './RequirementDetailView';

/** §13.2 /p/:key/requirements/:rk — fiche exigence en pleine page. */
export function RequirementPage() {
  const { t } = useTranslation();
  const { key, rk } = useParams();
  return (
    <Stack>
      <Anchor component={Link} to={`/p/${key}/backlog`} size="sm">
        <IconArrowLeft size={14} /> {t('backlog.title')}
      </Anchor>
      <RequirementDetailView key={rk} project={key!} requirementKey={rk!} />
    </Stack>
  );
}
