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
59747a23-20a2-49c2-8df4-6653d5511aed	9ec0fc09-c059-4328-8785-7e6a102b198f	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 09:18:33.142496+00	po	2026-10-12 09:18:33.142496+00	po	0
1fe4947c-10e6-4c2e-8547-b68acff3ba10	9ec0fc09-c059-4328-8785-7e6a102b198f	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 09:18:33.1435+00	po	2026-10-12 09:18:33.1435+00	po	0
659977cc-c42c-4225-8cb8-1ba1f423ac45	e9c8013a-4e21-4183-a570-30dc2fbc4448	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 09:18:33.193709+00	po	2026-10-12 09:18:33.193709+00	po	0
6ef5e97b-6604-46bc-b337-fe9f7fc0405d	e7f1af81-8599-4ebe-901a-9f534713c04e	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 09:18:33.266309+00	po	2026-10-12 09:18:33.266309+00	po	0
9bc94fb7-2f8b-46ba-b673-b283e4443c44	77a3afae-fa04-4648-8dc5-19240722030e	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 09:18:33.307676+00	po	2026-10-12 09:18:33.307676+00	po	0
40d666b7-15ba-474a-9c29-227391676672	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 09:18:33.342585+00	po	2026-10-12 09:18:33.342585+00	po	0
f1bf3e37-163f-4d50-8548-db538bd55294	1ea35027-3e83-490c-a3bc-d5cfd89339b0	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 09:18:33.408974+00	po	2026-10-12 09:18:33.408974+00	po	0
87d8912d-e6e7-41e1-bc74-7296109074e3	1ea35027-3e83-490c-a3bc-d5cfd89339b0	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 09:18:33.408974+00	po	2026-10-12 09:18:33.408974+00	po	0
b9b7ae22-80d1-4727-a3f9-c19bd85c4f5d	7829e77d-535f-44eb-90a9-4a1de99d13d6	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 09:18:33.445868+00	po	2026-10-12 09:18:33.445868+00	po	0
0f6d6904-c375-4194-bdab-2ce1e18801dc	7829e77d-535f-44eb-90a9-4a1de99d13d6	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 09:18:33.445868+00	po	2026-10-12 09:18:33.445868+00	po	0
9d572c78-86a4-49cd-abaa-c4ca591fe425	f541393a-f7bc-4bfe-a708-897b922fec4e	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 09:18:33.483958+00	po	2026-10-12 09:18:33.483958+00	po	0
8d0e5de3-ffd2-4de5-b9a5-c17c92677795	dd103bcf-8759-482a-9f1f-af52d5b91f52	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 09:18:33.549191+00	po	2026-10-12 09:18:33.549191+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e80daab0-f83c-4003-b1a9-85eaeca74ca1	99b0e710-6ad5-4465-8b19-0d4f93923ae0	EXECUTION_STEP	edc2cea4-dfd7-4312-ad59-991807e922f9	sd-defaut-problem-user.png	image/png	235120	36b79806-a8e9-46e8-910a-691267241ee6	2026-10-12 09:19:28.487897+00	qa2	2026-10-12 09:19:28.487897+00	qa2	0
7e704d03-cd35-4fa2-998d-e28f248bab6f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEFECT	2494f6c0-d5af-412f-a70e-4a491e1cc8ad	sd-defaut-problem-user.png	image/png	235120	36b79806-a8e9-46e8-910a-691267241ee6	2026-10-12 09:19:30.012732+00	qa2	2026-10-12 09:19:30.012732+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3c1c2990-596f-41b5-9caf-f94590ad2fc3	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	05faabd3-bc5a-4153-8fda-63ee57eacea0	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:32.95145+00	po	2026-10-12 09:18:32.95145+00	po	0
f23ac7ee-a315-4a86-a833-48c112575a8c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	5a853996-ae82-4f4f-b48c-164f8f403d92	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:33.054991+00	po	2026-10-12 09:18:33.054991+00	po	0
c4a7b594-e71c-4ee2-9d1a-52b542d97980	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.1435+00	po	2026-10-12 09:18:33.1435+00	po	0
762938cb-4e3e-4265-b0c1-00ac002e0cdd	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.194226+00	po	2026-10-12 09:18:33.194226+00	po	0
4806b17b-4766-46f8-84f0-0badb1ba11b2	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	d50149bc-44e4-437c-9026-b2742c3e730d	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:33.23124+00	po	2026-10-12 09:18:33.23124+00	po	0
5ed894c0-2d62-4699-87ba-da41c1ecf01b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e7f1af81-8599-4ebe-901a-9f534713c04e	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.266817+00	po	2026-10-12 09:18:33.266817+00	po	0
299cc254-50ea-44c6-af5d-0041ebf4d48c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	77a3afae-fa04-4648-8dc5-19240722030e	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.308249+00	po	2026-10-12 09:18:33.308249+00	po	0
73b95a26-3046-4b38-a1f6-f38ebac3f591	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	4b5f6e52-19aa-4dec-9cff-4c5af17d839c	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:33.37688+00	po	2026-10-12 09:18:33.37688+00	po	0
e9507405-ae04-4595-8064-54f0e60abaea	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 09:18:52.082732+00	po	2026-10-12 09:18:52.082732+00	po	0
c3f5598c-ebc1-4a52-9c8b-64d52cf41e1d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.343102+00	po	2026-10-12 09:18:33.343102+00	po	0
bedbfc40-c7f6-4a4b-8533-53a1a8ed3fc4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	1ea35027-3e83-490c-a3bc-d5cfd89339b0	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.408974+00	po	2026-10-12 09:18:33.408974+00	po	0
3281f1c4-1890-4e43-94df-281d11e4187a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	1c74f693-3064-466a-a01e-a3b1a0582695	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:33.516694+00	po	2026-10-12 09:18:33.516694+00	po	0
dd752fc5-0876-4712-9c96-e7cbec4de1fc	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	eea3d565-3bea-4d1f-a608-cfa70a603611	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:35.535018+00	po	2026-10-12 09:18:35.535018+00	po	0
9c330c76-073e-4b66-b15b-54e5abc3f425	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.584642+00	po	2026-10-12 09:18:36.584642+00	po	0
ed4d6ce2-e31a-4f8f-bb05-d6a436e973f1	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:37.580473+00	po	2026-10-12 09:18:37.580473+00	po	0
8f2a653f-4a7c-4fbb-9cc0-d52b0c6f7c92	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	b4139dae-2333-4955-86a1-1e6c1002e9d4	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 09:18:44.162909+00	dev	2026-10-12 09:18:44.162909+00	dev	0
489abe16-2ada-44c5-8f44-96c094043659	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	bc3979be-122d-4f0f-b8ed-78698b85905c	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 09:18:45.777781+00	qa1	2026-10-12 09:18:45.777781+00	qa1	0
62b15da7-79fd-4638-a44f-b15d834294db	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e80123ec-b623-49f6-8574-a3a732204856	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:46.84959+00	qa1	2026-10-12 09:18:46.84959+00	qa1	0
7bd32853-0710-4355-989f-98df8db4dbf1	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	b08ca36a-27c6-4fcb-a762-f82dd30852e8	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 09:18:51.278634+00	po	2026-10-12 09:18:51.278634+00	po	0
e57bac9e-81a9-4182-91f1-c7f697b63f1f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 09:18:51.944261+00	po	2026-10-12 09:18:51.944261+00	po	0
2c83edbc-a755-4e47-9cde-a84d4b2d6280	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.445868+00	po	2026-10-12 09:18:33.445868+00	po	0
c51b8a5d-52cc-44de-aaed-69d028ba9489	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.484477+00	po	2026-10-12 09:18:33.484477+00	po	0
a625527a-326d-45aa-bd22-76893c4c16b6	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	dd103bcf-8759-482a-9f1f-af52d5b91f52	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 09:18:33.549191+00	po	2026-10-12 09:18:33.549191+00	po	0
a2aea36a-96d3-43bc-ac78-8a29f324d721	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	c8055570-8e72-4102-9773-4e4f8ec6c4db	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:35.261657+00	po	2026-10-12 09:18:35.261657+00	po	0
7c6d7d51-110a-4f15-aefd-91554475340f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	394bda32-06f8-4f44-a2f5-2232e4bfdf48	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 09:18:35.502623+00	po	2026-10-12 09:18:35.502623+00	po	0
f481a4f6-34e2-46d9-b7a6-2cb919a7fd4f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.361656+00	po	2026-10-12 09:18:36.361656+00	po	0
3f17d11c-51bc-48a9-8989-c85446c03b38	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.396924+00	po	2026-10-12 09:18:36.396924+00	po	0
669ba7a3-7b55-4625-b1af-1d94b55494d4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e7f1af81-8599-4ebe-901a-9f534713c04e	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.430459+00	po	2026-10-12 09:18:36.430459+00	po	0
4b8e551d-175d-42ba-b6d9-e5bdf3445fb9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	77a3afae-fa04-4648-8dc5-19240722030e	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.467445+00	po	2026-10-12 09:18:36.467445+00	po	0
ff6a7cf5-229e-4a72-80cc-97889eb77562	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.510035+00	po	2026-10-12 09:18:36.510035+00	po	0
82615962-8cf4-4f3b-999f-e0a8a31ff585	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	1ea35027-3e83-490c-a3bc-d5cfd89339b0	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:36.54959+00	po	2026-10-12 09:18:36.54959+00	po	0
70910b07-a9bf-44f9-8ef9-fd2096b9e02a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	4024d965-5801-4535-8cb6-23688dca7a13	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:43.916871+00	qa1	2026-10-12 09:18:43.916871+00	qa1	0
108ade13-0e2a-4598-8008-de96ff30a7a7	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	3c23dff1-b246-4196-a751-df329fc0dfe6	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:43.981973+00	qa1	2026-10-12 09:18:43.981973+00	qa1	0
8bd2c0ac-2d00-45eb-8f91-1ad11a940207	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RUN	06ad4757-c916-459c-a96b-0ecb80a6980a	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:18:57.767064+00	dev	0
292206b3-b05b-49e3-bdb8-1ab0226e47a4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	4024d965-5801-4535-8cb6-23688dca7a13	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 09:18:43.862218+00	qa1	2026-10-12 09:18:43.862218+00	qa1	0
b15a3276-9472-44b7-9ddf-2c3bd291430e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	a8326366-813a-4983-8136-27ea126b14a3	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 09:18:44.215836+00	dev	2026-10-12 09:18:44.215836+00	dev	0
1ee2578e-18d9-4ebe-9c9a-77edca39d50a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	cf50092f-9431-4b3a-bef2-3712c4c44c77	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:46.975809+00	qa1	2026-10-12 09:18:46.975809+00	qa1	0
4f83132b-c3b9-417d-a8c1-dc7032c55e21	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:18:52.764747+00	po	2026-10-12 09:18:52.764747+00	po	0
a7ea88cc-6f14-4017-b093-79ee8ecc3794	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:18:52.765256+00	po	2026-10-12 09:18:52.765256+00	po	0
00ba2fcc-c4d5-4d22-b6ad-a4f4a4c81b54	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e7f1af81-8599-4ebe-901a-9f534713c04e	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:18:52.765256+00	po	2026-10-12 09:18:52.765256+00	po	0
24b1e9fb-1cf5-4d47-88fd-2acb5a8e1a0e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	77a3afae-fa04-4648-8dc5-19240722030e	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:18:52.765256+00	po	2026-10-12 09:18:52.765256+00	po	0
e1d2664d-ffd3-4db6-a46d-63ac7dbd5895	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:18:52.765802+00	po	2026-10-12 09:18:52.765802+00	po	0
5596c2d9-5e76-4f15-8838-0d96c624e46c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 09:18:52.765802+00	po	2026-10-12 09:18:52.765802+00	po	0
a4303fb8-2d86-49e3-a0d5-c9be5b5645ef	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 09:18:54.331156+00	qa1	2026-10-12 09:18:54.331156+00	qa1	0
cee7efd4-4964-4c0d-b4d6-ded4ec44d49b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	3c23dff1-b246-4196-a751-df329fc0dfe6	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["utilisateur = problem_user"], "field": "parameters", "before": null}, {"after": ["Compte du défaut : [{utilisateur=problem_user}]"], "field": "dataSets", "before": null}, {"after": ["1. Se connecter avec ${utilisateur} → Le catalogue s’affiche", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 09:18:43.946014+00	qa1	2026-10-12 09:18:43.946014+00	qa1	0
da3e4b18-fd47-4a24-b5d4-f62c00a1192e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:44.061225+00	qa1	2026-10-12 09:18:44.061225+00	qa1	0
051c7a9b-c62d-4e53-837d-32aeadc1eb1c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	d0883f42-8918-43ce-acf7-10d7c0326acd	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 09:18:44.28737+00	dev	2026-10-12 09:18:44.28737+00	dev	0
fd2f07ac-5d5b-4f16-91a0-bf1798918a00	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e05c1346-01ec-449f-8dca-9b8460638a0b	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 09:18:46.740725+00	dev	2026-10-12 09:18:46.740725+00	dev	0
af74a37b-0463-4942-9373-83584bc1c7b4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e80123ec-b623-49f6-8574-a3a732204856	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 09:18:46.812129+00	dev	2026-10-12 09:18:46.812129+00	dev	0
e70c205a-e2d8-43d0-8abd-dcd979dd3307	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 09:18:52.011121+00	po	2026-10-12 09:18:52.011121+00	po	0
a14eac01-4a85-4cac-a801-8e16517c7b3e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 09:19:22.827996+00	qa1	2026-10-12 09:19:22.827996+00	qa1	0
53a46db6-044b-4b0d-841a-ececb24902ea	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 09:19:22.908975+00	po	2026-10-12 09:19:22.908975+00	po	0
d3578398-b742-41d4-a71c-7919da94b2b2	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	77a3afae-fa04-4648-8dc5-19240722030e	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 09:19:23.088953+00	po	2026-10-12 09:19:23.088953+00	po	0
777762d0-ffb6-434b-a59e-a8aba5d380b9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	b08ca36a-27c6-4fcb-a762-f82dd30852e8	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 09:19:25.930388+00	po	2026-10-12 09:19:25.930388+00	po	0
9130fcb8-eaf0-4ae2-919a-d84636b1a974	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 09:18:44.022338+00	dev	2026-10-12 09:18:44.022338+00	dev	0
cfa73ec6-6d89-4140-ad3b-0a17dd688e72	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	7698b215-f69e-49cd-b7d1-c40c96aa8caf	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 09:18:44.09823+00	dev	2026-10-12 09:18:44.09823+00	dev	0
62d0bc23-6f24-45f1-9b3b-73878c89c4a2	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	7698b215-f69e-49cd-b7d1-c40c96aa8caf	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:44.131027+00	qa1	2026-10-12 09:18:44.131027+00	qa1	0
69052d77-d930-4e1f-bcce-c20d721ecaca	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	b4139dae-2333-4955-86a1-1e6c1002e9d4	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:44.19002+00	qa1	2026-10-12 09:18:44.19002+00	qa1	0
0001fccc-d4fd-48ae-a3d9-d1de17ee80ea	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	a8326366-813a-4983-8136-27ea126b14a3	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:44.247108+00	qa1	2026-10-12 09:18:44.247108+00	qa1	0
bbcce1e4-415b-4fa2-bb81-ea0b6c9c5ea3	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	d0883f42-8918-43ce-acf7-10d7c0326acd	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:44.324545+00	qa1	2026-10-12 09:18:44.324545+00	qa1	0
b25d29a1-7ee4-4220-a019-2558bdc64cb1	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	bc3979be-122d-4f0f-b8ed-78698b85905c	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 09:18:45.649925+00	qa1	2026-10-12 09:18:45.649925+00	qa1	0
47d66774-b13a-4735-b7d7-cc63a6c42871	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	bc3979be-122d-4f0f-b8ed-78698b85905c	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:45.734328+00	qa1	2026-10-12 09:18:45.734328+00	qa1	0
74f9c3cf-ab96-41cb-8ac9-45ff4edc962d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "installation-hors-docker", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 09:18:46.667538+00	dev	2026-10-12 09:18:46.667538+00	dev	0
551819f0-e3e0-4e84-ac5a-bf152229183c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:46.705022+00	qa1	2026-10-12 09:18:46.705022+00	qa1	0
b02d4fa4-e9a1-4a44-a7ae-12f994774331	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e05c1346-01ec-449f-8dca-9b8460638a0b	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:46.777947+00	qa1	2026-10-12 09:18:46.777947+00	qa1	0
2ad997f1-4be1-4915-816f-cf2e00675727	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 09:18:54.074857+00	qa1	2026-10-12 09:18:54.074857+00	qa1	0
4680e0a2-3b2b-4c4d-a0bb-dbfea0b4d7ab	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 09:18:46.880007+00	qa1	2026-10-12 09:18:46.880007+00	qa1	0
14af39b1-03b9-4518-b300-c5b8de95f661	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 09:18:46.91401+00	qa1	2026-10-12 09:18:46.91401+00	qa1	0
7da7b2f7-f400-4869-919f-79b7b60a4c1e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e7f1af81-8599-4ebe-901a-9f534713c04e	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 09:19:23.040428+00	po	2026-10-12 09:19:23.040428+00	po	0
b30d7cb2-2fd1-4231-8f70-9abf332d878b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 09:19:24.420876+00	po	2026-10-12 09:19:24.420876+00	po	0
6b2382f1-642e-46fa-bc23-a8b64dda2d7b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	1ea35027-3e83-490c-a3bc-d5cfd89339b0	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:19:25.978113+00	po	2026-10-12 09:19:25.978113+00	po	0
2d91a737-2ab5-411e-b679-db675f2ee384	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:19:25.978113+00	po	2026-10-12 09:19:25.978113+00	po	0
12483e6f-267e-4c0c-9427-96f9649a898f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 09:19:25.978718+00	po	2026-10-12 09:19:25.978718+00	po	0
8ab6ad60-b799-46f6-a26c-baa0270a4b08	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	b08ca36a-27c6-4fcb-a762-f82dd30852e8	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 09:19:25.978718+00	po	2026-10-12 09:19:25.978718+00	po	0
d075f37b-0bbd-4a68-a083-78ff7ac413a8	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	e47624ca-d400-475e-b4da-9f2eae51cc70	CMP-2	UPDATED	[{"after": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 09:19:26.980666+00	qa1	2026-10-12 09:19:26.980666+00	qa1	0
71dc5dac-74f8-4eb1-8654-7daec7597c7f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	e47624ca-d400-475e-b4da-9f2eae51cc70	CMP-2	UPDATED	[{"after": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2 [Compte du défaut #1]", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 09:19:27.00119+00	qa1	2026-10-12 09:19:27.00119+00	qa1	0
29182ca8-0a64-4dfa-a465-aa4fcfea5752	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	cf50092f-9431-4b3a-bef2-3712c4c44c77	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=standard_user}", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 09:18:46.944013+00	qa1	2026-10-12 09:18:46.944013+00	qa1	0
a6d1ca7c-49ba-4d6d-9898-e1c9ab5dd90a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RELEASE	29fcc520-e884-4a36-9c5b-5b922c457976	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 09:18:51.208679+00	po	2026-10-12 09:18:51.208679+00	po	0
f435ae0b-33b8-4608-aa05-563b8a580e48	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 09:18:51.237673+00	po	2026-10-12 09:18:51.237673+00	po	0
af49ba5a-bd31-4536-847c-689534c1f0d8	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 09:18:52.154996+00	po	2026-10-12 09:18:52.154996+00	po	0
6eb570a9-ec65-46ec-8369-d2b423815bb2	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 09:18:52.216782+00	po	2026-10-12 09:18:52.216782+00	po	0
74d8f826-467e-4a71-afc8-75330eab6d9d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 09:18:54.578542+00	qa1	2026-10-12 09:18:54.578542+00	qa1	0
a21585d9-95c0-4580-84bd-749e007dc7ba	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 09:19:22.971832+00	po	2026-10-12 09:19:22.971832+00	po	0
b437030c-6168-4f2f-97ab-b89249b065a9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 09:19:25.221462+00	po	2026-10-12 09:19:25.221462+00	po	0
94762427-6d8f-4d3c-aca4-585af2207f34	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	e47624ca-d400-475e-b4da-9f2eae51cc70	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 09:19:26.955036+00	qa1	2026-10-12 09:19:26.955036+00	qa1	0
134a504a-e73d-4855-8ebd-39fe4dbae709	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEFECT	2494f6c0-d5af-412f-a70e-4a491e1cc8ad	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n**Jeu de données** : Compte du défaut, ligne 1\\n\\n**Étapes pour reproduire**\\n\\n1. Se connecter avec problem_user\\n2. Cliquer « Add to cart » sur Sauce Labs Backpack\\n3. Ouvrir le panier\\n4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 09:19:30.008218+00	qa2	2026-10-12 09:19:30.008218+00	qa2	0
26bef49a-e199-40c0-b822-9c8b3083dc01	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SESSION	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 09:19:32.452406+00	qa1	2026-10-12 09:19:32.452406+00	qa1	0
5cdf79bf-de11-4133-9f40-3059ea3dc648	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEFECT	55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 00:00\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 09:19:33.389668+00	qa1	2026-10-12 09:19:33.389668+00	qa1	0
600a95e2-049d-4ef0-bbe9-d5b304f2a5cc	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SESSION	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 09:19:34.671944+00	qa1	2026-10-12 09:19:34.671944+00	qa1	0
13eb35ca-8bec-49a6-80c3-9d0e4ca60ae0	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SESSION	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 09:19:34.821545+00	qa1	2026-10-12 09:19:34.821545+00	qa1	0
1c5855d6-a754-4caa-a35c-d0e5646f82e4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	SESSION	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 09:19:35.407475+00	po	2026-10-12 09:19:35.407475+00	po	0
3ce136fc-40ad-4fbe-a123-ec8e7e1bac5c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RUN	6b25a481-b5c5-4f33-b395-be02d578edc1	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 09:19:36.819309+00	dev	2026-10-12 09:19:36.819309+00	dev	0
d42dc8c4-a342-4477-8d0f-d79c6823ec28	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CAMPAIGN	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 09:19:59.040192+00	qa1	2026-10-12 09:19:59.040192+00	qa1	0
746b2ba4-7941-4c99-8aa8-42e27b3d6a17	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 09:20:08.144402+00	po	2026-10-12 09:20:08.144402+00	po	0
2944394c-bbe1-4a26-895f-1f1d7e196aca	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	a8326366-813a-4983-8136-27ea126b14a3	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 09:20:08.152507+00	po	2026-10-12 09:20:08.152507+00	po	0
837d5eb1-e131-46bb-ab68-5bef4181e98d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TRACE_LINK	481b7d0a-7619-46ca-84ae-03bff434a453	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 09:20:08.799032+00	qa1	2026-10-12 09:20:08.799032+00	qa1	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
06ad4757-c916-459c-a96b-0ecb80a6980a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RUN-1	1	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	ec73112e-e745-4c97-a521-97707ebfbbe0	COMPLETED	dev	2026-10-12 09:18:57.761852+00	2026-10-12 09:18:57.814099+00	2026-10-12 09:18:57.812109+00	2026-10-12 09:19:20.955551+00	2026-10-12 09:19:20.955551+00	recette	1.0.0-s1	job-15529250	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-15529250/logs	http://localhost:8091/api/v1/jobs/job-15529250/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 09:18:57.766062+00	dev	2026-10-12 09:19:20.969696+00	anonymousUser	8
6b25a481-b5c5-4f33-b395-be02d578edc1	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RUN-2	2	e47624ca-d400-475e-b4da-9f2eae51cc70	ec73112e-e745-4c97-a521-97707ebfbbe0	COMPLETED	dev	2026-10-12 09:19:36.817682+00	2026-10-12 09:19:36.849738+00	2026-10-12 09:19:36.847434+00	2026-10-12 09:19:56.070798+00	2026-10-12 09:19:56.070798+00	recette	1.0.0-s2	job-bd4eaea4	executeur-docker@8b1369b338fd	http://localhost:8091/api/v1/jobs/job-bd4eaea4/logs	http://localhost:8091/api/v1/jobs/job-bd4eaea4/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 09:19:36.818703+00	dev	2026-10-12 09:19:56.080036+00	anonymousUser	8
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e1bdf970-cfdb-4c66-b4c9-781fd31e0b6d	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	DATA_DRIVEN	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 09:18:44.017493+00	dev	2026-10-12 09:18:44.017493+00	dev	0
389b3c9d-5471-4e07-8f42-e1561c28c9d2	7698b215-f69e-49cd-b7d1-c40c96aa8caf	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 09:18:44.095327+00	dev	2026-10-12 09:18:44.095327+00	dev	0
dce76942-8635-4cc4-88ba-fd3071e6abe6	b4139dae-2333-4955-86a1-1e6c1002e9d4	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 09:18:44.159825+00	dev	2026-10-12 09:18:44.159825+00	dev	0
603ba034-cf19-4b86-9660-2ccf40514709	a8326366-813a-4983-8136-27ea126b14a3	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 09:18:44.213271+00	dev	2026-10-12 09:18:44.213271+00	dev	0
d3f4bf0d-542d-4a68-91a3-5a9b0e5d8531	d0883f42-8918-43ce-acf7-10d7c0326acd	API	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 09:18:44.281083+00	dev	2026-10-12 09:18:44.281083+00	dev	0
b4f35dbe-dd2b-4db3-9722-787485656b3f	bc3979be-122d-4f0f-b8ed-78698b85905c	BDD	Playwright	\N	file:///depots/traceagile	installation-hors-docker	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 09:18:45.636563+00	qa1	2026-10-12 09:18:45.778288+00	qa1	1
2a47de14-a755-4ce3-bb0c-bd9e99273b95	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 09:18:46.664875+00	dev	2026-10-12 09:18:46.664875+00	dev	0
6a7b256b-ccb4-4e4e-aeb4-3119d7d7a616	e05c1346-01ec-449f-8dca-9b8460638a0b	UI	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 09:18:46.737718+00	dev	2026-10-12 09:18:46.737718+00	dev	0
130ea555-634d-4b9c-a085-61adad3f0ccd	e80123ec-b623-49f6-8574-a3a732204856	PERFORMANCE	Playwright	TypeScript	file:///depots/traceagile	installation-hors-docker	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 09:18:46.809371+00	dev	2026-10-12 09:18:46.809371+00	dev	0
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
36a715c1-0863-48b2-b0fc-27980c27d655	BDD	Cucumber-JVM	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
ecc77081-0da1-47ff-898e-55ac239b8b45	BDD	Cucumber-JS	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
56772899-280e-48bb-be66-e2d94fa76c16	BDD	Behave	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
343a2b99-166e-42a4-ad62-75fe9d47734f	BDD	SpecFlow	4	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
b3b462d7-cc2e-46da-a972-65553ec38a7e	BDD	Karate	5	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
76b81ee8-f6ca-4249-985a-4063a4d44c9c	UNIT	JUnit 5	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
3581218b-331b-488d-8f59-4340151734f2	UNIT	Kotest	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
0a7e16a8-fa4d-4892-8dee-df8a036854fc	UNIT	pytest	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
37fbc5c0-1b44-4e13-aa1f-691f2c3f15cd	UNIT	Jest	4	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
604de666-51d5-4069-bd97-5bccfb27aa87	UNIT	Vitest	5	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
b90f9da6-de7c-440c-acb1-5bff72ee0f12	UI	Playwright	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
92e87c02-5646-4b9d-8dc7-021feecc34e1	UI	Selenium	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
83f161e8-929c-4d85-8c85-461c2df8d33b	UI	Cypress	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
a07c15cc-d053-42f5-89cb-13943a9ae978	UI	Appium	4	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
1e76055a-2da0-4360-b785-c822ed2a9681	API	REST Assured	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
49f17063-e3a9-4240-8868-04ad6b96aa24	API	Karate	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
9e37e486-b024-4513-b79b-3dac257184e5	API	Postman/Newman	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
732ef6be-319c-48a3-8059-b171c355cade	API	pytest + requests	4	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
ddfe0b51-88da-4661-9105-cfb2f2791dee	KEYWORD	Robot Framework	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
7dbd68f1-8a9f-4c0d-9363-4950062d7596	DATA_DRIVEN	JUnit 5	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
b21ce2c9-e128-4849-b26a-d595b7fcbc7e	DATA_DRIVEN	pytest	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
bcb653c2-a25e-47b8-99a9-9511862eff21	DATA_DRIVEN	Playwright	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
eb0d30db-8ea0-4fc0-8d6f-898b7b45e21b	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
286a4660-b9bc-46c1-8927-dbd3c416d232	PERFORMANCE	Gatling	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
03f5418a-caa0-4cf3-9567-1ffd13107108	PERFORMANCE	k6	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
6af910ef-b200-436a-b7bf-f6204093f00a	PERFORMANCE	JMeter	3	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
ab1e4706-5b87-4108-823f-320ab242a708	CONTRACT	Pact	1	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
e1889f8b-975c-48c1-900b-8969ecc12f3c	CONTRACT	Spring Cloud Contract	2	2026-10-12 09:18:16.045547+00	system	2026-10-12 09:18:16.045547+00	system	0
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
e7ef7b02-f776-4a3e-a540-98d770884d60	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	1	\N	4	12	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.323655+00	qa1	0	\N	\N
f1be9b42-956a-4bf0-b63a-26b27f4dae65	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	7698b215-f69e-49cd-b7d1-c40c96aa8caf	1	\N	5	6	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.323655+00	qa1	0	\N	\N
433c03c1-2beb-4b31-b4c5-ea5adfe93e6d	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	b4139dae-2333-4955-86a1-1e6c1002e9d4	1	\N	6	3	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.323655+00	qa1	0	\N	\N
a68c0712-888a-4f31-bcb2-2ee8caaf8aaf	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	a8326366-813a-4983-8136-27ea126b14a3	1	\N	7	3	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.323655+00	qa1	0	\N	\N
26bd3934-bdf4-4f13-b65d-1d3e69eb00b8	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	d0883f42-8918-43ce-acf7-10d7c0326acd	1	\N	8	6	2026-10-12 09:18:54.576342+00	qa1	2026-10-12 09:18:54.576342+00	qa1	0	\N	\N
d14762e4-3d16-4ea3-9a5a-8babfd1076b0	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	4024d965-5801-4535-8cb6-23688dca7a13	1	2104170e-c421-4b32-ab97-2c9f9425af53	1	16	2026-10-12 09:18:54.323067+00	qa1	2026-10-12 09:18:54.620532+00	qa1	1	Comptes	0
181cdd20-faa2-42c1-a116-b6438203370b	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	4024d965-5801-4535-8cb6-23688dca7a13	1	2104170e-c421-4b32-ab97-2c9f9425af53	2	16	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.640679+00	qa1	1	Comptes	1
1b56d024-b14e-4e4b-b7c3-82af0bc9be78	0f8e9c27-e003-4fb8-90bb-afdfb6c30889	4024d965-5801-4535-8cb6-23688dca7a13	1	2104170e-c421-4b32-ab97-2c9f9425af53	3	16	2026-10-12 09:18:54.323655+00	qa1	2026-10-12 09:18:54.657537+00	qa1	1	Comptes	2
b43f7729-fba7-420c-bee8-1718f5b0f88f	e47624ca-d400-475e-b4da-9f2eae51cc70	bc3979be-122d-4f0f-b8ed-78698b85905c	2	\N	3	12	2026-10-12 09:19:26.976028+00	qa1	2026-10-12 09:19:26.976028+00	qa1	0	\N	\N
2d8cee7b-0e74-4d93-b320-dcc55e79e868	e47624ca-d400-475e-b4da-9f2eae51cc70	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	1	\N	4	12	2026-10-12 09:19:26.976028+00	qa1	2026-10-12 09:19:26.976028+00	qa1	0	\N	\N
cf08f8ef-4a69-433f-a4b5-0be266e76874	e47624ca-d400-475e-b4da-9f2eae51cc70	e05c1346-01ec-449f-8dca-9b8460638a0b	1	\N	7	6	2026-10-12 09:19:26.976028+00	qa1	2026-10-12 09:19:26.976028+00	qa1	0	\N	\N
f8de26e3-7d46-4f5a-ba5f-afca844bfd7d	e47624ca-d400-475e-b4da-9f2eae51cc70	e80123ec-b623-49f6-8574-a3a732204856	1	\N	8	6	2026-10-12 09:19:27.00016+00	qa1	2026-10-12 09:19:27.00016+00	qa1	0	\N	\N
d95de569-7363-4464-b015-b79a718147af	e47624ca-d400-475e-b4da-9f2eae51cc70	3c23dff1-b246-4196-a751-df329fc0dfe6	1	61044b7f-ede3-4da5-8a52-31b4cdb66421	1	16	2026-10-12 09:19:26.975514+00	qa1	2026-10-12 09:19:27.03192+00	qa1	1	Compte du défaut	0
c0ef9ed2-831b-4f42-a1aa-4563836366b4	e47624ca-d400-475e-b4da-9f2eae51cc70	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	1	2104170e-c421-4b32-ab97-2c9f9425af53	2	16	2026-10-12 09:19:26.975514+00	qa1	2026-10-12 09:19:27.048296+00	qa1	1	\N	\N
200228af-2395-4e5c-bbf7-9d331a61dd51	e47624ca-d400-475e-b4da-9f2eae51cc70	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	2104170e-c421-4b32-ab97-2c9f9425af53	5	12	2026-10-12 09:19:26.976028+00	qa1	2026-10-12 09:19:27.067944+00	qa1	1	Produits	0
a786a026-7787-476c-83f4-c437ac06a2b0	e47624ca-d400-475e-b4da-9f2eae51cc70	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	2104170e-c421-4b32-ab97-2c9f9425af53	6	12	2026-10-12 09:19:26.976028+00	qa1	2026-10-12 09:19:27.087778+00	qa1	1	Produits	1
0f2cd4ad-5b8e-4ec3-b0d5-c6af5b16ed42	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	d0883f42-8918-43ce-acf7-10d7c0326acd	1	\N	1	0	2026-10-12 09:20:00.287377+00	qa1	2026-10-12 09:20:00.287377+00	qa1	0	\N	\N
af5022f2-b714-4416-822d-b2dff085f7bb	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	1	\N	2	0	2026-10-12 09:20:00.294498+00	qa1	2026-10-12 09:20:00.294498+00	qa1	0	\N	\N
e1557e83-15b7-4088-917d-224f39e1f606	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	7698b215-f69e-49cd-b7d1-c40c96aa8caf	1	\N	3	0	2026-10-12 09:20:00.298893+00	qa1	2026-10-12 09:20:00.298893+00	qa1	0	\N	\N
4628b934-ddd0-43a6-81dc-b33f82e3e5a5	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	b4139dae-2333-4955-86a1-1e6c1002e9d4	1	\N	4	0	2026-10-12 09:20:00.303206+00	qa1	2026-10-12 09:20:00.303206+00	qa1	0	\N	\N
1abfd238-fb27-4ad2-8146-c431e5006195	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	a8326366-813a-4983-8136-27ea126b14a3	1	\N	5	0	2026-10-12 09:20:00.308545+00	qa1	2026-10-12 09:20:00.308545+00	qa1	0	\N	\N
89970ede-901a-42d0-95c9-7a9bde4b64f3	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	bc3979be-122d-4f0f-b8ed-78698b85905c	2	\N	6	0	2026-10-12 09:20:00.313477+00	qa1	2026-10-12 09:20:00.313477+00	qa1	0	\N	\N
f45fd985-967e-4033-9d02-5c033b4cf7a9	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	1	\N	7	0	2026-10-12 09:20:00.318446+00	qa1	2026-10-12 09:20:00.318446+00	qa1	0	\N	\N
7fe708ad-ed53-4167-a010-34eb682e1364	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	e05c1346-01ec-449f-8dca-9b8460638a0b	1	\N	8	0	2026-10-12 09:20:00.323639+00	qa1	2026-10-12 09:20:00.323639+00	qa1	0	\N	\N
a6f4a5a9-f34b-493d-8ac4-c087ef75fb3c	1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	e80123ec-b623-49f6-8574-a3a732204856	1	\N	9	0	2026-10-12 09:20:00.328857+00	qa1	2026-10-12 09:20:00.328857+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
0f8e9c27-e003-4fb8-90bb-afdfb6c30889	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CMP-1	1	Recette sprint 1	SPRINT	c484721e-147f-40bd-8dbe-83f842162033	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 09:18:54.074352+00	qa1	2026-10-12 09:19:22.828714+00	qa1	3	Release 1.0/Recettes de sprint
e47624ca-d400-475e-b4da-9f2eae51cc70	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CMP-2	2	Recette sprint 2	SPRINT	b08ca36a-27c6-4fcb-a762-f82dd30852e8	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 09:19:26.955036+00	qa1	2026-10-12 09:19:27.949388+00	qa2	2	Release 1.0/Recettes de sprint
1ccb9fdf-9cc5-404e-ab76-7a56f95862fd	99b0e710-6ad5-4465-8b19-0d4f93923ae0	CMP-3	3	Intégration continue — main	RELEASE	\N	29fcc520-e884-4a36-9c5b-5b922c457976	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 09:19:59.040192+00	qa1	2026-10-12 09:20:00.290135+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a5571abf-fae3-4380-a129-af6733235f15	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 09:18:30.073923+00	admin	2026-10-12 09:18:30.073923+00	admin	0
cb09fa27-d779-459c-bedd-cf9aa4f7dac9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 09:18:30.074435+00	admin	2026-10-12 09:18:30.074435+00	admin	0
1f8e034d-0ec0-4622-a2a4-09ae4cf1223e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 09:18:30.074435+00	admin	2026-10-12 09:18:30.074435+00	admin	0
a1a7ebd3-58bd-49fe-a6e3-90f832b81d12	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 09:18:30.074941+00	admin	2026-10-12 09:18:30.074941+00	admin	0
e697d4e9-b89c-4f47-8fcd-5a02ee4bf9ba	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 09:18:30.074941+00	admin	2026-10-12 09:18:30.074941+00	admin	0
f1c11b70-ae43-4a98-a3ac-8583dfe10c49	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 09:18:30.074941+00	admin	2026-10-12 09:18:30.074941+00	admin	0
01807ad7-0d98-4a71-8ed5-e80910770f08	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DOD	4	Code revu et intégré	\N	2026-10-12 09:18:30.074941+00	admin	2026-10-12 09:18:30.074941+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
33b5da70-880f-4aab-b9c4-3e451e5760a1	dd103bcf-8759-482a-9f1f-af52d5b91f52	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 09:18:40.331786+00	po	2026-10-12 09:18:40.331786+00	po	0
653c76da-5840-48a6-a0ee-c3d4d3449267	7829e77d-535f-44eb-90a9-4a1de99d13d6	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 09:18:41.220579+00	po	2026-10-12 09:18:41.220579+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
2494f6c0-d5af-412f-a70e-4a491e1cc8ad	4c6434c0-0b1c-441d-a6ac-a34e3c733080
55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	faa6ef89-b6e6-46f6-b13e-5e4ae25b61e5
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
2494f6c0-d5af-412f-a70e-4a491e1cc8ad	7829e77d-535f-44eb-90a9-4a1de99d13d6
2494f6c0-d5af-412f-a70e-4a491e1cc8ad	f541393a-f7bc-4bfe-a708-897b922fec4e
55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	7829e77d-535f-44eb-90a9-4a1de99d13d6
55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	f541393a-f7bc-4bfe-a708-897b922fec4e
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
2494f6c0-d5af-412f-a70e-4a491e1cc8ad	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n**Jeu de données** : Compte du défaut, ligne 1\n\n**Étapes pour reproduire**\n\n1. Se connecter avec problem_user\n2. Cliquer « Add to cart » sur Sauce Labs Backpack\n3. Ouvrir le panier\n4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 09:19:30.008218+00	qa2	2026-10-12 09:19:30.012732+00	qa2	1
55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 00:00\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 09:19:33.389668+00	qa1	2026-10-12 09:19:33.391252+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
933e6664-68de-4881-9fa7-50f3d1f15914	dd103bcf-8759-482a-9f1f-af52d5b91f52	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 09:18:39.98086+00	po	2026-10-12 09:18:39.98086+00	po	0
01c19716-0814-4a1f-87a3-70f664c862bf	dd103bcf-8759-482a-9f1f-af52d5b91f52	EXAMPLE	933e6664-68de-4881-9fa7-50f3d1f15914	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 09:18:40.102599+00	po	2026-10-12 09:18:40.102599+00	po	0
4323bf1b-2a81-4fdb-8222-3a6c1cf1c168	dd103bcf-8759-482a-9f1f-af52d5b91f52	EXAMPLE	933e6664-68de-4881-9fa7-50f3d1f15914	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 09:18:40.157731+00	po	2026-10-12 09:18:40.157731+00	po	0
1713af9f-312f-448b-9845-c8fbd80082ef	dd103bcf-8759-482a-9f1f-af52d5b91f52	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 09:18:40.215479+00	po	2026-10-12 09:18:40.215479+00	po	0
d3a429ba-97a5-40f1-bb48-3e96fc46a677	dd103bcf-8759-482a-9f1f-af52d5b91f52	EXAMPLE	1713af9f-312f-448b-9845-c8fbd80082ef	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 09:18:40.274762+00	po	2026-10-12 09:18:40.274762+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ec73112e-e745-4c97-a521-97707ebfbbe0	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Cucumber-JS"]	[]	4	t	2026-10-12 09:18:31.449675+00	admin	2026-10-12 09:19:40.032526+00	system	3
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
308b25df-8286-4f08-b924-b5a07712e04c	d14762e4-3d16-4ea3-9a5a-8babfd1076b0	4024d965-5801-4535-8cb6-23688dca7a13	1	1	PASSED	f	2026-10-12 09:18:55.505378+00	2026-10-12 09:18:56.202627+00	697	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 09:18:55.510697+00	qa1	2026-10-12 09:18:56.203665+00	qa1	1	\N
b52a3d68-f75e-4b54-ac7b-9161c07b4709	181cdd20-faa2-42c1-a116-b6438203370b	4024d965-5801-4535-8cb6-23688dca7a13	1	1	PASSED	f	2026-10-12 09:18:56.262682+00	2026-10-12 09:18:56.303047+00	40	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 09:18:56.264815+00	qa1	2026-10-12 09:18:56.304071+00	qa1	1	\N
37cd8ca9-d6ac-47e4-9562-97a7fcd8f4a4	1b56d024-b14e-4e4b-b7c3-82af0bc9be78	4024d965-5801-4535-8cb6-23688dca7a13	1	1	PASSED	f	2026-10-12 09:18:56.320638+00	2026-10-12 09:18:56.357621+00	36	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 09:18:56.322709+00	qa1	2026-10-12 09:18:56.359176+00	qa1	1	\N
e921dcf1-b140-4e8b-b9ff-9cfabcb576b8	26bd3934-bdf4-4f13-b65d-1d3e69eb00b8	d0883f42-8918-43ce-acf7-10d7c0326acd	1	1	PASSED	f	2026-10-12 09:19:16.638517+00	2026-10-12 09:19:19.321282+00	2687	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:19:19.343368+00	anonymousUser	2	06ad4757-c916-459c-a96b-0ecb80a6980a
08d88a3e-952e-475c-ae0d-a7dbe501f76a	e7ef7b02-f776-4a3e-a540-98d770884d60	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	1	1	PASSED	f	2026-10-12 09:19:16.63583+00	2026-10-12 09:19:19.733451+00	3100	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:19:19.746407+00	anonymousUser	2	06ad4757-c916-459c-a96b-0ecb80a6980a
2301e7c8-e6c9-43c6-8204-9e2d38373483	f1be9b42-956a-4bf0-b63a-26b27f4dae65	7698b215-f69e-49cd-b7d1-c40c96aa8caf	1	1	PASSED	f	2026-10-12 09:19:16.63622+00	2026-10-12 09:19:19.36265+00	2730	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:19:19.899166+00	anonymousUser	2	06ad4757-c916-459c-a96b-0ecb80a6980a
66fd83ba-a918-4476-8372-a861af094221	433c03c1-2beb-4b31-b4c5-ea5adfe93e6d	b4139dae-2333-4955-86a1-1e6c1002e9d4	1	1	PASSED	f	2026-10-12 09:19:16.638159+00	2026-10-12 09:19:19.362651+00	2729	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:19:19.899166+00	anonymousUser	2	06ad4757-c916-459c-a96b-0ecb80a6980a
6e7ec738-8636-4a1d-85e4-fbed99ddb1e5	a68c0712-888a-4f31-bcb2-2ee8caaf8aaf	a8326366-813a-4983-8136-27ea126b14a3	1	1	PASSED	f	2026-10-12 09:19:19.362371+00	2026-10-12 09:19:20.929678+00	1566	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:18:57.767064+00	dev	2026-10-12 09:19:20.942605+00	anonymousUser	2	06ad4757-c916-459c-a96b-0ecb80a6980a
4c6434c0-0b1c-441d-a6ac-a34e3c733080	d95de569-7363-4464-b015-b79a718147af	3c23dff1-b246-4196-a751-df329fc0dfe6	1	1	FAILED	f	2026-10-12 09:19:27.946753+00	2026-10-12 09:19:28.582093+00	635	\N	qa2	MANUAL	Compte du défaut	0	{"utilisateur": "problem_user"}	2026-10-12 09:19:27.948866+00	qa2	2026-10-12 09:19:28.583121+00	qa2	1	\N
221e0863-7fb5-4b25-a950-d787368921d0	200228af-2395-4e5c-bbf7-9d331a61dd51	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	1	PASSED	f	2026-10-12 09:19:30.518544+00	2026-10-12 09:19:31.34993+00	831	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 09:19:30.521129+00	qa1	2026-10-12 09:19:31.350445+00	qa1	1	\N
5966dda8-77c6-4364-8a29-cdcdbc8cacf5	a786a026-7787-476c-83f4-c437ac06a2b0	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	1	PASSED	f	2026-10-12 09:19:31.395804+00	2026-10-12 09:19:31.455037+00	59	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 09:19:31.398434+00	qa1	2026-10-12 09:19:31.456058+00	qa1	1	\N
faa6ef89-b6e6-46f6-b13e-5e4ae25b61e5	c0ef9ed2-831b-4f42-a1aa-4563836366b4	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	1	1	FAILED	f	2026-10-12 09:19:32.448062+00	2026-10-12 09:19:34.668709+00	2000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 09:19:32.451879+00	qa1	2026-10-12 09:19:34.672463+00	qa1	1	\N
9c89a7b8-221c-4b9b-a95a-f55956a521c9	b43f7729-fba7-420c-bee8-1718f5b0f88f	bc3979be-122d-4f0f-b8ed-78698b85905c	1	2	PASSED	f	2026-10-12 09:19:50.180795+00	2026-10-12 09:19:52.905636+00	2724	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:19:36.818703+00	dev	2026-10-12 09:19:52.915807+00	anonymousUser	2	6b25a481-b5c5-4f33-b395-be02d578edc1
13704fa8-3ed0-4ced-8504-d7ef24af2426	2d8cee7b-0e74-4d93-b320-dcc55e79e868	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	1	1	PASSED	f	2026-10-12 09:19:50.18067+00	2026-10-12 09:19:53.003433+00	2822	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:19:36.819309+00	dev	2026-10-12 09:19:53.012394+00	anonymousUser	2	6b25a481-b5c5-4f33-b395-be02d578edc1
8913cdbb-4691-4b1a-81ef-48fff569dd53	f8de26e3-7d46-4f5a-ba5f-afca844bfd7d	e80123ec-b623-49f6-8574-a3a732204856	1	1	PASSED	f	2026-10-12 09:19:50.180705+00	2026-10-12 09:19:53.384352+00	3203	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:19:36.819309+00	dev	2026-10-12 09:19:53.392906+00	anonymousUser	2	6b25a481-b5c5-4f33-b395-be02d578edc1
65e6ed6a-058d-4c81-b611-1ddc79203c9b	cf08f8ef-4a69-433f-a4b5-0be266e76874	e05c1346-01ec-449f-8dca-9b8460638a0b	1	1	FAILED	f	2026-10-12 09:19:50.180658+00	2026-10-12 09:19:56.048644+00	5867	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-bd4eaea4/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 09:19:36.819309+00	dev	2026-10-12 09:19:56.060768+00	anonymousUser	2	6b25a481-b5c5-4f33-b395-be02d578edc1
0edc856a-d986-45eb-9d95-8f175345f381	0f2cd4ad-5b8e-4ec3-b0d5-c6af5b16ed42	d0883f42-8918-43ce-acf7-10d7c0326acd	1	1	PASSED	f	2026-10-12 09:19:59.724234+00	2026-10-12 09:20:00.286234+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.289529+00	qa1	2026-10-12 09:20:00.289529+00	qa1	0	\N
c7dd91f4-aa4c-4115-8e69-5a167933e729	af5022f2-b714-4416-822d-b2dff085f7bb	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	1	1	PASSED	f	2026-10-12 09:19:56.771234+00	2026-10-12 09:20:00.286234+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.296108+00	qa1	2026-10-12 09:20:00.296108+00	qa1	0	\N
4830513b-383e-4f5d-b198-12deeff7ff39	e1557e83-15b7-4088-917d-224f39e1f606	7698b215-f69e-49cd-b7d1-c40c96aa8caf	1	1	PASSED	f	2026-10-12 09:19:57.081234+00	2026-10-12 09:20:00.286234+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.299968+00	qa1	2026-10-12 09:20:00.299968+00	qa1	0	\N
7d0af19d-6fd6-4ffd-8ab5-4514e90acd64	4628b934-ddd0-43a6-81dc-b33f82e3e5a5	b4139dae-2333-4955-86a1-1e6c1002e9d4	1	1	PASSED	f	2026-10-12 09:19:59.844234+00	2026-10-12 09:20:00.286234+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.30478+00	qa1	2026-10-12 09:20:00.30478+00	qa1	0	\N
19ded50e-500b-4c07-89c7-f2da4100d6b4	1abfd238-fb27-4ad2-8146-c431e5006195	a8326366-813a-4983-8136-27ea126b14a3	1	1	PASSED	f	2026-10-12 09:19:59.749234+00	2026-10-12 09:20:00.286234+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.310342+00	qa1	2026-10-12 09:20:00.310342+00	qa1	0	\N
5663301d-fcae-4e62-8002-677baa0f41f4	89970ede-901a-42d0-95c9-7a9bde4b64f3	bc3979be-122d-4f0f-b8ed-78698b85905c	1	2	PASSED	f	2026-10-12 09:19:59.599234+00	2026-10-12 09:20:00.286234+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.315105+00	qa1	2026-10-12 09:20:00.315105+00	qa1	0	\N
1d6ce379-8758-4111-aa5e-ae999254984b	f45fd985-967e-4033-9d02-5c033b4cf7a9	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	1	1	PASSED	f	2026-10-12 09:19:59.739234+00	2026-10-12 09:20:00.286234+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.319985+00	qa1	2026-10-12 09:20:00.319985+00	qa1	0	\N
867b27fd-7a1d-4b67-8f31-eab1dd629784	7fe708ad-ed53-4167-a010-34eb682e1364	e05c1346-01ec-449f-8dca-9b8460638a0b	1	1	FAILED	f	2026-10-12 09:19:56.818234+00	2026-10-12 09:20:00.286234+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.32576+00	qa1	2026-10-12 09:20:00.32576+00	qa1	0	\N
9bbe17d0-db5c-4670-a850-2f398f6ea844	a6f4a5a9-f34b-493d-8ac4-c087ef75fb3c	e80123ec-b623-49f6-8574-a3a732204856	1	1	PASSED	f	2026-10-12 09:19:59.472234+00	2026-10-12 09:20:00.286234+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 09:20:00.33014+00	qa1	2026-10-12 09:20:00.33014+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
31ce86c0-b315-476f-a867-8bd20f592831	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 09:18:46.874842+00	qa1	2026-10-12 09:18:46.874842+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
6a4a6dd7-ae59-4612-a7ce-128341cb12e8	faa6ef89-b6e6-46f6-b13e-5e4ae25b61e5	DEBRIEFED	60	2	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 09:19:34.819985+00	po	2026-10-12 09:19:35.406451+00	2026-10-12 09:19:32.451879+00	qa1	2026-10-12 09:19:35.407994+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 11:18:15.832292	51	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 11:18:15.914941	110	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 11:18:16.040024	88	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 11:18:16.142231	14	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 11:18:16.167546	6	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 11:18:16.182844	40	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 11:18:16.233638	74	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 11:18:16.324064	9	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 11:18:16.352836	11	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 11:18:16.383644	20	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 11:18:16.419381	32	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 11:18:16.467535	55	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 11:18:16.539252	20	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 11:18:16.575277	32	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 11:18:16.622065	24	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 11:18:16.656763	16	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 11:18:16.680771	9	t
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ	18
99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC	14
99b0e710-6ad5-4465-8b19-0d4f93923ae0	REL	2
99b0e710-6ad5-4465-8b19-0d4f93923ae0	SPR	3
99b0e710-6ad5-4465-8b19-0d4f93923ae0	DEF	3
99b0e710-6ad5-4465-8b19-0d4f93923ae0	RUN	3
99b0e710-6ad5-4465-8b19-0d4f93923ae0	CMP	4
99b0e710-6ad5-4465-8b19-0d4f93923ae0	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters") FROM stdin;
9402d353-1a8d-40e0-86cb-a3ebcc9a344e	4024d965-5801-4535-8cb6-23688dca7a13	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 09:18:43.847546+00	qa1	2026-10-12 09:18:43.847546+00	qa1	0	\N	{}
1c87d5e4-ec7d-406e-8b86-b622c307a151	4024d965-5801-4535-8cb6-23688dca7a13	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 09:18:43.848048+00	qa1	2026-10-12 09:18:43.848048+00	qa1	0	\N	{}
6261dd1a-0d92-48fc-a79c-a0bade12267e	3c23dff1-b246-4196-a751-df329fc0dfe6	1	Se connecter avec ${utilisateur}	Le catalogue s’affiche	\N	2026-10-12 09:18:43.940811+00	qa1	2026-10-12 09:18:43.940811+00	qa1	0	\N	{}
c34caf3c-4bd4-4bf3-9872-15c725a15bbe	3c23dff1-b246-4196-a751-df329fc0dfe6	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 09:18:43.940811+00	qa1	2026-10-12 09:18:43.940811+00	qa1	0	\N	{}
56963fd9-84d0-4f49-9003-474f45f2da82	3c23dff1-b246-4196-a751-df329fc0dfe6	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 09:18:43.940811+00	qa1	2026-10-12 09:18:43.940811+00	qa1	0	\N	{}
8d9aa605-fc2d-4649-9f69-9451753914c8	3c23dff1-b246-4196-a751-df329fc0dfe6	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 09:18:43.941326+00	qa1	2026-10-12 09:18:43.941326+00	qa1	0	\N	{}
e2b10d6f-8108-488b-9f79-88b9b4c3d8d0	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	\N	\N	\N	2026-10-12 09:18:46.939646+00	qa1	2026-10-12 09:18:46.939646+00	qa1	0	4024d965-5801-4535-8cb6-23688dca7a13	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}
8c39be20-4618-4681-a84d-3f75f3a61639	cf50092f-9431-4b3a-bef2-3712c4c44c77	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 09:18:46.94016+00	qa1	2026-10-12 09:18:46.94016+00	qa1	0	\N	{}
ef1db0d7-4d1c-462d-88ce-0e3319e88465	cf50092f-9431-4b3a-bef2-3712c4c44c77	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 09:18:46.94016+00	qa1	2026-10-12 09:18:46.94016+00	qa1	0	\N	{}
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e5720b18-2d42-418c-a078-382503d4e607	394bda32-06f8-4f44-a2f5-2232e4bfdf48	333	ms	p95Ms	TC-11	RUN-2	2026-10-12 09:19:53.384352+00	TARGET_MET	2026-10-12 09:19:53.40147+00	anonymousUser	2026-10-12 09:19:53.40147+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
6cc47019-6bdd-46cf-99b5-c39a8e02fc7f	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:18:57.833821+00
2d764da5-3e31-45b1-a45d-0a0e9c90e1b7	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:16.644503+00
69fa90d7-b26d-44fa-adc7-159b22f8af7f	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:17.18046+00
a11a040e-f654-4111-943a-2fcf505025dd	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:17.18046+00
6f6aa1d0-8043-4dbc-bc50-ad0685c42120	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:17.18046+00
c5002ffa-556e-4254-b955-1c2575678172	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:19.332322+00
1a04da1f-57eb-4df5-af20-a29f1be9c6f3	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:19.370119+00
f3e9b606-4f17-4964-b051-aca224757179	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:19.74169+00
02fd71be-648a-4de0-b241-ebe9a484fdc2	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:19.895484+00
5cfd05d3-2604-4a2c-bee9-896cfda9b9d2	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:19.895484+00
fdb3bae3-860d-4035-ba51-67d3a8b67332	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:20.938425+00
5a1bfa07-4d59-4ee3-8929-82fbdc3699ca	06ad4757-c916-459c-a96b-0ecb80a6980a	2026-10-12 09:19:20.962785+00
73a1490d-91f3-4387-8087-9d0d06c5d804	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:37.367434+00
ec962e48-0492-42f8-8beb-9a2d796393c5	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:50.186991+00
d07eca31-c81f-4af4-9f78-ddb5412afb47	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:50.703291+00
1dad9573-88da-47f1-a664-24d0c0873e94	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:50.70381+00
b27d3d50-e1a1-42b9-bbfb-26c591e01e3b	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:50.704415+00
cf66fc96-6057-47ca-b3f6-90b5d754025c	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:52.912173+00
73dd12d5-bfbc-4ee8-b0c5-6c4ed60bf593	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:53.009304+00
3aaa734e-6b1e-4653-9efc-444aa741c154	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:53.3903+00
1801437c-4e12-4d67-ace3-666a3929b764	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:56.055601+00
e25d8e08-aebb-4b5c-b8ba-f27095a9e790	6b25a481-b5c5-4f33-b395-be02d578edc1	2026-10-12 09:19:56.075898+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
35a0d7e0-6ffb-4fd4-a63d-d10f0624ecc5	99b0e710-6ad5-4465-8b19-0d4f93923ae0	8e932a13-e4ee-4d56-9017-26b8f861b413	ADMINISTRATOR	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
4d341de5-8802-456d-8600-a296736465ec	99b0e710-6ad5-4465-8b19-0d4f93923ae0	cbe72b1c-efcc-40c7-912b-861f781f5185	PRODUCT_OWNER	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
ec76c805-7c8d-46c8-8714-b19b8c147b6e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	2104170e-c421-4b32-ab97-2c9f9425af53	TESTER	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
cf149243-a556-4b78-9902-52c771ed22d8	99b0e710-6ad5-4465-8b19-0d4f93923ae0	61044b7f-ede3-4da5-8a52-31b4cdb66421	TESTER	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
5532a4c1-68aa-46c1-ba17-95750b940b3d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	cc161703-e71a-42e2-b923-cd85936544b5	DEVELOPER	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
3edab78d-93db-4e98-84c9-2bc57940a823	99b0e710-6ad5-4465-8b19-0d4f93923ae0	d13bb598-820d-4471-99b2-b96b6b7a2e30	VIEWER	2026-10-12 09:18:30.182964+00	admin	2026-10-12 09:18:30.182964+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
99b0e710-6ad5-4465-8b19-0d4f93923ae0	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 09:18:30.058033+00	admin	2026-10-12 09:18:30.058033+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
29fcc520-e884-4a36-9c5b-5b922c457976	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 09:18:51.208131+00	po	2026-10-12 09:18:52.766351+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5d939363-3fc7-418d-9cb5-0ee9858a9ea5	99b0e710-6ad5-4465-8b19-0d4f93923ae0	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 09:19:25.228522+00	po	2026-10-12 09:19:25.228522+00	po	0
2d144358-541b-46a2-97dd-3f4fde0f61dd	99b0e710-6ad5-4465-8b19-0d4f93923ae0	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 09:19:25.236907+00	po	2026-10-12 09:19:25.236907+00	po	0
d5b5ac40-d1b7-4329-9675-b8c4cd987686	99b0e710-6ad5-4465-8b19-0d4f93923ae0	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 09:20:15.987495+00	po	2026-10-12 09:20:15.987495+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
abf2f450-69e3-4261-a85d-4467af9c220e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T09:19:25.270197800Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 09:19:25.30197+00	clôture du sprint	2026-10-12 09:19:25.300971+00	po	2026-10-12 09:19:25.302971+00	po	1
1d3a6e2a-a675-4cd3-a36c-ca6125ce4198	99b0e710-6ad5-4465-8b19-0d4f93923ae0	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T09:20:12.571897400Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 0, "averageMinutes": 0.0, "defectsPerHour": 1800.0, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 09:20:14.065339+00	f	\N	\N	2026-10-12 09:20:12.585335+00	po	2026-10-12 09:20:14.065881+00	po	2
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
677bd737-fd38-4616-9b83-a549a4559e26	9ec0fc09-c059-4328-8785-7e6a102b198f	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.359122+00	po	2026-10-12 09:18:36.359122+00	po	0
3b5f8266-2570-4526-96de-4b3e079451b6	e9c8013a-4e21-4183-a570-30dc2fbc4448	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.396924+00	po	2026-10-12 09:18:36.396924+00	po	0
24c76751-e7c6-41a7-aa8f-b728bb47341e	e7f1af81-8599-4ebe-901a-9f534713c04e	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.430459+00	po	2026-10-12 09:18:36.430459+00	po	0
b3b256d4-4b43-425d-b67a-b9fd65072599	77a3afae-fa04-4648-8dc5-19240722030e	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.466927+00	po	2026-10-12 09:18:36.466927+00	po	0
6e7dd426-1822-42f3-b959-dc577fcd19d8	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.509519+00	po	2026-10-12 09:18:36.509519+00	po	0
b67373ab-5a9d-4d3b-98ec-6cea04c8fb15	1ea35027-3e83-490c-a3bc-d5cfd89339b0	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.548554+00	po	2026-10-12 09:18:36.548554+00	po	0
94ce92f1-b6af-4c57-93c0-d661405756ba	7829e77d-535f-44eb-90a9-4a1de99d13d6	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:36.584137+00	po	2026-10-12 09:18:36.584137+00	po	0
65ea94bb-b1d3-4be3-bbd7-40cc19906c08	f541393a-f7bc-4bfe-a708-897b922fec4e	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 09:18:37.579953+00	po	2026-10-12 09:18:37.579953+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
05faabd3-bc5a-4153-8fda-63ee57eacea0	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 09:18:32.945218+00	po	2026-10-12 09:18:32.945218+00	po	0
5a853996-ae82-4f4f-b48c-164f8f403d92	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 09:18:33.053964+00	po	2026-10-12 09:18:33.053964+00	po	0
d50149bc-44e4-437c-9026-b2742c3e730d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 09:18:33.230648+00	po	2026-10-12 09:18:33.230648+00	po	0
4b5f6e52-19aa-4dec-9cff-4c5af17d839c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 09:18:33.376362+00	po	2026-10-12 09:18:33.376362+00	po	0
e9c8013a-4e21-4183-a570-30dc2fbc4448	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	5a853996-ae82-4f4f-b48c-164f8f403d92	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 09:18:33.193709+00	po	2026-10-12 09:19:22.972334+00	po	3
e7f1af81-8599-4ebe-901a-9f534713c04e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	d50149bc-44e4-437c-9026-b2742c3e730d	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 09:18:33.265788+00	po	2026-10-12 09:19:23.041108+00	po	3
7829e77d-535f-44eb-90a9-4a1de99d13d6	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	4b5f6e52-19aa-4dec-9cff-4c5af17d839c	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 09:18:33.445363+00	po	2026-10-12 09:19:25.978718+00	po	2
dd103bcf-8759-482a-9f1f-af52d5b91f52	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	1c74f693-3064-466a-a01e-a3b1a0582695	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 09:18:33.548677+00	po	2026-10-12 09:18:33.548677+00	po	0
c8055570-8e72-4102-9773-4e4f8ec6c4db	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	1c74f693-3064-466a-a01e-a3b1a0582695	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 09:18:35.261132+00	po	2026-10-12 09:18:35.261132+00	po	0
394bda32-06f8-4f44-a2f5-2232e4bfdf48	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 09:18:35.501586+00	po	2026-10-12 09:18:35.501586+00	po	0
1ea35027-3e83-490c-a3bc-d5cfd89339b0	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	4b5f6e52-19aa-4dec-9cff-4c5af17d839c	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 09:18:33.408458+00	po	2026-10-12 09:19:25.978718+00	po	2
9ec0fc09-c059-4328-8785-7e6a102b198f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	5a853996-ae82-4f4f-b48c-164f8f403d92	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 09:18:33.140993+00	po	2026-10-12 09:19:22.9096+00	po	3
f541393a-f7bc-4bfe-a708-897b922fec4e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	4b5f6e52-19aa-4dec-9cff-4c5af17d839c	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 09:18:33.483958+00	po	2026-10-12 09:19:25.978718+00	po	2
1c74f693-3064-466a-a01e-a3b1a0582695	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 09:18:33.516177+00	po	2026-10-12 09:18:33.516177+00	po	0
eea3d565-3bea-4d1f-a608-cfa70a603611	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	05faabd3-bc5a-4153-8fda-63ee57eacea0	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 09:18:35.534513+00	po	2026-10-12 09:18:35.534513+00	po	0
77a3afae-fa04-4648-8dc5-19240722030e	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	d50149bc-44e4-437c-9026-b2742c3e730d	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 09:18:33.307676+00	po	2026-10-12 09:19:23.089581+00	po	3
052f782f-e0c0-49e9-85eb-ffb6d1fb5602	99b0e710-6ad5-4465-8b19-0d4f93923ae0	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	d50149bc-44e4-437c-9026-b2742c3e730d	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 09:18:33.342585+00	po	2026-10-12 09:20:08.144925+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
708973c7-3035-4ad9-be9f-196892997e6b	06ad4757-c916-459c-a96b-0ecb80a6980a	e921dcf1-b140-4e8b-b9ff-9cfabcb576b8	log-TC-7.txt	text/plain	SYSTEM_TRACE	487	2026-10-12 09:19:19.341285+00	anonymousUser	2026-10-12 09:19:19.341285+00	anonymousUser	0
8f862978-89da-4217-9a93-8ec7c1275889	06ad4757-c916-459c-a96b-0ecb80a6980a	08d88a3e-952e-475c-ae0d-a7dbe501f76a	log-TC-3.txt	text/plain	SYSTEM_TRACE	433	2026-10-12 09:19:19.745367+00	anonymousUser	2026-10-12 09:19:19.745367+00	anonymousUser	0
c2ffe779-3d52-487d-ac2c-9b2e3cf7f37e	06ad4757-c916-459c-a96b-0ecb80a6980a	2301e7c8-e6c9-43c6-8204-9e2d38373483	log-TC-4.txt	text/plain	SYSTEM_TRACE	393	2026-10-12 09:19:19.898646+00	anonymousUser	2026-10-12 09:19:19.898646+00	anonymousUser	0
9d704caf-faec-4a79-a36d-8458976eeb5d	06ad4757-c916-459c-a96b-0ecb80a6980a	66fd83ba-a918-4476-8372-a861af094221	log-TC-5.txt	text/plain	SYSTEM_TRACE	391	2026-10-12 09:19:19.898646+00	anonymousUser	2026-10-12 09:19:19.898646+00	anonymousUser	0
1620b98d-2afe-475a-a533-d83524501e3b	06ad4757-c916-459c-a96b-0ecb80a6980a	6e7ec738-8636-4a1d-85e4-fbed99ddb1e5	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 09:19:20.941561+00	anonymousUser	2026-10-12 09:19:20.941561+00	anonymousUser	0
fa3c806a-af91-4e7b-9d1c-71a45e640843	06ad4757-c916-459c-a96b-0ecb80a6980a	\N	system.log	text/plain	SYSTEM_TRACE	4728	2026-10-12 09:19:20.964351+00	anonymousUser	2026-10-12 09:19:20.964351+00	anonymousUser	0
9f4939b9-cddb-49b4-bab6-023f2b1d31bc	06ad4757-c916-459c-a96b-0ecb80a6980a	\N	junit.xml	application/xml	JUNIT	1185	2026-10-12 09:19:20.966968+00	anonymousUser	2026-10-12 09:19:20.966968+00	anonymousUser	0
6da4207b-44f9-4448-846c-82d70f49533f	06ad4757-c916-459c-a96b-0ecb80a6980a	\N	report.json	application/json	REPORT	484	2026-10-12 09:19:20.969171+00	anonymousUser	2026-10-12 09:19:20.969171+00	anonymousUser	0
519f8e58-4e63-450a-a784-9584fcb40d82	6b25a481-b5c5-4f33-b395-be02d578edc1	9c89a7b8-221c-4b9b-a95a-f55956a521c9	log-TC-8.txt	text/plain	SYSTEM_TRACE	453	2026-10-12 09:19:52.915287+00	anonymousUser	2026-10-12 09:19:52.915287+00	anonymousUser	0
a8a394b8-6a1d-46d4-9d89-7d38d0498c06	6b25a481-b5c5-4f33-b395-be02d578edc1	13704fa8-3ed0-4ced-8504-d7ef24af2426	log-TC-9.txt	text/plain	SYSTEM_TRACE	369	2026-10-12 09:19:53.01188+00	anonymousUser	2026-10-12 09:19:53.01188+00	anonymousUser	0
a5952c2c-40d7-4da9-8b01-1fd15870c36c	6b25a481-b5c5-4f33-b395-be02d578edc1	8913cdbb-4691-4b1a-81ef-48fff569dd53	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 09:19:53.392375+00	anonymousUser	2026-10-12 09:19:53.392375+00	anonymousUser	0
b1c82370-915f-459d-97af-19deb74e9bd7	6b25a481-b5c5-4f33-b395-be02d578edc1	65e6ed6a-058d-4c81-b611-1ddc79203c9b	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 09:19:56.058165+00	anonymousUser	2026-10-12 09:19:56.058165+00	anonymousUser	0
d59b9c68-1fa5-4457-a80e-50683522a02e	6b25a481-b5c5-4f33-b395-be02d578edc1	65e6ed6a-058d-4c81-b611-1ddc79203c9b	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 09:19:56.060258+00	anonymousUser	2026-10-12 09:19:56.060258+00	anonymousUser	0
8cec2417-2685-4b2e-ad6f-51ab87ef527e	6b25a481-b5c5-4f33-b395-be02d578edc1	\N	system.log	text/plain	SYSTEM_TRACE	8588	2026-10-12 09:19:56.077483+00	anonymousUser	2026-10-12 09:19:56.077483+00	anonymousUser	0
dffb243c-79f4-4d66-a8bf-a1ef6c135353	6b25a481-b5c5-4f33-b395-be02d578edc1	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 09:19:56.079032+00	anonymousUser	2026-10-12 09:19:56.079032+00	anonymousUser	0
e71116a4-00bd-4578-8da8-b52150987b28	6b25a481-b5c5-4f33-b395-be02d578edc1	\N	report.json	application/json	REPORT	475	2026-10-12 09:19:56.080036+00	anonymousUser	2026-10-12 09:19:56.080036+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
56680ee8-689b-49d1-ae55-0d363ccbf4bc	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	NOTE	0	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 09:19:32.556674+00	\N	2026-10-12 09:19:32.558323+00	qa1	2026-10-12 09:19:32.558323+00	qa1	0
be1f7eb4-ee50-444c-ae0e-ccbfaf17cc87	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	NOTE	0	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 09:19:32.610069+00	\N	2026-10-12 09:19:32.610069+00	qa1	2026-10-12 09:19:32.610069+00	qa1	0
92d62743-668d-430a-8ee7-f52f805f3245	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	QUESTION	0	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 09:19:32.731978+00	\N	2026-10-12 09:19:32.731978+00	qa1	2026-10-12 09:19:32.731978+00	qa1	0
08da4057-4757-47cd-beae-ceb72e893462	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	IDEA	0	Afficher le total du panier avant le checkout	2026-10-12 09:19:32.804531+00	\N	2026-10-12 09:19:32.805054+00	qa1	2026-10-12 09:19:32.805054+00	qa1	0
965d9125-3693-4663-b8a6-7f4e523c4de9	6a4a6dd7-ae59-4612-a7ce-128341cb12e8	BUG	0	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 09:19:32.669969+00	55ecfce4-bec6-4ba1-a294-cfa3e1a54ece	2026-10-12 09:19:32.669969+00	qa1	2026-10-12 09:19:33.391252+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1a838e9f-fa55-4852-90a8-cd7129644c3e	c484721e-147f-40bd-8dbe-83f842162033	9ec0fc09-c059-4328-8785-7e6a102b198f	1	3	DONE	2026-10-12 09:18:51.945267+00	po	2026-10-12 09:19:25.230068+00	po	1
2bc6e722-a389-45ce-b248-1558c9e7369a	c484721e-147f-40bd-8dbe-83f842162033	e9c8013a-4e21-4183-a570-30dc2fbc4448	2	2	DONE	2026-10-12 09:18:52.011645+00	po	2026-10-12 09:19:25.230068+00	po	1
b459c6e6-47c3-4977-9879-bb8b40bb89b3	c484721e-147f-40bd-8dbe-83f842162033	e7f1af81-8599-4ebe-901a-9f534713c04e	3	3	DONE	2026-10-12 09:18:52.082732+00	po	2026-10-12 09:19:25.230068+00	po	1
1219bc27-df10-46c2-b31c-059e2b7d2446	c484721e-147f-40bd-8dbe-83f842162033	77a3afae-fa04-4648-8dc5-19240722030e	4	2	DONE	2026-10-12 09:18:52.154996+00	po	2026-10-12 09:19:25.230068+00	po	1
49c35b26-426f-4b5e-9ce7-1d52a4f49874	c484721e-147f-40bd-8dbe-83f842162033	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	5	2	DONE	2026-10-12 09:18:52.217311+00	po	2026-10-12 09:19:25.230068+00	po	1
73487b16-d8c6-44e7-9d40-19b9423905f6	b08ca36a-27c6-4fcb-a762-f82dd30852e8	1ea35027-3e83-490c-a3bc-d5cfd89339b0	1	3	PLANNED	2026-10-12 09:19:25.930895+00	po	2026-10-12 09:19:25.930895+00	po	0
e275a105-1cf9-407e-abd2-c3af2c65023d	b08ca36a-27c6-4fcb-a762-f82dd30852e8	7829e77d-535f-44eb-90a9-4a1de99d13d6	2	3	PLANNED	2026-10-12 09:19:25.930895+00	po	2026-10-12 09:19:25.930895+00	po	0
4474508d-a86f-4d55-bd27-06e1d8950494	b08ca36a-27c6-4fcb-a762-f82dd30852e8	f541393a-f7bc-4bfe-a708-897b922fec4e	3	2	PLANNED	2026-10-12 09:19:25.930895+00	po	2026-10-12 09:19:25.930895+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c484721e-147f-40bd-8dbe-83f842162033	99b0e710-6ad5-4465-8b19-0d4f93923ae0	29fcc520-e884-4a36-9c5b-5b922c457976	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 09:18:51.23716+00	po	2026-10-12 09:19:25.229552+00	po	2
b08ca36a-27c6-4fcb-a762-f82dd30852e8	99b0e710-6ad5-4465-8b19-0d4f93923ae0	29fcc520-e884-4a36-9c5b-5b922c457976	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 09:18:51.278634+00	po	2026-10-12 09:19:25.978718+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
8d884f3f-8eda-45b6-a311-6eea66a11cef	308b25df-8286-4f08-b924-b5a07712e04c	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 09:18:55.511728+00	qa1	2026-10-12 09:18:55.645125+00	qa1	1	\N
566fec56-8302-4b6a-8029-995e196ea90e	308b25df-8286-4f08-b924-b5a07712e04c	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 09:18:55.511728+00	qa1	2026-10-12 09:18:56.204245+00	qa1	1	\N
3460e64c-dda1-4983-9cdd-3a489b5af0b9	b52a3d68-f75e-4b54-ac7b-9161c07b4709	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 09:18:56.264815+00	qa1	2026-10-12 09:18:56.286272+00	qa1	1	\N
cbba4a20-4e48-4054-9ce3-f87aba1776fc	b52a3d68-f75e-4b54-ac7b-9161c07b4709	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 09:18:56.264815+00	qa1	2026-10-12 09:18:56.304071+00	qa1	1	\N
39af4264-b70c-49a7-90f6-0dc5c74d9fd6	37cd8ca9-d6ac-47e4-9562-97a7fcd8f4a4	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 09:18:56.323385+00	qa1	2026-10-12 09:18:56.340032+00	qa1	1	\N
27eb186d-122a-4e8e-be27-31afc2fbecaf	37cd8ca9-d6ac-47e4-9562-97a7fcd8f4a4	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 09:18:56.323385+00	qa1	2026-10-12 09:18:56.359176+00	qa1	1	\N
2e9c350b-a1d5-4b6c-9ae3-8d454adc9b28	4c6434c0-0b1c-441d-a6ac-a34e3c733080	1	Se connecter avec problem_user	Le catalogue s’affiche	\N	PASSED	\N	2026-10-12 09:19:27.948866+00	qa2	2026-10-12 09:19:28.069051+00	qa2	1	\N
3baadd3e-9c8a-4395-9fff-1ffc321881ad	4c6434c0-0b1c-441d-a6ac-a34e3c733080	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 09:19:27.948866+00	qa2	2026-10-12 09:19:28.186498+00	qa2	1	\N
26f0059c-5530-4ba7-bd4c-69397f9f8c9b	4c6434c0-0b1c-441d-a6ac-a34e3c733080	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 09:19:27.948866+00	qa2	2026-10-12 09:19:28.300546+00	qa2	1	\N
edc2cea4-dfd7-4312-ad59-991807e922f9	4c6434c0-0b1c-441d-a6ac-a34e3c733080	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 09:19:27.948866+00	qa2	2026-10-12 09:19:28.583121+00	qa2	1	\N
06a81dab-0c55-4bb3-9d82-21a4c0703e03	221e0863-7fb5-4b25-a950-d787368921d0	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 09:19:30.521645+00	qa1	2026-10-12 09:19:30.654604+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
038b8068-82f8-4c1b-984d-17ce8cb032cf	221e0863-7fb5-4b25-a950-d787368921d0	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 09:19:30.521645+00	qa1	2026-10-12 09:19:31.217193+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
a3eaea78-7bed-4cd5-9a86-d2852d31e737	221e0863-7fb5-4b25-a950-d787368921d0	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 09:19:30.521645+00	qa1	2026-10-12 09:19:31.284632+00	qa1	1	\N
d9c352f5-6b32-4556-b08d-3b0aa3aa2824	221e0863-7fb5-4b25-a950-d787368921d0	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 09:19:30.521645+00	qa1	2026-10-12 09:19:31.350962+00	qa1	1	\N
7a4cf28a-c370-4e12-835b-32ea884e5e64	5966dda8-77c6-4364-8a29-cdcdbc8cacf5	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 09:19:31.398434+00	qa1	2026-10-12 09:19:31.414014+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
c0883b4c-2376-48ef-ba19-2353d764f0a2	5966dda8-77c6-4364-8a29-cdcdbc8cacf5	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 09:19:31.398434+00	qa1	2026-10-12 09:19:31.428524+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration
048a7413-fb03-4253-85d2-506658067e7d	5966dda8-77c6-4364-8a29-cdcdbc8cacf5	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 09:19:31.398434+00	qa1	2026-10-12 09:19:31.442487+00	qa1	1	\N
f600021c-97c5-439d-9448-0e4e33ffc55b	5966dda8-77c6-4364-8a29-cdcdbc8cacf5	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 09:19:31.398434+00	qa1	2026-10-12 09:19:31.456058+00	qa1	1	\N
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
59b56978-7819-42b6-a9fd-e8b92f119e19	4024d965-5801-4535-8cb6-23688dca7a13	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 09:18:43.851204+00	qa1	2026-10-12 09:18:43.851204+00	qa1	0
f0cf5a85-c732-4b69-bfe5-3b2e221500b9	3c23dff1-b246-4196-a751-df329fc0dfe6	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. Se connecter avec ${utilisateur} → Le catalogue s’affiche", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": ["Compte du défaut : [{utilisateur=problem_user}]"], "priority": "MUST", "objective": null, "parameters": ["utilisateur = problem_user"], "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 09:18:43.941326+00	qa1	2026-10-12 09:18:43.941326+00	qa1	0
3495591a-c3c7-4396-98de-b72d6ec41802	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "installation-hors-docker", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:44.017493+00	dev	2026-10-12 09:18:44.017493+00	dev	0
756d5b9a-8a6a-47f5-abdd-5bf7f851c936	7698b215-f69e-49cd-b7d1-c40c96aa8caf	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:44.095327+00	dev	2026-10-12 09:18:44.095327+00	dev	0
682fd91e-14f5-416c-a5f0-694fb36a73c5	b4139dae-2333-4955-86a1-1e6c1002e9d4	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:44.160349+00	dev	2026-10-12 09:18:44.160349+00	dev	0
c5dc1362-1e27-4362-9af7-8b810f48a6d4	a8326366-813a-4983-8136-27ea126b14a3	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "installation-hors-docker", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:44.213271+00	dev	2026-10-12 09:18:44.213271+00	dev	0
9b7108d4-0bf1-476c-89e1-d996c75f995a	d0883f42-8918-43ce-acf7-10d7c0326acd	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "installation-hors-docker", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:44.281083+00	dev	2026-10-12 09:18:44.281083+00	dev	0
f1d0d3a4-cd65-4c76-ac15-456614d5f051	bc3979be-122d-4f0f-b8ed-78698b85905c	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:45.637403+00	qa1	2026-10-12 09:18:45.637403+00	qa1	0
acbce415-8d22-4e1b-a258-788700b89277	bc3979be-122d-4f0f-b8ed-78698b85905c	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "installation-hors-docker", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:45.76951+00	qa1	2026-10-12 09:18:45.76951+00	qa1	0
0939341c-7c83-456d-80ea-782998341a03	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:46.664875+00	dev	2026-10-12 09:18:46.664875+00	dev	0
14949725-fd63-478a-8986-fcc2610ac92d	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 09:18:46.874842+00	qa1	2026-10-12 09:18:46.874842+00	qa1	0
9e04bdb9-f92e-442f-b4e2-3d1d99872063	e05c1346-01ec-449f-8dca-9b8460638a0b	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "installation-hors-docker", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:46.737718+00	dev	2026-10-12 09:18:46.737718+00	dev	0
329e7bb6-77ea-4e3c-a7d4-d40a7ac2002b	e80123ec-b623-49f6-8574-a3a732204856	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "installation-hors-docker", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 09:18:46.809898+00	dev	2026-10-12 09:18:46.809898+00	dev	0
3adec9f5-c359-4eec-8c5c-29740d13f92f	cf50092f-9431-4b3a-bef2-3712c4c44c77	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 {resultat_attendu=Le catalogue « Products » s’affiche, utilisateur=standard_user}", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 09:18:46.940676+00	qa1	2026-10-12 09:18:46.940676+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
4024d965-5801-4535-8cb6-23688dca7a13	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 09:18:43.844044+00	qa1	2026-10-12 09:18:43.916871+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}]}]	f
3c23dff1-b246-4196-a751-df329fc0dfe6	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 09:18:43.940296+00	qa1	2026-10-12 09:18:43.982504+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "problem_user"}]	[{"name": "Compte du défaut", "rows": [{"utilisateur": "problem_user"}]}]	f
fb411738-e440-4ef0-a9cc-b2a1a5e046a0	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 09:18:44.015367+00	dev	2026-10-12 09:18:44.061763+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}]}]	f
7698b215-f69e-49cd-b7d1-c40c96aa8caf	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 09:18:44.094743+00	dev	2026-10-12 09:18:44.131539+00	qa1	1	[]	[]	f
b4139dae-2333-4955-86a1-1e6c1002e9d4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 09:18:44.159825+00	dev	2026-10-12 09:18:44.19002+00	qa1	1	[]	[]	f
d0883f42-8918-43ce-acf7-10d7c0326acd	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 09:18:44.280547+00	dev	2026-10-12 09:18:44.32505+00	qa1	1	[]	[]	f
e05c1346-01ec-449f-8dca-9b8460638a0b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 09:18:46.737065+00	dev	2026-10-12 09:18:46.778452+00	qa1	1	[]	[]	f
bc3979be-122d-4f0f-b8ed-78698b85905c	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 09:18:45.636563+00	qa1	2026-10-12 09:18:45.778288+00	qa1	2	[]	[]	f
f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 09:18:46.664875+00	dev	2026-10-12 09:18:46.705022+00	qa1	1	[]	[]	f
e80123ec-b623-49f6-8574-a3a732204856	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 09:18:46.809371+00	dev	2026-10-12 09:18:46.850347+00	qa1	1	[]	[]	f
6d991976-d642-4251-ba7f-1b2ab1ecaa8a	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 09:18:46.873839+00	qa1	2026-10-12 09:18:46.914529+00	qa1	1	[]	[]	f
cf50092f-9431-4b3a-bef2-3712c4c44c77	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 09:18:46.939646+00	qa1	2026-10-12 09:18:46.976314+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}]}]	f
a8326366-813a-4983-8136-27ea126b14a3	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 09:18:44.212756+00	dev	2026-10-12 09:20:08.153014+00	po	2	[]	[]	f
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
00463bdf-b7a9-4d0a-a125-091743233dff	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	4024d965-5801-4535-8cb6-23688dca7a13	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	VERIFIES	MANUAL	2026-10-12 09:18:43.861006+00	qa1	2026-10-12 09:18:43.861006+00	qa1	0	\N
e7dc344f-5bd4-4815-aae6-0dd4045dff5b	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	4024d965-5801-4535-8cb6-23688dca7a13	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	VERIFIES	MANUAL	2026-10-12 09:18:43.861717+00	qa1	2026-10-12 09:18:43.861717+00	qa1	0	\N
2b91a4cf-23e3-46a7-8f41-eec4cb21fb01	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	3c23dff1-b246-4196-a751-df329fc0dfe6	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	PARTIALLY_VERIFIES	MANUAL	2026-10-12 09:18:43.946014+00	qa1	2026-10-12 09:18:43.946014+00	qa1	0	\N
da1ec66b-1233-4a9c-95d5-dd2a36dde7cf	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	3c23dff1-b246-4196-a751-df329fc0dfe6	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	VERIFIES	MANUAL	2026-10-12 09:18:43.946014+00	qa1	2026-10-12 09:18:43.946014+00	qa1	0	\N
93426c7e-b6dd-4acc-ad09-8a9b4acbcc5f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	REQUIREMENT	9ec0fc09-c059-4328-8785-7e6a102b198f	VERIFIES	MANUAL	2026-10-12 09:18:44.02179+00	dev	2026-10-12 09:18:44.02179+00	dev	0	\N
684a09d7-5b3b-43ff-be7a-9579334fec30	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	fb411738-e440-4ef0-a9cc-b2a1a5e046a0	REQUIREMENT	e9c8013a-4e21-4183-a570-30dc2fbc4448	VERIFIES	MANUAL	2026-10-12 09:18:44.02179+00	dev	2026-10-12 09:18:44.02179+00	dev	0	\N
997bf838-dc99-4a10-815d-16cd1be082c4	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	7698b215-f69e-49cd-b7d1-c40c96aa8caf	REQUIREMENT	e7f1af81-8599-4ebe-901a-9f534713c04e	VERIFIES	MANUAL	2026-10-12 09:18:44.09823+00	dev	2026-10-12 09:18:44.09823+00	dev	0	\N
97d0fa89-5d32-42c1-873f-fb618b3dbfc9	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	b4139dae-2333-4955-86a1-1e6c1002e9d4	REQUIREMENT	77a3afae-fa04-4648-8dc5-19240722030e	VERIFIES	MANUAL	2026-10-12 09:18:44.162909+00	dev	2026-10-12 09:18:44.162909+00	dev	0	\N
3b9985cb-7717-4571-b912-61f3df0124b2	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	d0883f42-8918-43ce-acf7-10d7c0326acd	REQUIREMENT	eea3d565-3bea-4d1f-a608-cfa70a603611	VERIFIES	MANUAL	2026-10-12 09:18:44.28684+00	dev	2026-10-12 09:18:44.28684+00	dev	0	\N
41850323-ed85-4c87-a1c9-05470d0d3e28	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	bc3979be-122d-4f0f-b8ed-78698b85905c	REQUIREMENT	1ea35027-3e83-490c-a3bc-d5cfd89339b0	VERIFIES	GHERKIN_TAG	2026-10-12 09:18:45.641587+00	qa1	2026-10-12 09:18:45.641587+00	qa1	0	\N
d17ec5cd-5e26-41c7-87ac-2e1de4f82d58	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	bc3979be-122d-4f0f-b8ed-78698b85905c	ACCEPTANCE_CRITERION	f1bf3e37-163f-4d50-8548-db538bd55294	VERIFIES	GHERKIN_TAG	2026-10-12 09:18:45.64942+00	qa1	2026-10-12 09:18:45.64942+00	qa1	0	\N
2154654a-172e-4e70-808a-48fb2cd82593	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	f7d4f54e-47ab-4372-b03c-5f2512d8b4c9	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	VERIFIES	MANUAL	2026-10-12 09:18:46.667538+00	dev	2026-10-12 09:18:46.667538+00	dev	0	\N
59e9479c-e237-40db-8911-bc69f9046b19	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e05c1346-01ec-449f-8dca-9b8460638a0b	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	VERIFIES	MANUAL	2026-10-12 09:18:46.740725+00	dev	2026-10-12 09:18:46.740725+00	dev	0	\N
db2000a5-d6f8-4a34-b1b8-4f8267c9f697	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	e80123ec-b623-49f6-8574-a3a732204856	REQUIREMENT	394bda32-06f8-4f44-a2f5-2232e4bfdf48	VERIFIES	MANUAL	2026-10-12 09:18:46.812129+00	dev	2026-10-12 09:18:46.812129+00	dev	0	\N
5209b94a-5fd9-4479-897a-a1c0387fdb5f	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	VERIFIES	MANUAL	2026-10-12 09:18:46.87939+00	qa1	2026-10-12 09:18:46.87939+00	qa1	0	\N
6b1718e1-6f2a-4c5f-9afc-cf6624b838e3	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	6d991976-d642-4251-ba7f-1b2ab1ecaa8a	REQUIREMENT	f541393a-f7bc-4bfe-a708-897b922fec4e	VERIFIES	MANUAL	2026-10-12 09:18:46.87939+00	qa1	2026-10-12 09:18:46.87939+00	qa1	0	\N
8a2cb060-2099-474f-8afe-7afe8b0b256d	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	cf50092f-9431-4b3a-bef2-3712c4c44c77	REQUIREMENT	7829e77d-535f-44eb-90a9-4a1de99d13d6	VERIFIES	MANUAL	2026-10-12 09:18:46.943508+00	qa1	2026-10-12 09:18:46.943508+00	qa1	0	\N
481b7d0a-7619-46ca-84ae-03bff434a453	99b0e710-6ad5-4465-8b19-0d4f93923ae0	TEST_CASE	a8326366-813a-4983-8136-27ea126b14a3	REQUIREMENT	052f782f-e0c0-49e9-85eb-ffb6d1fb5602	VERIFIES	MANUAL	2026-10-12 09:18:44.215836+00	dev	2026-10-12 09:20:08.79635+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
8e932a13-e4ee-4d56-9017-26b8f861b413	admin	admin@traceagile.local	Administrateur	$2a$12$25biez5ZhqzlEdYt.8gc.OWLofqtISZF0XKiaQ8tYiApe53HF6tm2	t	t	2026-10-12 09:18:20.300495+00	system	2026-10-12 09:18:20.300495+00	system	0
cbe72b1c-efcc-40c7-912b-861f781f5185	po	po@traceagile.demo	Paula Owner	$2a$12$21TwVWDNTL1FFUoZiOSbuuqjcEYXEVXHNSVHx/gxkjHgkbEkdbLPC	t	f	2026-10-12 09:18:28.213959+00	admin	2026-10-12 09:18:28.213959+00	admin	0
2104170e-c421-4b32-ab97-2c9f9425af53	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$ukbL64tyccK6Pcam82xexuFWSRxgmbKyFTYtscH24imICEr7aikTi	t	f	2026-10-12 09:18:28.401846+00	admin	2026-10-12 09:18:28.401846+00	admin	0
61044b7f-ede3-4da5-8a52-31b4cdb66421	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$Pn255uTBq3mhr8Qs2nIiuOGosd3HnyXawhSJcz/ZWwky1/X6/rrSS	t	f	2026-10-12 09:18:28.590664+00	admin	2026-10-12 09:18:28.590664+00	admin	0
cc161703-e71a-42e2-b923-cd85936544b5	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$tjx0bepFSj/MkYak2zyRP.Ty3pTI0tC9Crl4SONs8MajkpLE7OWNS	t	f	2026-10-12 09:18:28.779094+00	admin	2026-10-12 09:18:28.779094+00	admin	0
d13bb598-820d-4471-99b2-b96b6b7a2e30	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$Wr0ZCY8P3fTNs.wO9KnqF.0DeTtJuVBAYka6Y7tkupypzL.XwKLlC	t	f	2026-10-12 09:18:28.965991+00	admin	2026-10-12 09:18:28.965991+00	admin	0
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


