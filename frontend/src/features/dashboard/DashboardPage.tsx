import { Alert, Loader, Stack, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import { useProject } from '../../api/queries';
import { Forbidden } from '../../components/Forbidden';
import { ApiError } from '../../api/errors';

/** §13.2 /p/:key/dashboard — squelette ; widgets du §9.1 au lot 8. */
export function DashboardPage() {
  const { t } = useTranslation();
  const key = useParams().key!;
  const { data, error, isLoading } = useProject(key);

  if (isLoading) return <Loader />;
  if (error instanceof ApiError && error.status === 403) return <Forbidden />;

  return (
    <Stack>
      <Title order={2}>{t('dashboard.welcome', { name: data?.name ?? key })}</Title>
      <Alert color="gray" data-testid="dashboard-placeholder">
        {t('dashboard.body')}
      </Alert>
    </Stack>
  );
}
