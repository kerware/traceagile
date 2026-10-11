import { Badge } from '@mantine/core';
import type { JobStatus, TestStatus, ToolStatus } from '../api';
import { JOB_STATUS, TEST_STATUS, TOOL_STATUS } from './labels';

export function JobStatusBadge({ status }: { status: JobStatus }) {
  const s = JOB_STATUS[status];
  return (
    <Badge color={s.color} variant="light" data-status={status}>
      {s.label}
    </Badge>
  );
}

export function TestStatusBadge({ status }: { status: TestStatus }) {
  const s = TEST_STATUS[status];
  return (
    <Badge color={s.color} variant={status === 'PASSED' || status === 'FAILED' || status === 'ERROR' ? 'filled' : 'light'} data-status={status}>
      {s.label}
    </Badge>
  );
}

export function ToolStatusBadge({ status }: { status: ToolStatus }) {
  const s = TOOL_STATUS[status];
  return (
    <Badge color={s.color} variant="light" data-status={status}>
      {s.label}
    </Badge>
  );
}
