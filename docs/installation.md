# Installation de TraceAgile et du serveur d'exécution

Cette note décrit l'installation des deux logiciels livrés : **TraceAgile** (API, interface web et
guide d'utilisation) et son **serveur d'exécution** des tests automatisés. Chacun s'installe au
choix **hors Docker** (un jar Java lancé comme un service) ou **en conteneur Docker** (image construite
sur place à partir du même jar), sur la même machine ou sur des machines séparées. TraceAgile utilise
une base PostgreSQL, existante ou dans un conteneur, vide ou avec la démonstration SwagLabs. Les
choix techniques sont dans l'[ADR-0027](adr/0027-installation-hors-docker.md).

```
 Machine A : TraceAgile                       Machine B : serveur d'exécution
 +------------------------------+    jobs     +-------------------------------+
 | traceagile-api.jar  :8085    | ----------> | execution-server.jar  :8091   |
 | (API + interface + guide)    |             | (API + interface, base H2)    |
 | jar ou conteneur             | <---------- | jar ou conteneur              |
 +--------------+---------------+  résultats  +-------------------------------+
                |                 (webhooks)
                | JDBC
 +--------------v---------------+
 | PostgreSQL 16+  :5432        |   (serveur existant ou conteneur)
 +------------------------------+
```

Plusieurs serveurs d'exécution peuvent être rattachés à un même TraceAgile, chacun installé dans le
mode qui convient à sa machine.

## 1. Choisir le type d'installation

### 1.1 Les deux modes

| | Hors Docker | En conteneur Docker |
| --- | --- | --- |
| Livrable | le jar et ses scripts `demarrer.sh` / `demarrer.ps1` | le même dossier : `Dockerfile` et `docker-compose.yml` construisent l'image à partir du jar |
| Prérequis de la machine | Java 21 ; pour le serveur d'exécution, aussi Git, Node.js, Python selon les frameworks | Docker Engine 24+ et Docker Compose 2.20+ (Docker Desktop sous Windows et macOS) |
| Configuration | `traceagile.env` / `serveur-execution.env` | les mêmes variables, dans un fichier `.env` |
| Démarrage automatique | service systemd ou service Windows (§5.3) | `restart: unless-stopped` (démarre avec Docker) |
| Données | dossiers de la machine | volumes Docker |
| Conseillé quand | la machine n'a pas Docker, ou le serveur d'exécution doit piloter des navigateurs ou outils déjà installés sur la machine (Windows en particulier) | la machine a Docker : prérequis inclus dans l'image, mises à jour par reconstruction |

Le mode de l'un ne contraint pas le mode de l'autre : ils ne communiquent que par HTTP.

### 1.2 Les combinaisons

Deux réglages dépendent de la combinaison choisie :

- l'**adresse du serveur d'exécution**, déclarée dans TraceAgile (§9) ; elle doit être joignable
  depuis TraceAgile ;
- **`TRACEAGILE_CALLBACK_URL`**, réglée dans la configuration de TraceAgile ; c'est l'adresse à
  laquelle le serveur d'exécution renvoie les résultats, et elle doit être joignable depuis le
  serveur d'exécution.

`machine-a` et `machine-b` désignent le nom DNS ou l'adresse IP des machines de TraceAgile et du
serveur d'exécution ; les ports sont ceux par défaut.

| Combinaison | TraceAgile | Serveur d'exécution | Machines | Adresse du serveur dans TraceAgile | `TRACEAGILE_CALLBACK_URL` |
| --- | --- | --- | --- | --- | --- |
| A1 | hors Docker | hors Docker | une seule | `http://localhost:8091` | `http://localhost:8085/api/v1/execution-callbacks` |
| A2 | hors Docker | hors Docker | deux | `http://machine-b:8091` | `http://machine-a:8085/api/v1/execution-callbacks` |
| B1 | conteneur | conteneur | une seule | `http://serveur-execution:8091` | `http://traceagile:8085/api/v1/execution-callbacks` |
| B2 | conteneur | conteneur | deux | `http://machine-b:8091` | `http://machine-a:8085/api/v1/execution-callbacks` |
| C1 | conteneur | hors Docker | une seule | `http://host.docker.internal:8091` | `http://localhost:8085/api/v1/execution-callbacks` |
| C2 | conteneur | hors Docker | deux | `http://machine-b:8091` | `http://machine-a:8085/api/v1/execution-callbacks` |
| D1 | hors Docker | conteneur | une seule | `http://localhost:8091` | `http://host.docker.internal:8085/api/v1/execution-callbacks` |
| D2 | hors Docker | conteneur | deux | `http://machine-b:8091` | `http://machine-a:8085/api/v1/execution-callbacks` |

