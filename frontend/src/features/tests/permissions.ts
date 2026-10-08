import type { TestKind } from '../../api/testcases';
import { useAuthStore } from '../auth/authStore';

/**
 * §2.2 l'administrateur et le testeur créent et modifient tous les tests ; le développeur
 * seulement les tests automatisés. Confort d'interface : l'API vérifie aussi.
 */
export function useTestWriteKinds(project: string): TestKind[] {
  const user = useAuthStore((s) => s.user);
  if (!user) return [];
  if (user.systemAdmin) return ['MANUAL', 'EXPLORATORY', 'AUTOMATED'];
  switch (user.projects.find((p) => p.key === project)?.role) {
    case 'ADMINISTRATOR':
    case 'TESTER':
      return ['MANUAL', 'EXPLORATORY', 'AUTOMATED'];
    case 'DEVELOPER':
      return ['AUTOMATED'];
    default:
      return [];
  }
}
