# Installation de TraceAgile hors Docker

Cette note décrit l'installation de TraceAgile et de son serveur d'exécution sur des machines
indépendantes, sans Docker : deux jars Java autonomes, une base PostgreSQL, et en option le jeu de
démonstration SwagLabs. Pour un poste de développement, `docker compose up` reste plus simple
(voir [CLAUDE.md](../CLAUDE.md)). Les choix techniques sont dans l'[ADR-0027](adr/0027-installation-hors-docker.md).

```
 Machine A : TraceAgile                       Machine B : serveur d'exécution
 +------------------------------+    jobs     +-------------------------------+
 | traceagile-api.jar  :8085    | ----------> | execution-server.jar  :8091   |
 | (API + interface + guide)    |             | (API + interface, base H2)    |
 |                              | <---------- | Java 21, Git, Node.js, Python |
 +--------------+---------------+  résultats  +-------------------------------+
                |                 (webhooks)
                | JDBC
 +--------------v---------------+
 | PostgreSQL 16+  :5432        |   (machine A ou une machine dédiée)
 +------------------------------+
```

Les deux jars peuvent aussi tourner sur la même machine, et plusieurs serveurs d'exécution peuvent
être rattachés à un même TraceAgile.

## 1. Prérequis

| Machine | Logiciel | Remarque |
| --- | --- | --- |
| TraceAgile | Java 21 (JRE suffit) | `java -version` doit afficher 21 ou plus. |
| Base de données | PostgreSQL **16 ou plus**, avec `psql` | Le jeu de démonstration est un export PostgreSQL 16. Un superutilisateur (ex. `postgres`) est nécessaire pour la création du rôle et de la base. |
| Serveur d'exécution | Java 21, Git | Node.js 22, Python 3.10+ selon les frameworks utilisés (Playwright, Cypress, Robot Framework). L'interface du serveur détecte ces prérequis et explique comment les installer. Les outils de test eux-mêmes s'installent depuis cette interface. |
| Construction des jars | Java 21, Maven 3.9 | Node.js est téléchargé par Maven. À faire une fois, sur un poste de développement. |

Système : Windows 10/11 ou Server 2019+, Linux (x64 ou arm64), macOS. Mémoire : 1 Go pour
TraceAgile, 512 Mo pour le serveur d'exécution, plus ce que demandent les navigateurs des tests.

## 2. Produire les deux jars distribuables

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
    INSTALLATION.md                 cette note
    traceagile/
      traceagile-api.jar            API, interface web et guide d'utilisation (≈ 105 Mo)
      traceagile.env.exemple        configuration à copier en traceagile.env
      demarrer.sh  demarrer.ps1     lancement (lit traceagile.env)
      traceagile.service            service systemd
    serveur-execution/
      execution-server.jar          serveur d'exécution et son interface
      serveur-execution.env.exemple
      demarrer.sh  demarrer.ps1
      serveur-execution.service
    base-de-donnees/
      installer-base.sh  installer-base.ps1   création du rôle et de la base, démo en option
      creer-base.sql  apres-demo.sql
      demo/swaglabs.sql             jeu de démonstration SwagLabs (projet SWAG)
      demo/pieces-jointes/          captures jointes de la démo
  traceagile-<version>.zip          traceagile/ + base-de-donnees/ + note
  serveur-execution-<version>.zip   serveur-execution/ + note
