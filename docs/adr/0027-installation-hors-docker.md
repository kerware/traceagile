# ADR-0027 — Installation hors Docker

**Statut** : acceptée

**Contexte.** TraceAgile et le serveur d'exécution doivent pouvoir s'installer hors Docker, sur des
machines indépendantes. On veut :
- deux jars distribuables ;
- une note d'installation ;
- un script qui crée la base de données ;
- l'injection des données de démarrage et, en option, de la démonstration SwagLabs.

Jusqu'ici, l'interface de TraceAgile était servie par nginx (image `frontend`), et seul le profil
`demo` créait des comptes.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Jar de TraceAgile | Le profil Maven `distribution` de `traceagile-api` construit `frontend/` (frontend-maven-plugin, Node.js téléchargé) et copie `dist/` dans `static/` du jar. Sans ce profil, le jar ne contient que l'API, comme dans l'image Docker. Un seul processus sert donc l'API, l'interface et le guide. |
| Service de l'interface | `EmbeddedFrontendFilter`, actif seulement si `static/index.html` est présent. Il redirige les routes de l'application monopage vers `index.html` (`no-cache`), et `/guide/` vers le guide. Il reprend les en-têtes de `frontend/nginx.conf` (CSP, `nosniff`, `Referrer-Policy`). La sécurité laisse passer tout ce qui n'est pas sous `/api/` : les ressources statiques ne contiennent aucune donnée. |
| Données de démarrage | Les migrations Flyway créent déjà le schéma et les référentiels. `InitialAdministrator` (hors profil `demo`) crée l'administrateur si la base n'a aucun utilisateur : `TRACEAGILE_ADMIN_LOGIN` / `_PASSWORD` / `_EMAIL`. Sans mot de passe fourni, un mot de passe aléatoire est écrit une fois dans le journal, jamais un mot de passe connu. Le script de base n'injecte donc rien pour une base vide. |
| Création de la base | `install/base-de-donnees/installer-base.(sh\|ps1)` + `creer-base.sql` (`\gexec`, idempotent) : rôle, mot de passe, base UTF-8 dont le rôle est propriétaire. `--remplacer` recrée la base (`DROP … WITH (FORCE)`, PostgreSQL 13+). |
| Démonstration SwagLabs | Un export SQL (`demo/swaglabs.sql`, `pg_dump --no-owner --no-privileges`) plutôt qu'un chargeur Java : le projet SWAG est produit par le scénario du guide (ADR-0025), avec de vrais runs joués par le serveur d'exécution. Le recoder en Java le ferait diverger du guide. `generer-demo-swaglabs.sh` le régénère depuis le jar distribuable, sur une base et un rôle temporaires, sans captures (`GUIDE_SANS_CAPTURES`). Le scénario crée lui-même les comptes et appaire le serveur quand il vise une instance sans profil `demo`. La démo ne s'injecte que dans une base vide. |
| Secrets de la démo | `apres-demo.sql` efface le jeton, le secret des webhooks et l'état d'appairage du serveur. Il remplace son adresse (`--url-serveur`) : le serveur est à appairer sur place. Les comptes de la démo ont le mot de passe `SwagLabs-2026` (l'API exige 8 caractères ; « demo » reste celui du profil `demo`). |
| Configuration | Variables d'environnement existantes, regroupées dans un fichier `*.env` lu par `demarrer.(sh\|ps1)` et par `EnvironmentFile` de systemd. Pas de fichier de configuration propre : toute propriété Spring reste réglable. |
| Docker par logiciel | Chaque logiciel s'installe au choix hors Docker ou en conteneur, indépendamment de l'autre. Le dossier distribué contient un `Dockerfile` qui construit l'image **à partir du jar** (aucun registre, aucune construction Maven sur la cible) et un `docker-compose.yml` qui lit la même configuration, copiée en `.env`. Pour TraceAgile, une base PostgreSQL en conteneur est proposée (profil `base-locale`), ainsi qu'un service ponctuel `installation-demo` qui injecte la démo et ses pièces jointes. Les deux compose partagent le réseau `traceagile-reseau` (même machine : noms de service) et déclarent `host.docker.internal` (conteneur ↔ jar sur la même machine). La note décrit les 8 combinaisons (mode × mode × une ou deux machines) et les deux adresses qui en dépendent : celle du serveur déclarée dans TraceAgile et `TRACEAGILE_CALLBACK_URL`. La pile `docker-compose.yml` de la racine reste celle du développement. |
| Distribution | `scripts/construire-distribution.(sh\|ps1)` assemble `dist/traceagile-<version>/` et deux archives : l'une avec TraceAgile et les scripts de base, l'autre avec le serveur d'exécution. |

**Conséquences.**
- Les journaux et artefacts des runs de la démo restent sur le serveur qui les a produits. Les
  résultats, eux, sont dans la base.
- Les dates de la démo sont celles de sa génération : la régénérer à chaque évolution du schéma ou
  du guide.
- La note d'installation est [docs/installation.md](../installation.md), copiée dans la distribution.
