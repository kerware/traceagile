import { createTheme } from '@mantine/core';

/** Thème Mantine commun (clair / sombre, §13.1). */
export const theme = createTheme({
  primaryColor: 'blue',
  // NF-10 contraste WCAG AA (≥ 4,5:1) du texte blanc sur les boutons pleins
  primaryShade: { light: 8, dark: 8 },
  // NF-10 texte noir ou blanc selon la luminance du fond des éléments pleins (badges jaunes, oranges…)
  autoContrast: true,
  // point où noir et blanc offrent le même contraste WCAG ((L + 0,05) / 0,05 = 1,05 / (L + 0,05))
  luminanceThreshold: 0.18,
  defaultRadius: 'md',
  fontFamily: 'Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
});
