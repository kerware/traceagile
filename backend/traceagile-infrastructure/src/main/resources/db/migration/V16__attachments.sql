-- ADR-0024 pièces jointes (F-EXE-01, F-EXE-03, F-EXP-08) : métadonnées ; contenu dans le FileStorage.
create table attachments (
    id           uuid primary key,
    project_id   uuid         not null references projects (id) on delete cascade,
    target_type  varchar(20)  not null check (target_type in ('REQUIREMENT', 'EXECUTION_STEP', 'DEFECT', 'SESSION_NOTE')),
    target_id    uuid         not null,
    file_name    varchar(200) not null,
    content_type varchar(100) not null,
    size         bigint       not null,
    storage_key  varchar(100) not null,
    created_at   timestamptz  not null,
    created_by   varchar(32),
    updated_at   timestamptz  not null,
    updated_by   varchar(32),
    version      bigint       not null default 0
);
create index ix_attachments_target on attachments (target_type, target_id);
create index ix_attachments_storage on attachments (storage_key);