Explications :

- **Machines différentes** (A2, B2, C2, D2) : le mode ne change rien, on utilise toujours les noms
  des machines et les ports publiés. Ne jamais mettre `localhost` : dans un conteneur, `localhost`
  désigne le conteneur lui-même.
- **Deux conteneurs sur la même machine** (B1) : les deux fichiers `docker-compose.yml` rejoignent le
  même réseau Docker `traceagile-reseau`. Les conteneurs s'y appellent par leur nom de service,
  `traceagile` et `serveur-execution`.
- **Un conteneur et un jar sur la même machine** (C1, D1) : le conteneur joint la machine hôte par
  `host.docker.internal` (déclaré dans les deux `docker-compose.yml`, y compris sous Linux), et le
  jar joint le conteneur par le port publié sur `localhost`.

### 1.3 La base de données

| Option | Pour | Comment |
| --- | --- | --- |
| PostgreSQL existant (installé sur une machine, ou service géré) | TraceAgile dans les deux modes | `base-de-donnees/installer-base.(sh\|ps1)` crée le rôle et la base (§4.1) |
| PostgreSQL dans un conteneur, géré avec TraceAgile | TraceAgile en conteneur | profil `base-locale` du `docker-compose.yml` de TraceAgile (§6.2) ; rien à créer à la main |

La **démonstration SwagLabs** s'injecte dans tous les cas, dans une base vide, avant le premier
démarrage de TraceAgile :

- avec `installer-base --demo` (§4.3) ;
- ou, si TraceAgile est en conteneur, avec le service `installation-demo` (§6.3).

Sans démonstration, TraceAgile crée lui-même au premier démarrage le schéma, les données de
démarrage et l'administrateur.

Le serveur d'exécution n'a pas de base à installer : il garde ses données dans une base H2 créée
au premier démarrage.

### 1.4 Ordre d'installation

| Étape | Hors Docker | En conteneur |
| --- | --- | --- |
| 1. Produire la distribution | §3 (une fois, sur un poste de développement) | §3 |
| 2. Base de données | §4 (PostgreSQL existant) | §4 (PostgreSQL existant) ou rien (profil `base-locale`) |
| 3. Démo SwagLabs (option) | §4.3 | §4.3 ou §6.3 |
| 4. TraceAgile | §5 | §6 |
| 5. Serveur d'exécution | §7 | §8 |
| 6. Relier les deux, installer les outils de test | §9 | §9 |
| 7. Réseau, HTTPS | §10, §11 | §10, §11 |

La pile `docker-compose.yml` à la racine du dépôt est autre chose : c'est l'environnement de
**développement**, avec un profil de démonstration différent (projet SHOP), un simulateur et des
secrets connus. Elle se construit depuis les sources et ne sert pas à une installation.

## 2. Prérequis

| Rôle | Hors Docker | En conteneur |
| --- | --- | --- |
| TraceAgile | Java 21 (un JRE suffit) | Docker Engine 24+ / Docker Desktop, Compose 2.20+ |
| Base de données | PostgreSQL **16 ou plus** et `psql` ; un superutilisateur (ex. `postgres`) pour créer le rôle et la base | idem, ou rien avec le profil `base-locale` (image `postgres:16-alpine`) |
| Serveur d'exécution | Java 21 et Git. Node.js 22 et Python 3.10+ selon les frameworks (Playwright, Cypress, Robot Framework). L'interface du serveur détecte ces prérequis et explique comment les installer | Docker : l'image contient JDK 21, Git, Node.js 22, Python 3 et les bibliothèques des navigateurs (Linux x64) |
| Construction de la distribution | Java 21, Maven 3.9 (Node.js est téléchargé par Maven) | idem ; les images sont construites ensuite sur chaque machine cible, sans Maven |

Le jeu de démonstration est un export PostgreSQL 16 : la base doit être en version 16 ou plus.

Systèmes :

- **Hors Docker** : Windows 10/11 ou Server 2019+, Linux (x64 ou arm64), macOS.
- **En conteneur** : toute machine qui exécute des conteneurs Linux. L'image du serveur
  d'exécution est prévue pour x64.

Mémoire : 1 Go pour TraceAgile, 512 Mo pour le serveur d'exécution, plus ce que demandent les
navigateurs des tests.

## 3. Produire la distribution

Depuis la racine du dépôt :

```bash
scripts/construire-distribution.sh
```

ou, sous Windows :

```powershell
.\scripts\construire-distribution.ps1
```