```

Sans le script, les jars s'obtiennent ainsi :

```bash
cd backend
mvn -pl traceagile-api -am package -Pdistribution -DskipTests   # → traceagile-api/target/traceagile-api.jar
mvn -pl execution-server -am package -DskipTests                # → execution-server/target/execution-server.jar
```

Le profil `distribution` construit l'interface React (`frontend/`) et l'embarque dans le jar, avec le
guide d'utilisation. Sans lui, le jar ne contient que l'API (c'est le cas de l'image Docker, où nginx
sert l'interface).

Copier `traceagile-<version>.zip` sur la machine A et `serveur-execution-<version>.zip` sur la
machine B, puis les décompresser (ex. `/opt/traceagile`, `C:\TraceAgile`).

## 3. Créer la base de données

Le script `base-de-donnees/installer-base.(sh|ps1)` se lance depuis toute machine qui a `psql` et
accède au serveur PostgreSQL. Il :

1. crée le rôle applicatif (ou met à jour son mot de passe) et la base, propriété de ce rôle, en UTF-8 ;
2. avec l'option démo, injecte le jeu SwagLabs ;
3. prépare le serveur d'exécution de la démo (adresse, appairage à refaire) ;
4. copie les pièces jointes de la démo.

Le mot de passe du superutilisateur est demandé par `psql` (ou lu dans `PGPASSWORD`, `~/.pgpass`,
`%APPDATA%\postgresql\pgpass.conf`).

| Option (`.sh`) | Option (`.ps1`) | Défaut | Rôle |
| --- | --- | --- | --- |
| `--mot-de-passe` | `-MotDePasse` | *obligatoire* | mot de passe du rôle applicatif |
| `--hote`, `--port` | `-Hote`, `-Port` | `localhost`, `5432` | serveur PostgreSQL |
| `--superutilisateur` | `-Superutilisateur` | `postgres` | compte qui crée rôle et base |
| `--base`, `--utilisateur` | `-Base`, `-Utilisateur` | `traceagile`, `traceagile` | noms de la base et du rôle |
| `--demo` | `-Demo` | non | injecte la démo SwagLabs (base vide uniquement) |
| `--remplacer` | `-Remplacer` | non | **supprime** puis recrée la base (toutes les données sont perdues) |
| `--url-serveur` | `-UrlServeur` | inchangée | adresse du serveur d'exécution de la démo |
| `--pieces-jointes` | `-PiecesJointes` | aucune copie | dossier `TRACEAGILE_ATTACHMENTS_DIR` où copier les pièces jointes de la démo |

`PSQL` (variable d'environnement) remplace la commande `psql`, par exemple
`PSQL="/usr/lib/postgresql/16/bin/psql"` ou, sous Windows,
`$env:PSQL = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'`.

### 3.1 Base vide (production)

```bash
cd base-de-donnees
./installer-base.sh --hote db.example.org --mot-de-passe 'motDePasseDuRole'
```

```powershell
cd base-de-donnees
.\installer-base.ps1 -Hote db.example.org -MotDePasse 'motDePasseDuRole'
```

La base reste vide. **Au premier démarrage, TraceAgile crée lui-même le schéma** (migrations
Flyway), les données de démarrage (référentiels : statuts, types, priorités…) et le compte
administrateur défini par `TRACEAGILE_ADMIN_LOGIN` / `TRACEAGILE_ADMIN_PASSWORD` (§4). Ce compte
n'est créé que si la base ne contient aucun utilisateur.

### 3.2 Base avec la démonstration SwagLabs

```bash
./installer-base.sh --hote db.example.org --mot-de-passe 'motDePasseDuRole' --demo \
  --url-serveur http://machine-b:8091 --pieces-jointes /opt/traceagile/pieces-jointes
```

```powershell
.\installer-base.ps1 -Hote db.example.org -MotDePasse 'motDePasseDuRole' -Demo `
  -UrlServeur http://machine-b:8091 -PiecesJointes C:\TraceAgile\pieces-jointes
