-- Jeu de démonstration SwagLabs de TraceAgile (docs/installation.md) : schéma, migrations Flyway,
-- référentiels, comptes (admin, po, qa1, qa2, dev, viewer ; mot de passe SwagLabs-2026) et projet SWAG.
-- Généré le 2026-10-12 par install/base-de-donnees/generer-demo-swaglabs.sh — PostgreSQL 16 ou plus.
--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: acceptance_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."acceptance_criteria" (
    "id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "position" integer NOT NULL,
    "format" character varying(10) NOT NULL,
    "content" "text" NOT NULL,
    "status" character varying(10) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "acceptance_criteria_format_check" CHECK ((("format")::"text" = ANY ((ARRAY['TEXT'::character varying, 'GHERKIN'::character varying])::"text"[]))),
    CONSTRAINT "acceptance_criteria_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['TO_VERIFY'::character varying, 'VERIFIED'::character varying, 'FAILED'::character varying])::"text"[])))
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."attachments" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "target_type" character varying(20) NOT NULL,
    "target_id" "uuid" NOT NULL,
    "file_name" character varying(200) NOT NULL,
    "content_type" character varying(100) NOT NULL,
    "size" bigint NOT NULL,
    "storage_key" character varying(100) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "attachments_target_type_check" CHECK ((("target_type")::"text" = ANY ((ARRAY['REQUIREMENT'::character varying, 'EXECUTION_STEP'::character varying, 'DEFECT'::character varying, 'SESSION_NOTE'::character varying])::"text"[])))
);


--
-- Name: audit_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."audit_events" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "entity_type" character varying(40) NOT NULL,
    "entity_id" "uuid" NOT NULL,
    "entity_key" character varying(20),
    "action" character varying(30) NOT NULL,
    "diff" "jsonb" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: automated_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."automated_runs" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "run_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "campaign_id" "uuid" NOT NULL,
    "server_id" "uuid" NOT NULL,
    "status" character varying(12) NOT NULL,
    "requested_by" character varying(32),
    "requested_at" timestamp with time zone NOT NULL,
    "dispatched_at" timestamp with time zone,
    "started_at" timestamp with time zone,
    "ended_at" timestamp with time zone,
    "last_event_at" timestamp with time zone,
    "environment" character varying(60),
    "build_version" character varying(60),
    "external_job_id" character varying(100),
    "agent" character varying(100),
    "logs_url" character varying(500),
    "report_url" character varying(500),
    "timeout_minutes" integer NOT NULL,
    "error_code" character varying(60),
    "error_message" character varying(1000),
    "summary_total" integer,
    "summary_passed" integer,
    "summary_failed" integer,
    "summary_error" integer,
    "summary_skipped" integer,
    "rerun_of" character varying(20),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "automated_runs_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['QUEUED'::character varying, 'DISPATCHED'::character varying, 'RUNNING'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying, 'TIMEOUT'::character varying])::"text"[])))
);


--
-- Name: automated_test_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."automated_test_definitions" (
    "id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "technique" character varying(20) NOT NULL,
    "framework" character varying(60) NOT NULL,
    "language" character varying(40),
    "repository_url" character varying(500),
    "branch" character varying(200),
    "path" character varying(500),
    "test_identifier" character varying(500),
    "feature_name" character varying(200),
    "gherkin_source" "text",
    "parameters" "jsonb" NOT NULL,
    "execution_tags" "jsonb" NOT NULL,
    "environment_requirements" "jsonb" NOT NULL,
    "keywords" "jsonb" NOT NULL,
    "missing_in_repository" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "git_project_id" "uuid",
    CONSTRAINT "automated_test_definitions_technique_check" CHECK ((("technique")::"text" = ANY ((ARRAY['BDD'::character varying, 'UNIT'::character varying, 'UI'::character varying, 'API'::character varying, 'KEYWORD'::character varying, 'DATA_DRIVEN'::character varying, 'PERFORMANCE'::character varying, 'CONTRACT'::character varying])::"text"[])))
);


--
-- Name: automation_frameworks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."automation_frameworks" (
    "id" "uuid" NOT NULL,
    "technique" character varying(20) NOT NULL,
    "name" character varying(60) NOT NULL,
    "position" integer NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: campaign_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."campaign_folders" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "path" character varying(300) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: campaign_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."campaign_items" (
    "id" "uuid" NOT NULL,
    "campaign_id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "test_case_version" integer NOT NULL,
    "assignee_id" "uuid",
    "position" integer NOT NULL,
    "risk_score" integer NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "data_set_name" character varying(100),
    "data_set_row" integer,
    CONSTRAINT "campaign_items_data_set_row_check" CHECK (("data_set_row" >= 0))
);


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."campaigns" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "campaign_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "name" character varying(120) NOT NULL,
    "scope_type" character varying(12) NOT NULL,
    "sprint_id" "uuid",
    "release_id" "uuid",
    "environment" character varying(60),
    "build_version" character varying(60),
    "status" character varying(12) NOT NULL,
    "planned_start" "date",
    "planned_end" "date",
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "folder" character varying(300),
    CONSTRAINT "campaigns_scope_type_check" CHECK ((("scope_type")::"text" = ANY ((ARRAY['SPRINT'::character varying, 'RELEASE'::character varying, 'REGRESSION'::character varying])::"text"[]))),
    CONSTRAINT "campaigns_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PLANNED'::character varying, 'IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'ABORTED'::character varying])::"text"[])))
);


--
-- Name: checklist_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."checklist_items" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "kind" character varying(3) NOT NULL,
    "position" integer NOT NULL,
    "label" character varying(200) NOT NULL,
    "rule" character varying(40),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "checklist_items_kind_check" CHECK ((("kind")::"text" = ANY ((ARRAY['DOR'::character varying, 'DOD'::character varying])::"text"[])))
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."comments" (
    "id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "author" character varying(50) NOT NULL,
    "text" "text" NOT NULL,
    "question" boolean DEFAULT false NOT NULL,
    "resolved_at" timestamp with time zone,
    "resolved_by" character varying(50),
    "edited_at" timestamp with time zone,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: defect_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."defect_executions" (
    "defect_id" "uuid" NOT NULL,
    "execution_id" "uuid" NOT NULL
);


--
-- Name: defect_requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."defect_requirements" (
    "defect_id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL
);


--
-- Name: defects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."defects" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "defect_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "title" character varying(200) NOT NULL,
    "description" "text",
    "severity" character varying(10) NOT NULL,
    "status" character varying(12) NOT NULL,
    "external_ref" character varying(100),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "defects_severity_check" CHECK ((("severity")::"text" = ANY ((ARRAY['BLOCKER'::character varying, 'CRITICAL'::character varying, 'MAJOR'::character varying, 'MINOR'::character varying, 'TRIVIAL'::character varying])::"text"[]))),
    CONSTRAINT "defects_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['OPEN'::character varying, 'IN_PROGRESS'::character varying, 'RESOLVED'::character varying, 'CLOSED'::character varying, 'REJECTED'::character varying])::"text"[])))
);


--
-- Name: example_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."example_cards" (
    "id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "kind" character varying(10) NOT NULL,
    "rule_id" "uuid",
    "text" character varying(500) NOT NULL,
    "position" integer NOT NULL,
    "converted_to" character varying(40),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "ck_example_cards_rule" CHECK ((((("kind")::"text" = 'RULE'::"text") AND ("rule_id" IS NULL)) OR ((("kind")::"text" = 'EXAMPLE'::"text") AND ("rule_id" IS NOT NULL)))),
    CONSTRAINT "example_cards_kind_check" CHECK ((("kind")::"text" = ANY ((ARRAY['RULE'::character varying, 'EXAMPLE'::character varying])::"text"[])))
);


--
-- Name: execution_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."execution_servers" (
    "id" "uuid" NOT NULL,
    "name" character varying(100) NOT NULL,
    "base_url" character varying(300) NOT NULL,
    "auth_type" character varying(20) NOT NULL,
    "api_token" "text",
    "webhook_secret" "text",
    "token_id" character varying(100),
    "token_hint" character varying(8),
    "paired_at" timestamp with time zone,
    "status" character varying(15) NOT NULL,
    "last_heartbeat" timestamp with time zone,
    "last_error" character varying(500),
    "server_version" character varying(50),
    "techniques" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "frameworks" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "environments" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "agents" integer DEFAULT 0 NOT NULL,
    "enabled" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "execution_servers_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['UNPAIRED'::character varying, 'UNKNOWN'::character varying, 'ONLINE'::character varying, 'OFFLINE'::character varying, 'UNAUTHORIZED'::character varying])::"text"[])))
);


--
-- Name: executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."executions" (
    "id" "uuid" NOT NULL,
    "campaign_item_id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "attempt" integer NOT NULL,
    "test_case_version" integer NOT NULL,
    "status" character varying(10) NOT NULL,
    "status_overridden" boolean DEFAULT false NOT NULL,
    "started_at" timestamp with time zone NOT NULL,
    "ended_at" timestamp with time zone,
    "duration_ms" bigint,
    "comment" character varying(2000),
    "executed_by" character varying(32),
    "origin" character varying(10) NOT NULL,
    "data_set_name" character varying(100),
    "data_set_row" integer,
    "parameter_values" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "run_id" "uuid",
    CONSTRAINT "executions_origin_check" CHECK ((("origin")::"text" = ANY ((ARRAY['MANUAL'::character varying, 'AUTOMATED'::character varying])::"text"[]))),
    CONSTRAINT "executions_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['NOT_RUN'::character varying, 'RUNNING'::character varying, 'PASSED'::character varying, 'FAILED'::character varying, 'BLOCKED'::character varying, 'SKIPPED'::character varying, 'ERROR'::character varying])::"text"[])))
);


--
-- Name: exploratory_charters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."exploratory_charters" (
    "id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "mission_explore" character varying(500),
    "mission_with" character varying(500),
    "mission_to_discover" character varying(500),
    "areas" "jsonb" NOT NULL,
    "heuristics" "jsonb" NOT NULL,
    "timebox_min" integer NOT NULL,
    "setup_notes" "text",
    "targeted_risk" character varying(500),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "exploratory_charters_timebox_min_check" CHECK (("timebox_min" = ANY (ARRAY[60, 90, 120])))
);


--
-- Name: exploratory_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."exploratory_sessions" (
    "id" "uuid" NOT NULL,
    "execution_id" "uuid" NOT NULL,
    "state" character varying(10) NOT NULL,
    "timebox_min" integer NOT NULL,
    "active_seconds" bigint DEFAULT 0 NOT NULL,
    "resumed_at" timestamp with time zone,
    "draft" "text",
    "test_pct" integer,
    "bug_pct" integer,
    "setup_pct" integer,
    "areas_covered" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "proof_past" "text",
    "proof_results" "text",
    "proof_obstacles" "text",
    "proof_outlook" "text",
    "proof_feelings" integer,
    "debriefed_by" character varying(32),
    "debriefed_at" timestamp with time zone,
    "approved_by" character varying(32),
    "approved_at" timestamp with time zone,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "exploratory_sessions_bug_pct_check" CHECK ((("bug_pct" >= 0) AND ("bug_pct" <= 100))),
    CONSTRAINT "exploratory_sessions_proof_feelings_check" CHECK ((("proof_feelings" >= 1) AND ("proof_feelings" <= 5))),
    CONSTRAINT "exploratory_sessions_setup_pct_check" CHECK ((("setup_pct" >= 0) AND ("setup_pct" <= 100))),
    CONSTRAINT "exploratory_sessions_state_check" CHECK ((("state")::"text" = ANY ((ARRAY['RUNNING'::character varying, 'PAUSED'::character varying, 'FINISHED'::character varying, 'DEBRIEFED'::character varying])::"text"[]))),
    CONSTRAINT "exploratory_sessions_test_pct_check" CHECK ((("test_pct" >= 0) AND ("test_pct" <= 100)))
);


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."flyway_schema_history" (
    "installed_rank" integer NOT NULL,
    "version" character varying(50),
    "description" character varying(200) NOT NULL,
    "type" character varying(20) NOT NULL,
    "script" character varying(1000) NOT NULL,
    "checksum" integer,
    "installed_by" character varying(100) NOT NULL,
    "installed_on" timestamp without time zone DEFAULT "now"() NOT NULL,
    "execution_time" integer NOT NULL,
    "success" boolean NOT NULL
);


--
-- Name: git_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."git_projects" (
    "id" "uuid" NOT NULL,
    "source_id" "uuid" NOT NULL,
    "name" character varying(200) NOT NULL,
    "default_branch" character varying(200),
    "description" character varying(500),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: git_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."git_sources" (
    "id" "uuid" NOT NULL,
    "name" character varying(100) NOT NULL,
    "base_url" character varying(300) NOT NULL,
    "auth_type" character varying(10) NOT NULL,
    "username" character varying(100),
    "secret" "text",
    "description" character varying(500),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "git_sources_auth_type_check" CHECK ((("auth_type")::"text" = ANY ((ARRAY['NONE'::character varying, 'TOKEN'::character varying, 'SSH_KEY'::character varying])::"text"[])))
);


--
-- Name: key_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."key_sequences" (
    "project_id" "uuid" NOT NULL,
    "prefix" character varying(10) NOT NULL,
    "next_value" integer NOT NULL
);


--
-- Name: manual_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."manual_steps" (
    "id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "position" integer NOT NULL,
    "action" "text",
    "expected_result" "text",
    "test_data" "text",
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "called_test_case_id" "uuid",
    "call_parameters" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "call_data_set" "text",
    "call_data_row" "text"
);


--
-- Name: nfr_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."nfr_measurements" (
    "id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "measured_value" double precision NOT NULL,
    "unit" character varying(50),
    "metric" character varying(60),
    "test_key" character varying(20),
    "run_key" character varying(20),
    "measured_at" timestamp with time zone NOT NULL,
    "outcome" character varying(15) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "nfr_measurements_outcome_check" CHECK ((("outcome")::"text" = ANY ((ARRAY['TARGET_MET'::character varying, 'THRESHOLD_MET'::character varying, 'NOT_MET'::character varying, 'UNKNOWN'::character varying])::"text"[])))
);


--
-- Name: processed_webhook_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."processed_webhook_events" (
    "event_id" character varying(100) NOT NULL,
    "run_id" "uuid" NOT NULL,
    "received_at" timestamp with time zone NOT NULL
);


--
-- Name: project_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."project_members" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" character varying(20) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "ck_project_members_role" CHECK ((("role")::"text" = ANY ((ARRAY['ADMINISTRATOR'::character varying, 'PRODUCT_OWNER'::character varying, 'TESTER'::character varying, 'DEVELOPER'::character varying, 'VIEWER'::character varying])::"text"[])))
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."projects" (
    "id" "uuid" NOT NULL,
    "project_key" character varying(10) NOT NULL,
    "name" character varying(200) NOT NULL,
    "description" "text",
    "archived" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "custom_heuristics" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "verdict_rules" "jsonb",
    CONSTRAINT "ck_projects_key" CHECK ((("project_key")::"text" ~ '^[A-Z]{3,10}$'::"text"))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."refresh_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_hash" character varying(64) NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "revoked" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."releases" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "release_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "name" character varying(120) NOT NULL,
    "goal" character varying(1000),
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "status" character varying(10) NOT NULL,
    "closed_at" timestamp with time zone,
    "closing_report" "jsonb",
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "releases_check" CHECK (("end_date" >= "start_date")),
    CONSTRAINT "releases_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PLANNED'::character varying, 'ACTIVE'::character varying, 'CLOSED'::character varying])::"text"[])))
);


--
-- Name: report_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."report_definitions" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "name" character varying(120) NOT NULL,
    "description" "text",
    "scope_type" character varying(12) NOT NULL,
    "sections" "jsonb" NOT NULL,
    "default_format" character varying(12) NOT NULL,
    "include_charts" boolean DEFAULT true NOT NULL,
    "include_details" boolean DEFAULT false NOT NULL,
    "built_in" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "report_definitions_default_format_check" CHECK ((("default_format")::"text" = ANY ((ARRAY['HTML'::character varying, 'PDF'::character varying, 'DOCX'::character varying, 'XLSX'::character varying, 'MARKDOWN'::character varying, 'CSV'::character varying, 'JSON'::character varying])::"text"[]))),
    CONSTRAINT "report_definitions_scope_type_check" CHECK ((("scope_type")::"text" = ANY ((ARRAY['SPRINT'::character varying, 'RELEASE'::character varying, 'PROJECT'::character varying])::"text"[])))
);


--
-- Name: report_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."report_snapshots" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "report_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "title" character varying(200) NOT NULL,
    "definition_name" character varying(120) NOT NULL,
    "scope_type" character varying(12) NOT NULL,
    "scope" character varying(40) NOT NULL,
    "scope_label" character varying(200) NOT NULL,
    "sections" "jsonb" NOT NULL,
    "include_charts" boolean NOT NULL,
    "include_details" boolean NOT NULL,
    "data" "jsonb" NOT NULL,
    "computed_verdict" character varying(24),
    "verdict_override" character varying(24),
    "verdict_comment" "text",
    "verdict_by" character varying(50),
    "verdict_at" timestamp with time zone,
    "frozen" boolean DEFAULT false NOT NULL,
    "frozen_at" timestamp with time zone,
    "frozen_by" character varying(50),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "report_snapshots_computed_verdict_check" CHECK ((("computed_verdict")::"text" = ANY ((ARRAY['GO'::character varying, 'GO_WITH_RESERVATIONS'::character varying, 'NO_GO'::character varying])::"text"[]))),
    CONSTRAINT "report_snapshots_scope_type_check" CHECK ((("scope_type")::"text" = ANY ((ARRAY['SPRINT'::character varying, 'RELEASE'::character varying, 'PROJECT'::character varying])::"text"[]))),
    CONSTRAINT "report_snapshots_verdict_override_check" CHECK ((("verdict_override")::"text" = ANY ((ARRAY['GO'::character varying, 'GO_WITH_RESERVATIONS'::character varying, 'NO_GO'::character varying])::"text"[])))
);


--
-- Name: requirement_checklist_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."requirement_checklist_checks" (
    "requirement_id" "uuid" NOT NULL,
    "checklist_item_id" "uuid" NOT NULL
);


--
-- Name: requirement_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."requirement_tags" (
    "requirement_id" "uuid" NOT NULL,
    "tag" character varying(50) NOT NULL
);


