import {
  ActionIcon,
  AppShell,
  Burger,
  Button,
  Group,
  Indicator,
  Kbd,
  Menu,
  NavLink,
  Select,
  Text,
  Title,
  useMantineColorScheme,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { useEffect } from 'react';
import {
  IconBell,
  IconBug,
  IconChartBar,
  IconChecklist,
  IconCompass,
  IconFileAnalytics,
  IconFlask,
  IconLayoutDashboard,
  IconListDetails,
  IconLogout,
  IconMoonStars,
  IconPlayerPlay,
  IconRoute,
  IconSearch,
  IconSettings,
  IconTimeline,
  IconUserCircle,
  type Icon,
} from '@tabler/icons-react';
import { useQueryClient } from '@tanstack/react-query';

import { useTranslation } from 'react-i18next';
import { Link, Outlet, useLocation, useMatch, useNavigate } from 'react-router-dom';
import { api } from '../api/client';
import { useProjects } from '../api/queries';
import { useNotifications } from '../api/workshop';
import { SearchSpotlight } from '../components/search/SearchSpotlight';
import { emitShortcut, typing } from '../components/search/shortcuts';
import { ShortcutsHelp } from '../components/search/ShortcutsHelp';
import { useAuthStore } from '../features/auth/authStore';
import { navigationFor, type NavId } from './navigation';

const ICONS: Record<NavId, Icon> = {
  dashboard: IconLayoutDashboard,
  backlog: IconListDetails,
  tests: IconFlask,
  exploratory: IconCompass,
  planning: IconTimeline,
  campaigns: IconChecklist,
  myExecutions: IconPlayerPlay,
  traceability: IconRoute,
  defects: IconBug,
  reports: IconFileAnalytics,
  administration: IconSettings,
};

/** §13.1 Structure générale : barre supérieure et menu latéral. */
export function AppLayout() {
  const { t } = useTranslation();
  const [opened, { toggle }] = useDisclosure();
  const user = useAuthStore((s) => s.user)!;
  const projectKey = useMatch('/p/:key/*')?.params.key ?? null;
  const { pathname } = useLocation();
  const [searchOpened, search] = useDisclosure(false);
  const [helpOpened, help] = useDisclosure(false);
  useGlobalShortcuts(search.open, help.open);

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{ width: 240, breakpoint: 'sm', collapsed: { mobile: !opened } }}
      padding="md"
    >
      <AppShell.Header>
        <Group h="100%" px="md" justify="space-between" wrap="nowrap">
          <Group wrap="nowrap">
            <Burger opened={opened} onClick={toggle} hiddenFrom="sm" size="sm" />
            <Link to="/projects" style={{ textDecoration: 'none', color: 'inherit' }} data-testid="home-link">
              <Group gap={6} wrap="nowrap">
                <IconChartBar size={24} />
                <Title order={3}>{t('app.name')}</Title>
              </Group>
            </Link>
            <ProjectSelector current={projectKey} />
          </Group>
          <Group wrap="nowrap">
            {projectKey && <ActiveSprint project={projectKey} />}
            <Button
              variant="default"
              leftSection={<IconSearch size={16} />}
              rightSection={<Kbd size="xs">Ctrl K</Kbd>}
              onClick={search.open}
              visibleFrom="md"
              w={260}
              justify="space-between"
              c="dimmed"
              fw={400}
              data-testid="global-search"
            >
              {t('layout.search')}
            </Button>
            {projectKey && <NotificationsMenu project={projectKey} />}
            <ThemeToggle />
            <UserMenu />
          </Group>
        </Group>
      </AppShell.Header>

      <AppShell.Navbar p="xs" aria-label="Menu principal">
        {navigationFor(projectKey, user).map((item) => {
          const Icon = ICONS[item.id];
          return (
            <NavLink
              key={item.id}
              component={Link}
              to={item.to}
              label={t(`nav.${item.id}`)}
              leftSection={<Icon size={18} />}
              active={pathname.startsWith(item.to)}
              data-testid={`nav-${item.id}`}
            />
          );
        })}
      </AppShell.Navbar>

      <AppShell.Main>
        <Outlet />
      </AppShell.Main>
      <SearchSpotlight project={projectKey} opened={searchOpened} onClose={search.close} />
      <ShortcutsHelp opened={helpOpened} onClose={help.close} />
    </AppShell>
  );
}

