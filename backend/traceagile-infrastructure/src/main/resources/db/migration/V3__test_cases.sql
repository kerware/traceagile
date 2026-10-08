-- Lot 2 — référentiel de tests (§3.1, §6) : cas de test, pas manuels, chartes, définitions
-- automatisées, versions, frameworks de référence, liens de traçabilité.

create table test_cases (
    id                       uuid primary key,
    project_id               uuid         not null references projects (id) on delete cascade,
    test_key                 varchar(20)  not null,
    key_number               integer      not null,
    kind                     varchar(12)  not null check (kind in ('MANUAL', 'EXPLORATORY', 'AUTOMATED')),
    title                    varchar(200) not null,
    description              text,
    objective                text,
    priority                 varchar(10)  not null,
    status                   varchar(15)  not null check (status in ('DRAFT', 'READY', 'NEEDS_UPDATE', 'OBSOLETE')),
    estimated_duration_min   integer check (estimated_duration_min between 1 and 10000),
    folder                   varchar(300),
    current_version          integer      not null default 1,
    automation_candidate     boolean      not null default false,
    automation_justification varchar(1000),
    manual_data_set          jsonb,
    created_at               timestamptz  not null,
    created_by               varchar(32),
    updated_at               timestamptz  not null,
    updated_by               varchar(32),
    version                  bigint       not null default 0,
    constraint uk_test_cases_key unique (project_id, test_key)
);
create index ix_test_cases_project on test_cases (project_id, key_number);

create table test_case_tags (
    test_case_id uuid        not null references test_cases (id) on delete cascade,
    tag          varchar(50) not null,
    primary key (test_case_id, tag)
);

-- §3.1 ManualStep (F-MAN-01)
create table manual_steps (
    id              uuid primary key,
    test_case_id    uuid        not null references test_cases (id) on delete cascade,
    position        integer     not null,
    action          text        not null,
    expected_result text,
    test_data       text,
    created_at      timestamptz not null,
    created_by      varchar(32),
    updated_at      timestamptz not null,
    updated_by      varchar(32),
    version         bigint      not null default 0
);
create index ix_manual_steps_test on manual_steps (test_case_id, position);

-- §3.1 ExploratoryCharter (F-EXP-01 / F-EXP-02)
create table exploratory_charters (
    id                  uuid primary key,
    test_case_id        uuid         not null unique references test_cases (id) on delete cascade,
    mission_explore     varchar(500),
    mission_with        varchar(500),
    mission_to_discover varchar(500),
    areas               jsonb        not null,
    heuristics          jsonb        not null,
    timebox_min         integer      not null check (timebox_min in (60, 90, 120)),
    setup_notes         text,
    targeted_risk       varchar(500),
    created_at          timestamptz  not null,
    created_by          varchar(32),
    updated_at          timestamptz  not null,
    updated_by          varchar(32),
    version             bigint       not null default 0
);

-- §3.1 AutomatedTestDefinition (§6.1)
create table automated_test_definitions (
    id                       uuid primary key,
    test_case_id             uuid         not null unique references test_cases (id) on delete cascade,
    technique                varchar(20)  not null check (technique in ('BDD', 'UNIT', 'UI', 'API', 'KEYWORD', 'DATA_DRIVEN', 'PERFORMANCE', 'CONTRACT')),
    framework                varchar(60)  not null,
    language                 varchar(40),
    repository_url           varchar(500),
    branch                   varchar(200),
    path                     varchar(500),
    test_identifier          varchar(500),
    feature_name             varchar(200),
    gherkin_source           text,
    data_set                 jsonb,
    parameters               jsonb        not null,
    execution_tags           jsonb        not null,
    environment_requirements jsonb        not null,
    keywords                 jsonb        not null,
    missing_in_repository    boolean      not null default false,
    created_at               timestamptz  not null,
    created_by               varchar(32),
    updated_at               timestamptz  not null,
    updated_by               varchar(32),
    version                  bigint       not null default 0
);

-- F-AUT-10 versions des tests
create table test_case_versions (
    id             uuid primary key,
    test_case_id   uuid        not null references test_cases (id) on delete cascade,
    version_number integer     not null,
    snapshot       jsonb       not null,
    created_at     timestamptz not null,
    created_by     varchar(32),
    updated_at     timestamptz not null,
    updated_by     varchar(32),
    version        bigint      not null default 0,
    constraint uk_test_case_versions unique (test_case_id, version_number)
);

-- §3.1 TraceLink : extrémités génériques (pas de clé étrangère), nettoyées par l'application
create table trace_links (
    id          uuid primary key,
    project_id  uuid        not null references projects (id) on delete cascade,
    source_type varchar(25) not null,
    source_id   uuid        not null,
    target_type varchar(25) not null,
    target_id   uuid        not null,
    link_type   varchar(20) not null check (link_type in ('VERIFIES', 'PARTIALLY_VERIFIES', 'RELATES_TO')),
    origin      varchar(15) not null,
    created_at  timestamptz not null,
    created_by  varchar(32),
    updated_at  timestamptz not null,
    updated_by  varchar(32),
    version     bigint      not null default 0,
    constraint uk_trace_links unique (source_id, target_id)
);
create index ix_trace_links_target on trace_links (target_type, target_id);
create index ix_trace_links_source on trace_links (source_type, source_id);

-- F-AUT-01 frameworks de référence par technique (§6.1), modifiables par l'administrateur
create table automation_frameworks (
    id         uuid primary key,
    technique  varchar(20) not null,
    name       varchar(60) not null,
    position   integer     not null,
    created_at timestamptz not null,
    created_by varchar(32),
    updated_at timestamptz not null,
    updated_by varchar(32),
    version    bigint      not null default 0
);

insert into automation_frameworks (id, technique, name, position, created_at, created_by, updated_at, updated_by, version)
select gen_random_uuid(), f.technique, f.name, f.position, now(), 'system', now(), 'system', 0
from (values
    ('BDD', 'Cucumber-JVM', 1), ('BDD', 'Cucumber-JS', 2), ('BDD', 'Behave', 3), ('BDD', 'SpecFlow', 4), ('BDD', 'Karate', 5),
    ('UNIT', 'JUnit 5', 1), ('UNIT', 'Kotest', 2), ('UNIT', 'pytest', 3), ('UNIT', 'Jest', 4), ('UNIT', 'Vitest', 5),
    ('UI', 'Playwright', 1), ('UI', 'Selenium', 2), ('UI', 'Cypress', 3), ('UI', 'Appium', 4),
    ('API', 'REST Assured', 1), ('API', 'Karate', 2), ('API', 'Postman/Newman', 3), ('API', 'pytest + requests', 4),
    ('KEYWORD', 'Robot Framework', 1),
    ('DATA_DRIVEN', 'JUnit 5', 1), ('DATA_DRIVEN', 'pytest', 2), ('DATA_DRIVEN', 'Playwright', 3), ('DATA_DRIVEN', 'Cucumber-JVM', 4),
    ('PERFORMANCE', 'Gatling', 1), ('PERFORMANCE', 'k6', 2), ('PERFORMANCE', 'JMeter', 3),
    ('CONTRACT', 'Pact', 1), ('CONTRACT', 'Spring Cloud Contract', 2)
) as f (technique, name, position);