--
-- Name: requirement_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."requirement_versions" (
    "id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "version_number" integer NOT NULL,
    "snapshot" "jsonb" NOT NULL,
    "change_comment" character varying(500),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."requirements" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "requirement_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "type" character varying(20) NOT NULL,
    "title" character varying(200) NOT NULL,
    "description" "text",
    "story_as_a" character varying(500),
    "story_i_want" character varying(2000),
    "story_so_that" character varying(2000),
    "priority" character varying(10) NOT NULL,
    "business_value" integer,
    "story_points" integer,
    "status" character varying(20) NOT NULL,
    "risk_level" character varying(10) NOT NULL,
    "category" character varying(20),
    "nfr_scale" character varying(500),
    "nfr_measurement_method" character varying(500),
    "nfr_minimum_threshold" character varying(100),
    "nfr_target" character varying(100),
    "nfr_unit" character varying(50),
    "transverse" boolean DEFAULT false NOT NULL,
    "external_ref" character varying(100),
    "current_version" integer DEFAULT 0 NOT NULL,
    "parent_id" "uuid",
    "rank" character varying(255) NOT NULL COLLATE "pg_catalog"."C",
    "invest_independent" boolean DEFAULT false NOT NULL,
    "invest_negotiable" boolean DEFAULT false NOT NULL,
    "invest_valuable" boolean DEFAULT false NOT NULL,
    "invest_estimable" boolean DEFAULT false NOT NULL,
    "invest_small" boolean DEFAULT false NOT NULL,
    "invest_testable" boolean DEFAULT false NOT NULL,
    "search_text" "text" DEFAULT ''::"text" NOT NULL,
    "search_vector" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"french"'::"regconfig", "search_text")) STORED,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "ck_requirements_status" CHECK ((("status")::"text" = ANY ((ARRAY['DRAFT'::character varying, 'TO_REFINE'::character varying, 'READY'::character varying, 'IN_SPRINT'::character varying, 'DONE'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'OBSOLETE'::character varying])::"text"[]))),
    CONSTRAINT "ck_requirements_type" CHECK ((("type")::"text" = ANY ((ARRAY['EPIC'::character varying, 'FEATURE'::character varying, 'USER_STORY'::character varying, 'BUSINESS_RULE'::character varying, 'NON_FUNCTIONAL'::character varying, 'TECHNICAL_ENABLER'::character varying])::"text"[]))),
    CONSTRAINT "requirements_business_value_check" CHECK ((("business_value" >= 1) AND ("business_value" <= 100))),
    CONSTRAINT "requirements_story_points_check" CHECK (("story_points" = ANY (ARRAY[1, 2, 3, 5, 8, 13, 21])))
);


--
-- Name: run_artifacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."run_artifacts" (
    "id" "uuid" NOT NULL,
    "run_id" "uuid" NOT NULL,
    "execution_id" "uuid",
    "name" character varying(200) NOT NULL,
    "content_type" character varying(100) NOT NULL,
    "kind" character varying(15) NOT NULL,
    "size" bigint,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "run_artifacts_kind_check" CHECK ((("kind")::"text" = ANY ((ARRAY['SYSTEM_TRACE'::character varying, 'JUNIT'::character varying, 'JEST'::character varying, 'REPORT'::character varying, 'SCREENSHOT'::character varying, 'OTHER'::character varying])::"text"[])))
);


--
-- Name: session_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."session_notes" (
    "id" "uuid" NOT NULL,
    "session_id" "uuid" NOT NULL,
    "type" character varying(10) NOT NULL,
    "offset_seconds" bigint NOT NULL,
    "text" "text" NOT NULL,
    "noted_at" timestamp with time zone NOT NULL,
    "defect_id" "uuid",
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "session_notes_type_check" CHECK ((("type")::"text" = ANY ((ARRAY['NOTE'::character varying, 'QUESTION'::character varying, 'ISSUE'::character varying, 'BUG'::character varying, 'IDEA'::character varying])::"text"[])))
);


--
-- Name: sprint_scope; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."sprint_scope" (
    "id" "uuid" NOT NULL,
    "sprint_id" "uuid" NOT NULL,
    "requirement_id" "uuid" NOT NULL,
    "position" integer NOT NULL,
    "committed_points" integer,
    "outcome" character varying(15) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "sprint_scope_outcome_check" CHECK ((("outcome")::"text" = ANY ((ARRAY['PLANNED'::character varying, 'DONE'::character varying, 'RETURNED'::character varying, 'CARRIED_OVER'::character varying, 'DROPPED'::character varying])::"text"[])))
);


--
-- Name: sprints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."sprints" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "release_id" "uuid",
    "sprint_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "name" character varying(120) NOT NULL,
    "goal" character varying(1000),
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "capacity_points" integer,
    "status" character varying(10) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    CONSTRAINT "sprints_capacity_points_check" CHECK ((("capacity_points" >= 0) AND ("capacity_points" <= 1000))),
    CONSTRAINT "sprints_check" CHECK (("end_date" >= "start_date")),
    CONSTRAINT "sprints_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PLANNED'::character varying, 'ACTIVE'::character varying, 'CLOSED'::character varying])::"text"[])))
);


--
-- Name: step_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."step_results" (
    "id" "uuid" NOT NULL,
    "execution_id" "uuid" NOT NULL,
    "position" integer NOT NULL,
    "action" "text" NOT NULL,
    "expected_result" "text",
    "test_data" "text",
    "status" character varying(10) NOT NULL,
    "actual_result" "text",
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "called_from" "text",
    CONSTRAINT "step_results_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['NOT_RUN'::character varying, 'PASSED'::character varying, 'FAILED'::character varying, 'BLOCKED'::character varying, 'SKIPPED'::character varying])::"text"[])))
);


--
-- Name: test_case_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."test_case_tags" (
    "test_case_id" "uuid" NOT NULL,
    "tag" character varying(50) NOT NULL
);


--
-- Name: test_case_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."test_case_versions" (
    "id" "uuid" NOT NULL,
    "test_case_id" "uuid" NOT NULL,
    "version_number" integer NOT NULL,
    "snapshot" "jsonb" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: test_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."test_cases" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "test_key" character varying(20) NOT NULL,
    "key_number" integer NOT NULL,
    "kind" character varying(12) NOT NULL,
    "title" character varying(200) NOT NULL,
    "description" "text",
    "objective" "text",
    "priority" character varying(10) NOT NULL,
    "status" character varying(15) NOT NULL,
    "estimated_duration_min" integer,
    "folder" character varying(300),
    "current_version" integer DEFAULT 1 NOT NULL,
    "automation_candidate" boolean DEFAULT false NOT NULL,
    "automation_justification" character varying(1000),
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "parameters" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "data_sets" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "flaky" boolean DEFAULT false NOT NULL,
    CONSTRAINT "test_cases_estimated_duration_min_check" CHECK ((("estimated_duration_min" >= 1) AND ("estimated_duration_min" <= 10000))),
    CONSTRAINT "test_cases_kind_check" CHECK ((("kind")::"text" = ANY ((ARRAY['MANUAL'::character varying, 'EXPLORATORY'::character varying, 'AUTOMATED'::character varying])::"text"[]))),
    CONSTRAINT "test_cases_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['DRAFT'::character varying, 'READY'::character varying, 'NEEDS_UPDATE'::character varying, 'OBSOLETE'::character varying])::"text"[])))
);


