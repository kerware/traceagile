import { Alert } from '@mantine/core';
import { useTranslation } from 'react-i18next';

export function NotFound() {
  const { t } = useTranslation();
  return (
    <Alert color="gray" data-testid="not-found">
      {t('errors.notFound')}
    </Alert>
  );
}
