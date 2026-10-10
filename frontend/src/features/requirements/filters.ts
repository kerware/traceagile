import type { Priority, RequirementFilters, RequirementStatus, RequirementType, RiskLevel, VerificationStatus } from '../../api/requirements';

/** F-REQ-01 filtres de la vue liste, reflétés dans l'URL (§11.4). */
export function filtersFromParams(params: URLSearchParams): RequirementFilters {
  const filters: RequirementFilters = {};
  const type = params.getAll('type') as RequirementType[];
  const status = params.getAll('status') as RequirementStatus[];
  const priority = params.getAll('priority') as Priority[];
  const risk = params.getAll('risk') as RiskLevel[];
  const verification = params.getAll('verification') as VerificationStatus[];
  if (type.length) filters.type = type;
  if (status.length) filters.status = status;
  if (priority.length) filters.priority = priority;
  if (risk.length) filters.risk = risk;
  if (verification.length) filters.verification = verification;
  if (params.get('tag')) filters.tag = params.get('tag')!;
  if (params.get('q')) filters.q = params.get('q')!;
  return filters;
}

export function hasFilters(filters: RequirementFilters): boolean {
  return Object.keys(filters).length > 0;
}
