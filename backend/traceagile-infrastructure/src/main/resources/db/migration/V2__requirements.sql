-- Lot 1 — exigences agiles (§3, §4) : clés séquentielles, exigences, critères, versions, DoR / DoD, audit.

-- §3 clés lisibles séquentielles par projet et par préfixe (REQ-12, TC-45…)
create table key_sequences (
    project_id uuid        not null references projects (id) on delete cascade,
    prefix     varchar(10) not null,
    next_value integer     not null,
    primary key (project_id, prefix)
);

-- §3.1 Requirement
create table requirements (
    id                    uuid primary key,
    project_id            uuid          not null references projects (id) on delete cascade,
    requirement_key       varchar(20)   not null,
    key_number            integer       not null,
    type                  varchar(20)   not null,
    title                 varchar(200)  not null,
    description           text,
    story_as_a            varchar(500),
    story_i_want          varchar(2000),
    story_so_that         varchar(2000),
    priority              varchar(10)   not null,
    business_value        integer check (business_value between 1 and 100),
    story_points          integer check (story_points in (1, 2, 3, 5, 8, 13, 21)),
    status                varchar(20)   not null,
    risk_level            varchar(10)   not null,
    category              varchar(20),
    nfr_scale             varchar(500),
    nfr_measurement_method varchar(500),
    nfr_minimum_threshold varchar(100),
    nfr_target            varchar(100),
    nfr_unit              varchar(50),
    transverse            boolean       not null default false,
    external_ref          varchar(100),
    current_version       integer       not null default 0,
    parent_id             uuid references requirements (id),
    -- F-REQ-03 rang LexoRank : collation « C » pour un tri identique à String.compareTo
    rank                  varchar(255) collate "C" not null,
    invest_independent    boolean       not null default false,
    invest_negotiable     boolean       not null default false,
    invest_valuable       boolean       not null default false,
    invest_estimable      boolean       not null default false,
    invest_small          boolean       not null default false,
    invest_testable       boolean       not null default false,
    -- F-REQ-04 recherche plein texte (§11.1 PostgreSQL tsvector)
    search_text           text          not null default '',
    search_vector         tsvector generated always as (to_tsvector('french', search_text)) stored,
    created_at            timestamptz   not null,
    created_by            varchar(32),
    updated_at            timestamptz   not null,
    updated_by            varchar(32),
    version               bigint        not null default 0,
    constraint uk_requirements_key unique (project_id, requirement_key),
    constraint ck_requirements_type check (type in ('EPIC', 'FEATURE', 'USER_STORY', 'BUSINESS_RULE', 'NON_FUNCTIONAL', 'TECHNICAL_ENABLER')),
    constraint ck_requirements_status check (status in ('DRAFT', 'TO_REFINE', 'READY', 'IN_SPRINT', 'DONE', 'ACCEPTED', 'REJECTED', 'OBSOLETE'))
);
create index ix_requirements_project_rank on requirements (project_id, rank);
create index ix_requirements_parent on requirements (parent_id);
create index ix_requirements_search on requirements using gin (search_vector);

create table requirement_tags (
    requirement_id uuid        not null references requirements (id) on delete cascade,
    tag            varchar(50) not null,
    primary key (requirement_id, tag)
);
create index ix_requirement_tags_tag on requirement_tags (tag);

-- §3.1 AcceptanceCriterion
create table acceptance_criteria (
    id             uuid primary key,
    requirement_id uuid        not null references requirements (id) on delete cascade,
    position       integer     not null,
    format         varchar(10) not null check (format in ('TEXT', 'GHERKIN')),
    content        text        not null,
    status         varchar(10) not null check (status in ('TO_VERIFY', 'VERIFIED', 'FAILED')),
    created_at     timestamptz not null,
    created_by     varchar(32),
    updated_at     timestamptz not null,
    updated_by     varchar(32),
    version        bigint      not null default 0
);
create index ix_acceptance_criteria_requirement on acceptance_criteria (requirement_id, position);

-- §3.1 RequirementVersion (F-REQ-21)
create table requirement_versions (
    id             uuid primary key,
    requirement_id uuid        not null references requirements (id) on delete cascade,
    version_number integer     not null,
    snapshot       jsonb       not null,
    change_comment varchar(500),
    created_at     timestamptz not null,
    created_by     varchar(32),
    updated_at     timestamptz not null,
    updated_by     varchar(32),
    version        bigint      not null default 0,
    constraint uk_requirement_versions unique (requirement_id, version_number)
);

-- F-REQ-19 Definition of Ready / Definition of Done par projet
create table checklist_items (
    id         uuid primary key,
    project_id uuid         not null references projects (id) on delete cascade,
    kind       varchar(3)   not null check (kind in ('DOR', 'DOD')),
    position   integer      not null,
    label      varchar(200) not null,
    rule       varchar(40),
    created_at timestamptz  not null,
    created_by varchar(32),
    updated_at timestamptz  not null,
    updated_by varchar(32),
    version    bigint       not null default 0
);
create index ix_checklist_items_project on checklist_items (project_id, kind, position);

create table requirement_checklist_checks (
    requirement_id    uuid not null references requirements (id) on delete cascade,
    checklist_item_id uuid not null references checklist_items (id) on delete cascade,
    primary key (requirement_id, checklist_item_id)
);

-- §3.1 AuditEvent (NF-16), journal en lecture seule, sans clé étrangère pour survivre aux suppressions
create table audit_events (
    id          uuid primary key,
    project_id  uuid        not null,
    entity_type varchar(40) not null,
    entity_id   uuid        not null,
    entity_key  varchar(20),
    action      varchar(30) not null,
    diff        jsonb       not null,
    created_at  timestamptz not null,
    created_by  varchar(32),
    updated_at  timestamptz not null,
    updated_by  varchar(32),
    version     bigint      not null default 0
);
create index ix_audit_events_entity on audit_events (entity_type, entity_id, created_at desc);

-- DoR / DoD par défaut pour les projets déjà créés (les nouveaux les reçoivent à la création)
insert into checklist_items (id, project_id, kind, position, label, rule, created_at, created_by, updated_at, updated_by, version)
select gen_random_uuid(), p.id, d.kind, d.position, d.label, d.rule, now(), 'system', now(), 'system', 0
from projects p
cross join (values
    ('DOR', 1, 'Au moins un critère d''acceptation', 'HAS_ACCEPTANCE_CRITERION'),
    ('DOR', 2, 'Estimation renseignée', 'ESTIMATED'),
    ('DOR', 3, 'Story comprise et acceptée par l''équipe', null),
    ('DOD', 1, 'Au moins un test lié', 'HAS_LINKED_TEST'),
    ('DOD', 2, 'Tous les tests liés passés', 'ALL_LINKED_TESTS_PASSED'),
    ('DOD', 3, 'Aucune anomalie bloquante ouverte', 'NO_BLOCKING_DEFECT_OPEN'),
    ('DOD', 4, 'Code revu et intégré', null)
) as d (kind, position, label, rule);
