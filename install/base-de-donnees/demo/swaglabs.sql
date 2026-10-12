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
    "call_parameters" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL
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
edef7395-d101-49c5-a5a9-f46546d3ccf7	cd53432e-2327-4823-af92-d3964d722dfe	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 10:37:03.179893+00	po	2026-10-12 10:37:03.179893+00	po	0
89c3cfa2-93ca-4b8a-9029-4a3030883882	cd53432e-2327-4823-af92-d3964d722dfe	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 10:37:03.180395+00	po	2026-10-12 10:37:03.180395+00	po	0
2ec07bf1-21c1-418a-aef7-6ae419849a80	0d902e8b-245a-44e3-868e-a0770ea04520	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 10:37:03.221206+00	po	2026-10-12 10:37:03.221206+00	po	0
3b71a4a9-59db-4de3-b621-1b2aa5fc857f	71b894d7-3f09-4db8-91b4-04d1204086ca	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 10:37:03.295916+00	po	2026-10-12 10:37:03.295916+00	po	0
855c2776-9d6d-4cdf-b6ba-d59968aaf077	5bc1d976-5432-464b-a9ed-e890a9f526e1	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 10:37:03.335213+00	po	2026-10-12 10:37:03.335213+00	po	0
d06b4b66-58a8-46db-8a87-510f597b2ab9	13ba4d0e-c713-4a52-a3ca-dba7326c2741	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 10:37:03.374957+00	po	2026-10-12 10:37:03.374957+00	po	0
7590b7be-339e-40de-b64b-c1835b64f1d8	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 10:37:03.44291+00	po	2026-10-12 10:37:03.44291+00	po	0
f0ae7665-209c-403e-bdfc-a1864f5fda20	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 10:37:03.44291+00	po	2026-10-12 10:37:03.44291+00	po	0
2750ac69-92dd-458a-aa14-18f63e8ccd2b	f215e06a-1763-48b7-8096-5578cf556838	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 10:37:03.481556+00	po	2026-10-12 10:37:03.481556+00	po	0
a5292951-2663-4749-b90d-214df3685e50	f215e06a-1763-48b7-8096-5578cf556838	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 10:37:03.481556+00	po	2026-10-12 10:37:03.481556+00	po	0
9b4f3c03-0d42-4713-8e10-7a89994065e0	f70c9457-5d72-4cdf-8253-90cac7809aaf	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 10:37:03.515794+00	po	2026-10-12 10:37:03.515794+00	po	0
836f6cf2-903b-462c-9ab3-fff0d37aee1c	55e3a11c-302b-4cad-91b4-3c41369af8de	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 10:37:03.580825+00	po	2026-10-12 10:37:03.580825+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
96a88abb-a267-47b4-8fed-d1b0af216dc8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	EXECUTION_STEP	6eaf36e0-3480-4af5-b54b-1f6882f69993	sd-defaut-problem-user.png	image/png	235120	0ab0072b-c1e5-4d18-9796-be7c05dae34a	2026-10-12 10:37:49.663439+00	qa2	2026-10-12 10:37:49.663439+00	qa2	0
2ed2886a-d0c3-4a1b-8cad-16f1237e67ce	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEFECT	6da03bf6-4ce1-49be-9477-3e869343ec2d	sd-defaut-problem-user.png	image/png	235120	0ab0072b-c1e5-4d18-9796-be7c05dae34a	2026-10-12 10:37:51.192036+00	qa2	2026-10-12 10:37:51.192036+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
fa0b5750-6893-4a0d-9420-4967014fc5d0	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:03.049641+00	po	2026-10-12 10:37:03.049641+00	po	0
2bd033d7-4599-49ab-aa24-ad6963a6ebac	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	da15b5a2-541d-4180-8768-742787628d0b	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:03.123782+00	po	2026-10-12 10:37:03.123782+00	po	0
584d89b2-50d1-47f9-a750-a057a288cab9	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.180395+00	po	2026-10-12 10:37:03.180395+00	po	0
77d27afc-8d13-423e-b063-82da28f2e078	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.221743+00	po	2026-10-12 10:37:03.221743+00	po	0
9699053b-5864-472e-b8d1-fc01a25f10de	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f398f9a7-5204-4599-bada-e14eeb10f408	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:03.261152+00	po	2026-10-12 10:37:03.261152+00	po	0
abf3d393-495c-4a09-8272-81575458f775	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	71b894d7-3f09-4db8-91b4-04d1204086ca	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.296475+00	po	2026-10-12 10:37:03.296475+00	po	0
9e649ffb-d376-4b0e-9936-44b6efc8682e	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	5bc1d976-5432-464b-a9ed-e890a9f526e1	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.335797+00	po	2026-10-12 10:37:03.335797+00	po	0
d15386bc-5306-406a-bfd1-55f1e6306d5f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	c3f77c83-1f3e-495f-b7e6-35463941159c	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:03.410178+00	po	2026-10-12 10:37:03.410178+00	po	0
e238d405-eae4-4379-9ee0-fd4cc5496d3c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	70fe82e6-66c3-4e34-827b-539a2599c2df	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.133586+00	qa1	2026-10-12 10:37:14.133586+00	qa1	0
ec803fa5-411c-4473-8652-9645f5c29a59	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.375489+00	po	2026-10-12 10:37:03.375489+00	po	0
c89e39ea-49a9-401e-b02b-f2acf01b242c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	55e3a11c-302b-4cad-91b4-3c41369af8de	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.581416+00	po	2026-10-12 10:37:03.581416+00	po	0
f5185ec3-ae55-4c9d-ba99-c26fab4091ed	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	fd3b0a25-4d22-4c38-bb58-c5a037715d10	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:05.288925+00	po	2026-10-12 10:37:05.288925+00	po	0
8c18496a-003b-4449-b50d-119ec13d0b76	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	305b6ae2-f378-4624-bc86-cff3ed3b65e8	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:05.534893+00	po	2026-10-12 10:37:05.534893+00	po	0
a1e21480-3ea1-4460-b276-be9730bfd682	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.416949+00	po	2026-10-12 10:37:06.416949+00	po	0
bb77fdf3-66f9-43ed-ba4a-67b047960e61	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	71b894d7-3f09-4db8-91b4-04d1204086ca	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.448753+00	po	2026-10-12 10:37:06.448753+00	po	0
89a1ef6d-22d0-4885-a159-2ff46d864e56	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.580352+00	po	2026-10-12 10:37:06.580352+00	po	0
15c83493-4b1d-486d-8b25-cc5ba3a5cacd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:07.533808+00	po	2026-10-12 10:37:07.533808+00	po	0
35b67d38-d56d-4d32-affc-8457e53a5692	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:13.991539+00	qa1	2026-10-12 10:37:13.991539+00	qa1	0
e32054e2-53bb-4c0e-bd22-00cc717a34e1	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	d417a76d-678b-46be-b8d3-c5d8dab86e5d	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.067274+00	qa1	2026-10-12 10:37:14.067274+00	qa1	0
8cfafbb1-bcc8-4f90-96a3-68ad69b30e8b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	efe193cb-7bf4-4501-bbe1-e445c6f0322f	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 10:37:14.16426+00	dev	2026-10-12 10:37:14.16426+00	dev	0
e5974c67-4776-4cd8-85e3-1b7ab27ae3d5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	b79c9049-1436-4d92-8485-430df45a30a2	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.308213+00	qa1	2026-10-12 10:37:14.308213+00	qa1	0
630341ae-2f1b-4aad-932a-c01e55d4aa47	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	fb1eb699-aa70-497a-b476-f3d7c21d9024	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.366144+00	qa1	2026-10-12 10:37:14.366144+00	qa1	0
6706d6d0-dcb3-441a-829b-35ec4adfa511	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:15.767052+00	qa1	2026-10-12 10:37:15.767052+00	qa1	0
8bca6c78-ad13-4f99-8bba-4eefea5009e7	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	71b894d7-3f09-4db8-91b4-04d1204086ca	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 10:37:43.96567+00	po	2026-10-12 10:37:43.96567+00	po	0
6b71baba-403e-476d-a173-ce908b0ce166	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.44291+00	po	2026-10-12 10:37:03.44291+00	po	0
1433fdd4-669d-479d-85a8-e8841ba021e5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.482174+00	po	2026-10-12 10:37:03.482174+00	po	0
fdca1927-9943-4f71-ad15-19dce34537c3	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 10:37:03.515794+00	po	2026-10-12 10:37:03.515794+00	po	0
3500c156-1b0c-4759-a7b3-dfe4057d3756	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	9a2557b0-7843-439f-b46b-888ea9f64ae4	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:03.549363+00	po	2026-10-12 10:37:03.549363+00	po	0
2dc295ea-413b-4171-94b7-1b036d4bfb14	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	828db1d0-edff-49d8-a435-92c1e0c141ea	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 10:37:05.568818+00	po	2026-10-12 10:37:05.568818+00	po	0
bafc7748-b0fa-4185-9c0f-93eb23a26ed3	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.381439+00	po	2026-10-12 10:37:06.381439+00	po	0
7f0d73a4-bea7-4054-a133-e6d02e15b354	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	5bc1d976-5432-464b-a9ed-e890a9f526e1	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.481481+00	po	2026-10-12 10:37:06.481481+00	po	0
2c1cdc80-7762-4f2b-9750-30196d5b303f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.514323+00	po	2026-10-12 10:37:06.514323+00	po	0
2bc7cd13-9d1e-4821-9e4c-50cf127791fd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:06.549357+00	po	2026-10-12 10:37:06.549357+00	po	0
65b46cd7-9956-4c2e-9f78-a77830143ccd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	d417a76d-678b-46be-b8d3-c5d8dab86e5d	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["utilisateur = problem_user"], "field": "parameters", "before": null}, {"after": ["Compte du défaut : [{utilisateur=problem_user}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=${utilisateur}}", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 10:37:14.03218+00	qa1	2026-10-12 10:37:14.03218+00	qa1	0
6f449f7f-479f-432b-b4d2-753ed9ca49c5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 10:37:13.921+00	qa1	2026-10-12 10:37:13.921+00	qa1	0
475b7929-c9f4-49b1-9c30-ddc22673b0f0	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	70fe82e6-66c3-4e34-827b-539a2599c2df	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 10:37:14.102637+00	dev	2026-10-12 10:37:14.102637+00	dev	0
c68a32af-858e-41ea-ae50-4753d7a26f55	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	efe193cb-7bf4-4501-bbe1-e445c6f0322f	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.193356+00	qa1	2026-10-12 10:37:14.193356+00	qa1	0
6613ccd1-3d5a-4cd9-9517-4b3bdf9aff38	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	b79c9049-1436-4d92-8485-430df45a30a2	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 10:37:14.279764+00	dev	2026-10-12 10:37:14.279764+00	dev	0
bbeb985a-96e3-4b50-aa04-760388c81c6d	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 10:37:15.805907+00	qa1	2026-10-12 10:37:15.805907+00	qa1	0
f3768961-950f-4de0-9dda-536a519dcfff	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2d39472c-9177-4a9e-a867-ebd6bf1cb114	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 10:37:16.690127+00	dev	2026-10-12 10:37:16.690127+00	dev	0
ff6944f2-c543-4cfd-b0d3-2e2c28baf3df	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2d39472c-9177-4a9e-a867-ebd6bf1cb114	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:16.718191+00	qa1	2026-10-12 10:37:16.718191+00	qa1	0
c583aaa1-6d5e-4cff-93ff-eef4185c360b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	65d69ded-e149-4a18-89ea-ad4963f1f2dd	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:16.830958+00	qa1	2026-10-12 10:37:16.830958+00	qa1	0
8c747aa3-de28-405f-b483-c9a4a47a37e7	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 10:37:21.865596+00	po	2026-10-12 10:37:21.865596+00	po	0
d45de9e2-e7d1-42dd-8cfb-a2a8b206dd3e	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 10:37:22.817547+00	po	2026-10-12 10:37:22.817547+00	po	0
08bdeedc-4d26-49bc-9a78-fd6c1cbf536a	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	8df080af-c8da-4ccb-87a8-c271093fc03e	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 10:37:14.224131+00	dev	2026-10-12 10:37:14.224131+00	dev	0
4b8c6409-9b3c-440d-add2-f6bbb2d189a3	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	fb1eb699-aa70-497a-b476-f3d7c21d9024	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 10:37:14.33951+00	dev	2026-10-12 10:37:14.33951+00	dev	0
3ef2cd1b-c960-4a91-ae04-f3d4fb28a6cd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 10:37:15.692934+00	qa1	2026-10-12 10:37:15.692934+00	qa1	0
07bfe76d-4e77-4854-bcec-5ec2de5d03c9	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	948b1866-8a93-4de1-bda5-b4091b782416	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 10:37:16.746145+00	dev	2026-10-12 10:37:16.746145+00	dev	0
a9303394-e00c-46b2-9406-db9237e1ed54	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 10:37:22.502156+00	po	2026-10-12 10:37:22.502156+00	po	0
6921914e-00c4-4aef-86cb-67cdc303a01a	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RUN	06d0582d-a4d1-454b-8126-98132edd4db4	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 10:37:28.4022+00	dev	2026-10-12 10:37:28.4022+00	dev	0
32e23522-6552-4917-a91f-53571c553a21	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	8df080af-c8da-4ccb-87a8-c271093fc03e	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:14.252157+00	qa1	2026-10-12 10:37:14.252157+00	qa1	0
0625cc2d-e895-4a53-b8b8-af39b497f32e	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	948b1866-8a93-4de1-bda5-b4091b782416	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:16.773638+00	qa1	2026-10-12 10:37:16.773638+00	qa1	0
3b3c408e-fcfa-47d1-91b0-5d204e88596b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2efae0cb-0b1c-424a-9d30-64e7c9921a70	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 10:37:16.859714+00	qa1	2026-10-12 10:37:16.859714+00	qa1	0
2a253aaa-5dac-4cd9-926c-beb885e4d063	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	a2e12230-5cc8-4b6b-b376-382e4edf04ba	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=standard_user}", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 10:37:16.918567+00	qa1	2026-10-12 10:37:16.918567+00	qa1	0
fd8ed6fd-3660-418c-b009-1c7290d468b5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 10:37:22.575291+00	po	2026-10-12 10:37:22.575291+00	po	0
5b46c546-6c66-4bb7-a627-70cecde07a6a	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:23.423013+00	po	2026-10-12 10:37:23.423013+00	po	0
fc1a002f-d53e-43d1-91a2-fc16ea70a9a8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:23.423533+00	po	2026-10-12 10:37:23.423533+00	po	0
8ae7eb15-6a4a-48c8-a9d1-a07f33c9235e	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	71b894d7-3f09-4db8-91b4-04d1204086ca	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:23.42405+00	po	2026-10-12 10:37:23.42405+00	po	0
a4801022-7e0b-49bf-9829-2f10a64bb9b4	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	5bc1d976-5432-464b-a9ed-e890a9f526e1	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:23.42405+00	po	2026-10-12 10:37:23.42405+00	po	0
5543f98d-b3b8-42fc-a5a5-b5f8ace93ed7	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:23.42459+00	po	2026-10-12 10:37:23.42459+00	po	0
fb870dde-4ac7-4247-95f9-00243cb09302	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 10:37:23.42459+00	po	2026-10-12 10:37:23.42459+00	po	0
e561b694-075c-4bbd-87d2-042b76e68383	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	3969851f-c05f-4dd7-a13f-f1999f83f45f	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 10:37:24.719136+00	qa1	2026-10-12 10:37:24.719136+00	qa1	0
9592a5c5-dde4-45f8-adc9-33ebfe4f6ad5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	3969851f-c05f-4dd7-a13f-f1999f83f45f	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 10:37:25.151223+00	qa1	2026-10-12 10:37:25.151223+00	qa1	0
b7073b5c-3c04-49af-af17-f39524606c43	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	3969851f-c05f-4dd7-a13f-f1999f83f45f	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 10:37:43.792331+00	qa1	2026-10-12 10:37:43.792331+00	qa1	0
237f59bb-7f53-42d2-b5af-7727ef38ebc4	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 10:37:43.925327+00	po	2026-10-12 10:37:43.925327+00	po	0
b6a65b5d-83cc-4d48-bb52-7717fb6d0775	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	5bc1d976-5432-464b-a9ed-e890a9f526e1	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 10:37:44.006323+00	po	2026-10-12 10:37:44.006323+00	po	0
0555f2ec-98af-4d96-ae18-0d3457906a95	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 10:37:45.456001+00	po	2026-10-12 10:37:45.456001+00	po	0
fc5f6861-ae9f-4a5c-a0fb-7b4d56c333cb	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	8de13d5e-7b51-4085-a29b-c7bf3a902d02	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 10:37:46.975469+00	po	2026-10-12 10:37:46.975469+00	po	0
74b9ec9d-4dc5-4ef1-8c82-85e60ed9d76c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:47.020335+00	po	2026-10-12 10:37:47.020335+00	po	0
a831c940-91db-4b18-b086-d6b77c83c998	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:47.020335+00	po	2026-10-12 10:37:47.020335+00	po	0
0402f01c-22f6-42b8-a59c-f461cfa297ab	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 10:37:47.020335+00	po	2026-10-12 10:37:47.020335+00	po	0
180351de-e101-42d2-81a9-e66ec15febe6	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	8de13d5e-7b51-4085-a29b-c7bf3a902d02	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 10:37:47.021008+00	po	2026-10-12 10:37:47.021008+00	po	0
20b9732e-9bd2-4aab-b7a2-9c92cc3065f7	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	65d69ded-e149-4a18-89ea-ad4963f1f2dd	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 10:37:16.801731+00	dev	2026-10-12 10:37:16.801731+00	dev	0
82122c67-5586-43ee-9568-1002fbac66b1	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2efae0cb-0b1c-424a-9d30-64e7c9921a70	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:16.888033+00	qa1	2026-10-12 10:37:16.888033+00	qa1	0
f1d937be-89eb-49a6-a781-e5902c2f53ba	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	a2e12230-5cc8-4b6b-b376-382e4edf04ba	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 10:37:16.9515+00	qa1	2026-10-12 10:37:16.9515+00	qa1	0
79a89164-aba4-494b-9dc9-97bde0167247	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RELEASE	88ca15c8-8b12-47b9-8e34-2ec313fd6308	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 10:37:21.837473+00	po	2026-10-12 10:37:21.837473+00	po	0
524f5b49-61a7-4303-aa00-68068dff8477	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 10:37:22.738872+00	po	2026-10-12 10:37:22.738872+00	po	0
1a139894-3e08-40ce-bb17-a32683fafd36	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	3969851f-c05f-4dd7-a13f-f1999f83f45f	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 10:37:25.033779+00	qa1	2026-10-12 10:37:25.033779+00	qa1	0
7dc97de6-f908-460f-87c6-6b31bbcac0c5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 10:37:43.874256+00	po	2026-10-12 10:37:43.874256+00	po	0
0d66ea10-9a19-4fbd-a4a6-38e1180f56e1	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	8de13d5e-7b51-4085-a29b-c7bf3a902d02	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 10:37:21.908142+00	po	2026-10-12 10:37:21.908142+00	po	0
6b411771-60dd-4660-8bf1-1020b9eb0a73	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 10:37:22.655138+00	po	2026-10-12 10:37:22.655138+00	po	0
cfdb03a9-3ccd-4e51-ac0a-9106d3578947	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	290019ac-8b07-4898-9b51-aa90a7d32561	CMP-2	UPDATED	[{"after": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 10:37:48.037136+00	qa1	2026-10-12 10:37:48.037136+00	qa1	0
6bae7bd6-68f8-4a8e-8a53-28a53308ba5a	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 10:37:46.279042+00	po	2026-10-12 10:37:46.279042+00	po	0
c07ee54e-2954-4603-8a43-a2d2e1b0330b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	290019ac-8b07-4898-9b51-aa90a7d32561	CMP-2	UPDATED	[{"after": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 10:37:48.059462+00	qa1	2026-10-12 10:37:48.059462+00	qa1	0
3cc7814a-c216-4e2a-812c-83c99cb4c494	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	290019ac-8b07-4898-9b51-aa90a7d32561	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 10:37:48.009404+00	qa1	2026-10-12 10:37:48.009404+00	qa1	0
34f4291a-a562-411c-926b-113191af8796	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEFECT	6da03bf6-4ce1-49be-9477-3e869343ec2d	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n**Jeu de données** : Compte du défaut, ligne 1\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 10:37:51.185636+00	qa2	2026-10-12 10:37:51.185636+00	qa2	0
e332233f-cc18-4241-8888-fb1a5e40b405	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SESSION	d8b7ba28-b53b-4319-b572-b4403072610b	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 10:37:53.858645+00	qa1	2026-10-12 10:37:53.858645+00	qa1	0
b23cb5b2-f4c1-4d1f-a5df-dbecb374052b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEFECT	957b2325-8da5-4471-b0e9-deca9de911dc	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 00:00\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 10:37:54.882582+00	qa1	2026-10-12 10:37:54.882582+00	qa1	0
92f1232a-ecd8-44f5-9b36-2cecf0ee6c69	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SESSION	d8b7ba28-b53b-4319-b572-b4403072610b	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 10:37:56.230618+00	qa1	2026-10-12 10:37:56.230618+00	qa1	0
109f39ee-c386-4842-b867-99c945b585bc	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SESSION	d8b7ba28-b53b-4319-b572-b4403072610b	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 10:37:56.442713+00	qa1	2026-10-12 10:37:56.442713+00	qa1	0
4f2aa3e5-5f72-4853-b03b-280107771ed3	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SESSION	d8b7ba28-b53b-4319-b572-b4403072610b	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 10:37:56.978416+00	po	2026-10-12 10:37:56.978416+00	po	0
82e7ffc0-033e-4593-ba8a-d0b2464f9ee3	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RUN	d4d24782-4057-4028-84a5-89cd77aafae6	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 10:37:58.360223+00	dev	2026-10-12 10:37:58.360223+00	dev	0
47a4d06c-03ec-4885-8df6-d5d836870e6b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CAMPAIGN	53ef4dff-58ee-49f8-935b-69e6ed19561c	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 10:38:14.144612+00	qa1	2026-10-12 10:38:14.144612+00	qa1	0
49a9ea27-8d6d-4148-9f44-79d5ad5bd7ea	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 10:38:23.067273+00	po	2026-10-12 10:38:23.067273+00	po	0
503cfd3c-1256-4ed7-8679-3d7640790864	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	b79c9049-1436-4d92-8485-430df45a30a2	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 10:38:23.074828+00	po	2026-10-12 10:38:23.074828+00	po	0
69373e78-a18f-4e1e-87e2-cee70d347502	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TRACE_LINK	37491779-9cbc-47c7-be97-9c5b626668a8	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 10:38:23.715827+00	qa1	2026-10-12 10:38:23.715827+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
06d0582d-a4d1-454b-8126-98132edd4db4	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RUN-1	1	3969851f-c05f-4dd7-a13f-f1999f83f45f	b56fc638-1aff-47d6-86b0-abbce184b15a	COMPLETED	dev	2026-10-12 10:37:28.397954+00	2026-10-12 10:37:28.441845+00	2026-10-12 10:37:28.439554+00	2026-10-12 10:37:42.129591+00	2026-10-12 10:37:42.129591+00	recette	1.0.0-s1	job-ccde8e92	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-ccde8e92/logs	http://localhost:8091/api/v1/jobs/job-ccde8e92/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 10:37:28.401131+00	dev	2026-10-12 10:37:42.143307+00	anonymousUser	10
d4d24782-4057-4028-84a5-89cd77aafae6	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RUN-2	2	290019ac-8b07-4898-9b51-aa90a7d32561	b56fc638-1aff-47d6-86b0-abbce184b15a	COMPLETED	dev	2026-10-12 10:37:58.359173+00	2026-10-12 10:37:58.389731+00	2026-10-12 10:37:58.388792+00	2026-10-12 10:38:11.226943+00	2026-10-12 10:38:11.226943+00	recette	1.0.0-s2	job-8a32e445	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-8a32e445/logs	http://localhost:8091/api/v1/jobs/job-8a32e445/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 10:37:58.35968+00	dev	2026-10-12 10:38:11.240236+00	anonymousUser	10
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
659f6137-a949-4e51-a6c3-a8a0f1d2e21e	70fe82e6-66c3-4e34-827b-539a2599c2df	DATA_DRIVEN	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 10:37:14.096716+00	dev	2026-10-12 10:37:14.096716+00	dev	0
bd08f59b-b80e-4312-9973-3326773021a3	efe193cb-7bf4-4501-bbe1-e445c6f0322f	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 10:37:14.161367+00	dev	2026-10-12 10:37:14.161367+00	dev	0
ae6443b9-a97e-4c26-9729-d03157367b48	8df080af-c8da-4ccb-87a8-c271093fc03e	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 10:37:14.220243+00	dev	2026-10-12 10:37:14.220243+00	dev	0
d77eda6f-eb78-4081-a0a1-fc6462c0e413	b79c9049-1436-4d92-8485-430df45a30a2	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 10:37:14.276564+00	dev	2026-10-12 10:37:14.276564+00	dev	0
c78cb332-4540-4477-8d20-5c22930246da	fb1eb699-aa70-497a-b476-f3d7c21d9024	API	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 10:37:14.33638+00	dev	2026-10-12 10:37:14.33638+00	dev	0
86da462f-8264-4825-98a1-550cb366fc08	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	BDD	Playwright	\N	file:///depots/traceagile	installation-hors-docker	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 10:37:15.676931+00	qa1	2026-10-12 10:37:15.806936+00	qa1	1
73d609c1-a5d5-494d-a357-0349f8f00eee	2d39472c-9177-4a9e-a867-ebd6bf1cb114	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 10:37:16.685905+00	dev	2026-10-12 10:37:16.685905+00	dev	0
5bad9b9c-7122-4a86-bce0-34a55f83b0ff	948b1866-8a93-4de1-bda5-b4091b782416	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 10:37:16.743639+00	dev	2026-10-12 10:37:16.743639+00	dev	0
a246dbeb-f7e3-4399-bc0e-6622176d5570	65d69ded-e149-4a18-89ea-ad4963f1f2dd	PERFORMANCE	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 10:37:16.798707+00	dev	2026-10-12 10:37:16.798707+00	dev	0
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
32c433b0-dece-4bef-b2fb-cdfd25326ad1	BDD	Cucumber-JVM	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
2588b557-bfa7-4636-ab41-8657a62c5322	BDD	Cucumber-JS	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
a5fbee77-1bf5-4742-81fe-86572404f2a7	BDD	Behave	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
6cb68457-1f7e-4dc9-89fa-21a0ccff33e7	BDD	SpecFlow	4	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
8d196397-e577-4a5a-b7fd-a14bf8a51534	BDD	Karate	5	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
a1f4cf32-988f-4af0-9f7d-b447da649b58	UNIT	JUnit 5	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
96614d62-19e0-4168-876c-30319baf9d40	UNIT	Kotest	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
5099dc8f-a44e-4bc8-9fc5-d106c3e3e8b4	UNIT	pytest	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
dd35c9ad-b418-4ac4-9599-59bf9e5e6abb	UNIT	Jest	4	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
3207ed82-04a9-466d-8c3b-7f75fe2c5e56	UNIT	Vitest	5	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
970c6d79-fa24-4f70-bad2-58c888c50225	UI	Playwright	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
e00adf87-1bf2-4e0e-90d6-57988f72363b	UI	Selenium	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
3a06af2e-6252-48d3-a038-e51d1616f8d2	UI	Cypress	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
2329663c-969d-4f0a-b41b-d090691588ce	UI	Appium	4	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
c8e999fa-6f2a-4033-aa3b-934f3d948a02	API	REST Assured	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
bae785a0-f1f8-4ebd-97fa-9cbf33f6d849	API	Karate	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
205f0e7b-76dd-4d20-9aea-36172a64dadf	API	Postman/Newman	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
545b8aaf-8c23-4e6b-abc5-383469a253a2	API	pytest + requests	4	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
91a5a3f8-37da-4124-a9c4-41022909b3f5	KEYWORD	Robot Framework	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
1ea65d1f-9277-4e85-9668-a9481e90baf6	DATA_DRIVEN	JUnit 5	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
69994ce6-3b07-4417-94b6-9e19349b39e7	DATA_DRIVEN	pytest	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
299d576f-a1e6-4142-8e9f-25fab0b7b38e	DATA_DRIVEN	Playwright	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
0ed68c11-4484-4954-9984-4bf1973298e4	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
5fb4bc60-c271-4ada-abe8-22fe4cf1ee9a	PERFORMANCE	Gatling	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
bc298920-2bca-4a75-8dd1-bbd6210cc574	PERFORMANCE	k6	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
76d12871-dcdb-4c7f-90d1-41136f0bab00	PERFORMANCE	JMeter	3	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
cd8b7f92-ef2b-41df-acf0-8e3f38c56d5e	CONTRACT	Pact	1	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
b4e2bd75-352b-4ba0-a8e6-4fb930ab4764	CONTRACT	Spring Cloud Contract	2	2026-10-12 10:36:43.271654+00	system	2026-10-12 10:36:43.271654+00	system	0
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
7f8d4d86-a018-4527-b628-5f88ed390e53	3969851f-c05f-4dd7-a13f-f1999f83f45f	70fe82e6-66c3-4e34-827b-539a2599c2df	1	\N	4	12	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.023441+00	qa1	0	\N	\N
4f259805-dacf-443f-8d75-d31a5d0b0c9f	3969851f-c05f-4dd7-a13f-f1999f83f45f	efe193cb-7bf4-4501-bbe1-e445c6f0322f	1	\N	5	6	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.023441+00	qa1	0	\N	\N
6bd0afff-7548-4ce0-b29f-91d7e7e6beb4	3969851f-c05f-4dd7-a13f-f1999f83f45f	8df080af-c8da-4ccb-87a8-c271093fc03e	1	\N	6	3	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.023441+00	qa1	0	\N	\N
6716637d-6dd3-4f38-b38a-6eecc4d18ea3	3969851f-c05f-4dd7-a13f-f1999f83f45f	b79c9049-1436-4d92-8485-430df45a30a2	1	\N	7	3	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.023441+00	qa1	0	\N	\N
cc032049-d8a0-4d70-8229-0f4b0c39dc87	3969851f-c05f-4dd7-a13f-f1999f83f45f	fb1eb699-aa70-497a-b476-f3d7c21d9024	1	\N	8	6	2026-10-12 10:37:25.14914+00	qa1	2026-10-12 10:37:25.14914+00	qa1	0	\N	\N
0be3bc29-cabe-4450-aa42-db2c9831ca22	3969851f-c05f-4dd7-a13f-f1999f83f45f	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	449d3ab1-5074-41d6-bf82-961a64c725fb	1	16	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.192155+00	qa1	1	Comptes	0
3d61d8b4-eab8-467f-a795-7dea76f4a108	3969851f-c05f-4dd7-a13f-f1999f83f45f	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	449d3ab1-5074-41d6-bf82-961a64c725fb	2	16	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.211112+00	qa1	1	Comptes	1
1574d1b1-dc2f-450e-a785-f1c310f5cfe8	3969851f-c05f-4dd7-a13f-f1999f83f45f	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	449d3ab1-5074-41d6-bf82-961a64c725fb	3	16	2026-10-12 10:37:25.023441+00	qa1	2026-10-12 10:37:25.229748+00	qa1	1	Comptes	2
5f289d35-3a97-4ab8-9eff-69588e32e2b0	290019ac-8b07-4898-9b51-aa90a7d32561	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	2	\N	3	12	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.031765+00	qa1	0	\N	\N
0fac2ad5-33ab-43af-9bf5-aba55d521fbd	290019ac-8b07-4898-9b51-aa90a7d32561	2d39472c-9177-4a9e-a867-ebd6bf1cb114	1	\N	4	12	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.031765+00	qa1	0	\N	\N
cda9590a-cffd-4fc1-9398-f7bd578a21f7	290019ac-8b07-4898-9b51-aa90a7d32561	948b1866-8a93-4de1-bda5-b4091b782416	1	\N	7	6	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.031765+00	qa1	0	\N	\N
785b96a6-509e-4f02-8811-8a0df76484e8	290019ac-8b07-4898-9b51-aa90a7d32561	65d69ded-e149-4a18-89ea-ad4963f1f2dd	1	\N	8	6	2026-10-12 10:37:48.057805+00	qa1	2026-10-12 10:37:48.057805+00	qa1	0	\N	\N
3aae6490-dcb1-451a-8933-a217f203af20	290019ac-8b07-4898-9b51-aa90a7d32561	d417a76d-678b-46be-b8d3-c5d8dab86e5d	1	e7b3425c-50cb-4ea4-988e-ab36afd76881	1	16	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.091272+00	qa1	1	Compte du défaut	0
05b9b873-b91a-4e4e-9233-dba68d9c875a	290019ac-8b07-4898-9b51-aa90a7d32561	2efae0cb-0b1c-424a-9d30-64e7c9921a70	1	449d3ab1-5074-41d6-bf82-961a64c725fb	2	16	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.106093+00	qa1	1	\N	\N
6b9a4caf-575e-4474-a51c-a276540b3c0c	290019ac-8b07-4898-9b51-aa90a7d32561	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	449d3ab1-5074-41d6-bf82-961a64c725fb	5	12	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.120184+00	qa1	1	Produits	0
51613d70-9040-4630-83e3-76a976216733	290019ac-8b07-4898-9b51-aa90a7d32561	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	449d3ab1-5074-41d6-bf82-961a64c725fb	6	12	2026-10-12 10:37:48.031765+00	qa1	2026-10-12 10:37:48.135301+00	qa1	1	Produits	1
941f10a7-eba9-4c8d-849c-abad6a442db6	53ef4dff-58ee-49f8-935b-69e6ed19561c	fb1eb699-aa70-497a-b476-f3d7c21d9024	1	\N	1	0	2026-10-12 10:38:15.296198+00	qa1	2026-10-12 10:38:15.296198+00	qa1	0	\N	\N
d48ffcc5-d03f-4b9f-a030-5274a2bc0368	53ef4dff-58ee-49f8-935b-69e6ed19561c	70fe82e6-66c3-4e34-827b-539a2599c2df	1	\N	2	0	2026-10-12 10:38:15.304264+00	qa1	2026-10-12 10:38:15.304264+00	qa1	0	\N	\N
b42b3c48-b536-44b3-b5b3-aeb097410af1	53ef4dff-58ee-49f8-935b-69e6ed19561c	efe193cb-7bf4-4501-bbe1-e445c6f0322f	1	\N	3	0	2026-10-12 10:38:15.308974+00	qa1	2026-10-12 10:38:15.308974+00	qa1	0	\N	\N
4a48bad4-2db0-4293-bef1-769d35bfe69f	53ef4dff-58ee-49f8-935b-69e6ed19561c	8df080af-c8da-4ccb-87a8-c271093fc03e	1	\N	4	0	2026-10-12 10:38:15.314373+00	qa1	2026-10-12 10:38:15.314373+00	qa1	0	\N	\N
e3a8195e-c62a-4440-a83a-a900d35c2d85	53ef4dff-58ee-49f8-935b-69e6ed19561c	b79c9049-1436-4d92-8485-430df45a30a2	1	\N	5	0	2026-10-12 10:38:15.319578+00	qa1	2026-10-12 10:38:15.319578+00	qa1	0	\N	\N
a6aaad51-adf4-41e0-8e74-0e835ff908b3	53ef4dff-58ee-49f8-935b-69e6ed19561c	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	2	\N	6	0	2026-10-12 10:38:15.324863+00	qa1	2026-10-12 10:38:15.324863+00	qa1	0	\N	\N
54686c2f-3dfa-455c-a031-48ce591043b1	53ef4dff-58ee-49f8-935b-69e6ed19561c	2d39472c-9177-4a9e-a867-ebd6bf1cb114	1	\N	7	0	2026-10-12 10:38:15.33061+00	qa1	2026-10-12 10:38:15.33061+00	qa1	0	\N	\N
862a2f44-7cdc-49f1-b2cb-4d682ec2a9ac	53ef4dff-58ee-49f8-935b-69e6ed19561c	948b1866-8a93-4de1-bda5-b4091b782416	1	\N	8	0	2026-10-12 10:38:15.335363+00	qa1	2026-10-12 10:38:15.335363+00	qa1	0	\N	\N
83f17ffc-78a0-4205-a3d6-fd638517134c	53ef4dff-58ee-49f8-935b-69e6ed19561c	65d69ded-e149-4a18-89ea-ad4963f1f2dd	1	\N	9	0	2026-10-12 10:38:15.340085+00	qa1	2026-10-12 10:38:15.340085+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
3969851f-c05f-4dd7-a13f-f1999f83f45f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CMP-1	1	Recette sprint 1	SPRINT	2aa9194b-0707-4654-b4e2-98d62f8d2320	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 10:37:24.717627+00	qa1	2026-10-12 10:37:43.79285+00	qa1	3	Release 1.0/Recettes de sprint
290019ac-8b07-4898-9b51-aa90a7d32561	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CMP-2	2	Recette sprint 2	SPRINT	8de13d5e-7b51-4085-a29b-c7bf3a902d02	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 10:37:48.008898+00	qa1	2026-10-12 10:37:48.975897+00	qa2	2	Release 1.0/Recettes de sprint
53ef4dff-58ee-49f8-935b-69e6ed19561c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CMP-3	3	Intégration continue — main	RELEASE	\N	88ca15c8-8b12-47b9-8e34-2ec313fd6308	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 10:38:14.143954+00	qa1	2026-10-12 10:38:15.298404+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
db4e41d8-809c-4f4d-a3f1-9c4cb49706ef	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 10:37:00.097748+00	admin	2026-10-12 10:37:00.097748+00	admin	0
c0a88675-cbe2-4bda-bae4-14734af577d5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 10:37:00.098327+00	admin	2026-10-12 10:37:00.098327+00	admin	0
5fe4b3ce-1767-4329-bc10-7f4446ba51c5	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 10:37:00.098327+00	admin	2026-10-12 10:37:00.098327+00	admin	0
14ae49fa-3e75-4b60-ae5e-3ab7162d39cf	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 10:37:00.098327+00	admin	2026-10-12 10:37:00.098327+00	admin	0
7815ae60-7fa7-4754-b50a-cd616cf03aad	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 10:37:00.098834+00	admin	2026-10-12 10:37:00.098834+00	admin	0
2c38c97f-e0f4-431d-abe0-0bc2b7db3f41	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 10:37:00.098834+00	admin	2026-10-12 10:37:00.098834+00	admin	0
a66c9a15-4408-4ab5-940d-9b97e66953f2	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DOD	4	Code revu et intégré	\N	2026-10-12 10:37:00.098834+00	admin	2026-10-12 10:37:00.098834+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ca88a906-f50b-48a1-860d-983554a7f39e	55e3a11c-302b-4cad-91b4-3c41369af8de	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 10:37:10.29403+00	po	2026-10-12 10:37:10.29403+00	po	0
962797d5-ca32-479c-9f26-9417e3d22609	f215e06a-1763-48b7-8096-5578cf556838	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 10:37:11.261026+00	po	2026-10-12 10:37:11.261026+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
6da03bf6-4ce1-49be-9477-3e869343ec2d	053cb7ef-b296-422f-acb9-b9486f9592ce
957b2325-8da5-4471-b0e9-deca9de911dc	004b7330-a4ab-4222-bfbf-548a55300ded
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
6da03bf6-4ce1-49be-9477-3e869343ec2d	f215e06a-1763-48b7-8096-5578cf556838
6da03bf6-4ce1-49be-9477-3e869343ec2d	f70c9457-5d72-4cdf-8253-90cac7809aaf
957b2325-8da5-4471-b0e9-deca9de911dc	f215e06a-1763-48b7-8096-5578cf556838
957b2325-8da5-4471-b0e9-deca9de911dc	f70c9457-5d72-4cdf-8253-90cac7809aaf
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
6da03bf6-4ce1-49be-9477-3e869343ec2d	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n**Jeu de données** : Compte du défaut, ligne 1\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 10:37:51.184481+00	qa2	2026-10-12 10:37:51.192036+00	qa2	1
957b2325-8da5-4471-b0e9-deca9de911dc	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 00:00\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 10:37:54.882582+00	qa1	2026-10-12 10:37:54.884523+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2ee4937f-8893-44ef-b8c4-356e79255775	55e3a11c-302b-4cad-91b4-3c41369af8de	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 10:37:09.942572+00	po	2026-10-12 10:37:09.942572+00	po	0
54da7adb-b175-436c-b61d-42c163d5dbfd	55e3a11c-302b-4cad-91b4-3c41369af8de	EXAMPLE	2ee4937f-8893-44ef-b8c4-356e79255775	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 10:37:10.020803+00	po	2026-10-12 10:37:10.020803+00	po	0
a34cb763-558d-4738-830d-660a40253ecc	55e3a11c-302b-4cad-91b4-3c41369af8de	EXAMPLE	2ee4937f-8893-44ef-b8c4-356e79255775	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 10:37:10.087514+00	po	2026-10-12 10:37:10.087514+00	po	0
48f1bf79-34b6-435b-a6b0-92500515a694	55e3a11c-302b-4cad-91b4-3c41369af8de	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 10:37:10.146624+00	po	2026-10-12 10:37:10.146624+00	po	0
c13cdbd9-4b6a-4992-b5fb-3ef09c193c46	55e3a11c-302b-4cad-91b4-3c41369af8de	EXAMPLE	48f1bf79-34b6-435b-a6b0-92500515a694	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 10:37:10.218487+00	po	2026-10-12 10:37:10.218487+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b56fc638-1aff-47d6-86b0-abbce184b15a	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Cucumber-JS"]	[]	4	t	2026-10-12 10:37:01.522462+00	admin	2026-10-12 10:38:07.703817+00	system	3
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
ae67dd1f-856b-45de-8904-5b55da5d9a15	0be3bc29-cabe-4450-aa42-db2c9831ca22	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	1	PASSED	f	2026-10-12 10:37:26.07655+00	2026-10-12 10:37:26.793552+00	717	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 10:37:26.08213+00	qa1	2026-10-12 10:37:26.795149+00	qa1	1	\N
0493be26-cdf1-412e-9d9b-47c47038ca15	3d61d8b4-eab8-467f-a795-7dea76f4a108	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	1	PASSED	f	2026-10-12 10:37:26.839837+00	2026-10-12 10:37:26.881612+00	41	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 10:37:26.842424+00	qa1	2026-10-12 10:37:26.882652+00	qa1	1	\N
250922ba-4081-4532-a95d-25f5cd793b24	1574d1b1-dc2f-450e-a785-f1c310f5cfe8	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	1	PASSED	f	2026-10-12 10:37:26.897112+00	2026-10-12 10:37:26.93023+00	33	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 10:37:26.898669+00	qa1	2026-10-12 10:37:26.931259+00	qa1	1	\N
f539e881-1619-4978-bdb5-b205e87f5f90	cc032049-d8a0-4d70-8229-0f4b0c39dc87	fb1eb699-aa70-497a-b476-f3d7c21d9024	1	1	PASSED	f	2026-10-12 10:37:37.728091+00	2026-10-12 10:37:40.43206+00	2703	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:28.4022+00	dev	2026-10-12 10:37:40.45855+00	anonymousUser	2	06d0582d-a4d1-454b-8126-98132edd4db4
fa3eb3cc-2622-4085-9aa7-e5fda5ad1d77	6bd0afff-7548-4ce0-b29f-91d7e7e6beb4	8df080af-c8da-4ccb-87a8-c271093fc03e	1	1	PASSED	f	2026-10-12 10:37:37.728148+00	2026-10-12 10:37:40.827724+00	3099	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:28.4022+00	dev	2026-10-12 10:37:40.840474+00	anonymousUser	2	06d0582d-a4d1-454b-8126-98132edd4db4
1b943ff6-ff16-4eb6-acd3-4dabbe30b779	4f259805-dacf-443f-8d75-d31a5d0b0c9f	efe193cb-7bf4-4501-bbe1-e445c6f0322f	1	1	PASSED	f	2026-10-12 10:37:37.728049+00	2026-10-12 10:37:40.988021+00	3260	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:28.401658+00	dev	2026-10-12 10:37:40.999331+00	anonymousUser	2	06d0582d-a4d1-454b-8126-98132edd4db4
ce740398-a203-44b4-b0d8-6ec2f7f68804	7f8d4d86-a018-4527-b628-5f88ed390e53	70fe82e6-66c3-4e34-827b-539a2599c2df	1	1	PASSED	f	2026-10-12 10:37:37.727996+00	2026-10-12 10:37:41.09433+00	3366	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:28.401658+00	dev	2026-10-12 10:37:41.108443+00	anonymousUser	2	06d0582d-a4d1-454b-8126-98132edd4db4
eae6d57d-6fc7-4c57-a276-c97ecd2f19dc	6716637d-6dd3-4f38-b38a-6eecc4d18ea3	b79c9049-1436-4d92-8485-430df45a30a2	1	1	PASSED	f	2026-10-12 10:37:40.480636+00	2026-10-12 10:37:42.106858+00	1626	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:28.4022+00	dev	2026-10-12 10:37:42.116019+00	anonymousUser	2	06d0582d-a4d1-454b-8126-98132edd4db4
053cb7ef-b296-422f-acb9-b9486f9592ce	3aae6490-dcb1-451a-8933-a217f203af20	d417a76d-678b-46be-b8d3-c5d8dab86e5d	1	1	FAILED	f	2026-10-12 10:37:48.972151+00	2026-10-12 10:37:49.756199+00	784	\N	qa2	MANUAL	Compte du défaut	0	{"utilisateur": "problem_user"}	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.757253+00	qa2	1	\N
f7ee183d-9b22-4c80-a824-31671222eff0	6b9a4caf-575e-4474-a51c-a276540b3c0c	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	1	PASSED	f	2026-10-12 10:37:51.776067+00	2026-10-12 10:37:52.690181+00	914	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 10:37:51.778668+00	qa1	2026-10-12 10:37:52.691193+00	qa1	1	\N
d54726ff-b7b5-45e7-9901-6bfa1273c5d5	51613d70-9040-4630-83e3-76a976216733	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	1	PASSED	f	2026-10-12 10:37:52.737379+00	2026-10-12 10:37:52.800298+00	62	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 10:37:52.739947+00	qa1	2026-10-12 10:37:52.801345+00	qa1	1	\N
004b7330-a4ab-4222-bfbf-548a55300ded	05b9b873-b91a-4e4e-9233-dba68d9c875a	2efae0cb-0b1c-424a-9d30-64e7c9921a70	1	1	FAILED	f	2026-10-12 10:37:53.854222+00	2026-10-12 10:37:56.226672+00	2000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 10:37:53.858102+00	qa1	2026-10-12 10:37:56.230618+00	qa1	1	\N
a78eddad-080c-4de3-bbcf-ebff3966851d	5f289d35-3a97-4ab8-9eff-69588e32e2b0	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	1	2	PASSED	f	2026-10-12 10:38:05.484129+00	2026-10-12 10:38:08.120791+00	2636	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:58.35968+00	dev	2026-10-12 10:38:08.130041+00	anonymousUser	2	d4d24782-4057-4028-84a5-89cd77aafae6
9a6a019d-8b6b-4043-95f0-6a2af83fa059	785b96a6-509e-4f02-8811-8a0df76484e8	65d69ded-e149-4a18-89ea-ad4963f1f2dd	1	1	PASSED	f	2026-10-12 10:38:05.484187+00	2026-10-12 10:38:08.949125+00	3464	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:58.360223+00	dev	2026-10-12 10:38:08.959596+00	anonymousUser	2	d4d24782-4057-4028-84a5-89cd77aafae6
d01be9f8-cc3d-4797-8d01-b1575eb5d0ff	0fac2ad5-33ab-43af-9bf5-aba55d521fbd	2d39472c-9177-4a9e-a867-ebd6bf1cb114	1	1	PASSED	f	2026-10-12 10:37:58.359173+00	2026-10-12 10:38:10.060915+00	4576	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:58.360223+00	dev	2026-10-12 10:38:10.069663+00	anonymousUser	1	d4d24782-4057-4028-84a5-89cd77aafae6
f9dd6fe0-1979-4349-8be3-7aeaf4777caa	cda9590a-cffd-4fc1-9398-f7bd578a21f7	948b1866-8a93-4de1-bda5-b4091b782416	1	1	FAILED	f	2026-10-12 10:38:05.484104+00	2026-10-12 10:38:11.201971+00	5717	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-8a32e445/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 10:37:58.360223+00	dev	2026-10-12 10:38:11.215687+00	anonymousUser	2	d4d24782-4057-4028-84a5-89cd77aafae6
e5819c5c-07c2-4560-bd2a-71de0fbf0d46	941f10a7-eba9-4c8d-849c-abad6a442db6	fb1eb699-aa70-497a-b476-f3d7c21d9024	1	1	PASSED	f	2026-10-12 10:38:14.732615+00	2026-10-12 10:38:15.294615+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.297874+00	qa1	2026-10-12 10:38:15.297874+00	qa1	0	\N
35de3f7f-42ae-4595-a929-549a28c27350	d48ffcc5-d03f-4b9f-a030-5274a2bc0368	70fe82e6-66c3-4e34-827b-539a2599c2df	1	1	PASSED	f	2026-10-12 10:38:11.779615+00	2026-10-12 10:38:15.294615+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.30585+00	qa1	2026-10-12 10:38:15.30585+00	qa1	0	\N
dfd709c5-0c9e-49d7-98e8-66979a50d8ea	b42b3c48-b536-44b3-b5b3-aeb097410af1	efe193cb-7bf4-4501-bbe1-e445c6f0322f	1	1	PASSED	f	2026-10-12 10:38:12.089615+00	2026-10-12 10:38:15.294615+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.310517+00	qa1	2026-10-12 10:38:15.310517+00	qa1	0	\N
b047904b-c79e-4a40-8916-b40ff3770ca1	4a48bad4-2db0-4293-bef1-769d35bfe69f	8df080af-c8da-4ccb-87a8-c271093fc03e	1	1	PASSED	f	2026-10-12 10:38:14.852615+00	2026-10-12 10:38:15.294615+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.315955+00	qa1	2026-10-12 10:38:15.315955+00	qa1	0	\N
e93afea7-7da6-4c4a-b9d5-33de622b5cf7	e3a8195e-c62a-4440-a83a-a900d35c2d85	b79c9049-1436-4d92-8485-430df45a30a2	1	1	PASSED	f	2026-10-12 10:38:14.757615+00	2026-10-12 10:38:15.294615+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.321177+00	qa1	2026-10-12 10:38:15.321177+00	qa1	0	\N
30f1db9a-d940-4695-9754-ba619ab1d4f0	a6aaad51-adf4-41e0-8e74-0e835ff908b3	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	1	2	PASSED	f	2026-10-12 10:38:14.607615+00	2026-10-12 10:38:15.294615+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.326414+00	qa1	2026-10-12 10:38:15.326414+00	qa1	0	\N
136d7533-a773-4ab9-9520-41144daacde6	54686c2f-3dfa-455c-a031-48ce591043b1	2d39472c-9177-4a9e-a867-ebd6bf1cb114	1	1	PASSED	f	2026-10-12 10:38:14.747615+00	2026-10-12 10:38:15.294615+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.331673+00	qa1	2026-10-12 10:38:15.331673+00	qa1	0	\N
d7d3edc7-c07a-4a12-ac96-ecff837e2c95	862a2f44-7cdc-49f1-b2cb-4d682ec2a9ac	948b1866-8a93-4de1-bda5-b4091b782416	1	1	FAILED	f	2026-10-12 10:38:11.826615+00	2026-10-12 10:38:15.294615+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.336947+00	qa1	2026-10-12 10:38:15.336947+00	qa1	0	\N
73a3b6cd-c6df-4e2a-984b-0bc0c50e25a2	83f17ffc-78a0-4205-a3d6-fd638517134c	65d69ded-e149-4a18-89ea-ad4963f1f2dd	1	1	PASSED	f	2026-10-12 10:38:14.480615+00	2026-10-12 10:38:15.294615+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 10:38:15.341363+00	qa1	2026-10-12 10:38:15.341363+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
cc128aa5-96a7-494a-8270-a5e0c4af9d3d	2efae0cb-0b1c-424a-9d30-64e7c9921a70	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 10:37:16.854606+00	qa1	2026-10-12 10:37:16.854606+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d8b7ba28-b53b-4319-b572-b4403072610b	004b7330-a4ab-4222-bfbf-548a55300ded	DEBRIEFED	60	2	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 10:37:56.441662+00	po	2026-10-12 10:37:56.977382+00	2026-10-12 10:37:53.858102+00	qa1	2026-10-12 10:37:56.97882+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 12:36:43.087166	49	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 12:36:43.170517	77	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 12:36:43.265795	81	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 12:36:43.363066	14	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 12:36:43.390248	6	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 12:36:43.405991	41	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 12:36:43.461876	72	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 12:36:43.549577	7	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 12:36:43.566845	7	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 12:36:43.587734	16	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 12:36:43.615497	28	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 12:36:43.655767	44	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 12:36:43.712406	15	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 12:36:43.738838	26	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 12:36:43.777448	22	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 12:36:43.812344	16	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 12:36:43.837472	10	t
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ	18
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC	14
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REL	2
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SPR	3
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	DEF	3
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RUN	3
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	CMP	4
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters") FROM stdin;
494587fa-c270-45c0-a9c0-ceb655e62564	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 10:37:13.902388+00	qa1	2026-10-12 10:37:13.902388+00	qa1	0	\N	{}
ccaa16b0-1806-47db-9453-767c3e794dbd	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 10:37:13.903434+00	qa1	2026-10-12 10:37:13.903434+00	qa1	0	\N	{}
c177944b-3b29-4a4f-bb4b-5e83796a9e8d	d417a76d-678b-46be-b8d3-c5d8dab86e5d	1	\N	\N	\N	2026-10-12 10:37:14.025917+00	qa1	2026-10-12 10:37:14.025917+00	qa1	0	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	{"utilisateur": "${utilisateur}", "resultat_attendu": "Le catalogue « Products » s’affiche"}
d153654c-f5ff-4f98-ad96-fda1e2634b9e	d417a76d-678b-46be-b8d3-c5d8dab86e5d	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 10:37:14.025917+00	qa1	2026-10-12 10:37:14.025917+00	qa1	0	\N	{}
42d226a7-a3c0-4dc2-9ad8-56bd558413bd	d417a76d-678b-46be-b8d3-c5d8dab86e5d	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 10:37:14.025917+00	qa1	2026-10-12 10:37:14.025917+00	qa1	0	\N	{}
e87e5e1e-9990-4518-ad42-c329b5d80dee	d417a76d-678b-46be-b8d3-c5d8dab86e5d	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 10:37:14.025917+00	qa1	2026-10-12 10:37:14.025917+00	qa1	0	\N	{}
95bc445a-6650-46f6-a8b8-6f7c96f5424c	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	\N	\N	\N	2026-10-12 10:37:16.914801+00	qa1	2026-10-12 10:37:16.914801+00	qa1	0	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}
b6ded6fa-e28e-4e23-adf7-465fbf7d72d3	a2e12230-5cc8-4b6b-b376-382e4edf04ba	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 10:37:16.914801+00	qa1	2026-10-12 10:37:16.914801+00	qa1	0	\N	{}
77339d1b-0e27-4462-8f4c-ab395d792d20	a2e12230-5cc8-4b6b-b376-382e4edf04ba	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 10:37:16.915316+00	qa1	2026-10-12 10:37:16.915316+00	qa1	0	\N	{}
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e542ebae-f595-4678-bd56-fe9457dbdcf9	305b6ae2-f378-4624-bc86-cff3ed3b65e8	284	ms	p95Ms	TC-11	RUN-2	2026-10-12 10:38:08.949125+00	TARGET_MET	2026-10-12 10:38:08.967978+00	anonymousUser	2026-10-12 10:38:08.967978+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
23a18343-b871-43d5-82e7-353384cb2e72	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:28.457378+00
709bb327-51fd-4b44-862e-07d25f876d26	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:37.736268+00
b091d3d3-6f4f-4ed2-a8f9-856148c1bae5	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:38.26875+00
88e61d00-85b0-4f01-ac78-526ff25baea8	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:38.269261+00
a11aa6c9-93d2-465e-ab56-b7b48c3a6890	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:38.269261+00
04f23375-ef1c-4fab-8876-18aca4203c2f	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:40.442126+00
ec27635c-8236-4dff-8648-d936b25fd5a4	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:40.489749+00
852ea1b5-dbee-4590-85da-982adbd17be9	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:40.835775+00
10581789-99a0-419a-bb88-93ab63956c35	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:40.994715+00
eb751797-0fd2-488e-b5d3-e6ae17ba8d78	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:41.102633+00
d4e70b3c-3c1f-4350-bcef-40966f03f0b2	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:42.113462+00
c3c86b25-2e64-4a8a-a132-8bcb26ef7149	06d0582d-a4d1-454b-8126-98132edd4db4	2026-10-12 10:37:42.135196+00
e5b868e0-6de3-4b3f-b8bf-5365d91b3230	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:37:58.909176+00
6f2612a7-6120-40ec-bd85-07ad1c8e0144	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:05.491115+00
cea06d9e-73f1-497e-bb5f-f47d93a3b38f	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:06.006003+00
d78e1d3b-1b82-46f3-8d60-7e2f6bea5995	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:07.023201+00
46e29d65-f139-4f98-a9e1-96569cfd46bd	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:08.125938+00
f6d11dc1-88a3-4a01-8623-aa7be9ba29c8	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:08.956249+00
7b01dc64-22ee-48b4-be65-bdeba0cc8cc1	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:10.066581+00
cd022a6d-949a-4144-b5a7-77813062ff4d	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:11.208941+00
0e9f0643-601b-41e9-9ce8-817223ee75ca	d4d24782-4057-4028-84a5-89cd77aafae6	2026-10-12 10:38:11.233302+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
13b819ed-d379-4432-b055-9b881cc15ee7	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	d9d5d704-2010-402e-bb4e-196c0c8bad07	ADMINISTRATOR	2026-10-12 10:37:00.205789+00	admin	2026-10-12 10:37:00.205789+00	admin	0
b2aa33d9-9e08-4f1a-8e4b-da4bdaedeeee	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	c99b3891-3e12-477a-9e5b-34ed4835fc08	PRODUCT_OWNER	2026-10-12 10:37:00.206309+00	admin	2026-10-12 10:37:00.206309+00	admin	0
50052d59-de08-452d-b9af-c91f72630969	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	449d3ab1-5074-41d6-bf82-961a64c725fb	TESTER	2026-10-12 10:37:00.206309+00	admin	2026-10-12 10:37:00.206309+00	admin	0
f9d5e268-80f2-47eb-9ad9-7539066e4da8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	e7b3425c-50cb-4ea4-988e-ab36afd76881	TESTER	2026-10-12 10:37:00.206309+00	admin	2026-10-12 10:37:00.206309+00	admin	0
2a290db5-f365-473e-94cb-bb5b291ec848	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	ff6387b1-eec8-45d7-b0b8-ae1a1d7a8d4f	DEVELOPER	2026-10-12 10:37:00.206309+00	admin	2026-10-12 10:37:00.206309+00	admin	0
c09171d5-73b4-422a-bc64-315d8260c0be	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	fae3c4a1-de29-4353-935d-62f23220c317	VIEWER	2026-10-12 10:37:00.206309+00	admin	2026-10-12 10:37:00.206309+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 10:37:00.080856+00	admin	2026-10-12 10:37:00.080856+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
88ca15c8-8b12-47b9-8e34-2ec313fd6308	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 10:37:21.836939+00	po	2026-10-12 10:37:23.425115+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9d4854c7-b76b-4855-8c50-034552b71845	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 10:37:46.285694+00	po	2026-10-12 10:37:46.285694+00	po	0
6ac9f9d0-36b5-4dd7-9548-a26e1fc7cb19	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 10:37:46.295326+00	po	2026-10-12 10:37:46.295326+00	po	0
40b2538a-1358-4c37-ad0e-ff9e0244c447	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 10:38:30.850094+00	po	2026-10-12 10:38:30.850094+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
203d48d6-92c6-45af-a76b-c8d48441bb1b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T10:37:46.325239400Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 10:37:46.366279+00	clôture du sprint	2026-10-12 10:37:46.364001+00	po	2026-10-12 10:37:46.366279+00	po	1
b0c0de32-365c-4c2b-8c16-fdc7ba865294	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T10:38:27.475451Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 0, "averageMinutes": 0.0, "defectsPerHour": 1800.0, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 10:38:28.957358+00	f	\N	\N	2026-10-12 10:38:27.488536+00	po	2026-10-12 10:38:28.957358+00	po	2
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
e32832db-f697-421d-bf17-0cd04fae96ea	cd53432e-2327-4823-af92-d3964d722dfe	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.378356+00	po	2026-10-12 10:37:06.378356+00	po	0
d575436b-11af-44a7-91dc-60bc51dca2b2	0d902e8b-245a-44e3-868e-a0770ea04520	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.416401+00	po	2026-10-12 10:37:06.416401+00	po	0
80e0d18d-9b63-4872-8a40-8fca925c4c1d	71b894d7-3f09-4db8-91b4-04d1204086ca	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.448753+00	po	2026-10-12 10:37:06.448753+00	po	0
91d46c35-dfe7-4e07-80c0-828166eb0de8	5bc1d976-5432-464b-a9ed-e890a9f526e1	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.480824+00	po	2026-10-12 10:37:06.480824+00	po	0
5229b075-982d-4167-b84a-7fba812fc73b	13ba4d0e-c713-4a52-a3ca-dba7326c2741	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.514323+00	po	2026-10-12 10:37:06.514323+00	po	0
e3af4767-b82e-4e6f-a813-407484cf7d53	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.54885+00	po	2026-10-12 10:37:06.54885+00	po	0
ddac0861-ca72-4404-a2fc-b5b37262d71b	f215e06a-1763-48b7-8096-5578cf556838	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:06.579818+00	po	2026-10-12 10:37:06.579818+00	po	0
67867aed-b478-4cdd-a19f-8aae9d07fab2	f70c9457-5d72-4cdf-8253-90cac7809aaf	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 10:37:07.533271+00	po	2026-10-12 10:37:07.533271+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 10:37:03.049641+00	po	2026-10-12 10:37:03.049641+00	po	0
da15b5a2-541d-4180-8768-742787628d0b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 10:37:03.123151+00	po	2026-10-12 10:37:03.123151+00	po	0
f398f9a7-5204-4599-bada-e14eeb10f408	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 10:37:03.260651+00	po	2026-10-12 10:37:03.260651+00	po	0
c3f77c83-1f3e-495f-b7e6-35463941159c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 10:37:03.409629+00	po	2026-10-12 10:37:03.409629+00	po	0
0d902e8b-245a-44e3-868e-a0770ea04520	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	da15b5a2-541d-4180-8768-742787628d0b	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 10:37:03.221206+00	po	2026-10-12 10:37:43.926146+00	po	3
71b894d7-3f09-4db8-91b4-04d1204086ca	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	f398f9a7-5204-4599-bada-e14eeb10f408	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 10:37:03.295375+00	po	2026-10-12 10:37:43.966195+00	po	3
f215e06a-1763-48b7-8096-5578cf556838	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	c3f77c83-1f3e-495f-b7e6-35463941159c	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 10:37:03.481556+00	po	2026-10-12 10:37:47.021008+00	po	2
9a2557b0-7843-439f-b46b-888ea9f64ae4	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 10:37:03.548801+00	po	2026-10-12 10:37:03.548801+00	po	0
828db1d0-edff-49d8-a435-92c1e0c141ea	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 10:37:05.568312+00	po	2026-10-12 10:37:05.568312+00	po	0
13ba4d0e-c713-4a52-a3ca-dba7326c2741	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	f398f9a7-5204-4599-bada-e14eeb10f408	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 10:37:03.374957+00	po	2026-10-12 10:38:23.067802+00	po	4
cd53432e-2327-4823-af92-d3964d722dfe	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	da15b5a2-541d-4180-8768-742787628d0b	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 10:37:03.177389+00	po	2026-10-12 10:37:43.87529+00	po	3
5bc1d976-5432-464b-a9ed-e890a9f526e1	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	f398f9a7-5204-4599-bada-e14eeb10f408	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 10:37:03.335213+00	po	2026-10-12 10:37:44.006839+00	po	3
fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	c3f77c83-1f3e-495f-b7e6-35463941159c	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 10:37:03.442389+00	po	2026-10-12 10:37:47.021008+00	po	2
f70c9457-5d72-4cdf-8253-90cac7809aaf	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	c3f77c83-1f3e-495f-b7e6-35463941159c	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 10:37:03.515273+00	po	2026-10-12 10:37:47.021008+00	po	2
55e3a11c-302b-4cad-91b4-3c41369af8de	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	9a2557b0-7843-439f-b46b-888ea9f64ae4	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 10:37:03.580825+00	po	2026-10-12 10:37:03.580825+00	po	0
fd3b0a25-4d22-4c38-bb58-c5a037715d10	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	9a2557b0-7843-439f-b46b-888ea9f64ae4	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 10:37:05.288417+00	po	2026-10-12 10:37:05.288417+00	po	0
305b6ae2-f378-4624-bc86-cff3ed3b65e8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	4df4d129-3769-41dd-9cb8-2c3fb1aaac6b	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 10:37:05.534356+00	po	2026-10-12 10:37:05.534356+00	po	0
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a391621f-1423-4e91-9087-fc9ed0ff4974	06d0582d-a4d1-454b-8126-98132edd4db4	f539e881-1619-4978-bdb5-b205e87f5f90	log-TC-7.txt	text/plain	SYSTEM_TRACE	395	2026-10-12 10:37:40.456483+00	anonymousUser	2026-10-12 10:37:40.456483+00	anonymousUser	0
868a030c-d82c-49cb-8ada-4daf53fcac8c	06d0582d-a4d1-454b-8126-98132edd4db4	fa3eb3cc-2622-4085-9aa7-e5fda5ad1d77	log-TC-5.txt	text/plain	SYSTEM_TRACE	482	2026-10-12 10:37:40.83943+00	anonymousUser	2026-10-12 10:37:40.83943+00	anonymousUser	0
1a06377a-a7e7-4179-9a18-71c8bd316c0b	06d0582d-a4d1-454b-8126-98132edd4db4	1b943ff6-ff16-4eb6-acd3-4dabbe30b779	log-TC-4.txt	text/plain	SYSTEM_TRACE	392	2026-10-12 10:37:40.998305+00	anonymousUser	2026-10-12 10:37:40.998305+00	anonymousUser	0
2c9e2dd0-7adf-438e-b986-6a47b4b8c4f8	06d0582d-a4d1-454b-8126-98132edd4db4	ce740398-a203-44b4-b0d8-6ec2f7f68804	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 10:37:41.107924+00	anonymousUser	2026-10-12 10:37:41.107924+00	anonymousUser	0
333130f8-74ab-4cbd-b0cf-6d863926a28b	06d0582d-a4d1-454b-8126-98132edd4db4	eae6d57d-6fc7-4c57-a276-c97ecd2f19dc	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 10:37:42.116019+00	anonymousUser	2026-10-12 10:37:42.116019+00	anonymousUser	0
078b5ad9-9faf-451c-b9af-bc706efafb5e	06d0582d-a4d1-454b-8126-98132edd4db4	\N	system.log	text/plain	SYSTEM_TRACE	4726	2026-10-12 10:37:42.13674+00	anonymousUser	2026-10-12 10:37:42.13674+00	anonymousUser	0
e5ecc145-a00c-4e79-bb20-d9dbc615516e	06d0582d-a4d1-454b-8126-98132edd4db4	\N	junit.xml	application/xml	JUNIT	1187	2026-10-12 10:37:42.137742+00	anonymousUser	2026-10-12 10:37:42.137742+00	anonymousUser	0
4fc1e05e-f057-41d2-89f0-c9168c163fdd	06d0582d-a4d1-454b-8126-98132edd4db4	\N	report.json	application/json	REPORT	484	2026-10-12 10:37:42.142742+00	anonymousUser	2026-10-12 10:37:42.142742+00	anonymousUser	0
7951827a-f6a3-4109-a094-7ebd18e0213f	d4d24782-4057-4028-84a5-89cd77aafae6	a78eddad-080c-4de3-bbcf-ebff3966851d	log-TC-8.txt	text/plain	SYSTEM_TRACE	361	2026-10-12 10:38:08.129036+00	anonymousUser	2026-10-12 10:38:08.129036+00	anonymousUser	0
c2e5988b-5470-46b2-9bc2-3b5602de935f	d4d24782-4057-4028-84a5-89cd77aafae6	9a6a019d-8b6b-4043-95f0-6a2af83fa059	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 10:38:08.959033+00	anonymousUser	2026-10-12 10:38:08.959033+00	anonymousUser	0
8b770ac6-9ff0-4e54-b8fc-c118111d4cb4	d4d24782-4057-4028-84a5-89cd77aafae6	d01be9f8-cc3d-4797-8d01-b1575eb5d0ff	log-TC-9.txt	text/plain	SYSTEM_TRACE	370	2026-10-12 10:38:10.069159+00	anonymousUser	2026-10-12 10:38:10.069159+00	anonymousUser	0
838be420-5c77-4d36-bd3d-116f1e9674af	d4d24782-4057-4028-84a5-89cd77aafae6	f9dd6fe0-1979-4349-8be3-7aeaf4777caa	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 10:38:11.211502+00	anonymousUser	2026-10-12 10:38:11.211502+00	anonymousUser	0
f691e64b-94a3-49b4-bcae-70a64cbb135e	d4d24782-4057-4028-84a5-89cd77aafae6	f9dd6fe0-1979-4349-8be3-7aeaf4777caa	log-TC-10.txt	text/plain	SYSTEM_TRACE	3392	2026-10-12 10:38:11.214135+00	anonymousUser	2026-10-12 10:38:11.214135+00	anonymousUser	0
494c61ad-67ad-440f-bd95-d0c657c3a526	d4d24782-4057-4028-84a5-89cd77aafae6	\N	system.log	text/plain	SYSTEM_TRACE	8590	2026-10-12 10:38:11.234935+00	anonymousUser	2026-10-12 10:38:11.234935+00	anonymousUser	0
88d32a69-a615-4f1b-88ce-6d4d1cb43e6a	d4d24782-4057-4028-84a5-89cd77aafae6	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 10:38:11.237609+00	anonymousUser	2026-10-12 10:38:11.237609+00	anonymousUser	0
7b3d0fff-bab8-48ed-95ab-c6cd00df1ffb	d4d24782-4057-4028-84a5-89cd77aafae6	\N	report.json	application/json	REPORT	475	2026-10-12 10:38:11.239697+00	anonymousUser	2026-10-12 10:38:11.239697+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d3434da5-b2a9-494e-aa81-ac3719b0495b	d8b7ba28-b53b-4319-b572-b4403072610b	NOTE	0	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 10:37:53.971822+00	\N	2026-10-12 10:37:53.974417+00	qa1	2026-10-12 10:37:53.974417+00	qa1	0
f9d6e6c2-9c24-46d0-8a1b-27fa31eeb3c6	d8b7ba28-b53b-4319-b572-b4403072610b	NOTE	0	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 10:37:54.077747+00	\N	2026-10-12 10:37:54.078331+00	qa1	2026-10-12 10:37:54.078331+00	qa1	0
26976033-3395-4902-b53b-d3b52352e1f7	d8b7ba28-b53b-4319-b572-b4403072610b	QUESTION	0	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 10:37:54.210227+00	\N	2026-10-12 10:37:54.210789+00	qa1	2026-10-12 10:37:54.210789+00	qa1	0
ffb956f8-dd62-45d3-a184-2a5d35e72c6b	d8b7ba28-b53b-4319-b572-b4403072610b	IDEA	0	Afficher le total du panier avant le checkout	2026-10-12 10:37:54.279321+00	\N	2026-10-12 10:37:54.279321+00	qa1	2026-10-12 10:37:54.279321+00	qa1	0
84c167ff-ea67-4502-97ba-84772f77dbf4	d8b7ba28-b53b-4319-b572-b4403072610b	BUG	0	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 10:37:54.142754+00	957b2325-8da5-4471-b0e9-deca9de911dc	2026-10-12 10:37:54.143305+00	qa1	2026-10-12 10:37:54.884523+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e58b1ce7-abfe-4c1f-8764-5762b2a7c4db	2aa9194b-0707-4654-b4e2-98d62f8d2320	cd53432e-2327-4823-af92-d3964d722dfe	1	3	DONE	2026-10-12 10:37:22.503736+00	po	2026-10-12 10:37:46.287321+00	po	1
af3d672b-da51-4bf8-81ce-bce3797d50d4	2aa9194b-0707-4654-b4e2-98d62f8d2320	0d902e8b-245a-44e3-868e-a0770ea04520	2	2	DONE	2026-10-12 10:37:22.575291+00	po	2026-10-12 10:37:46.287321+00	po	1
00049e08-76ce-4645-8049-ce7c050d8d86	2aa9194b-0707-4654-b4e2-98d62f8d2320	71b894d7-3f09-4db8-91b4-04d1204086ca	3	3	DONE	2026-10-12 10:37:22.655138+00	po	2026-10-12 10:37:46.287321+00	po	1
c1b7a2e9-d41f-4484-8504-add5bbc8e1eb	2aa9194b-0707-4654-b4e2-98d62f8d2320	5bc1d976-5432-464b-a9ed-e890a9f526e1	4	2	DONE	2026-10-12 10:37:22.739391+00	po	2026-10-12 10:37:46.287321+00	po	1
7a3d86ff-896e-442d-bd33-fa1c7cdadef7	2aa9194b-0707-4654-b4e2-98d62f8d2320	13ba4d0e-c713-4a52-a3ca-dba7326c2741	5	2	DONE	2026-10-12 10:37:22.817547+00	po	2026-10-12 10:37:46.287321+00	po	1
c3e8ad9d-10fa-4ce6-bf4d-b570076960db	8de13d5e-7b51-4085-a29b-c7bf3a902d02	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	1	3	PLANNED	2026-10-12 10:37:46.975809+00	po	2026-10-12 10:37:46.975809+00	po	0
32e2c330-d421-4507-bb76-c7196110618c	8de13d5e-7b51-4085-a29b-c7bf3a902d02	f215e06a-1763-48b7-8096-5578cf556838	2	3	PLANNED	2026-10-12 10:37:46.975809+00	po	2026-10-12 10:37:46.975809+00	po	0
3382dcca-2b38-43c5-b91b-d2889a471a6e	8de13d5e-7b51-4085-a29b-c7bf3a902d02	f70c9457-5d72-4cdf-8253-90cac7809aaf	3	2	PLANNED	2026-10-12 10:37:46.975809+00	po	2026-10-12 10:37:46.975809+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2aa9194b-0707-4654-b4e2-98d62f8d2320	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	88ca15c8-8b12-47b9-8e34-2ec313fd6308	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 10:37:21.864977+00	po	2026-10-12 10:37:46.287321+00	po	2
8de13d5e-7b51-4085-a29b-c7bf3a902d02	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	88ca15c8-8b12-47b9-8e34-2ec313fd6308	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 10:37:21.907632+00	po	2026-10-12 10:37:47.021008+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
a31ebc2a-bdce-4976-85e8-1d93a392ed53	ae67dd1f-856b-45de-8904-5b55da5d9a15	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:26.0837+00	qa1	2026-10-12 10:37:26.217013+00	qa1	1	\N
5d8e7d3e-edf4-4fa5-81ca-d6644ce3e90a	ae67dd1f-856b-45de-8904-5b55da5d9a15	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 10:37:26.084231+00	qa1	2026-10-12 10:37:26.795668+00	qa1	1	\N
6cbf2b62-bf9e-46de-b697-a1d205db7450	0493be26-cdf1-412e-9d9b-47c47038ca15	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:26.842424+00	qa1	2026-10-12 10:37:26.861866+00	qa1	1	\N
f141d9d1-beca-460c-b224-13607c8d7fc1	0493be26-cdf1-412e-9d9b-47c47038ca15	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 10:37:26.842424+00	qa1	2026-10-12 10:37:26.882652+00	qa1	1	\N
54f6edea-a037-46bf-be45-e7b330031750	250922ba-4081-4532-a95d-25f5cd793b24	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:26.899176+00	qa1	2026-10-12 10:37:26.914758+00	qa1	1	\N
69e89709-9779-486b-945a-5da6f1f7092e	250922ba-4081-4532-a95d-25f5cd793b24	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 10:37:26.899176+00	qa1	2026-10-12 10:37:26.931259+00	qa1	1	\N
a1e17b88-8af5-41a1-8900-5804a8014f8f	053cb7ef-b296-422f-acb9-b9486f9592ce	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.107165+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration
b1d6bdb3-8ffb-48ba-bad7-ad709bc1c6c9	053cb7ef-b296-422f-acb9-b9486f9592ce	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.241078+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration
c735c3b9-2acc-410b-95ae-b7ca3d471ffa	053cb7ef-b296-422f-acb9-b9486f9592ce	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.357138+00	qa2	1	\N
5d3c4739-5b0d-4a3c-bbb0-14732e252f67	053cb7ef-b296-422f-acb9-b9486f9592ce	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.476313+00	qa2	1	\N
6eaf36e0-3480-4af5-b54b-1f6882f69993	053cb7ef-b296-422f-acb9-b9486f9592ce	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 10:37:48.975344+00	qa2	2026-10-12 10:37:49.757253+00	qa2	1	\N
538dba47-80f1-45c6-9458-ce70db33c8ba	f7ee183d-9b22-4c80-a824-31671222eff0	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:51.779196+00	qa1	2026-10-12 10:37:51.923735+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
869448b9-7bfd-410f-8b57-f75b6bd7d6d7	f7ee183d-9b22-4c80-a824-31671222eff0	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 10:37:51.779196+00	qa1	2026-10-12 10:37:52.506685+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
9e767528-2ff6-4ba3-9712-6b48afda3bf0	f7ee183d-9b22-4c80-a824-31671222eff0	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 10:37:51.779196+00	qa1	2026-10-12 10:37:52.624467+00	qa1	1	\N
5007b699-43c7-425a-b862-49921250c553	f7ee183d-9b22-4c80-a824-31671222eff0	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 10:37:51.779196+00	qa1	2026-10-12 10:37:52.691193+00	qa1	1	\N
162a700c-54f6-4030-b1b8-ab3d1a33fa27	d54726ff-b7b5-45e7-9901-6bfa1273c5d5	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 10:37:52.740465+00	qa1	2026-10-12 10:37:52.756586+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
cbd053e9-f377-4007-95b7-52e6fb00c3f9	d54726ff-b7b5-45e7-9901-6bfa1273c5d5	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 10:37:52.740465+00	qa1	2026-10-12 10:37:52.772166+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
e43eb26e-8250-4e8d-a663-4e1bfb0e9be4	d54726ff-b7b5-45e7-9901-6bfa1273c5d5	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 10:37:52.740465+00	qa1	2026-10-12 10:37:52.785997+00	qa1	1	\N
8f5046d8-9929-4a55-89de-17af59710874	d54726ff-b7b5-45e7-9901-6bfa1273c5d5	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 10:37:52.740465+00	qa1	2026-10-12 10:37:52.801345+00	qa1	1	\N
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
65bf5490-0758-413d-86f1-f882fe4955f2	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 10:37:13.907493+00	qa1	2026-10-12 10:37:13.907493+00	qa1	0
aee8f5c0-c4fb-4357-adeb-30c927338537	d417a76d-678b-46be-b8d3-c5d8dab86e5d	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=${utilisateur}}", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": ["Compte du défaut : [{utilisateur=problem_user}]"], "priority": "MUST", "objective": null, "parameters": ["utilisateur = problem_user"], "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 10:37:14.026437+00	qa1	2026-10-12 10:37:14.026437+00	qa1	0
77234126-0b6b-4764-8fcc-7c764da4b2f9	70fe82e6-66c3-4e34-827b-539a2599c2df	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "installation-hors-docker", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:14.097234+00	dev	2026-10-12 10:37:14.097234+00	dev	0
896d1ec7-5903-4533-aff3-60dbf118c9dd	efe193cb-7bf4-4501-bbe1-e445c6f0322f	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:14.161367+00	dev	2026-10-12 10:37:14.161367+00	dev	0
cab12e4b-f8f4-42e5-a090-94952b2ad92f	8df080af-c8da-4ccb-87a8-c271093fc03e	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:14.220781+00	dev	2026-10-12 10:37:14.220781+00	dev	0
67f74086-b7d5-4193-9f90-fff4cf8f4060	b79c9049-1436-4d92-8485-430df45a30a2	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:14.276564+00	dev	2026-10-12 10:37:14.276564+00	dev	0
78a44569-15f1-4590-a750-58a25a325d32	fb1eb699-aa70-497a-b476-f3d7c21d9024	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "installation-hors-docker", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:14.33638+00	dev	2026-10-12 10:37:14.33638+00	dev	0
cb555eaa-5e4e-4472-a68d-ed51aa1e103e	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:15.677572+00	qa1	2026-10-12 10:37:15.677572+00	qa1	0
7217ce11-bb22-4ec8-8f97-699b159cb767	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "installation-hors-docker", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:15.79768+00	qa1	2026-10-12 10:37:15.79768+00	qa1	0
257e8aab-9466-41f8-af58-808974b2de40	2d39472c-9177-4a9e-a867-ebd6bf1cb114	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:16.686412+00	dev	2026-10-12 10:37:16.686412+00	dev	0
7295a919-dace-4d69-9f83-bde70e14dcf9	948b1866-8a93-4de1-bda5-b4091b782416	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:16.743639+00	dev	2026-10-12 10:37:16.743639+00	dev	0
d6ba4a6d-0a97-4b26-b5d5-1585285d425a	65d69ded-e149-4a18-89ea-ad4963f1f2dd	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "installation-hors-docker", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 10:37:16.799218+00	dev	2026-10-12 10:37:16.799218+00	dev	0
849ae841-5522-4007-8194-91612e450a8f	2efae0cb-0b1c-424a-9d30-64e7c9921a70	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 10:37:16.855124+00	qa1	2026-10-12 10:37:16.855124+00	qa1	0
25d8b9b9-5826-4532-af09-36936b385cdf	a2e12230-5cc8-4b6b-b376-382e4edf04ba	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=standard_user}", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 10:37:16.915316+00	qa1	2026-10-12 10:37:16.915316+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 10:37:13.89739+00	qa1	2026-10-12 10:37:13.991539+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}]}]	f
d417a76d-678b-46be-b8d3-c5d8dab86e5d	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 10:37:14.025366+00	qa1	2026-10-12 10:37:14.067793+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "problem_user"}]	[{"name": "Compte du défaut", "rows": [{"utilisateur": "problem_user"}]}]	f
70fe82e6-66c3-4e34-827b-539a2599c2df	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 10:37:14.094466+00	dev	2026-10-12 10:37:14.134119+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}]}]	f
efe193cb-7bf4-4501-bbe1-e445c6f0322f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 10:37:14.160834+00	dev	2026-10-12 10:37:14.193907+00	qa1	1	[]	[]	f
8df080af-c8da-4ccb-87a8-c271093fc03e	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 10:37:14.220243+00	dev	2026-10-12 10:37:14.252675+00	qa1	1	[]	[]	f
fb1eb699-aa70-497a-b476-f3d7c21d9024	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 10:37:14.335857+00	dev	2026-10-12 10:37:14.366144+00	qa1	1	[]	[]	f
948b1866-8a93-4de1-bda5-b4091b782416	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 10:37:16.74311+00	dev	2026-10-12 10:37:16.77418+00	qa1	1	[]	[]	f
07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 10:37:15.676931+00	qa1	2026-10-12 10:37:15.806936+00	qa1	2	[]	[]	f
2d39472c-9177-4a9e-a867-ebd6bf1cb114	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 10:37:16.685384+00	dev	2026-10-12 10:37:16.718191+00	qa1	1	[]	[]	f
65d69ded-e149-4a18-89ea-ad4963f1f2dd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 10:37:16.798707+00	dev	2026-10-12 10:37:16.830958+00	qa1	1	[]	[]	f
2efae0cb-0b1c-424a-9d30-64e7c9921a70	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 10:37:16.852821+00	qa1	2026-10-12 10:37:16.888033+00	qa1	1	[]	[]	f
a2e12230-5cc8-4b6b-b376-382e4edf04ba	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 10:37:16.914801+00	qa1	2026-10-12 10:37:16.9515+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}]}]	f
b79c9049-1436-4d92-8485-430df45a30a2	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 10:37:14.276564+00	dev	2026-10-12 10:38:23.075611+00	po	2	[]	[]	f
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
46d4684d-1dd7-4a8a-ba42-633eff0c3b23	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	VERIFIES	MANUAL	2026-10-12 10:37:13.919961+00	qa1	2026-10-12 10:37:13.919961+00	qa1	0	\N
ab17d8b5-9761-40ee-9124-f1fb1eaa75e6	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	f62bedee-ee94-4c9f-a9c3-fda0d85c4fc0	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	VERIFIES	MANUAL	2026-10-12 10:37:13.920479+00	qa1	2026-10-12 10:37:13.920479+00	qa1	0	\N
20e1acac-8150-4fa5-8a7c-9ba2585df643	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	d417a76d-678b-46be-b8d3-c5d8dab86e5d	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	PARTIALLY_VERIFIES	MANUAL	2026-10-12 10:37:14.031651+00	qa1	2026-10-12 10:37:14.031651+00	qa1	0	\N
565e2b58-b53a-4213-a1e7-e2c3290b931f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	d417a76d-678b-46be-b8d3-c5d8dab86e5d	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	VERIFIES	MANUAL	2026-10-12 10:37:14.031651+00	qa1	2026-10-12 10:37:14.031651+00	qa1	0	\N
8867ed8d-bd54-423c-a004-8b7c35824a0f	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	70fe82e6-66c3-4e34-827b-539a2599c2df	REQUIREMENT	cd53432e-2327-4823-af92-d3964d722dfe	VERIFIES	MANUAL	2026-10-12 10:37:14.102113+00	dev	2026-10-12 10:37:14.102113+00	dev	0	\N
c4072683-c834-4155-bfcc-0f54c10962cd	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	70fe82e6-66c3-4e34-827b-539a2599c2df	REQUIREMENT	0d902e8b-245a-44e3-868e-a0770ea04520	VERIFIES	MANUAL	2026-10-12 10:37:14.102113+00	dev	2026-10-12 10:37:14.102113+00	dev	0	\N
a938071d-f118-4e37-bd04-d8ca68d76baa	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	efe193cb-7bf4-4501-bbe1-e445c6f0322f	REQUIREMENT	71b894d7-3f09-4db8-91b4-04d1204086ca	VERIFIES	MANUAL	2026-10-12 10:37:14.16426+00	dev	2026-10-12 10:37:14.16426+00	dev	0	\N
0f2bd001-bcc4-49f5-9f6c-d7d93164b0b8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	8df080af-c8da-4ccb-87a8-c271093fc03e	REQUIREMENT	5bc1d976-5432-464b-a9ed-e890a9f526e1	VERIFIES	MANUAL	2026-10-12 10:37:14.224131+00	dev	2026-10-12 10:37:14.224131+00	dev	0	\N
9613d158-d864-4316-80d0-bc2564510bb8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	fb1eb699-aa70-497a-b476-f3d7c21d9024	REQUIREMENT	828db1d0-edff-49d8-a435-92c1e0c141ea	VERIFIES	MANUAL	2026-10-12 10:37:14.338985+00	dev	2026-10-12 10:37:14.338985+00	dev	0	\N
82126cb1-27b0-4d29-a91a-885c4f79bea4	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	REQUIREMENT	fc333fa9-ea2e-4ed4-831e-8b04ca9fb76c	VERIFIES	GHERKIN_TAG	2026-10-12 10:37:15.683153+00	qa1	2026-10-12 10:37:15.683153+00	qa1	0	\N
01e81fe1-be5c-4d4c-b55d-7171079b64c8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	07c55ccd-e12a-4304-9c97-7b6dc2ea18c6	ACCEPTANCE_CRITERION	7590b7be-339e-40de-b64b-c1835b64f1d8	VERIFIES	GHERKIN_TAG	2026-10-12 10:37:15.692934+00	qa1	2026-10-12 10:37:15.692934+00	qa1	0	\N
26ae0233-27d0-47bd-931b-598e966581bf	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2d39472c-9177-4a9e-a867-ebd6bf1cb114	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	VERIFIES	MANUAL	2026-10-12 10:37:16.690127+00	dev	2026-10-12 10:37:16.690127+00	dev	0	\N
b24c9ce0-2291-46e7-8994-2bd81ad58547	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	948b1866-8a93-4de1-bda5-b4091b782416	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	VERIFIES	MANUAL	2026-10-12 10:37:16.746145+00	dev	2026-10-12 10:37:16.746145+00	dev	0	\N
c3aac5e2-89df-4bd8-a0a0-a9b2ceffdb7b	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	65d69ded-e149-4a18-89ea-ad4963f1f2dd	REQUIREMENT	305b6ae2-f378-4624-bc86-cff3ed3b65e8	VERIFIES	MANUAL	2026-10-12 10:37:16.801731+00	dev	2026-10-12 10:37:16.801731+00	dev	0	\N
f35df22b-602d-46ac-bd08-6dea13c99037	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2efae0cb-0b1c-424a-9d30-64e7c9921a70	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	VERIFIES	MANUAL	2026-10-12 10:37:16.85912+00	qa1	2026-10-12 10:37:16.85912+00	qa1	0	\N
0fc2e045-eab9-4b25-b0e8-50a1e45af0ae	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	2efae0cb-0b1c-424a-9d30-64e7c9921a70	REQUIREMENT	f70c9457-5d72-4cdf-8253-90cac7809aaf	VERIFIES	MANUAL	2026-10-12 10:37:16.85912+00	qa1	2026-10-12 10:37:16.85912+00	qa1	0	\N
7ecaa177-39c5-4b85-9a67-a5b235471346	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	a2e12230-5cc8-4b6b-b376-382e4edf04ba	REQUIREMENT	f215e06a-1763-48b7-8096-5578cf556838	VERIFIES	MANUAL	2026-10-12 10:37:16.91805+00	qa1	2026-10-12 10:37:16.91805+00	qa1	0	\N
37491779-9cbc-47c7-be97-9c5b626668a8	8b586dd6-596c-4c1c-9fd1-a0ff33d3d932	TEST_CASE	b79c9049-1436-4d92-8485-430df45a30a2	REQUIREMENT	13ba4d0e-c713-4a52-a3ca-dba7326c2741	VERIFIES	MANUAL	2026-10-12 10:37:14.279764+00	dev	2026-10-12 10:38:23.714103+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d9d5d704-2010-402e-bb4e-196c0c8bad07	admin	admin@traceagile.local	Administrateur	$2a$12$RO2P1GuoYDTYpUnveHhhaeEg7eM/QQkLWhUgOws2ElzpKZkY6Btze	t	t	2026-10-12 10:36:47.975434+00	system	2026-10-12 10:36:47.975434+00	system	0
c99b3891-3e12-477a-9e5b-34ed4835fc08	po	po@traceagile.demo	Paula Owner	$2a$12$qHaFkLnxUZGcN5Qcz3nGwuqKDqCfGOdL/5OlgPSlkS14LPyJNuvMK	t	f	2026-10-12 10:36:58.155902+00	admin	2026-10-12 10:36:58.155902+00	admin	0
449d3ab1-5074-41d6-bf82-961a64c725fb	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$ok.GDjJuvnXz9fvbjCo4kuovI/bpkrJbx2kWRSPgMM8cg5mAq.mOq	t	f	2026-10-12 10:36:58.345361+00	admin	2026-10-12 10:36:58.345361+00	admin	0
e7b3425c-50cb-4ea4-988e-ab36afd76881	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$AUqYKp48XHVSlb7NzUb9OuGQmBXxx3dZ4On0vOrl.6Y1vjk4WiuvK	t	f	2026-10-12 10:36:58.535231+00	admin	2026-10-12 10:36:58.535231+00	admin	0
ff6387b1-eec8-45d7-b0b8-ae1a1d7a8d4f	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$T2mIfZMR0BArJ61mc9sktOJGa4Mh7io808FlcqhncZLepG2xl63PO	t	f	2026-10-12 10:36:58.721306+00	admin	2026-10-12 10:36:58.721306+00	admin	0
fae3c4a1-de29-4353-935d-62f23220c317	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$LTPK2SRvKeWVJ0h3v/JSoOS4SVTVWcaLIgO6dWGEvzKKpscLflPdC	t	f	2026-10-12 10:36:58.910583+00	admin	2026-10-12 10:36:58.910583+00	admin	0
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


