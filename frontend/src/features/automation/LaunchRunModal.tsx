import { Alert, Badge, Button, Checkbox, Group, Modal, NumberInput, Select, Stack, Text } from '@mantine/core';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useLaunchRun, useServerChoices } from '../../api/automation';
import type { CampaignDetail } from '../../api/campaigns';
import { errorMessage } from '../../api/errors';
import { TechniqueBadge } from '../tests/Badges';
import { SERVER_STATUS_COLORS } from './model';

/**
 * F-EXE-06 « Lancer sur… » : tests automatisés de la campagne (tous cochés par défaut, ceux en cours
 * exclus) et serveur compatible avec leurs techniques ; ouvre le run créé.
 */
export function LaunchRunModal({ project, detail, opened, onClose }: { project: string; detail: CampaignDetail; opened: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data: servers } = useServerChoices(project, opened);
  const launch = useLaunchRun(project, detail.campaign.key);
  const automated = useMemo(() => detail.items.filter((i) => i.test.kind === 'AUTOMATED'), [detail.items]);
  // un test en cours, ou en attente dans un run déjà lancé, ne repart pas (RUN_ITEM_BUSY)
  const busy = (i: (typeof automated)[number]) => i.lastStatus === 'RUNNING' || (i.lastStatus === 'NOT_RUN' && i.attempts > 0);
  const available = automated.filter((i) => !busy(i));
  const [selected, setSelected] = useState<string[]>([]);
  const [serverId, setServerId] = useState<string | null>(null);
  const [timeout, setTimeoutMinutes] = useState<number>(30);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (opened) {
      setSelected(available.map((i) => i.id));
      setError(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [opened]);

  const techniques = [...new Set(automated.filter((i) => selected.includes(i.id)).map((i) => i.test.technique).filter(Boolean))] as string[];
  const compatible = (servers ?? []).filter((s) => s.usable && techniques.every((tech) => s.techniques.includes(tech as never)));

  useEffect(() => {
    if (opened && !serverId && compatible.length > 0) setServerId(compatible[0]!.id);
  }, [opened, compatible, serverId]);

  const submit = async () => {
    if (!serverId) return;
    setError(null);
    try {
      const run = await launch.mutateAsync({ serverId, itemIds: selected, timeoutMinutes: timeout });
      onClose();
      navigate(`/p/${project}/runs/${run.run.key}`);
    } catch (e) {
      setError(errorMessage(e, t('errors.generic')));
    }
  };

  return (
    <Modal opened={opened} onClose={onClose} title={t('runs.launchTitle', { key: detail.campaign.key })} size="lg">
      <Stack>
        {error && (
          <Alert color="red" role="alert">
            {error}
          </Alert>
        )}
        {automated.length === 0 && <Text c="dimmed">{t('runs.noAutomated')}</Text>}
        {automated.length > 0 && (
          <>
            <Group justify="space-between">
              <Text size="sm" fw={500}>
                {t('runs.tests', { count: selected.length, total: automated.length })}
              </Text>
              <Checkbox label={t('runs.all')} checked={selected.length > 0 && selected.length === available.length}
                indeterminate={selected.length > 0 && selected.length < available.length}
                onChange={(e) => setSelected(e.currentTarget.checked ? available.map((i) => i.id) : [])} data-testid="launch-all" />
            </Group>
            <Stack gap={4} mah={260} style={{ overflow: 'auto' }}>
              {automated.map((item) => (
                <Checkbox key={item.id} checked={selected.includes(item.id)} disabled={busy(item)}
                  onChange={(e) => setSelected(e.currentTarget.checked ? [...selected, item.id] : selected.filter((id) => id !== item.id))}
                  data-testid={`launch-item-${item.test.key}`}
                  label={
                    <Group gap={6}>
                      <Text size="sm" ff="monospace">
                        {item.test.key}
                      </Text>
                      <TechniqueBadge technique={item.test.technique} />
                      <Text size="sm">{item.test.title}</Text>
                    </Group>
                  }
                />
              ))}
            </Stack>
            <Select
              label={t('runs.server')}
              placeholder={t('runs.serverPlaceholder')}
              data={(servers ?? []).map((s) => ({
                value: s.id,
                label: `${s.name} — ${t(`serverStatus.${s.status}`)}`,
                disabled: !compatible.some((c) => c.id === s.id),
              }))}
              value={serverId}
              onChange={setServerId}
              allowDeselect={false}
              data-testid="launch-server"
            />
            {(servers ?? []).length > 0 && compatible.length === 0 && (
              <Alert color="orange">{t('runs.noCompatible', { techniques: techniques.join(', ') })}</Alert>
            )}
            {(servers ?? []).length === 0 && <Alert color="gray">{t('runs.noServer')}</Alert>}
            <Group gap={4}>
              {(servers ?? []).filter((s) => s.id === serverId).flatMap((s) => [
                <Badge key="status" color={SERVER_STATUS_COLORS[s.status]} variant="light">
                  {t(`serverStatus.${s.status}`)}
                </Badge>,
                ...s.techniques.map((tech) => <TechniqueBadge key={tech} technique={tech} />),
              ])}
            </Group>
            <NumberInput label={t('runs.timeout')} description={t('runs.timeoutHint')} min={1} max={1440} value={timeout}
              onChange={(v) => setTimeoutMinutes(Number(v) || 30)} w={220} data-testid="launch-timeout" />
          </>
        )}
        <Group justify="flex-end">
          <Button variant="default" onClick={onClose}>
            {t('test.cancel')}
          </Button>
          <Button onClick={submit} loading={launch.isPending} disabled={!serverId || selected.length === 0} data-testid="launch-submit">
            {t('runs.launch', { count: selected.length })}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
