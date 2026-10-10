import { Group, Text } from '@mantine/core';
import { labelIndexes, MARGIN, polylines, seriesMax, VIEW_WIDTH, type ChartSeries } from './geometry';

interface ChartProps {
  categories: string[];
  series: ChartSeries[];
  height?: number;
  testId?: string;
  /** Texte alternatif (lecteurs d'écran). */
  label: string;
}

function Axis({ max, height }: { max: number; height: number }) {
  const plot = height - MARGIN.top - MARGIN.bottom;
  return (
    <>
      {[0, 0.5, 1].map((f) => {
        const y = MARGIN.top + plot * (1 - f);
        return (
          <g key={f}>
            <line x1={MARGIN.left} x2={VIEW_WIDTH - MARGIN.right} y1={y} y2={y} stroke="var(--mantine-color-gray-3)" strokeWidth={1} />
            <text x={MARGIN.left - 6} y={y + 4} textAnchor="end" fontSize={11} fill="var(--mantine-color-dimmed)">
              {Math.round(max * f * 10) / 10}
            </text>
          </g>
        );
      })}
    </>
  );
}

function Legend({ series }: { series: ChartSeries[] }) {
  return (
    <Group gap="md" justify="center" mt={4}>
      {series.map((s) => (
        <Group key={s.name} gap={4}>
          <span style={{ display: 'inline-block', width: 10, height: 10, background: s.color, borderRadius: 2 }} />
          <Text size="xs" c="dimmed">
            {s.name}
          </Text>
        </Group>
      ))}
    </Group>
  );
}

/** F-RPT-02 courbes (burndown, burnup) : un point absent interrompt la courbe. */
export function LineChart({ categories, series, height = 200, testId, label }: ChartProps) {
  const max = seriesMax(series);
  const plotWidth = VIEW_WIDTH - MARGIN.left - MARGIN.right;
  const plotHeight = height - MARGIN.top - MARGIN.bottom;
  const x = (i: number) => MARGIN.left + (categories.length <= 1 ? plotWidth / 2 : (plotWidth * i) / (categories.length - 1));
  const y = (v: number) => MARGIN.top + plotHeight * (1 - v / max);
  return (
    <div data-testid={testId}>
      <svg viewBox={`0 0 ${VIEW_WIDTH} ${height}`} width="100%" role="img" aria-label={label}>
        <Axis max={max} height={height} />
        {series.map((s, si) =>
          polylines(s.values, x, y).map((points, pi) => (
            <polyline key={`${si}-${pi}`} points={points} fill="none" stroke={s.color} strokeWidth={si === 0 ? 2.5 : 1.5}
              strokeDasharray={si === 0 ? undefined : '5 4'} data-series={s.name} />
          )),
        )}
        {labelIndexes(categories.length).map((i) => (
          <text key={i} x={x(i)} y={height - 8} textAnchor="middle" fontSize={11} fill="var(--mantine-color-dimmed)">
            {categories[i]}
          </text>
        ))}
      </svg>
      <Legend series={series} />
    </div>
  );
}

/** F-RPT-02 colonnes groupées (taux de réussite des runs, anomalies par sprint). */
export function ColumnChart({ categories, series, height = 200, testId, label }: ChartProps) {
  const max = seriesMax(series);
  const plotWidth = VIEW_WIDTH - MARGIN.left - MARGIN.right;
  const plotHeight = height - MARGIN.top - MARGIN.bottom;
  const group = plotWidth / Math.max(1, categories.length);
  const bar = Math.min(28, (group * 0.75) / Math.max(1, series.length));
  return (
    <div data-testid={testId}>
      <svg viewBox={`0 0 ${VIEW_WIDTH} ${height}`} width="100%" role="img" aria-label={label}>
        <Axis max={max} height={height} />
        {categories.map((c, ci) => {
          const left = MARGIN.left + group * ci + (group - bar * series.length) / 2;
          return (
            <g key={c + ci}>
              {series.map((s, si) => {
                const v = s.values[ci];
                if (typeof v !== 'number') return null;
                const h = (plotHeight * v) / max;
                return (
                  <rect key={s.name} x={left + si * bar} y={MARGIN.top + plotHeight - h} width={bar - 2} height={h} fill={s.color}>
                    <title>{`${c} — ${s.name} : ${v}`}</title>
                  </rect>
                );
              })}
            </g>
          );
        })}
        {labelIndexes(categories.length).map((i) => (
          <text key={i} x={MARGIN.left + group * i + group / 2} y={height - 8} textAnchor="middle" fontSize={11} fill="var(--mantine-color-dimmed)">
            {categories[i]}
          </text>
        ))}
      </svg>
      {series.length > 1 && <Legend series={series} />}
    </div>
  );
}
