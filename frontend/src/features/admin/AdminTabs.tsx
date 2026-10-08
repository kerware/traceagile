import { Tabs, Title } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

/** §13.2 /admin/* — onglets de l'administration (lot 0 : utilisateurs, projets et membres). */
export function AdminTabs({ value }: { value: 'users' | 'projects' }) {
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
        </Tabs.List>
      </Tabs>
    </>
  );
}
