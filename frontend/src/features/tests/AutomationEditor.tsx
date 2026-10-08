import { Alert, Autocomplete, Badge, Fieldset, Group, Input, NumberInput, Select, Stack, Switch, TagsInput, Text, TextInput } from '@mantine/core';
import { IconAlertTriangle } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useFrameworks, type TestCaseDetail } from '../../api/testcases';
import { CodeEditor } from '../../components/code/CodeEditor';
import { DataSetGrid } from './DataSetGrid';
import type { TestDraft } from './draft';
import { GherkinEditor } from './GherkinEditor';
import { KeyValueEditor } from './KeyValueEditor';
import { TECHNIQUES } from './model';

/**
 * §6.1 définition d'un test automatisé : identification résolue par le serveur d'exécution, tags
 * d'exécution (F-AUT-02), prérequis (F-AUT-03) et champs propres à la technique (ADR-0012).
 */
export function AutomationEditor({
  project,
  test,
  draft,
  onChange,
  readOnly,
}: {
  project: string;
  test: TestCaseDetail;
  draft: TestDraft;
  onChange: (patch: Partial<TestDraft>) => void;
  readOnly: boolean;
}) {
  const { t } = useTranslation();
  const { data: frameworks } = useFrameworks();
  const [parametersText, setParametersText] = useState(() => JSON.stringify(draft.parameters, null, 2));
  const [parametersError, setParametersError] = useState(false);
  const technique = draft.technique;
  const parameter = (name: string) => draft.parameters[name];
  const expected = (draft.parameters.expected ?? {}) as Record<string, unknown>;

  const setParameters = (parameters: Record<string, unknown>) => {
    onChange({ parameters });
    setParametersText(JSON.stringify(parameters, null, 2));
    setParametersError(false);
  };
  const setParameter = (name: string, value: unknown) => {
    const next = { ...draft.parameters };
    if (value === '' || value === undefined || (Array.isArray(value) && value.length === 0)) delete next[name];
    else next[name] = value;
    setParameters(next);
  };
  const setExpected = (name: string, value: number | string) => {
    const next = { ...expected };
    if (value === '') delete next[name];
    else next[name] = Number(value);
    setParameter('expected', Object.keys(next).length ? next : undefined);
  };

  return (
    <Stack>
      {test.automation?.missingInRepository && (
        <Alert color="red" icon={<IconAlertTriangle size={16} />} data-testid="missing-in-repository">
          {t('automation.missing')}
        </Alert>
      )}
      <Fieldset legend={t('automation.identification')}>
        <Stack>
          <Group grow align="flex-start">
            <Select
              label={t('test.technique')}
              data={TECHNIQUES.map((value) => ({ value, label: t(`technique.${value}`) }))}
              value={technique}
              onChange={(value) => value && onChange({ technique: value, framework: frameworks?.find((f) => f.technique === value)?.name ?? draft.framework })}
              allowDeselect={false}
              disabled={readOnly}
              data-testid="automation-technique"
            />
            <Autocomplete
              label={t('test.framework')}
              data={(frameworks ?? []).filter((f) => f.technique === technique).map((f) => f.name)}
              value={draft.framework}
              onChange={(framework) => onChange({ framework })}
              disabled={readOnly}
              data-testid="automation-framework"
            />
            <TextInput label={t('automation.language')} value={draft.language} onChange={(e) => onChange({ language: e.currentTarget.value })} disabled={readOnly} />
          </Group>
          <Group grow align="flex-start">
            <TextInput label={t('automation.repositoryUrl')} value={draft.repositoryUrl} onChange={(e) => onChange({ repositoryUrl: e.currentTarget.value })} disabled={readOnly} />
            <TextInput label={t('automation.branch')} value={draft.branch} onChange={(e) => onChange({ branch: e.currentTarget.value })} disabled={readOnly} />
          </Group>
          <Group grow align="flex-start">
            <TextInput label={t('automation.path')} value={draft.path} onChange={(e) => onChange({ path: e.currentTarget.value })} disabled={readOnly} data-testid="automation-path" />
            <TextInput
              label={t('automation.testIdentifier')}
              description={technique ? t(`techniqueHint.${technique}`) : undefined}
              value={draft.testIdentifier}
              onChange={(e) => onChange({ testIdentifier: e.currentTarget.value })}
              disabled={readOnly}
              data-testid="automation-identifier"
            />
          </Group>
          <TagsInput
            label={t('automation.executionTags')}
            description={t('automation.executionTagsHint')}
            data={['smoke', 'regression', 'nightly']}
            value={draft.executionTags}
            onChange={(executionTags) => onChange({ executionTags })}
            disabled={readOnly}
            data-testid="automation-execution-tags"
          />
          <KeyValueEditor
            label={t('automation.environment')}
            description={t('automation.environmentHint')}
            value={draft.environmentRequirements}
            onChange={(environmentRequirements) => onChange({ environmentRequirements })}
            readOnly={readOnly}
          />
        </Stack>
      </Fieldset>

      {technique === 'BDD' && <GherkinEditor project={project} value={draft.gherkinSource} onChange={(gherkinSource) => onChange({ gherkinSource })} readOnly={readOnly} />}
      {(technique === 'DATA_DRIVEN' || draft.dataSet.length > 0) && (
        <DataSetGrid label={t('automation.dataSet')} rows={draft.dataSet} onChange={(dataSet) => onChange({ dataSet })} readOnly={readOnly} typed />
      )}
      {technique === 'UI' && (
        <Group grow align="flex-start">
          <TagsInput
            label={t('automation.browsers')}
            data={['chromium', 'firefox', 'webkit', 'edge']}
            value={(parameter('browsers') as string[] | undefined) ?? []}
            onChange={(v) => setParameter('browsers', v)}
            disabled={readOnly}
          />
          <TextInput label={t('automation.resolution')} placeholder="1280x800" value={(parameter('resolution') as string | undefined) ?? ''} onChange={(e) => setParameter('resolution', e.currentTarget.value)} disabled={readOnly} />
        </Group>
      )}
      {technique === 'API' && (
        <Group grow align="flex-end">
          <TextInput label={t('automation.baseUrl')} value={(parameter('baseUrl') as string | undefined) ?? ''} onChange={(e) => setParameter('baseUrl', e.currentTarget.value)} disabled={readOnly} />
          <Switch label={t('automation.authRequired')} checked={parameter('authRequired') === true} onChange={(e) => setParameter('authRequired', e.currentTarget.checked)} disabled={readOnly} />
        </Group>
      )}
      {technique === 'PERFORMANCE' && (
        <Input.Wrapper label={t('automation.expectedMetrics')}>
          <Group grow>
            {(['p95Ms', 'throughputRps', 'errorRatePct'] as const).map((metric) => (
              <NumberInput key={metric} label={t(`automation.${metric}`)} value={(expected[metric] as number | undefined) ?? ''} onChange={(v) => setExpected(metric, v)} disabled={readOnly} />
            ))}
          </Group>
        </Input.Wrapper>
      )}
      {technique === 'KEYWORD' && (
        <Input.Wrapper label={t('automation.keywords')}>
          <Group gap={4}>
            {(test.automation?.keywords ?? []).map((k) => (
              <Badge key={k} variant="light">
                {k}
              </Badge>
            ))}
            {(test.automation?.keywords ?? []).length === 0 && <Text size="sm" c="dimmed">—</Text>}
          </Group>
        </Input.Wrapper>
      )}

      <Input.Wrapper label={t('automation.parameters')} error={parametersError ? t('automation.parametersInvalid') : undefined}>
        <CodeEditor
          language="json"
          value={parametersText}
          height={160}
          readOnly={readOnly}
          ariaLabel={t('automation.parameters')}
          testId="automation-parameters"
          onChange={(text) => {
            setParametersText(text);
            try {
              const parsed = JSON.parse(text || '{}') as unknown;
              if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
                onChange({ parameters: parsed as Record<string, unknown> });
                setParametersError(false);
              } else setParametersError(true);
            } catch {
              setParametersError(true);
            }
          }}
        />
      </Input.Wrapper>
    </Stack>
  );
}
