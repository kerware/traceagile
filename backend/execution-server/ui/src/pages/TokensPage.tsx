import { Alert, Badge, Button, Card, Code, CopyButton, Group, Loader, Modal, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCopy, IconKey, IconTrash } from '@tabler/icons-react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { dateTime, getJson, send, type IssuedToken, type TokenInfo } from '../api';

/**
 * ADR-0020 jetons de sécurité : émis ici, saisis une fois dans TraceAgile (Administration › Serveurs
 * d'exécution) ; le jeton et le secret de signature ne sont affichés qu'à l'émission.
 */
export function TokensPage() {
  const client = useQueryClient();
  const { data, isLoading } = useQuery({ queryKey: ['tokens'], queryFn: () => getJson<TokenInfo[]>('/api/v1/tokens') });
  const [label, setLabel] = useState('TraceAgile');
  const [issued, setIssued] = useState<IssuedToken | null>(null);
  const [revoking, setRevoking] = useState<TokenInfo | null>(null);
  const issue = useMutation({
    mutationFn: () => send<IssuedToken>('POST', '/api/v1/tokens', { label }),
    onSuccess: (token) => {
      setIssued(token);
      return client.invalidateQueries({ queryKey: ['tokens'] });
    },
  });
  const revoke = useMutation({
    mutationFn: (tokenId: string) => send('DELETE', `/api/v1/tokens/${tokenId}`),
    onSuccess: () => {
      notifications.show({ color: 'orange', message: 'Jeton révoqué : TraceAgile devra être appairé à nouveau.' });
      setRevoking(null);
      return client.invalidateQueries({ queryKey: ['tokens'] });
    },
  });

  return (
    <Stack>
      <Title order={2}>Jetons de sécurité</Title>
      <Card withBorder>
        <Stack>
          <Text size="sm">
            Un jeton autorise une instance de TraceAgile à soumettre des jobs ; son secret signe les webhooks de résultats (HMAC-SHA256). Dans TraceAgile,
            ouvrez Administration › Serveurs d'exécution, ajoutez ce serveur puis collez le jeton et le secret — ou laissez TraceAgile les demander avec
            les identifiants de l'administrateur.
          </Text>
          <Group align="flex-end">
            <TextInput label="Libellé" description="Instance de TraceAgile qui utilisera le jeton" value={label} onChange={(e) => setLabel(e.currentTarget.value)}
              w={320} data-testid="token-label" />
            <Button leftSection={<IconKey size={16} />} onClick={() => issue.mutate()} loading={issue.isPending} disabled={!label.trim()} data-testid="token-issue">
              Émettre un jeton
            </Button>
          </Group>
        </Stack>
      </Card>
      {isLoading && <Loader />}
      {data && (
        <Table data-testid="tokens-table">
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Libellé</Table.Th>
              <Table.Th>Jeton</Table.Th>
              <Table.Th>Émis le</Table.Th>
              <Table.Th>Dernière utilisation</Table.Th>
              <Table.Th>État</Table.Th>
              <Table.Th />
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {data.map((token) => (
              <Table.Tr key={token.tokenId}>
                <Table.Td>{token.label}</Table.Td>
                <Table.Td>
                  <Code>ets_…{token.hint}</Code>
                </Table.Td>
                <Table.Td>{dateTime(token.createdAt)}</Table.Td>
                <Table.Td>{dateTime(token.lastUsedAt)}</Table.Td>
                <Table.Td>
                  {token.revokedAt ? (
                    <Badge color="gray" variant="light">
                      Révoqué le {dateTime(token.revokedAt)}
                    </Badge>
                  ) : (
                    <Badge color="teal" variant="light">
                      Actif
                    </Badge>
                  )}
                </Table.Td>
                <Table.Td ta="right">
                  {!token.revokedAt && (
                    <Button size="compact-sm" color="red" variant="subtle" leftSection={<IconTrash size={14} />} onClick={() => setRevoking(token)}
                      data-testid={`token-revoke-${token.tokenId}`}>
                      Révoquer
                    </Button>
                  )}
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}

      <Modal opened={!!issued} onClose={() => setIssued(null)} title="Jeton émis" size="lg" closeOnClickOutside={false}>
        {issued && (
          <Stack>
            <Alert color="orange" variant="light">
              Copiez-les maintenant : ils ne seront plus jamais affichés. Seule une empreinte du jeton est conservée.
            </Alert>
            <Secret label="Jeton (Bearer)" value={issued.token} testId="issued-token" />
            <Secret label="Secret de signature des webhooks" value={issued.webhookSecret} testId="issued-secret" />
            <Button onClick={() => setIssued(null)}>J'ai copié le jeton et le secret</Button>
          </Stack>
        )}
      </Modal>
      <Modal opened={!!revoking} onClose={() => setRevoking(null)} title="Révoquer le jeton ?">
        <Stack>
          <Text size="sm">
            « {revoking?.label} » ne pourra plus soumettre de jobs. Les jobs en cours se terminent, mais TraceAgile ne pourra plus lire leurs résultats.
          </Text>
          <Group justify="flex-end">
            <Button variant="default" onClick={() => setRevoking(null)}>
              Annuler
            </Button>
            <Button color="red" loading={revoke.isPending} onClick={() => revoking && revoke.mutate(revoking.tokenId)} data-testid="token-revoke-confirm">
              Révoquer
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Stack>
  );
}

function Secret({ label, value, testId }: { label: string; value: string; testId: string }) {
  return (
    <Stack gap={4}>
      <Text size="sm" fw={600}>
        {label}
      </Text>
      <Group wrap="nowrap" gap="xs">
        <Code block style={{ flex: 1, wordBreak: 'break-all' }} data-testid={testId}>
          {value}
        </Code>
        <CopyButton value={value}>
          {({ copied, copy }) => (
            <Button size="xs" variant={copied ? 'light' : 'default'} color={copied ? 'teal' : undefined} leftSection={<IconCopy size={14} />} onClick={copy}>
              {copied ? 'Copié' : 'Copier'}
            </Button>
          )}
        </CopyButton>
      </Group>
    </Stack>
  );
}
