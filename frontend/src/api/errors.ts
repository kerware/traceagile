/** Erreur RFC 9457 renvoyée par l'API (§11.3) : code métier, message et erreurs par champ. */
export interface Problem {
  status?: number;
  code?: string;
  detail?: string;
  errors?: Record<string, string>;
}

export class ApiError extends Error {
  readonly status: number;
  readonly code: string | undefined;
  readonly fieldErrors: Record<string, string>;

  constructor(status: number, problem: Problem | undefined) {
    super(problem?.detail ?? `HTTP ${status}`);
    this.name = 'ApiError';
    this.status = status;
    this.code = problem?.code;
    this.fieldErrors = problem?.errors ?? {};
  }
}

/** Renvoie les données d'une réponse openapi-fetch ou lève une {@link ApiError}. */
export function unwrap<T>(result: { data?: T; error?: unknown; response: Response }): T {
  if (result.error !== undefined || !result.response.ok) {
    throw new ApiError(result.response.status, result.error as Problem | undefined);
  }
  return result.data as T;
}

export function errorMessage(error: unknown, fallback: string): string {
  return error instanceof Error && error.message ? error.message : fallback;
}
