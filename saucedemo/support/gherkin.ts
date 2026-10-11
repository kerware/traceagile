import { test, type Page } from '@playwright/test';
import { readFileSync } from 'node:fs';

/**
 * Exécuteur Gherkin minimal (sans dépendance) : chaque scénario d'un fichier .feature devient un test
 * Playwright portant le nom exact du scénario — celui que TraceAgile donne au test BDD généré depuis
 * le critère d'acceptation, ce qui rapproche les résultats JUnit importés. Mots-clés français.
 */
type Definition = { motif: RegExp; action: (page: Page, ...valeurs: string[]) => Promise<void> };

const MOTS_CLES = /^(Étant donné que|Étant donné|Etant donné|Quand|Lorsque|Alors|Et|Mais)\s+/;

export class Etapes {
  private readonly definitions: Definition[] = [];

  /** Définit une étape ; les groupes du motif sont passés en paramètres. */
  definir(motif: RegExp, action: Definition['action']) {
    this.definitions.push({ motif, action });
  }

  async jouer(page: Page, texte: string) {
    for (const { motif, action } of this.definitions) {
      const correspondance = texte.match(motif);
      if (correspondance) {
        await action(page, ...correspondance.slice(1));
        return;
      }
    }
    throw new Error(`Étape non définie : « ${texte} »`);
  }
}

type Scenario = { nom: string; tags: string[]; etapes: string[] };

export function lireFeature(chemin: string): { fonctionnalite: string; scenarios: Scenario[] } {
  let fonctionnalite = '';
  const scenarios: Scenario[] = [];
  let tags: string[] = [];
  for (const brute of readFileSync(chemin, 'utf-8').split(/\r?\n/)) {
    const ligne = brute.trim();
    if (!ligne || ligne.startsWith('#')) continue;
    if (ligne.startsWith('@')) {
      tags = ligne.split(/\s+/);
    } else if (ligne.startsWith('Fonctionnalité:')) {
      fonctionnalite = ligne.slice('Fonctionnalité:'.length).trim();
    } else if (ligne.startsWith('Scénario:')) {
      scenarios.push({ nom: ligne.slice('Scénario:'.length).trim(), tags, etapes: [] });
      tags = [];
    } else if (MOTS_CLES.test(ligne) && scenarios.length > 0) {
      scenarios.at(-1)!.etapes.push(ligne);
    }
  }
  return { fonctionnalite, scenarios };
}

/** Déclare un test Playwright par scénario du fichier. */
export function jouerFeature(chemin: string, etapes: Etapes) {
  const { scenarios } = lireFeature(chemin);
  for (const scenario of scenarios) {
    test(scenario.nom, { tag: scenario.tags }, async ({ page }) => {
      for (const ligne of scenario.etapes) {
        await test.step(ligne, () => etapes.jouer(page, ligne.replace(MOTS_CLES, '')));
      }
    });
  }
}