--
-- Name: test_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."test_folders" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "path" character varying(300) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Name: trace_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."trace_links" (
    "id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "source_type" character varying(25) NOT NULL,
    "source_id" "uuid" NOT NULL,
    "target_type" character varying(25) NOT NULL,
    "target_id" "uuid" NOT NULL,
    "link_type" character varying(20) NOT NULL,
    "origin" character varying(15) NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL,
    "suspect_since" timestamp with time zone,
    CONSTRAINT "trace_links_link_type_check" CHECK ((("link_type")::"text" = ANY ((ARRAY['VERIFIES'::character varying, 'PARTIALLY_VERIFIES'::character varying, 'RELATES_TO'::character varying])::"text"[])))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."users" (
    "id" "uuid" NOT NULL,
    "login" character varying(32) NOT NULL,
    "email" character varying(254) NOT NULL,
    "display_name" character varying(100) NOT NULL,
    "password_hash" character varying(100) NOT NULL,
    "active" boolean DEFAULT true NOT NULL,
    "system_admin" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "created_by" character varying(32),
    "updated_at" timestamp with time zone NOT NULL,
    "updated_by" character varying(32),
    "version" bigint DEFAULT 0 NOT NULL
);


--
-- Data for Name: acceptance_criteria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."acceptance_criteria" ("id", "requirement_id", "position", "format", "content", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
71b2e9aa-9d0e-4470-b68b-6806d4daa191	10b55aac-a552-4e2b-85ba-9030d82fe533	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 14:38:56.124731+00	po	2026-10-12 14:38:56.124731+00	po	0
b1e789ee-e041-44e5-abdf-ebacf504c55e	10b55aac-a552-4e2b-85ba-9030d82fe533	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 14:38:56.124731+00	po	2026-10-12 14:38:56.124731+00	po	0
66f354da-5109-4d46-8f29-e654eb75e35f	10cf0f35-ed81-42c0-84d5-33c562347c84	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 14:38:56.165534+00	po	2026-10-12 14:38:56.165534+00	po	0
46efdb3c-c42d-4b94-9584-41eff4095753	3e946069-8458-45e5-a52f-09eb5996e23c	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 14:38:56.235808+00	po	2026-10-12 14:38:56.235808+00	po	0
7986e535-fe29-4fa8-b7fd-a56aba0e1c5b	86bb0385-5bbd-413c-8a9a-dae851fee51a	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 14:38:56.273584+00	po	2026-10-12 14:38:56.273584+00	po	0
594ef704-fdb6-4b01-bdc9-f1527fb14b04	9633fdd3-bdce-4766-8796-4e2118c70ab9	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 14:38:56.314347+00	po	2026-10-12 14:38:56.314347+00	po	0
3f686dd5-343a-4f10-8fc6-1b754f7f18ed	433b4394-434f-4058-b654-f3b14e814e6c	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 14:38:56.382599+00	po	2026-10-12 14:38:56.382599+00	po	0
81896148-3922-45ce-b57c-dcfb19c88272	433b4394-434f-4058-b654-f3b14e814e6c	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 14:38:56.382599+00	po	2026-10-12 14:38:56.382599+00	po	0
22d2d57c-8b42-40ba-a5bd-c0706da2683c	7c982acd-5066-45e4-b6c1-2077ff3876ca	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 14:38:56.416784+00	po	2026-10-12 14:38:56.416784+00	po	0
517a6149-4a48-4509-be07-4d5722bd3b95	7c982acd-5066-45e4-b6c1-2077ff3876ca	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 14:38:56.416784+00	po	2026-10-12 14:38:56.416784+00	po	0
2f529413-684c-4141-9e5c-7029acaa784c	e9fca955-cac1-4ef7-87de-afa4fa38da8b	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 14:38:56.450101+00	po	2026-10-12 14:38:56.450101+00	po	0
1a8e7759-a285-4119-88a3-bdc78a7fc7b1	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 14:38:56.518244+00	po	2026-10-12 14:38:56.518244+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
df86b07a-ea75-4e8e-8832-d9e521a05490	cd2efab4-a355-40ff-9847-bf10d8f16c53	EXECUTION_STEP	417bd7bb-4308-405b-b154-dd0ab449b0bc	sd-defaut-problem-user.png	image/png	235120	521f1270-5587-4c5f-9485-63e40d8cd41a	2026-10-12 14:40:47.506708+00	qa2	2026-10-12 14:40:47.506708+00	qa2	0
7510a119-144b-4dee-ad2e-d04de4276969	cd2efab4-a355-40ff-9847-bf10d8f16c53	DEFECT	5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	sd-defaut-problem-user.png	image/png	235120	521f1270-5587-4c5f-9485-63e40d8cd41a	2026-10-12 14:40:49.050248+00	qa2	2026-10-12 14:40:49.050248+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
96df34c7-41e5-4e57-82cf-5e453210b7f6	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:56.003228+00	po	2026-10-12 14:38:56.003228+00	po	0
b6a7d08d-dadf-43ad-9584-90f5d17e99a0	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9f5930be-6492-4981-86f2-4824df02afaa	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:56.070958+00	po	2026-10-12 14:38:56.070958+00	po	0
2f42aafe-7b3f-4943-99bf-c581987ebde6	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.124731+00	po	2026-10-12 14:38:56.124731+00	po	0
f96dd946-75f5-487e-aa80-fdcb7409da82	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.165534+00	po	2026-10-12 14:38:56.165534+00	po	0
ab96369a-2569-497f-bf90-562257579ec1	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	1de832fe-63ec-4ec4-868e-47649110193f	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:56.200377+00	po	2026-10-12 14:38:56.200377+00	po	0
3e8b8da4-2f30-4f03-92b0-7cdb321dbca4	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.236382+00	po	2026-10-12 14:38:56.236382+00	po	0
a148fd90-f964-49e6-9393-8f497bdba2fc	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	86bb0385-5bbd-413c-8a9a-dae851fee51a	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.273584+00	po	2026-10-12 14:38:56.273584+00	po	0
7ac61561-34d1-4b31-a625-d1a2354c57d7	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	c39b3007-d713-4b4c-8b21-b23b29ba9b86	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 14:39:18.350988+00	qa1	2026-10-12 14:39:18.350988+00	qa1	0
aa7a07fc-4fbe-44b3-a82e-ebcd9d3413f0	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.314347+00	po	2026-10-12 14:38:56.314347+00	po	0
2ff4d464-0056-4350-a028-5329e97740a9	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	f1a7483d-d168-4816-a9b9-22ec72f2cc2b	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:56.347537+00	po	2026-10-12 14:38:56.347537+00	po	0
49fddafd-2f4f-462d-aae9-5a6f5ec21f48	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.450101+00	po	2026-10-12 14:38:56.450101+00	po	0
99b47a84-680d-47ea-a81c-2dc6ccabe8b1	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	ae0e99af-7408-4f9e-bdd9-b86b0e9b3c1f	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:56.48392+00	po	2026-10-12 14:38:56.48392+00	po	0
c325b3d3-6d50-4a90-ac9d-ab1548793cb7	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.518751+00	po	2026-10-12 14:38:56.518751+00	po	0
e3cabaf1-a770-432e-b301-90f5ee0971d4	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	c27c5eb1-83f6-4a15-98e8-47e923801445	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:58.197524+00	po	2026-10-12 14:38:58.197524+00	po	0
a7c56a5e-832d-4c7f-b24d-b47d81f192d8	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	c45b3d45-beb6-4b4e-a1ab-aeba3fd92fa1	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:58.441665+00	po	2026-10-12 14:38:58.441665+00	po	0
3b717c1f-c3ec-4b12-90ce-387e189cb4c8	cd2efab4-a355-40ff-9847-bf10d8f16c53	SESSION	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 14:40:51.590134+00	qa1	2026-10-12 14:40:51.590134+00	qa1	0
efa816b3-9436-4e7b-9f20-475fc3cc8499	cd2efab4-a355-40ff-9847-bf10d8f16c53	SESSION	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 14:40:54.144384+00	qa1	2026-10-12 14:40:54.144384+00	qa1	0
7a1ff88a-23fa-45e0-b3e6-5b83cecd401d	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	433b4394-434f-4058-b654-f3b14e814e6c	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.383113+00	po	2026-10-12 14:38:56.383113+00	po	0
8a04c60e-f857-4c85-bc76-5eece54a5f37	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 14:38:56.416784+00	po	2026-10-12 14:38:56.416784+00	po	0
17d9a90a-1d99-469e-9e8b-99d197c07ec7	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.308411+00	po	2026-10-12 14:38:59.308411+00	po	0
93c05a58-1555-434d-a138-4fd9d5eee7fa	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d6d77d95-1345-4dec-acf8-922ceee859ef	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:06.554415+00	qa1	2026-10-12 14:39:06.554415+00	qa1	0
c2ca168e-0e39-4de8-9044-7f54f7ff424b	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	a0139051-c18a-4cb5-85aa-531106f97cc1	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:06.725995+00	qa1	2026-10-12 14:39:06.725995+00	qa1	0
3156b2c2-b8c9-4d99-9971-78173cbd68e4	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0056a059-4846-49cc-8a3f-d509ba64f50b	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:07.045838+00	qa1	2026-10-12 14:39:07.045838+00	qa1	0
b17d069c-b1dd-4b19-8c19-7b5abf597966	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	12239701-7612-4137-b83a-b93193537887	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.445309+00	qa1	2026-10-12 14:39:09.445309+00	qa1	0
fb5e4f86-c696-49a0-939c-8737f7f0dd6f	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 14:39:09.62846+00	qa1	2026-10-12 14:39:09.62846+00	qa1	0
58a16b03-ba1a-4a9e-b7fc-693531f8d186	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 14:39:15.222641+00	po	2026-10-12 14:39:15.222641+00	po	0
844ba5fa-2e3b-4381-9d2f-30cf8a3f998d	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:39:16.813738+00	po	2026-10-12 14:39:16.813738+00	po	0
38b2bfe8-2903-4e11-9810-59035f3b65b2	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:39:16.814415+00	po	2026-10-12 14:39:16.814415+00	po	0
f93e9553-a305-4454-9e0a-d65f36133cd0	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:39:16.814415+00	po	2026-10-12 14:39:16.814415+00	po	0
0ec920ac-6290-4426-b05c-c911ad5db5c3	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	86bb0385-5bbd-413c-8a9a-dae851fee51a	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:39:16.815045+00	po	2026-10-12 14:39:16.815045+00	po	0
ef65f86b-5ebb-4ff4-abc3-d83bd2d51935	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:39:16.815045+00	po	2026-10-12 14:39:16.815045+00	po	0
b90e0dd1-f157-4946-909e-c9b98e2b45cf	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 14:39:16.815045+00	po	2026-10-12 14:39:16.815045+00	po	0
9d3d886f-3480-4c57-8feb-eb26d9a75625	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	c39b3007-d713-4b4c-8b21-b23b29ba9b86	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 14:39:18.01411+00	qa1	2026-10-12 14:39:18.01411+00	qa1	0
a38735cd-83d6-4102-9a3b-e50495e89dc8	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	0952fcae-a38e-40cc-b7da-8a6b02c2d361	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 14:38:58.470539+00	po	2026-10-12 14:38:58.470539+00	po	0
172f7201-90ed-40ee-be17-bd6ffdef67ba	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.264272+00	po	2026-10-12 14:38:59.264272+00	po	0
d1628049-756e-4734-80d5-6e9c40ef2c9d	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.346508+00	po	2026-10-12 14:38:59.346508+00	po	0
f5944775-8343-49b2-9749-4802a2e79c31	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	86bb0385-5bbd-413c-8a9a-dae851fee51a	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.386061+00	po	2026-10-12 14:38:59.386061+00	po	0
0efdcbd6-b001-4200-822a-e112c16b03aa	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.427857+00	po	2026-10-12 14:38:59.427857+00	po	0
31ed690b-a1ae-45f4-b95c-7de56bee3b90	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	433b4394-434f-4058-b654-f3b14e814e6c	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.472535+00	po	2026-10-12 14:38:59.472535+00	po	0
6cae67b9-2a43-450b-9890-1795db3e6558	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:38:59.52033+00	po	2026-10-12 14:38:59.52033+00	po	0
f95dc8ed-5e1d-4c6e-8b84-b3675c866914	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:00.462043+00	po	2026-10-12 14:39:00.462043+00	po	0
81a1fc34-f0c8-4568-8939-1e94d05611fb	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d6d77d95-1345-4dec-acf8-922ceee859ef	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 14:39:06.492033+00	qa1	2026-10-12 14:39:06.492033+00	qa1	0
89ea37c1-a507-4665-8055-210804075d3c	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	71497a83-6128-4475-b66c-47a4fa5e254a	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 14:39:06.595063+00	qa1	2026-10-12 14:39:06.595063+00	qa1	0
7d610862-0ceb-42ba-99fa-17da6b7e5149	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	71497a83-6128-4475-b66c-47a4fa5e254a	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:06.637243+00	qa1	2026-10-12 14:39:06.637243+00	qa1	0
20501764-d903-4d59-9c9a-3cca215ed796	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	a0139051-c18a-4cb5-85aa-531106f97cc1	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 14:39:06.687857+00	dev	2026-10-12 14:39:06.687857+00	dev	0
9a58a5d2-62e5-4a06-b5b2-ae9a11e7b664	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d706d841-3a3a-46cf-8e38-6c796482f370	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:06.804364+00	qa1	2026-10-12 14:39:06.804364+00	qa1	0
fbfbe6c7-50f9-4614-8787-74190e97597a	cd2efab4-a355-40ff-9847-bf10d8f16c53	RUN	d451f4f5-d80f-45a0-8390-9881de9065d3	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 14:40:56.692286+00	dev	2026-10-12 14:40:56.692286+00	dev	0
c412a8cc-2fc9-472e-88c5-f7b1aee2ba56	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d706d841-3a3a-46cf-8e38-6c796482f370	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 14:39:06.76351+00	dev	2026-10-12 14:39:06.76351+00	dev	0
aecd5556-5a0a-4987-ba24-840664217490	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0056a059-4846-49cc-8a3f-d509ba64f50b	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 14:39:07.000976+00	dev	2026-10-12 14:39:07.000976+00	dev	0
84dc28f8-26a5-4ad3-88f5-ce1d1750a2b1	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0b4decbf-519b-4401-a935-59c2a44afff9	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 14:39:07.074925+00	dev	2026-10-12 14:39:07.074925+00	dev	0
d23c1e4f-d3e0-4d6b-82e1-46f16657f510	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	64b43d67-5e84-4c3c-ab29-ae070db37256	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:08.414779+00	qa1	2026-10-12 14:39:08.414779+00	qa1	0
1807e7c6-3628-4248-afb6-a93d39e9438d	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	64b43d67-5e84-4c3c-ab29-ae070db37256	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 14:39:08.453791+00	qa1	2026-10-12 14:39:08.453791+00	qa1	0
385b1587-ad50-432e-a3df-f5e940f08a05	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	563f6b55-cf8b-48ad-b46a-a5866feb4f82	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 14:39:09.486254+00	dev	2026-10-12 14:39:09.486254+00	dev	0
ef07a413-e64b-4e82-abc7-e5262887b3c8	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	563f6b55-cf8b-48ad-b46a-a5866feb4f82	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.523201+00	qa1	2026-10-12 14:39:09.523201+00	qa1	0
63bd6a5d-9dbe-4a5d-ae9c-36fafa68831e	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.673357+00	qa1	2026-10-12 14:39:09.673357+00	qa1	0
939cc36c-6a28-4c32-9c37-8d4ab7116e3c	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	47af8bdc-0dcb-4745-a8c5-d379caae99e2	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 14:39:15.271663+00	po	2026-10-12 14:39:15.271663+00	po	0
af8a8bc3-dd9c-487d-bd23-1e7997a4bd11	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 14:39:15.965198+00	po	2026-10-12 14:39:15.965198+00	po	0
62d64d25-1dc2-4758-a01c-de783b4c0c99	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 14:39:16.125835+00	po	2026-10-12 14:39:16.125835+00	po	0
a4993d28-dde1-4851-be1a-40871ea3e7e2	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	c39b3007-d713-4b4c-8b21-b23b29ba9b86	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"]}]	2026-10-12 14:39:18.574424+00	qa1	2026-10-12 14:39:18.574424+00	qa1	0
1100dc4c-4b59-4b95-b34f-914749f85fe1	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	ef6242e0-f26d-4635-b90c-cb1b0425b578	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 14:39:06.848079+00	dev	2026-10-12 14:39:06.848079+00	dev	0
3bbfe115-e68a-4410-9142-17f2f7485d51	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	ef6242e0-f26d-4635-b90c-cb1b0425b578	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:06.958342+00	qa1	2026-10-12 14:39:06.958342+00	qa1	0
6245fe34-660f-49a7-a6be-d5ea4be7de2e	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0b4decbf-519b-4401-a935-59c2a44afff9	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:07.102036+00	qa1	2026-10-12 14:39:07.102036+00	qa1	0
89a546c7-7019-4f40-ad75-a44d622a0fe7	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	64b43d67-5e84-4c3c-ab29-ae070db37256	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 14:39:08.335535+00	qa1	2026-10-12 14:39:08.335535+00	qa1	0
f42e4262-ca7a-4507-b96e-e05f4a7da835	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	83906e72-3061-420e-acbd-5d07f689899d	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.37914+00	qa1	2026-10-12 14:39:09.37914+00	qa1	0
b88bfdc9-f73e-4f34-9bd1-f0714de6f576	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	12239701-7612-4137-b83a-b93193537887	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 14:39:09.408123+00	dev	2026-10-12 14:39:09.408123+00	dev	0
1599591e-b503-4510-9bc9-6ba3ed8fdcc2	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	379e9e17-562f-4e76-97eb-b6a323bfbf8d	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 14:39:09.554759+00	qa1	2026-10-12 14:39:09.554759+00	qa1	0
2ba4c7e3-dcc5-4ad5-8653-5e6b58e35336	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	379e9e17-562f-4e76-97eb-b6a323bfbf8d	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.592623+00	qa1	2026-10-12 14:39:09.592623+00	qa1	0
a85f44a3-ade6-4faa-b7fe-76ac13a498a2	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	226f66ce-ea72-409e-b909-b17942c5c8cb	TC-14	CREATED	[{"after": "TC-14", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : noms et prix (Playwright Java)", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "JUnit 5", "field": "framework", "before": null}, {"after": "Java", "field": "language", "before": null}, {"after": "https://github.com/kerware/saucedemo-e2e", "field": "repositoryUrl", "before": null}, {"after": "master", "field": "branch", "before": null}, {"after": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "field": "path", "before": null}, {"after": "InventaireCatalogueTest#catalogueAffiche", "field": "testIdentifier", "before": null}, {"after": "kerware, smoke", "field": "executionTags", "before": null}]	2026-10-12 14:39:09.705732+00	dev	2026-10-12 14:39:09.705732+00	dev	0
2b26e5eb-b3f9-43a0-b34b-bf533b683eeb	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	226f66ce-ea72-409e-b909-b17942c5c8cb	TC-14	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 14:39:09.731497+00	qa1	2026-10-12 14:39:09.731497+00	qa1	0
475b1a7e-7fe5-464a-aeb5-1129d31e60f1	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 14:39:16.258639+00	po	2026-10-12 14:39:16.258639+00	po	0
75ee4350-c0bd-40cd-9266-9972cb07cfe3	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	83906e72-3061-420e-acbd-5d07f689899d	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 14:39:09.350542+00	dev	2026-10-12 14:39:09.350542+00	dev	0
ceac56d4-3934-448f-8ac0-3f18a6663ad6	cd2efab4-a355-40ff-9847-bf10d8f16c53	RELEASE	572b5b72-07e1-4b13-a256-7359be352088	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 14:39:15.187906+00	po	2026-10-12 14:39:15.187906+00	po	0
7714f5b6-43e3-4ef9-9745-e3d9626a4ab5	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 14:39:16.031608+00	po	2026-10-12 14:39:16.031608+00	po	0
19d4d404-9abd-478a-90cf-d52dc714ec88	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 14:39:16.187115+00	po	2026-10-12 14:39:16.187115+00	po	0
0ca82aa9-9eb7-484f-a1d6-1ce29632ce82	cd2efab4-a355-40ff-9847-bf10d8f16c53	RUN	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:39:21.768245+00	dev	0
9c00dc2b-14e3-4464-9595-a21dfb7f2972	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	c39b3007-d713-4b4c-8b21-b23b29ba9b86	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 14:40:41.526838+00	qa1	2026-10-12 14:40:41.526838+00	qa1	0
7ecf8732-ee66-4d8d-9b7f-9edd53a41557	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 14:40:41.595292+00	po	2026-10-12 14:40:41.595292+00	po	0
2bce62d8-122c-4381-811a-9ee08e4fa1e0	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 14:40:41.631933+00	po	2026-10-12 14:40:41.631933+00	po	0
08bd48a3-2681-4587-ad25-9d7af25a4bd6	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 14:40:41.671156+00	po	2026-10-12 14:40:41.671156+00	po	0
4a8b74e0-ae48-4078-bee5-b489074177cf	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	86bb0385-5bbd-413c-8a9a-dae851fee51a	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 14:40:41.721058+00	po	2026-10-12 14:40:41.721058+00	po	0
607c4ae8-2ba0-4d53-adb2-bfc4eb0e20d6	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 14:40:43.135805+00	po	2026-10-12 14:40:43.135805+00	po	0
f77c66b8-735f-4391-855f-d583008738b6	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 14:40:43.90967+00	po	2026-10-12 14:40:43.90967+00	po	0
1775bd56-5c21-4c85-822c-c17c85ad1de8	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	47af8bdc-0dcb-4745-a8c5-d379caae99e2	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 14:40:44.601964+00	po	2026-10-12 14:40:44.601964+00	po	0
4deef4d0-eb55-41eb-b07a-19f360bb6da2	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	433b4394-434f-4058-b654-f3b14e814e6c	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:40:44.65722+00	po	2026-10-12 14:40:44.65722+00	po	0
a6c818d0-7b6a-41f1-a81f-3afc9cb3f1b8	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:40:44.65722+00	po	2026-10-12 14:40:44.65722+00	po	0
5b1ffc8b-647a-4231-a1ae-df8bcddf0173	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 14:40:44.657736+00	po	2026-10-12 14:40:44.657736+00	po	0
7345f20f-b1e1-4a17-82a5-c269334031d1	cd2efab4-a355-40ff-9847-bf10d8f16c53	SPRINT	47af8bdc-0dcb-4745-a8c5-d379caae99e2	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 14:40:44.657736+00	po	2026-10-12 14:40:44.657736+00	po	0
594f8476-1a9c-46e6-b596-f61fdb55ea05	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	d49748ba-5b72-4cbb-91f0-a5288d3024a1	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 14:40:45.744976+00	qa1	2026-10-12 14:40:45.744976+00	qa1	0
d48d3138-f700-4006-9d44-7238781eb143	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	d49748ba-5b72-4cbb-91f0-a5288d3024a1	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 14:40:45.781546+00	qa1	2026-10-12 14:40:45.781546+00	qa1	0
3e642495-7123-4c5c-8687-b3a8296b67c1	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	d49748ba-5b72-4cbb-91f0-a5288d3024a1	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 14:40:45.812346+00	qa1	2026-10-12 14:40:45.812346+00	qa1	0
f31f2dbb-1ca1-4937-85fb-39ed1e6c28fe	cd2efab4-a355-40ff-9847-bf10d8f16c53	DEFECT	5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 14:40:49.046418+00	qa2	2026-10-12 14:40:49.046418+00	qa2	0
b834cbaf-f9c1-40d3-a403-54147c0a39c8	cd2efab4-a355-40ff-9847-bf10d8f16c53	SESSION	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 14:40:54.556602+00	qa1	2026-10-12 14:40:54.556602+00	qa1	0
24e718b8-d870-4c88-9815-9d4ebf7e10fd	cd2efab4-a355-40ff-9847-bf10d8f16c53	DEFECT	b7f3be37-82c7-4843-a008-c92f5958394b	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 14:40:52.874919+00	qa1	2026-10-12 14:40:52.874919+00	qa1	0
8accdd4f-1675-4719-bac7-63fd60b4c349	cd2efab4-a355-40ff-9847-bf10d8f16c53	SESSION	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 14:40:55.160115+00	po	2026-10-12 14:40:55.160115+00	po	0
bfaa46bc-2128-4798-b8c1-3798515b2fff	cd2efab4-a355-40ff-9847-bf10d8f16c53	TRACE_LINK	2ab28dee-5311-4cab-b892-db0a5e9435cc	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 14:41:38.780467+00	qa1	2026-10-12 14:41:38.780467+00	qa1	0
8422b026-362d-43a1-a0cb-134f9c60ac22	cd2efab4-a355-40ff-9847-bf10d8f16c53	CAMPAIGN	ea3f05c8-5e94-4527-bac1-036c59f43a8d	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 14:41:28.841563+00	qa1	2026-10-12 14:41:28.841563+00	qa1	0
1cc408ce-b600-4adf-9395-190e360517e6	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 14:41:38.130342+00	po	2026-10-12 14:41:38.130342+00	po	0
e59418e7-a7d6-4ca5-8836-0845890e8da3	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0056a059-4846-49cc-8a3f-d509ba64f50b	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 14:41:38.143148+00	po	2026-10-12 14:41:38.143148+00	po	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7112e79f-70d7-49bc-ba54-3b4e7c898ae0	cd2efab4-a355-40ff-9847-bf10d8f16c53	RUN-1	1	c39b3007-d713-4b4c-8b21-b23b29ba9b86	0a40a6e0-f6aa-4ade-9723-4488a22a7541	COMPLETED	dev	2026-10-12 14:39:21.76428+00	2026-10-12 14:39:21.826892+00	2026-10-12 14:39:21.826255+00	2026-10-12 14:40:39.659791+00	2026-10-12 14:40:39.659791+00	recette	1.0.0-s1	job-d149b711	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-d149b711/logs	http://localhost:8091/api/v1/jobs/job-d149b711/artifacts/report.json	30	\N	\N	6	6	0	0	0	\N	2026-10-12 14:39:21.766621+00	dev	2026-10-12 14:40:39.676638+00	anonymousUser	14
d451f4f5-d80f-45a0-8390-9881de9065d3	cd2efab4-a355-40ff-9847-bf10d8f16c53	RUN-2	2	d49748ba-5b72-4cbb-91f0-a5288d3024a1	0a40a6e0-f6aa-4ade-9723-4488a22a7541	COMPLETED	dev	2026-10-12 14:40:56.690779+00	2026-10-12 14:40:56.727039+00	2026-10-12 14:40:56.723869+00	2026-10-12 14:41:26.187885+00	2026-10-12 14:41:26.187885+00	recette	1.0.0-s2	job-30307e95	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-30307e95/logs	http://localhost:8091/api/v1/jobs/job-30307e95/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 14:40:56.691951+00	dev	2026-10-12 14:41:26.202075+00	anonymousUser	9
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version", "git_project_id") FROM stdin;
6664a403-8ff6-473a-aa02-5f3227a1f04a	a0139051-c18a-4cb5-85aa-531106f97cc1	DATA_DRIVEN	Playwright	TypeScript	\N	\N	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 14:39:06.681755+00	dev	2026-10-12 14:39:06.681755+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
7bc8159d-00ce-47c0-8c1e-0e18c3b9a970	d706d841-3a3a-46cf-8e38-6c796482f370	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 14:39:06.758945+00	dev	2026-10-12 14:39:06.758945+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
2f3e97bd-8ef4-4cd9-b79e-762aca3d2b8d	ef6242e0-f26d-4635-b90c-cb1b0425b578	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 14:39:06.840764+00	dev	2026-10-12 14:39:06.840764+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
ba7bfe9a-b35e-4ecb-b6fa-b014afe028ee	0056a059-4846-49cc-8a3f-d509ba64f50b	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 14:39:06.995937+00	dev	2026-10-12 14:39:06.995937+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
70c7a42b-258a-4aa4-89f7-fd220069e994	0b4decbf-519b-4401-a935-59c2a44afff9	API	Playwright	TypeScript	\N	\N	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 14:39:07.071839+00	dev	2026-10-12 14:39:07.071839+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
b8586de0-ea28-4878-8184-7c280d25bede	64b43d67-5e84-4c3c-ab29-ae070db37256	BDD	Playwright	\N	\N	\N	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 14:39:08.318723+00	qa1	2026-10-12 14:39:08.454308+00	qa1	1	442afb21-1980-4c78-8fbe-7ba5bee0818c
5f5a3405-e614-4a57-a6b4-fb2d2fbda0d1	83906e72-3061-420e-acbd-5d07f689899d	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 14:39:09.347336+00	dev	2026-10-12 14:39:09.347336+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
c14972ed-90ec-4513-b9f6-d056e8686d2e	12239701-7612-4137-b83a-b93193537887	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 14:39:09.405067+00	dev	2026-10-12 14:39:09.405067+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
d69d47d0-259a-4ef2-8b39-793ea632668f	563f6b55-cf8b-48ad-b46a-a5866feb4f82	PERFORMANCE	Playwright	TypeScript	\N	\N	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 14:39:09.482635+00	dev	2026-10-12 14:39:09.482635+00	dev	0	442afb21-1980-4c78-8fbe-7ba5bee0818c
079c3cfa-6145-4d3d-99ca-33f374ae61ad	226f66ce-ea72-409e-b909-b17942c5c8cb	UI	JUnit 5	Java	\N	\N	src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java	InventaireCatalogueTest#catalogueAffiche	\N	\N	{}	["kerware", "smoke"]	{}	[]	f	2026-10-12 14:39:09.703673+00	dev	2026-10-12 14:39:09.703673+00	dev	0	1f80776b-8036-424c-b026-c20e01fb1f90
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9d9f480d-5719-4b7e-87ab-acf89e368fd3	BDD	Cucumber-JVM	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
9704177a-7274-4894-a29f-5ece01ffcb55	BDD	Cucumber-JS	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
9c81aed1-ae4e-4ecd-bf42-ddcd116c7b15	BDD	Behave	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
a3e42349-0b0b-40f5-92c7-2be4c08f5dd9	BDD	SpecFlow	4	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
a133f15f-f8a9-4314-8988-1f23e97c8bd6	BDD	Karate	5	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
4bffafd0-8948-48a8-bb82-d44eea780f56	UNIT	JUnit 5	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
2ac0811a-73ce-4890-af64-3ec24b23387e	UNIT	Kotest	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
db9f364a-fabe-4e82-89e2-1d56b4d547b1	UNIT	pytest	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
17ad1ff2-c2d9-410c-be11-9287e902e93a	UNIT	Jest	4	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
993275fa-e7d6-4b74-b4d9-91ad1558dba8	UNIT	Vitest	5	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
d509eb04-974a-4de6-9cd8-116c7afaa6e1	UI	Playwright	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
9b8aab92-592e-493b-9793-eeec9430bdc0	UI	Selenium	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
608c127a-b8ed-4c73-b3b0-69f2f2a0ce67	UI	Cypress	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
a0bed4c1-e2dc-4630-a7ec-fe94db92ecb0	UI	Appium	4	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
9847263e-8ac7-4d42-addf-53e1ffb82a24	API	REST Assured	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
c1f70725-fefe-4133-b801-df8410ff1f9d	API	Karate	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
b60428c0-cdb4-4829-baae-811e5e108650	API	Postman/Newman	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
ca2dd2b2-66a6-4827-8f96-274c50b41ee7	API	pytest + requests	4	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
97f21ca2-24e9-4b6a-af54-e0caf505cbb3	KEYWORD	Robot Framework	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
a8e05553-300b-4938-9d46-84b9eb44fc54	DATA_DRIVEN	JUnit 5	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
149d6654-4896-4553-be59-887c432ca0d1	DATA_DRIVEN	pytest	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
bcdb6ff0-517a-4377-911a-c99e495de9f2	DATA_DRIVEN	Playwright	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
fabea74e-1a67-473c-b862-e1e4f5f79d93	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
21228640-914f-4343-a2f6-9abf14d90d2a	PERFORMANCE	Gatling	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
51639721-5374-4889-82bd-f25935b43717	PERFORMANCE	k6	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
249cd655-8872-4268-8ed8-61a1efb4c9cf	PERFORMANCE	JMeter	3	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
3260983e-deeb-4e69-9b4b-a7471b626742	CONTRACT	Pact	1	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
a6dd7a4a-4abb-4042-bb04-6e8427586314	CONTRACT	Spring Cloud Contract	2	2026-10-12 14:38:33.449557+00	system	2026-10-12 14:38:33.449557+00	system	0
\.


--
-- Data for Name: campaign_folders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaign_folders" ("id", "project_id", "path", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
\.


--
-- Data for Name: campaign_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaign_items" ("id", "campaign_id", "test_case_id", "test_case_version", "assignee_id", "position", "risk_score", "created_at", "created_by", "updated_at", "updated_by", "version", "data_set_name", "data_set_row") FROM stdin;
16b043c6-0fae-49a8-ad97-0640b27ae9e6	c39b3007-d713-4b4c-8b21-b23b29ba9b86	a0139051-c18a-4cb5-85aa-531106f97cc1	1	\N	4	12	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.340367+00	qa1	0	\N	\N
049b0aa3-1ca0-4a66-b97a-504d2cfefd62	c39b3007-d713-4b4c-8b21-b23b29ba9b86	d706d841-3a3a-46cf-8e38-6c796482f370	1	\N	5	6	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.340367+00	qa1	0	\N	\N
8023b99c-9080-41c8-8844-c18e831fc513	c39b3007-d713-4b4c-8b21-b23b29ba9b86	226f66ce-ea72-409e-b909-b17942c5c8cb	1	\N	6	6	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.340367+00	qa1	0	\N	\N
1c9bed3a-e487-4a45-b420-4d97251726c9	c39b3007-d713-4b4c-8b21-b23b29ba9b86	ef6242e0-f26d-4635-b90c-cb1b0425b578	1	\N	7	3	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.340367+00	qa1	0	\N	\N
98ca9b71-3561-434b-97a5-040e14938705	c39b3007-d713-4b4c-8b21-b23b29ba9b86	0056a059-4846-49cc-8a3f-d509ba64f50b	1	\N	8	3	2026-10-12 14:39:18.340814+00	qa1	2026-10-12 14:39:18.340814+00	qa1	0	\N	\N
ea1c11d0-d7b7-4d53-8fc4-eff9e49cd1e8	c39b3007-d713-4b4c-8b21-b23b29ba9b86	0b4decbf-519b-4401-a935-59c2a44afff9	1	\N	9	6	2026-10-12 14:39:18.572076+00	qa1	2026-10-12 14:39:18.572076+00	qa1	0	\N	\N
e81f8fe6-65c4-44a1-89ea-ae64c033e0f7	c39b3007-d713-4b4c-8b21-b23b29ba9b86	d6d77d95-1345-4dec-acf8-922ceee859ef	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	1	16	2026-10-12 14:39:18.339774+00	qa1	2026-10-12 14:39:18.619064+00	qa1	1	Comptes	0
a9526428-3ed0-47d7-8af6-0f4a6eb36ce0	c39b3007-d713-4b4c-8b21-b23b29ba9b86	d6d77d95-1345-4dec-acf8-922ceee859ef	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	2	16	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.6401+00	qa1	1	Comptes	1
ba0aa5d7-e895-4ac3-9f7e-917972c83209	c39b3007-d713-4b4c-8b21-b23b29ba9b86	d6d77d95-1345-4dec-acf8-922ceee859ef	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	3	16	2026-10-12 14:39:18.340367+00	qa1	2026-10-12 14:39:18.657371+00	qa1	1	Comptes	2
7b193a6a-91c5-4e62-ba50-1f39c8e4c796	d49748ba-5b72-4cbb-91f0-a5288d3024a1	64b43d67-5e84-4c3c-ab29-ae070db37256	2	\N	3	12	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.773554+00	qa1	0	\N	\N
ae02e7f6-5fa1-4b2e-a883-09e548d7e05d	d49748ba-5b72-4cbb-91f0-a5288d3024a1	83906e72-3061-420e-acbd-5d07f689899d	1	\N	4	12	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.773554+00	qa1	0	\N	\N
d8ee4fb5-d1ca-4afe-bbc5-9bb665786e10	d49748ba-5b72-4cbb-91f0-a5288d3024a1	12239701-7612-4137-b83a-b93193537887	1	\N	7	6	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.773554+00	qa1	0	\N	\N
b9c3efb4-c281-4c22-8d41-517a7824ba33	d49748ba-5b72-4cbb-91f0-a5288d3024a1	563f6b55-cf8b-48ad-b46a-a5866feb4f82	1	\N	8	6	2026-10-12 14:40:45.809114+00	qa1	2026-10-12 14:40:45.809114+00	qa1	0	\N	\N
cf3c648b-2e23-476a-b191-1f04d0e65124	d49748ba-5b72-4cbb-91f0-a5288d3024a1	71497a83-6128-4475-b66c-47a4fa5e254a	1	648cd446-d827-4f93-a49a-c81b39e8ca1a	1	16	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.855496+00	qa1	1	\N	\N
f538b94f-11e2-4a22-858a-99bc2255f8b1	d49748ba-5b72-4cbb-91f0-a5288d3024a1	379e9e17-562f-4e76-97eb-b6a323bfbf8d	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	2	16	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.87584+00	qa1	1	\N	\N
f06eb542-4c46-40a5-b292-d1f74975cd83	d49748ba-5b72-4cbb-91f0-a5288d3024a1	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	5	12	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.896388+00	qa1	1	Produits	0
2973dc0b-fbe5-42f6-b9d7-fd9a99dbbd3f	d49748ba-5b72-4cbb-91f0-a5288d3024a1	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	0ebd6b56-2299-4444-b9a0-e1b94213e70d	6	12	2026-10-12 14:40:45.773554+00	qa1	2026-10-12 14:40:45.914849+00	qa1	1	Produits	1
212779a7-46a6-4591-8f19-dbba810461f5	ea3f05c8-5e94-4527-bac1-036c59f43a8d	0b4decbf-519b-4401-a935-59c2a44afff9	1	\N	1	0	2026-10-12 14:41:30.008689+00	qa1	2026-10-12 14:41:30.008689+00	qa1	0	\N	\N
170f90d7-f468-4d9e-893e-3c0415be2532	ea3f05c8-5e94-4527-bac1-036c59f43a8d	a0139051-c18a-4cb5-85aa-531106f97cc1	1	\N	2	0	2026-10-12 14:41:30.017444+00	qa1	2026-10-12 14:41:30.017444+00	qa1	0	\N	\N
b225d0d2-d81a-4551-a727-fe1b285c8c81	ea3f05c8-5e94-4527-bac1-036c59f43a8d	d706d841-3a3a-46cf-8e38-6c796482f370	1	\N	3	0	2026-10-12 14:41:30.024247+00	qa1	2026-10-12 14:41:30.024247+00	qa1	0	\N	\N
7c55d68c-7058-44db-b1c5-2c5185fa9ba4	ea3f05c8-5e94-4527-bac1-036c59f43a8d	ef6242e0-f26d-4635-b90c-cb1b0425b578	1	\N	4	0	2026-10-12 14:41:30.030735+00	qa1	2026-10-12 14:41:30.030735+00	qa1	0	\N	\N
8409ced4-3b38-40c7-99ef-7941b27ad62f	ea3f05c8-5e94-4527-bac1-036c59f43a8d	0056a059-4846-49cc-8a3f-d509ba64f50b	1	\N	5	0	2026-10-12 14:41:30.035868+00	qa1	2026-10-12 14:41:30.035868+00	qa1	0	\N	\N
0d8ee495-6db8-45aa-8aa1-27ef363eb373	ea3f05c8-5e94-4527-bac1-036c59f43a8d	64b43d67-5e84-4c3c-ab29-ae070db37256	2	\N	6	0	2026-10-12 14:41:30.041366+00	qa1	2026-10-12 14:41:30.041366+00	qa1	0	\N	\N
4fa9d8f7-b5ac-4f11-b94a-c2c95618eb2f	ea3f05c8-5e94-4527-bac1-036c59f43a8d	83906e72-3061-420e-acbd-5d07f689899d	1	\N	7	0	2026-10-12 14:41:30.047611+00	qa1	2026-10-12 14:41:30.047611+00	qa1	0	\N	\N
7c2f7e93-d98e-4f3b-a545-1f4f8dab4664	ea3f05c8-5e94-4527-bac1-036c59f43a8d	12239701-7612-4137-b83a-b93193537887	1	\N	8	0	2026-10-12 14:41:30.052805+00	qa1	2026-10-12 14:41:30.052805+00	qa1	0	\N	\N
2024acd2-448b-4eb3-a9ac-28d17e33cb2a	ea3f05c8-5e94-4527-bac1-036c59f43a8d	563f6b55-cf8b-48ad-b46a-a5866feb4f82	1	\N	9	0	2026-10-12 14:41:30.05799+00	qa1	2026-10-12 14:41:30.05799+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
c39b3007-d713-4b4c-8b21-b23b29ba9b86	cd2efab4-a355-40ff-9847-bf10d8f16c53	CMP-1	1	Recette sprint 1	SPRINT	c31ebf09-4c16-457d-b607-686bbc7b11c2	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 14:39:18.01411+00	qa1	2026-10-12 14:40:41.527469+00	qa1	3	Release 1.0/Recettes de sprint
d49748ba-5b72-4cbb-91f0-a5288d3024a1	cd2efab4-a355-40ff-9847-bf10d8f16c53	CMP-2	2	Recette sprint 2	SPRINT	47af8bdc-0dcb-4745-a8c5-d379caae99e2	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 14:40:45.744376+00	qa1	2026-10-12 14:40:46.843728+00	qa2	2	Release 1.0/Recettes de sprint
ea3f05c8-5e94-4527-bac1-036c59f43a8d	cd2efab4-a355-40ff-9847-bf10d8f16c53	CMP-3	3	Intégration continue — main	RELEASE	\N	572b5b72-07e1-4b13-a256-7359be352088	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 14:41:28.841563+00	qa1	2026-10-12 14:41:30.011414+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
748b977e-d8b5-48ec-b0ab-59fda6f47312	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 14:38:52.461843+00	admin	2026-10-12 14:38:52.461843+00	admin	0
36a84666-1994-4d0a-9560-98e0ad8ccd6c	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 14:38:52.462382+00	admin	2026-10-12 14:38:52.462382+00	admin	0
086d8b49-6a91-4162-b6c2-1d6e8a534a3d	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 14:38:52.462382+00	admin	2026-10-12 14:38:52.462382+00	admin	0
bfa1345c-93f3-4daa-b7e9-09455e285163	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 14:38:52.463039+00	admin	2026-10-12 14:38:52.463039+00	admin	0
cdefc96b-cdf8-48b7-adcb-e6253c8c0cfc	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 14:38:52.463039+00	admin	2026-10-12 14:38:52.463039+00	admin	0
9b4033af-c47f-4dd5-9134-efb29ef930b8	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 14:38:52.463039+00	admin	2026-10-12 14:38:52.463039+00	admin	0
76b2ac9c-8bc8-494c-a49b-343894300e80	cd2efab4-a355-40ff-9847-bf10d8f16c53	DOD	4	Code revu et intégré	\N	2026-10-12 14:38:52.463039+00	admin	2026-10-12 14:38:52.463039+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9f03274f-103e-4565-b7c5-e9e5e0d37397	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 14:39:03.080021+00	po	2026-10-12 14:39:03.080021+00	po	0
b197c308-90d3-4a00-a325-53a80777da9c	7c982acd-5066-45e4-b6c1-2077ff3876ca	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 14:39:03.937201+00	po	2026-10-12 14:39:03.937201+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	1baf7fbe-97f1-46d7-b22c-78e828222998
b7f3be37-82c7-4843-a008-c92f5958394b	02f2051d-4ed5-43b6-83dc-3926a5e7b166
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	7c982acd-5066-45e4-b6c1-2077ff3876ca
5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	e9fca955-cac1-4ef7-87de-afa4fa38da8b
b7f3be37-82c7-4843-a008-c92f5958394b	7c982acd-5066-45e4-b6c1-2077ff3876ca
b7f3be37-82c7-4843-a008-c92f5958394b	e9fca955-cac1-4ef7-87de-afa4fa38da8b
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5fa6cb1a-30df-48a7-bce7-d74885f6ceb7	cd2efab4-a355-40ff-9847-bf10d8f16c53	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 14:40:49.045414+00	qa2	2026-10-12 14:40:49.050786+00	qa2	1
b7f3be37-82c7-4843-a008-c92f5958394b	cd2efab4-a355-40ff-9847-bf10d8f16c53	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 14:40:52.874401+00	qa1	2026-10-12 14:40:52.87647+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
944d3385-6041-4d38-879f-8d6fb53a8233	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 14:39:02.748847+00	po	2026-10-12 14:39:02.748847+00	po	0
831fad40-2cce-4bd8-84a0-1019eb20a1c2	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	EXAMPLE	944d3385-6041-4d38-879f-8d6fb53a8233	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 14:39:02.857665+00	po	2026-10-12 14:39:02.857665+00	po	0
c46d8c32-68de-4e5f-8ee7-9bab73d230ca	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	EXAMPLE	944d3385-6041-4d38-879f-8d6fb53a8233	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 14:39:02.915456+00	po	2026-10-12 14:39:02.915456+00	po	0
f12a910a-36bd-4551-9c6c-7ab7965aa7ca	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 14:39:02.968494+00	po	2026-10-12 14:39:02.968494+00	po	0
8c71fbda-5ae7-4c57-be9b-72069321d3f4	65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	EXAMPLE	f12a910a-36bd-4551-9c6c-7ab7965aa7ca	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 14:39:03.023327+00	po	2026-10-12 14:39:03.023327+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0a40a6e0-f6aa-4ade-9723-4488a22a7541	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact", "Playwright", "Cypress", "Selenium", "pytest", "pytest + requests", "Robot Framework", "Cucumber-JS"]	[]	4	t	2026-10-12 14:38:53.799561+00	admin	2026-10-12 14:41:58.077228+00	system	5
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
0a23b6c8-1500-416f-ac06-a92394562f01	e81f8fe6-65c4-44a1-89ea-ae64c033e0f7	d6d77d95-1345-4dec-acf8-922ceee859ef	1	1	PASSED	f	2026-10-12 14:39:19.492632+00	2026-10-12 14:39:20.190597+00	697	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 14:39:19.498168+00	qa1	2026-10-12 14:39:20.191824+00	qa1	1	\N
f5d88a33-2505-41cd-b8cc-91c8cf0ce850	a9526428-3ed0-47d7-8af6-0f4a6eb36ce0	d6d77d95-1345-4dec-acf8-922ceee859ef	1	1	PASSED	f	2026-10-12 14:39:20.235122+00	2026-10-12 14:39:20.270355+00	35	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 14:39:20.237204+00	qa1	2026-10-12 14:39:20.270869+00	qa1	1	\N
504deca2-b3df-437e-8343-8bac304d0eac	ba0aa5d7-e895-4ac3-9f7e-917972c83209	d6d77d95-1345-4dec-acf8-922ceee859ef	1	1	PASSED	f	2026-10-12 14:39:20.285904+00	2026-10-12 14:39:20.320596+00	34	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 14:39:20.287557+00	qa1	2026-10-12 14:39:20.321668+00	qa1	1	\N
44045106-0c5b-4c2e-ae07-d25dc834ea7b	049b0aa3-1ca0-4a66-b97a-504d2cfefd62	d706d841-3a3a-46cf-8e38-6c796482f370	1	1	PASSED	f	2026-10-12 14:39:52.827797+00	2026-10-12 14:39:56.181945+00	3352	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:39:56.198345+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
ebcfd92c-70db-46c6-8df3-30d27425db51	16b043c6-0fae-49a8-ad97-0640b27ae9e6	a0139051-c18a-4cb5-85aa-531106f97cc1	1	1	PASSED	f	2026-10-12 14:39:52.827842+00	2026-10-12 14:39:56.552591+00	3724	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.766621+00	dev	2026-10-12 14:39:56.56899+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
a7dd2c2c-32f8-48d1-b226-ee3a0f1aab2d	1c9bed3a-e487-4a45-b420-4d97251726c9	ef6242e0-f26d-4635-b90c-cb1b0425b578	1	1	PASSED	f	2026-10-12 14:39:53.510338+00	2026-10-12 14:39:56.206296+00	2695	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:39:56.74834+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
9f21caab-6ca2-48d9-942a-8bdb14a7d758	ea1c11d0-d7b7-4d53-8fc4-eff9e49cd1e8	0b4decbf-519b-4401-a935-59c2a44afff9	1	1	PASSED	f	2026-10-12 14:39:56.215211+00	2026-10-12 14:39:57.908658+00	1692	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:39:57.921683+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
d1ec56a2-dfce-41bc-8f4b-81cbf3679bbd	98ca9b71-3561-434b-97a5-040e14938705	0056a059-4846-49cc-8a3f-d509ba64f50b	1	1	PASSED	f	2026-10-12 14:39:56.587765+00	2026-10-12 14:39:58.156426+00	1568	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:39:58.169755+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
beb94ce6-bec5-413a-ba71-02ae914b5294	8023b99c-9080-41c8-8844-c18e831fc513	226f66ce-ea72-409e-b909-b17942c5c8cb	1	1	PASSED	f	2026-10-12 14:39:53.510352+00	2026-10-12 14:40:39.6258+00	46114	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:39:21.768245+00	dev	2026-10-12 14:40:39.640624+00	anonymousUser	2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0
1baf7fbe-97f1-46d7-b22c-78e828222998	cf3c648b-2e23-476a-b191-1f04d0e65124	71497a83-6128-4475-b66c-47a4fa5e254a	1	1	FAILED	f	2026-10-12 14:40:46.838293+00	2026-10-12 14:40:47.606606+00	768	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:47.607691+00	qa2	1	\N
2f809489-99e2-4896-9ed4-f0bc24765efb	f06eb542-4c46-40a5-b292-d1f74975cd83	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	1	PASSED	f	2026-10-12 14:40:49.554941+00	2026-10-12 14:40:50.485036+00	930	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 14:40:49.560389+00	qa1	2026-10-12 14:40:50.48555+00	qa1	1	\N
6e046399-b4f4-4a81-99f5-4b9afa3e88d5	2973dc0b-fbe5-42f6-b9d7-fd9a99dbbd3f	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	1	PASSED	f	2026-10-12 14:40:50.529838+00	2026-10-12 14:40:50.590933+00	61	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 14:40:50.532947+00	qa1	2026-10-12 14:40:50.591448+00	qa1	1	\N
fd1d5a49-9315-4fcd-9b35-a86a2a3eb28c	170f90d7-f468-4d9e-893e-3c0415be2532	a0139051-c18a-4cb5-85aa-531106f97cc1	1	1	PASSED	f	2026-10-12 14:41:26.492635+00	2026-10-12 14:41:30.007635+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.019517+00	qa1	2026-10-12 14:41:30.019517+00	qa1	0	\N
02f2051d-4ed5-43b6-83dc-3926a5e7b166	f538b94f-11e2-4a22-858a-99bc2255f8b1	379e9e17-562f-4e76-97eb-b6a323bfbf8d	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 14:40:51.589451+00	qa1	2026-10-12 14:40:54.144384+00	qa1	1	\N
f9e792ca-cb1d-4c6a-b896-3a47dbd15f2a	7b193a6a-91c5-4e62-ba50-1f39c8e4c796	64b43d67-5e84-4c3c-ab29-ae070db37256	1	2	PASSED	f	2026-10-12 14:41:20.257822+00	2026-10-12 14:41:23.0196+00	2761	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:40:56.692286+00	dev	2026-10-12 14:41:23.032415+00	anonymousUser	2	d451f4f5-d80f-45a0-8390-9881de9065d3
cb33bc7f-08cf-45e7-a1fd-dca646b2afb0	ae02e7f6-5fa1-4b2e-a883-09e548d7e05d	83906e72-3061-420e-acbd-5d07f689899d	1	1	PASSED	f	2026-10-12 14:41:20.257796+00	2026-10-12 14:41:23.139516+00	2881	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:40:56.692286+00	dev	2026-10-12 14:41:23.150853+00	anonymousUser	2	d451f4f5-d80f-45a0-8390-9881de9065d3
67f46e0e-4dea-4cfd-a051-f731183ea022	b9c3efb4-c281-4c22-8d41-517a7824ba33	563f6b55-cf8b-48ad-b46a-a5866feb4f82	1	1	PASSED	f	2026-10-12 14:41:20.257989+00	2026-10-12 14:41:23.542784+00	3281	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:40:56.692286+00	dev	2026-10-12 14:41:23.552239+00	anonymousUser	2	d451f4f5-d80f-45a0-8390-9881de9065d3
a1c4a443-48c8-4a7a-aeff-b00d51cba454	d8ee4fb5-d1ca-4afe-bbc5-9bb665786e10	12239701-7612-4137-b83a-b93193537887	1	1	FAILED	f	2026-10-12 14:41:20.2578+00	2026-10-12 14:41:26.160479+00	5901	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-30307e95/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 14:40:56.692286+00	dev	2026-10-12 14:41:26.173519+00	anonymousUser	2	d451f4f5-d80f-45a0-8390-9881de9065d3
b23f3828-2ae1-4416-be0e-826dada31f68	212779a7-46a6-4591-8f19-dbba810461f5	0b4decbf-519b-4401-a935-59c2a44afff9	1	1	PASSED	f	2026-10-12 14:41:29.445635+00	2026-10-12 14:41:30.007635+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.010376+00	qa1	2026-10-12 14:41:30.010376+00	qa1	0	\N
c264d9d5-ed3d-48b7-a948-9731f17ab767	b225d0d2-d81a-4551-a727-fe1b285c8c81	d706d841-3a3a-46cf-8e38-6c796482f370	1	1	PASSED	f	2026-10-12 14:41:26.802635+00	2026-10-12 14:41:30.007635+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.0258+00	qa1	2026-10-12 14:41:30.0258+00	qa1	0	\N
67b1eaec-c4e1-4a8b-b61c-4407ac493890	7c55d68c-7058-44db-b1c5-2c5185fa9ba4	ef6242e0-f26d-4635-b90c-cb1b0425b578	1	1	PASSED	f	2026-10-12 14:41:29.565635+00	2026-10-12 14:41:30.007635+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.03278+00	qa1	2026-10-12 14:41:30.03278+00	qa1	0	\N
01a16e80-5e6c-4943-9649-fb365e99aad3	8409ced4-3b38-40c7-99ef-7941b27ad62f	0056a059-4846-49cc-8a3f-d509ba64f50b	1	1	PASSED	f	2026-10-12 14:41:29.470635+00	2026-10-12 14:41:30.007635+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.037413+00	qa1	2026-10-12 14:41:30.037413+00	qa1	0	\N
dd6e2bed-766c-49d9-bfb7-39baf4e4d85d	0d8ee495-6db8-45aa-8aa1-27ef363eb373	64b43d67-5e84-4c3c-ab29-ae070db37256	1	2	PASSED	f	2026-10-12 14:41:29.320635+00	2026-10-12 14:41:30.007635+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.043443+00	qa1	2026-10-12 14:41:30.043443+00	qa1	0	\N
738d74e0-5b36-4c14-b477-6b4a2f85ac29	4fa9d8f7-b5ac-4f11-b94a-c2c95618eb2f	83906e72-3061-420e-acbd-5d07f689899d	1	1	PASSED	f	2026-10-12 14:41:29.460635+00	2026-10-12 14:41:30.007635+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.049166+00	qa1	2026-10-12 14:41:30.049166+00	qa1	0	\N
dc8dd605-77ce-4c36-9497-172cf87bb2bc	7c2f7e93-d98e-4f3b-a545-1f4f8dab4664	12239701-7612-4137-b83a-b93193537887	1	1	FAILED	f	2026-10-12 14:41:26.539635+00	2026-10-12 14:41:30.007635+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.054366+00	qa1	2026-10-12 14:41:30.054366+00	qa1	0	\N
7f842b09-b158-4a64-b73b-792ead4216c2	2024acd2-448b-4eb3-a9ac-28d17e33cb2a	563f6b55-cf8b-48ad-b46a-a5866feb4f82	1	1	PASSED	f	2026-10-12 14:41:29.193635+00	2026-10-12 14:41:30.007635+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 14:41:30.059059+00	qa1	2026-10-12 14:41:30.059059+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3998e97b-46ce-4257-8086-afedddaee9c3	379e9e17-562f-4e76-97eb-b6a323bfbf8d	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 14:39:09.550526+00	qa1	2026-10-12 14:39:09.550526+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
48e5d4f7-bf7f-4e70-b70e-7a140042ac52	02f2051d-4ed5-43b6-83dc-3926a5e7b166	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 14:40:51.589451+00	qa1	2026-10-12 14:40:55.160632+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 16:38:33.142797	97	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 16:38:33.269022	149	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 16:38:33.443073	161	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 16:38:33.627569	24	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 16:38:33.675353	11	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 16:38:33.706234	86	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 16:38:33.816712	133	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 16:38:33.972882	14	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 16:38:34.006512	19	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 16:38:34.04478	36	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 16:38:34.097256	51	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 16:38:34.162996	88	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 16:38:34.268651	25	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 16:38:34.311831	55	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 16:38:34.38794	48	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 16:38:34.455633	32	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 16:38:34.507202	18	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 16:38:34.540095	4	t
19	19	git sources	SQL	V19__git_sources.sql	1616532274	traceagile_demo	2026-10-12 16:38:34.559299	55	t
\.


--
-- Data for Name: git_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_projects" ("id", "source_id", "name", "default_branch", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
442afb21-1980-4c78-8fbe-7ba5bee0818c	ad616b7c-af91-4163-a9a2-110aaf669a35	traceagile	depots-git	\N	2026-10-12 14:38:54.476206+00	admin	2026-10-12 14:38:54.476206+00	admin	0
1f80776b-8036-424c-b026-c20e01fb1f90	656cd738-19bb-4fc1-a2c3-a4e2be566c4a	saucedemo-e2e	master	\N	2026-10-12 14:38:54.516763+00	admin	2026-10-12 14:38:54.516763+00	admin	0
\.


--
-- Data for Name: git_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_sources" ("id", "name", "base_url", "auth_type", "username", "secret", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ad616b7c-af91-4163-a9a2-110aaf669a35	Dépôt local	file:///depots	NONE	\N	\N	Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)	2026-10-12 14:38:54.453153+00	admin	2026-10-12 14:38:54.453153+00	admin	0
656cd738-19bb-4fc1-a2c3-a4e2be566c4a	kerware	https://github.com/kerware	NONE	\N	\N	Projets de formation (GitHub, public)	2026-10-12 14:38:54.501853+00	admin	2026-10-12 14:38:54.501853+00	admin	0
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ	18
cd2efab4-a355-40ff-9847-bf10d8f16c53	TC	15
cd2efab4-a355-40ff-9847-bf10d8f16c53	REL	2
cd2efab4-a355-40ff-9847-bf10d8f16c53	SPR	3
cd2efab4-a355-40ff-9847-bf10d8f16c53	DEF	3
cd2efab4-a355-40ff-9847-bf10d8f16c53	RUN	3
cd2efab4-a355-40ff-9847-bf10d8f16c53	CMP	4
cd2efab4-a355-40ff-9847-bf10d8f16c53	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
77c722f7-102e-4ce7-b391-8edfecdadfa4	d6d77d95-1345-4dec-acf8-922ceee859ef	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 14:39:06.478746+00	qa1	2026-10-12 14:39:06.478746+00	qa1	0	\N	{}	\N	\N
94b82bfb-9566-4577-ae85-d6198d3af2e2	d6d77d95-1345-4dec-acf8-922ceee859ef	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 14:39:06.479351+00	qa1	2026-10-12 14:39:06.479351+00	qa1	0	\N	{}	\N	\N
5c4d5ea2-85f1-488b-8b90-3b9a4f7b4efb	71497a83-6128-4475-b66c-47a4fa5e254a	1	\N	\N	\N	2026-10-12 14:39:06.584551+00	qa1	2026-10-12 14:39:06.584551+00	qa1	0	d6d77d95-1345-4dec-acf8-922ceee859ef	{}	Comptes	problem_user
4628232e-6fde-4a09-bee9-da7d4820a698	71497a83-6128-4475-b66c-47a4fa5e254a	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 14:39:06.585012+00	qa1	2026-10-12 14:39:06.585012+00	qa1	0	\N	{}	\N	\N
ebb64abd-8fc0-4f08-bb53-4c437ee21b7c	71497a83-6128-4475-b66c-47a4fa5e254a	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 14:39:06.585012+00	qa1	2026-10-12 14:39:06.585012+00	qa1	0	\N	{}	\N	\N
da351339-84f1-41b8-99be-ccac741b9038	71497a83-6128-4475-b66c-47a4fa5e254a	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 14:39:06.585012+00	qa1	2026-10-12 14:39:06.585012+00	qa1	0	\N	{}	\N	\N
4a6c3ff2-b170-4705-8f25-5e0494872116	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	\N	\N	\N	2026-10-12 14:39:09.625278+00	qa1	2026-10-12 14:39:09.625278+00	qa1	0	d6d77d95-1345-4dec-acf8-922ceee859ef	{}	Comptes	standard_user
e87f4330-5b4d-4469-87d2-4fce1f801997	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 14:39:09.625776+00	qa1	2026-10-12 14:39:09.625776+00	qa1	0	\N	{}	\N	\N
a60efee6-e6a8-4a2b-b1ed-e1fc97032e72	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 14:39:09.625776+00	qa1	2026-10-12 14:39:09.625776+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
26b57347-ae98-4132-8a96-03e1c0657d01	c45b3d45-beb6-4b4e-a1ab-aeba3fd92fa1	336	ms	p95Ms	TC-11	RUN-2	2026-10-12 14:41:23.542784+00	TARGET_MET	2026-10-12 14:41:23.563403+00	anonymousUser	2026-10-12 14:41:23.563403+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
0215839b-2d72-469f-a06c-e146010ef8a4	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:21.847905+00
37cb447f-b30a-4970-b2b8-70f7b4dd6aea	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:52.838007+00
56691da9-8db7-4138-ae4c-363488d82a53	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:53.379941+00
da23e723-6e5c-416f-aaab-2b37ec305695	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:53.517623+00
aee1dc1a-a080-4997-aba5-2c5b9d3b070e	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:54.038146+00
1daf2ed1-e680-48a2-9bfc-3bfed6696c85	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:56.191308+00
eb019653-f01d-4b1c-a3e1-6005d6830afb	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:56.223455+00
45cc5153-6b36-43ab-9938-b3b6c6ed317a	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:56.563183+00
53d58e87-3a38-4285-a21e-9ee2281f1104	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:56.595062+00
d0817e48-a7ca-43ad-a67b-55cb739cc005	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:56.742131+00
6aea654a-14b2-4f3c-b63c-26deece2d97e	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:57.917504+00
30ee2c67-f3da-4ae7-824e-5e7a6640ecff	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:39:58.164876+00
6b5c2852-7cb8-40c4-9b36-2309383bf400	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:40:39.636185+00
426c55d0-faa9-44e9-981e-3981427c3bd2	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	2026-10-12 14:40:39.66775+00
c512045a-96d6-4d27-ab78-70fdf505fcf6	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:40:57.248776+00
446d44a0-9f24-498d-b96f-83f93ed8e816	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:20.2661+00
fdd6c852-f57d-4535-b281-72f4b17662e7	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:20.783363+00
340b3517-4c5a-4038-97ab-342dd4ef4fc4	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:20.783881+00
198ccca6-edfe-4157-864d-c2b9753b56a4	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:20.783881+00
f14b8547-9018-4024-b690-775b7f3f1e6a	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:23.027715+00
4bb35941-6233-40ec-af85-cc245defee03	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:23.147107+00
9e5e1d55-a1bb-496c-98b3-fc0e09f0518d	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:23.549147+00
7568e6be-75b7-4aa1-88a7-f1cba90822b1	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:26.168331+00
e2745eec-7ad6-465c-86f2-e98b2ae4f815	d451f4f5-d80f-45a0-8390-9881de9065d3	2026-10-12 14:41:26.194324+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
26c219de-da80-43be-a66a-bdd68934942e	cd2efab4-a355-40ff-9847-bf10d8f16c53	84622b6c-4cca-44e5-9c9a-db7725fb6a61	ADMINISTRATOR	2026-10-12 14:38:52.562233+00	admin	2026-10-12 14:38:52.562233+00	admin	0
bb2ef4c0-b3bf-4898-b3eb-cb7d047c7b9a	cd2efab4-a355-40ff-9847-bf10d8f16c53	13d8511d-e5ef-4de4-bae8-c41abca6e5be	PRODUCT_OWNER	2026-10-12 14:38:52.562788+00	admin	2026-10-12 14:38:52.562788+00	admin	0
dbfdb531-1d5d-429b-b76f-ab3c110ad4f4	cd2efab4-a355-40ff-9847-bf10d8f16c53	0ebd6b56-2299-4444-b9a0-e1b94213e70d	TESTER	2026-10-12 14:38:52.562788+00	admin	2026-10-12 14:38:52.562788+00	admin	0
7d5f1380-9fbb-4810-8eb6-490800e33fb0	cd2efab4-a355-40ff-9847-bf10d8f16c53	648cd446-d827-4f93-a49a-c81b39e8ca1a	TESTER	2026-10-12 14:38:52.562788+00	admin	2026-10-12 14:38:52.562788+00	admin	0
9bbd7be8-bb10-4f00-8334-28a7e129d971	cd2efab4-a355-40ff-9847-bf10d8f16c53	48db6d6c-3e56-4da4-a1fc-aab01347554a	DEVELOPER	2026-10-12 14:38:52.562788+00	admin	2026-10-12 14:38:52.562788+00	admin	0
67ba0453-a1eb-4201-b571-ce46b60b54f0	cd2efab4-a355-40ff-9847-bf10d8f16c53	3a5b2a36-c644-4ae6-9024-43161c2b509a	VIEWER	2026-10-12 14:38:52.563299+00	admin	2026-10-12 14:38:52.563299+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
cd2efab4-a355-40ff-9847-bf10d8f16c53	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 14:38:52.442392+00	admin	2026-10-12 14:38:52.442392+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
572b5b72-07e1-4b13-a256-7359be352088	cd2efab4-a355-40ff-9847-bf10d8f16c53	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 14:39:15.187906+00	po	2026-10-12 14:39:16.815045+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
127727a4-d00c-4a56-8984-027eeed32c42	cd2efab4-a355-40ff-9847-bf10d8f16c53	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 14:40:43.915752+00	po	2026-10-12 14:40:43.915752+00	po	0
7147f7f8-fe9f-440a-a2cd-9afb713b6343	cd2efab4-a355-40ff-9847-bf10d8f16c53	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 14:40:43.927167+00	po	2026-10-12 14:40:43.927167+00	po	0
3097e1c2-7cf0-4a49-8981-30d7c64f71a2	cd2efab4-a355-40ff-9847-bf10d8f16c53	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 14:41:46.188941+00	po	2026-10-12 14:41:46.188941+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2c4fbd6d-717a-4231-954c-30b979efa9f6	cd2efab4-a355-40ff-9847-bf10d8f16c53	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T14:40:43.957684500Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 9, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 6, "failed": 0, "notRun": 0, "passed": 6}], "attempts": 9, "byStatus": {"PASSED": 9}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 9, "attempts": 9}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 14:40:43.987771+00	clôture du sprint	2026-10-12 14:40:43.986272+00	po	2026-10-12 14:40:43.988588+00	po	1
38fd35ee-7853-4920-bc62-cefae7e94217	cd2efab4-a355-40ff-9847-bf10d8f16c53	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T14:41:42.725851500Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 14:41:44.285206+00	f	\N	\N	2026-10-12 14:41:42.742214+00	po	2026-10-12 14:41:44.285206+00	po	2
\.


--
-- Data for Name: requirement_checklist_checks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirement_checklist_checks" ("requirement_id", "checklist_item_id") FROM stdin;
\.


--
-- Data for Name: requirement_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirement_tags" ("requirement_id", "tag") FROM stdin;
\.


--
-- Data for Name: requirement_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirement_versions" ("id", "requirement_id", "version_number", "snapshot", "change_comment", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
19227777-4306-44cc-88f7-f837287b06d2	10b55aac-a552-4e2b-85ba-9030d82fe533	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.262268+00	po	2026-10-12 14:38:59.262268+00	po	0
a8149a5d-cd9b-4a79-8ef3-34c7e593ce1a	10cf0f35-ed81-42c0-84d5-33c562347c84	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.307638+00	po	2026-10-12 14:38:59.307638+00	po	0
510808e9-493e-432a-80a5-12251a4fd1d8	3e946069-8458-45e5-a52f-09eb5996e23c	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.345964+00	po	2026-10-12 14:38:59.345964+00	po	0
e9fdadb4-8c2c-41e7-a842-3fb86780ed7e	86bb0385-5bbd-413c-8a9a-dae851fee51a	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.385404+00	po	2026-10-12 14:38:59.385404+00	po	0
f385ec29-a1f9-4d30-95ed-8590b688d4fd	9633fdd3-bdce-4766-8796-4e2118c70ab9	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.427236+00	po	2026-10-12 14:38:59.427236+00	po	0
6b896fc0-570a-44ca-9260-41213b1aa3dc	433b4394-434f-4058-b654-f3b14e814e6c	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.472011+00	po	2026-10-12 14:38:59.472011+00	po	0
a4bc8cfe-5534-40a4-9d20-5d6d6b400086	7c982acd-5066-45e4-b6c1-2077ff3876ca	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:38:59.519827+00	po	2026-10-12 14:38:59.519827+00	po	0
643c81a5-5cc8-4eef-a4fe-1bb437d085e6	e9fca955-cac1-4ef7-87de-afa4fa38da8b	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 14:39:00.461496+00	po	2026-10-12 14:39:00.461496+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 14:38:56.000258+00	po	2026-10-12 14:38:56.000258+00	po	0
9f5930be-6492-4981-86f2-4824df02afaa	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 14:38:56.070441+00	po	2026-10-12 14:38:56.070441+00	po	0
1de832fe-63ec-4ec4-868e-47649110193f	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 14:38:56.200377+00	po	2026-10-12 14:38:56.200377+00	po	0
f1a7483d-d168-4816-a9b9-22ec72f2cc2b	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 14:38:56.347537+00	po	2026-10-12 14:38:56.347537+00	po	0
10cf0f35-ed81-42c0-84d5-33c562347c84	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	9f5930be-6492-4981-86f2-4824df02afaa	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 14:38:56.165019+00	po	2026-10-12 14:40:41.632448+00	po	3
3e946069-8458-45e5-a52f-09eb5996e23c	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	1de832fe-63ec-4ec4-868e-47649110193f	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 14:38:56.235808+00	po	2026-10-12 14:40:41.671699+00	po	3
7c982acd-5066-45e4-b6c1-2077ff3876ca	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	f1a7483d-d168-4816-a9b9-22ec72f2cc2b	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 14:38:56.41627+00	po	2026-10-12 14:40:44.658183+00	po	2
ae0e99af-7408-4f9e-bdd9-b86b0e9b3c1f	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 14:38:56.48392+00	po	2026-10-12 14:38:56.48392+00	po	0
65c448b7-fad5-4ab8-8da1-32c4dcfc5b29	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	ae0e99af-7408-4f9e-bdd9-b86b0e9b3c1f	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 14:38:56.518244+00	po	2026-10-12 14:38:56.518244+00	po	0
c27c5eb1-83f6-4a15-98e8-47e923801445	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	ae0e99af-7408-4f9e-bdd9-b86b0e9b3c1f	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 14:38:58.196987+00	po	2026-10-12 14:38:58.196987+00	po	0
c45b3d45-beb6-4b4e-a1ab-aeba3fd92fa1	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 14:38:58.441272+00	po	2026-10-12 14:38:58.441272+00	po	0
0952fcae-a38e-40cc-b7da-8a6b02c2d361	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	e29b38cf-7810-45a0-8ea3-1fe8bb8341c2	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 14:38:58.470023+00	po	2026-10-12 14:38:58.470023+00	po	0
e9fca955-cac1-4ef7-87de-afa4fa38da8b	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	f1a7483d-d168-4816-a9b9-22ec72f2cc2b	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 14:38:56.449585+00	po	2026-10-12 14:40:44.658183+00	po	2
10b55aac-a552-4e2b-85ba-9030d82fe533	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	9f5930be-6492-4981-86f2-4824df02afaa	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 14:38:56.124731+00	po	2026-10-12 14:40:41.595798+00	po	3
433b4394-434f-4058-b654-f3b14e814e6c	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	f1a7483d-d168-4816-a9b9-22ec72f2cc2b	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 14:38:56.382599+00	po	2026-10-12 14:40:44.658183+00	po	2
86bb0385-5bbd-413c-8a9a-dae851fee51a	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	1de832fe-63ec-4ec4-868e-47649110193f	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 14:38:56.273584+00	po	2026-10-12 14:40:41.721587+00	po	3
9633fdd3-bdce-4766-8796-4e2118c70ab9	cd2efab4-a355-40ff-9847-bf10d8f16c53	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	1de832fe-63ec-4ec4-868e-47649110193f	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 14:38:56.313831+00	po	2026-10-12 14:41:38.130882+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
363906d9-88e8-4726-af17-c4b3d865f125	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	44045106-0c5b-4c2e-ae07-d25dc834ea7b	log-TC-4.txt	text/plain	SYSTEM_TRACE	760	2026-10-12 14:39:56.196898+00	anonymousUser	2026-10-12 14:39:56.196898+00	anonymousUser	0
1087f2c6-8488-43a6-a19d-25d00ccf603a	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	ebcfd92c-70db-46c6-8df3-30d27425db51	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 14:39:56.568481+00	anonymousUser	2026-10-12 14:39:56.568481+00	anonymousUser	0
5cf6d2df-2cc0-4d0f-ac2e-f33fe647cce1	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	a7dd2c2c-32f8-48d1-b226-ee3a0f1aab2d	log-TC-5.txt	text/plain	SYSTEM_TRACE	390	2026-10-12 14:39:56.74729+00	anonymousUser	2026-10-12 14:39:56.74729+00	anonymousUser	0
5a4533cd-bd2c-4a56-885a-b3d206f1b94c	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	9f21caab-6ca2-48d9-942a-8bdb14a7d758	log-TC-7.txt	text/plain	SYSTEM_TRACE	394	2026-10-12 14:39:57.92116+00	anonymousUser	2026-10-12 14:39:57.92116+00	anonymousUser	0
fca9ea2c-66d4-4314-aa91-abe9e510eaa7	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	d1ec56a2-dfce-41bc-8f4b-81cbf3679bbd	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 14:39:58.168205+00	anonymousUser	2026-10-12 14:39:58.168205+00	anonymousUser	0
4b20bd3b-185c-4406-80bb-b992002856b9	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	beb94ce6-bec5-413a-ba71-02ae914b5294	log-TC-14.txt	text/plain	SYSTEM_TRACE	8738	2026-10-12 14:40:39.640066+00	anonymousUser	2026-10-12 14:40:39.640066+00	anonymousUser	0
16f1e213-5554-4968-9493-3fb91104cb31	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	\N	system.log	text/plain	SYSTEM_TRACE	18782	2026-10-12 14:40:39.669927+00	anonymousUser	2026-10-12 14:40:39.669927+00	anonymousUser	0
63e07684-5772-4d74-9e62-2a9bf527e7b7	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	\N	junit.xml	application/xml	JUNIT	1361	2026-10-12 14:40:39.673446+00	anonymousUser	2026-10-12 14:40:39.673446+00	anonymousUser	0
62f35cf3-67d4-42f4-9f06-1d82e5101881	7112e79f-70d7-49bc-ba54-3b4e7c898ae0	\N	report.json	application/json	REPORT	554	2026-10-12 14:40:39.676119+00	anonymousUser	2026-10-12 14:40:39.676119+00	anonymousUser	0
5cad3e78-7cca-438c-b8ea-619cb58a39fc	d451f4f5-d80f-45a0-8390-9881de9065d3	f9e792ca-cb1d-4c6a-b896-3a47dbd15f2a	log-TC-8.txt	text/plain	SYSTEM_TRACE	729	2026-10-12 14:41:23.031898+00	anonymousUser	2026-10-12 14:41:23.031898+00	anonymousUser	0
0df8821d-2e58-457c-bf69-a5188e0bf914	d451f4f5-d80f-45a0-8390-9881de9065d3	cb33bc7f-08cf-45e7-a1fd-dca646b2afb0	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 14:41:23.150335+00	anonymousUser	2026-10-12 14:41:23.150335+00	anonymousUser	0
21a7e6d9-d1e2-4bd4-8665-2001b2529ea0	d451f4f5-d80f-45a0-8390-9881de9065d3	67f46e0e-4dea-4cfd-a051-f731183ea022	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 14:41:23.551724+00	anonymousUser	2026-10-12 14:41:23.551724+00	anonymousUser	0
8b7ce85f-b4a7-4791-b3b5-50ff87635e18	d451f4f5-d80f-45a0-8390-9881de9065d3	a1c4a443-48c8-4a7a-aeff-b00d51cba454	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 14:41:26.170931+00	anonymousUser	2026-10-12 14:41:26.170931+00	anonymousUser	0
54d6f92c-0def-4ad3-b215-9573228e3bd0	d451f4f5-d80f-45a0-8390-9881de9065d3	a1c4a443-48c8-4a7a-aeff-b00d51cba454	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 14:41:26.173002+00	anonymousUser	2026-10-12 14:41:26.173002+00	anonymousUser	0
0e7d598e-59cc-459a-ac1c-dab059eea139	d451f4f5-d80f-45a0-8390-9881de9065d3	\N	system.log	text/plain	SYSTEM_TRACE	8988	2026-10-12 14:41:26.196391+00	anonymousUser	2026-10-12 14:41:26.196391+00	anonymousUser	0
7beff365-4a34-4196-8ace-b634ded30c50	d451f4f5-d80f-45a0-8390-9881de9065d3	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 14:41:26.199475+00	anonymousUser	2026-10-12 14:41:26.199475+00	anonymousUser	0
6e2e941d-24fb-4371-9aa3-1b45f483215e	d451f4f5-d80f-45a0-8390-9881de9065d3	\N	report.json	application/json	REPORT	475	2026-10-12 14:41:26.201556+00	anonymousUser	2026-10-12 14:41:26.201556+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5b4c81df-9695-417b-91d9-3048c260e16d	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 14:40:51.695759+00	qa1	2026-10-12 14:40:51.695759+00	qa1	0
112b844b-9b6a-40d6-bcee-cec7ae82f98a	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 14:40:51.750477+00	qa1	2026-10-12 14:40:51.750477+00	qa1	0
d6b2de4a-1191-4c06-9b31-08068b8f2dfe	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 14:40:51.934495+00	qa1	2026-10-12 14:40:51.934495+00	qa1	0
c0f13ab6-1a7d-417a-84b8-859e8af905b3	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 14:40:51.99995+00	qa1	2026-10-12 14:40:51.99995+00	qa1	0
47608cf4-1c41-40da-8d75-6e09e5195148	48e5d4f7-bf7f-4e70-b70e-7a140042ac52	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	b7f3be37-82c7-4843-a008-c92f5958394b	2026-10-12 14:40:51.870267+00	qa1	2026-10-12 14:40:52.87647+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
cf002a66-6c5f-400b-b896-6ab35e82a196	c31ebf09-4c16-457d-b607-686bbc7b11c2	10b55aac-a552-4e2b-85ba-9030d82fe533	1	3	DONE	2026-10-12 14:39:15.966596+00	po	2026-10-12 14:40:43.917292+00	po	1
8b0f63bd-7c2c-42a1-87a8-bea080db60a7	c31ebf09-4c16-457d-b607-686bbc7b11c2	10cf0f35-ed81-42c0-84d5-33c562347c84	2	2	DONE	2026-10-12 14:39:16.032123+00	po	2026-10-12 14:40:43.917292+00	po	1
10afefe7-6d3a-40f8-b1bc-250e211374b3	c31ebf09-4c16-457d-b607-686bbc7b11c2	3e946069-8458-45e5-a52f-09eb5996e23c	3	3	DONE	2026-10-12 14:39:16.12647+00	po	2026-10-12 14:40:43.917292+00	po	1
a6e2af1f-c7fe-423f-b429-607a46565bf5	c31ebf09-4c16-457d-b607-686bbc7b11c2	86bb0385-5bbd-413c-8a9a-dae851fee51a	4	2	DONE	2026-10-12 14:39:16.187639+00	po	2026-10-12 14:40:43.917292+00	po	1
0941d7e1-e376-496c-ac86-fdcdac61bcbf	c31ebf09-4c16-457d-b607-686bbc7b11c2	9633fdd3-bdce-4766-8796-4e2118c70ab9	5	2	DONE	2026-10-12 14:39:16.259161+00	po	2026-10-12 14:40:43.917292+00	po	1
333635cd-5e38-4f0b-a501-5bad1a57fec6	47af8bdc-0dcb-4745-a8c5-d379caae99e2	433b4394-434f-4058-b654-f3b14e814e6c	1	3	PLANNED	2026-10-12 14:40:44.601964+00	po	2026-10-12 14:40:44.601964+00	po	0
5c09c7b9-176e-4327-8da1-ffdd15b970ca	47af8bdc-0dcb-4745-a8c5-d379caae99e2	7c982acd-5066-45e4-b6c1-2077ff3876ca	2	3	PLANNED	2026-10-12 14:40:44.601964+00	po	2026-10-12 14:40:44.601964+00	po	0
d43667c6-82b9-4b4a-a80c-5f113da0699a	47af8bdc-0dcb-4745-a8c5-d379caae99e2	e9fca955-cac1-4ef7-87de-afa4fa38da8b	3	2	PLANNED	2026-10-12 14:40:44.601964+00	po	2026-10-12 14:40:44.601964+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c31ebf09-4c16-457d-b607-686bbc7b11c2	cd2efab4-a355-40ff-9847-bf10d8f16c53	572b5b72-07e1-4b13-a256-7359be352088	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 14:39:15.222641+00	po	2026-10-12 14:40:43.917292+00	po	2
47af8bdc-0dcb-4745-a8c5-d379caae99e2	cd2efab4-a355-40ff-9847-bf10d8f16c53	572b5b72-07e1-4b13-a256-7359be352088	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 14:39:15.271053+00	po	2026-10-12 14:40:44.658183+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
91cb3b9e-fc9b-443f-8c52-c82792edc601	0a23b6c8-1500-416f-ac06-a92394562f01	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:39:19.499169+00	qa1	2026-10-12 14:39:19.623369+00	qa1	1	\N
2a75b68f-fcb9-4f0b-955d-8da96a82bef7	0a23b6c8-1500-416f-ac06-a92394562f01	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 14:39:19.499169+00	qa1	2026-10-12 14:39:20.191824+00	qa1	1	\N
9ae5926a-eb44-435b-8ab2-6f69f7897af0	f5d88a33-2505-41cd-b8cc-91c8cf0ce850	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:39:20.237204+00	qa1	2026-10-12 14:39:20.25428+00	qa1	1	\N
f900357b-f22b-496b-8138-3ed4cd7f7e5c	f5d88a33-2505-41cd-b8cc-91c8cf0ce850	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 14:39:20.237204+00	qa1	2026-10-12 14:39:20.271384+00	qa1	1	\N
706c8380-865c-4604-93f5-358a8f4cb68d	504deca2-b3df-437e-8343-8bac304d0eac	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:39:20.287557+00	qa1	2026-10-12 14:39:20.304266+00	qa1	1	\N
571007a4-8f89-4f81-9c7f-0c5876be1f9c	504deca2-b3df-437e-8343-8bac304d0eac	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 14:39:20.287557+00	qa1	2026-10-12 14:39:20.321668+00	qa1	1	\N
358b980e-89ec-4df3-bc00-e5ac6fa6b406	1baf7fbe-97f1-46d7-b22c-78e828222998	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:46.984142+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
44363a02-6fac-4e3a-8111-d7a462dce206	1baf7fbe-97f1-46d7-b22c-78e828222998	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:47.101874+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
492131ac-83de-42e8-9a7b-3d6145290c16	1baf7fbe-97f1-46d7-b22c-78e828222998	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:47.222868+00	qa2	1	\N
aefd14da-38e0-49a6-83fe-fdd99c19a053	1baf7fbe-97f1-46d7-b22c-78e828222998	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:47.337313+00	qa2	1	\N
417bd7bb-4308-405b-b154-dd0ab449b0bc	1baf7fbe-97f1-46d7-b22c-78e828222998	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 14:40:46.843009+00	qa2	2026-10-12 14:40:47.607691+00	qa2	1	\N
dc56b1fc-4a0f-4ad2-afe4-06dc676ccd1a	2f809489-99e2-4896-9ed4-f0bc24765efb	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:40:49.560902+00	qa1	2026-10-12 14:40:49.68407+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
adefb581-ec01-4a69-b392-8ea3c53079b7	2f809489-99e2-4896-9ed4-f0bc24765efb	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 14:40:49.560902+00	qa1	2026-10-12 14:40:50.257325+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
21bc9a35-fc73-406f-b223-3617bb1c2e0c	2f809489-99e2-4896-9ed4-f0bc24765efb	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 14:40:49.560902+00	qa1	2026-10-12 14:40:50.374576+00	qa1	1	\N
839103d1-4526-49f9-84df-2283e2b45360	2f809489-99e2-4896-9ed4-f0bc24765efb	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 14:40:49.560902+00	qa1	2026-10-12 14:40:50.48555+00	qa1	1	\N
ce309e31-3b54-49fa-915b-1c0debe1de8f	6e046399-b4f4-4a81-99f5-4b9afa3e88d5	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 14:40:50.533452+00	qa1	2026-10-12 14:40:50.551953+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
eb08f583-b740-482f-ad5b-3af262515c15	6e046399-b4f4-4a81-99f5-4b9afa3e88d5	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 14:40:50.533452+00	qa1	2026-10-12 14:40:50.56469+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
7a6400b6-9aa4-43bf-96de-46300b9f71c8	6e046399-b4f4-4a81-99f5-4b9afa3e88d5	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 14:40:50.533452+00	qa1	2026-10-12 14:40:50.578305+00	qa1	1	\N
5f0cd5b2-2466-415b-a7c7-60f65b235372	6e046399-b4f4-4a81-99f5-4b9afa3e88d5	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 14:40:50.533452+00	qa1	2026-10-12 14:40:50.591448+00	qa1	1	\N
\.


--
-- Data for Name: test_case_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_case_tags" ("test_case_id", "tag") FROM stdin;
\.


--
-- Data for Name: test_case_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_case_versions" ("id", "test_case_id", "version_number", "snapshot", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
cc4cc342-237f-46b4-b3ec-2b823d1c7a4f	d6d77d95-1345-4dec-acf8-922ceee859ef	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 14:39:06.48167+00	qa1	2026-10-12 14:39:06.48167+00	qa1	0
cc743426-4f8b-4f94-a884-e8548bdb1f2a	71497a83-6128-4475-b66c-47a4fa5e254a	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 14:39:06.585516+00	qa1	2026-10-12 14:39:06.585516+00	qa1	0
8bafe76f-61e0-4004-842b-87a0e34a4356	a0139051-c18a-4cb5-85aa-531106f97cc1	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "depots-git", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:06.682299+00	dev	2026-10-12 14:39:06.682299+00	dev	0
2de4a6fc-21a7-4ea1-a3e2-b6e7fe5ed3b1	d706d841-3a3a-46cf-8e38-6c796482f370	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:06.759485+00	dev	2026-10-12 14:39:06.759485+00	dev	0
2cb2507a-365b-498b-bdc9-93fe7712535a	ef6242e0-f26d-4635-b90c-cb1b0425b578	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:06.840764+00	dev	2026-10-12 14:39:06.840764+00	dev	0
8203d6f3-7297-4f2d-93e4-e003fa984285	0056a059-4846-49cc-8a3f-d509ba64f50b	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:06.996453+00	dev	2026-10-12 14:39:06.996453+00	dev	0
d7fdd5a5-5567-4d98-a1b4-433b854d9879	0b4decbf-519b-4401-a935-59c2a44afff9	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "depots-git", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:07.072353+00	dev	2026-10-12 14:39:07.072353+00	dev	0
fb4b1f06-ddb4-4358-9e1c-52677b00014a	64b43d67-5e84-4c3c-ab29-ae070db37256	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:08.319725+00	qa1	2026-10-12 14:39:08.319725+00	qa1	0
265f3952-a101-45f1-9197-525f09886502	64b43d67-5e84-4c3c-ab29-ae070db37256	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "depots-git", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:08.447127+00	qa1	2026-10-12 14:39:08.447127+00	qa1	0
8a8ca45f-e058-4419-bccd-2c8ac837f682	83906e72-3061-420e-acbd-5d07f689899d	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:09.347336+00	dev	2026-10-12 14:39:09.347336+00	dev	0
d224c454-aa7b-40d0-a3b1-53408061fd2f	12239701-7612-4137-b83a-b93193537887	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:09.405067+00	dev	2026-10-12 14:39:09.405067+00	dev	0
6b6f781e-d358-49f8-9498-a4d325635eb1	563f6b55-cf8b-48ad-b46a-a5866feb4f82	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "depots-git", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:09.482635+00	dev	2026-10-12 14:39:09.482635+00	dev	0
8b9a08cc-3b17-43a0-8fd8-ead36672943b	379e9e17-562f-4e76-97eb-b6a323bfbf8d	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 14:39:09.550526+00	qa1	2026-10-12 14:39:09.550526+00	qa1	0
7feea33f-b6e3-430d-8819-d91977f016d1	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 14:39:09.625776+00	qa1	2026-10-12 14:39:09.625776+00	qa1	0
c693328d-7cdf-40d7-bde8-d05c7b81c083	226f66ce-ea72-409e-b909-b17942c5c8cb	1	{"key": "TC-14", "kind": "AUTOMATED", "path": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "tags": null, "title": "Catalogue : noms et prix (Playwright Java)", "branch": "master", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "Java", "priority": "SHOULD", "framework": "JUnit 5", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "kerware, smoke", "gherkinSource": null, "repositoryUrl": "https://github.com/kerware/saucedemo-e2e", "testIdentifier": "InventaireCatalogueTest#catalogueAffiche", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 14:39:09.703673+00	dev	2026-10-12 14:39:09.703673+00	dev	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
d6d77d95-1345-4dec-acf8-922ceee859ef	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 14:39:06.473337+00	qa1	2026-10-12 14:39:06.554955+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
71497a83-6128-4475-b66c-47a4fa5e254a	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 14:39:06.584551+00	qa1	2026-10-12 14:39:06.63786+00	qa1	1	[]	[]	f
a0139051-c18a-4cb5-85aa-531106f97cc1	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 14:39:06.679828+00	dev	2026-10-12 14:39:06.725995+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
d706d841-3a3a-46cf-8e38-6c796482f370	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 14:39:06.758945+00	dev	2026-10-12 14:39:06.804364+00	qa1	1	[]	[]	f
ef6242e0-f26d-4635-b90c-cb1b0425b578	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 14:39:06.840232+00	dev	2026-10-12 14:39:06.958342+00	qa1	1	[]	[]	f
0b4decbf-519b-4401-a935-59c2a44afff9	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 14:39:07.071839+00	dev	2026-10-12 14:39:07.102036+00	qa1	1	[]	[]	f
12239701-7612-4137-b83a-b93193537887	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 14:39:09.404552+00	dev	2026-10-12 14:39:09.445811+00	qa1	1	[]	[]	f
64b43d67-5e84-4c3c-ab29-ae070db37256	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 14:39:08.318723+00	qa1	2026-10-12 14:39:08.454308+00	qa1	2	[]	[]	f
83906e72-3061-420e-acbd-5d07f689899d	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 14:39:09.346818+00	dev	2026-10-12 14:39:09.37914+00	qa1	1	[]	[]	f
563f6b55-cf8b-48ad-b46a-a5866feb4f82	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 14:39:09.482094+00	dev	2026-10-12 14:39:09.523735+00	qa1	1	[]	[]	f
379e9e17-562f-4e76-97eb-b6a323bfbf8d	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 14:39:09.549133+00	qa1	2026-10-12 14:39:09.593152+00	qa1	1	[]	[]	f
59f7b2ed-8f81-408a-a6c9-e889d58bfc73	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 14:39:09.624748+00	qa1	2026-10-12 14:39:09.673357+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
226f66ce-ea72-409e-b909-b17942c5c8cb	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-14	14	AUTOMATED	Catalogue : noms et prix (Playwright Java)	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 14:39:09.703159+00	dev	2026-10-12 14:39:09.731497+00	qa1	1	[]	[]	f
0056a059-4846-49cc-8a3f-d509ba64f50b	cd2efab4-a355-40ff-9847-bf10d8f16c53	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 14:39:06.995937+00	dev	2026-10-12 14:41:38.143706+00	po	2	[]	[]	f
\.


--
-- Data for Name: test_folders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_folders" ("id", "project_id", "path", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
\.


--
-- Data for Name: trace_links; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."trace_links" ("id", "project_id", "source_type", "source_id", "target_type", "target_id", "link_type", "origin", "created_at", "created_by", "updated_at", "updated_by", "version", "suspect_since") FROM stdin;
a2fdd013-9080-4ac3-86e3-d5cb258952aa	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d6d77d95-1345-4dec-acf8-922ceee859ef	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	VERIFIES	MANUAL	2026-10-12 14:39:06.489953+00	qa1	2026-10-12 14:39:06.489953+00	qa1	0	\N
3cc9cca6-71d9-48b0-a077-19bb01f90e1b	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d6d77d95-1345-4dec-acf8-922ceee859ef	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	VERIFIES	MANUAL	2026-10-12 14:39:06.489953+00	qa1	2026-10-12 14:39:06.489953+00	qa1	0	\N
a8c6ae57-0c84-4189-8f90-2328c2fb33ed	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	71497a83-6128-4475-b66c-47a4fa5e254a	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	PARTIALLY_VERIFIES	MANUAL	2026-10-12 14:39:06.594268+00	qa1	2026-10-12 14:39:06.594268+00	qa1	0	\N
ac7ab6d2-4135-4623-a3bc-f0ebb37a3397	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	71497a83-6128-4475-b66c-47a4fa5e254a	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	VERIFIES	MANUAL	2026-10-12 14:39:06.594268+00	qa1	2026-10-12 14:39:06.594268+00	qa1	0	\N
90f52fc7-9a65-4245-812b-c13842b39717	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	a0139051-c18a-4cb5-85aa-531106f97cc1	REQUIREMENT	10b55aac-a552-4e2b-85ba-9030d82fe533	VERIFIES	MANUAL	2026-10-12 14:39:06.687176+00	dev	2026-10-12 14:39:06.687176+00	dev	0	\N
8cf32b03-0ebc-4c5d-b20b-f143fe52f309	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	a0139051-c18a-4cb5-85aa-531106f97cc1	REQUIREMENT	10cf0f35-ed81-42c0-84d5-33c562347c84	VERIFIES	MANUAL	2026-10-12 14:39:06.687176+00	dev	2026-10-12 14:39:06.687176+00	dev	0	\N
a68dcd6e-f13e-4fa0-9151-4bd890ab0567	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	d706d841-3a3a-46cf-8e38-6c796482f370	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	VERIFIES	MANUAL	2026-10-12 14:39:06.762939+00	dev	2026-10-12 14:39:06.762939+00	dev	0	\N
2071cfda-ca65-4a0a-b396-b2f425a1c209	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	ef6242e0-f26d-4635-b90c-cb1b0425b578	REQUIREMENT	86bb0385-5bbd-413c-8a9a-dae851fee51a	VERIFIES	MANUAL	2026-10-12 14:39:06.847558+00	dev	2026-10-12 14:39:06.847558+00	dev	0	\N
163e27a6-96b3-488e-9566-6147cd3fde49	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0b4decbf-519b-4401-a935-59c2a44afff9	REQUIREMENT	0952fcae-a38e-40cc-b7da-8a6b02c2d361	VERIFIES	MANUAL	2026-10-12 14:39:07.074411+00	dev	2026-10-12 14:39:07.074411+00	dev	0	\N
adcbb8bd-ba34-4300-96e7-092d73810c05	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	64b43d67-5e84-4c3c-ab29-ae070db37256	REQUIREMENT	433b4394-434f-4058-b654-f3b14e814e6c	VERIFIES	GHERKIN_TAG	2026-10-12 14:39:08.32381+00	qa1	2026-10-12 14:39:08.32381+00	qa1	0	\N
5d5d0d9d-bc8e-4299-ba79-d6ec837020f5	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	64b43d67-5e84-4c3c-ab29-ae070db37256	ACCEPTANCE_CRITERION	3f686dd5-343a-4f10-8fc6-1b754f7f18ed	VERIFIES	GHERKIN_TAG	2026-10-12 14:39:08.334998+00	qa1	2026-10-12 14:39:08.334998+00	qa1	0	\N
6b07cf33-f1ac-4f2e-b183-60fdabcac60e	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	83906e72-3061-420e-acbd-5d07f689899d	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	VERIFIES	MANUAL	2026-10-12 14:39:09.350542+00	dev	2026-10-12 14:39:09.350542+00	dev	0	\N
ab9ed135-8264-4d6d-9593-f37b6a7cb2f2	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	12239701-7612-4137-b83a-b93193537887	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	VERIFIES	MANUAL	2026-10-12 14:39:09.408123+00	dev	2026-10-12 14:39:09.408123+00	dev	0	\N
ac8df7d4-3451-4667-a59a-52959e4ac501	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	563f6b55-cf8b-48ad-b46a-a5866feb4f82	REQUIREMENT	c45b3d45-beb6-4b4e-a1ab-aeba3fd92fa1	VERIFIES	MANUAL	2026-10-12 14:39:09.486254+00	dev	2026-10-12 14:39:09.486254+00	dev	0	\N
0fb3f0b0-de7c-4d1e-a9ac-3a85afa7dd24	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	379e9e17-562f-4e76-97eb-b6a323bfbf8d	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	VERIFIES	MANUAL	2026-10-12 14:39:09.554759+00	qa1	2026-10-12 14:39:09.554759+00	qa1	0	\N
06de9bd4-144f-4820-8e3f-887ed9355f52	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	379e9e17-562f-4e76-97eb-b6a323bfbf8d	REQUIREMENT	e9fca955-cac1-4ef7-87de-afa4fa38da8b	VERIFIES	MANUAL	2026-10-12 14:39:09.554759+00	qa1	2026-10-12 14:39:09.554759+00	qa1	0	\N
64de59e6-3e07-4fdd-9e7d-cc4f32edcc25	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	59f7b2ed-8f81-408a-a6c9-e889d58bfc73	REQUIREMENT	7c982acd-5066-45e4-b6c1-2077ff3876ca	VERIFIES	MANUAL	2026-10-12 14:39:09.62846+00	qa1	2026-10-12 14:39:09.62846+00	qa1	0	\N
dfe5e945-c001-440a-bf71-5469c69dea48	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	226f66ce-ea72-409e-b909-b17942c5c8cb	REQUIREMENT	3e946069-8458-45e5-a52f-09eb5996e23c	VERIFIES	MANUAL	2026-10-12 14:39:09.705732+00	dev	2026-10-12 14:39:09.705732+00	dev	0	\N
2ab28dee-5311-4cab-b892-db0a5e9435cc	cd2efab4-a355-40ff-9847-bf10d8f16c53	TEST_CASE	0056a059-4846-49cc-8a3f-d509ba64f50b	REQUIREMENT	9633fdd3-bdce-4766-8796-4e2118c70ab9	VERIFIES	MANUAL	2026-10-12 14:39:07.000379+00	dev	2026-10-12 14:41:38.778805+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
84622b6c-4cca-44e5-9c9a-db7725fb6a61	admin	admin@traceagile.local	Administrateur	$2a$12$I5JooZaqp3KaCBUl52MkYOSeXX0QsPvIG14mdPCPPWcDM8Za7sDgK	t	t	2026-10-12 14:38:38.300387+00	system	2026-10-12 14:38:38.300387+00	system	0
13d8511d-e5ef-4de4-bae8-c41abca6e5be	po	po@traceagile.demo	Paula Owner	$2a$12$.k5Nq0KRjyR0MTAvDBaqXOaFH55Qsf.Fi4/eJKANpY11Oc4iFiz6G	t	f	2026-10-12 14:38:50.486367+00	admin	2026-10-12 14:38:50.486367+00	admin	0
0ebd6b56-2299-4444-b9a0-e1b94213e70d	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$63kPLzAqYPyM0jnN7ujczeA.FEDLhXxccwKleeYsecfY3EAjp6QJq	t	f	2026-10-12 14:38:50.677363+00	admin	2026-10-12 14:38:50.677363+00	admin	0
648cd446-d827-4f93-a49a-c81b39e8ca1a	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$B83SchvUqSWqIWUQGdE5K.X8UNDtU3u26gAz0M4eUHuC0hXUI5gxq	t	f	2026-10-12 14:38:50.864957+00	admin	2026-10-12 14:38:50.864957+00	admin	0
48db6d6c-3e56-4da4-a1fc-aab01347554a	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$DxQ2AplD/.OsfD/ZpBPzLu70QMIQxDkzMIgfvqKDayx4oSQsxelDy	t	f	2026-10-12 14:38:51.051845+00	admin	2026-10-12 14:38:51.051845+00	admin	0
3a5b2a36-c644-4ae6-9024-43161c2b509a	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$CTNli9JdozfgcX1EU0J1P.CvvUr6.CorUBa7b1hlc.8z5DJdqJxfu	t	f	2026-10-12 14:38:51.248641+00	admin	2026-10-12 14:38:51.248641+00	admin	0
\.


--
-- Name: acceptance_criteria acceptance_criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."acceptance_criteria"
    ADD CONSTRAINT "acceptance_criteria_pkey" PRIMARY KEY ("id");


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."attachments"
    ADD CONSTRAINT "attachments_pkey" PRIMARY KEY ("id");


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."audit_events"
    ADD CONSTRAINT "audit_events_pkey" PRIMARY KEY ("id");


--
-- Name: automated_runs automated_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_runs"
    ADD CONSTRAINT "automated_runs_pkey" PRIMARY KEY ("id");


--
-- Name: automated_test_definitions automated_test_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_test_definitions"
    ADD CONSTRAINT "automated_test_definitions_pkey" PRIMARY KEY ("id");


--
-- Name: automated_test_definitions automated_test_definitions_test_case_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_test_definitions"
    ADD CONSTRAINT "automated_test_definitions_test_case_id_key" UNIQUE ("test_case_id");


--
-- Name: automation_frameworks automation_frameworks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automation_frameworks"
    ADD CONSTRAINT "automation_frameworks_pkey" PRIMARY KEY ("id");


--
-- Name: campaign_folders campaign_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_folders"
    ADD CONSTRAINT "campaign_folders_pkey" PRIMARY KEY ("id");


--
-- Name: campaign_items campaign_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_items"
    ADD CONSTRAINT "campaign_items_pkey" PRIMARY KEY ("id");


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_pkey" PRIMARY KEY ("id");


--
-- Name: checklist_items checklist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."checklist_items"
    ADD CONSTRAINT "checklist_items_pkey" PRIMARY KEY ("id");


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");


--
-- Name: defect_executions defect_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_executions"
    ADD CONSTRAINT "defect_executions_pkey" PRIMARY KEY ("defect_id", "execution_id");


--
-- Name: defect_requirements defect_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_requirements"
    ADD CONSTRAINT "defect_requirements_pkey" PRIMARY KEY ("defect_id", "requirement_id");


--
-- Name: defects defects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defects"
    ADD CONSTRAINT "defects_pkey" PRIMARY KEY ("id");


--
-- Name: example_cards example_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."example_cards"
    ADD CONSTRAINT "example_cards_pkey" PRIMARY KEY ("id");


--
-- Name: execution_servers execution_servers_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."execution_servers"
    ADD CONSTRAINT "execution_servers_name_key" UNIQUE ("name");


--
-- Name: execution_servers execution_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."execution_servers"
    ADD CONSTRAINT "execution_servers_pkey" PRIMARY KEY ("id");


--
-- Name: executions executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."executions"
    ADD CONSTRAINT "executions_pkey" PRIMARY KEY ("id");


--
-- Name: exploratory_charters exploratory_charters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_charters"
    ADD CONSTRAINT "exploratory_charters_pkey" PRIMARY KEY ("id");


--
-- Name: exploratory_charters exploratory_charters_test_case_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_charters"
    ADD CONSTRAINT "exploratory_charters_test_case_id_key" UNIQUE ("test_case_id");


--
-- Name: exploratory_sessions exploratory_sessions_execution_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_sessions"
    ADD CONSTRAINT "exploratory_sessions_execution_id_key" UNIQUE ("execution_id");


--
-- Name: exploratory_sessions exploratory_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_sessions"
    ADD CONSTRAINT "exploratory_sessions_pkey" PRIMARY KEY ("id");


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."flyway_schema_history"
    ADD CONSTRAINT "flyway_schema_history_pk" PRIMARY KEY ("installed_rank");


--
-- Name: git_projects git_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."git_projects"
    ADD CONSTRAINT "git_projects_pkey" PRIMARY KEY ("id");


--
-- Name: git_sources git_sources_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."git_sources"
    ADD CONSTRAINT "git_sources_name_key" UNIQUE ("name");


--
-- Name: git_sources git_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."git_sources"
    ADD CONSTRAINT "git_sources_pkey" PRIMARY KEY ("id");


--
-- Name: key_sequences key_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."key_sequences"
    ADD CONSTRAINT "key_sequences_pkey" PRIMARY KEY ("project_id", "prefix");


--
-- Name: manual_steps manual_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."manual_steps"
    ADD CONSTRAINT "manual_steps_pkey" PRIMARY KEY ("id");


--
-- Name: nfr_measurements nfr_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."nfr_measurements"
    ADD CONSTRAINT "nfr_measurements_pkey" PRIMARY KEY ("id");


--
-- Name: processed_webhook_events processed_webhook_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."processed_webhook_events"
    ADD CONSTRAINT "processed_webhook_events_pkey" PRIMARY KEY ("event_id");


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_pkey" PRIMARY KEY ("id");


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."releases"
    ADD CONSTRAINT "releases_pkey" PRIMARY KEY ("id");


--
-- Name: report_definitions report_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_definitions"
    ADD CONSTRAINT "report_definitions_pkey" PRIMARY KEY ("id");


--
-- Name: report_snapshots report_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_snapshots"
    ADD CONSTRAINT "report_snapshots_pkey" PRIMARY KEY ("id");


--
-- Name: requirement_checklist_checks requirement_checklist_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_checklist_checks"
    ADD CONSTRAINT "requirement_checklist_checks_pkey" PRIMARY KEY ("requirement_id", "checklist_item_id");


--
-- Name: requirement_tags requirement_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_tags"
    ADD CONSTRAINT "requirement_tags_pkey" PRIMARY KEY ("requirement_id", "tag");


--
-- Name: requirement_versions requirement_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_versions"
    ADD CONSTRAINT "requirement_versions_pkey" PRIMARY KEY ("id");


--
-- Name: requirements requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_pkey" PRIMARY KEY ("id");


--
-- Name: run_artifacts run_artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."run_artifacts"
    ADD CONSTRAINT "run_artifacts_pkey" PRIMARY KEY ("id");


--
-- Name: session_notes session_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."session_notes"
    ADD CONSTRAINT "session_notes_pkey" PRIMARY KEY ("id");


--
-- Name: sprint_scope sprint_scope_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprint_scope"
    ADD CONSTRAINT "sprint_scope_pkey" PRIMARY KEY ("id");


--
-- Name: sprints sprints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprints"
    ADD CONSTRAINT "sprints_pkey" PRIMARY KEY ("id");


--
-- Name: step_results step_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."step_results"
    ADD CONSTRAINT "step_results_pkey" PRIMARY KEY ("id");


--
-- Name: test_case_tags test_case_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_case_tags"
    ADD CONSTRAINT "test_case_tags_pkey" PRIMARY KEY ("test_case_id", "tag");


--
-- Name: test_case_versions test_case_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_case_versions"
    ADD CONSTRAINT "test_case_versions_pkey" PRIMARY KEY ("id");


--
-- Name: test_cases test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_cases"
    ADD CONSTRAINT "test_cases_pkey" PRIMARY KEY ("id");


--
-- Name: test_folders test_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_folders"
    ADD CONSTRAINT "test_folders_pkey" PRIMARY KEY ("id");


--
-- Name: trace_links trace_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."trace_links"
    ADD CONSTRAINT "trace_links_pkey" PRIMARY KEY ("id");


--
-- Name: automated_runs uk_automated_runs_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_runs"
    ADD CONSTRAINT "uk_automated_runs_key" UNIQUE ("project_id", "run_key");


--
-- Name: campaign_folders uk_campaign_folders_path; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_folders"
    ADD CONSTRAINT "uk_campaign_folders_path" UNIQUE ("project_id", "path");


--
-- Name: campaigns uk_campaigns_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "uk_campaigns_key" UNIQUE ("project_id", "campaign_key");


--
-- Name: defects uk_defects_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defects"
    ADD CONSTRAINT "uk_defects_key" UNIQUE ("project_id", "defect_key");


--
-- Name: executions uk_executions_attempt; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."executions"
    ADD CONSTRAINT "uk_executions_attempt" UNIQUE ("campaign_item_id", "attempt");


--
-- Name: project_members uk_project_members; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "uk_project_members" UNIQUE ("project_id", "user_id");


--
-- Name: projects uk_projects_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "uk_projects_key" UNIQUE ("project_key");


--
-- Name: refresh_tokens uk_refresh_tokens_hash; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "uk_refresh_tokens_hash" UNIQUE ("token_hash");


--
-- Name: releases uk_releases_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."releases"
    ADD CONSTRAINT "uk_releases_key" UNIQUE ("project_id", "release_key");


--
-- Name: report_definitions uk_report_definitions_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_definitions"
    ADD CONSTRAINT "uk_report_definitions_name" UNIQUE ("project_id", "name");


--
-- Name: report_snapshots uk_report_snapshots_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_snapshots"
    ADD CONSTRAINT "uk_report_snapshots_key" UNIQUE ("project_id", "report_key");


--
-- Name: requirement_versions uk_requirement_versions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_versions"
    ADD CONSTRAINT "uk_requirement_versions" UNIQUE ("requirement_id", "version_number");


--
-- Name: requirements uk_requirements_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "uk_requirements_key" UNIQUE ("project_id", "requirement_key");


--
-- Name: run_artifacts uk_run_artifacts_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."run_artifacts"
    ADD CONSTRAINT "uk_run_artifacts_name" UNIQUE ("run_id", "name");


--
-- Name: sprint_scope uk_sprint_scope; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprint_scope"
    ADD CONSTRAINT "uk_sprint_scope" UNIQUE ("sprint_id", "requirement_id");


--
-- Name: sprints uk_sprints_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprints"
    ADD CONSTRAINT "uk_sprints_key" UNIQUE ("project_id", "sprint_key");


--
-- Name: test_case_versions uk_test_case_versions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_case_versions"
    ADD CONSTRAINT "uk_test_case_versions" UNIQUE ("test_case_id", "version_number");


--
-- Name: test_cases uk_test_cases_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_cases"
    ADD CONSTRAINT "uk_test_cases_key" UNIQUE ("project_id", "test_key");


--
-- Name: test_folders uk_test_folders_path; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_folders"
    ADD CONSTRAINT "uk_test_folders_path" UNIQUE ("project_id", "path");


--
-- Name: trace_links uk_trace_links; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."trace_links"
    ADD CONSTRAINT "uk_trace_links" UNIQUE ("source_id", "target_id");


--
-- Name: users uk_users_login; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "uk_users_login" UNIQUE ("login");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: automated_test_definitions_git_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "automated_test_definitions_git_project" ON "public"."automated_test_definitions" USING "btree" ("git_project_id");


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "flyway_schema_history_s_idx" ON "public"."flyway_schema_history" USING "btree" ("success");


--
-- Name: git_projects_source_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "git_projects_source_name" ON "public"."git_projects" USING "btree" ("source_id", "lower"(("name")::"text"));


--
-- Name: ix_acceptance_criteria_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_acceptance_criteria_requirement" ON "public"."acceptance_criteria" USING "btree" ("requirement_id", "position");


--
-- Name: ix_attachments_storage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_attachments_storage" ON "public"."attachments" USING "btree" ("storage_key");


--
-- Name: ix_attachments_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_attachments_target" ON "public"."attachments" USING "btree" ("target_type", "target_id");


--
-- Name: ix_audit_events_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_audit_events_entity" ON "public"."audit_events" USING "btree" ("entity_type", "entity_id", "created_at" DESC);


--
-- Name: ix_automated_runs_campaign; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_automated_runs_campaign" ON "public"."automated_runs" USING "btree" ("campaign_id");


--
-- Name: ix_automated_runs_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_automated_runs_key" ON "public"."automated_runs" USING "btree" ("run_key");


--
-- Name: ix_automated_runs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_automated_runs_status" ON "public"."automated_runs" USING "btree" ("status");


--
-- Name: ix_campaign_items_assignee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_campaign_items_assignee" ON "public"."campaign_items" USING "btree" ("assignee_id");


--
-- Name: ix_campaigns_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_campaigns_folder" ON "public"."campaigns" USING "btree" ("project_id", "folder");


--
-- Name: ix_checklist_items_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_checklist_items_project" ON "public"."checklist_items" USING "btree" ("project_id", "kind", "position");


--
-- Name: ix_comments_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_comments_requirement" ON "public"."comments" USING "btree" ("requirement_id", "created_at");


--
-- Name: ix_defect_requirements_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_defect_requirements_requirement" ON "public"."defect_requirements" USING "btree" ("requirement_id");


--
-- Name: ix_example_cards_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_example_cards_requirement" ON "public"."example_cards" USING "btree" ("requirement_id", "position");


--
-- Name: ix_executions_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_executions_run" ON "public"."executions" USING "btree" ("run_id") WHERE ("run_id" IS NOT NULL);


--
-- Name: ix_executions_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_executions_test" ON "public"."executions" USING "btree" ("test_case_id", "started_at");


--
-- Name: ix_exploratory_sessions_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_exploratory_sessions_state" ON "public"."exploratory_sessions" USING "btree" ("state");


--
-- Name: ix_manual_steps_called; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_manual_steps_called" ON "public"."manual_steps" USING "btree" ("called_test_case_id") WHERE ("called_test_case_id" IS NOT NULL);


--
-- Name: ix_manual_steps_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_manual_steps_test" ON "public"."manual_steps" USING "btree" ("test_case_id", "position");


--
-- Name: ix_nfr_measurements_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_nfr_measurements_requirement" ON "public"."nfr_measurements" USING "btree" ("requirement_id", "measured_at" DESC);


--
-- Name: ix_project_members_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_project_members_user" ON "public"."project_members" USING "btree" ("user_id");


--
-- Name: ix_refresh_tokens_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_refresh_tokens_user" ON "public"."refresh_tokens" USING "btree" ("user_id");


--
-- Name: ix_report_snapshots_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_report_snapshots_scope" ON "public"."report_snapshots" USING "btree" ("project_id", "scope");


--
-- Name: ix_requirement_tags_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_requirement_tags_tag" ON "public"."requirement_tags" USING "btree" ("tag");


--
-- Name: ix_requirements_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_requirements_parent" ON "public"."requirements" USING "btree" ("parent_id");


--
-- Name: ix_requirements_project_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_requirements_project_rank" ON "public"."requirements" USING "btree" ("project_id", "rank");


--
-- Name: ix_requirements_search; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_requirements_search" ON "public"."requirements" USING "gin" ("search_vector");


--
-- Name: ix_run_artifacts_execution; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_run_artifacts_execution" ON "public"."run_artifacts" USING "btree" ("execution_id") WHERE ("execution_id" IS NOT NULL);


--
-- Name: ix_session_notes_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_session_notes_session" ON "public"."session_notes" USING "btree" ("session_id", "offset_seconds");


--
-- Name: ix_sprint_scope_requirement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_sprint_scope_requirement" ON "public"."sprint_scope" USING "btree" ("requirement_id");


--
-- Name: ix_sprints_release; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_sprints_release" ON "public"."sprints" USING "btree" ("release_id");


--
-- Name: ix_step_results_execution; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_step_results_execution" ON "public"."step_results" USING "btree" ("execution_id", "position");


--
-- Name: ix_test_cases_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_test_cases_project" ON "public"."test_cases" USING "btree" ("project_id", "key_number");


--
-- Name: ix_trace_links_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_trace_links_project" ON "public"."trace_links" USING "btree" ("project_id");


--
-- Name: ix_trace_links_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_trace_links_source" ON "public"."trace_links" USING "btree" ("source_type", "source_id");


--
-- Name: ix_trace_links_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_trace_links_target" ON "public"."trace_links" USING "btree" ("target_type", "target_id");


--
-- Name: uk_campaign_items; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "uk_campaign_items" ON "public"."campaign_items" USING "btree" ("campaign_id", "test_case_id", COALESCE("lower"(("data_set_name")::"text"), ''::"text"), COALESCE("data_set_row", '-1'::integer));


--
-- Name: uk_sprints_one_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "uk_sprints_one_active" ON "public"."sprints" USING "btree" ("project_id") WHERE (("status")::"text" = 'ACTIVE'::"text");


--
-- Name: acceptance_criteria acceptance_criteria_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."acceptance_criteria"
    ADD CONSTRAINT "acceptance_criteria_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: attachments attachments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."attachments"
    ADD CONSTRAINT "attachments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: automated_runs automated_runs_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_runs"
    ADD CONSTRAINT "automated_runs_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;


--
-- Name: automated_runs automated_runs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_runs"
    ADD CONSTRAINT "automated_runs_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: automated_runs automated_runs_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_runs"
    ADD CONSTRAINT "automated_runs_server_id_fkey" FOREIGN KEY ("server_id") REFERENCES "public"."execution_servers"("id");


--
-- Name: automated_test_definitions automated_test_definitions_git_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_test_definitions"
    ADD CONSTRAINT "automated_test_definitions_git_project_id_fkey" FOREIGN KEY ("git_project_id") REFERENCES "public"."git_projects"("id");


--
-- Name: automated_test_definitions automated_test_definitions_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."automated_test_definitions"
    ADD CONSTRAINT "automated_test_definitions_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE CASCADE;


--
-- Name: campaign_folders campaign_folders_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_folders"
    ADD CONSTRAINT "campaign_folders_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: campaign_items campaign_items_assignee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_items"
    ADD CONSTRAINT "campaign_items_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "public"."users"("id");


--
-- Name: campaign_items campaign_items_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_items"
    ADD CONSTRAINT "campaign_items_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;


--
-- Name: campaign_items campaign_items_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaign_items"
    ADD CONSTRAINT "campaign_items_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id");


--
-- Name: campaigns campaigns_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: campaigns campaigns_release_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_release_id_fkey" FOREIGN KEY ("release_id") REFERENCES "public"."releases"("id");


--
-- Name: campaigns campaigns_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_sprint_id_fkey" FOREIGN KEY ("sprint_id") REFERENCES "public"."sprints"("id");


--
-- Name: checklist_items checklist_items_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."checklist_items"
    ADD CONSTRAINT "checklist_items_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: comments comments_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: defect_executions defect_executions_defect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_executions"
    ADD CONSTRAINT "defect_executions_defect_id_fkey" FOREIGN KEY ("defect_id") REFERENCES "public"."defects"("id") ON DELETE CASCADE;


--
-- Name: defect_executions defect_executions_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_executions"
    ADD CONSTRAINT "defect_executions_execution_id_fkey" FOREIGN KEY ("execution_id") REFERENCES "public"."executions"("id") ON DELETE CASCADE;


--
-- Name: defect_requirements defect_requirements_defect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_requirements"
    ADD CONSTRAINT "defect_requirements_defect_id_fkey" FOREIGN KEY ("defect_id") REFERENCES "public"."defects"("id") ON DELETE CASCADE;


--
-- Name: defect_requirements defect_requirements_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defect_requirements"
    ADD CONSTRAINT "defect_requirements_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: defects defects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."defects"
    ADD CONSTRAINT "defects_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: example_cards example_cards_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."example_cards"
    ADD CONSTRAINT "example_cards_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: example_cards example_cards_rule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."example_cards"
    ADD CONSTRAINT "example_cards_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "public"."example_cards"("id") ON DELETE CASCADE;


--
-- Name: executions executions_campaign_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."executions"
    ADD CONSTRAINT "executions_campaign_item_id_fkey" FOREIGN KEY ("campaign_item_id") REFERENCES "public"."campaign_items"("id") ON DELETE CASCADE;


--
-- Name: executions executions_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."executions"
    ADD CONSTRAINT "executions_run_id_fkey" FOREIGN KEY ("run_id") REFERENCES "public"."automated_runs"("id");


--
-- Name: executions executions_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."executions"
    ADD CONSTRAINT "executions_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id");


