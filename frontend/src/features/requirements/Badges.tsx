import { Anchor, Badge } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import type { Priority, RequirementStatus, RequirementType, RiskLevel } from '../../api/requirements';
import { PRIORITY_COLORS, RISK_COLORS, STATUS_COLORS, TYPE_COLORS } from './model';

/** Pastilles : la couleur est toujours doublée d'un libellé (§13.3). */

export function StatusBadge({ status }: { status: RequirementStatus }) {
  const { t } = useTranslation();
  return (
    <Badge color={STATUS_COLORS[status]} variant="light" data-testid="status-badge">
      {t(`requirementStatus.${status}`)}
    </Badge>
  );
}

export function TypeBadge({ type }: { type: RequirementType }) {
  const { t } = useTranslation();
  return (
    <Badge color={TYPE_COLORS[type]} variant="outline" size="sm">
      {t(`requirementType.${type}`)}
    </Badge>
  );
}

export function PriorityBadge({ priority }: { priority: Priority }) {
  const { t } = useTranslation();
  return (
    <Badge color={PRIORITY_COLORS[priority]} variant="dot" size="sm">
      {t(`priority.${priority}`)}
    </Badge>
  );
}

export function RiskBadge({ risk }: { risk: RiskLevel }) {
  const { t } = useTranslation();
  return (
    <Badge color={RISK_COLORS[risk]} variant="light" size="sm">
      {t(`risk.${risk}`)}
    </Badge>
  );
}

/** §13.1 clés cliquables partout. */
export function RequirementKeyLink({ project, requirementKey }: { project: string; requirementKey: string }) {
  return (
    <Anchor component={Link} to={`/p/${project}/requirements/${requirementKey}`} fw={600} size="sm" ff="monospace">
      {requirementKey}
    </Anchor>
  );
}
