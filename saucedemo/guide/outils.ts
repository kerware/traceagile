import { expect, type APIRequestContext, type Locator, type Page } from '@playwright/test';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

/** Projet créé par le scénario (autre clé possible pour rejouer sur la même base : GUIDE_PROJET=SWAG2). */
export const P = process.env.GUIDE_PROJET ?? 'SWAG';
export const MOT_DE_PASSE = 'demo';

const ICI = dirname(fileURLToPath(import.meta.url));
export const RACINE_SAUCEDEMO = join(ICI, '..');
export const IMAGES = join(ICI, '..', '..', 'docs', 'guide', 'images');
const ETAT = join(ICI, '..', 'results', 'guide-etat.json');

// ------------------------------------------------------------------------------------ état partagé

type Etat = Record<string, string | number>;

/** Valeurs passées d'un fichier du scénario au suivant (clés, identifiants). */
export function lireEtat(): Etat {
  return existsSync(ETAT) ? (JSON.parse(readFileSync(ETAT, 'utf-8')) as Etat) : {};
}

export function noterEtat(valeurs: Etat) {
  mkdirSync(dirname(ETAT), { recursive: true });
  writeFileSync(ETAT, JSON.stringify({ ...lireEtat(), ...valeurs }, null, 2));
}

// ------------------------------------------------------------------------------------------- API

/** Client de l'API REST de TraceAgile, connecté avec un compte de démonstration. */
export class Api {
  private constructor(private readonly request: APIRequestContext, private readonly jeton: string) {}

  static async de(request: APIRequestContext, login: string): Promise<Api> {
    const reponse = await request.post('/api/v1/auth/login', { data: { login, password: MOT_DE_PASSE } });
    expect(reponse.ok(), `connexion ${login}`).toBeTruthy();
    return new Api(request, (await reponse.json()).accessToken as string);
  }

  private chemin(chemin: string) {
    return chemin.startsWith('/api/') ? chemin : `/api/v1/projects/${P}${chemin}`;
  }

  private async lire(reponse: import('@playwright/test').APIResponse, quoi: string) {
    expect(reponse.ok(), `${quoi} → ${reponse.status()} ${await reponse.text()}`).toBeTruthy();
    const texte = await reponse.text();
    return texte ? JSON.parse(texte) : null;
  }

  get headers() {
    return { Authorization: `Bearer ${this.jeton}` };
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async get(chemin: string): Promise<any> {
    return this.lire(await this.request.get(this.chemin(chemin), { headers: this.headers }), `GET ${chemin}`);
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async post(chemin: string, data?: unknown): Promise<any> {
    return this.lire(await this.request.post(this.chemin(chemin), { headers: this.headers, data }), `POST ${chemin}`);
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async put(chemin: string, data: unknown): Promise<any> {
    return this.lire(await this.request.put(this.chemin(chemin), { headers: this.headers, data }), `PUT ${chemin}`);
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async patch(chemin: string, data: unknown): Promise<any> {
    return this.lire(await this.request.patch(this.chemin(chemin), {
      headers: { ...this.headers, 'Content-Type': 'application/merge-patch+json' }, data: JSON.stringify(data),
    }), `PATCH ${chemin}`);
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async multipart(chemin: string, multipart: Record<string, any>): Promise<any> {
    return this.lire(await this.request.post(this.chemin(chemin), { headers: this.headers, multipart }), `POST ${chemin}`);
  }
}

/** Éléments d'une campagne (un par test, ou par ligne de jeu de données). */
export async function elements(api: Api, campagne: string): Promise<Element[]> {
  return (await api.get(`/campaigns/${campagne}`)).items as Element[];
}

export type Element = { id: string; test: { key: string }; dataSetRow?: number | null; attempts: number; lastStatus: string; latestExecutionId?: string };

// ----------------------------------------------------------------------------------- navigateur

export async function connexion(page: Page, login: string) {
  await page.goto('/login');
  await page.getByTestId('login-input').fill(login);
  await page.getByTestId('password-input').fill(MOT_DE_PASSE);
  await page.getByTestId('login-submit').click();
  await expect(page.getByTestId('user-menu')).toBeVisible();
}

/**
 * Capture d'écran pour le guide (docs/guide/images/<nom>.png) : la fenêtre entière ou une partie
 * (locator). Les animations sont figées et le curseur de saisie masqué.
 */
export async function capturer(page: Page, nom: string, cible?: Locator, options: { pleinePage?: boolean; marge?: number } = {}) {
  await page.waitForLoadState('load');
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(400);
  const chemin = join(IMAGES, `${nom}.png`);
  if (!cible) {
    await page.screenshot({ path: chemin, fullPage: options.pleinePage ?? false, animations: 'disabled', caret: 'hide' });
    return;
  }
  await cible.scrollIntoViewIfNeeded({ timeout: 15_000 });
  if (!options.marge) {
    await cible.screenshot({ path: chemin, animations: 'disabled', caret: 'hide' });
    return;
  }
  const boite = (await cible.boundingBox())!;
  const m = options.marge;
  const vue = page.viewportSize()!;
  const x = Math.max(0, boite.x - m);
  const y = Math.max(0, boite.y - m);
  await page.screenshot({
    path: chemin, animations: 'disabled', caret: 'hide',
    clip: { x, y, width: Math.min(vue.width - x, boite.width + 2 * m), height: Math.min(vue.height - y, boite.height + 2 * m) },
  });
}

/** Ferme les notifications Mantine visibles (elles masqueraient une partie des captures). */
export async function fermerNotifications(page: Page) {
  for (const bouton of await page.locator('.mantine-Notification-root button').all()) {
    await bouton.click().catch(() => undefined);
  }
  await expect(page.locator('.mantine-Notification-root')).toHaveCount(0);
}

// ----------------------------------------------------------------------------------------- dates

function iso(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function decaler(date: Date, jours: number): Date {
  const copie = new Date(date);
  copie.setUTCDate(copie.getUTCDate() + jours);
  return copie;
}

/** Deux sprints de deux semaines : SPR-2 commence le lundi de la semaine courante, SPR-1 deux semaines avant. */
export function calendrier() {
  const aujourdhui = new Date(Date.UTC(new Date().getFullYear(), new Date().getMonth(), new Date().getDate()));
  const lundi = decaler(aujourdhui, -((aujourdhui.getUTCDay() + 6) % 7));
  return {
    sprint1: { debut: iso(decaler(lundi, -14)), fin: iso(decaler(lundi, -3)) },
    sprint2: { debut: iso(lundi), fin: iso(decaler(lundi, 11)) },
  };
}
