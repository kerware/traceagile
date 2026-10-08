import { create } from 'zustand';
import type { Schemas } from '../../api/client';

export type Me = Schemas['MeResponse'];

type SessionStatus = 'unknown' | 'authenticated' | 'anonymous';

interface AuthState {
  /** Jeton d'accès gardé en mémoire uniquement ; la session survit via le cookie de rafraîchissement (ADR-0003). */
  accessToken: string | null;
  user: Me | null;
  status: SessionStatus;
  setSession: (accessToken: string, user: Me) => void;
  clear: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  user: null,
  status: 'unknown',
  setSession: (accessToken, user) => set({ accessToken, user, status: 'authenticated' }),
  clear: () => set({ accessToken: null, user: null, status: 'anonymous' }),
}));