Le script lance `mvn -pl traceagile-api,execution-server -am package -Pdistribution -DskipTests`,
puis assemble `dist/traceagile-<version>/` :

```
dist/
  traceagile-<version>/
    INSTALLATION.md .html .docx       cette note
    traceagile/
      traceagile-api.jar              API, interface web et guide d'utilisation (≈ 105 Mo)
      traceagile.env.exemple          configuration (traceagile.env hors Docker, .env en conteneur)
      demarrer.sh  demarrer.ps1       lancement hors Docker
      traceagile.service              service systemd
      Dockerfile  docker-compose.yml  installation en conteneur
    serveur-execution/
      execution-server.jar            serveur d'exécution et son interface
      serveur-execution.env.exemple
      demarrer.sh  demarrer.ps1  serveur-execution.service
      Dockerfile  docker-compose.yml
    base-de-donnees/
      installer-base.sh  installer-base.ps1   création du rôle et de la base, démo en option
      installer-demo-docker.sh        démo pour TraceAgile en conteneur (service installation-demo)
      creer-base.sql  apres-demo.sql
      demo/swaglabs.sql               jeu de démonstration SwagLabs (projet SWAG)
      demo/pieces-jointes/            captures jointes de la démo
  traceagile-<version>.zip            traceagile/ + base-de-donnees/ + note
  serveur-execution-<version>.zip     serveur-execution/ + note
```

Sans le script, les jars s'obtiennent ainsi :

```bash
cd backend
mvn -pl traceagile-api -am package -Pdistribution -DskipTests   # → traceagile-api/target/traceagile-api.jar
mvn -pl execution-server -am package -DskipTests                # → execution-server/target/execution-server.jar
```

Le profil `distribution` construit l'interface React (`frontend/`) et l'embarque dans le jar, avec le
guide d'utilisation. Sans lui, le jar ne contient que l'API. C'est le cas de l'image de la pile de
développement, où nginx sert l'interface.

Copier les archives sur les machines cibles et les décompresser, par exemple dans `/opt/traceagile`
ou `C:\TraceAgile` :

- `traceagile-<version>.zip` sur la machine de TraceAgile ;
- `serveur-execution-<version>.zip` sur chaque machine de serveur d'exécution.

Pour TraceAgile en conteneur, garder `traceagile/` et `base-de-donnees/` côte à côte : le service
`installation-demo` lit `../base-de-donnees`. Les images Docker se construisent sur place à partir
du jar. Aucun registre n'est nécessaire.

## 4. Base de données PostgreSQL existante

Cette partie concerne une base sur un serveur PostgreSQL existant, quel que soit le mode de
TraceAgile. Avec le profil `base-locale` (§6.2), il n'y a rien à faire ici.

### 4.1 Script de création

Le script `base-de-donnees/installer-base.(sh|ps1)` se lance depuis toute machine qui a `psql` et
accède au serveur PostgreSQL. Il :

1. crée le rôle applicatif (ou met à jour son mot de passe) et la base, propriété de ce rôle, en UTF-8 ;
2. avec l'option démo, injecte le jeu SwagLabs ;
3. prépare le serveur d'exécution de la démo (adresse, appairage à refaire) ;
4. copie les pièces jointes de la démo.

Le mot de passe du superutilisateur est demandé par `psql`, ou lu dans `PGPASSWORD`, `~/.pgpass`
ou `%APPDATA%\postgresql\pgpass.conf`.

| Option (`.sh`) | Option (`.ps1`) | Défaut | Rôle |
| --- | --- | --- | --- |
| `--mot-de-passe` | `-MotDePasse` | *obligatoire* | mot de passe du rôle applicatif |
| `--hote`, `--port` | `-Hote`, `-Port` | `localhost`, `5432` | serveur PostgreSQL |
| `--superutilisateur` | `-Superutilisateur` | `postgres` | compte qui crée rôle et base |
| `--base`, `--utilisateur` | `-Base`, `-Utilisateur` | `traceagile`, `traceagile` | noms de la base et du rôle |
| `--demo` | `-Demo` | non | injecte la démo SwagLabs (base vide uniquement) |
| `--remplacer` | `-Remplacer` | non | **supprime** puis recrée la base (toutes les données sont perdues) |
| `--url-serveur` | `-UrlServeur` | inchangée | adresse du serveur d'exécution de la démo (colonne « Adresse du serveur » du §1.2) |
| `--pieces-jointes` | `-PiecesJointes` | aucune copie | dossier `TRACEAGILE_ATTACHMENTS_DIR` où copier les pièces jointes de la démo (TraceAgile hors Docker) |

La variable d'environnement `PSQL` remplace la commande `psql`, par exemple :

