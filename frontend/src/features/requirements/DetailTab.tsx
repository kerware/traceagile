import {
  Alert,
  Anchor,
  Button,
  Checkbox,
  Divider,
  Fieldset,
  Grid,
  Group,
  NumberInput,
  Paper,
  Select,
  SimpleGrid,
  Stack,
  Switch,
  TagsInput,
  Text,
  TextInput,
  Title,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconAlertTriangle } from '@tabler/icons-react';
import { useEffect } from 'react';
import { Controller, useForm, useWatch } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import type { Schemas } from '../../api/client';
import { ApiError, errorMessage } from '../../api/errors';
import {
  useCheckItem,
  useRequirementChecklists,
  useSetInvest,
  useUpdateRequirement,
  type RequirementDetail,
  type RequirementPatch,
} from '../../api/requirements';
import { StatusBadge } from './Badges';
import { MarkdownField } from './MarkdownField';
import { FIBONACCI, needsSplitting, NFR_CATEGORIES, PRIORITIES, REQUIREMENT_TYPES, RISK_LEVELS, userStorySentence } from './model';
import { ChecklistResults } from './StatusMenu';

interface FormValues {
  type: string;
  title: string;
  description: string;
  asA: string;
  iWant: string;
  soThat: string;
  priority: string;
  businessValue: number | '';
  storyPoints: string | null;
  riskLevel: string;
  category: string | null;
  transverse: boolean;
  scale: string;
  measurementMethod: string;
  minimumThreshold: string;
  target: string;
  unit: string;
  tags: string[];
  externalRef: string;
}

function toForm(r: RequirementDetail): FormValues {
  return {
    type: r.type,
    title: r.title,
    description: r.description ?? '',
    asA: r.userStory.asA ?? '',
    iWant: r.userStory.iWant ?? '',
    soThat: r.userStory.soThat ?? '',
    priority: r.priority,
    businessValue: r.businessValue ?? '',
    storyPoints: r.storyPoints == null ? null : String(r.storyPoints),
    riskLevel: r.riskLevel,
    category: r.category ?? null,
    transverse: r.transverse,
    scale: r.planguage.scale ?? '',
    measurementMethod: r.planguage.measurementMethod ?? '',
    minimumThreshold: r.planguage.minimumThreshold ?? '',
    target: r.planguage.target ?? '',
    unit: r.planguage.unit ?? '',
    tags: r.tags,
    externalRef: r.externalRef ?? '',
  };
}

/** §12 merge-patch : seuls les champs modifiés, une chaîne vide efface la valeur. */
function toPatch(values: FormValues, dirty: Partial<Record<keyof FormValues, unknown>>): RequirementPatch {
  const patch: Record<string, unknown> = {};
  (Object.keys(dirty) as (keyof FormValues)[]).forEach((field) => {
    const value = values[field];
    if (field === 'storyPoints') patch.storyPoints = value === null ? null : Number(value);
    else if (field === 'businessValue') patch.businessValue = value === '' ? null : value;
    else if (typeof value === 'string') patch[field] = value.trim() === '' ? null : value;
    else patch[field] = value;
  });
  return patch as RequirementPatch;
}

