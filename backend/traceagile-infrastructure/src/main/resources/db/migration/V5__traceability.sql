-- Lot 3 - traçabilité (§7, ADR-0014) : alerte de suspicion sur les liens (§3.3-7).
alter table trace_links add column suspect_since timestamptz;
create index if not exists ix_trace_links_project on trace_links (project_id);