- `PSQL="/usr/lib/postgresql/16/bin/psql"` ;
- sous Windows, `$env:PSQL = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'`.

### 4.2 Base vide (production)

```bash
cd base-de-donnees
./installer-base.sh --hote db.example.org --mot-de-passe 'motDePasseDuRole'
```

```powershell
cd base-de-donnees
.\installer-base.ps1 -Hote db.example.org -MotDePasse 'motDePasseDuRole'
```

La base reste vide. **Au premier démarrage, TraceAgile crée lui-même** :

- le schéma (migrations Flyway) ;
- les données de démarrage (référentiels : statuts, types, priorités…) ;
- le compte administrateur défini par `TRACEAGILE_ADMIN_LOGIN` / `TRACEAGILE_ADMIN_PASSWORD` (§5.1).
  Ce compte n'est créé que si la base ne contient aucun utilisateur.

### 4.3 Base avec la démonstration SwagLabs

```bash
./installer-base.sh --hote db.example.org --mot-de-passe 'motDePasseDuRole' --demo \
  --url-serveur http://machine-b:8091 --pieces-jointes /opt/traceagile/pieces-jointes
```

```powershell
.\installer-base.ps1 -Hote db.example.org -MotDePasse 'motDePasseDuRole' -Demo `
  -UrlServeur http://machine-b:8091 -PiecesJointes C:\TraceAgile\pieces-jointes
```

Si TraceAgile tourne en conteneur, omettre `--pieces-jointes` et injecter plutôt la démo par le
service `installation-demo` (§6.3). Ce service copie aussi les pièces jointes dans le volume du
conteneur.

La démo contient le projet **SWAG** (application Swag Labs, www.saucedemo.com), décrit dans le
[guide d'utilisation](guide/README.md) :

- backlog, critères Gherkin, ENF, atelier Example Mapping ;
- tests manuels, automatisés, BDD et chartes exploratoires ;
- deux sprints joués, avec campagnes, runs automatisés réels et une session exploratoire ;
- anomalies et bilans.

Comptes (mot de passe **`SwagLabs-2026`**, à changer après la première connexion) :

| Compte | Rôle dans SWAG |
| --- | --- |
| `admin` | administrateur système |
| `po` | Product Owner |
| `qa1`, `qa2` | testeurs |
| `dev` | développeur |
| `viewer` | lecteur |

Le script refuse d'injecter la démo dans une base qui contient déjà des tables. Pour repartir de
zéro, ajouter `--remplacer`, après une sauvegarde si besoin.

Le serveur d'exécution de la démo garde son nom (« Serveur d'exécution ») :

- son adresse devient celle de `--url-serveur` ;
- il est **à appairer** (§9) ;
- les jetons de la machine qui a produit la démo ne sont jamais distribués.

## 5. TraceAgile hors Docker

### 5.1 Configuration

Dans le dossier `traceagile/` :

1. copier `traceagile.env.exemple` en `traceagile.env` ;
2. l'adapter ;
3. le protéger, car il contient des secrets : `chmod 600 traceagile.env`, ou droits NTFS réservés
   au compte du service.

| Variable | Défaut | À renseigner |
| --- | --- | --- |
| `SERVER_PORT` | `8085` | port HTTP (interface et API) |
| `TRACEAGILE_DB_URL` | `jdbc:postgresql://localhost:5433/traceagile` | `jdbc:postgresql://<hôte>:5432/<base>` |
| `TRACEAGILE_DB_USER`, `TRACEAGILE_DB_PASSWORD` | `traceagile` | rôle et mot de passe du §4 |
| `TRACEAGILE_JWT_SECRET` | secret de développement | **obligatoire** : 32 caractères ou plus, aléatoire (signature des jetons de connexion) |
| `TRACEAGILE_ENCRYPTION_KEY` | clé de développement | **obligatoire** : aléatoire ; chiffre les jetons des serveurs d'exécution. La changer oblige à réappairer les serveurs. |
| `TRACEAGILE_ADMIN_LOGIN`, `TRACEAGILE_ADMIN_PASSWORD`, `TRACEAGILE_ADMIN_EMAIL` | `admin`, aléatoire, `admin@traceagile.local` | administrateur créé sur une base vide. Sans mot de passe, un mot de passe aléatoire est écrit **une fois** dans le journal (`WARN`). |
| `TRACEAGILE_COOKIE_SECURE` | `false` | `true` dès que l'accès se fait en HTTPS |
| `TRACEAGILE_CALLBACK_URL` | `http://localhost:8085/api/v1/execution-callbacks` | adresse de TraceAgile **vue depuis le serveur d'exécution** : voir le §1.2 |
| `TRACEAGILE_ATTACHMENTS_DIR` | `<TEMP>/traceagile-attachments` | **obligatoire** : dossier persistant des pièces jointes (le dossier temporaire par défaut peut être vidé par le système) |
| `JAVA_OPTS` | — | options de la JVM (ex. `-Xmx1g`) |

