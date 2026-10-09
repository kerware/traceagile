-- Corrections lots 0-2 (ADR-0013) : paramètres déclarés et jeux de données nommés portés par le
-- cas de test (manuel ou automatisé) ; dossiers de tests explicites (dossiers vides possibles).

alter table test_cases
    add column parameters jsonb not null default '[]'::jsonb,
    add column data_sets  jsonb not null default '[]'::jsonb;

-- Reprise de l'ancien jeu de données unique (test manuel ou définition automatisée).
with old as (
    select tc.id, coalesce(tc.manual_data_set, atd.data_set) as rows
    from test_cases tc
             left join automated_test_definitions atd on atd.test_case_id = tc.id
)
update test_cases tc
set data_sets  = jsonb_build_array(jsonb_build_object('name', 'Jeu de données 1', 'rows', old.rows)),
    parameters = (select coalesce(jsonb_agg(jsonb_build_object('name', k.key) order by k.first_seen), '[]'::jsonb)
                  from (select e.key, min(r.ordinality * 1000 + e.ordinality) as first_seen
                        from jsonb_array_elements(old.rows) with ordinality r(row, ordinality),
                             jsonb_each(r.row) with ordinality e(key, value, ordinality)
                        group by e.key) k)
from old
where old.id = tc.id
  and jsonb_typeof(old.rows) = 'array'
  and jsonb_array_length(old.rows) > 0;

alter table test_cases drop column manual_data_set;
alter table automated_test_definitions drop column data_set;

-- ADR-0013 dossiers explicites : chemin « a/b/c » ; les dossiers implicites restent ceux des tests.
create table test_folders (
    id         uuid primary key,
    project_id uuid         not null references projects (id) on delete cascade,
    path       varchar(300) not null,
    created_at timestamptz  not null,
    created_by varchar(32),
    updated_at timestamptz  not null,
    updated_by varchar(32),
    version    bigint       not null default 0,
    constraint uk_test_folders_path unique (project_id, path)
);
