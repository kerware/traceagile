-- §3.1 ExecutionServer (ADR-0020) : jeton et secret de signature émis par le serveur, chiffrés (AES-GCM).
create table execution_servers (
    id             uuid primary key,
    name           varchar(100) not null unique,
    base_url       varchar(300) not null,
    auth_type      varchar(20)  not null,
    api_token      text,
    webhook_secret text,
    token_id       varchar(100),
    token_hint     varchar(8),
    paired_at      timestamptz,
    status         varchar(15)  not null check (status in ('UNPAIRED', 'UNKNOWN', 'ONLINE', 'OFFLINE', 'UNAUTHORIZED')),
    last_heartbeat timestamptz,
    last_error     varchar(500),
    server_version varchar(50),
    techniques     jsonb        not null default '[]'::jsonb,
    frameworks     jsonb        not null default '[]'::jsonb,
    environments   jsonb        not null default '[]'::jsonb,
    agents         integer      not null default 0,
    enabled        boolean      not null default true,
    created_at     timestamptz  not null,
    created_by     varchar(32),
    updated_at     timestamptz  not null,
    updated_by     varchar(32),
    version        bigint       not null default 0
);

-- §3.1 AutomatedRun (§8.5, §10)
create table automated_runs (
    id              uuid primary key,
    project_id      uuid         not null references projects (id) on delete cascade,
    run_key         varchar(20)  not null,
    key_number      integer      not null,
    campaign_id     uuid         not null references campaigns (id) on delete cascade,
    server_id       uuid         not null references execution_servers (id),
    status          varchar(12)  not null check (status in ('QUEUED', 'DISPATCHED', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED', 'TIMEOUT')),
    requested_by    varchar(32),
    requested_at    timestamptz  not null,
    dispatched_at   timestamptz,
    started_at      timestamptz,
    ended_at        timestamptz,
    last_event_at   timestamptz,
    environment     varchar(60),
    build_version   varchar(60),
    external_job_id varchar(100),
    agent           varchar(100),
    logs_url        varchar(500),
    report_url      varchar(500),
    timeout_minutes integer      not null,
    error_code      varchar(60),
    error_message   varchar(1000),
    summary_total   integer,
    summary_passed  integer,
    summary_failed  integer,
    summary_error   integer,
    summary_skipped integer,
    rerun_of        varchar(20),
    created_at      timestamptz  not null,
    created_by      varchar(32),
    updated_at      timestamptz  not null,
    updated_by      varchar(32),
    version         bigint       not null default 0,
    constraint uk_automated_runs_key unique (project_id, run_key)
);
create index ix_automated_runs_campaign on automated_runs (campaign_id);
create index ix_automated_runs_status on automated_runs (status);
create index ix_automated_runs_key on automated_runs (run_key);

-- §10.4 idempotence des webhooks
create table processed_webhook_events (
    event_id    varchar(100) primary key,
    run_id      uuid         not null references automated_runs (id) on delete cascade,
    received_at timestamptz  not null
);

-- Une tentative automatisée appartient à un run ; elle est en attente (NOT_RUN) jusqu'à TEST_STARTED.
alter table executions add column run_id uuid references automated_runs (id);
create index ix_executions_run on executions (run_id) where run_id is not null;

-- F-EXE-11 test instable
alter table test_cases add column flaky boolean not null default false;
