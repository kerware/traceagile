-- ADR-0030 dépôts Git déclarés pour toute l'instance et leurs projets, choisis dans les fiches de tests.
create table git_sources (
    id          uuid primary key,
    name        varchar(100) not null unique,
    base_url    varchar(300) not null,
    auth_type   varchar(10)  not null check (auth_type in ('NONE', 'TOKEN', 'SSH_KEY')),
    username    varchar(100),
    secret      text,
    description varchar(500),
    created_at  timestamptz  not null,
    created_by  varchar(32),
    updated_at  timestamptz  not null,
    updated_by  varchar(32),
    version     bigint       not null default 0
);

create table git_projects (
    id             uuid primary key,
    source_id      uuid         not null references git_sources (id),
    name           varchar(200) not null,
    default_branch varchar(200),
    description    varchar(500),
    created_at     timestamptz  not null,
    created_by     varchar(32),
    updated_at     timestamptz  not null,
    updated_by     varchar(32),
    version        bigint       not null default 0
);
create unique index git_projects_source_name on git_projects (source_id, lower(name));

alter table automated_test_definitions add column git_project_id uuid references git_projects (id);
create index automated_test_definitions_git_project on automated_test_definitions (git_project_id);
