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
97441420-2349-4aee-9c80-418a86b79557	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 12:39:13.103417+00	po	2026-10-12 12:39:13.103417+00	po	0
ddb5155e-8a4d-4459-b691-cd7343d45a71	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 12:39:13.103417+00	po	2026-10-12 12:39:13.103417+00	po	0
1289ec12-679f-4553-ac31-2fb2fd4e9a65	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 12:39:13.152744+00	po	2026-10-12 12:39:13.152744+00	po	0
1932ac11-e4ef-406d-8193-340ea0a36abe	4222d787-b055-460f-b6fb-876f7f28c776	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 12:39:13.237859+00	po	2026-10-12 12:39:13.237859+00	po	0
0fc5d686-ae2e-4b22-823a-da988f448a34	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 12:39:13.278987+00	po	2026-10-12 12:39:13.278987+00	po	0
49d652c3-e472-40f5-b740-e34d3f57e28f	f0e7d617-1cee-475c-9edf-e9320686cb84	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 12:39:13.317711+00	po	2026-10-12 12:39:13.317711+00	po	0
09c4b8d7-7806-4896-9b23-a3e56e5a71c7	3ff41af0-f5e0-408e-86c8-833b3b1ca617	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 12:39:13.386363+00	po	2026-10-12 12:39:13.386363+00	po	0
6d21a3d7-ae26-490d-b93b-21d657cf6210	3ff41af0-f5e0-408e-86c8-833b3b1ca617	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 12:39:13.386363+00	po	2026-10-12 12:39:13.386363+00	po	0
b7b401ec-196d-48d2-916f-c0abfa852b79	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 12:39:13.423785+00	po	2026-10-12 12:39:13.423785+00	po	0
8022df39-683e-4121-bf88-2a8dbf097845	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 12:39:13.424291+00	po	2026-10-12 12:39:13.424291+00	po	0
d040db2e-366f-48c4-8232-a7c4c0c24bf4	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 12:39:13.462242+00	po	2026-10-12 12:39:13.462242+00	po	0
6779306e-9009-49cc-a6f4-b770adaf802f	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 12:39:13.534152+00	po	2026-10-12 12:39:13.534152+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
f944461d-6c24-4531-9f04-44358a86aec5	a7592200-587e-47ad-a9c8-7d4db95efc3f	EXECUTION_STEP	3f525bb7-bfd5-45b0-9360-09994b947a31	sd-defaut-problem-user.png	image/png	235120	49e450b6-51c2-479c-ba31-e2bdf7edf0c6	2026-10-12 12:40:19.62611+00	qa2	2026-10-12 12:40:19.62611+00	qa2	0
b3bdf9b1-3bdf-4d36-ae1d-b82a440a47d4	a7592200-587e-47ad-a9c8-7d4db95efc3f	DEFECT	9c967cf8-cc80-49b2-a48f-a3dd1513ef64	sd-defaut-problem-user.png	image/png	235120	49e450b6-51c2-479c-ba31-e2bdf7edf0c6	2026-10-12 12:40:21.153444+00	qa2	2026-10-12 12:40:21.153444+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
6a13fc65-b707-40b7-97ac-abb0c8122047	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f26e6366-1ef1-4de1-92a7-8fcf3956957e	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:12.969387+00	po	2026-10-12 12:39:12.969387+00	po	0
44f3edfe-0492-4f5f-ab71-a07c5039a8a7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	c40a280d-1618-4254-ad3d-9e05cc4f7bbd	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:13.048293+00	po	2026-10-12 12:39:13.048293+00	po	0
2354b84c-58e4-4727-9919-138cc3b2146b	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.103417+00	po	2026-10-12 12:39:13.103417+00	po	0
58e2edb7-f86c-4254-9259-070fb7395e17	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.153286+00	po	2026-10-12 12:39:13.153286+00	po	0
0cfd95cd-1f49-4bd4-be01-462bd4da22b7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	c4ff77d5-2854-4092-900a-fcb5de411b62	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:13.194449+00	po	2026-10-12 12:39:13.194449+00	po	0
fbb570bc-9190-4f89-8d5d-c84c75aef3ba	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	4222d787-b055-460f-b6fb-876f7f28c776	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.237859+00	po	2026-10-12 12:39:13.237859+00	po	0
74adeffb-8bec-465c-b5be-33db9f6884ac	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.279501+00	po	2026-10-12 12:39:13.279501+00	po	0
1cc38be7-7d85-468d-b300-1c1d107b1678	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	27184d29-f9bd-4eba-8858-0642eef37143	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:26.615692+00	qa1	2026-10-12 12:39:26.615692+00	qa1	0
157c3137-aa98-4077-87b6-cdc38744c164	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 12:40:17.936454+00	qa1	2026-10-12 12:40:17.936454+00	qa1	0
e6e4af86-8c0b-44d5-a0a6-712049cd4f15	a7592200-587e-47ad-a9c8-7d4db95efc3f	SESSION	ff158847-a5cb-4555-8fd0-8cfd69e06937	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 12:40:27.382745+00	po	2026-10-12 12:40:27.382745+00	po	0
2fed8926-556a-4cb7-a8d8-54ce9cb36a78	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.317711+00	po	2026-10-12 12:39:13.317711+00	po	0
882412ab-2cf8-4bdf-b57c-2a388bf8bbf2	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	a616c143-5569-4a1d-a5f4-d35bf56738eb	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:13.355004+00	po	2026-10-12 12:39:13.355004+00	po	0
dcca0c64-8a81-4f62-9d05-2bcb812137ac	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.462242+00	po	2026-10-12 12:39:13.462242+00	po	0
328dae03-2ce1-423e-88eb-478ae575cd54	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	760aa453-d250-4d3b-824c-9a5484497545	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:13.500165+00	po	2026-10-12 12:39:13.500165+00	po	0
5ef63d25-f152-4b6b-9b82-9e918c7792a7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.534657+00	po	2026-10-12 12:39:13.534657+00	po	0
d02168fc-813d-40ee-bd64-478a87cb64a4	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	afb8a021-1ef8-458a-a45b-6ede51277b43	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:15.237733+00	po	2026-10-12 12:39:15.237733+00	po	0
5d996175-086d-472a-ad33-64ff7f82ba62	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	09bbbe4e-4d4d-4643-b4c7-07319fd7b884	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:15.48213+00	po	2026-10-12 12:39:15.48213+00	po	0
45c5bd8a-b66a-4b00-88f5-fabf8c16fe35	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:40:17.864322+00	qa1	2026-10-12 12:40:17.864322+00	qa1	0
b21de64a-9d41-4d27-be6b-974e8afeab8b	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	3ff41af0-f5e0-408e-86c8-833b3b1ca617	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.386363+00	po	2026-10-12 12:39:13.386363+00	po	0
2f49af36-269b-42d4-b599-7d7c3bb3e59b	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 12:39:13.424291+00	po	2026-10-12 12:39:13.424291+00	po	0
eb3f8af5-f75d-413f-8634-04a1cc1d363f	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	3ff41af0-f5e0-408e-86c8-833b3b1ca617	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.513201+00	po	2026-10-12 12:39:16.513201+00	po	0
b5e6b1fb-ca60-4368-80bd-eb44071c95ac	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ee55515a-64b4-40e0-a4d1-1740035e9b64	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:39:24.078383+00	dev	2026-10-12 12:39:24.078383+00	dev	0
38e414fa-afa8-4d56-a5d7-cfc49e358a6b	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:39:26.6538+00	dev	2026-10-12 12:39:26.6538+00	dev	0
42449b61-ebe6-4df9-b83b-2e30e7e2c24e	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 12:39:31.808396+00	po	2026-10-12 12:39:31.808396+00	po	0
cfc6072e-9ff8-4222-ac75-0998947b79a5	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 12:39:32.605443+00	po	2026-10-12 12:39:32.605443+00	po	0
13251068-5580-4f78-8b9b-45fe0fc99a6c	a7592200-587e-47ad-a9c8-7d4db95efc3f	RUN	96177475-ad0a-4966-8768-63cb806036f1	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 12:39:38.488602+00	dev	2026-10-12 12:39:38.488602+00	dev	0
1f3d3516-8b1f-4640-85dc-d0b37226d712	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	ed96f626-5e2f-4263-9051-35cd87544d59	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:39:15.51563+00	po	2026-10-12 12:39:15.51563+00	po	0
0b7d9487-edb0-489a-8f45-a1a19ec2f601	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.325353+00	po	2026-10-12 12:39:16.325353+00	po	0
2632e218-5946-4b4e-9a1b-7c053a6f71d1	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.371161+00	po	2026-10-12 12:39:16.371161+00	po	0
9d7225a9-985a-4e7d-8e64-facdc9f96098	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	4222d787-b055-460f-b6fb-876f7f28c776	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.406172+00	po	2026-10-12 12:39:16.406172+00	po	0
4d893ada-6311-48dd-902f-0a41f7a720e9	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.443205+00	po	2026-10-12 12:39:16.443205+00	po	0
462f419a-9290-4fbb-a38f-f3a5dea80ca0	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.47797+00	po	2026-10-12 12:39:16.47797+00	po	0
51399c28-f7f6-4cd4-97dd-ff8802738123	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:16.548201+00	po	2026-10-12 12:39:16.548201+00	po	0
f5e24916-7488-43d6-ac47-28d95fc7cbc0	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:17.556049+00	po	2026-10-12 12:39:17.556049+00	po	0
82bd3b61-2319-4c79-ab23-c2ee1070d71d	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ccf4786e-39b1-431c-af24-6f75a7cab94c	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 12:39:23.77845+00	qa1	2026-10-12 12:39:23.77845+00	qa1	0
d6d04195-0246-4de2-b70b-93e547811e50	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ccf4786e-39b1-431c-af24-6f75a7cab94c	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:23.832595+00	qa1	2026-10-12 12:39:23.832595+00	qa1	0
479e119a-af56-406b-8bc2-bc51f062b111	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	261b830e-e4e5-46ef-93e1-63df247e784e	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 12:39:23.872009+00	qa1	2026-10-12 12:39:23.872009+00	qa1	0
b7125ebe-c24e-41ed-b588-464544334c34	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	261b830e-e4e5-46ef-93e1-63df247e784e	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:23.909125+00	qa1	2026-10-12 12:39:23.909125+00	qa1	0
ad86919f-8c36-48ad-97e3-b64d59cd3ee1	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 12:39:23.952027+00	dev	2026-10-12 12:39:23.952027+00	dev	0
e6654534-e1a5-4f02-b7f0-45d10d2b3a6a	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:23.985963+00	qa1	2026-10-12 12:39:23.985963+00	qa1	0
4a9e15d3-8bb0-44d6-b9b2-c95006a746d0	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	8f843627-d65f-4abd-a65d-b74e5e8de2b0	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:24.053897+00	qa1	2026-10-12 12:39:24.053897+00	qa1	0
b487325b-998b-4b3f-aecf-53697c4dd59f	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	8f843627-d65f-4abd-a65d-b74e5e8de2b0	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:39:24.020757+00	dev	2026-10-12 12:39:24.020757+00	dev	0
bc92259d-69bb-429b-b7e4-beea36f875cc	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ee55515a-64b4-40e0-a4d1-1740035e9b64	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:24.120948+00	qa1	2026-10-12 12:39:24.120948+00	qa1	0
11d34eea-5581-41b9-a977-3bc0d3c9d942	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f93c33e1-c462-4306-a66e-d962f7a8339a	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:24.186402+00	qa1	2026-10-12 12:39:24.186402+00	qa1	0
1cc822eb-b33e-4e32-b9c2-343d2392163a	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	6a9be277-8e4c-4564-b119-1be12622f814	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:39:24.219771+00	dev	2026-10-12 12:39:24.219771+00	dev	0
4a3678e2-54b8-442b-9b09-6a923cbfb8e7	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	6a9be277-8e4c-4564-b119-1be12622f814	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:24.251142+00	qa1	2026-10-12 12:39:24.251142+00	qa1	0
3eab5848-4a40-4eb2-a941-c2e1d62fe5a1	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	596ba90e-a60f-4580-aad7-926587affcce	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 12:39:25.587855+00	qa1	2026-10-12 12:39:25.587855+00	qa1	0
77dc9361-39de-4a95-8a9a-221139b74111	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	596ba90e-a60f-4580-aad7-926587affcce	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 12:39:25.719518+00	qa1	2026-10-12 12:39:25.719518+00	qa1	0
25693a02-bec1-49d5-a19d-76edbb5b0f02	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	27184d29-f9bd-4eba-8858-0642eef37143	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:39:26.577564+00	dev	2026-10-12 12:39:26.577564+00	dev	0
3aeac94e-91ee-4ee6-b320-8a991dfcf232	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f00293bd-6193-4e68-bc74-6f071fd46723	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:26.76887+00	qa1	2026-10-12 12:39:26.76887+00	qa1	0
8d8ac94f-c9f2-4665-a57c-711a9931f5c8	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:26.841739+00	qa1	2026-10-12 12:39:26.841739+00	qa1	0
4fe4ee46-ccfa-4605-81cf-1a395d771a1c	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 12:39:32.536327+00	po	2026-10-12 12:39:32.536327+00	po	0
dff86d72-b3ca-4d96-a177-4b916b66447f	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	32f48f83-52b7-4754-812b-7a7df846c637	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 12:39:34.98968+00	qa1	2026-10-12 12:39:34.98968+00	qa1	0
c8cef44a-e086-470e-a0f2-1a17069a8621	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 12:40:17.905303+00	qa1	2026-10-12 12:40:17.905303+00	qa1	0
e9a9627f-7800-414e-90bd-c3d417d905a9	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f93c33e1-c462-4306-a66e-d962f7a8339a	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:39:24.156749+00	dev	2026-10-12 12:39:24.156749+00	dev	0
219b54ff-2897-4223-ba61-09b443209386	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	596ba90e-a60f-4580-aad7-926587affcce	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:25.675445+00	qa1	2026-10-12 12:39:25.675445+00	qa1	0
6d1d5c0c-faae-4a00-a048-8fdf58a5f3e7	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:26.690076+00	qa1	2026-10-12 12:39:26.690076+00	qa1	0
d8cb4148-5377-48f9-8f84-50b7cfbd08fe	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f00293bd-6193-4e68-bc74-6f071fd46723	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:39:26.731906+00	dev	2026-10-12 12:39:26.731906+00	dev	0
807b1c5c-22f7-4166-bb40-a642657a5d5a	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 12:39:32.822323+00	po	2026-10-12 12:39:32.822323+00	po	0
8ea0bfdf-53ca-45d7-a691-1220951f7b2f	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 12:39:26.802085+00	qa1	2026-10-12 12:39:26.802085+00	qa1	0
173bed15-5ff9-4bc9-a0ee-ed378a9bce05	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	a9fcdd24-651e-4927-8b43-72eec5356920	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:39:26.924259+00	qa1	2026-10-12 12:39:26.924259+00	qa1	0
604b6d0a-6c15-49e5-af2f-23849ae95637	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 12:39:32.685972+00	po	2026-10-12 12:39:32.685972+00	po	0
5b811a30-0099-44d0-a887-15a996293503	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 12:39:32.753535+00	po	2026-10-12 12:39:32.753535+00	po	0
925a0682-a37e-4bf5-9908-69e5b4c86328	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	a9fcdd24-651e-4927-8b43-72eec5356920	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 12:39:26.878437+00	qa1	2026-10-12 12:39:26.878437+00	qa1	0
d7733494-78de-44c6-87ab-6d4e59031bce	a7592200-587e-47ad-a9c8-7d4db95efc3f	RELEASE	71811338-d011-4ded-a0db-686a09014de7	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 12:39:31.772674+00	po	2026-10-12 12:39:31.772674+00	po	0
c5f5a43e-8610-42cc-b496-4362d6e3625f	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	4cb4463e-4b72-468e-af4e-272bc7cb7d82	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 12:39:31.855178+00	po	2026-10-12 12:39:31.855178+00	po	0
e719994b-1241-40dc-80cb-64601d528e8d	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:39:33.368991+00	po	2026-10-12 12:39:33.368991+00	po	0
e11a2ade-8382-44e0-9084-24e1b2829cb7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:39:33.369532+00	po	2026-10-12 12:39:33.369532+00	po	0
1fda0f30-6202-4886-8368-6559b7fb441c	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	4222d787-b055-460f-b6fb-876f7f28c776	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:39:33.369532+00	po	2026-10-12 12:39:33.369532+00	po	0
31948f03-cbaa-4e47-83a3-7182a425f07d	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:39:33.369532+00	po	2026-10-12 12:39:33.369532+00	po	0
5769ec9a-b661-4fb2-bad4-1653e7e7feb3	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:39:33.369532+00	po	2026-10-12 12:39:33.369532+00	po	0
8db2befb-8532-465b-8cca-b50bb0ede36d	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 12:39:33.369532+00	po	2026-10-12 12:39:33.369532+00	po	0
67e50029-99d8-4d5c-b796-f8487a52121f	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	32f48f83-52b7-4754-812b-7a7df846c637	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:39:34.654033+00	qa1	2026-10-12 12:39:34.654033+00	qa1	0
d6a8256e-e915-4d9a-b173-c59ed6a43322	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	32f48f83-52b7-4754-812b-7a7df846c637	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 12:39:35.215364+00	qa1	2026-10-12 12:39:35.215364+00	qa1	0
bb7cbb5b-44cc-4c3f-9e38-dad8274c4c50	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	32f48f83-52b7-4754-812b-7a7df846c637	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 12:40:13.71318+00	qa1	2026-10-12 12:40:13.71318+00	qa1	0
a609a5b1-c5a1-43a0-8446-3c1b2b108318	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:40:13.796656+00	po	2026-10-12 12:40:13.796656+00	po	0
12d7824e-48f8-460b-9d9c-ef1a7eb725da	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:40:13.837658+00	po	2026-10-12 12:40:13.837658+00	po	0
ba3b06b1-10dc-4466-a9c0-f099d247d985	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	4222d787-b055-460f-b6fb-876f7f28c776	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:40:13.877185+00	po	2026-10-12 12:40:13.877185+00	po	0
8463d08c-662c-47e3-8823-b0e59da757e7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:40:13.912931+00	po	2026-10-12 12:40:13.912931+00	po	0
8a1d4cfd-82ee-43b4-877d-33caa3872aca	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:40:15.328202+00	po	2026-10-12 12:40:15.328202+00	po	0
68d0e98e-df10-453f-aef2-510037197e20	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 12:40:16.132265+00	po	2026-10-12 12:40:16.132265+00	po	0
7c71950d-bdc7-42af-ac06-614bae7c2332	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	4cb4463e-4b72-468e-af4e-272bc7cb7d82	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 12:40:16.834754+00	po	2026-10-12 12:40:16.834754+00	po	0
ecd52bad-c020-4787-a7fd-7ce455da51e4	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	3ff41af0-f5e0-408e-86c8-833b3b1ca617	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:40:16.888225+00	po	2026-10-12 12:40:16.888225+00	po	0
f19005ea-a05b-4757-b90a-445b52e05221	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:40:16.888853+00	po	2026-10-12 12:40:16.888853+00	po	0
8be76d5d-5de2-4186-a492-3b9e314cbc68	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:40:16.888853+00	po	2026-10-12 12:40:16.888853+00	po	0
253c193e-dbaf-403a-8060-440c25e317a6	a7592200-587e-47ad-a9c8-7d4db95efc3f	SPRINT	4cb4463e-4b72-468e-af4e-272bc7cb7d82	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 12:40:16.888853+00	po	2026-10-12 12:40:16.888853+00	po	0
93af21d3-7538-42ad-8c72-4c56363f69a6	a7592200-587e-47ad-a9c8-7d4db95efc3f	SESSION	ff158847-a5cb-4555-8fd0-8cfd69e06937	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 12:40:26.781864+00	qa1	2026-10-12 12:40:26.781864+00	qa1	0
175c2fa1-45ed-42a9-9b7e-e0a11ef3079f	a7592200-587e-47ad-a9c8-7d4db95efc3f	DEFECT	9c967cf8-cc80-49b2-a48f-a3dd1513ef64	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 12:40:21.149716+00	qa2	2026-10-12 12:40:21.149716+00	qa2	0
063c6bec-e860-4758-99d3-8a3c6a11917d	a7592200-587e-47ad-a9c8-7d4db95efc3f	SESSION	ff158847-a5cb-4555-8fd0-8cfd69e06937	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 12:40:23.645643+00	qa1	2026-10-12 12:40:23.645643+00	qa1	0
0bbdf655-e95d-4f20-bb2e-0ac09a4804c9	a7592200-587e-47ad-a9c8-7d4db95efc3f	DEFECT	c99fbc9b-2bef-4e03-be21-eb3edeca0140	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 12:40:25.032219+00	qa1	2026-10-12 12:40:25.032219+00	qa1	0
cf44ec06-cfdb-447a-a91f-4eb759b04bfa	a7592200-587e-47ad-a9c8-7d4db95efc3f	CAMPAIGN	92d142e9-7855-4403-887d-fc0a792f7e7b	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:41:00.009431+00	qa1	2026-10-12 12:41:00.009431+00	qa1	0
ce4b22ab-0fcc-4db1-bc62-efbeca25b6cd	a7592200-587e-47ad-a9c8-7d4db95efc3f	SESSION	ff158847-a5cb-4555-8fd0-8cfd69e06937	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 12:40:26.330449+00	qa1	2026-10-12 12:40:26.330449+00	qa1	0
1900e28b-0a4a-407a-aa4e-45ee37b459ce	a7592200-587e-47ad-a9c8-7d4db95efc3f	TRACE_LINK	276d0d05-35b2-4480-afbf-98d26730f571	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 12:41:09.737637+00	qa1	2026-10-12 12:41:09.737637+00	qa1	0
e1cd3e2b-40b2-4c11-aa1a-82b3f162a37b	a7592200-587e-47ad-a9c8-7d4db95efc3f	RUN	c8306261-d14c-4c8d-babd-37df438e789e	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 12:40:29.046977+00	dev	2026-10-12 12:40:29.046977+00	dev	0
e35f1e77-3c78-4e5a-b089-ab652a4ec0ee	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 12:41:09.069386+00	po	2026-10-12 12:41:09.069386+00	po	0
e26d3276-cc82-455e-a945-1eaeb5096377	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f93c33e1-c462-4306-a66e-d962f7a8339a	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 12:41:09.078753+00	po	2026-10-12 12:41:09.078753+00	po	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
96177475-ad0a-4966-8768-63cb806036f1	a7592200-587e-47ad-a9c8-7d4db95efc3f	RUN-1	1	32f48f83-52b7-4754-812b-7a7df846c637	7f436f34-da6e-4b1e-aecd-fdfc79c8109e	COMPLETED	dev	2026-10-12 12:39:38.484457+00	2026-10-12 12:39:38.551367+00	2026-10-12 12:39:38.55091+00	2026-10-12 12:40:11.906267+00	2026-10-12 12:40:11.906267+00	recette	1.0.0-s1	job-fa8c832c	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-fa8c832c/logs	http://localhost:8091/api/v1/jobs/job-fa8c832c/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 12:39:38.487804+00	dev	2026-10-12 12:40:11.920848+00	anonymousUser	12
c8306261-d14c-4c8d-babd-37df438e789e	a7592200-587e-47ad-a9c8-7d4db95efc3f	RUN-2	2	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	7f436f34-da6e-4b1e-aecd-fdfc79c8109e	COMPLETED	dev	2026-10-12 12:40:29.045205+00	2026-10-12 12:40:29.08814+00	2026-10-12 12:40:29.087642+00	2026-10-12 12:40:57.454211+00	2026-10-12 12:40:57.454211+00	recette	1.0.0-s2	job-5b7aeac2	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-5b7aeac2/logs	http://localhost:8091/api/v1/jobs/job-5b7aeac2/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 12:40:29.046364+00	dev	2026-10-12 12:40:57.46808+00	anonymousUser	7
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version", "git_project_id") FROM stdin;
2fd97415-5ebf-4acd-b028-000785eef2d2	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	DATA_DRIVEN	Playwright	TypeScript	\N	\N	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 12:39:23.944885+00	dev	2026-10-12 12:39:23.944885+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
0418e0e7-de47-4bc8-a68f-69f27074bc0d	8f843627-d65f-4abd-a65d-b74e5e8de2b0	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:39:24.017646+00	dev	2026-10-12 12:39:24.017646+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
443e601e-f2ee-44c5-bd90-680ad07b511a	ee55515a-64b4-40e0-a4d1-1740035e9b64	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:39:24.078383+00	dev	2026-10-12 12:39:24.078383+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
0d7ae410-e606-40fb-b196-b34912809183	f93c33e1-c462-4306-a66e-d962f7a8339a	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:39:24.152527+00	dev	2026-10-12 12:39:24.152527+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
76bbb332-9b39-434e-8870-de33c094fa30	6a9be277-8e4c-4564-b119-1be12622f814	API	Playwright	TypeScript	\N	\N	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:39:24.216164+00	dev	2026-10-12 12:39:24.216164+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
1f7110e3-55d3-4cf6-a70b-1975e66dac91	596ba90e-a60f-4580-aad7-926587affcce	BDD	Playwright	\N	\N	\N	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 12:39:25.573512+00	qa1	2026-10-12 12:39:25.720026+00	qa1	1	e6dda626-ece9-46cc-aee4-a2214709f6f3
f3387337-a7e4-46ec-872f-9840dd73a40f	27184d29-f9bd-4eba-8858-0642eef37143	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:39:26.574574+00	dev	2026-10-12 12:39:26.574574+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
6eb01b17-6599-46e7-941a-3220bcef22cb	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:39:26.650564+00	dev	2026-10-12 12:39:26.650564+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
46d05556-9c8d-4077-be5d-e83f8e15f925	f00293bd-6193-4e68-bc74-6f071fd46723	PERFORMANCE	Playwright	TypeScript	\N	\N	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 12:39:26.727923+00	dev	2026-10-12 12:39:26.727923+00	dev	0	e6dda626-ece9-46cc-aee4-a2214709f6f3
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
dc2dbc12-e211-4999-a081-6abb6c0de6a2	BDD	Cucumber-JVM	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
5f295c0f-c105-4ae8-aedc-27731109e66e	BDD	Cucumber-JS	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
78d92a16-8a48-4793-980d-cfc32fc9065a	BDD	Behave	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
c3e5ce6c-a08a-4465-8f7c-94d1bba53cf9	BDD	SpecFlow	4	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
d8720001-ce79-46eb-ace1-04ad8ec291c5	BDD	Karate	5	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
60d659e0-2d2b-45a6-b6d0-0d6e77a52426	UNIT	JUnit 5	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
ff7274d3-520e-427d-b92d-6349c0938750	UNIT	Kotest	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
5f1f8b02-35c5-4358-9f53-0d46f8ae568e	UNIT	pytest	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
d178c364-9550-4302-9c1c-df5a91ced896	UNIT	Jest	4	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
912dd4d5-f5f2-4afe-ba5e-13178729a81e	UNIT	Vitest	5	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
e54b9817-c64a-4914-ba35-ddcfb1912347	UI	Playwright	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
301ab176-e6ef-4658-bae6-c18b331c0343	UI	Selenium	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
e513f313-ea36-4739-ba3c-4fea16f13c7a	UI	Cypress	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
d83e4292-ac54-4795-80ee-57745871e6ef	UI	Appium	4	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
fb3bb904-85e7-4906-a91e-b9c20b4b6cd3	API	REST Assured	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
c405b49d-7ec4-42da-8d5a-66fae7154059	API	Karate	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
76dfb980-3888-4fdc-a6d8-494e1820b13b	API	Postman/Newman	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
4da073e7-84f9-4470-a287-8f6405bde871	API	pytest + requests	4	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
3d54adb9-cdbf-47c1-8b9f-3f1597fb4920	KEYWORD	Robot Framework	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
d8b82823-394c-4756-955f-983f194291ea	DATA_DRIVEN	JUnit 5	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
f3d37496-5956-4faf-96ca-98efeb49cefd	DATA_DRIVEN	pytest	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
d02c1e4a-0911-4cce-afe8-159bbe3a1971	DATA_DRIVEN	Playwright	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
0ce67ade-6476-4114-b907-b41db3ba0776	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
76f094e0-a92d-4e42-9933-f82f496d1a6c	PERFORMANCE	Gatling	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
fbfe8bdf-5a88-4c76-8528-c9c420b51c5e	PERFORMANCE	k6	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
ecb345ac-fa5c-4d72-972a-3dbb50adf8ef	PERFORMANCE	JMeter	3	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
e70a7b64-ce90-47ef-afe3-0128c96ec712	CONTRACT	Pact	1	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
e9c22d2f-9164-4cae-909d-e73d3dfa2239	CONTRACT	Spring Cloud Contract	2	2026-10-12 12:38:52.273401+00	system	2026-10-12 12:38:52.273401+00	system	0
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
46c6ae5c-2014-4315-a4d0-f285926cce5c	32f48f83-52b7-4754-812b-7a7df846c637	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	1	\N	4	12	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:34.979691+00	qa1	0	\N	\N
b17c442e-1816-4e90-9726-e3a17af16d7b	32f48f83-52b7-4754-812b-7a7df846c637	8f843627-d65f-4abd-a65d-b74e5e8de2b0	1	\N	5	6	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:34.979691+00	qa1	0	\N	\N
6c29d87c-a767-4d4a-85ed-b1593b3e2cde	32f48f83-52b7-4754-812b-7a7df846c637	ee55515a-64b4-40e0-a4d1-1740035e9b64	1	\N	6	3	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:34.979691+00	qa1	0	\N	\N
c0f339ed-00f4-4af2-98f2-6bc5564071f5	32f48f83-52b7-4754-812b-7a7df846c637	f93c33e1-c462-4306-a66e-d962f7a8339a	1	\N	7	3	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:34.979691+00	qa1	0	\N	\N
f39755a0-be30-4af0-a23a-3351da688be6	32f48f83-52b7-4754-812b-7a7df846c637	6a9be277-8e4c-4564-b119-1be12622f814	1	\N	8	6	2026-10-12 12:39:35.213998+00	qa1	2026-10-12 12:39:35.213998+00	qa1	0	\N	\N
5ac44fcc-27c8-4fbf-9e30-dedd7dd2eb6a	32f48f83-52b7-4754-812b-7a7df846c637	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	f88ee032-a263-4d16-9f40-3c190c42eaef	1	16	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:35.265236+00	qa1	1	Comptes	0
bf4f678b-84c7-4a88-b507-045a94f93d71	32f48f83-52b7-4754-812b-7a7df846c637	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	f88ee032-a263-4d16-9f40-3c190c42eaef	2	16	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:35.288327+00	qa1	1	Comptes	1
d43068cd-16eb-4cd6-8522-a9b88f4287c8	32f48f83-52b7-4754-812b-7a7df846c637	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	f88ee032-a263-4d16-9f40-3c190c42eaef	3	16	2026-10-12 12:39:34.979691+00	qa1	2026-10-12 12:39:35.308821+00	qa1	1	Comptes	2
903a0a09-084a-4d48-87e0-dcf5f1eab705	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	596ba90e-a60f-4580-aad7-926587affcce	2	\N	3	12	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.896738+00	qa1	0	\N	\N
a5dbdadb-e6e2-4a5d-b226-440ada996a39	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	27184d29-f9bd-4eba-8858-0642eef37143	1	\N	4	12	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.896738+00	qa1	0	\N	\N
c48d9b00-387e-41c4-a36e-0c206846b1a2	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	1	\N	7	6	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.896738+00	qa1	0	\N	\N
87ed9f3b-1a35-444a-8ede-9595bff32e3e	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	f00293bd-6193-4e68-bc74-6f071fd46723	1	\N	8	6	2026-10-12 12:40:17.935001+00	qa1	2026-10-12 12:40:17.935001+00	qa1	0	\N	\N
e321caa6-df6c-4cf3-8c11-61356c7997d3	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	261b830e-e4e5-46ef-93e1-63df247e784e	1	993752b1-4beb-4cf0-bc77-ccce4971bd89	1	16	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.968431+00	qa1	1	\N	\N
dda23dac-c003-428e-a8b0-74b37230a6df	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	1	f88ee032-a263-4d16-9f40-3c190c42eaef	2	16	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.982593+00	qa1	1	\N	\N
6cbc35ce-b4a6-4e9c-a449-fc4c26894e92	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	a9fcdd24-651e-4927-8b43-72eec5356920	1	f88ee032-a263-4d16-9f40-3c190c42eaef	5	12	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:17.997368+00	qa1	1	Produits	0
b8e39cff-f67a-4a5b-935f-b1c1a4c47f78	d4c002f4-7be3-4057-92c5-dc208bd7d4f3	a9fcdd24-651e-4927-8b43-72eec5356920	1	f88ee032-a263-4d16-9f40-3c190c42eaef	6	12	2026-10-12 12:40:17.896738+00	qa1	2026-10-12 12:40:18.013301+00	qa1	1	Produits	1
7380d016-dc1a-4805-9108-9a8ff9fde7c3	92d142e9-7855-4403-887d-fc0a792f7e7b	6a9be277-8e4c-4564-b119-1be12622f814	1	\N	1	0	2026-10-12 12:41:01.179521+00	qa1	2026-10-12 12:41:01.179521+00	qa1	0	\N	\N
9db0fc39-b8a1-4218-a6f5-880a85974c0a	92d142e9-7855-4403-887d-fc0a792f7e7b	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	1	\N	2	0	2026-10-12 12:41:01.187914+00	qa1	2026-10-12 12:41:01.187914+00	qa1	0	\N	\N
e56bbbde-ad43-45fa-8c89-e27851b14e11	92d142e9-7855-4403-887d-fc0a792f7e7b	8f843627-d65f-4abd-a65d-b74e5e8de2b0	1	\N	3	0	2026-10-12 12:41:01.193352+00	qa1	2026-10-12 12:41:01.193352+00	qa1	0	\N	\N
ab3b4a7a-0bf1-4ac0-874f-3f740266c69f	92d142e9-7855-4403-887d-fc0a792f7e7b	ee55515a-64b4-40e0-a4d1-1740035e9b64	1	\N	4	0	2026-10-12 12:41:01.197697+00	qa1	2026-10-12 12:41:01.197697+00	qa1	0	\N	\N
d5505362-d32f-4017-8687-a00fcd87df16	92d142e9-7855-4403-887d-fc0a792f7e7b	f93c33e1-c462-4306-a66e-d962f7a8339a	1	\N	5	0	2026-10-12 12:41:01.201388+00	qa1	2026-10-12 12:41:01.201388+00	qa1	0	\N	\N
456a3e13-e5ab-4e55-80c5-f3469f9b2c16	92d142e9-7855-4403-887d-fc0a792f7e7b	596ba90e-a60f-4580-aad7-926587affcce	2	\N	6	0	2026-10-12 12:41:01.205639+00	qa1	2026-10-12 12:41:01.205639+00	qa1	0	\N	\N
eac49b7d-2237-45fc-958b-383fa9091218	92d142e9-7855-4403-887d-fc0a792f7e7b	27184d29-f9bd-4eba-8858-0642eef37143	1	\N	7	0	2026-10-12 12:41:01.210478+00	qa1	2026-10-12 12:41:01.210478+00	qa1	0	\N	\N
ea457f42-f1b6-440d-ba8f-cd3e0a84b636	92d142e9-7855-4403-887d-fc0a792f7e7b	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	1	\N	8	0	2026-10-12 12:41:01.214959+00	qa1	2026-10-12 12:41:01.214959+00	qa1	0	\N	\N
35a71949-24f0-4611-963d-a4757884feb2	92d142e9-7855-4403-887d-fc0a792f7e7b	f00293bd-6193-4e68-bc74-6f071fd46723	1	\N	9	0	2026-10-12 12:41:01.219741+00	qa1	2026-10-12 12:41:01.219741+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
32f48f83-52b7-4754-812b-7a7df846c637	a7592200-587e-47ad-a9c8-7d4db95efc3f	CMP-1	1	Recette sprint 1	SPRINT	059d2bef-6dd1-4f36-ab15-73b6e99c897a	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 12:39:34.653033+00	qa1	2026-10-12 12:40:13.71318+00	qa1	3	Release 1.0/Recettes de sprint
d4c002f4-7be3-4057-92c5-dc208bd7d4f3	a7592200-587e-47ad-a9c8-7d4db95efc3f	CMP-2	2	Recette sprint 2	SPRINT	4cb4463e-4b72-468e-af4e-272bc7cb7d82	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 12:40:17.864322+00	qa1	2026-10-12 12:40:18.945378+00	qa2	2	Release 1.0/Recettes de sprint
92d142e9-7855-4403-887d-fc0a792f7e7b	a7592200-587e-47ad-a9c8-7d4db95efc3f	CMP-3	3	Intégration continue — main	RELEASE	\N	71811338-d011-4ded-a0db-686a09014de7	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 12:41:00.009431+00	qa1	2026-10-12 12:41:01.181712+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e9b1c524-63d6-4875-ab3a-ba045c0872f6	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 12:39:09.31292+00	admin	2026-10-12 12:39:09.31292+00	admin	0
6620a075-cb64-4f4c-ba1f-e2c1f1c298f8	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
0a4fe6a9-44fe-4481-ab93-1edd5cee06d2	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
2649de59-6b2e-46c0-ac85-3c375fbd8465	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
72578f43-864b-4560-82ee-df3f2467a56a	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
656452ea-8e67-4335-9674-2b20af3bae89	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
43b090b8-ba47-4677-a73c-689a4517c625	a7592200-587e-47ad-a9c8-7d4db95efc3f	DOD	4	Code revu et intégré	\N	2026-10-12 12:39:09.314925+00	admin	2026-10-12 12:39:09.314925+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1a0721f0-350b-42ca-a1c8-cd29a34189e7	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 12:39:20.267682+00	po	2026-10-12 12:39:20.267682+00	po	0
1381591a-a35a-4fc8-8823-cb66c47e7124	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 12:39:21.226324+00	po	2026-10-12 12:39:21.226324+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
9c967cf8-cc80-49b2-a48f-a3dd1513ef64	e41b9f32-feb2-4a8c-b230-f183416fcef3
c99fbc9b-2bef-4e03-be21-eb3edeca0140	58cc7d38-cc36-4819-83e1-c3e3238d7c99
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
9c967cf8-cc80-49b2-a48f-a3dd1513ef64	dc84cf01-48e1-4c96-8b54-0ebad6e010bd
9c967cf8-cc80-49b2-a48f-a3dd1513ef64	9864f436-f0e8-4dd9-b8d2-b7d372287bf6
c99fbc9b-2bef-4e03-be21-eb3edeca0140	dc84cf01-48e1-4c96-8b54-0ebad6e010bd
c99fbc9b-2bef-4e03-be21-eb3edeca0140	9864f436-f0e8-4dd9-b8d2-b7d372287bf6
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9c967cf8-cc80-49b2-a48f-a3dd1513ef64	a7592200-587e-47ad-a9c8-7d4db95efc3f	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 12:40:21.149214+00	qa2	2026-10-12 12:40:21.153977+00	qa2	1
c99fbc9b-2bef-4e03-be21-eb3edeca0140	a7592200-587e-47ad-a9c8-7d4db95efc3f	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 12:40:25.032219+00	qa1	2026-10-12 12:40:25.033777+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2c9b987f-361a-4fe3-99ac-d3fb2078348e	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 12:39:19.897908+00	po	2026-10-12 12:39:19.897908+00	po	0
eafcb598-c8f1-4119-89b1-c383f7a4e860	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	EXAMPLE	2c9b987f-361a-4fe3-99ac-d3fb2078348e	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 12:39:20.018665+00	po	2026-10-12 12:39:20.018665+00	po	0
3d550749-bb17-4cb2-9473-b315af441c7b	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	EXAMPLE	2c9b987f-361a-4fe3-99ac-d3fb2078348e	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 12:39:20.077484+00	po	2026-10-12 12:39:20.077484+00	po	0
3bbb7c7f-b4fb-4f20-ba9a-3c3ec56d2ddb	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 12:39:20.134535+00	po	2026-10-12 12:39:20.134535+00	po	0
96fbf487-ef44-40c5-945b-09f2e1eb505b	02eb10ab-01de-468a-9d8c-7e75f4e05c6b	EXAMPLE	3bbb7c7f-b4fb-4f20-ba9a-3c3ec56d2ddb	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 12:39:20.200448+00	po	2026-10-12 12:39:20.200448+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7f436f34-da6e-4b1e-aecd-fdfc79c8109e	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact", "Playwright", "Cypress", "Selenium", "pytest", "pytest + requests", "Robot Framework", "Cucumber-JS"]	[]	4	t	2026-10-12 12:39:10.718941+00	admin	2026-10-12 12:41:17.328757+00	system	4
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
5952dc7b-f30c-4edd-a983-725c02735454	5ac44fcc-27c8-4fbf-9e30-dedd7dd2eb6a	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	1	PASSED	f	2026-10-12 12:39:36.194038+00	2026-10-12 12:39:36.895756+00	701	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 12:39:36.199251+00	qa1	2026-10-12 12:39:36.898424+00	qa1	1	\N
662f0260-30b8-4c4a-9030-f0f868253a98	bf4f678b-84c7-4a88-b507-045a94f93d71	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	1	PASSED	f	2026-10-12 12:39:36.988348+00	2026-10-12 12:39:37.021993+00	33	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 12:39:36.990934+00	qa1	2026-10-12 12:39:37.023026+00	qa1	1	\N
3f5e52ba-f991-4432-a2bd-271574ae02be	d43068cd-16eb-4cd6-8522-a9b88f4287c8	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	1	PASSED	f	2026-10-12 12:39:37.036628+00	2026-10-12 12:39:37.068379+00	31	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 12:39:37.038176+00	qa1	2026-10-12 12:39:37.069414+00	qa1	1	\N
f1f03492-6fc4-4e60-a448-1ff8483f9cc1	b17c442e-1816-4e90-9726-e3a17af16d7b	8f843627-d65f-4abd-a65d-b74e5e8de2b0	1	1	PASSED	f	2026-10-12 12:40:06.472907+00	2026-10-12 12:40:09.90626+00	3431	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:39:38.488245+00	dev	2026-10-12 12:40:09.923708+00	anonymousUser	2	96177475-ad0a-4966-8768-63cb806036f1
13d8384d-740d-4e1a-9717-ea5e767c9f86	6c29d87c-a767-4d4a-85ed-b1593b3e2cde	ee55515a-64b4-40e0-a4d1-1740035e9b64	1	1	PASSED	f	2026-10-12 12:40:06.472988+00	2026-10-12 12:40:10.055435+00	3582	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:39:38.488602+00	dev	2026-10-12 12:40:10.067122+00	anonymousUser	2	96177475-ad0a-4966-8768-63cb806036f1
3e80282f-8a61-42c1-982d-4e3574a44c84	f39755a0-be30-4af0-a23a-3351da688be6	6a9be277-8e4c-4564-b119-1be12622f814	1	1	PASSED	f	2026-10-12 12:40:06.473012+00	2026-10-12 12:40:10.604088+00	4130	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:39:38.488602+00	dev	2026-10-12 12:40:10.615849+00	anonymousUser	2	96177475-ad0a-4966-8768-63cb806036f1
3999edfc-0726-462b-99a5-14d45fe51e34	46c6ae5c-2014-4315-a4d0-f285926cce5c	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	1	1	PASSED	f	2026-10-12 12:39:38.484457+00	2026-10-12 12:40:11.755375+00	5282	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:39:38.488245+00	dev	2026-10-12 12:40:11.767895+00	anonymousUser	1	96177475-ad0a-4966-8768-63cb806036f1
0167ca96-a3e3-43df-bdb7-bfeb79661f56	c0f339ed-00f4-4af2-98f2-6bc5564071f5	f93c33e1-c462-4306-a66e-d962f7a8339a	1	1	PASSED	f	2026-10-12 12:40:09.939739+00	2026-10-12 12:40:11.876332+00	1936	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:39:38.488602+00	dev	2026-10-12 12:40:11.890749+00	anonymousUser	2	96177475-ad0a-4966-8768-63cb806036f1
e41b9f32-feb2-4a8c-b230-f183416fcef3	e321caa6-df6c-4cf3-8c11-61356c7997d3	261b830e-e4e5-46ef-93e1-63df247e784e	1	1	FAILED	f	2026-10-12 12:40:18.940696+00	2026-10-12 12:40:19.726993+00	786	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.728026+00	qa2	1	\N
1539c405-d34b-4abe-8620-3aad61024593	6cbc35ce-b4a6-4e9c-a449-fc4c26894e92	a9fcdd24-651e-4927-8b43-72eec5356920	1	1	PASSED	f	2026-10-12 12:40:21.681349+00	2026-10-12 12:40:22.623841+00	942	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 12:40:21.685281+00	qa1	2026-10-12 12:40:22.624871+00	qa1	1	\N
eefe2982-2ac9-4850-986a-f1874e88ac4d	b8e39cff-f67a-4a5b-935f-b1c1a4c47f78	a9fcdd24-651e-4927-8b43-72eec5356920	1	1	PASSED	f	2026-10-12 12:40:22.669241+00	2026-10-12 12:40:22.736835+00	67	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 12:40:22.67251+00	qa1	2026-10-12 12:40:22.737959+00	qa1	1	\N
58cc7d38-cc36-4819-83e1-c3e3238d7c99	dda23dac-c003-428e-a8b0-74b37230a6df	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 12:40:23.645104+00	qa1	2026-10-12 12:40:26.330967+00	qa1	1	\N
4530f4b4-db21-465f-92f8-8e96f22e0bc3	903a0a09-084a-4d48-87e0-dcf5f1eab705	596ba90e-a60f-4580-aad7-926587affcce	1	2	PASSED	f	2026-10-12 12:40:50.705013+00	2026-10-12 12:40:54.447862+00	3743	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:40:29.046364+00	dev	2026-10-12 12:40:54.460104+00	anonymousUser	2	c8306261-d14c-4c8d-babd-37df438e789e
3e401882-3a4e-4e34-92e5-021161a246e4	ab3b4a7a-0bf1-4ac0-874f-3f740266c69f	ee55515a-64b4-40e0-a4d1-1740035e9b64	1	1	PASSED	f	2026-10-12 12:41:00.736436+00	2026-10-12 12:41:01.178436+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.198765+00	qa1	2026-10-12 12:41:01.198765+00	qa1	0	\N
4f9b773d-fb22-442a-9f15-1c5b4e16edc2	87ed9f3b-1a35-444a-8ede-9595bff32e3e	f00293bd-6193-4e68-bc74-6f071fd46723	1	1	PASSED	f	2026-10-12 12:40:50.70496+00	2026-10-12 12:40:54.877879+00	4173	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:40:29.046977+00	dev	2026-10-12 12:40:54.887684+00	anonymousUser	2	c8306261-d14c-4c8d-babd-37df438e789e
8da9dca1-6118-4823-b792-0e1140040a0c	a5dbdadb-e6e2-4a5d-b226-440ada996a39	27184d29-f9bd-4eba-8858-0642eef37143	1	1	PASSED	f	2026-10-12 12:40:50.704922+00	2026-10-12 12:40:54.460072+00	3755	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:40:29.046977+00	dev	2026-10-12 12:40:54.992923+00	anonymousUser	2	c8306261-d14c-4c8d-babd-37df438e789e
0413cef8-77d6-42b0-8722-82bb66c27537	c48d9b00-387e-41c4-a36e-0c206846b1a2	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	1	1	FAILED	f	2026-10-12 12:40:50.705027+00	2026-10-12 12:40:57.422552+00	6718	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-5b7aeac2/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:40:29.046977+00	dev	2026-10-12 12:40:57.43979+00	anonymousUser	2	c8306261-d14c-4c8d-babd-37df438e789e
ec149bdd-3c7e-4e22-9d0d-b7eaaed4b975	7380d016-dc1a-4805-9108-9a8ff9fde7c3	6a9be277-8e4c-4564-b119-1be12622f814	1	1	PASSED	f	2026-10-12 12:41:00.616436+00	2026-10-12 12:41:01.178436+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.181712+00	qa1	2026-10-12 12:41:01.181712+00	qa1	0	\N
c3b93378-eca0-441e-909e-40e852496b10	9db0fc39-b8a1-4218-a6f5-880a85974c0a	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	1	1	PASSED	f	2026-10-12 12:40:57.663436+00	2026-10-12 12:41:01.178436+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.189344+00	qa1	2026-10-12 12:41:01.189344+00	qa1	0	\N
e03bbb10-eaa4-4fb3-9533-42f4870f5392	e56bbbde-ad43-45fa-8c89-e27851b14e11	8f843627-d65f-4abd-a65d-b74e5e8de2b0	1	1	PASSED	f	2026-10-12 12:40:57.973436+00	2026-10-12 12:41:01.178436+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.194449+00	qa1	2026-10-12 12:41:01.194449+00	qa1	0	\N
847e4789-053b-49a1-ac5a-8339735d87e8	d5505362-d32f-4017-8687-a00fcd87df16	f93c33e1-c462-4306-a66e-d962f7a8339a	1	1	PASSED	f	2026-10-12 12:41:00.641436+00	2026-10-12 12:41:01.178436+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.202751+00	qa1	2026-10-12 12:41:01.202751+00	qa1	0	\N
027534b1-2d66-46b3-9a6a-478ca9939fa9	456a3e13-e5ab-4e55-80c5-f3469f9b2c16	596ba90e-a60f-4580-aad7-926587affcce	1	2	PASSED	f	2026-10-12 12:41:00.491436+00	2026-10-12 12:41:01.178436+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.206746+00	qa1	2026-10-12 12:41:01.206746+00	qa1	0	\N
dd37ecb9-3c09-43b1-9f08-1d7f468619fe	eac49b7d-2237-45fc-958b-383fa9091218	27184d29-f9bd-4eba-8858-0642eef37143	1	1	PASSED	f	2026-10-12 12:41:00.631436+00	2026-10-12 12:41:01.178436+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.211609+00	qa1	2026-10-12 12:41:01.211609+00	qa1	0	\N
a62a9569-1a2a-4102-8a4d-a3bc9e0cc1ae	ea457f42-f1b6-440d-ba8f-cd3e0a84b636	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	1	1	FAILED	f	2026-10-12 12:40:57.710436+00	2026-10-12 12:41:01.178436+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.216764+00	qa1	2026-10-12 12:41:01.216764+00	qa1	0	\N
bce6e98f-82fa-4a97-bbe4-d45aafa666b6	35a71949-24f0-4611-963d-a4757884feb2	f00293bd-6193-4e68-bc74-6f071fd46723	1	1	PASSED	f	2026-10-12 12:41:00.364436+00	2026-10-12 12:41:01.178436+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:41:01.22079+00	qa1	2026-10-12 12:41:01.22079+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
75775fac-8299-4269-9695-ea7caecac07f	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 12:39:26.797037+00	qa1	2026-10-12 12:39:26.797037+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ff158847-a5cb-4555-8fd0-8cfd69e06937	58cc7d38-cc36-4819-83e1-c3e3238d7c99	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 12:40:23.645104+00	qa1	2026-10-12 12:40:27.383302+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 14:38:51.966055	95	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 14:38:52.090963	150	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 14:38:52.265523	168	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 14:38:52.457628	25	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 14:38:52.506837	13	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 14:38:52.536988	85	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 14:38:52.639306	143	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 14:38:52.797364	11	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 14:38:52.820916	10	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 14:38:52.844143	30	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 14:38:52.887568	61	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 14:38:52.967888	86	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 14:38:53.073256	26	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 14:38:53.11551	51	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 14:38:53.188753	51	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 14:38:53.256251	34	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 14:38:53.310497	19	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 14:38:53.347058	4	t
19	19	git sources	SQL	V19__git_sources.sql	1616532274	traceagile_demo	2026-10-12 14:38:53.365851	50	t
\.


