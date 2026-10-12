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
d6938f1f-2230-4314-80d8-9493b6b766cc	ad60110a-7c5f-4ea9-bed9-ea4f29866094	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 15:27:14.847959+00	po	2026-10-12 15:27:14.847959+00	po	0
c383c0ba-e186-467c-a101-cf4090c164b2	ad60110a-7c5f-4ea9-bed9-ea4f29866094	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 15:27:14.847959+00	po	2026-10-12 15:27:14.847959+00	po	0
fc771846-7676-4c22-b2cf-fd353c13172f	92195f11-baa2-45bd-be3a-7275cf9a3714	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 15:27:14.890005+00	po	2026-10-12 15:27:14.890005+00	po	0
e055de85-d481-4c55-bcbd-5d792aae761f	8efd7182-8f71-46f6-a75d-32ee338fddea	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 15:27:14.966169+00	po	2026-10-12 15:27:14.966169+00	po	0
4d029862-a39b-444f-aca3-01c802a242dd	425ea114-f313-4545-aef6-7b0689673731	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 15:27:15.027826+00	po	2026-10-12 15:27:15.027826+00	po	0
e548e6ea-3daa-4589-b763-9e3fd2dd1801	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 15:27:15.067489+00	po	2026-10-12 15:27:15.067489+00	po	0
e2ea298d-e6a5-433f-a82e-5b9873330f40	5ac319b3-077e-4a16-a470-fe8bf0260397	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 15:27:15.141929+00	po	2026-10-12 15:27:15.141929+00	po	0
9af825b2-76b6-4344-aeff-e4c87dbcab9d	5ac319b3-077e-4a16-a470-fe8bf0260397	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 15:27:15.141929+00	po	2026-10-12 15:27:15.141929+00	po	0
1e89e369-d66a-4133-805d-d668b1f05dc6	ba8d4956-c976-4691-aba0-c3b98c97ebee	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 15:27:15.178682+00	po	2026-10-12 15:27:15.178682+00	po	0
f034f40d-a733-4af0-ab4a-12ecce384eb5	ba8d4956-c976-4691-aba0-c3b98c97ebee	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 15:27:15.178682+00	po	2026-10-12 15:27:15.178682+00	po	0
d64ed1b6-b21e-411c-89be-7545464ad3e8	2b918b31-1456-4c95-9d2e-587617e6d967	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 15:27:15.214498+00	po	2026-10-12 15:27:15.214498+00	po	0
e0f04c61-67ef-4495-8d22-50554fe8735d	95dc54b0-9038-4acd-abf6-482c43689753	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 15:27:15.280614+00	po	2026-10-12 15:27:15.280614+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
49191ef5-84bb-4880-a2a4-6b69415ac7a7	54a2489c-9f91-42bb-b289-a489376506fc	EXECUTION_STEP	879c3075-0c70-4115-b1b5-01862809622b	sd-defaut-problem-user.png	image/png	235121	70d86939-bc77-4efd-bdf0-6f1a4c8a6c8e	2026-10-12 15:28:43.143842+00	qa2	2026-10-12 15:28:43.143842+00	qa2	0
3afee247-b070-41b1-83ef-04e537aae5eb	54a2489c-9f91-42bb-b289-a489376506fc	DEFECT	aeddb787-60f7-4835-b966-f307e33693cf	sd-defaut-problem-user.png	image/png	235121	70d86939-bc77-4efd-bdf0-6f1a4c8a6c8e	2026-10-12 15:28:44.684071+00	qa2	2026-10-12 15:28:44.684071+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
13533da8-b5d9-411b-91fc-755c193c252e	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5e28b3d3-bc72-4174-b762-8c02a95210cc	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:14.710923+00	po	2026-10-12 15:27:14.710923+00	po	0
6a02a7ca-d340-42a6-bd99-fac3d0b103aa	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	6b7372d2-2bd1-46a7-8a42-0a16ed88659b	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:14.788407+00	po	2026-10-12 15:27:14.788407+00	po	0
0ad33fef-e40a-49e0-b750-374996bcff1d	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 15:27:14.847959+00	po	2026-10-12 15:27:14.847959+00	po	0
c00905dd-d30f-4413-968d-992376bab5ff	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 15:27:14.890522+00	po	2026-10-12 15:27:14.890522+00	po	0
815bca4f-7d80-4369-9a4d-96faabbec0c0	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	c7d676e7-cac1-41d7-9815-32e1bf7ca6db	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:14.927514+00	po	2026-10-12 15:27:14.927514+00	po	0
94923925-8791-4e4a-9912-f70f89bd98d9	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 15:27:14.966169+00	po	2026-10-12 15:27:14.966169+00	po	0
2869a1e9-5c2f-4a9e-9ed3-aa57974b740e	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	425ea114-f313-4545-aef6-7b0689673731	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.028344+00	po	2026-10-12 15:27:15.028344+00	po	0
4579be63-a439-4738-afde-4df372bcc1bf	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:26.984415+00	qa1	2026-10-12 15:27:26.984415+00	qa1	0
05888de6-daa1-4306-9c50-f8a7705bbf7b	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	59231cfa-b570-4620-a814-5f966abea164	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:27.959885+00	qa1	2026-10-12 15:27:27.959885+00	qa1	0
c9d87757-be84-4a5c-ac2c-9da457f0d8a5	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	49aba8a5-0963-4048-a86f-1a00c2fc1e05	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:28.031472+00	qa1	2026-10-12 15:27:28.031472+00	qa1	0
710d68f9-ef85-43df-9644-adb933d99793	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:27:35.11421+00	po	2026-10-12 15:27:35.11421+00	po	0
b173f8ed-5c11-4438-8076-8d4da06f856c	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.067489+00	po	2026-10-12 15:27:15.067489+00	po	0
ebbd2529-0e2a-4e70-a956-40d22eda34a1	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	699b11c2-179e-4679-9962-98d207dfc0f1	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:15.108425+00	po	2026-10-12 15:27:15.108425+00	po	0
91712771-d5d4-4c65-a650-bfce0cd75247	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	f0d80128-acd4-42ef-a7a8-ba96c998a985	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:16.964866+00	po	2026-10-12 15:27:16.964866+00	po	0
daffe658-125a-4aba-bb36-f0234f52d05a	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.073584+00	po	2026-10-12 15:27:18.073584+00	po	0
8edb89c1-cc10-43cf-9dd8-63bd19560baa	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	425ea114-f313-4545-aef6-7b0689673731	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.148542+00	po	2026-10-12 15:27:18.148542+00	po	0
f5efdb6d-1ea0-467d-b14a-f85f1f673053	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5ac319b3-077e-4a16-a470-fe8bf0260397	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.2328+00	po	2026-10-12 15:27:18.2328+00	po	0
6bacd509-f600-4afa-9374-2baede05b14e	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	223d8c71-f344-4c0d-9413-c6f931d49ff5	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.209598+00	qa1	2026-10-12 15:27:25.209598+00	qa1	0
1f70af63-4e54-4041-a8e2-31b9903bda6e	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	4521d948-2d7c-431e-b9a1-703fd325ebfd	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 15:27:25.247548+00	qa1	2026-10-12 15:27:25.247548+00	qa1	0
1cf0d3bb-6357-4548-9248-5d78632e499f	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	733ef065-6786-4af9-97aa-5570ea1066c3	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 15:27:25.467506+00	dev	2026-10-12 15:27:25.467506+00	dev	0
a437ff74-88f6-43ba-a202-35acbb651ff4	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.570588+00	qa1	2026-10-12 15:27:25.570588+00	qa1	0
f130e905-fdae-4afd-8623-f867976f0942	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1c0d00d-094d-402a-a168-9187e9108bb2	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 15:27:25.604216+00	dev	2026-10-12 15:27:25.604216+00	dev	0
6ca7701b-46f6-4027-9935-bfa950e48b6c	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 15:27:27.027465+00	qa1	2026-10-12 15:27:27.027465+00	qa1	0
4ccd6326-64a2-422e-9b7e-a8b0f4068e52	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5ac319b3-077e-4a16-a470-fe8bf0260397	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.142446+00	po	2026-10-12 15:27:15.142446+00	po	0
c1a17f73-b0cf-4b88-9651-2c6b87f23349	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.179198+00	po	2026-10-12 15:27:15.179198+00	po	0
222b6eb8-ac91-4164-91a4-236e0a1bdf4b	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.215006+00	po	2026-10-12 15:27:15.215006+00	po	0
1267e7b5-2219-499f-ae25-7960f83b8cf9	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	e20ac237-3793-4419-891d-46ddfc914700	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:15.248289+00	po	2026-10-12 15:27:15.248289+00	po	0
b992deaa-3e65-4fc5-8531-8e4eae484565	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	95dc54b0-9038-4acd-abf6-482c43689753	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 15:27:15.280614+00	po	2026-10-12 15:27:15.280614+00	po	0
3dbd8884-0595-4faf-8e13-04c0085e73ba	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	08701d22-a93d-4128-8d94-0023fef3c40f	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:17.20128+00	po	2026-10-12 15:27:17.20128+00	po	0
68b27de1-ff13-4911-94d8-1a4d5039da33	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	d4fe1427-d374-42d6-85ee-721366ccc95d	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:27.896741+00	qa1	2026-10-12 15:27:27.896741+00	qa1	0
3297e91b-4314-4aa4-9d0c-f068cdbade6a	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:27:35.11421+00	po	2026-10-12 15:27:35.11421+00	po	0
f9897630-3bfb-4a7a-9a04-81c5b93c70a3	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:27:35.114858+00	po	2026-10-12 15:27:35.114858+00	po	0
70142833-7455-4a16-b737-0a71f0d2946f	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	425ea114-f313-4545-aef6-7b0689673731	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:27:35.114858+00	po	2026-10-12 15:27:35.114858+00	po	0
a6201fff-628d-47f5-92ca-e3b5b8920a96	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	c9797ec5-af3e-4b7d-8382-7cd5eccf3ad4	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 15:27:17.231149+00	po	2026-10-12 15:27:17.231149+00	po	0
335df4be-d6bf-4375-a116-b1be45d0b50c	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.029418+00	po	2026-10-12 15:27:18.029418+00	po	0
c411719f-df6a-464e-87b4-5b0078b2b8f8	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.111128+00	po	2026-10-12 15:27:18.111128+00	po	0
b531801b-eb49-4063-9550-cfdc3bccbaff	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.192087+00	po	2026-10-12 15:27:18.192087+00	po	0
bc441a2d-4eea-4891-a7a2-a1d30fdfce11	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:18.274698+00	po	2026-10-12 15:27:18.274698+00	po	0
1b0f3da6-7fc1-4818-b19e-48af9e17d5af	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:19.211364+00	po	2026-10-12 15:27:19.211364+00	po	0
39681b00-060b-43ef-b7b1-bc3b3901d289	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	223d8c71-f344-4c0d-9413-c6f931d49ff5	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 15:27:25.158942+00	qa1	2026-10-12 15:27:25.158942+00	qa1	0
a62c5205-0e69-4be5-88fd-d134d24c7052	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	4521d948-2d7c-431e-b9a1-703fd325ebfd	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.292353+00	qa1	2026-10-12 15:27:25.292353+00	qa1	0
01ada414-4d47-4fd0-81a4-bf387019c67d	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1b38cd2-623a-42f3-b185-f3be46c4abcc	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 15:27:25.335243+00	dev	2026-10-12 15:27:25.335243+00	dev	0
e264ebc9-0498-43e7-ae44-b04ed435a980	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1b38cd2-623a-42f3-b185-f3be46c4abcc	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.380085+00	qa1	2026-10-12 15:27:25.380085+00	qa1	0
1cb7211d-9a3e-4462-b07f-4afab07f591f	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 15:27:25.41289+00	dev	2026-10-12 15:27:25.41289+00	dev	0
c19d0e27-10e6-4333-8eda-e787c5598aaf	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.440368+00	qa1	2026-10-12 15:27:25.440368+00	qa1	0
e152e3d9-40b5-4769-a8ad-c36db8b85238	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	733ef065-6786-4af9-97aa-5570ea1066c3	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.503897+00	qa1	2026-10-12 15:27:25.503897+00	qa1	0
33f9cfe5-3ba8-4d14-8eea-753778c70331	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1c0d00d-094d-402a-a168-9187e9108bb2	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:25.635194+00	qa1	2026-10-12 15:27:25.635194+00	qa1	0
c95d9a8c-16a4-44cf-a9c1-a1c634e2add3	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 15:27:25.539877+00	dev	2026-10-12 15:27:25.539877+00	dev	0
c3b4087f-f4a1-4fc9-b3e3-b0c08011d663	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	d4fe1427-d374-42d6-85ee-721366ccc95d	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 15:27:27.868511+00	dev	2026-10-12 15:27:27.868511+00	dev	0
20b934f4-6f5a-45bc-8ba8-4c321e9d517e	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 15:27:34.36532+00	po	2026-10-12 15:27:34.36532+00	po	0
b64b23e8-284f-4e20-8305-8d342fbb4656	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 15:27:26.889239+00	qa1	2026-10-12 15:27:26.889239+00	qa1	0
f54e7886-38ee-4e33-9214-0df07db8a017	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	49aba8a5-0963-4048-a86f-1a00c2fc1e05	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 15:27:27.99601+00	dev	2026-10-12 15:27:27.99601+00	dev	0
ccff1aa0-5c8d-4a4e-bd84-8e26993b6cfb	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	f213d543-7f6a-462f-acf8-d569070fbfaf	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 15:27:36.65196+00	qa1	2026-10-12 15:27:36.65196+00	qa1	0
1bea72d7-5172-43cb-a409-eca69f54450b	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	f213d543-7f6a-462f-acf8-d569070fbfaf	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"]}]	2026-10-12 15:27:36.879191+00	qa1	2026-10-12 15:27:36.879191+00	qa1	0
bb229ba4-1c87-4198-a453-e9eaeefe4390	54a2489c-9f91-42bb-b289-a489376506fc	RUN	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:27:39.963455+00	dev	0
72e91f55-175a-4dab-85c2-e142bc0c9510	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	59231cfa-b570-4620-a814-5f966abea164	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "backlog-tableau", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 15:27:27.931531+00	dev	2026-10-12 15:27:27.931531+00	dev	0
cd25f61e-ac88-4796-bfb3-b0dec8e25c73	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 15:27:28.131182+00	qa1	2026-10-12 15:27:28.131182+00	qa1	0
3a27cec1-ebd7-45f7-950f-3fff697cd776	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	TC-14	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:28.249526+00	qa1	2026-10-12 15:27:28.249526+00	qa1	0
32d48b77-064d-4d76-9d1b-129666ed2241	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 15:27:33.683904+00	po	2026-10-12 15:27:33.683904+00	po	0
3d472303-825f-49aa-bbf6-80dfd7d17798	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 15:27:34.433236+00	po	2026-10-12 15:27:34.433236+00	po	0
f82e6589-ee67-4a45-8fc1-73a169a8fd70	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 15:27:34.497927+00	po	2026-10-12 15:27:34.497927+00	po	0
7da2b93c-31ae-461d-9f5a-5f38eec9b4b6	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	f213d543-7f6a-462f-acf8-d569070fbfaf	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 15:27:36.394645+00	qa1	2026-10-12 15:27:36.394645+00	qa1	0
548251b8-cc39-4c91-abfa-28fc6490444c	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	47708765-6d89-40f2-b5bf-765066cbafb3	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 15:27:28.063752+00	qa1	2026-10-12 15:27:28.063752+00	qa1	0
c529563e-9ff5-4e71-ab76-72b76786f72a	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	47708765-6d89-40f2-b5bf-765066cbafb3	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:28.097463+00	qa1	2026-10-12 15:27:28.097463+00	qa1	0
552a82ba-a334-4890-93e2-dcdf962d2d8e	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 15:27:28.171109+00	qa1	2026-10-12 15:27:28.171109+00	qa1	0
c4a9e6c5-4017-4df9-a304-257958d11618	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	TC-14	CREATED	[{"after": "TC-14", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : noms et prix (Playwright Java)", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "JUnit 5", "field": "framework", "before": null}, {"after": "Java", "field": "language", "before": null}, {"after": "https://github.com/kerware/saucedemo-e2e", "field": "repositoryUrl", "before": null}, {"after": "master", "field": "branch", "before": null}, {"after": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "field": "path", "before": null}, {"after": "InventaireCatalogueTest#catalogueAffiche", "field": "testIdentifier", "before": null}, {"after": "kerware, smoke", "field": "executionTags", "before": null}]	2026-10-12 15:27:28.214502+00	dev	2026-10-12 15:27:28.214502+00	dev	0
c474bbb8-adc4-4d12-a3db-f8324382cf39	54a2489c-9f91-42bb-b289-a489376506fc	RELEASE	320bfae7-35db-4a5d-a609-8d33e6e34ad0	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 15:27:33.656516+00	po	2026-10-12 15:27:33.656516+00	po	0
28ba8475-ada3-4934-b7f7-e97e81efc843	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	28b827fd-ddd2-42ee-87c7-85effe954295	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 15:27:33.729192+00	po	2026-10-12 15:27:33.729192+00	po	0
0f1d003d-ef98-451c-9aa7-4a54d2e7020d	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 15:27:34.296803+00	po	2026-10-12 15:27:34.296803+00	po	0
229d7dd5-c62b-45bb-b7cf-349db184f81a	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 15:27:34.569694+00	po	2026-10-12 15:27:34.569694+00	po	0
de72c77f-6e28-42c6-9e28-dd11359a6d0d	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:27:35.114858+00	po	2026-10-12 15:27:35.114858+00	po	0
18478776-6396-4f16-a645-fab7b3b21666	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 15:27:35.114858+00	po	2026-10-12 15:27:35.114858+00	po	0
a381e1cc-0a43-4650-9296-4f39583b3cdb	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	f213d543-7f6a-462f-acf8-d569070fbfaf	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 15:28:37.319661+00	qa1	2026-10-12 15:28:37.319661+00	qa1	0
78e7f040-ecd1-45c8-b996-34c4c82b5b76	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 15:28:37.392424+00	po	2026-10-12 15:28:37.392424+00	po	0
fe83b288-190f-4bca-9320-7b63ed93c617	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 15:28:37.435427+00	po	2026-10-12 15:28:37.435427+00	po	0
cbf00dce-ae53-42cd-86a6-d9549964a53f	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 15:28:37.475848+00	po	2026-10-12 15:28:37.475848+00	po	0
b632b912-5f92-416d-9f46-a545e24d6543	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	425ea114-f313-4545-aef6-7b0689673731	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 15:28:37.514342+00	po	2026-10-12 15:28:37.514342+00	po	0
f782ebac-f91c-4099-a984-1979576ef52e	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 15:28:38.918043+00	po	2026-10-12 15:28:38.918043+00	po	0
668f18e7-f8ec-4971-b41e-7dcbbd6032e8	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 15:28:39.689774+00	po	2026-10-12 15:28:39.689774+00	po	0
558fe839-907b-496d-8376-bac16a50fb6e	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	28b827fd-ddd2-42ee-87c7-85effe954295	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 15:28:40.387246+00	po	2026-10-12 15:28:40.387246+00	po	0
613df9e0-4417-4d27-b0ce-d98c742ffa16	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5ac319b3-077e-4a16-a470-fe8bf0260397	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:28:40.429446+00	po	2026-10-12 15:28:40.429446+00	po	0
87f23dd5-7042-46ff-9e88-a9000cb75694	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:28:40.42997+00	po	2026-10-12 15:28:40.42997+00	po	0
46d300c1-1814-4d88-a33c-8d043cd4be35	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 15:28:40.42997+00	po	2026-10-12 15:28:40.42997+00	po	0
a617e3ec-c915-4b88-b374-7aa8530f09ff	54a2489c-9f91-42bb-b289-a489376506fc	SPRINT	28b827fd-ddd2-42ee-87c7-85effe954295	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 15:28:40.42997+00	po	2026-10-12 15:28:40.42997+00	po	0
1e473313-ab97-4282-bd0d-672014ae703a	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	998bc5b1-c539-468e-b667-3da2422839e5	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 15:28:41.420765+00	qa1	2026-10-12 15:28:41.420765+00	qa1	0
4897bd8d-35a0-4529-b522-a5a828bed26a	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	998bc5b1-c539-468e-b667-3da2422839e5	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 15:28:41.447393+00	qa1	2026-10-12 15:28:41.447393+00	qa1	0
e23b35a6-d656-4abc-8394-97f08e08abfb	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	998bc5b1-c539-468e-b667-3da2422839e5	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 15:28:41.468097+00	qa1	2026-10-12 15:28:41.468097+00	qa1	0
55d44058-b3c1-431f-a0c0-7adfda2f6a3e	54a2489c-9f91-42bb-b289-a489376506fc	DEFECT	aeddb787-60f7-4835-b966-f307e33693cf	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 15:28:44.680056+00	qa2	2026-10-12 15:28:44.680056+00	qa2	0
0cd46e66-c83b-4b12-a694-b4a7b5e0262e	54a2489c-9f91-42bb-b289-a489376506fc	SESSION	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 15:28:47.207922+00	qa1	2026-10-12 15:28:47.207922+00	qa1	0
f6b9700f-baed-4e8c-8f09-df774f7c71d6	54a2489c-9f91-42bb-b289-a489376506fc	DEFECT	665e1d1d-a50f-4558-9330-30aa05756080	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 15:28:48.424516+00	qa1	2026-10-12 15:28:48.424516+00	qa1	0
37fcdae8-37e9-41de-b36d-1a4ea2d4ea82	54a2489c-9f91-42bb-b289-a489376506fc	SESSION	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 15:28:49.691501+00	qa1	2026-10-12 15:28:49.691501+00	qa1	0
09f580d2-6ff5-4d60-a26e-95a2031acc76	54a2489c-9f91-42bb-b289-a489376506fc	SESSION	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 15:28:50.090961+00	qa1	2026-10-12 15:28:50.090961+00	qa1	0
1463bbc7-c193-492f-9fc8-f29582f21f46	54a2489c-9f91-42bb-b289-a489376506fc	SESSION	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 15:28:50.621262+00	po	2026-10-12 15:28:50.621262+00	po	0
51856ad7-90c7-4b5e-9478-0af295005ac2	54a2489c-9f91-42bb-b289-a489376506fc	RUN	18e2f9dc-d66b-42cb-972a-67d037f4a408	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 15:28:52.256637+00	dev	2026-10-12 15:28:52.256637+00	dev	0
f6d345bf-ec96-486f-8c8c-9a7d6b473a4e	54a2489c-9f91-42bb-b289-a489376506fc	CAMPAIGN	3c5e5048-2046-42da-8562-c083492e5e75	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 15:29:21.224709+00	qa1	2026-10-12 15:29:21.224709+00	qa1	0
b8746a69-e1e3-4228-831b-07ff615dc002	54a2489c-9f91-42bb-b289-a489376506fc	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 15:29:31.114441+00	po	2026-10-12 15:29:31.114441+00	po	0
52c4a7e8-222b-443a-8f89-ec94beee2e8e	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 15:29:31.125921+00	po	2026-10-12 15:29:31.125921+00	po	0
fe2f74f7-8c5c-488b-9eab-ce8de1b71773	54a2489c-9f91-42bb-b289-a489376506fc	TRACE_LINK	7d618427-a668-472b-a8de-578f708e6f1d	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 15:29:31.759651+00	qa1	2026-10-12 15:29:31.759651+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	54a2489c-9f91-42bb-b289-a489376506fc	RUN-1	1	f213d543-7f6a-462f-acf8-d569070fbfaf	e7e66a72-b40f-4690-b297-db1eb1c830df	COMPLETED	dev	2026-10-12 15:27:39.95929+00	2026-10-12 15:27:40.020394+00	2026-10-12 15:27:40.01932+00	2026-10-12 15:28:35.550456+00	2026-10-12 15:28:35.550456+00	recette	1.0.0-s1	job-612d31ab	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-612d31ab/logs	http://localhost:8091/api/v1/jobs/job-612d31ab/artifacts/report.json	30	\N	\N	6	6	0	0	0	\N	2026-10-12 15:27:39.96241+00	dev	2026-10-12 15:28:35.569084+00	anonymousUser	15
18e2f9dc-d66b-42cb-972a-67d037f4a408	54a2489c-9f91-42bb-b289-a489376506fc	RUN-2	2	998bc5b1-c539-468e-b667-3da2422839e5	e7e66a72-b40f-4690-b297-db1eb1c830df	COMPLETED	dev	2026-10-12 15:28:52.255001+00	2026-10-12 15:28:52.296321+00	2026-10-12 15:28:52.294573+00	2026-10-12 15:29:18.626418+00	2026-10-12 15:29:18.626418+00	recette	1.0.0-s2	job-1fed3a24	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-1fed3a24/logs	http://localhost:8091/api/v1/jobs/job-1fed3a24/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 15:28:52.25613+00	dev	2026-10-12 15:29:18.638524+00	anonymousUser	10
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version", "git_project_id") FROM stdin;
2bba0184-68ed-49c1-8035-c1cf79200614	f1b38cd2-623a-42f3-b185-f3be46c4abcc	DATA_DRIVEN	Playwright	TypeScript	\N	\N	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 15:27:25.329455+00	dev	2026-10-12 15:27:25.329455+00	dev	0	20372435-3aac-495a-af40-70da1267b857
65447073-9968-4a2a-9a0f-d3580f4903a4	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 15:27:25.409453+00	dev	2026-10-12 15:27:25.409453+00	dev	0	20372435-3aac-495a-af40-70da1267b857
1ed318cf-de81-47b5-bc15-18c6feebd731	733ef065-6786-4af9-97aa-5570ea1066c3	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 15:27:25.464161+00	dev	2026-10-12 15:27:25.464161+00	dev	0	20372435-3aac-495a-af40-70da1267b857
703c9464-feff-4e8a-b57e-347b9ae0a79e	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 15:27:25.535749+00	dev	2026-10-12 15:27:25.535749+00	dev	0	20372435-3aac-495a-af40-70da1267b857
07ec1c90-ef6a-4ba6-86c5-8be63819cd73	f1c0d00d-094d-402a-a168-9187e9108bb2	API	Playwright	TypeScript	\N	\N	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 15:27:25.601004+00	dev	2026-10-12 15:27:25.601004+00	dev	0	20372435-3aac-495a-af40-70da1267b857
684d3bc0-7e2d-4f9e-9a33-c903a0dd78c2	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	BDD	Playwright	\N	\N	\N	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 15:27:26.874128+00	qa1	2026-10-12 15:27:27.028472+00	qa1	1	20372435-3aac-495a-af40-70da1267b857
8ca9506f-dab8-491c-b3c1-2fd0eeaf20b4	d4fe1427-d374-42d6-85ee-721366ccc95d	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 15:27:27.86431+00	dev	2026-10-12 15:27:27.86431+00	dev	0	20372435-3aac-495a-af40-70da1267b857
6a71b789-e9c8-4149-8243-158f3a309f20	59231cfa-b570-4620-a814-5f966abea164	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 15:27:27.928922+00	dev	2026-10-12 15:27:27.928922+00	dev	0	20372435-3aac-495a-af40-70da1267b857
0e38bbab-fa8e-407f-ae59-f9ef145a73af	49aba8a5-0963-4048-a86f-1a00c2fc1e05	PERFORMANCE	Playwright	TypeScript	\N	\N	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 15:27:27.992831+00	dev	2026-10-12 15:27:27.992831+00	dev	0	20372435-3aac-495a-af40-70da1267b857
cef0e218-8014-438c-9a82-45a9c0ece7a0	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	UI	JUnit 5	Java	\N	\N	src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java	InventaireCatalogueTest#catalogueAffiche	\N	\N	{}	["kerware", "smoke"]	{}	[]	f	2026-10-12 15:27:28.211391+00	dev	2026-10-12 15:27:28.211391+00	dev	0	bc2381df-ef86-4749-a746-1876bbf34ed9
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1983ad36-daaf-4464-bbf5-d9c6a71ec58f	BDD	Cucumber-JVM	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
6f0bd0a5-5934-40b9-9745-cbafbc56fde1	BDD	Cucumber-JS	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
b4f1b8d7-5366-4fb7-b060-b942b9ed3422	BDD	Behave	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
2afbef95-491f-4b3a-9e34-89efb67426a7	BDD	SpecFlow	4	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
91fb3bba-bdec-4fac-ab39-311f5226a7f3	BDD	Karate	5	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
dcaa5bdd-db3a-4024-84b7-c1859b4d3fa5	UNIT	JUnit 5	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
2cd85e13-2995-4af8-a6a8-f57f0c9ff9b0	UNIT	Kotest	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
c7718019-330a-4e4a-ac8b-1abbb48c6229	UNIT	pytest	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
c6394fd2-f639-4121-89c1-6405de3a1325	UNIT	Jest	4	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
90528961-5b31-4cbc-9398-c12da5422931	UNIT	Vitest	5	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
5d4a1af5-5b92-4b38-9182-6225a7d2afd5	UI	Playwright	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
778f214a-4888-465c-bd3e-3892a310dc3b	UI	Selenium	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
81808802-8ed1-4f66-a187-4fc0964969d1	UI	Cypress	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
58a0bc5d-64c2-419b-ab3d-300b1601a262	UI	Appium	4	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
47674954-0e30-4d8a-b2c8-5e7a1f517dfe	API	REST Assured	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
eb70fce0-1844-43a2-b15a-9db2291bd645	API	Karate	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
9635d312-d057-42a8-ba78-8743bdbc7033	API	Postman/Newman	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
0ff31d46-7f69-49ab-af21-b0f5c96df607	API	pytest + requests	4	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
4c2c28ae-ee41-4328-8b94-ad43a2d8fe62	KEYWORD	Robot Framework	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
1dc21e3c-2275-4da0-b1f5-050b548a3b35	DATA_DRIVEN	JUnit 5	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
f7040662-efa0-482d-ba0d-1f57b88663bf	DATA_DRIVEN	pytest	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
745790ab-87cf-4eb6-a6bf-d12bc0596d46	DATA_DRIVEN	Playwright	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
a30d92ab-dec2-4b11-a7fa-230d08425903	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
21e21a99-2563-4037-aa4a-ff5e6a0c5a04	PERFORMANCE	Gatling	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
40938bae-e6cc-4a86-be49-c44e6de2bb07	PERFORMANCE	k6	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
59e38438-8326-4596-8561-97ae21eb1cd5	PERFORMANCE	JMeter	3	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
2d94ec99-986a-418b-96d5-d0a6d11b3c09	CONTRACT	Pact	1	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
2b6bc28e-55e5-4f4c-90bc-63c2a82d5424	CONTRACT	Spring Cloud Contract	2	2026-10-12 15:26:53.163141+00	system	2026-10-12 15:26:53.163141+00	system	0
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
ef6e7170-56f0-4482-833c-17c4ad9011e6	f213d543-7f6a-462f-acf8-d569070fbfaf	f1b38cd2-623a-42f3-b185-f3be46c4abcc	1	\N	4	12	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.640637+00	qa1	0	\N	\N
cf30e2a9-7aec-4884-a225-0060cf9ea653	f213d543-7f6a-462f-acf8-d569070fbfaf	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	1	\N	5	6	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.640637+00	qa1	0	\N	\N
b663ad16-4f5a-459d-afed-d1756e220029	f213d543-7f6a-462f-acf8-d569070fbfaf	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	1	\N	6	6	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.640637+00	qa1	0	\N	\N
6b15bc39-3f0b-4ee3-be3f-230dcf7c04e5	f213d543-7f6a-462f-acf8-d569070fbfaf	733ef065-6786-4af9-97aa-5570ea1066c3	1	\N	7	3	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.640637+00	qa1	0	\N	\N
e6906ac3-3779-47d4-b59c-aa8982115c93	f213d543-7f6a-462f-acf8-d569070fbfaf	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	1	\N	8	3	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.640637+00	qa1	0	\N	\N
3b51a342-82ab-4516-9bd6-aea52d856ac9	f213d543-7f6a-462f-acf8-d569070fbfaf	f1c0d00d-094d-402a-a168-9187e9108bb2	1	\N	9	6	2026-10-12 15:27:36.87592+00	qa1	2026-10-12 15:27:36.87592+00	qa1	0	\N	\N
4dc9842b-ed04-497e-bd03-4199dcb82ddc	f213d543-7f6a-462f-acf8-d569070fbfaf	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	88e057fa-32a5-49de-9e07-aa43c9fab938	1	16	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.927679+00	qa1	1	Comptes	0
e4f1eca5-07a3-41e8-be5b-4543ad51e82e	f213d543-7f6a-462f-acf8-d569070fbfaf	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	88e057fa-32a5-49de-9e07-aa43c9fab938	2	16	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.94521+00	qa1	1	Comptes	1
23696a27-ff98-4350-8505-e2c7dd109a84	f213d543-7f6a-462f-acf8-d569070fbfaf	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	88e057fa-32a5-49de-9e07-aa43c9fab938	3	16	2026-10-12 15:27:36.640637+00	qa1	2026-10-12 15:27:36.962623+00	qa1	1	Comptes	2
8d1bd020-fe4d-4c52-b02a-dcbc7cd249df	998bc5b1-c539-468e-b667-3da2422839e5	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	2	\N	3	12	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.442765+00	qa1	0	\N	\N
f9067201-27a1-4183-9b8e-56a46c3341f7	998bc5b1-c539-468e-b667-3da2422839e5	d4fe1427-d374-42d6-85ee-721366ccc95d	1	\N	4	12	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.442765+00	qa1	0	\N	\N
a0dcbb47-c92a-4edc-88bd-25f633b54495	998bc5b1-c539-468e-b667-3da2422839e5	59231cfa-b570-4620-a814-5f966abea164	1	\N	7	6	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.442765+00	qa1	0	\N	\N
bbe8ab04-982c-4493-948c-3d50399214c4	998bc5b1-c539-468e-b667-3da2422839e5	49aba8a5-0963-4048-a86f-1a00c2fc1e05	1	\N	8	6	2026-10-12 15:28:41.467073+00	qa1	2026-10-12 15:28:41.467073+00	qa1	0	\N	\N
b99110ba-588e-4790-9174-aaa5148bc383	998bc5b1-c539-468e-b667-3da2422839e5	4521d948-2d7c-431e-b9a1-703fd325ebfd	1	cdb1d017-6c70-4fd0-b5a5-b3f6e1dcc80e	1	16	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.496764+00	qa1	1	\N	\N
c7774ea4-193a-4709-a22c-2061cee3e74f	998bc5b1-c539-468e-b667-3da2422839e5	47708765-6d89-40f2-b5bf-765066cbafb3	1	88e057fa-32a5-49de-9e07-aa43c9fab938	2	16	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.511525+00	qa1	1	\N	\N
d4afb1fc-b303-491e-a837-91f3a5d67b09	998bc5b1-c539-468e-b667-3da2422839e5	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	88e057fa-32a5-49de-9e07-aa43c9fab938	5	12	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.535721+00	qa1	1	Produits	0
e3300acf-30ee-4367-8e87-cf8a0fbac05e	998bc5b1-c539-468e-b667-3da2422839e5	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	88e057fa-32a5-49de-9e07-aa43c9fab938	6	12	2026-10-12 15:28:41.442765+00	qa1	2026-10-12 15:28:41.555082+00	qa1	1	Produits	1
0522237c-4241-44e2-9d29-262b7c72abc6	3c5e5048-2046-42da-8562-c083492e5e75	f1c0d00d-094d-402a-a168-9187e9108bb2	1	\N	1	0	2026-10-12 15:29:22.457426+00	qa1	2026-10-12 15:29:22.457426+00	qa1	0	\N	\N
06e614eb-01fc-4e64-aa76-2ae32bd505cd	3c5e5048-2046-42da-8562-c083492e5e75	f1b38cd2-623a-42f3-b185-f3be46c4abcc	1	\N	2	0	2026-10-12 15:29:22.465439+00	qa1	2026-10-12 15:29:22.465439+00	qa1	0	\N	\N
9b50d23d-7cc9-43c6-83d5-1eed770158f3	3c5e5048-2046-42da-8562-c083492e5e75	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	1	\N	3	0	2026-10-12 15:29:22.470122+00	qa1	2026-10-12 15:29:22.470122+00	qa1	0	\N	\N
de413776-92cb-4cfb-bd42-74f8ce17ac5e	3c5e5048-2046-42da-8562-c083492e5e75	733ef065-6786-4af9-97aa-5570ea1066c3	1	\N	4	0	2026-10-12 15:29:22.474313+00	qa1	2026-10-12 15:29:22.474313+00	qa1	0	\N	\N
9b12352c-930c-45e1-a540-2355901fed05	3c5e5048-2046-42da-8562-c083492e5e75	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	1	\N	5	0	2026-10-12 15:29:22.477996+00	qa1	2026-10-12 15:29:22.477996+00	qa1	0	\N	\N
f93005a3-10d6-403f-8755-2cab575d8c66	3c5e5048-2046-42da-8562-c083492e5e75	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	2	\N	6	0	2026-10-12 15:29:22.48145+00	qa1	2026-10-12 15:29:22.48145+00	qa1	0	\N	\N
cd528cb2-7eea-4c6c-985a-a6f2777d55d5	3c5e5048-2046-42da-8562-c083492e5e75	d4fe1427-d374-42d6-85ee-721366ccc95d	1	\N	7	0	2026-10-12 15:29:22.485581+00	qa1	2026-10-12 15:29:22.485581+00	qa1	0	\N	\N
2ccfd916-5921-46e9-b6c1-2f8a9f22db93	3c5e5048-2046-42da-8562-c083492e5e75	59231cfa-b570-4620-a814-5f966abea164	1	\N	8	0	2026-10-12 15:29:22.489295+00	qa1	2026-10-12 15:29:22.489295+00	qa1	0	\N	\N
cadbb2a7-c638-43c0-b0e3-7f8d32657c91	3c5e5048-2046-42da-8562-c083492e5e75	49aba8a5-0963-4048-a86f-1a00c2fc1e05	1	\N	9	0	2026-10-12 15:29:22.493627+00	qa1	2026-10-12 15:29:22.493627+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
f213d543-7f6a-462f-acf8-d569070fbfaf	54a2489c-9f91-42bb-b289-a489376506fc	CMP-1	1	Recette sprint 1	SPRINT	af367b72-2a4e-4d66-8540-8393285694c4	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 15:27:36.394129+00	qa1	2026-10-12 15:28:37.320174+00	qa1	3	Release 1.0/Recettes de sprint
998bc5b1-c539-468e-b667-3da2422839e5	54a2489c-9f91-42bb-b289-a489376506fc	CMP-2	2	Recette sprint 2	SPRINT	28b827fd-ddd2-42ee-87c7-85effe954295	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 15:28:41.420246+00	qa1	2026-10-12 15:28:42.491747+00	qa2	2	Release 1.0/Recettes de sprint
3c5e5048-2046-42da-8562-c083492e5e75	54a2489c-9f91-42bb-b289-a489376506fc	CMP-3	3	Intégration continue — main	RELEASE	\N	320bfae7-35db-4a5d-a609-8d33e6e34ad0	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 15:29:21.224709+00	qa1	2026-10-12 15:29:22.460334+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3cd0ac8e-6f25-4e14-a197-bae9550cb79e	54a2489c-9f91-42bb-b289-a489376506fc	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 15:27:11.09315+00	admin	2026-10-12 15:27:11.09315+00	admin	0
7b7ddef4-6083-4d8a-9606-ca2f5f0f6dd7	54a2489c-9f91-42bb-b289-a489376506fc	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 15:27:11.09315+00	admin	2026-10-12 15:27:11.09315+00	admin	0
c3af3bc1-3c8c-4cb7-b6f3-834829c33732	54a2489c-9f91-42bb-b289-a489376506fc	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 15:27:11.09315+00	admin	2026-10-12 15:27:11.09315+00	admin	0
b330d23e-edae-43f1-88eb-66e89c0b3dea	54a2489c-9f91-42bb-b289-a489376506fc	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 15:27:11.094643+00	admin	2026-10-12 15:27:11.094643+00	admin	0
1b9f7e0c-da89-4efb-9945-9f834e013c59	54a2489c-9f91-42bb-b289-a489376506fc	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 15:27:11.095148+00	admin	2026-10-12 15:27:11.095148+00	admin	0
7f27229b-5661-4b8a-910a-abf1420942cb	54a2489c-9f91-42bb-b289-a489376506fc	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 15:27:11.095148+00	admin	2026-10-12 15:27:11.095148+00	admin	0
c1da4be2-3c37-4e3a-be3e-b397b5693fb7	54a2489c-9f91-42bb-b289-a489376506fc	DOD	4	Code revu et intégré	\N	2026-10-12 15:27:11.095148+00	admin	2026-10-12 15:27:11.095148+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d1d68a41-1737-45f5-a026-e6d5d0a51575	95dc54b0-9038-4acd-abf6-482c43689753	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 15:27:21.788639+00	po	2026-10-12 15:27:21.788639+00	po	0
de9c6fdc-d3ba-4a17-b746-949317834194	ba8d4956-c976-4691-aba0-c3b98c97ebee	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 15:27:22.671039+00	po	2026-10-12 15:27:22.671039+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
aeddb787-60f7-4835-b966-f307e33693cf	6a5192b5-ec3d-42de-9a28-a5deb428d88f
665e1d1d-a50f-4558-9330-30aa05756080	bec30635-2393-4f9b-8bda-b6d9d0b311d6
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
aeddb787-60f7-4835-b966-f307e33693cf	ba8d4956-c976-4691-aba0-c3b98c97ebee
aeddb787-60f7-4835-b966-f307e33693cf	2b918b31-1456-4c95-9d2e-587617e6d967
665e1d1d-a50f-4558-9330-30aa05756080	ba8d4956-c976-4691-aba0-c3b98c97ebee
665e1d1d-a50f-4558-9330-30aa05756080	2b918b31-1456-4c95-9d2e-587617e6d967
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
aeddb787-60f7-4835-b966-f307e33693cf	54a2489c-9f91-42bb-b289-a489376506fc	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 15:28:44.679551+00	qa2	2026-10-12 15:28:44.68468+00	qa2	1
665e1d1d-a50f-4558-9330-30aa05756080	54a2489c-9f91-42bb-b289-a489376506fc	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 15:28:48.423992+00	qa1	2026-10-12 15:28:48.426065+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ac3cfe67-1834-449d-8906-f8114841f78c	95dc54b0-9038-4acd-abf6-482c43689753	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 15:27:21.509254+00	po	2026-10-12 15:27:21.509254+00	po	0
3b594a7f-f967-44c6-afc3-2f3c2d1eb185	95dc54b0-9038-4acd-abf6-482c43689753	EXAMPLE	ac3cfe67-1834-449d-8906-f8114841f78c	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 15:27:21.569541+00	po	2026-10-12 15:27:21.569541+00	po	0
8bf88e5b-657a-41f1-b024-c317c33c9d02	95dc54b0-9038-4acd-abf6-482c43689753	EXAMPLE	ac3cfe67-1834-449d-8906-f8114841f78c	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 15:27:21.620983+00	po	2026-10-12 15:27:21.620983+00	po	0
bd339de0-a2e5-4030-8768-064a30f271c0	95dc54b0-9038-4acd-abf6-482c43689753	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 15:27:21.671508+00	po	2026-10-12 15:27:21.671508+00	po	0
900925ae-a75e-4412-8def-a3909c5e7748	95dc54b0-9038-4acd-abf6-482c43689753	EXAMPLE	bd339de0-a2e5-4030-8768-064a30f271c0	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 15:27:21.729069+00	po	2026-10-12 15:27:21.729069+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e7e66a72-b40f-4690-b297-db1eb1c830df	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact", "Playwright", "Cypress", "Selenium", "pytest", "pytest + requests", "Robot Framework", "Cucumber-JS"]	[]	4	t	2026-10-12 15:27:12.481733+00	admin	2026-10-12 15:29:18.230709+00	system	4
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
7092595e-43e5-4d43-bbd5-77a3a629e1cd	4dc9842b-ed04-497e-bd03-4199dcb82ddc	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	1	PASSED	f	2026-10-12 15:27:37.774344+00	2026-10-12 15:27:38.473562+00	699	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 15:27:37.779546+00	qa1	2026-10-12 15:27:38.47535+00	qa1	1	\N
0b639bee-9f53-4e1c-88f3-74b04d07cfa9	e4f1eca5-07a3-41e8-be5b-4543ad51e82e	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	1	PASSED	f	2026-10-12 15:27:38.518076+00	2026-10-12 15:27:38.551082+00	33	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 15:27:38.520146+00	qa1	2026-10-12 15:27:38.552163+00	qa1	1	\N
400d1cb1-e712-4d99-96b9-4e6d1df9ceaa	23696a27-ff98-4350-8505-e2c7dd109a84	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	1	PASSED	f	2026-10-12 15:27:38.564843+00	2026-10-12 15:27:38.595656+00	30	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 15:27:38.566391+00	qa1	2026-10-12 15:27:38.596171+00	qa1	1	\N
5899f35c-8717-4ffa-855e-f77ec9bf8ff2	cf30e2a9-7aec-4884-a225-0060cf9ea653	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	1	1	PASSED	f	2026-10-12 15:27:57.262449+00	2026-10-12 15:27:59.983307+00	2720	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:28:00.002688+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
aef91da5-43da-4c66-9a65-4c27c339d406	6b15bc39-3f0b-4ee3-be3f-230dcf7c04e5	733ef065-6786-4af9-97aa-5570ea1066c3	1	1	PASSED	f	2026-10-12 15:27:58.00717+00	2026-10-12 15:28:00.174937+00	2167	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:28:00.193191+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
693838d3-2c55-4cb5-8b31-9937b312eb35	ef6e7170-56f0-4482-833c-17c4ad9011e6	f1b38cd2-623a-42f3-b185-f3be46c4abcc	1	1	PASSED	f	2026-10-12 15:27:57.262448+00	2026-10-12 15:28:00.42227+00	3159	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.962917+00	dev	2026-10-12 15:28:00.438163+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
27115c18-1064-4c1c-b5fd-83282a5368eb	e6906ac3-3779-47d4-b59c-aa8982115c93	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	1	1	PASSED	f	2026-10-12 15:28:00.213823+00	2026-10-12 15:28:01.86984+00	1655	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:28:01.883477+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
77a862ed-2f11-449c-8abb-394950611edb	3b51a342-82ab-4516-9bd6-aea52d856ac9	f1c0d00d-094d-402a-a168-9187e9108bb2	1	1	PASSED	f	2026-10-12 15:28:00.022282+00	2026-10-12 15:28:01.887581+00	1865	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:28:02.427555+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
47603958-636b-4df8-8f04-97fae7c91b98	b663ad16-4f5a-459d-afed-d1756e220029	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	1	1	PASSED	f	2026-10-12 15:27:58.007167+00	2026-10-12 15:28:35.515996+00	37508	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:27:39.963455+00	dev	2026-10-12 15:28:35.529296+00	anonymousUser	2	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb
6a5192b5-ec3d-42de-9a28-a5deb428d88f	b99110ba-588e-4790-9174-aaa5148bc383	4521d948-2d7c-431e-b9a1-703fd325ebfd	1	1	FAILED	f	2026-10-12 15:28:42.487229+00	2026-10-12 15:28:43.236356+00	749	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:43.236908+00	qa2	1	\N
f5cb9e37-92aa-499c-b971-b6c07eb829ea	d4afb1fc-b303-491e-a837-91f3a5d67b09	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	1	PASSED	f	2026-10-12 15:28:45.185583+00	2026-10-12 15:28:46.100461+00	914	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 15:28:45.188733+00	qa1	2026-10-12 15:28:46.101576+00	qa1	1	\N
5600e321-8ad2-4541-80b3-28b09abfe372	e3300acf-30ee-4367-8e87-cf8a0fbac05e	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	1	PASSED	f	2026-10-12 15:28:46.144633+00	2026-10-12 15:28:46.204544+00	59	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 15:28:46.148472+00	qa1	2026-10-12 15:28:46.205059+00	qa1	1	\N
a26f71f5-36ea-4640-a676-95680548732f	06e614eb-01fc-4e64-aa76-2ae32bd505cd	f1b38cd2-623a-42f3-b185-f3be46c4abcc	1	1	PASSED	f	2026-10-12 15:29:18.940692+00	2026-10-12 15:29:22.455692+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.467107+00	qa1	2026-10-12 15:29:22.467107+00	qa1	0	\N
bec30635-2393-4f9b-8bda-b6d9d0b311d6	c7774ea4-193a-4709-a22c-2061cee3e74f	47708765-6d89-40f2-b5bf-765066cbafb3	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 15:28:47.207257+00	qa1	2026-10-12 15:28:49.692017+00	qa1	1	\N
b9b05350-ee5e-49b0-a83c-7101334c13ae	8d1bd020-fe4d-4c52-b02a-dcbc7cd249df	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	1	2	PASSED	f	2026-10-12 15:29:12.793925+00	2026-10-12 15:29:15.541299+00	2746	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:28:52.25613+00	dev	2026-10-12 15:29:15.553542+00	anonymousUser	2	18e2f9dc-d66b-42cb-972a-67d037f4a408
b9584b14-3ab2-45da-b054-60aa3cca377d	f9067201-27a1-4183-9b8e-56a46c3341f7	d4fe1427-d374-42d6-85ee-721366ccc95d	1	1	PASSED	f	2026-10-12 15:29:12.794016+00	2026-10-12 15:29:16.020469+00	3226	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:28:52.256637+00	dev	2026-10-12 15:29:16.031762+00	anonymousUser	2	18e2f9dc-d66b-42cb-972a-67d037f4a408
2e200946-7565-471e-a39a-6925ccf17ba7	bbe8ab04-982c-4493-948c-3d50399214c4	49aba8a5-0963-4048-a86f-1a00c2fc1e05	1	1	PASSED	f	2026-10-12 15:29:12.793938+00	2026-10-12 15:29:16.382737+00	3588	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:28:52.256637+00	dev	2026-10-12 15:29:16.39353+00	anonymousUser	2	18e2f9dc-d66b-42cb-972a-67d037f4a408
bf0e30e3-080c-4af0-8107-c2066ca7c913	a0dcbb47-c92a-4edc-88bd-25f633b54495	59231cfa-b570-4620-a814-5f966abea164	1	1	FAILED	f	2026-10-12 15:29:12.793993+00	2026-10-12 15:29:18.601778+00	5807	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-1fed3a24/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 15:28:52.256637+00	dev	2026-10-12 15:29:18.614505+00	anonymousUser	2	18e2f9dc-d66b-42cb-972a-67d037f4a408
1abb7816-af7d-40c8-b0c6-300e26f1421e	0522237c-4241-44e2-9d29-262b7c72abc6	f1c0d00d-094d-402a-a168-9187e9108bb2	1	1	PASSED	f	2026-10-12 15:29:21.893692+00	2026-10-12 15:29:22.455692+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.459419+00	qa1	2026-10-12 15:29:22.459419+00	qa1	0	\N
e5c9aa59-4446-4bb7-88c3-e56993cdbf5c	9b50d23d-7cc9-43c6-83d5-1eed770158f3	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	1	1	PASSED	f	2026-10-12 15:29:19.250692+00	2026-10-12 15:29:22.455692+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.471713+00	qa1	2026-10-12 15:29:22.471713+00	qa1	0	\N
10b89d05-1c6e-43f9-b034-ccd1e5446f24	de413776-92cb-4cfb-bd42-74f8ce17ac5e	733ef065-6786-4af9-97aa-5570ea1066c3	1	1	PASSED	f	2026-10-12 15:29:22.013692+00	2026-10-12 15:29:22.455692+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.475358+00	qa1	2026-10-12 15:29:22.475358+00	qa1	0	\N
6da11e31-a5c3-4589-bca3-987360034fd3	9b12352c-930c-45e1-a540-2355901fed05	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	1	1	PASSED	f	2026-10-12 15:29:21.918692+00	2026-10-12 15:29:22.455692+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.47888+00	qa1	2026-10-12 15:29:22.47888+00	qa1	0	\N
198b7753-5494-4e8a-98e6-68c53c4554c4	f93005a3-10d6-403f-8755-2cab575d8c66	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	1	2	PASSED	f	2026-10-12 15:29:21.768692+00	2026-10-12 15:29:22.455692+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.481965+00	qa1	2026-10-12 15:29:22.481965+00	qa1	0	\N
028b94ad-da59-4510-b900-906f5e1b0df5	cd528cb2-7eea-4c6c-985a-a6f2777d55d5	d4fe1427-d374-42d6-85ee-721366ccc95d	1	1	PASSED	f	2026-10-12 15:29:21.908692+00	2026-10-12 15:29:22.455692+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.486616+00	qa1	2026-10-12 15:29:22.486616+00	qa1	0	\N
0beafee9-0a05-4419-be58-48af88e72403	2ccfd916-5921-46e9-b6c1-2f8a9f22db93	59231cfa-b570-4620-a814-5f966abea164	1	1	FAILED	f	2026-10-12 15:29:18.987692+00	2026-10-12 15:29:22.455692+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.490845+00	qa1	2026-10-12 15:29:22.490845+00	qa1	0	\N
516ba180-f2b7-41b5-84e5-c583c9fae87e	cadbb2a7-c638-43c0-b0e3-7f8d32657c91	49aba8a5-0963-4048-a86f-1a00c2fc1e05	1	1	PASSED	f	2026-10-12 15:29:21.641692+00	2026-10-12 15:29:22.455692+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 15:29:22.494661+00	qa1	2026-10-12 15:29:22.494661+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b251fc1d-e52f-4a9a-88f0-7c93ce612fb9	47708765-6d89-40f2-b5bf-765066cbafb3	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 15:27:28.059582+00	qa1	2026-10-12 15:27:28.059582+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	bec30635-2393-4f9b-8bda-b6d9d0b311d6	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 15:28:47.207257+00	qa1	2026-10-12 15:28:50.621262+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 17:26:52.85337	99	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 17:26:52.981706	146	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 17:26:53.155039	132	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 17:26:53.313832	28	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 17:26:53.365745	12	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 17:26:53.395579	75	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 17:26:53.496845	120	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 17:26:53.635234	11	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 17:26:53.663383	13	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 17:26:53.691974	26	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 17:26:53.736353	48	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 17:26:53.805564	80	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 17:26:53.90997	19	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 17:26:53.947623	47	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 17:26:54.014024	49	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 17:26:54.083319	27	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 17:26:54.126662	19	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 17:26:54.163896	4	t
19	19	git sources	SQL	V19__git_sources.sql	1616532274	traceagile_demo	2026-10-12 17:26:54.18826	42	t
\.


--
-- Data for Name: git_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_projects" ("id", "source_id", "name", "default_branch", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
20372435-3aac-495a-af40-70da1267b857	b585abc6-31a0-46c2-9f1b-ba86fa16131c	traceagile	backlog-tableau	\N	2026-10-12 15:27:13.173807+00	admin	2026-10-12 15:27:13.173807+00	admin	0
bc2381df-ef86-4749-a746-1876bbf34ed9	ab0e6c42-c710-4618-9235-97711072f177	saucedemo-e2e	master	\N	2026-10-12 15:27:13.212188+00	admin	2026-10-12 15:27:13.212188+00	admin	0
\.


--
-- Data for Name: git_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_sources" ("id", "name", "base_url", "auth_type", "username", "secret", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b585abc6-31a0-46c2-9f1b-ba86fa16131c	Dépôt local	file:///depots	NONE	\N	\N	Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)	2026-10-12 15:27:13.153007+00	admin	2026-10-12 15:27:13.153007+00	admin	0
ab0e6c42-c710-4618-9235-97711072f177	kerware	https://github.com/kerware	NONE	\N	\N	Projets de formation (GitHub, public)	2026-10-12 15:27:13.199182+00	admin	2026-10-12 15:27:13.199182+00	admin	0
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
54a2489c-9f91-42bb-b289-a489376506fc	REQ	18
54a2489c-9f91-42bb-b289-a489376506fc	TC	15
54a2489c-9f91-42bb-b289-a489376506fc	REL	2
54a2489c-9f91-42bb-b289-a489376506fc	SPR	3
54a2489c-9f91-42bb-b289-a489376506fc	DEF	3
54a2489c-9f91-42bb-b289-a489376506fc	RUN	3
54a2489c-9f91-42bb-b289-a489376506fc	CMP	4
54a2489c-9f91-42bb-b289-a489376506fc	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
55c74458-002a-4b27-8cdf-d16e06ee468a	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 15:27:25.144868+00	qa1	2026-10-12 15:27:25.144868+00	qa1	0	\N	{}	\N	\N
f0235437-8d12-4e16-a135-7ee795b5ff29	223d8c71-f344-4c0d-9413-c6f931d49ff5	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 15:27:25.145383+00	qa1	2026-10-12 15:27:25.145383+00	qa1	0	\N	{}	\N	\N
c732116e-1340-49de-a357-b09147331a04	4521d948-2d7c-431e-b9a1-703fd325ebfd	1	\N	\N	\N	2026-10-12 15:27:25.240756+00	qa1	2026-10-12 15:27:25.240756+00	qa1	0	223d8c71-f344-4c0d-9413-c6f931d49ff5	{}	Comptes	problem_user
acef1f0d-b642-4576-8ce0-1ba580d7e2d1	4521d948-2d7c-431e-b9a1-703fd325ebfd	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 15:27:25.240756+00	qa1	2026-10-12 15:27:25.240756+00	qa1	0	\N	{}	\N	\N
0a697607-069b-48dd-8c4f-fae09ae360b4	4521d948-2d7c-431e-b9a1-703fd325ebfd	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 15:27:25.240756+00	qa1	2026-10-12 15:27:25.240756+00	qa1	0	\N	{}	\N	\N
b4a4eda7-af11-44fe-855b-8c139201d717	4521d948-2d7c-431e-b9a1-703fd325ebfd	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 15:27:25.240756+00	qa1	2026-10-12 15:27:25.240756+00	qa1	0	\N	{}	\N	\N
d9cc496f-dcb3-44b1-a81d-222fc85d0e53	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	\N	\N	\N	2026-10-12 15:27:28.127604+00	qa1	2026-10-12 15:27:28.127604+00	qa1	0	223d8c71-f344-4c0d-9413-c6f931d49ff5	{}	Comptes	standard_user
becb037b-d5a7-4729-be5b-8d63ef32d946	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 15:27:28.127604+00	qa1	2026-10-12 15:27:28.127604+00	qa1	0	\N	{}	\N	\N
a3a4a629-2d55-4da2-ae45-ec527fbe5a3e	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 15:27:28.127604+00	qa1	2026-10-12 15:27:28.127604+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
13125d6e-54a6-48c3-8b85-d5c045aeffe2	08701d22-a93d-4128-8d94-0023fef3c40f	327	ms	p95Ms	TC-11	RUN-2	2026-10-12 15:29:16.382737+00	TARGET_MET	2026-10-12 15:29:16.403404+00	anonymousUser	2026-10-12 15:29:16.403404+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
c81735fc-7bca-4948-bb18-89d6730837a1	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:40.035385+00
5dd841d2-21a2-4f22-8bfd-43258846fb82	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:57.271813+00
5da84e69-33ea-44e1-9b62-6c5080d95166	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:57.808874+00
0ab2861b-618c-4db4-9875-730f54f7c028	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:58.015369+00
49e2ef71-b944-4a7a-a2f5-d02387a4c965	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:58.535506+00
b99d8a29-9427-4b38-98c0-9a41ecbae9da	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:27:59.993165+00
c9de14d1-a7e9-441d-b818-3f2adc35a579	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:00.029724+00
69303a5a-222f-473a-8302-506aa2de0291	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:00.185404+00
c81582d0-7d2d-445a-94a8-e1411a8db277	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:00.223316+00
1142e53b-46c2-425e-8d8a-a29c1d055897	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:00.432367+00
963f83db-bade-4d0c-a9e0-de1dad994bd4	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:01.878764+00
c5735c24-c8f2-4094-bb22-e6cd499ee7f8	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:02.41966+00
3757c4af-8df1-4608-9621-a09a5a97cc90	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:35.524862+00
b949b25a-8fa5-4866-99c2-57db0f310d5a	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	2026-10-12 15:28:35.560224+00
76bf12c1-f516-4e4b-b4c9-ab1fe4360238	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:28:52.815978+00
10c56e86-a578-4b43-a2f8-1aed8f676f61	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:12.800702+00
49f0eb27-4b0c-4f5a-b696-c776f0b8413b	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:13.317794+00
c251d4d4-b9e9-4a84-bdab-d3543cdcd31c	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:14.335316+00
ee4e46e2-63ed-45be-863e-8988d35c4e5d	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:14.335316+00
5c57b8a6-3d9f-4d19-a0ee-e448426cacd3	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:15.549366+00
d557c0ce-2c4b-430a-8ea1-dbf890905cb1	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:16.027653+00
8eb3e605-5c03-4335-824a-a3fb7ad49669	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:16.389785+00
c48c2ff6-84f0-4aaa-b168-7adcfadaa975	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:18.608175+00
bb480b56-42ce-431b-a0fa-2a2d035e59b9	18e2f9dc-d66b-42cb-972a-67d037f4a408	2026-10-12 15:29:18.632217+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4ab96e39-a959-41bd-a94d-d0847bd01de2	54a2489c-9f91-42bb-b289-a489376506fc	4b720c70-2a06-4f4e-9363-989211d900d3	ADMINISTRATOR	2026-10-12 15:27:11.213961+00	admin	2026-10-12 15:27:11.213961+00	admin	0
9c9364a8-2124-4dca-9edb-818e23d5ef11	54a2489c-9f91-42bb-b289-a489376506fc	16d3b928-1327-436b-b4ba-ce5d92a9595d	PRODUCT_OWNER	2026-10-12 15:27:11.213961+00	admin	2026-10-12 15:27:11.213961+00	admin	0
bcc0edb8-87ad-4606-86ca-76c0aa656d5d	54a2489c-9f91-42bb-b289-a489376506fc	88e057fa-32a5-49de-9e07-aa43c9fab938	TESTER	2026-10-12 15:27:11.214483+00	admin	2026-10-12 15:27:11.214483+00	admin	0
65b70258-a853-4bb3-bb4a-069d9ec11224	54a2489c-9f91-42bb-b289-a489376506fc	cdb1d017-6c70-4fd0-b5a5-b3f6e1dcc80e	TESTER	2026-10-12 15:27:11.214483+00	admin	2026-10-12 15:27:11.214483+00	admin	0
c3a4595a-603a-47d0-87d8-3348e06e576f	54a2489c-9f91-42bb-b289-a489376506fc	6d314bcb-72e7-411c-8c73-9986b2fea171	DEVELOPER	2026-10-12 15:27:11.214483+00	admin	2026-10-12 15:27:11.214483+00	admin	0
27202eb3-6291-41e1-86fe-b6b4cdb7c129	54a2489c-9f91-42bb-b289-a489376506fc	a038163d-43eb-49a3-a8d0-63ad804f920f	VIEWER	2026-10-12 15:27:11.214483+00	admin	2026-10-12 15:27:11.214483+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
54a2489c-9f91-42bb-b289-a489376506fc	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 15:27:11.078143+00	admin	2026-10-12 15:27:11.078143+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
320bfae7-35db-4a5d-a609-8d33e6e34ad0	54a2489c-9f91-42bb-b289-a489376506fc	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 15:27:33.655902+00	po	2026-10-12 15:27:35.115565+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e9ea10b1-66c4-4ac7-8f2a-e4952fdf55c0	54a2489c-9f91-42bb-b289-a489376506fc	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 15:28:39.695659+00	po	2026-10-12 15:28:39.695659+00	po	0
a34ce0ee-d77f-4610-b0d0-c88b94fc4b85	54a2489c-9f91-42bb-b289-a489376506fc	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 15:28:39.703492+00	po	2026-10-12 15:28:39.703492+00	po	0
d761ef94-bca9-4d90-b756-b9b679ff7abe	54a2489c-9f91-42bb-b289-a489376506fc	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 15:29:38.908163+00	po	2026-10-12 15:29:38.908163+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9ec6c452-b9d3-4e98-a9c7-255cba40ebff	54a2489c-9f91-42bb-b289-a489376506fc	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T15:28:39.732474800Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 9, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 6, "failed": 0, "notRun": 0, "passed": 6}], "attempts": 9, "byStatus": {"PASSED": 9}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 9, "attempts": 9}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 15:28:39.757591+00	clôture du sprint	2026-10-12 15:28:39.757591+00	po	2026-10-12 15:28:39.760076+00	po	1
ccc62d27-236a-4956-a2fc-db8241afb385	54a2489c-9f91-42bb-b289-a489376506fc	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T15:29:35.537500700Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 15:29:37.021322+00	f	\N	\N	2026-10-12 15:29:35.551198+00	po	2026-10-12 15:29:37.021322+00	po	2
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
ce152970-63d5-41d9-9c5c-34dc052d573f	ad60110a-7c5f-4ea9-bed9-ea4f29866094	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.026081+00	po	2026-10-12 15:27:18.026081+00	po	0
d7eccf46-2020-447d-9f78-53795f48df6d	92195f11-baa2-45bd-be3a-7275cf9a3714	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.073045+00	po	2026-10-12 15:27:18.073045+00	po	0
5d058d9b-d3c6-4f3e-8472-eae684b0542d	8efd7182-8f71-46f6-a75d-32ee338fddea	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.110625+00	po	2026-10-12 15:27:18.110625+00	po	0
1597de3e-a0c2-4444-bed1-2e6202683754	425ea114-f313-4545-aef6-7b0689673731	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.147879+00	po	2026-10-12 15:27:18.147879+00	po	0
62dca7bb-3f79-46ca-9432-3cca1086ad23	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.191287+00	po	2026-10-12 15:27:18.191287+00	po	0
c7046959-ec4a-4fba-af51-75b2cd9cc5e1	5ac319b3-077e-4a16-a470-fe8bf0260397	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.232254+00	po	2026-10-12 15:27:18.232254+00	po	0
e0f8d5c6-710a-4186-9a76-5307ea7cf533	ba8d4956-c976-4691-aba0-c3b98c97ebee	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:18.274137+00	po	2026-10-12 15:27:18.274137+00	po	0
8c35e8c0-8bd2-471a-98cb-0b08893bfc13	2b918b31-1456-4c95-9d2e-587617e6d967	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 15:27:19.210852+00	po	2026-10-12 15:27:19.210852+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5e28b3d3-bc72-4174-b762-8c02a95210cc	54a2489c-9f91-42bb-b289-a489376506fc	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 15:27:14.706776+00	po	2026-10-12 15:27:14.706776+00	po	0
6b7372d2-2bd1-46a7-8a42-0a16ed88659b	54a2489c-9f91-42bb-b289-a489376506fc	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 15:27:14.787402+00	po	2026-10-12 15:27:14.787402+00	po	0
c7d676e7-cac1-41d7-9815-32e1bf7ca6db	54a2489c-9f91-42bb-b289-a489376506fc	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 15:27:14.926891+00	po	2026-10-12 15:27:14.926891+00	po	0
699b11c2-179e-4679-9962-98d207dfc0f1	54a2489c-9f91-42bb-b289-a489376506fc	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 15:27:15.107857+00	po	2026-10-12 15:27:15.107857+00	po	0
92195f11-baa2-45bd-be3a-7275cf9a3714	54a2489c-9f91-42bb-b289-a489376506fc	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	6b7372d2-2bd1-46a7-8a42-0a16ed88659b	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 15:27:14.890005+00	po	2026-10-12 15:28:37.435945+00	po	3
8efd7182-8f71-46f6-a75d-32ee338fddea	54a2489c-9f91-42bb-b289-a489376506fc	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	c7d676e7-cac1-41d7-9815-32e1bf7ca6db	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 15:27:14.966169+00	po	2026-10-12 15:28:37.476354+00	po	3
ba8d4956-c976-4691-aba0-c3b98c97ebee	54a2489c-9f91-42bb-b289-a489376506fc	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	699b11c2-179e-4679-9962-98d207dfc0f1	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 15:27:15.178682+00	po	2026-10-12 15:28:40.430545+00	po	2
e20ac237-3793-4419-891d-46ddfc914700	54a2489c-9f91-42bb-b289-a489376506fc	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 15:27:15.248289+00	po	2026-10-12 15:27:15.248289+00	po	0
95dc54b0-9038-4acd-abf6-482c43689753	54a2489c-9f91-42bb-b289-a489376506fc	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e20ac237-3793-4419-891d-46ddfc914700	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 15:27:15.280082+00	po	2026-10-12 15:27:15.280082+00	po	0
08701d22-a93d-4128-8d94-0023fef3c40f	54a2489c-9f91-42bb-b289-a489376506fc	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 15:27:17.200552+00	po	2026-10-12 15:27:17.200552+00	po	0
c9797ec5-af3e-4b7d-8382-7cd5eccf3ad4	54a2489c-9f91-42bb-b289-a489376506fc	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	5e28b3d3-bc72-4174-b762-8c02a95210cc	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 15:27:17.230453+00	po	2026-10-12 15:27:17.230453+00	po	0
ad60110a-7c5f-4ea9-bed9-ea4f29866094	54a2489c-9f91-42bb-b289-a489376506fc	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	6b7372d2-2bd1-46a7-8a42-0a16ed88659b	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 15:27:14.846956+00	po	2026-10-12 15:28:37.392937+00	po	3
2b918b31-1456-4c95-9d2e-587617e6d967	54a2489c-9f91-42bb-b289-a489376506fc	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	699b11c2-179e-4679-9962-98d207dfc0f1	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 15:27:15.213979+00	po	2026-10-12 15:28:40.430545+00	po	2
f0d80128-acd4-42ef-a7a8-ba96c998a985	54a2489c-9f91-42bb-b289-a489376506fc	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	e20ac237-3793-4419-891d-46ddfc914700	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 15:27:16.964273+00	po	2026-10-12 15:27:16.964273+00	po	0
425ea114-f313-4545-aef6-7b0689673731	54a2489c-9f91-42bb-b289-a489376506fc	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	c7d676e7-cac1-41d7-9815-32e1bf7ca6db	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 15:27:15.027826+00	po	2026-10-12 15:28:37.514857+00	po	3
5ac319b3-077e-4a16-a470-fe8bf0260397	54a2489c-9f91-42bb-b289-a489376506fc	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	699b11c2-179e-4679-9962-98d207dfc0f1	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 15:27:15.141929+00	po	2026-10-12 15:28:40.430545+00	po	2
5cdf1568-16c2-4f61-8a68-d4b15c92ef26	54a2489c-9f91-42bb-b289-a489376506fc	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	c7d676e7-cac1-41d7-9815-32e1bf7ca6db	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 15:27:15.067489+00	po	2026-10-12 15:29:31.115092+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8c5fa07a-9b4c-46bb-9173-9522221c264f	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	5899f35c-8717-4ffa-855e-f77ec9bf8ff2	log-TC-4.txt	text/plain	SYSTEM_TRACE	393	2026-10-12 15:28:00.001115+00	anonymousUser	2026-10-12 15:28:00.001115+00	anonymousUser	0
42eea57b-eb50-4271-803a-e9f82edb36a4	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	aef91da5-43da-4c66-9a65-4c27c339d406	log-TC-5.txt	text/plain	SYSTEM_TRACE	390	2026-10-12 15:28:00.192153+00	anonymousUser	2026-10-12 15:28:00.192153+00	anonymousUser	0
b91e882a-2fc1-4d75-956f-3fe73f843d34	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	693838d3-2c55-4cb5-8b31-9937b312eb35	log-TC-3.txt	text/plain	SYSTEM_TRACE	525	2026-10-12 15:28:00.43764+00	anonymousUser	2026-10-12 15:28:00.43764+00	anonymousUser	0
a918250a-d0c9-49bb-8b3b-3aa29ae2a71a	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	27115c18-1064-4c1c-b5fd-83282a5368eb	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 15:28:01.882432+00	anonymousUser	2026-10-12 15:28:01.882432+00	anonymousUser	0
e9eb2fb1-b0a9-4878-8440-a96a0e4f485d	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	77a862ed-2f11-449c-8abb-394950611edb	log-TC-7.txt	text/plain	SYSTEM_TRACE	394	2026-10-12 15:28:02.424824+00	anonymousUser	2026-10-12 15:28:02.424824+00	anonymousUser	0
972c7808-1945-4f2b-ba1c-04144746c49c	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	47603958-636b-4df8-8f04-97fae7c91b98	log-TC-14.txt	text/plain	SYSTEM_TRACE	8738	2026-10-12 15:28:35.528738+00	anonymousUser	2026-10-12 15:28:35.528738+00	anonymousUser	0
ce8fdfd5-a6f3-410b-af93-a45110800526	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	\N	system.log	text/plain	SYSTEM_TRACE	18362	2026-10-12 15:28:35.563093+00	anonymousUser	2026-10-12 15:28:35.563093+00	anonymousUser	0
9f2d0dbc-bedc-4f71-b99a-f9a41fa7a52b	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	\N	junit.xml	application/xml	JUNIT	1360	2026-10-12 15:28:35.565853+00	anonymousUser	2026-10-12 15:28:35.565853+00	anonymousUser	0
5b6b6048-43be-4994-a4de-146b08bf8433	d08071bd-5d30-4cc6-9cd8-a2dc3fc0b7fb	\N	report.json	application/json	REPORT	554	2026-10-12 15:28:35.568541+00	anonymousUser	2026-10-12 15:28:35.568541+00	anonymousUser	0
50f86602-0ee7-4ac1-bfa6-74a77ddf04cc	18e2f9dc-d66b-42cb-972a-67d037f4a408	b9b05350-ee5e-49b0-a83c-7101334c13ae	log-TC-8.txt	text/plain	SYSTEM_TRACE	728	2026-10-12 15:29:15.553015+00	anonymousUser	2026-10-12 15:29:15.553015+00	anonymousUser	0
7803cd05-f7e6-46b9-8232-4a7c8a9c9cf8	18e2f9dc-d66b-42cb-972a-67d037f4a408	b9584b14-3ab2-45da-b054-60aa3cca377d	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 15:29:16.031243+00	anonymousUser	2026-10-12 15:29:16.031243+00	anonymousUser	0
8401d158-01c7-4275-b241-98759f59ba9f	18e2f9dc-d66b-42cb-972a-67d037f4a408	2e200946-7565-471e-a39a-6925ccf17ba7	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 15:29:16.393155+00	anonymousUser	2026-10-12 15:29:16.393155+00	anonymousUser	0
c15bf32c-8918-4c61-8c7b-2f55fd612ddb	18e2f9dc-d66b-42cb-972a-67d037f4a408	bf0e30e3-080c-4af0-8107-c2066ca7c913	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 15:29:18.610806+00	anonymousUser	2026-10-12 15:29:18.610806+00	anonymousUser	0
0b22fd0f-dbe9-450a-ba99-635196ff8033	18e2f9dc-d66b-42cb-972a-67d037f4a408	bf0e30e3-080c-4af0-8107-c2066ca7c913	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 15:29:18.614+00	anonymousUser	2026-10-12 15:29:18.614+00	anonymousUser	0
72d8aa89-494d-4743-94db-5b40042d1863	18e2f9dc-d66b-42cb-972a-67d037f4a408	\N	system.log	text/plain	SYSTEM_TRACE	8997	2026-10-12 15:29:18.633781+00	anonymousUser	2026-10-12 15:29:18.633781+00	anonymousUser	0
12763ef1-af88-4d84-ba76-ac3103256f19	18e2f9dc-d66b-42cb-972a-67d037f4a408	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 15:29:18.635857+00	anonymousUser	2026-10-12 15:29:18.635857+00	anonymousUser	0
3b398c2b-3ce0-4483-85b4-2840afa64010	18e2f9dc-d66b-42cb-972a-67d037f4a408	\N	report.json	application/json	REPORT	475	2026-10-12 15:29:18.637987+00	anonymousUser	2026-10-12 15:29:18.637987+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
41654ec8-5ea3-48b8-ac0b-6e948a4c3e3f	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 15:28:47.315825+00	qa1	2026-10-12 15:28:47.315825+00	qa1	0
d65eaf44-73e3-4ab5-af3a-0176df732e59	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 15:28:47.370953+00	qa1	2026-10-12 15:28:47.370953+00	qa1	0
5afc00ee-6652-497f-abc8-1158394c2969	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 15:28:47.501283+00	qa1	2026-10-12 15:28:47.501283+00	qa1	0
2e0a5897-b57b-45d2-9070-8afa8d8bd0f7	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 15:28:47.567848+00	qa1	2026-10-12 15:28:47.567848+00	qa1	0
dccf4098-fbe9-4bee-ad58-d4a93d67ff88	b3456cdc-874d-4ca5-9412-f1cf7bcf8f82	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	665e1d1d-a50f-4558-9330-30aa05756080	2026-10-12 15:28:47.439833+00	qa1	2026-10-12 15:28:48.425549+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0219bc3c-6491-4715-9d37-9a2edb3f7982	af367b72-2a4e-4d66-8540-8393285694c4	ad60110a-7c5f-4ea9-bed9-ea4f29866094	1	3	DONE	2026-10-12 15:27:34.298353+00	po	2026-10-12 15:28:39.697205+00	po	1
f1253fa2-402b-42c9-8bb6-3abd77d0ca88	af367b72-2a4e-4d66-8540-8393285694c4	92195f11-baa2-45bd-be3a-7275cf9a3714	2	2	DONE	2026-10-12 15:27:34.36532+00	po	2026-10-12 15:28:39.697205+00	po	1
88377b15-0065-4d3f-b6d7-b1e6643a7bef	af367b72-2a4e-4d66-8540-8393285694c4	8efd7182-8f71-46f6-a75d-32ee338fddea	3	3	DONE	2026-10-12 15:27:34.433755+00	po	2026-10-12 15:28:39.697205+00	po	1
4e450cf0-083e-48f3-8747-f6c740e31a91	af367b72-2a4e-4d66-8540-8393285694c4	425ea114-f313-4545-aef6-7b0689673731	4	2	DONE	2026-10-12 15:27:34.498434+00	po	2026-10-12 15:28:39.697205+00	po	1
2b307cb2-7aad-48df-b524-034a7d9235c9	af367b72-2a4e-4d66-8540-8393285694c4	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	5	2	DONE	2026-10-12 15:27:34.570205+00	po	2026-10-12 15:28:39.697205+00	po	1
58c92751-8e34-4f30-9cee-69b45d9b36ce	28b827fd-ddd2-42ee-87c7-85effe954295	5ac319b3-077e-4a16-a470-fe8bf0260397	1	3	PLANNED	2026-10-12 15:28:40.387246+00	po	2026-10-12 15:28:40.387246+00	po	0
b598e1df-9c48-4ce0-b344-0d941e3fa938	28b827fd-ddd2-42ee-87c7-85effe954295	ba8d4956-c976-4691-aba0-c3b98c97ebee	2	3	PLANNED	2026-10-12 15:28:40.387822+00	po	2026-10-12 15:28:40.387822+00	po	0
bf22559f-8367-4d56-9906-8a4736a89388	28b827fd-ddd2-42ee-87c7-85effe954295	2b918b31-1456-4c95-9d2e-587617e6d967	3	2	PLANNED	2026-10-12 15:28:40.387822+00	po	2026-10-12 15:28:40.387822+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
af367b72-2a4e-4d66-8540-8393285694c4	54a2489c-9f91-42bb-b289-a489376506fc	320bfae7-35db-4a5d-a609-8d33e6e34ad0	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 15:27:33.683904+00	po	2026-10-12 15:28:39.697205+00	po	2
28b827fd-ddd2-42ee-87c7-85effe954295	54a2489c-9f91-42bb-b289-a489376506fc	320bfae7-35db-4a5d-a609-8d33e6e34ad0	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 15:27:33.728656+00	po	2026-10-12 15:28:40.430545+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
b90dcf23-57b3-4533-b3f5-627cee6f1ca9	7092595e-43e5-4d43-bbd5-77a3a629e1cd	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:27:37.781168+00	qa1	2026-10-12 15:27:37.906323+00	qa1	1	\N
3391c73f-62da-4c1d-8973-46c7e360b679	7092595e-43e5-4d43-bbd5-77a3a629e1cd	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 15:27:37.781168+00	qa1	2026-10-12 15:27:38.47535+00	qa1	1	\N
6ae9b55d-4daa-4881-8175-d47918ec219f	0b639bee-9f53-4e1c-88f3-74b04d07cfa9	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:27:38.520146+00	qa1	2026-10-12 15:27:38.536235+00	qa1	1	\N
998866b2-514a-4f8d-aa47-deeb77cf3fcc	0b639bee-9f53-4e1c-88f3-74b04d07cfa9	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 15:27:38.520146+00	qa1	2026-10-12 15:27:38.552163+00	qa1	1	\N
dd02bd95-062c-474b-93f7-90b243d54841	400d1cb1-e712-4d99-96b9-4e6d1df9ceaa	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:27:38.566906+00	qa1	2026-10-12 15:27:38.581794+00	qa1	1	\N
464d60e8-7abe-4e1e-ad5f-00d4915e0881	400d1cb1-e712-4d99-96b9-4e6d1df9ceaa	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 15:27:38.566906+00	qa1	2026-10-12 15:27:38.596171+00	qa1	1	\N
7a84a99e-f361-47a6-8820-749ef4c6137a	6a5192b5-ec3d-42de-9a28-a5deb428d88f	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:42.634982+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
69d379ce-c9ca-42eb-953c-579f047b0bcb	6a5192b5-ec3d-42de-9a28-a5deb428d88f	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:42.771207+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
ddfc15f3-fd81-40d6-a60a-d983630d1dd8	6a5192b5-ec3d-42de-9a28-a5deb428d88f	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:42.884879+00	qa2	1	\N
af00aebc-6c0c-4345-a8da-0c9f00de8fb7	6a5192b5-ec3d-42de-9a28-a5deb428d88f	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:42.956441+00	qa2	1	\N
879c3075-0c70-4115-b1b5-01862809622b	6a5192b5-ec3d-42de-9a28-a5deb428d88f	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 15:28:42.491747+00	qa2	2026-10-12 15:28:43.236908+00	qa2	1	\N
0cd1b00f-7ebf-422f-b478-1bc78fd246c5	f5cb9e37-92aa-499c-b971-b6c07eb829ea	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:28:45.188733+00	qa1	2026-10-12 15:28:45.342456+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
a592149b-e841-46f9-9aaf-31dd4e8e1938	f5cb9e37-92aa-499c-b971-b6c07eb829ea	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 15:28:45.188733+00	qa1	2026-10-12 15:28:45.869293+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
e7eb2576-822b-41aa-b4d0-529726edcb1d	f5cb9e37-92aa-499c-b971-b6c07eb829ea	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 15:28:45.188733+00	qa1	2026-10-12 15:28:45.984898+00	qa1	1	\N
951c8199-c015-4afc-91d9-b79272182270	f5cb9e37-92aa-499c-b971-b6c07eb829ea	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 15:28:45.188733+00	qa1	2026-10-12 15:28:46.102081+00	qa1	1	\N
c7d450a8-1882-43cf-ae4e-2382b0bc8c05	5600e321-8ad2-4541-80b3-28b09abfe372	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 15:28:46.148472+00	qa1	2026-10-12 15:28:46.164127+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
c31cf4bb-1e4c-4d7c-8114-8a2302e7b49e	5600e321-8ad2-4541-80b3-28b09abfe372	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 15:28:46.148472+00	qa1	2026-10-12 15:28:46.177377+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
3ad4e26d-8dbc-4d58-8d2c-7aa0d7621b25	5600e321-8ad2-4541-80b3-28b09abfe372	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 15:28:46.148472+00	qa1	2026-10-12 15:28:46.191201+00	qa1	1	\N
0a4d82dd-6ad2-4604-806e-57d43b0bae73	5600e321-8ad2-4541-80b3-28b09abfe372	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 15:28:46.148999+00	qa1	2026-10-12 15:28:46.205059+00	qa1	1	\N
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
38b85eb2-d166-4e94-8b64-dbec5090c0be	223d8c71-f344-4c0d-9413-c6f931d49ff5	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 15:27:25.148516+00	qa1	2026-10-12 15:27:25.148516+00	qa1	0
c23b983e-253c-4eef-bca9-f4bc34da6d45	4521d948-2d7c-431e-b9a1-703fd325ebfd	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 15:27:25.242923+00	qa1	2026-10-12 15:27:25.242923+00	qa1	0
df4361e6-e107-437f-8999-3e31c277b92c	f1b38cd2-623a-42f3-b185-f3be46c4abcc	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "backlog-tableau", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:25.329962+00	dev	2026-10-12 15:27:25.329962+00	dev	0
acf6497e-1dad-4c51-89c6-73ddc08bf1d2	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "backlog-tableau", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:25.409453+00	dev	2026-10-12 15:27:25.409453+00	dev	0
76a238bb-1821-4bf8-8a5d-54d1dfce0f3b	733ef065-6786-4af9-97aa-5570ea1066c3	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "backlog-tableau", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:25.464161+00	dev	2026-10-12 15:27:25.464161+00	dev	0
a30d7d52-1be6-4a90-9b54-d50ddb58830b	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "backlog-tableau", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:25.535749+00	dev	2026-10-12 15:27:25.535749+00	dev	0
f2fb607f-10cf-49ff-925e-cfcb05632fb4	f1c0d00d-094d-402a-a168-9187e9108bb2	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "backlog-tableau", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:25.601514+00	dev	2026-10-12 15:27:25.601514+00	dev	0
1ebc7a49-dea1-4ae1-95a1-71600ddf8b02	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:26.874638+00	qa1	2026-10-12 15:27:26.874638+00	qa1	0
5b989390-9b25-494d-8868-49db85f4f2d3	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "backlog-tableau", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:27.020438+00	qa1	2026-10-12 15:27:27.020438+00	qa1	0
cf6c328d-b988-4723-914d-1da649c85370	47708765-6d89-40f2-b5bf-765066cbafb3	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 15:27:28.059582+00	qa1	2026-10-12 15:27:28.059582+00	qa1	0
6d60d3da-c43d-410a-a70d-720fcef2dad0	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	1	{"key": "TC-14", "kind": "AUTOMATED", "path": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "tags": null, "title": "Catalogue : noms et prix (Playwright Java)", "branch": "master", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "Java", "priority": "SHOULD", "framework": "JUnit 5", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "kerware, smoke", "gherkinSource": null, "repositoryUrl": "https://github.com/kerware/saucedemo-e2e", "testIdentifier": "InventaireCatalogueTest#catalogueAffiche", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:28.212061+00	dev	2026-10-12 15:27:28.212061+00	dev	0
a77e2c78-7471-4c03-8611-98bb5fce5eca	d4fe1427-d374-42d6-85ee-721366ccc95d	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "backlog-tableau", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:27.86431+00	dev	2026-10-12 15:27:27.86431+00	dev	0
a755a3f8-d505-42b7-8d0a-dc8667fdf065	59231cfa-b570-4620-a814-5f966abea164	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "backlog-tableau", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:27.928922+00	dev	2026-10-12 15:27:27.928922+00	dev	0
71380476-c2ea-44d8-9daf-6e011e217112	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 15:27:28.127604+00	qa1	2026-10-12 15:27:28.127604+00	qa1	0
4445f982-9167-4f4b-aca9-39b7e238c3d2	49aba8a5-0963-4048-a86f-1a00c2fc1e05	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "backlog-tableau", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 15:27:27.992831+00	dev	2026-10-12 15:27:27.992831+00	dev	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
223d8c71-f344-4c0d-9413-c6f931d49ff5	54a2489c-9f91-42bb-b289-a489376506fc	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 15:27:25.140754+00	qa1	2026-10-12 15:27:25.210116+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
4521d948-2d7c-431e-b9a1-703fd325ebfd	54a2489c-9f91-42bb-b289-a489376506fc	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 15:27:25.240756+00	qa1	2026-10-12 15:27:25.292899+00	qa1	1	[]	[]	f
f1b38cd2-623a-42f3-b185-f3be46c4abcc	54a2489c-9f91-42bb-b289-a489376506fc	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 15:27:25.327351+00	dev	2026-10-12 15:27:25.380085+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
1a7fb472-ee82-4f6c-8442-b866ff9d71e9	54a2489c-9f91-42bb-b289-a489376506fc	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 15:27:25.408939+00	dev	2026-10-12 15:27:25.440368+00	qa1	1	[]	[]	f
733ef065-6786-4af9-97aa-5570ea1066c3	54a2489c-9f91-42bb-b289-a489376506fc	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 15:27:25.463504+00	dev	2026-10-12 15:27:25.503897+00	qa1	1	[]	[]	f
f1c0d00d-094d-402a-a168-9187e9108bb2	54a2489c-9f91-42bb-b289-a489376506fc	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 15:27:25.601004+00	dev	2026-10-12 15:27:25.635194+00	qa1	1	[]	[]	f
59231cfa-b570-4620-a814-5f966abea164	54a2489c-9f91-42bb-b289-a489376506fc	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 15:27:27.928409+00	dev	2026-10-12 15:27:27.959885+00	qa1	1	[]	[]	f
b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	54a2489c-9f91-42bb-b289-a489376506fc	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 15:27:26.874128+00	qa1	2026-10-12 15:27:27.028472+00	qa1	2	[]	[]	f
d4fe1427-d374-42d6-85ee-721366ccc95d	54a2489c-9f91-42bb-b289-a489376506fc	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 15:27:27.863795+00	dev	2026-10-12 15:27:27.896741+00	qa1	1	[]	[]	f
49aba8a5-0963-4048-a86f-1a00c2fc1e05	54a2489c-9f91-42bb-b289-a489376506fc	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 15:27:27.992062+00	dev	2026-10-12 15:27:28.03208+00	qa1	1	[]	[]	f
47708765-6d89-40f2-b5bf-765066cbafb3	54a2489c-9f91-42bb-b289-a489376506fc	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 15:27:28.057951+00	qa1	2026-10-12 15:27:28.098001+00	qa1	1	[]	[]	f
b7c5ea07-1bfb-4097-a31f-a494a8a53a91	54a2489c-9f91-42bb-b289-a489376506fc	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 15:27:28.127069+00	qa1	2026-10-12 15:27:28.171648+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	54a2489c-9f91-42bb-b289-a489376506fc	TC-14	14	AUTOMATED	Catalogue : noms et prix (Playwright Java)	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 15:27:28.211391+00	dev	2026-10-12 15:27:28.250073+00	qa1	1	[]	[]	f
0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	54a2489c-9f91-42bb-b289-a489376506fc	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 15:27:25.535234+00	dev	2026-10-12 15:29:31.126534+00	po	2	[]	[]	f
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
c9ac45f6-798f-47a8-b58e-f02579ffda01	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	223d8c71-f344-4c0d-9413-c6f931d49ff5	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	VERIFIES	MANUAL	2026-10-12 15:27:25.158429+00	qa1	2026-10-12 15:27:25.158429+00	qa1	0	\N
e2e2fb0c-3633-4b1c-89d1-f5456635d071	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	223d8c71-f344-4c0d-9413-c6f931d49ff5	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	VERIFIES	MANUAL	2026-10-12 15:27:25.158429+00	qa1	2026-10-12 15:27:25.158429+00	qa1	0	\N
bfd81f4b-3f3f-434e-890e-f2264bfbbaa4	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	4521d948-2d7c-431e-b9a1-703fd325ebfd	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	PARTIALLY_VERIFIES	MANUAL	2026-10-12 15:27:25.247548+00	qa1	2026-10-12 15:27:25.247548+00	qa1	0	\N
c2350482-3aed-4918-bcef-d8854680c554	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	4521d948-2d7c-431e-b9a1-703fd325ebfd	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	VERIFIES	MANUAL	2026-10-12 15:27:25.247548+00	qa1	2026-10-12 15:27:25.247548+00	qa1	0	\N
ccff4158-ff35-4e0f-b743-d3878a6a5bec	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1b38cd2-623a-42f3-b185-f3be46c4abcc	REQUIREMENT	ad60110a-7c5f-4ea9-bed9-ea4f29866094	VERIFIES	MANUAL	2026-10-12 15:27:25.334736+00	dev	2026-10-12 15:27:25.334736+00	dev	0	\N
5bef68ac-9193-4ed7-81f3-f7935232560c	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1b38cd2-623a-42f3-b185-f3be46c4abcc	REQUIREMENT	92195f11-baa2-45bd-be3a-7275cf9a3714	VERIFIES	MANUAL	2026-10-12 15:27:25.335243+00	dev	2026-10-12 15:27:25.335243+00	dev	0	\N
71ceac51-692a-478a-ba23-4083454e5c9b	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	1a7fb472-ee82-4f6c-8442-b866ff9d71e9	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	VERIFIES	MANUAL	2026-10-12 15:27:25.412368+00	dev	2026-10-12 15:27:25.412368+00	dev	0	\N
e7a1b387-0d16-458b-b9d3-b2840e95418b	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	733ef065-6786-4af9-97aa-5570ea1066c3	REQUIREMENT	425ea114-f313-4545-aef6-7b0689673731	VERIFIES	MANUAL	2026-10-12 15:27:25.466776+00	dev	2026-10-12 15:27:25.466776+00	dev	0	\N
f6a0d510-9d60-4b42-91a4-c5cbb2ad5e84	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	f1c0d00d-094d-402a-a168-9187e9108bb2	REQUIREMENT	c9797ec5-af3e-4b7d-8382-7cd5eccf3ad4	VERIFIES	MANUAL	2026-10-12 15:27:25.604216+00	dev	2026-10-12 15:27:25.604216+00	dev	0	\N
f110978e-81b0-4bc1-8fbf-94948c8c8db0	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	REQUIREMENT	5ac319b3-077e-4a16-a470-fe8bf0260397	VERIFIES	GHERKIN_TAG	2026-10-12 15:27:26.880255+00	qa1	2026-10-12 15:27:26.880255+00	qa1	0	\N
2df8f745-4659-49a8-b1d8-c7f42574c358	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b686ebd7-f48a-452e-b25f-9bdcd4d0d2f5	ACCEPTANCE_CRITERION	e2ea298d-e6a5-433f-a82e-5b9873330f40	VERIFIES	GHERKIN_TAG	2026-10-12 15:27:26.888321+00	qa1	2026-10-12 15:27:26.888321+00	qa1	0	\N
4ecaf037-d10b-4fac-ad3c-967a82b2dec2	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	d4fe1427-d374-42d6-85ee-721366ccc95d	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	VERIFIES	MANUAL	2026-10-12 15:27:27.868511+00	dev	2026-10-12 15:27:27.868511+00	dev	0	\N
87893750-1f48-4616-9430-6d7436f02c75	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	59231cfa-b570-4620-a814-5f966abea164	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	VERIFIES	MANUAL	2026-10-12 15:27:27.931531+00	dev	2026-10-12 15:27:27.931531+00	dev	0	\N
7392601f-2c92-459b-8e01-32dd6d7c6553	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	49aba8a5-0963-4048-a86f-1a00c2fc1e05	REQUIREMENT	08701d22-a93d-4128-8d94-0023fef3c40f	VERIFIES	MANUAL	2026-10-12 15:27:27.99601+00	dev	2026-10-12 15:27:27.99601+00	dev	0	\N
e3e7e104-c9bb-4309-94c0-84f44ec4ff09	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	47708765-6d89-40f2-b5bf-765066cbafb3	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	VERIFIES	MANUAL	2026-10-12 15:27:28.063752+00	qa1	2026-10-12 15:27:28.063752+00	qa1	0	\N
35ec17f4-077f-4667-8c28-07b5487e9299	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	47708765-6d89-40f2-b5bf-765066cbafb3	REQUIREMENT	2b918b31-1456-4c95-9d2e-587617e6d967	VERIFIES	MANUAL	2026-10-12 15:27:28.063752+00	qa1	2026-10-12 15:27:28.063752+00	qa1	0	\N
7ce60a18-fcb0-423c-a477-b1122fe0f919	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	b7c5ea07-1bfb-4097-a31f-a494a8a53a91	REQUIREMENT	ba8d4956-c976-4691-aba0-c3b98c97ebee	VERIFIES	MANUAL	2026-10-12 15:27:28.131182+00	qa1	2026-10-12 15:27:28.131182+00	qa1	0	\N
29d8547b-f2be-45ef-b7d8-71235711ded2	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	ea24ce74-8dbe-4f29-8e20-1cfccf9b8ce8	REQUIREMENT	8efd7182-8f71-46f6-a75d-32ee338fddea	VERIFIES	MANUAL	2026-10-12 15:27:28.214502+00	dev	2026-10-12 15:27:28.214502+00	dev	0	\N
7d618427-a668-472b-a8de-578f708e6f1d	54a2489c-9f91-42bb-b289-a489376506fc	TEST_CASE	0eaaee7c-3e84-49dd-b7d8-f6d89caa7356	REQUIREMENT	5cdf1568-16c2-4f61-8a68-d4b15c92ef26	VERIFIES	MANUAL	2026-10-12 15:27:25.539364+00	dev	2026-10-12 15:29:31.757325+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4b720c70-2a06-4f4e-9363-989211d900d3	admin	admin@traceagile.local	Administrateur	$2a$12$ul1/ozWvM65T9xAcJJ2uxeTUWGINSsTm1NtQzSbQpW/kQ69IZwfh2	t	t	2026-10-12 15:26:58.516671+00	system	2026-10-12 15:26:58.516671+00	system	0
16d3b928-1327-436b-b4ba-ce5d92a9595d	po	po@traceagile.demo	Paula Owner	$2a$12$riTmq4WkAEXEA19lDTb.7.b1Wm0AKhMSl7YD8uyupUifxKZlB3Z4S	t	f	2026-10-12 15:27:09.076403+00	admin	2026-10-12 15:27:09.076403+00	admin	0
88e057fa-32a5-49de-9e07-aa43c9fab938	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$YFASQbtHaXKFyA/SYnB64ubo7MG5r2656QJG6kpb5H9u/pCD95Gsa	t	f	2026-10-12 15:27:09.267405+00	admin	2026-10-12 15:27:09.267405+00	admin	0
cdb1d017-6c70-4fd0-b5a5-b3f6e1dcc80e	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$Q1S.EarUNCDX9H1JI7oL0eQh152ISF8kgne43.4SWK/bjdz.9IK/q	t	f	2026-10-12 15:27:09.463207+00	admin	2026-10-12 15:27:09.463207+00	admin	0
6d314bcb-72e7-411c-8c73-9986b2fea171	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$WjiBxCMW5MGPsCkxGHgs5u/zd2WpVaoYG3.wweRFMzRU.dXdB2xpm	t	f	2026-10-12 15:27:09.65113+00	admin	2026-10-12 15:27:09.65113+00	admin	0
a038163d-43eb-49a3-a8d0-63ad804f920f	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$quEgn1aD.34WpovZ3qZ8nO9dbCP6iIxAz6Psjagr.2rXpGIeLT9ye	t	f	2026-10-12 15:27:09.848717+00	admin	2026-10-12 15:27:09.848717+00	admin	0
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


