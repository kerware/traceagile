-- ADR-0018 campagnes rangées dans une arborescence de dossiers (chemins « a/b », comme les tests).
alter table campaigns add column folder varchar(300);
create index ix_campaigns_folder on campaigns (project_id, folder);

create table campaign_folders (
    id         uuid primary key,
    project_id uuid         not null references projects (id) on delete cascade,
    path       varchar(300) not null,
    created_at timestamptz  not null,
    created_by varchar(32),
    updated_at timestamptz  not null,
    updated_by varchar(32),
    version    bigint       not null default 0,
    constraint uk_campaign_folders_path unique (project_id, path)
);
