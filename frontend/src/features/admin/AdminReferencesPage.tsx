import { Button, Group, Loader, Paper, SimpleGrid, Stack, TagsInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useFrameworks, useReplaceFrameworks, type TestTechnique } from '../../api/testcases';
import { TECHNIQUES } from '../tests/model';
import { AdminTabs } from './AdminTabs';

/** §13.2 /admin référentiels — F-AUT-01 frameworks proposés pour chaque technique. */
export function AdminReferencesPage() {
  const { t } = useTranslation();
  const { data, isLoading } = useFrameworks();
  return (
    <Stack>
      <AdminTabs value="references" />
      <Title order={4}>{t('references.frameworks')}</Title>
      {isLoading && <Loader />}
      {data && (
        <SimpleGrid cols={{ base: 1, md: 2 }}>
          {TECHNIQUES.map((technique) => (
            <FrameworkEditor key={technique} technique={technique} initial={data.filter((f) => f.technique === technique).map((f) => f.name)} />
          ))}
        </SimpleGrid>
      )}
    </Stack>
  );
}

function FrameworkEditor({ technique, initial }: { technique: TestTechnique; initial: string[] }) {
  const { t } = useTranslation();
  const replace = useReplaceFrameworks();
  const [names, setNames] = useState(initial);
  useEffect(() => setNames(initial), [initial.join('|')]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <Paper withBorder p="sm" data-testid={`frameworks-${technique}`}>
      <Stack gap="xs">
        <TagsInput label={t(`technique.${technique}`)} value={names} onChange={setNames} />
        <Group justify="flex-end">
          <Button
            size="xs"
            loading={replace.isPending}
            disabled={names.join('|') === initial.join('|')}
            onClick={() =>
              replace.mutate(
                { technique, names },
                {
                  onSuccess: () => notifications.show({ color: 'green', message: t('references.saved') }),
                  onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
                },
              )
            }
          >
            {t('references.save')}
          </Button>
        </Group>
      </Stack>
    </Paper>
  );
}