/** Onglet Détail : F-REQ-05 à F-REQ-08, F-REQ-16 / F-REQ-17, F-REQ-19. */
export function DetailTab({
  project,
  requirement,
  canWrite,
  canContribute,
}: {
  project: string;
  requirement: RequirementDetail;
  canWrite: boolean;
  canContribute: boolean;
}) {
  const { t } = useTranslation();
  const update = useUpdateRequirement(project);
  const { control, register, handleSubmit, reset, setError, formState } = useForm<FormValues>({
    defaultValues: toForm(requirement),
  });

  useEffect(() => {
    reset(toForm(requirement));
  }, [requirement, reset]);

  // Re-rendu limité aux champs qui pilotent l'affichage (aperçu de la story, alerte, section ENF).
  const [type, asA, iWant, soThat, storyPoints] = useWatch({ control, name: ['type', 'asA', 'iWant', 'soThat', 'storyPoints'] });
  const readOnly = !canWrite || requirement.status === 'OBSOLETE';
  const option = (list: readonly string[], prefix: string) => list.map((value) => ({ value, label: t(`${prefix}.${value}`) }));

  const save = handleSubmit(async (form) => {
    try {
      await update.mutateAsync({ requirement, patch: toPatch(form, formState.dirtyFields) });
      notifications.show({ color: 'green', message: t('requirement.saved') });
    } catch (error) {
      if (error instanceof ApiError) {
        Object.entries(error.fieldErrors).forEach(([field, message]) => setError(field as keyof FormValues, { message }));
      }
      notifications.show({ color: 'red', message: errorMessage(error, t('errors.generic')) });
    }
  });

  return (
    <Grid>
      <Grid.Col span={{ base: 12, lg: 8 }}>
        <form onSubmit={save} noValidate>
          <Stack>
            <TextInput label={t('requirement.title')} required maxLength={200} disabled={readOnly} error={formState.errors.title?.message} {...register('title')} data-testid="field-title" />
            <Group grow>
              <Controller
                control={control}
                name="type"
                render={({ field }) => (
                  <Select label={t('requirement.type')} data={option(REQUIREMENT_TYPES, 'requirementType')} disabled={readOnly} allowDeselect={false} {...field} data-testid="field-type" />
                )}
              />
              <Controller
                control={control}
                name="priority"
                render={({ field }) => (
                  <Select label={t('requirement.priority')} data={option(PRIORITIES, 'priority')} disabled={readOnly} allowDeselect={false} {...field} data-testid="field-priority" />
                )}
              />
              <Controller
                control={control}
                name="riskLevel"
                render={({ field }) => (
                  <Select label={t('requirement.riskLevel')} data={option(RISK_LEVELS, 'risk')} disabled={readOnly} allowDeselect={false} {...field} data-testid="field-risk" />
                )}
              />
            </Group>

            {(type === 'USER_STORY' || asA || iWant || soThat) && (
              <Fieldset legend={t('requirement.userStory')}>
                <SimpleGrid cols={{ base: 1, md: 3 }}>
                  <TextInput label={t('requirement.asA')} disabled={readOnly} {...register('asA')} data-testid="field-as-a" />
                  <TextInput label={t('requirement.iWant')} disabled={readOnly} {...register('iWant')} data-testid="field-i-want" />
                  <TextInput label={t('requirement.soThat')} disabled={readOnly} {...register('soThat')} data-testid="field-so-that" />
                </SimpleGrid>
                <Text size="sm" mt="xs" fs="italic" c="dimmed" data-testid="story-sentence">
                  {userStorySentence(asA, iWant, soThat)}
                </Text>
              </Fieldset>
            )}

            <Group grow align="flex-start">
              <Controller
                control={control}
                name="storyPoints"
                render={({ field }) => (
                  <Select
                    label={t('requirement.storyPoints')}
                    data={FIBONACCI.map(String)}
                    clearable
                    disabled={readOnly}
                    {...field}
                    data-testid="field-points"
                  />
                )}
              />
              <Controller
                control={control}
                name="businessValue"
                render={({ field }) => (
                  <NumberInput label={t('requirement.businessValue')} min={1} max={100} disabled={readOnly} {...field} data-testid="field-business-value" />
                )}
              />
              <TextInput
                label={t('requirement.externalRef')}
                placeholder={t('requirement.externalRefHint')}
                disabled={readOnly}
                {...register('externalRef')}
                data-testid="field-external-ref"
              />
            </Group>
            {needsSplitting(storyPoints === null ? null : Number(storyPoints)) && (
              <Alert color="orange" icon={<IconAlertTriangle size={16} />} title={t('requirement.split')} data-testid="split-warning">
                {t('requirement.splitHint')}
              </Alert>
            )}
            <Controller
              control={control}
              name="tags"
              render={({ field }) => (
                <TagsInput label={t('requirement.tags')} description={t('requirement.tagsHint')} disabled={readOnly} {...field} data-testid="field-tags" />
              )}
            />

            {type === 'NON_FUNCTIONAL' && (
              <Fieldset legend={t('requirement.nfr')} data-testid="nfr-fields">
                <Stack>
                  <Group grow align="flex-end">
                    <Controller
                      control={control}
                      name="category"
                      render={({ field }) => (
                        <Select label={t('requirement.category')} data={option(NFR_CATEGORIES, 'nfrCategory')} clearable disabled={readOnly} {...field} data-testid="field-category" />
                      )}
                    />
                    <Controller
                      control={control}
                      name="transverse"
                      render={({ field }) => (
                        <Switch
                          label={t('requirement.transverse')}
                          description={t('requirement.transverseHint')}
                          checked={field.value}
                          onChange={(e) => field.onChange(e.currentTarget.checked)}
                          disabled={readOnly}
                          data-testid="field-transverse"
                        />
                      )}
                    />
                  </Group>
                  <TextInput label={t('requirement.scale')} disabled={readOnly} {...register('scale')} data-testid="field-scale" />
                  <TextInput label={t('requirement.measurementMethod')} disabled={readOnly} {...register('measurementMethod')} />
                  <Group grow>
                    <TextInput label={t('requirement.minimumThreshold')} disabled={readOnly} {...register('minimumThreshold')} />
                    <TextInput label={t('requirement.target')} disabled={readOnly} {...register('target')} />
                    <TextInput label={t('requirement.unit')} disabled={readOnly} {...register('unit')} />
                  </Group>
                </Stack>
              </Fieldset>
            )}

            <Controller
              control={control}
              name="description"
              render={({ field }) => (
                <MarkdownField label={t('requirement.description')} value={field.value} onChange={field.onChange} readOnly={readOnly} />
              )}
            />

            {!readOnly && (
              <Group justify="flex-end">
                <Button variant="default" onClick={() => reset(toForm(requirement))} disabled={!formState.isDirty}>
                  {t('requirement.cancel')}
                </Button>
                <Button type="submit" disabled={!formState.isDirty} loading={update.isPending} data-testid="requirement-save">
                  {t('requirement.save')}
                </Button>
              </Group>
            )}
          </Stack>
        </form>
      </Grid.Col>

      <Grid.Col span={{ base: 12, lg: 4 }}>
        <Stack>
          {requirement.type === 'USER_STORY' && (
            <InvestPanel project={project} requirement={requirement} canContribute={canContribute && requirement.status !== 'OBSOLETE'} />
          )}
          <ChecklistPanel project={project} requirement={requirement} canContribute={canContribute} />
          <RelationsPanel project={project} requirement={requirement} />
        </Stack>
      </Grid.Col>
    </Grid>
  );
}

