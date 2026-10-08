-- Lot 0 — socle : utilisateurs, projets, membres (§2.2, §3.1), jetons de rafraîchissement (§11.1).
-- Toutes les tables portent les champs techniques du §3 : id, created_at/by, updated_at/by, version.

create table users (
    id            uuid primary key,
    login         varchar(32)  not null,
    email         varchar(254) not null,
    display_name  varchar(100) not null,
    password_hash varchar(100) not null,
    active        boolean      not null default true,
    system_admin  boolean      not null default false,
    created_at    timestamptz  not null,
    created_by    varchar(32),
    updated_at    timestamptz  not null,
    updated_by    varchar(32),
    version       bigint       not null default 0,
    constraint uk_users_login unique (login)
);

create table projects (
    id          uuid primary key,
    project_key varchar(10)  not null,
    name        varchar(200) not null,
    description text,
    archived    boolean      not null default false,
    created_at  timestamptz  not null,
    created_by  varchar(32),
    updated_at  timestamptz  not null,
    updated_by  varchar(32),
    version     bigint       not null default 0,
    constraint uk_projects_key unique (project_key),
    constraint ck_projects_key check (project_key ~ '^[A-Z]{3,10}$')
);

create table project_members (
    id         uuid primary key,
    project_id uuid        not null references projects (id) on delete cascade,
    user_id    uuid        not null references users (id),
    role       varchar(20) not null,
    created_at timestamptz not null,
    created_by varchar(32),
    updated_at timestamptz not null,
    updated_by varchar(32),
    version    bigint      not null default 0,
    constraint uk_project_members unique (project_id, user_id),
    constraint ck_project_members_role check (role in ('ADMINISTRATOR', 'PRODUCT_OWNER', 'TESTER', 'DEVELOPER', 'VIEWER'))
);
create index ix_project_members_user on project_members (user_id);

create table refresh_tokens (
    id         uuid primary key,
    user_id    uuid        not null references users (id),
    token_hash varchar(64) not null,
    expires_at timestamptz not null,
    revoked    boolean     not null default false,
    created_at timestamptz not null,
    created_by varchar(32),
    updated_at timestamptz not null,
    updated_by varchar(32),
    version    bigint      not null default 0,
    constraint uk_refresh_tokens_hash unique (token_hash)
);
create index ix_refresh_tokens_user on refresh_tokens (user_id);
