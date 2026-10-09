import { useAuthStore } from '../auth/authStore';

/** §2.2 seuls l'administrateur et le PO créent releases et sprints et définissent le périmètre (l'API le vérifie aussi). */
export function useCanPlan(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;
  if (user.systemAdmin) return true;
  const role = user.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'PRODUCT_OWNER';
}
