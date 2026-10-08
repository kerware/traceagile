import { zodResolver } from '@hookform/resolvers/zod';
import { Alert, Badge, Button, Checkbox, Group, Loader, Modal, PasswordInput, Stack, Table, TextInput } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { IconUserPlus } from '@tabler/icons-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { z } from 'zod';
import { ApiError, errorMessage } from '../../api/errors';
import { useCreateUser, useUpdateUser, useUsers } from '../../api/queries';
import { AdminTabs } from './AdminTabs';

/** §12 Administration des utilisateurs : liste, création, activation (PATCH + If-Match). */
export function AdminUsersPage() {
  const { t } = useTranslation();
  const { data, isLoading } = useUsers();
  const updateUser = useUpdateUser();
  const [creating, { open, close }] = useDisclosure(false);

  const toggleActive = (user: NonNullable<typeof data>['content'][number]) =>
    updateUser.mutate(
      { user, patch: { active: !user.active } },
      { onError: (error) => notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) }) },
    );

  return (
    <Stack>
      <AdminTabs value="users" />
      <Group justify="flex-end">
        <Button leftSection={<IconUserPlus size={16} />} onClick={open} data-testid="user-create">
          {t('admin.newUser')}
        </Button>
      </Group>
      {isLoading && <Loader />}
      <Table striped highlightOnHover data-testid="users-table">
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t('admin.login')}</Table.Th>
            <Table.Th>{t('admin.displayName')}</Table.Th>
            <Table.Th>{t('admin.email')}</Table.Th>
            <Table.Th />
            <Table.Th />
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {data?.content.map((user) => (
            <Table.Tr key={user.id} data-testid={`user-row-${user.login}`}>
              <Table.Td>{user.login}</Table.Td>
              <Table.Td>{user.displayName}</Table.Td>
              <Table.Td>{user.email}</Table.Td>
              <Table.Td>
                <Group gap="xs">
                  <Badge color={user.active ? 'green' : 'gray'} variant="light">
                    {user.active ? t('admin.active') : t('admin.inactive')}
                  </Badge>
                  {user.systemAdmin && <Badge color="grape">{t('roles.SYSTEM_ADMIN')}</Badge>}
                </Group>
              </Table.Td>
              <Table.Td>
                <Button
                  size="xs"
                  variant="default"
                  onClick={() => toggleActive(user)}
                  data-testid={`user-toggle-active-${user.login}`}
                >
                  {user.active ? t('admin.deactivate') : t('admin.activate')}
                </Button>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
      <CreateUserModal opened={creating} onClose={close} />
    </Stack>
  );
}

function CreateUserModal({ opened, onClose }: { opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const createUser = useCreateUser();
  const [failure, setFailure] = useState<string | null>(null);

  const schema = z.object({
    login: z.string().regex(/^[a-z0-9._-]{2,32}$/, t('admin.loginInvalid')),
    email: z.string().email(t('admin.emailInvalid')),
    displayName: z.string().max(100),
    password: z.string().min(8, t('admin.passwordHint')).max(72),
    systemAdmin: z.boolean(),
  });
  type Form = z.infer<typeof schema>;
  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { login: '', email: '', displayName: '', password: '', systemAdmin: false },
  });

  const close = () => {
    reset();
    setFailure(null);
    onClose();
  };

  const onSubmit = async (form: Form) => {
    try {
      const user = await createUser.mutateAsync(form);
      notifications.show({ color: 'green', message: t('admin.userCreated', { login: user.login }) });
      close();
    } catch (error) {
      if (error instanceof ApiError && error.code === 'USER_LOGIN_TAKEN') {
        setError('login', { message: error.message });
      } else {
        setFailure(errorMessage(error, t('errors.generic')));
      }
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('admin.newUser')}>
      <form onSubmit={handleSubmit(onSubmit)} noValidate>
        <Stack>
          {failure && (
            <Alert color="red" role="alert">
              {failure}
            </Alert>
          )}
          <TextInput label={t('admin.login')} required data-testid="user-login-input" error={errors.login?.message} {...register('login')} />
          <TextInput label={t('admin.email')} required data-testid="user-email-input" error={errors.email?.message} {...register('email')} />
          <TextInput label={t('admin.displayName')} data-testid="user-display-name-input" {...register('displayName')} />
          <PasswordInput
            label={t('admin.password')}
            description={t('admin.passwordHint')}
            required
            data-testid="user-password-input"
            error={errors.password?.message}
            {...register('password')}
          />
          <Checkbox label={t('admin.systemAdmin')} data-testid="user-system-admin-input" {...register('systemAdmin')} />
          <Group justify="flex-end">
            <Button type="submit" loading={isSubmitting} data-testid="user-save">
              {t('admin.create')}
            </Button>
          </Group>
        </Stack>
      </form>
    </Modal>
  );
}
