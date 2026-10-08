import { ActionIcon, Anchor, Badge, Button, Group, MultiSelect, Select, Stack, Text } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlus, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useRequirement, useRequirementTree } from '../../api/requirements';
import { useReplaceTestLinks, type LinkType, type TestCaseDetail } from '../../api/testcases';
import { flatten } from '../requirements/model';

type Row = Schemas['LinkRequest'] & { origin?: string };
const LINK_TYPES: LinkType[] = ['VERIFIES', 'PARTIALLY_VERIFIES', 'RELATES_TO'];

/** F-TRA-01 à F-TRA-03 exigences (et critères) vérifiées par le test. */
export function TestLinksTab({ project, test, canWrite }: { project: string; test: TestCaseDetail; canWrite: boolean }) {
  const { t } = useTranslation();
  const { data: tree } = useRequirementTree(project);
  const replace = useReplaceTestLinks(project, test.key);
  const [rows, setRows] = useState<Row[]>(() =>
    test.requirements.map((r) => ({ requirementKey: r.requirementKey, linkType: r.linkType, criterionPositions: r.criterionPositions, origin: r.origin })),
  );
  const options = flatten(tree ?? []).map((n) => ({ value: n.key, label: `${n.key} — ${n.title}` }));
  const update = (index: number, patch: Partial<Row>) => setRows((list) => list.map((row, i) => (i === index ? { ...row, ...patch } : row)));

  const save = () =>
    replace.mutate(
      rows.filter((r) => r.requirementKey).map(({ requirementKey, linkType, criterionPositions }) => ({ requirementKey, linkType, criterionPositions: criterionPositions ?? [] })),
      {
        onSuccess: () => notifications.show({ color: 'green', message: t('links.saved') }),
        onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }),
      },
    );

  return (
    <Stack data-testid="test-links">
      {rows.length === 0 && <Text c="dimmed">{t('links.empty')}</Text>}
      {rows.map((row, index) =>
        canWrite ? (
          <Group key={index} align="flex-end" wrap="nowrap">
            <Select
              w={320}
              label={index === 0 ? t('links.requirement') : undefined}
              data={options}
              value={row.requirementKey || null}
              onChange={(value) => update(index, { requirementKey: value ?? '', criterionPositions: [] })}
              searchable
              data-testid={`link-requirement-${index}`}
            />
            <Select
              w={200}
              label={index === 0 ? t('links.type') : undefined}
              data={LINK_TYPES.map((value) => ({ value, label: t(`linkType.${value}`) }))}
              value={row.linkType}
              onChange={(value) => value && update(index, { linkType: value as LinkType })}
              allowDeselect={false}
              data-testid={`link-type-${index}`}
            />
            <CriteriaSelect
              project={project}
              requirementKey={row.requirementKey}
              value={row.criterionPositions ?? []}
              onChange={(criterionPositions) => update(index, { criterionPositions })}
              label={index === 0 ? t('links.criteria') : undefined}
            />
            {row.origin && row.origin !== 'MANUAL' && <Badge variant="outline">{t(`linkOrigin.${row.origin}`)}</Badge>}
            <ActionIcon variant="subtle" color="red" onClick={() => setRows((list) => list.filter((_, i) => i !== index))} aria-label={t('admin.remove')}>
              <IconTrash size={16} />
            </ActionIcon>
          </Group>
        ) : (
          <Group key={index} gap="xs">
            <Anchor component={Link} to={`/p/${project}/requirements/${row.requirementKey}`} ff="monospace" fw={600}>
              {row.requirementKey}
            </Anchor>
            <Text size="sm">{test.requirements[index]?.requirementTitle}</Text>
            <Badge variant="light">{t(`linkType.${row.linkType}`)}</Badge>
            {(row.criterionPositions ?? []).length > 0 && <Text size="xs" c="dimmed">{t('linkedTests.criteria', { list: row.criterionPositions!.map((p) => `#${p}`).join(', ') })}</Text>}
          </Group>
        ),
      )}
      {canWrite && (
        <Group>
          <Button variant="default" leftSection={<IconPlus size={16} />} onClick={() => setRows((list) => [...list, { requirementKey: '', linkType: 'VERIFIES', criterionPositions: [] }])} data-testid="link-add">
            {t('links.add')}
          </Button>
          <Button onClick={save} loading={replace.isPending} data-testid="links-save">
            {t('links.save')}
          </Button>
        </Group>
      )}
    </Stack>
  );
}

/** F-TRA-03 critères vérifiés, parmi ceux de l'exigence choisie. */
function CriteriaSelect({
  project,
  requirementKey,
  value,
  onChange,
  label,
}: {
  project: string;
  requirementKey: string;
  value: number[];
  onChange: (value: number[]) => void;
  label?: string;
}) {
  const { data: requirement } = useRequirement(project, requirementKey || null);
  return (
    <MultiSelect
      w={240}
      label={label}
      data={(requirement?.criteria ?? []).map((c) => ({ value: String(c.position), label: `#${c.position} ${c.content.split('\n')[0]!.slice(0, 50)}` }))}
      value={value.map(String)}
      onChange={(list) => onChange(list.map(Number))}
      disabled={!requirementKey}
      clearable
    />
  );
}
