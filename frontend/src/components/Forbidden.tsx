import { Alert } from '@mantine/core';
import { IconLock } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';

/** §2.2 Message explicite pour une action refusée (HTTP 403). */
export function Forbidden() {
  const { t } = useTranslation();
  return (
    <Alert color="red" icon={<IconLock size={18} />} data-testid="forbidden">
      {t('errors.forbidden')}
    </Alert>
  );
}
