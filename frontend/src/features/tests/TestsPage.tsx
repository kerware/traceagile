import { Anchor, Button, Checkbox, Drawer, Group, Menu, MultiSelect, SegmentedControl, Stack, TextInput, Title } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconChevronDown, IconDownload, IconPlus, IconSearch, IconUpload } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { downloadFeatures, type TestFilters } from '../../api/testcases';
import { CreateTestModal } from './CreateTestModal';
import { DiscoveryModal } from './DiscoveryModal';
import { hasTestFilters, testFiltersFromParams } from './filters';
import { ImportFeatureModal } from './ImportFeatureModal';
import { TECHNIQUES, TEST_KINDS, TEST_STATUSES } from './model';
import { useTestWriteKinds } from './permissions';
import { TestCaseDetailView } from './TestCaseDetailView';
import { TestList } from './TestList';
import { TestTree } from './TestTree';

/**
 * §13.2 /p/:key/tests — référentiel par dossier, par feature ou en liste filtrée (§12) ; import et
 * export .feature (F-AUT-07), rapport de découverte (F-AUT-08), fiche en panneau latéral (§13.1).
 */
export function TestsPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const [creating, createModal] = useDisclosure(false);
  const [createIn, setCreateIn] = useState<string | null>(null);
  const [importing, importModal] = useDisclosure(false);
  const [discovering, discoveryModal] = useDisclosure(false);
  const [search, setSearch] = useState(params.get('q') ?? '');
  const writableKinds = useTestWriteKinds(project);
  const canWriteAutomated = writableKinds.includes('AUTOMATED');

  const filters = testFiltersFromParams(params);
  const view = params.get('view') === 'list' || hasTestFilters(filters) ? 'list' : params.get('view') === 'feature' ? 'feature' : 'folder';
  const selected = params.get('selected');

  const update = (changes: Record<string, string | string[] | null>) => {
    const next = new URLSearchParams(params);
    Object.entries(changes).forEach(([name, value]) => {
      next.delete(name);
      if (Array.isArray(value)) value.forEach((v) => next.append(name, v));
      else if (value) next.set(name, value);
    });
    if (!('page' in changes)) next.delete('page');
    setParams(next);
  };
  const options = (values: string[], prefix: string) => values.map((value) => ({ value, label: t(`${prefix}.${value}`) }));

  const exportFeatures = () =>
    downloadFeatures(project).catch((error) => notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) }));

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('tests.title')}</Title>
        <Group>
          {writableKinds.length > 0 && (
            <Button leftSection={<IconPlus size={16} />} onClick={createModal.open} data-testid="tests-new">
              {t('tests.new')}
            </Button>
          )}
          <Menu position="bottom-end">
            <Menu.Target>
              <Button variant="default" rightSection={<IconChevronDown size={14} />} data-testid="tests-bdd-menu">
                .feature / {t('tests.discovery')}
              </Button>
            </Menu.Target>
            <Menu.Dropdown>
              {canWriteAutomated && (
                <Menu.Item leftSection={<IconUpload size={14} />} onClick={importModal.open} data-testid="tests-import-feature">
                  {t('tests.importFeature')}
                </Menu.Item>
              )}
              <Menu.Item leftSection={<IconDownload size={14} />} onClick={exportFeatures} data-testid="tests-export-feature">
                {t('tests.exportFeature')}
              </Menu.Item>
              {canWriteAutomated && (
                <Menu.Item leftSection={<IconUpload size={14} />} onClick={discoveryModal.open} data-testid="tests-discovery">
                  {t('tests.discovery')}
                </Menu.Item>
              )}
            </Menu.Dropdown>
          </Menu>
        </Group>
      </Group>

      <Group>
        <SegmentedControl
          value={view}
          onChange={(value) => update({ view: value })}
          data={[
            { value: 'folder', label: t('tests.byFolder') },
            { value: 'feature', label: t('tests.byFeature') },
            { value: 'list', label: t('tests.list') },
          ]}
          data-testid="tests-view"
        />
        <TextInput
          flex={1}
          leftSection={<IconSearch size={16} />}
          placeholder={t('tests.search')}
          aria-label={t('tests.search')}
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') update({ q: search.trim() || null, view: 'list' });
          }}
          data-testid="tests-search"
        />
      </Group>

      {view === 'list' && (
        <Group align="flex-end" data-testid="tests-filters">
          <MultiSelect label={t('tests.filterKind')} data={options(TEST_KINDS, 'testKind')} value={filters.kind ?? []} onChange={(v) => update({ kind: v, view: 'list' })} clearable w={200} data-testid="filter-kind" />
          <MultiSelect label={t('tests.filterTechnique')} data={options(TECHNIQUES, 'technique')} value={filters.technique ?? []} onChange={(v) => update({ technique: v, view: 'list' })} clearable w={220} data-testid="filter-technique" />
          <MultiSelect label={t('tests.filterStatus')} data={options(TEST_STATUSES, 'testStatus')} value={filters.status ?? []} onChange={(v) => update({ status: v, view: 'list' })} clearable w={200} data-testid="filter-status" />
          <TextInput
            label={t('tests.filterTag')}
            defaultValue={filters.tag ?? ''}
            onKeyDown={(e) => e.key === 'Enter' && update({ tag: e.currentTarget.value.trim() || null, view: 'list' })}
            onBlur={(e) => update({ tag: e.currentTarget.value.trim() || null, view: 'list' })}
            w={130}
            data-testid="filter-tag"
          />
          <TextInput
            label={t('tests.filterRequirement')}
            defaultValue={filters.requirement ?? ''}
            onKeyDown={(e) => e.key === 'Enter' && update({ requirement: e.currentTarget.value.trim() || null, view: 'list' })}
            onBlur={(e) => update({ requirement: e.currentTarget.value.trim() || null, view: 'list' })}
            w={150}
            data-testid="filter-requirement"
          />
          <Checkbox label={t('tests.orphans')} checked={filters.orphan ?? false} onChange={(e) => update({ orphan: e.currentTarget.checked ? 'true' : null, view: 'list' })} data-testid="filter-orphan" />
          <Checkbox
            label={t('tests.candidates')}
            checked={filters.automationCandidate ?? false}
            onChange={(e) => update({ automationCandidate: e.currentTarget.checked ? 'true' : null, sort: e.currentTarget.checked ? 'executionCount,desc' : null, view: 'list' })}
            data-testid="filter-candidates"
          />
          {hasTestFilters(filters) && (
            <Button
              variant="subtle"
              onClick={() => update({ kind: null, technique: null, status: null, tag: null, requirement: null, orphan: null, automationCandidate: null, q: null, view: 'list' })}
            >
              {t('tests.resetFilters')}
            </Button>
          )}
        </Group>
      )}

      {view === 'list' ? (
        <TestList
          project={project}
          filters={filters as TestFilters}
          page={Number(params.get('page') ?? 0)}
          sort={params.get('sort') ?? 'key,asc'}
          onSort={(sort) => update({ sort })}
          onPage={(p) => update({ page: String(p) })}
          onSelect={(key) => update({ selected: key, page: params.get('page') })}
        />
      ) : (
        <TestTree
          project={project}
          groupBy={view}
          writableKinds={writableKinds}
          onSelect={(key) => update({ selected: key })}
          onCreateTest={(folder) => {
            setCreateIn(folder);
            createModal.open();
          }}
        />
      )}

      <Drawer
        opened={selected !== null}
        onClose={() => update({ selected: null, page: params.get('page') })}
        position="right"
        size="xl"
        title={
          selected && (
            <Anchor component={Link} to={`/p/${project}/tests/${selected}`} data-testid="test-drawer-open-full">
              {t('tests.openFull')}
            </Anchor>
          )
        }
      >
        {selected && <TestCaseDetailView project={project} testKey={selected} />}
      </Drawer>

      <CreateTestModal
        project={project}
        opened={creating}
        onClose={() => {
          createModal.close();
          setCreateIn(null);
        }}
        kinds={writableKinds}
        initialFolder={createIn}
        onCreated={(key) => update({ selected: key })}
      />
      <ImportFeatureModal project={project} opened={importing} onClose={importModal.close} />
      <DiscoveryModal project={project} opened={discovering} onClose={discoveryModal.close} />
    </Stack>
  );
}
