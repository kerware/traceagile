// Le routeur de données crée des Request avec l'AbortSignal de jsdom, que le Request natif de Node
// (undici) refuse. En test uniquement, on retire un signal que undici n'accepte pas.
// Chargé avant MSW (voir vite.config.ts) pour que ses intercepteurs enveloppent cette classe.
const NodeRequest = globalThis.Request;

function acceptedByUndici(signal: AbortSignal): boolean {
  try {
    new NodeRequest('http://localhost', { signal });
    return true;
  } catch {
    return false;
  }
}

globalThis.Request = class extends NodeRequest {
  constructor(input: RequestInfo | URL, init?: RequestInit) {
    if (init?.signal && !acceptedByUndici(init.signal)) {
      const { signal: _ignored, ...rest } = init;
      void _ignored;
      super(input, rest);
    } else {
      super(input, init);
    }
  }
} as typeof Request;
