-- ADR-0018 un pas manuel peut appeler un autre cas de test (réutilisation) avec des valeurs de paramètres.
alter table manual_steps
    alter column action drop not null,
    add column called_test_case_id uuid references test_cases (id),
    add column call_parameters     jsonb not null default '{}'::jsonb;

create index ix_manual_steps_called on manual_steps (called_test_case_id) where called_test_case_id is not null;

-- Pas déroulé depuis un test appelé : « TC-5 Se connecter » (chaîne d'appels séparée par « › »).
alter table step_results add column called_from text;
