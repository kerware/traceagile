import { Progress, type MantineSize } from '@mantine/core';

/** NF-10 barre de progression avec un nom accessible (axe « aria-progressbar-name »). */
export function LabeledProgress({ value, label, color, size, mt }: { value: number; label: string; color?: string; size?: MantineSize;
  mt?: number | string }) {
  return (
    <Progress.Root size={size} mt={mt}>
      <Progress.Section value={value} color={color} aria-label={label} />
    </Progress.Root>
  );
}