const INVEST_ITEMS = ['independent', 'negotiable', 'valuable', 'estimable', 'small', 'testable'] as const;

/** F-REQ-07 six cases INVEST, enregistrées immédiatement (PO ou testeur). */
function InvestPanel({ project, requirement, canContribute }: { project: string; requirement: RequirementDetail; canContribute: boolean }) {
  const { t } = useTranslation();
  const setInvest = useSetInvest(project);
  const toggle = (item: (typeof INVEST_ITEMS)[number], checked: boolean) =>
    setInvest.mutate(
      { key: requirement.key, invest: { ...requirement.invest, [item]: checked } },
      { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) },
    );
  const count = INVEST_ITEMS.filter((item) => requirement.invest[item]).length;
  return (
    <Paper withBorder p="sm">
      <Title order={5}>
        {t('requirement.invest')} ({count}/6)
      </Title>
      <SimpleGrid cols={2} mt="xs">
        {INVEST_ITEMS.map((item) => (
          <Checkbox
            key={item}
            label={t(`requirement.investItems.${item}`)}
            checked={requirement.invest[item]}
            disabled={!canContribute}
            onChange={(e) => toggle(item, e.currentTarget.checked)}
            data-testid={`invest-${item}`}
          />
        ))}
      </SimpleGrid>
    </Paper>
  );
}

/** F-REQ-19 DoR / DoD évaluées ; les items manuels se cochent ici. */
function ChecklistPanel({ project, requirement, canContribute }: { project: string; requirement: RequirementDetail; canContribute: boolean }) {
  const { t } = useTranslation();
  const { data } = useRequirementChecklists(project, requirement.key);
  const check = useCheckItem(project, requirement.key);
  if (!data) return null;
  const toggle = canContribute
    ? (item: Schemas['ChecklistResultResponse'], checked: boolean) =>
        check.mutate({ itemId: item.id, checked }, { onError: (e) => notifications.show({ color: 'red', message: errorMessage(e, t('errors.generic')) }) })
    : undefined;
  return (
    <Paper withBorder p="sm" data-testid="checklist-panel">
      <Title order={5}>{t('requirement.dor')}</Title>
      <ChecklistResults items={data.dor} onToggle={toggle} />
      <Divider my="sm" />
      <Title order={5}>{t('requirement.dod')}</Title>
      <ChecklistResults items={data.dod} onToggle={toggle} />
    </Paper>
  );
}

/** Parent, enfants et ENF transverses applicables (F-REQ-17). */
function RelationsPanel({ project, requirement }: { project: string; requirement: RequirementDetail }) {
  const { t } = useTranslation();
  const link = (ref: Schemas['RequirementRef']) => (
    <Group key={ref.key} gap="xs" wrap="nowrap">
      <Anchor component={Link} to={`/p/${project}/requirements/${ref.key}`} ff="monospace" fw={600} size="sm">
        {ref.key}
      </Anchor>
      <Text size="sm" truncate>
        {ref.title}
      </Text>
      <StatusBadge status={ref.status} />
    </Group>
  );
  return (
    <Paper withBorder p="sm">
      <Stack gap="xs">
        <Text fw={600} size="sm">
          {t('requirement.parent')}
        </Text>
        {requirement.parent ? link(requirement.parent) : <Text size="sm" c="dimmed">{t('requirement.noParent')}</Text>}
        {requirement.children.length > 0 && (
          <>
            <Text fw={600} size="sm">
              {t('requirement.children')}
            </Text>
            {requirement.children.map(link)}
          </>
        )}
        {requirement.applicableTransverseNfrs.length > 0 && (
          <>
            <Text fw={600} size="sm">
              {t('requirement.transverseNfrs')}
            </Text>
            <div data-testid="transverse-nfrs">{requirement.applicableTransverseNfrs.map(link)}</div>
          </>
        )}
      </Stack>
    </Paper>
  );
}
