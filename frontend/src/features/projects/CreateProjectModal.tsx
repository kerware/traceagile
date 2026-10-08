import { zodResolver } from '@hookform/resolvers/zod';
import { Alert, Button, Group, Modal, Stack, Textarea, TextInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import { Controller, useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { z } from 'zod';
import { ApiError, errorMessage } from '../../api/errors';
import { useCreateProject } from '../../api/queries';

/** §12 POST /projects ; §3.1 clé de 3 à 10 lettres majuscules, unique. */
export function CreateProjectModal({ opened, onClose }: { opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const createProject = useCreateProject();
  const [failure, setFailure] = useState<string | null>(null);

  const schema = z.object({
    key: z.string().regex(/^[A-Z]{3,10}$/, t('projects.keyInvalid')),
    name: z.string().trim().min(1, t('auth.required')).max(200),
    description: z.string(),
  });
  type Form = z.infer<typeof schema>;
  const {
    control,
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<Form>({ resolver: zodResolver(schema), defaultValues: { key: '', name: '', description: '' } });

  const close = () => {
    reset();
    setFailure(null);
    onClose();
  };

  const onSubmit = async (form: Form) => {
    setFailure(null);
    try {
      const project = await createProject.mutateAsync(form);
      notifications.show({ color: 'green', message: t('projects.created', { key: project.key }) });
      close();
    } catch (error) {
      if (error instanceof ApiError && error.code === 'PROJECT_KEY_TAKEN') {
        setError('key', { message: error.message });
      } else if (error instanceof ApiError && Object.keys(error.fieldErrors).length > 0) {
        Object.entries(error.fieldErrors).forEach(([field, message]) => setError(field as keyof Form, { message }));
      } else {
        setFailure(errorMessage(error, t('errors.generic')));
      }
    }
  };

  return (
    <Modal opened={opened} onClose={close} title={t('projects.create')}>
      <form onSubmit={handleSubmit(onSubmit)} noValidate>
        <Stack>
          {failure && (
            <Alert color="red" role="alert">
              {failure}
            </Alert>
          )}
          <Controller
            control={control}
            name="key"
            render={({ field }) => (
              <TextInput
                label={t('projects.key')}
                description={t('projects.keyHint')}
                required
                data-testid="project-key-input"
                error={errors.key?.message}
                {...field}
                onChange={(e) => field.onChange(e.currentTarget.value.toUpperCase())}
              />
            )}
          />
          <TextInput
            label={t('projects.name')}
            required
            data-testid="project-name-input"
            error={errors.name?.message}
            {...register('name')}
          />
          <Textarea
            label={t('projects.description')}
            autosize
            minRows={2}
            data-testid="project-description-input"
            {...register('description')}
          />
          <Group justify="flex-end">
            <Button variant="default" onClick={close} data-testid="project-cancel">
              {t('projects.cancel')}
            </Button>
            <Button type="submit" loading={isSubmitting} data-testid="project-save">
              {t('projects.save')}
            </Button>
          </Group>
        </Stack>
      </form>
    </Modal>
  );
}