--
-- Name: exploratory_charters exploratory_charters_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_charters"
    ADD CONSTRAINT "exploratory_charters_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE CASCADE;


--
-- Name: exploratory_sessions exploratory_sessions_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."exploratory_sessions"
    ADD CONSTRAINT "exploratory_sessions_execution_id_fkey" FOREIGN KEY ("execution_id") REFERENCES "public"."executions"("id") ON DELETE CASCADE;


--
-- Name: git_projects git_projects_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."git_projects"
    ADD CONSTRAINT "git_projects_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "public"."git_sources"("id");


--
-- Name: key_sequences key_sequences_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."key_sequences"
    ADD CONSTRAINT "key_sequences_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: manual_steps manual_steps_called_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."manual_steps"
    ADD CONSTRAINT "manual_steps_called_test_case_id_fkey" FOREIGN KEY ("called_test_case_id") REFERENCES "public"."test_cases"("id");


--
-- Name: manual_steps manual_steps_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."manual_steps"
    ADD CONSTRAINT "manual_steps_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE CASCADE;


--
-- Name: nfr_measurements nfr_measurements_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."nfr_measurements"
    ADD CONSTRAINT "nfr_measurements_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: processed_webhook_events processed_webhook_events_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."processed_webhook_events"
    ADD CONSTRAINT "processed_webhook_events_run_id_fkey" FOREIGN KEY ("run_id") REFERENCES "public"."automated_runs"("id") ON DELETE CASCADE;


