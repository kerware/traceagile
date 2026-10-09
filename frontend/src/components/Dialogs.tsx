import { Alert, Autocomplete, Button, Group, Modal, Stack, Text, TextInput } from '@mantine/core';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { errorMessage } from '../api/errors';

/** Saisie d'une valeur (nom de dossier…) ; l'erreur de l'API reste affichée dans la fenêtre. */
export function PromptModal({
  opened,
  title,
  label,
  description,
  initialValue = '',
  suggestions,
  submitLabel,
  onSubmit,
  onClose,
}: {
  opened: boolean;
  title: string;
  label: string;
  description?: string;
  initialValue?: string;
  suggestions?: string[];
  submitLabel: string;
  onSubmit: (value: string) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [value, setValue] = useState(initialValue);
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  useEffect(() => {
    if (opened) {
      setValue(initialValue);
      setError(null);
    }
  }, [opened, initialValue]);

  const submit = async () => {
    setPending(true);
    setError(null);
    try {
      await onSubmit(value.trim());
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    } finally {
      setPending(false);
    }
  };
  const inputProps = {
    label,
    description,
    value,
    'data-autofocus': true,
    'data-testid': 'prompt-input',
    onKeyDown: (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && value.trim()) void submit();
    },
  };

  return (
    <Modal opened={opened} onClose={onClose} title={title}>
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        {suggestions ? (
          <Autocomplete {...inputProps} data={suggestions} onChange={setValue} />
        ) : (
          <TextInput {...inputProps} onChange={(e) => setValue(e.currentTarget.value)} />
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={pending} disabled={!value.trim()} data-testid="prompt-submit">
            {submitLabel}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}

/** Confirmation d'une action irréversible (suppression). */
export function ConfirmModal({
  opened,
  title,
  message,
  confirmLabel,
  onConfirm,
  onClose,
}: {
  opened: boolean;
  title: string;
  message: string;
  confirmLabel: string;
  onConfirm: () => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  useEffect(() => {
    if (opened) setError(null);
  }, [opened]);

  const confirm = async () => {
    setPending(true);
    try {
      await onConfirm();
      onClose();
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    } finally {
      setPending(false);
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={title}>
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        <Text size="sm">{message}</Text>
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button color="red" onClick={confirm} loading={pending} data-testid="confirm-submit">
            {confirmLabel}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