```

La démo contient le projet **SWAG** (application Swag Labs, www.saucedemo.com), décrit dans le
[guide d'utilisation](guide/README.md) : backlog, critères Gherkin, ENF, atelier Example Mapping,
tests manuels, automatisés, BDD, chartes exploratoires, deux sprints joués avec campagnes, runs
automatisés réels, session exploratoire, anomalies, bilans. Comptes (mot de passe **`SwagLabs-2026`**,
à changer après la première connexion) :

| Compte | Rôle dans SWAG |
| --- | --- |
| `admin` | administrateur système |
| `po` | Product Owner |
| `qa1`, `qa2` | testeurs |
| `dev` | développeur |
| `viewer` | lecteur |

Le script refuse d'injecter la démo dans une base qui contient déjà des tables : ajouter
`--remplacer` pour repartir de zéro (après une sauvegarde si besoin).

Le serveur d'exécution de la démo garde son nom (« Serveur d'exécution ») ; son adresse devient
celle de `--url-serveur` et il est **à appairer** (§7.3). Les jetons de la machine qui a produit la
démo ne sont jamais distribués.

## 4. Configurer TraceAgile

Dans le dossier `traceagile/`, copier `traceagile.env.exemple` en `traceagile.env`, l'adapter, et
le protéger (`chmod 600 traceagile.env`, ou droits NTFS réservés au compte du service) : il contient
des secrets.

| Variable | Défaut | À renseigner |
| --- | --- | --- |
| `SERVER_PORT` | `8085` | port HTTP (interface et API) |
| `TRACEAGILE_DB_URL` | `jdbc:postgresql://localhost:5433/traceagile` | `jdbc:postgresql://<hôte>:5432/<base>` |
| `TRACEAGILE_DB_USER`, `TRACEAGILE_DB_PASSWORD` | `traceagile` | rôle et mot de passe du §3 |
| `TRACEAGILE_JWT_SECRET` | secret de développement | **obligatoire** : 32 caractères ou plus, aléatoire (signature des jetons de connexion) |
| `TRACEAGILE_ENCRYPTION_KEY` | clé de développement | **obligatoire** : aléatoire ; chiffre les jetons des serveurs d'exécution. La changer oblige à réappairer les serveurs. |
| `TRACEAGILE_ADMIN_LOGIN`, `TRACEAGILE_ADMIN_PASSWORD`, `TRACEAGILE_ADMIN_EMAIL` | `admin`, aléatoire, `admin@traceagile.local` | administrateur créé sur une base vide. Sans mot de passe, un mot de passe aléatoire est écrit **une fois** dans le journal (`WARN`). |
| `TRACEAGILE_COOKIE_SECURE` | `false` | `true` dès que l'accès se fait en HTTPS |
| `TRACEAGILE_CALLBACK_URL` | `http://localhost:8085/api/v1/execution-callbacks` | adresse de TraceAgile **vue depuis le serveur d'exécution** (nom ou IP de la machine A, jamais `localhost` si le serveur est ailleurs) |
| `TRACEAGILE_ATTACHMENTS_DIR` | `<TEMP>/traceagile-attachments` | **obligatoire** : dossier persistant des pièces jointes (le dossier temporaire par défaut peut être vidé par le système) |
| `JAVA_OPTS` | — | options de la JVM (ex. `-Xmx1g`) |

Générer un secret : `openssl rand -base64 48`, ou en PowerShell
`[Convert]::ToBase64String((1..48 | % { Get-Random -Max 256 }) -as [byte[]])`.

Toute propriété Spring Boot peut aussi se régler par variable d'environnement ou par un fichier
`config/application.yml` à côté du jar. **Ne pas activer le profil `demo`** : il charge un autre jeu
de démonstration (projet SHOP) et appaire le simulateur de développement.

## 5. Démarrer TraceAgile

```bash
cd /opt/traceagile/traceagile && ./demarrer.sh
```

```powershell
cd C:\TraceAgile\traceagile; .\demarrer.ps1
```

Au premier démarrage sur une base vide, le journal indique les migrations Flyway puis la création
de l'administrateur. Vérifications :

- `http://machine-a:8085/actuator/health` répond `{"status":"UP"}` ;
- `http://machine-a:8085/` affiche l'écran de connexion ;
- le menu **Documentation** (`/guide/`) ouvre le guide d'utilisation ;
- `http://machine-a:8085/swagger-ui.html` décrit l'API.

