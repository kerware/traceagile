import { Badge, Group, Kbd, Modal, ScrollArea, Stack, Text, TextInput, UnstyledButton } from '@mantine/core';
import { useDebouncedValue } from '@mantine/hooks';
import { IconSearch } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useSearch, type SearchHit } from '../../api/workshop';
import { routeOf } from '../keys/keys';

/**
 * §13.1 recherche globale ({@code Ctrl+K}) : clés et titres des exigences, tests, campagnes, anomalies,
 * runs, rapports, sprints et releases ; flèches pour choisir, Entrée pour ouvrir (ADR-0024).
 */
export function SearchSpotlight({ project, opened, onClose }: { project: string | null; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [q, setQ] = useState('');
  const [debounced] = useDebouncedValue(q, 150);
  const [active, setActive] = useState(0);
  const { data, isFetching } = useSearch(project, debounced);
  const hits = debounced.trim().length >= 2 ? (data ?? []) : [];

  useEffect(() => {
    if (opened) {
      setQ('');
      setActive(0);
    }
  }, [opened]);
  useEffect(() => setActive(0), [debounced]);

  const open = (hit: SearchHit) => {
    const route = project ? routeOf(project, hit.key) : null;
    if (route) {
      onClose();
      navigate(route);
    }
  };
  const onKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      setActive((i) => Math.min(i + 1, hits.length - 1));
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      setActive((i) => Math.max(i - 1, 0));
    } else if (event.key === 'Enter' && hits[active]) {
      event.preventDefault();
      open(hits[active]);
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} size="lg" yOffset="10vh" padding="sm" title={t('search.title')}>
      <Stack gap="xs">
        <TextInput
          data-autofocus
          value={q}
          onChange={(e) => setQ(e.currentTarget.value)}
          onKeyDown={onKeyDown}
          placeholder={project ? t('search.placeholder') : t('search.noProject')}
          disabled={!project}
          leftSection={<IconSearch size={16} />}
          rightSection={<Kbd size="xs">Esc</Kbd>}
          aria-label={t('search.title')}
          data-testid="search-input"
        />
        <ScrollArea.Autosize mah={420}>
          <Stack gap={2} role="listbox" aria-label={t('search.results')} data-testid="search-results">
            {hits.map((hit, index) => (
              <UnstyledButton
                key={hit.key}
                role="option"
                aria-selected={index === active}
                onClick={() => open(hit)}
                onMouseEnter={() => setActive(index)}
                p={6}
                style={{ borderRadius: 4, background: index === active ? 'var(--mantine-color-blue-light)' : undefined }}
                data-testid={`search-hit-${hit.key}`}
              >
                <Group gap="xs" wrap="nowrap">
                  <Badge size="xs" variant="light" w={92}>
                    {t(`search.type.${hit.type}`)}
                  </Badge>
                  <Text size="sm" ff="monospace" fw={700} w={70}>
                    {hit.key}
                  </Text>
                  <Text size="sm" truncate style={{ flex: 1 }}>
                    {hit.title}
                  </Text>
                  {hit.detail && (
                    <Text size="xs" c="dimmed">
                      {hit.detail}
                    </Text>
                  )}
                </Group>
              </UnstyledButton>
            ))}
            {debounced.trim().length >= 2 && !isFetching && hits.length === 0 && (
              <Text size="sm" c="dimmed" p="xs" data-testid="search-empty">
                {t('search.empty', { q: debounced })}
              </Text>
            )}
            {debounced.trim().length < 2 && (
              <Text size="xs" c="dimmed" p="xs">
                {t('search.hint')}
              </Text>
            )}
          </Stack>
        </ScrollArea.Autosize>
      </Stack>
    </Modal>
  );
}
