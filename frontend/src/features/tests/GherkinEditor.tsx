import { Alert, Badge, Input, List, Text } from '@mantine/core';
import { useDebouncedValue } from '@mantine/hooks';
import { IconCheck } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { Schemas } from '../../api/client';
import { validateGherkin } from '../../api/requirements';
import { fetchSteps } from '../../api/testcases';
import { CodeEditor } from '../../components/code/CodeEditor';

/**
 * F-AUT-04 éditeur Gherkin complet : coloration (Monaco, grammaire fr / en), autocomplétion des
 * étapes déjà utilisées dans le projet, validation à la frappe (même moteur que le serveur).
 */
export function GherkinEditor({
  project,
  value,
  onChange,
  readOnly,
}: {
  project: string;
  value: string;
  onChange: (value: string) => void;
  readOnly: boolean;
}) {
  const { t } = useTranslation();
  const [debounced] = useDebouncedValue(value, 400);
  const [validation, setValidation] = useState<Schemas['GherkinValidationResponse'] | null>(null);

  useEffect(() => {
    if (!debounced.trim()) {
      setValidation(null);
      return;
    }
    let cancelled = false;
    validateGherkin(debounced)
      .then((result) => !cancelled && setValidation(result))
      .catch(() => !cancelled && setValidation(null));
    return () => {
      cancelled = true;
    };
  }, [debounced]);

  return (
    <Input.Wrapper label={t('automation.gherkin')} description={t('automation.gherkinHint')}>
      <CodeEditor
        language="gherkin"
        value={value}
        onChange={onChange}
        readOnly={readOnly}
        height={320}
        markers={validation?.errors ?? []}
        completeSteps={async (prefix) => (await fetchSteps(project, prefix || undefined)).map((s) => s.text)}
        ariaLabel={t('automation.gherkin')}
        testId="gherkin-editor"
      />
      {validation?.valid && (
        <Text size="sm" c="green" mt={4} data-testid="gherkin-valid">
          <IconCheck size={14} /> {t('criteria.valid', { language: validation.language })}
        </Text>
      )}
      {validation && !validation.valid && (
        <Alert color="red" mt="xs" title={t('criteria.invalid')} data-testid="gherkin-errors">
          <List size="sm">
            {validation.errors.map((error) => (
              <List.Item key={`${error.line}-${error.column}-${error.message}`}>
                <Badge size="xs" variant="outline" color="red" mr={6}>
                  {t('criteria.line', { line: error.line })}
                </Badge>
                {error.message}
              </List.Item>
            ))}
          </List>
        </Alert>
      )}
    </Input.Wrapper>
  );
}