/** §13.3 raccourcis globaux : Ctrl+K et « / » (recherche), « ? » (aide), N et E (diffusés aux pages). */
function useGlobalShortcuts(openSearch: () => void, openHelp: () => void) {
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault();
        openSearch();
        return;
      }
      if (event.ctrlKey || event.metaKey || event.altKey || typing(event.target) || document.querySelector('[role="dialog"]')) return;
      if (event.key === '?') {
        event.preventDefault();
        openHelp();
      } else if (event.key === '/') {
        event.preventDefault();
        openSearch();
      } else if (event.key === 'n' || event.key === 'N') {
        emitShortcut('new');
      } else if (event.key === 'e' || event.key === 'E') {
        emitShortcut('edit');
      }
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [openSearch, openHelp]);
}

/** §13.1 sprint actif du projet (lien vers la planification). */
function ActiveSprint({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data } = useNotifications(project);
  if (!data?.activeSprintKey) return null;
  return (
    <Button component={Link} to={`/p/${project}/planning?sprint=${data.activeSprintKey}`} variant="light" size="xs" visibleFrom="lg"
      data-testid="active-sprint" title={t('layout.activeSprint')}>
      {data.activeSprintKey} — {data.activeSprintName}
    </Button>
  );
}

/** §13.1 notifications calculées à la demande (ADR-0024). */
function NotificationsMenu({ project }: { project: string }) {
  const { t } = useTranslation();
  const { data } = useNotifications(project);
  const items = data
    ? [
        { id: 'myTests', count: data.myTests, to: `/p/${project}/my-executions` },
        { id: 'sessionsToApprove', count: data.sessionsToApprove, to: `/p/${project}/exploratory` },
        { id: 'blockingDefects', count: data.blockingDefects, to: `/p/${project}/defects?status=OPEN&status=IN_PROGRESS&severity=BLOCKER&severity=CRITICAL` },
        { id: 'failedRuns', count: data.failedRuns, to: `/p/${project}/dashboard` },
      ]
    : [];
  const total = items.reduce((sum, i) => sum + i.count, 0);
  return (
    <Indicator label={total} size={16} disabled={total === 0} offset={4} color="red">
      <Menu position="bottom-end" withinPortal>
        <Menu.Target>
          <ActionIcon variant="default" size="lg" aria-label={t('notifications.title', { count: total })} data-testid="notifications">
            <IconBell size={18} />
          </ActionIcon>
        </Menu.Target>
      <Menu.Dropdown>
        <Menu.Label>{t('notifications.label')}</Menu.Label>
        {items.map((item) => (
          <Menu.Item key={item.id} component={Link} to={item.to} disabled={item.count === 0} data-testid={`notification-${item.id}`}
            rightSection={<Text size="sm" fw={700}>{item.count}</Text>}>
            {t(`notifications.${item.id}`)}
          </Menu.Item>
        ))}
        </Menu.Dropdown>
      </Menu>
    </Indicator>
  );
}

function ProjectSelector({ current }: { current: string | null }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data } = useProjects();
  return (
    <Select
      data-testid="project-selector"
      aria-label={t('layout.selectProject')}
      placeholder={t('layout.selectProject')}
      data={(data?.content ?? []).map((p) => ({ value: p.key, label: `${p.key} — ${p.name}` }))}
      value={current}
      onChange={(key) => key && navigate(`/p/${key}/dashboard`)}
      searchable
      allowDeselect={false}
      w={260}
      visibleFrom="sm"
    />
  );
}

function ThemeToggle() {
  const { t } = useTranslation();
  const { toggleColorScheme } = useMantineColorScheme();
  return (
    <ActionIcon
      variant="default"
      size="lg"
      onClick={toggleColorScheme}
      aria-label={t('layout.toggleTheme')}
      data-testid="theme-toggle"
    >
      <IconMoonStars size={18} />
    </ActionIcon>
  );
}

function UserMenu() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user)!;
  const clear = useAuthStore((s) => s.clear);

  const logout = async () => {
    await api.POST('/api/v1/auth/logout');
    clear();
    queryClient.clear();
    navigate('/login', { replace: true });
  };

  return (
    <Menu position="bottom-end" withinPortal>
      <Menu.Target>
        <Button variant="subtle" leftSection={<IconUserCircle size={20} />} data-testid="user-menu" aria-label={t('layout.userMenu')}>
          <Text size="sm" span>
            {user.displayName}
          </Text>
        </Button>
      </Menu.Target>
      <Menu.Dropdown>
        <Menu.Label>{user.login}</Menu.Label>
        <Menu.Item leftSection={<IconLogout size={16} />} onClick={logout} data-testid="logout">
          {t('auth.logout')}
        </Menu.Item>
      </Menu.Dropdown>
    </Menu>
  );
}
