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
0ffd56d6-5bfc-4c7a-831e-289b6d76b4da	549b7819-9798-451f-a043-4827291f6a7d	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 11:19:31.255114+00	po	2026-10-12 11:19:31.255114+00	po	0
35d5f969-509c-43eb-ac1e-cc46495e263a	549b7819-9798-451f-a043-4827291f6a7d	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 11:19:31.255617+00	po	2026-10-12 11:19:31.255617+00	po	0
759ebcfc-ff28-4dcf-886b-6572b80745dc	c763465d-0e53-4d68-9ba9-43cc442c47ec	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 11:19:31.31039+00	po	2026-10-12 11:19:31.31039+00	po	0
c4474708-b4b7-4045-878e-064dd6ca231f	9f9272a6-225c-49e4-ba76-3e22cf327afc	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 11:19:31.405325+00	po	2026-10-12 11:19:31.405325+00	po	0
83e0c5c1-410a-4d6d-aad1-b3be8edaacac	8e881c76-aea1-451a-89ce-60626a0f35cd	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 11:19:31.462382+00	po	2026-10-12 11:19:31.462382+00	po	0
d90cfee8-f194-4238-8495-0f96c572ba0c	b04c7cfc-67e4-4f07-a577-af2526bf13e0	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 11:19:31.513838+00	po	2026-10-12 11:19:31.513838+00	po	0
2581da30-7926-4c8d-8138-6ee51ea45952	940845db-6a95-436f-85d9-048f8cb7f974	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 11:19:31.597025+00	po	2026-10-12 11:19:31.597025+00	po	0
08921464-f90b-4e70-834b-b7df6dc9ebd9	940845db-6a95-436f-85d9-048f8cb7f974	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 11:19:31.597025+00	po	2026-10-12 11:19:31.597025+00	po	0
66ad4c55-ab48-4f8a-9460-f1851efd6d7d	d77a002f-072f-47c7-a0e6-ad4e7594edfa	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 11:19:31.644088+00	po	2026-10-12 11:19:31.644088+00	po	0
20fbd743-0003-47e4-8ece-4304de717ac8	d77a002f-072f-47c7-a0e6-ad4e7594edfa	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 11:19:31.644088+00	po	2026-10-12 11:19:31.644088+00	po	0
7fdcc72a-61dd-4d49-a7f8-fe1fa1484365	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 11:19:31.688981+00	po	2026-10-12 11:19:31.688981+00	po	0
d983d039-bbe7-4f31-af49-5416950b1351	94194db9-ea1c-4f6f-9ebd-0ba91f149391	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 11:19:31.774102+00	po	2026-10-12 11:19:31.774102+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
dd62e9dc-fece-44c3-854d-cca262aca81e	82caf026-6393-4635-81e1-836a58d86076	EXECUTION_STEP	6190f7a5-6437-44d0-9c8c-fb0a86c5181d	sd-defaut-problem-user.png	image/png	235121	51689098-7a3d-4d28-8059-fa56393262e4	2026-10-12 11:20:25.22331+00	qa2	2026-10-12 11:20:25.22331+00	qa2	0
1813b243-5bc4-4b76-afe6-8c4b860061aa	82caf026-6393-4635-81e1-836a58d86076	DEFECT	41632f0b-0bca-49ff-acb4-b65f36623379	sd-defaut-problem-user.png	image/png	235121	51689098-7a3d-4d28-8059-fa56393262e4	2026-10-12 11:20:26.885793+00	qa2	2026-10-12 11:20:26.885793+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8472114c-51ab-4d30-be1a-0ae039017603	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	7f257578-68b4-4194-bbff-820461e9d40a	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:31.068626+00	po	2026-10-12 11:19:31.068626+00	po	0
c2f09c36-9c77-4682-8ecd-d9f3bb1c7d26	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	123c04d5-e852-4c0b-9af8-57208dbb997e	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:31.170854+00	po	2026-10-12 11:19:31.170854+00	po	0
f0692aee-9020-47a9-922c-1e4caca91b9f	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.255617+00	po	2026-10-12 11:19:31.255617+00	po	0
a8ca73c9-1223-4c24-aa59-d74570e66a79	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.31039+00	po	2026-10-12 11:19:31.31039+00	po	0
54bdb762-40e1-476a-8829-2a1fbee0399c	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	262432e3-aa0f-40c3-9127-b9f5cab827c0	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:31.359763+00	po	2026-10-12 11:19:31.359763+00	po	0
cced574a-857e-4e99-aee5-5ed3d5688953	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	9f9272a6-225c-49e4-ba76-3e22cf327afc	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.405902+00	po	2026-10-12 11:19:31.405902+00	po	0
34797df1-36f4-4300-a249-455558c4ad6e	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	8e881c76-aea1-451a-89ce-60626a0f35cd	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.462382+00	po	2026-10-12 11:19:31.462382+00	po	0
441856a1-7349-4645-9f6d-abf489f2b41f	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	3b2b2e57-24ff-4d9f-939d-0dc9e3671970	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:31.733334+00	po	2026-10-12 11:19:31.733334+00	po	0
618bf702-fadb-4ea3-9796-6ce7f9b56cc1	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.514366+00	po	2026-10-12 11:19:31.514366+00	po	0
c7e178dd-9e26-44e9-a48b-af842f0997f0	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	8d6d2d8b-e9ad-4b68-8844-2e03de760306	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:31.557094+00	po	2026-10-12 11:19:31.557094+00	po	0
74bdc91d-d5b3-4bab-bae1-6c68cd27b5eb	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	940845db-6a95-436f-85d9-048f8cb7f974	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.597025+00	po	2026-10-12 11:19:31.597025+00	po	0
48947845-7efd-4c84-b3a6-47b5877766d2	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.644709+00	po	2026-10-12 11:19:31.644709+00	po	0
1e7693ce-b834-4cce-8cc5-20812f7a4c7b	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.688981+00	po	2026-10-12 11:19:31.688981+00	po	0
58f18470-e0df-4f0a-8209-a1985d71c418	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	94194db9-ea1c-4f6f-9ebd-0ba91f149391	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 11:19:31.774102+00	po	2026-10-12 11:19:31.774102+00	po	0
09c79d19-a58e-46ac-a013-f99bcbc40438	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	a9b3a4c6-e2ca-47d4-a994-3271f3799413	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:33.544805+00	po	2026-10-12 11:19:33.544805+00	po	0
92c09e66-49ee-436e-a0c2-274ce65e5a4e	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:35.114793+00	po	2026-10-12 11:19:35.114793+00	po	0
0f0d6483-3f56-409c-b6e7-e129dc293b07	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	2d6e793c-94b9-4541-9bc3-e2527c8f42d2	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:33.804841+00	po	2026-10-12 11:19:33.804841+00	po	0
a148feeb-a0d9-480c-871c-e3bf7846e6cc	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	1d5135a2-567a-44e7-a20b-7b2a0b210ef9	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:19:33.848278+00	po	2026-10-12 11:19:33.848278+00	po	0
1e976673-5b72-4177-b155-0461fcea5037	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:34.870156+00	po	2026-10-12 11:19:34.870156+00	po	0
c83aa3e0-e4a2-408c-a10b-adc9563d7a74	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:34.914951+00	po	2026-10-12 11:19:34.914951+00	po	0
1d833597-0566-4be2-b5b3-16cd48ee5e23	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	9f9272a6-225c-49e4-ba76-3e22cf327afc	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:34.952942+00	po	2026-10-12 11:19:34.952942+00	po	0
4bd25419-43ae-45a5-b1b0-8f08089c0aba	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	8e881c76-aea1-451a-89ce-60626a0f35cd	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:34.9909+00	po	2026-10-12 11:19:34.9909+00	po	0
8ec2a26a-491c-492e-b11e-61e664815088	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:35.034905+00	po	2026-10-12 11:19:35.034905+00	po	0
fe0126ce-b183-4ed9-8f79-7c48c94f668f	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	940845db-6a95-436f-85d9-048f8cb7f974	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:35.076263+00	po	2026-10-12 11:19:35.076263+00	po	0
e8be5b14-39fa-4e00-8347-8dafa95f34aa	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	bd6973a9-9e86-4ee3-8786-9960daeb68cd	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 11:19:44.072753+00	dev	2026-10-12 11:19:44.072753+00	dev	0
0a864279-cd63-4118-9ee1-28b5c93cdd5a	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	bd6973a9-9e86-4ee3-8786-9960daeb68cd	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.107432+00	qa1	2026-10-12 11:19:44.107432+00	qa1	0
fa2e34ab-ac92-4165-bc9a-b6dbede764e0	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f9a60afe-54fb-4703-88be-9f50a831554c	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:19:44.143512+00	dev	2026-10-12 11:19:44.143512+00	dev	0
72c0e98e-2d5d-4341-a111-972b767d2b16	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f9a60afe-54fb-4703-88be-9f50a831554c	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.177787+00	qa1	2026-10-12 11:19:44.177787+00	qa1	0
6a6f9854-8008-4856-87c2-45e98ca0ac74	82caf026-6393-4635-81e1-836a58d86076	SPRINT	8566cc15-1549-45ae-8e28-f6c48663b16c	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 11:19:53.019018+00	po	2026-10-12 11:19:53.019018+00	po	0
2294b88f-394c-455a-9f42-e52a78431f17	82caf026-6393-4635-81e1-836a58d86076	TRACE_LINK	ecb8a2ec-ec00-46f5-a3d1-7a9406a59f3d	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 11:21:05.849172+00	qa1	2026-10-12 11:21:05.849172+00	qa1	0
33a82a97-3ea5-4109-8bc5-3cde2d15cf1c	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:36.366356+00	po	2026-10-12 11:19:36.366356+00	po	0
a2558f10-f27a-429a-948c-e3fc3cff0e5b	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 11:19:43.857268+00	qa1	2026-10-12 11:19:43.857268+00	qa1	0
2ef1c8a7-db1c-403d-9e7f-4ad296af0867	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:43.938354+00	qa1	2026-10-12 11:19:43.938354+00	qa1	0
d3329e51-b514-4830-b8e3-2d3ce519d7c4	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b9ac4984-1751-44e7-9cff-e32877e03756	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 11:19:43.987136+00	qa1	2026-10-12 11:19:43.987136+00	qa1	0
7767478a-fbdc-4367-bfc7-8833005f25e6	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b9ac4984-1751-44e7-9cff-e32877e03756	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.027437+00	qa1	2026-10-12 11:19:44.027437+00	qa1	0
12d4a79b-88a8-4a86-9000-c14697d615fa	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.244541+00	qa1	2026-10-12 11:19:44.244541+00	qa1	0
96535732-4660-4148-ac7d-b925ecd5628b	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3b81aa15-d972-42e4-8516-34c5b92a71d9	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:19:44.280737+00	dev	2026-10-12 11:19:44.280737+00	dev	0
a0bc156a-33b2-45c7-817f-199fd278276a	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3b81aa15-d972-42e4-8516-34c5b92a71d9	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.312982+00	qa1	2026-10-12 11:19:44.312982+00	qa1	0
a1f73b4c-5d46-42bd-bf2a-beb332ea91f0	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:19:44.351699+00	dev	2026-10-12 11:19:44.351699+00	dev	0
265a3876-7738-4692-a712-595866aebc4f	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:44.389312+00	qa1	2026-10-12 11:19:44.389312+00	qa1	0
45ee6179-b58b-4151-8d3f-380497162fc2	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:45.880768+00	qa1	2026-10-12 11:19:45.880768+00	qa1	0
5c8b1f7e-d691-400a-a3ee-263fdb7d11a5	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 11:19:45.929077+00	qa1	2026-10-12 11:19:45.929077+00	qa1	0
6001456d-b783-4b96-b5b7-782692080b0b	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	1a2db9af-540c-49e7-a550-a36d83de5897	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:46.951183+00	qa1	2026-10-12 11:19:46.951183+00	qa1	0
3c4f3ad8-be43-4976-9bfe-4280b99d8287	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f71c33e3-115a-4a19-b096-39d80cedb8f7	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:47.0141+00	qa1	2026-10-12 11:19:47.0141+00	qa1	0
dd05945e-9e27-4366-81ff-3dffe2c7e2ec	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:47.150662+00	qa1	2026-10-12 11:19:47.150662+00	qa1	0
6929944d-4531-4e20-b21d-3b775f2a368f	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:19:44.212864+00	dev	2026-10-12 11:19:44.212864+00	dev	0
5ea1e1db-ff0a-4eca-af41-2ebcd4195648	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	8e0688dc-30d0-46e8-9e21-177364442c35	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:47.076267+00	qa1	2026-10-12 11:19:47.076267+00	qa1	0
24bbaaae-5062-4ac3-a706-105deb95e6c1	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	d5685b03-4869-4d6d-9e64-fc67e7c97962	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:19:47.227692+00	qa1	2026-10-12 11:19:47.227692+00	qa1	0
764c4094-903b-4748-9841-8f0dbf8741f6	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 11:19:53.728209+00	po	2026-10-12 11:19:53.728209+00	po	0
24cd9d0b-c1bb-4959-9750-993b7b4eadd9	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 11:19:54.045937+00	po	2026-10-12 11:19:54.045937+00	po	0
1ca43440-fe8d-404c-a108-2d1ac523022f	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:19:54.643814+00	po	2026-10-12 11:19:54.643814+00	po	0
5446e091-2fa1-45c5-8ddd-aa8177fdf96d	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:19:54.644363+00	po	2026-10-12 11:19:54.644363+00	po	0
b3a5fc01-a4d7-420f-bd65-609e03d21533	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	9f9272a6-225c-49e4-ba76-3e22cf327afc	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:19:54.644363+00	po	2026-10-12 11:19:54.644363+00	po	0
26f62417-6e82-44cf-9df2-76575a14fe61	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	8e881c76-aea1-451a-89ce-60626a0f35cd	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:19:54.644927+00	po	2026-10-12 11:19:54.644927+00	po	0
97ae9be3-f880-4b56-abe0-4ae5076f1c93	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:19:54.644927+00	po	2026-10-12 11:19:54.644927+00	po	0
160f6e18-9e3f-4a71-9598-e60308b8476f	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 11:19:54.645493+00	po	2026-10-12 11:19:54.645493+00	po	0
536d294a-cc6f-4d17-849a-801f9d7aaa51	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 11:19:45.802489+00	qa1	2026-10-12 11:19:45.802489+00	qa1	0
5908f7bf-c60d-4649-8122-9e3c57257996	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	1a2db9af-540c-49e7-a550-a36d83de5897	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:19:46.918182+00	dev	2026-10-12 11:19:46.918182+00	dev	0
5ff43b76-5ae0-4d34-9625-25ba22ae46a3	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f71c33e3-115a-4a19-b096-39d80cedb8f7	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:19:46.983955+00	dev	2026-10-12 11:19:46.983955+00	dev	0
7fec2cb1-38b6-47c3-8179-bd3326adeafd	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	8e0688dc-30d0-46e8-9e21-177364442c35	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:19:47.045748+00	dev	2026-10-12 11:19:47.045748+00	dev	0
02bb9e40-46a6-43c1-9d9d-3a8c6620ef50	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	d5685b03-4869-4d6d-9e64-fc67e7c97962	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 11:19:47.185036+00	qa1	2026-10-12 11:19:47.185036+00	qa1	0
cdad7bc2-b5c9-4864-b90b-0b7199ca3a4c	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	3094d509-688c-4511-9357-03bffeb70c04	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:19:55.999287+00	qa1	2026-10-12 11:19:55.999287+00	qa1	0
ea91b58a-9863-486b-9e28-e9aaa6b100ba	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	3094d509-688c-4511-9357-03bffeb70c04	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 11:19:56.615447+00	qa1	2026-10-12 11:19:56.615447+00	qa1	0
096dc3d4-5af0-4c4d-aa43-7945f0177cb8	82caf026-6393-4635-81e1-836a58d86076	RUN	45af275b-e2d9-4181-9cd2-7e06f161bf08	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 11:20:00.454531+00	dev	2026-10-12 11:20:00.454531+00	dev	0
1f7024a4-1b32-4d9e-b8e9-8a0b8f403c08	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 11:19:47.112062+00	qa1	2026-10-12 11:19:47.112062+00	qa1	0
9db82874-8f52-4b9a-bcc8-f4248b1d66ec	82caf026-6393-4635-81e1-836a58d86076	RELEASE	1690358a-ac95-4fc3-a81e-0e0724492790	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 11:19:52.92983+00	po	2026-10-12 11:19:52.92983+00	po	0
48fa2160-445a-4cf1-9997-32a4c2500070	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 11:19:52.96646+00	po	2026-10-12 11:19:52.96646+00	po	0
f0885e13-0cf7-4125-b105-c44e24b0a685	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 11:19:53.798426+00	po	2026-10-12 11:19:53.798426+00	po	0
311f2cfe-e953-4efe-b7b8-e9f8a9c4febc	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 11:19:53.886179+00	po	2026-10-12 11:19:53.886179+00	po	0
20d8d5cf-6a04-46fb-b2cd-a8d8f7b82fc5	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	3094d509-688c-4511-9357-03bffeb70c04	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 11:19:56.339246+00	qa1	2026-10-12 11:19:56.339246+00	qa1	0
da4243a6-4a98-4976-a5ab-234044891348	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 11:19:53.946423+00	po	2026-10-12 11:19:53.946423+00	po	0
d46ef079-60c7-4310-936c-7e5e10979805	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	3094d509-688c-4511-9357-03bffeb70c04	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 11:20:17.6729+00	qa1	2026-10-12 11:20:17.6729+00	qa1	0
74496612-a29c-4402-a7dd-c924757a4807	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:20:17.798206+00	po	2026-10-12 11:20:17.798206+00	po	0
cb548749-8b10-4e1b-b7c0-8fc398bf1284	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:20:17.856888+00	po	2026-10-12 11:20:17.856888+00	po	0
1593dec2-42dc-4909-9467-4fb38e408d6d	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	9f9272a6-225c-49e4-ba76-3e22cf327afc	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:20:17.909036+00	po	2026-10-12 11:20:17.909036+00	po	0
c276b6e3-516e-4543-9a03-97d707828206	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	8e881c76-aea1-451a-89ce-60626a0f35cd	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:20:17.960223+00	po	2026-10-12 11:20:17.960223+00	po	0
eda0dbcc-069e-4d82-9f96-33e9109069b6	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:20:19.692191+00	po	2026-10-12 11:20:19.692191+00	po	0
6cad5ca9-9dbb-4fbe-b3aa-2f98d87e4c0f	82caf026-6393-4635-81e1-836a58d86076	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 11:20:20.71207+00	po	2026-10-12 11:20:20.71207+00	po	0
464551dc-29c8-4414-be4d-78f496e29840	82caf026-6393-4635-81e1-836a58d86076	SPRINT	8566cc15-1549-45ae-8e28-f6c48663b16c	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 11:20:22.15012+00	po	2026-10-12 11:20:22.15012+00	po	0
0ff069b6-c276-4146-9b88-4602380ca3c7	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	940845db-6a95-436f-85d9-048f8cb7f974	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:20:22.19745+00	po	2026-10-12 11:20:22.19745+00	po	0
a549da60-13df-4a23-9d94-eb56c9e09a8f	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:20:22.19745+00	po	2026-10-12 11:20:22.19745+00	po	0
2e3928fc-4250-4743-829c-754c8182cdf0	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:20:22.19745+00	po	2026-10-12 11:20:22.19745+00	po	0
c9c47036-ab5a-4a63-9d6f-5068e3e04a4b	82caf026-6393-4635-81e1-836a58d86076	SPRINT	8566cc15-1549-45ae-8e28-f6c48663b16c	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 11:20:22.198143+00	po	2026-10-12 11:20:22.198143+00	po	0
43e3345b-c1c8-4f4a-9a1b-a70ef06ab9ce	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	d12b85b3-c17d-4028-80fe-8cc387c84eed	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:20:23.322371+00	qa1	2026-10-12 11:20:23.322371+00	qa1	0
0ac2b5e6-1b10-43fa-a8dc-b5357ff3d028	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	d12b85b3-c17d-4028-80fe-8cc387c84eed	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 11:20:23.358649+00	qa1	2026-10-12 11:20:23.358649+00	qa1	0
af5b85fd-47f6-47a2-beae-011b331c25aa	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	d12b85b3-c17d-4028-80fe-8cc387c84eed	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 11:20:23.388229+00	qa1	2026-10-12 11:20:23.388229+00	qa1	0
c6805728-f298-4764-b738-544832bb4372	82caf026-6393-4635-81e1-836a58d86076	DEFECT	41632f0b-0bca-49ff-acb4-b65f36623379	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 11:20:26.880855+00	qa2	2026-10-12 11:20:26.880855+00	qa2	0
13bfa4c9-de17-4c37-87ee-be275984c161	82caf026-6393-4635-81e1-836a58d86076	SESSION	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 11:20:29.937954+00	qa1	2026-10-12 11:20:29.937954+00	qa1	0
219b34ec-b435-429f-9e7f-7f16f322710b	82caf026-6393-4635-81e1-836a58d86076	DEFECT	4ac29366-c47d-49a4-9602-7af48f905a93	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 00:00\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 11:20:31.177811+00	qa1	2026-10-12 11:20:31.177811+00	qa1	0
201588a1-ee8c-4ced-97fc-7443b5974876	82caf026-6393-4635-81e1-836a58d86076	SESSION	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 11:20:32.577908+00	qa1	2026-10-12 11:20:32.577908+00	qa1	0
7582e382-939e-4edc-9d07-3e6ad11eb317	82caf026-6393-4635-81e1-836a58d86076	SESSION	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 11:20:32.805154+00	qa1	2026-10-12 11:20:32.805154+00	qa1	0
35b30dff-11c0-4ce3-a82f-f29e4d42fdb9	82caf026-6393-4635-81e1-836a58d86076	SESSION	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 11:20:33.524597+00	po	2026-10-12 11:20:33.524597+00	po	0
ddc163c7-40ec-4ee7-989a-b29b098fed7b	82caf026-6393-4635-81e1-836a58d86076	RUN	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 11:20:35.189746+00	dev	2026-10-12 11:20:35.189746+00	dev	0
2b96039e-90f5-420c-90f1-73acb84e8e9c	82caf026-6393-4635-81e1-836a58d86076	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 11:21:05.137605+00	po	2026-10-12 11:21:05.137605+00	po	0
19184f07-366e-4717-8006-98be15b162d8	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3b81aa15-d972-42e4-8516-34c5b92a71d9	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 11:21:05.146659+00	po	2026-10-12 11:21:05.146659+00	po	0
0b8b28c4-d8aa-407f-85cd-46b565510484	82caf026-6393-4635-81e1-836a58d86076	CAMPAIGN	46be6920-1617-42ba-8ed6-d9323b3cd687	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:20:54.974961+00	qa1	2026-10-12 11:20:54.974961+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
45af275b-e2d9-4181-9cd2-7e06f161bf08	82caf026-6393-4635-81e1-836a58d86076	RUN-1	1	3094d509-688c-4511-9357-03bffeb70c04	7d0f1ba2-1020-4e06-999a-df539e194f50	COMPLETED	dev	2026-10-12 11:20:00.445127+00	2026-10-12 11:20:00.525496+00	2026-10-12 11:20:00.506707+00	2026-10-12 11:20:15.753643+00	2026-10-12 11:20:15.753643+00	recette	1.0.0-s1	job-c83d700c	executeur-docker@dac3eebb59fc	http://localhost:8091/api/v1/jobs/job-c83d700c/logs	http://localhost:8091/api/v1/jobs/job-c83d700c/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 11:20:00.45219+00	dev	2026-10-12 11:20:15.774463+00	anonymousUser	9
19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	82caf026-6393-4635-81e1-836a58d86076	RUN-2	2	d12b85b3-c17d-4028-80fe-8cc387c84eed	7d0f1ba2-1020-4e06-999a-df539e194f50	COMPLETED	dev	2026-10-12 11:20:35.1881+00	2026-10-12 11:20:35.229276+00	2026-10-12 11:20:35.228239+00	2026-10-12 11:20:51.934916+00	2026-10-12 11:20:51.934916+00	recette	1.0.0-s2	job-a861f8e6	executeur-docker@dac3eebb59fc	http://localhost:8091/api/v1/jobs/job-a861f8e6/logs	http://localhost:8091/api/v1/jobs/job-a861f8e6/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 11:20:35.188726+00	dev	2026-10-12 11:20:51.949364+00	anonymousUser	9
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4e2ac0a6-96b2-4929-8118-000640228a12	bd6973a9-9e86-4ee3-8786-9960daeb68cd	DATA_DRIVEN	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 11:19:44.065289+00	dev	2026-10-12 11:19:44.065289+00	dev	0
fa80bd49-ae3e-4b41-a821-fdfb16a5eb69	f9a60afe-54fb-4703-88be-9f50a831554c	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:19:44.139335+00	dev	2026-10-12 11:19:44.139335+00	dev	0
94281414-83bb-4fe1-838e-bae58d6b000d	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:19:44.209212+00	dev	2026-10-12 11:19:44.209212+00	dev	0
4f1819ba-d10c-4e1a-99e2-568b3436fc87	3b81aa15-d972-42e4-8516-34c5b92a71d9	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:19:44.275221+00	dev	2026-10-12 11:19:44.275221+00	dev	0
ff13f9b8-0347-42c3-a792-8e2c4a3a4fba	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	API	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:19:44.346657+00	dev	2026-10-12 11:19:44.346657+00	dev	0
e76b8483-3aac-42d1-bd6c-54c4d69eb7a3	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	BDD	Playwright	\N	file:///depots/traceagile	installation-hors-docker	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 11:19:45.784683+00	qa1	2026-10-12 11:19:45.929645+00	qa1	1
b5d96173-3ffb-4685-b63e-12bb313af5bc	1a2db9af-540c-49e7-a550-a36d83de5897	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:19:46.914268+00	dev	2026-10-12 11:19:46.914268+00	dev	0
fe1c8f69-ae16-44cb-a4d1-ffd4f703ebff	f71c33e3-115a-4a19-b096-39d80cedb8f7	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:19:46.980376+00	dev	2026-10-12 11:19:46.980376+00	dev	0
471ff6ad-c205-40c0-9538-36b0043355ad	8e0688dc-30d0-46e8-9e21-177364442c35	PERFORMANCE	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 11:19:47.042605+00	dev	2026-10-12 11:19:47.042605+00	dev	0
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a757e804-807b-4f36-b4ad-ce024f580cab	BDD	Cucumber-JVM	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
9b3144f2-31a2-4666-99e5-2562384a2786	BDD	Cucumber-JS	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
b9897a85-f6cd-4869-b786-f24239dd4df8	BDD	Behave	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
685d44f8-5cd8-4eae-8359-ced020b59477	BDD	SpecFlow	4	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
685f8b6a-2d83-4779-9fe0-616fba71fd7f	BDD	Karate	5	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
9fb94b31-a928-49a6-846a-307c1f73ff6c	UNIT	JUnit 5	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
bcec3e1d-e515-4de4-8a1d-a866637aaa92	UNIT	Kotest	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
c3bcc1d5-f274-4efd-bd2d-a70c64fbdcf8	UNIT	pytest	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
46c972b6-5c45-45af-be2f-63b57aa48d52	UNIT	Jest	4	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
1b37b118-61d6-46dd-bd24-12c6ffefa2bf	UNIT	Vitest	5	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
1ad01d49-1edb-45f7-9d65-d18c45fe37e6	UI	Playwright	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
28114f20-1cb7-4013-bc8c-0da09386c720	UI	Selenium	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
bd84e155-7180-47d7-ad47-6ac05d468a07	UI	Cypress	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
7c395f20-ebc0-4dc4-9ca4-317bd80cfca5	UI	Appium	4	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
8759a37b-6e0f-409e-bf4d-9b86bdac4987	API	REST Assured	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
9cfa11e3-0ab0-49f3-82df-d88f6c3b62c6	API	Karate	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
fcb7e34f-45fc-40aa-81f1-87b9154031b0	API	Postman/Newman	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
85ccfddb-9165-4a34-b6d1-474c44a9a0b7	API	pytest + requests	4	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
943ebaa4-1785-4407-af3d-7e7e21f9e9d6	KEYWORD	Robot Framework	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
7fe00027-352f-42ed-99c5-a64ae96352e0	DATA_DRIVEN	JUnit 5	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
5beb7b14-29b0-4509-a494-7d753b575df2	DATA_DRIVEN	pytest	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
7761cacd-64f6-4bb9-9c85-c5b766bc397b	DATA_DRIVEN	Playwright	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
1eb23295-4411-4c95-a264-486b027ebcac	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
dafc80a1-7175-497c-a961-f2a4e7650467	PERFORMANCE	Gatling	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
564ed50f-e31a-4ec2-8692-3b761e9d4e17	PERFORMANCE	k6	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
d4ccc4d7-b2e2-4631-a09a-eae7d8c55ccc	PERFORMANCE	JMeter	3	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
8dfd7d4e-9c16-46ba-bf47-f768ad6bcc46	CONTRACT	Pact	1	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
b710092c-7e69-4751-aee1-718b3658b1b4	CONTRACT	Spring Cloud Contract	2	2026-10-12 11:19:06.076688+00	system	2026-10-12 11:19:06.076688+00	system	0
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
73af4853-4c32-40f6-9cb8-0f4de0f5f7b6	3094d509-688c-4511-9357-03bffeb70c04	bd6973a9-9e86-4ee3-8786-9960daeb68cd	1	\N	4	12	2026-10-12 11:19:56.330949+00	qa1	2026-10-12 11:19:56.330949+00	qa1	0	\N	\N
a4ab846d-5159-4f96-bfc5-0f91456f46fc	3094d509-688c-4511-9357-03bffeb70c04	f9a60afe-54fb-4703-88be-9f50a831554c	1	\N	5	6	2026-10-12 11:19:56.330949+00	qa1	2026-10-12 11:19:56.330949+00	qa1	0	\N	\N
29cd2e37-9b17-4970-bf8a-b37f792f1305	3094d509-688c-4511-9357-03bffeb70c04	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	1	\N	6	3	2026-10-12 11:19:56.331534+00	qa1	2026-10-12 11:19:56.331534+00	qa1	0	\N	\N
20ddc174-eca1-4308-b0db-b071f29df68c	3094d509-688c-4511-9357-03bffeb70c04	3b81aa15-d972-42e4-8516-34c5b92a71d9	1	\N	7	3	2026-10-12 11:19:56.331534+00	qa1	2026-10-12 11:19:56.331534+00	qa1	0	\N	\N
5cbb1500-3462-40eb-a101-dc501c16a96a	3094d509-688c-4511-9357-03bffeb70c04	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	1	\N	8	6	2026-10-12 11:19:56.611903+00	qa1	2026-10-12 11:19:56.611903+00	qa1	0	\N	\N
8629c163-3bc3-4d18-831c-cb1b33991e1a	3094d509-688c-4511-9357-03bffeb70c04	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	1	16	2026-10-12 11:19:56.33042+00	qa1	2026-10-12 11:19:56.672269+00	qa1	1	Comptes	0
72dac5a9-041c-401b-b8a7-f2fc6fbc3360	3094d509-688c-4511-9357-03bffeb70c04	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	2	16	2026-10-12 11:19:56.330949+00	qa1	2026-10-12 11:19:56.697466+00	qa1	1	Comptes	1
d275030e-daa0-421e-a636-5d6b39497fb4	3094d509-688c-4511-9357-03bffeb70c04	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	3	16	2026-10-12 11:19:56.330949+00	qa1	2026-10-12 11:19:56.719401+00	qa1	1	Comptes	2
1ea221d5-ab36-4f62-b9fb-cef2797d6afd	d12b85b3-c17d-4028-80fe-8cc387c84eed	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	2	\N	3	12	2026-10-12 11:20:23.351672+00	qa1	2026-10-12 11:20:23.351672+00	qa1	0	\N	\N
f4ad9909-4098-4234-af78-0adfd2259b8d	d12b85b3-c17d-4028-80fe-8cc387c84eed	1a2db9af-540c-49e7-a550-a36d83de5897	1	\N	4	12	2026-10-12 11:20:23.351672+00	qa1	2026-10-12 11:20:23.351672+00	qa1	0	\N	\N
38cc6ee3-a8d1-47e1-9687-6f2a41b3de16	d12b85b3-c17d-4028-80fe-8cc387c84eed	f71c33e3-115a-4a19-b096-39d80cedb8f7	1	\N	7	6	2026-10-12 11:20:23.352674+00	qa1	2026-10-12 11:20:23.352674+00	qa1	0	\N	\N
5429cb35-b135-435b-b137-b01abe779696	d12b85b3-c17d-4028-80fe-8cc387c84eed	8e0688dc-30d0-46e8-9e21-177364442c35	1	\N	8	6	2026-10-12 11:20:23.385871+00	qa1	2026-10-12 11:20:23.385871+00	qa1	0	\N	\N
4e12993d-7736-4b9b-9294-10bcef6fc7b4	d12b85b3-c17d-4028-80fe-8cc387c84eed	b9ac4984-1751-44e7-9cff-e32877e03756	1	c214f6ca-5b72-41c0-ab02-10eb661a0ff6	1	16	2026-10-12 11:20:23.351672+00	qa1	2026-10-12 11:20:23.432902+00	qa1	1	\N	\N
d553baa1-d240-4fe4-b87b-b16c8ee68673	d12b85b3-c17d-4028-80fe-8cc387c84eed	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	2	16	2026-10-12 11:20:23.351672+00	qa1	2026-10-12 11:20:23.45305+00	qa1	1	\N	\N
afd75522-0d7b-49ad-a4ba-5082e39aa119	d12b85b3-c17d-4028-80fe-8cc387c84eed	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	5	12	2026-10-12 11:20:23.351672+00	qa1	2026-10-12 11:20:23.472214+00	qa1	1	Produits	0
f1020bf6-8483-484c-a369-9e800d123a72	d12b85b3-c17d-4028-80fe-8cc387c84eed	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	6	12	2026-10-12 11:20:23.352674+00	qa1	2026-10-12 11:20:23.49282+00	qa1	1	Produits	1
d3b041cf-bf1e-4e71-8bdf-ec5bcc20dc3a	46be6920-1617-42ba-8ed6-d9323b3cd687	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	1	\N	1	0	2026-10-12 11:20:56.430113+00	qa1	2026-10-12 11:20:56.430113+00	qa1	0	\N	\N
91200368-72d4-45f1-82dc-b245de3c40b1	46be6920-1617-42ba-8ed6-d9323b3cd687	bd6973a9-9e86-4ee3-8786-9960daeb68cd	1	\N	2	0	2026-10-12 11:20:56.437913+00	qa1	2026-10-12 11:20:56.437913+00	qa1	0	\N	\N
1d064e36-b72a-45fc-817f-2e1fe421147f	46be6920-1617-42ba-8ed6-d9323b3cd687	f9a60afe-54fb-4703-88be-9f50a831554c	1	\N	3	0	2026-10-12 11:20:56.445749+00	qa1	2026-10-12 11:20:56.445749+00	qa1	0	\N	\N
c31fe37b-fd20-4835-aec4-e98cd3c0339c	46be6920-1617-42ba-8ed6-d9323b3cd687	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	1	\N	4	0	2026-10-12 11:20:56.451708+00	qa1	2026-10-12 11:20:56.451708+00	qa1	0	\N	\N
4f66a9e2-f3f4-4e2a-91de-cc58f955bdac	46be6920-1617-42ba-8ed6-d9323b3cd687	3b81aa15-d972-42e4-8516-34c5b92a71d9	1	\N	5	0	2026-10-12 11:20:56.457359+00	qa1	2026-10-12 11:20:56.457359+00	qa1	0	\N	\N
5a3c1043-7984-4ac2-8522-24333afd5d6b	46be6920-1617-42ba-8ed6-d9323b3cd687	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	2	\N	6	0	2026-10-12 11:20:56.462931+00	qa1	2026-10-12 11:20:56.462931+00	qa1	0	\N	\N
cebbd87c-7458-4e80-ba38-88c2b636f5b0	46be6920-1617-42ba-8ed6-d9323b3cd687	1a2db9af-540c-49e7-a550-a36d83de5897	1	\N	7	0	2026-10-12 11:20:56.46905+00	qa1	2026-10-12 11:20:56.46905+00	qa1	0	\N	\N
60146871-7e97-4ae2-b2a3-e2ba66c806e4	46be6920-1617-42ba-8ed6-d9323b3cd687	f71c33e3-115a-4a19-b096-39d80cedb8f7	1	\N	8	0	2026-10-12 11:20:56.474951+00	qa1	2026-10-12 11:20:56.474951+00	qa1	0	\N	\N
d47a86af-cf0f-47a3-ab92-9a24ab85937d	46be6920-1617-42ba-8ed6-d9323b3cd687	8e0688dc-30d0-46e8-9e21-177364442c35	1	\N	9	0	2026-10-12 11:20:56.480596+00	qa1	2026-10-12 11:20:56.480596+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
3094d509-688c-4511-9357-03bffeb70c04	82caf026-6393-4635-81e1-836a58d86076	CMP-1	1	Recette sprint 1	SPRINT	361d2eb6-c285-4bdb-9501-626ddbf3193b	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 11:19:55.999287+00	qa1	2026-10-12 11:20:17.6729+00	qa1	3	Release 1.0/Recettes de sprint
d12b85b3-c17d-4028-80fe-8cc387c84eed	82caf026-6393-4635-81e1-836a58d86076	CMP-2	2	Recette sprint 2	SPRINT	8566cc15-1549-45ae-8e28-f6c48663b16c	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 11:20:23.321865+00	qa1	2026-10-12 11:20:24.503499+00	qa2	2	Release 1.0/Recettes de sprint
46be6920-1617-42ba-8ed6-d9323b3cd687	82caf026-6393-4635-81e1-836a58d86076	CMP-3	3	Intégration continue — main	RELEASE	\N	1690358a-ac95-4fc3-a81e-0e0724492790	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 11:20:54.974961+00	qa1	2026-10-12 11:20:56.433219+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3970568f-b941-4004-891b-4ef264454409	82caf026-6393-4635-81e1-836a58d86076	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 11:19:27.717248+00	admin	2026-10-12 11:19:27.717248+00	admin	0
e85e34ab-b655-4ec4-b54c-f8b79e6a81af	82caf026-6393-4635-81e1-836a58d86076	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 11:19:27.71777+00	admin	2026-10-12 11:19:27.71777+00	admin	0
131603d5-b302-4fbf-9576-8c3c57ce843a	82caf026-6393-4635-81e1-836a58d86076	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 11:19:27.71834+00	admin	2026-10-12 11:19:27.71834+00	admin	0
d6762c44-6a2b-46d7-a901-23ece7eaedde	82caf026-6393-4635-81e1-836a58d86076	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 11:19:27.71834+00	admin	2026-10-12 11:19:27.71834+00	admin	0
454a0815-0b1f-453b-9c44-468651654c98	82caf026-6393-4635-81e1-836a58d86076	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 11:19:27.718844+00	admin	2026-10-12 11:19:27.718844+00	admin	0
2ea45bb4-1da2-4077-8b84-0a18d769439d	82caf026-6393-4635-81e1-836a58d86076	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 11:19:27.718844+00	admin	2026-10-12 11:19:27.718844+00	admin	0
81167887-443f-4c23-9110-612fc850e753	82caf026-6393-4635-81e1-836a58d86076	DOD	4	Code revu et intégré	\N	2026-10-12 11:19:27.718844+00	admin	2026-10-12 11:19:27.718844+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
abef21c2-b0ab-4d89-a7eb-3dc9c0e3f184	94194db9-ea1c-4f6f-9ebd-0ba91f149391	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 11:19:39.598731+00	po	2026-10-12 11:19:39.598731+00	po	0
4e354891-5fa6-4f5e-a961-c74cc493de5e	d77a002f-072f-47c7-a0e6-ad4e7594edfa	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 11:19:40.718847+00	po	2026-10-12 11:19:40.718847+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
41632f0b-0bca-49ff-acb4-b65f36623379	618c415b-f66c-4e63-8a4d-73693ea28d8f
4ac29366-c47d-49a4-9602-7af48f905a93	d4497379-ec02-4213-97ca-6935b03c9dbc
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
41632f0b-0bca-49ff-acb4-b65f36623379	d77a002f-072f-47c7-a0e6-ad4e7594edfa
41632f0b-0bca-49ff-acb4-b65f36623379	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744
4ac29366-c47d-49a4-9602-7af48f905a93	d77a002f-072f-47c7-a0e6-ad4e7594edfa
4ac29366-c47d-49a4-9602-7af48f905a93	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
41632f0b-0bca-49ff-acb4-b65f36623379	82caf026-6393-4635-81e1-836a58d86076	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 11:20:26.880109+00	qa2	2026-10-12 11:20:26.88635+00	qa2	1
4ac29366-c47d-49a4-9602-7af48f905a93	82caf026-6393-4635-81e1-836a58d86076	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 00:00\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 11:20:31.177811+00	qa1	2026-10-12 11:20:31.180292+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0c2932ed-e40b-452f-92a6-dade5a48eac8	94194db9-ea1c-4f6f-9ebd-0ba91f149391	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 11:19:39.175943+00	po	2026-10-12 11:19:39.175943+00	po	0
aab48f9f-a5e8-486b-94ec-757bc90904e2	94194db9-ea1c-4f6f-9ebd-0ba91f149391	EXAMPLE	0c2932ed-e40b-452f-92a6-dade5a48eac8	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 11:19:39.264252+00	po	2026-10-12 11:19:39.264252+00	po	0
9534d818-ab5b-40b9-bf9b-031dd3bc83fa	94194db9-ea1c-4f6f-9ebd-0ba91f149391	EXAMPLE	0c2932ed-e40b-452f-92a6-dade5a48eac8	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 11:19:39.350256+00	po	2026-10-12 11:19:39.350256+00	po	0
691ac128-d133-4b5c-abee-327951294ae9	94194db9-ea1c-4f6f-9ebd-0ba91f149391	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 11:19:39.427219+00	po	2026-10-12 11:19:39.427219+00	po	0
9c02fe4e-9edf-449b-bc1d-b7d749863205	94194db9-ea1c-4f6f-9ebd-0ba91f149391	EXAMPLE	691ac128-d133-4b5c-abee-327951294ae9	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 11:19:39.511494+00	po	2026-10-12 11:19:39.511494+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7d0f1ba2-1020-4e06-999a-df539e194f50	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Playwright", "Cucumber-JS"]	[]	4	t	2026-10-12 11:19:29.30245+00	admin	2026-10-12 11:20:34.359927+00	system	3
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
53932020-ba52-41b5-ae9d-eb3270b39ac0	8629c163-3bc3-4d18-831c-cb1b33991e1a	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	1	PASSED	f	2026-10-12 11:19:57.789085+00	2026-10-12 11:19:58.652909+00	863	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 11:19:57.796193+00	qa1	2026-10-12 11:19:58.654554+00	qa1	1	\N
96ab983d-2242-4738-84a6-a3b3b44aac40	72dac5a9-041c-401b-b8a7-f2fc6fbc3360	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	1	PASSED	f	2026-10-12 11:19:58.727165+00	2026-10-12 11:19:58.770474+00	43	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 11:19:58.730008+00	qa1	2026-10-12 11:19:58.771509+00	qa1	1	\N
52dedcf2-04aa-402a-9d1e-e5d827cc13ae	d275030e-daa0-421e-a636-5d6b39497fb4	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	1	PASSED	f	2026-10-12 11:19:58.787449+00	2026-10-12 11:19:58.825548+00	38	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 11:19:58.789505+00	qa1	2026-10-12 11:19:58.826606+00	qa1	1	\N
08a7f986-7c17-4c61-a8bc-e36c2011114c	a4ab846d-5159-4f96-bfc5-0f91456f46fc	f9a60afe-54fb-4703-88be-9f50a831554c	1	1	PASSED	f	2026-10-12 11:20:10.931876+00	2026-10-12 11:20:14.115264+00	3182	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:00.453421+00	dev	2026-10-12 11:20:14.134124+00	anonymousUser	2	45af275b-e2d9-4181-9cd2-7e06f161bf08
d504fa3e-d156-4bd7-a4b7-b55da22e410b	20ddc174-eca1-4308-b0db-b071f29df68c	3b81aa15-d972-42e4-8516-34c5b92a71d9	1	1	PASSED	f	2026-10-12 11:20:10.931908+00	2026-10-12 11:20:14.193696+00	3260	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:00.454012+00	dev	2026-10-12 11:20:14.207399+00	anonymousUser	2	45af275b-e2d9-4181-9cd2-7e06f161bf08
ebbd45b5-a09a-4032-99af-afb14f044f76	73af4853-4c32-40f6-9cb8-0f4de0f5f7b6	bd6973a9-9e86-4ee3-8786-9960daeb68cd	1	1	PASSED	f	2026-10-12 11:20:10.931852+00	2026-10-12 11:20:14.46504+00	3533	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:00.453421+00	dev	2026-10-12 11:20:14.477512+00	anonymousUser	2	45af275b-e2d9-4181-9cd2-7e06f161bf08
adc0bf4e-efbf-46a2-8593-f222fbf7cccd	29cd2e37-9b17-4970-bf8a-b37f792f1305	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	1	1	PASSED	f	2026-10-12 11:20:10.931868+00	2026-10-12 11:20:14.115262+00	3182	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:00.454012+00	dev	2026-10-12 11:20:14.673932+00	anonymousUser	2	45af275b-e2d9-4181-9cd2-7e06f161bf08
4b274d7c-1720-4aaa-8f97-72d17d1cb8b6	5cbb1500-3462-40eb-a101-dc501c16a96a	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	1	1	PASSED	f	2026-10-12 11:20:14.158107+00	2026-10-12 11:20:15.721847+00	1563	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:00.454012+00	dev	2026-10-12 11:20:15.734717+00	anonymousUser	2	45af275b-e2d9-4181-9cd2-7e06f161bf08
618c415b-f66c-4e63-8a4d-73693ea28d8f	4e12993d-7736-4b9b-9294-10bcef6fc7b4	b9ac4984-1751-44e7-9cff-e32877e03756	1	1	FAILED	f	2026-10-12 11:20:24.499404+00	2026-10-12 11:20:25.351795+00	852	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 11:20:24.502394+00	qa2	2026-10-12 11:20:25.353342+00	qa2	1	\N
e10ed829-0057-42c7-84c2-d5e5497ba0fd	afd75522-0d7b-49ad-a4ba-5082e39aa119	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	1	PASSED	f	2026-10-12 11:20:27.638642+00	2026-10-12 11:20:28.634099+00	995	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 11:20:27.643468+00	qa1	2026-10-12 11:20:28.634669+00	qa1	1	\N
958f6bbd-941b-400d-86bf-eb7a3afc4791	f1020bf6-8483-484c-a369-9e800d123a72	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	1	PASSED	f	2026-10-12 11:20:28.700695+00	2026-10-12 11:20:28.778716+00	78	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 11:20:28.704322+00	qa1	2026-10-12 11:20:28.779742+00	qa1	1	\N
d4497379-ec02-4213-97ca-6935b03c9dbc	d553baa1-d240-4fe4-b87b-b16c8ee68673	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	1	1	FAILED	f	2026-10-12 11:20:29.931673+00	2026-10-12 11:20:32.574499+00	2000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 11:20:29.936952+00	qa1	2026-10-12 11:20:32.579434+00	qa1	1	\N
d50ed14a-5059-4a27-8a60-9787c37faace	1ea221d5-ab36-4f62-b9fb-cef2797d6afd	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	1	2	PASSED	f	2026-10-12 11:20:46.059832+00	2026-10-12 11:20:48.860296+00	2805	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:35.189241+00	dev	2026-10-12 11:20:48.875242+00	anonymousUser	2	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d
8867ba0b-2f1f-49c4-ac20-c4e500b72cae	f4ad9909-4098-4234-af78-0adfd2259b8d	1a2db9af-540c-49e7-a550-a36d83de5897	1	1	PASSED	f	2026-10-12 11:20:46.05982+00	2026-10-12 11:20:48.928516+00	2873	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:35.189241+00	dev	2026-10-12 11:20:48.940689+00	anonymousUser	2	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d
04381ace-bcee-4a58-bb68-93dc837037ff	5429cb35-b135-435b-b137-b01abe779696	8e0688dc-30d0-46e8-9e21-177364442c35	1	1	PASSED	f	2026-10-12 11:20:46.059825+00	2026-10-12 11:20:49.309056+00	3254	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:35.189746+00	dev	2026-10-12 11:20:49.318634+00	anonymousUser	2	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d
a614f5e0-c4da-41a4-ae0d-f94637c90f5f	38cc6ee3-a8d1-47e1-9687-6f2a41b3de16	f71c33e3-115a-4a19-b096-39d80cedb8f7	1	1	FAILED	f	2026-10-12 11:20:46.059851+00	2026-10-12 11:20:51.90586+00	5850	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-a861f8e6/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:20:35.189746+00	dev	2026-10-12 11:20:51.919979+00	anonymousUser	2	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d
48f58d53-b7bd-496a-be31-7c4a7b2f09cf	d3b041cf-bf1e-4e71-8bdf-ec5bcc20dc3a	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	1	1	PASSED	f	2026-10-12 11:20:55.866759+00	2026-10-12 11:20:56.428759+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.432665+00	qa1	2026-10-12 11:20:56.432665+00	qa1	0	\N
e6881ec7-020d-4c93-aed2-779b9a8d6515	91200368-72d4-45f1-82dc-b245de3c40b1	bd6973a9-9e86-4ee3-8786-9960daeb68cd	1	1	PASSED	f	2026-10-12 11:20:52.913759+00	2026-10-12 11:20:56.428759+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.440587+00	qa1	2026-10-12 11:20:56.440587+00	qa1	0	\N
6817b927-9a3e-411f-a841-4dc8c0cc588f	1d064e36-b72a-45fc-817f-2e1fe421147f	f9a60afe-54fb-4703-88be-9f50a831554c	1	1	PASSED	f	2026-10-12 11:20:53.223759+00	2026-10-12 11:20:56.428759+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.447298+00	qa1	2026-10-12 11:20:56.447298+00	qa1	0	\N
1bfe3a24-390f-4cad-bbb4-ef1483f3d6eb	c31fe37b-fd20-4835-aec4-e98cd3c0339c	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	1	1	PASSED	f	2026-10-12 11:20:55.986759+00	2026-10-12 11:20:56.428759+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.453036+00	qa1	2026-10-12 11:20:56.453036+00	qa1	0	\N
d619c841-b94d-47b1-84eb-d5c2c45c2ddc	4f66a9e2-f3f4-4e2a-91de-cc58f955bdac	3b81aa15-d972-42e4-8516-34c5b92a71d9	1	1	PASSED	f	2026-10-12 11:20:55.891759+00	2026-10-12 11:20:56.428759+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.45927+00	qa1	2026-10-12 11:20:56.45927+00	qa1	0	\N
ad5c24aa-5e5c-4300-828d-0b35d34bcd66	5a3c1043-7984-4ac2-8522-24333afd5d6b	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	1	2	PASSED	f	2026-10-12 11:20:55.741759+00	2026-10-12 11:20:56.428759+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.464769+00	qa1	2026-10-12 11:20:56.464769+00	qa1	0	\N
4460d364-3b90-454d-acdb-aa615cf5dee6	cebbd87c-7458-4e80-ba38-88c2b636f5b0	1a2db9af-540c-49e7-a550-a36d83de5897	1	1	PASSED	f	2026-10-12 11:20:55.881759+00	2026-10-12 11:20:56.428759+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.470574+00	qa1	2026-10-12 11:20:56.470574+00	qa1	0	\N
b8639e7b-320c-4ad1-ae2b-64ad3c518e38	60146871-7e97-4ae2-b2a3-e2ba66c806e4	f71c33e3-115a-4a19-b096-39d80cedb8f7	1	1	FAILED	f	2026-10-12 11:20:52.960759+00	2026-10-12 11:20:56.428759+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.476937+00	qa1	2026-10-12 11:20:56.476937+00	qa1	0	\N
cc7897d8-4350-424b-ab1d-194553a516a2	d47a86af-cf0f-47a3-ab92-9a24ab85937d	8e0688dc-30d0-46e8-9e21-177364442c35	1	1	PASSED	f	2026-10-12 11:20:55.614759+00	2026-10-12 11:20:56.428759+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:20:56.482645+00	qa1	2026-10-12 11:20:56.482645+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0a646048-9682-43e1-b5b6-bd4c73100a29	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 11:19:47.105799+00	qa1	2026-10-12 11:19:47.105799+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c7e9f981-5c2b-460e-aa2d-9ed646aed87f	d4497379-ec02-4213-97ca-6935b03c9dbc	DEBRIEFED	60	2	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 11:20:32.804502+00	po	2026-10-12 11:20:33.523519+00	2026-10-12 11:20:29.936952+00	qa1	2026-10-12 11:20:33.525113+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 13:19:05.632626	192	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 13:19:05.917198	91	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 13:19:06.065669	305	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 13:19:06.389822	19	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 13:19:06.430562	15	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 13:19:06.466087	114	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 13:19:06.628384	81	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 13:19:06.734252	8	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 13:19:06.75264	7	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 13:19:06.769877	15	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 13:19:06.79536	29	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 13:19:06.836687	46	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 13:19:06.895418	14	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 13:19:06.92052	27	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 13:19:06.96165	28	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 13:19:07.004064	33	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 13:19:07.053874	14	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 13:19:07.078034	2	t
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
82caf026-6393-4635-81e1-836a58d86076	REQ	18
82caf026-6393-4635-81e1-836a58d86076	TC	14
82caf026-6393-4635-81e1-836a58d86076	REL	2
82caf026-6393-4635-81e1-836a58d86076	SPR	3
82caf026-6393-4635-81e1-836a58d86076	DEF	3
82caf026-6393-4635-81e1-836a58d86076	RUN	3
82caf026-6393-4635-81e1-836a58d86076	CMP	4
82caf026-6393-4635-81e1-836a58d86076	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
78229f98-8b36-428d-8722-e17e7e7812dc	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 11:19:43.829992+00	qa1	2026-10-12 11:19:43.829992+00	qa1	0	\N	{}	\N	\N
7b5933e6-acc0-4dfd-bfbc-ef36fe6c268e	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 11:19:43.831495+00	qa1	2026-10-12 11:19:43.831495+00	qa1	0	\N	{}	\N	\N
4c6fc491-1ec0-42f1-8712-6fe214aea72f	b9ac4984-1751-44e7-9cff-e32877e03756	1	\N	\N	\N	2026-10-12 11:19:43.976456+00	qa1	2026-10-12 11:19:43.976456+00	qa1	0	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	{}	Comptes	problem_user
406ccd87-af3f-4e43-8cf7-6e010a6d4d8e	b9ac4984-1751-44e7-9cff-e32877e03756	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 11:19:43.976456+00	qa1	2026-10-12 11:19:43.976456+00	qa1	0	\N	{}	\N	\N
3e47a82a-73ec-449a-8f8c-f0bd2b66b404	b9ac4984-1751-44e7-9cff-e32877e03756	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 11:19:43.976991+00	qa1	2026-10-12 11:19:43.976991+00	qa1	0	\N	{}	\N	\N
60ac40dc-c604-434b-b274-dec599db11b8	b9ac4984-1751-44e7-9cff-e32877e03756	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 11:19:43.976991+00	qa1	2026-10-12 11:19:43.976991+00	qa1	0	\N	{}	\N	\N
8734593d-65bd-4ef7-a920-4a5234dc8484	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	\N	\N	\N	2026-10-12 11:19:47.180821+00	qa1	2026-10-12 11:19:47.180821+00	qa1	0	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	{}	Comptes	standard_user
777eccc0-edad-45f8-87c8-4700e55d5b5c	d5685b03-4869-4d6d-9e64-fc67e7c97962	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 11:19:47.180821+00	qa1	2026-10-12 11:19:47.180821+00	qa1	0	\N	{}	\N	\N
3b4e176e-4403-4db9-ab81-a3c605a11325	d5685b03-4869-4d6d-9e64-fc67e7c97962	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 11:19:47.180821+00	qa1	2026-10-12 11:19:47.180821+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d63ee787-ea66-418d-a3aa-35fced027b50	2d6e793c-94b9-4541-9bc3-e2527c8f42d2	324	ms	p95Ms	TC-11	RUN-2	2026-10-12 11:20:49.309056+00	TARGET_MET	2026-10-12 11:20:49.333149+00	anonymousUser	2026-10-12 11:20:49.333149+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
2611f537-2e14-46f9-96d0-0ad14519d11f	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:00.570136+00
f3097474-ab89-4a0f-be0a-58bc8f68c697	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:10.939915+00
3a4e4303-fcd6-4e2f-b7d5-8664aeb36182	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:11.481596+00
d73727d7-c298-4e47-9c77-339f03fb7f81	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:11.481596+00
cf618ca1-0bd6-43b8-aca8-8603a9327c12	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:11.481596+00
eae4253b-0a7b-410c-b50d-d134535a88d0	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:14.124559+00
632ee5e2-f7aa-40fe-8a90-f07f003e7790	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:14.16906+00
1bdc14ee-c287-43a2-9514-5a29f2441144	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:14.200522+00
5143b5e9-2e85-4e8c-adc5-52b9abdafc89	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:14.47298+00
82323418-cb0f-4ef0-986c-70c069ec17f1	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:14.668674+00
e6bd484c-efe0-499e-89cd-c0078381d669	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:15.730258+00
8f14da1f-27d8-430c-95d3-21dc3b88f93f	45af275b-e2d9-4181-9cd2-7e06f161bf08	2026-10-12 11:20:15.761667+00
295e8985-e303-4883-9584-39a66e9761e7	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:35.236094+00
553d6e3a-57b4-4cd2-a299-78b5499a8693	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:46.068885+00
3e40b550-c221-48c6-b2af-0554b83a1070	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:46.591575+00
ecbdcf94-2f7b-4bb7-b734-7e857d1fc79c	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:46.591575+00
79d1050f-5880-4fd9-ab55-282e93136b17	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:46.591575+00
66faff25-74a0-47d4-a2d6-3a488a4f2aa3	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:48.870052+00
33695960-a974-4479-89cb-3e2ea8a81ec6	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:48.936462+00
dfbab433-9a43-4f91-9a60-602afe4f6e95	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:49.315772+00
16ba496f-a6a5-44e4-9c53-39b841eb3603	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:51.914244+00
39ce6711-9e4f-4274-b719-eb4df903085d	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	2026-10-12 11:20:51.941169+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9b441fd1-b10f-4de4-bd18-f0aa2b1b5662	82caf026-6393-4635-81e1-836a58d86076	fbc9faf8-66b7-47ce-bba8-2aec923cf3c5	ADMINISTRATOR	2026-10-12 11:19:27.832784+00	admin	2026-10-12 11:19:27.832784+00	admin	0
a486edf5-034a-45c8-b57b-cd1a355e7fb8	82caf026-6393-4635-81e1-836a58d86076	298277ee-918d-4cf0-9630-34c461a2db45	PRODUCT_OWNER	2026-10-12 11:19:27.832784+00	admin	2026-10-12 11:19:27.832784+00	admin	0
f78b32d5-7e1b-45ce-b8a8-fead1593d7f1	82caf026-6393-4635-81e1-836a58d86076	6aba21bf-14dd-41f7-9dce-0a38f9f97b01	TESTER	2026-10-12 11:19:27.832784+00	admin	2026-10-12 11:19:27.832784+00	admin	0
afc509f8-f462-4cd2-9786-0d46f1b10502	82caf026-6393-4635-81e1-836a58d86076	c214f6ca-5b72-41c0-ab02-10eb661a0ff6	TESTER	2026-10-12 11:19:27.833514+00	admin	2026-10-12 11:19:27.833514+00	admin	0
2cfa0e7a-8c5a-4b3f-b1c0-8e9b3297ab09	82caf026-6393-4635-81e1-836a58d86076	4d377e7c-c078-4bee-a427-7603c3a8731c	DEVELOPER	2026-10-12 11:19:27.833514+00	admin	2026-10-12 11:19:27.833514+00	admin	0
959d8b85-d916-44e1-8df2-7703a963eeb7	82caf026-6393-4635-81e1-836a58d86076	5d08cf7a-9133-4782-9e33-a4f036d9486c	VIEWER	2026-10-12 11:19:27.833514+00	admin	2026-10-12 11:19:27.833514+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
82caf026-6393-4635-81e1-836a58d86076	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 11:19:27.693316+00	admin	2026-10-12 11:19:27.693316+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1690358a-ac95-4fc3-a81e-0e0724492790	82caf026-6393-4635-81e1-836a58d86076	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 11:19:52.928321+00	po	2026-10-12 11:19:54.645493+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3132af75-729b-4bae-a362-fe2eda3f0ceb	82caf026-6393-4635-81e1-836a58d86076	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 11:20:20.721611+00	po	2026-10-12 11:20:20.721611+00	po	0
63ea3056-b852-419b-9bff-badac8086142	82caf026-6393-4635-81e1-836a58d86076	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 11:20:20.735123+00	po	2026-10-12 11:20:20.735123+00	po	0
6e72509f-14a7-4e53-a752-a010bb29cb6f	82caf026-6393-4635-81e1-836a58d86076	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 11:21:14.758162+00	po	2026-10-12 11:21:14.758162+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
21346c71-930c-4a59-b81e-b03f815d8355	82caf026-6393-4635-81e1-836a58d86076	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T11:20:20.776588400Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 11:20:20.915546+00	clôture du sprint	2026-10-12 11:20:20.912547+00	po	2026-10-12 11:20:20.919603+00	po	1
bdb1a31b-2373-4852-b8fe-c1f248b965a0	82caf026-6393-4635-81e1-836a58d86076	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T11:21:10.927883100Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 0, "averageMinutes": 0.0, "defectsPerHour": 1800.0, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 11:21:12.637201+00	f	\N	\N	2026-10-12 11:21:10.947272+00	po	2026-10-12 11:21:12.637201+00	po	2
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
b09cac4c-4885-41fd-826a-323d66e9bd0a	549b7819-9798-451f-a043-4827291f6a7d	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:34.865451+00	po	2026-10-12 11:19:34.865451+00	po	0
06a640b5-aedd-4eb9-a09b-50a8519c6d29	c763465d-0e53-4d68-9ba9-43cc442c47ec	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:34.913921+00	po	2026-10-12 11:19:34.913921+00	po	0
4dd24880-632a-4c1a-b590-95025f0e2805	9f9272a6-225c-49e4-ba76-3e22cf327afc	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:34.952374+00	po	2026-10-12 11:19:34.952374+00	po	0
f361557b-2beb-424a-aba3-99a23b90f301	8e881c76-aea1-451a-89ce-60626a0f35cd	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:34.990339+00	po	2026-10-12 11:19:34.990339+00	po	0
83f04068-2751-49bb-8cea-d96992eb9110	b04c7cfc-67e4-4f07-a577-af2526bf13e0	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:35.034905+00	po	2026-10-12 11:19:35.034905+00	po	0
0b21d27e-643f-49fc-be97-00586c95cd37	940845db-6a95-436f-85d9-048f8cb7f974	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:35.075646+00	po	2026-10-12 11:19:35.075646+00	po	0
7a9328ce-aa01-4b4e-bb37-2ceb40af1c9c	d77a002f-072f-47c7-a0e6-ad4e7594edfa	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:35.114277+00	po	2026-10-12 11:19:35.114277+00	po	0
11bbb672-dd95-4d93-bc33-596a1f32e948	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:19:36.365309+00	po	2026-10-12 11:19:36.365309+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7f257578-68b4-4194-bbff-820461e9d40a	82caf026-6393-4635-81e1-836a58d86076	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 11:19:31.05911+00	po	2026-10-12 11:19:31.05911+00	po	0
123c04d5-e852-4c0b-9af8-57208dbb997e	82caf026-6393-4635-81e1-836a58d86076	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 11:19:31.170337+00	po	2026-10-12 11:19:31.170337+00	po	0
262432e3-aa0f-40c3-9127-b9f5cab827c0	82caf026-6393-4635-81e1-836a58d86076	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 11:19:31.359242+00	po	2026-10-12 11:19:31.359242+00	po	0
8d6d2d8b-e9ad-4b68-8844-2e03de760306	82caf026-6393-4635-81e1-836a58d86076	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 11:19:31.556421+00	po	2026-10-12 11:19:31.556421+00	po	0
c763465d-0e53-4d68-9ba9-43cc442c47ec	82caf026-6393-4635-81e1-836a58d86076	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	123c04d5-e852-4c0b-9af8-57208dbb997e	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 11:19:31.309872+00	po	2026-10-12 11:20:17.857921+00	po	3
9f9272a6-225c-49e4-ba76-3e22cf327afc	82caf026-6393-4635-81e1-836a58d86076	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	262432e3-aa0f-40c3-9127-b9f5cab827c0	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 11:19:31.404823+00	po	2026-10-12 11:20:17.909543+00	po	3
d77a002f-072f-47c7-a0e6-ad4e7594edfa	82caf026-6393-4635-81e1-836a58d86076	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	8d6d2d8b-e9ad-4b68-8844-2e03de760306	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 11:19:31.644088+00	po	2026-10-12 11:20:22.198577+00	po	2
94194db9-ea1c-4f6f-9ebd-0ba91f149391	82caf026-6393-4635-81e1-836a58d86076	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	3b2b2e57-24ff-4d9f-939d-0dc9e3671970	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 11:19:31.774102+00	po	2026-10-12 11:19:31.774102+00	po	0
a9b3a4c6-e2ca-47d4-a994-3271f3799413	82caf026-6393-4635-81e1-836a58d86076	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	3b2b2e57-24ff-4d9f-939d-0dc9e3671970	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 11:19:33.544201+00	po	2026-10-12 11:19:33.544201+00	po	0
2d6e793c-94b9-4541-9bc3-e2527c8f42d2	82caf026-6393-4635-81e1-836a58d86076	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 11:19:33.804319+00	po	2026-10-12 11:19:33.804319+00	po	0
1d5135a2-567a-44e7-a20b-7b2a0b210ef9	82caf026-6393-4635-81e1-836a58d86076	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 11:19:33.84776+00	po	2026-10-12 11:19:33.84776+00	po	0
940845db-6a95-436f-85d9-048f8cb7f974	82caf026-6393-4635-81e1-836a58d86076	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	8d6d2d8b-e9ad-4b68-8844-2e03de760306	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 11:19:31.596505+00	po	2026-10-12 11:20:22.198577+00	po	2
549b7819-9798-451f-a043-4827291f6a7d	82caf026-6393-4635-81e1-836a58d86076	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	123c04d5-e852-4c0b-9af8-57208dbb997e	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 11:19:31.251607+00	po	2026-10-12 11:20:17.798721+00	po	3
65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	82caf026-6393-4635-81e1-836a58d86076	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	8d6d2d8b-e9ad-4b68-8844-2e03de760306	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 11:19:31.688475+00	po	2026-10-12 11:20:22.198577+00	po	2
3b2b2e57-24ff-4d9f-939d-0dc9e3671970	82caf026-6393-4635-81e1-836a58d86076	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	7f257578-68b4-4194-bbff-820461e9d40a	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 11:19:31.73233+00	po	2026-10-12 11:19:31.73233+00	po	0
8e881c76-aea1-451a-89ce-60626a0f35cd	82caf026-6393-4635-81e1-836a58d86076	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	262432e3-aa0f-40c3-9127-b9f5cab827c0	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 11:19:31.462382+00	po	2026-10-12 11:20:17.961262+00	po	3
b04c7cfc-67e4-4f07-a577-af2526bf13e0	82caf026-6393-4635-81e1-836a58d86076	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	262432e3-aa0f-40c3-9127-b9f5cab827c0	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 11:19:31.513838+00	po	2026-10-12 11:21:05.138134+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8e1fbe75-b4aa-4319-b603-6d457886b73d	45af275b-e2d9-4181-9cd2-7e06f161bf08	ebbd45b5-a09a-4032-99af-afb14f044f76	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 11:20:14.47663+00	anonymousUser	2026-10-12 11:20:14.47663+00	anonymousUser	0
1cafcd1c-d538-445b-bce4-d6dbf9d3a604	45af275b-e2d9-4181-9cd2-7e06f161bf08	08a7f986-7c17-4c61-a8bc-e36c2011114c	log-TC-4.txt	text/plain	SYSTEM_TRACE	392	2026-10-12 11:20:14.132007+00	anonymousUser	2026-10-12 11:20:14.132007+00	anonymousUser	0
c304c636-b3a5-48ac-b69a-6d43f2e5ab2e	45af275b-e2d9-4181-9cd2-7e06f161bf08	d504fa3e-d156-4bd7-a4b7-b55da22e410b	log-TC-6.txt	text/plain	SYSTEM_TRACE	468	2026-10-12 11:20:14.20503+00	anonymousUser	2026-10-12 11:20:14.20503+00	anonymousUser	0
8ab5381b-4fd8-4571-9e35-cdb2b16d141a	45af275b-e2d9-4181-9cd2-7e06f161bf08	adc0bf4e-efbf-46a2-8593-f222fbf7cccd	log-TC-5.txt	text/plain	SYSTEM_TRACE	390	2026-10-12 11:20:14.673157+00	anonymousUser	2026-10-12 11:20:14.673157+00	anonymousUser	0
bf0f27b2-9f87-41b1-af96-0a9ae10cb40d	45af275b-e2d9-4181-9cd2-7e06f161bf08	4b274d7c-1720-4aaa-8f97-72d17d1cb8b6	log-TC-7.txt	text/plain	SYSTEM_TRACE	395	2026-10-12 11:20:15.7342+00	anonymousUser	2026-10-12 11:20:15.7342+00	anonymousUser	0
fb32ff02-d025-4d6b-8576-24e5bb3e474e	45af275b-e2d9-4181-9cd2-7e06f161bf08	\N	system.log	text/plain	SYSTEM_TRACE	4725	2026-10-12 11:20:15.763674+00	anonymousUser	2026-10-12 11:20:15.763674+00	anonymousUser	0
64f1902f-c8f1-43d9-80d2-e6a40d5b1123	45af275b-e2d9-4181-9cd2-7e06f161bf08	\N	junit.xml	application/xml	JUNIT	1185	2026-10-12 11:20:15.769136+00	anonymousUser	2026-10-12 11:20:15.769136+00	anonymousUser	0
dfe6f680-f815-4cea-b726-6f745861090e	45af275b-e2d9-4181-9cd2-7e06f161bf08	\N	report.json	application/json	REPORT	484	2026-10-12 11:20:15.772956+00	anonymousUser	2026-10-12 11:20:15.772956+00	anonymousUser	0
2d2e24f9-d9a1-456f-be74-2e01e74c4c13	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	d50ed14a-5059-4a27-8a60-9787c37faace	log-TC-8.txt	text/plain	SYSTEM_TRACE	452	2026-10-12 11:20:48.874198+00	anonymousUser	2026-10-12 11:20:48.874198+00	anonymousUser	0
45ceee11-e1ad-4ad6-ad50-dcb7837177f6	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	8867ba0b-2f1f-49c4-ac20-c4e500b72cae	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 11:20:48.939583+00	anonymousUser	2026-10-12 11:20:48.939583+00	anonymousUser	0
7d59b3f0-0dcf-4292-a11a-278d2af59890	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	04381ace-bcee-4a58-bb68-93dc837037ff	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 11:20:49.317909+00	anonymousUser	2026-10-12 11:20:49.317909+00	anonymousUser	0
f215e2cd-8ccc-4984-9eb1-9ce94062299f	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	a614f5e0-c4da-41a4-ae0d-f94637c90f5f	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 11:20:51.91705+00	anonymousUser	2026-10-12 11:20:51.91705+00	anonymousUser	0
09b395f7-b768-4580-90ce-c0021ddee4be	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	a614f5e0-c4da-41a4-ae0d-f94637c90f5f	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 11:20:51.919979+00	anonymousUser	2026-10-12 11:20:51.919979+00	anonymousUser	0
2bb16ee8-238d-467f-b6f6-40a7bda56aff	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	\N	system.log	text/plain	SYSTEM_TRACE	8587	2026-10-12 11:20:51.943336+00	anonymousUser	2026-10-12 11:20:51.943336+00	anonymousUser	0
847c0865-045e-4e56-91dc-fadd1841c78b	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	\N	junit.xml	application/xml	JUNIT	1057	2026-10-12 11:20:51.945836+00	anonymousUser	2026-10-12 11:20:51.945836+00	anonymousUser	0
70f73df1-f91e-4196-bb60-697bdfb6f48f	19a48aba-fe9c-4d08-b58e-a0ccd7d4407d	\N	report.json	application/json	REPORT	475	2026-10-12 11:20:51.948224+00	anonymousUser	2026-10-12 11:20:51.948224+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8b487b55-574e-4e45-9d82-94c6352c3b91	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	NOTE	0	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 11:20:30.088781+00	\N	2026-10-12 11:20:30.090883+00	qa1	2026-10-12 11:20:30.090883+00	qa1	0
8ea34328-2601-4131-8566-b91a6a80b950	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	NOTE	0	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 11:20:30.207496+00	\N	2026-10-12 11:20:30.208035+00	qa1	2026-10-12 11:20:30.208035+00	qa1	0
c243eed7-bb67-4e15-b025-4073f070583b	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	QUESTION	0	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 11:20:30.406995+00	\N	2026-10-12 11:20:30.407514+00	qa1	2026-10-12 11:20:30.407514+00	qa1	0
6eb9c578-6314-45c4-be19-cfd4b76e9533	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	IDEA	0	Afficher le total du panier avant le checkout	2026-10-12 11:20:30.51592+00	\N	2026-10-12 11:20:30.51592+00	qa1	2026-10-12 11:20:30.51592+00	qa1	0
65825d62-6f69-42f6-b8b0-053c9f3aafb4	c7e9f981-5c2b-460e-aa2d-9ed646aed87f	BUG	0	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 11:20:30.307737+00	4ac29366-c47d-49a4-9602-7af48f905a93	2026-10-12 11:20:30.308268+00	qa1	2026-10-12 11:20:31.180292+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3c831f86-de15-4030-8396-e7f9cf2950a7	361d2eb6-c285-4bdb-9501-626ddbf3193b	549b7819-9798-451f-a043-4827291f6a7d	1	3	DONE	2026-10-12 11:19:53.731385+00	po	2026-10-12 11:20:20.726116+00	po	1
f650e849-a076-4889-9aad-74259b6922f4	361d2eb6-c285-4bdb-9501-626ddbf3193b	c763465d-0e53-4d68-9ba9-43cc442c47ec	2	2	DONE	2026-10-12 11:19:53.798933+00	po	2026-10-12 11:20:20.726116+00	po	1
fd27f2d0-ad60-4992-8eb3-e9711a79697f	361d2eb6-c285-4bdb-9501-626ddbf3193b	9f9272a6-225c-49e4-ba76-3e22cf327afc	3	3	DONE	2026-10-12 11:19:53.886179+00	po	2026-10-12 11:20:20.726116+00	po	1
34c03aee-0a72-4ad2-b4f6-e99cdb3e5eb8	361d2eb6-c285-4bdb-9501-626ddbf3193b	8e881c76-aea1-451a-89ce-60626a0f35cd	4	2	DONE	2026-10-12 11:19:53.946423+00	po	2026-10-12 11:20:20.726116+00	po	1
ed4fd5c1-f5aa-4281-9178-0e6c3b7756b0	361d2eb6-c285-4bdb-9501-626ddbf3193b	b04c7cfc-67e4-4f07-a577-af2526bf13e0	5	2	DONE	2026-10-12 11:19:54.045937+00	po	2026-10-12 11:20:20.726116+00	po	1
e94f24af-e116-47c2-916d-8cd4a24f2f75	8566cc15-1549-45ae-8e28-f6c48663b16c	940845db-6a95-436f-85d9-048f8cb7f974	1	3	PLANNED	2026-10-12 11:20:22.15012+00	po	2026-10-12 11:20:22.15012+00	po	0
68209eba-aa65-4a1d-91da-bf8bebad2270	8566cc15-1549-45ae-8e28-f6c48663b16c	d77a002f-072f-47c7-a0e6-ad4e7594edfa	2	3	PLANNED	2026-10-12 11:20:22.15012+00	po	2026-10-12 11:20:22.15012+00	po	0
20585544-162d-4e88-931b-865201277f93	8566cc15-1549-45ae-8e28-f6c48663b16c	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	3	2	PLANNED	2026-10-12 11:20:22.15012+00	po	2026-10-12 11:20:22.15012+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
361d2eb6-c285-4bdb-9501-626ddbf3193b	82caf026-6393-4635-81e1-836a58d86076	1690358a-ac95-4fc3-a81e-0e0724492790	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 11:19:52.965741+00	po	2026-10-12 11:20:20.725116+00	po	2
8566cc15-1549-45ae-8e28-f6c48663b16c	82caf026-6393-4635-81e1-836a58d86076	1690358a-ac95-4fc3-a81e-0e0724492790	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 11:19:53.019018+00	po	2026-10-12 11:20:22.198143+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
9d712fbc-97f2-4282-b75f-1b5f00112f3d	53932020-ba52-41b5-ae9d-eb3270b39ac0	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:19:57.798941+00	qa1	2026-10-12 11:19:58.063526+00	qa1	1	\N
809bb9e6-32c0-4bdb-ab69-21091a379118	53932020-ba52-41b5-ae9d-eb3270b39ac0	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:19:57.798941+00	qa1	2026-10-12 11:19:58.654554+00	qa1	1	\N
ee8c29cd-2d14-4ccb-9a86-2145ba6cd01d	96ab983d-2242-4738-84a6-a3b3b44aac40	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:19:58.730008+00	qa1	2026-10-12 11:19:58.750961+00	qa1	1	\N
a25bc4f1-c392-43e8-9e1c-d1de702d4a77	96ab983d-2242-4738-84a6-a3b3b44aac40	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 11:19:58.730526+00	qa1	2026-10-12 11:19:58.772078+00	qa1	1	\N
b48cd9e7-b42b-4391-81e4-3e0867440dd4	52dedcf2-04aa-402a-9d1e-e5d827cc13ae	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:19:58.789505+00	qa1	2026-10-12 11:19:58.807879+00	qa1	1	\N
b31ab19b-fbac-4f57-b91b-94e6ed121aba	52dedcf2-04aa-402a-9d1e-e5d827cc13ae	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:19:58.790174+00	qa1	2026-10-12 11:19:58.826606+00	qa1	1	\N
5847b5ac-9de2-4afe-a368-f434ef006f5b	618c415b-f66c-4e63-8a4d-73693ea28d8f	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:20:24.502997+00	qa2	2026-10-12 11:20:24.649298+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
874dd59d-7d48-40cb-8741-4c2aa58f6126	618c415b-f66c-4e63-8a4d-73693ea28d8f	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:20:24.502997+00	qa2	2026-10-12 11:20:24.785575+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
fc72498c-948e-474c-9998-dd5f12a2c649	618c415b-f66c-4e63-8a4d-73693ea28d8f	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:20:24.502997+00	qa2	2026-10-12 11:20:24.887015+00	qa2	1	\N
2e284da3-efd0-4ec0-8433-c72022513029	618c415b-f66c-4e63-8a4d-73693ea28d8f	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 11:20:24.502997+00	qa2	2026-10-12 11:20:24.987362+00	qa2	1	\N
6190f7a5-6437-44d0-9c8c-fb0a86c5181d	618c415b-f66c-4e63-8a4d-73693ea28d8f	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 11:20:24.502997+00	qa2	2026-10-12 11:20:25.353342+00	qa2	1	\N
789c5c75-abca-4d15-808d-6f5b6ca042f3	e10ed829-0057-42c7-84c2-d5e5497ba0fd	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:20:27.643468+00	qa1	2026-10-12 11:20:27.817989+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
b4d2be13-8308-4a53-a14e-107904d7c778	e10ed829-0057-42c7-84c2-d5e5497ba0fd	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:20:27.643468+00	qa1	2026-10-12 11:20:28.416285+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
f1e50f6c-3ff1-4bf3-8ca7-9cf2bfc93087	e10ed829-0057-42c7-84c2-d5e5497ba0fd	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:20:27.643468+00	qa1	2026-10-12 11:20:28.534786+00	qa1	1	\N
4466e06b-5790-4b8a-9d2b-1d41e883305a	e10ed829-0057-42c7-84c2-d5e5497ba0fd	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 11:20:27.643468+00	qa1	2026-10-12 11:20:28.635185+00	qa1	1	\N
6d30efc4-3922-4b76-8367-66696b1ff756	958f6bbd-941b-400d-86bf-eb7a3afc4791	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:20:28.704322+00	qa1	2026-10-12 11:20:28.724683+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
76e1c69b-d811-40de-85ca-0378a547fe22	958f6bbd-941b-400d-86bf-eb7a3afc4791	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:20:28.704322+00	qa1	2026-10-12 11:20:28.74505+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
dcf54946-868c-45b6-9b1a-4b9cc7e3f57a	958f6bbd-941b-400d-86bf-eb7a3afc4791	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:20:28.704322+00	qa1	2026-10-12 11:20:28.762486+00	qa1	1	\N
fa86cf0e-9900-43ab-ad9b-b293e1ee6a16	958f6bbd-941b-400d-86bf-eb7a3afc4791	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 11:20:28.704322+00	qa1	2026-10-12 11:20:28.780277+00	qa1	1	\N
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
73151634-705e-4fe0-a562-6c3f9cc14e71	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 11:19:43.836496+00	qa1	2026-10-12 11:19:43.836496+00	qa1	0
e8e9f1e0-437f-486e-8f47-ce47e172d013	b9ac4984-1751-44e7-9cff-e32877e03756	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 11:19:43.979633+00	qa1	2026-10-12 11:19:43.979633+00	qa1	0
3c42a0ea-bee8-4631-b20d-4e0e758278a4	bd6973a9-9e86-4ee3-8786-9960daeb68cd	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "installation-hors-docker", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:44.066361+00	dev	2026-10-12 11:19:44.066361+00	dev	0
ffe31dec-a4e4-425f-bd2c-9d9b55992288	f9a60afe-54fb-4703-88be-9f50a831554c	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:44.139335+00	dev	2026-10-12 11:19:44.139335+00	dev	0
f95a1618-c7f8-4704-9dd2-83356c2de669	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:44.209734+00	dev	2026-10-12 11:19:44.209734+00	dev	0
41ea02b0-05cf-47e1-aca0-ddfe4684a973	3b81aa15-d972-42e4-8516-34c5b92a71d9	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:44.275922+00	dev	2026-10-12 11:19:44.275922+00	dev	0
1f67837f-e7d3-4777-a87c-b3ca379813e7	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "installation-hors-docker", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:44.346657+00	dev	2026-10-12 11:19:44.346657+00	dev	0
f5fbd841-1d82-4417-befd-7e99b5b5c2a3	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:45.784683+00	qa1	2026-10-12 11:19:45.784683+00	qa1	0
92349139-404b-40ca-a2de-f5f229eeb103	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "installation-hors-docker", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:45.918161+00	qa1	2026-10-12 11:19:45.918161+00	qa1	0
e1b52d3b-ca16-4bea-bec0-a8f0a71d7c38	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 11:19:47.10633+00	qa1	2026-10-12 11:19:47.10633+00	qa1	0
d8a0a94b-ddd3-46c9-8a7a-b74293e1b4bd	1a2db9af-540c-49e7-a550-a36d83de5897	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:46.914787+00	dev	2026-10-12 11:19:46.914787+00	dev	0
a90f6b89-d610-48c9-955a-72853fb9f15e	f71c33e3-115a-4a19-b096-39d80cedb8f7	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:46.980376+00	dev	2026-10-12 11:19:46.980376+00	dev	0
b96f7979-ff78-44c8-92ca-41459aa7fc0e	8e0688dc-30d0-46e8-9e21-177364442c35	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "installation-hors-docker", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:19:47.04311+00	dev	2026-10-12 11:19:47.04311+00	dev	0
4acd8e71-b5fb-4cc5-b35d-4d42f5cd7dd6	d5685b03-4869-4d6d-9e64-fc67e7c97962	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 11:19:47.181342+00	qa1	2026-10-12 11:19:47.181342+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
e2e83ce2-043f-4aef-8ca1-f4170a3461f5	82caf026-6393-4635-81e1-836a58d86076	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 11:19:43.822479+00	qa1	2026-10-12 11:19:43.938861+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
b9ac4984-1751-44e7-9cff-e32877e03756	82caf026-6393-4635-81e1-836a58d86076	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 11:19:43.975906+00	qa1	2026-10-12 11:19:44.027952+00	qa1	1	[]	[]	f
bd6973a9-9e86-4ee3-8786-9960daeb68cd	82caf026-6393-4635-81e1-836a58d86076	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 11:19:44.062185+00	dev	2026-10-12 11:19:44.107949+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
f9a60afe-54fb-4703-88be-9f50a831554c	82caf026-6393-4635-81e1-836a58d86076	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 11:19:44.13882+00	dev	2026-10-12 11:19:44.177787+00	qa1	1	[]	[]	f
3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	82caf026-6393-4635-81e1-836a58d86076	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 11:19:44.209212+00	dev	2026-10-12 11:19:44.244541+00	qa1	1	[]	[]	f
9661c6f6-cbc1-4efe-af6d-2bdf708caafc	82caf026-6393-4635-81e1-836a58d86076	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 11:19:44.346153+00	dev	2026-10-12 11:19:44.389817+00	qa1	1	[]	[]	f
f71c33e3-115a-4a19-b096-39d80cedb8f7	82caf026-6393-4635-81e1-836a58d86076	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 11:19:46.979856+00	dev	2026-10-12 11:19:47.014642+00	qa1	1	[]	[]	f
b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	82caf026-6393-4635-81e1-836a58d86076	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 11:19:45.784147+00	qa1	2026-10-12 11:19:45.930227+00	qa1	2	[]	[]	f
1a2db9af-540c-49e7-a550-a36d83de5897	82caf026-6393-4635-81e1-836a58d86076	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 11:19:46.913724+00	dev	2026-10-12 11:19:46.951183+00	qa1	1	[]	[]	f
8e0688dc-30d0-46e8-9e21-177364442c35	82caf026-6393-4635-81e1-836a58d86076	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 11:19:47.042605+00	dev	2026-10-12 11:19:47.076773+00	qa1	1	[]	[]	f
24d5f978-f6f9-47ee-a5da-af78d7dabcb3	82caf026-6393-4635-81e1-836a58d86076	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 11:19:47.102198+00	qa1	2026-10-12 11:19:47.151269+00	qa1	1	[]	[]	f
d5685b03-4869-4d6d-9e64-fc67e7c97962	82caf026-6393-4635-81e1-836a58d86076	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 11:19:47.179735+00	qa1	2026-10-12 11:19:47.228208+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
3b81aa15-d972-42e4-8516-34c5b92a71d9	82caf026-6393-4635-81e1-836a58d86076	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 11:19:44.275221+00	dev	2026-10-12 11:21:05.147189+00	po	2	[]	[]	f
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
e4653bd6-e115-48f0-9ba1-2653450aee3b	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	VERIFIES	MANUAL	2026-10-12 11:19:43.85595+00	qa1	2026-10-12 11:19:43.85595+00	qa1	0	\N
afd42386-cb4d-40ac-9f2a-7b302d18f924	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	e2e83ce2-043f-4aef-8ca1-f4170a3461f5	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	VERIFIES	MANUAL	2026-10-12 11:19:43.856528+00	qa1	2026-10-12 11:19:43.856528+00	qa1	0	\N
10d9434d-96ee-4e7d-9568-6579ce0dc963	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b9ac4984-1751-44e7-9cff-e32877e03756	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	PARTIALLY_VERIFIES	MANUAL	2026-10-12 11:19:43.986078+00	qa1	2026-10-12 11:19:43.986078+00	qa1	0	\N
466922d2-f5dd-4e6a-8045-894fe703422d	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b9ac4984-1751-44e7-9cff-e32877e03756	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	VERIFIES	MANUAL	2026-10-12 11:19:43.98662+00	qa1	2026-10-12 11:19:43.98662+00	qa1	0	\N
2a765443-4051-41ae-bd92-c5201af3115b	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	bd6973a9-9e86-4ee3-8786-9960daeb68cd	REQUIREMENT	549b7819-9798-451f-a043-4827291f6a7d	VERIFIES	MANUAL	2026-10-12 11:19:44.072218+00	dev	2026-10-12 11:19:44.072218+00	dev	0	\N
1c845c8c-c7b5-41c6-bbf4-df1d6db5ea82	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	bd6973a9-9e86-4ee3-8786-9960daeb68cd	REQUIREMENT	c763465d-0e53-4d68-9ba9-43cc442c47ec	VERIFIES	MANUAL	2026-10-12 11:19:44.072753+00	dev	2026-10-12 11:19:44.072753+00	dev	0	\N
dbdba9f0-17e6-48a9-b907-7693f06531cf	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f9a60afe-54fb-4703-88be-9f50a831554c	REQUIREMENT	9f9272a6-225c-49e4-ba76-3e22cf327afc	VERIFIES	MANUAL	2026-10-12 11:19:44.142987+00	dev	2026-10-12 11:19:44.142987+00	dev	0	\N
31e6d2d7-e9fd-47fc-8952-6c21ca996b8d	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3a99b0cf-3d14-4dfc-8d9d-eb04758c1e28	REQUIREMENT	8e881c76-aea1-451a-89ce-60626a0f35cd	VERIFIES	MANUAL	2026-10-12 11:19:44.212864+00	dev	2026-10-12 11:19:44.212864+00	dev	0	\N
e2e75107-41ca-4343-bdc4-f8dec66d4444	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	9661c6f6-cbc1-4efe-af6d-2bdf708caafc	REQUIREMENT	1d5135a2-567a-44e7-a20b-7b2a0b210ef9	VERIFIES	MANUAL	2026-10-12 11:19:44.351167+00	dev	2026-10-12 11:19:44.351167+00	dev	0	\N
cc48e9f9-15fe-4014-96cd-57ad4189d10e	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	REQUIREMENT	940845db-6a95-436f-85d9-048f8cb7f974	VERIFIES	GHERKIN_TAG	2026-10-12 11:19:45.792988+00	qa1	2026-10-12 11:19:45.792988+00	qa1	0	\N
c823fdce-2783-46ac-8e20-0171e79651db	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	b8c6e545-6c96-4104-9ed4-f5ab02cfbbbe	ACCEPTANCE_CRITERION	2581da30-7926-4c8d-8138-6ee51ea45952	VERIFIES	GHERKIN_TAG	2026-10-12 11:19:45.80197+00	qa1	2026-10-12 11:19:45.80197+00	qa1	0	\N
b89b9a79-94dc-49a6-a6b2-7c8e2fd3c6f7	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	1a2db9af-540c-49e7-a550-a36d83de5897	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	VERIFIES	MANUAL	2026-10-12 11:19:46.918182+00	dev	2026-10-12 11:19:46.918182+00	dev	0	\N
47c4ba83-0b03-4f79-822e-47ed347872f8	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	f71c33e3-115a-4a19-b096-39d80cedb8f7	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	VERIFIES	MANUAL	2026-10-12 11:19:46.98345+00	dev	2026-10-12 11:19:46.98345+00	dev	0	\N
2c7c9d2c-82a9-4e74-9a0a-491dd01163d0	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	8e0688dc-30d0-46e8-9e21-177364442c35	REQUIREMENT	2d6e793c-94b9-4541-9bc3-e2527c8f42d2	VERIFIES	MANUAL	2026-10-12 11:19:47.045748+00	dev	2026-10-12 11:19:47.045748+00	dev	0	\N
9b588312-05fa-4b11-91d2-c9fa5765c6e7	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	VERIFIES	MANUAL	2026-10-12 11:19:47.111332+00	qa1	2026-10-12 11:19:47.111332+00	qa1	0	\N
a8cf1ef3-8d58-4a71-83fb-34f7b91e39ca	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	24d5f978-f6f9-47ee-a5da-af78d7dabcb3	REQUIREMENT	65358ad4-4ac6-4b88-8eaf-5d8ecadfb744	VERIFIES	MANUAL	2026-10-12 11:19:47.111332+00	qa1	2026-10-12 11:19:47.111332+00	qa1	0	\N
9def786e-23a0-499b-a8e9-39c56ff143c7	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	d5685b03-4869-4d6d-9e64-fc67e7c97962	REQUIREMENT	d77a002f-072f-47c7-a0e6-ad4e7594edfa	VERIFIES	MANUAL	2026-10-12 11:19:47.184531+00	qa1	2026-10-12 11:19:47.184531+00	qa1	0	\N
ecb8a2ec-ec00-46f5-a3d1-7a9406a59f3d	82caf026-6393-4635-81e1-836a58d86076	TEST_CASE	3b81aa15-d972-42e4-8516-34c5b92a71d9	REQUIREMENT	b04c7cfc-67e4-4f07-a577-af2526bf13e0	VERIFIES	MANUAL	2026-10-12 11:19:44.280205+00	dev	2026-10-12 11:21:05.846948+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
fbc9faf8-66b7-47ce-bba8-2aec923cf3c5	admin	admin@traceagile.local	Administrateur	$2a$12$FyYLMZPGPjzPCUJiRCaLYu0ADaPT6MdkTvGXB5oemB2K2YTIejRyi	t	t	2026-10-12 11:19:14.768153+00	system	2026-10-12 11:19:14.768153+00	system	0
298277ee-918d-4cf0-9630-34c461a2db45	po	po@traceagile.demo	Paula Owner	$2a$12$KIYo/cklSaDGQmBU36Qg0.pDgHXTZ8eicqIIGST/plsbwVLj0kfFG	t	f	2026-10-12 11:19:25.563605+00	admin	2026-10-12 11:19:25.563605+00	admin	0
6aba21bf-14dd-41f7-9dce-0a38f9f97b01	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$RLP/IjnqorjN0iFc8k/qqu858uCxBKOm0Ej/.kvRMpTBVKqeMisxe	t	f	2026-10-12 11:19:25.788469+00	admin	2026-10-12 11:19:25.788469+00	admin	0
c214f6ca-5b72-41c0-ab02-10eb661a0ff6	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$hO9bukCJSQAFBQvN1umSl.FCVBGrMfWh8KEEr7GUiLe5jqMj1D1M.	t	f	2026-10-12 11:19:26.009867+00	admin	2026-10-12 11:19:26.009867+00	admin	0
4d377e7c-c078-4bee-a427-7603c3a8731c	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$RyFCSfgU8150EEkKMlzq8.9HuLmhTEj.rbSdHWWDPJgP8eCwog2Ji	t	f	2026-10-12 11:19:26.229057+00	admin	2026-10-12 11:19:26.229057+00	admin	0
5d08cf7a-9133-4782-9e33-a4f036d9486c	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$GGaRkC5.qtYf.0Y.qghnG./EDM6Rsk4XvVdhLEFJJkxm44lJq9HoW	t	f	2026-10-12 11:19:26.450779+00	admin	2026-10-12 11:19:26.450779+00	admin	0
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
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "flyway_schema_history_s_idx" ON "public"."flyway_schema_history" USING "btree" ("success");


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


