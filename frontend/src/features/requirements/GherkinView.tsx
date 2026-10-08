import { Code } from '@mantine/core';

const KEYWORDS =
  /^(\s*)(Fonctionnalité|Feature|Plan du scénario|Plan du Scénario|Scenario Outline|Scénario|Scenario|Exemples|Examples|Exemple|Example|Contexte|Background|Règle|Rule|Étant donné que|Étant donné|Etant donné|Sachant que|Soit|Quand|Lorsque|Alors|Et|Mais|Given|When|Then|And|But)(:?)/;

/**
 * F-REQ-10 coloration syntaxique en lecture (mots-clés, tags, commentaires, tableaux). L'éditeur
 * Monaco avec grammaire Gherkin arrive au lot 2.
 */
export function GherkinView({ source }: { source: string }) {
  return (
    <Code block data-testid="gherkin-view">
      {source.split('\n').map((line, index) => (
        <div key={index}>{renderLine(line)}</div>
      ))}
    </Code>
  );
}

function renderLine(line: string) {
  const trimmed = line.trim();
  if (trimmed.startsWith('#')) return <span style={{ color: 'var(--mantine-color-dimmed)' }}>{line}</span>;
  if (trimmed.startsWith('@')) return <span style={{ color: 'var(--mantine-color-grape-6)' }}>{line}</span>;
  if (trimmed.startsWith('|')) return <span style={{ color: 'var(--mantine-color-cyan-7)' }}>{line}</span>;
  const match = KEYWORDS.exec(line);
  if (!match) return line || ' ';
  const [all, indent, keyword, colon] = match;
  return (
    <>
      {indent}
      <span style={{ color: 'var(--mantine-color-blue-7)', fontWeight: 700 }}>
        {keyword}
        {colon}
      </span>
      {line.slice(all.length)}
    </>
  );
}
