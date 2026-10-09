import { Badge, ColorSwatch, Group, Text, Tooltip } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { VerificationStatus } from '../../api/traceability';
import { VERIFICATION_COLORS } from './model';

/** §7.3 pastille de couleur du statut de vérification ; {@code compact} : pastille seule avec info-bulle. */
export function VerificationBadge({ status, compact = false, testId }: { status: VerificationStatus; compact?: boolean; testId?: string }) {
  const { t } = useTranslation();
  const color = `var(--mantine-color-${VERIFICATION_COLORS[status]}-6)`;
  if (compact) {
    return (
      <Tooltip label={`${t(`verification.${status}`)} — ${t(`verification.hint.${status}`)}`}>
        <ColorSwatch color={color} size={12} aria-label={t(`verification.${status}`)} data-testid={testId} data-status={status} />
      </Tooltip>
    );
  }
  return (
    <Tooltip label={t(`verification.hint.${status}`)}>
      <Badge variant="light" color={VERIFICATION_COLORS[status]} data-testid={testId} data-status={status}
        leftSection={<ColorSwatch color={color} size={8} withShadow={false} />}>
        {t(`verification.${status}`)}
      </Badge>
    </Tooltip>
  );
}

/** Légende des sept statuts (§7.3). */
export function VerificationLegend() {
  const { t } = useTranslation();
  return (
    <Group gap="md" data-testid="verification-legend">
      {(Object.keys(VERIFICATION_COLORS) as VerificationStatus[]).map((status) => (
        <Group key={status} gap={4}>
          <ColorSwatch color={`var(--mantine-color-${VERIFICATION_COLORS[status]}-6)`} size={10} withShadow={false} />
          <Text size="xs">{t(`verification.${status}`)}</Text>
        </Group>
      ))}
    </Group>
  );
}
