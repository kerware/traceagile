/**
 * F-REQ-03 Calcule le nouvel ordre après un glisser-déposer et les voisins à transmettre à
 * l'API {@code move} : l'élément est inséré après {@code afterKey} et avant {@code beforeKey}.
 */
export function reorder(
  keys: string[],
  activeKey: string,
  overKey: string,
): { ordered: string[]; afterKey?: string; beforeKey?: string } | null {
  const from = keys.indexOf(activeKey);
  const to = keys.indexOf(overKey);
  if (from < 0 || to < 0 || from === to) return null;
  const ordered = [...keys];
  ordered.splice(from, 1);
  ordered.splice(to, 0, activeKey);
  const index = ordered.indexOf(activeKey);
  return {
    ordered,
    afterKey: index > 0 ? ordered[index - 1] : undefined,
    beforeKey: index < ordered.length - 1 ? ordered[index + 1] : undefined,
  };
}
