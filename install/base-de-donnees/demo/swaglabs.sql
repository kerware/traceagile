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
7cc7631d-9e50-45ce-8145-925ed20b5190	8210bc1c-4b21-416b-a550-de9cc2505f0c	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 11:43:47.114064+00	po	2026-10-12 11:43:47.114064+00	po	0
9e9eee7e-8156-415c-8f02-f7eb1e89c9e0	8210bc1c-4b21-416b-a550-de9cc2505f0c	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 11:43:47.114064+00	po	2026-10-12 11:43:47.114064+00	po	0
120d9c89-b717-47aa-9671-eaa2a5b5e04d	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 11:43:47.156073+00	po	2026-10-12 11:43:47.156073+00	po	0
f430c35f-09f6-4ae0-b09e-5952896ef912	2217e2d2-dcba-41ca-a719-f4ad66722a97	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 11:43:47.232432+00	po	2026-10-12 11:43:47.232432+00	po	0
541f4c8f-75d5-4c6a-835f-96d89ce12ba5	bc64631e-be55-47c4-945c-6daa40bc79e5	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 11:43:47.268563+00	po	2026-10-12 11:43:47.268563+00	po	0
264a2da7-c116-4276-b9f8-56eba1963737	94c7fd05-9d4c-445f-a104-c60b10d3a230	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 11:43:47.305182+00	po	2026-10-12 11:43:47.305182+00	po	0
4e7e065e-a286-4518-8439-dab18d8de20a	a121518a-c7e1-4c20-bc62-c4824e698c30	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 11:43:47.370398+00	po	2026-10-12 11:43:47.370398+00	po	0
e4515b7b-c457-4ddd-a059-68c94ea7be46	a121518a-c7e1-4c20-bc62-c4824e698c30	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 11:43:47.370398+00	po	2026-10-12 11:43:47.370398+00	po	0
a5844759-cbcf-46d7-a7de-1a1f9d4f90ae	a8c8c836-d7a0-40e3-8c87-d228acb7a333	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 11:43:47.40438+00	po	2026-10-12 11:43:47.40438+00	po	0
486c3448-e9c7-4f74-bcbb-a9eaa90c2719	a8c8c836-d7a0-40e3-8c87-d228acb7a333	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 11:43:47.40438+00	po	2026-10-12 11:43:47.40438+00	po	0
d3ec29cd-d999-4e20-a253-7d7bdcd1b095	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 11:43:47.440346+00	po	2026-10-12 11:43:47.440346+00	po	0
ea6f84cc-2d5a-49e1-81c5-9e1a1205cea1	598f46e0-8e8b-43ba-81eb-700faf744841	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 11:43:47.501323+00	po	2026-10-12 11:43:47.501323+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
95232df7-41b6-4ad8-ab6e-16a2bc63c9f1	658d0618-1de6-4155-bdd0-48b1c6dedaac	EXECUTION_STEP	f4098cab-d7b2-4d27-a4a7-d7a002da21f1	sd-defaut-problem-user.png	image/png	235120	2d7abe45-be4b-468b-abc8-cb47a8070aa8	2026-10-12 11:44:31.906695+00	qa2	2026-10-12 11:44:31.906695+00	qa2	0
0a916f99-01bf-4d32-91e3-f7856579c132	658d0618-1de6-4155-bdd0-48b1c6dedaac	DEFECT	e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	sd-defaut-problem-user.png	image/png	235120	2d7abe45-be4b-468b-abc8-cb47a8070aa8	2026-10-12 11:44:33.444298+00	qa2	2026-10-12 11:44:33.444298+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
22a8ec67-92c5-4cc9-a3f4-c33787fc000b	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	8a19c9b1-3e78-424c-9080-32435a0983b0	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:46.985628+00	po	2026-10-12 11:43:46.985628+00	po	0
a32de661-2772-4698-b032-0d1b1b2c9385	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	2d10675b-ecf5-44a3-bc38-f6d9dec8bc62	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:47.051587+00	po	2026-10-12 11:43:47.051587+00	po	0
77b1b7be-57d7-4daa-9407-7623b2480833	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.114064+00	po	2026-10-12 11:43:47.114064+00	po	0
15823798-c1b7-44c9-8b3c-f530b0e7cd56	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.156073+00	po	2026-10-12 11:43:47.156073+00	po	0
35246ca7-cd24-4384-b241-5e855a2f9ed8	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	1c0558dc-a490-4552-b0c6-fb8aa0763119	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:47.195804+00	po	2026-10-12 11:43:47.195804+00	po	0
13015403-26a7-4063-a53e-1e96ca432a44	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	2217e2d2-dcba-41ca-a719-f4ad66722a97	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.232969+00	po	2026-10-12 11:43:47.232969+00	po	0
237f90ca-e4f2-4d84-b279-ffb369390ef9	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	bc64631e-be55-47c4-945c-6daa40bc79e5	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.269079+00	po	2026-10-12 11:43:47.269079+00	po	0
3ef9156f-8a83-41fa-ba3d-915210477df2	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:51.474133+00	po	2026-10-12 11:43:51.474133+00	po	0
34fe6980-781b-4014-adc1-6d751448915a	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:44:27.379792+00	po	2026-10-12 11:44:27.379792+00	po	0
15574cff-2a44-4863-8256-8ff55c51e7e6	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 11:44:28.202097+00	po	2026-10-12 11:44:28.202097+00	po	0
db2b04ee-5e58-48fd-b857-4233d747bbd8	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a121518a-c7e1-4c20-bc62-c4824e698c30	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:28.951984+00	po	2026-10-12 11:44:28.951984+00	po	0
8cd0462b-2526-4a14-b757-f58762fac897	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.305182+00	po	2026-10-12 11:43:47.305182+00	po	0
cd15a130-a8b4-4517-a02f-5cb86c9090b3	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	46ca823c-5360-4acd-90af-e8aa37dd0fae	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:47.339121+00	po	2026-10-12 11:43:47.339121+00	po	0
1c61fa06-6a67-4553-a7a6-36d6c1e96b7f	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.404962+00	po	2026-10-12 11:43:47.404962+00	po	0
128c71bf-b0d5-4212-af28-df3cc556deb8	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	5a3e7645-5840-487c-b349-7bdc79a2a054	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:47.472084+00	po	2026-10-12 11:43:47.472084+00	po	0
29d1976e-7364-4797-89d2-74af337ecdac	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	598f46e0-8e8b-43ba-81eb-700faf744841	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.501896+00	po	2026-10-12 11:43:47.501896+00	po	0
ce692aaf-3549-4f1d-9817-16b75f151d7d	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	67c287c2-6293-47f3-85fb-a1c518557d8b	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:49.205666+00	po	2026-10-12 11:43:49.205666+00	po	0
bf35f712-c4fc-47ea-97be-b0aa3c24aaa0	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	050bcbbc-6ff8-4a42-b656-8da5ab4d023d	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:49.480777+00	po	2026-10-12 11:43:49.480777+00	po	0
5dee37a2-ae47-4a7f-b8ac-92abd350bd29	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	2217e2d2-dcba-41ca-a719-f4ad66722a97	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.360941+00	po	2026-10-12 11:43:50.360941+00	po	0
de29c7f6-7df8-469d-8f89-3015163c17df	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	bc64631e-be55-47c4-945c-6daa40bc79e5	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.39149+00	po	2026-10-12 11:43:50.39149+00	po	0
e1496bc6-6b96-467e-8636-f637e67617cc	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a121518a-c7e1-4c20-bc62-c4824e698c30	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.453901+00	po	2026-10-12 11:43:50.453901+00	po	0
c033302f-d2bd-427d-9725-48f361e76ea6	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a121518a-c7e1-4c20-bc62-c4824e698c30	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.370398+00	po	2026-10-12 11:43:47.370398+00	po	0
17821c1d-008d-45ca-b9cc-a00e2393af35	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 11:43:47.440346+00	po	2026-10-12 11:43:47.440346+00	po	0
2d65f1eb-672f-490e-9d48-322928b219dc	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	0aeee68e-00ea-41ad-8f2e-d2779eac99d0	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 11:43:49.448763+00	po	2026-10-12 11:43:49.448763+00	po	0
9d5117eb-d16e-4af5-b2ce-c4c5d989248a	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.288555+00	po	2026-10-12 11:43:50.288555+00	po	0
bba45add-10c1-4483-b8cb-69d738a79669	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.326663+00	po	2026-10-12 11:43:50.326663+00	po	0
e2888d42-3b46-42b8-81e7-43b23ebc2af7	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.42183+00	po	2026-10-12 11:43:50.42183+00	po	0
78a17b19-c6de-466a-ba3c-54838d250e99	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:50.48646+00	po	2026-10-12 11:43:50.48646+00	po	0
6b594307-aad4-461d-a6df-56b77fc26f72	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2f547331-6326-4644-b351-b879ede01bf0	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 11:43:57.674646+00	qa1	2026-10-12 11:43:57.674646+00	qa1	0
a6e68705-e32e-48bf-972c-2574a671fcbc	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2f547331-6326-4644-b351-b879ede01bf0	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:57.734189+00	qa1	2026-10-12 11:43:57.734189+00	qa1	0
4d782f46-2e51-458a-8c32-0e984b9ff7ac	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	784b6b08-703b-47d4-9a01-1726c31ae483	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:57.883639+00	qa1	2026-10-12 11:43:57.883639+00	qa1	0
83a43e13-0695-4f34-b605-8a0e9592cf22	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	5946baab-664a-4474-a55e-1416fce4c67b	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:57.997772+00	qa1	2026-10-12 11:43:57.997772+00	qa1	0
2fb235be-13a5-4070-acd2-0f6c35541dfc	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	f4009358-0ebe-4b1b-97ed-43cd24235157	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:44:00.436071+00	qa1	2026-10-12 11:44:00.436071+00	qa1	0
9467c9b5-8773-4ccd-b6aa-c346ccfdfa70	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 11:44:06.415678+00	po	2026-10-12 11:44:06.415678+00	po	0
3be69bba-8036-4d11-a4c9-5e301994d2c6	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	2e7bc820-a669-4650-bb78-fa5d08fe8332	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 11:44:08.718424+00	qa1	2026-10-12 11:44:08.718424+00	qa1	0
e5822073-3e00-4d79-8948-0b9de46fb818	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	21c73ffd-f8b4-424c-8130-8076ee38e849	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 11:43:57.772533+00	qa1	2026-10-12 11:43:57.772533+00	qa1	0
0429f4e2-df54-4d45-9059-a4851878b264	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	21c73ffd-f8b4-424c-8130-8076ee38e849	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:57.809619+00	qa1	2026-10-12 11:43:57.809619+00	qa1	0
349b4349-27b5-42c0-927d-2ed9138555b0	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	d0f99a45-390a-4287-82f7-f95ff69894ff	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:43:58.084416+00	dev	2026-10-12 11:43:58.084416+00	dev	0
28655b5b-f89c-4a62-805d-abf78523828a	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	d0f99a45-390a-4287-82f7-f95ff69894ff	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:58.110687+00	qa1	2026-10-12 11:43:58.110687+00	qa1	0
147398c7-c150-4a84-aa64-071a31155143	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	f4009358-0ebe-4b1b-97ed-43cd24235157	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:44:00.406521+00	dev	2026-10-12 11:44:00.406521+00	dev	0
58caedd1-a686-4e68-a386-41d3c0284299	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2c8fca63-ebd3-491e-8eac-cdc263d9704f	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:44:00.657988+00	qa1	2026-10-12 11:44:00.657988+00	qa1	0
ee47e25e-0be1-4656-99c0-462d9db4e07b	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 11:44:06.268143+00	po	2026-10-12 11:44:06.268143+00	po	0
ab0bee9e-3d77-4bf7-a3a0-42304d9ddc5b	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 11:44:06.341763+00	po	2026-10-12 11:44:06.341763+00	po	0
d021ab9c-34cd-47b5-8bd2-61a0c71f7fa5	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	2e7bc820-a669-4650-bb78-fa5d08fe8332	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 11:44:08.497751+00	qa1	2026-10-12 11:44:08.497751+00	qa1	0
a14db830-9f13-46dd-9416-aba5fc02473a	658d0618-1de6-4155-bdd0-48b1c6dedaac	RUN	cdaf7d74-493c-4c4e-bb55-9f9b153de933	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 11:44:11.806459+00	dev	2026-10-12 11:44:11.806459+00	dev	0
c0652739-5f25-4897-beec-b1280003060c	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:44:25.794669+00	po	2026-10-12 11:44:25.794669+00	po	0
ec0eea35-2952-436c-9099-9f935ef287cf	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	62f13039-c762-4a00-9b9d-347bd3bbe080	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 11:44:30.062739+00	qa1	2026-10-12 11:44:30.062739+00	qa1	0
f4fdf4be-1e63-41e6-b9e8-e9144a863e42	658d0618-1de6-4155-bdd0-48b1c6dedaac	SESSION	eb295c74-1a5f-47d9-b6f2-06177a500bd9	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 11:44:36.015254+00	qa1	2026-10-12 11:44:36.015254+00	qa1	0
8db76189-ab04-4947-982a-767b2b2d9870	658d0618-1de6-4155-bdd0-48b1c6dedaac	SESSION	eb295c74-1a5f-47d9-b6f2-06177a500bd9	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 11:44:39.68635+00	po	2026-10-12 11:44:39.68635+00	po	0
e4c5b1e2-d7d6-4a8d-85ef-b81b771b8996	658d0618-1de6-4155-bdd0-48b1c6dedaac	RUN	267429aa-1eb0-445c-86b6-bc3774110554	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 11:44:41.36704+00	dev	2026-10-12 11:44:41.36704+00	dev	0
c7e3150d-71f5-4700-ae5a-addff321f293	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	784b6b08-703b-47d4-9a01-1726c31ae483	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 11:43:57.847569+00	dev	2026-10-12 11:43:57.847569+00	dev	0
4d71ab91-8929-4798-81e9-503062d32176	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	5946baab-664a-4474-a55e-1416fce4c67b	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:43:57.971241+00	dev	2026-10-12 11:43:57.971241+00	dev	0
74be949b-edbd-4fb8-94e9-ab010d8f790b	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	867dda4b-4eea-4539-a4e0-676f182775ae	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 11:43:59.571459+00	qa1	2026-10-12 11:43:59.571459+00	qa1	0
c03c30c4-f16f-44a3-9f0e-e60f16d12f22	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:44:00.462664+00	dev	2026-10-12 11:44:00.462664+00	dev	0
3207686f-fc4e-4dcc-b989-6937997e6fd4	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2c8fca63-ebd3-491e-8eac-cdc263d9704f	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 11:44:00.625341+00	qa1	2026-10-12 11:44:00.625341+00	qa1	0
a00a7f14-a6f9-4e52-849b-1b6a33825cc0	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:07.035586+00	po	2026-10-12 11:44:07.035586+00	po	0
0ac28dcc-b4a2-4926-9dc6-76e1c7876bed	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:07.036286+00	po	2026-10-12 11:44:07.036286+00	po	0
1c8dc01b-a9c6-4186-95bb-40dfa854c19c	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	2217e2d2-dcba-41ca-a719-f4ad66722a97	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:07.036286+00	po	2026-10-12 11:44:07.036286+00	po	0
aab43ecc-1658-4743-9d9a-f1d10a9b7843	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	bc64631e-be55-47c4-945c-6daa40bc79e5	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:07.036286+00	po	2026-10-12 11:44:07.036286+00	po	0
5404f5cd-5f3d-4a2a-84b4-8959e2593dd1	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:07.036841+00	po	2026-10-12 11:44:07.036841+00	po	0
a89c500d-ba5c-4e0e-b231-0f860aab6949	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 11:44:07.036841+00	po	2026-10-12 11:44:07.036841+00	po	0
cbc017ab-4ed3-4beb-9fd0-7de5d82610a8	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	2e7bc820-a669-4650-bb78-fa5d08fe8332	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:44:08.238113+00	qa1	2026-10-12 11:44:08.238113+00	qa1	0
8ad36c9a-6617-4d0c-bd56-84b88aa69a6a	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 11:43:57.916422+00	dev	2026-10-12 11:43:57.916422+00	dev	0
6c8319a6-82cc-4876-8f89-cec28b71e33b	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:57.943349+00	qa1	2026-10-12 11:43:57.943349+00	qa1	0
0a7bc56c-e455-4579-b4bb-f5a9407ab0f2	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	daefb4fb-e381-482a-b586-27387d59a018	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:58.055247+00	qa1	2026-10-12 11:43:58.055247+00	qa1	0
3fa22dd1-4343-4891-a280-5b03083aaf94	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	867dda4b-4eea-4539-a4e0-676f182775ae	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:43:59.535519+00	qa1	2026-10-12 11:43:59.535519+00	qa1	0
60d9e6a4-b88a-4131-9f87-ab6bf6cd756c	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:44:00.489098+00	qa1	2026-10-12 11:44:00.489098+00	qa1	0
7c0bf76a-2fcf-4169-a7e7-2bde846b349d	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	b28e7635-3121-4882-9f2f-c104b3f78180	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:44:00.542591+00	qa1	2026-10-12 11:44:00.542591+00	qa1	0
918579cb-d167-4b42-bb03-509e27dd9574	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	23a05279-c105-47be-9768-25d4fa9f0222	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 11:44:00.569618+00	qa1	2026-10-12 11:44:00.569618+00	qa1	0
5d33fdee-585b-42cf-8073-7969b62adc19	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	23a05279-c105-47be-9768-25d4fa9f0222	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 11:44:00.596239+00	qa1	2026-10-12 11:44:00.596239+00	qa1	0
0394aee6-9f77-4053-bae3-bf3c6f9da165	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 11:44:05.469947+00	po	2026-10-12 11:44:05.469947+00	po	0
53ca2e55-5fae-4926-9a67-b2f5bae541a7	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 11:44:06.476979+00	po	2026-10-12 11:44:06.476979+00	po	0
6fd90715-b743-410b-99e6-5239c506d200	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	2e7bc820-a669-4650-bb78-fa5d08fe8332	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 11:44:25.717832+00	qa1	2026-10-12 11:44:25.717832+00	qa1	0
f285bf21-bf7a-4442-83d1-35a1c2a6e5a1	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	2217e2d2-dcba-41ca-a719-f4ad66722a97	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:44:25.884821+00	po	2026-10-12 11:44:25.884821+00	po	0
29093017-64ea-47de-a97f-5d857c36f482	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	bc64631e-be55-47c4-945c-6daa40bc79e5	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:44:25.920768+00	po	2026-10-12 11:44:25.920768+00	po	0
8da38916-4d58-4fd5-a9db-8f07e336a077	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	000159d6-f57d-4e3c-977a-bb6235a1b98c	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 11:44:28.913218+00	po	2026-10-12 11:44:28.913218+00	po	0
282775ea-698c-432f-9731-d5f26539c44f	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	62f13039-c762-4a00-9b9d-347bd3bbe080	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 11:44:30.08425+00	qa1	2026-10-12 11:44:30.08425+00	qa1	0
ce95d984-1455-4b1f-98c8-618b0ccdd01e	658d0618-1de6-4155-bdd0-48b1c6dedaac	DEFECT	a85cb532-42d3-4abf-af20-bb988ba74beb	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 11:44:37.34191+00	qa1	2026-10-12 11:44:37.34191+00	qa1	0
55439308-a067-451b-a979-79099d51cd4f	658d0618-1de6-4155-bdd0-48b1c6dedaac	SESSION	eb295c74-1a5f-47d9-b6f2-06177a500bd9	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 11:44:39.064937+00	qa1	2026-10-12 11:44:39.064937+00	qa1	0
7dc724f0-5caf-4c7a-8dbe-3c66332df58b	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	daefb4fb-e381-482a-b586-27387d59a018	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:43:58.027818+00	dev	2026-10-12 11:43:58.027818+00	dev	0
fec732ab-1b19-41ea-822b-eed695b94881	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	867dda4b-4eea-4539-a4e0-676f182775ae	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 11:43:59.341491+00	qa1	2026-10-12 11:43:59.341491+00	qa1	0
7abed4a8-b743-4442-ace7-b716f5e7fc49	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	b28e7635-3121-4882-9f2f-c104b3f78180	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 11:44:00.516608+00	dev	2026-10-12 11:44:00.516608+00	dev	0
14250f22-8748-4288-9de5-6cfe91b5c8cf	658d0618-1de6-4155-bdd0-48b1c6dedaac	RELEASE	33a70e93-d363-4916-8dd7-1d88b245f0c5	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 11:44:05.44207+00	po	2026-10-12 11:44:05.44207+00	po	0
c2cc2ed5-6935-48c5-a022-20c9c8dc61db	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	000159d6-f57d-4e3c-977a-bb6235a1b98c	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 11:44:05.510397+00	po	2026-10-12 11:44:05.510397+00	po	0
55aa8df2-207e-406f-895c-89491158cb77	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 11:44:06.190882+00	po	2026-10-12 11:44:06.190882+00	po	0
7f6bbf5a-2588-4bea-add8-babfb7c45cdf	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 11:44:25.842643+00	po	2026-10-12 11:44:25.842643+00	po	0
a018ab99-b5ea-4190-a61b-1758e8b48d1c	658d0618-1de6-4155-bdd0-48b1c6dedaac	SESSION	eb295c74-1a5f-47d9-b6f2-06177a500bd9	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 11:44:38.617532+00	qa1	2026-10-12 11:44:38.617532+00	qa1	0
7a5a5dfb-0cd9-4aac-a919-051ab836c318	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:28.952513+00	po	2026-10-12 11:44:28.952513+00	po	0
c733299c-63db-4600-83e9-24a5da0cabe0	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 11:44:28.952513+00	po	2026-10-12 11:44:28.952513+00	po	0
0cbffe03-5725-4a40-b00f-1c63d2a544ff	658d0618-1de6-4155-bdd0-48b1c6dedaac	SPRINT	000159d6-f57d-4e3c-977a-bb6235a1b98c	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 11:44:28.952513+00	po	2026-10-12 11:44:28.952513+00	po	0
fce8bbd0-309a-4773-a5f1-31795f1f63e1	658d0618-1de6-4155-bdd0-48b1c6dedaac	DEFECT	e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 11:44:33.440085+00	qa2	2026-10-12 11:44:33.440085+00	qa2	0
b8a9f99a-79df-4280-b81e-f9fd48e7fbc5	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	62f13039-c762-4a00-9b9d-347bd3bbe080	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:44:30.03138+00	qa1	2026-10-12 11:44:30.03138+00	qa1	0
7430675f-06cc-4619-a35e-622b7f850ad6	658d0618-1de6-4155-bdd0-48b1c6dedaac	CAMPAIGN	701c64e2-df23-4415-8136-6dd1768ef02f	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 11:44:57.099629+00	qa1	2026-10-12 11:44:57.099629+00	qa1	0
2cba3ce8-ab7b-4ebe-90c4-55b66cbd37e6	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 11:45:06.275965+00	po	2026-10-12 11:45:06.275965+00	po	0
6960d24a-332c-4193-ae5a-c0d277b56131	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	daefb4fb-e381-482a-b586-27387d59a018	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 11:45:06.283824+00	po	2026-10-12 11:45:06.283824+00	po	0
f5690226-d148-4fda-a496-303d136d3233	658d0618-1de6-4155-bdd0-48b1c6dedaac	TRACE_LINK	f3ac7797-5637-431e-ad9c-fbd0141abd08	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 11:45:06.940099+00	qa1	2026-10-12 11:45:06.940099+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
cdaf7d74-493c-4c4e-bb55-9f9b153de933	658d0618-1de6-4155-bdd0-48b1c6dedaac	RUN-1	1	2e7bc820-a669-4650-bb78-fa5d08fe8332	eeeb5b54-7a2a-43e0-85d5-5ed943bb00da	COMPLETED	dev	2026-10-12 11:44:11.802272+00	2026-10-12 11:44:11.844212+00	2026-10-12 11:44:11.841066+00	2026-10-12 11:44:23.871854+00	2026-10-12 11:44:23.871854+00	recette	1.0.0-s1	job-cc0b8741	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-cc0b8741/logs	http://localhost:8091/api/v1/jobs/job-cc0b8741/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 11:44:11.805424+00	dev	2026-10-12 11:44:23.891259+00	anonymousUser	10
267429aa-1eb0-445c-86b6-bc3774110554	658d0618-1de6-4155-bdd0-48b1c6dedaac	RUN-2	2	62f13039-c762-4a00-9b9d-347bd3bbe080	eeeb5b54-7a2a-43e0-85d5-5ed943bb00da	COMPLETED	dev	2026-10-12 11:44:41.365186+00	2026-10-12 11:44:41.404242+00	2026-10-12 11:44:41.403106+00	2026-10-12 11:44:54.094344+00	2026-10-12 11:44:54.094344+00	recette	1.0.0-s2	job-f04eddf6	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-f04eddf6/logs	http://localhost:8091/api/v1/jobs/job-f04eddf6/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 11:44:41.366513+00	dev	2026-10-12 11:44:54.105401+00	anonymousUser	9
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1a505c67-e6dc-45f0-817f-64084b6fb523	784b6b08-703b-47d4-9a01-1726c31ae483	DATA_DRIVEN	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 11:43:57.841718+00	dev	2026-10-12 11:43:57.841718+00	dev	0
4e5a79e4-2011-4556-bff9-8b0ccea7e005	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:43:57.912654+00	dev	2026-10-12 11:43:57.912654+00	dev	0
69938351-f060-4e03-abb5-72bbfd747163	5946baab-664a-4474-a55e-1416fce4c67b	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:43:57.967981+00	dev	2026-10-12 11:43:57.967981+00	dev	0
12708d28-7425-4722-b292-5ca59f3590f3	daefb4fb-e381-482a-b586-27387d59a018	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:43:58.02434+00	dev	2026-10-12 11:43:58.02434+00	dev	0
d1725438-aaee-4fc1-b060-3989756c7663	d0f99a45-390a-4287-82f7-f95ff69894ff	API	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:43:58.080955+00	dev	2026-10-12 11:43:58.080955+00	dev	0
4e690fb1-fce0-43f1-84e3-9c8bacfc3817	867dda4b-4eea-4539-a4e0-676f182775ae	BDD	Playwright	\N	file:///depots/traceagile	installation-hors-docker	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 11:43:59.327765+00	qa1	2026-10-12 11:43:59.571966+00	qa1	1
3efcd481-558e-494f-a14a-c8508f57493e	f4009358-0ebe-4b1b-97ed-43cd24235157	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 11:44:00.403781+00	dev	2026-10-12 11:44:00.403781+00	dev	0
3c68a4d4-d773-48a7-b1a6-7cd8dae1faee	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 11:44:00.459913+00	dev	2026-10-12 11:44:00.459913+00	dev	0
73cadfa5-6c5b-420b-8f08-969b31598709	b28e7635-3121-4882-9f2f-c104b3f78180	PERFORMANCE	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 11:44:00.513506+00	dev	2026-10-12 11:44:00.513506+00	dev	0
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d65fdfa1-3129-4e10-8d05-28b2c4bba5fe	BDD	Cucumber-JVM	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
4a3368cd-0e21-4147-82bc-d576a7481192	BDD	Cucumber-JS	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
8bbdcc64-e4b6-4f10-b935-832465a865f7	BDD	Behave	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
fb30bfac-6b53-4563-86ea-126bf8d8f94d	BDD	SpecFlow	4	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
af6a97f2-0630-42d5-9161-57403ce1fc45	BDD	Karate	5	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
4a8e23fa-dbca-43fe-9ded-3fb6d4744ac3	UNIT	JUnit 5	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
4a0b5c47-ad5d-440c-897a-01b0154a0cfa	UNIT	Kotest	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
eb60211a-98c8-4be5-bfb6-f39509a2bfba	UNIT	pytest	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
b0bade51-9a46-485c-a0e7-e8bcc0a6d689	UNIT	Jest	4	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
2e8c42ca-97de-45a4-b06e-8549b7afe78d	UNIT	Vitest	5	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
53f11eb9-db87-4794-b2c7-658d51d4b76c	UI	Playwright	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
acbe16a0-6c4c-4ce3-960c-a4526aac02f5	UI	Selenium	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
ba5ad557-0848-419b-993d-3d16599d616a	UI	Cypress	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
f3f185e4-0ced-4aaa-82b0-a3b53069456a	UI	Appium	4	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
bf1563bc-0195-4eee-a9a8-177c024e7e54	API	REST Assured	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
98167bda-1bf4-450d-b656-a31d7648f4ad	API	Karate	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
4cf31e07-e2f1-4896-ae05-6fa393d4d9a1	API	Postman/Newman	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
f203d146-fd5c-4fbc-850d-80529b8878a1	API	pytest + requests	4	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
86be039d-5ee9-4432-bbd9-0157ecb019e3	KEYWORD	Robot Framework	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
e2e1468b-f98c-4171-8a41-6de6cbe168c4	DATA_DRIVEN	JUnit 5	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
3183ce61-5c63-41da-8001-bfeef8575537	DATA_DRIVEN	pytest	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
d59f6688-ec58-45c2-8c38-0663d1be90a7	DATA_DRIVEN	Playwright	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
a048192f-6cfa-4b37-bd3b-9379cb019799	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
ee6d9e44-4edc-4b47-b4e8-3041305f3733	PERFORMANCE	Gatling	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
37f65b31-62aa-4dd0-aafe-b38d81f5d474	PERFORMANCE	k6	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
5b98026d-d99b-4d29-8788-6fbd68f5594c	PERFORMANCE	JMeter	3	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
6a4582fd-0325-4367-ba75-42c1f2f6f93b	CONTRACT	Pact	1	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
89464d3e-4577-470f-80e8-327065b7f83d	CONTRACT	Spring Cloud Contract	2	2026-10-12 11:43:29.878065+00	system	2026-10-12 11:43:29.878065+00	system	0
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
ee03909a-67ab-4b59-b02a-3c2cbee4d189	2e7bc820-a669-4650-bb78-fa5d08fe8332	784b6b08-703b-47d4-9a01-1726c31ae483	1	\N	4	12	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.487278+00	qa1	0	\N	\N
f10b7bed-9cda-4924-bf88-6083702bbc5f	2e7bc820-a669-4650-bb78-fa5d08fe8332	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	1	\N	5	6	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.487278+00	qa1	0	\N	\N
200d8099-c763-43dd-a7f7-6869dc357441	2e7bc820-a669-4650-bb78-fa5d08fe8332	5946baab-664a-4474-a55e-1416fce4c67b	1	\N	6	3	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.487278+00	qa1	0	\N	\N
02de012a-7fc2-4af9-ad25-e9278d6f0543	2e7bc820-a669-4650-bb78-fa5d08fe8332	daefb4fb-e381-482a-b586-27387d59a018	1	\N	7	3	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.487278+00	qa1	0	\N	\N
107b6f40-3e54-4372-b77b-b0cde1a15c5a	2e7bc820-a669-4650-bb78-fa5d08fe8332	d0f99a45-390a-4287-82f7-f95ff69894ff	1	\N	8	6	2026-10-12 11:44:08.716274+00	qa1	2026-10-12 11:44:08.716274+00	qa1	0	\N	\N
0511f0a3-2210-4bb9-8d27-3991e3d1462b	2e7bc820-a669-4650-bb78-fa5d08fe8332	2f547331-6326-4644-b351-b879ede01bf0	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	1	16	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.754904+00	qa1	1	Comptes	0
5bf956d1-8b64-4ad0-9a22-4fa670fcf816	2e7bc820-a669-4650-bb78-fa5d08fe8332	2f547331-6326-4644-b351-b879ede01bf0	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	2	16	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.779627+00	qa1	1	Comptes	1
c41b0e61-d472-4716-ac71-fd95cdec411f	2e7bc820-a669-4650-bb78-fa5d08fe8332	2f547331-6326-4644-b351-b879ede01bf0	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	3	16	2026-10-12 11:44:08.487278+00	qa1	2026-10-12 11:44:08.797161+00	qa1	1	Comptes	2
7e97cdc6-58dc-4fd6-acae-13fa9d05df41	62f13039-c762-4a00-9b9d-347bd3bbe080	867dda4b-4eea-4539-a4e0-676f182775ae	2	\N	3	12	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.058285+00	qa1	0	\N	\N
00e8ca42-61a3-45e9-9678-38e784831e09	62f13039-c762-4a00-9b9d-347bd3bbe080	f4009358-0ebe-4b1b-97ed-43cd24235157	1	\N	4	12	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.058285+00	qa1	0	\N	\N
af8b2a24-0780-49c5-9549-ffd7fbb3843a	62f13039-c762-4a00-9b9d-347bd3bbe080	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	1	\N	7	6	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.058285+00	qa1	0	\N	\N
e2f9d633-3f38-4084-8300-1b9bcbfe69df	62f13039-c762-4a00-9b9d-347bd3bbe080	b28e7635-3121-4882-9f2f-c104b3f78180	1	\N	8	6	2026-10-12 11:44:30.082567+00	qa1	2026-10-12 11:44:30.082567+00	qa1	0	\N	\N
49aa837b-2c43-4d08-a656-851717bfca07	62f13039-c762-4a00-9b9d-347bd3bbe080	21c73ffd-f8b4-424c-8130-8076ee38e849	1	6944f490-8e8f-45c7-b5d6-8d4831abe911	1	16	2026-10-12 11:44:30.057677+00	qa1	2026-10-12 11:44:30.114901+00	qa1	1	\N	\N
5cac0255-6b62-41d8-bc02-afbdf1f813cc	62f13039-c762-4a00-9b9d-347bd3bbe080	23a05279-c105-47be-9768-25d4fa9f0222	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	2	16	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.130593+00	qa1	1	\N	\N
c3fe2fa2-746b-4ca6-b71f-942837ae1b5c	62f13039-c762-4a00-9b9d-347bd3bbe080	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	5	12	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.145383+00	qa1	1	Produits	0
06742fe2-5295-48c0-93b1-63f45ae9b3e5	62f13039-c762-4a00-9b9d-347bd3bbe080	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	91875ec1-5ed3-4313-a299-02eaaf1c6654	6	12	2026-10-12 11:44:30.058285+00	qa1	2026-10-12 11:44:30.160586+00	qa1	1	Produits	1
85d872ed-0db5-4c61-9ea9-e389490be5ef	701c64e2-df23-4415-8136-6dd1768ef02f	d0f99a45-390a-4287-82f7-f95ff69894ff	1	\N	1	0	2026-10-12 11:44:58.352498+00	qa1	2026-10-12 11:44:58.352498+00	qa1	0	\N	\N
4f34cd9d-9d33-444f-a52b-91579c655207	701c64e2-df23-4415-8136-6dd1768ef02f	784b6b08-703b-47d4-9a01-1726c31ae483	1	\N	2	0	2026-10-12 11:44:58.359586+00	qa1	2026-10-12 11:44:58.359586+00	qa1	0	\N	\N
37cb94b3-350a-4d06-8deb-d0daf511cc25	701c64e2-df23-4415-8136-6dd1768ef02f	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	1	\N	3	0	2026-10-12 11:44:58.364447+00	qa1	2026-10-12 11:44:58.364447+00	qa1	0	\N	\N
d85435ee-69f4-474c-9064-21a96d97dd64	701c64e2-df23-4415-8136-6dd1768ef02f	5946baab-664a-4474-a55e-1416fce4c67b	1	\N	4	0	2026-10-12 11:44:58.369951+00	qa1	2026-10-12 11:44:58.369951+00	qa1	0	\N	\N
fdb333f2-f6d3-4e8d-b060-cfca99359f67	701c64e2-df23-4415-8136-6dd1768ef02f	daefb4fb-e381-482a-b586-27387d59a018	1	\N	5	0	2026-10-12 11:44:58.374578+00	qa1	2026-10-12 11:44:58.374578+00	qa1	0	\N	\N
5499e146-ee67-4e60-b309-18aa04cf6888	701c64e2-df23-4415-8136-6dd1768ef02f	867dda4b-4eea-4539-a4e0-676f182775ae	2	\N	6	0	2026-10-12 11:44:58.380107+00	qa1	2026-10-12 11:44:58.380107+00	qa1	0	\N	\N
c9b84513-9668-4bea-bef4-afe291ef0cab	701c64e2-df23-4415-8136-6dd1768ef02f	f4009358-0ebe-4b1b-97ed-43cd24235157	1	\N	7	0	2026-10-12 11:44:58.385968+00	qa1	2026-10-12 11:44:58.385968+00	qa1	0	\N	\N
8a332c5e-0528-45ff-b13e-8b9079beed87	701c64e2-df23-4415-8136-6dd1768ef02f	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	1	\N	8	0	2026-10-12 11:44:58.389999+00	qa1	2026-10-12 11:44:58.389999+00	qa1	0	\N	\N
e3029566-d58f-4b8f-9317-5efce2d90e27	701c64e2-df23-4415-8136-6dd1768ef02f	b28e7635-3121-4882-9f2f-c104b3f78180	1	\N	9	0	2026-10-12 11:44:58.39513+00	qa1	2026-10-12 11:44:58.39513+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
2e7bc820-a669-4650-bb78-fa5d08fe8332	658d0618-1de6-4155-bdd0-48b1c6dedaac	CMP-1	1	Recette sprint 1	SPRINT	c0413527-4ece-4bbc-a9bd-16d6221cc828	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 11:44:08.236994+00	qa1	2026-10-12 11:44:25.717832+00	qa1	3	Release 1.0/Recettes de sprint
62f13039-c762-4a00-9b9d-347bd3bbe080	658d0618-1de6-4155-bdd0-48b1c6dedaac	CMP-2	2	Recette sprint 2	SPRINT	000159d6-f57d-4e3c-977a-bb6235a1b98c	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 11:44:30.03138+00	qa1	2026-10-12 11:44:31.11041+00	qa2	2	Release 1.0/Recettes de sprint
701c64e2-df23-4415-8136-6dd1768ef02f	658d0618-1de6-4155-bdd0-48b1c6dedaac	CMP-3	3	Intégration continue — main	RELEASE	\N	33a70e93-d363-4916-8dd7-1d88b245f0c5	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 11:44:57.099629+00	qa1	2026-10-12 11:44:58.355258+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
984e694c-57dd-4faf-9697-b51ba11f044e	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 11:43:44.083777+00	admin	2026-10-12 11:43:44.083777+00	admin	0
381744c0-d208-40fd-ba94-aedef9234fe0	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 11:43:44.084306+00	admin	2026-10-12 11:43:44.084306+00	admin	0
3ee4edd9-2a32-4227-a26b-c9c42e5eb709	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 11:43:44.084306+00	admin	2026-10-12 11:43:44.084306+00	admin	0
e20c04ff-8175-4c7b-ad46-851a222ff901	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 11:43:44.084306+00	admin	2026-10-12 11:43:44.084306+00	admin	0
edbf9a0a-7037-4b78-8668-cf813d0980b6	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 11:43:44.084824+00	admin	2026-10-12 11:43:44.084824+00	admin	0
4f2563d4-74ab-45ac-a54b-a22ca046a02e	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 11:43:44.084824+00	admin	2026-10-12 11:43:44.084824+00	admin	0
8ca446c7-d861-48d9-8847-b2274bacf2ad	658d0618-1de6-4155-bdd0-48b1c6dedaac	DOD	4	Code revu et intégré	\N	2026-10-12 11:43:44.084824+00	admin	2026-10-12 11:43:44.084824+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
40bee083-69ce-4c77-b65c-27c07538ae25	598f46e0-8e8b-43ba-81eb-700faf744841	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 11:43:54.196666+00	po	2026-10-12 11:43:54.196666+00	po	0
5ccc6e20-5382-4386-b589-84ad4dadfb29	a8c8c836-d7a0-40e3-8c87-d228acb7a333	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 11:43:55.080101+00	po	2026-10-12 11:43:55.080101+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	4f968034-a7e7-4fbf-8f68-a4d118d7dc61
a85cb532-42d3-4abf-af20-bb988ba74beb	e0984119-d2b5-461a-aaa4-36f26eee6541
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	a8c8c836-d7a0-40e3-8c87-d228acb7a333
e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	4170fd8a-bc8c-4ac3-b654-91e361bc8af3
a85cb532-42d3-4abf-af20-bb988ba74beb	a8c8c836-d7a0-40e3-8c87-d228acb7a333
a85cb532-42d3-4abf-af20-bb988ba74beb	4170fd8a-bc8c-4ac3-b654-91e361bc8af3
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e6632bbd-0a62-4b4c-98b1-eadaeeab5c3c	658d0618-1de6-4155-bdd0-48b1c6dedaac	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 11:44:33.43956+00	qa2	2026-10-12 11:44:33.444846+00	qa2	1
a85cb532-42d3-4abf-af20-bb988ba74beb	658d0618-1de6-4155-bdd0-48b1c6dedaac	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 11:44:37.34191+00	qa1	2026-10-12 11:44:37.344047+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7494db29-3b70-47c1-8b3e-13b4ab745f75	598f46e0-8e8b-43ba-81eb-700faf744841	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 11:43:53.834516+00	po	2026-10-12 11:43:53.834516+00	po	0
d06e39fa-80a9-4d2a-acd3-cb8206650d28	598f46e0-8e8b-43ba-81eb-700faf744841	EXAMPLE	7494db29-3b70-47c1-8b3e-13b4ab745f75	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 11:43:53.948887+00	po	2026-10-12 11:43:53.948887+00	po	0
a6ee4724-be69-455e-a2a9-3e2a56b3312c	598f46e0-8e8b-43ba-81eb-700faf744841	EXAMPLE	7494db29-3b70-47c1-8b3e-13b4ab745f75	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 11:43:54.001892+00	po	2026-10-12 11:43:54.001892+00	po	0
6b29588b-38b4-43a4-a3c1-850894f41401	598f46e0-8e8b-43ba-81eb-700faf744841	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 11:43:54.061574+00	po	2026-10-12 11:43:54.061574+00	po	0
9ef733c3-33a6-40ef-9eb2-2c75c3c86d9e	598f46e0-8e8b-43ba-81eb-700faf744841	EXAMPLE	6b29588b-38b4-43a4-a3c1-850894f41401	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 11:43:54.130263+00	po	2026-10-12 11:43:54.130263+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
eeeb5b54-7a2a-43e0-85d5-5ed943bb00da	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Playwright", "Cucumber-JS"]	[]	4	t	2026-10-12 11:43:45.462127+00	admin	2026-10-12 11:44:54.027757+00	system	3
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
b972df79-becd-4930-9598-de0af9e3cece	0511f0a3-2210-4bb9-8d27-3991e3d1462b	2f547331-6326-4644-b351-b879ede01bf0	1	1	PASSED	f	2026-10-12 11:44:09.631472+00	2026-10-12 11:44:10.346915+00	715	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 11:44:09.636044+00	qa1	2026-10-12 11:44:10.347989+00	qa1	1	\N
f268e96a-aae0-4d03-b117-d41a556e8698	5bf956d1-8b64-4ad0-9a22-4fa670fcf816	2f547331-6326-4644-b351-b879ede01bf0	1	1	PASSED	f	2026-10-12 11:44:10.385587+00	2026-10-12 11:44:10.42253+00	36	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 11:44:10.388184+00	qa1	2026-10-12 11:44:10.423048+00	qa1	1	\N
519f3480-e891-4333-a2f5-42fb3e2f319f	c41b0e61-d472-4716-ac71-fd95cdec411f	2f547331-6326-4644-b351-b879ede01bf0	1	1	PASSED	f	2026-10-12 11:44:10.437826+00	2026-10-12 11:44:10.470666+00	32	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 11:44:10.439915+00	qa1	2026-10-12 11:44:10.47117+00	qa1	1	\N
5947b26a-8897-4891-a543-6227c84e86ed	107b6f40-3e54-4372-b77b-b0cde1a15c5a	d0f99a45-390a-4287-82f7-f95ff69894ff	1	1	PASSED	f	2026-10-12 11:44:19.996976+00	2026-10-12 11:44:22.226511+00	2229	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:11.805942+00	dev	2026-10-12 11:44:22.244091+00	anonymousUser	2	cdaf7d74-493c-4c4e-bb55-9f9b153de933
212ddcaf-a0b4-490e-b3c5-216d369f28f9	200d8099-c763-43dd-a7f7-6869dc357441	5946baab-664a-4474-a55e-1416fce4c67b	1	1	PASSED	f	2026-10-12 11:44:19.996923+00	2026-10-12 11:44:22.607267+00	2609	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:11.805942+00	dev	2026-10-12 11:44:22.620751+00	anonymousUser	2	cdaf7d74-493c-4c4e-bb55-9f9b153de933
3db9552f-dc55-486e-ad52-787979cacf02	f10b7bed-9cda-4924-bf88-6083702bbc5f	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	1	1	PASSED	f	2026-10-12 11:44:19.996915+00	2026-10-12 11:44:22.641202+00	2643	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:11.805942+00	dev	2026-10-12 11:44:22.654496+00	anonymousUser	2	cdaf7d74-493c-4c4e-bb55-9f9b153de933
c387f099-6fa6-44e3-83e0-ee4f27a959ec	ee03909a-67ab-4b59-b02a-3c2cbee4d189	784b6b08-703b-47d4-9a01-1726c31ae483	1	1	PASSED	f	2026-10-12 11:44:19.996957+00	2026-10-12 11:44:22.959477+00	2961	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:11.805942+00	dev	2026-10-12 11:44:22.97119+00	anonymousUser	2	cdaf7d74-493c-4c4e-bb55-9f9b153de933
5000f1ee-0477-468a-9bb0-6146defcb06b	02de012a-7fc2-4af9-ad25-e9278d6f0543	daefb4fb-e381-482a-b586-27387d59a018	1	1	PASSED	f	2026-10-12 11:44:22.262454+00	2026-10-12 11:44:23.848568+00	1585	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:11.805942+00	dev	2026-10-12 11:44:23.85884+00	anonymousUser	2	cdaf7d74-493c-4c4e-bb55-9f9b153de933
4f968034-a7e7-4fbf-8f68-a4d118d7dc61	49aa837b-2c43-4d08-a656-851717bfca07	21c73ffd-f8b4-424c-8130-8076ee38e849	1	1	FAILED	f	2026-10-12 11:44:31.099188+00	2026-10-12 11:44:31.995162+00	895	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.99627+00	qa2	1	\N
a02bcc20-c559-4469-b039-dc762cf696e7	c3fe2fa2-746b-4ca6-b71f-942837ae1b5c	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	1	PASSED	f	2026-10-12 11:44:34.000887+00	2026-10-12 11:44:34.982533+00	981	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 11:44:34.00454+00	qa1	2026-10-12 11:44:34.98357+00	qa1	1	\N
6860bff4-ffa7-4be5-84dd-78249977b9df	06742fe2-5295-48c0-93b1-63f45ae9b3e5	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	1	PASSED	f	2026-10-12 11:44:35.03266+00	2026-10-12 11:44:35.094424+00	61	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 11:44:35.035297+00	qa1	2026-10-12 11:44:35.094961+00	qa1	1	\N
e0984119-d2b5-461a-aaa4-36f26eee6541	5cac0255-6b62-41d8-bc02-afbdf1f813cc	23a05279-c105-47be-9768-25d4fa9f0222	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 11:44:36.014205+00	qa1	2026-10-12 11:44:38.618111+00	qa1	1	\N
6e180ab6-b834-4b9a-bd42-2c68cc25cab4	7e97cdc6-58dc-4fd6-acae-13fa9d05df41	867dda4b-4eea-4539-a4e0-676f182775ae	1	2	PASSED	f	2026-10-12 11:44:48.329574+00	2026-10-12 11:44:50.983442+00	2653	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:41.366513+00	dev	2026-10-12 11:44:50.994224+00	anonymousUser	2	267429aa-1eb0-445c-86b6-bc3774110554
7f6a4ebe-5c09-4c76-929e-a01b9052b34a	00e8ca42-61a3-45e9-9678-38e784831e09	f4009358-0ebe-4b1b-97ed-43cd24235157	1	1	PASSED	f	2026-10-12 11:44:48.329552+00	2026-10-12 11:44:51.138122+00	2808	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:41.36704+00	dev	2026-10-12 11:44:51.148127+00	anonymousUser	2	267429aa-1eb0-445c-86b6-bc3774110554
8838051d-a193-4db5-8348-ce498dbb2b38	e2f9d633-3f38-4084-8300-1b9bcbfe69df	b28e7635-3121-4882-9f2f-c104b3f78180	1	1	PASSED	f	2026-10-12 11:44:48.329572+00	2026-10-12 11:44:51.865791+00	3535	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:41.36704+00	dev	2026-10-12 11:44:51.874844+00	anonymousUser	2	267429aa-1eb0-445c-86b6-bc3774110554
7facae8d-7cdf-46d2-bc6e-85bfd9fbaaa7	af8b2a24-0780-49c5-9549-ffd7fbb3843a	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	1	1	FAILED	f	2026-10-12 11:44:48.329556+00	2026-10-12 11:44:54.071029+00	5740	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-f04eddf6/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 11:44:41.36704+00	dev	2026-10-12 11:44:54.082708+00	anonymousUser	2	267429aa-1eb0-445c-86b6-bc3774110554
fd27ed43-d90c-4644-9484-834ac5efe9c5	85d872ed-0db5-4c61-9ea9-e389490be5ef	d0f99a45-390a-4287-82f7-f95ff69894ff	1	1	PASSED	f	2026-10-12 11:44:57.788957+00	2026-10-12 11:44:58.350957+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.354739+00	qa1	2026-10-12 11:44:58.354739+00	qa1	0	\N
b17aecaf-55a8-420b-ada5-874feeebbe90	4f34cd9d-9d33-444f-a52b-91579c655207	784b6b08-703b-47d4-9a01-1726c31ae483	1	1	PASSED	f	2026-10-12 11:44:54.835957+00	2026-10-12 11:44:58.350957+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.361268+00	qa1	2026-10-12 11:44:58.361268+00	qa1	0	\N
0bf3e01c-1875-4638-94f3-8cecae5b9e3b	37cb94b3-350a-4d06-8deb-d0daf511cc25	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	1	1	PASSED	f	2026-10-12 11:44:55.145957+00	2026-10-12 11:44:58.350957+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.366086+00	qa1	2026-10-12 11:44:58.366086+00	qa1	0	\N
b270d598-6386-4246-a502-4d770277734b	d85435ee-69f4-474c-9064-21a96d97dd64	5946baab-664a-4474-a55e-1416fce4c67b	1	1	PASSED	f	2026-10-12 11:44:57.908957+00	2026-10-12 11:44:58.350957+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.371505+00	qa1	2026-10-12 11:44:58.371505+00	qa1	0	\N
e829be80-a2e0-46c7-b193-f8cdbfe6e83f	fdb333f2-f6d3-4e8d-b060-cfca99359f67	daefb4fb-e381-482a-b586-27387d59a018	1	1	PASSED	f	2026-10-12 11:44:57.813957+00	2026-10-12 11:44:58.350957+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.376355+00	qa1	2026-10-12 11:44:58.376355+00	qa1	0	\N
28d21ec7-76ee-4f2a-9685-9fe949f6496c	5499e146-ee67-4e60-b309-18aa04cf6888	867dda4b-4eea-4539-a4e0-676f182775ae	1	2	PASSED	f	2026-10-12 11:44:57.663957+00	2026-10-12 11:44:58.350957+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.381201+00	qa1	2026-10-12 11:44:58.381201+00	qa1	0	\N
833cc571-fd57-4df9-9974-622c543b0218	c9b84513-9668-4bea-bef4-afe291ef0cab	f4009358-0ebe-4b1b-97ed-43cd24235157	1	1	PASSED	f	2026-10-12 11:44:57.803957+00	2026-10-12 11:44:58.350957+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.387492+00	qa1	2026-10-12 11:44:58.387492+00	qa1	0	\N
e9eb77da-6aa4-4611-bf7c-9045760a4ca2	8a332c5e-0528-45ff-b13e-8b9079beed87	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	1	1	FAILED	f	2026-10-12 11:44:54.882957+00	2026-10-12 11:44:58.350957+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.392111+00	qa1	2026-10-12 11:44:58.392111+00	qa1	0	\N
33897427-8267-438c-bc6a-2a9d40581be5	e3029566-d58f-4b8f-9317-5efce2d90e27	b28e7635-3121-4882-9f2f-c104b3f78180	1	1	PASSED	f	2026-10-12 11:44:57.536957+00	2026-10-12 11:44:58.350957+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 11:44:58.397135+00	qa1	2026-10-12 11:44:58.397135+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
afca5cf3-b555-4f28-81b2-edcf58db4ee4	23a05279-c105-47be-9768-25d4fa9f0222	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 11:44:00.564394+00	qa1	2026-10-12 11:44:00.564394+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
eb295c74-1a5f-47d9-b6f2-06177a500bd9	e0984119-d2b5-461a-aaa4-36f26eee6541	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 11:44:36.014205+00	qa1	2026-10-12 11:44:39.687383+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 13:43:29.692497	51	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 13:43:29.775332	78	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 13:43:29.871507	78	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 13:43:29.963813	14	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 13:43:29.988939	6	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 13:43:30.003306	39	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 13:43:30.05153	64	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 13:43:30.125584	7	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 13:43:30.141575	6	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 13:43:30.156602	14	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 13:43:30.17949	26	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 13:43:30.216252	41	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 13:43:30.266333	13	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 13:43:30.288644	26	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 13:43:30.326412	23	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 13:43:30.358181	15	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 13:43:30.381841	10	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 13:43:30.399456	2	t
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ	18
658d0618-1de6-4155-bdd0-48b1c6dedaac	TC	14
658d0618-1de6-4155-bdd0-48b1c6dedaac	REL	2
658d0618-1de6-4155-bdd0-48b1c6dedaac	SPR	3
658d0618-1de6-4155-bdd0-48b1c6dedaac	DEF	3
658d0618-1de6-4155-bdd0-48b1c6dedaac	RUN	3
658d0618-1de6-4155-bdd0-48b1c6dedaac	CMP	4
658d0618-1de6-4155-bdd0-48b1c6dedaac	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
fd27e170-358b-4d55-9bdf-f6ff58b13c27	2f547331-6326-4644-b351-b879ede01bf0	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 11:43:57.658244+00	qa1	2026-10-12 11:43:57.658244+00	qa1	0	\N	{}	\N	\N
0673c921-3033-4414-8a9e-fe529dae7ac2	2f547331-6326-4644-b351-b879ede01bf0	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 11:43:57.65878+00	qa1	2026-10-12 11:43:57.65878+00	qa1	0	\N	{}	\N	\N
a603fad5-7d88-4ee0-a953-6045681ac87e	21c73ffd-f8b4-424c-8130-8076ee38e849	1	\N	\N	\N	2026-10-12 11:43:57.765922+00	qa1	2026-10-12 11:43:57.765922+00	qa1	0	2f547331-6326-4644-b351-b879ede01bf0	{}	Comptes	problem_user
4f246819-5cbe-4869-97cc-d4e8fbaf8141	21c73ffd-f8b4-424c-8130-8076ee38e849	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 11:43:57.765922+00	qa1	2026-10-12 11:43:57.765922+00	qa1	0	\N	{}	\N	\N
654c7d76-611b-4a58-ac21-be7b1c5915aa	21c73ffd-f8b4-424c-8130-8076ee38e849	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 11:43:57.765922+00	qa1	2026-10-12 11:43:57.765922+00	qa1	0	\N	{}	\N	\N
1e320488-d971-455e-90d7-9789da04c449	21c73ffd-f8b4-424c-8130-8076ee38e849	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 11:43:57.765922+00	qa1	2026-10-12 11:43:57.765922+00	qa1	0	\N	{}	\N	\N
6a2c9acd-369a-4434-8a47-92c6e04c31ba	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	\N	\N	\N	2026-10-12 11:44:00.621412+00	qa1	2026-10-12 11:44:00.621412+00	qa1	0	2f547331-6326-4644-b351-b879ede01bf0	{}	Comptes	standard_user
c6aa8402-15b3-4180-a5ad-12a90e6af2a3	2c8fca63-ebd3-491e-8eac-cdc263d9704f	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 11:44:00.621412+00	qa1	2026-10-12 11:44:00.621412+00	qa1	0	\N	{}	\N	\N
41f1a122-96ca-4543-9d22-80a9af8a06fb	2c8fca63-ebd3-491e-8eac-cdc263d9704f	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 11:44:00.621412+00	qa1	2026-10-12 11:44:00.621412+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ba37f477-6b29-4c72-9c14-b2d2e897d8a9	0aeee68e-00ea-41ad-8f2e-d2779eac99d0	298	ms	p95Ms	TC-11	RUN-2	2026-10-12 11:44:51.865791+00	TARGET_MET	2026-10-12 11:44:51.883539+00	anonymousUser	2026-10-12 11:44:51.883539+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
3748561e-2fe2-4247-b844-b63c14222b52	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:11.860527+00
00f544c8-24db-46ac-9be3-d71995fbfb6d	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:20.00494+00
cd52ac37-1554-4e7a-bdfb-d4937f19dc0e	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:20.539062+00
8f4c6e8a-707a-4a25-8ac0-1d840fd5709c	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:20.539062+00
71b3fe56-e4c7-4bb3-b4ba-ae6052fa13d0	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:20.539062+00
6639dc45-9b80-4148-8917-e56628a38f31	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:22.235272+00
a3f1ab55-16f9-4496-9f26-8be2ede51233	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:22.270219+00
1c180e4e-a8dd-4182-9356-8e4e553cab14	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:22.614634+00
d7df150d-12df-407e-b51a-dfba3d738d1c	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:22.648623+00
cc5064e9-b2cc-41f8-8b49-a66442b39974	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:22.966855+00
4944dae5-b534-4f28-8b46-762be59ac03d	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:23.855765+00
9792e364-4ae8-4941-b3bf-5351be871c84	cdaf7d74-493c-4c4e-bb55-9f9b153de933	2026-10-12 11:44:23.877623+00
c75101a7-ce99-477d-a5b3-096294a1c4c8	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:41.410143+00
1c2ec9ce-fe15-4783-b5d5-15259e032a1e	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:48.336711+00
b6db1c80-11a5-434f-b44e-3bbbbc3f2459	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:48.853216+00
ab4ad6b9-c7f8-41e3-8d65-fb8d779f5d7e	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:48.854232+00
c1497555-fefb-4c3d-930a-d3424c24cace	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:49.870125+00
724feeb3-d00e-452c-85da-a6922a777f8b	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:50.990113+00
ce175450-b361-4cbd-a609-c1ebf5c318db	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:51.144903+00
377afe3b-60dd-4373-b647-641f2343e30b	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:51.872118+00
f67a627e-8e5b-4ecc-9170-1aadf45902bf	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:54.077592+00
2de4fde0-e8bd-4633-a72e-c19ce9705ad4	267429aa-1eb0-445c-86b6-bc3774110554	2026-10-12 11:44:54.099561+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
47c22ece-2ca0-4c1f-be11-182b0fc2138c	658d0618-1de6-4155-bdd0-48b1c6dedaac	974022c6-c648-441d-b1e9-2acef8a3158d	ADMINISTRATOR	2026-10-12 11:43:44.187143+00	admin	2026-10-12 11:43:44.187143+00	admin	0
72c07062-fbde-4ee8-b144-e61cc6acf4e3	658d0618-1de6-4155-bdd0-48b1c6dedaac	259475e7-fb48-4047-bfa2-a7434b1432d7	PRODUCT_OWNER	2026-10-12 11:43:44.187143+00	admin	2026-10-12 11:43:44.187143+00	admin	0
688f8f2f-dc2e-4779-8ca3-78e220e17a5f	658d0618-1de6-4155-bdd0-48b1c6dedaac	91875ec1-5ed3-4313-a299-02eaaf1c6654	TESTER	2026-10-12 11:43:44.188196+00	admin	2026-10-12 11:43:44.188196+00	admin	0
6a6c6695-8648-4dce-b903-071ea8b5c03c	658d0618-1de6-4155-bdd0-48b1c6dedaac	6944f490-8e8f-45c7-b5d6-8d4831abe911	TESTER	2026-10-12 11:43:44.188196+00	admin	2026-10-12 11:43:44.188196+00	admin	0
8f238e44-be10-4de7-87eb-b6f3d0db841f	658d0618-1de6-4155-bdd0-48b1c6dedaac	1136d86f-25de-4f3d-a127-f6f3461dd040	DEVELOPER	2026-10-12 11:43:44.188196+00	admin	2026-10-12 11:43:44.188196+00	admin	0
73c9f22f-7551-413d-9b9c-59b6f0352986	658d0618-1de6-4155-bdd0-48b1c6dedaac	046765d7-37c2-439b-a290-1f85c11008f6	VIEWER	2026-10-12 11:43:44.188196+00	admin	2026-10-12 11:43:44.188196+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
658d0618-1de6-4155-bdd0-48b1c6dedaac	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 11:43:44.068667+00	admin	2026-10-12 11:43:44.068667+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
33a70e93-d363-4916-8dd7-1d88b245f0c5	658d0618-1de6-4155-bdd0-48b1c6dedaac	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 11:44:05.441565+00	po	2026-10-12 11:44:07.036841+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2a693c86-089f-46a9-83b9-12b35c76d628	658d0618-1de6-4155-bdd0-48b1c6dedaac	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 11:44:28.209406+00	po	2026-10-12 11:44:28.209406+00	po	0
7ea10cbc-e124-48d8-8743-d5484359d623	658d0618-1de6-4155-bdd0-48b1c6dedaac	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 11:44:28.218296+00	po	2026-10-12 11:44:28.218296+00	po	0
88ba18f2-5946-4c40-a352-cc0cdf4b0ab4	658d0618-1de6-4155-bdd0-48b1c6dedaac	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 11:45:14.184784+00	po	2026-10-12 11:45:14.184784+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
40cbace2-b683-4543-b9a4-6801c7e9f7e8	658d0618-1de6-4155-bdd0-48b1c6dedaac	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T11:44:28.247118400Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 11:44:28.275902+00	clôture du sprint	2026-10-12 11:44:28.274901+00	po	2026-10-12 11:44:28.276902+00	po	1
be5a137a-bcec-4184-af34-c03724793e84	658d0618-1de6-4155-bdd0-48b1c6dedaac	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T11:45:10.784033300Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 11:45:12.263432+00	f	\N	\N	2026-10-12 11:45:10.795995+00	po	2026-10-12 11:45:12.263432+00	po	2
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
8b173eb0-ff92-47a8-907c-946f4de7b4a1	8210bc1c-4b21-416b-a550-de9cc2505f0c	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.285739+00	po	2026-10-12 11:43:50.285739+00	po	0
43427d22-7b0a-4a73-b371-a61fb75e6c4e	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.326132+00	po	2026-10-12 11:43:50.326132+00	po	0
10a16acf-0371-4113-bdcc-39678ed00def	2217e2d2-dcba-41ca-a719-f4ad66722a97	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.360941+00	po	2026-10-12 11:43:50.360941+00	po	0
6282601d-4352-42bb-b7d8-a43cd72632d0	bc64631e-be55-47c4-945c-6daa40bc79e5	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.390979+00	po	2026-10-12 11:43:50.390979+00	po	0
a75107ca-17a7-4252-be2b-f0f86daf8d92	94c7fd05-9d4c-445f-a104-c60b10d3a230	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.421323+00	po	2026-10-12 11:43:50.421323+00	po	0
4699868d-744d-4f47-a3da-351d9bdb22aa	a121518a-c7e1-4c20-bc62-c4824e698c30	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.453377+00	po	2026-10-12 11:43:50.453377+00	po	0
143a464a-3e30-4eb2-b019-990962cd610b	a8c8c836-d7a0-40e3-8c87-d228acb7a333	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:50.485942+00	po	2026-10-12 11:43:50.485942+00	po	0
024ad957-de20-4f94-9373-7b04731b1d9d	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 11:43:51.473604+00	po	2026-10-12 11:43:51.473604+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8a19c9b1-3e78-424c-9080-32435a0983b0	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 11:43:46.982627+00	po	2026-10-12 11:43:46.982627+00	po	0
2d10675b-ecf5-44a3-bc38-f6d9dec8bc62	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 11:43:47.051587+00	po	2026-10-12 11:43:47.051587+00	po	0
1c0558dc-a490-4552-b0c6-fb8aa0763119	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 11:43:47.195095+00	po	2026-10-12 11:43:47.195095+00	po	0
46ca823c-5360-4acd-90af-e8aa37dd0fae	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 11:43:47.338526+00	po	2026-10-12 11:43:47.338526+00	po	0
4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	2d10675b-ecf5-44a3-bc38-f6d9dec8bc62	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 11:43:47.155544+00	po	2026-10-12 11:44:25.843158+00	po	3
2217e2d2-dcba-41ca-a719-f4ad66722a97	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	1c0558dc-a490-4552-b0c6-fb8aa0763119	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 11:43:47.232432+00	po	2026-10-12 11:44:25.885342+00	po	3
a8c8c836-d7a0-40e3-8c87-d228acb7a333	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	46ca823c-5360-4acd-90af-e8aa37dd0fae	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 11:43:47.40438+00	po	2026-10-12 11:44:28.953067+00	po	2
0aeee68e-00ea-41ad-8f2e-d2779eac99d0	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 11:43:49.448247+00	po	2026-10-12 11:43:49.448247+00	po	0
8210bc1c-4b21-416b-a550-de9cc2505f0c	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	2d10675b-ecf5-44a3-bc38-f6d9dec8bc62	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 11:43:47.111502+00	po	2026-10-12 11:44:25.795685+00	po	3
bc64631e-be55-47c4-945c-6daa40bc79e5	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	1c0558dc-a490-4552-b0c6-fb8aa0763119	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 11:43:47.268563+00	po	2026-10-12 11:44:25.92134+00	po	3
4170fd8a-bc8c-4ac3-b654-91e361bc8af3	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	46ca823c-5360-4acd-90af-e8aa37dd0fae	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 11:43:47.439786+00	po	2026-10-12 11:44:28.953067+00	po	2
94c7fd05-9d4c-445f-a104-c60b10d3a230	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	1c0558dc-a490-4552-b0c6-fb8aa0763119	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 11:43:47.30462+00	po	2026-10-12 11:45:06.277047+00	po	4
5a3e7645-5840-487c-b349-7bdc79a2a054	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 11:43:47.472084+00	po	2026-10-12 11:43:47.472084+00	po	0
598f46e0-8e8b-43ba-81eb-700faf744841	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5a3e7645-5840-487c-b349-7bdc79a2a054	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 11:43:47.501323+00	po	2026-10-12 11:43:47.501323+00	po	0
67c287c2-6293-47f3-85fb-a1c518557d8b	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	5a3e7645-5840-487c-b349-7bdc79a2a054	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 11:43:49.205666+00	po	2026-10-12 11:43:49.205666+00	po	0
050bcbbc-6ff8-4a42-b656-8da5ab4d023d	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	8a19c9b1-3e78-424c-9080-32435a0983b0	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 11:43:49.480777+00	po	2026-10-12 11:43:49.480777+00	po	0
a121518a-c7e1-4c20-bc62-c4824e698c30	658d0618-1de6-4155-bdd0-48b1c6dedaac	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	46ca823c-5360-4acd-90af-e8aa37dd0fae	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 11:43:47.369797+00	po	2026-10-12 11:44:28.953067+00	po	2
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
78de9bb5-3da7-4631-9591-dd4d908f8a88	cdaf7d74-493c-4c4e-bb55-9f9b153de933	5947b26a-8897-4891-a543-6227c84e86ed	log-TC-7.txt	text/plain	SYSTEM_TRACE	487	2026-10-12 11:44:22.243059+00	anonymousUser	2026-10-12 11:44:22.243059+00	anonymousUser	0
7a2c5d81-87c2-462a-9636-8147d88bfa78	cdaf7d74-493c-4c4e-bb55-9f9b153de933	212ddcaf-a0b4-490e-b3c5-216d369f28f9	log-TC-5.txt	text/plain	SYSTEM_TRACE	391	2026-10-12 11:44:22.620234+00	anonymousUser	2026-10-12 11:44:22.620234+00	anonymousUser	0
35a15990-ca34-4c24-affd-2d96d6d14e19	cdaf7d74-493c-4c4e-bb55-9f9b153de933	3db9552f-dc55-486e-ad52-787979cacf02	log-TC-4.txt	text/plain	SYSTEM_TRACE	393	2026-10-12 11:44:22.652932+00	anonymousUser	2026-10-12 11:44:22.652932+00	anonymousUser	0
4b9bd261-b59c-47f0-a5ef-d5718c1d8807	cdaf7d74-493c-4c4e-bb55-9f9b153de933	c387f099-6fa6-44e3-83e0-ee4f27a959ec	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 11:44:22.970667+00	anonymousUser	2026-10-12 11:44:22.970667+00	anonymousUser	0
3bde75b2-e0dc-4a31-98b7-0e73410b5c84	cdaf7d74-493c-4c4e-bb55-9f9b153de933	5000f1ee-0477-468a-9bb0-6146defcb06b	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 11:44:23.858325+00	anonymousUser	2026-10-12 11:44:23.858325+00	anonymousUser	0
e7bf4286-1000-47a1-ae8d-0d23d6203231	cdaf7d74-493c-4c4e-bb55-9f9b153de933	\N	system.log	text/plain	SYSTEM_TRACE	4728	2026-10-12 11:44:23.879201+00	anonymousUser	2026-10-12 11:44:23.879201+00	anonymousUser	0
0c11680d-a5e2-4ac9-86e2-eb3cef38c99a	cdaf7d74-493c-4c4e-bb55-9f9b153de933	\N	junit.xml	application/xml	JUNIT	1188	2026-10-12 11:44:23.882571+00	anonymousUser	2026-10-12 11:44:23.882571+00	anonymousUser	0
4d67d43b-f942-4b9e-9c47-bd50b43bdd21	cdaf7d74-493c-4c4e-bb55-9f9b153de933	\N	report.json	application/json	REPORT	484	2026-10-12 11:44:23.889674+00	anonymousUser	2026-10-12 11:44:23.889674+00	anonymousUser	0
1dd01272-06f0-4a96-8e87-a54445c71744	267429aa-1eb0-445c-86b6-bc3774110554	6e180ab6-b834-4b9a-bd42-2c68cc25cab4	log-TC-8.txt	text/plain	SYSTEM_TRACE	361	2026-10-12 11:44:50.993178+00	anonymousUser	2026-10-12 11:44:50.993178+00	anonymousUser	0
78bdc8e6-207c-483e-8342-13e6419e05ae	267429aa-1eb0-445c-86b6-bc3774110554	7f6a4ebe-5c09-4c76-929e-a01b9052b34a	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 11:44:51.147524+00	anonymousUser	2026-10-12 11:44:51.147524+00	anonymousUser	0
14127bf0-a87f-477d-b7e3-a2c7bb591859	267429aa-1eb0-445c-86b6-bc3774110554	8838051d-a193-4db5-8348-ce498dbb2b38	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 11:44:51.874318+00	anonymousUser	2026-10-12 11:44:51.874318+00	anonymousUser	0
165b077d-d123-4210-8674-e65736169211	267429aa-1eb0-445c-86b6-bc3774110554	7facae8d-7cdf-46d2-bc6e-85bfd9fbaaa7	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 11:44:54.080155+00	anonymousUser	2026-10-12 11:44:54.080155+00	anonymousUser	0
2ae53169-5315-4890-9620-2f09d862340f	267429aa-1eb0-445c-86b6-bc3774110554	7facae8d-7cdf-46d2-bc6e-85bfd9fbaaa7	log-TC-10.txt	text/plain	SYSTEM_TRACE	3392	2026-10-12 11:44:54.082199+00	anonymousUser	2026-10-12 11:44:54.082199+00	anonymousUser	0
87de71ae-21be-4bd6-91d9-00bec018948c	267429aa-1eb0-445c-86b6-bc3774110554	\N	system.log	text/plain	SYSTEM_TRACE	8592	2026-10-12 11:44:54.10059+00	anonymousUser	2026-10-12 11:44:54.10059+00	anonymousUser	0
4112b294-ed05-4af8-9ac9-847cac7d1eb2	267429aa-1eb0-445c-86b6-bc3774110554	\N	junit.xml	application/xml	JUNIT	1057	2026-10-12 11:44:54.103214+00	anonymousUser	2026-10-12 11:44:54.103214+00	anonymousUser	0
1f791130-bb57-4220-8c0a-b2dba11e34f3	267429aa-1eb0-445c-86b6-bc3774110554	\N	report.json	application/json	REPORT	475	2026-10-12 11:44:54.105401+00	anonymousUser	2026-10-12 11:44:54.105401+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
aa3c9a82-c914-4495-b3ee-3f28e613e672	eb295c74-1a5f-47d9-b6f2-06177a500bd9	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 11:44:36.139599+00	qa1	2026-10-12 11:44:36.139599+00	qa1	0
e1c2cbbf-3a69-4922-8e0b-3237fe120a69	eb295c74-1a5f-47d9-b6f2-06177a500bd9	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 11:44:36.248686+00	qa1	2026-10-12 11:44:36.248686+00	qa1	0
fafaf532-5293-4284-b811-c90ef9a1d647	eb295c74-1a5f-47d9-b6f2-06177a500bd9	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 11:44:36.381485+00	qa1	2026-10-12 11:44:36.381485+00	qa1	0
6384d76c-54ad-4723-aadd-a8ce30f53c58	eb295c74-1a5f-47d9-b6f2-06177a500bd9	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 11:44:36.463597+00	qa1	2026-10-12 11:44:36.463597+00	qa1	0
e999cd50-c3b1-4f34-a670-7cef22545239	eb295c74-1a5f-47d9-b6f2-06177a500bd9	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	a85cb532-42d3-4abf-af20-bb988ba74beb	2026-10-12 11:44:36.314147+00	qa1	2026-10-12 11:44:37.343528+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7aaeaa29-b1b7-46e6-9229-2112b3b4d8d4	c0413527-4ece-4bbc-a9bd-16d6221cc828	8210bc1c-4b21-416b-a550-de9cc2505f0c	1	3	DONE	2026-10-12 11:44:06.192509+00	po	2026-10-12 11:44:28.210985+00	po	1
a3271cde-4d1b-47a2-b004-d5a30481cc94	c0413527-4ece-4bbc-a9bd-16d6221cc828	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	2	2	DONE	2026-10-12 11:44:06.268658+00	po	2026-10-12 11:44:28.210985+00	po	1
a5288894-b51d-4b28-aef7-25728ba926cd	c0413527-4ece-4bbc-a9bd-16d6221cc828	2217e2d2-dcba-41ca-a719-f4ad66722a97	3	3	DONE	2026-10-12 11:44:06.342273+00	po	2026-10-12 11:44:28.210985+00	po	1
e387d8e6-396d-4357-90d3-092a4f500060	c0413527-4ece-4bbc-a9bd-16d6221cc828	bc64631e-be55-47c4-945c-6daa40bc79e5	4	2	DONE	2026-10-12 11:44:06.416684+00	po	2026-10-12 11:44:28.210985+00	po	1
40ee90d2-bf24-4d51-b136-ea6c66aebe2c	c0413527-4ece-4bbc-a9bd-16d6221cc828	94c7fd05-9d4c-445f-a104-c60b10d3a230	5	2	DONE	2026-10-12 11:44:06.476979+00	po	2026-10-12 11:44:28.210985+00	po	1
dd640415-7880-4d02-9112-8ba9992162a0	000159d6-f57d-4e3c-977a-bb6235a1b98c	a121518a-c7e1-4c20-bc62-c4824e698c30	1	3	PLANNED	2026-10-12 11:44:28.91374+00	po	2026-10-12 11:44:28.91374+00	po	0
a88f8329-dfd9-4eeb-beca-1c19a243fabc	000159d6-f57d-4e3c-977a-bb6235a1b98c	a8c8c836-d7a0-40e3-8c87-d228acb7a333	2	3	PLANNED	2026-10-12 11:44:28.91374+00	po	2026-10-12 11:44:28.91374+00	po	0
527cfc56-b9dd-4ed7-8ab0-5662c4529b45	000159d6-f57d-4e3c-977a-bb6235a1b98c	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	3	2	PLANNED	2026-10-12 11:44:28.91374+00	po	2026-10-12 11:44:28.91374+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c0413527-4ece-4bbc-a9bd-16d6221cc828	658d0618-1de6-4155-bdd0-48b1c6dedaac	33a70e93-d363-4916-8dd7-1d88b245f0c5	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 11:44:05.469391+00	po	2026-10-12 11:44:28.210475+00	po	2
000159d6-f57d-4e3c-977a-bb6235a1b98c	658d0618-1de6-4155-bdd0-48b1c6dedaac	33a70e93-d363-4916-8dd7-1d88b245f0c5	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 11:44:05.510397+00	po	2026-10-12 11:44:28.952513+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
4a62fe1f-55b3-4761-b3a4-0d31bce9ad33	b972df79-becd-4930-9598-de0af9e3cece	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:09.637281+00	qa1	2026-10-12 11:44:09.778888+00	qa1	1	\N
c2d6348c-ddd2-4b27-8944-097ab862de6e	b972df79-becd-4930-9598-de0af9e3cece	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:44:09.637281+00	qa1	2026-10-12 11:44:10.348525+00	qa1	1	\N
3907b0d5-71af-4a7c-81a5-1980476ae9d1	f268e96a-aae0-4d03-b117-d41a556e8698	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:10.388184+00	qa1	2026-10-12 11:44:10.405787+00	qa1	1	\N
bc48489c-6143-407d-aae2-0be447b64ad8	f268e96a-aae0-4d03-b117-d41a556e8698	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 11:44:10.388184+00	qa1	2026-10-12 11:44:10.423567+00	qa1	1	\N
0a97340c-142f-40a1-8d91-b61e1b4f15ef	519f3480-e891-4333-a2f5-42fb3e2f319f	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:10.439915+00	qa1	2026-10-12 11:44:10.455932+00	qa1	1	\N
1f216771-1a90-4db6-a31e-30e8d6ae7111	519f3480-e891-4333-a2f5-42fb3e2f319f	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:44:10.439915+00	qa1	2026-10-12 11:44:10.47117+00	qa1	1	\N
4dcb9d40-0566-4913-8eda-474607b10746	4f968034-a7e7-4fbf-8f68-a4d118d7dc61	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.362215+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
c720f9c8-534a-4777-abee-0b8f499238c1	4f968034-a7e7-4fbf-8f68-a4d118d7dc61	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.48887+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
653ad0c7-a5f8-4fd4-9d54-e21fea83f92b	4f968034-a7e7-4fbf-8f68-a4d118d7dc61	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.601241+00	qa2	1	\N
80bbd7d4-142e-403d-96d7-fcdde1f226b9	4f968034-a7e7-4fbf-8f68-a4d118d7dc61	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.719203+00	qa2	1	\N
f4098cab-d7b2-4d27-a4a7-d7a002da21f1	4f968034-a7e7-4fbf-8f68-a4d118d7dc61	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 11:44:31.11041+00	qa2	2026-10-12 11:44:31.99627+00	qa2	1	\N
8024b198-8a21-454c-ba04-769a66378fa6	a02bcc20-c559-4469-b039-dc762cf696e7	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:34.00454+00	qa1	2026-10-12 11:44:34.151424+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
0fe843e6-8389-433f-8037-36f1566d3a3a	a02bcc20-c559-4469-b039-dc762cf696e7	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:44:34.00454+00	qa1	2026-10-12 11:44:34.749302+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
4a71d3ca-6bec-478a-aca2-3abb5cf2aecc	a02bcc20-c559-4469-b039-dc762cf696e7	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:44:34.005046+00	qa1	2026-10-12 11:44:34.863388+00	qa1	1	\N
4dee0a8a-9fbb-4111-9515-d99ec6221d33	a02bcc20-c559-4469-b039-dc762cf696e7	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 11:44:34.005046+00	qa1	2026-10-12 11:44:34.984088+00	qa1	1	\N
4f4f8f7f-37e3-4fd0-9677-a5474ffe48c1	6860bff4-ffa7-4be5-84dd-78249977b9df	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 11:44:35.035297+00	qa1	2026-10-12 11:44:35.051012+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
005f7dde-014f-4d30-8cbd-0306bcf79457	6860bff4-ffa7-4be5-84dd-78249977b9df	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 11:44:35.035297+00	qa1	2026-10-12 11:44:35.065678+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
c9b1c2f8-f67d-4c25-a527-13f49b8eeffb	6860bff4-ffa7-4be5-84dd-78249977b9df	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 11:44:35.035297+00	qa1	2026-10-12 11:44:35.080296+00	qa1	1	\N
f2957362-8318-459a-832d-f57142cbc9ac	6860bff4-ffa7-4be5-84dd-78249977b9df	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 11:44:35.035297+00	qa1	2026-10-12 11:44:35.09548+00	qa1	1	\N
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
9b27fefa-b5ac-417d-9405-52ca0e2c272e	2f547331-6326-4644-b351-b879ede01bf0	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 11:43:57.661811+00	qa1	2026-10-12 11:43:57.661811+00	qa1	0
051691a7-834f-4b60-ab90-54f5df7d5933	21c73ffd-f8b4-424c-8130-8076ee38e849	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 11:43:57.766473+00	qa1	2026-10-12 11:43:57.766473+00	qa1	0
e333b321-a26e-448d-a55c-93be88c63962	784b6b08-703b-47d4-9a01-1726c31ae483	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "installation-hors-docker", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:57.842249+00	dev	2026-10-12 11:43:57.842249+00	dev	0
5177b50e-cf15-41b1-b7c9-415bfa6e5da2	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:57.913201+00	dev	2026-10-12 11:43:57.913201+00	dev	0
6c6e3a6d-606e-4ed8-a952-bc2dd27d8332	5946baab-664a-4474-a55e-1416fce4c67b	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:57.968519+00	dev	2026-10-12 11:43:57.968519+00	dev	0
b00b6bd4-5c36-424c-aa58-2a8b8655ede7	daefb4fb-e381-482a-b586-27387d59a018	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:58.02434+00	dev	2026-10-12 11:43:58.02434+00	dev	0
8e396922-cebd-48a4-9dcb-18e7bf731910	d0f99a45-390a-4287-82f7-f95ff69894ff	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "installation-hors-docker", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:58.080955+00	dev	2026-10-12 11:43:58.080955+00	dev	0
77185b55-176e-4f76-914b-00c63a3ee35d	867dda4b-4eea-4539-a4e0-676f182775ae	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:59.327765+00	qa1	2026-10-12 11:43:59.327765+00	qa1	0
a80dab0e-2dcc-4ef1-bbe9-ef01074e6df9	867dda4b-4eea-4539-a4e0-676f182775ae	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "installation-hors-docker", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:43:59.564162+00	qa1	2026-10-12 11:43:59.564162+00	qa1	0
2a2a472c-3f8b-44e5-a409-b8cceaa1e956	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:44:00.460421+00	dev	2026-10-12 11:44:00.460421+00	dev	0
05448643-4447-4fab-8cec-61788f8ae04c	2c8fca63-ebd3-491e-8eac-cdc263d9704f	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 11:44:00.621919+00	qa1	2026-10-12 11:44:00.621919+00	qa1	0
82e88aa1-8f64-4e9c-84dd-43fd1e86e0ca	f4009358-0ebe-4b1b-97ed-43cd24235157	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:44:00.403781+00	dev	2026-10-12 11:44:00.403781+00	dev	0
01fe30e5-ea70-44b3-899a-abae26b9ed91	b28e7635-3121-4882-9f2f-c104b3f78180	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "installation-hors-docker", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 11:44:00.513506+00	dev	2026-10-12 11:44:00.513506+00	dev	0
dd92422c-b9c3-4eed-ad5a-d85591332bee	23a05279-c105-47be-9768-25d4fa9f0222	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 11:44:00.564901+00	qa1	2026-10-12 11:44:00.564901+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
2f547331-6326-4644-b351-b879ede01bf0	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 11:43:57.652901+00	qa1	2026-10-12 11:43:57.734745+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
21c73ffd-f8b4-424c-8130-8076ee38e849	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 11:43:57.765411+00	qa1	2026-10-12 11:43:57.810158+00	qa1	1	[]	[]	f
784b6b08-703b-47d4-9a01-1726c31ae483	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 11:43:57.839512+00	dev	2026-10-12 11:43:57.884206+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
16ad2303-ebbf-48b1-9b04-a9c36a418a5c	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 11:43:57.912654+00	dev	2026-10-12 11:43:57.943349+00	qa1	1	[]	[]	f
5946baab-664a-4474-a55e-1416fce4c67b	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 11:43:57.967981+00	dev	2026-10-12 11:43:57.998326+00	qa1	1	[]	[]	f
d0f99a45-390a-4287-82f7-f95ff69894ff	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 11:43:58.080367+00	dev	2026-10-12 11:43:58.111229+00	qa1	1	[]	[]	f
54b03b4f-aeb7-41cc-9784-7aa19e5f0577	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 11:44:00.459913+00	dev	2026-10-12 11:44:00.489098+00	qa1	1	[]	[]	f
867dda4b-4eea-4539-a4e0-676f182775ae	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 11:43:59.327765+00	qa1	2026-10-12 11:43:59.571966+00	qa1	2	[]	[]	f
f4009358-0ebe-4b1b-97ed-43cd24235157	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 11:44:00.403238+00	dev	2026-10-12 11:44:00.436071+00	qa1	1	[]	[]	f
b28e7635-3121-4882-9f2f-c104b3f78180	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 11:44:00.512973+00	dev	2026-10-12 11:44:00.542591+00	qa1	1	[]	[]	f
23a05279-c105-47be-9768-25d4fa9f0222	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 11:44:00.56281+00	qa1	2026-10-12 11:44:00.596747+00	qa1	1	[]	[]	f
2c8fca63-ebd3-491e-8eac-cdc263d9704f	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 11:44:00.62082+00	qa1	2026-10-12 11:44:00.658521+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
daefb4fb-e381-482a-b586-27387d59a018	658d0618-1de6-4155-bdd0-48b1c6dedaac	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 11:43:58.02434+00	dev	2026-10-12 11:45:06.283824+00	po	2	[]	[]	f
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
7d23d58f-7e41-4d24-8f1f-6097efdff8dc	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2f547331-6326-4644-b351-b879ede01bf0	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	VERIFIES	MANUAL	2026-10-12 11:43:57.6741+00	qa1	2026-10-12 11:43:57.6741+00	qa1	0	\N
5ddbaef6-fd8c-466a-bf45-f1eb4b3054d0	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2f547331-6326-4644-b351-b879ede01bf0	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	VERIFIES	MANUAL	2026-10-12 11:43:57.674646+00	qa1	2026-10-12 11:43:57.674646+00	qa1	0	\N
1b7b7123-e5fd-4fb3-92d4-2ec1125eae61	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	21c73ffd-f8b4-424c-8130-8076ee38e849	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	PARTIALLY_VERIFIES	MANUAL	2026-10-12 11:43:57.772533+00	qa1	2026-10-12 11:43:57.772533+00	qa1	0	\N
bda29d72-9139-4b53-83d3-503abe209768	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	21c73ffd-f8b4-424c-8130-8076ee38e849	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	VERIFIES	MANUAL	2026-10-12 11:43:57.772533+00	qa1	2026-10-12 11:43:57.772533+00	qa1	0	\N
f51e4afe-d29f-42cc-af74-5698c45ec977	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	784b6b08-703b-47d4-9a01-1726c31ae483	REQUIREMENT	8210bc1c-4b21-416b-a550-de9cc2505f0c	VERIFIES	MANUAL	2026-10-12 11:43:57.846983+00	dev	2026-10-12 11:43:57.846983+00	dev	0	\N
417b98ff-7f42-406f-9959-70bcdce169f8	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	784b6b08-703b-47d4-9a01-1726c31ae483	REQUIREMENT	4412f9c7-6efd-4ea6-8c1e-e9bacab7f7b4	VERIFIES	MANUAL	2026-10-12 11:43:57.847569+00	dev	2026-10-12 11:43:57.847569+00	dev	0	\N
c4c72070-4e28-4a6d-9595-b373fc93f5e1	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	16ad2303-ebbf-48b1-9b04-a9c36a418a5c	REQUIREMENT	2217e2d2-dcba-41ca-a719-f4ad66722a97	VERIFIES	MANUAL	2026-10-12 11:43:57.915902+00	dev	2026-10-12 11:43:57.915902+00	dev	0	\N
186b72b3-61ab-4fc0-9068-e90e5119d14a	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	5946baab-664a-4474-a55e-1416fce4c67b	REQUIREMENT	bc64631e-be55-47c4-945c-6daa40bc79e5	VERIFIES	MANUAL	2026-10-12 11:43:57.971241+00	dev	2026-10-12 11:43:57.971241+00	dev	0	\N
b173df0d-f522-400c-a4af-53ef9c3b8b0e	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	d0f99a45-390a-4287-82f7-f95ff69894ff	REQUIREMENT	050bcbbc-6ff8-4a42-b656-8da5ab4d023d	VERIFIES	MANUAL	2026-10-12 11:43:58.083887+00	dev	2026-10-12 11:43:58.083887+00	dev	0	\N
49f19057-a6b2-40b2-a33f-7b7b54a4f21a	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	867dda4b-4eea-4539-a4e0-676f182775ae	REQUIREMENT	a121518a-c7e1-4c20-bc62-c4824e698c30	VERIFIES	GHERKIN_TAG	2026-10-12 11:43:59.333789+00	qa1	2026-10-12 11:43:59.333789+00	qa1	0	\N
dd40e081-21a7-4a7d-beda-e551e96473fd	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	867dda4b-4eea-4539-a4e0-676f182775ae	ACCEPTANCE_CRITERION	4e7e065e-a286-4518-8439-dab18d8de20a	VERIFIES	GHERKIN_TAG	2026-10-12 11:43:59.341491+00	qa1	2026-10-12 11:43:59.341491+00	qa1	0	\N
ee48433c-69a1-4328-ad2f-e99d063f73d8	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	f4009358-0ebe-4b1b-97ed-43cd24235157	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	VERIFIES	MANUAL	2026-10-12 11:44:00.406521+00	dev	2026-10-12 11:44:00.406521+00	dev	0	\N
f0d2bce4-ebdd-4657-96fb-9f63a4d92def	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	54b03b4f-aeb7-41cc-9784-7aa19e5f0577	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	VERIFIES	MANUAL	2026-10-12 11:44:00.462664+00	dev	2026-10-12 11:44:00.462664+00	dev	0	\N
aa8dda9d-eba3-4d2a-aa60-1cea9b45cb30	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	b28e7635-3121-4882-9f2f-c104b3f78180	REQUIREMENT	0aeee68e-00ea-41ad-8f2e-d2779eac99d0	VERIFIES	MANUAL	2026-10-12 11:44:00.516608+00	dev	2026-10-12 11:44:00.516608+00	dev	0	\N
7f9ec6fd-0205-4712-9da5-3e04397a4d5f	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	23a05279-c105-47be-9768-25d4fa9f0222	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	VERIFIES	MANUAL	2026-10-12 11:44:00.569086+00	qa1	2026-10-12 11:44:00.569086+00	qa1	0	\N
65a91327-8d60-4a95-8f91-a8c7ddf534cf	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	23a05279-c105-47be-9768-25d4fa9f0222	REQUIREMENT	4170fd8a-bc8c-4ac3-b654-91e361bc8af3	VERIFIES	MANUAL	2026-10-12 11:44:00.569618+00	qa1	2026-10-12 11:44:00.569618+00	qa1	0	\N
52ad2d82-bf45-4063-83b8-51211a2b3ad6	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	2c8fca63-ebd3-491e-8eac-cdc263d9704f	REQUIREMENT	a8c8c836-d7a0-40e3-8c87-d228acb7a333	VERIFIES	MANUAL	2026-10-12 11:44:00.625341+00	qa1	2026-10-12 11:44:00.625341+00	qa1	0	\N
f3ac7797-5637-431e-ad9c-fbd0141abd08	658d0618-1de6-4155-bdd0-48b1c6dedaac	TEST_CASE	daefb4fb-e381-482a-b586-27387d59a018	REQUIREMENT	94c7fd05-9d4c-445f-a104-c60b10d3a230	VERIFIES	MANUAL	2026-10-12 11:43:58.027257+00	dev	2026-10-12 11:45:06.93801+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
974022c6-c648-441d-b1e9-2acef8a3158d	admin	admin@traceagile.local	Administrateur	$2a$12$ZRC8QlI8F2Q1CJnYqoAY8.6BVQcxbAxlm1N.SRCO7JlRo/yQmElJ.	t	t	2026-10-12 11:43:34.289523+00	system	2026-10-12 11:43:34.289523+00	system	0
259475e7-fb48-4047-bfa2-a7434b1432d7	po	po@traceagile.demo	Paula Owner	$2a$12$Mu07PhBh8ZO8KvVjr9YjLukCwqKdXh3BLf.vq9hGw2KulINVj55Ce	t	f	2026-10-12 11:43:42.171545+00	admin	2026-10-12 11:43:42.171545+00	admin	0
91875ec1-5ed3-4313-a299-02eaaf1c6654	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$5d3CycqNvj7tHrf1QSjCCeSzYCquM0wvB9V1zzlDCFB5YJ4jMODHy	t	f	2026-10-12 11:43:42.363197+00	admin	2026-10-12 11:43:42.363197+00	admin	0
6944f490-8e8f-45c7-b5d6-8d4831abe911	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$9vdKzGiM2vEexj4gj1lcceOGiBG8EnL76fG3ELK1icOfR33Dwwioa	t	f	2026-10-12 11:43:42.550265+00	admin	2026-10-12 11:43:42.550265+00	admin	0
1136d86f-25de-4f3d-a127-f6f3461dd040	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$yi0WOVVIccJAZIXJIHCfk.MXshCs3jiH2GauGpCv1pQ6jr.sAw01S	t	f	2026-10-12 11:43:42.741575+00	admin	2026-10-12 11:43:42.741575+00	admin	0
046765d7-37c2-439b-a290-1f85c11008f6	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$bMZVqoTWDsyBSKMSE5Vw/.gptG0UqNdzVnlqc3ZtAHuOTllayMzxy	t	f	2026-10-12 11:43:42.926448+00	admin	2026-10-12 11:43:42.926448+00	admin	0
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


