import { zodResolver } from '@hookform/resolvers/zod';
import { Alert, Button, Center, Paper, PasswordInput, Stack, TextInput, Title } from '@mantine/core';
import { IconAlertCircle } from '@tabler/icons-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { z } from 'zod';
import { api } from '../../api/client';
import { errorMessage, unwrap } from '../../api/errors';
import { useAuthStore } from './authStore';

/** §13.2 /login — Connexion par login et mot de passe (§1.3 authentification locale). */
export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const status = useAuthStore((s) => s.status);
  const setSession = useAuthStore((s) => s.setSession);
  const [failure, setFailure] = useState<string | null>(null);

  const schema = z.object({
    login: z.string().trim().min(1, t('auth.required')),
    password: z.string().min(1, t('auth.required')),
  });
  type Form = z.infer<typeof schema>;
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<Form>({ resolver: zodResolver(schema), defaultValues: { login: '', password: '' } });

  if (status === 'authenticated') {
    return <Navigate to="/projects" replace />;
  }

  const onSubmit = async (form: Form) => {
    setFailure(null);
    try {
      const token = unwrap(await api.POST('/api/v1/auth/login', { body: form }));
      setSession(token.accessToken, token.user);
      const from = (location.state as { from?: string } | null)?.from;
      navigate(from && from !== '/login' ? from : '/projects', { replace: true });
    } catch (error) {
      setFailure(errorMessage(error, t('auth.failed')));
    }
  };

  return (
    <Center mih="100vh" p="md">
      <Paper withBorder shadow="sm" p="xl" w={380} component="main">
        <form onSubmit={handleSubmit(onSubmit)} noValidate>
          <Stack>
            <Title order={2}>{t('auth.title')}</Title>
            {failure && (
              <Alert color="red" icon={<IconAlertCircle size={18} />} role="alert" data-testid="login-error">
                {failure}
              </Alert>
            )}
            <TextInput
              label={t('auth.login')}
              autoComplete="username"
              autoFocus
              data-testid="login-input"
              error={errors.login?.message}
              {...register('login')}
            />
            <PasswordInput
              label={t('auth.password')}
              autoComplete="current-password"
              data-testid="password-input"
              error={errors.password?.message}
              {...register('password')}
            />
            <Button type="submit" loading={isSubmitting} data-testid="login-submit">
              {t('auth.submit')}
            </Button>
          </Stack>
        </form>
      </Paper>
    </Center>
  );
}
