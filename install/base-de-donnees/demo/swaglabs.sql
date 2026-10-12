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
b7fe8581-d28d-4fbd-aabf-90d15195cddd	bdf53abe-d5ae-4209-998c-afa00a468622	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 07:39:57.842512+00	po	2026-10-12 07:39:57.842512+00	po	0
6c7dc6d4-c8ea-4b43-89ad-23084c97cce2	bdf53abe-d5ae-4209-998c-afa00a468622	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 07:39:57.842512+00	po	2026-10-12 07:39:57.842512+00	po	0
4b619c1f-1514-4b79-aea6-10016d87c4b0	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 07:39:57.892853+00	po	2026-10-12 07:39:57.892853+00	po	0
9204dcd7-ac7e-4bc2-9da7-bff45ba84db2	7b60a040-8f6b-40db-b1b9-aff842e97b39	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 07:39:57.975273+00	po	2026-10-12 07:39:57.975273+00	po	0
6f45827f-9059-42ae-bbf2-8f970e5917a3	64a0e4ad-69de-4a90-9db3-686f0957dfc8	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 07:39:58.019251+00	po	2026-10-12 07:39:58.019251+00	po	0
822f2d1c-37d7-4ca0-a772-e999184b20d3	3ec48475-423b-498d-b31b-77f00228351f	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 07:39:58.058167+00	po	2026-10-12 07:39:58.058167+00	po	0
962ca414-2e5f-4afb-af5e-712bea015fd8	9befb8bf-ee36-4059-8580-a412e87e9615	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 07:39:58.126417+00	po	2026-10-12 07:39:58.126417+00	po	0
949dd916-c3a8-4a05-b2f4-f6abae8a6357	9befb8bf-ee36-4059-8580-a412e87e9615	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 07:39:58.126417+00	po	2026-10-12 07:39:58.126417+00	po	0
042fe794-bed1-4fee-b0b4-4ac45effcdc1	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 07:39:58.163886+00	po	2026-10-12 07:39:58.163886+00	po	0
1a254c20-cb13-4f46-8465-c752c49f06ec	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 07:39:58.163886+00	po	2026-10-12 07:39:58.163886+00	po	0
fa464c27-d8b0-4b5f-921a-a60d2519128c	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 07:39:58.201121+00	po	2026-10-12 07:39:58.201121+00	po	0
73397301-fda2-4443-b67a-eed7240523a9	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 07:39:58.273998+00	po	2026-10-12 07:39:58.273998+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
04ea55df-0c67-4202-a0a3-5f8fd01cec29	9f08b136-a1be-45dc-a997-879aa2515dab	EXECUTION_STEP	117fefe1-355f-4f71-8c7c-949776940a2d	sd-defaut-problem-user.png	image/png	235120	57aaadac-b7a4-4b99-a5cf-382d4474aea6	2026-10-12 07:40:35.343703+00	qa2	2026-10-12 07:40:35.343703+00	qa2	0
3a960297-475e-4ea3-9eaa-48bd88d94985	9f08b136-a1be-45dc-a997-879aa2515dab	DEFECT	877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	sd-defaut-problem-user.png	image/png	235120	57aaadac-b7a4-4b99-a5cf-382d4474aea6	2026-10-12 07:40:35.973472+00	qa2	2026-10-12 07:40:35.973472+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
f6738517-9d47-4afc-97eb-5b060f186d01	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	64c4fc09-2525-47cb-a06b-8eb077421e9d	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:57.682959+00	po	2026-10-12 07:39:57.682959+00	po	0
12122486-89f3-48e6-b176-92b866c3c55f	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	24a475c9-085a-4f74-a1a7-c30c23e31c7f	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:57.773683+00	po	2026-10-12 07:39:57.773683+00	po	0
8417b939-26c3-48d9-9f80-1c526fbf5856	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 07:39:57.842512+00	po	2026-10-12 07:39:57.842512+00	po	0
4ed5fa43-cf86-439a-941f-bcf07a8a67ef	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 07:39:57.893372+00	po	2026-10-12 07:39:57.893372+00	po	0
f4658b0a-6d08-4090-afc5-0c48edf0d8c3	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	a081aff8-9c59-445d-b780-034a92889ee7	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:57.934916+00	po	2026-10-12 07:39:57.934916+00	po	0
1c1984df-8d8a-4810-8daa-92f04b2e8eef	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	7b60a040-8f6b-40db-b1b9-aff842e97b39	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 07:39:57.975273+00	po	2026-10-12 07:39:57.975273+00	po	0
0bcec112-3b07-49fe-892d-a8f8302b14e6	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	64a0e4ad-69de-4a90-9db3-686f0957dfc8	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.01977+00	po	2026-10-12 07:39:58.01977+00	po	0
62b8b754-68d0-4276-9cf5-40bfda43fe15	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	64a0e4ad-69de-4a90-9db3-686f0957dfc8	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 07:40:31.518071+00	po	2026-10-12 07:40:31.518071+00	po	0
a887fa7f-5331-4577-9d51-f92d742a1fa6	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 07:40:32.459816+00	po	2026-10-12 07:40:32.459816+00	po	0
eff3a4b3-851a-4f1d-9779-e2b96174c066	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 07:40:33.013098+00	po	2026-10-12 07:40:33.013098+00	po	0
b1e954ea-9cbd-4045-8ddc-5597f4bf1038	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.058167+00	po	2026-10-12 07:39:58.058167+00	po	0
51243c57-1d38-4e00-bb29-32adc3043ea2	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	db644e63-1f4c-4b80-acfd-dad2183084cc	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:58.093934+00	po	2026-10-12 07:39:58.093934+00	po	0
8c61b1c4-01bb-4a63-bf7f-1df46a9e6dcf	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.201121+00	po	2026-10-12 07:39:58.201121+00	po	0
87448b0e-727d-4431-9776-1cb04412c271	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	f5e78f12-7563-43b0-a8c9-ebeba1b377af	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:58.237137+00	po	2026-10-12 07:39:58.237137+00	po	0
dec65cb7-9889-4ef6-9392-c368421a0a4d	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	28b1b74e-4a53-47d5-aef2-e5fadce5f8bd	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:59.714206+00	po	2026-10-12 07:39:59.714206+00	po	0
891ff5a0-a6c0-410e-bb90-1bde678d0897	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	f3983cc0-e39a-4edf-85e2-10edafea9b86	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:59.746011+00	po	2026-10-12 07:39:59.746011+00	po	0
9f8c9c3c-73a5-4079-9998-b78483c3ee27	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.060818+00	po	2026-10-12 07:40:00.060818+00	po	0
46354672-5c34-4078-aeeb-5a0af1b09889	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.099784+00	po	2026-10-12 07:40:00.099784+00	po	0
e073ddbc-7bb5-463b-8a20-37a17c8a3e98	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	7b60a040-8f6b-40db-b1b9-aff842e97b39	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.129736+00	po	2026-10-12 07:40:00.129736+00	po	0
e26f87ef-8b97-41aa-b358-cc87f9ebb630	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.191266+00	po	2026-10-12 07:40:00.191266+00	po	0
42a9f8a4-98ee-43d7-8ec9-d2875ef59c63	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.816287+00	po	2026-10-12 07:40:00.816287+00	po	0
8f645e3e-8b0e-44f1-ad7a-946a40c96f50	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:03.891862+00	qa1	2026-10-12 07:40:03.891862+00	qa1	0
dc309094-5bf1-4774-aed5-20f836fc0617	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	9befb8bf-ee36-4059-8580-a412e87e9615	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.126935+00	po	2026-10-12 07:39:58.126935+00	po	0
c9d6676b-8327-491a-99f1-8b4d2755f634	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.163886+00	po	2026-10-12 07:39:58.163886+00	po	0
5ff08213-462b-475a-a042-9192911f6e2b	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 07:39:58.274582+00	po	2026-10-12 07:39:58.274582+00	po	0
2d5aa23a-a7f8-4deb-947d-a2d649d53ce3	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	d027f6ba-16d2-4763-902d-4353559529f0	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 07:39:59.438396+00	po	2026-10-12 07:39:59.438396+00	po	0
11579c2e-caa3-4efc-831f-63f197bee64c	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	64a0e4ad-69de-4a90-9db3-686f0957dfc8	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.158825+00	po	2026-10-12 07:40:00.158825+00	po	0
4ecaaad8-1d2c-43a4-b456-ff5057aca9f2	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	9befb8bf-ee36-4059-8580-a412e87e9615	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.231598+00	po	2026-10-12 07:40:00.231598+00	po	0
eb6532ce-bfd5-4a13-ad1c-89ea179e3059	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:00.271218+00	po	2026-10-12 07:40:00.271218+00	po	0
4d6040b6-0c3e-41ce-a561-5212d8946e8a	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 07:40:03.83516+00	qa1	2026-10-12 07:40:03.83516+00	qa1	0
cf5a29fd-4ceb-48d3-a2a9-84d7499765a3	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	4c7f8390-deb1-488c-a0df-683d5547250d	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:03.974779+00	qa1	2026-10-12 07:40:03.974779+00	qa1	0
78292f6c-ce2b-4314-8186-3d9b966f8554	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:04.131732+00	qa1	2026-10-12 07:40:04.131732+00	qa1	0
86f06953-2bbe-4a4b-b453-a9679a0854d5	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:04.345537+00	qa1	2026-10-12 07:40:04.345537+00	qa1	0
8e02119c-59b6-4105-b856-c7bacaa82580	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	4c7f8390-deb1-488c-a0df-683d5547250d	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["utilisateur = problem_user"], "field": "parameters", "before": null}, {"after": ["1. Se connecter avec ${utilisateur} → Le catalogue s’affiche", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 07:40:03.925478+00	qa1	2026-10-12 07:40:03.925478+00	qa1	0
4c8ebac1-dbe5-4164-9858-f3d1eb0f8820	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	3a02e1a7-0caa-492c-91ed-e6771b926f19	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:04.207603+00	qa1	2026-10-12 07:40:04.207603+00	qa1	0
29b02e14-6ea2-4836-b8c6-493a31773c8b	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 07:40:04.316587+00	dev	2026-10-12 07:40:04.316587+00	dev	0
77eb8bca-9dbd-4dbd-b6a4-6a21d6f43cc9	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	62154ec4-1fb3-4439-a00b-661092807e31	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:05.724926+00	qa1	2026-10-12 07:40:05.724926+00	qa1	0
df4ed26d-aad9-4522-b87a-47c0a4fc4c45	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 07:40:07.882428+00	po	2026-10-12 07:40:07.882428+00	po	0
684b61ea-baf1-4e18-b1b8-73c77059f4ea	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:08.250755+00	po	2026-10-12 07:40:08.250755+00	po	0
0de14afc-5a49-432b-86d0-e03514a086a5	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:08.25152+00	po	2026-10-12 07:40:08.25152+00	po	0
52351384-4e55-433d-a01c-5318ececcfcb	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	7b60a040-8f6b-40db-b1b9-aff842e97b39	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:08.25152+00	po	2026-10-12 07:40:08.25152+00	po	0
a1648cf4-7fee-4532-a638-b3e0f06ad943	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	64a0e4ad-69de-4a90-9db3-686f0957dfc8	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:08.252051+00	po	2026-10-12 07:40:08.252051+00	po	0
9214c8b7-3082-4d1c-bbf1-d44ef5b366c6	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:08.252051+00	po	2026-10-12 07:40:08.252051+00	po	0
d6d257b7-726f-4e64-8fde-826e63d865a2	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 07:40:08.252571+00	po	2026-10-12 07:40:08.252571+00	po	0
7597bd26-1c1a-4939-8b2f-006cc1fdbc85	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	90e59962-4082-49cb-b900-08fc134f99f5	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 07:40:09.304758+00	qa1	2026-10-12 07:40:09.304758+00	qa1	0
a819e85e-061f-4a10-9a11-6b695543305f	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f0ac4646-edd9-42f5-b72c-c7fb05c51703	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 07:40:04.027367+00	dev	2026-10-12 07:40:04.027367+00	dev	0
2c00227f-9658-4ee7-904d-72acb9a1d2f0	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f0ac4646-edd9-42f5-b72c-c7fb05c51703	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:04.063662+00	qa1	2026-10-12 07:40:04.063662+00	qa1	0
fbd18c73-7a11-40f3-b927-717b0bacb212	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 07:40:04.099024+00	dev	2026-10-12 07:40:04.099024+00	dev	0
16b894be-01d6-4f29-96b8-13de451c1f8b	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	3a02e1a7-0caa-492c-91ed-e6771b926f19	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 07:40:04.1674+00	dev	2026-10-12 07:40:04.1674+00	dev	0
17ce540d-1798-464e-999d-592cd1c0e961	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	29648801-a423-46a8-807a-b36dd028e6c7	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:04.2799+00	qa1	2026-10-12 07:40:04.2799+00	qa1	0
c2847989-44d8-45a6-adc0-7aeaa72d75ce	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	6c522c6c-c6a4-4f21-956b-d487f3444882	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:05.28112+00	qa1	2026-10-12 07:40:05.28112+00	qa1	0
45dde722-6fc1-4aee-8a01-a5c2e621a6c5	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	6c522c6c-c6a4-4f21-956b-d487f3444882	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 07:40:05.318924+00	qa1	2026-10-12 07:40:05.318924+00	qa1	0
368bda98-8819-41ec-a073-6900d68debe7	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	62154ec4-1fb3-4439-a00b-661092807e31	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 07:40:05.693389+00	dev	2026-10-12 07:40:05.693389+00	dev	0
6b9302c4-a523-41f9-b0d8-6e9bef296f94	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	0e76b33f-54b0-47b2-9ab5-561fe38a4174	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:05.784671+00	qa1	2026-10-12 07:40:05.784671+00	qa1	0
ee5dbd95-16a4-46f0-99bc-307af96fc853	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 07:40:07.103744+00	po	2026-10-12 07:40:07.103744+00	po	0
b4d3854e-3255-408f-92b8-5786db2879c8	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	90e59962-4082-49cb-b900-08fc134f99f5	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 07:40:31.297646+00	qa1	2026-10-12 07:40:31.297646+00	qa1	0
8a797646-928e-4375-b192-9978096db6d0	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 07:40:31.442366+00	po	2026-10-12 07:40:31.442366+00	po	0
282dcbe5-f931-42bc-a272-bafafa0a4f4d	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	29648801-a423-46a8-807a-b36dd028e6c7	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 07:40:04.244797+00	dev	2026-10-12 07:40:04.244797+00	dev	0
5e47c676-d7f5-49e6-a704-4f470dfd8b05	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	6c522c6c-c6a4-4f21-956b-d487f3444882	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 07:40:05.191036+00	qa1	2026-10-12 07:40:05.191036+00	qa1	0
23b63bcf-7053-4a30-8687-632564825bad	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	2070438a-f265-4624-ab3a-6d2cfacc48b6	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 07:40:05.872578+00	qa1	2026-10-12 07:40:05.872578+00	qa1	0
be5bce1c-62c6-4425-b90f-830dc63f50cd	9f08b136-a1be-45dc-a997-879aa2515dab	RELEASE	492e63a4-80c2-4768-9126-751443f0bb88	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 07:40:07.073289+00	po	2026-10-12 07:40:07.073289+00	po	0
a044b2f9-568c-4528-a073-cc29a857866c	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 07:40:07.955754+00	po	2026-10-12 07:40:07.955754+00	po	0
60dc6776-e8bb-4dd4-9977-02bf3e5750ca	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 07:40:08.029204+00	po	2026-10-12 07:40:08.029204+00	po	0
1578b893-6dd3-42e8-a853-d64520736b2f	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	90e59962-4082-49cb-b900-08fc134f99f5	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 07:40:09.871524+00	qa1	2026-10-12 07:40:09.871524+00	qa1	0
e6c66d7f-443e-478e-80f1-e2f29a43ec9f	9f08b136-a1be-45dc-a997-879aa2515dab	SESSION	843548d2-558b-4292-9083-f0d685a0343e	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 07:40:38.034163+00	qa1	2026-10-12 07:40:38.034163+00	qa1	0
230c530f-d978-43e9-aea1-4352927a4944	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	0e76b33f-54b0-47b2-9ab5-561fe38a4174	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 07:40:05.755614+00	dev	2026-10-12 07:40:05.755614+00	dev	0
8b09f0c1-d21d-4834-9494-49f70a46dbaa	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	2070438a-f265-4624-ab3a-6d2cfacc48b6	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:05.901215+00	qa1	2026-10-12 07:40:05.901215+00	qa1	0
33bbc885-f73b-41aa-8602-04755a08344f	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 07:40:07.807179+00	po	2026-10-12 07:40:07.807179+00	po	0
563d3a07-1195-4d2e-b5d8-611527a01597	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 07:40:08.10877+00	po	2026-10-12 07:40:08.10877+00	po	0
60acc04a-799f-49f6-be0a-8316f8b3964c	9f08b136-a1be-45dc-a997-879aa2515dab	RUN	12dc7539-fb49-4142-9b5d-d248e8e1f403	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 07:40:11.838202+00	dev	2026-10-12 07:40:11.838202+00	dev	0
cfb90fe6-eb87-48be-98ab-351c5bb24954	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	7b60a040-8f6b-40db-b1b9-aff842e97b39	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 07:40:31.482128+00	po	2026-10-12 07:40:31.482128+00	po	0
ce0e2bd8-12c6-4749-b125-3fc5d06a3207	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 07:40:33.712154+00	po	2026-10-12 07:40:33.712154+00	po	0
8b695df9-553e-46e2-8d7d-0ab0726e16a7	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-10"], "field": "tests", "before": []}]	2026-10-12 07:40:34.287637+00	qa1	2026-10-12 07:40:34.287637+00	qa1	0
1168975b-9654-4b5d-832d-e83a3abba9ec	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-10"]}]	2026-10-12 07:40:34.308316+00	qa1	2026-10-12 07:40:34.308316+00	qa1	0
ff889999-7c92-4b0d-b421-942726cf4235	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cd9e8633-71ad-4c8e-816d-f194ed4637f0	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 07:40:05.814943+00	dev	2026-10-12 07:40:05.814943+00	dev	0
8bd04ba9-94fc-4c35-a8d6-e02f1f950fde	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cd9e8633-71ad-4c8e-816d-f194ed4637f0	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 07:40:05.842421+00	qa1	2026-10-12 07:40:05.842421+00	qa1	0
03dbbde6-bdab-4a40-ae92-b8369cbacc56	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 07:40:07.144294+00	po	2026-10-12 07:40:07.144294+00	po	0
aa7d5f3e-a1c3-4ecb-91a3-2c04a7b35cf7	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	90e59962-4082-49cb-b900-08fc134f99f5	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 07:40:09.639128+00	qa1	2026-10-12 07:40:09.639128+00	qa1	0
cbea462a-12ba-41ae-8107-f03ca0469d96	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 07:40:31.397944+00	po	2026-10-12 07:40:31.397944+00	po	0
6eb6fbf6-fa60-4fc8-8036-880468ef9dd2	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	9befb8bf-ee36-4059-8580-a412e87e9615	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:33.752541+00	po	2026-10-12 07:40:33.752541+00	po	0
ee4d3875-4319-4aab-9863-732426707ea9	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:33.753063+00	po	2026-10-12 07:40:33.753063+00	po	0
41882b00-9c79-42de-9bd7-831c1f690f1e	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 07:40:33.753063+00	po	2026-10-12 07:40:33.753063+00	po	0
c4eb0ff0-069b-4c41-aee6-f852194a1e8c	9f08b136-a1be-45dc-a997-879aa2515dab	SPRINT	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 07:40:33.753063+00	po	2026-10-12 07:40:33.753063+00	po	0
035c1e55-5d71-49e7-9c41-c07e3d5ef381	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 07:40:34.262427+00	qa1	2026-10-12 07:40:34.262427+00	qa1	0
1de7f49a-3242-4776-9638-39fa489eb5e0	9f08b136-a1be-45dc-a997-879aa2515dab	DEFECT	8cfbf174-d4f9-44df-96f8-9b9a2307f69b	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 00:00\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 07:40:37.231948+00	qa1	2026-10-12 07:40:37.231948+00	qa1	0
533e60fe-69de-4b01-bc05-e3572563d9c4	9f08b136-a1be-45dc-a997-879aa2515dab	SESSION	843548d2-558b-4292-9083-f0d685a0343e	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 07:40:38.228723+00	qa1	2026-10-12 07:40:38.228723+00	qa1	0
d6bb4ff7-b3ca-4355-8bb9-6996daf7be58	9f08b136-a1be-45dc-a997-879aa2515dab	RUN	6e160147-b0d7-47f7-ba6c-0060be87d02a	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 07:40:39.728729+00	dev	2026-10-12 07:40:39.728729+00	dev	0
8636b0f9-23ba-4178-951a-399e2e3fa395	9f08b136-a1be-45dc-a997-879aa2515dab	DEFECT	877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Se connecter avec problem_user\\n2. Cliquer « Add to cart » sur Sauce Labs Backpack\\n3. Ouvrir le panier\\n4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 07:40:35.968961+00	qa2	2026-10-12 07:40:35.968961+00	qa2	0
46203e00-24c4-4b83-93cd-23da11536df0	9f08b136-a1be-45dc-a997-879aa2515dab	SESSION	843548d2-558b-4292-9083-f0d685a0343e	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 07:40:36.568574+00	qa1	2026-10-12 07:40:36.568574+00	qa1	0
be664042-dae6-4542-a3ab-72a8d1e005ba	9f08b136-a1be-45dc-a997-879aa2515dab	SESSION	843548d2-558b-4292-9083-f0d685a0343e	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 07:40:38.801855+00	po	2026-10-12 07:40:38.801855+00	po	0
0653e68a-99da-4039-b17d-f897d175f434	9f08b136-a1be-45dc-a997-879aa2515dab	CAMPAIGN	c9959d99-7505-4d64-b08f-5926da9edc59	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 07:40:59.015675+00	qa1	2026-10-12 07:40:59.015675+00	qa1	0
bf1c3a69-20f8-448f-a07c-bcf4384849cd	9f08b136-a1be-45dc-a997-879aa2515dab	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 07:41:02.730318+00	po	2026-10-12 07:41:02.730318+00	po	0
ac5e0dda-0095-451b-ad8f-4dcec8684990	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	29648801-a423-46a8-807a-b36dd028e6c7	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 07:41:02.737554+00	po	2026-10-12 07:41:02.737554+00	po	0
c7e6ace8-140b-4f52-9b7f-7ff558002869	9f08b136-a1be-45dc-a997-879aa2515dab	TRACE_LINK	58a7edf2-3a43-49fc-a5b6-b2f8c4003c51	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 07:41:02.919077+00	qa1	2026-10-12 07:41:02.919077+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
12dc7539-fb49-4142-9b5d-d248e8e1f403	9f08b136-a1be-45dc-a997-879aa2515dab	RUN-1	1	90e59962-4082-49cb-b900-08fc134f99f5	3f6b21dc-9258-49f5-9486-3f18ec6fcdb3	COMPLETED	dev	2026-10-12 07:40:11.83362+00	2026-10-12 07:40:11.875376+00	2026-10-12 07:40:11.873197+00	2026-10-12 07:40:30.663115+00	2026-10-12 07:40:30.663115+00	recette	1.0.0-s1	job-da367103	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-da367103/logs	http://localhost:8091/api/v1/jobs/job-da367103/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 07:40:11.836703+00	dev	2026-10-12 07:40:30.676765+00	anonymousUser	12
6e160147-b0d7-47f7-ba6c-0060be87d02a	9f08b136-a1be-45dc-a997-879aa2515dab	RUN-2	2	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	3f6b21dc-9258-49f5-9486-3f18ec6fcdb3	COMPLETED	dev	2026-10-12 07:40:39.727638+00	2026-10-12 07:40:39.758915+00	2026-10-12 07:40:39.75739+00	2026-10-12 07:40:58.037715+00	2026-10-12 07:40:58.037715+00	recette	1.0.0-s2	job-eea5ceba	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-eea5ceba/logs	http://localhost:8091/api/v1/jobs/job-eea5ceba/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 07:40:39.728212+00	dev	2026-10-12 07:40:58.051917+00	anonymousUser	8
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
fdc43ba0-fff6-42fd-be9f-6463568669c1	f0ac4646-edd9-42f5-b72c-c7fb05c51703	DATA_DRIVEN	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 07:40:04.018931+00	dev	2026-10-12 07:40:04.018931+00	dev	0
4ef4fda5-9e41-48d4-a495-d3f70e42edbe	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 07:40:04.094894+00	dev	2026-10-12 07:40:04.094894+00	dev	0
7ae7f5cf-95aa-44c1-894d-4b6e0531ee94	3a02e1a7-0caa-492c-91ed-e6771b926f19	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 07:40:04.164316+00	dev	2026-10-12 07:40:04.164316+00	dev	0
3ea34d66-cf65-439e-9475-7d3eb076ed3c	29648801-a423-46a8-807a-b36dd028e6c7	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 07:40:04.240903+00	dev	2026-10-12 07:40:04.240903+00	dev	0
fa85ce6e-f83a-40e6-b7a5-f692f2a4746b	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	API	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 07:40:04.310975+00	dev	2026-10-12 07:40:04.310975+00	dev	0
bbed1a2d-3bbf-499c-a444-4da61d8c7922	6c522c6c-c6a4-4f21-956b-d487f3444882	BDD	Playwright	\N	file:///depots/traceagile	installation-hors-docker	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 07:40:05.174833+00	qa1	2026-10-12 07:40:05.319557+00	qa1	1
6847acac-b5c1-4187-8350-3aeb50cbc66c	62154ec4-1fb3-4439-a00b-661092807e31	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 07:40:05.690265+00	dev	2026-10-12 07:40:05.690265+00	dev	0
152f2647-68ef-4d1d-80da-c3d2754de95b	0e76b33f-54b0-47b2-9ab5-561fe38a4174	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 07:40:05.751824+00	dev	2026-10-12 07:40:05.751824+00	dev	0
274b28bd-c1e3-4f46-9923-05a97dc2b692	cd9e8633-71ad-4c8e-816d-f194ed4637f0	PERFORMANCE	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 07:40:05.811384+00	dev	2026-10-12 07:40:05.811384+00	dev	0
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5df27a0e-3113-4944-a2bd-efb32a4767ef	BDD	Cucumber-JVM	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
d8bbd6e4-c21e-4c29-adbb-ebd2257774ab	BDD	Cucumber-JS	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
e0bffd69-4619-4831-8f54-17131b67b704	BDD	Behave	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
84fa0e91-6850-48cd-a609-d6fde300c33b	BDD	SpecFlow	4	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
c7e928f7-f86e-40f6-adfe-10a705d17875	BDD	Karate	5	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
eb429316-6fcd-4aa0-b616-76def345ca69	UNIT	JUnit 5	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
6ee8b1f5-dc72-4df2-9184-0a682ddcef6c	UNIT	Kotest	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
49abbf02-c149-44ed-a0d9-ef68b5e8b481	UNIT	pytest	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
190f452e-1411-4bfa-adad-cf76feae3355	UNIT	Jest	4	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
b616497b-cb16-4280-b811-b280ec9d9c98	UNIT	Vitest	5	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
83d255c4-3ac1-426e-9486-565836b25a60	UI	Playwright	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
2cc38441-e7ad-4462-9af5-0509b94f9190	UI	Selenium	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
302f2ccd-434b-4b0c-ab61-3e118f0625ee	UI	Cypress	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
12b43f41-6ee6-4de6-aa61-72fd9f37421f	UI	Appium	4	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
4b84d822-9e12-4298-80c5-ef15dd79c836	API	REST Assured	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
f6178e7d-de4a-4df8-bdcd-6441dd10cf16	API	Karate	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
c6b2a44e-ba70-4431-81ed-55df7526837b	API	Postman/Newman	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
5404a3e0-a20f-43d2-ad30-b532a0b25d68	API	pytest + requests	4	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
afdd1129-be13-4f2a-a8d2-323e3c64ef28	KEYWORD	Robot Framework	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
65103788-91c5-4d37-9300-2f5b3cf7decb	DATA_DRIVEN	JUnit 5	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
c5bbbbe5-f308-4903-9969-78663cbd7f52	DATA_DRIVEN	pytest	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
2ca67543-6367-4a6a-a96d-086110382b3c	DATA_DRIVEN	Playwright	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
bfb5a4fb-9a56-4e37-acfa-3a5173a8fba8	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
c07d791b-3876-4e1e-a4ff-daecf15dbfbd	PERFORMANCE	Gatling	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
ddd40723-6cba-435f-8a79-5bb60f841d84	PERFORMANCE	k6	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
4ffefeb2-2ebf-4786-ada7-f9b4854c0dae	PERFORMANCE	JMeter	3	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
f3d46d28-dd03-493c-a2be-f6a9765fa42f	CONTRACT	Pact	1	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
5098ecac-5850-4e25-97a8-99897a457762	CONTRACT	Spring Cloud Contract	2	2026-10-12 07:39:47.618286+00	system	2026-10-12 07:39:47.618286+00	system	0
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
42594787-316f-4c7b-b024-78d8fac56ec7	90e59962-4082-49cb-b900-08fc134f99f5	f0ac4646-edd9-42f5-b72c-c7fb05c51703	1	\N	4	12	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.630047+00	qa1	0	\N	\N
6bee902d-abb7-484b-971b-16f9d6676720	90e59962-4082-49cb-b900-08fc134f99f5	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	1	\N	5	6	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.630047+00	qa1	0	\N	\N
92d3527e-ab59-478e-9ba8-880c06872c26	90e59962-4082-49cb-b900-08fc134f99f5	3a02e1a7-0caa-492c-91ed-e6771b926f19	1	\N	6	3	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.630047+00	qa1	0	\N	\N
e5ee1051-a43a-41f9-aa84-dff24e837fd2	90e59962-4082-49cb-b900-08fc134f99f5	29648801-a423-46a8-807a-b36dd028e6c7	1	\N	7	3	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.630047+00	qa1	0	\N	\N
449fafaf-cd3c-4875-8c78-04c178862133	90e59962-4082-49cb-b900-08fc134f99f5	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	1	\N	8	6	2026-10-12 07:40:09.868119+00	qa1	2026-10-12 07:40:09.868119+00	qa1	0	\N	\N
34b8b20e-a0c1-4b24-9efc-b81ecb6bf41a	90e59962-4082-49cb-b900-08fc134f99f5	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	051f7375-7cc7-4828-a8d7-12cc1c039f47	1	16	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.910932+00	qa1	1	Comptes	0
fa8ee3c8-a0cb-4a84-b061-e558daa30a2e	90e59962-4082-49cb-b900-08fc134f99f5	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	051f7375-7cc7-4828-a8d7-12cc1c039f47	2	16	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.93121+00	qa1	1	Comptes	1
76fbb323-95e8-4d19-8aae-e0c69310fee5	90e59962-4082-49cb-b900-08fc134f99f5	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	051f7375-7cc7-4828-a8d7-12cc1c039f47	3	16	2026-10-12 07:40:09.630047+00	qa1	2026-10-12 07:40:09.948594+00	qa1	1	Comptes	2
298f15c4-2c44-47c1-bfc0-cad03f6a4523	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	6c522c6c-c6a4-4f21-956b-d487f3444882	2	\N	3	12	2026-10-12 07:40:34.28344+00	qa1	2026-10-12 07:40:34.28344+00	qa1	0	\N	\N
ccec547c-271a-4f86-9c47-5afddbc13824	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	62154ec4-1fb3-4439-a00b-661092807e31	1	\N	4	12	2026-10-12 07:40:34.283993+00	qa1	2026-10-12 07:40:34.283993+00	qa1	0	\N	\N
80069196-c7f1-4a26-8f08-78c7a0f0e919	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	0e76b33f-54b0-47b2-9ab5-561fe38a4174	1	\N	5	6	2026-10-12 07:40:34.283993+00	qa1	2026-10-12 07:40:34.283993+00	qa1	0	\N	\N
a125e40f-8770-424a-9003-d020a6a2b4d4	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	cd9e8633-71ad-4c8e-816d-f194ed4637f0	1	\N	6	6	2026-10-12 07:40:34.307286+00	qa1	2026-10-12 07:40:34.307286+00	qa1	0	\N	\N
65b9e415-0e16-401b-96fe-99a3cbe02b62	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	4c7f8390-deb1-488c-a0df-683d5547250d	1	7f25af9a-826c-4dca-af42-c02c2f7b337d	1	16	2026-10-12 07:40:34.28344+00	qa1	2026-10-12 07:40:34.340773+00	qa1	1	\N	\N
d5f50d31-3952-428d-833b-a714cfee458d	eed50eaf-fb6c-493f-a126-f4000ddd8bb7	2070438a-f265-4624-ab3a-6d2cfacc48b6	1	051f7375-7cc7-4828-a8d7-12cc1c039f47	2	16	2026-10-12 07:40:34.28344+00	qa1	2026-10-12 07:40:34.357453+00	qa1	1	\N	\N
292bb428-27ee-41ac-8ff8-841576751afb	c9959d99-7505-4d64-b08f-5926da9edc59	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	1	\N	1	0	2026-10-12 07:40:59.828136+00	qa1	2026-10-12 07:40:59.828136+00	qa1	0	\N	\N
c3d1aeab-e094-41b0-82ed-f57349744612	c9959d99-7505-4d64-b08f-5926da9edc59	f0ac4646-edd9-42f5-b72c-c7fb05c51703	1	\N	2	0	2026-10-12 07:40:59.837145+00	qa1	2026-10-12 07:40:59.837145+00	qa1	0	\N	\N
390884e7-37e5-44b8-8231-5104e3ea73ff	c9959d99-7505-4d64-b08f-5926da9edc59	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	1	\N	3	0	2026-10-12 07:40:59.843371+00	qa1	2026-10-12 07:40:59.843371+00	qa1	0	\N	\N
32b428a1-2994-4120-a38f-62d37dea4a34	c9959d99-7505-4d64-b08f-5926da9edc59	3a02e1a7-0caa-492c-91ed-e6771b926f19	1	\N	4	0	2026-10-12 07:40:59.849262+00	qa1	2026-10-12 07:40:59.849262+00	qa1	0	\N	\N
3813ee45-6fd0-4722-aca1-525522900a6d	c9959d99-7505-4d64-b08f-5926da9edc59	29648801-a423-46a8-807a-b36dd028e6c7	1	\N	5	0	2026-10-12 07:40:59.854673+00	qa1	2026-10-12 07:40:59.854673+00	qa1	0	\N	\N
a12ef7d0-f1c1-461e-9e44-6d415b8a6d9c	c9959d99-7505-4d64-b08f-5926da9edc59	6c522c6c-c6a4-4f21-956b-d487f3444882	2	\N	6	0	2026-10-12 07:40:59.859368+00	qa1	2026-10-12 07:40:59.859368+00	qa1	0	\N	\N
0800a3f1-9110-4c8f-87a9-8d9b27779441	c9959d99-7505-4d64-b08f-5926da9edc59	62154ec4-1fb3-4439-a00b-661092807e31	1	\N	7	0	2026-10-12 07:40:59.863503+00	qa1	2026-10-12 07:40:59.863503+00	qa1	0	\N	\N
2b57df82-cab5-4a85-89ea-122f257cd66c	c9959d99-7505-4d64-b08f-5926da9edc59	0e76b33f-54b0-47b2-9ab5-561fe38a4174	1	\N	8	0	2026-10-12 07:40:59.867758+00	qa1	2026-10-12 07:40:59.867758+00	qa1	0	\N	\N
f42bccc8-abb5-443e-a302-297a3230070a	c9959d99-7505-4d64-b08f-5926da9edc59	cd9e8633-71ad-4c8e-816d-f194ed4637f0	1	\N	9	0	2026-10-12 07:40:59.872263+00	qa1	2026-10-12 07:40:59.872263+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
90e59962-4082-49cb-b900-08fc134f99f5	9f08b136-a1be-45dc-a997-879aa2515dab	CMP-1	1	Recette sprint 1	SPRINT	8a88d0fc-6f94-453b-b458-eb6a06780ff4	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 07:40:09.304053+00	qa1	2026-10-12 07:40:31.297646+00	qa1	3	Release 1.0/Recettes de sprint
eed50eaf-fb6c-493f-a126-f4000ddd8bb7	9f08b136-a1be-45dc-a997-879aa2515dab	CMP-2	2	Recette sprint 2	SPRINT	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 07:40:34.261909+00	qa1	2026-10-12 07:40:34.793891+00	qa2	2	Release 1.0/Recettes de sprint
c9959d99-7505-4d64-b08f-5926da9edc59	9f08b136-a1be-45dc-a997-879aa2515dab	CMP-3	3	Intégration continue — main	RELEASE	\N	492e63a4-80c2-4768-9126-751443f0bb88	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 07:40:59.015067+00	qa1	2026-10-12 07:40:59.830898+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8dc9baae-880d-4fd7-95bd-d4d0f4a41306	9f08b136-a1be-45dc-a997-879aa2515dab	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 07:39:56.58327+00	admin	2026-10-12 07:39:56.58327+00	admin	0
9469dfaa-1574-4489-be5f-0a69b2989b7a	9f08b136-a1be-45dc-a997-879aa2515dab	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 07:39:56.584045+00	admin	2026-10-12 07:39:56.584045+00	admin	0
3b750551-630a-457f-9d84-24f20a523e07	9f08b136-a1be-45dc-a997-879aa2515dab	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 07:39:56.584045+00	admin	2026-10-12 07:39:56.584045+00	admin	0
761d4c73-ba96-43be-a5cb-d789686a099e	9f08b136-a1be-45dc-a997-879aa2515dab	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 07:39:56.584045+00	admin	2026-10-12 07:39:56.584045+00	admin	0
509607a8-c471-4208-9f9d-ea17ea9a1f37	9f08b136-a1be-45dc-a997-879aa2515dab	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 07:39:56.584561+00	admin	2026-10-12 07:39:56.584561+00	admin	0
6be744e9-9b66-4020-ab50-3d4acbf6e083	9f08b136-a1be-45dc-a997-879aa2515dab	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 07:39:56.584561+00	admin	2026-10-12 07:39:56.584561+00	admin	0
924edd26-f918-44e1-af13-015817b565f4	9f08b136-a1be-45dc-a997-879aa2515dab	DOD	4	Code revu et intégré	\N	2026-10-12 07:39:56.585084+00	admin	2026-10-12 07:39:56.585084+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a635e1d2-74d2-489b-ba16-adc9acc44764	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 07:40:02.194769+00	po	2026-10-12 07:40:02.194769+00	po	0
79b9fd39-9836-4c88-b872-d1871d8f83ee	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 07:40:02.658424+00	po	2026-10-12 07:40:02.658424+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	50a14f68-b9a7-4b87-80c8-5086a12f80e4
8cfbf174-d4f9-44df-96f8-9b9a2307f69b	6cc6622d-4e09-4950-818e-90e193d74bfd
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	c72b0e88-aecc-4da3-a5de-a45f0e500dcb
877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	87820fdd-6bd4-4cec-99e0-2d8e520e7b55
8cfbf174-d4f9-44df-96f8-9b9a2307f69b	c72b0e88-aecc-4da3-a5de-a45f0e500dcb
8cfbf174-d4f9-44df-96f8-9b9a2307f69b	87820fdd-6bd4-4cec-99e0-2d8e520e7b55
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
877d2120-ce8a-4f7e-bebb-d3c02e29bfeb	9f08b136-a1be-45dc-a997-879aa2515dab	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Se connecter avec problem_user\n2. Cliquer « Add to cart » sur Sauce Labs Backpack\n3. Ouvrir le panier\n4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 07:40:35.96845+00	qa2	2026-10-12 07:40:35.973997+00	qa2	1
8cfbf174-d4f9-44df-96f8-9b9a2307f69b	9f08b136-a1be-45dc-a997-879aa2515dab	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 00:00\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 07:40:37.231433+00	qa1	2026-10-12 07:40:37.234106+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ebbe6b5c-294f-4a22-8dc8-9540dac0baae	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 07:40:01.799874+00	po	2026-10-12 07:40:01.799874+00	po	0
317591fe-85a3-4c2d-9869-d16c6428e07c	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	EXAMPLE	ebbe6b5c-294f-4a22-8dc8-9540dac0baae	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 07:40:01.922959+00	po	2026-10-12 07:40:01.922959+00	po	0
b8e677ed-bef4-4aab-8b40-834b6128ad1f	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	EXAMPLE	ebbe6b5c-294f-4a22-8dc8-9540dac0baae	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 07:40:01.989706+00	po	2026-10-12 07:40:01.989706+00	po	0
28605f54-d977-4970-845b-de55d92a809e	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 07:40:02.048208+00	po	2026-10-12 07:40:02.048208+00	po	0
97b2c686-3b1e-436c-b44e-721ba0daba36	3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	EXAMPLE	28605f54-d977-4970-845b-de55d92a809e	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 07:40:02.120658+00	po	2026-10-12 07:40:02.120658+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3f6b21dc-9258-49f5-9486-3f18ec6fcdb3	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Cucumber-JS"]	[]	4	t	2026-10-12 07:39:57.039962+00	admin	2026-10-12 07:40:12.007455+00	system	2
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
ab4a1ecc-1647-4937-ad11-39a992987c59	34b8b20e-a0c1-4b24-9efc-b81ecb6bf41a	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	1	PASSED	f	2026-10-12 07:40:10.376087+00	2026-10-12 07:40:10.640377+00	264	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 07:40:10.380378+00	qa1	2026-10-12 07:40:10.64192+00	qa1	1	\N
f75df1ba-9018-47a6-ae22-4c7447c1a1d8	fa8ee3c8-a0cb-4a84-b061-e558daa30a2e	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	1	PASSED	f	2026-10-12 07:40:10.734202+00	2026-10-12 07:40:10.767999+00	33	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 07:40:10.735995+00	qa1	2026-10-12 07:40:10.769045+00	qa1	1	\N
4f2cdd0b-8892-46e4-b893-4695c93c2fab	76fbb323-95e8-4d19-8aae-e0c69310fee5	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	1	PASSED	f	2026-10-12 07:40:10.782261+00	2026-10-12 07:40:10.814077+00	31	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 07:40:10.784322+00	qa1	2026-10-12 07:40:10.81511+00	qa1	1	\N
9dacfe35-96c8-4c64-a3d2-3c988d18e1a8	449fafaf-cd3c-4875-8c78-04c178862133	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	1	1	PASSED	f	2026-10-12 07:40:26.061505+00	2026-10-12 07:40:28.463125+00	2400	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:11.83775+00	dev	2026-10-12 07:40:28.481459+00	anonymousUser	2	12dc7539-fb49-4142-9b5d-d248e8e1f403
ee41d0b8-b947-4d89-8776-d43aa1a55b82	42594787-316f-4c7b-b024-78d8fac56ec7	f0ac4646-edd9-42f5-b72c-c7fb05c51703	1	1	PASSED	f	2026-10-12 07:40:26.061505+00	2026-10-12 07:40:29.146091+00	3084	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:11.837237+00	dev	2026-10-12 07:40:29.158762+00	anonymousUser	2	12dc7539-fb49-4142-9b5d-d248e8e1f403
c34d7a74-5fc4-4105-9db2-3c287ec4e374	6bee902d-abb7-484b-971b-16f9d6676720	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	1	1	PASSED	f	2026-10-12 07:40:26.061505+00	2026-10-12 07:40:29.207669+00	3145	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:11.837237+00	dev	2026-10-12 07:40:29.219124+00	anonymousUser	2	12dc7539-fb49-4142-9b5d-d248e8e1f403
9c4bb3b5-16c4-462b-bdbe-d54de5cfbdd4	e5ee1051-a43a-41f9-aa84-dff24e837fd2	29648801-a423-46a8-807a-b36dd028e6c7	1	1	PASSED	f	2026-10-12 07:40:28.49735+00	2026-10-12 07:40:30.136913+00	1639	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:11.83775+00	dev	2026-10-12 07:40:30.148975+00	anonymousUser	2	12dc7539-fb49-4142-9b5d-d248e8e1f403
d6841386-2054-4b6d-8207-767919be1288	92d3527e-ab59-478e-9ba8-880c06872c26	3a02e1a7-0caa-492c-91ed-e6771b926f19	1	1	PASSED	f	2026-10-12 07:40:11.83362+00	2026-10-12 07:40:30.632691+00	4570	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:11.83775+00	dev	2026-10-12 07:40:30.6468+00	anonymousUser	1	12dc7539-fb49-4142-9b5d-d248e8e1f403
50a14f68-b9a7-4b87-80c8-5086a12f80e4	65b9e415-0e16-401b-96fe-99a3cbe02b62	4c7f8390-deb1-488c-a0df-683d5547250d	1	1	FAILED	f	2026-10-12 07:40:34.791167+00	2026-10-12 07:40:35.440309+00	649	\N	qa2	MANUAL	\N	\N	{"utilisateur": "problem_user"}	2026-10-12 07:40:34.793375+00	qa2	2026-10-12 07:40:35.44134+00	qa2	1	\N
6cc6622d-4e09-4950-818e-90e193d74bfd	d5f50d31-3952-428d-833b-a714cfee458d	2070438a-f265-4624-ab3a-6d2cfacc48b6	1	1	FAILED	f	2026-10-12 07:40:36.562874+00	2026-10-12 07:40:38.030192+00	1000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 07:40:36.567539+00	qa1	2026-10-12 07:40:38.034163+00	qa1	1	\N
ce1acaf8-0b9d-46a9-a2b3-9260259592d8	298f15c4-2c44-47c1-bfc0-cad03f6a4523	6c522c6c-c6a4-4f21-956b-d487f3444882	1	2	PASSED	f	2026-10-12 07:40:51.918913+00	2026-10-12 07:40:54.969045+00	3049	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:39.728212+00	dev	2026-10-12 07:40:54.980057+00	anonymousUser	2	6e160147-b0d7-47f7-ba6c-0060be87d02a
e9a7bed2-192e-4f35-96c9-db00edd9865a	ccec547c-271a-4f86-9c47-5afddbc13824	62154ec4-1fb3-4439-a00b-661092807e31	1	1	PASSED	f	2026-10-12 07:40:51.918781+00	2026-10-12 07:40:55.043085+00	3123	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:39.728729+00	dev	2026-10-12 07:40:55.056805+00	anonymousUser	2	6e160147-b0d7-47f7-ba6c-0060be87d02a
4b8c15d8-b520-4ac2-941f-09a23d68afb4	a125e40f-8770-424a-9003-d020a6a2b4d4	cd9e8633-71ad-4c8e-816d-f194ed4637f0	1	1	PASSED	f	2026-10-12 07:40:51.918787+00	2026-10-12 07:40:55.352752+00	3433	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:39.728729+00	dev	2026-10-12 07:40:55.361934+00	anonymousUser	2	6e160147-b0d7-47f7-ba6c-0060be87d02a
aad11270-104e-4556-a4f9-5faa839dfe69	80069196-c7f1-4a26-8f08-78c7a0f0e919	0e76b33f-54b0-47b2-9ab5-561fe38a4174	1	1	FAILED	f	2026-10-12 07:40:51.918821+00	2026-10-12 07:40:58.007248+00	6087	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-eea5ceba/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 07:40:39.728729+00	dev	2026-10-12 07:40:58.022719+00	anonymousUser	2	6e160147-b0d7-47f7-ba6c-0060be87d02a
4746f460-44fd-4b14-976f-5d685e6915a6	292bb428-27ee-41ac-8ff8-841576751afb	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	1	1	PASSED	f	2026-10-12 07:40:59.265253+00	2026-10-12 07:40:59.827253+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.830141+00	qa1	2026-10-12 07:40:59.830141+00	qa1	0	\N
64bfd509-7073-43c1-ab8a-0a144ff58678	c3d1aeab-e094-41b0-82ed-f57349744612	f0ac4646-edd9-42f5-b72c-c7fb05c51703	1	1	PASSED	f	2026-10-12 07:40:56.312253+00	2026-10-12 07:40:59.827253+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.83979+00	qa1	2026-10-12 07:40:59.83979+00	qa1	0	\N
eb8b695e-d28b-40e4-ab3c-7ef882ed7c37	390884e7-37e5-44b8-8231-5104e3ea73ff	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	1	1	PASSED	f	2026-10-12 07:40:56.622253+00	2026-10-12 07:40:59.827253+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.845029+00	qa1	2026-10-12 07:40:59.845029+00	qa1	0	\N
39129741-6c5c-4ab4-a82d-2570072e0a2e	32b428a1-2994-4120-a38f-62d37dea4a34	3a02e1a7-0caa-492c-91ed-e6771b926f19	1	1	PASSED	f	2026-10-12 07:40:59.385253+00	2026-10-12 07:40:59.827253+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.850607+00	qa1	2026-10-12 07:40:59.850607+00	qa1	0	\N
d09acc91-801f-42dd-a5bd-9a567ffb63a7	3813ee45-6fd0-4722-aca1-525522900a6d	29648801-a423-46a8-807a-b36dd028e6c7	1	1	PASSED	f	2026-10-12 07:40:59.290253+00	2026-10-12 07:40:59.827253+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.856784+00	qa1	2026-10-12 07:40:59.856784+00	qa1	0	\N
593e6187-72a9-45e4-aa11-cb12b6903f7f	a12ef7d0-f1c1-461e-9e44-6d415b8a6d9c	6c522c6c-c6a4-4f21-956b-d487f3444882	1	2	PASSED	f	2026-10-12 07:40:59.140253+00	2026-10-12 07:40:59.827253+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.8604+00	qa1	2026-10-12 07:40:59.8604+00	qa1	0	\N
21290a3b-ce48-4616-8c7c-f237c3f8a78e	0800a3f1-9110-4c8f-87a9-8d9b27779441	62154ec4-1fb3-4439-a00b-661092807e31	1	1	PASSED	f	2026-10-12 07:40:59.280253+00	2026-10-12 07:40:59.827253+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.865047+00	qa1	2026-10-12 07:40:59.865047+00	qa1	0	\N
0ea957c5-bd21-49f2-800a-5b2c07d3f4c9	2b57df82-cab5-4a85-89ea-122f257cd66c	0e76b33f-54b0-47b2-9ab5-561fe38a4174	1	1	FAILED	f	2026-10-12 07:40:56.359253+00	2026-10-12 07:40:59.827253+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.869295+00	qa1	2026-10-12 07:40:59.869295+00	qa1	0	\N
64636b8b-64eb-4458-8d2d-184a391e4a7c	f42bccc8-abb5-443e-a302-297a3230070a	cd9e8633-71ad-4c8e-816d-f194ed4637f0	1	1	PASSED	f	2026-10-12 07:40:59.013253+00	2026-10-12 07:40:59.827253+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 07:40:59.873815+00	qa1	2026-10-12 07:40:59.873815+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b1c083dc-7851-4cf2-9f33-f4d963aa68d3	2070438a-f265-4624-ab3a-6d2cfacc48b6	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 07:40:05.865411+00	qa1	2026-10-12 07:40:05.865411+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
843548d2-558b-4292-9083-f0d685a0343e	6cc6622d-4e09-4950-818e-90e193d74bfd	DEBRIEFED	60	1	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 07:40:38.227656+00	po	2026-10-12 07:40:38.800601+00	2026-10-12 07:40:36.567539+00	qa1	2026-10-12 07:40:38.801855+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 09:39:47.440555	48	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 09:39:47.514794	78	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 09:39:47.610102	78	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 09:39:47.7067	14	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 09:39:47.7324	6	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 09:39:47.749759	38	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 09:39:47.799735	69	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 09:39:47.884984	11	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 09:39:47.912204	10	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 09:39:47.937306	17	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 09:39:47.968726	32	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 09:39:48.012593	39	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 09:39:48.063195	13	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 09:39:48.086198	28	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 09:39:48.123686	22	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 09:39:48.155688	15	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 09:39:48.179333	10	t
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
9f08b136-a1be-45dc-a997-879aa2515dab	REQ	18
9f08b136-a1be-45dc-a997-879aa2515dab	TC	13
9f08b136-a1be-45dc-a997-879aa2515dab	REL	2
9f08b136-a1be-45dc-a997-879aa2515dab	SPR	3
9f08b136-a1be-45dc-a997-879aa2515dab	DEF	3
9f08b136-a1be-45dc-a997-879aa2515dab	RUN	3
9f08b136-a1be-45dc-a997-879aa2515dab	CMP	4
9f08b136-a1be-45dc-a997-879aa2515dab	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters") FROM stdin;
320fe4dd-5d5b-4c02-ac25-dfb889475cda	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 07:40:03.819218+00	qa1	2026-10-12 07:40:03.819218+00	qa1	0	\N	{}
72e4ce62-41a1-459c-844c-2175d1054a55	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 07:40:03.819805+00	qa1	2026-10-12 07:40:03.819805+00	qa1	0	\N	{}
f47b4bb2-e8a7-4f85-aa29-9a30662ed3ae	4c7f8390-deb1-488c-a0df-683d5547250d	1	Se connecter avec ${utilisateur}	Le catalogue s’affiche	\N	2026-10-12 07:40:03.91916+00	qa1	2026-10-12 07:40:03.91916+00	qa1	0	\N	{}
e7841358-52ad-4747-b66d-9777a84460dd	4c7f8390-deb1-488c-a0df-683d5547250d	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 07:40:03.91916+00	qa1	2026-10-12 07:40:03.91916+00	qa1	0	\N	{}
82a65842-cead-48a2-9e4a-1a011ed62cd6	4c7f8390-deb1-488c-a0df-683d5547250d	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 07:40:03.91916+00	qa1	2026-10-12 07:40:03.91916+00	qa1	0	\N	{}
42e4f622-afcf-4276-b901-00c3e85887bc	4c7f8390-deb1-488c-a0df-683d5547250d	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 07:40:03.91916+00	qa1	2026-10-12 07:40:03.91916+00	qa1	0	\N	{}
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
0cf0dc3e-9e5a-428e-b2d9-573f77bdd18b	28b1b74e-4a53-47d5-aef2-e5fadce5f8bd	507	ms	p95Ms	TC-11	RUN-2	2026-10-12 07:40:55.352752+00	TARGET_MET	2026-10-12 07:40:55.372979+00	anonymousUser	2026-10-12 07:40:55.372979+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
d2fb921a-29c6-4e1f-ab44-8ac3824278d7	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:11.889198+00
22bea90f-321b-40c4-80bc-36b9336534e1	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:26.073131+00
224aae8d-b891-4147-91f0-fca2d2b24e36	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:26.616503+00
b8521a00-0a3f-4f6a-a4f5-fc1ff83ccc6b	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:27.643042+00
ffc607e9-7e55-49ec-8fc5-38b2beba314a	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:28.47208+00
3ad73d91-3a1c-4faf-877a-d4cd9e8ab83a	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:28.50468+00
6d0dea92-369d-4d47-85b3-d9cdc03fc780	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:29.154122+00
b94c9914-8feb-490a-92af-92d79762d305	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:29.214852+00
ac7e58fe-66a9-4528-9c06-c232f54e8734	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:30.144945+00
c20e1a94-8cc1-45fb-a41b-294d29c52dd5	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:30.641286+00
eab05225-22ae-459d-9de1-5dafd4d63258	12dc7539-fb49-4142-9b5d-d248e8e1f403	2026-10-12 07:40:30.670405+00
c48a5266-2ddc-484e-ab8f-ce700310fced	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:40.278894+00
99dc44b5-5d0d-483c-a493-395624204cdd	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:51.926121+00
5682ba79-68cf-4c88-8485-e52d77991808	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:52.445052+00
472e513c-c7f2-43a6-a38d-5b43abd4e667	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:52.44556+00
0f4a8bf8-e32a-44fd-b34d-075e02a5df0e	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:52.44556+00
dfbb1ae8-18a0-4449-af21-dbac2d6e696c	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:54.975775+00
5991939b-cb8f-473e-8261-c9ead038d7e5	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:55.052241+00
d3253585-5004-4363-8f70-58b8ec09cd72	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:55.358385+00
cad123ef-b8d1-46e8-908e-1cdc705e9f53	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:58.015302+00
ee4140f1-685f-46ad-8279-ba3590314f81	6e160147-b0d7-47f7-ba6c-0060be87d02a	2026-10-12 07:40:58.043705+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
bb078b7b-d5e2-4e3a-bc2f-55afab293864	9f08b136-a1be-45dc-a997-879aa2515dab	8326982f-d71e-40ec-961a-1136a60170e4	ADMINISTRATOR	2026-10-12 07:39:56.701588+00	admin	2026-10-12 07:39:56.701588+00	admin	0
00ff5522-7648-41c3-8654-d2809082f9a3	9f08b136-a1be-45dc-a997-879aa2515dab	80c26784-e402-4ac1-be87-057918b96f5c	PRODUCT_OWNER	2026-10-12 07:39:56.702142+00	admin	2026-10-12 07:39:56.702142+00	admin	0
68681e4d-d25a-4d60-b165-a54478cfb6b1	9f08b136-a1be-45dc-a997-879aa2515dab	051f7375-7cc7-4828-a8d7-12cc1c039f47	TESTER	2026-10-12 07:39:56.702142+00	admin	2026-10-12 07:39:56.702142+00	admin	0
7041ea82-72ae-491b-be7f-1dcc96b7d024	9f08b136-a1be-45dc-a997-879aa2515dab	7f25af9a-826c-4dca-af42-c02c2f7b337d	TESTER	2026-10-12 07:39:56.702142+00	admin	2026-10-12 07:39:56.702142+00	admin	0
8b68a58b-700e-4f01-b1a0-a03b7105715e	9f08b136-a1be-45dc-a997-879aa2515dab	be49bcb2-9ef9-4739-af83-c087eadefc54	DEVELOPER	2026-10-12 07:39:56.702142+00	admin	2026-10-12 07:39:56.702142+00	admin	0
82832d47-63e5-4704-9800-695d0f4360e6	9f08b136-a1be-45dc-a997-879aa2515dab	3ab03024-cd89-4c84-b157-6b25570a7e3c	VIEWER	2026-10-12 07:39:56.702677+00	admin	2026-10-12 07:39:56.702677+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
9f08b136-a1be-45dc-a997-879aa2515dab	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 07:39:56.563102+00	admin	2026-10-12 07:39:56.563102+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
492e63a4-80c2-4768-9126-751443f0bb88	9f08b136-a1be-45dc-a997-879aa2515dab	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 07:40:07.072786+00	po	2026-10-12 07:40:08.25309+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ad9bfb07-a546-4323-a8b2-bfb3fd06602a	9f08b136-a1be-45dc-a997-879aa2515dab	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 07:40:33.018918+00	po	2026-10-12 07:40:33.018918+00	po	0
451b875b-1ce1-40da-ad8d-008f168586b3	9f08b136-a1be-45dc-a997-879aa2515dab	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 07:40:33.026231+00	po	2026-10-12 07:40:33.026231+00	po	0
481ce821-1b5b-4b1d-a57c-7e65a62b5ba3	9f08b136-a1be-45dc-a997-879aa2515dab	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 07:41:06.11427+00	po	2026-10-12 07:41:06.11427+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
48d916a2-2c70-4846-acd6-0830bc432582	9f08b136-a1be-45dc-a997-879aa2515dab	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T07:40:33.053083900Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 07:40:33.07949+00	clôture du sprint	2026-10-12 07:40:33.078226+00	po	2026-10-12 07:40:33.079992+00	po	1
32216383-99b9-4688-b45a-28859fc1e1e0	9f08b136-a1be-45dc-a997-879aa2515dab	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T07:41:04.581264200Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 6, "byKind": [{"kind": "MANUAL", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 6, "byStatus": {"FAILED": 3, "PASSED": 3}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 3, "attempts": 6}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 0, "averageMinutes": 0.0, "defectsPerHour": 3600.0, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 07:41:05.159066+00	f	\N	\N	2026-10-12 07:41:04.595381+00	po	2026-10-12 07:41:05.159066+00	po	2
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
e2d33e70-2ef1-43f9-91b9-ee9216351d42	bdf53abe-d5ae-4209-998c-afa00a468622	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.056816+00	po	2026-10-12 07:40:00.056816+00	po	0
ab5016bb-d0ca-4461-9cee-07ff8407a286	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.099784+00	po	2026-10-12 07:40:00.099784+00	po	0
eb6f4fe3-0ec9-4d5c-bc47-3def4ccebbb7	7b60a040-8f6b-40db-b1b9-aff842e97b39	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.129217+00	po	2026-10-12 07:40:00.129217+00	po	0
cb726b6d-8f54-43b1-9948-119b39e5158a	64a0e4ad-69de-4a90-9db3-686f0957dfc8	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.158825+00	po	2026-10-12 07:40:00.158825+00	po	0
2b028805-5ca8-4725-a571-e06b2249b9c9	3ec48475-423b-498d-b31b-77f00228351f	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.190726+00	po	2026-10-12 07:40:00.190726+00	po	0
fffe5802-965c-425b-9032-18bc2011cd41	9befb8bf-ee36-4059-8580-a412e87e9615	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.231089+00	po	2026-10-12 07:40:00.231089+00	po	0
4b83ade7-129d-4468-a7d3-210b25155c76	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.270677+00	po	2026-10-12 07:40:00.270677+00	po	0
d9d6b591-6110-4ab1-93ec-aec5a4759dfc	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 07:40:00.815707+00	po	2026-10-12 07:40:00.815707+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
64c4fc09-2525-47cb-a06b-8eb077421e9d	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 07:39:57.672922+00	po	2026-10-12 07:39:57.672922+00	po	0
24a475c9-085a-4f74-a1a7-c30c23e31c7f	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 07:39:57.773683+00	po	2026-10-12 07:39:57.773683+00	po	0
a081aff8-9c59-445d-b780-034a92889ee7	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 07:39:57.934383+00	po	2026-10-12 07:39:57.934383+00	po	0
db644e63-1f4c-4b80-acfd-dad2183084cc	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 07:39:58.093934+00	po	2026-10-12 07:39:58.093934+00	po	0
4ec6bfba-ec7e-466f-aa7b-97753470d5c4	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	24a475c9-085a-4f74-a1a7-c30c23e31c7f	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 07:39:57.892853+00	po	2026-10-12 07:40:31.442991+00	po	3
7b60a040-8f6b-40db-b1b9-aff842e97b39	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	a081aff8-9c59-445d-b780-034a92889ee7	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 07:39:57.974755+00	po	2026-10-12 07:40:31.482646+00	po	3
c72b0e88-aecc-4da3-a5de-a45f0e500dcb	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	db644e63-1f4c-4b80-acfd-dad2183084cc	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 07:39:58.16335+00	po	2026-10-12 07:40:33.753063+00	po	2
f5e78f12-7563-43b0-a8c9-ebeba1b377af	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 07:39:58.236417+00	po	2026-10-12 07:39:58.236417+00	po	0
28b1b74e-4a53-47d5-aef2-e5fadce5f8bd	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 07:39:59.713686+00	po	2026-10-12 07:39:59.713686+00	po	0
f3983cc0-e39a-4edf-85e2-10edafea9b86	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	64c4fc09-2525-47cb-a06b-8eb077421e9d	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 07:39:59.745399+00	po	2026-10-12 07:39:59.745399+00	po	0
bdf53abe-d5ae-4209-998c-afa00a468622	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	24a475c9-085a-4f74-a1a7-c30c23e31c7f	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 07:39:57.838993+00	po	2026-10-12 07:40:31.398985+00	po	3
87820fdd-6bd4-4cec-99e0-2d8e520e7b55	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	db644e63-1f4c-4b80-acfd-dad2183084cc	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 07:39:58.201121+00	po	2026-10-12 07:40:33.753063+00	po	2
3a6b7bb7-0cbf-43bc-ada7-5214a70d3f58	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f5e78f12-7563-43b0-a8c9-ebeba1b377af	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 07:39:58.273998+00	po	2026-10-12 07:39:58.273998+00	po	0
d027f6ba-16d2-4763-902d-4353559529f0	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	f5e78f12-7563-43b0-a8c9-ebeba1b377af	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 07:39:59.437873+00	po	2026-10-12 07:39:59.437873+00	po	0
64a0e4ad-69de-4a90-9db3-686f0957dfc8	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	a081aff8-9c59-445d-b780-034a92889ee7	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 07:39:58.018729+00	po	2026-10-12 07:40:31.518586+00	po	3
9befb8bf-ee36-4059-8580-a412e87e9615	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	db644e63-1f4c-4b80-acfd-dad2183084cc	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 07:39:58.125898+00	po	2026-10-12 07:40:33.753063+00	po	2
3ec48475-423b-498d-b31b-77f00228351f	9f08b136-a1be-45dc-a997-879aa2515dab	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	a081aff8-9c59-445d-b780-034a92889ee7	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 07:39:58.058167+00	po	2026-10-12 07:41:02.730835+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a920b66d-a6e5-4936-b2f3-358f3ccc4976	12dc7539-fb49-4142-9b5d-d248e8e1f403	9dacfe35-96c8-4c64-a3d2-3c988d18e1a8	log-TC-7.txt	text/plain	SYSTEM_TRACE	487	2026-10-12 07:40:28.4794+00	anonymousUser	2026-10-12 07:40:28.4794+00	anonymousUser	0
32955795-75cf-4d20-9e82-2a2271ea9458	12dc7539-fb49-4142-9b5d-d248e8e1f403	ee41d0b8-b947-4d89-8776-d43aa1a55b82	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 07:40:29.157738+00	anonymousUser	2026-10-12 07:40:29.157738+00	anonymousUser	0
e0c47a45-ecc4-4cd2-b4f7-60bfac794f23	12dc7539-fb49-4142-9b5d-d248e8e1f403	c34d7a74-5fc4-4105-9db2-3c287ec4e374	log-TC-4.txt	text/plain	SYSTEM_TRACE	393	2026-10-12 07:40:29.218605+00	anonymousUser	2026-10-12 07:40:29.218605+00	anonymousUser	0
7d265bb1-85cd-4745-a632-3720c95f4b39	12dc7539-fb49-4142-9b5d-d248e8e1f403	9c4bb3b5-16c4-462b-bdbe-d54de5cfbdd4	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 07:40:30.148449+00	anonymousUser	2026-10-12 07:40:30.148449+00	anonymousUser	0
9fae6dba-76b4-460a-a03a-f85218ec1da0	12dc7539-fb49-4142-9b5d-d248e8e1f403	d6841386-2054-4b6d-8207-767919be1288	log-TC-5.txt	text/plain	SYSTEM_TRACE	391	2026-10-12 07:40:30.6454+00	anonymousUser	2026-10-12 07:40:30.6454+00	anonymousUser	0
713ec265-4ed2-478f-9b7c-1e8e780845bb	12dc7539-fb49-4142-9b5d-d248e8e1f403	\N	system.log	text/plain	SYSTEM_TRACE	4728	2026-10-12 07:40:30.67213+00	anonymousUser	2026-10-12 07:40:30.67213+00	anonymousUser	0
7a49e134-419c-490e-92b6-85aad85d91cb	12dc7539-fb49-4142-9b5d-d248e8e1f403	\N	junit.xml	application/xml	JUNIT	1185	2026-10-12 07:40:30.674402+00	anonymousUser	2026-10-12 07:40:30.674402+00	anonymousUser	0
30d18680-7874-4f05-a1ec-f020f295ef41	12dc7539-fb49-4142-9b5d-d248e8e1f403	\N	report.json	application/json	REPORT	484	2026-10-12 07:40:30.676026+00	anonymousUser	2026-10-12 07:40:30.676026+00	anonymousUser	0
03733864-adf5-4a21-a0e3-5f7ad6704169	6e160147-b0d7-47f7-ba6c-0060be87d02a	ce1acaf8-0b9d-46a9-a2b3-9260259592d8	log-TC-8.txt	text/plain	SYSTEM_TRACE	452	2026-10-12 07:40:54.979034+00	anonymousUser	2026-10-12 07:40:54.979034+00	anonymousUser	0
dccb80fc-9687-4729-bf78-9d9f6e7bd6de	6e160147-b0d7-47f7-ba6c-0060be87d02a	e9a7bed2-192e-4f35-96c9-db00edd9865a	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 07:40:55.056287+00	anonymousUser	2026-10-12 07:40:55.056287+00	anonymousUser	0
d3103077-4179-4a2a-b378-e0dd8b186687	6e160147-b0d7-47f7-ba6c-0060be87d02a	4b8c15d8-b520-4ac2-941f-09a23d68afb4	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 07:40:55.361419+00	anonymousUser	2026-10-12 07:40:55.361419+00	anonymousUser	0
5f1ee2ec-4d14-4ebb-a21a-c241e050226a	6e160147-b0d7-47f7-ba6c-0060be87d02a	aad11270-104e-4556-a4f9-5faa839dfe69	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 07:40:58.018491+00	anonymousUser	2026-10-12 07:40:58.018491+00	anonymousUser	0
38dc3f61-ac25-40fb-b1b1-0c1de9a7e80c	6e160147-b0d7-47f7-ba6c-0060be87d02a	aad11270-104e-4556-a4f9-5faa839dfe69	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 07:40:58.021666+00	anonymousUser	2026-10-12 07:40:58.021666+00	anonymousUser	0
848b6ff7-b17c-47ec-809f-eaacb3d35837	6e160147-b0d7-47f7-ba6c-0060be87d02a	\N	system.log	text/plain	SYSTEM_TRACE	8587	2026-10-12 07:40:58.045911+00	anonymousUser	2026-10-12 07:40:58.045911+00	anonymousUser	0
6662df39-01ea-4461-b39a-aa6046a3573d	6e160147-b0d7-47f7-ba6c-0060be87d02a	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 07:40:58.048393+00	anonymousUser	2026-10-12 07:40:58.048393+00	anonymousUser	0
1556ae33-5150-42ca-b1a1-756dec46b8e0	6e160147-b0d7-47f7-ba6c-0060be87d02a	\N	report.json	application/json	REPORT	475	2026-10-12 07:40:58.051415+00	anonymousUser	2026-10-12 07:40:58.051415+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
85ff0bc9-8691-4b64-a42c-7c59e48e9315	843548d2-558b-4292-9083-f0d685a0343e	NOTE	0	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 07:40:36.697041+00	\N	2026-10-12 07:40:36.698692+00	qa1	2026-10-12 07:40:36.698692+00	qa1	0
b446731e-5010-4c6e-a37c-6c8eb5d2d12b	843548d2-558b-4292-9083-f0d685a0343e	NOTE	0	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 07:40:36.803379+00	\N	2026-10-12 07:40:36.803919+00	qa1	2026-10-12 07:40:36.803919+00	qa1	0
4afedc2c-b455-4554-95e2-0354893d030f	843548d2-558b-4292-9083-f0d685a0343e	QUESTION	0	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 07:40:37.000304+00	\N	2026-10-12 07:40:37.000823+00	qa1	2026-10-12 07:40:37.000823+00	qa1	0
d0a28195-52be-492e-aca7-52bbf3fd98fe	843548d2-558b-4292-9083-f0d685a0343e	IDEA	0	Afficher le total du panier avant le checkout	2026-10-12 07:40:37.075878+00	\N	2026-10-12 07:40:37.075878+00	qa1	2026-10-12 07:40:37.075878+00	qa1	0
fe9f0da7-f9da-4bb7-b092-fc193c060975	843548d2-558b-4292-9083-f0d685a0343e	BUG	0	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 07:40:36.922099+00	8cfbf174-d4f9-44df-96f8-9b9a2307f69b	2026-10-12 07:40:36.922615+00	qa1	2026-10-12 07:40:37.233596+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7d9e6e74-1a6d-4631-aa9b-5a1b1282330d	8a88d0fc-6f94-453b-b458-eb6a06780ff4	bdf53abe-d5ae-4209-998c-afa00a468622	1	3	DONE	2026-10-12 07:40:07.809183+00	po	2026-10-12 07:40:33.020456+00	po	1
07e300bf-bf2b-44d7-b829-fb4f8f299282	8a88d0fc-6f94-453b-b458-eb6a06780ff4	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	2	2	DONE	2026-10-12 07:40:07.882428+00	po	2026-10-12 07:40:33.020456+00	po	1
a7bd9a2b-f73c-4398-95fd-5d57281b8ff0	8a88d0fc-6f94-453b-b458-eb6a06780ff4	7b60a040-8f6b-40db-b1b9-aff842e97b39	3	3	DONE	2026-10-12 07:40:07.956273+00	po	2026-10-12 07:40:33.020456+00	po	1
f7ab66da-81da-47a5-9dee-f9f19962678e	8a88d0fc-6f94-453b-b458-eb6a06780ff4	64a0e4ad-69de-4a90-9db3-686f0957dfc8	4	2	DONE	2026-10-12 07:40:08.029204+00	po	2026-10-12 07:40:33.020456+00	po	1
745fd774-f1f4-4642-b630-a9701f947075	8a88d0fc-6f94-453b-b458-eb6a06780ff4	3ec48475-423b-498d-b31b-77f00228351f	5	2	DONE	2026-10-12 07:40:08.109278+00	po	2026-10-12 07:40:33.020456+00	po	1
6e1216fd-88e3-451a-93fb-c62b89a05e9a	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	9befb8bf-ee36-4059-8580-a412e87e9615	1	3	PLANNED	2026-10-12 07:40:33.712154+00	po	2026-10-12 07:40:33.712154+00	po	0
ae272b9d-7fed-4f40-8cba-5982b7506df2	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	2	3	PLANNED	2026-10-12 07:40:33.712154+00	po	2026-10-12 07:40:33.712154+00	po	0
c7200a27-54c3-4716-853e-f0a119e56331	2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	3	2	PLANNED	2026-10-12 07:40:33.712154+00	po	2026-10-12 07:40:33.712154+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8a88d0fc-6f94-453b-b458-eb6a06780ff4	9f08b136-a1be-45dc-a997-879aa2515dab	492e63a4-80c2-4768-9126-751443f0bb88	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 07:40:07.103101+00	po	2026-10-12 07:40:33.020456+00	po	2
2bf15e01-4ad5-49cd-ac08-4aa65315e4d4	9f08b136-a1be-45dc-a997-879aa2515dab	492e63a4-80c2-4768-9126-751443f0bb88	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 07:40:07.144294+00	po	2026-10-12 07:40:33.753063+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
a955d053-ca2c-4ee3-90cd-d8e140c14623	ab4a1ecc-1647-4937-ad11-39a992987c59	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 07:40:10.381915+00	qa1	2026-10-12 07:40:10.540269+00	qa1	1	\N
96bd638e-a33a-4ef3-8afe-26c892571615	ab4a1ecc-1647-4937-ad11-39a992987c59	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 07:40:10.381915+00	qa1	2026-10-12 07:40:10.64192+00	qa1	1	\N
73c980de-313f-47b4-81f4-9ee793f216f1	f75df1ba-9018-47a6-ae22-4c7447c1a1d8	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 07:40:10.735995+00	qa1	2026-10-12 07:40:10.753202+00	qa1	1	\N
b6070236-c78b-4663-9584-373f83fa1824	f75df1ba-9018-47a6-ae22-4c7447c1a1d8	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 07:40:10.735995+00	qa1	2026-10-12 07:40:10.769045+00	qa1	1	\N
7d8a37c0-0c2e-46af-b90a-0dfe3a849dec	4f2cdd0b-8892-46e4-b893-4695c93c2fab	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 07:40:10.784322+00	qa1	2026-10-12 07:40:10.799235+00	qa1	1	\N
bf8e9722-b0b9-4de3-9b5d-077bfd86cd1e	4f2cdd0b-8892-46e4-b893-4695c93c2fab	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 07:40:10.784322+00	qa1	2026-10-12 07:40:10.815625+00	qa1	1	\N
67238e3c-ec72-4ff8-9294-e19477f1ec97	50a14f68-b9a7-4b87-80c8-5086a12f80e4	1	Se connecter avec problem_user	Le catalogue s’affiche	\N	PASSED	\N	2026-10-12 07:40:34.793375+00	qa2	2026-10-12 07:40:34.944726+00	qa2	1	\N
fcee818b-e926-4a0f-b6dc-88f6320d1aba	50a14f68-b9a7-4b87-80c8-5086a12f80e4	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 07:40:34.793375+00	qa2	2026-10-12 07:40:35.058312+00	qa2	1	\N
8455730b-b087-42d3-83fc-d72f95acaf26	50a14f68-b9a7-4b87-80c8-5086a12f80e4	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 07:40:34.793891+00	qa2	2026-10-12 07:40:35.178639+00	qa2	1	\N
117fefe1-355f-4f71-8c7c-949776940a2d	50a14f68-b9a7-4b87-80c8-5086a12f80e4	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 07:40:34.793891+00	qa2	2026-10-12 07:40:35.441855+00	qa2	1	\N
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
258868fc-911c-4d95-abaf-77fba06f47fc	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 07:40:03.822253+00	qa1	2026-10-12 07:40:03.822253+00	qa1	0
a517a1f8-ecd1-4944-ae64-de6253af8c53	4c7f8390-deb1-488c-a0df-683d5547250d	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. Se connecter avec ${utilisateur} → Le catalogue s’affiche", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": ["utilisateur = problem_user"], "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 07:40:03.919693+00	qa1	2026-10-12 07:40:03.919693+00	qa1	0
d579c043-fea2-4776-94c2-f49e5d147bf9	f0ac4646-edd9-42f5-b72c-c7fb05c51703	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "installation-hors-docker", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:04.019975+00	dev	2026-10-12 07:40:04.019975+00	dev	0
1061c9d4-d7d6-48d9-9c65-40ab8a589644	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:04.09541+00	dev	2026-10-12 07:40:04.09541+00	dev	0
cb817716-9dc4-42e1-a801-5da35311d77e	3a02e1a7-0caa-492c-91ed-e6771b926f19	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:04.164316+00	dev	2026-10-12 07:40:04.164316+00	dev	0
074a6457-40c1-4d1c-a007-a2f9825bb2ec	29648801-a423-46a8-807a-b36dd028e6c7	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:04.240903+00	dev	2026-10-12 07:40:04.240903+00	dev	0
62f6cc1c-89d8-4d79-b5b2-741d7ecafa82	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "installation-hors-docker", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:04.310975+00	dev	2026-10-12 07:40:04.310975+00	dev	0
a316c89a-4d4e-4e28-a27a-49adf5a9a1f9	6c522c6c-c6a4-4f21-956b-d487f3444882	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:05.174833+00	qa1	2026-10-12 07:40:05.174833+00	qa1	0
616bed30-4a1e-4bd0-a63c-a58485fa6c73	6c522c6c-c6a4-4f21-956b-d487f3444882	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "installation-hors-docker", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:05.310031+00	qa1	2026-10-12 07:40:05.310031+00	qa1	0
cdb324e8-c324-447f-a204-5ebb43d2ddc3	62154ec4-1fb3-4439-a00b-661092807e31	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:05.690782+00	dev	2026-10-12 07:40:05.690782+00	dev	0
aac231bc-a5c4-41f2-b6f4-d23b92c119bf	0e76b33f-54b0-47b2-9ab5-561fe38a4174	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:05.75234+00	dev	2026-10-12 07:40:05.75234+00	dev	0
7fb17ecc-2a90-4648-82bd-dd490dcb5c3a	cd9e8633-71ad-4c8e-816d-f194ed4637f0	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "installation-hors-docker", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 07:40:05.811384+00	dev	2026-10-12 07:40:05.811384+00	dev	0
c1711d60-2572-4f10-9d2e-65e7edfa362a	2070438a-f265-4624-ab3a-6d2cfacc48b6	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 07:40:05.867425+00	qa1	2026-10-12 07:40:05.867425+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	9f08b136-a1be-45dc-a997-879aa2515dab	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 07:40:03.813048+00	qa1	2026-10-12 07:40:03.892589+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}]}]	f
4c7f8390-deb1-488c-a0df-683d5547250d	9f08b136-a1be-45dc-a997-879aa2515dab	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 07:40:03.918651+00	qa1	2026-10-12 07:40:03.975356+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "problem_user"}]	[]	f
f0ac4646-edd9-42f5-b72c-c7fb05c51703	9f08b136-a1be-45dc-a997-879aa2515dab	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 07:40:04.014752+00	dev	2026-10-12 07:40:04.064181+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}]}]	f
1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	9f08b136-a1be-45dc-a997-879aa2515dab	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 07:40:04.094376+00	dev	2026-10-12 07:40:04.13228+00	qa1	1	[]	[]	f
3a02e1a7-0caa-492c-91ed-e6771b926f19	9f08b136-a1be-45dc-a997-879aa2515dab	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 07:40:04.163783+00	dev	2026-10-12 07:40:04.208143+00	qa1	1	[]	[]	f
cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	9f08b136-a1be-45dc-a997-879aa2515dab	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 07:40:04.310423+00	dev	2026-10-12 07:40:04.345537+00	qa1	1	[]	[]	f
cd9e8633-71ad-4c8e-816d-f194ed4637f0	9f08b136-a1be-45dc-a997-879aa2515dab	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 07:40:05.810869+00	dev	2026-10-12 07:40:05.842942+00	qa1	1	[]	[]	f
6c522c6c-c6a4-4f21-956b-d487f3444882	9f08b136-a1be-45dc-a997-879aa2515dab	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 07:40:05.173824+00	qa1	2026-10-12 07:40:05.319557+00	qa1	2	[]	[]	f
62154ec4-1fb3-4439-a00b-661092807e31	9f08b136-a1be-45dc-a997-879aa2515dab	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 07:40:05.690265+00	dev	2026-10-12 07:40:05.724926+00	qa1	1	[]	[]	f
0e76b33f-54b0-47b2-9ab5-561fe38a4174	9f08b136-a1be-45dc-a997-879aa2515dab	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 07:40:05.751824+00	dev	2026-10-12 07:40:05.785186+00	qa1	1	[]	[]	f
2070438a-f265-4624-ab3a-6d2cfacc48b6	9f08b136-a1be-45dc-a997-879aa2515dab	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 07:40:05.865411+00	qa1	2026-10-12 07:40:05.901746+00	qa1	1	[]	[]	f
29648801-a423-46a8-807a-b36dd028e6c7	9f08b136-a1be-45dc-a997-879aa2515dab	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 07:40:04.240327+00	dev	2026-10-12 07:41:02.737554+00	po	2	[]	[]	f
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
53d0da5b-b1eb-419f-8402-6a416a0322b0	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	VERIFIES	MANUAL	2026-10-12 07:40:03.834649+00	qa1	2026-10-12 07:40:03.834649+00	qa1	0	\N
dce320f1-a5dc-4e47-9d13-85b644220b13	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f8e57c8a-26f7-4d22-b2b4-9f47577a6cca	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	VERIFIES	MANUAL	2026-10-12 07:40:03.834649+00	qa1	2026-10-12 07:40:03.834649+00	qa1	0	\N
f98987ce-f413-46cc-bcaa-c070ca34162f	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	4c7f8390-deb1-488c-a0df-683d5547250d	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	PARTIALLY_VERIFIES	MANUAL	2026-10-12 07:40:03.924853+00	qa1	2026-10-12 07:40:03.924853+00	qa1	0	\N
7ee2318b-91fd-4da2-8ee4-c692c9cc7d4c	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	4c7f8390-deb1-488c-a0df-683d5547250d	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	VERIFIES	MANUAL	2026-10-12 07:40:03.925478+00	qa1	2026-10-12 07:40:03.925478+00	qa1	0	\N
fce03dfb-6250-45be-b05c-f67c1ad0ff66	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f0ac4646-edd9-42f5-b72c-c7fb05c51703	REQUIREMENT	bdf53abe-d5ae-4209-998c-afa00a468622	VERIFIES	MANUAL	2026-10-12 07:40:04.026847+00	dev	2026-10-12 07:40:04.026847+00	dev	0	\N
70fb1880-166d-49af-9377-d6f788f2988d	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	f0ac4646-edd9-42f5-b72c-c7fb05c51703	REQUIREMENT	4ec6bfba-ec7e-466f-aa7b-97753470d5c4	VERIFIES	MANUAL	2026-10-12 07:40:04.027367+00	dev	2026-10-12 07:40:04.027367+00	dev	0	\N
272a9668-f158-4f24-a128-20c8cb96acd5	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	1a86cc1e-f9f4-4a10-96cc-59c5d83c8a39	REQUIREMENT	7b60a040-8f6b-40db-b1b9-aff842e97b39	VERIFIES	MANUAL	2026-10-12 07:40:04.098509+00	dev	2026-10-12 07:40:04.098509+00	dev	0	\N
de61bc9f-a4e1-4c37-9435-6cfb07bcd468	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	3a02e1a7-0caa-492c-91ed-e6771b926f19	REQUIREMENT	64a0e4ad-69de-4a90-9db3-686f0957dfc8	VERIFIES	MANUAL	2026-10-12 07:40:04.1674+00	dev	2026-10-12 07:40:04.1674+00	dev	0	\N
c9c77e14-e3e8-4e22-8c91-1a680a99eb15	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cfdf2209-bce7-4a16-8e5b-029ab3ea94f0	REQUIREMENT	f3983cc0-e39a-4edf-85e2-10edafea9b86	VERIFIES	MANUAL	2026-10-12 07:40:04.31598+00	dev	2026-10-12 07:40:04.31598+00	dev	0	\N
2bbf45db-b0dd-460a-a299-dd5b42e27acf	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	6c522c6c-c6a4-4f21-956b-d487f3444882	REQUIREMENT	9befb8bf-ee36-4059-8580-a412e87e9615	VERIFIES	GHERKIN_TAG	2026-10-12 07:40:05.180938+00	qa1	2026-10-12 07:40:05.180938+00	qa1	0	\N
b0bbe6b1-e7c4-4822-a135-ea720a538fbe	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	6c522c6c-c6a4-4f21-956b-d487f3444882	ACCEPTANCE_CRITERION	962ca414-2e5f-4afb-af5e-712bea015fd8	VERIFIES	GHERKIN_TAG	2026-10-12 07:40:05.190459+00	qa1	2026-10-12 07:40:05.190459+00	qa1	0	\N
011d68ef-ead4-4802-bff1-c2388d9419ea	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	62154ec4-1fb3-4439-a00b-661092807e31	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	VERIFIES	MANUAL	2026-10-12 07:40:05.692873+00	dev	2026-10-12 07:40:05.692873+00	dev	0	\N
a49d5307-15c1-41b1-9324-42707b635bdb	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	0e76b33f-54b0-47b2-9ab5-561fe38a4174	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	VERIFIES	MANUAL	2026-10-12 07:40:05.754939+00	dev	2026-10-12 07:40:05.754939+00	dev	0	\N
18deb8ee-837a-42a7-b1b4-bbb00c781dbc	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	cd9e8633-71ad-4c8e-816d-f194ed4637f0	REQUIREMENT	28b1b74e-4a53-47d5-aef2-e5fadce5f8bd	VERIFIES	MANUAL	2026-10-12 07:40:05.814943+00	dev	2026-10-12 07:40:05.814943+00	dev	0	\N
75a76942-1303-42c9-a324-65cbc7cdecb5	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	2070438a-f265-4624-ab3a-6d2cfacc48b6	REQUIREMENT	c72b0e88-aecc-4da3-a5de-a45f0e500dcb	VERIFIES	MANUAL	2026-10-12 07:40:05.87204+00	qa1	2026-10-12 07:40:05.87204+00	qa1	0	\N
e439c556-b993-4ec6-a170-97bc59305a05	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	2070438a-f265-4624-ab3a-6d2cfacc48b6	REQUIREMENT	87820fdd-6bd4-4cec-99e0-2d8e520e7b55	VERIFIES	MANUAL	2026-10-12 07:40:05.87204+00	qa1	2026-10-12 07:40:05.87204+00	qa1	0	\N
58a7edf2-3a43-49fc-a5b6-b2f8c4003c51	9f08b136-a1be-45dc-a997-879aa2515dab	TEST_CASE	29648801-a423-46a8-807a-b36dd028e6c7	REQUIREMENT	3ec48475-423b-498d-b31b-77f00228351f	VERIFIES	MANUAL	2026-10-12 07:40:04.244797+00	dev	2026-10-12 07:41:02.916872+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8326982f-d71e-40ec-961a-1136a60170e4	admin	admin@traceagile.local	Administrateur	$2a$12$hdj3.BqWCJe9u.hXAdQfnOnxXjMKG/QZNaxMf/DaFc8fDNyJQOiXC	t	t	2026-10-12 07:39:52.289051+00	system	2026-10-12 07:39:52.289051+00	system	0
80c26784-e402-4ac1-be87-057918b96f5c	po	po@traceagile.demo	Paula Owner	$2a$12$IwMh4vNm6RrkrDoITciHFeasAJdZCLBiMEqj700e/U9fPhIdv.lw6	t	f	2026-10-12 07:39:54.861659+00	admin	2026-10-12 07:39:54.861659+00	admin	0
051f7375-7cc7-4828-a8d7-12cc1c039f47	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$RabvNmi.8oU7DhijeQAC5eh7.JZ4QQafgqrimAB7KFkz3OnVGpVxG	t	f	2026-10-12 07:39:55.050682+00	admin	2026-10-12 07:39:55.050682+00	admin	0
7f25af9a-826c-4dca-af42-c02c2f7b337d	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$MEl7f7OjYEQuBcmbukwpmevd2V.dSeoI7yz5OkcA71ZS.0wjfedCu	t	f	2026-10-12 07:39:55.235499+00	admin	2026-10-12 07:39:55.235499+00	admin	0
be49bcb2-9ef9-4739-af83-c087eadefc54	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$T6NJ5JU8tqHSHOOSCgDAceIUjueztK3PWAy1F9WHqTCg1fKlc/Zbu	t	f	2026-10-12 07:39:55.432931+00	admin	2026-10-12 07:39:55.432931+00	admin	0
3ab03024-cd89-4c84-b157-6b25570a7e3c	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$g85u858hNpjVV.pn9RDkZeQJZtJ1ZiEtub9knZ3C9x2r8/Z6DjmFG	t	f	2026-10-12 07:39:55.621544+00	admin	2026-10-12 07:39:55.621544+00	admin	0
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


