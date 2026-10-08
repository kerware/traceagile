import { Fieldset, Group, Input, SegmentedControl, Stack, TagsInput, Text, Textarea, TextInput } from '@mantine/core';
import { useTranslation } from 'react-i18next';
import type { TestDraft } from './draft';
import { charterSentence, HEURISTICS, TIMEBOXES } from './model';

/** F-EXP-01 / F-EXP-02 charte exploratoire : mission guidée, durée cible, zones, heuristiques. */
export function CharterEditor({ draft, onChange, readOnly }: { draft: TestDraft; onChange: (patch: Partial<TestDraft>) => void; readOnly: boolean }) {
  const { t } = useTranslation();
  return (
    <Fieldset legend={t('charter.mission')} data-testid="charter-editor">
      <Stack>
        <Group grow align="flex-start">
          <TextInput label={t('charter.explore')} value={draft.explore} onChange={(e) => onChange({ explore: e.currentTarget.value })} disabled={readOnly} data-testid="charter-explore" />
          <TextInput label={t('charter.with')} value={draft.with} onChange={(e) => onChange({ with: e.currentTarget.value })} disabled={readOnly} data-testid="charter-with" />
          <TextInput label={t('charter.toDiscover')} value={draft.toDiscover} onChange={(e) => onChange({ toDiscover: e.currentTarget.value })} disabled={readOnly} data-testid="charter-to-discover" />
        </Group>
        <Text size="sm" fs="italic" c="dimmed" data-testid="charter-preview">
          {charterSentence(draft.explore, draft.with, draft.toDiscover)}
        </Text>
        <Input.Wrapper label={t('charter.timebox')}>
          <div>
            <SegmentedControl
              value={String(draft.timeboxMin)}
              onChange={(value) => onChange({ timeboxMin: Number(value) })}
              data={TIMEBOXES.map((m) => ({ value: String(m), label: t('charter.minutes', { count: m }) }))}
              disabled={readOnly}
              data-testid="charter-timebox"
            />
          </div>
        </Input.Wrapper>
        <TagsInput label={t('charter.areas')} value={draft.areas} onChange={(areas) => onChange({ areas })} disabled={readOnly} data-testid="charter-areas" />
        <TagsInput
          label={t('charter.heuristics')}
          description={t('charter.heuristicsHint')}
          data={HEURISTICS}
          value={draft.heuristics}
          onChange={(heuristics) => onChange({ heuristics })}
          disabled={readOnly}
          data-testid="charter-heuristics"
        />
        <TextInput label={t('charter.targetedRisk')} value={draft.targetedRisk} onChange={(e) => onChange({ targetedRisk: e.currentTarget.value })} disabled={readOnly} />
        <Textarea label={t('charter.setupNotes')} autosize minRows={2} value={draft.setupNotes} onChange={(e) => onChange({ setupNotes: e.currentTarget.value })} disabled={readOnly} />
      </Stack>
    </Fieldset>
  );
}
