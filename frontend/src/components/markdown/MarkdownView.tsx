import { Loader, useComputedColorScheme } from '@mantine/core';
import { lazy, Suspense, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import rehypeSanitize from 'rehype-sanitize';
import { rehypeKeyLinks } from './keyLinks';

const Markdown = lazy(() => import('@uiw/react-md-editor').then((m) => ({ default: m.default.Markdown })));

/**
 * Markdown assaini (NF-09) dont les clés citées sont cliquables (§13.1, ADR-0024) ; un clic sur une clé
 * navigue dans l'application sans recharger la page.
 */
export function MarkdownView({ project, source, testId }: { project?: string; source: string; testId?: string }) {
  const scheme = useComputedColorScheme('light');
  const navigate = useNavigate();
  const plugins = useMemo(
    () => (project ? [[rehypeSanitize], [rehypeKeyLinks(project)]] : [[rehypeSanitize]]) as never,
    [project],
  );
  const onClick = (event: React.MouseEvent) => {
    const link = (event.target as HTMLElement).closest('a.trace-key');
    if (link) {
      event.preventDefault();
      navigate(link.getAttribute('href') ?? '/');
    }
  };
  return (
    <div data-color-mode={scheme} onClick={onClick} data-testid={testId}>
      <Suspense fallback={<Loader size="sm" />}>
        <Markdown source={source || '—'} rehypePlugins={plugins} style={{ background: 'transparent' }} />
      </Suspense>
    </div>
  );
}
