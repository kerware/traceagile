import { ActionIcon, Alert, Badge, Button, Checkbox, Group, Loader, Paper, Stack, Text, Textarea, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconEdit, IconHelpCircle, IconRotate, IconTrash } from '@tabler/icons-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { useAddComment, useComments, useDeleteComment, useEditComment, useResolveComment, type Comment } from '../../api/workshop';
import { AttachmentsPanel } from '../../components/attachments/AttachmentsPanel';
import { ConfirmModal } from '../../components/Dialogs';
import { MarkdownView } from '../../components/markdown/MarkdownView';
import { useAuthStore } from '../auth/authStore';
import { useCanComment } from './permissions';

/**
 * §13.2 onglet Commentaires (ADR-0024) : fil de discussion en Markdown, questions ouvertes ou résolues
 * (F-REQ-14 / F-REQ-15), pièces jointes de l'exigence.
 */
export function CommentsPanel({ project, requirementKey, requirementId }: { project: string; requirementKey: string; requirementId: string }) {
  const { t } = useTranslation();
  const { data, isLoading } = useComments(project, requirementKey);
  const add = useAddComment(project, requirementKey);
  const canComment = useCanComment(project);
  const [text, setText] = useState('');
  const [question, setQuestion] = useState(false);
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  const submit = () =>
    add.mutate({ text, question }, {
      onSuccess: () => {
        setText('');
        setQuestion(false);
      },
      onError: fail,
    });

  return (
    <Stack data-testid="comments-panel">
      {isLoading && <Loader size="sm" />}
      {data?.length === 0 && (
        <Text c="dimmed" size="sm">
          {t('comments.empty')}
        </Text>
      )}
      {data?.map((c) => <CommentItem key={c.id} project={project} requirementKey={requirementKey} comment={c} canComment={canComment} />)}
      {canComment && (
        <Paper withBorder p="sm">
          <Stack gap="xs">
            <Textarea placeholder={t('comments.placeholder')} value={text} onChange={(e) => setText(e.currentTarget.value)} autosize minRows={2}
              aria-label={t('comments.new')} data-testid="comment-input" />
            <Group justify="space-between">
              <Checkbox label={t('comments.asQuestion')} checked={question} onChange={(e) => setQuestion(e.currentTarget.checked)}
                data-testid="comment-question" />
              <Button size="xs" onClick={submit} loading={add.isPending} disabled={!text.trim()} data-testid="comment-submit">
                {t('comments.send')}
              </Button>
            </Group>
          </Stack>
        </Paper>
      )}
      <AttachmentsPanel project={project} target="REQUIREMENT" targetId={requirementId} canWrite={canComment} testId="requirement-attachments" pasteZone />
    </Stack>
  );
}

function CommentItem({ project, requirementKey, comment, canComment }: { project: string; requirementKey: string; comment: Comment; canComment: boolean }) {
  const { t } = useTranslation();
  const login = useAuthStore((s) => s.user?.login);
  const edit = useEditComment(project, requirementKey);
  const remove = useDeleteComment(project, requirementKey);
  const resolve = useResolveComment(project, requirementKey);
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(comment.text);
  const [deleting, setDeleting] = useState(false);
  const mine = comment.author === login;
  const fail = (e: unknown) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });

  return (
    <Paper withBorder p="sm" data-testid={`comment-${comment.id}`} style={comment.open ? { borderColor: 'var(--mantine-color-red-4)' } : undefined}>
      <Group justify="space-between" align="flex-start">
        <Group gap={6}>
          <Text size="sm" fw={600}>
            {comment.author}
          </Text>
          <Text size="xs" c="dimmed">
            {new Date(comment.createdAt).toLocaleString()}
            {comment.editedAt ? ` · ${t('comments.edited')}` : ''}
          </Text>
          {comment.question && (
            <Badge size="sm" color={comment.open ? 'red' : 'gray'} variant="light" leftSection={<IconHelpCircle size={12} />}
              data-testid={`comment-question-${comment.open ? 'open' : 'resolved'}`}>
              {comment.open ? t('comments.openQuestion') : t('comments.resolvedBy', { by: comment.resolvedBy ?? '—' })}
            </Badge>
          )}
        </Group>
        <Group gap={2}>
          {comment.question && canComment && (
            <Tooltip label={comment.open ? t('comments.resolve') : t('comments.reopen')}>
              <ActionIcon variant="subtle" size="sm" aria-label={comment.open ? t('comments.resolve') : t('comments.reopen')}
                onClick={() => resolve.mutate({ id: comment.id, resolved: comment.open }, { onError: fail })} data-testid="comment-resolve">
                {comment.open ? <IconCheck size={14} /> : <IconRotate size={14} />}
              </ActionIcon>
            </Tooltip>
          )}
          {mine && (
            <>
              <ActionIcon variant="subtle" size="sm" aria-label={t('common.edit')} onClick={() => setEditing(true)} data-testid="comment-edit">
                <IconEdit size={14} />
              </ActionIcon>
              <ActionIcon variant="subtle" size="sm" color="red" aria-label={t('common.delete')} onClick={() => setDeleting(true)} data-testid="comment-delete">
                <IconTrash size={14} />
              </ActionIcon>
            </>
          )}
        </Group>
      </Group>
      {editing ? (
        <Stack gap="xs" mt="xs">
          <Textarea value={draft} onChange={(e) => setDraft(e.currentTarget.value)} autosize minRows={2} aria-label={t('common.edit')} />
          <Group gap="xs" justify="flex-end">
            <Button size="xs" variant="default" onClick={() => setEditing(false)}>
              {t('common.cancel')}
            </Button>
            <Button size="xs" disabled={!draft.trim()} loading={edit.isPending}
              onClick={() => edit.mutate({ id: comment.id, text: draft }, { onSuccess: () => setEditing(false), onError: fail })}>
              {t('common.save')}
            </Button>
          </Group>
        </Stack>
      ) : (
        <MarkdownView project={project} source={comment.text} />
      )}
      <ConfirmModal opened={deleting} title={t('comments.deleteTitle')} message={t('comments.deleteMessage')} confirmLabel={t('common.delete')}
        onConfirm={() => remove.mutateAsync(comment.id)} onClose={() => setDeleting(false)} />
    </Paper>
  );
}

/** Rappel affiché en tête de l'atelier et de la DoR : questions ouvertes (F-REQ-15). */
export function OpenQuestionsAlert({ count }: { count: number }) {
  const { t } = useTranslation();
  if (count === 0) return null;
  return (
    <Alert color="red" variant="light" icon={<IconHelpCircle size={16} />} data-testid="open-questions">
      {t('comments.openQuestionsWarning', { count })}
    </Alert>
  );
}
