/**
 * Après un redéploiement, une page restée ouverte référence des morceaux JavaScript (écrans chargés à
 * la demande) qui n'existent plus : l'écran ne s'ouvre pas. Vite émet alors `vite:preloadError` ; on
 * recharge la page une fois pour obtenir la nouvelle version, sans boucler si l'échec persiste.
 */
export const RELOAD_KEY = 'traceagile.staleReloadAt';
const MIN_INTERVAL_MS = 60_000;

interface Deps {
  reload: () => void;
  storage: Pick<Storage, 'getItem' | 'setItem'>;
  now: () => number;
}

/** @return true si la page est rechargée */
export function handleStaleChunk(event: { preventDefault: () => void }, { reload, storage, now }: Deps): boolean {
  let last = 0;
  try {
    last = Number(storage.getItem(RELOAD_KEY) ?? 0);
  } catch {
    // stockage indisponible (navigation privée, sites bloqués) : on recharge sans mémoriser
  }
  if (last && now() - last < MIN_INTERVAL_MS) {
    return false;
  }
  try {
    storage.setItem(RELOAD_KEY, String(now()));
  } catch {
    // idem
  }
  event.preventDefault();
  reload();
  return true;
}

/**
 * `pendingUrl` : l'écran en cours de chargement (le routeur charge l'écran avant de changer l'URL) ;
 * le rechargement y mène directement plutôt que de revenir à la page de départ.
 */
export function installStaleChunkReload(pendingUrl: () => string | null) {
  window.addEventListener('vite:preloadError', (event) =>
    handleStaleChunk(event, {
      reload: () => {
        const target = pendingUrl();
        if (target) window.location.assign(target);
        else window.location.reload();
      },
      storage: window.sessionStorage,
      now: Date.now,
    }));
}
