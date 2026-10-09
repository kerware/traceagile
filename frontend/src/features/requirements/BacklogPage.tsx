import { Anchor, Button, Drawer, Group, SegmentedControl, Stack, TextInput, Title } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconDownload, IconPlus, IconSearch, IconUpload } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { errorMessage } from '../../api/errors';
import { downloadCsv, type RequirementFilters, type RequirementTreeNode } from '../../api/requirements';
import { CreateTestModal } from '../tests/CreateTestModal';
import { useTestWriteKinds } from '../tests/permissions';
import { BacklogFilters } from './BacklogFilters';
import { CreateRequirementModal } from './CreateRequirementModal';
import { filtersFromParams } from './filters';
import { defaultChildType } from './model';
import { ImportCsvModal } from './ImportCsvModal';
import { useCanWriteRequirements } from './permissions';
import { RequirementDetailView } from './RequirementDetailView';
import { RequirementList } from './RequirementList';
import { RequirementTree } from './RequirementTree';

/**
 * §13.2 /p/:key/backlog — vues arbre et liste (F-REQ-01), glisser-déposer (F-REQ-02/03),
 * recherche (F-REQ-04), import / export CSV (F-REQ-23), fiche en panneau latéral (§13.1).
 */
export function BacklogPage() {
  const { t } = useTranslation();
  const project = useParams().key!;
  const [params, setParams] = useSearchParams();
  const [creating, createModal] = useDisclosure(false);
  const [childOf, setChildOf] = useState<RequirementTreeNode | null>(null);
  const [testFor, setTestFor] = useState<string | null>(null);
  const testKinds = useTestWriteKinds(project);
  const [importing, importModal] = useDisclosure(false);
  const [search, setSearch] = useState(params.get('q') ?? '');
  const canWrite = useCanWriteRequirements(project);

  const view = params.get('view') === 'list' || params.get('q') ? 'list' : 'tree';
  const filters: RequirementFilters = filtersFromParams(params);
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

  const exportCsv = () =>
    downloadCsv(project, filters).catch((error) =>
      notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) }),
    );

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('backlog.title')}</Title>
        <Group>
          {canWrite && (
            <>
              <Button leftSection={<IconPlus size={16} />} onClick={createModal.open} data-testid="backlog-new">
                {t('backlog.new')}
              </Button>
              <Button variant="default" leftSection={<IconUpload size={16} />} onClick={importModal.open} data-testid="backlog-import">
                {t('backlog.import')}
              </Button>
            </>
          )}
          <Button variant="default" leftSection={<IconDownload size={16} />} onClick={exportCsv} data-testid="backlog-export">
            {t('backlog.export')}
          </Button>
        </Group>
      </Group>

      <Group>
        <SegmentedControl
          value={view}
          onChange={(value) => update({ view: value, q: value === 'tree' ? null : params.get('q') })}
          data={[
            { value: 'tree', label: t('backlog.tree') },
            { value: 'list', label: t('backlog.list') },
          ]}
          data-testid="backlog-view"
        />
        <TextInput
          flex={1}
          leftSection={<IconSearch size={16} />}
          placeholder={t('backlog.search')}
          aria-label={t('backlog.search')}
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') update({ q: search.trim() || null, view: 'list' });
          }}
          data-testid="backlog-search"
        />
      </Group>

      {view === 'list' && <BacklogFilters filters={filters} onChange={update} />}

      {view === 'list' ? (
        <RequirementList
          project={project}
          filters={filters}
          page={Number(params.get('page') ?? 0)}
          sort={params.get('sort') ?? 'rank,asc'}
          onSort={(sort) => update({ sort })}
          onPage={(page) => update({ page: String(page) })}
          onSelect={(key) => update({ selected: key, page: params.get('page') })}
          canWrite={canWrite}
        />
      ) : (
        <RequirementTree
          project={project}
          onSelect={(key) => update({ selected: key })}
          canWrite={canWrite}
          canAddTest={testKinds.length > 0}
          onAddChild={(node) => {
            setChildOf(node);
            createModal.open();
          }}
          onAddTest={(node) => setTestFor(node.key)}
        />
      )}

      <Drawer
        opened={selected !== null}
        onClose={() => update({ selected: null, page: params.get('page') })}
        position="right"
        size="xl"
        title={
          selected && (
            <Anchor component={Link} to={`/p/${project}/requirements/${selected}`} data-testid="drawer-open-full">
              {t('backlog.openFull')}
            </Anchor>
          )
        }
      >
        {selected && <RequirementDetailView project={project} requirementKey={selected} />}
      </Drawer>

      <CreateRequirementModal
        project={project}
        opened={creating}
        onClose={() => {
          createModal.close();
          setChildOf(null);
        }}
        initialParent={childOf?.key ?? null}
        initialType={childOf ? defaultChildType(childOf.type) : null}
        onCreated={(key) => update({ selected: key, page: params.get('page') })}
      />
      <ImportCsvModal project={project} opened={importing} onClose={importModal.close} />
      <CreateTestModal
        project={project}
        opened={testFor !== null}
        onClose={() => setTestFor(null)}
        kinds={testKinds}
        initialRequirement={testFor}
        onCreated={(key) => {
          notifications.show({ color: 'green', message: t('tree.testLinked', { key, requirement: testFor }) });
          update({ selected: testFor });
        }}
      />
    </Stack>
  );
}