Pour générer un secret :

- `openssl rand -base64 48` ;
- ou en PowerShell : `[Convert]::ToBase64String((1..48 | % { Get-Random -Max 256 }) -as [byte[]])`.

Toute propriété Spring Boot peut aussi se régler par variable d'environnement, ou par un fichier
`config/application.yml` à côté du jar.

**Ne pas activer le profil `demo`** : il charge un autre jeu de démonstration (projet SHOP) et
appaire le simulateur de développement.

### 5.2 Démarrage

```bash
cd /opt/traceagile/traceagile && ./demarrer.sh
```

```powershell
cd C:\TraceAgile\traceagile; .\demarrer.ps1
```

Au premier démarrage sur une base vide, le journal indique les migrations Flyway, puis la création
de l'administrateur. Vérifications :

- `http://machine-a:8085/actuator/health` répond `{"status":"UP"}` ;
- `http://machine-a:8085/` affiche l'écran de connexion ;
- le menu **Documentation** (`/guide/`) ouvre le guide d'utilisation ;
- `http://machine-a:8085/swagger-ui.html` décrit l'API.

### 5.3 Service

**Linux (systemd).**

1. Créer un compte sans connexion : `sudo useradd -r -s /usr/sbin/nologin traceagile`.
2. Lui donner le dossier : `sudo chown -R traceagile: /opt/traceagile`.
3. Installer et démarrer le service :

```bash
sudo cp /opt/traceagile/traceagile/traceagile.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now traceagile
journalctl -u traceagile -f
```

Si l'installation n'est pas dans `/opt/traceagile`, adapter dans le fichier de service
`WorkingDirectory`, `EnvironmentFile` et le chemin du jar. Ces variables sont lues par systemd : ne
pas mettre de guillemets autour des valeurs.

