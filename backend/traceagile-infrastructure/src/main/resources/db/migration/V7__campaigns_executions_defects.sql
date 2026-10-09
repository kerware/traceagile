-- Lot 5 - campagnes, exécution manuelle et anomalies (§8.3, §8.4, §8.6, ADR-0016).

create table campaigns (
    id            uuid primary key,
    project_id    uuid         not null references projects (id) on delete cascade,
    campaign_key  varchar(20)  not null,
    key_number    integer      not null,
    name          varchar(120) not null,
    scope_type    varchar(12)  not null check (scope_type in ('SPRINT', 'RELEASE', 'REGRESSION')),
    sprint_id     uuid references sprints (id),
    release_id    uuid references releases (id),
    environment   varchar(60),
    build_version varchar(60),
    status        varchar(12)  not null check (status in ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'ABORTED')),
    planned_start date,
    planned_end   date,
    created_at    timestamptz  not null,
    created_by    varchar(32),
    updated_at    timestamptz  not null,
    updated_by    varchar(32),
    version       bigint       not null default 0,
    constraint uk_campaigns_key unique (project_id, campaign_key)
);

create table campaign_items (
    id                uuid primary key,
    campaign_id       uuid        not null references campaigns (id) on delete cascade,
    test_case_id      uuid        not null references test_cases (id),
    test_case_version integer     not null,
    assignee_id       uuid references users (id),
    position          integer     not null,
    risk_score        integer     not null,
    created_at        timestamptz not null,
    created_by        varchar(32),
    updated_at        timestamptz not null,
    updated_by        varchar(32),
    version           bigint      not null default 0,
    constraint uk_campaign_items unique (campaign_id, test_case_id)
);
create index ix_campaign_items_assignee on campaign_items (assignee_id);

create table executions (
    id                uuid primary key,
    campaign_item_id  uuid         not null references campaign_items (id) on delete cascade,
    test_case_id      uuid         not null references test_cases (id),
    attempt           integer      not null,
    test_case_version integer      not null,
    status            varchar(10)  not null check (status in ('NOT_RUN', 'RUNNING', 'PASSED', 'FAILED', 'BLOCKED', 'SKIPPED', 'ERROR')),
    status_overridden boolean      not null default false,
    started_at        timestamptz  not null,
    ended_at          timestamptz,
    duration_ms       bigint,
    comment           varchar(2000),
    executed_by       varchar(32),
    origin            varchar(10)  not null check (origin in ('MANUAL', 'AUTOMATED')),
    data_set_name     varchar(100),
    data_set_row      integer,
    parameter_values  jsonb        not null default '{}'::jsonb,
    created_at        timestamptz  not null,
    created_by        varchar(32),
    updated_at        timestamptz  not null,
    updated_by        varchar(32),
    version           bigint       not null default 0,
    constraint uk_executions_attempt unique (campaign_item_id, attempt)
);
create index ix_executions_test on executions (test_case_id, started_at);

create table step_results (
    id              uuid primary key,
    execution_id    uuid        not null references executions (id) on delete cascade,
    position        integer     not null,
    action          text        not null,
    expected_result text,
    test_data       text,
    status          varchar(10) not null check (status in ('NOT_RUN', 'PASSED', 'FAILED', 'BLOCKED', 'SKIPPED')),
    actual_result   text,
    created_at      timestamptz not null,
    created_by      varchar(32),
    updated_at      timestamptz not null,
    updated_by      varchar(32),
    version         bigint      not null default 0
);
create index ix_step_results_execution on step_results (execution_id, position);

create table defects (
    id           uuid primary key,
    project_id   uuid         not null references projects (id) on delete cascade,
    defect_key   varchar(20)  not null,
    key_number   integer      not null,
    title        varchar(200) not null,
    description  text,
    severity     varchar(10)  not null check (severity in ('BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'TRIVIAL')),
    status       varchar(12)  not null check (status in ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED')),
    external_ref varchar(100),
    created_at   timestamptz  not null,
    created_by   varchar(32),
    updated_at   timestamptz  not null,
    updated_by   varchar(32),
    version      bigint       not null default 0,
    constraint uk_defects_key unique (project_id, defect_key)
);

create table defect_executions (
    defect_id    uuid not null references defects (id) on delete cascade,
    execution_id uuid not null references executions (id) on delete cascade,
    primary key (defect_id, execution_id)
);

create table defect_requirements (
    defect_id      uuid not null references defects (id) on delete cascade,
    requirement_id uuid not null references requirements (id) on delete cascade,
    primary key (defect_id, requirement_id)
);
create index ix_defect_requirements_requirement on defect_requirements (requirement_id);
