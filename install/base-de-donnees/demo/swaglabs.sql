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
1341f056-cd05-427e-a96e-edba0b9e823b	1aeace40-db9f-4837-92db-9f7cf4907e86	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 16:43:13.87875+00	po	2026-10-12 16:43:13.87875+00	po	0
675b3b92-9af1-4ab7-910d-921a00af04c3	1aeace40-db9f-4837-92db-9f7cf4907e86	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 16:43:13.87875+00	po	2026-10-12 16:43:13.87875+00	po	0
2d4d55b6-398b-41dc-a2ca-27090a04c1f2	e621377d-312a-4c6c-9ef9-35970f553809	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 16:43:13.929821+00	po	2026-10-12 16:43:13.929821+00	po	0
ef91012e-951d-43ff-8d20-09b35783ab6c	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 16:43:14.010816+00	po	2026-10-12 16:43:14.010816+00	po	0
92302c5b-0fcc-46b1-a8d2-2afb592cb7d8	b70751d5-7bee-4baf-916c-94cd19574aea	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 16:43:14.05442+00	po	2026-10-12 16:43:14.05442+00	po	0
e2c33a38-77f3-4568-88f0-b2c48182a85a	4cdaea31-8ff5-4615-8bbb-0e16feeac320	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 16:43:14.097053+00	po	2026-10-12 16:43:14.097053+00	po	0
46f9acbb-5eb4-446f-be95-45a9300874db	e3fceab0-160c-4689-b69f-a1b025291f00	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 16:43:14.181763+00	po	2026-10-12 16:43:14.181763+00	po	0
1bf1f45c-3a0d-412b-9837-16ca578428e0	e3fceab0-160c-4689-b69f-a1b025291f00	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 16:43:14.181763+00	po	2026-10-12 16:43:14.181763+00	po	0
593ac7c8-13ec-44e8-8c2f-cdcd68d0e19a	0a582dbf-8db9-4057-8018-1153ee12d10f	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 16:43:14.223036+00	po	2026-10-12 16:43:14.223036+00	po	0
bfbf2bac-922a-43bf-ad24-95ccaf68c373	0a582dbf-8db9-4057-8018-1153ee12d10f	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 16:43:14.223036+00	po	2026-10-12 16:43:14.223036+00	po	0
28cf8516-3f54-4b0d-b927-b1584f4c22da	40072a58-34f0-4a1a-81af-8bd5c97f131c	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 16:43:14.271614+00	po	2026-10-12 16:43:14.271614+00	po	0
9adc2bb2-4977-4f23-bd85-8de6ef89d422	5438fcd2-03e1-417e-b707-9b6dcea755fb	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 16:43:14.350832+00	po	2026-10-12 16:43:14.350832+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
318c8852-baf7-4617-b419-a8d3a5a852a7	cb27c1cf-a769-44d9-afb4-573b3c74bd99	EXECUTION_STEP	56c396cb-d1e1-4c05-b86a-ba356877375a	sd-defaut-problem-user.png	image/png	235120	c388094e-550b-4c7a-b113-a7715f9f0d25	2026-10-12 16:44:44.245818+00	qa2	2026-10-12 16:44:44.245818+00	qa2	0
369c3d78-0137-4080-8493-87917fc8b094	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEFECT	63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	sd-defaut-problem-user.png	image/png	235120	c388094e-550b-4c7a-b113-a7715f9f0d25	2026-10-12 16:44:45.759964+00	qa2	2026-10-12 16:44:45.759964+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
97f58409-d3cc-46f4-922e-1042e44931b3	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	5e10052f-35e8-4c3a-a969-2f1b35b6a017	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:13.746021+00	po	2026-10-12 16:43:13.746021+00	po	0
7001c077-bfe5-489d-90e3-709c1f1d9c46	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	163b59c7-f622-4e47-8de2-ae51397d3880	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:13.81736+00	po	2026-10-12 16:43:13.81736+00	po	0
d520a8a7-9cb0-490b-a28f-2186d106ee13	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 16:43:13.879476+00	po	2026-10-12 16:43:13.879476+00	po	0
79d6fef8-43f0-4208-bb38-55df17fd6549	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 16:43:13.929821+00	po	2026-10-12 16:43:13.929821+00	po	0
570a3eee-9282-459f-93e7-f7bd5382a785	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	6e065ed6-1657-4653-b09a-7d2c49b48dcd	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:13.971402+00	po	2026-10-12 16:43:13.971402+00	po	0
72fc480a-a5e7-4a01-83d7-38e30bb67bd2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.010816+00	po	2026-10-12 16:43:14.010816+00	po	0
35693583-50b5-4172-af20-8be688dc770d	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	b70751d5-7bee-4baf-916c-94cd19574aea	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.05442+00	po	2026-10-12 16:43:14.05442+00	po	0
876119cb-8751-43e2-9be8-572d31abad60	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a9e42611-9ec7-4b76-b721-1d54ebe19827	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.750503+00	qa1	2026-10-12 16:43:24.750503+00	qa1	0
6447fd86-4732-451c-8f3d-a356e4ec970f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RUN	0168a1e5-431a-40d8-b4bb-82fc99a51049	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 16:43:39.923514+00	dev	2026-10-12 16:43:39.923514+00	dev	0
fbe16a0d-0a2c-4365-965e-14bc0f2f39b1	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 16:44:38.375895+00	po	2026-10-12 16:44:38.375895+00	po	0
8868be6a-65ce-4832-98ae-8609e962fedf	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.09756+00	po	2026-10-12 16:43:14.09756+00	po	0
7204341a-7b68-44b5-a9fc-ea2705b48377	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	35dace4d-1842-4d18-9ca6-55f0b8cabd14	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:14.138391+00	po	2026-10-12 16:43:14.138391+00	po	0
04588a62-78bc-4965-a440-4e2c38778aad	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e3fceab0-160c-4689-b69f-a1b025291f00	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.181763+00	po	2026-10-12 16:43:14.181763+00	po	0
5e3c3a99-4f24-4a2c-af4f-705644eb8b7b	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.223036+00	po	2026-10-12 16:43:14.223036+00	po	0
f929238d-c63c-440e-bab6-921bbd89be64	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	6219e898-c47d-4bc9-a9c6-d0c4e695bef6	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:14.315979+00	po	2026-10-12 16:43:14.315979+00	po	0
593538fe-063d-49fe-8309-b544abf167cb	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	5438fcd2-03e1-417e-b707-9b6dcea755fb	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.351839+00	po	2026-10-12 16:43:14.351839+00	po	0
746bb751-9763-4f57-b02c-b1df274fe9ca	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	bca7c8e9-42d8-47c4-a6d9-0b93c9428b7e	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:16.040163+00	po	2026-10-12 16:43:16.040163+00	po	0
5738d3c1-93d3-435c-9c68-a4666b8f2118	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	93b161df-79d2-4610-9673-f89ab59381d8	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 16:43:36.331049+00	qa1	2026-10-12 16:43:36.331049+00	qa1	0
1001c1e1-a66f-45f7-8365-43473fb98c57	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	93b161df-79d2-4610-9673-f89ab59381d8	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 16:44:38.297243+00	qa1	2026-10-12 16:44:38.297243+00	qa1	0
27fd6742-91ea-4b04-abd6-0d6c18857298	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 16:43:14.271614+00	po	2026-10-12 16:43:14.271614+00	po	0
f35873cf-f70f-4542-94f4-299d5999c87c	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.280457+00	po	2026-10-12 16:43:17.280457+00	po	0
05cbb242-cc22-405a-81d9-05ccf0d5bd4e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	074601e0-2232-428d-a5b6-1102b7fd59ca	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 16:43:24.572908+00	qa1	2026-10-12 16:43:24.572908+00	qa1	0
f8c46430-2090-41f2-acee-7bc9bea78e3e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff511444-2795-403b-b6fd-e65c615309f3	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 16:43:24.930081+00	dev	2026-10-12 16:43:24.930081+00	dev	0
76cb824f-4374-4047-9fb3-4c8949417538	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	2810f279-a3b9-4328-9458-29e4bfa684ee	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 16:43:27.303679+00	dev	2026-10-12 16:43:27.303679+00	dev	0
acf437fc-938a-409a-9abb-3cc4bece5289	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	27408e0a-9202-4fd5-b162-7146fa7ee253	TC-14	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.607651+00	qa1	2026-10-12 16:43:27.607651+00	qa1	0
2234d650-df8d-42c3-b863-2d356f26b790	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	93b161df-79d2-4610-9673-f89ab59381d8	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 16:43:36.005013+00	qa1	2026-10-12 16:43:36.005013+00	qa1	0
3d0d714b-de17-44e6-9877-ed4bc6c1d5ec	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4446da66-82e2-47e3-a920-773b4e7c3771	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:16.278237+00	po	2026-10-12 16:43:16.278237+00	po	0
7097a2e3-7bf8-445c-8f20-a63401fcf952	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	43568d71-9ff0-467d-899e-1e4a7d81c256	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 16:43:16.312561+00	po	2026-10-12 16:43:16.312561+00	po	0
03e983c1-4198-4b92-8be5-ce8312285170	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.106762+00	po	2026-10-12 16:43:17.106762+00	po	0
db6bd63c-ae08-4853-b52b-e1ce9de2bdfa	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.157867+00	po	2026-10-12 16:43:17.157867+00	po	0
19c7ed63-bc71-4003-9394-895bbda4f04a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.202451+00	po	2026-10-12 16:43:17.202451+00	po	0
0e537a7e-d004-42d3-806a-b1dcf0e2a3b4	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	b70751d5-7bee-4baf-916c-94cd19574aea	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.242894+00	po	2026-10-12 16:43:17.242894+00	po	0
b0b841de-b423-4f02-aa2d-cc5e1cd8f533	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e3fceab0-160c-4689-b69f-a1b025291f00	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.320558+00	po	2026-10-12 16:43:17.320558+00	po	0
6dd62ef0-2773-4426-b29b-cc29b527648f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:17.361697+00	po	2026-10-12 16:43:17.361697+00	po	0
03d0980f-f6e8-4307-8678-b302232e324b	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:18.338378+00	po	2026-10-12 16:43:18.338378+00	po	0
00e4ef7f-6ae9-4297-9d32-4aa60f892784	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 16:43:24.464078+00	qa1	2026-10-12 16:43:24.464078+00	qa1	0
6e7c995b-5084-44d2-aea8-e2e467286ed7	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.525092+00	qa1	2026-10-12 16:43:24.525092+00	qa1	0
78f8269c-98b7-4f2d-8063-0baead5242d0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	074601e0-2232-428d-a5b6-1102b7fd59ca	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.610859+00	qa1	2026-10-12 16:43:24.610859+00	qa1	0
cfe125ea-8bd6-4794-acad-951db426ca68	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	fc149eda-1819-4e4f-9e56-c18776fe746d	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 16:43:24.656008+00	dev	2026-10-12 16:43:24.656008+00	dev	0
39acf78e-3961-4383-b0c6-c5709afe53d2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	fc149eda-1819-4e4f-9e56-c18776fe746d	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.689531+00	qa1	2026-10-12 16:43:24.689531+00	qa1	0
b0859cfb-8041-4190-b8aa-4f89e8f3aabc	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a9e42611-9ec7-4b76-b721-1d54ebe19827	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 16:43:24.71802+00	dev	2026-10-12 16:43:24.71802+00	dev	0
11baf61b-ca3f-4f02-af02-b3c40e8fb027	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	8295380f-fa42-4cbd-94f5-e495dcdccd74	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.886942+00	qa1	2026-10-12 16:43:24.886942+00	qa1	0
209d720d-7055-45df-acf4-43be602131c6	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff511444-2795-403b-b6fd-e65c615309f3	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.970425+00	qa1	2026-10-12 16:43:24.970425+00	qa1	0
2ada1e2f-072c-4924-9039-4de5957878ee	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	cf2bfbfd-f14d-441c-9020-1865165590de	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:26.289663+00	qa1	2026-10-12 16:43:26.289663+00	qa1	0
b90d4a7a-3a29-4f05-9acf-af2d761f5269	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	4bfeb009-f118-4cee-b388-6b0810563ec0	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.269195+00	qa1	2026-10-12 16:43:27.269195+00	qa1	0
48581179-ebdc-4325-87e2-1e16f799ed6e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	c65dc8f5-5e74-4355-ba77-6387b8057fff	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 16:43:27.437939+00	qa1	2026-10-12 16:43:27.437939+00	qa1	0
f4cb1030-062c-4398-856a-0e68f86cfa65	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	c65dc8f5-5e74-4355-ba77-6387b8057fff	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.46936+00	qa1	2026-10-12 16:43:27.46936+00	qa1	0
2f695944-fd45-40db-898b-3538d27d40a3	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a8e27b92-1df4-4406-9892-86ae4838da46	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 16:43:27.50189+00	qa1	2026-10-12 16:43:27.50189+00	qa1	0
c46bdeec-815d-4986-9d81-c4490b29ca03	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	27408e0a-9202-4fd5-b162-7146fa7ee253	TC-14	CREATED	[{"after": "TC-14", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : noms et prix (Playwright Java)", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "JUnit 5", "field": "framework", "before": null}, {"after": "Java", "field": "language", "before": null}, {"after": "https://github.com/kerware/saucedemo-e2e", "field": "repositoryUrl", "before": null}, {"after": "master", "field": "branch", "before": null}, {"after": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "field": "path", "before": null}, {"after": "InventaireCatalogueTest#catalogueAffiche", "field": "testIdentifier", "before": null}, {"after": "kerware, smoke", "field": "executionTags", "before": null}]	2026-10-12 16:43:27.579299+00	dev	2026-10-12 16:43:27.579299+00	dev	0
01ae2d27-27b7-4d23-8e5e-f7d8c091ca6e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 16:43:33.95372+00	po	2026-10-12 16:43:33.95372+00	po	0
cd849a65-e75d-4f9b-aba2-d21b8686860c	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 16:43:34.091895+00	po	2026-10-12 16:43:34.091895+00	po	0
d8700662-fbc0-4d24-802e-601d732e9557	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	93b161df-79d2-4610-9673-f89ab59381d8	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-14", "TC-5", "TC-6"]}]	2026-10-12 16:43:36.566563+00	qa1	2026-10-12 16:43:36.566563+00	qa1	0
0c3e25bd-d261-4041-bda2-393339cb141a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff82674d-1a8b-432d-a7c9-d4b43a336a25	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 16:43:24.788361+00	dev	2026-10-12 16:43:24.788361+00	dev	0
42ff22bb-3eab-4507-bc95-1e1badfaa45d	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff82674d-1a8b-432d-a7c9-d4b43a336a25	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:24.823842+00	qa1	2026-10-12 16:43:24.823842+00	qa1	0
4cf68dac-706e-40b2-a6dd-45a853163054	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	4bfeb009-f118-4cee-b388-6b0810563ec0	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 16:43:27.234317+00	dev	2026-10-12 16:43:27.234317+00	dev	0
2c1e1381-7cbd-4b3b-9410-39f0745162a2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	f08e4fd9-b712-4bb7-8b31-622610367bd4	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.408325+00	qa1	2026-10-12 16:43:27.408325+00	qa1	0
b5c46cf4-d27a-45d4-b2b7-a9b52a84d393	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:43:34.789851+00	po	2026-10-12 16:43:34.789851+00	po	0
fdcbbc4f-7ec7-4d65-b4c4-afbcb486dcd9	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:43:34.789851+00	po	2026-10-12 16:43:34.789851+00	po	0
cc11614b-f918-456c-85c2-1a7499613e54	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:43:34.790377+00	po	2026-10-12 16:43:34.790377+00	po	0
05c65f23-8694-43d3-887b-b1bede35acaa	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	b70751d5-7bee-4baf-916c-94cd19574aea	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:43:34.790377+00	po	2026-10-12 16:43:34.790377+00	po	0
5613b00d-7e75-4f23-b84a-ae0fe5f20d09	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:43:34.790377+00	po	2026-10-12 16:43:34.790377+00	po	0
b54a797d-521e-4d09-8b43-8a8f5ce4436f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 16:43:34.790377+00	po	2026-10-12 16:43:34.790377+00	po	0
72a00a00-e2d9-4b5a-8e5a-ebe3de897460	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	8295380f-fa42-4cbd-94f5-e495dcdccd74	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 16:43:24.857817+00	dev	2026-10-12 16:43:24.857817+00	dev	0
92a1850b-8b7d-4746-b0e7-07c31c5f337a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	cf2bfbfd-f14d-441c-9020-1865165590de	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 16:43:26.208153+00	qa1	2026-10-12 16:43:26.208153+00	qa1	0
2c53e598-5b6a-4292-bc0b-31d1123a65c1	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	cf2bfbfd-f14d-441c-9020-1865165590de	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 16:43:26.327245+00	qa1	2026-10-12 16:43:26.327245+00	qa1	0
66d03ffc-57f8-4e7b-8890-a425c3ff7ae7	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	2810f279-a3b9-4328-9458-29e4bfa684ee	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.340283+00	qa1	2026-10-12 16:43:27.340283+00	qa1	0
16f34517-36fd-46ea-92b1-01acf8f345ea	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	f08e4fd9-b712-4bb7-8b31-622610367bd4	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "mes-executions-admin", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 16:43:27.374954+00	dev	2026-10-12 16:43:27.374954+00	dev	0
9ff36078-9d0d-40bc-b380-e717908886f4	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a8e27b92-1df4-4406-9892-86ae4838da46	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 16:43:27.539529+00	qa1	2026-10-12 16:43:27.539529+00	qa1	0
805b9d65-d52e-4758-a59d-ab1518473591	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RELEASE	763f895a-2ce4-417e-ae17-a4cde6084f70	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 16:43:33.201454+00	po	2026-10-12 16:43:33.201454+00	po	0
8a8168f6-eb76-4ea0-a3c0-5ba1ddf65a73	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 16:43:33.232872+00	po	2026-10-12 16:43:33.232872+00	po	0
6198c45c-777a-4a46-a25b-7518c85a84e9	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	066e22a8-7c47-4fe0-a525-0c2d85398c1e	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 16:43:33.285068+00	po	2026-10-12 16:43:33.285068+00	po	0
042f09b4-5b7a-4ed7-9316-598d391619ba	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 16:43:34.029757+00	po	2026-10-12 16:43:34.029757+00	po	0
ca208979-b9bf-43ec-a977-c0acc8d66db2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 16:43:34.164527+00	po	2026-10-12 16:43:34.164527+00	po	0
0ee7cd8d-872f-4f27-b4c6-008d030ad72f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 16:43:34.235305+00	po	2026-10-12 16:43:34.235305+00	po	0
e238f144-eb28-4108-b66d-6d134aab6c55	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 16:44:38.423973+00	po	2026-10-12 16:44:38.423973+00	po	0
16cefb23-3119-4f6a-89e1-ba384f79cc2c	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SESSION	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 16:44:51.88527+00	po	2026-10-12 16:44:51.88527+00	po	0
8d8dc237-2153-4bfa-9ae1-921fd0cac138	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	35592861-6c55-4e08-b532-8bb41a703812	CMP-4	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-2", "TC-13 [Produits #1]", "TC-13 [Produits #2]"], "field": "tests", "before": []}]	2026-10-12 16:45:46.026824+00	qa1	2026-10-12 16:45:46.026824+00	qa1	0
c8c31961-5b15-4da3-918d-78dc6365c2c0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 16:44:38.463055+00	po	2026-10-12 16:44:38.463055+00	po	0
874314c1-c429-436a-9000-61c673cfeefe	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	b70751d5-7bee-4baf-916c-94cd19574aea	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 16:44:38.506576+00	po	2026-10-12 16:44:38.506576+00	po	0
ddb8f242-5335-4d7c-b53d-d9b48c622438	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 16:44:39.961529+00	po	2026-10-12 16:44:39.961529+00	po	0
13d359b3-99ef-4ada-a239-7b06027b71cd	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 16:44:40.785877+00	po	2026-10-12 16:44:40.785877+00	po	0
14f09cdf-34e9-48fb-8a1f-97c3f5ad0f32	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	066e22a8-7c47-4fe0-a525-0c2d85398c1e	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 16:44:41.483369+00	po	2026-10-12 16:44:41.483369+00	po	0
66f53ee9-7003-42e1-b3b9-2cad01197c5e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	e3fceab0-160c-4689-b69f-a1b025291f00	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:44:41.52876+00	po	2026-10-12 16:44:41.52876+00	po	0
77279716-0bdf-4a7b-9d79-0ddaa40e0a04	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:44:41.52929+00	po	2026-10-12 16:44:41.52929+00	po	0
94371512-88bf-471e-b1cf-007fc79eb638	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 16:44:41.52929+00	po	2026-10-12 16:44:41.52929+00	po	0
8f6ed335-a98b-4027-97dc-ecfefc034540	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPRINT	066e22a8-7c47-4fe0-a525-0c2d85398c1e	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 16:44:41.52929+00	po	2026-10-12 16:44:41.52929+00	po	0
a417d702-d35a-4966-86ae-ef4e17c371a8	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	b4d95f5a-40cb-4560-bc34-2a47acee1e99	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 16:44:42.514509+00	qa1	2026-10-12 16:44:42.514509+00	qa1	0
99bc2958-2adc-4cf2-9efe-5d68bfa6681e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	b4d95f5a-40cb-4560-bc34-2a47acee1e99	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 16:44:42.548154+00	qa1	2026-10-12 16:44:42.548154+00	qa1	0
8d906c77-852c-4ab1-870f-102cd0349aa2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEFECT	63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 16:44:45.75548+00	qa2	2026-10-12 16:44:45.75548+00	qa2	0
75218631-2f10-4a64-aa8b-2791b111dd2b	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEFECT	f773e362-16eb-47e7-943b-725f13439921	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 16:44:49.566561+00	qa1	2026-10-12 16:44:49.566561+00	qa1	0
3245f0ea-37de-4a55-8747-8160508f48c0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SESSION	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 16:44:50.818917+00	qa1	2026-10-12 16:44:50.818917+00	qa1	0
13b95936-9519-420e-a7e2-77661541bf7f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SESSION	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 16:44:51.264939+00	qa1	2026-10-12 16:44:51.264939+00	qa1	0
f217c4e6-7e44-437d-884f-388e3d16a0fa	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RUN	53b20ccc-d563-48c8-82e3-e255442f1957	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:44:53.432357+00	dev	0
d1570f44-3b77-4809-8204-3bfe63b1f907	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	b9853624-3739-4c62-b230-69bf1d45f48e	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 16:45:20.43352+00	qa1	2026-10-12 16:45:20.43352+00	qa1	0
0b7781d5-2dfe-4834-a896-9aa4ce85710a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 16:45:30.376068+00	po	2026-10-12 16:45:30.376068+00	po	0
d24ab357-32bc-432a-8198-8c08e7650f98	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	8295380f-fa42-4cbd-94f5-e495dcdccd74	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 16:45:30.390345+00	po	2026-10-12 16:45:30.390345+00	po	0
e2b9683a-29a8-43b0-999f-15791fe10db8	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	35592861-6c55-4e08-b532-8bb41a703812	CMP-4	CREATED	[{"after": "Régression 1.0", "field": "name", "before": null}, {"after": "REGRESSION", "field": "scopeType", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Régression", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 16:45:45.989532+00	qa1	2026-10-12 16:45:45.989532+00	qa1	0
0a8e7ea3-d332-4d2a-98ad-1fa7af7cf886	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CAMPAIGN	b4d95f5a-40cb-4560-bc34-2a47acee1e99	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 16:44:42.571032+00	qa1	2026-10-12 16:44:42.571032+00	qa1	0
1da667e2-211d-43a2-8aa9-fb823505dda5	cb27c1cf-a769-44d9-afb4-573b3c74bd99	SESSION	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 16:44:48.364666+00	qa1	2026-10-12 16:44:48.364666+00	qa1	0
304e14c8-71b5-4d2e-972f-9ea34edaf985	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TRACE_LINK	67ea8e80-19f7-41be-b6fd-44365afa5c90	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 16:45:31.0402+00	qa1	2026-10-12 16:45:31.0402+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0168a1e5-431a-40d8-b4bb-82fc99a51049	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RUN-1	1	93b161df-79d2-4610-9673-f89ab59381d8	94942184-c680-4b1a-970a-8281d564612d	COMPLETED	dev	2026-10-12 16:43:39.919421+00	2026-10-12 16:43:39.996145+00	2026-10-12 16:43:40.000031+00	2026-10-12 16:44:36.409254+00	2026-10-12 16:44:36.409254+00	recette	1.0.0-s1	job-414af9a9	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-414af9a9/logs	http://localhost:8091/api/v1/jobs/job-414af9a9/artifacts/report.json	30	\N	\N	6	6	0	0	0	\N	2026-10-12 16:43:39.922484+00	dev	2026-10-12 16:44:36.427008+00	anonymousUser	15
53b20ccc-d563-48c8-82e3-e255442f1957	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RUN-2	2	b4d95f5a-40cb-4560-bc34-2a47acee1e99	94942184-c680-4b1a-970a-8281d564612d	COMPLETED	dev	2026-10-12 16:44:53.431127+00	2026-10-12 16:44:53.464682+00	2026-10-12 16:44:53.463275+00	2026-10-12 16:45:17.839982+00	2026-10-12 16:45:17.839982+00	recette	1.0.0-s2	job-d03b6b9d	executeur-docker@fe229cb3c827	http://localhost:8091/api/v1/jobs/job-d03b6b9d/logs	http://localhost:8091/api/v1/jobs/job-d03b6b9d/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:45:17.852439+00	anonymousUser	9
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version", "git_project_id") FROM stdin;
f3b45b6d-7eb4-4f05-95bf-d1091cd2ff79	fc149eda-1819-4e4f-9e56-c18776fe746d	DATA_DRIVEN	Playwright	TypeScript	\N	\N	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 16:43:24.649208+00	dev	2026-10-12 16:43:24.649208+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
b2aeb2d7-7da6-493d-b2c0-3bbb6b97ed19	a9e42611-9ec7-4b76-b721-1d54ebe19827	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 16:43:24.714654+00	dev	2026-10-12 16:43:24.714654+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
215c277f-ef57-410e-9e20-0ae796af4f58	ff82674d-1a8b-432d-a7c9-d4b43a336a25	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 16:43:24.784627+00	dev	2026-10-12 16:43:24.784627+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
d34c62b3-f192-491c-a7e3-4a74076a71cb	8295380f-fa42-4cbd-94f5-e495dcdccd74	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 16:43:24.854026+00	dev	2026-10-12 16:43:24.854026+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
593e3575-e504-4112-bd58-108a8a51413b	ff511444-2795-403b-b6fd-e65c615309f3	API	Playwright	TypeScript	\N	\N	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 16:43:24.927185+00	dev	2026-10-12 16:43:24.927185+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
6b7757ff-5630-4ed4-a415-adc82d08063f	cf2bfbfd-f14d-441c-9020-1865165590de	BDD	Playwright	\N	\N	\N	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 16:43:26.19467+00	qa1	2026-10-12 16:43:26.327245+00	qa1	1	dab50772-8aec-4558-bfcb-1670bde77137
1a5a6aa8-26f6-4624-b1c6-690b65097ca7	4bfeb009-f118-4cee-b388-6b0810563ec0	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 16:43:27.230329+00	dev	2026-10-12 16:43:27.230329+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
87691e6d-4dfa-4e03-9c7c-9a56128670b4	2810f279-a3b9-4328-9458-29e4bfa684ee	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 16:43:27.300001+00	dev	2026-10-12 16:43:27.300001+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
f996d745-b699-42dc-950c-b960a9923d70	f08e4fd9-b712-4bb7-8b31-622610367bd4	PERFORMANCE	Playwright	TypeScript	\N	\N	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 16:43:27.370609+00	dev	2026-10-12 16:43:27.370609+00	dev	0	dab50772-8aec-4558-bfcb-1670bde77137
b20872b3-a4a1-437b-b143-ba3e4b21d739	27408e0a-9202-4fd5-b162-7146fa7ee253	UI	JUnit 5	Java	\N	\N	src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java	InventaireCatalogueTest#catalogueAffiche	\N	\N	{}	["kerware", "smoke"]	{}	[]	f	2026-10-12 16:43:27.576187+00	dev	2026-10-12 16:43:27.576187+00	dev	0	f65bbc2b-4a71-4bee-baf1-0114143a5253
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0b22e4b3-fde0-44c9-aa6b-65cc4106ff5b	BDD	Cucumber-JVM	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
e7582a5c-9594-4ba6-a150-403f1ce66851	BDD	Cucumber-JS	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
7fd1c152-1f5f-4c38-b301-d285fb61d25f	BDD	Behave	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
4d48b9db-34fb-4eff-a8cc-95aa0a012fb7	BDD	SpecFlow	4	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
1dcb68d4-aea9-443a-94a5-cbff55b69efa	BDD	Karate	5	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
8f942510-05dc-45b9-beab-8e51bbfe817c	UNIT	JUnit 5	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
0165849e-5eb5-4cc3-bd75-5b38b2c87c39	UNIT	Kotest	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
15a26405-9945-476b-9c86-b7c02d5ac904	UNIT	pytest	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
aacc539e-2a4b-4d05-84fb-6b18c1d6071e	UNIT	Jest	4	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
56775c45-def4-41b0-a515-54772aab3645	UNIT	Vitest	5	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
203091a6-8cea-40f1-a496-8ca57513b42f	UI	Playwright	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
9e65ae4b-cbac-4259-bf1b-3996f61b89fc	UI	Selenium	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
f50822a8-89c3-412f-8b50-35f1d7737aba	UI	Cypress	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
38a2df26-69ed-4841-af74-eea0b1f570a8	UI	Appium	4	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
97c8fff8-86c1-4f74-9d97-21795978e016	API	REST Assured	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
de435ebd-c2cf-48ef-884d-f4f1deaaee59	API	Karate	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
1b0f4e5f-9aa0-4d8b-ae38-10cd8f870fe0	API	Postman/Newman	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
1ac3c186-c96b-43c3-a05f-cd3291b2a36a	API	pytest + requests	4	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
1cc672ee-1366-43ed-a1a0-cc3ab8be3a22	KEYWORD	Robot Framework	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
7f4fdb70-6dfe-4f28-9c52-eb483cf3e16f	DATA_DRIVEN	JUnit 5	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
b06d4bf1-6b86-41e5-95cb-4bae20faf182	DATA_DRIVEN	pytest	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
13987e5f-579a-4b18-bed7-f71dbe05f295	DATA_DRIVEN	Playwright	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
f11dc025-d18e-492d-8572-19bdcddb9503	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
caf32ed8-e636-4da9-af4f-d1325d57cee1	PERFORMANCE	Gatling	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
f6fd75ef-e306-47be-bf69-0128732e1e44	PERFORMANCE	k6	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
06fd80d5-428a-49d9-a5e4-0fb7a9ea69fb	PERFORMANCE	JMeter	3	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
accd5bc2-c1a0-45b1-9d06-6bc42e79749e	CONTRACT	Pact	1	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
6ee75c06-ac60-4cdb-85dd-5cd5fd7ae2c9	CONTRACT	Spring Cloud Contract	2	2026-10-12 16:42:52.725141+00	system	2026-10-12 16:42:52.725141+00	system	0
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
42fe8da2-a85b-46de-9b14-e8ecd28a3d6c	93b161df-79d2-4610-9673-f89ab59381d8	fc149eda-1819-4e4f-9e56-c18776fe746d	1	\N	4	12	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.319604+00	qa1	0	\N	\N
dc21d9ae-8da9-43e1-9591-21605d6a3f62	93b161df-79d2-4610-9673-f89ab59381d8	a9e42611-9ec7-4b76-b721-1d54ebe19827	1	\N	5	6	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.319604+00	qa1	0	\N	\N
861f8d4f-2af4-4b34-82be-fedc8c17beed	93b161df-79d2-4610-9673-f89ab59381d8	27408e0a-9202-4fd5-b162-7146fa7ee253	1	\N	6	6	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.319604+00	qa1	0	\N	\N
235f5ee5-3429-4b31-a035-65822e631425	93b161df-79d2-4610-9673-f89ab59381d8	ff82674d-1a8b-432d-a7c9-d4b43a336a25	1	\N	7	3	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.319604+00	qa1	0	\N	\N
c1301c69-916a-49e3-b7cc-d7a70deb9fb1	93b161df-79d2-4610-9673-f89ab59381d8	8295380f-fa42-4cbd-94f5-e495dcdccd74	1	\N	8	3	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.319604+00	qa1	0	\N	\N
4284e3d2-c189-495c-9d38-f574515accf8	93b161df-79d2-4610-9673-f89ab59381d8	ff511444-2795-403b-b6fd-e65c615309f3	1	\N	9	6	2026-10-12 16:43:36.563966+00	qa1	2026-10-12 16:43:36.563966+00	qa1	0	\N	\N
31053d82-c27b-4e6f-80a4-d66321a0f112	93b161df-79d2-4610-9673-f89ab59381d8	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	aa560ef9-573e-43a0-bec3-0cc635162f73	1	16	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.613436+00	qa1	1	Comptes	0
8f92c652-588a-4331-84cf-b8cf59c489e9	93b161df-79d2-4610-9673-f89ab59381d8	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	aa560ef9-573e-43a0-bec3-0cc635162f73	2	16	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.636202+00	qa1	1	Comptes	1
0763c834-0bea-460b-ae77-da0439656349	93b161df-79d2-4610-9673-f89ab59381d8	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	aa560ef9-573e-43a0-bec3-0cc635162f73	3	16	2026-10-12 16:43:36.319604+00	qa1	2026-10-12 16:43:36.655967+00	qa1	1	Comptes	2
53edc8be-f377-4e8e-9e2a-d049d052f56f	b4d95f5a-40cb-4560-bc34-2a47acee1e99	cf2bfbfd-f14d-441c-9020-1865165590de	2	\N	3	12	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.54217+00	qa1	0	\N	\N
6ef0cb68-3aaf-4251-baf2-d297742b192c	b4d95f5a-40cb-4560-bc34-2a47acee1e99	4bfeb009-f118-4cee-b388-6b0810563ec0	1	\N	4	12	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.54217+00	qa1	0	\N	\N
ce1be98d-abab-40c9-9325-8bd2b83ae59f	b4d95f5a-40cb-4560-bc34-2a47acee1e99	2810f279-a3b9-4328-9458-29e4bfa684ee	1	\N	7	6	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.54217+00	qa1	0	\N	\N
30d702e3-3c17-46fa-82a2-43ab0f1037cd	b4d95f5a-40cb-4560-bc34-2a47acee1e99	f08e4fd9-b712-4bb7-8b31-622610367bd4	1	\N	8	6	2026-10-12 16:44:42.569867+00	qa1	2026-10-12 16:44:42.569867+00	qa1	0	\N	\N
0e3b103e-3ece-4f31-b5fe-ae5f5c8f1283	b4d95f5a-40cb-4560-bc34-2a47acee1e99	074601e0-2232-428d-a5b6-1102b7fd59ca	1	a26a2375-4c31-4b8d-9d21-57801eaff561	1	16	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.600956+00	qa1	1	\N	\N
d9f54323-11cd-47eb-94a0-5d016313f130	b4d95f5a-40cb-4560-bc34-2a47acee1e99	c65dc8f5-5e74-4355-ba77-6387b8057fff	1	aa560ef9-573e-43a0-bec3-0cc635162f73	2	16	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.61659+00	qa1	1	\N	\N
969da14e-6aa6-4d33-811f-6e945f329ac2	b4d95f5a-40cb-4560-bc34-2a47acee1e99	a8e27b92-1df4-4406-9892-86ae4838da46	1	aa560ef9-573e-43a0-bec3-0cc635162f73	5	12	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.632497+00	qa1	1	Produits	0
fc1d91d0-7dc0-4f45-8a0b-9eff97422be6	b4d95f5a-40cb-4560-bc34-2a47acee1e99	a8e27b92-1df4-4406-9892-86ae4838da46	1	aa560ef9-573e-43a0-bec3-0cc635162f73	6	12	2026-10-12 16:44:42.54217+00	qa1	2026-10-12 16:44:42.646912+00	qa1	1	Produits	1
6d0188cb-e480-4a57-be7c-b67a4a0fd097	b9853624-3739-4c62-b230-69bf1d45f48e	ff511444-2795-403b-b6fd-e65c615309f3	1	\N	1	0	2026-10-12 16:45:21.567839+00	qa1	2026-10-12 16:45:21.567839+00	qa1	0	\N	\N
b644536f-42a5-4bad-b0e8-6ab9d1679100	b9853624-3739-4c62-b230-69bf1d45f48e	fc149eda-1819-4e4f-9e56-c18776fe746d	1	\N	2	0	2026-10-12 16:45:21.574339+00	qa1	2026-10-12 16:45:21.574339+00	qa1	0	\N	\N
bfa57ea5-ab3b-4318-8a40-aac91baf2ec4	b9853624-3739-4c62-b230-69bf1d45f48e	a9e42611-9ec7-4b76-b721-1d54ebe19827	1	\N	3	0	2026-10-12 16:45:21.578638+00	qa1	2026-10-12 16:45:21.578638+00	qa1	0	\N	\N
b21fbc25-5931-49aa-a0db-8e48d2495806	b9853624-3739-4c62-b230-69bf1d45f48e	ff82674d-1a8b-432d-a7c9-d4b43a336a25	1	\N	4	0	2026-10-12 16:45:21.581813+00	qa1	2026-10-12 16:45:21.581813+00	qa1	0	\N	\N
731d2ce1-f520-41e6-9887-c2f8053f4511	b9853624-3739-4c62-b230-69bf1d45f48e	8295380f-fa42-4cbd-94f5-e495dcdccd74	1	\N	5	0	2026-10-12 16:45:21.586168+00	qa1	2026-10-12 16:45:21.586168+00	qa1	0	\N	\N
ad60ddad-0b41-4cab-b1b2-bab5e8a8dbc6	b9853624-3739-4c62-b230-69bf1d45f48e	cf2bfbfd-f14d-441c-9020-1865165590de	2	\N	6	0	2026-10-12 16:45:21.590401+00	qa1	2026-10-12 16:45:21.590401+00	qa1	0	\N	\N
c54fd484-63fe-4f45-aff4-53a92880a91f	b9853624-3739-4c62-b230-69bf1d45f48e	4bfeb009-f118-4cee-b388-6b0810563ec0	1	\N	7	0	2026-10-12 16:45:21.594077+00	qa1	2026-10-12 16:45:21.594077+00	qa1	0	\N	\N
3b07f1bc-406b-414d-9edb-7ffdbc0a95ef	b9853624-3739-4c62-b230-69bf1d45f48e	2810f279-a3b9-4328-9458-29e4bfa684ee	1	\N	8	0	2026-10-12 16:45:21.598513+00	qa1	2026-10-12 16:45:21.598513+00	qa1	0	\N	\N
54ecf44b-ab3e-4c43-90f5-46dde2b57210	b9853624-3739-4c62-b230-69bf1d45f48e	f08e4fd9-b712-4bb7-8b31-622610367bd4	1	\N	9	0	2026-10-12 16:45:21.602549+00	qa1	2026-10-12 16:45:21.602549+00	qa1	0	\N	\N
642a8e4e-23d5-4208-a227-231ca5e1e39b	35592861-6c55-4e08-b532-8bb41a703812	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	0876f995-71b9-499e-ac6f-dbc321d3c871	1	16	2026-10-12 16:45:46.019847+00	qa1	2026-10-12 16:45:46.055409+00	qa1	1	Comptes	0
cf49c59e-e57b-483a-8021-65e51f905f1f	35592861-6c55-4e08-b532-8bb41a703812	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	0876f995-71b9-499e-ac6f-dbc321d3c871	2	16	2026-10-12 16:45:46.019847+00	qa1	2026-10-12 16:45:46.073984+00	qa1	1	Comptes	1
a32f6787-91e9-4b89-96db-b71efdc02297	35592861-6c55-4e08-b532-8bb41a703812	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	0876f995-71b9-499e-ac6f-dbc321d3c871	3	16	2026-10-12 16:45:46.019847+00	qa1	2026-10-12 16:45:46.093025+00	qa1	1	Comptes	2
20e28280-0642-405e-ae30-2c375e232b1d	35592861-6c55-4e08-b532-8bb41a703812	074601e0-2232-428d-a5b6-1102b7fd59ca	1	0876f995-71b9-499e-ac6f-dbc321d3c871	4	16	2026-10-12 16:45:46.019847+00	qa1	2026-10-12 16:45:46.111484+00	qa1	1	\N	\N
fe0a7f13-7a25-41c0-8314-4a6500816dea	35592861-6c55-4e08-b532-8bb41a703812	a8e27b92-1df4-4406-9892-86ae4838da46	1	0876f995-71b9-499e-ac6f-dbc321d3c871	5	12	2026-10-12 16:45:46.020356+00	qa1	2026-10-12 16:45:46.129982+00	qa1	1	Produits	0
32b5f782-d8cc-40b2-bb0e-5d7df8faa7cb	35592861-6c55-4e08-b532-8bb41a703812	a8e27b92-1df4-4406-9892-86ae4838da46	1	0876f995-71b9-499e-ac6f-dbc321d3c871	6	12	2026-10-12 16:45:46.020356+00	qa1	2026-10-12 16:45:46.150188+00	qa1	1	Produits	1
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
93b161df-79d2-4610-9673-f89ab59381d8	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CMP-1	1	Recette sprint 1	SPRINT	82d0a1b0-f020-4066-98bf-8be35aa1054b	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 16:43:36.005013+00	qa1	2026-10-12 16:44:38.297769+00	qa1	3	Release 1.0/Recettes de sprint
b4d95f5a-40cb-4560-bc34-2a47acee1e99	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CMP-2	2	Recette sprint 2	SPRINT	066e22a8-7c47-4fe0-a525-0c2d85398c1e	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 16:44:42.514509+00	qa1	2026-10-12 16:44:43.581632+00	qa2	2	Release 1.0/Recettes de sprint
b9853624-3739-4c62-b230-69bf1d45f48e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CMP-3	3	Intégration continue — main	RELEASE	\N	763f895a-2ce4-417e-ae17-a4cde6084f70	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 16:45:20.433012+00	qa1	2026-10-12 16:45:21.570565+00	qa1	2	Release 1.0/Intégration continue
35592861-6c55-4e08-b532-8bb41a703812	cb27c1cf-a769-44d9-afb4-573b3c74bd99	CMP-4	4	Régression 1.0	REGRESSION	\N	\N	recette	1.0.0	PLANNED	\N	\N	2026-10-12 16:45:45.989532+00	qa1	2026-10-12 16:45:45.990039+00	qa1	1	Release 1.0/Régression
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e0ddabdb-0e1a-4f98-af8a-00a0de8a87e0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 16:43:10.020136+00	admin	2026-10-12 16:43:10.020136+00	admin	0
5736a8ce-6ccb-4eb6-8332-f674ad9a727f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 16:43:10.020136+00	admin	2026-10-12 16:43:10.020136+00	admin	0
d54001f9-4fe8-422c-8e68-6235aca5c929	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 16:43:10.020136+00	admin	2026-10-12 16:43:10.020136+00	admin	0
3d0c7e5f-8589-43d8-a26c-cb2ac541bdac	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 16:43:10.020136+00	admin	2026-10-12 16:43:10.020136+00	admin	0
10f05ee7-47c2-40b6-bebd-9e453b1690ad	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 16:43:10.022108+00	admin	2026-10-12 16:43:10.022108+00	admin	0
e20a148b-851c-422c-8462-3af332210fd3	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 16:43:10.022108+00	admin	2026-10-12 16:43:10.022108+00	admin	0
ffbfebc5-b169-403d-9243-e3c69312cdf0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DOD	4	Code revu et intégré	\N	2026-10-12 16:43:10.022108+00	admin	2026-10-12 16:43:10.022108+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
924fd5f0-af55-4ae1-9668-fe911a56990d	5438fcd2-03e1-417e-b707-9b6dcea755fb	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 16:43:21.003636+00	po	2026-10-12 16:43:21.003636+00	po	0
b51ee7ec-7f0e-4192-8e5c-d079c4dcba21	0a582dbf-8db9-4057-8018-1153ee12d10f	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 16:43:21.878807+00	po	2026-10-12 16:43:21.878807+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	529adc1d-29a7-41d9-b711-cc5d5dbe4cda
f773e362-16eb-47e7-943b-725f13439921	efcd47ae-ffa3-4424-9c13-84b87c8663de
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	0a582dbf-8db9-4057-8018-1153ee12d10f
63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	40072a58-34f0-4a1a-81af-8bd5c97f131c
f773e362-16eb-47e7-943b-725f13439921	0a582dbf-8db9-4057-8018-1153ee12d10f
f773e362-16eb-47e7-943b-725f13439921	40072a58-34f0-4a1a-81af-8bd5c97f131c
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
63c74656-02ce-4c72-ab0c-a4f7ebe6c8b3	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 16:44:45.75548+00	qa2	2026-10-12 16:44:45.760549+00	qa2	1
f773e362-16eb-47e7-943b-725f13439921	cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 16:44:49.566561+00	qa1	2026-10-12 16:44:49.568829+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c2a42974-6cf7-4164-82a1-c4ed8aa53802	5438fcd2-03e1-417e-b707-9b6dcea755fb	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 16:43:20.667072+00	po	2026-10-12 16:43:20.667072+00	po	0
96e7f82b-d3d2-4d63-afa4-dc434cfa0631	5438fcd2-03e1-417e-b707-9b6dcea755fb	EXAMPLE	c2a42974-6cf7-4164-82a1-c4ed8aa53802	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 16:43:20.78066+00	po	2026-10-12 16:43:20.78066+00	po	0
492cd1d6-0de3-42ad-a37e-5eda3ade82ab	5438fcd2-03e1-417e-b707-9b6dcea755fb	EXAMPLE	c2a42974-6cf7-4164-82a1-c4ed8aa53802	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 16:43:20.832044+00	po	2026-10-12 16:43:20.832044+00	po	0
77a11eff-856e-44d9-b209-f4aff69923ae	5438fcd2-03e1-417e-b707-9b6dcea755fb	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 16:43:20.886759+00	po	2026-10-12 16:43:20.886759+00	po	0
260efd8f-19f3-4fa5-84b6-123bc3a1e2ad	5438fcd2-03e1-417e-b707-9b6dcea755fb	EXAMPLE	77a11eff-856e-44d9-b209-f4aff69923ae	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 16:43:20.945411+00	po	2026-10-12 16:43:20.945411+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
94942184-c680-4b1a-970a-8281d564612d	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact", "Playwright", "Cypress", "Selenium", "pytest", "pytest + requests", "Robot Framework", "Cucumber-JS"]	[]	4	t	2026-10-12 16:43:11.397206+00	admin	2026-10-12 16:45:17.936318+00	system	4
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
47eb3608-83d0-4c6b-904b-67969e22d6bc	31053d82-c27b-4e6f-80a4-d66321a0f112	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	1	PASSED	f	2026-10-12 16:43:37.518547+00	2026-10-12 16:43:38.220219+00	701	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 16:43:37.523243+00	qa1	2026-10-12 16:43:38.22209+00	qa1	1	\N
34cce1fe-9233-4feb-9622-deb8a0ae5786	8f92c652-588a-4331-84cf-b8cf59c489e9	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	1	PASSED	f	2026-10-12 16:43:38.313628+00	2026-10-12 16:43:38.354688+00	41	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 16:43:38.315174+00	qa1	2026-10-12 16:43:38.355798+00	qa1	1	\N
82c589f8-7dcd-47be-b01a-f9244d9a820c	0763c834-0bea-460b-ae77-da0439656349	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	1	PASSED	f	2026-10-12 16:43:38.375212+00	2026-10-12 16:43:38.421985+00	46	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 16:43:38.376975+00	qa1	2026-10-12 16:43:38.423241+00	qa1	1	\N
b50fc118-6302-4e0c-a79b-e86ca54eada8	dc21d9ae-8da9-43e1-9591-21605d6a3f62	a9e42611-9ec7-4b76-b721-1d54ebe19827	1	1	PASSED	f	2026-10-12 16:44:00.761415+00	2026-10-12 16:44:03.731541+00	2969	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923+00	dev	2026-10-12 16:44:03.752933+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
68d93276-1c7e-4cd6-a821-da12f1e16bc1	42fe8da2-a85b-46de-9b14-e8ecd28a3d6c	fc149eda-1819-4e4f-9e56-c18776fe746d	1	1	PASSED	f	2026-10-12 16:44:00.761295+00	2026-10-12 16:44:04.095255+00	3332	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923+00	dev	2026-10-12 16:44:04.111926+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
2c27e615-9707-47f3-977f-7071cd2f43f5	c1301c69-916a-49e3-b7cc-d7a70deb9fb1	8295380f-fa42-4cbd-94f5-e495dcdccd74	1	1	PASSED	f	2026-10-12 16:44:02.211909+00	2026-10-12 16:44:04.513548+00	2300	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923514+00	dev	2026-10-12 16:44:04.528867+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
60d3d021-7347-4dd3-b2fd-2f9837f7a6c8	4284e3d2-c189-495c-9d38-f574515accf8	ff511444-2795-403b-b6fd-e65c615309f3	1	1	PASSED	f	2026-10-12 16:44:03.772869+00	2026-10-12 16:44:05.669682+00	1896	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923514+00	dev	2026-10-12 16:44:05.682798+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
160ce0ba-8fe7-455f-ad87-a369708c145c	235f5ee5-3429-4b31-a035-65822e631425	ff82674d-1a8b-432d-a7c9-d4b43a336a25	1	1	PASSED	f	2026-10-12 16:44:04.131065+00	2026-10-12 16:44:05.840507+00	1709	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923514+00	dev	2026-10-12 16:44:05.85203+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
69a42481-8f6e-4ccf-86bb-4e0fddff907f	861f8d4f-2af4-4b34-82be-fedc8c17beed	27408e0a-9202-4fd5-b162-7146fa7ee253	1	1	PASSED	f	2026-10-12 16:44:02.211902+00	2026-10-12 16:44:36.382833+00	34170	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:43:39.923+00	dev	2026-10-12 16:44:36.393596+00	anonymousUser	2	0168a1e5-431a-40d8-b4bb-82fc99a51049
529adc1d-29a7-41d9-b711-cc5d5dbe4cda	0e3b103e-3ece-4f31-b5fe-ae5f5c8f1283	074601e0-2232-428d-a5b6-1102b7fd59ca	1	1	FAILED	f	2026-10-12 16:44:43.576915+00	2026-10-12 16:44:44.32749+00	750	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 16:44:43.580544+00	qa2	2026-10-12 16:44:44.328634+00	qa2	1	\N
db425e76-c48e-4a6a-9370-e5d8d7a30af6	969da14e-6aa6-4d33-811f-6e945f329ac2	a8e27b92-1df4-4406-9892-86ae4838da46	1	1	PASSED	f	2026-10-12 16:44:46.298137+00	2026-10-12 16:44:47.233039+00	934	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 16:44:46.300718+00	qa1	2026-10-12 16:44:47.234274+00	qa1	1	\N
ef77e702-ad96-47f9-b860-4a4c6a93f7ad	fc1d91d0-7dc0-4f45-8a0b-9eff97422be6	a8e27b92-1df4-4406-9892-86ae4838da46	1	1	PASSED	f	2026-10-12 16:44:47.270401+00	2026-10-12 16:44:47.349216+00	78	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 16:44:47.274874+00	qa1	2026-10-12 16:44:47.349879+00	qa1	1	\N
718f3f96-e933-4dd8-84b8-c93c28ffefdd	bfa57ea5-ab3b-4318-8a40-aac91baf2ec4	a9e42611-9ec7-4b76-b721-1d54ebe19827	1	1	PASSED	f	2026-10-12 16:45:18.361282+00	2026-10-12 16:45:21.566282+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.579154+00	qa1	2026-10-12 16:45:21.579154+00	qa1	0	\N
efcd47ae-ffa3-4424-9c13-84b87c8663de	d9f54323-11cd-47eb-94a0-5d016313f130	c65dc8f5-5e74-4355-ba77-6387b8057fff	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 16:44:48.363664+00	qa1	2026-10-12 16:44:50.819979+00	qa1	1	\N
9611c126-1f54-4fcb-a22d-281d06c0718d	53edc8be-f377-4e8e-9e2a-d049d052f56f	cf2bfbfd-f14d-441c-9020-1865165590de	1	2	PASSED	f	2026-10-12 16:45:12.08588+00	2026-10-12 16:45:15.160351+00	3073	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:45:15.171819+00	anonymousUser	2	53b20ccc-d563-48c8-82e3-e255442f1957
53698fd4-d666-42a0-a190-4945d992bcd3	6ef0cb68-3aaf-4251-baf2-d297742b192c	4bfeb009-f118-4cee-b388-6b0810563ec0	1	1	PASSED	f	2026-10-12 16:45:12.085888+00	2026-10-12 16:45:15.180119+00	3093	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:45:15.189853+00	anonymousUser	2	53b20ccc-d563-48c8-82e3-e255442f1957
14995cbb-8458-4de4-818a-d807b2558d78	30d702e3-3c17-46fa-82a2-43ab0f1037cd	f08e4fd9-b712-4bb7-8b31-622610367bd4	1	1	PASSED	f	2026-10-12 16:45:12.085865+00	2026-10-12 16:45:15.196742+00	3110	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:45:15.20777+00	anonymousUser	2	53b20ccc-d563-48c8-82e3-e255442f1957
a6acc16e-0974-4363-85f2-5e2baa45e5b5	ce1be98d-abab-40c9-9325-8bd2b83ae59f	2810f279-a3b9-4328-9458-29e4bfa684ee	1	1	FAILED	f	2026-10-12 16:45:12.085891+00	2026-10-12 16:45:17.813099+00	5726	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-d03b6b9d/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 16:44:53.432357+00	dev	2026-10-12 16:45:17.826406+00	anonymousUser	2	53b20ccc-d563-48c8-82e3-e255442f1957
5f171809-8553-495a-a1da-cceb9611b7f4	6d0188cb-e480-4a57-be7c-b67a4a0fd097	ff511444-2795-403b-b6fd-e65c615309f3	1	1	PASSED	f	2026-10-12 16:45:21.004282+00	2026-10-12 16:45:21.566282+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.569768+00	qa1	2026-10-12 16:45:21.569768+00	qa1	0	\N
8e254def-642c-43d4-88af-84825bc0a554	b644536f-42a5-4bad-b0e8-6ab9d1679100	fc149eda-1819-4e4f-9e56-c18776fe746d	1	1	PASSED	f	2026-10-12 16:45:18.051282+00	2026-10-12 16:45:21.566282+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.576048+00	qa1	2026-10-12 16:45:21.576048+00	qa1	0	\N
48e0a346-ecf3-4d5a-b299-7e8985f2c20d	b21fbc25-5931-49aa-a0db-8e48d2495806	ff82674d-1a8b-432d-a7c9-d4b43a336a25	1	1	PASSED	f	2026-10-12 16:45:21.124282+00	2026-10-12 16:45:21.566282+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.582897+00	qa1	2026-10-12 16:45:21.582897+00	qa1	0	\N
65d6779f-0450-4fb2-b963-3aa0d1ae6eaf	731d2ce1-f520-41e6-9887-c2f8053f4511	8295380f-fa42-4cbd-94f5-e495dcdccd74	1	1	PASSED	f	2026-10-12 16:45:21.029282+00	2026-10-12 16:45:21.566282+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.58781+00	qa1	2026-10-12 16:45:21.58781+00	qa1	0	\N
9d6cd9d1-5a3a-427f-b8b8-683d2d8b2c8b	ad60ddad-0b41-4cab-b1b2-bab5e8a8dbc6	cf2bfbfd-f14d-441c-9020-1865165590de	1	2	PASSED	f	2026-10-12 16:45:20.879282+00	2026-10-12 16:45:21.566282+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.591491+00	qa1	2026-10-12 16:45:21.591491+00	qa1	0	\N
f2f89bb7-3c78-41b9-ac0d-a02bff8156e6	c54fd484-63fe-4f45-aff4-53a92880a91f	4bfeb009-f118-4cee-b388-6b0810563ec0	1	1	PASSED	f	2026-10-12 16:45:21.019282+00	2026-10-12 16:45:21.566282+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.595169+00	qa1	2026-10-12 16:45:21.595169+00	qa1	0	\N
3a766e9a-6166-4fd2-b2cd-03eba1567178	3b07f1bc-406b-414d-9edb-7ffdbc0a95ef	2810f279-a3b9-4328-9458-29e4bfa684ee	1	1	FAILED	f	2026-10-12 16:45:18.098282+00	2026-10-12 16:45:21.566282+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.59955+00	qa1	2026-10-12 16:45:21.59955+00	qa1	0	\N
18f0cd65-ca24-445b-9fb9-dc285dd9cec9	54ecf44b-ab3e-4c43-90f5-46dde2b57210	f08e4fd9-b712-4bb7-8b31-622610367bd4	1	1	PASSED	f	2026-10-12 16:45:20.752282+00	2026-10-12 16:45:21.566282+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 16:45:21.603602+00	qa1	2026-10-12 16:45:21.603602+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c2347490-2292-4c73-aae6-76e619799d46	c65dc8f5-5e74-4355-ba77-6387b8057fff	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 16:43:27.433266+00	qa1	2026-10-12 16:43:27.433266+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	efcd47ae-ffa3-4424-9c13-84b87c8663de	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 16:44:48.363664+00	qa1	2026-10-12 16:44:51.885697+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 18:42:52.419074	92	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 18:42:52.540855	153	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 18:42:52.71768	167	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 18:42:52.907562	29	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 18:42:52.958334	13	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 18:42:52.992256	89	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 18:42:53.103424	140	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 18:42:53.263283	13	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 18:42:53.2949	13	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 18:42:53.327017	33	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 18:42:53.380964	64	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 18:42:53.468924	89	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 18:42:53.578494	28	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 18:42:53.626325	53	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 18:42:53.700246	49	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 18:42:53.768846	33	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 18:42:53.82175	20	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 18:42:53.861007	5	t
19	19	git sources	SQL	V19__git_sources.sql	1616532274	traceagile_demo	2026-10-12 18:42:53.884624	53	t
\.


--
-- Data for Name: git_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_projects" ("id", "source_id", "name", "default_branch", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
dab50772-8aec-4558-bfcb-1670bde77137	e9d4c8ca-f521-43a7-813c-97c644858873	traceagile	mes-executions-admin	\N	2026-10-12 16:43:12.16218+00	admin	2026-10-12 16:43:12.16218+00	admin	0
f65bbc2b-4a71-4bee-baf1-0114143a5253	e3e38328-6b69-4681-8414-790ba879c50d	saucedemo-e2e	master	\N	2026-10-12 16:43:12.2114+00	admin	2026-10-12 16:43:12.2114+00	admin	0
\.


--
-- Data for Name: git_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_sources" ("id", "name", "base_url", "auth_type", "username", "secret", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e9d4c8ca-f521-43a7-813c-97c644858873	Dépôt local	file:///depots	NONE	\N	\N	Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)	2026-10-12 16:43:12.136537+00	admin	2026-10-12 16:43:12.136537+00	admin	0
e3e38328-6b69-4681-8414-790ba879c50d	kerware	https://github.com/kerware	NONE	\N	\N	Projets de formation (GitHub, public)	2026-10-12 16:43:12.195373+00	admin	2026-10-12 16:43:12.195373+00	admin	0
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ	18
cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC	15
cb27c1cf-a769-44d9-afb4-573b3c74bd99	REL	2
cb27c1cf-a769-44d9-afb4-573b3c74bd99	SPR	3
cb27c1cf-a769-44d9-afb4-573b3c74bd99	DEF	3
cb27c1cf-a769-44d9-afb4-573b3c74bd99	RUN	3
cb27c1cf-a769-44d9-afb4-573b3c74bd99	RPT	3
cb27c1cf-a769-44d9-afb4-573b3c74bd99	CMP	5
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
c9314513-f91b-4aaa-bc1b-98d20f89069e	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 16:43:24.448212+00	qa1	2026-10-12 16:43:24.448212+00	qa1	0	\N	{}	\N	\N
d763e7eb-62b6-407b-ad28-5775007e50c5	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 16:43:24.448741+00	qa1	2026-10-12 16:43:24.448741+00	qa1	0	\N	{}	\N	\N
31caf42a-168c-48e0-a7da-303fdda1772b	074601e0-2232-428d-a5b6-1102b7fd59ca	1	\N	\N	\N	2026-10-12 16:43:24.56592+00	qa1	2026-10-12 16:43:24.56592+00	qa1	0	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	{}	Comptes	problem_user
eb050cc5-c476-478a-a068-0d7459b3a172	074601e0-2232-428d-a5b6-1102b7fd59ca	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 16:43:24.56592+00	qa1	2026-10-12 16:43:24.56592+00	qa1	0	\N	{}	\N	\N
04ebccd5-66ad-471b-90f8-bf7bc01e7bf6	074601e0-2232-428d-a5b6-1102b7fd59ca	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 16:43:24.56592+00	qa1	2026-10-12 16:43:24.56592+00	qa1	0	\N	{}	\N	\N
dda1633b-4532-4cc6-ba23-2ca556eb80dd	074601e0-2232-428d-a5b6-1102b7fd59ca	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 16:43:24.56592+00	qa1	2026-10-12 16:43:24.56592+00	qa1	0	\N	{}	\N	\N
db8410b6-70cf-4c9f-930c-7fb16d4052a1	a8e27b92-1df4-4406-9892-86ae4838da46	1	\N	\N	\N	2026-10-12 16:43:27.497379+00	qa1	2026-10-12 16:43:27.497379+00	qa1	0	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	{}	Comptes	standard_user
5f9e307d-59a3-4213-b0a8-c6ac2d396749	a8e27b92-1df4-4406-9892-86ae4838da46	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 16:43:27.497379+00	qa1	2026-10-12 16:43:27.497379+00	qa1	0	\N	{}	\N	\N
3292e471-852a-4403-814a-2a8a4f49c511	a8e27b92-1df4-4406-9892-86ae4838da46	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 16:43:27.497379+00	qa1	2026-10-12 16:43:27.497379+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
fec16edd-c1db-4e76-9f42-d95a8218ab42	4446da66-82e2-47e3-a920-773b4e7c3771	287	ms	p95Ms	TC-11	RUN-2	2026-10-12 16:45:15.196742+00	TARGET_MET	2026-10-12 16:45:15.218871+00	anonymousUser	2026-10-12 16:45:15.218871+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
82ce165a-ea08-485a-8e4f-b9b5b5473fda	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:43:40.01849+00
1e8e616c-8bee-4793-a3f4-f14986235357	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:00.770162+00
496731d5-2f2a-4aec-a618-84f158ddaccc	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:01.306012+00
4e559b18-b8f5-48b3-9543-3b61faec88a7	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:02.218992+00
2a7bd616-b3a6-46c8-977e-11122b0f3ef4	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:02.741516+00
ffdf9057-4802-42ce-abb0-39952434b27b	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:03.743848+00
87dfff3c-1b6b-42c9-b6ed-814bef385c41	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:03.781627+00
23a4cdb8-1ee8-4236-93d6-786826d84cce	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:04.106+00
50576904-0a1c-4448-946b-a8ab56f29a55	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:04.140695+00
7f71b2be-570b-4450-b238-b0730f1823de	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:04.523718+00
7e2b6b32-fb24-4ab6-a423-f645fca3847c	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:05.678374+00
4e717503-41a2-4ba4-b6fe-25bd28a31ee6	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:05.847445+00
e7197306-fb56-4e7f-8e1c-9b691a9d36a8	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:36.390518+00
5a50b713-e8e5-461d-bb56-dc7ef82d6f61	0168a1e5-431a-40d8-b4bb-82fc99a51049	2026-10-12 16:44:36.418035+00
21783c8b-9f78-4dca-87df-589edc659fa1	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:44:53.985977+00
797e742c-1e26-471a-b462-232cefc3466d	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:12.093953+00
9d1ace43-5efd-4aa5-b1b9-effe12a4682e	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:12.613876+00
48af6bc6-4b84-42ad-bb2d-794d6d65774a	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:13.63275+00
ac5468e0-0f86-4003-bbb0-f29dfae0b061	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:13.63275+00
945a8020-0632-4332-9d58-bec7ef74ca01	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:15.168538+00
3da03421-4846-4743-907e-5b245ea1824c	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:15.186811+00
06376461-7d87-4264-afee-fcf4ff49d033	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:15.204141+00
f47d6e03-1bf2-486c-88a4-4d2984f8924f	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:17.82124+00
a2ae3592-4e34-45fe-9bc3-ce009cb3b357	53b20ccc-d563-48c8-82e3-e255442f1957	2026-10-12 16:45:17.845015+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
fe5c5be2-22de-49e7-bbd4-e5c7c58bf2fd	cb27c1cf-a769-44d9-afb4-573b3c74bd99	0876f995-71b9-499e-ac6f-dbc321d3c871	ADMINISTRATOR	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
09af070b-7d5d-4b14-81ad-4c908ce967e5	cb27c1cf-a769-44d9-afb4-573b3c74bd99	e98c603a-a170-4990-b60a-39d0784e6dfe	PRODUCT_OWNER	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
a7069895-0ee1-402c-812f-3dc44709b331	cb27c1cf-a769-44d9-afb4-573b3c74bd99	aa560ef9-573e-43a0-bec3-0cc635162f73	TESTER	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
c6ed013c-79f3-4f4a-ae55-77f8e60942f8	cb27c1cf-a769-44d9-afb4-573b3c74bd99	a26a2375-4c31-4b8d-9d21-57801eaff561	TESTER	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
45785edb-132a-4987-8666-e4c529005e73	cb27c1cf-a769-44d9-afb4-573b3c74bd99	562cb3cc-28de-4706-9b0a-ffebc7b79c07	DEVELOPER	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
59fdaf66-06b4-47fa-8bc8-91590af97209	cb27c1cf-a769-44d9-afb4-573b3c74bd99	289a7552-515a-47b6-88a1-78025f42b8e8	VIEWER	2026-10-12 16:43:10.129027+00	admin	2026-10-12 16:43:10.129027+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
cb27c1cf-a769-44d9-afb4-573b3c74bd99	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 16:43:10.00507+00	admin	2026-10-12 16:43:10.00507+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
763f895a-2ce4-417e-ae17-a4cde6084f70	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 16:43:33.201454+00	po	2026-10-12 16:43:34.790904+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5ae7ed37-52d5-4567-8e2a-233fc10c6308	cb27c1cf-a769-44d9-afb4-573b3c74bd99	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 16:44:40.791984+00	po	2026-10-12 16:44:40.791984+00	po	0
253b9d73-35f3-407e-be02-828395c7d114	cb27c1cf-a769-44d9-afb4-573b3c74bd99	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 16:44:40.801194+00	po	2026-10-12 16:44:40.801194+00	po	0
79d89393-9de7-4ffd-9334-4d51ea28dbcc	cb27c1cf-a769-44d9-afb4-573b3c74bd99	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 16:45:38.295773+00	po	2026-10-12 16:45:38.295773+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
f41aeee9-9e1a-4230-a23e-23f3a3e59b2f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T16:44:40.833952700Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 9, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 6, "failed": 0, "notRun": 0, "passed": 6}], "attempts": 9, "byStatus": {"PASSED": 9}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 9, "attempts": 9}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 16:44:40.870493+00	clôture du sprint	2026-10-12 16:44:40.869483+00	po	2026-10-12 16:44:40.871018+00	po	1
e43e20b8-5e27-46ae-993a-2c3a31e3993f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T16:45:34.929881300Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 16:45:36.411459+00	f	\N	\N	2026-10-12 16:45:34.944588+00	po	2026-10-12 16:45:36.411459+00	po	2
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
3f214e3d-ed6f-4b54-b838-227ca68b507d	1aeace40-db9f-4837-92db-9f7cf4907e86	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.103762+00	po	2026-10-12 16:43:17.103762+00	po	0
9f723d82-b637-48e9-8856-49753e3b64e2	e621377d-312a-4c6c-9ef9-35970f553809	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.157253+00	po	2026-10-12 16:43:17.157253+00	po	0
5f67c55f-a5f7-40ae-bd6d-11c412f9c6e5	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.201922+00	po	2026-10-12 16:43:17.201922+00	po	0
a1e0788e-f3bb-4905-aacb-46e2c0f27c01	b70751d5-7bee-4baf-916c-94cd19574aea	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.242373+00	po	2026-10-12 16:43:17.242373+00	po	0
00a302c7-08b9-404e-b1a4-78dd9c39a5bc	4cdaea31-8ff5-4615-8bbb-0e16feeac320	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.279812+00	po	2026-10-12 16:43:17.279812+00	po	0
04d00832-ed27-43b6-b007-5fcc68f24eda	e3fceab0-160c-4689-b69f-a1b025291f00	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.320055+00	po	2026-10-12 16:43:17.320055+00	po	0
458afb1f-a53f-4e9f-bebc-b223d2d42cd3	0a582dbf-8db9-4057-8018-1153ee12d10f	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:17.36116+00	po	2026-10-12 16:43:17.36116+00	po	0
a0fb85bd-9d18-4026-bfd8-ca1751465d1f	40072a58-34f0-4a1a-81af-8bd5c97f131c	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 16:43:18.337865+00	po	2026-10-12 16:43:18.337865+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5e10052f-35e8-4c3a-a969-2f1b35b6a017	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 16:43:13.741975+00	po	2026-10-12 16:43:13.741975+00	po	0
163b59c7-f622-4e47-8de2-ae51397d3880	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 16:43:13.816845+00	po	2026-10-12 16:43:13.816845+00	po	0
6e065ed6-1657-4653-b09a-7d2c49b48dcd	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 16:43:13.971402+00	po	2026-10-12 16:43:13.971402+00	po	0
35dace4d-1842-4d18-9ca6-55f0b8cabd14	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 16:43:14.138391+00	po	2026-10-12 16:43:14.138391+00	po	0
e621377d-312a-4c6c-9ef9-35970f553809	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	163b59c7-f622-4e47-8de2-ae51397d3880	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 16:43:13.929302+00	po	2026-10-12 16:44:38.424489+00	po	3
ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	6e065ed6-1657-4653-b09a-7d2c49b48dcd	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 16:43:14.010816+00	po	2026-10-12 16:44:38.464055+00	po	3
0a582dbf-8db9-4057-8018-1153ee12d10f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	35dace4d-1842-4d18-9ca6-55f0b8cabd14	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 16:43:14.222716+00	po	2026-10-12 16:44:41.529808+00	po	2
40072a58-34f0-4a1a-81af-8bd5c97f131c	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	35dace4d-1842-4d18-9ca6-55f0b8cabd14	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 16:43:14.271614+00	po	2026-10-12 16:44:41.529808+00	po	2
6219e898-c47d-4bc9-a9c6-d0c4e695bef6	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 16:43:14.315979+00	po	2026-10-12 16:43:14.315979+00	po	0
5438fcd2-03e1-417e-b707-9b6dcea755fb	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	6219e898-c47d-4bc9-a9c6-d0c4e695bef6	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 16:43:14.350832+00	po	2026-10-12 16:43:14.350832+00	po	0
bca7c8e9-42d8-47c4-a6d9-0b93c9428b7e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	6219e898-c47d-4bc9-a9c6-d0c4e695bef6	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 16:43:16.039609+00	po	2026-10-12 16:43:16.039609+00	po	0
4446da66-82e2-47e3-a920-773b4e7c3771	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 16:43:16.277721+00	po	2026-10-12 16:43:16.277721+00	po	0
43568d71-9ff0-467d-899e-1e4a7d81c256	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	5e10052f-35e8-4c3a-a969-2f1b35b6a017	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 16:43:16.312046+00	po	2026-10-12 16:43:16.312046+00	po	0
b70751d5-7bee-4baf-916c-94cd19574aea	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	6e065ed6-1657-4653-b09a-7d2c49b48dcd	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 16:43:14.05442+00	po	2026-10-12 16:44:38.507095+00	po	3
1aeace40-db9f-4837-92db-9f7cf4907e86	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	163b59c7-f622-4e47-8de2-ae51397d3880	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 16:43:13.872749+00	po	2026-10-12 16:44:38.376409+00	po	3
e3fceab0-160c-4689-b69f-a1b025291f00	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	35dace4d-1842-4d18-9ca6-55f0b8cabd14	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 16:43:14.181763+00	po	2026-10-12 16:44:41.529808+00	po	2
4cdaea31-8ff5-4615-8bbb-0e16feeac320	cb27c1cf-a769-44d9-afb4-573b3c74bd99	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	6e065ed6-1657-4653-b09a-7d2c49b48dcd	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 16:43:14.097053+00	po	2026-10-12 16:45:30.376666+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b517bde9-15e1-41fb-ae02-af9c861c5a2a	0168a1e5-431a-40d8-b4bb-82fc99a51049	b50fc118-6302-4e0c-a79b-e86ca54eada8	log-TC-4.txt	text/plain	SYSTEM_TRACE	392	2026-10-12 16:44:03.751398+00	anonymousUser	2026-10-12 16:44:03.751398+00	anonymousUser	0
9f5d76d1-119a-43da-a39f-87a0d1551547	0168a1e5-431a-40d8-b4bb-82fc99a51049	68d93276-1c7e-4cd6-a821-da12f1e16bc1	log-TC-3.txt	text/plain	SYSTEM_TRACE	525	2026-10-12 16:44:04.110883+00	anonymousUser	2026-10-12 16:44:04.110883+00	anonymousUser	0
ab627543-e55b-4c08-8274-a2004b769a6c	0168a1e5-431a-40d8-b4bb-82fc99a51049	2c27e615-9707-47f3-977f-7071cd2f43f5	log-TC-6.txt	text/plain	SYSTEM_TRACE	376	2026-10-12 16:44:04.527356+00	anonymousUser	2026-10-12 16:44:04.527356+00	anonymousUser	0
17b6c884-134f-4760-8085-c7558c4eae1d	0168a1e5-431a-40d8-b4bb-82fc99a51049	60d3d021-7347-4dd3-b2fd-2f9837f7a6c8	log-TC-7.txt	text/plain	SYSTEM_TRACE	394	2026-10-12 16:44:05.682075+00	anonymousUser	2026-10-12 16:44:05.682075+00	anonymousUser	0
a38ad6e9-3f7b-4eb5-bc98-c8fb13ecb885	0168a1e5-431a-40d8-b4bb-82fc99a51049	160ce0ba-8fe7-455f-ad87-a369708c145c	log-TC-5.txt	text/plain	SYSTEM_TRACE	391	2026-10-12 16:44:05.851003+00	anonymousUser	2026-10-12 16:44:05.851003+00	anonymousUser	0
6464675f-8b8a-4eea-90a8-aad3c3c4f6e1	0168a1e5-431a-40d8-b4bb-82fc99a51049	69a42481-8f6e-4ccf-86bb-4e0fddff907f	log-TC-14.txt	text/plain	SYSTEM_TRACE	8738	2026-10-12 16:44:36.393091+00	anonymousUser	2026-10-12 16:44:36.393091+00	anonymousUser	0
2b00aa54-f447-4a29-8ae2-34b650048925	0168a1e5-431a-40d8-b4bb-82fc99a51049	\N	system.log	text/plain	SYSTEM_TRACE	18374	2026-10-12 16:44:36.421275+00	anonymousUser	2026-10-12 16:44:36.421275+00	anonymousUser	0
04e8e3c4-269b-461a-996f-e2d78c931234	0168a1e5-431a-40d8-b4bb-82fc99a51049	\N	junit.xml	application/xml	JUNIT	1358	2026-10-12 16:44:36.424266+00	anonymousUser	2026-10-12 16:44:36.424266+00	anonymousUser	0
b23d84d7-575b-409b-9d34-47a9fa8796ec	0168a1e5-431a-40d8-b4bb-82fc99a51049	\N	report.json	application/json	REPORT	554	2026-10-12 16:44:36.426501+00	anonymousUser	2026-10-12 16:44:36.426501+00	anonymousUser	0
7959f5b0-b4a3-4af0-bf7b-3759358fe971	53b20ccc-d563-48c8-82e3-e255442f1957	9611c126-1f54-4fcb-a22d-281d06c0718d	log-TC-8.txt	text/plain	SYSTEM_TRACE	361	2026-10-12 16:45:15.171301+00	anonymousUser	2026-10-12 16:45:15.171301+00	anonymousUser	0
d30ff3c6-6374-4694-9e38-516e437cbab7	53b20ccc-d563-48c8-82e3-e255442f1957	53698fd4-d666-42a0-a190-4945d992bcd3	log-TC-9.txt	text/plain	SYSTEM_TRACE	371	2026-10-12 16:45:15.189336+00	anonymousUser	2026-10-12 16:45:15.189336+00	anonymousUser	0
3beacbe3-736c-4411-8529-ecf5cd5c4144	53b20ccc-d563-48c8-82e3-e255442f1957	14995cbb-8458-4de4-818a-d807b2558d78	log-TC-11.txt	text/plain	SYSTEM_TRACE	824	2026-10-12 16:45:15.207253+00	anonymousUser	2026-10-12 16:45:15.207253+00	anonymousUser	0
cbcb9ac9-f381-4852-9a52-2dfc3da97a43	53b20ccc-d563-48c8-82e3-e255442f1957	a6acc16e-0974-4363-85f2-5e2baa45e5b5	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 16:45:17.82382+00	anonymousUser	2026-10-12 16:45:17.82382+00	anonymousUser	0
3e03bca7-7325-4c88-80a3-19beb3b8ef7f	53b20ccc-d563-48c8-82e3-e255442f1957	a6acc16e-0974-4363-85f2-5e2baa45e5b5	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 16:45:17.826406+00	anonymousUser	2026-10-12 16:45:17.826406+00	anonymousUser	0
68d6f990-ebcb-4aac-8e27-f90422f5bfe2	53b20ccc-d563-48c8-82e3-e255442f1957	\N	system.log	text/plain	SYSTEM_TRACE	9018	2026-10-12 16:45:17.846669+00	anonymousUser	2026-10-12 16:45:17.846669+00	anonymousUser	0
08b002f3-2cc5-4c50-a015-9608571adf60	53b20ccc-d563-48c8-82e3-e255442f1957	\N	junit.xml	application/xml	JUNIT	1057	2026-10-12 16:45:17.849804+00	anonymousUser	2026-10-12 16:45:17.849804+00	anonymousUser	0
d2b14a0c-6797-47d4-993d-e70273c04fc1	53b20ccc-d563-48c8-82e3-e255442f1957	\N	report.json	application/json	REPORT	475	2026-10-12 16:45:17.851914+00	anonymousUser	2026-10-12 16:45:17.851914+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
6689c9c3-217f-437b-8f39-4bfc4f6e0096	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 16:44:48.477178+00	qa1	2026-10-12 16:44:48.477178+00	qa1	0
bcbdb2d4-4dd4-47fd-9653-3ccb94ecfa42	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 16:44:48.535883+00	qa1	2026-10-12 16:44:48.535883+00	qa1	0
fba9f995-1d4c-47ce-b03a-4e38cf29ffe4	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 16:44:48.668977+00	qa1	2026-10-12 16:44:48.668977+00	qa1	0
5dd5fe9e-b04c-45bb-a925-6ccb969d8c8b	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 16:44:48.738122+00	qa1	2026-10-12 16:44:48.738122+00	qa1	0
29caae88-3d59-4c5a-bd9a-166412f76cf0	8dfda8af-e2f7-4d03-b552-66ec8a1b0b17	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	f773e362-16eb-47e7-943b-725f13439921	2026-10-12 16:44:48.603108+00	qa1	2026-10-12 16:44:49.568829+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
89fbd577-7ab5-4251-9d19-a8358d2ce56f	82d0a1b0-f020-4066-98bf-8be35aa1054b	1aeace40-db9f-4837-92db-9f7cf4907e86	1	3	DONE	2026-10-12 16:43:33.954755+00	po	2026-10-12 16:44:40.792983+00	po	1
dd2c33e7-d29f-489d-b0b2-98c29e15ddef	82d0a1b0-f020-4066-98bf-8be35aa1054b	e621377d-312a-4c6c-9ef9-35970f553809	2	2	DONE	2026-10-12 16:43:34.029757+00	po	2026-10-12 16:44:40.792983+00	po	1
b5983bfd-aa6d-4214-8b2f-9feb53410a1c	82d0a1b0-f020-4066-98bf-8be35aa1054b	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	3	3	DONE	2026-10-12 16:43:34.091895+00	po	2026-10-12 16:44:40.792983+00	po	1
064ff8b4-7ed9-4b43-8059-62f4502bcf75	82d0a1b0-f020-4066-98bf-8be35aa1054b	b70751d5-7bee-4baf-916c-94cd19574aea	4	2	DONE	2026-10-12 16:43:34.165049+00	po	2026-10-12 16:44:40.792983+00	po	1
ecd9d7d6-d715-4b64-95f3-882ef5d835c5	82d0a1b0-f020-4066-98bf-8be35aa1054b	4cdaea31-8ff5-4615-8bbb-0e16feeac320	5	2	DONE	2026-10-12 16:43:34.235305+00	po	2026-10-12 16:44:40.792983+00	po	1
de546327-af01-4ea9-a4af-a60db3a583bd	066e22a8-7c47-4fe0-a525-0c2d85398c1e	e3fceab0-160c-4689-b69f-a1b025291f00	1	3	PLANNED	2026-10-12 16:44:41.483369+00	po	2026-10-12 16:44:41.483369+00	po	0
6fe65bd1-c940-4671-b059-02d8090c306a	066e22a8-7c47-4fe0-a525-0c2d85398c1e	0a582dbf-8db9-4057-8018-1153ee12d10f	2	3	PLANNED	2026-10-12 16:44:41.483369+00	po	2026-10-12 16:44:41.483369+00	po	0
44cc0924-9ea6-4b64-8a52-7c17d497232d	066e22a8-7c47-4fe0-a525-0c2d85398c1e	40072a58-34f0-4a1a-81af-8bd5c97f131c	3	2	PLANNED	2026-10-12 16:44:41.483894+00	po	2026-10-12 16:44:41.483894+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
82d0a1b0-f020-4066-98bf-8be35aa1054b	cb27c1cf-a769-44d9-afb4-573b3c74bd99	763f895a-2ce4-417e-ae17-a4cde6084f70	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 16:43:33.232872+00	po	2026-10-12 16:44:40.792983+00	po	2
066e22a8-7c47-4fe0-a525-0c2d85398c1e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	763f895a-2ce4-417e-ae17-a4cde6084f70	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 16:43:33.284538+00	po	2026-10-12 16:44:41.529808+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
dc2d46fb-ae28-4ba3-b315-760a838f64e9	47eb3608-83d0-4c6b-904b-67969e22d6bc	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:43:37.524916+00	qa1	2026-10-12 16:43:37.651517+00	qa1	1	\N
b72b556a-2d24-4017-914f-0ed476409eb4	47eb3608-83d0-4c6b-904b-67969e22d6bc	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 16:43:37.524916+00	qa1	2026-10-12 16:43:38.222637+00	qa1	1	\N
665e0b02-b057-4b42-881f-64882085c5e8	34cce1fe-9233-4feb-9622-deb8a0ae5786	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:43:38.315174+00	qa1	2026-10-12 16:43:38.333796+00	qa1	1	\N
a571bca6-818b-45f8-8958-6be1bbd09bbc	34cce1fe-9233-4feb-9622-deb8a0ae5786	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 16:43:38.315174+00	qa1	2026-10-12 16:43:38.355798+00	qa1	1	\N
d5388e5a-52b0-428b-88f9-1e641ce0fa9a	82c589f8-7dcd-47be-b01a-f9244d9a820c	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:43:38.376975+00	qa1	2026-10-12 16:43:38.398706+00	qa1	1	\N
fed9c210-d994-4b01-8f43-d4a2cdc848cb	82c589f8-7dcd-47be-b01a-f9244d9a820c	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 16:43:38.376975+00	qa1	2026-10-12 16:43:38.423241+00	qa1	1	\N
eba84c0e-dd7f-4e17-bfcf-f65eb94f61bd	529adc1d-29a7-41d9-b711-cc5d5dbe4cda	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:44:43.581053+00	qa2	2026-10-12 16:44:43.712337+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
6b135347-bd6e-4ab8-a716-79052c193b90	529adc1d-29a7-41d9-b711-cc5d5dbe4cda	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 16:44:43.581053+00	qa2	2026-10-12 16:44:43.828209+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
cc32c73c-4a95-4039-b87b-8418dd6e3f1a	529adc1d-29a7-41d9-b711-cc5d5dbe4cda	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 16:44:43.581053+00	qa2	2026-10-12 16:44:43.948367+00	qa2	1	\N
99ccd034-0321-40ab-97ab-c9a7515c8132	529adc1d-29a7-41d9-b711-cc5d5dbe4cda	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 16:44:43.581053+00	qa2	2026-10-12 16:44:44.060901+00	qa2	1	\N
56c396cb-d1e1-4c05-b86a-ba356877375a	529adc1d-29a7-41d9-b711-cc5d5dbe4cda	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 16:44:43.581053+00	qa2	2026-10-12 16:44:44.328634+00	qa2	1	\N
c4f0d4f1-2761-47d8-9ed8-71442190c365	db425e76-c48e-4a6a-9370-e5d8d7a30af6	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:44:46.300718+00	qa1	2026-10-12 16:44:46.432365+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
fb5cd292-41c8-42d2-9228-7de8a0b3ce9b	db425e76-c48e-4a6a-9370-e5d8d7a30af6	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 16:44:46.300718+00	qa1	2026-10-12 16:44:46.998202+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
b3d5d046-0b3c-4177-abac-202b10e1c073	db425e76-c48e-4a6a-9370-e5d8d7a30af6	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 16:44:46.301233+00	qa1	2026-10-12 16:44:47.116331+00	qa1	1	\N
b40abe86-4bae-44c9-8ca8-c8718d841888	db425e76-c48e-4a6a-9370-e5d8d7a30af6	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 16:44:46.301233+00	qa1	2026-10-12 16:44:47.234274+00	qa1	1	\N
7e4df50d-ac3f-4c01-a575-3e1d1b3e4e3b	ef77e702-ad96-47f9-b860-4a4c6a93f7ad	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 16:44:47.274874+00	qa1	2026-10-12 16:44:47.28959+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
a3938226-46f3-45f6-8ca5-04ed643015f9	ef77e702-ad96-47f9-b860-4a4c6a93f7ad	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 16:44:47.274874+00	qa1	2026-10-12 16:44:47.306965+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
cf3b7f63-aa84-41b6-b14d-7f4055a01c89	ef77e702-ad96-47f9-b860-4a4c6a93f7ad	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 16:44:47.274874+00	qa1	2026-10-12 16:44:47.328446+00	qa1	1	\N
c579d654-cd7b-4118-b2ee-041ae4b6efaa	ef77e702-ad96-47f9-b860-4a4c6a93f7ad	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 16:44:47.275391+00	qa1	2026-10-12 16:44:47.350217+00	qa1	1	\N
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
bdde38ce-5367-4790-a38d-f09e47f3bc82	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 16:43:24.450824+00	qa1	2026-10-12 16:43:24.450824+00	qa1	0
ad92da6d-7dda-46b7-a897-648feb2f7b61	074601e0-2232-428d-a5b6-1102b7fd59ca	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 16:43:24.56592+00	qa1	2026-10-12 16:43:24.56592+00	qa1	0
3b024aa4-de53-46bb-a900-26130cd6e5d7	fc149eda-1819-4e4f-9e56-c18776fe746d	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "mes-executions-admin", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:24.649713+00	dev	2026-10-12 16:43:24.649713+00	dev	0
13c19927-9d8e-464c-b2df-831c26ea93fc	a9e42611-9ec7-4b76-b721-1d54ebe19827	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "mes-executions-admin", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:24.715168+00	dev	2026-10-12 16:43:24.715168+00	dev	0
3b3d0fe8-960a-48b5-8f74-8d2e2af8f247	ff82674d-1a8b-432d-a7c9-d4b43a336a25	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "mes-executions-admin", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:24.784627+00	dev	2026-10-12 16:43:24.784627+00	dev	0
937ffe3a-51a0-496a-a7c9-43b59402fc10	8295380f-fa42-4cbd-94f5-e495dcdccd74	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "mes-executions-admin", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:24.854026+00	dev	2026-10-12 16:43:24.854026+00	dev	0
b3dc043f-8e04-40bb-8ab0-2e238bd1bded	ff511444-2795-403b-b6fd-e65c615309f3	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "mes-executions-admin", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:24.927185+00	dev	2026-10-12 16:43:24.927185+00	dev	0
36352713-cd1a-4fa8-96c2-bab38f921162	cf2bfbfd-f14d-441c-9020-1865165590de	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:26.19467+00	qa1	2026-10-12 16:43:26.19467+00	qa1	0
2c367a74-aba5-4234-b31d-1422eed776ff	cf2bfbfd-f14d-441c-9020-1865165590de	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "mes-executions-admin", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:26.320312+00	qa1	2026-10-12 16:43:26.320312+00	qa1	0
31f3fc2d-3112-428f-b205-0a5b8273ccc3	f08e4fd9-b712-4bb7-8b31-622610367bd4	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "mes-executions-admin", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:27.371132+00	dev	2026-10-12 16:43:27.371132+00	dev	0
ddbcedb7-e22e-48d1-9169-c5bcefaa116f	4bfeb009-f118-4cee-b388-6b0810563ec0	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "mes-executions-admin", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:27.230849+00	dev	2026-10-12 16:43:27.230849+00	dev	0
0a6d128f-5ea4-4721-aebc-31e21da3e99c	2810f279-a3b9-4328-9458-29e4bfa684ee	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "mes-executions-admin", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:27.300517+00	dev	2026-10-12 16:43:27.300517+00	dev	0
de3eeb05-7fad-4fe9-829b-f97d84421a11	c65dc8f5-5e74-4355-ba77-6387b8057fff	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 16:43:27.433769+00	qa1	2026-10-12 16:43:27.433769+00	qa1	0
979b5d4a-017f-4249-9421-90d8f6f206bb	a8e27b92-1df4-4406-9892-86ae4838da46	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 16:43:27.498041+00	qa1	2026-10-12 16:43:27.498041+00	qa1	0
7605c836-3aff-4fe9-bab9-5394ad331615	27408e0a-9202-4fd5-b162-7146fa7ee253	1	{"key": "TC-14", "kind": "AUTOMATED", "path": "src/test/java/com/kerware/e2e/saucedemo/inventaire/InventaireCatalogueTest.java", "tags": null, "title": "Catalogue : noms et prix (Playwright Java)", "branch": "master", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "Java", "priority": "SHOULD", "framework": "JUnit 5", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "kerware, smoke", "gherkinSource": null, "repositoryUrl": "https://github.com/kerware/saucedemo-e2e", "testIdentifier": "InventaireCatalogueTest#catalogueAffiche", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 16:43:27.576187+00	dev	2026-10-12 16:43:27.576187+00	dev	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 16:43:24.443262+00	qa1	2026-10-12 16:43:24.525092+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
074601e0-2232-428d-a5b6-1102b7fd59ca	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 16:43:24.565129+00	qa1	2026-10-12 16:43:24.611379+00	qa1	1	[]	[]	f
fc149eda-1819-4e4f-9e56-c18776fe746d	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 16:43:24.646829+00	dev	2026-10-12 16:43:24.689531+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
a9e42611-9ec7-4b76-b721-1d54ebe19827	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 16:43:24.714654+00	dev	2026-10-12 16:43:24.750503+00	qa1	1	[]	[]	f
ff82674d-1a8b-432d-a7c9-d4b43a336a25	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 16:43:24.784075+00	dev	2026-10-12 16:43:24.824357+00	qa1	1	[]	[]	f
ff511444-2795-403b-b6fd-e65c615309f3	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 16:43:24.926655+00	dev	2026-10-12 16:43:24.970425+00	qa1	1	[]	[]	f
2810f279-a3b9-4328-9458-29e4bfa684ee	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 16:43:27.300001+00	dev	2026-10-12 16:43:27.3408+00	qa1	1	[]	[]	f
cf2bfbfd-f14d-441c-9020-1865165590de	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 16:43:26.19467+00	qa1	2026-10-12 16:43:26.327758+00	qa1	2	[]	[]	f
4bfeb009-f118-4cee-b388-6b0810563ec0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 16:43:27.230329+00	dev	2026-10-12 16:43:27.269195+00	qa1	1	[]	[]	f
f08e4fd9-b712-4bb7-8b31-622610367bd4	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 16:43:27.370609+00	dev	2026-10-12 16:43:27.408834+00	qa1	1	[]	[]	f
c65dc8f5-5e74-4355-ba77-6387b8057fff	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 16:43:27.431919+00	qa1	2026-10-12 16:43:27.46936+00	qa1	1	[]	[]	f
a8e27b92-1df4-4406-9892-86ae4838da46	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 16:43:27.496849+00	qa1	2026-10-12 16:43:27.539529+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
27408e0a-9202-4fd5-b162-7146fa7ee253	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-14	14	AUTOMATED	Catalogue : noms et prix (Playwright Java)	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 16:43:27.575667+00	dev	2026-10-12 16:43:27.607651+00	qa1	1	[]	[]	f
8295380f-fa42-4cbd-94f5-e495dcdccd74	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 16:43:24.853458+00	dev	2026-10-12 16:45:30.390345+00	po	2	[]	[]	f
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
ab77a304-81f4-4490-90b2-aea654dc0e2a	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	VERIFIES	MANUAL	2026-10-12 16:43:24.463042+00	qa1	2026-10-12 16:43:24.463042+00	qa1	0	\N
97e83bfc-5fcd-4a7e-9793-56a0f8bb71c0	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	0f30af67-ea6a-4211-9d9d-4d6acdab7bc4	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	VERIFIES	MANUAL	2026-10-12 16:43:24.463564+00	qa1	2026-10-12 16:43:24.463564+00	qa1	0	\N
d9e2a9bb-6064-4ef4-8042-6c9dffebd346	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	074601e0-2232-428d-a5b6-1102b7fd59ca	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	PARTIALLY_VERIFIES	MANUAL	2026-10-12 16:43:24.572331+00	qa1	2026-10-12 16:43:24.572331+00	qa1	0	\N
3571d0b0-80f4-4e13-bc7a-2c410c1fe5b9	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	074601e0-2232-428d-a5b6-1102b7fd59ca	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	VERIFIES	MANUAL	2026-10-12 16:43:24.572331+00	qa1	2026-10-12 16:43:24.572331+00	qa1	0	\N
2aa832c9-0bd3-4bef-949f-cdffa8ffd71d	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	fc149eda-1819-4e4f-9e56-c18776fe746d	REQUIREMENT	1aeace40-db9f-4837-92db-9f7cf4907e86	VERIFIES	MANUAL	2026-10-12 16:43:24.654898+00	dev	2026-10-12 16:43:24.654898+00	dev	0	\N
340fc83a-1fa9-46e9-99bf-85b0fbf9e2ce	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	fc149eda-1819-4e4f-9e56-c18776fe746d	REQUIREMENT	e621377d-312a-4c6c-9ef9-35970f553809	VERIFIES	MANUAL	2026-10-12 16:43:24.655492+00	dev	2026-10-12 16:43:24.655492+00	dev	0	\N
c6a88734-3b2d-472b-bbe4-5563bd88222e	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a9e42611-9ec7-4b76-b721-1d54ebe19827	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	VERIFIES	MANUAL	2026-10-12 16:43:24.71802+00	dev	2026-10-12 16:43:24.71802+00	dev	0	\N
fb23cbe7-b6cf-4c64-9037-f60935b8e567	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff82674d-1a8b-432d-a7c9-d4b43a336a25	REQUIREMENT	b70751d5-7bee-4baf-916c-94cd19574aea	VERIFIES	MANUAL	2026-10-12 16:43:24.788037+00	dev	2026-10-12 16:43:24.788037+00	dev	0	\N
9f613f06-7818-497e-a26e-4f3fb5ed1487	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	ff511444-2795-403b-b6fd-e65c615309f3	REQUIREMENT	43568d71-9ff0-467d-899e-1e4a7d81c256	VERIFIES	MANUAL	2026-10-12 16:43:24.930081+00	dev	2026-10-12 16:43:24.930081+00	dev	0	\N
a140199d-c512-4c0d-98f2-056a4f1eca6f	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	cf2bfbfd-f14d-441c-9020-1865165590de	REQUIREMENT	e3fceab0-160c-4689-b69f-a1b025291f00	VERIFIES	GHERKIN_TAG	2026-10-12 16:43:26.199627+00	qa1	2026-10-12 16:43:26.199627+00	qa1	0	\N
e3ec808c-7019-43f7-a1c1-3a881653e1c7	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	cf2bfbfd-f14d-441c-9020-1865165590de	ACCEPTANCE_CRITERION	46f9acbb-5eb4-446f-be95-45a9300874db	VERIFIES	GHERKIN_TAG	2026-10-12 16:43:26.207622+00	qa1	2026-10-12 16:43:26.207622+00	qa1	0	\N
d7ff5e70-2e70-482a-b0e7-e439b49f5020	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	4bfeb009-f118-4cee-b388-6b0810563ec0	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	VERIFIES	MANUAL	2026-10-12 16:43:27.234317+00	dev	2026-10-12 16:43:27.234317+00	dev	0	\N
15bfa713-5949-41ac-b42c-3897b9750eac	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	2810f279-a3b9-4328-9458-29e4bfa684ee	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	VERIFIES	MANUAL	2026-10-12 16:43:27.30312+00	dev	2026-10-12 16:43:27.30312+00	dev	0	\N
518ef375-1d19-4011-893a-933b3f598400	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	f08e4fd9-b712-4bb7-8b31-622610367bd4	REQUIREMENT	4446da66-82e2-47e3-a920-773b4e7c3771	VERIFIES	MANUAL	2026-10-12 16:43:27.374954+00	dev	2026-10-12 16:43:27.374954+00	dev	0	\N
1bc813c3-4f4d-49d1-aa04-ed6ba668b0ac	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	c65dc8f5-5e74-4355-ba77-6387b8057fff	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	VERIFIES	MANUAL	2026-10-12 16:43:27.437366+00	qa1	2026-10-12 16:43:27.437366+00	qa1	0	\N
7698da51-d868-4e0d-a2f3-e68781a1ff4c	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	c65dc8f5-5e74-4355-ba77-6387b8057fff	REQUIREMENT	40072a58-34f0-4a1a-81af-8bd5c97f131c	VERIFIES	MANUAL	2026-10-12 16:43:27.437366+00	qa1	2026-10-12 16:43:27.437366+00	qa1	0	\N
382d924d-8dde-475b-b11d-54b778ca72c2	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	a8e27b92-1df4-4406-9892-86ae4838da46	REQUIREMENT	0a582dbf-8db9-4057-8018-1153ee12d10f	VERIFIES	MANUAL	2026-10-12 16:43:27.50137+00	qa1	2026-10-12 16:43:27.50137+00	qa1	0	\N
d721b40b-f036-45b9-b51b-1d1c7d788bc7	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	27408e0a-9202-4fd5-b162-7146fa7ee253	REQUIREMENT	ba3b5322-9cfe-427b-a7a9-b26e0cab0a2a	VERIFIES	MANUAL	2026-10-12 16:43:27.578779+00	dev	2026-10-12 16:43:27.578779+00	dev	0	\N
67ea8e80-19f7-41be-b6fd-44365afa5c90	cb27c1cf-a769-44d9-afb4-573b3c74bd99	TEST_CASE	8295380f-fa42-4cbd-94f5-e495dcdccd74	REQUIREMENT	4cdaea31-8ff5-4615-8bbb-0e16feeac320	VERIFIES	MANUAL	2026-10-12 16:43:24.857298+00	dev	2026-10-12 16:45:31.037985+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0876f995-71b9-499e-ac6f-dbc321d3c871	admin	admin@traceagile.local	Administrateur	$2a$12$kYlnCAabsW7F43ZrECwlL.fDPEKV/aO7T.o1N/m.DSld/3t7S3InS	t	t	2026-10-12 16:42:58.201595+00	system	2026-10-12 16:42:58.201595+00	system	0
e98c603a-a170-4990-b60a-39d0784e6dfe	po	po@traceagile.demo	Paula Owner	$2a$12$N5GTpMDdPpDnbqeEKAyo2u2vE.buN.ZZ4lE1FHzcRzksOgbWKjWAq	t	f	2026-10-12 16:43:08.024627+00	admin	2026-10-12 16:43:08.024627+00	admin	0
aa560ef9-573e-43a0-bec3-0cc635162f73	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$wVTvnJV9G7tN2XZHADBux.b8xprqtbhz1o0NPUWBKD8huCZWi5wnO	t	f	2026-10-12 16:43:08.216747+00	admin	2026-10-12 16:43:08.216747+00	admin	0
a26a2375-4c31-4b8d-9d21-57801eaff561	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$vqqL2kP715eQjAvoJIHZcu2P.lm3rolKsgcJPs5gxJcoIuQY3QHLq	t	f	2026-10-12 16:43:08.410179+00	admin	2026-10-12 16:43:08.410179+00	admin	0
562cb3cc-28de-4706-9b0a-ffebc7b79c07	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$PfcQkqZ5uegGNyeIawdj5.lLbYDZNPlEf4hNHP8y6AncuQGe/Y0n.	t	f	2026-10-12 16:43:08.59773+00	admin	2026-10-12 16:43:08.59773+00	admin	0
289a7552-515a-47b6-88a1-78025f42b8e8	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$eZYctWN/OrIhZ3f8ouLP7eS90Fz9xL77DD0OhRa4kzYm.SnAkoa8q	t	f	2026-10-12 16:43:08.795059+00	admin	2026-10-12 16:43:08.795059+00	admin	0
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


