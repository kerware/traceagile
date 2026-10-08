import { ActionIcon, Button, Group, Input, Stack, TextInput } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';

/** F-AUT-03 prérequis d'environnement en paires clé / valeur. */
export function KeyValueEditor({
  label,
  description,
  value,
  onChange,
  readOnly,
}: {
  label: string;
  description?: string;
  value: Record<string, string>;
  onChange: (value: Record<string, string>) => void;
  readOnly: boolean;
}) {
  const { t } = useTranslation();
  const entries = Object.entries(value);
  const set = (next: [string, string][]) => onChange(Object.fromEntries(next));

  return (
    <Input.Wrapper label={label} description={description}>
      <Stack gap={4} mt={4} data-testid="key-value-editor">
        {entries.map(([key, val], index) => (
          <Group key={index} wrap="nowrap">
            <TextInput
              placeholder={t('automation.key')}
              aria-label={t('automation.key')}
              value={key}
              onChange={(e) => set(entries.map((entry, i) => (i === index ? [e.currentTarget.value, entry[1]] : entry)))}
              readOnly={readOnly}
            />
            <TextInput
              flex={1}
              placeholder={t('automation.value')}
              aria-label={t('automation.value')}
              value={val}
              onChange={(e) => set(entries.map((entry, i) => (i === index ? [entry[0], e.currentTarget.value] : entry)))}
              readOnly={readOnly}
            />
            {!readOnly && (
              <ActionIcon variant="subtle" color="red" onClick={() => set(entries.filter((_, i) => i !== index))} aria-label={t('grid.removeRow')}>
                <IconTrash size={14} />
              </ActionIcon>
            )}
          </Group>
        ))}
        {!readOnly && (
          <Group>
            <Button
              size="xs"
              variant="light"
              leftSection={<IconPlus size={14} />}
              onClick={() => set([...entries, [`cle${entries.length + 1}`, '']])}
              data-testid="key-value-add"
            >
              {t('automation.addPair')}
            </Button>
          </Group>
        )}
      </Stack>
    </Input.Wrapper>
  );
}