## 6. Démarrer en service

**Linux (systemd).** Créer un compte sans connexion (`sudo useradd -r -s /usr/sbin/nologin traceagile`),
lui donner le dossier (`sudo chown -R traceagile: /opt/traceagile`), puis :

```bash
sudo cp /opt/traceagile/traceagile/traceagile.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now traceagile
journalctl -u traceagile -f
```

Adapter dans le fichier `WorkingDirectory`, `EnvironmentFile` et le chemin du jar s'ils diffèrent de
`/opt/traceagile`. Les variables y sont lues par systemd : ne pas mettre de guillemets autour des
valeurs.

**Windows.** Le plus simple est [WinSW](https://github.com/winsw/winsw) ou
[NSSM](https://nssm.cc/) : service qui lance `powershell -ExecutionPolicy Bypass -File
C:\TraceAgile\traceagile\demarrer.ps1`, démarrage automatique, compte de service ayant les droits sur
le dossier. Sinon, une tâche planifiée « au démarrage du système » fait l'affaire.

Le serveur d'exécution s'installe de la même façon avec `serveur-execution.service` (compte
`executeur`) ou son `demarrer.ps1`.

## 7. Installer le serveur d'exécution

### 7.1 Configuration et démarrage

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

Puis `./demarrer.sh` (ou `.\demarrer.ps1`). La base H2 est créée au premier démarrage : il n'y a
pas de base à installer pour le serveur d'exécution.

### 7.2 Outils de test

Ouvrir `http://machine-b:8091`, se connecter avec le compte ci-dessus, puis la page **Outils** :

- les prérequis (Java, Git, Node.js, Python) sont détectés ; ceux qui manquent s'installent avec les
  droits d'administrateur de la machine, en suivant l'aide affichée ;
- l'**assistant d'installation** propose, pour les frameworks choisis (Playwright, Cypress,
  Selenium, Robot Framework, JUnit, Maven, JDK, Gatling…), un plan ordonné qui s'installe sans droits
  particuliers dans `EXECUTION_SERVER_TOOLS_DIR`.

Pour rejouer la démo SwagLabs : Node.js et l'outil **Playwright** (avec ses navigateurs).

### 7.3 Relier TraceAgile au serveur

1. Dans TraceAgile, en administrateur : **Administration → Serveurs d'exécution**. Déclarer le
   serveur avec l'adresse `http://machine-b:8091` (pour la démo, il existe déjà avec l'adresse donnée
   par `--url-serveur` ; corriger l'adresse si besoin).
2. **Appairer** en saisissant le compte administrateur du serveur d'exécution : TraceAgile demande un
   jeton et un secret de signature des webhooks, les chiffre, puis ne garde plus le mot de passe.
3. L'état passe à **En ligne** au bout de quelques secondes (sonde de santé périodique).

Ensuite, un run automatisé lancé dans TraceAgile envoie un job au serveur. Le serveur clone le dépôt
Git du projet, exécute les tests et renvoie l'avancement et les résultats à `TRACEAGILE_CALLBACK_URL`.
Les journaux et artefacts (captures, traces) restent sur le serveur d'exécution et sont relus par
TraceAgile à la demande.

### 7.4 Réseau

| Flux | De → vers | Port |
| --- | --- | --- |
| Navigateurs des utilisateurs | postes → machine A | 8085 (ou 443 derrière un proxy) |
| Connexion à la base | machine A → PostgreSQL | 5432 |
| Jobs, santé, artefacts | machine A → machine B | 8091 |
| Webhooks de résultats | machine B → machine A | 8085 (`TRACEAGILE_CALLBACK_URL`) |
| Clonage des dépôts de tests | machine B → serveur Git | 443 / 22 |

Ouvrir ces ports dans les pare-feu (sous Windows : `New-NetFirewallRule -DisplayName TraceAgile
-Direction Inbound -Protocol TCP -LocalPort 8085 -Action Allow`, idem 8091 sur la machine B).
Les dépôts Git privés : identifiants par hôte dans l'interface du serveur d'exécution (page **Paramètres**).

## 8. HTTPS et proxy inverse

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
protégé de la même façon (son adresse dans TraceAgile devient `https://…`).

## 9. Sauvegarde, mise à jour, désinstallation

**Sauvegarde** : la base (`pg_dump -Fc -d traceagile > traceagile.dump`) **et** le dossier
`TRACEAGILE_ATTACHMENTS_DIR`. Côté serveur d'exécution, `EXECUTION_SERVER_DATA_DIR` (jetons, jobs) ;
les outils se réinstallent.

**Mise à jour** : arrêter le service, remplacer le jar, redémarrer. Les nouvelles migrations Flyway
s'appliquent seules au démarrage. Sauvegarder avant ; une version antérieure ne peut pas rouvrir une
base migrée.

**Désinstallation** : arrêter et retirer les services, supprimer les dossiers, puis
`DROP DATABASE traceagile; DROP ROLE traceagile;` avec un superutilisateur.

## 10. Dépannage

| Symptôme | Cause et remède |
| --- | --- |
| `FATAL: password authentication failed` | Mot de passe ou rôle de `TRACEAGILE_DB_*` différent de celui du §3 ; ou `pg_hba.conf` n'autorise pas l'hôte de TraceAgile. |
| `traceagile.security.jwt-secret doit comporter au moins 32 octets` | `TRACEAGILE_JWT_SECRET` trop court. |
| Aucun administrateur ne peut se connecter | Le compte n'est créé que sur une base sans utilisateur : relire le journal du premier démarrage (mot de passe aléatoire) ; sinon le changer depuis un autre administrateur. |
| Serveur d'exécution « Hors ligne » | Pare-feu ou adresse déclarée injoignable depuis la machine A. |
| Run bloqué « En cours » | Le serveur ne joint pas `TRACEAGILE_CALLBACK_URL` : tester `curl <url>` depuis la machine B. |
| Serveur « Non autorisé » | Jeton révoqué côté serveur ou `TRACEAGILE_ENCRYPTION_KEY` changée : appairer à nouveau. |
| Windows : `Unable to establish loopback connection` | Dossier TEMP en nom court 8.3 ; les deux jars le contournent au démarrage. Si l'erreur persiste, ajouter `-Djdk.net.unixdomain.tmpdir=C:\TraceAgile\tmp` à `JAVA_OPTS`. |
| Construction : `npm ci` échoue avec `EBUSY` (Windows) | Le dépôt est dans un dossier synchronisé (OneDrive) qui verrouille `node_modules` : relancer, ou ajouter `-Ddistribution.npm.install=install` à la commande Maven. |
| Pages blanches après une mise à jour | Le navigateur garde l'ancienne version : recharger (Ctrl+F5). |

## 11. Limites de la démonstration

- Les runs automatisés de la démo ont été exécutés lors de la génération : leurs résultats, statuts
  et rapports sont dans la base, mais leurs journaux et artefacts (captures, traces) sont restés sur
  le serveur d'origine. Rejouer un run sur le nouveau serveur les rend disponibles.
- Les dates de la démo sont celles de sa génération (sprints, campagnes, bilans).
- Les tests automatisés de SWAG pointent vers le dépôt Git de la génération
  (`file:///depots/traceagile`) : pour rejouer les runs, indiquer dans la fiche de chaque test
  automatisé (champs Dépôt et Branche) un dépôt accessible depuis le serveur d'exécution qui contient
  le dossier `saucedemo/` de TraceAgile.

Pour régénérer le jeu de démonstration après une évolution du schéma ou du guide (mainteneurs) :
`install/base-de-donnees/generer-demo-swaglabs.sh` (pile Docker démarrée, jar construit avec
`-Pdistribution`).
