import { Badge } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { TestCaseStatus, TestKind, TestTechnique } from '../../api/testcases';
import { KIND_COLORS, TEST_STATUS_COLORS } from './model';

/** Pastilles des tests : couleur toujours doublée d'un libellé (§13.3). */

export function KindBadge({ kind }: { kind: TestKind }) {
  const { t } = useTranslation();
  return (
    <Badge color={KIND_COLORS[kind]} variant="outline" size="sm">
      {t(`testKind.${kind}`)}
    </Badge>
  );
}

export function TestStatusBadge({ status }: { status: TestCaseStatus }) {
  const { t } = useTranslation();
  return (
    <Badge color={TEST_STATUS_COLORS[status]} variant="light" data-testid="test-status-badge">
      {t(`testStatus.${status}`)}
    </Badge>
  );
}

export function TechniqueBadge({ technique }: { technique?: TestTechnique | null }) {
  const { t } = useTranslation();
  if (!technique) return null;
  return (
    <Badge color="cyan" variant="light" size="sm">
      {t(`technique.${technique}`)}
    </Badge>
  );
}
