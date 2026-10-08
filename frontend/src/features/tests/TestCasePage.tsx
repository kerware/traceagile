import { Anchor, Stack } from '@mantine/core';
import { IconArrowLeft } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import { TestCaseDetailView } from './TestCaseDetailView';

/** §13.2 /p/:key/tests/:tk — fiche test en pleine page. */
export function TestCasePage() {
  const { t } = useTranslation();
  const { key, tk } = useParams();
  return (
    <Stack>
      <Anchor component={Link} to={`/p/${key}/tests`} size="sm">
        <IconArrowLeft size={14} /> {t('tests.title')}
      </Anchor>
      <TestCaseDetailView key={tk} project={key!} testKey={tk!} />
    </Stack>
  );
}
