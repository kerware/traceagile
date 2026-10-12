-- Après l'injection de la démo SwagLabs (installer-base -Demo), exécuté par le propriétaire de la base :
--   psql … -d traceagile -v url_serveur='http://machine-de-test:8091' -f apres-demo.sql
-- Les jetons des serveurs d'exécution sont chiffrés avec la clé de l'instance qui a produit la démo
-- (TRACEAGILE_ENCRYPTION_KEY) : ils sont effacés, le serveur reprend l'adresse de la nouvelle machine et
-- reste « non appairé » jusqu'à l'appairage depuis Administration › Serveurs d'exécution.
\set ON_ERROR_STOP on

UPDATE execution_servers
SET base_url       = COALESCE(NULLIF(:'url_serveur', ''), base_url),
    api_token      = NULL,
    webhook_secret = NULL,
    token_id       = NULL,
    token_hint     = NULL,
    paired_at      = NULL,
    last_heartbeat = NULL,
    last_error     = NULL,
    status         = 'UNPAIRED';

-- Contrôle : comptes, projet et volumes injectés
SELECT 'utilisateurs' AS element, count(*) AS nombre FROM users
UNION ALL SELECT 'projets', count(*) FROM projects
UNION ALL SELECT 'exigences', count(*) FROM requirements
UNION ALL SELECT 'tests', count(*) FROM test_cases
UNION ALL SELECT 'campagnes', count(*) FROM campaigns
UNION ALL SELECT 'runs automatisés', count(*) FROM automated_runs
UNION ALL SELECT 'anomalies', count(*) FROM defects;
