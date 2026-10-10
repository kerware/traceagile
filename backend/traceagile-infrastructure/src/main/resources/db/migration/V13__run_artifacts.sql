-- ADR-0021 artefacts des runs (traces système, JUnit XML, Jest JSON, rapport, copies d'écran) :
-- référence seulement, le contenu reste sur le serveur d'exécution.
create table run_artifacts (
    id           uuid primary key,
    run_id       uuid         not null references automated_runs (id) on delete cascade,
    execution_id uuid references executions (id) on delete set null,
    name         varchar(200) not null,
    content_type varchar(100) not null,
    kind         varchar(15)  not null check (kind in ('SYSTEM_TRACE', 'JUNIT', 'JEST', 'REPORT', 'SCREENSHOT', 'OTHER')),
    size         bigint,
    created_at   timestamptz  not null,
    created_by   varchar(32),
    updated_at   timestamptz  not null,
    updated_by   varchar(32),
    version      bigint       not null default 0,
    constraint uk_run_artifacts_name unique (run_id, name)
);
create index ix_run_artifacts_execution on run_artifacts (execution_id) where execution_id is not null;
