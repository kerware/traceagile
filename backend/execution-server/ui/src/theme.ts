import { createTheme } from '@mantine/core';

/** Teinte « pétrole » : distingue le serveur d'exécution de l'application TraceAgile. */
export const theme = createTheme({
  primaryColor: 'cyan',
  primaryShade: { light: 8, dark: 6 },
  autoContrast: true,
  fontFamily: 'system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
  fontFamilyMonospace: 'ui-monospace, "Cascadia Mono", Consolas, monospace',
  defaultRadius: 'md',
  headings: { fontWeight: '650' },
});
