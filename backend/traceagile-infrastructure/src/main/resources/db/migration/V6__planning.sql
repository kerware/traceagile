-- Lot 4 - planification (§8.1, §8.2, ADR-0015) : releases, sprints, périmètre des sprints.

create table releases (
    id             uuid primary key,
    project_id     uuid          not null references projects (id) on delete cascade,
    release_key    varchar(20)   not null,
    key_number     integer       not null,
    name           varchar(120)  not null,
    goal           varchar(1000),
    start_date     date          not null,
    end_date       date          not null check (end_date >= start_date),
    status         varchar(10)   not null check (status in ('PLANNED', 'ACTIVE', 'CLOSED')),
    closed_at      timestamptz,
    closing_report jsonb,
    created_at     timestamptz   not null,
    created_by     varchar(32),
    updated_at     timestamptz   not null,
    updated_by     varchar(32),
    version        bigint        not null default 0,
    constraint uk_releases_key unique (project_id, release_key)
);

create table sprints (
    id              uuid primary key,
    project_id      uuid          not null references projects (id) on delete cascade,
    release_id      uuid          references releases (id),
    sprint_key      varchar(20)   not null,
    key_number      integer       not null,
    name            varchar(120)  not null,
    goal            varchar(1000),
    start_date      date          not null,
    end_date        date          not null check (end_date >= start_date),
    capacity_points integer       check (capacity_points between 0 and 1000),
    status          varchar(10)   not null check (status in ('PLANNED', 'ACTIVE', 'CLOSED')),
    created_at      timestamptz   not null,
    created_by      varchar(32),
    updated_at      timestamptz   not null,
    updated_by      varchar(32),
    version         bigint        not null default 0,
    constraint uk_sprints_key unique (project_id, sprint_key)
);
create index ix_sprints_release on sprints (release_id);
-- §3.3-4 un seul sprint ACTIVE par projet
create unique index uk_sprints_one_active on sprints (project_id) where status = 'ACTIVE';

create table sprint_scope (
    id               uuid primary key,
    sprint_id        uuid        not null references sprints (id) on delete cascade,
    requirement_id   uuid        not null references requirements (id) on delete cascade,
    position         integer     not null,
    committed_points integer,
    outcome          varchar(15) not null check (outcome in ('PLANNED', 'DONE', 'RETURNED', 'CARRIED_OVER', 'DROPPED')),
    created_at       timestamptz not null,
    created_by       varchar(32),
    updated_at       timestamptz not null,
    updated_by       varchar(32),
    version          bigint      not null default 0,
    constraint uk_sprint_scope unique (sprint_id, requirement_id)
);
create index ix_sprint_scope_requirement on sprint_scope (requirement_id);
