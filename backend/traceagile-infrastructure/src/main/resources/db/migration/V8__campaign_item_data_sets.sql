-- ADR-0018 un test peut figurer plusieurs fois dans une campagne, une fois par ligne de jeu de données.
alter table campaign_items
    add column data_set_name varchar(100),
    add column data_set_row  integer check (data_set_row >= 0);

alter table campaign_items drop constraint uk_campaign_items;

create unique index uk_campaign_items
    on campaign_items (campaign_id, test_case_id, coalesce(lower(data_set_name), ''), coalesce(data_set_row, -1));
