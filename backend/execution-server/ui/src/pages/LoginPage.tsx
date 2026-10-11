import { Alert, Button, Center, Paper, PasswordInput, Stack, Text, TextInput, Title } from '@mantine/core';
import { IconPlayerPlay } from '@tabler/icons-react';
import { useState } from 'react';
import { login } from '../api';

export function LoginPage({ onLogin }: { onLogin: () => void }) {
  const [user, setUser] = useState('admin');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setPending(true);
    setError(null);
    try {
      await login(user, password);
      onLogin();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Connexion impossible.');
    } finally {
      setPending(false);
    }
  };

  return (
    <Center mih="100vh" p="md">
      <Paper withBorder p="xl" w={380} component="form" onSubmit={submit}>
        <Stack>
          <Stack gap={4} align="center">
            <IconPlayerPlay size={36} color="var(--mantine-primary-color-filled)" aria-hidden />
            <Title order={3}>Serveur d'exécution</Title>
            <Text size="sm" c="dimmed" ta="center">
              Administration : jetons, outils de test, jobs reçus de TraceAgile.
            </Text>
          </Stack>
          {error && (
            <Alert color="red" role="alert" data-testid="login-error">
              {error}
            </Alert>
          )}
          <TextInput label="Administrateur" value={user} onChange={(e) => setUser(e.currentTarget.value)} required autoComplete="username"
            data-testid="login-user" />
          <PasswordInput label="Mot de passe" value={password} onChange={(e) => setPassword(e.currentTarget.value)} required
            autoComplete="current-password" data-testid="login-password" />
          <Button type="submit" loading={pending} data-testid="login-submit">
            Se connecter
          </Button>
          <Text size="xs" c="dimmed" ta="center">
            Identifiants définis au lancement (EXECUTION_SERVER_ADMIN_USER / EXECUTION_SERVER_ADMIN_PASSWORD).
          </Text>
        </Stack>
      </Paper>
    </Center>
  );
}
