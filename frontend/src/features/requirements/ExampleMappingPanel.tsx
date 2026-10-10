import { ActionIcon, Badge, Group, Loader, Menu, Paper, SimpleGrid, Stack, Text, TextInput, Title, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconDots, IconPlus, IconRotate, IconTransform } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import {
  useAddCard,
  useAddComment,
  useConvertCard,
  useDeleteCard,
  useEditCard,
  useExampleMap,
  useResolveComment,
  type Comment,
  type ExampleCard,
} from '../../api/workshop';
import { PromptModal } from '../../components/Dialogs';
import { KeyLink } from '../../components/keys/KeyLink';
import { OpenQuestionsAlert } from './CommentsPanel';
import { useCanComment, useCanContribute, useCanWriteRequirements } from './permissions';

const COLORS = { story: 'yellow', rule: 'blue', example: 'green', question: 'red' } as const;

/**
 * §4.4 atelier Example Mapping (F-REQ-13) : Story (jaune), Règles (bleu), Exemples (vert, par règle),
 * Questions (rouge). Conversions F-REQ-14 : règle → règle métier enfant, exemple → critère Gherkin.
 */
export function ExampleMappingPanel({ project, requirementKey }: { project: string; requirementKey: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useExampleMap(project, requirementKey);
  const canContribute = useCanContribute(project);
  const canComment = useCanComment(project);
  const addCard = useAddCard(project, requirementKey);
  const addComment = useAddComment(project, requirementKey);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  if (isLoading || !data) return <Loader />;
  const questions = [...data.questions].sort((a, b) => Number(b.open) - Number(a.open));

  return (
    <Stack data-testid="example-mapping">
      <OpenQuestionsAlert count={data.openQuestions} />
      <SimpleGrid cols={4} spacing="sm">
        <Column title={t('exampleMapping.story')} color={COLORS.story}>
          <Paper p="sm" bg="var(--mantine-color-yellow-light)" withBorder data-testid="em-story">
            <Text size="xs" ff="monospace" fw={700}>
              {data.storyKey}
            </Text>
            <Text fw={600}>{data.storyTitle}</Text>
            {data.iWant && (
              <Text size="sm" mt={4}>
                {t('requirement.asA')} {data.asA ?? '…'}, {t('exampleMapping.iWant')} {data.iWant}
                {data.soThat ? `, ${t('exampleMapping.soThat')} ${data.soThat}` : ''}
              </Text>
            )}
          </Paper>
        </Column>

        <Column title={t('exampleMapping.rules')} color={COLORS.rule} count={data.rules.length}>
          {data.rules.map((r, index) => (
            <CardView key={r.rule.id} project={project} requirementKey={requirementKey} card={r.rule} label={t('exampleMapping.ruleN', { n: index + 1 })}
              color={COLORS.rule} canContribute={canContribute} />
          ))}
          {canContribute && (
            <AddInput testId="em-add-rule" placeholder={t('exampleMapping.newRule')}
              onAdd={(text) => addCard.mutateAsync({ kind: 'RULE', text }).catch(fail)} />
          )}
        </Column>

        <Column title={t('exampleMapping.examples')} color={COLORS.example} count={data.rules.reduce((n, r) => n + r.examples.length, 0)}>
          {data.rules.length === 0 && (
            <Text size="xs" c="dimmed">
              {t('exampleMapping.noRule')}
            </Text>
          )}
          {data.rules.map((r, index) => (
            <Stack key={r.rule.id} gap={4} data-testid={`em-examples-${index + 1}`}>
              <Text size="xs" c="dimmed" fw={600}>
                {t('exampleMapping.ruleN', { n: index + 1 })}
              </Text>
              {r.examples.map((e) => (
                <CardView key={e.id} project={project} requirementKey={requirementKey} card={e} color={COLORS.example} canContribute={canContribute} />
              ))}
              {canContribute && (
                <AddInput testId={`em-add-example-${index + 1}`} placeholder={t('exampleMapping.newExample')}
                  onAdd={(text) => addCard.mutateAsync({ kind: 'EXAMPLE', ruleId: r.rule.id, text }).catch(fail)} />
              )}
            </Stack>
          ))}
        </Column>

        <Column title={t('exampleMapping.questions')} color={COLORS.question} count={data.openQuestions}>
          {questions.map((q) => (
            <QuestionView key={q.id} project={project} requirementKey={requirementKey} question={q} canComment={canComment} />
          ))}
          {canComment && (
            <AddInput testId="em-add-question" placeholder={t('exampleMapping.newQuestion')}
              onAdd={(text) => addComment.mutateAsync({ text, question: true }).catch(fail)} />
          )}
        </Column>
      </SimpleGrid>
    </Stack>
  );
}

function Column({ title, color, count, children }: { title: string; color: string; count?: number; children: React.ReactNode }) {
  return (
    <Stack gap="xs">
      <Group gap={6}>
        <span style={{ width: 10, height: 10, borderRadius: 2, background: `var(--mantine-color-${color}-6)` }} aria-hidden />
        <Title order={6}>{title}</Title>
        {count !== undefined && (
          <Badge size="xs" color={color} variant="light">
            {count}
          </Badge>
        )}
      </Group>
      {children}
    </Stack>
  );
}

function AddInput({ placeholder, onAdd, testId }: { placeholder: string; onAdd: (text: string) => Promise<unknown>; testId: string }) {
  const [text, setText] = useState('');
  const submit = async () => {
    if (!text.trim()) return;
    await onAdd(text.trim());
    setText('');
  };
  return (
    <TextInput size="xs" value={text} placeholder={placeholder} aria-label={placeholder} onChange={(e) => setText(e.currentTarget.value)}
      onKeyDown={(e) => {
        if (e.key === 'Enter') void submit();
      }}
      rightSection={
        <ActionIcon size="sm" variant="subtle" onClick={() => void submit()} aria-label={placeholder} data-testid={`${testId}-submit`}>
          <IconPlus size={14} />
        </ActionIcon>
      }
      data-testid={testId} />
  );
}

function CardView({ project, requirementKey, card, color, label, canContribute }: { project: string; requirementKey: string; card: ExampleCard;
  color: string; label?: string; canContribute: boolean }) {
  const { t } = useTranslation();
  const canWrite = useCanWriteRequirements(project);
  const edit = useEditCard(project, requirementKey);
  const remove = useDeleteCard(project, requirementKey);
  const convert = useConvertCard(project, requirementKey);
  const [editing, setEditing] = useState(false);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
  const canConvert = !card.convertedTo && (card.kind === 'EXAMPLE' ? canContribute : canWrite);
  const onConvert = () =>
    convert.mutate(card.id, {
      onSuccess: (result) => notifications.show({ color: 'green', message: result.requirementKey
        ? t('exampleMapping.ruleConverted', { key: result.requirementKey })
        : t('exampleMapping.exampleConverted', { position: result.criterionPosition }) }),
      onError: fail,
    });

  return (
    <Paper p="xs" withBorder bg={`var(--mantine-color-${color}-light)`} data-testid={`em-card-${card.text}`}>
      <Group justify="space-between" align="flex-start" wrap="nowrap" gap={4}>
        <Stack gap={2}>
          {label && (
            <Text size="xs" c="dimmed" fw={600}>
              {label}
            </Text>
          )}
          <Text size="sm">{card.text}</Text>
          {card.convertedTo && (
            <Group gap={4}>
              <IconCheck size={12} />
              <Text size="xs" c="dimmed">
                {t('exampleMapping.convertedTo')}{' '}
              </Text>
              {card.convertedTo.startsWith('REQ-') ? <KeyLink project={project} itemKey={card.convertedTo} size="xs" />
                : <Text size="xs">{card.convertedTo}</Text>}
            </Group>
          )}
        </Stack>
        {canContribute && (
          <Menu position="bottom-end" withinPortal>
            <Menu.Target>
              <ActionIcon size="sm" variant="subtle" aria-label={t('exampleMapping.actions')} data-testid="em-card-menu">
                <IconDots size={14} />
              </ActionIcon>
            </Menu.Target>
            <Menu.Dropdown>
              {canConvert && (
                <Menu.Item leftSection={<IconTransform size={14} />} onClick={onConvert} data-testid="em-convert">
                  {card.kind === 'RULE' ? t('exampleMapping.convertRule') : t('exampleMapping.convertExample')}
                </Menu.Item>
              )}
              <Menu.Item onClick={() => setEditing(true)} data-testid="em-edit">
                {t('common.edit')}
              </Menu.Item>
              <Menu.Item color="red" onClick={() => remove.mutate(card.id, { onError: fail })} data-testid="em-delete">
                {t('common.delete')}
              </Menu.Item>
            </Menu.Dropdown>
          </Menu>
        )}
      </Group>
      <PromptModal opened={editing} title={t('exampleMapping.editCard')} label={t('exampleMapping.text')} initialValue={card.text}
        submitLabel={t('common.save')} onSubmit={(text) => edit.mutateAsync({ id: card.id, text })} onClose={() => setEditing(false)} />
    </Paper>
  );
}

function QuestionView({ project, requirementKey, question, canComment }: { project: string; requirementKey: string; question: Comment; canComment: boolean }) {
  const { t } = useTranslation();
  const resolve = useResolveComment(project, requirementKey);
  return (
    <Paper p="xs" withBorder bg={question.open ? 'var(--mantine-color-red-light)' : undefined} data-testid={`em-question-${question.text}`}
      style={question.open ? undefined : { opacity: 0.7 }}>
      <Group justify="space-between" align="flex-start" wrap="nowrap" gap={4}>
        <Stack gap={2}>
          <Text size="sm" td={question.open ? undefined : 'line-through'}>
            {question.text}
          </Text>
          <Text size="xs" c="dimmed">
            {question.author}
            {!question.open && question.resolvedBy ? ` · ${t('comments.resolvedBy', { by: question.resolvedBy })}` : ''}
          </Text>
        </Stack>
        {canComment && (
          <Tooltip label={question.open ? t('comments.resolve') : t('comments.reopen')}>
            <ActionIcon size="sm" variant="subtle" aria-label={question.open ? t('comments.resolve') : t('comments.reopen')}
              onClick={() => resolve.mutate({ id: question.id, resolved: question.open })} data-testid="em-resolve">
              {question.open ? <IconCheck size={14} /> : <IconRotate size={14} />}
            </ActionIcon>
          </Tooltip>
        )}
      </Group>
    </Paper>
  );
}

