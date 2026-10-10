-- F-REQ-18 / ADR-0024 valeurs mesurées des ENF (tests de performance ou saisie), comparées au seuil et à la cible.
create table nfr_measurements (
    id             uuid primary key,
    requirement_id uuid             not null references requirements (id) on delete cascade,
    measured_value double precision not null,
    unit           varchar(50),
    metric         varchar(60),
    test_key       varchar(20),
    run_key        varchar(20),
    measured_at    timestamptz      not null,
    outcome        varchar(15)      not null check (outcome in ('TARGET_MET', 'THRESHOLD_MET', 'NOT_MET', 'UNKNOWN')),
    created_at     timestamptz      not null,
    created_by     varchar(32),
    updated_at     timestamptz      not null,
    updated_by     varchar(32),
    version        bigint           not null default 0
);
create index ix_nfr_measurements_requirement on nfr_measurements (requirement_id, measured_at desc);