**Windows.** Le plus simple est [WinSW](https://github.com/winsw/winsw) ou
[NSSM](https://nssm.cc/), réglé ainsi :

- commande : `powershell -ExecutionPolicy Bypass -File C:\TraceAgile\traceagile\demarrer.ps1` ;
- démarrage automatique ;
- compte de service ayant les droits sur le dossier.

Une tâche planifiée « au démarrage du système » fait aussi l'affaire.

## 6. TraceAgile en conteneur Docker

### 6.1 Configuration

Dans le dossier `traceagile/`, copier `traceagile.env.exemple` en **`.env`** et le régler comme au
§5.1, avec ces différences :

| Variable | En conteneur |
| --- | --- |
| `SERVER_PORT` | port **publié sur la machine** (le conteneur écoute toujours sur 8085) |
| `TRACEAGILE_DB_URL` | base existante : `jdbc:postgresql://<hôte>:5432/<base>` ; si PostgreSQL tourne sur la même machine hors Docker, `<hôte>` = `host.docker.internal`. Base en conteneur : `jdbc:postgresql://postgres:5432/traceagile` |
| `TRACEAGILE_ATTACHMENTS_DIR` | ignorée : les pièces jointes vont dans le volume `pieces-jointes` |
| `TRACEAGILE_CALLBACK_URL` | selon la combinaison (§1.2) |
| `COMPOSE_PROFILES` | `base-locale` pour une base PostgreSQL en conteneur (§6.2), sinon absente |
| `TRACEAGILE_DEMO_URL_SERVEUR` | adresse du serveur d'exécution de la démo, utilisée par le service `installation-demo` (§6.3) |

Docker Compose lit aussi ce fichier pour ses propres réglages. Une valeur contenant `$` doit
l'écrire `$$`.

### 6.2 Démarrage

```bash
cd /opt/traceagile/traceagile
docker compose up -d --build
docker compose logs -f traceagile
```

Ce que fait cette commande :

- elle construit l'image `traceagile:local` à partir du jar ;
- elle démarre le conteneur `traceagile` avec le volume `pieces-jointes` ;
- avec `COMPOSE_PROFILES=base-locale`, elle démarre aussi le conteneur `postgres` (volume `base`).
  Son rôle et sa base sont créés au premier démarrage avec `TRACEAGILE_DB_USER` /
  `TRACEAGILE_DB_PASSWORD`. Cette base n'est pas exposée hors de Docker.

Les vérifications sont les mêmes qu'au §5.2. Le conteneur redémarre avec Docker
(`restart: unless-stopped`) : il n'y a pas de service à créer.

### 6.3 Démonstration SwagLabs en conteneur

Le service `installation-demo` injecte la démo dans la base de `TRACEAGILE_DB_URL` (en conteneur
ou existante) et copie les pièces jointes dans le volume. Il se lance **une fois, sur une base vide,
avant le premier démarrage de TraceAgile** :

```bash
cd /opt/traceagile/traceagile
docker compose run --rm installation-demo   # démarre aussi postgres avec le profil base-locale
docker compose up -d --build
```

Si TraceAgile a déjà démarré une fois, la base contient son schéma et le service refuse d'injecter
la démo. Pour repartir de zéro :

1. `docker compose down -v` (**supprime** la base en conteneur et les pièces jointes) ;
2. pour une base existante, la recréer avec `installer-base --remplacer`.

## 7. Serveur d'exécution hors Docker

Dans `serveur-execution/`, copier `serveur-execution.env.exemple` en `serveur-execution.env` :

| Variable | Défaut | Rôle |
| --- | --- | --- |
| `SERVER_PORT` | `8091` | port de l'API et de l'interface |
| `EXECUTION_SERVER_ADMIN_USER`, `EXECUTION_SERVER_ADMIN_PASSWORD` | `admin`, `executeur` | compte de l'interface et de l'appairage : **changer le mot de passe** |
| `EXECUTION_SERVER_DATA_DIR` | `./data` | base H2, dépôts clonés, rapports, artefacts, journaux |
| `EXECUTION_SERVER_TOOLS_DIR` | `./tools` | outils installés depuis l'interface |
| `EXECUTION_SERVER_AGENTS` | `4` | tests joués en parallèle |
| `EXECUTION_SERVER_RETENTION_DAYS` | `14` | conservation des jobs et de leurs artefacts |
| `EXECUTION_SERVER_NAME` | `executeur` | nom renvoyé à TraceAgile |

Lancer ensuite `./demarrer.sh` (ou `.\demarrer.ps1`). La base H2 est créée au premier démarrage.

Pour en faire un service :

- sous Linux : `serveur-execution.service`, à installer comme au §5.3, avec le compte `executeur` ;
- sous Windows : WinSW ou NSSM avec `demarrer.ps1`.

Les prérequis manquants (Java, Git, Node.js, Python) s'installent avec les droits d'administrateur
de la machine. La page **Outils** du serveur les détecte et explique comment faire (§9.2).

## 8. Serveur d'exécution en conteneur Docker

Dans `serveur-execution/`, copier `serveur-execution.env.exemple` en **`.env`** et le régler comme
au §7, avec ces différences :

- `SERVER_PORT` est le port **publié sur la machine** ; le conteneur écoute toujours sur 8091 ;
- `EXECUTION_SERVER_DATA_DIR` et `EXECUTION_SERVER_TOOLS_DIR` sont ignorées : les données vont dans
  les volumes `donnees` et `outils`.

Puis :

```bash
cd /opt/serveur-execution/serveur-execution
docker compose up -d --build
docker compose logs -f serveur-execution
```

L'image `traceagile-serveur-execution:local` est construite à partir du jar. Elle contient déjà
JDK 21, Git, Node.js 22, Python 3 et les bibliothèques système des navigateurs : la page **Outils**
n'a plus qu'à installer les frameworks de test (§9.2), dans le volume `outils`, qui est conservé lors
des mises à jour. Le conteneur redémarre avec Docker.

Les tests s'exécutent dans le conteneur, sous Linux et sans écran (navigateurs en mode headless,
Xvfb fourni). Pour des tests qui ont besoin de Windows, d'un navigateur installé sur la machine ou
d'un écran, préférer le serveur hors Docker (§7).

Les dépôts de tests sont clonés depuis leur URL Git, par HTTPS ou SSH. Un dépôt local de la machine
n'est visible qu'après l'avoir monté dans le conteneur. Exemple, à ajouter sous `volumes` du service
dans `docker-compose.yml` :

```yaml
      - /srv/depots:/depots:ro     # puis file:///depots/<projet> dans la fiche des tests
      # Docker Desktop sous Windows : - C:/Depots/projet:/depots/projet:ro
```

## 9. Relier TraceAgile et le serveur d'exécution

### 9.1 Appairage

1. Dans TraceAgile, en administrateur, ouvrir **Administration → Serveurs d'exécution**.
2. Déclarer le serveur avec l'adresse de la colonne « Adresse du serveur dans TraceAgile » du §1.2.
   Pour la démo, le serveur existe déjà avec l'adresse donnée lors de l'injection : la corriger si
   besoin.
3. **Appairer** en saisissant le compte administrateur du serveur d'exécution. TraceAgile demande
   un jeton et un secret de signature des webhooks, les chiffre, puis ne garde pas le mot de passe.
4. Au bout de quelques secondes, l'état passe à **En ligne** (sonde de santé périodique).

Ensuite, un run automatisé lancé dans TraceAgile envoie un job au serveur. Le serveur clone le dépôt
Git du test, exécute les tests et renvoie l'avancement et les résultats à `TRACEAGILE_CALLBACK_URL`.
Les journaux et artefacts (captures, traces) restent sur le serveur d'exécution, et TraceAgile les
relit à la demande.

### 9.2 Outils de test

Ouvrir l'interface du serveur (`http://machine-b:8091`), se connecter avec son compte
administrateur, puis aller sur la page **Outils** :

- les prérequis (Java, Git, Node.js, Python) sont détectés ; en conteneur, ils sont déjà présents ;
- l'**assistant d'installation** propose un plan ordonné pour les frameworks choisis (Playwright,
  Cypress, Selenium, Robot Framework, JUnit, Maven, JDK, Gatling…). Ce plan s'installe sans droits
  particuliers dans le dossier ou le volume des outils.

Pour rejouer la démo SwagLabs, il faut Node.js et l'outil **Playwright** avec ses navigateurs.

Pour un dépôt Git privé, saisir les identifiants de son hôte dans la page **Paramètres** du serveur
d'exécution.

## 10. Réseau et pare-feu

| Flux | De → vers | Port |
| --- | --- | --- |
| Navigateurs des utilisateurs | postes → TraceAgile | 8085 (ou 443 derrière un proxy) |
| Connexion à la base | TraceAgile → PostgreSQL | 5432 (interne à Docker avec `base-locale`) |
| Jobs, santé, artefacts | TraceAgile → serveur d'exécution | 8091 |
| Webhooks de résultats | serveur d'exécution → TraceAgile | 8085 (`TRACEAGILE_CALLBACK_URL`) |
| Interface du serveur d'exécution | postes des administrateurs → serveur d'exécution | 8091 |
| Clonage des dépôts de tests | serveur d'exécution → serveur Git | 443 / 22 |

Sur des machines séparées, ouvrir ces ports en entrée. Sous Windows, par exemple :
`New-NetFirewallRule -DisplayName TraceAgile -Direction Inbound -Protocol TCP -LocalPort 8085 -Action Allow`,
et de même pour 8091 sur la machine du serveur.

Sous Linux, Docker publie les ports des conteneurs en contournant les règles `ufw` : restreindre
l'accès au besoin, par exemple en publiant sur une seule interface
(`"127.0.0.1:${SERVER_PORT:-8085}:8085"` derrière un proxy local).

## 11. HTTPS et proxy inverse

En production, placer TraceAgile derrière un proxy TLS (nginx, Apache, IIS ARR, Traefik) et régler
`TRACEAGILE_COOKIE_SECURE=true`. Le suivi des runs en direct utilise des flux SSE : désactiver la
mise en mémoire tampon pour `/api/`. Exemple nginx :

```nginx
location / {
    proxy_pass http://127.0.0.1:8085;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_read_timeout 1h;
    client_max_body_size 20m;
}
```

`TRACEAGILE_CALLBACK_URL` prend alors l'adresse HTTPS publique. Le serveur d'exécution peut être
protégé de la même façon ; son adresse dans TraceAgile devient `https://…`.

## 12. Sauvegarde, mise à jour, désinstallation

| | Hors Docker | En conteneur |
| --- | --- | --- |
| Sauvegarder TraceAgile | la base (`pg_dump -Fc -d traceagile > traceagile.dump`) et le dossier `TRACEAGILE_ATTACHMENTS_DIR` | la base (avec `base-locale` : `docker compose exec -T postgres pg_dump -Fc -U traceagile traceagile > traceagile.dump`) et le volume `pieces-jointes` |
| Sauvegarder le serveur d'exécution | `EXECUTION_SERVER_DATA_DIR` (jetons, jobs) ; les outils se réinstallent | le volume `donnees` |
| Mettre à jour | arrêter le service, remplacer le jar, redémarrer | remplacer le jar dans le dossier, puis `docker compose up -d --build` |
| Désinstaller | retirer le service, supprimer le dossier, puis `DROP DATABASE traceagile; DROP ROLE traceagile;` | `docker compose down` (garde les volumes) ou `docker compose down -v` (**supprime** les volumes), puis supprimer le dossier |

À chaque mise à jour, les nouvelles migrations Flyway s'appliquent seules au démarrage. Sauvegarder
avant : une version antérieure ne peut pas rouvrir une base migrée.

Pour sauvegarder un volume Docker, par exemple :
`docker run --rm -v traceagile-app_pieces-jointes:/v -v "$PWD":/s alpine tar czf /s/pieces-jointes.tgz -C /v .`.

Changer de mode plus tard ne demande que de transporter les données :

- TraceAgile : sa base et ses pièces jointes ;
- serveur d'exécution : son dossier de données ;
- une nouvelle base se remplit par `pg_restore` ;
- un serveur d'exécution réinstallé à neuf est simplement à réappairer.

## 13. Dépannage

| Symptôme | Cause et remède |
| --- | --- |
| `FATAL: password authentication failed` | Mot de passe ou rôle de `TRACEAGILE_DB_*` différent de celui de la base ; ou `pg_hba.conf` n'autorise pas l'hôte de TraceAgile (en conteneur, l'adresse vue est celle du réseau Docker). |
| `Connection refused` vers la base depuis le conteneur | `TRACEAGILE_DB_URL` vise `localhost`, c'est-à-dire le conteneur lui-même : utiliser `postgres` (profil `base-locale`), `host.docker.internal` ou le nom de la machine de la base. |
| `traceagile.security.jwt-secret doit comporter au moins 32 octets` | `TRACEAGILE_JWT_SECRET` trop court. |
| Aucun administrateur ne peut se connecter | Le compte n'est créé que sur une base sans utilisateur. Relire le journal du premier démarrage (mot de passe aléatoire) ; sinon, changer le mot de passe depuis un autre compte administrateur. |
| Serveur d'exécution « Hors ligne » | L'adresse déclarée n'est pas joignable depuis TraceAgile (§1.2), ou un pare-feu bloque. En conteneur, tester depuis TraceAgile : `docker compose exec traceagile wget -qO- <adresse>/api/v1/health`. |
| Run bloqué « En cours » | Le serveur ne joint pas `TRACEAGILE_CALLBACK_URL`. Tester depuis la machine ou le conteneur du serveur : `curl <url>` ou `docker compose exec serveur-execution curl <url>`. |
| Serveur « Non autorisé » | Jeton révoqué côté serveur, ou `TRACEAGILE_ENCRYPTION_KEY` changée : appairer à nouveau. |
| `host.docker.internal` introuvable | Docker trop ancien (option `host-gateway` : Docker 20.10+), ou le service a été lancé sans le `docker-compose.yml` fourni. |
| Avertissement `a network with name traceagile-reseau exists but was not created for project …` | Normal quand les deux logiciels sont en conteneur sur la même machine : le second rejoint le réseau créé par le premier. |
| `depends_on … required` refusé | Docker Compose antérieur à 2.20 : le mettre à jour. |
| Windows : `Unable to establish loopback connection` | Dossier TEMP en nom court 8.3 ; les deux jars le contournent au démarrage. Si l'erreur persiste, ajouter `-Djdk.net.unixdomain.tmpdir=C:\TraceAgile\tmp` à `JAVA_OPTS`. |
| Construction : `npm ci` échoue avec `EBUSY` (Windows) | Le dépôt est dans un dossier synchronisé (OneDrive) qui verrouille `node_modules` : relancer, ou ajouter `-Ddistribution.npm.install=install` à la commande Maven. |
| Pages blanches après une mise à jour | Le navigateur garde l'ancienne version : recharger (Ctrl+F5). |

## 14. Limites de la démonstration

- Les runs automatisés de la démo ont été exécutés lors de la génération. Leurs résultats, statuts
  et rapports sont dans la base, mais leurs journaux et artefacts (captures, traces) sont restés sur
  le serveur d'origine. Rejouer un run sur le nouveau serveur les rend disponibles.
- Les dates de la démo sont celles de sa génération (sprints, campagnes, bilans).
- Les tests automatisés de SWAG pointent vers le dépôt Git de la génération
  (`file:///depots/traceagile`). Pour rejouer les runs, renseigner dans la fiche de chaque test
  automatisé (champs Dépôt et Branche) un dépôt accessible depuis le serveur d'exécution qui
  contient le dossier `saucedemo/` de TraceAgile.

Pour régénérer le jeu de démonstration après une évolution du schéma ou du guide (mainteneurs) :
`install/base-de-donnees/generer-demo-swaglabs.sh`. Il faut la pile Docker de développement
démarrée et le jar construit avec `-Pdistribution`.
