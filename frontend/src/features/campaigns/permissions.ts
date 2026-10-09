import { useAuthStore } from '../auth/authStore';

function useRole(project: string) {
  const user = useAuthStore((s) => s.user);
  return { admin: !!user?.systemAdmin, role: user?.projects.find((p) => p.key === project)?.role };
}

/** §2.2 « Créer et gérer les campagnes » : testeur et administrateur. */
export function useCanManageCampaigns(project: string): boolean {
  const { admin, role } = useRole(project);
  return admin || role === 'ADMINISTRATOR' || role === 'TESTER';
}

/** §2.2 « Exécuter, saisir sessions, créer anomalies » : testeur et administrateur. */
export function useCanExecute(project: string): boolean {
  return useCanManageCampaigns(project);
}

/** ADR-0016 faire vivre une anomalie : tous sauf le lecteur (l'API vérifie aussi). */
export function useCanUpdateDefects(project: string): boolean {
  const { admin, role } = useRole(project);
  return admin || (!!role && role !== 'VIEWER');
}
