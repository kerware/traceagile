import { Input, Loader, useComputedColorScheme } from '@mantine/core';
import { lazy, Suspense } from 'react';
import rehypeSanitize from 'rehype-sanitize';

// Éditeur chargé à la demande : il pèse lourd et n'est utile que sur la fiche (§11.4).
const MDEditor = lazy(() => import('@uiw/react-md-editor'));
const Markdown = lazy(() => import('@uiw/react-md-editor').then((m) => ({ default: m.default.Markdown })));

/**
 * F-REQ-08 description Markdown avec prévisualisation ; le rendu est assaini (rehype-sanitize,
 * NF-09) pour neutraliser tout HTML ou script injecté.
 */
export function MarkdownField({
  label,
  value,
  onChange,
  readOnly,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  readOnly: boolean;
}) {
  const scheme = useComputedColorScheme('light');
  return (
    <Input.Wrapper label={label}>
      <div data-color-mode={scheme} data-testid="field-description">
        <Suspense fallback={<Loader size="sm" />}>
          {readOnly ? (
            <Markdown source={value || '—'} rehypePlugins={[[rehypeSanitize]]} />
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
