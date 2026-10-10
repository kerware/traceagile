import { useEffect, useRef } from 'react';
import { SHORTCUT_EVENT, typing } from './shortcuts';

/**
 * §13.3 raccourcis d'une page : touches d'une lettre (hors saisie, sans modificateur, sans fenêtre
 * ouverte) et actions « nouvel élément » / « éditer » diffusées par la barre supérieure (N, E).
 */
export function useShortcuts(handlers: Record<string, () => void>, enabled = true) {
  const current = useRef(handlers);
  current.current = handlers;
  useEffect(() => {
    if (!enabled) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.ctrlKey || event.metaKey || event.altKey || typing(event.target) || document.querySelector('[role="dialog"]')) return;
      const handler = current.current[event.key.toLowerCase()];
      if (handler && event.key.toLowerCase() !== 'n' && event.key.toLowerCase() !== 'e') {
        event.preventDefault();
        handler();
      }
    };
    const onAction = (event: Event) => current.current[(event as CustomEvent<string>).detail === 'new' ? 'n' : 'e']?.();
    window.addEventListener('keydown', onKeyDown);
    window.addEventListener(SHORTCUT_EVENT, onAction);
    return () => {
      window.removeEventListener('keydown', onKeyDown);
      window.removeEventListener(SHORTCUT_EVENT, onAction);
    };
  }, [enabled]);
}
