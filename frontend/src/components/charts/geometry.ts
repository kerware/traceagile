/** Géométrie des petits graphiques SVG (F-RPT-02) : échelles, courbes interrompues, graduations. */

export interface ChartSeries {
  name: string;
  values: (number | null | undefined)[];
  /** Couleur CSS (variable Mantine ou hexadécimal). */
  color: string;
}

export const VIEW_WIDTH = 600;
export const MARGIN = { top: 10, right: 10, bottom: 28, left: 36 };

/** Plus grande valeur arrondie à une graduation lisible (1, 2, 5 × 10^n). */
export function niceMax(values: number[]): number {
  const max = Math.max(0, ...values);
  if (max === 0) return 1;
  const power = 10 ** Math.floor(Math.log10(max));
  const step = [1, 2, 5, 10].find((s) => s * power >= max) ?? 10;
  return step * power;
}

export function seriesMax(series: ChartSeries[]): number {
  return niceMax(series.flatMap((s) => s.values.filter((v): v is number => typeof v === 'number')));
}

/** Segments d'une courbe : un point absent (jour futur du burndown) interrompt le tracé. */
export function polylines(values: (number | null | undefined)[], x: (i: number) => number, y: (v: number) => number): string[] {
  const lines: string[] = [];
  let current: string[] = [];
  values.forEach((v, i) => {
    if (typeof v === 'number') {
      current.push(`${x(i).toFixed(1)},${y(v).toFixed(1)}`);
    } else if (current.length) {
      lines.push(current.join(' '));
      current = [];
    }
  });
  if (current.length) lines.push(current.join(' '));
  return lines;
}

/** Libellés de l'axe des catégories : au plus {@code max}, répartis régulièrement. */
export function labelIndexes(count: number, max = 8): number[] {
  if (count <= max) return Array.from({ length: count }, (_, i) => i);
  const step = Math.ceil(count / max);
  return Array.from({ length: count }, (_, i) => i).filter((i) => i % step === 0 || i === count - 1);
}
