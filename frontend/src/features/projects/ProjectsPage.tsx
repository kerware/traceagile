import { Badge, Button, Card, Group, Loader, SimpleGrid, Stack, Text, Title } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { IconPlus } from '@tabler/icons-react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useProjects } from '../../api/queries';
import { useAuthStore } from '../auth/authStore';
import { CreateProjectModal } from './CreateProjectModal';

/** §13.2 /projects — cartes des projets visibles (§2.2), avec couverture et sprint actif (lots 3 et 4). */
export function ProjectsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const systemAdmin = useAuthStore((s) => s.user?.systemAdmin ?? false);
  const { data, isLoading } = useProjects();
  const [creating, { open, close }] = useDisclosure(false);

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={2}>{t('projects.title')}</Title>
        {systemAdmin && (
          <Button leftSection={<IconPlus size={16} />} onClick={open} data-testid="project-create">
            {t('projects.create')}
          </Button>
        )}
      </Group>

      {isLoading && <Loader />}
      {data && data.content.length === 0 && <Text c="dimmed">{t('projects.empty')}</Text>}

      <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }}>
        {data?.content.map((project) => (
          <Card key={project.key} withBorder padding="lg" data-testid={`project-card-${project.key}`}>
            <Group justify="space-between" mb="xs" wrap="nowrap">
              <Text fw={600} truncate>
                {project.name}
              </Text>
              <Badge variant="light">{project.key}</Badge>
            </Group>
            <Badge color="grape" variant="outline" mb="sm">
              {t(`roles.${project.myRole ?? 'SYSTEM_ADMIN'}`)}
            </Badge>
            <Text size="sm" c="dimmed">
              {t('projects.coverage')} : {t('projects.notYet')} · {t('projects.activeSprint')} : {t('projects.notYet')}
            </Text>
            <Text size="sm" c="dimmed">
              {t('projects.members', { count: project.memberCount })}
            </Text>
            <Button
              mt="md"
              variant="light"
              onClick={() => navigate(`/p/${project.key}/dashboard`)}
              data-testid={`project-open-${project.key}`}
            >
              {t('projects.open')}
            </Button>
          </Card>
        ))}
      </SimpleGrid>

      <CreateProjectModal opened={creating} onClose={close} />
    </Stack>
  );
}
