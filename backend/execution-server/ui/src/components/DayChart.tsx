import { Box, Group, Text } from '@mantine/core';
import type { Dashboard } from '../api';

const SERIES = [
  { key: 'passed', label: 'Réussis', color: 'var(--mantine-color-teal-6)' },
  { key: 'failed', label: 'Échoués', color: 'var(--mantine-color-red-6)' },
  { key: 'errors', label: 'Erreurs', color: 'var(--mantine-color-grape-5)' },
] as const;

/** Tests exécutés par jour (14 jours), barres empilées réussis / échoués / erreurs. */
export function DayChart({ days }: { days: Dashboard['days'] }) {
  const width = 640;
  const height = 180;
  const left = 32;
  const bottom = 22;
  const max = Math.max(1, ...days.map((d) => d.passed + d.failed + d.errors));
  const step = (width - left) / Math.max(1, days.length);
  const bar = Math.min(28, step * 0.6);
  const scale = (value: number) => ((height - bottom - 8) * value) / max;
  const ticks = [0, Math.round(max / 2), max].filter((v, i, all) => all.indexOf(v) === i);

  return (
    <Box>
      <Box style={{ overflowX: 'auto' }}>
        <svg viewBox={`0 0 ${width} ${height}`} width="100%" role="img" aria-label="Tests exécutés par jour sur 14 jours" data-testid="chart-days"
          style={{ minWidth: 420 }}>
          {ticks.map((tick) => {
            const y = height - bottom - scale(tick);
            return (
              <g key={tick}>
                <line x1={left} x2={width} y1={y} y2={y} stroke="var(--mantine-color-default-border)" strokeDasharray={tick === 0 ? undefined : '3 3'} />
                <text x={left - 6} y={y + 4} fontSize={11} textAnchor="end" fill="var(--mantine-color-dimmed)">
                  {tick}
                </text>
              </g>
            );
          })}
          {days.map((day, index) => {
            const x = left + index * step + (step - bar) / 2;
            let y = height - bottom;
            return (
              <g key={day.day}>
                {SERIES.map((serie) => {
                  const value = day[serie.key];
                  const h = scale(value);
                  y -= h;
                  return value > 0 ? (
                    <rect key={serie.key} x={x} y={y} width={bar} height={h} fill={serie.color} rx={2}>
                      <title>{`${new Date(day.day).toLocaleDateString('fr-FR')} : ${value} ${serie.label.toLowerCase()}`}</title>
                    </rect>
                  ) : null;
                })}
                {((days.length - 1 - index) % 2 === 0 || days.length <= 7) && (
                  <text x={x + bar / 2} y={height - 6} fontSize={10} textAnchor="middle" fill="var(--mantine-color-dimmed)">
                    {new Date(day.day).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' })}
                  </text>
                )}
              </g>
            );
          })}
        </svg>
      </Box>
      <Group gap="md" mt={4}>
        {SERIES.map((serie) => (
          <Group key={serie.key} gap={6}>
            <Box w={10} h={10} style={{ background: serie.color, borderRadius: 2 }} />
            <Text size="xs" c="dimmed">
              {serie.label}
            </Text>
          </Group>
        ))}
      </Group>
    </Box>
  );
}