--
-- Name: project_members project_members_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: project_members project_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");


--
-- Name: releases releases_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."releases"
    ADD CONSTRAINT "releases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: report_definitions report_definitions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_definitions"
    ADD CONSTRAINT "report_definitions_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: report_snapshots report_snapshots_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."report_snapshots"
    ADD CONSTRAINT "report_snapshots_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: requirement_checklist_checks requirement_checklist_checks_checklist_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_checklist_checks"
    ADD CONSTRAINT "requirement_checklist_checks_checklist_item_id_fkey" FOREIGN KEY ("checklist_item_id") REFERENCES "public"."checklist_items"("id") ON DELETE CASCADE;


--
-- Name: requirement_checklist_checks requirement_checklist_checks_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_checklist_checks"
    ADD CONSTRAINT "requirement_checklist_checks_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: requirement_tags requirement_tags_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_tags"
    ADD CONSTRAINT "requirement_tags_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: requirement_versions requirement_versions_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirement_versions"
    ADD CONSTRAINT "requirement_versions_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: requirements requirements_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."requirements"("id");


--
-- Name: requirements requirements_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."requirements"
    ADD CONSTRAINT "requirements_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: run_artifacts run_artifacts_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."run_artifacts"
    ADD CONSTRAINT "run_artifacts_execution_id_fkey" FOREIGN KEY ("execution_id") REFERENCES "public"."executions"("id") ON DELETE SET NULL;


