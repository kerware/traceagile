-- Installation hors Docker (docs/installation.md) : rôle et base PostgreSQL de TraceAgile.
-- Exécuté par un superutilisateur sur la base « postgres » :
--   psql -h <hôte> -U postgres -d postgres -v base=traceagile -v utilisateur=traceagile -v motdepasse='…' -v remplacer=non -f creer-base.sql
-- Idempotent : le rôle et la base ne sont créés que s'ils n'existent pas ; remplacer=oui supprime d'abord la base.
-- Le schéma, les référentiels et l'administrateur sont créés par TraceAgile à son premier démarrage
-- (migrations Flyway, InitialAdministrator), ou viennent du jeu de démonstration SwagLabs (installer-base -Demo).
\set ON_ERROR_STOP on

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'utilisateur', :'motdepasse')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'utilisateur') \gexec

SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'utilisateur', :'motdepasse') \gexec

SELECT format('DROP DATABASE IF EXISTS %I WITH (FORCE)', :'base')
WHERE :'remplacer' = 'oui' \gexec

SELECT format('CREATE DATABASE %I OWNER %I ENCODING %L TEMPLATE template0', :'base', :'utilisateur', 'UTF8')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'base') \gexec

SELECT format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', :'base', :'utilisateur') \gexec
