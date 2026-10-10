import { routeOf, splitKeys } from '../keys/keys';

/** Nœud hast minimal (rehype). */
interface HastNode {
  type: string;
  tagName?: string;
  value?: string;
  properties?: Record<string, unknown>;
  children?: HastNode[];
}

/**
 * §13.1 / ADR-0024 plugin rehype : les clés citées dans le texte ({@code REQ-12}, {@code TC-45}…)
 * deviennent des liens {@code a.trace-key} (pas dans les liens ni le code). Appliqué après
 * l'assainissement : il n'ajoute que des liens internes.
 */
export function rehypeKeyLinks(project: string) {
  return () => (tree: HastNode) => {
    const visit = (node: HastNode) => {
      if (!node.children || node.tagName === 'a' || node.tagName === 'code' || node.tagName === 'pre') return;
      const next: HastNode[] = [];
      for (const child of node.children) {
        if (child.type === 'text' && child.value) {
          for (const part of splitKeys(child.value)) {
            const href = part.key ? routeOf(project, part.text) : null;
            next.push(href
              ? { type: 'element', tagName: 'a', properties: { href, className: ['trace-key'] }, children: [{ type: 'text', value: part.text }] }
              : { type: 'text', value: part.text });
          }
        } else {
          visit(child);
          next.push(child);
        }
      }
      node.children = next;
    };
    visit(tree);
  };
}
