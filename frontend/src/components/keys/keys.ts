/** §13.1 « clés cliquables partout » : reconnaissance d'une clé et route de sa fiche (ADR-0024). */

export const KEY_PATTERN = /\b(REQ|TC|CMP|DEF|RUN|RPT|SPR|REL)-\d+\b/g;

const ROUTES: Record<string, (project: string, key: string) => string> = {
  REQ: (p, k) => `/p/${p}/requirements/${k}`,
  TC: (p, k) => `/p/${p}/tests/${k}`,
  CMP: (p, k) => `/p/${p}/campaigns/${k}`,
  DEF: (p, k) => `/p/${p}/defects?selected=${k}`,
  RUN: (p, k) => `/p/${p}/runs/${k}`,
  RPT: (p, k) => `/p/${p}/reports/${k}`,
  SPR: (p, k) => `/p/${p}/planning?sprint=${k}`,
  REL: (p) => `/p/${p}/planning`,
};

/** Route de la fiche d'une clé ({@code null} si le préfixe est inconnu). */
export function routeOf(project: string, key: string): string | null {
  const prefix = key.slice(0, key.indexOf('-')).toUpperCase();
  const route = ROUTES[prefix];
  return route ? route(project, key.toUpperCase()) : null;
}

/** Découpe un texte en morceaux de texte et de clés (pour les rendre cliquables). */
export function splitKeys(text: string): { text: string; key: boolean }[] {
  const parts: { text: string; key: boolean }[] = [];
  let last = 0;
  for (const match of text.matchAll(KEY_PATTERN)) {
    const index = match.index ?? 0;
    if (index > last) parts.push({ text: text.slice(last, index), key: false });
    parts.push({ text: match[0], key: true });
    last = index + match[0].length;
  }
  if (last < text.length) parts.push({ text: text.slice(last), key: false });
  return parts;
}
