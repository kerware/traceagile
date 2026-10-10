import { Alert, Badge, Box, Button, Group, Loader, Modal, MultiSelect, ScrollArea, SegmentedControl, Stack, Switch, Table, Text, Tooltip, UnstyledButton } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle, IconCheck, IconDownload, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import type { TestKind } from '../../api/testcases';
import {
  downloadMatrix,
  useCreateLink,
  useDeleteLink,
  useMatrix,
  useReviewLink,
  useUpdateLink,
  type LinkType,
  type MatrixCell,
  type MatrixOptions,
} from '../../api/traceability';
import { KIND_COLORS, TEST_KINDS } from '../tests/model';
import { useTestWriteKinds } from '../tests/permissions';
import { cellColor, LINK_CODES, LINK_TYPES } from './model';
import classes from './MatrixView.module.css';
import { ScopeSelect } from './ScopeSelect';
import { VerificationBadge, VerificationLegend } from './VerificationBadge';

/**
 * F-TRA-04 matrice exigences (lignes, dans l'ordre de l'arbre) × tests (colonnes). Cellule : type de
 * lien (V, PV, R), dernier résultat, alerte de suspicion. Clic sur une cellule vide = lien « vérifie » ;
 * clic sur une cellule liée = changer le type, marquer revu, supprimer. Export CSV / PDF (F-TRA-08).
 */
