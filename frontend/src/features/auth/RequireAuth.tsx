import { Center, Loader } from '@mantine/core';
import { useEffect, type ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { refreshSession } from '../../api/client';
import { useAuthStore } from './authStore';

/** Garde d'authentification : restaure la session depuis le cookie, sinon renvoie vers /login. */
export function RequireAuth({ children }: { children: ReactNode }) {
  const status = useAuthStore((s) => s.status);
  const location = useLocation();

  useEffect(() => {
    if (status === 'unknown') void refreshSession();
  }, [status]);

  if (status === 'unknown') {
    return (
      <Center h="100vh">
        <Loader aria-label="Chargement" />
      </Center>
    );
  }
  if (status === 'anonymous') {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }
  return children;
}
