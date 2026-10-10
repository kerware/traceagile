-- ADR-0023 bilans et rapports configurables : définitions, instantanés (RPT-n), règles de verdict du projet.
alter table projects add column verdict_rules jsonb;

create table report_definitions (
    id              uuid primary key,
    project_id      uuid         not null references projects (id) on delete cascade,
    name            varchar(120) not null,
    description     text,
    scope_type      varchar(12)  not null check (scope_type in ('SPRINT', 'RELEASE', 'PROJECT')),
    sections        jsonb        not null,
    default_format  varchar(12)  not null check (default_format in ('HTML', 'PDF', 'DOCX', 'XLSX', 'MARKDOWN', 'CSV', 'JSON')),
    include_charts  boolean      not null default true,
    include_details boolean      not null default false,
    built_in        boolean      not null default false,
    created_at      timestamptz  not null,
    created_by      varchar(32),
    updated_at      timestamptz  not null,
    updated_by      varchar(32),
    version         bigint       not null default 0,
    constraint uk_report_definitions_name unique (project_id, name)
);

create table report_snapshots (
    id               uuid primary key,
    project_id       uuid         not null references projects (id) on delete cascade,
    report_key       varchar(20)  not null,
    key_number       integer      not null,
    title            varchar(200) not null,
    definition_name  varchar(120) not null,
    scope_type       varchar(12)  not null check (scope_type in ('SPRINT', 'RELEASE', 'PROJECT')),
    scope            varchar(40)  not null,
    scope_label      varchar(200) not null,
    sections         jsonb        not null,
    include_charts   boolean      not null,
    include_details  boolean      not null,
    data             jsonb        not null,
    computed_verdict varchar(24) check (computed_verdict in ('GO', 'GO_WITH_RESERVATIONS', 'NO_GO')),
    verdict_override varchar(24) check (verdict_override in ('GO', 'GO_WITH_RESERVATIONS', 'NO_GO')),
    verdict_comment  text,
    verdict_by       varchar(50),
    verdict_at       timestamptz,
    frozen           boolean      not null default false,
    frozen_at        timestamptz,
    frozen_by        varchar(50),
    created_at       timestamptz  not null,
    created_by       varchar(32),
    updated_at       timestamptz  not null,
    updated_by       varchar(32),
    version          bigint       not null default 0,
    constraint uk_report_snapshots_key unique (project_id, report_key)
);
create index ix_report_snapshots_scope on report_snapshots (project_id, scope);