--
-- Name: run_artifacts run_artifacts_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."run_artifacts"
    ADD CONSTRAINT "run_artifacts_run_id_fkey" FOREIGN KEY ("run_id") REFERENCES "public"."automated_runs"("id") ON DELETE CASCADE;


--
-- Name: session_notes session_notes_defect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."session_notes"
    ADD CONSTRAINT "session_notes_defect_id_fkey" FOREIGN KEY ("defect_id") REFERENCES "public"."defects"("id") ON DELETE SET NULL;


--
-- Name: session_notes session_notes_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."session_notes"
    ADD CONSTRAINT "session_notes_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."exploratory_sessions"("id") ON DELETE CASCADE;


--
-- Name: sprint_scope sprint_scope_requirement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprint_scope"
    ADD CONSTRAINT "sprint_scope_requirement_id_fkey" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE CASCADE;


--
-- Name: sprint_scope sprint_scope_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprint_scope"
    ADD CONSTRAINT "sprint_scope_sprint_id_fkey" FOREIGN KEY ("sprint_id") REFERENCES "public"."sprints"("id") ON DELETE CASCADE;


--
-- Name: sprints sprints_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprints"
    ADD CONSTRAINT "sprints_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: sprints sprints_release_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."sprints"
    ADD CONSTRAINT "sprints_release_id_fkey" FOREIGN KEY ("release_id") REFERENCES "public"."releases"("id");


--
-- Name: step_results step_results_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."step_results"
    ADD CONSTRAINT "step_results_execution_id_fkey" FOREIGN KEY ("execution_id") REFERENCES "public"."executions"("id") ON DELETE CASCADE;


--
-- Name: test_case_tags test_case_tags_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_case_tags"
    ADD CONSTRAINT "test_case_tags_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE CASCADE;


--
-- Name: test_case_versions test_case_versions_test_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_case_versions"
    ADD CONSTRAINT "test_case_versions_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE CASCADE;


--
-- Name: test_cases test_cases_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_cases"
    ADD CONSTRAINT "test_cases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: test_folders test_folders_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."test_folders"
    ADD CONSTRAINT "test_folders_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: trace_links trace_links_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."trace_links"
    ADD CONSTRAINT "trace_links_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


