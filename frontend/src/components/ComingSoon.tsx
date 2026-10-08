import { Alert, Stack, Title } from '@mantine/core';
import { IconHourglass } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import type { NavId } from '../layouts/navigation';

/** Emplacement réservé d'un écran livré par un lot ultérieur (§16.2). */
export function ComingSoon({ screen, lot }: { screen: NavId; lot: number }) {
  const { t } = useTranslation();
  return (
    <Stack>
      <Title order={2}>{t(`nav.${screen}`)}</Title>
      <Alert icon={<IconHourglass size={18} />} color="gray" data-testid="coming-soon">
        {t('comingSoon.body', { lot })}
      </Alert>
    </Stack>
  );
}
