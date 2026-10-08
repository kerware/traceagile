import { Outlet } from 'react-router-dom';
import { Forbidden } from '../../components/Forbidden';
import { useAuthStore } from './authStore';

/** §2.2 Écrans d'administration réservés à l'administrateur système (l'API refuse aussi avec 403). */
export function RequireSystemAdmin() {
  const systemAdmin = useAuthStore((s) => s.user?.systemAdmin ?? false);
  return systemAdmin ? <Outlet /> : <Forbidden />;
}
