import { useAuthStore } from '../auth/authStore';

/** §2.2 seuls l'administrateur et le PO créent, modifient, déplacent les exigences (l'API le vérifie aussi). */
export function useCanWriteRequirements(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;
  if (user.systemAdmin) return true;
  const role = user.projects.find((p) => p.key === project)?.role;
  return role === 'ADMINISTRATOR' || role === 'PRODUCT_OWNER';
}

/** §2.2 le testeur contribue aussi aux critères, à INVEST et aux items manuels de DoR / DoD. */
export function useCanContribute(project: string): boolean {
  const user = useAuthStore((s) => s.user);
  const canWrite = useCanWriteRequirements(project);
  return canWrite || user?.projects.find((p) => p.key === project)?.role === 'TESTER';
}
