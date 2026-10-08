import { Loader, Textarea } from '@mantine/core';
import { lazy, Suspense } from 'react';

export interface EditorMarker {
  line: number;
  column: number;
  message: string;
}

export interface CodeEditorProps {
  language: 'gherkin' | 'json';
  value: string;
  onChange: (value: string) => void;
  readOnly?: boolean;
  height?: number;
  markers?: EditorMarker[];
  /** F-AUT-04 suggestions d'étapes pour un début de texte. */
  completeSteps?: (prefix: string) => Promise<string[]>;
  ariaLabel?: string;
  testId?: string;
}

const MonacoCodeEditor = lazy(() => import('./MonacoCodeEditor'));

/**
 * §11.1 éditeur de code (Monaco : Gherkin, JSON). Monaco ne fonctionne pas dans jsdom : en test,
 * une zone de texte le remplace, avec le même contrat.
 */
export function CodeEditor(props: CodeEditorProps) {
  if (import.meta.env.MODE === 'test') {
    return (
      <Textarea
        aria-label={props.ariaLabel}
        value={props.value}
        onChange={(e) => props.onChange(e.currentTarget.value)}
        readOnly={props.readOnly}
        autosize
        minRows={4}
        data-testid={props.testId}
      />
    );
  }
  return (
    <div data-testid={props.testId} style={{ border: '1px solid var(--mantine-color-default-border)', borderRadius: 4 }}>
      <Suspense fallback={<Loader size="sm" m="sm" />}>
        <MonacoCodeEditor {...props} />
      </Suspense>
    </div>
  );
}
