// Publie un document Markdown de docs/ en deux formats autonomes (option --document, « guide » par défaut) :
// - guide : docs/guide/README.md → docs/guide/guide-traceagile.html (captures intégrées en data URI, copiée
//   dans frontend/public/guide/index.html, menu « Documentation » de l'application, /guide/) et .docx ;
// - installation : docs/installation.md → docs/installation-traceagile.html et .docx (ADR-0027).
// HTML : page unique, navigation des chapitres, thème clair et sombre. Word : sommaire cliquable, pied de page numéroté.
// Option --fragment <fichier> : même page sans <!doctype>/<head>, pour la publier comme Artifact.
import {
  AlignmentType, BorderStyle, Bookmark, Document, ExternalHyperlink, Footer, HeadingLevel, ImageRun, InternalHyperlink,
  LevelFormat, PageNumber, Packer, Paragraph, ShadingType, Table, TableCell, TableRow, TextRun, WidthType,
} from 'docx';
import { marked } from 'marked';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, posix, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const RACINE = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const DOCUMENTS = {
  guide: {
    dossier: join(RACINE, 'docs', 'guide'), source: 'README.md', sortie: 'guide-traceagile',
    titre: 'Guide d’utilisation de TraceAgile', onglet: 'Guide TraceAgile', marque: 'TraceAgile · guide',
    description: 'Guide d’utilisation de TraceAgile illustré sur le projet Swag Labs (saucedemo)',
    surtitre: 'Exemple Swag Labs · release 1.0 · 2 sprints', chapitreParPage: true, copieApplication: true,
  },
  installation: {
    dossier: join(RACINE, 'docs'), source: 'installation.md', sortie: 'installation-traceagile',
    titre: 'Installation de TraceAgile et du serveur d’exécution', onglet: 'Installation TraceAgile', marque: 'TraceAgile · installation',
    description: 'Installation de TraceAgile et du serveur d’exécution, hors Docker ou en conteneur, sur une ou plusieurs machines',
    surtitre: 'Hors Docker ou conteneur · 8 combinaisons · démo SwagLabs', chapitreParPage: false, copieApplication: false,
  },
};
const option = process.argv.indexOf('--document');
const DOC = DOCUMENTS[option > 0 ? process.argv[option + 1] : 'guide'];
if (!DOC) throw new Error(`Document inconnu ; choix : ${Object.keys(DOCUMENTS).join(', ')}`);
const GUIDE = DOC.dossier;
const SOURCE = readFileSync(join(GUIDE, DOC.source), 'utf-8').replace(/\r\n/g, '\n');
const TITRE = DOC.titre;

// ------------------------------------------------------------------------------------- utilitaires

/** Ancre façon GitHub : minuscules, ponctuation retirée, espaces → tirets (accents conservés). */
function ancre(texte) {
  return texte.toLowerCase().replace(/[^\p{L}\p{N}\s_-]/gu, '').replace(/ /g, '-');
}