--
-- Data for Name: git_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_projects" ("id", "source_id", "name", "default_branch", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e6dda626-ece9-46cc-aee4-a2214709f6f3	40bb75ef-643b-44ec-bf1c-82b5a7bc564b	traceagile	depots-git	\N	2026-10-12 12:39:11.446743+00	admin	2026-10-12 12:39:11.446743+00	admin	0
82fc4bbd-b8de-4104-8e1d-3649d354f315	3a4ccc8a-0d7d-4d80-a979-a2f9c3a4ef0b	saucedemo-e2e	master	\N	2026-10-12 12:39:11.483983+00	admin	2026-10-12 12:39:11.483983+00	admin	0
\.


--
-- Data for Name: git_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_sources" ("id", "name", "base_url", "auth_type", "username", "secret", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
40bb75ef-643b-44ec-bf1c-82b5a7bc564b	Dépôt local	file:///depots	NONE	\N	\N	Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)	2026-10-12 12:39:11.424829+00	admin	2026-10-12 12:39:11.424829+00	admin	0
3a4ccc8a-0d7d-4d80-a979-a2f9c3a4ef0b	kerware	https://github.com/kerware	NONE	\N	\N	Projets de formation (GitHub, public)	2026-10-12 12:39:11.471394+00	admin	2026-10-12 12:39:11.471394+00	admin	0
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ	18
a7592200-587e-47ad-a9c8-7d4db95efc3f	TC	14
a7592200-587e-47ad-a9c8-7d4db95efc3f	REL	2
a7592200-587e-47ad-a9c8-7d4db95efc3f	SPR	3
a7592200-587e-47ad-a9c8-7d4db95efc3f	DEF	3
a7592200-587e-47ad-a9c8-7d4db95efc3f	RUN	3
a7592200-587e-47ad-a9c8-7d4db95efc3f	CMP	4
a7592200-587e-47ad-a9c8-7d4db95efc3f	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
09e2cd0b-c1a0-4727-8ad5-176b99d2aa2a	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 12:39:23.764915+00	qa1	2026-10-12 12:39:23.764915+00	qa1	0	\N	{}	\N	\N
45a590a6-8965-4a68-ae0c-22dba72becbd	ccf4786e-39b1-431c-af24-6f75a7cab94c	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 12:39:23.765428+00	qa1	2026-10-12 12:39:23.765428+00	qa1	0	\N	{}	\N	\N
7e68df5b-2683-4363-baf7-2bc583aa4825	261b830e-e4e5-46ef-93e1-63df247e784e	1	\N	\N	\N	2026-10-12 12:39:23.864699+00	qa1	2026-10-12 12:39:23.864699+00	qa1	0	ccf4786e-39b1-431c-af24-6f75a7cab94c	{}	Comptes	problem_user
f0817ec6-f313-40d2-9088-ed90dbe154bf	261b830e-e4e5-46ef-93e1-63df247e784e	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 12:39:23.864699+00	qa1	2026-10-12 12:39:23.864699+00	qa1	0	\N	{}	\N	\N
61a3872d-1117-47f3-b9eb-a78e544c554c	261b830e-e4e5-46ef-93e1-63df247e784e	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 12:39:23.864699+00	qa1	2026-10-12 12:39:23.864699+00	qa1	0	\N	{}	\N	\N
a0123d85-66e4-4380-bdf1-39859053a5f3	261b830e-e4e5-46ef-93e1-63df247e784e	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 12:39:23.864699+00	qa1	2026-10-12 12:39:23.864699+00	qa1	0	\N	{}	\N	\N
f850c6e6-e078-492a-a9f4-d0067733af76	a9fcdd24-651e-4927-8b43-72eec5356920	1	\N	\N	\N	2026-10-12 12:39:26.875605+00	qa1	2026-10-12 12:39:26.875605+00	qa1	0	ccf4786e-39b1-431c-af24-6f75a7cab94c	{}	Comptes	standard_user
2ea48153-1732-43fc-846b-40e743bedc67	a9fcdd24-651e-4927-8b43-72eec5356920	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 12:39:26.875605+00	qa1	2026-10-12 12:39:26.875605+00	qa1	0	\N	{}	\N	\N
ccd7965b-8247-4f3d-a1a3-7c006209b964	a9fcdd24-651e-4927-8b43-72eec5356920	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 12:39:26.875605+00	qa1	2026-10-12 12:39:26.875605+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
6196db5c-5bee-492e-893d-2de1ec4b708d	09bbbe4e-4d4d-4643-b4c7-07319fd7b884	629	ms	p95Ms	TC-11	RUN-2	2026-10-12 12:40:54.877879+00	TARGET_MET	2026-10-12 12:40:54.897264+00	anonymousUser	2026-10-12 12:40:54.897264+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
29131535-bbff-442c-8dec-27b3dab6b453	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:39:38.57345+00
58f2831a-ca88-4ada-8ea8-dc46b2a13b07	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:06.482119+00
11471db2-d863-4968-8b30-ba43d13089fe	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:07.016571+00
197995d6-66b8-4281-a37c-f280f984e3e2	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:08.040205+00
b4703270-6791-4395-a800-25bfd44b3f0d	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:09.915753+00
d0fb21dd-4cf1-4b60-95d1-a1cac3eec133	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:09.947796+00
12f3330f-4484-4951-989f-3a6585e68090	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:10.063682+00
561d4a11-9ffd-46cb-b3b2-5bfda51b99e0	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:10.612231+00
73198cde-4f31-40f1-a35e-ded8cbe51377	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:11.762868+00
ee44b5d1-dc4a-4bf5-8aa8-62cf951a11f9	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:11.885213+00
370a08a4-9b4b-47e3-add9-e3d7a1f04513	96177475-ad0a-4966-8768-63cb806036f1	2026-10-12 12:40:11.912746+00
c09d2e47-fbae-463c-81e2-fbe7113b972b	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:29.094685+00
16d39923-e697-4d22-9473-b37d7512158d	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:50.7134+00
52bf7171-2813-417b-b2ff-60e6dc9f8c3b	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:51.232806+00
d4f74d00-d3a0-466d-b323-da30a1597df6	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:51.232806+00
bd71cb3c-a0e0-409e-bff2-ad84c13ba5b5	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:51.232806+00
ee4c850a-a3f3-4ded-acf8-6ed773a633f5	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:54.45539+00
369ccd7e-d332-4601-81aa-a0778ea74cee	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:54.884587+00
ef95eca4-3c7f-4319-b2cd-9c9946a656d7	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:54.98967+00
a64ec61c-d057-4060-aaf7-c332608eb0dd	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:57.431982+00
a458fa54-14e6-4db0-9cb3-96e9f86bc409	c8306261-d14c-4c8d-babd-37df438e789e	2026-10-12 12:40:57.460147+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0e8bb6cd-ee49-4374-83ea-1de6a4030cdb	a7592200-587e-47ad-a9c8-7d4db95efc3f	53e67d93-0813-4cef-b85f-e7abd0213569	ADMINISTRATOR	2026-10-12 12:39:09.441535+00	admin	2026-10-12 12:39:09.441535+00	admin	0
476bcb01-fbc7-4472-8d13-1ed9de132200	a7592200-587e-47ad-a9c8-7d4db95efc3f	83889936-10af-4f11-b88f-1cd5f5834b26	PRODUCT_OWNER	2026-10-12 12:39:09.441535+00	admin	2026-10-12 12:39:09.441535+00	admin	0
83a04881-1e08-4390-a2f6-179c80f66749	a7592200-587e-47ad-a9c8-7d4db95efc3f	f88ee032-a263-4d16-9f40-3c190c42eaef	TESTER	2026-10-12 12:39:09.441535+00	admin	2026-10-12 12:39:09.441535+00	admin	0
e05faf98-de1f-4da4-8c96-5422a7fd7e7d	a7592200-587e-47ad-a9c8-7d4db95efc3f	993752b1-4beb-4cf0-bc77-ccce4971bd89	TESTER	2026-10-12 12:39:09.442052+00	admin	2026-10-12 12:39:09.442052+00	admin	0
c0b28171-3b45-41f5-a44f-e21b799469e8	a7592200-587e-47ad-a9c8-7d4db95efc3f	b202ced4-22eb-4fa3-8c84-955369764d09	DEVELOPER	2026-10-12 12:39:09.442052+00	admin	2026-10-12 12:39:09.442052+00	admin	0
99f12538-0119-42f0-942a-29ecbfab1daa	a7592200-587e-47ad-a9c8-7d4db95efc3f	fa8cf5a0-3d64-4ce4-9464-95d4610998f9	VIEWER	2026-10-12 12:39:09.442052+00	admin	2026-10-12 12:39:09.442052+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
a7592200-587e-47ad-a9c8-7d4db95efc3f	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 12:39:09.29827+00	admin	2026-10-12 12:39:09.29827+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
71811338-d011-4ded-a0db-686a09014de7	a7592200-587e-47ad-a9c8-7d4db95efc3f	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 12:39:31.772674+00	po	2026-10-12 12:39:33.370536+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0735b8e7-c8e5-43d2-8806-d6ce0c8a5c15	a7592200-587e-47ad-a9c8-7d4db95efc3f	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 12:40:16.137311+00	po	2026-10-12 12:40:16.137311+00	po	0
8c5f21f2-0176-40c3-9aef-53328e87ef31	a7592200-587e-47ad-a9c8-7d4db95efc3f	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 12:40:16.149192+00	po	2026-10-12 12:40:16.149192+00	po	0
88e5c00f-7ef1-4b25-bc6f-6eb9631cb043	a7592200-587e-47ad-a9c8-7d4db95efc3f	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 12:41:16.961807+00	po	2026-10-12 12:41:16.961807+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ed0901c8-49c0-4fb5-9a79-3e3659049000	a7592200-587e-47ad-a9c8-7d4db95efc3f	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T12:40:16.179240200Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 12:40:16.211219+00	clôture du sprint	2026-10-12 12:40:16.211219+00	po	2026-10-12 12:40:16.212963+00	po	1
1a22da8b-df7a-4005-b6d7-513fcfdc1f7b	a7592200-587e-47ad-a9c8-7d4db95efc3f	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T12:41:13.544830500Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 12:41:15.023934+00	f	\N	\N	2026-10-12 12:41:13.558065+00	po	2026-10-12 12:41:15.023934+00	po	2
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
8de84c78-7392-4b58-a7b3-cd75fbc23f1e	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.322244+00	po	2026-10-12 12:39:16.322244+00	po	0
7be2a361-a797-40cb-a030-7e0873727a19	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.370644+00	po	2026-10-12 12:39:16.370644+00	po	0
9720684e-b276-4267-a8dd-f3798dcf715a	4222d787-b055-460f-b6fb-876f7f28c776	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.405551+00	po	2026-10-12 12:39:16.405551+00	po	0
1930afed-1ec0-42a2-9ab6-e241d10505db	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.44269+00	po	2026-10-12 12:39:16.44269+00	po	0
39c489ef-831b-4d34-89d3-cf6de6d09270	f0e7d617-1cee-475c-9edf-e9320686cb84	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.477455+00	po	2026-10-12 12:39:16.477455+00	po	0
2e902691-3e75-42b9-850d-788428c39649	3ff41af0-f5e0-408e-86c8-833b3b1ca617	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.512686+00	po	2026-10-12 12:39:16.512686+00	po	0
bb742413-4103-433d-aa4a-e0a5f657f892	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:16.547684+00	po	2026-10-12 12:39:16.547684+00	po	0
c4401400-41ab-4732-8844-0d8b2f118f75	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:39:17.555408+00	po	2026-10-12 12:39:17.555408+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
f26e6366-1ef1-4de1-92a7-8fcf3956957e	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 12:39:12.967823+00	po	2026-10-12 12:39:12.967823+00	po	0
c40a280d-1618-4254-ad3d-9e05cc4f7bbd	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 12:39:13.048293+00	po	2026-10-12 12:39:13.048293+00	po	0
c4ff77d5-2854-4092-900a-fcb5de411b62	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 12:39:13.193944+00	po	2026-10-12 12:39:13.193944+00	po	0
a616c143-5569-4a1d-a5f4-d35bf56738eb	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 12:39:13.355004+00	po	2026-10-12 12:39:13.355004+00	po	0
ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	c40a280d-1618-4254-ad3d-9e05cc4f7bbd	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 12:39:13.152222+00	po	2026-10-12 12:40:13.837658+00	po	3
4222d787-b055-460f-b6fb-876f7f28c776	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	c4ff77d5-2854-4092-900a-fcb5de411b62	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 12:39:13.237345+00	po	2026-10-12 12:40:13.877185+00	po	3
dc84cf01-48e1-4c96-8b54-0ebad6e010bd	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	a616c143-5569-4a1d-a5f4-d35bf56738eb	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 12:39:13.423785+00	po	2026-10-12 12:40:16.888853+00	po	2
760aa453-d250-4d3b-824c-9a5484497545	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 12:39:13.499663+00	po	2026-10-12 12:39:13.499663+00	po	0
02eb10ab-01de-468a-9d8c-7e75f4e05c6b	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	760aa453-d250-4d3b-824c-9a5484497545	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 12:39:13.533635+00	po	2026-10-12 12:39:13.533635+00	po	0
afb8a021-1ef8-458a-a45b-6ede51277b43	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	760aa453-d250-4d3b-824c-9a5484497545	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 12:39:15.237212+00	po	2026-10-12 12:39:15.237212+00	po	0
09bbbe4e-4d4d-4643-b4c7-07319fd7b884	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 12:39:15.481616+00	po	2026-10-12 12:39:15.481616+00	po	0
ed96f626-5e2f-4263-9051-35cd87544d59	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	f26e6366-1ef1-4de1-92a7-8fcf3956957e	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 12:39:15.515112+00	po	2026-10-12 12:39:15.515112+00	po	0
f0e7d617-1cee-475c-9edf-e9320686cb84	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	c4ff77d5-2854-4092-900a-fcb5de411b62	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 12:39:13.31714+00	po	2026-10-12 12:41:09.069907+00	po	4
8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	c40a280d-1618-4254-ad3d-9e05cc4f7bbd	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 12:39:13.103417+00	po	2026-10-12 12:40:13.797691+00	po	3
e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	c4ff77d5-2854-4092-900a-fcb5de411b62	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 12:39:13.278987+00	po	2026-10-12 12:40:13.913444+00	po	3
9864f436-f0e8-4dd9-b8d2-b7d372287bf6	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	a616c143-5569-4a1d-a5f4-d35bf56738eb	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 12:39:13.461724+00	po	2026-10-12 12:40:16.888853+00	po	2
3ff41af0-f5e0-408e-86c8-833b3b1ca617	a7592200-587e-47ad-a9c8-7d4db95efc3f	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	a616c143-5569-4a1d-a5f4-d35bf56738eb	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 12:39:13.385838+00	po	2026-10-12 12:40:16.888853+00	po	2
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9d76d241-7b82-4c8c-a522-3584d03920af	96177475-ad0a-4966-8768-63cb806036f1	f1f03492-6fc4-4e60-a448-1ff8483f9cc1	log-TC-4.txt	text/plain	SYSTEM_TRACE	484	2026-10-12 12:40:09.92215+00	anonymousUser	2026-10-12 12:40:09.92215+00	anonymousUser	0
7cf111a3-2143-414c-ab89-7653cea4608b	96177475-ad0a-4966-8768-63cb806036f1	13d8384d-740d-4e1a-9717-ea5e767c9f86	log-TC-5.txt	text/plain	SYSTEM_TRACE	390	2026-10-12 12:40:10.066353+00	anonymousUser	2026-10-12 12:40:10.066353+00	anonymousUser	0
29483044-7083-498b-8137-6a3ca28c938c	96177475-ad0a-4966-8768-63cb806036f1	3e80282f-8a61-42c1-982d-4e3574a44c84	log-TC-7.txt	text/plain	SYSTEM_TRACE	394	2026-10-12 12:40:10.614821+00	anonymousUser	2026-10-12 12:40:10.614821+00	anonymousUser	0
6e34f533-7471-4d84-8c7c-02517498e769	96177475-ad0a-4966-8768-63cb806036f1	3999edfc-0726-462b-99a5-14d45fe51e34	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 12:40:11.766871+00	anonymousUser	2026-10-12 12:40:11.766871+00	anonymousUser	0
fe01a89e-5101-4708-99c9-6c905f8efc64	96177475-ad0a-4966-8768-63cb806036f1	0167ca96-a3e3-43df-bdb7-bfeb79661f56	log-TC-6.txt	text/plain	SYSTEM_TRACE	376	2026-10-12 12:40:11.889204+00	anonymousUser	2026-10-12 12:40:11.889204+00	anonymousUser	0
476db08a-ed07-4920-b783-e5121f453863	96177475-ad0a-4966-8768-63cb806036f1	\N	system.log	text/plain	SYSTEM_TRACE	4696	2026-10-12 12:40:11.914278+00	anonymousUser	2026-10-12 12:40:11.914278+00	anonymousUser	0
241177af-c064-413a-8b52-9bbabe7bdbb5	96177475-ad0a-4966-8768-63cb806036f1	\N	junit.xml	application/xml	JUNIT	1187	2026-10-12 12:40:11.916861+00	anonymousUser	2026-10-12 12:40:11.916861+00	anonymousUser	0
e31f03b7-965c-4395-b705-7051eba64a84	96177475-ad0a-4966-8768-63cb806036f1	\N	report.json	application/json	REPORT	484	2026-10-12 12:40:11.92033+00	anonymousUser	2026-10-12 12:40:11.92033+00	anonymousUser	0
31ee90ca-cc6e-4195-8426-5436a50150ad	c8306261-d14c-4c8d-babd-37df438e789e	4530f4b4-db21-465f-92f8-8e96f22e0bc3	log-TC-8.txt	text/plain	SYSTEM_TRACE	360	2026-10-12 12:40:54.458994+00	anonymousUser	2026-10-12 12:40:54.458994+00	anonymousUser	0
1b0e6e7b-4ce4-4a04-824e-d35dc78d7c72	c8306261-d14c-4c8d-babd-37df438e789e	4f9b773d-fb22-442a-9f15-1c5b4e16edc2	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 12:40:54.88717+00	anonymousUser	2026-10-12 12:40:54.88717+00	anonymousUser	0
1ab63fa5-b895-439e-9f70-e031b4b5748e	c8306261-d14c-4c8d-babd-37df438e789e	8da9dca1-6118-4823-b792-0e1140040a0c	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 12:40:54.991889+00	anonymousUser	2026-10-12 12:40:54.991889+00	anonymousUser	0
4a9e786b-4ebd-48f0-bfdb-3592fb9a4088	c8306261-d14c-4c8d-babd-37df438e789e	0413cef8-77d6-42b0-8722-82bb66c27537	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 12:40:57.435684+00	anonymousUser	2026-10-12 12:40:57.435684+00	anonymousUser	0
e0b3fa35-962b-4003-b1cf-03f879af79c3	c8306261-d14c-4c8d-babd-37df438e789e	0413cef8-77d6-42b0-8722-82bb66c27537	log-TC-10.txt	text/plain	SYSTEM_TRACE	3392	2026-10-12 12:40:57.439167+00	anonymousUser	2026-10-12 12:40:57.439167+00	anonymousUser	0
2228b556-194f-4ff1-8f4d-c2caa5961132	c8306261-d14c-4c8d-babd-37df438e789e	\N	system.log	text/plain	SYSTEM_TRACE	8560	2026-10-12 12:40:57.462859+00	anonymousUser	2026-10-12 12:40:57.462859+00	anonymousUser	0
07bda297-5554-4911-b248-6a48b6288cb6	c8306261-d14c-4c8d-babd-37df438e789e	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 12:40:57.465949+00	anonymousUser	2026-10-12 12:40:57.465949+00	anonymousUser	0
061d49da-c9e6-485c-b821-f4c063fc619b	c8306261-d14c-4c8d-babd-37df438e789e	\N	report.json	application/json	REPORT	475	2026-10-12 12:40:57.46808+00	anonymousUser	2026-10-12 12:40:57.46808+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
78a2f981-d2e2-4988-bdcb-150d05c5e285	ff158847-a5cb-4555-8fd0-8cfd69e06937	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 12:40:23.77653+00	qa1	2026-10-12 12:40:23.77653+00	qa1	0
c712129b-2cf3-424d-9ac0-2aad4cd07761	ff158847-a5cb-4555-8fd0-8cfd69e06937	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 12:40:23.885164+00	qa1	2026-10-12 12:40:23.885164+00	qa1	0
e50da20a-6c01-4188-b030-072f00573af5	ff158847-a5cb-4555-8fd0-8cfd69e06937	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 12:40:24.081028+00	qa1	2026-10-12 12:40:24.081028+00	qa1	0
b4f1f16a-36a4-4408-b99a-8e0ee942ebb2	ff158847-a5cb-4555-8fd0-8cfd69e06937	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 12:40:24.165483+00	qa1	2026-10-12 12:40:24.165483+00	qa1	0
7605ba2b-818c-4e32-9c04-5aa076c44d78	ff158847-a5cb-4555-8fd0-8cfd69e06937	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	c99fbc9b-2bef-4e03-be21-eb3edeca0140	2026-10-12 12:40:23.953863+00	qa1	2026-10-12 12:40:25.033777+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
06616e02-9442-4536-88c8-3b3b9feffc57	059d2bef-6dd1-4f36-ab15-73b6e99c897a	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	1	3	DONE	2026-10-12 12:39:32.537945+00	po	2026-10-12 12:40:16.139606+00	po	1
2e4fd008-8db1-4673-a070-70f881192356	059d2bef-6dd1-4f36-ab15-73b6e99c897a	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	2	2	DONE	2026-10-12 12:39:32.605443+00	po	2026-10-12 12:40:16.139606+00	po	1
ae0fbc2c-3f22-4d30-a192-4272e9b613da	059d2bef-6dd1-4f36-ab15-73b6e99c897a	4222d787-b055-460f-b6fb-876f7f28c776	3	3	DONE	2026-10-12 12:39:32.68652+00	po	2026-10-12 12:40:16.139606+00	po	1
2a341f41-abc0-4543-a09a-24ada796a134	059d2bef-6dd1-4f36-ab15-73b6e99c897a	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	4	2	DONE	2026-10-12 12:39:32.754055+00	po	2026-10-12 12:40:16.139606+00	po	1
a8bcc952-c88a-489a-b8cf-326e71379fb9	059d2bef-6dd1-4f36-ab15-73b6e99c897a	f0e7d617-1cee-475c-9edf-e9320686cb84	5	2	DONE	2026-10-12 12:39:32.822838+00	po	2026-10-12 12:40:16.139606+00	po	1
e335be9e-07c6-42da-9606-7b6261599ab9	4cb4463e-4b72-468e-af4e-272bc7cb7d82	3ff41af0-f5e0-408e-86c8-833b3b1ca617	1	3	PLANNED	2026-10-12 12:40:16.834754+00	po	2026-10-12 12:40:16.834754+00	po	0
885a3f81-0341-43a9-a3aa-8e152da4387e	4cb4463e-4b72-468e-af4e-272bc7cb7d82	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	2	3	PLANNED	2026-10-12 12:40:16.834754+00	po	2026-10-12 12:40:16.834754+00	po	0
d3df6f4c-fb95-4e54-8962-6630ce939f46	4cb4463e-4b72-468e-af4e-272bc7cb7d82	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	3	2	PLANNED	2026-10-12 12:40:16.834754+00	po	2026-10-12 12:40:16.834754+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
059d2bef-6dd1-4f36-ab15-73b6e99c897a	a7592200-587e-47ad-a9c8-7d4db95efc3f	71811338-d011-4ded-a0db-686a09014de7	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 12:39:31.806388+00	po	2026-10-12 12:40:16.1391+00	po	2
4cb4463e-4b72-468e-af4e-272bc7cb7d82	a7592200-587e-47ad-a9c8-7d4db95efc3f	71811338-d011-4ded-a0db-686a09014de7	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 12:39:31.854643+00	po	2026-10-12 12:40:16.888853+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
49aded88-e812-4e17-8753-df9a4a9df10e	5952dc7b-f30c-4edd-a983-725c02735454	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:39:36.200286+00	qa1	2026-10-12 12:39:36.333774+00	qa1	1	\N
9a87bbd8-03bf-4eed-8b59-af80e0449c7a	5952dc7b-f30c-4edd-a983-725c02735454	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:39:36.200286+00	qa1	2026-10-12 12:39:36.898424+00	qa1	1	\N
b30a7f05-a2a5-4cc9-8fec-9ab553808557	662f0260-30b8-4c4a-9030-f0f868253a98	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:39:36.990934+00	qa1	2026-10-12 12:39:37.007662+00	qa1	1	\N
de407b2b-08bd-42d3-972e-062dde951224	662f0260-30b8-4c4a-9030-f0f868253a98	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 12:39:36.990934+00	qa1	2026-10-12 12:39:37.023026+00	qa1	1	\N
22850f36-5f0f-4983-8563-41ad36327648	3f5e52ba-f991-4432-a2bd-271574ae02be	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:39:37.038686+00	qa1	2026-10-12 12:39:37.054021+00	qa1	1	\N
a25cfe0a-9d3e-447e-81ba-34cebb6c5af2	3f5e52ba-f991-4432-a2bd-271574ae02be	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:39:37.038686+00	qa1	2026-10-12 12:39:37.069414+00	qa1	1	\N
0c69e1b3-e077-4bb9-b436-d1b12016725c	e41b9f32-feb2-4a8c-b230-f183416fcef3	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.0916+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
808ef0d5-e808-44b4-8532-e7b5abf50a68	e41b9f32-feb2-4a8c-b230-f183416fcef3	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.212751+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
67d01de5-2590-40af-99b8-44e9c522baa1	e41b9f32-feb2-4a8c-b230-f183416fcef3	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.327918+00	qa2	1	\N
31f6e7b5-04fe-47b2-933a-cb684fad4ea8	e41b9f32-feb2-4a8c-b230-f183416fcef3	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.44622+00	qa2	1	\N
3f525bb7-bfd5-45b0-9360-09994b947a31	e41b9f32-feb2-4a8c-b230-f183416fcef3	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 12:40:18.945378+00	qa2	2026-10-12 12:40:19.728026+00	qa2	1	\N
49ca5392-c283-4d48-8529-62b5461bf879	1539c405-d34b-4abe-8620-3aad61024593	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:40:21.685797+00	qa1	2026-10-12 12:40:21.809582+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
9aa518e6-ee30-4aad-ba4c-85ac580f4570	1539c405-d34b-4abe-8620-3aad61024593	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:40:21.685797+00	qa1	2026-10-12 12:40:22.394411+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
63217a4d-26a1-491a-b8cd-435c94e6da3e	1539c405-d34b-4abe-8620-3aad61024593	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:40:21.685797+00	qa1	2026-10-12 12:40:22.513347+00	qa1	1	\N
9a045cae-429b-4233-bb62-30992ed1ae01	1539c405-d34b-4abe-8620-3aad61024593	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 12:40:21.685797+00	qa1	2026-10-12 12:40:22.624871+00	qa1	1	\N
230bac3d-196e-48e2-9588-0709c78d77a5	eefe2982-2ac9-4850-986a-f1874e88ac4d	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:40:22.67251+00	qa1	2026-10-12 12:40:22.692505+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
db633647-7b24-4f37-8432-ccbc88c687f4	eefe2982-2ac9-4850-986a-f1874e88ac4d	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:40:22.67251+00	qa1	2026-10-12 12:40:22.709734+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
a4b96734-1713-41e2-8213-6fbc27abf4fc	eefe2982-2ac9-4850-986a-f1874e88ac4d	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:40:22.673029+00	qa1	2026-10-12 12:40:22.723815+00	qa1	1	\N
465ca423-23f2-4185-9d3b-d86c8c40f281	eefe2982-2ac9-4850-986a-f1874e88ac4d	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 12:40:22.673029+00	qa1	2026-10-12 12:40:22.737959+00	qa1	1	\N
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
b04703b2-4ce7-4e82-9c4e-1bcb2d4d9236	ccf4786e-39b1-431c-af24-6f75a7cab94c	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 12:39:23.768012+00	qa1	2026-10-12 12:39:23.768012+00	qa1	0
09a5a4e4-2ae1-4b81-9e2a-12daab7adf14	261b830e-e4e5-46ef-93e1-63df247e784e	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 12:39:23.866258+00	qa1	2026-10-12 12:39:23.866258+00	qa1	0
5190cf8f-5662-4bf8-b20a-9c0284a98a8e	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "depots-git", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:23.9461+00	dev	2026-10-12 12:39:23.9461+00	dev	0
65cda224-31ae-4c3d-ae69-f276839ccce7	8f843627-d65f-4abd-a65d-b74e5e8de2b0	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:24.017646+00	dev	2026-10-12 12:39:24.017646+00	dev	0
0bd5d973-d3f3-4906-a9b9-d523f8bae36e	ee55515a-64b4-40e0-a4d1-1740035e9b64	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:24.078383+00	dev	2026-10-12 12:39:24.078383+00	dev	0
3afc1229-497f-4745-991f-9e6f11a150c8	f93c33e1-c462-4306-a66e-d962f7a8339a	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:24.152527+00	dev	2026-10-12 12:39:24.152527+00	dev	0
0014d504-0a78-41f8-a1be-74984a2ce627	6a9be277-8e4c-4564-b119-1be12622f814	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "depots-git", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:24.216164+00	dev	2026-10-12 12:39:24.216164+00	dev	0
ac91f7b6-a570-4ee3-9be6-25eb8b4a036c	596ba90e-a60f-4580-aad7-926587affcce	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:25.57392+00	qa1	2026-10-12 12:39:25.57392+00	qa1	0
23d457b1-1159-40be-98a7-ef2ddb7efa78	596ba90e-a60f-4580-aad7-926587affcce	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "depots-git", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:25.711891+00	qa1	2026-10-12 12:39:25.711891+00	qa1	0
0b80b3e9-a934-4232-bb13-e0d0a116839a	27184d29-f9bd-4eba-8858-0642eef37143	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:26.575104+00	dev	2026-10-12 12:39:26.575104+00	dev	0
c1a353f0-1aeb-4725-b05a-c4cf8aecc90f	a9fcdd24-651e-4927-8b43-72eec5356920	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 12:39:26.875605+00	qa1	2026-10-12 12:39:26.875605+00	qa1	0
d15b8170-f21f-45f4-847b-ffbfbef2f146	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:26.650564+00	dev	2026-10-12 12:39:26.650564+00	dev	0
4cf1fe3a-0db8-41f3-b4eb-fb55a475dcec	f00293bd-6193-4e68-bc74-6f071fd46723	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "depots-git", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:39:26.727923+00	dev	2026-10-12 12:39:26.727923+00	dev	0
4629fe05-45df-4fda-889d-1fa3962d5b86	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 12:39:26.797037+00	qa1	2026-10-12 12:39:26.797037+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
ccf4786e-39b1-431c-af24-6f75a7cab94c	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 12:39:23.760478+00	qa1	2026-10-12 12:39:23.832595+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
261b830e-e4e5-46ef-93e1-63df247e784e	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 12:39:23.864182+00	qa1	2026-10-12 12:39:23.909645+00	qa1	1	[]	[]	f
b2211fe1-4ee0-4afa-bda2-7a53cc72b121	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 12:39:23.942772+00	dev	2026-10-12 12:39:23.985963+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
8f843627-d65f-4abd-a65d-b74e5e8de2b0	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 12:39:24.017125+00	dev	2026-10-12 12:39:24.054414+00	qa1	1	[]	[]	f
ee55515a-64b4-40e0-a4d1-1740035e9b64	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 12:39:24.078383+00	dev	2026-10-12 12:39:24.121471+00	qa1	1	[]	[]	f
6a9be277-8e4c-4564-b119-1be12622f814	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 12:39:24.215624+00	dev	2026-10-12 12:39:24.251142+00	qa1	1	[]	[]	f
ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 12:39:26.650012+00	dev	2026-10-12 12:39:26.690617+00	qa1	1	[]	[]	f
596ba90e-a60f-4580-aad7-926587affcce	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 12:39:25.573512+00	qa1	2026-10-12 12:39:25.720026+00	qa1	2	[]	[]	f
27184d29-f9bd-4eba-8858-0642eef37143	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 12:39:26.574574+00	dev	2026-10-12 12:39:26.616198+00	qa1	1	[]	[]	f
f00293bd-6193-4e68-bc74-6f071fd46723	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 12:39:26.727389+00	dev	2026-10-12 12:39:26.769405+00	qa1	1	[]	[]	f
4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 12:39:26.795473+00	qa1	2026-10-12 12:39:26.84228+00	qa1	1	[]	[]	f
a9fcdd24-651e-4927-8b43-72eec5356920	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 12:39:26.874685+00	qa1	2026-10-12 12:39:26.924799+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
f93c33e1-c462-4306-a66e-d962f7a8339a	a7592200-587e-47ad-a9c8-7d4db95efc3f	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 12:39:24.152527+00	dev	2026-10-12 12:41:09.079278+00	po	2	[]	[]	f
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
1c2ab810-96af-4edd-a784-16c736cef2e7	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ccf4786e-39b1-431c-af24-6f75a7cab94c	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	VERIFIES	MANUAL	2026-10-12 12:39:23.777604+00	qa1	2026-10-12 12:39:23.777604+00	qa1	0	\N
e5b4ed2a-4b2c-4bb4-a68b-89bb677f92b2	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ccf4786e-39b1-431c-af24-6f75a7cab94c	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	VERIFIES	MANUAL	2026-10-12 12:39:23.777604+00	qa1	2026-10-12 12:39:23.777604+00	qa1	0	\N
e0358879-f513-49e5-bfb0-6b11233a6d16	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	261b830e-e4e5-46ef-93e1-63df247e784e	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	PARTIALLY_VERIFIES	MANUAL	2026-10-12 12:39:23.871495+00	qa1	2026-10-12 12:39:23.871495+00	qa1	0	\N
c9c23f60-f155-4a60-af4c-d7b4c1cb3fca	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	261b830e-e4e5-46ef-93e1-63df247e784e	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	VERIFIES	MANUAL	2026-10-12 12:39:23.872009+00	qa1	2026-10-12 12:39:23.872009+00	qa1	0	\N
5ac23714-0b8f-4674-b179-298ea547127a	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	REQUIREMENT	8f85bba5-4e84-4bd3-9a4d-2dcf54578e01	VERIFIES	MANUAL	2026-10-12 12:39:23.95151+00	dev	2026-10-12 12:39:23.95151+00	dev	0	\N
df14037b-4b2b-4005-9179-edfcf478e8d8	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	b2211fe1-4ee0-4afa-bda2-7a53cc72b121	REQUIREMENT	ffb5a35b-b89d-4361-87ca-95ecf3b4c1bd	VERIFIES	MANUAL	2026-10-12 12:39:23.95151+00	dev	2026-10-12 12:39:23.95151+00	dev	0	\N
5f171650-def9-485e-a7f8-92d90f621cb0	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	8f843627-d65f-4abd-a65d-b74e5e8de2b0	REQUIREMENT	4222d787-b055-460f-b6fb-876f7f28c776	VERIFIES	MANUAL	2026-10-12 12:39:24.020757+00	dev	2026-10-12 12:39:24.020757+00	dev	0	\N
d64e19c6-6883-42cb-870a-6a23559afc45	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ee55515a-64b4-40e0-a4d1-1740035e9b64	REQUIREMENT	e5ef1ad6-e8f0-4ac8-9276-40e2b0f23823	VERIFIES	MANUAL	2026-10-12 12:39:24.078383+00	dev	2026-10-12 12:39:24.078383+00	dev	0	\N
01887a9c-7861-4974-937c-e3488e015636	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	6a9be277-8e4c-4564-b119-1be12622f814	REQUIREMENT	ed96f626-5e2f-4263-9051-35cd87544d59	VERIFIES	MANUAL	2026-10-12 12:39:24.219771+00	dev	2026-10-12 12:39:24.219771+00	dev	0	\N
c6c1225e-a870-48ca-97ef-e097eb9a4094	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	596ba90e-a60f-4580-aad7-926587affcce	REQUIREMENT	3ff41af0-f5e0-408e-86c8-833b3b1ca617	VERIFIES	GHERKIN_TAG	2026-10-12 12:39:25.578203+00	qa1	2026-10-12 12:39:25.578203+00	qa1	0	\N
2620819c-1abe-4282-91ba-44a7786dd950	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	596ba90e-a60f-4580-aad7-926587affcce	ACCEPTANCE_CRITERION	09c4b8d7-7806-4896-9b23-a3e56e5a71c7	VERIFIES	GHERKIN_TAG	2026-10-12 12:39:25.587855+00	qa1	2026-10-12 12:39:25.587855+00	qa1	0	\N
b73c25a7-de67-490a-91a3-de352afcde2c	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	27184d29-f9bd-4eba-8858-0642eef37143	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	VERIFIES	MANUAL	2026-10-12 12:39:26.577564+00	dev	2026-10-12 12:39:26.577564+00	dev	0	\N
3d366df6-81a9-43d9-b17c-ce71036aeb46	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	ce6c9548-ce4c-4e49-9b21-d48f5bfa4d89	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	VERIFIES	MANUAL	2026-10-12 12:39:26.6538+00	dev	2026-10-12 12:39:26.6538+00	dev	0	\N
47185cd2-4985-472d-905c-6f56952327a0	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f00293bd-6193-4e68-bc74-6f071fd46723	REQUIREMENT	09bbbe4e-4d4d-4643-b4c7-07319fd7b884	VERIFIES	MANUAL	2026-10-12 12:39:26.731364+00	dev	2026-10-12 12:39:26.731364+00	dev	0	\N
6b19c586-7860-40cf-ad6c-ef260f33077d	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	VERIFIES	MANUAL	2026-10-12 12:39:26.80155+00	qa1	2026-10-12 12:39:26.80155+00	qa1	0	\N
44eaff1b-d5b1-4da3-8b00-6b6e31676cc6	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	4c55e0bc-cd0a-42d4-aa8b-cf599ef09755	REQUIREMENT	9864f436-f0e8-4dd9-b8d2-b7d372287bf6	VERIFIES	MANUAL	2026-10-12 12:39:26.802085+00	qa1	2026-10-12 12:39:26.802085+00	qa1	0	\N
dc1c0c4b-f654-4b67-81fd-61cfa1536076	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	a9fcdd24-651e-4927-8b43-72eec5356920	REQUIREMENT	dc84cf01-48e1-4c96-8b54-0ebad6e010bd	VERIFIES	MANUAL	2026-10-12 12:39:26.878437+00	qa1	2026-10-12 12:39:26.878437+00	qa1	0	\N
276d0d05-35b2-4480-afbf-98d26730f571	a7592200-587e-47ad-a9c8-7d4db95efc3f	TEST_CASE	f93c33e1-c462-4306-a66e-d962f7a8339a	REQUIREMENT	f0e7d617-1cee-475c-9edf-e9320686cb84	VERIFIES	MANUAL	2026-10-12 12:39:24.156749+00	dev	2026-10-12 12:41:09.735865+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
53e67d93-0813-4cef-b85f-e7abd0213569	admin	admin@traceagile.local	Administrateur	$2a$12$2yeockDrI.UurBmIRDBDC.mqKVwJWGCSVd5AKXLbIdo4CvAzPE3za	t	t	2026-10-12 12:38:57.578115+00	system	2026-10-12 12:38:57.578115+00	system	0
83889936-10af-4f11-b88f-1cd5f5834b26	po	po@traceagile.demo	Paula Owner	$2a$12$1fl/484yz5rxSnAqepWCpuq9GATRqCWLJmdH2zfYDYUw3TIk6AKLq	t	f	2026-10-12 12:39:07.30835+00	admin	2026-10-12 12:39:07.30835+00	admin	0
f88ee032-a263-4d16-9f40-3c190c42eaef	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$89OB1jNmV2Af9P/RhDNEDuirz4k2blQD5b01Tvnv.kLqcorefpxIa	t	f	2026-10-12 12:39:07.498726+00	admin	2026-10-12 12:39:07.498726+00	admin	0
993752b1-4beb-4cf0-bc77-ccce4971bd89	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$PLbFZFNKEaVChF6REeZiH.4VNUm.rvmYFs12Hvg12J98uR5gpQLGO	t	f	2026-10-12 12:39:07.693333+00	admin	2026-10-12 12:39:07.693333+00	admin	0
b202ced4-22eb-4fa3-8c84-955369764d09	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$lHUASgk2YOyIGQ9b4FqzB.4rJE1FsW6iR1mIsOYZUeWrLl1iIMINm	t	f	2026-10-12 12:39:07.882329+00	admin	2026-10-12 12:39:07.882329+00	admin	0
fa8cf5a0-3d64-4ce4-9464-95d4610998f9	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$uwbjS3QvvjAf/vYw5Oo4g.lnN/5/IEvGZRrGE5fFeFJOXfO7ozRQ6	t	f	2026-10-12 12:39:08.06526+00	admin	2026-10-12 12:39:08.06526+00	admin	0
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


