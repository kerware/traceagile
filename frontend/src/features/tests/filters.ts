import type { TestCaseStatus, TestFilters, TestKind, TestTechnique } from '../../api/testcases';

/** §12 filtres du référentiel, reflétés dans l'URL (§11.4). */
export function testFiltersFromParams(params: URLSearchParams): TestFilters {
  const filters: TestFilters = {};
  const kind = params.getAll('kind') as TestKind[];
  const technique = params.getAll('technique') as TestTechnique[];
  const status = params.getAll('status') as TestCaseStatus[];
  if (kind.length) filters.kind = kind;
  if (technique.length) filters.technique = technique;
  if (status.length) filters.status = status;
  if (params.get('tag')) filters.tag = params.get('tag')!;
  if (params.get('requirement')) filters.requirement = params.get('requirement')!;
  if (params.get('orphan') === 'true') filters.orphan = true;
  if (params.get('automationCandidate') === 'true') filters.automationCandidate = true;
  if (params.get('q')) filters.q = params.get('q')!;
  return filters;
}

export function hasTestFilters(filters: TestFilters): boolean {
  return Object.keys(filters).length > 0;
}
