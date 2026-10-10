-- §3.1 ExploratorySession (§5.2, §5.3, ADR-0019) : une session porte une tentative (exécution) d'une charte.
create table exploratory_sessions (
    id              uuid primary key,
    execution_id    uuid        not null unique references executions (id) on delete cascade,
    state           varchar(10) not null check (state in ('RUNNING', 'PAUSED', 'FINISHED', 'DEBRIEFED')),
    timebox_min     integer     not null,
    active_seconds  bigint      not null default 0,
    resumed_at      timestamptz,
    draft           text,
    test_pct        integer check (test_pct between 0 and 100),
    bug_pct         integer check (bug_pct between 0 and 100),
    setup_pct       integer check (setup_pct between 0 and 100),
    areas_covered   jsonb       not null default '[]'::jsonb,
    proof_past      text,
    proof_results   text,
    proof_obstacles text,
    proof_outlook   text,
    proof_feelings  integer check (proof_feelings between 1 and 5),
    debriefed_by    varchar(32),
    debriefed_at    timestamptz,
    approved_by     varchar(32),
    approved_at     timestamptz,
    created_at      timestamptz not null,
    created_by      varchar(32),
    updated_at      timestamptz not null,
    updated_by      varchar(32),
    version         bigint      not null default 0
);
create index ix_exploratory_sessions_state on exploratory_sessions (state);

-- F-EXP-06 notes horodatées (secondes de temps actif depuis le début de la session).
create table session_notes (
    id             uuid primary key,
    session_id     uuid        not null references exploratory_sessions (id) on delete cascade,
    type           varchar(10) not null check (type in ('NOTE', 'QUESTION', 'ISSUE', 'BUG', 'IDEA')),
    offset_seconds bigint      not null,
    text           text        not null,
    noted_at       timestamptz not null,
    defect_id      uuid references defects (id) on delete set null,
    created_at     timestamptz not null,
    created_by     varchar(32),
    updated_at     timestamptz not null,
    updated_by     varchar(32),
    version        bigint      not null default 0
);
create index ix_session_notes_session on session_notes (session_id, offset_seconds);

-- F-EXP-02 heuristiques propres au projet, en plus des heuristiques suggérées.
alter table projects add column custom_heuristics jsonb not null default '[]'::jsonb;
