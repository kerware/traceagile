import { Tabs, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

/** §13.2 /admin/* — onglets de l'administration : utilisateurs, projets et membres, DoR / DoD. */
export function AdminTabs({ value }: { value: 'users' | 'projects' | 'checklists' | 'references' }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  return (
    <>
      <Title order={2}>{t('admin.title')}</Title>
      <Tabs value={value} onChange={(tab) => tab && navigate(`/admin/${tab}`)}>
        <Tabs.List>
          <Tabs.Tab value="users" data-testid="admin-tab-users">
            {t('admin.users')}
          </Tabs.Tab>
          <Tabs.Tab value="projects" data-testid="admin-tab-projects">
            {t('admin.projects')}
          </Tabs.Tab>
          <Tabs.Tab value="checklists" data-testid="admin-tab-checklists">
            {t('admin.checklists')}
          </Tabs.Tab>
          <Tabs.Tab value="references" data-testid="admin-tab-references">
            {t('admin.references')}
          </Tabs.Tab>
        </Tabs.List>
      </Tabs>
    </>
  );
}
