import Editor, { type OnMount } from '@monaco-editor/react';
import { useComputedColorScheme } from '@mantine/core';
import { useEffect, useRef } from 'react';
import type { CodeEditorProps } from './CodeEditor';
import { monaco, stepSources } from './monacoSetup';

/** Éditeur Monaco (chargé à la demande par {@link CodeEditor}). */
export default function MonacoCodeEditor({ language, value, onChange, readOnly, height = 280, markers = [], completeSteps, ariaLabel }: CodeEditorProps) {
  const scheme = useComputedColorScheme('light');
  const editorRef = useRef<Parameters<OnMount>[0] | null>(null);

  const onMount: OnMount = (editor) => {
    editorRef.current = editor;
    const model = editor.getModel();
    if (model && completeSteps) stepSources.set(model.uri.toString(), completeSteps);
  };

  useEffect(() => {
    const model = editorRef.current?.getModel();
    if (!model) return;
    monaco.editor.setModelMarkers(
      model,
      'validation',
      markers.map((m) => ({
        startLineNumber: m.line,
        endLineNumber: m.line,
        startColumn: m.column,
        endColumn: model.getLineMaxColumn(Math.min(m.line, model.getLineCount())),
        message: m.message,
        severity: monaco.MarkerSeverity.Error,
      })),
    );
  }, [markers]);

  useEffect(
    () => () => {
      const model = editorRef.current?.getModel();
      if (model) stepSources.delete(model.uri.toString());
    },
    [],
  );

  return (
    <Editor
      height={height}
      language={language}
      value={value}
      onChange={(next) => onChange(next ?? '')}
      onMount={onMount}
      theme={language === 'gherkin' ? (scheme === 'dark' ? 'gherkin-dark' : 'gherkin-light') : scheme === 'dark' ? 'vs-dark' : 'vs'}
      options={{
        readOnly,
        minimap: { enabled: false },
        fontSize: 13,
        scrollBeyondLastLine: false,
        wordWrap: 'on',
        // La molette fait défiler la page quand l'éditeur n'a plus rien à faire défiler.
        scrollbar: { alwaysConsumeMouseWheel: false },
        tabSize: 2,
        ariaLabel,
        quickSuggestions: language === 'gherkin' ? { other: true, comments: false, strings: false } : undefined,
      }}
    />
  );
}
