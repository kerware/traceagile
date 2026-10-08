import { loader } from '@monaco-editor/react';
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api';
import 'monaco-editor/esm/vs/language/json/monaco.contribution';
import EditorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker';
import JsonWorker from 'monaco-editor/esm/vs/language/json/json.worker?worker';

/**
 * §11.1 Monaco servi par l'application elle-même (pas de CDN : CSP et usage hors ligne). Seuls
 * l'éditeur, JSON et la grammaire Gherkin maison sont chargés.
 */
self.MonacoEnvironment = {
  getWorker: (_id: string, label: string) => (label === 'json' ? new JsonWorker() : new EditorWorker()),
};
loader.config({ monaco });

const STEP_KEYWORDS = [
  'Étant donné que', 'Étant donné', 'Etant donné', 'Sachant que', 'Soit', 'Quand', 'Lorsque', 'Alors', 'Et', 'Mais',
  'Given', 'When', 'Then', 'And', 'But',
];
const BLOCK_KEYWORDS = [
  'Fonctionnalité', 'Feature', 'Contexte', 'Background', 'Plan du scénario', 'Scenario Outline', 'Scénario', 'Scenario',
  'Exemples', 'Examples', 'Exemple', 'Example', 'Règle', 'Rule',
];
const STEP_LINE = new RegExp(`^\\s*(${STEP_KEYWORDS.join('|')})\\s+(.*)$`);

/** Sources de suggestions par modèle (une par éditeur ouvert). */
export const stepSources = new Map<string, (prefix: string) => Promise<string[]>>();

monaco.languages.register({ id: 'gherkin', extensions: ['.feature'] });
monaco.languages.setMonarchTokensProvider('gherkin', {
  tokenizer: {
    root: [
      [/^\s*#.*$/, 'comment'],
      [/@[^\s@]+/, 'tag'],
      [new RegExp(`^\\s*(${BLOCK_KEYWORDS.join('|')})\\s*:`), 'keyword'],
      [new RegExp(`^\\s*(${STEP_KEYWORDS.join('|')})(?=\\s)`), 'keyword.step'],
      [/"""/, 'string', '@docString'],
      [/"[^"]*"/, 'string'],
      [/<[^>]+>/, 'variable'],
      [/\|/, 'delimiter'],
      [/\d+([.,]\d+)?/, 'number'],
    ],
    docString: [
      [/"""/, 'string', '@pop'],
      [/./, 'string'],
    ],
  },
});
monaco.editor.defineTheme('gherkin-light', {
  base: 'vs',
  inherit: true,
  rules: [
    { token: 'keyword', foreground: '1c7ed6', fontStyle: 'bold' },
    { token: 'keyword.step', foreground: '1971c2', fontStyle: 'bold' },
    { token: 'tag', foreground: 'ae3ec9' },
    { token: 'variable', foreground: 'e8590c' },
  ],
  colors: {},
});
monaco.editor.defineTheme('gherkin-dark', {
  base: 'vs-dark',
  inherit: true,
  rules: [
    { token: 'keyword', foreground: '74c0fc', fontStyle: 'bold' },
    { token: 'keyword.step', foreground: '74c0fc', fontStyle: 'bold' },
    { token: 'tag', foreground: 'e599f7' },
    { token: 'variable', foreground: 'ffa94d' },
  ],
  colors: {},
});

/** F-AUT-04 autocomplétion des étapes déjà utilisées dans le projet. */
monaco.languages.registerCompletionItemProvider('gherkin', {
  triggerCharacters: [' '],
  provideCompletionItems: async (model, position) => {
    const line = model.getLineContent(position.lineNumber).slice(0, position.column - 1);
    const match = STEP_LINE.exec(line);
    const source = stepSources.get(model.uri.toString());
    if (!match || !source) {
      return {
        suggestions: [...BLOCK_KEYWORDS, ...STEP_KEYWORDS].map((keyword) => ({
          label: keyword,
          kind: monaco.languages.CompletionItemKind.Keyword,
          insertText: keyword,
          range: model.getWordUntilPosition(position) && {
            startLineNumber: position.lineNumber,
            endLineNumber: position.lineNumber,
            startColumn: model.getWordUntilPosition(position).startColumn,
            endColumn: position.column,
          },
        })),
      };
    }
    const prefix = match[2] ?? '';
    const steps = await source(prefix);
    return {
      suggestions: steps.map((text) => ({
        label: text,
        kind: monaco.languages.CompletionItemKind.Text,
        insertText: text,
        range: {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: position.column - prefix.length,
          endColumn: model.getLineMaxColumn(position.lineNumber),
        },
      })),
    };
  },
});

export { monaco };
