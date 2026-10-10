import { ActionIcon, Anchor, FileButton, Group, Image, Loader, Paper, Stack, Text, Tooltip } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconFile, IconPaperclip, IconTrash } from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../../api/errors';
import { attachmentUrl, useAttachments, useDeleteAttachment, useUploadAttachment, type Attachment, type AttachmentTarget } from '../../api/workshop';
import { ConfirmModal } from '../Dialogs';

/** Formats proposés au téléversement (le serveur vérifie de nouveau, ADR-0024). */
const ACCEPT = 'image/png,image/jpeg,image/gif,image/webp,application/pdf,text/plain,.log,.md,application/json,application/xml,text/csv';

/**
 * ADR-0024 pièces jointes d'un élément (exigence, pas d'exécution, anomalie, note de session) :
 * téléversement, collage d'une image (presse-papier, F-EXP-08) quand {@code pasteZone} est actif,
 * vignettes des images, suppression.
 */
export function AttachmentsPanel({ project, target, targetId, canWrite, testId = 'attachments', compact = false, pasteZone = false }: {
  project: string;
  target: AttachmentTarget;
  targetId: string;
  canWrite: boolean;
  testId?: string;
  compact?: boolean;
  /** Le panneau accepte le collage d'une image quand il a le focus. */
  pasteZone?: boolean;
}) {
  const { t } = useTranslation();
  const { data, isLoading } = useAttachments(project, target, [targetId]);
  const upload = useUploadAttachment(project);
  const remove = useDeleteAttachment(project);
  const [deleting, setDeleting] = useState<Attachment | null>(null);

  const send = (file: File | null) => {
    if (!file) return;
    upload.mutate({ target, targetId, file }, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) });
  };
  const onPaste = (event: React.ClipboardEvent) => {
    const image = Array.from(event.clipboardData.files).find((f) => f.type.startsWith('image/'));
    if (image) {
      event.preventDefault();
      send(new File([image], image.name && image.name !== 'image.png' ? image.name : `capture-${Date.now()}.png`, { type: image.type }));
    }
  };

  return (
    <Paper withBorder={!compact} p={compact ? 0 : 'xs'} tabIndex={pasteZone && canWrite ? 0 : undefined} onPaste={pasteZone && canWrite ? onPaste : undefined}
      data-testid={testId} aria-label={t('attachments.title')}>
      <Stack gap={6}>
        <Group justify="space-between" gap="xs">
          <Group gap={4}>
            <IconPaperclip size={14} />
            <Text size="xs" fw={600}>
              {t('attachments.title')} ({data?.length ?? 0})
            </Text>
            {pasteZone && canWrite && (
              <Text size="xs" c="dimmed">
                {t('attachments.pasteHint')}
              </Text>
            )}
          </Group>
          {canWrite && (
            <FileButton onChange={send} accept={ACCEPT}>
              {(props) => (
                <Anchor component="button" type="button" size="xs" {...props} data-testid={`${testId}-add`}>
                  {upload.isPending ? <Loader size={10} /> : t('attachments.add')}
                </Anchor>
              )}
            </FileButton>
          )}
        </Group>
        {isLoading && <Loader size="xs" />}
        {!!data?.length && (
          <Group gap="xs">
            {data.map((a) => (
              <AttachmentItem key={a.id} project={project} attachment={a} canWrite={canWrite} onDelete={() => setDeleting(a)} />
            ))}
          </Group>
        )}
      </Stack>
      <ConfirmModal opened={!!deleting} title={t('attachments.deleteTitle')} message={t('attachments.deleteMessage', { name: deleting?.fileName ?? '' })}
        confirmLabel={t('common.delete')} onConfirm={() => remove.mutateAsync(deleting?.id ?? '')} onClose={() => setDeleting(null)} />
    </Paper>
  );
}

function AttachmentItem({ project, attachment, canWrite, onDelete }: { project: string; attachment: Attachment; canWrite: boolean; onDelete: () => void }) {
  const { t } = useTranslation();
  const [url, setUrl] = useState<string | null>(null);
  useEffect(() => {
    if (!attachment.image) return;
    let objectUrl: string | null = null;
    let cancelled = false;
    attachmentUrl(project, attachment.id).then((u) => {
      if (cancelled) URL.revokeObjectURL(u);
      else {
        objectUrl = u;
        setUrl(u);
      }
    }).catch(() => undefined);
    return () => {
      cancelled = true;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [project, attachment.id, attachment.image]);

  const open = async () => {
    try {
      const u = url ?? (await attachmentUrl(project, attachment.id));
      const link = document.createElement('a');
      link.href = u;
      link.target = '_blank';
      link.rel = 'noopener';
      if (!attachment.image) link.download = attachment.fileName;
      document.body.appendChild(link);
      link.click();
      link.remove();
    } catch (e) {
      notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) });
    }
  };

  return (
    <Paper withBorder p={4} w={attachment.image ? 128 : undefined} data-testid={`attachment-${attachment.fileName}`}>
      <Stack gap={2}>
        {attachment.image && (url ? <Image src={url} alt={attachment.fileName} h={72} fit="contain" onClick={open} style={{ cursor: 'zoom-in' }} /> : <Loader size="xs" />)}
        <Group gap={4} wrap="nowrap" justify="space-between">
          <Anchor component="button" type="button" size="xs" onClick={open} truncate maw={attachment.image ? 90 : 220} title={attachment.fileName}>
            {!attachment.image && <IconFile size={12} />} {attachment.fileName}
          </Anchor>
          {canWrite && (
            <Tooltip label={t('common.delete')}>
              <ActionIcon size="xs" variant="subtle" color="red" onClick={onDelete} aria-label={t('attachments.delete', { name: attachment.fileName })}>
                <IconTrash size={12} />
              </ActionIcon>
            </Tooltip>
          )}
        </Group>
      </Stack>
    </Paper>
  );
}