function decoder(texte) {
  return texte.replace(/&quot;/g, '"').replace(/&#39;/g, '\'').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
}

function texteBrut(tokens) {
  return (tokens ?? []).map((t) => (t.tokens ? texteBrut(t.tokens) : decoder(t.text ?? t.raw ?? ''))).join('');
}

/** Lien relatif du guide → chemin depuis la racine du dépôt (les liens relatifs n'ont pas de sens hors du dépôt). */
function cheminDepot(href) {
  return relative(RACINE, resolve(GUIDE, href)).split('\\').join(posix.sep);
}

const images = new Map();
function image(src) {
  if (!images.has(src)) {
    const contenu = readFileSync(join(GUIDE, src));
    // PNG : largeur et hauteur dans l'en-tête IHDR
    images.set(src, { contenu, largeur: contenu.readUInt32BE(16), hauteur: contenu.readUInt32BE(20) });
  }
  return images.get(src);
}

const jetons = marked.lexer(SOURCE);
const titres = jetons.filter((t) => t.type === 'heading' && t.depth >= 2).map((t) => ({ niveau: t.depth, texte: texteBrut(t.tokens), id: ancre(texteBrut(t.tokens)) }));

// ------------------------------------------------------------------------------------------- HTML

function pageHtml() {
  const rendu = new marked.Renderer();
  rendu.heading = function ({ tokens, depth }) {
    const texte = texteBrut(tokens);
    if (depth === 1) return '';
    return `<h${depth} id="${ancre(texte)}">${this.parser.parseInline(tokens)}</h${depth}>\n`;
  };
  rendu.image = function ({ href, text }) {
    const { contenu, largeur, hauteur } = image(href);
    return `<img src="data:image/png;base64,${contenu.toString('base64')}" alt="${text}" width="${largeur}" height="${hauteur}" loading="lazy">`;
  };
  rendu.paragraph = function ({ tokens }) {
    if (tokens.length === 1 && tokens[0].type === 'image') {
      return `<figure>${this.parser.parseInline(tokens)}<figcaption>${tokens[0].text}</figcaption></figure>\n`;
    }
    return `<p>${this.parser.parseInline(tokens)}</p>\n`;
  };
  rendu.link = function ({ href, tokens }) {
    const libelle = this.parser.parseInline(tokens);
    if (href.startsWith('#') || /^https?:/.test(href)) return `<a href="${href}">${libelle}</a>`;
    return `<span class="chemin" title="Fichier du dépôt : ${cheminDepot(href)}">${libelle}</span>`;
  };
  rendu.table = function (table) {
    return `<div class="tableau">${marked.Renderer.prototype.table.call(this, table)}</div>\n`;
  };
  rendu.blockquote = function ({ tokens }) {
    return `<aside class="principe">${this.parser.parse(tokens)}</aside>\n`;
  };
  rendu.hr = () => '';
  // le sommaire du Markdown est remplacé par la navigation latérale
  const sansSommaire = SOURCE.replace(/## Sommaire[\s\S]*?\n---\n/, '');
  const corps = marked.parse(sansSommaire.replace(/^# .*\n/, ''), { renderer: rendu });
  const intro = corps.slice(0, corps.indexOf('<h2'));
  const chapitres = corps.slice(corps.indexOf('<h2'));
  const navigation = titres.filter((t) => t.niveau === 2 && t.texte !== 'Sommaire')
    .map((t) => `<li><a href="#${t.id}">${t.texte.replace(/^(\d+)\. /, '<span class="num">$1</span>')}</a></li>`).join('\n');
  return `<title>${DOC.onglet}</title>
<meta name="description" content="${DOC.description}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600;12..96,700&family=IBM+Plex+Sans:ital,wght@0,400;0,600;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Mise en page : navigation des chapitres fixe à gauche, colonne de lecture d'environ 70 caractères, captures pleine colonne. */
:root {
  --fond: #f5f7f8; --papier: #ffffff; --encre: #15222c; --doux: #51606b; --filet: #d8e0e5;
  --accent: #19647e; --accent-doux: #e2eef2; --valide: #2f855a; --echec: #c53030;
  --titre: "Bricolage Grotesque", "Segoe UI", system-ui, sans-serif;
  --texte: "IBM Plex Sans", "Segoe UI", system-ui, sans-serif;
  --code: "IBM Plex Mono", Consolas, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --fond: #0f171d; --papier: #16212a; --encre: #e3eaee; --doux: #9aabb6; --filet: #2a3a46;
  --accent: #6cc3de; --accent-doux: #1b3340; --valide: #68d391; --echec: #fc8181; color-scheme: dark } }
:root[data-theme="dark"] {
  --fond: #0f171d; --papier: #16212a; --encre: #e3eaee; --doux: #9aabb6; --filet: #2a3a46;
  --accent: #6cc3de; --accent-doux: #1b3340; --valide: #68d391; --echec: #fc8181; color-scheme: dark }
body { margin: 0; background: var(--fond); color: var(--encre); font: 16px/1.65 var(--texte); }
img { max-width: 100%; height: auto; }
.page { display: grid; grid-template-columns: 17rem minmax(0, 1fr); gap: 3rem; max-width: 76rem; margin: 0 auto; padding-inline: 1.5rem; }
nav { position: sticky; top: env(safe-area-inset-top, 0px); align-self: start; max-height: 100vh; overflow-y: auto; padding-block: 2.5rem; }
nav .marque { font: 700 1.05rem/1.2 var(--titre); color: var(--accent); letter-spacing: .01em; margin: 0 0 1.25rem; }
nav ol { list-style: none; margin: 0; padding: 0; display: grid; gap: .15rem; }
nav a { display: flex; gap: .6rem; padding: .3rem .5rem; border-radius: 6px; color: var(--doux); text-decoration: none; font-size: .92rem; line-height: 1.35; }
nav a:hover, nav a:focus-visible { background: var(--accent-doux); color: var(--encre); outline: none; }
nav .num { font: 500 .8rem/1.6 var(--code); color: var(--accent); min-width: 1.4rem; font-variant-numeric: tabular-nums; }
main { min-width: 0; padding-block: 2.5rem 5rem; max-width: 48rem; }
header.entete { border-bottom: 1px solid var(--filet); padding-bottom: 1.75rem; margin-bottom: 1rem; }
.surtitre { font: 500 .78rem/1 var(--code); text-transform: uppercase; letter-spacing: .12em; color: var(--accent); margin: 0 0 .9rem; }
h1 { font: 700 clamp(2rem, 4.5vw, 2.9rem)/1.08 var(--titre); margin: 0 0 1rem; text-wrap: balance; letter-spacing: -.01em; }
h2 { font: 700 1.7rem/1.2 var(--titre); margin: 3.5rem 0 1rem; padding-top: 1.5rem; border-top: 1px solid var(--filet); text-wrap: balance; scroll-margin-top: 1rem; }
h3 { font: 600 1.2rem/1.3 var(--titre); margin: 2.2rem 0 .6rem; scroll-margin-top: 1rem; }
p, li { max-width: 68ch; }
a { color: var(--accent); text-underline-offset: 2px; }
code { font: .88em var(--code); background: var(--accent-doux); padding: .08em .35em; border-radius: 4px; }
pre { overflow-x: auto; margin: 1.2rem 0 1.6rem; padding: .9rem 1.1rem; background: var(--papier); border: 1px solid var(--filet); border-radius: 8px; line-height: 1.5; }
pre code { background: none; padding: 0; font-size: .84rem; }
.chemin { font-family: var(--code); font-size: .9em; border-bottom: 1px dotted var(--doux); }
figure { margin: 1.4rem 0 1.8rem; }
figure img, .tableau img { display: block; height: auto; border: 1px solid var(--filet); border-radius: 6px; background: #fff; box-shadow: 0 1px 2px rgb(0 0 0 / .06), 0 6px 18px -10px rgb(0 0 0 / .25); }
figcaption { font-size: .85rem; color: var(--doux); margin-top: .55rem; }
.tableau { overflow-x: auto; margin: 1.2rem 0 1.6rem; }
table { border-collapse: collapse; width: 100%; font-size: .93rem; }
th, td { text-align: left; vertical-align: top; padding: .55rem .7rem; border-bottom: 1px solid var(--filet); }
th { font-weight: 600; background: var(--accent-doux); }
.principe { margin: 1.8rem 0; padding: 1rem 1.25rem; background: var(--papier); border: 1px solid var(--filet); border-left: 4px solid var(--valide); border-radius: 0 8px 8px 0; }
.principe p { margin: 0; }
@media (max-width: 60rem) {
  .page { grid-template-columns: minmax(0, 1fr); gap: 0; padding-inline: 1rem; }
  nav { position: static; max-height: none; padding-block: 1.5rem 0; border-bottom: 1px solid var(--filet); }
}
@media (prefers-reduced-motion: no-preference) { html { scroll-behavior: smooth; } }
</style>
<div class="page">
<nav aria-label="Chapitres">
<p class="marque">${DOC.marque}</p>
<ol>
${navigation}
</ol>
</nav>
<main>
<header class="entete">
<p class="surtitre">${DOC.surtitre}</p>
<h1>${TITRE}</h1>
${intro}
</header>
${chapitres}
</main>
</div>
`;
}

// ------------------------------------------------------------------------------------------- Word

const ACCENT = '19647E';
const largeurUtile = 620; // pixels pour 16,4 cm de texte (A4, marges de 2,3 cm)

const signets = new Map(titres.map((t, i) => [t.id, `chap_${i + 1}`]));

function runs(tokens, style = {}) {
  const resultat = [];
  for (const t of tokens ?? []) {
    switch (t.type) {
      case 'strong': resultat.push(...runs(t.tokens, { ...style, bold: true })); break;
      case 'em': resultat.push(...runs(t.tokens, { ...style, italics: true })); break;
      case 'codespan': resultat.push(new TextRun({ ...style, text: decoder(t.text), font: 'Consolas', size: 19, shading: { type: ShadingType.CLEAR, fill: 'E2EEF2' } })); break;
      case 'br': resultat.push(new TextRun({ break: 1 })); break;
      case 'image': resultat.push(imageRun(t.href, 190)); break;
      case 'link': {
        const enfants = runs(t.tokens, { ...style, color: ACCENT, underline: {} });
        if (t.href.startsWith('#') && signets.has(t.href.slice(1))) resultat.push(new InternalHyperlink({ anchor: signets.get(t.href.slice(1)), children: enfants }));
        else if (/^https?:/.test(t.href)) resultat.push(new ExternalHyperlink({ link: t.href, children: enfants }));
        else resultat.push(...runs(t.tokens, style), new TextRun({ ...style, text: ` (${cheminDepot(t.href)})`, font: 'Consolas', size: 18 }));
        break;
      }
      default:
        if (t.tokens) resultat.push(...runs(t.tokens, style));
        else resultat.push(new TextRun({ ...style, text: decoder(t.text ?? t.raw ?? '') }));
    }
  }
  return resultat;
}

function imageRun(src, largeurMax = largeurUtile, hauteurMax = 760) {
  const { contenu, largeur, hauteur } = image(src);
  const echelle = Math.min(1, largeurMax / largeur, hauteurMax / hauteur);
  return new ImageRun({ type: 'png', data: contenu, transformation: { width: Math.round(largeur * echelle), height: Math.round(hauteur * echelle) } });
}

let listes = 0;

function blocs(tokens, options = {}) {
  const resultat = [];
  for (const t of tokens) {
    switch (t.type) {
      case 'heading': {
        const texte = texteBrut(t.tokens);
        if (t.depth === 1 || texte === 'Sommaire') break;
        const niveau = t.depth === 2 ? HeadingLevel.HEADING_1 : HeadingLevel.HEADING_2;
        resultat.push(new Paragraph({ heading: niveau, pageBreakBefore: t.depth === 2 && DOC.chapitreParPage,
          children: [new Bookmark({ id: signets.get(ancre(texte)), children: runs(t.tokens) })] }));
        break;
      }
      case 'paragraph':
        if (t.tokens.length === 1 && t.tokens[0].type === 'image') {
          resultat.push(new Paragraph({ alignment: AlignmentType.CENTER, keepNext: true, spacing: { before: 160, after: 60 }, children: [imageRun(t.tokens[0].href)] }));
          resultat.push(new Paragraph({ style: 'Legende', children: [new TextRun(decoder(t.tokens[0].text))] }));
        } else {
          resultat.push(new Paragraph({ ...options.paragraphe, children: runs(t.tokens) }));
        }
        break;
      case 'list': {
        const instance = ++listes; // chaque liste numérotée repart de 1
        for (const item of t.items) {
          const [premier, ...reste] = item.tokens;
          resultat.push(new Paragraph({
            numbering: { reference: t.ordered ? 'numeros' : 'puces', level: options.niveau ?? 0, ...(t.ordered ? { instance } : {}) },
            children: runs(premier.tokens ?? [premier]),
          }));
          resultat.push(...blocs(reste, { niveau: (options.niveau ?? 0) + 1 }));
        }
        break;
      }
      case 'table': {
        const colonnes = t.header.length;
        const cellule = (c, entete) => new TableCell({
          shading: entete ? { type: ShadingType.CLEAR, fill: 'E2EEF2' } : undefined,
          margins: { top: 60, bottom: 60, left: 100, right: 100 },
          children: [new Paragraph({ children: runs(c.tokens, entete ? { bold: true } : {}) })],
        });
        const avecImages = t.rows.some((r) => r.some((c) => c.tokens.some((x) => x.type === 'image')));
        resultat.push(new Table({
          width: { size: 100, type: WidthType.PERCENTAGE },
          rows: [
            new TableRow({ tableHeader: true, children: t.header.map((c) => cellule(c, true)) }),
            ...t.rows.map((r) => new TableRow({ cantSplit: true, children: r.map((c) => cellule(c, false)) })),
          ],
          ...(avecImages ? { columnWidths: Array(colonnes).fill(Math.floor(9300 / colonnes)) } : {}),
        }));
        resultat.push(new Paragraph({ spacing: { after: 120 }, children: [] }));
        break;
      }
      case 'blockquote':
        resultat.push(...blocs(t.tokens, { paragraphe: { style: 'Principe' } }));
        break;
      case 'code':
        // une ligne par saut de ligne Word, espaces conservés (schémas en texte)
        resultat.push(new Paragraph({ style: 'Code', children: t.text.split('\n').map((ligne, i) => new TextRun({ text: ligne, break: i ? 1 : 0 })) }));
        break;
      default:
        break; // hr, espaces
    }
  }
  return resultat;
}

function sommaire() {
  return [
    new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun('Sommaire')] }),
    ...titres.filter((t) => t.texte !== 'Sommaire').map((t) => new Paragraph({
      indent: { left: t.niveau === 2 ? 0 : 400 },
      spacing: { after: t.niveau === 2 ? 60 : 20 },
      children: [new InternalHyperlink({ anchor: signets.get(t.id), children: [new TextRun({ text: t.texte, color: ACCENT, bold: t.niveau === 2, size: t.niveau === 2 ? 22 : 20 })] })],
    })),
  ];
}

async function documentWord() {
  const debut = jetons.findIndex((t) => t.type === 'heading' && t.depth === 2);
  const intro = jetons.slice(1, debut);
  const corps = jetons.slice(debut);
  const doc = new Document({
    creator: 'TraceAgile',
    title: TITRE,
    description: DOC.description,
    styles: {
      default: { document: { run: { font: 'Calibri', size: 22, color: '15222C' }, paragraph: { spacing: { after: 120, line: 288 } } } },
      paragraphStyles: [
        { id: 'Title', name: 'Title', basedOn: 'Normal', run: { font: 'Calibri Light', size: 56, bold: true, color: '15222C' }, paragraph: { spacing: { after: 240 } } },
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true, run: { font: 'Calibri Light', size: 36, bold: true, color: ACCENT }, paragraph: { spacing: { before: 120, after: 200 }, keepNext: true } },
        { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true, run: { font: 'Calibri', size: 26, bold: true, color: '15222C' }, paragraph: { spacing: { before: 320, after: 120 }, keepNext: true } },
        { id: 'Code', name: 'Code', basedOn: 'Normal', run: { font: 'Consolas', size: 17 }, paragraph: {
          shading: { type: ShadingType.CLEAR, fill: 'F2F6F8' }, spacing: { before: 120, after: 200, line: 240 }, indent: { left: 120, right: 120 } } },
        { id: 'Legende', name: 'Légende', basedOn: 'Normal', run: { size: 18, italics: true, color: '51606B' }, paragraph: { alignment: AlignmentType.CENTER, spacing: { after: 240 } } },
        { id: 'Principe', name: 'Principe', basedOn: 'Normal', paragraph: {
          shading: { type: ShadingType.CLEAR, fill: 'EEF6F0' }, border: { left: { style: BorderStyle.SINGLE, size: 24, color: '2F855A', space: 8 } },
          indent: { left: 200, right: 200 }, spacing: { before: 200, after: 200 } } },
      ],
    },
    numbering: { config: [
      { reference: 'puces', levels: [0, 1].map((level) => ({ level, format: LevelFormat.BULLET, text: level ? '–' : '•', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 360 + level * 360, hanging: 260 } } } })) },
      { reference: 'numeros', levels: [0, 1].map((level) => ({ level, format: LevelFormat.DECIMAL, text: `%${level + 1}.`, alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 360 + level * 360, hanging: 300 } } } })) },
    ] },
    sections: [{
      properties: { page: { margin: { top: 1300, bottom: 1300, left: 1300, right: 1300 } } },
      footers: { default: new Footer({ children: [new Paragraph({ alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: `${TITRE} — page `, size: 16, color: '51606B' }), new TextRun({ children: [PageNumber.CURRENT], size: 16, color: '51606B' })] })] }) },
      children: [
        new Paragraph({ children: [new TextRun({ text: DOC.surtitre.toUpperCase(), size: 18, color: ACCENT, bold: true })] }),
        new Paragraph({ heading: HeadingLevel.TITLE, children: [new TextRun(TITRE)] }),
        ...blocs(intro.filter((t) => !(t.type === 'heading'))),
        ...sommaire(),
        ...blocs(corps),
      ],
    }],
  });
  return Packer.toBuffer(doc);
}

// ----------------------------------------------------------------------------------------- sorties

const page = pageHtml();
const complete = `<!doctype html>\n<html lang="fr">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n${page.slice(0, page.indexOf('<div class="page">'))}</head>\n<body>\n${page.slice(page.indexOf('<div class="page">'))}</body>\n</html>\n`;
writeFileSync(join(GUIDE, `${DOC.sortie}.html`), complete);
if (DOC.copieApplication) {
  // servi par l'application à /guide/ (menu « Documentation »)
  mkdirSync(join(RACINE, 'frontend', 'public', 'guide'), { recursive: true });
  writeFileSync(join(RACINE, 'frontend', 'public', 'guide', 'index.html'), complete);
}
const fragment = process.argv.indexOf('--fragment');
if (fragment > 0) {
  mkdirSync(dirname(resolve(process.argv[fragment + 1])), { recursive: true });
  writeFileSync(resolve(process.argv[fragment + 1]), page);
}
writeFileSync(join(GUIDE, `${DOC.sortie}.docx`), await documentWord());
console.log(`Publié : ${relative(RACINE, join(GUIDE, DOC.sortie)).split('\\').join('/')}.html et .docx (${images.size} captures)`);
