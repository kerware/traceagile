/** §13.3 raccourcis clavier documentés (aide « ? ») ; inactifs pendant la saisie dans un champ (ADR-0024). */

export interface Shortcut {
  id: string;
  keys: string[];
  where: 'everywhere' | 'lists' | 'details' | 'execution';
}

export const SHORTCUTS: Shortcut[] = [
  { id: 'help', keys: ['?'], where: 'everywhere' },
  { id: 'search', keys: ['Ctrl', 'K'], where: 'everywhere' },
  { id: 'searchSlash', keys: ['/'], where: 'everywhere' },
  { id: 'new', keys: ['N'], where: 'lists' },
  { id: 'edit', keys: ['E'], where: 'details' },
  { id: 'pass', keys: ['P'], where: 'execution' },
  { id: 'fail', keys: ['F'], where: 'execution' },
  { id: 'block', keys: ['B'], where: 'execution' },
];

/** Événement « nouvel élément » / « éditer » diffusé aux pages (raccourcis N et E). */
export const SHORTCUT_EVENT = 'traceagile:shortcut';

export function emitShortcut(action: 'new' | 'edit') {
  window.dispatchEvent(new CustomEvent(SHORTCUT_EVENT, { detail: action }));
}

/** Saisie en cours dans un champ ou un éditeur : les raccourcis d'une lettre ne s'y déclenchent pas. */
export function typing(target: EventTarget | null): boolean {
  const element = target as HTMLElement | null;
  if (!element || !element.tagName) return false;
  return ['INPUT', 'TEXTAREA', 'SELECT'].includes(element.tagName) || element.isContentEditable || !!element.closest?.('.monaco-editor');
}
