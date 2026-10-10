import { Input, Loader, useComputedColorScheme } from '@mantine/core';
import { lazy, Suspense, useEffect, useRef } from 'react';
import rehypeSanitize from 'rehype-sanitize';
import { MarkdownView } from '../../components/markdown/MarkdownView';

// Éditeur chargé à la demande : il pèse lourd et n'est utile que sur la fiche (§11.4).
const MDEditor = lazy(() => import('@uiw/react-md-editor'));

/**
 * F-REQ-08 description Markdown avec prévisualisation ; le rendu est assaini (rehype-sanitize,
 * NF-09) pour neutraliser tout HTML ou script injecté.
 */
export function MarkdownField({
  label,
  value,
  onChange,
  readOnly,
  project,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  readOnly: boolean;
  /** ADR-0024 les clés citées deviennent cliquables en lecture. */
  project?: string;
}) {
  const scheme = useComputedColorScheme('light');
  const container = useRef<HTMLDivElement>(null);
  // NF-10 icônes de la barre d'outils (bibliothèque tierce) : décoratives, leurs boutons sont nommés
  useEffect(() => {
    const root = container.current;
    if (!root) return;
    const hide = () => root.querySelectorAll('svg[role="img"]:not([aria-hidden])').forEach((svg) => svg.setAttribute('aria-hidden', 'true'));
    hide();
    const observer = new MutationObserver(hide);
    observer.observe(root, { childList: true, subtree: true });
    return () => observer.disconnect();
  }, []);
  return (
    <Input.Wrapper label={label}>
      <div ref={container} data-color-mode={scheme} data-testid="field-description">
        <Suspense fallback={<Loader size="sm" />}>
          {readOnly ? (
            <MarkdownView project={project} source={value} />
          ) : (
            <MDEditor
              value={value}
              onChange={(next) => onChange(next ?? '')}
              preview="live"
              height={240}
              // Sinon l'éditeur fige le overflow du body (« hidden » quand il est monté dans un tiroir)
              // et la page ne défile plus après fermeture ou navigation.
              overflow={false}
              previewOptions={{ rehypePlugins: [[rehypeSanitize]] }}
              textareaProps={{ 'aria-label': label }}
            />
          )}
        </Suspense>
      </div>
    </Input.Wrapper>
  );
}
