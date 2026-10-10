-- ADR-0024 commentaires d'exigence (questions comprises) et cartes de l'atelier Example Mapping (F-REQ-13 à F-REQ-15).
create table comments (
    id             uuid primary key,
    requirement_id uuid         not null references requirements (id) on delete cascade,
    author         varchar(50)  not null,
    text           text         not null,
    question       boolean      not null default false,
    resolved_at    timestamptz,
    resolved_by    varchar(50),
    edited_at      timestamptz,
    created_at     timestamptz  not null,
    created_by     varchar(32),
    updated_at     timestamptz  not null,
    updated_by     varchar(32),
    version        bigint       not null default 0
);
create index ix_comments_requirement on comments (requirement_id, created_at);

create table example_cards (
    id             uuid primary key,
    requirement_id uuid         not null references requirements (id) on delete cascade,
    kind           varchar(10)  not null check (kind in ('RULE', 'EXAMPLE')),
    rule_id        uuid references example_cards (id) on delete cascade,
    text           varchar(500) not null,
    position       integer      not null,
    converted_to   varchar(40),
    created_at     timestamptz  not null,
    created_by     varchar(32),
    updated_at     timestamptz  not null,
    updated_by     varchar(32),
    version        bigint       not null default 0,
    constraint ck_example_cards_rule check ((kind = 'RULE' and rule_id is null) or (kind = 'EXAMPLE' and rule_id is not null))
);
create index ix_example_cards_requirement on example_cards (requirement_id, position);
