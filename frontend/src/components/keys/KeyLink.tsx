import { Anchor, Badge, Group, HoverCard, Loader, Stack, Text } from '@mantine/core';
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { useItemPreview } from '../../api/workshop';
import { routeOf, splitKeys } from './keys';

/**
 * §13.1 clé cliquable avec aperçu au survol (type, titre, précision, statut), chargé à la demande
 * (ADR-0024). Sans route connue, la clé reste un simple texte.
 */
export function KeyLink({ project, itemKey, children, size = 'sm' }: { project: string; itemKey: string; children?: ReactNode; size?: string }) {
  const [opened, setOpened] = useState(false);
  const route = routeOf(project, itemKey);
  if (!route) return <>{children ?? itemKey}</>;
  return (
    <HoverCard openDelay={350} width={300} shadow="md" withinPortal onOpen={() => setOpened(true)}>
      <HoverCard.Target>
        <Anchor component={Link} to={route} ff="monospace" fw={600} size={size} data-testid={`key-${itemKey}`}>
          {children ?? itemKey}
        </Anchor>
      </HoverCard.Target>
      <HoverCard.Dropdown>
        <Preview project={project} itemKey={itemKey} enabled={opened} />
      </HoverCard.Dropdown>
    </HoverCard>
  );
}

function Preview({ project, itemKey, enabled }: { project: string; itemKey: string; enabled: boolean }) {
  const { t } = useTranslation();
  const { data, isLoading, error } = useItemPreview(project, itemKey, enabled);
  if (isLoading) return <Loader size="xs" />;
  if (error || !data) return <Text size="sm" c="dimmed">{t('search.notFound', { key: itemKey })}</Text>;
  return (
    <Stack gap={4} data-testid={`key-preview-${itemKey}`}>
      <Group gap={6}>
        <Badge size="xs" variant="light">
          {t(`search.type.${data.type}`)}
        </Badge>
        <Text size="xs" ff="monospace" fw={700}>
          {data.key}
        </Text>
      </Group>
      <Text size="sm" fw={500}>
        {data.title}
      </Text>
      {(data.detail || data.status) && (
        <Text size="xs" c="dimmed">
          {[data.detail, data.status].filter(Boolean).join(' · ')}
        </Text>
      )}
    </Stack>
  );
}

/** Texte dont les clés citées deviennent des {@link KeyLink}. */
export function LinkedText({ project, text }: { project: string; text: string }) {
  return (
    <>
      {splitKeys(text).map((part, index) =>
        part.key ? <KeyLink key={index} project={project} itemKey={part.text} /> : <span key={index}>{part.text}</span>,
      )}
    </>
  );
}
