import type { ReactNode } from 'react';

/** Entrée d'un menu contextuel d'arbre ({@link NodeMenuRow}). */
export interface NodeMenuItem {
  key: string;
  label?: string;
  icon?: ReactNode;
  color?: string;
  disabled?: boolean;
  divider?: boolean;
  onClick?: () => void;
}

export const DIVIDER = (key: string): NodeMenuItem => ({ key, divider: true });
