import { ActionIcon, Button, Group, Loader, Select, Stack, Table, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlus, IconTrash } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { errorMessage } from '../../api/errors';
import { useMembers, useProjects, useReplaceMembers, useUsers } from '../../api/queries';
import { AdminTabs } from './AdminTabs';

type Role = Schemas['MemberRequest']['role'];
const ROLES: Role[] = ['ADMINISTRATOR', 'PRODUCT_OWNER', 'TESTER', 'DEVELOPER', 'VIEWER'];

/** §12 PUT /projects/{key}/members : rôles attribués par projet (§2.2). */
export function AdminProjectsPage() {
  const { t } = useTranslation();
  const { data: projects, isLoading } = useProjects();
  const [selected, setSelected] = useState<string | null>(null);

  return (
    <Stack>
      <AdminTabs value="projects" />
      {isLoading && <Loader />}
      <Table striped highlightOnHover data-testid="admin-projects-table">
        <Table.Tbody>
          {projects?.content.map((project) => (
            <Table.Tr key={project.key}>
              <Table.Td w={120}>{project.key}</Table.Td>
              <Table.Td>{project.name}</Table.Td>
              <Table.Td>{t('projects.members', { count: project.memberCount })}</Table.Td>
              <Table.Td>
                <Button size="xs" variant="light" onClick={() => setSelected(project.key)} data-testid={`admin-members-${project.key}`}>
                  {t('admin.members', { key: project.key })}
                </Button>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
      {selected ? <MembersEditor key={selected} projectKey={selected} /> : <Text c="dimmed">{t('admin.chooseProject')}</Text>}
    </Stack>
  );
}

function MembersEditor({ projectKey }: { projectKey: string }) {
  const { t } = useTranslation();
  const { data: members } = useMembers(projectKey);
  const { data: users } = useUsers();
  const replaceMembers = useReplaceMembers(projectKey);
  const [rows, setRows] = useState<Schemas['MemberRequest'][]>([]);

  useEffect(() => {
    if (members) setRows(members.map((m) => ({ login: m.login, role: m.role })));
  }, [members]);

  const userOptions = (users?.content ?? []).map((u) => ({ value: u.login, label: `${u.displayName} (${u.login})` }));
  const roleOptions = ROLES.map((role) => ({ value: role, label: t(`roles.${role}`) }));
  const update = (index: number, change: Partial<Schemas['MemberRequest']>) =>
    setRows((current) => current.map((row, i) => (i === index ? { ...row, ...change } : row)));

  const save = () =>
    replaceMembers.mutate(
      rows.filter((row) => row.login),
      {
        onSuccess: () => notifications.show({ color: 'green', message: t('admin.membersSaved') }),
        onError: (error) => notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) }),
      },
    );

  return (
    <Stack data-testid="members-editor">
      <Title order={4}>{t('admin.members', { key: projectKey })}</Title>
      {rows.map((row, index) => (
        <Group key={index} wrap="nowrap">
          <Select
            aria-label={t('admin.login')}
            data={userOptions}
            value={row.login || null}
            onChange={(login) => update(index, { login: login ?? '' })}
            searchable
            w={280}
            data-testid={`member-login-${index}`}
          />
          <Select
            aria-label={t('admin.role')}
            data={roleOptions}
            value={row.role}
            onChange={(role) => role && update(index, { role: role as Role })}
            allowDeselect={false}
            w={200}
            data-testid={`member-role-${index}`}
          />
          <ActionIcon
            variant="subtle"
            color="red"
            aria-label={t('admin.remove')}
            onClick={() => setRows((current) => current.filter((_, i) => i !== index))}
            data-testid={`member-remove-${index}`}
          >
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      ))}
      <Group>
        <Button
          variant="default"
          leftSection={<IconPlus size={16} />}
          onClick={() => setRows((current) => [...current, { login: '', role: 'VIEWER' }])}
          data-testid="member-add"
        >
          {t('admin.addMember')}
        </Button>
        <Button onClick={save} loading={replaceMembers.isPending} data-testid="members-save">
          {t('admin.saveMembers')}
        </Button>
      </Group>
    </Stack>
  );
}
