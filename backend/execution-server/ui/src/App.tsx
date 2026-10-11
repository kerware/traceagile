import { ActionIcon, AppShell, Burger, Group, NavLink, Text, Title, Tooltip, useMantineColorScheme } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import {
  IconGauge,
  IconKey,
  IconListDetails,
  IconLogout,
  IconMoonStars,
  IconNotes,
  IconPlayerPlay,
  IconSettings,
  IconTools,
} from '@tabler/icons-react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { Link, Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { clearCredentials, credentials, getJson, setUnauthorizedHandler } from './api';
import { DashboardPage } from './pages/DashboardPage';
import { JobPage } from './pages/JobPage';
import { JobsPage } from './pages/JobsPage';
import { LoginPage } from './pages/LoginPage';
import { LogsPage } from './pages/LogsPage';
import { SettingsPage } from './pages/SettingsPage';
import { TokensPage } from './pages/TokensPage';
import { ToolsPage } from './pages/ToolsPage';

const MENU = [
  { to: '/', label: 'Tableau de bord', icon: IconGauge },
  { to: '/jobs', label: 'Jobs', icon: IconListDetails },
  { to: '/tools', label: 'Outils', icon: IconTools },
  { to: '/tokens', label: 'Jetons', icon: IconKey },
  { to: '/settings', label: 'Paramètres', icon: IconSettings },
  { to: '/logs', label: 'Journaux', icon: IconNotes },
];

export function App() {
  const [authenticated, setAuthenticated] = useState(() => credentials() !== null);
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  useEffect(() => {
    setUnauthorizedHandler(() => {
      clearCredentials();
      setAuthenticated(false);
    });
  }, []);

  if (!authenticated) {
    return (
      <Routes>
        <Route path="*" element={<LoginPage onLogin={() => {
          setAuthenticated(true);
          navigate('/');
        }} />} />
      </Routes>
    );
  }
  return (
    <Shell onLogout={() => {
      clearCredentials();
      queryClient.clear();
      setAuthenticated(false);
    }}>
      <Routes>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/jobs" element={<JobsPage />} />
        <Route path="/jobs/:id" element={<JobPage />} />
        <Route path="/tools" element={<ToolsPage />} />
        <Route path="/tokens" element={<TokensPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/logs" element={<LogsPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Shell>
  );
}

function Shell({ children, onLogout }: { children: React.ReactNode; onLogout: () => void }) {
  const [opened, { toggle, close }] = useDisclosure();
  const { pathname } = useLocation();
  const { toggleColorScheme } = useMantineColorScheme();
  const { data: me } = useQuery({ queryKey: ['me'], queryFn: () => getJson<{ user: string; serverName: string }>('/api/admin/me') });

  return (
    <AppShell header={{ height: 56 }} navbar={{ width: 230, breakpoint: 'sm', collapsed: { mobile: !opened } }} padding="lg">
      <AppShell.Header>
        <Group h="100%" px="md" justify="space-between" wrap="nowrap">
          <Group gap="sm" wrap="nowrap">
            <Burger opened={opened} onClick={toggle} hiddenFrom="sm" size="sm" aria-label="Menu" />
            <IconPlayerPlay size={22} color="var(--mantine-primary-color-filled)" aria-hidden />
            <Title order={4} style={{ whiteSpace: 'nowrap' }}>
              Serveur d'exécution
            </Title>
            {me && (
              <Text size="sm" c="dimmed" visibleFrom="sm" data-testid="server-name">
                {me.serverName}
              </Text>
            )}
          </Group>
          <Group gap="xs" wrap="nowrap">
            <Tooltip label="Thème clair / sombre">
              <ActionIcon variant="default" size="lg" onClick={toggleColorScheme} aria-label="Thème clair / sombre">
                <IconMoonStars size={18} />
              </ActionIcon>
            </Tooltip>
            <Tooltip label={`Déconnexion${me ? ` (${me.user})` : ''}`}>
              <ActionIcon variant="default" size="lg" onClick={onLogout} aria-label="Déconnexion" data-testid="logout">
                <IconLogout size={18} />
              </ActionIcon>
            </Tooltip>
          </Group>
        </Group>
      </AppShell.Header>
      <AppShell.Navbar p="xs" aria-label="Menu principal">
        {MENU.map((item) => (
          <NavLink key={item.to} component={Link} to={item.to} label={item.label} leftSection={<item.icon size={18} />} onClick={close}
            active={item.to === '/' ? pathname === '/' : pathname.startsWith(item.to)} data-testid={`nav-${item.to.slice(1) || 'dashboard'}`} />
        ))}
      </AppShell.Navbar>
      <AppShell.Main>{children}</AppShell.Main>
    </AppShell>
  );
}
