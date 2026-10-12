# ADR-0030 — Dépôts Git déclarés dans l'administration

**Statut** : acceptée

**Contexte.** Une fiche de test automatisé portait une adresse de dépôt saisie à la main. Les
identifiants d'un dépôt privé étaient saisis à part, par hôte, sur chaque serveur d'exécution (page
Paramètres, ADR-0026). Besoin exprimé : déclarer dans l'administration des dépôts comme
`https://github.com/kerware`, publics ou privés, avec ou sans authentification (jeton, clé). Y
déclarer des projets comme `saucedemo-e2e`, puis les réutiliser dans les fiches de tests. Le dépôt
local `file://` des exemples doit rester possible.

Choix de l'utilisateur :
- secrets conservés dans TraceAgile et transmis avec les jobs ;
- authentification aucune, par jeton ou par clé SSH ;
- déclaration pour toute l'instance.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Modèle | `GitSource` (« dépôt » : nom unique, adresse de base, authentification, description) et `GitProject` (« projet » : nom unique dans son dépôt, branche par défaut). Adresses admises : `https://` / `http://`, `git@hôte:compte` (SSH), `file:///dossier` (dépôt local du serveur d'exécution, sans authentification). Tables `git_sources`, `git_projects` (migration V19). |
| Authentification | `NONE`, `TOKEN` (HTTPS seulement ; utilisateur par défaut `x-access-token`), `SSH_KEY`. Le secret est chiffré par `SecretCipher` (clé `TRACEAGILE_ENCRYPTION_KEY`), jamais renvoyé (`hasSecret`) ; laissé vide à la modification, il est conservé si le type ne change pas. Une clé SSH est normalisée (fins de ligne LF, saut de ligne final). |
| Adresse de clonage | Calculée à chaque fois : `base/projet`, ou `git@hôte:chemin/projet.git` quand le dépôt passe en clé SSH. Changer l'adresse ou l'authentification d'un dépôt ne touche pas les tests. |
| Fiche de test | `AutomatedTestDefinition.gitProject` (colonne `git_project_id`), prioritaire sur l'adresse libre, qui reste possible (« Autre adresse »). `getRepositoryUrl()` et `getBranch()` rendent l'adresse et la branche effectives (branche du test, sinon celle du projet). Une adresse libre différente libère le projet. API : `gitProjectId` dans le merge-patch, `gitProject` dans la réponse. |
| Administration | `Administration › Dépôts Git` (administrateur système). La liste, sans secret, est lisible par tout utilisateur connecté, pour le choix dans les fiches. Un projet utilisé par un test, ou un dépôt qui a des projets, ne se supprime pas (409). |
| Transmission | Contrat étendu : `repository.credentials {type, username, secret}` dans le job (identifiants du projet du premier test, comme l'adresse). Le serveur d'exécution les garde en mémoire jusqu'au clone (`GitWorkspace.remember` / `prepare`), ne les écrit ni en base ni au journal. Jeton : dans l'URL du clone, masquée. Clé SSH : fichier `cle-ssh` (droits 600 sous Unix) dans le dossier du job, `GIT_SSH_COMMAND` avec `IdentitiesOnly`, `StrictHostKeyChecking=accept-new` et un `known_hosts` propre au job ; supprimé après le clone. Sans identifiants transmis, ceux de la page Paramètres du serveur s'appliquent comme avant. |

**Conséquences.**
- Le secret circule entre TraceAgile et le serveur d'exécution à chaque run : HTTPS conseillé dès
  que le serveur est sur une autre machine (note d'installation §11).
- Démo SwagLabs : dépôts « Dépôt local » (`file:///depots`, projet `traceagile`, utilisé par les tests
  de SWAG) et « kerware » (`https://github.com/kerware`, projet `saucedemo-e2e`).
- Un run mêle encore des tests d'un seul dépôt : celui du premier test (limite existante).