export function MatrixView({ project, options, onOptions }: { project: string; options: MatrixOptions; onOptions: (o: MatrixOptions) => void }) {
  const { t } = useTranslation();
  const { data, isLoading, error } = useMatrix(project, options);
  const writableKinds = useTestWriteKinds(project);
  const create = useCreateLink(project);
  const [selected, setSelected] = useState<MatrixCell | null>(null);

  const cells = new Map((data?.cells ?? []).map((c) => [`${c.requirementKey}|${c.testKey}`, c]));
  const kindOf = new Map((data?.tests ?? []).map((test) => [test.key, test.kind]));

  const link = (requirementKey: string, testKey: string) =>
    create.mutate(
      { requirementKey, testKey, linkType: 'VERIFIES' },
      {
        onSuccess: () => notifications.show({ color: 'green', message: t('traceability.linked', { test: testKey, requirement: requirementKey }) }),
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );
  const exportAs = (format: 'csv' | 'pdf') =>
    downloadMatrix(project, format, options).catch((e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }));

  return (
    <Stack>
      <Group align="flex-end" justify="space-between">
        <Group align="flex-end">
          <ScopeSelect project={project} value={options.scope ?? 'project'} onChange={(scope) => onOptions({ ...options, scope })} />
          <MultiSelect
            label={t('traceability.kinds')}
            data={TEST_KINDS.map((k) => ({ value: k, label: t(`testKind.${k}`) }))}
            value={options.kind ?? []}
            onChange={(kind) => onOptions({ ...options, kind: kind as TestKind[] })}
            clearable
            w={260}
            data-testid="matrix-kinds"
          />
          <Switch
            label={t('traceability.allTests')}
            description={t('traceability.allTestsHint')}
            checked={!!options.allTests}
            onChange={(e) => onOptions({ ...options, allTests: e.currentTarget.checked })}
            data-testid="matrix-all-tests"
          />
        </Group>
        <Group>
          <Button variant="default" leftSection={<IconDownload size={16} />} onClick={() => exportAs('csv')} data-testid="matrix-export-csv">
            CSV
          </Button>
          <Button variant="default" leftSection={<IconDownload size={16} />} onClick={() => exportAs('pdf')} data-testid="matrix-export-pdf">
            PDF
          </Button>
        </Group>
      </Group>
      <Group justify="space-between">
        <VerificationLegend />
        <Text size="xs" c="dimmed">
          {t('traceability.cellLegend')}
        </Text>
      </Group>

      {isLoading && <Loader />}
      {error && (
        <Alert color="red" icon={<IconAlertTriangle size={16} />}>
          {errorMessage(error, t('errors.generic'))}
        </Alert>
      )}
      {data && data.tests.length === 0 && (
        <Text c="dimmed" data-testid="matrix-no-tests">
          {t('traceability.noTests')}
        </Text>
      )}
      {data && data.tests.length > 0 && (
        <ScrollArea type="auto" offsetScrollbars data-testid="matrix">
          <Table withTableBorder withColumnBorders striped highlightOnHover style={{ width: 'max-content' }}>
            <Table.Thead>
              <Table.Tr>
                <Table.Th style={{ position: 'sticky', left: 0, zIndex: 2, background: 'var(--mantine-color-body)', minWidth: 360 }}>
                  {t('traceability.requirement')}
                </Table.Th>
                {data.tests.map((test) => (
                  <Table.Th key={test.key} p={4} style={{ verticalAlign: 'bottom' }}>
                    <Tooltip label={`${test.key} — ${test.title}`}>
                      <Box
                        component={Link}
                        to={`/p/${project}/tests/${test.key}`}
                        style={{ writingMode: 'vertical-rl', transform: 'rotate(180deg)', whiteSpace: 'nowrap', textDecoration: 'none' }}
                        c={`${KIND_COLORS[test.kind]}.9`}
                        ff="monospace"
                        fz="xs"
                        fw={600}
                        data-testid={`matrix-test-${test.key}`}
                      >
                        {test.key}
                      </Box>
                    </Tooltip>
                  </Table.Th>
                ))}
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {data.requirements.map((row) => (
                <Table.Tr key={row.key} data-testid={`matrix-row-${row.key}`}>
                  <Table.Td style={{ position: 'sticky', left: 0, zIndex: 1, background: 'var(--mantine-color-body)' }}>
                    <Group gap={6} wrap="nowrap" pl={row.depth * 16}>
                      <VerificationBadge status={row.verificationStatus} compact testId={`matrix-status-${row.key}`} />
                      <Text ff="monospace" fw={row.leaf ? 500 : 700} size="xs" component={Link} to={`/p/${project}/requirements/${row.key}`} c="inherit" td="none">
                        {row.key}
                      </Text>
                      <Text size="xs" fw={row.leaf ? 400 : 600} truncate maw={260} title={row.title}>
                        {row.title}
                      </Text>
                    </Group>
                  </Table.Td>
                  {data.tests.map((test) => {
                    const cell = cells.get(`${row.key}|${test.key}`);
                    const id = `matrix-cell-${row.key}-${test.key}`;
                    if (cell) {
                      return (
                        <Table.Td key={test.key} p={2} ta="center">
                          <UnstyledButton onClick={() => setSelected(cell)} data-testid={id} aria-label={t('traceability.cellLabel', { requirement: row.key, test: test.key })}>
                            <Badge size="sm" radius="sm" variant={cell.linkType === 'RELATES_TO' ? 'outline' : 'light'} color={cellColor(cell)}
                              rightSection={cell.suspect ? <IconAlertTriangle size={10} /> : undefined}>
                              {LINK_CODES[cell.linkType]}
                            </Badge>
                          </UnstyledButton>
                        </Table.Td>
                      );
                    }
                    const writable = writableKinds.includes(kindOf.get(test.key)!);
                    return (
                      <Table.Td key={test.key} p={2} ta="center">
                        {writable && (
                          <Tooltip label={t('traceability.createLink', { requirement: row.key, test: test.key })} openDelay={400}>
                            <UnstyledButton
                              w={24}
                              h={18}
                              onClick={() => link(row.key, test.key)}
                              disabled={create.isPending}
                              data-testid={id}
                              aria-label={t('traceability.createLink', { requirement: row.key, test: test.key })}
                              style={{ borderRadius: 4 }}
                              className={classes.empty}
                            />
                          </Tooltip>
                        )}
                      </Table.Td>
                    );
                  })}
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </ScrollArea>
      )}
      <LinkModal project={project} cell={selected} writable={!!selected && writableKinds.includes(kindOf.get(selected.testKey)!)} onClose={() => setSelected(null)} />
    </Stack>
  );
}

/** Lien existant : type (F-TRA-02), revue de la suspicion (§3.3-7), suppression. */
function LinkModal({ project, cell, writable, onClose }: { project: string; cell: MatrixCell | null; writable: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const update = useUpdateLink(project);
  const review = useReviewLink(project);
  const remove = useDeleteLink(project);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  return (
    <Modal opened={!!cell} onClose={onClose} title={cell ? t('traceability.linkTitle', { test: cell.testKey, requirement: cell.requirementKey }) : ''}>
      {cell && (
        <Stack>
          {cell.suspect && (
            <Alert color="violet" icon={<IconAlertTriangle size={16} />} data-testid="link-suspect">
              {t('traceability.suspectHint')}
            </Alert>
          )}
          <Text size="sm">
            {t('traceability.origin')} : {t(`linkOrigin.${cell.origin}`)}
            {cell.criterionPositions.length > 0 && ` · ${t('linkedTests.criteria', { list: cell.criterionPositions.map((p) => `#${p}`).join(', ') })}`}
            {cell.lastResult && ` · ${t('traceability.lastResult')} : ${t(`executionStatus.${cell.lastResult}`)}`}
          </Text>
          <SegmentedControl
            value={cell.linkType}
            disabled={!writable || update.isPending}
            data={LINK_TYPES.map((type) => ({ value: type, label: t(`linkType.${type}`) }))}
            onChange={(linkType) => update.mutate({ id: cell.linkId, linkType: linkType as LinkType }, { onSuccess: onClose, onError: fail })}
            data-testid="link-type"
          />
          {writable && (
            <Group justify="space-between">
              <Button color="red" variant="subtle" leftSection={<IconTrash size={16} />} loading={remove.isPending}
                onClick={() => remove.mutate(cell.linkId, { onSuccess: onClose, onError: fail })} data-testid="link-delete">
                {t('traceability.deleteLink')}
              </Button>
              {cell.suspect && (
                <Button color="violet" leftSection={<IconCheck size={16} />} loading={review.isPending}
                  onClick={() => review.mutate(cell.linkId, { onSuccess: onClose, onError: fail })} data-testid="link-review">
                  {t('traceability.markReviewed')}
                </Button>
              )}
            </Group>
          )}
        </Stack>
      )}
    </Modal>
  );
}
