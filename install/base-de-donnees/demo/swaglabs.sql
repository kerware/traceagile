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
da3e647e-b90d-40c0-8c42-528523d9a1fc	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	1	GHERKIN	Scénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche	TO_VERIFY	2026-10-12 12:44:51.983869+00	po	2026-10-12 12:44:51.983869+00	po	0
e3a1c17a-02dc-4d19-a49c-c8beb3a1a97a	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	2	TEXT	Le compte problem_user accède lui aussi au catalogue.	TO_VERIFY	2026-10-12 12:44:51.983869+00	po	2026-10-12 12:44:51.983869+00	po	0
e2b039a9-12f1-4c98-8e7a-a238fffddd7c	213f7e56-e2ec-4042-9a29-0ed2bb157e33	1	TEXT	Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	TO_VERIFY	2026-10-12 12:44:52.028792+00	po	2026-10-12 12:44:52.028792+00	po	0
4384a240-dfe9-445a-ab16-e83abe773898	702601a5-33df-4395-b47c-e3ca85e96993	1	TEXT	Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	TO_VERIFY	2026-10-12 12:44:52.108765+00	po	2026-10-12 12:44:52.108765+00	po	0
ddac505d-c5e8-4a6b-a462-952e787be28a	1815821a-5f7e-4621-a8f0-00996df35ac7	1	TEXT	Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	TO_VERIFY	2026-10-12 12:44:52.154272+00	po	2026-10-12 12:44:52.154272+00	po	0
bf0de724-ea52-42de-8a70-29392bfaff37	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	1	TEXT	La fiche affiche le nom, la description, le prix et un bouton « Back to products ».	TO_VERIFY	2026-10-12 12:44:52.195915+00	po	2026-10-12 12:44:52.195915+00	po	0
4ad68602-a82b-408b-b818-e3e4b90c5985	b68ddd88-cf31-4488-8ede-74b4d54de51d	1	GHERKIN	Scénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	TO_VERIFY	2026-10-12 12:44:52.273456+00	po	2026-10-12 12:44:52.273456+00	po	0
4152da4d-f509-423a-8ed1-265cf81da5de	b68ddd88-cf31-4488-8ede-74b4d54de51d	2	TEXT	Le bouton « Add to cart » devient « Remove ».	TO_VERIFY	2026-10-12 12:44:52.273456+00	po	2026-10-12 12:44:52.273456+00	po	0
069574c7-1aa8-497c-8ada-dd40086fcfe5	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	1	TEXT	Le panier liste chaque produit avec sa quantité, sa description et son prix.	TO_VERIFY	2026-10-12 12:44:52.315686+00	po	2026-10-12 12:44:52.315686+00	po	0
050eaab1-8547-4372-8f66-505edce9a4a1	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	2	TEXT	« Continue Shopping » ramène au catalogue sans vider le panier.	TO_VERIFY	2026-10-12 12:44:52.316192+00	po	2026-10-12 12:44:52.316192+00	po	0
56c1eccc-d704-4616-9b50-e34c94bdcdb2	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	1	TEXT	« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	TO_VERIFY	2026-10-12 12:44:52.36144+00	po	2026-10-12 12:44:52.36144+00	po	0
f1489de4-8112-499d-84bf-7f52c1480295	ad2028b8-e429-450d-aa56-ca0831aedee5	1	TEXT	Le prénom, le nom et le code postal sont obligatoires.	TO_VERIFY	2026-10-12 12:44:52.433328+00	po	2026-10-12 12:44:52.433328+00	po	0
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."attachments" ("id", "project_id", "target_type", "target_id", "file_name", "content_type", "size", "storage_key", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
b18cb0be-ea4d-4f8d-8636-12ab37603de4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	EXECUTION_STEP	7a2cc1af-344f-4ac3-89a9-2b2bc9cc7a5c	sd-defaut-problem-user.png	image/png	235120	c9a4e873-9485-4a92-a415-87a819266751	2026-10-12 12:45:48.801464+00	qa2	2026-10-12 12:45:48.801464+00	qa2	0
037deb09-d46b-4df3-9a57-b91dbc393c6e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEFECT	3b0347ce-858f-4973-8153-8658754c8c7f	sd-defaut-problem-user.png	image/png	235120	c9a4e873-9485-4a92-a415-87a819266751	2026-10-12 12:45:50.332001+00	qa2	2026-10-12 12:45:50.332001+00	qa2	0
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."audit_events" ("id", "project_id", "entity_type", "entity_id", "entity_key", "action", "diff", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
c19440cc-fb67-4e66-8846-7aa4953261c6	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	eb434eaf-4d35-46fd-9330-26a103936ed3	REQ-1	CREATED	[{"after": "REQ-1", "field": "key", "before": null}, {"after": "EPIC", "field": "type", "before": null}, {"after": "Acheter en ligne sur Swag Labs", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.", "field": "description", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:51.849492+00	po	2026-10-12 12:44:51.849492+00	po	0
2c93cada-8f17-4fe4-beb9-5b937fc6b447	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	c0e546fd-e6e2-4a14-a218-2e3f68412c5c	REQ-2	CREATED	[{"after": "REQ-2", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Authentification", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:51.914719+00	po	2026-10-12 12:44:51.914719+00	po	0
90e3dc08-50b0-4e8d-be5c-e541e4efcf08	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	REQ-3	CREATED	[{"after": "REQ-3", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Se connecter avec un compte valide", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "me connecter avec mon identifiant et mon mot de passe", "field": "userStory.iWant", "before": null}, {"after": "accéder au catalogue", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "field": "criteria", "before": null}]	2026-10-12 12:44:51.983869+00	po	2026-10-12 12:44:51.983869+00	po	0
dad842d0-541b-4a19-a686-330515ba22f5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	REQ-4	CREATED	[{"after": "REQ-4", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Refuser un compte verrouillé", "field": "title", "before": null}, {"after": "REQ-2", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "responsable sécurité", "field": "userStory.asA", "before": null}, {"after": "que les comptes verrouillés ne puissent pas se connecter", "field": "userStory.iWant", "before": null}, {"after": "protéger la boutique", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.02931+00	po	2026-10-12 12:44:52.02931+00	po	0
a896f443-730c-4c7d-abb6-c73566deb875	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	2296fe8a-ec13-48e4-9531-ea274772789b	REQ-5	CREATED	[{"after": "REQ-5", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:52.069134+00	po	2026-10-12 12:44:52.069134+00	po	0
9d61fcaa-d631-425b-8baa-14a7ef311c94	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	702601a5-33df-4395-b47c-e3ca85e96993	REQ-6	CREATED	[{"after": "REQ-6", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter le catalogue des produits", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir les produits avec leur prix", "field": "userStory.iWant", "before": null}, {"after": "choisir mes achats", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.108765+00	po	2026-10-12 12:44:52.108765+00	po	0
9f190920-2435-4aa0-9390-df49207d61e4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	1815821a-5f7e-4621-a8f0-00996df35ac7	REQ-7	CREATED	[{"after": "REQ-7", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Trier le catalogue", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "trier les produits par nom ou par prix", "field": "userStory.iWant", "before": null}, {"after": "trouver plus vite ce qui m’intéresse", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.154587+00	po	2026-10-12 12:44:52.154587+00	po	0
7dce5e2c-9754-4fde-9c77-965c1e358572	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	a3dd920e-f432-4223-997c-db6db4b3eaab	REQ-9	CREATED	[{"after": "REQ-9", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Panier", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:52.237223+00	po	2026-10-12 12:44:52.237223+00	po	0
f13d01a2-44b9-4b23-8d72-1e0d14c2487f	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	REQ-8	CREATED	[{"after": "REQ-8", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Consulter la fiche d’un produit", "field": "title", "before": null}, {"after": "REQ-5", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ouvrir la fiche détaillée d’un produit", "field": "userStory.iWant", "before": null}, {"after": "lire sa description complète", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "LOW", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.195915+00	po	2026-10-12 12:44:52.195915+00	po	0
ebb2706a-f93f-44db-a91e-f66a53c49ace	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	b68ddd88-cf31-4488-8ede-74b4d54de51d	REQ-10	CREATED	[{"after": "REQ-10", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Ajouter un produit au panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "ajouter un produit au panier depuis le catalogue", "field": "userStory.iWant", "before": null}, {"after": "le commander plus tard", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.27422+00	po	2026-10-12 12:44:52.27422+00	po	0
19c4ea57-4198-4639-81bd-8c991feab272	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	REQ-11	CREATED	[{"after": "REQ-11", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Visualiser le contenu du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "voir le contenu de mon panier", "field": "userStory.iWant", "before": null}, {"after": "vérifier mes achats avant de commander", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 3, "field": "storyPoints", "before": null}, {"after": "HIGH", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.316192+00	po	2026-10-12 12:44:52.316192+00	po	0
d99c33b6-acfa-4f99-922d-8d07cad4edf3	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	7820c512-1276-4f53-8455-5c2682ee8847	REQ-15	CREATED	[{"after": "REQ-15", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Valider la commande", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "vérifier le récapitulatif et valider ma commande", "field": "userStory.iWant", "before": null}, {"after": "recevoir mes produits", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:54.111355+00	po	2026-10-12 12:44:54.111355+00	po	0
870950e4-7f1a-4c92-9003-78b613a30f30	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	1815821a-5f7e-4621-a8f0-00996df35ac7	REQ-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.361654+00	po	2026-10-12 12:44:55.361654+00	po	0
25935e8f-d85c-4553-a15f-71429716c200	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	b68ddd88-cf31-4488-8ede-74b4d54de51d	REQ-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.443869+00	po	2026-10-12 12:44:55.443869+00	po	0
ef098f84-30ba-4c18-a944-6539edeafb5c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	REQ-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:56.462204+00	po	2026-10-12 12:44:56.462204+00	po	0
c1bfdb29-983d-4682-ba96-bb256e6bc6d1	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	700ee46f-2e16-4595-8e42-60df8efba238	TC-1	CREATED	[{"after": "TC-1", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Se connecter avec les comptes de démonstration", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Vérifier l’accès au catalogue selon le type de compte.", "field": "objective", "before": null}, {"after": 3, "field": "estimatedDurationMin", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": true, "field": "automationCandidate", "before": null}, {"after": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.", "field": "automationJustification", "before": null}, {"after": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "field": "parameters", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "field": "dataSets", "before": null}, {"after": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "field": "steps", "before": null}]	2026-10-12 12:45:02.71856+00	qa1	2026-10-12 12:45:02.71856+00	qa1	0
39761974-d425-4848-953d-1f34ffcd8b4b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RUN	d2836591-3c64-4148-8f7c-c3b30b68bf62	RUN-2	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-2", "field": "campaign", "before": null}]	2026-10-12 12:45:58.320946+00	dev	2026-10-12 12:45:58.320946+00	dev	0
16e45117-0cf3-499e-adfc-b2703a3ab293	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	REQ-12	CREATED	[{"after": "REQ-12", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Retirer un produit du panier", "field": "title", "before": null}, {"after": "REQ-9", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "retirer un produit ajouté par erreur", "field": "userStory.iWant", "before": null}, {"after": "ne garder que ce que je veux acheter", "field": "userStory.soThat", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 2, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.36144+00	po	2026-10-12 12:44:52.36144+00	po	0
3d5a060f-6506-4904-9ad2-209a0d2dca06	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	424484f0-be28-4f80-beba-57398970bf97	REQ-13	CREATED	[{"after": "REQ-13", "field": "key", "before": null}, {"after": "FEATURE", "field": "type", "before": null}, {"after": "Commande", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "Parcours de commande (checkout) : **non développé** dans la release 1.0.", "field": "description", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:52.402162+00	po	2026-10-12 12:44:52.402162+00	po	0
9a6effc0-916f-4562-94c0-f8e1140a2e43	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	ad2028b8-e429-450d-aa56-ca0831aedee5	REQ-14	CREATED	[{"after": "REQ-14", "field": "key", "before": null}, {"after": "USER_STORY", "field": "type", "before": null}, {"after": "Saisir les informations de livraison", "field": "title", "before": null}, {"after": "REQ-13", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "client", "field": "userStory.asA", "before": null}, {"after": "saisir mon nom et mon code postal", "field": "userStory.iWant", "before": null}, {"after": "être livré", "field": "userStory.soThat", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": 5, "field": "storyPoints", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": false, "field": "transverse", "before": null}, {"after": ["[TEXT] Le prénom, le nom et le code postal sont obligatoires."], "field": "criteria", "before": null}]	2026-10-12 12:44:52.433845+00	po	2026-10-12 12:44:52.433845+00	po	0
b80cbe77-4efa-4026-87f0-493dfc86f031	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	26c7900c-066b-49a5-ab2a-3a8e6b22d58f	REQ-16	CREATED	[{"after": "REQ-16", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Temps de chargement du catalogue", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "PERFORMANCE", "field": "category", "before": null}, {"after": "Délai entre le clic « Login » et l’affichage des six produits", "field": "planguage.scale", "before": null}, {"after": "p95 de 5 connexions successives (test Playwright de performance)", "field": "planguage.measurementMethod", "before": null}, {"after": "3000", "field": "planguage.minimumThreshold", "before": null}, {"after": "1000", "field": "planguage.target", "before": null}, {"after": "ms", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:54.363991+00	po	2026-10-12 12:44:54.363991+00	po	0
6d42321e-5a55-431c-abab-54a216f858e4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	5332dd2d-0ece-4253-96f6-5f995405899c	REQ-17	CREATED	[{"after": "REQ-17", "field": "key", "before": null}, {"after": "NON_FUNCTIONAL", "field": "type", "before": null}, {"after": "Contrat HTTP du site", "field": "title", "before": null}, {"after": "REQ-1", "field": "parentKey", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "MEDIUM", "field": "riskLevel", "before": null}, {"after": "RELIABILITY", "field": "category", "before": null}, {"after": "Part des ressources publiques servies conformément (page, manifeste, icônes)", "field": "planguage.scale", "before": null}, {"after": "Test d’API sans navigateur", "field": "planguage.measurementMethod", "before": null}, {"after": "100", "field": "planguage.minimumThreshold", "before": null}, {"after": "100", "field": "planguage.target", "before": null}, {"after": "%", "field": "planguage.unit", "before": null}, {"after": true, "field": "transverse", "before": null}, {"after": [], "field": "criteria", "before": null}]	2026-10-12 12:44:54.404952+00	po	2026-10-12 12:44:54.404952+00	po	0
062c288a-43b7-4c2b-bbaf-24ae5f6e972d	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	REQ-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.23349+00	po	2026-10-12 12:44:55.23349+00	po	0
e1c5b43d-14c3-4026-a64f-751fdc5a0840	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	REQ-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.283172+00	po	2026-10-12 12:44:55.283172+00	po	0
c6affc45-ce38-40fa-8bdc-21443b8b293e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	702601a5-33df-4395-b47c-e3ca85e96993	REQ-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.323642+00	po	2026-10-12 12:44:55.323642+00	po	0
dcfb476a-93d8-4acb-998e-9e8561c84cb8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	REQ-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.404106+00	po	2026-10-12 12:44:55.404106+00	po	0
5c9f1b73-1fdd-45c0-b339-7820e8ff88a5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	REQ-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:44:55.483922+00	po	2026-10-12 12:44:55.483922+00	po	0
67a23929-5508-492b-a6fe-46b33cd379a6	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	700ee46f-2e16-4595-8e42-60df8efba238	TC-1	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:02.775293+00	qa1	2026-10-12 12:45:02.775293+00	qa1	0
9de6f237-4294-4eb7-bcf6-2c34f3b4a0bb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	03f2bd14-310b-40c4-98cd-403a38526c96	TC-6	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:03.156364+00	qa1	2026-10-12 12:45:03.156364+00	qa1	0
c6f552c5-d629-4c7b-970d-bebe52baa7d1	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	d6866772-c3cd-4fbc-9865-a644c6069f09	CMP-3	CREATED	[{"after": "Intégration continue — main", "field": "name", "before": null}, {"after": "RELEASE", "field": "scopeType", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "ci", "field": "environment", "before": null}, {"after": "main", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Intégration continue", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:46:18.671119+00	qa1	2026-10-12 12:46:18.671119+00	qa1	0
36e22e73-6ef9-407a-a1d0-a7485d8ec9e6	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TRACE_LINK	9fdac818-ff48-4593-8758-d43a918ce3dc	TC-6 → REQ-8	UPDATED	[{"after": false, "field": "suspect", "before": true}]	2026-10-12 12:46:28.245147+00	qa1	2026-10-12 12:46:28.245147+00	qa1	0
b61797ea-24db-44f6-bd3f-7545cc75ed4d	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	187c5fea-f6d8-4f2c-9980-e010cab078a0	TC-2	CREATED	[{"after": "TC-2", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Retirer un produit depuis le catalogue et le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": 5, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "field": "steps", "before": null}]	2026-10-12 12:45:02.812918+00	qa1	2026-10-12 12:45:02.812918+00	qa1	0
8bae2f62-2b7b-47c6-bf91-8fa90f78553a	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	187c5fea-f6d8-4f2c-9980-e010cab078a0	TC-2	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:02.856136+00	qa1	2026-10-12 12:45:02.856136+00	qa1	0
6e6f7a13-1239-475c-8088-7fa8caae3549	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	cc8fecbd-629e-4b49-9cb5-301da0d06f13	TC-3	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:02.936454+00	qa1	2026-10-12 12:45:02.936454+00	qa1	0
a70c6f1c-76bc-414c-bf49-08894b163d65	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	c908281b-629c-4e68-a53c-cc6608cdeacf	TC-4	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:02.997841+00	qa1	2026-10-12 12:45:02.997841+00	qa1	0
1c97f2b7-ce43-464e-8ea5-f844332159f8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	be93af9c-6d55-40a3-a432-6f98fd300c13	TC-5	CREATED	[{"after": "TC-5", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : tri par prix croissant", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › trie les produits par prix croissant", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:45:03.034932+00	dev	2026-10-12 12:45:03.034932+00	dev	0
767e080e-71c4-4c17-8b52-019123e69397	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	03f2bd14-310b-40c4-98cd-403a38526c96	TC-6	CREATED	[{"after": "TC-6", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : fiche produit", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › ouvre la fiche d’un produit", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:45:03.118862+00	dev	2026-10-12 12:45:03.118862+00	dev	0
bb599b92-7e1a-4798-a2fe-2fdb252ab06b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	a420130e-db79-424c-8dc9-25f714dc3be6	TC-7	CREATED	[{"after": "TC-7", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Contrat HTTP : manifeste et icônes", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "API", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "API", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/api.spec.ts", "field": "path", "before": null}, {"after": "Contrat HTTP › expose le manifeste PWA et ses icônes", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:45:03.199162+00	dev	2026-10-12 12:45:03.199162+00	dev	0
e3bdde5d-2d4a-4342-b654-fa71bcb05aef	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	a420130e-db79-424c-8dc9-25f714dc3be6	TC-7	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:03.238227+00	qa1	2026-10-12 12:45:03.238227+00	qa1	0
8d9346f4-9b91-4be0-a149-1be6f82bc1cf	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	d254040b-f43a-4181-944f-27c1d035d594	TC-8	CREATED	[{"after": "TC-8", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "field": "objective", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "BDD", "field": "technique", "before": null}, {"after": "Cucumber-JVM", "field": "framework", "before": null}, {"after": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "field": "path", "before": null}, {"after": "Ajouter un produit au panier depuis le catalogue", "field": "testIdentifier", "before": null}, {"after": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "field": "gherkinSource", "before": null}, {"after": "bdd", "field": "executionTags", "before": null}]	2026-10-12 12:45:04.550055+00	qa1	2026-10-12 12:45:04.550055+00	qa1	0
94aee502-5f12-4b3c-aa51-ef662fbb5b45	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	d254040b-f43a-4181-944f-27c1d035d594	TC-8	UPDATED	[{"after": "Panier", "field": "folder", "before": null}, {"after": "Playwright", "field": "framework", "before": "Cucumber-JVM"}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/features/panier.feature", "field": "path", "before": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature"}]	2026-10-12 12:45:04.681593+00	qa1	2026-10-12 12:45:04.681593+00	qa1	0
e9a58332-470e-4da8-8b3c-891213bcc816	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	cc8fecbd-629e-4b49-9cb5-301da0d06f13	TC-3	CREATED	[{"after": "TC-3", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Connexion pilotée par les données", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Authentification", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "field": "dataSets", "before": null}, {"after": "DATA_DRIVEN", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/authentification.spec.ts", "field": "path", "before": null}, {"after": "Authentification › connexion avec chaque compte du jeu de données", "field": "testIdentifier", "before": null}, {"after": "saucedemo, regression", "field": "executionTags", "before": null}]	2026-10-12 12:45:02.903444+00	dev	2026-10-12 12:45:02.903444+00	dev	0
ee241813-3948-495c-8a2f-1e8bef509c09	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	c908281b-629c-4e68-a53c-cc6608cdeacf	TC-4	CREATED	[{"after": "TC-4", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Catalogue : six produits affichés", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Catalogue", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/catalogue.spec.ts", "field": "path", "before": null}, {"after": "Catalogue › affiche les six produits du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:45:02.968478+00	dev	2026-10-12 12:45:02.968478+00	dev	0
81668ea5-ac54-43d7-b8d3-f4ae10388029	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	be93af9c-6d55-40a3-a432-6f98fd300c13	TC-5	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:03.072847+00	qa1	2026-10-12 12:45:03.072847+00	qa1	0
175606f5-bcb8-407a-8228-4d00b6febb92	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	d254040b-f43a-4181-944f-27c1d035d594	TC-8	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:04.635521+00	qa1	2026-10-12 12:45:04.635521+00	qa1	0
df471499-e056-4c7b-a068-2dfa11d218de	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	TC-9	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:05.598644+00	qa1	2026-10-12 12:45:05.598644+00	qa1	0
3f9f53f0-7c7f-4ae1-a296-37d80cd8ced0	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	7239fab8-aed6-4e47-a3fe-b60e84557eab	TC-11	CREATED	[{"after": "TC-11", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Performance : chargement du catalogue", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Performance", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "{iterations=5, seuilMs=3000}", "field": "parameters", "before": null}, {"after": "PERFORMANCE", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/performance.spec.ts", "field": "path", "before": null}, {"after": "Performance › temps de chargement du catalogue", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:45:05.695307+00	dev	2026-10-12 12:45:05.695307+00	dev	0
ab094480-38a5-40e8-b69b-a229cabf5f9b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	7239fab8-aed6-4e47-a3fe-b60e84557eab	TC-11	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:05.724389+00	qa1	2026-10-12 12:45:05.724389+00	qa1	0
090717e0-99a6-4573-ae0c-19b1d4401b48	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	TC-13	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:05.851346+00	qa1	2026-10-12 12:45:05.851346+00	qa1	0
1b259928-aff1-44f4-96e1-dab97a926b90	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4"], "field": "scope", "before": ["REQ-3"]}]	2026-10-12 12:45:11.416006+00	po	2026-10-12 12:45:11.416006+00	po	0
de62cde6-b804-4b8f-a38d-1197e66a6341	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	0bce208d-4e06-41c4-869a-01d4af1d45b2	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6", "TC-7"], "field": "tests", "before": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"]}]	2026-10-12 12:45:13.760987+00	qa1	2026-10-12 12:45:13.760987+00	qa1	0
480b784e-8d43-462b-885e-03e8d20b99bc	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	REQ-8	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:45:44.553231+00	po	2026-10-12 12:45:44.553231+00	po	0
bccc5eaa-38ee-4ba8-acf9-ba6f81b805bc	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	STATUS_CHANGED	[{"after": "CLOSED", "field": "status", "before": "ACTIVE"}]	2026-10-12 12:45:45.357149+00	po	2026-10-12 12:45:45.357149+00	po	0
636dfc95-d258-49eb-aa0b-2e3edbbc6ab4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	TC-9	CREATED	[{"after": "TC-9", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : visualiser le contenu", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › visualise le contenu du panier", "field": "testIdentifier", "before": null}, {"after": "saucedemo, smoke", "field": "executionTags", "before": null}]	2026-10-12 12:45:05.564766+00	dev	2026-10-12 12:45:05.564766+00	dev	0
1c886cb9-4abc-4955-80d5-a93c15270ac2	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	9fdec814-d958-4de8-855a-e1a27cd20933	TC-10	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:05.661496+00	qa1	2026-10-12 12:45:05.661496+00	qa1	0
dd8c0a16-88f8-46d5-9564-36a0e22622e1	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7", "REQ-8"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"]}]	2026-10-12 12:45:11.636245+00	po	2026-10-12 12:45:11.636245+00	po	0
81f0c894-ef36-41e2-b84c-0cafc11f2aa4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RUN	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	RUN-1	CREATED	[{"after": "QUEUED", "field": "status", "before": null}, {"after": "Serveur d'exécution", "field": "server", "before": null}, {"after": "CMP-1", "field": "campaign", "before": null}]	2026-10-12 12:45:16.921592+00	dev	2026-10-12 12:45:16.921592+00	dev	0
2bdf52a9-9243-47ab-a1c9-6531dcdb3130	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	0bce208d-4e06-41c4-869a-01d4af1d45b2	CMP-1	STATUS_CHANGED	[{"after": "COMPLETED", "field": "status", "before": "IN_PROGRESS"}]	2026-10-12 12:45:42.923572+00	qa1	2026-10-12 12:45:42.923572+00	qa1	0
800693b6-76d4-4fb0-9dad-f98920f4bcf4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	REQ-3	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:45:42.997237+00	po	2026-10-12 12:45:42.997237+00	po	0
b616c189-ac4d-4630-9d22-fb51ee424525	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	1815821a-5f7e-4621-a8f0-00996df35ac7	REQ-7	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:45:43.126362+00	po	2026-10-12 12:45:43.126362+00	po	0
d1faee3d-cd65-4956-afc1-fff21c988cf0	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	9fdec814-d958-4de8-855a-e1a27cd20933	TC-10	CREATED	[{"after": "TC-10", "field": "key", "before": null}, {"after": "AUTOMATED", "field": "kind", "before": null}, {"after": "Panier : retrait par problem_user", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "UI", "field": "technique", "before": null}, {"after": "Playwright", "field": "framework", "before": null}, {"after": "TypeScript", "field": "language", "before": null}, {"after": "file:///depots/traceagile", "field": "repositoryUrl", "before": null}, {"after": "depots-git", "field": "branch", "before": null}, {"after": "saucedemo/app-tests/panier.spec.ts", "field": "path", "before": null}, {"after": "Panier › problem_user retire un produit depuis le catalogue @fail", "field": "testIdentifier", "before": null}, {"after": "saucedemo", "field": "executionTags", "before": null}]	2026-10-12 12:45:05.629287+00	dev	2026-10-12 12:45:05.629287+00	dev	0
7be607f3-f289-4209-bca4-e3bf9c981010	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	b0393b4a-992f-441a-9e85-d6a27de9108a	TC-12	STATUS_CHANGED	[{"after": "READY", "field": "status", "before": "DRAFT"}]	2026-10-12 12:45:05.786336+00	qa1	2026-10-12 12:45:05.786336+00	qa1	0
a5d28bdf-0f32-4915-bc91-02c32981b64c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	TC-13	CREATED	[{"after": "TC-13", "field": "key", "before": null}, {"after": "MANUAL", "field": "kind", "before": null}, {"after": "Ajouter un produit au panier après connexion", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "SHOULD", "field": "priority", "before": null}, {"after": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "field": "objective", "before": null}, {"after": 4, "field": "estimatedDurationMin", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": ["produit = Sauce Labs Backpack", "prix = $29.99"], "field": "parameters", "before": null}, {"after": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "field": "dataSets", "before": null}, {"after": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "field": "steps", "before": null}]	2026-10-12 12:45:05.817967+00	qa1	2026-10-12 12:45:05.817967+00	qa1	0
0a46af10-80ae-4280-92b7-aa1ef8d8011a	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	22c2616c-7486-4747-8085-a9eb65ee0ea5	SPR-2	CREATED	[{"after": "Sprint 2 — Panier", "field": "name", "before": null}, {"after": "Ajouter, visualiser et retirer des produits du panier", "field": "goal", "before": null}, {"after": "2026-10-12", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": 10, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 12:45:10.752099+00	po	2026-10-12 12:45:10.752099+00	po	0
ebca4c9c-b25e-413f-b179-ff63a51232e5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6"], "field": "scope", "before": ["REQ-3", "REQ-4"]}]	2026-10-12 12:45:11.48868+00	po	2026-10-12 12:45:11.48868+00	po	0
a4768a8f-acef-4b30-8e7f-66705272fedb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	UPDATED	[{"after": ["REQ-3", "REQ-4", "REQ-6", "REQ-7"], "field": "scope", "before": ["REQ-3", "REQ-4", "REQ-6"]}]	2026-10-12 12:45:11.561993+00	po	2026-10-12 12:45:11.561993+00	po	0
69008caf-b807-493a-99c0-9ec76a097560	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	0bce208d-4e06-41c4-869a-01d4af1d45b2	CMP-1	UPDATED	[{"after": ["TC-1 [Comptes #1]", "TC-1 [Comptes #2]", "TC-1 [Comptes #3]", "TC-3", "TC-4", "TC-5", "TC-6"], "field": "tests", "before": []}]	2026-10-12 12:45:13.534104+00	qa1	2026-10-12 12:45:13.534104+00	qa1	0
4acf5124-0d43-488a-842e-6ee92ba17b5b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	702601a5-33df-4395-b47c-e3ca85e96993	REQ-6	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:45:43.085724+00	po	2026-10-12 12:45:43.085724+00	po	0
ec154062-f7c7-4292-8969-845a2ca726d9	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	b0393b4a-992f-441a-9e85-d6a27de9108a	TC-12	CREATED	[{"after": "TC-12", "field": "key", "before": null}, {"after": "EXPLORATORY", "field": "kind", "before": null}, {"after": "Explorer le panier", "field": "title", "before": null}, {"after": "DRAFT", "field": "status", "before": null}, {"after": "MUST", "field": "priority", "before": null}, {"after": "Panier", "field": "folder", "before": null}, {"after": false, "field": "automationCandidate", "before": null}, {"after": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "field": "mission", "before": null}, {"after": "Panier, Catalogue", "field": "areas", "before": null}, {"after": "CRUD, Goldilocks", "field": "heuristics", "before": null}, {"after": 60, "field": "timeboxMin", "before": null}, {"after": "Panier faux au moment de commander", "field": "targetedRisk", "before": null}]	2026-10-12 12:45:05.753988+00	qa1	2026-10-12 12:45:05.753988+00	qa1	0
d1a5bc66-f927-4e74-97ed-4c0d9e817a94	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RELEASE	25d7c25e-ee25-4a23-9f89-d9273c419eb5	REL-1	CREATED	[{"after": "Swag Labs 1.0", "field": "name", "before": null}, {"after": "Connexion, catalogue et panier (la commande viendra en 1.1)", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-23", "field": "endDate", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "sprints", "before": null}]	2026-10-12 12:45:10.678618+00	po	2026-10-12 12:45:10.678618+00	po	0
a1963035-f1b5-48cf-87ec-bb11316f9339	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	CREATED	[{"after": "Sprint 1 — Connexion et catalogue", "field": "name", "before": null}, {"after": "Se connecter et parcourir le catalogue", "field": "goal", "before": null}, {"after": "2026-09-28", "field": "startDate", "before": null}, {"after": "2026-10-09", "field": "endDate", "before": null}, {"after": 13, "field": "capacityPoints", "before": null}, {"after": "REL-1", "field": "release", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": [], "field": "scope", "before": null}]	2026-10-12 12:45:10.709127+00	po	2026-10-12 12:45:10.709127+00	po	0
ccdbfb21-60dc-4743-9f8c-a62c0bb8050a	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	UPDATED	[{"after": ["REQ-3"], "field": "scope", "before": []}]	2026-10-12 12:45:11.345478+00	po	2026-10-12 12:45:11.345478+00	po	0
b3fba054-8fb2-43ce-9347-a5137936fafb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	REQ-3	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:12.193553+00	po	2026-10-12 12:45:12.193553+00	po	0
31c88a37-cc48-46f6-82a4-6240899867f8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	REQ-4	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:12.194071+00	po	2026-10-12 12:45:12.194071+00	po	0
16a2efb8-0597-49e7-b344-8ccfc114364e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	702601a5-33df-4395-b47c-e3ca85e96993	REQ-6	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:12.194071+00	po	2026-10-12 12:45:12.194071+00	po	0
ca21bf78-aa2a-452c-b8f3-d99831a6ea33	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	1815821a-5f7e-4621-a8f0-00996df35ac7	REQ-7	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:12.194071+00	po	2026-10-12 12:45:12.194071+00	po	0
ce85d0ef-430f-4e8c-996b-c962c7a602a1	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	REQ-8	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:12.194071+00	po	2026-10-12 12:45:12.194071+00	po	0
eedecda8-d3d6-45c3-b2c3-6d39bffdd84d	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	SPR-1	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 12:45:12.194071+00	po	2026-10-12 12:45:12.194071+00	po	0
29e0b15c-5d04-4a98-b427-061b90633f55	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	0bce208d-4e06-41c4-869a-01d4af1d45b2	CMP-1	CREATED	[{"after": "Recette sprint 1", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-1", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s1", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:45:13.27892+00	qa1	2026-10-12 12:45:13.27892+00	qa1	0
eaeb620f-6cfc-44d7-a15c-7cee3182996b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	REQ-4	STATUS_CHANGED	[{"after": "DONE", "field": "status", "before": "IN_SPRINT"}]	2026-10-12 12:45:43.042814+00	po	2026-10-12 12:45:43.042814+00	po	0
b58040d4-24b6-4ce9-ba9b-21184a62eaa2	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	22c2616c-7486-4747-8085-a9eb65ee0ea5	SPR-2	UPDATED	[{"after": ["REQ-10", "REQ-11", "REQ-12"], "field": "scope", "before": []}]	2026-10-12 12:45:46.05323+00	po	2026-10-12 12:45:46.05323+00	po	0
ea278f8d-29df-4096-bdf4-eeb844894a19	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	b68ddd88-cf31-4488-8ede-74b4d54de51d	REQ-10	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:46.099233+00	po	2026-10-12 12:45:46.099233+00	po	0
c67d3fa9-ee00-4806-a759-739cd5e80e21	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	REQ-11	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:46.099777+00	po	2026-10-12 12:45:46.099777+00	po	0
493553ea-71b4-4773-a9e8-1aa713dca312	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	REQ-12	STATUS_CHANGED	[{"after": "IN_SPRINT", "field": "status", "before": "READY"}]	2026-10-12 12:45:46.099777+00	po	2026-10-12 12:45:46.099777+00	po	0
d2d30d20-8351-466e-97ff-c68ff59ea076	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPRINT	22c2616c-7486-4747-8085-a9eb65ee0ea5	SPR-2	STATUS_CHANGED	[{"after": "ACTIVE", "field": "status", "before": "PLANNED"}]	2026-10-12 12:45:46.099777+00	po	2026-10-12 12:45:46.099777+00	po	0
6d9dda54-5861-417d-b925-947d1d8bbf1e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	876bf075-731a-4542-ac54-529ee2ff7c8b	CMP-2	CREATED	[{"after": "Recette sprint 2", "field": "name", "before": null}, {"after": "SPRINT", "field": "scopeType", "before": null}, {"after": "SPR-2", "field": "sprint", "before": null}, {"after": "recette", "field": "environment", "before": null}, {"after": "1.0.0-s2", "field": "buildVersion", "before": null}, {"after": "PLANNED", "field": "status", "before": null}, {"after": "Release 1.0/Recettes de sprint", "field": "folder", "before": null}, {"after": [], "field": "tests", "before": null}]	2026-10-12 12:45:47.070556+00	qa1	2026-10-12 12:45:47.070556+00	qa1	0
c430d6ac-ff5e-4cc8-8d25-7e73839973de	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	876bf075-731a-4542-ac54-529ee2ff7c8b	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"], "field": "tests", "before": []}]	2026-10-12 12:45:47.099177+00	qa1	2026-10-12 12:45:47.099177+00	qa1	0
f1e48d85-41bc-41d3-a116-267160b51d1a	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CAMPAIGN	876bf075-731a-4542-ac54-529ee2ff7c8b	CMP-2	UPDATED	[{"after": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10", "TC-11"], "field": "tests", "before": ["TC-2", "TC-12", "TC-8", "TC-9", "TC-13 [Produits #1]", "TC-13 [Produits #2]", "TC-10"]}]	2026-10-12 12:45:47.122395+00	qa1	2026-10-12 12:45:47.122395+00	qa1	0
a259ef93-c4c6-40bb-b5df-0a106c21a131	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SESSION	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	TC-12#1	STATUS_CHANGED	[{"after": "FINISHED", "field": "state", "before": "RUNNING"}, {"after": "FAILED", "field": "status", "before": "RUNNING"}, {"after": "60/25/15", "field": "tbs", "before": null}, {"after": ["Panier", "Catalogue"], "field": "areasCovered", "before": []}]	2026-10-12 12:45:55.678141+00	qa1	2026-10-12 12:45:55.678141+00	qa1	0
edd141b5-7c41-4418-9221-49429c01c090	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SESSION	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	TC-12#1	UPDATED	[{"after": 4, "field": "feelings", "before": null}]	2026-10-12 12:45:56.141604+00	qa1	2026-10-12 12:45:56.141604+00	qa1	0
e3b3ac7e-b7f0-49f4-8b85-37ebca2607dd	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEFECT	3b0347ce-858f-4973-8153-8658754c8c7f	DEF-1	CREATED	[{"after": "problem_user : « Remove » sur le catalogue ne retire pas le produit", "field": "title", "before": null}, {"after": "**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Étapes pour reproduire**\\n\\n1. Ouvrir https://www.saucedemo.com\\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\\n4. Ouvrir le panier\\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\\n\\n**Attendu** : Le badge du panier disparaît\\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 12:45:50.326763+00	qa2	2026-10-12 12:45:50.326763+00	qa2	0
d31cb893-20c1-4422-b999-6e16c5f0e0eb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SESSION	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	TC-12#1	CREATED	[{"after": "RUNNING", "field": "state", "before": null}, {"after": "RUNNING", "field": "status", "before": null}, {"after": [], "field": "areasCovered", "before": null}]	2026-10-12 12:45:53.088765+00	qa1	2026-10-12 12:45:53.088765+00	qa1	0
00b1d86c-aa4d-4d1a-a89b-3125062721f7	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEFECT	cd2537b4-e904-4a71-84ef-dea9b7e4b306	DEF-2	CREATED	[{"after": "TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt", "field": "title", "before": null}, {"after": "**Charte** : TC-12 Explorer le panier\\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\\n**Session** : tentative 1 de qa1, constat à 26:30\\n**Campagne** : CMP-2 Recette sprint 2\\n**Environnement** : recette · **Build** : 1.0.0-s2\\n\\n**Constat**\\n\\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\\n", "field": "description", "before": null}, {"after": "MAJOR", "field": "severity", "before": null}, {"after": "OPEN", "field": "status", "before": null}, {"after": ["REQ-11", "REQ-12"], "field": "requirements", "before": null}]	2026-10-12 12:45:54.394032+00	qa1	2026-10-12 12:45:54.394032+00	qa1	0
51d78b8f-8f34-4d92-b31b-010c8673622b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SESSION	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	TC-12#1	STATUS_CHANGED	[{"after": "DEBRIEFED", "field": "state", "before": "FINISHED"}, {"after": "po", "field": "approvedBy", "before": null}]	2026-10-12 12:45:56.640682+00	po	2026-10-12 12:45:56.640682+00	po	0
cd3f1eb5-c04b-486b-bd6b-1055c90b9a51	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	REQ-8	UPDATED	[{"after": "Consulter la fiche détaillée d’un produit", "field": "title", "before": "Consulter la fiche d’un produit"}]	2026-10-12 12:46:27.61195+00	po	2026-10-12 12:46:27.61195+00	po	0
4db99133-c520-423c-8b4b-27c25c7185b4	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	03f2bd14-310b-40c4-98cd-403a38526c96	TC-6	STATUS_CHANGED	[{"after": "NEEDS_UPDATE", "field": "status", "before": "READY"}]	2026-10-12 12:46:27.620537+00	po	2026-10-12 12:46:27.620537+00	po	0
\.


--
-- Data for Name: automated_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_runs" ("id", "project_id", "run_key", "key_number", "campaign_id", "server_id", "status", "requested_by", "requested_at", "dispatched_at", "started_at", "ended_at", "last_event_at", "environment", "build_version", "external_job_id", "agent", "logs_url", "report_url", "timeout_minutes", "error_code", "error_message", "summary_total", "summary_passed", "summary_failed", "summary_error", "summary_skipped", "rerun_of", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RUN-1	1	0bce208d-4e06-41c4-869a-01d4af1d45b2	1cd84867-4524-4972-a681-84ea0d4a8cd5	COMPLETED	dev	2026-10-12 12:45:16.915435+00	2026-10-12 12:45:16.970509+00	2026-10-12 12:45:16.968932+00	2026-10-12 12:45:41.064+00	2026-10-12 12:45:41.064+00	recette	1.0.0-s1	job-4b5f201a	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-4b5f201a/logs	http://localhost:8091/api/v1/jobs/job-4b5f201a/artifacts/report.json	30	\N	\N	5	5	0	0	0	\N	2026-10-12 12:45:16.92009+00	dev	2026-10-12 12:45:41.079778+00	anonymousUser	9
d2836591-3c64-4148-8f7c-c3b30b68bf62	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RUN-2	2	876bf075-731a-4542-ac54-529ee2ff7c8b	1cd84867-4524-4972-a681-84ea0d4a8cd5	COMPLETED	dev	2026-10-12 12:45:58.319272+00	2026-10-12 12:45:58.345824+00	2026-10-12 12:45:58.344751+00	2026-10-12 12:46:16.13986+00	2026-10-12 12:46:16.13986+00	recette	1.0.0-s2	job-634b1209	executeur-docker@ef337df0bd79	http://localhost:8091/api/v1/jobs/job-634b1209/logs	http://localhost:8091/api/v1/jobs/job-634b1209/artifacts/report.json	30	\N	\N	4	3	1	0	0	\N	2026-10-12 12:45:58.319783+00	dev	2026-10-12 12:46:16.152509+00	anonymousUser	9
\.


--
-- Data for Name: automated_test_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automated_test_definitions" ("id", "test_case_id", "technique", "framework", "language", "repository_url", "branch", "path", "test_identifier", "feature_name", "gherkin_source", "parameters", "execution_tags", "environment_requirements", "keywords", "missing_in_repository", "created_at", "created_by", "updated_at", "updated_by", "version", "git_project_id") FROM stdin;
47444469-81e5-4ba7-9131-53b04f876115	cc8fecbd-629e-4b49-9cb5-301da0d06f13	DATA_DRIVEN	Playwright	TypeScript	\N	\N	saucedemo/app-tests/authentification.spec.ts	Authentification › connexion avec chaque compte du jeu de données	\N	\N	{}	["saucedemo", "regression"]	{}	[]	f	2026-10-12 12:45:02.898289+00	dev	2026-10-12 12:45:02.898289+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
5a8039de-6863-4bda-a6cb-eff417a1c501	c908281b-629c-4e68-a53c-cc6608cdeacf	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › affiche les six produits du catalogue	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:45:02.965215+00	dev	2026-10-12 12:45:02.965215+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
a528dee8-c7b5-45e0-ae48-fbb73d320787	be93af9c-6d55-40a3-a432-6f98fd300c13	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › trie les produits par prix croissant	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:45:03.031956+00	dev	2026-10-12 12:45:03.031956+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
5bacfcef-5238-4d85-ac90-2b3d3318b066	03f2bd14-310b-40c4-98cd-403a38526c96	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/catalogue.spec.ts	Catalogue › ouvre la fiche d’un produit	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:45:03.115361+00	dev	2026-10-12 12:45:03.115361+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
c0341c54-a19a-4893-a0e2-23d781665788	a420130e-db79-424c-8dc9-25f714dc3be6	API	Playwright	TypeScript	\N	\N	saucedemo/app-tests/api.spec.ts	Contrat HTTP › expose le manifeste PWA et ses icônes	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:45:03.195231+00	dev	2026-10-12 12:45:03.195231+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
faff7c49-fe7e-42d4-abb4-72d97374bbf3	d254040b-f43a-4181-944f-27c1d035d594	BDD	Playwright	\N	\N	\N	saucedemo/features/panier.feature	Ajouter un produit au panier depuis le catalogue	Ajouter un produit au panier	# language: fr\nFonctionnalité: Ajouter un produit au panier\n\n  @REQ-10 @AC-10-1\n  Scénario: Ajouter un produit au panier depuis le catalogue\n    Étant donné que je suis connecté en tant que "standard_user"\n    Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n    Alors le badge du panier affiche "1"\n    Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"	{}	["bdd"]	{}	[]	f	2026-10-12 12:45:04.532535+00	qa1	2026-10-12 12:45:04.682126+00	qa1	1	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
6613178a-91e7-494a-a68e-7273e47b0f6d	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › visualise le contenu du panier	\N	\N	{}	["saucedemo", "smoke"]	{}	[]	f	2026-10-12 12:45:05.561361+00	dev	2026-10-12 12:45:05.561361+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
501233d9-f1f0-4264-b2eb-304542fe7c34	9fdec814-d958-4de8-855a-e1a27cd20933	UI	Playwright	TypeScript	\N	\N	saucedemo/app-tests/panier.spec.ts	Panier › problem_user retire un produit depuis le catalogue @fail	\N	\N	{}	["saucedemo"]	{}	[]	f	2026-10-12 12:45:05.625649+00	dev	2026-10-12 12:45:05.625649+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
37ccc591-522a-440a-9ff7-5de09b0e31ec	7239fab8-aed6-4e47-a3fe-b60e84557eab	PERFORMANCE	Playwright	TypeScript	\N	\N	saucedemo/app-tests/performance.spec.ts	Performance › temps de chargement du catalogue	\N	\N	{"seuilMs": 3000, "iterations": 5}	["saucedemo"]	{}	[]	f	2026-10-12 12:45:05.69156+00	dev	2026-10-12 12:45:05.69156+00	dev	0	7f4d34a7-93a1-436d-b7f8-6de6e60484b5
\.


--
-- Data for Name: automation_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."automation_frameworks" ("id", "technique", "name", "position", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
f3badc46-b46e-4df3-96bf-63f08a3249a7	BDD	Cucumber-JVM	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
08eb85e6-74c0-409b-a68f-8711d5f2c374	BDD	Cucumber-JS	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
92e192e8-1838-4421-a6c1-e81736cae9f3	BDD	Behave	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
a157b4fb-ef76-4742-abeb-4853b23a4352	BDD	SpecFlow	4	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
7886602f-c867-4757-bb30-c3dab03a670b	BDD	Karate	5	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
27a6bb9f-f104-4166-98c1-d3eb246a04ff	UNIT	JUnit 5	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
0cfa5f7a-5c37-4404-95c3-d94d25c84c2d	UNIT	Kotest	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
0d153537-ada8-4ba1-b8f3-663a54fcc255	UNIT	pytest	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
0587d9ef-fffa-42f5-b65b-f2631d463276	UNIT	Jest	4	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
aeb62e59-7724-4e13-9588-d69e5b7f757c	UNIT	Vitest	5	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
07c60fc6-78cf-451d-b383-b7e40e791794	UI	Playwright	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
15c92924-acb1-4803-b217-1ae7db2d607c	UI	Selenium	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
99647362-5a7b-4909-b1c6-614bbde731d4	UI	Cypress	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
10fc7161-ffbd-4430-aa59-816db367baeb	UI	Appium	4	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
3d53dceb-509a-4816-a6b5-412c30f4336b	API	REST Assured	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
972d3107-a8ce-41e8-9045-fa26bdeda98c	API	Karate	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
492533e9-835f-4acc-b6bc-4c2f07a4bad7	API	Postman/Newman	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
aa9f37e6-8a41-406a-b757-6dabe4bf2436	API	pytest + requests	4	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
1167742a-1b29-4e47-b05d-6c745b77b2a3	KEYWORD	Robot Framework	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
a25b73be-6948-45c7-8a2b-a9628da140b9	DATA_DRIVEN	JUnit 5	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
8cb04979-c36f-4ad3-abfa-20690102c7fe	DATA_DRIVEN	pytest	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
3e1b60e3-5de4-4045-993b-3a0b48ceb91f	DATA_DRIVEN	Playwright	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
76c3b558-b305-4239-a1a0-ebcfd1822440	DATA_DRIVEN	Cucumber-JVM	4	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
972e447a-4e20-4f0b-8b1e-349b886005a6	PERFORMANCE	Gatling	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
edb538d7-f7e6-4ad8-8155-021920525b0e	PERFORMANCE	k6	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
64dfaf40-22c5-42f2-8a14-58503fcf1ba7	PERFORMANCE	JMeter	3	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
68b4aa67-661a-4a47-8a9a-02fca4b7ffea	CONTRACT	Pact	1	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
b9a3f29b-518b-4af9-9c41-1027b3db242c	CONTRACT	Spring Cloud Contract	2	2026-10-12 12:44:34.047375+00	system	2026-10-12 12:44:34.047375+00	system	0
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
ba658130-dbb2-477f-b71a-8710b13cee81	0bce208d-4e06-41c4-869a-01d4af1d45b2	cc8fecbd-629e-4b49-9cb5-301da0d06f13	1	\N	4	12	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.524377+00	qa1	0	\N	\N
0832b8cb-7b2b-4812-a45a-827d0109ffc4	0bce208d-4e06-41c4-869a-01d4af1d45b2	c908281b-629c-4e68-a53c-cc6608cdeacf	1	\N	5	6	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.524377+00	qa1	0	\N	\N
cae6f2e3-4248-4d47-a1ad-f484af484987	0bce208d-4e06-41c4-869a-01d4af1d45b2	be93af9c-6d55-40a3-a432-6f98fd300c13	1	\N	6	3	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.524377+00	qa1	0	\N	\N
7ce7ffb1-df93-4634-a7c7-719d0f87b1b9	0bce208d-4e06-41c4-869a-01d4af1d45b2	03f2bd14-310b-40c4-98cd-403a38526c96	1	\N	7	3	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.524377+00	qa1	0	\N	\N
e6b54c79-5ca6-40ca-9640-c3faa2234c80	0bce208d-4e06-41c4-869a-01d4af1d45b2	a420130e-db79-424c-8dc9-25f714dc3be6	1	\N	8	6	2026-10-12 12:45:13.759547+00	qa1	2026-10-12 12:45:13.759547+00	qa1	0	\N	\N
191d90c7-821c-4046-b4e9-5c6115c960ac	0bce208d-4e06-41c4-869a-01d4af1d45b2	700ee46f-2e16-4595-8e42-60df8efba238	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	1	16	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.806136+00	qa1	1	Comptes	0
0025c45e-4906-48b3-9709-b7a8f557751c	0bce208d-4e06-41c4-869a-01d4af1d45b2	700ee46f-2e16-4595-8e42-60df8efba238	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	2	16	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.82584+00	qa1	1	Comptes	1
1bdc4ca4-05b1-4952-af3a-ac33ccdc7e85	0bce208d-4e06-41c4-869a-01d4af1d45b2	700ee46f-2e16-4595-8e42-60df8efba238	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	3	16	2026-10-12 12:45:13.524377+00	qa1	2026-10-12 12:45:13.840352+00	qa1	1	Comptes	2
2666ccf3-5851-40cd-a940-c5d50df985b5	876bf075-731a-4542-ac54-529ee2ff7c8b	d254040b-f43a-4181-944f-27c1d035d594	2	\N	3	12	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.094192+00	qa1	0	\N	\N
5c40ceb8-8914-440f-87a1-ec6db8704813	876bf075-731a-4542-ac54-529ee2ff7c8b	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	1	\N	4	12	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.094192+00	qa1	0	\N	\N
8b6ff943-c9ff-44ba-b5a4-f722cbc25b0b	876bf075-731a-4542-ac54-529ee2ff7c8b	9fdec814-d958-4de8-855a-e1a27cd20933	1	\N	7	6	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.094192+00	qa1	0	\N	\N
ebab618f-36b5-41f4-b6cc-5cd7dc290c41	876bf075-731a-4542-ac54-529ee2ff7c8b	7239fab8-aed6-4e47-a3fe-b60e84557eab	1	\N	8	6	2026-10-12 12:45:47.120741+00	qa1	2026-10-12 12:45:47.120741+00	qa1	0	\N	\N
dac7898a-c4cf-4ea4-a848-816d1d7a9c69	876bf075-731a-4542-ac54-529ee2ff7c8b	187c5fea-f6d8-4f2c-9980-e010cab078a0	1	6ba2b9d3-29bb-4bed-9e9e-3830a752aef7	1	16	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.159007+00	qa1	1	\N	\N
abe23808-2f33-4ccb-8740-10a7f8853f4a	876bf075-731a-4542-ac54-529ee2ff7c8b	b0393b4a-992f-441a-9e85-d6a27de9108a	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	2	16	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.173995+00	qa1	1	\N	\N
fe63aa35-714b-4991-864f-a28506ada242	876bf075-731a-4542-ac54-529ee2ff7c8b	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	5	12	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.188328+00	qa1	1	Produits	0
15750411-f41d-4912-85a1-301a544f99ca	876bf075-731a-4542-ac54-529ee2ff7c8b	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	65a7a55a-d8a6-438e-90ae-a9788fb611eb	6	12	2026-10-12 12:45:47.094192+00	qa1	2026-10-12 12:45:47.202645+00	qa1	1	Produits	1
9efddffd-2636-433e-be02-6d65b9531f24	d6866772-c3cd-4fbc-9865-a644c6069f09	a420130e-db79-424c-8dc9-25f714dc3be6	1	\N	1	0	2026-10-12 12:46:19.92335+00	qa1	2026-10-12 12:46:19.92335+00	qa1	0	\N	\N
74c0f119-8c46-4594-b4b9-bec8958fa79a	d6866772-c3cd-4fbc-9865-a644c6069f09	cc8fecbd-629e-4b49-9cb5-301da0d06f13	1	\N	2	0	2026-10-12 12:46:19.930911+00	qa1	2026-10-12 12:46:19.930911+00	qa1	0	\N	\N
58b04fa8-d7e2-4f7d-bdf3-57ddb33b9c65	d6866772-c3cd-4fbc-9865-a644c6069f09	c908281b-629c-4e68-a53c-cc6608cdeacf	1	\N	3	0	2026-10-12 12:46:19.935146+00	qa1	2026-10-12 12:46:19.935146+00	qa1	0	\N	\N
0bf39955-ba44-49da-8599-b50d8896b80a	d6866772-c3cd-4fbc-9865-a644c6069f09	be93af9c-6d55-40a3-a432-6f98fd300c13	1	\N	4	0	2026-10-12 12:46:19.939436+00	qa1	2026-10-12 12:46:19.939436+00	qa1	0	\N	\N
d39938f5-3520-4478-8fa8-bcf23d4906be	d6866772-c3cd-4fbc-9865-a644c6069f09	03f2bd14-310b-40c4-98cd-403a38526c96	1	\N	5	0	2026-10-12 12:46:19.944156+00	qa1	2026-10-12 12:46:19.944156+00	qa1	0	\N	\N
214e80ff-26cf-408b-ae29-97822e0c6279	d6866772-c3cd-4fbc-9865-a644c6069f09	d254040b-f43a-4181-944f-27c1d035d594	2	\N	6	0	2026-10-12 12:46:19.948247+00	qa1	2026-10-12 12:46:19.948247+00	qa1	0	\N	\N
54ff1cac-d7eb-4581-8173-c7194083fad2	d6866772-c3cd-4fbc-9865-a644c6069f09	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	1	\N	7	0	2026-10-12 12:46:19.95335+00	qa1	2026-10-12 12:46:19.95335+00	qa1	0	\N	\N
32023f18-a2af-4bd1-bded-49174c184f80	d6866772-c3cd-4fbc-9865-a644c6069f09	9fdec814-d958-4de8-855a-e1a27cd20933	1	\N	8	0	2026-10-12 12:46:19.95836+00	qa1	2026-10-12 12:46:19.95836+00	qa1	0	\N	\N
fa6af60f-8f38-4908-b801-ef285eb85a21	d6866772-c3cd-4fbc-9865-a644c6069f09	7239fab8-aed6-4e47-a3fe-b60e84557eab	1	\N	9	0	2026-10-12 12:46:19.962828+00	qa1	2026-10-12 12:46:19.962828+00	qa1	0	\N	\N
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."campaigns" ("id", "project_id", "campaign_key", "key_number", "name", "scope_type", "sprint_id", "release_id", "environment", "build_version", "status", "planned_start", "planned_end", "created_at", "created_by", "updated_at", "updated_by", "version", "folder") FROM stdin;
0bce208d-4e06-41c4-869a-01d4af1d45b2	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CMP-1	1	Recette sprint 1	SPRINT	a0c8470f-6717-4499-b373-b4efa2bdbaae	\N	recette	1.0.0-s1	COMPLETED	2026-09-28	2026-10-09	2026-10-12 12:45:13.27892+00	qa1	2026-10-12 12:45:42.92409+00	qa1	3	Release 1.0/Recettes de sprint
876bf075-731a-4542-ac54-529ee2ff7c8b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CMP-2	2	Recette sprint 2	SPRINT	22c2616c-7486-4747-8085-a9eb65ee0ea5	\N	recette	1.0.0-s2	IN_PROGRESS	2026-10-12	2026-10-23	2026-10-12 12:45:47.070556+00	qa1	2026-10-12 12:45:48.140007+00	qa2	2	Release 1.0/Recettes de sprint
d6866772-c3cd-4fbc-9865-a644c6069f09	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CMP-3	3	Intégration continue — main	RELEASE	\N	25d7c25e-ee25-4a23-9f89-d9273c419eb5	ci	main	IN_PROGRESS	2026-09-28	2026-10-23	2026-10-12 12:46:18.671119+00	qa1	2026-10-12 12:46:19.926017+00	qa1	2	Release 1.0/Intégration continue
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."checklist_items" ("id", "project_id", "kind", "position", "label", "rule", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
08a79e44-00b2-4b98-8386-e48098e5e8c8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOR	1	Au moins un critère d'acceptation	HAS_ACCEPTANCE_CRITERION	2026-10-12 12:44:48.207427+00	admin	2026-10-12 12:44:48.207427+00	admin	0
7350dd0b-97c8-4cb4-9662-aec3286d47cb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOR	2	Estimation renseignée	ESTIMATED	2026-10-12 12:44:48.207933+00	admin	2026-10-12 12:44:48.207933+00	admin	0
a6293675-75ec-447b-91dc-4fce400d74a2	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOR	3	Story comprise et acceptée par l'équipe	\N	2026-10-12 12:44:48.207933+00	admin	2026-10-12 12:44:48.207933+00	admin	0
79c5aaf5-5092-459c-a67b-f9102974fbdb	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOD	1	Au moins un test lié	HAS_LINKED_TEST	2026-10-12 12:44:48.207933+00	admin	2026-10-12 12:44:48.207933+00	admin	0
c50882a1-cd98-4db5-89a1-42b82a3d006c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOD	2	Tous les tests liés passés	ALL_LINKED_TESTS_PASSED	2026-10-12 12:44:48.208553+00	admin	2026-10-12 12:44:48.208553+00	admin	0
c3f58a05-5d51-4646-a5e1-d7d5d86d7167	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOD	3	Aucune anomalie bloquante ouverte	NO_BLOCKING_DEFECT_OPEN	2026-10-12 12:44:48.208553+00	admin	2026-10-12 12:44:48.208553+00	admin	0
57ac2a2a-cd44-47c3-bc28-7aeae1720fe2	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DOD	4	Code revu et intégré	\N	2026-10-12 12:44:48.208553+00	admin	2026-10-12 12:44:48.208553+00	admin	0
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."comments" ("id", "requirement_id", "author", "text", "question", "resolved_at", "resolved_by", "edited_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9c758d7b-89b1-4a90-8b87-e757528b5963	ad2028b8-e429-450d-aa56-ca0831aedee5	po	Le format du code postal est-il contrôlé ?	t	\N	\N	\N	2026-10-12 12:44:59.266932+00	po	2026-10-12 12:44:59.266932+00	po	0
210cad9d-6639-4251-8220-971ac2b676bd	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	po	@qa1 penser à vérifier le panier après un retour au catalogue (« Continue Shopping »).	f	\N	\N	\N	2026-10-12 12:45:00.136807+00	po	2026-10-12 12:45:00.136807+00	po	0
\.


--
-- Data for Name: defect_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_executions" ("defect_id", "execution_id") FROM stdin;
3b0347ce-858f-4973-8153-8658754c8c7f	c19047cf-21b0-4417-8c80-eb7701404639
cd2537b4-e904-4a71-84ef-dea9b7e4b306	a6c9671a-5602-42eb-a1f5-1d963ab14b64
\.


--
-- Data for Name: defect_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defect_requirements" ("defect_id", "requirement_id") FROM stdin;
3b0347ce-858f-4973-8153-8658754c8c7f	d96e0b06-c6fc-43c9-b110-ea61b93b8b56
3b0347ce-858f-4973-8153-8658754c8c7f	636a60d1-7053-4d2b-a980-0ed4fc5a85f6
cd2537b4-e904-4a71-84ef-dea9b7e4b306	d96e0b06-c6fc-43c9-b110-ea61b93b8b56
cd2537b4-e904-4a71-84ef-dea9b7e4b306	636a60d1-7053-4d2b-a980-0ed4fc5a85f6
\.


--
-- Data for Name: defects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."defects" ("id", "project_id", "defect_key", "key_number", "title", "description", "severity", "status", "external_ref", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
3b0347ce-858f-4973-8153-8658754c8c7f	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEF-1	1	problem_user : « Remove » sur le catalogue ne retire pas le produit	**Test** : TC-2 Retirer un produit depuis le catalogue et le panier (version 1, tentative 1)\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Étapes pour reproduire**\n\n1. Ouvrir https://www.saucedemo.com\n2. Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »\n3. Cliquer « Add to cart » sur Sauce Labs Backpack\n4. Ouvrir le panier\n5. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack\n\n**Attendu** : Le badge du panier disparaît\n**Obtenu** : Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.\n	MAJOR	OPEN	\N	2026-10-12 12:45:50.326257+00	qa2	2026-10-12 12:45:50.332503+00	qa2	1
cd2537b4-e904-4a71-84ef-dea9b7e4b306	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEF-2	2	TC-12 Explorer le panier : problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	**Charte** : TC-12 Explorer le panier\n**Mission** : Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.\n**Session** : tentative 1 de qa1, constat à 26:30\n**Campagne** : CMP-2 Recette sprint 2\n**Environnement** : recette · **Build** : 1.0.0-s2\n\n**Constat**\n\nproblem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt\n	MAJOR	OPEN	\N	2026-10-12 12:45:54.394032+00	qa1	2026-10-12 12:45:54.396597+00	qa1	1
\.


--
-- Data for Name: example_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."example_cards" ("id", "requirement_id", "kind", "rule_id", "text", "position", "converted_to", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
d8204414-28cf-427b-910c-d76e16f9f705	ad2028b8-e429-450d-aa56-ca0831aedee5	RULE	\N	Prénom, nom et code postal sont obligatoires	1	\N	2026-10-12 12:44:58.856833+00	po	2026-10-12 12:44:58.856833+00	po	0
bf10a4d8-239b-4124-bbe8-8125e8227d36	ad2028b8-e429-450d-aa56-ca0831aedee5	EXAMPLE	d8204414-28cf-427b-910c-d76e16f9f705	Code postal vide : « Error: Postal Code is required »	1	\N	2026-10-12 12:44:58.9723+00	po	2026-10-12 12:44:58.9723+00	po	0
78d2362f-47e3-41b0-bc17-612d014097c6	ad2028b8-e429-450d-aa56-ca0831aedee5	EXAMPLE	d8204414-28cf-427b-910c-d76e16f9f705	Jean / Dupont / 75001 : passage au récapitulatif	2	\N	2026-10-12 12:44:59.036435+00	po	2026-10-12 12:44:59.036435+00	po	0
54dafe72-6fcb-435b-9ae1-8f384f889ae6	ad2028b8-e429-450d-aa56-ca0831aedee5	RULE	\N	Le bouton « Cancel » ramène au panier	2	\N	2026-10-12 12:44:59.150382+00	po	2026-10-12 12:44:59.150382+00	po	0
96b785dc-6efd-43a2-8396-c58956f8976e	ad2028b8-e429-450d-aa56-ca0831aedee5	EXAMPLE	54dafe72-6fcb-435b-9ae1-8f384f889ae6	Annulation : le panier garde ses 2 produits	3	\N	2026-10-12 12:44:59.207473+00	po	2026-10-12 12:44:59.207473+00	po	0
\.


--
-- Data for Name: execution_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."execution_servers" ("id", "name", "base_url", "auth_type", "api_token", "webhook_secret", "token_id", "token_hint", "paired_at", "status", "last_heartbeat", "last_error", "server_version", "techniques", "frameworks", "environments", "agents", "enabled", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
1cd84867-4524-4972-a681-84ea0d4a8cd5	Serveur d'exécution	http://localhost:8091	SERVER_TOKEN	\N	\N	\N	\N	\N	UNPAIRED	\N	\N	0.1.0-SNAPSHOT	["API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"]	["JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact", "Playwright", "Cypress", "Selenium", "pytest", "pytest + requests", "Robot Framework", "Cucumber-JS"]	[]	4	t	2026-10-12 12:44:49.613586+00	admin	2026-10-12 12:45:59.071838+00	system	3
\.


--
-- Data for Name: executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."executions" ("id", "campaign_item_id", "test_case_id", "attempt", "test_case_version", "status", "status_overridden", "started_at", "ended_at", "duration_ms", "comment", "executed_by", "origin", "data_set_name", "data_set_row", "parameter_values", "created_at", "created_by", "updated_at", "updated_by", "version", "run_id") FROM stdin;
d4612c4c-9021-4594-9291-c3e439601b89	191d90c7-821c-4046-b4e9-5c6115c960ac	700ee46f-2e16-4595-8e42-60df8efba238	1	1	PASSED	f	2026-10-12 12:45:14.689614+00	2026-10-12 12:45:15.403623+00	714	\N	qa1	MANUAL	Comptes	0	{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 12:45:14.695002+00	qa1	2026-10-12 12:45:15.405544+00	qa1	1	\N
d9e8fbe9-e6ce-48f2-9393-b7f292b2341d	0025c45e-4906-48b3-9709-b7a8f557751c	700ee46f-2e16-4595-8e42-60df8efba238	1	1	PASSED	f	2026-10-12 12:45:15.443157+00	2026-10-12 12:45:15.47821+00	35	\N	qa1	MANUAL	Comptes	1	{"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}	2026-10-12 12:45:15.445103+00	qa1	2026-10-12 12:45:15.478734+00	qa1	1	\N
9aacec72-9323-4b91-a489-002a23a761c7	1bdc4ca4-05b1-4952-af3a-ac33ccdc7e85	700ee46f-2e16-4595-8e42-60df8efba238	1	1	PASSED	f	2026-10-12 12:45:15.493059+00	2026-10-12 12:45:15.532516+00	39	\N	qa1	MANUAL	Comptes	2	{"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}	2026-10-12 12:45:15.494574+00	qa1	2026-10-12 12:45:15.533563+00	qa1	1	\N
c45bd0cc-db64-4d57-8a0c-a2279e820e79	e6b54c79-5ca6-40ca-9640-c3faa2234c80	a420130e-db79-424c-8dc9-25f714dc3be6	1	1	PASSED	f	2026-10-12 12:45:36.963681+00	2026-10-12 12:45:39.368716+00	2404	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:16.921089+00	dev	2026-10-12 12:45:39.392523+00	anonymousUser	2	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e
4b444e83-a865-457a-8b78-3b61767901e8	0832b8cb-7b2b-4812-a45a-827d0109ffc4	c908281b-629c-4e68-a53c-cc6608cdeacf	1	1	PASSED	f	2026-10-12 12:45:36.963666+00	2026-10-12 12:45:39.640102+00	2675	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:16.921089+00	dev	2026-10-12 12:45:39.652903+00	anonymousUser	2	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e
f7dd5f19-b34f-4fd7-84cb-b3bc5a24c340	ba658130-dbb2-477f-b71a-8710b13cee81	cc8fecbd-629e-4b49-9cb5-301da0d06f13	1	1	PASSED	f	2026-10-12 12:45:36.963755+00	2026-10-12 12:45:40.001809+00	3037	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:16.920744+00	dev	2026-10-12 12:45:40.014923+00	anonymousUser	2	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e
1b062258-7b85-4cee-b9cf-5191d8bf2e5d	cae6f2e3-4248-4d47-a1ad-f484af484987	be93af9c-6d55-40a3-a432-6f98fd300c13	1	1	PASSED	f	2026-10-12 12:45:36.963744+00	2026-10-12 12:45:39.654581+00	2690	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:16.921089+00	dev	2026-10-12 12:45:40.192099+00	anonymousUser	2	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e
04073aef-e58c-4e5c-a2d2-092a7de8605e	7ce7ffb1-df93-4634-a7c7-719d0f87b1b9	03f2bd14-310b-40c4-98cd-403a38526c96	1	1	PASSED	f	2026-10-12 12:45:39.412567+00	2026-10-12 12:45:41.034559+00	1621	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:16.921089+00	dev	2026-10-12 12:45:41.047069+00	anonymousUser	2	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e
c19047cf-21b0-4417-8c80-eb7701404639	dac7898a-c4cf-4ea4-a848-816d1d7a9c69	187c5fea-f6d8-4f2c-9980-e010cab078a0	1	1	FAILED	f	2026-10-12 12:45:48.135397+00	2026-10-12 12:45:48.885463+00	750	\N	qa2	MANUAL	\N	\N	{}	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.886495+00	qa2	1	\N
205ac971-ea1c-4c48-96ff-7edcc4cc97b7	fe63aa35-714b-4991-864f-a28506ada242	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	1	PASSED	f	2026-10-12 12:45:51.019603+00	2026-10-12 12:45:51.968238+00	948	\N	qa1	MANUAL	Produits	0	{"prix": "$29.99", "produit": "Sauce Labs Backpack"}	2026-10-12 12:45:51.022885+00	qa1	2026-10-12 12:45:51.96927+00	qa1	1	\N
031f1bc4-8603-4eef-b19c-27503019c44d	15750411-f41d-4912-85a1-301a544f99ca	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	1	PASSED	f	2026-10-12 12:45:52.019009+00	2026-10-12 12:45:52.082412+00	63	\N	qa1	MANUAL	Produits	1	{"prix": "$9.99", "produit": "Sauce Labs Bike Light"}	2026-10-12 12:45:52.021682+00	qa1	2026-10-12 12:45:52.083446+00	qa1	1	\N
a6c9671a-5602-42eb-a1f5-1d963ab14b64	abe23808-2f33-4ccb-8740-10a7f8853f4a	b0393b4a-992f-441a-9e85-d6a27de9108a	1	1	FAILED	f	2026-10-12 13:00:00+00	2026-10-12 13:55:00+00	3300000	\N	qa1	MANUAL	\N	\N	{}	2026-10-12 12:45:53.088247+00	qa1	2026-10-12 12:45:55.678841+00	qa1	1	\N
626c41ad-9eb4-4749-a2ee-068864d0e908	2666ccf3-5851-40cd-a940-c5d50df985b5	d254040b-f43a-4181-944f-27c1d035d594	1	2	PASSED	f	2026-10-12 12:46:10.100817+00	2026-10-12 12:46:13.117769+00	3016	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:58.320295+00	dev	2026-10-12 12:46:13.130516+00	anonymousUser	2	d2836591-3c64-4148-8f7c-c3b30b68bf62
8aba4a7f-ddfc-49b2-b69f-97607a6ede86	5c40ceb8-8914-440f-87a1-ec6db8704813	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	1	1	PASSED	f	2026-10-12 12:46:10.100804+00	2026-10-12 12:46:13.13982+00	3038	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:58.320295+00	dev	2026-10-12 12:46:13.150741+00	anonymousUser	2	d2836591-3c64-4148-8f7c-c3b30b68bf62
b74099fc-abc0-4e38-84e2-f90d5f54849d	ebab618f-36b5-41f4-b6cc-5cd7dc290c41	7239fab8-aed6-4e47-a3fe-b60e84557eab	1	1	PASSED	f	2026-10-12 12:46:10.100786+00	2026-10-12 12:46:13.599274+00	3498	\N	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:58.320946+00	dev	2026-10-12 12:46:13.608404+00	anonymousUser	2	d2836591-3c64-4148-8f7c-c3b30b68bf62
a3185a8a-6d52-4027-9823-97ed15832c74	8b6ff943-c9ff-44ba-b5a4-f722cbc25b0b	9fdec814-d958-4de8-855a-e1a27cd20933	1	1	FAILED	f	2026-10-12 12:46:10.100788+00	2026-10-12 12:46:16.115191+00	6013	le badge doit disparaître après le retrait\n[chromium] › panier.spec.ts:25:3 › Panier › problem_user retire un produit depuis le catalogue @fail @REQ-12 \n\n    Error: le badge doit disparaître après le retrait\n\n    expect(locator).toHaveCount(expected) failed\n\n    Locator:  getByTestId('shopping-cart-badge')\n    Expected: 0\n    Received: 1\n    Timeout:  3000ms\n\n    Call log:\n      - le badge doit disparaître après le retrait getByTestId('shopping-cart-badge') with timeout 3000ms\n      - waiting for getByTestId('shopping-cart-badge')\n        10 × locator resolved to 1 element\n           - unexpected value "1"\n\n\n      28 |     await expect(page.getByTestId('shopping-cart-badge')).toHaveText('1');\n      29 |     await page.getByTestId('remove-sauce-labs-backpack').click();\n    > 30 |     await expect(page.getByTestId('shopping-cart-badge'), 'le badge doit disparaître après le retrait').toHaveCount(0, { timeout: 3_000 });\n         |                                                                                                         ^\n      31 |   });\n      32 | });\n      33 |\n        at /data/jobs/job-634b1209/workspace/saucedemo/app-tests/panier.spec.ts:30:105\n\n    attachment #1: screenshot (image/png) ──────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/test-failed-1.png\n    ────────────────────────────────────────────────────────────────────────────────────────────────\n\n    Error Context: ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/error-context.md\n\n    attachment #3: trace (application/zip) ─────────────────────────────────────────────────────────\n    ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chromium/trace.zip\n    Usage:\n\n        npx playwright show-trace ../../../tests/TC-10-1/results/panier-Panier-problem-user-9cd4c-it-depuis-le-catalogue-fail-chr…	Serveur d'exécution	AUTOMATED	\N	\N	{}	2026-10-12 12:45:58.320295+00	dev	2026-10-12 12:46:16.127755+00	anonymousUser	2	d2836591-3c64-4148-8f7c-c3b30b68bf62
92833096-f77e-4781-b2d7-3bf87da7900f	9efddffd-2636-433e-be02-6d65b9531f24	a420130e-db79-424c-8dc9-25f714dc3be6	1	1	PASSED	f	2026-10-12 12:46:19.360068+00	2026-10-12 12:46:19.922068+00	562	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.925481+00	qa1	2026-10-12 12:46:19.925481+00	qa1	0	\N
3d090594-0935-47a7-bcb0-2e2a0f30f08a	74c0f119-8c46-4594-b4b9-bec8958fa79a	cc8fecbd-629e-4b49-9cb5-301da0d06f13	1	1	PASSED	f	2026-10-12 12:46:16.407068+00	2026-10-12 12:46:19.922068+00	3515	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.93255+00	qa1	2026-10-12 12:46:19.93255+00	qa1	0	\N
781b906d-fc9e-4391-8aa1-e1a976d272c5	58b04fa8-d7e2-4f7d-bdf3-57ddb33b9c65	c908281b-629c-4e68-a53c-cc6608cdeacf	1	1	PASSED	f	2026-10-12 12:46:16.717068+00	2026-10-12 12:46:19.922068+00	3205	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.936214+00	qa1	2026-10-12 12:46:19.936214+00	qa1	0	\N
c756f1a3-5e6a-4b82-9669-0d5779832f91	0bf39955-ba44-49da-8599-b50d8896b80a	be93af9c-6d55-40a3-a432-6f98fd300c13	1	1	PASSED	f	2026-10-12 12:46:19.480068+00	2026-10-12 12:46:19.922068+00	442	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.94106+00	qa1	2026-10-12 12:46:19.94106+00	qa1	0	\N
c3bfd90b-7cb9-44ea-8f30-04473909fb46	d39938f5-3520-4478-8fa8-bcf23d4906be	03f2bd14-310b-40c4-98cd-403a38526c96	1	1	PASSED	f	2026-10-12 12:46:19.385068+00	2026-10-12 12:46:19.922068+00	537	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.945704+00	qa1	2026-10-12 12:46:19.945704+00	qa1	0	\N
ef2e0d26-8c0f-4722-baf1-9b166d10a043	214e80ff-26cf-408b-ae29-97822e0c6279	d254040b-f43a-4181-944f-27c1d035d594	1	2	PASSED	f	2026-10-12 12:46:19.235068+00	2026-10-12 12:46:19.922068+00	687	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.949832+00	qa1	2026-10-12 12:46:19.949832+00	qa1	0	\N
0dcc5020-427c-4582-ba9b-d5cb6aa0b594	54ff1cac-d7eb-4581-8173-c7194083fad2	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	1	1	PASSED	f	2026-10-12 12:46:19.375068+00	2026-10-12 12:46:19.922068+00	547	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.954438+00	qa1	2026-10-12 12:46:19.954438+00	qa1	0	\N
3f107009-98a4-4799-b6d6-993b721ae52b	32023f18-a2af-4bd1-bded-49174c184f80	9fdec814-d958-4de8-855a-e1a27cd20933	1	1	FAILED	f	2026-10-12 12:46:16.454068+00	2026-10-12 12:46:19.922068+00	3468	Import « junit-saucedemo.xml » : le badge doit disparaître après le retrait	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.959727+00	qa1	2026-10-12 12:46:19.959727+00	qa1	0	\N
51895719-b67b-4ec9-8729-5c325aaaf121	fa6af60f-8f38-4908-b801-ef285eb85a21	7239fab8-aed6-4e47-a3fe-b60e84557eab	1	1	PASSED	f	2026-10-12 12:46:19.108068+00	2026-10-12 12:46:19.922068+00	814	Import « junit-saucedemo.xml »	import	AUTOMATED	\N	\N	{}	2026-10-12 12:46:19.963344+00	qa1	2026-10-12 12:46:19.963344+00	qa1	0	\N
\.


--
-- Data for Name: exploratory_charters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_charters" ("id", "test_case_id", "mission_explore", "mission_with", "mission_to_discover", "areas", "heuristics", "timebox_min", "setup_notes", "targeted_risk", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
59274365-6cbc-438b-8089-da9d2b280b25	b0393b4a-992f-441a-9e85-d6a27de9108a	le panier	les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur	les écarts entre le badge, les boutons du catalogue et le contenu du panier	["Panier", "Catalogue"]	["CRUD", "Goldilocks"]	60	\N	Panier faux au moment de commander	2026-10-12 12:45:05.749649+00	qa1	2026-10-12 12:45:05.749649+00	qa1	0
\.


--
-- Data for Name: exploratory_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."exploratory_sessions" ("id", "execution_id", "state", "timebox_min", "active_seconds", "resumed_at", "draft", "test_pct", "bug_pct", "setup_pct", "areas_covered", "proof_past", "proof_results", "proof_obstacles", "proof_outlook", "proof_feelings", "debriefed_by", "debriefed_at", "approved_by", "approved_at", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	a6c9671a-5602-42eb-a1f5-1d963ab14b64	DEBRIEFED	60	3300	\N	\N	60	25	15	["Panier", "Catalogue"]	Ajouts, retraits et navigation arrière avec standard_user et problem_user.	DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.	Le panier est conservé dans le navigateur : il faut le vider entre deux comptes.	Explorer le checkout dès la release 1.1 ; charte sur la conservation du panier.	4	qa1	2026-10-12 14:10:00+00	po	2026-10-12 14:25:00+00	2026-10-12 12:45:53.08765+00	qa1	2026-10-12 12:45:56.641199+00	po	3
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."flyway_schema_history" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") FROM stdin;
1	1	socle administration	SQL	V1__socle_administration.sql	1514107492	traceagile_demo	2026-10-12 14:44:33.728753	100	t
2	2	requirements	SQL	V2__requirements.sql	-1050946232	traceagile_demo	2026-10-12 14:44:33.859559	152	t
3	3	test cases	SQL	V3__test_cases.sql	550804290	traceagile_demo	2026-10-12 14:44:34.039529	166	t
4	4	test parameters folders	SQL	V4__test_parameters_folders.sql	1300970288	traceagile_demo	2026-10-12 14:44:34.227474	27	t
5	5	traceability	SQL	V5__traceability.sql	1365443046	traceagile_demo	2026-10-12 14:44:34.272316	13	t
6	6	planning	SQL	V6__planning.sql	1356912497	traceagile_demo	2026-10-12 14:44:34.3034	90	t
7	7	campaigns executions defects	SQL	V7__campaigns_executions_defects.sql	-1016759066	traceagile_demo	2026-10-12 14:44:34.41459	147	t
8	8	campaign item data sets	SQL	V8__campaign_item_data_sets.sql	-480663635	traceagile_demo	2026-10-12 14:44:34.582594	13	t
9	9	called test steps	SQL	V9__called_test_steps.sql	-2089413811	traceagile_demo	2026-10-12 14:44:34.613892	13	t
10	10	campaign folders	SQL	V10__campaign_folders.sql	837637463	traceagile_demo	2026-10-12 14:44:34.64775	32	t
11	11	exploratory sessions	SQL	V11__exploratory_sessions.sql	1383191777	traceagile_demo	2026-10-12 14:44:34.697955	58	t
12	12	automated runs	SQL	V12__automated_runs.sql	-53594050	traceagile_demo	2026-10-12 14:44:34.774141	81	t
13	13	run artifacts	SQL	V13__run_artifacts.sql	807949324	traceagile_demo	2026-10-12 14:44:34.871117	27	t
14	14	reports	SQL	V14__reports.sql	442683259	traceagile_demo	2026-10-12 14:44:34.917288	57	t
15	15	comments example mapping	SQL	V15__comments_example_mapping.sql	-126851509	traceagile_demo	2026-10-12 14:44:34.994928	47	t
16	16	attachments	SQL	V16__attachments.sql	-1220010676	traceagile_demo	2026-10-12 14:44:35.060985	32	t
17	17	nfr measurements	SQL	V17__nfr_measurements.sql	268992115	traceagile_demo	2026-10-12 14:44:35.112855	20	t
18	18	named data set rows	SQL	V18__named_data_set_rows.sql	-2016133967	traceagile_demo	2026-10-12 14:44:35.152435	5	t
19	19	git sources	SQL	V19__git_sources.sql	1616532274	traceagile_demo	2026-10-12 14:44:35.174235	60	t
\.


--
-- Data for Name: git_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_projects" ("id", "source_id", "name", "default_branch", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7f4d34a7-93a1-436d-b7f8-6de6e60484b5	9fcf061f-94d0-4c8b-8cfd-577f8f4c51a5	traceagile	depots-git	\N	2026-10-12 12:44:50.356196+00	admin	2026-10-12 12:44:50.356196+00	admin	0
78dbabf1-e11b-4d3f-9ee9-b46b6530538e	28441b43-6161-4b7c-bd8e-5ecd0ed80845	saucedemo-e2e	master	\N	2026-10-12 12:44:50.397518+00	admin	2026-10-12 12:44:50.397518+00	admin	0
\.


--
-- Data for Name: git_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."git_sources" ("id", "name", "base_url", "auth_type", "username", "secret", "description", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
9fcf061f-94d0-4c8b-8cfd-577f8f4c51a5	Dépôt local	file:///depots	NONE	\N	\N	Dépôt TraceAgile monté dans le serveur d’exécution (exemples du guide)	2026-10-12 12:44:50.331891+00	admin	2026-10-12 12:44:50.331891+00	admin	0
28441b43-6161-4b7c-bd8e-5ecd0ed80845	kerware	https://github.com/kerware	NONE	\N	\N	Projets de formation (GitHub, public)	2026-10-12 12:44:50.382+00	admin	2026-10-12 12:44:50.382+00	admin	0
\.


--
-- Data for Name: key_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."key_sequences" ("project_id", "prefix", "next_value") FROM stdin;
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ	18
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC	14
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REL	2
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SPR	3
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	DEF	3
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RUN	3
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	CMP	4
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RPT	3
\.


--
-- Data for Name: manual_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."manual_steps" ("id", "test_case_id", "position", "action", "expected_result", "test_data", "created_at", "created_by", "updated_at", "updated_by", "version", "called_test_case_id", "call_parameters", "call_data_set", "call_data_row") FROM stdin;
5421f846-233d-4750-8d4e-b40ce23d23d0	700ee46f-2e16-4595-8e42-60df8efba238	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	2026-10-12 12:45:02.700993+00	qa1	2026-10-12 12:45:02.700993+00	qa1	0	\N	{}	\N	\N
13639a0d-b8df-4db8-973d-e53092eefec9	700ee46f-2e16-4595-8e42-60df8efba238	2	Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login »	${resultat_attendu}	\N	2026-10-12 12:45:02.701587+00	qa1	2026-10-12 12:45:02.701587+00	qa1	0	\N	{}	\N	\N
b9843c17-5bf8-4d03-a903-c2e62afefa22	187c5fea-f6d8-4f2c-9980-e010cab078a0	1	\N	\N	\N	2026-10-12 12:45:02.804827+00	qa1	2026-10-12 12:45:02.804827+00	qa1	0	700ee46f-2e16-4595-8e42-60df8efba238	{}	Comptes	problem_user
de598ce0-5942-4734-90a6-205e3e83b034	187c5fea-f6d8-4f2c-9980-e010cab078a0	2	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	2026-10-12 12:45:02.804827+00	qa1	2026-10-12 12:45:02.804827+00	qa1	0	\N	{}	\N	\N
583cc5b3-30d3-4501-8ae9-59e9f0e7e62b	187c5fea-f6d8-4f2c-9980-e010cab078a0	3	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	2026-10-12 12:45:02.804827+00	qa1	2026-10-12 12:45:02.804827+00	qa1	0	\N	{}	\N	\N
c386bbba-e035-427a-92b1-93066b65e1e3	187c5fea-f6d8-4f2c-9980-e010cab078a0	4	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	2026-10-12 12:45:02.806049+00	qa1	2026-10-12 12:45:02.806049+00	qa1	0	\N	{}	\N	\N
76742882-e457-4665-9a6d-09c53eee2d12	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	\N	\N	\N	2026-10-12 12:45:05.814877+00	qa1	2026-10-12 12:45:05.814877+00	qa1	0	700ee46f-2e16-4595-8e42-60df8efba238	{}	Comptes	standard_user
59710bcc-a0a9-4221-a89e-4de237a5099c	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	2	Cliquer « Add to cart » sur ${produit}	Le badge du panier affiche 1	\N	2026-10-12 12:45:05.814877+00	qa1	2026-10-12 12:45:05.814877+00	qa1	0	\N	{}	\N	\N
e1281ed4-d679-45f1-a8c9-4af2d3706a4b	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	3	Ouvrir le panier	${produit} est listé : quantité 1, ${prix}	\N	2026-10-12 12:45:05.814877+00	qa1	2026-10-12 12:45:05.814877+00	qa1	0	\N	{}	\N	\N
\.


--
-- Data for Name: nfr_measurements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."nfr_measurements" ("id", "requirement_id", "measured_value", "unit", "metric", "test_key", "run_key", "measured_at", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4a6be6bf-c632-407d-bf7b-3973352db287	26c7900c-066b-49a5-ab2a-3a8e6b22d58f	506	ms	p95Ms	TC-11	RUN-2	2026-10-12 12:46:13.599274+00	TARGET_MET	2026-10-12 12:46:13.61785+00	anonymousUser	2026-10-12 12:46:13.61785+00	anonymousUser	0
\.


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."processed_webhook_events" ("event_id", "run_id", "received_at") FROM stdin;
bba64696-55d3-4281-b55f-673c3e751a1e	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:16.985771+00
3088858b-be92-420d-bac1-982e38c4055d	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:36.97195+00
2952cf15-bca8-4b09-b431-89ec99c52286	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:37.504362+00
9a0b869b-180b-42c8-aec6-af58ac75b65d	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:37.504362+00
c1bca037-8161-4dff-8175-967c145a3d95	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:37.504362+00
59be4cd8-ad12-441e-a154-1d604852cecf	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:39.381506+00
1c259323-6747-418a-8e08-28af8714a73b	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:39.419886+00
60aee94c-8d2a-46ac-892b-5ffb48dc151a	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:39.648229+00
ef10939e-a446-4408-8326-362cc4d497db	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:40.011151+00
c6402f6f-d228-4e9f-b33a-c7b1a6d7205f	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:40.187843+00
9615abef-315d-429c-84e7-555a37684a38	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:41.04225+00
68108f60-5946-44d5-b812-16496a4f23dc	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	2026-10-12 12:45:41.070579+00
7d62048b-6395-4d1c-afba-125909215170	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:45:58.863414+00
cf0f639f-61df-473c-9f2d-fb85f7561703	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:10.108851+00
6f7e98e0-a3d0-425b-b914-c2271d398cae	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:10.62563+00
95fbecb1-6c00-4317-b1f4-77b3c32f8f7e	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:10.626148+00
9e1eba06-f8c5-4726-ae43-a2ce7112a556	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:10.626148+00
f14c3346-51c4-47c3-8173-5446bbd73163	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:13.125915+00
1c0cbacc-912e-47ed-a8ed-20e40dd93f92	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:13.147534+00
8117b0d2-cc32-43f1-a8f5-46aec5d81fc2	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:13.605306+00
0d4ff8ec-8d38-4171-b202-6e789a0eb0f4	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:16.121931+00
f10f08ab-4115-4f5b-a568-0d74d9e33d0b	d2836591-3c64-4148-8f7c-c3b30b68bf62	2026-10-12 12:46:16.146428+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."project_members" ("id", "project_id", "user_id", "role", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
e9a09924-d57a-4c73-ba0e-8b53d604b8e3	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	4980f78c-962c-4fb1-99f3-8b3ebae66490	ADMINISTRATOR	2026-10-12 12:44:48.31717+00	admin	2026-10-12 12:44:48.31717+00	admin	0
61efebf8-8511-4d35-93f8-73e0002fda98	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	8e12d588-2f31-4e08-9f57-f7b1d57c7915	PRODUCT_OWNER	2026-10-12 12:44:48.31817+00	admin	2026-10-12 12:44:48.31817+00	admin	0
5b7502af-2da3-477c-9ef0-20b6ed5d6c5c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	65a7a55a-d8a6-438e-90ae-a9788fb611eb	TESTER	2026-10-12 12:44:48.31817+00	admin	2026-10-12 12:44:48.31817+00	admin	0
24961123-cd49-4d28-9ec9-43c8524459e7	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	6ba2b9d3-29bb-4bed-9e9e-3830a752aef7	TESTER	2026-10-12 12:44:48.31817+00	admin	2026-10-12 12:44:48.31817+00	admin	0
70cdb806-ce82-44b0-b53b-9da51de81a2c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	1d1dc3ef-cf25-4058-abb9-7f739ed73ca0	DEVELOPER	2026-10-12 12:44:48.31817+00	admin	2026-10-12 12:44:48.31817+00	admin	0
add70788-27d6-4c1e-ad49-eb35260a9f31	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	0a4829a1-d19b-4a1d-876b-a9a649d4b9a6	VIEWER	2026-10-12 12:44:48.31817+00	admin	2026-10-12 12:44:48.31817+00	admin	0
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."projects" ("id", "project_key", "name", "description", "archived", "created_at", "created_by", "updated_at", "updated_by", "version", "custom_heuristics", "verdict_rules") FROM stdin;
7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	SWAG	Swag Labs (saucedemo)	Boutique de démonstration www.saucedemo.com — release 1.0 en deux sprints, jusqu’à la visualisation du panier. Le parcours de commande n’est pas encore développé.	f	2026-10-12 12:44:48.191346+00	admin	2026-10-12 12:44:48.191346+00	admin	0	[]	\N
\.


--
-- Data for Name: releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."releases" ("id", "project_id", "release_key", "key_number", "name", "goal", "start_date", "end_date", "status", "closed_at", "closing_report", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
25d7c25e-ee25-4a23-9f89-d9273c419eb5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REL-1	1	Swag Labs 1.0	Connexion, catalogue et panier (la commande viendra en 1.1)	2026-09-28	2026-10-23	ACTIVE	\N	\N	2026-10-12 12:45:10.67799+00	po	2026-10-12 12:45:12.19486+00	po	1
\.


--
-- Data for Name: report_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_definitions" ("id", "project_id", "name", "description", "scope_type", "sections", "default_format", "include_charts", "include_details", "built_in", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
eb4959f9-f357-43e3-b211-b55db72a5a97	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	Bilan de sprint	Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels et recommandation.	SPRINT	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 12:45:45.363758+00	po	2026-10-12 12:45:45.363758+00	po	0
188fe066-6976-4088-b6cd-561c35a3e5e9	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	Bilan de release	Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, avec l'évolution par sprint, la régression finale et les ENF.	RELEASE	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION"]	PDF	t	f	t	2026-10-12 12:45:45.373335+00	po	2026-10-12 12:45:45.373335+00	po	0
f2a42f47-1e89-4423-8bee-b6abba97b7ad	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	Comité qualité Swag Labs	\N	SPRINT	["SUMMARY", "COVERAGE", "EXECUTION", "DEFECTS", "BURNDOWN", "DEFECT_LIST"]	PDF	t	f	f	2026-10-12 12:46:35.424495+00	po	2026-10-12 12:46:35.424495+00	po	0
\.


--
-- Data for Name: report_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."report_snapshots" ("id", "project_id", "report_key", "key_number", "title", "definition_name", "scope_type", "scope", "scope_label", "sections", "include_charts", "include_details", "data", "computed_verdict", "verdict_override", "verdict_comment", "verdict_by", "verdict_at", "frozen", "frozen_at", "frozen_by", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
da24e2aa-a48e-4f5d-bbfc-fe1130e4aafc	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RPT-1	1	Bilan de sprint — SPR-1 — Sprint 1 — Connexion et catalogue	Bilan de sprint	SPRINT	sprint:SPR-1	SPR-1 — Sprint 1 — Connexion et catalogue	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [], "header": {"goal": "Se connecter et parcourir le catalogue", "scope": "sprint:SPR-1", "status": "CLOSED", "endDate": "2026-10-09", "startDate": "2026-09-28", "projectKey": "SWAG", "scopeLabel": "SPR-1 — Sprint 1 — Connexion et catalogue", "generatedAt": "2026-10-12T12:45:45.402597800Z", "generatedBy": null, "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 0, "created": 0, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 0, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Se connecter et parcourir le catalogue", "verdict": "GO", "velocity": 12, "objective": "ACHIEVED", "openDefects": 0, "validationPercent": 100.0, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "failing": [], "criteria": {"percent": 0.0, "numerator": 0.0, "denominator": 6.0}, "execution": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "uncovered": [], "validation": {"percent": 100.0, "numerator": 5.0, "denominator": 5.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-3", "title": "Se connecter avec un compte valide", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-4", "title": "Refuser un compte verrouillé", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-6", "title": "Consulter le catalogue des produits", "points": 3, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-7", "title": "Trier le catalogue", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}, {"key": "REQ-8", "title": "Consulter la fiche d’un produit", "points": 2, "sprint": "SPR-1", "status": "DONE", "outcome": "DONE"}], "donePoints": 12, "doneStories": 5, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 12, "returnedStories": 0, "committedStories": 5, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 0, "notRun": 0, "passed": 3}, {"kind": "AUTOMATED", "other": 0, "total": 5, "failed": 0, "notRun": 0, "passed": 5}], "attempts": 8, "byStatus": {"PASSED": 8}, "attemptsByDay": [{"date": "2026-10-12", "failed": 0, "passed": 8, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": null, "testPct": null, "findings": [], "sessions": 0, "setupPct": null, "debriefed": 0, "totalMinutes": 0, "averageMinutes": null, "defectsPerHour": null, "chartersPlanned": 0, "chartersExecuted": 0, "averageConfidence": null, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 100 %, aucune anomalie bloquante"], "verdict": "GO"}}	GO	\N	\N	\N	\N	t	2026-10-12 12:45:45.440457+00	clôture du sprint	2026-10-12 12:45:45.438452+00	po	2026-10-12 12:45:45.440457+00	po	1
a109fec5-5672-4db0-95fb-1b9a4f0925ee	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	RPT-2	2	Bilan de sprint — SPR-2 — Sprint 2 — Panier	Bilan de sprint	SPRINT	sprint:SPR-2	SPR-2 — Sprint 2 — Panier	["SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS", "RECOMMENDATION"]	t	f	{"nfr": null, "risks": [{"key": "REQ-11", "risk": "HIGH", "title": "Visualiser le contenu du panier", "status": "FAILED"}], "header": {"goal": "Ajouter, visualiser et retirer des produits du panier", "scope": "sprint:SPR-2", "status": "ACTIVE", "endDate": "2026-10-23", "startDate": "2026-10-12", "projectKey": "SWAG", "scopeLabel": "SPR-2 — Sprint 2 — Panier", "generatedAt": "2026-10-12T12:46:32.052933900Z", "generatedBy": "po", "projectName": "Swag Labs (saucedemo)"}, "defects": {"open": 2, "created": 2, "blocking": [], "resolved": 0, "openBySeverity": {"MAJOR": 2, "MINOR": 0, "BLOCKER": 0, "TRIVIAL": 0, "CRITICAL": 0}}, "summary": {"goal": "Ajouter, visualiser et retirer des produits du panier", "verdict": "NO_GO", "velocity": 0, "objective": "NOT_ACHIEVED", "openDefects": 2, "validationPercent": 33.33, "openBlockingDefects": 0}, "burndown": null, "coverage": {"design": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "failing": [{"key": "REQ-11", "title": "Visualiser le contenu du panier", "status": "FAILED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "status": "FAILED"}], "criteria": {"percent": 20.0, "numerator": 1.0, "denominator": 5.0}, "execution": {"percent": 100.0, "numerator": 3.0, "denominator": 3.0}, "uncovered": [], "validation": {"percent": 33.33, "numerator": 1.0, "denominator": 3.0}, "riskWeighted": {"percent": 100.0, "numerator": 10.0, "denominator": 10.0}}, "delivery": {"stories": [{"key": "REQ-10", "title": "Ajouter un produit au panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-11", "title": "Visualiser le contenu du panier", "points": 3, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}, {"key": "REQ-12", "title": "Retirer un produit du panier", "points": 2, "sprint": "SPR-2", "status": "IN_SPRINT", "outcome": "PLANNED"}], "donePoints": 0, "doneStories": 0, "droppedStories": 0, "acceptedStories": 0, "committedPoints": 8, "returnedStories": 0, "committedStories": 3, "carriedOverStories": 0}, "execution": {"flaky": [], "items": 8, "byKind": [{"kind": "MANUAL", "other": 0, "total": 3, "failed": 1, "notRun": 0, "passed": 2}, {"kind": "EXPLORATORY", "other": 0, "total": 1, "failed": 1, "notRun": 0, "passed": 0}, {"kind": "AUTOMATED", "other": 0, "total": 4, "failed": 1, "notRun": 0, "passed": 3}], "attempts": 8, "byStatus": {"FAILED": 3, "PASSED": 5}, "attemptsByDay": [{"date": "2026-10-12", "failed": 3, "passed": 5, "attempts": 8}]}, "defectList": null, "regression": null, "exploratory": {"bugPct": 25.0, "testPct": 60.0, "findings": [{"tester": "qa1", "charter": "Explorer le panier", "results": "DEF-2 : trois produits impossibles à ajouter avec problem_user. Panier cohérent avec standard_user.", "obstacles": "Le panier est conservé dans le navigateur : il faut le vider entre deux comptes."}], "sessions": 1, "setupPct": 15.0, "debriefed": 1, "totalMinutes": 55, "averageMinutes": 55.0, "defectsPerHour": 1.1, "chartersPlanned": 1, "chartersExecuted": 1, "averageConfidence": 4.0, "neverExploredAreas": []}, "sprintTrend": null, "testResults": null, "requirements": null, "recommendation": {"reasons": ["taux de validation 33.33 % < 95 %"], "verdict": "NO_GO"}}	NO_GO	GO_WITH_RESERVATIONS	Go pour la démonstration client : DEF-1 et DEF-2 ne touchent que le compte problem_user ; correctifs attendus au sprint 3.	po	2026-10-12 12:46:33.535771+00	f	\N	\N	2026-10-12 12:46:32.067252+00	po	2026-10-12 12:46:33.535771+00	po	2
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
f57a035e-0d00-4492-97d5-276aaa8b9f79	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	1	{"key": "REQ-3", "tags": null, "type": "USER_STORY", "title": "Se connecter avec un compte valide", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Connexion réussie\\n  Étant donné que je suis sur la page de connexion\\n  Quand je me connecte avec \\"standard_user\\" et \\"secret_sauce\\"\\n  Alors le catalogue \\"Products\\" s'affiche", "[TEXT] Le compte problem_user accède lui aussi au catalogue."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "me connecter avec mon identifiant et mon mot de passe", "planguage.target": null, "userStory.soThat": "accéder au catalogue", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.23049+00	po	2026-10-12 12:44:55.23049+00	po	0
82ef5339-e0f5-492c-a9aa-d5cd488a420f	213f7e56-e2ec-4042-9a29-0ed2bb157e33	1	{"key": "REQ-4", "tags": null, "type": "USER_STORY", "title": "Refuser un compte verrouillé", "status": "READY", "category": null, "criteria": ["[TEXT] Le compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion."], "priority": "MUST", "parentKey": "REQ-2", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "responsable sécurité", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "que les comptes verrouillés ne puissent pas se connecter", "planguage.target": null, "userStory.soThat": "protéger la boutique", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.282667+00	po	2026-10-12 12:44:55.282667+00	po	0
09f9b063-bec2-408c-a07a-f75e22204b05	702601a5-33df-4395-b47c-e3ca85e96993	1	{"key": "REQ-6", "tags": null, "type": "USER_STORY", "title": "Consulter le catalogue des produits", "status": "READY", "category": null, "criteria": ["[TEXT] Les six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart »."], "priority": "MUST", "parentKey": "REQ-5", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir les produits avec leur prix", "planguage.target": null, "userStory.soThat": "choisir mes achats", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.323106+00	po	2026-10-12 12:44:55.323106+00	po	0
02f14307-7254-43cd-adfe-45a0f53f7942	1815821a-5f7e-4621-a8f0-00996df35ac7	1	{"key": "REQ-7", "tags": null, "type": "USER_STORY", "title": "Trier le catalogue", "status": "READY", "category": null, "criteria": ["[TEXT] Quatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "trier les produits par nom ou par prix", "planguage.target": null, "userStory.soThat": "trouver plus vite ce qui m’intéresse", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.360969+00	po	2026-10-12 12:44:55.360969+00	po	0
b499bd95-06b4-463d-a5d4-b9cc4ad76b8d	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	1	{"key": "REQ-8", "tags": null, "type": "USER_STORY", "title": "Consulter la fiche d’un produit", "status": "READY", "category": null, "criteria": ["[TEXT] La fiche affiche le nom, la description, le prix et un bouton « Back to products »."], "priority": "SHOULD", "parentKey": "REQ-5", "riskLevel": "LOW", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ouvrir la fiche détaillée d’un produit", "planguage.target": null, "userStory.soThat": "lire sa description complète", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.403569+00	po	2026-10-12 12:44:55.403569+00	po	0
789c2baf-906e-4fdf-9a46-819e96e99dc8	b68ddd88-cf31-4488-8ede-74b4d54de51d	1	{"key": "REQ-10", "tags": null, "type": "USER_STORY", "title": "Ajouter un produit au panier", "status": "READY", "category": null, "criteria": ["[GHERKIN] Scénario: Ajouter un produit au panier depuis le catalogue\\n  Étant donné que je suis connecté en tant que \\"standard_user\\"\\n  Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n  Alors le badge du panier affiche \\"1\\"\\n  Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "[TEXT] Le bouton « Add to cart » devient « Remove »."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "ajouter un produit au panier depuis le catalogue", "planguage.target": null, "userStory.soThat": "le commander plus tard", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.443332+00	po	2026-10-12 12:44:55.443332+00	po	0
7b89d53c-a003-4c88-8c70-bbb94a47a487	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	1	{"key": "REQ-11", "tags": null, "type": "USER_STORY", "title": "Visualiser le contenu du panier", "status": "READY", "category": null, "criteria": ["[TEXT] Le panier liste chaque produit avec sa quantité, sa description et son prix.", "[TEXT] « Continue Shopping » ramène au catalogue sans vider le panier."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "HIGH", "transverse": false, "description": null, "externalRef": null, "storyPoints": 3, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "voir le contenu de mon panier", "planguage.target": null, "userStory.soThat": "vérifier mes achats avant de commander", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:55.483413+00	po	2026-10-12 12:44:55.483413+00	po	0
279af334-907e-44fa-a5aa-f8dd4c7e92e5	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	1	{"key": "REQ-12", "tags": null, "type": "USER_STORY", "title": "Retirer un produit du panier", "status": "READY", "category": null, "criteria": ["[TEXT] « Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge."], "priority": "MUST", "parentKey": "REQ-9", "riskLevel": "MEDIUM", "transverse": false, "description": null, "externalRef": null, "storyPoints": 2, "businessValue": null, "userStory.asA": "client", "planguage.unit": null, "planguage.scale": null, "userStory.iWant": "retirer un produit ajouté par erreur", "planguage.target": null, "userStory.soThat": "ne garder que ce que je veux acheter", "planguage.minimumThreshold": null, "planguage.measurementMethod": null}	Passage à READY	2026-10-12 12:44:56.461589+00	po	2026-10-12 12:44:56.461589+00	po	0
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."requirements" ("id", "project_id", "requirement_key", "key_number", "type", "title", "description", "story_as_a", "story_i_want", "story_so_that", "priority", "business_value", "story_points", "status", "risk_level", "category", "nfr_scale", "nfr_measurement_method", "nfr_minimum_threshold", "nfr_target", "nfr_unit", "transverse", "external_ref", "current_version", "parent_id", "rank", "invest_independent", "invest_negotiable", "invest_valuable", "invest_estimable", "invest_small", "invest_testable", "search_text", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
eb434eaf-4d35-46fd-9330-26a103936ed3	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-1	1	EPIC	Acheter en ligne sur Swag Labs	Permettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	\N	i	f	f	f	f	f	f	REQ-1\nAcheter en ligne sur Swag Labs\nPermettre à un client de se connecter, de parcourir le catalogue et de préparer son panier. **Release 1.0** : jusqu’à la visualisation du panier ; la commande viendra en 1.1.	2026-10-12 12:44:51.847436+00	po	2026-10-12 12:44:51.847436+00	po	0
c0e546fd-e6e2-4a14-a218-2e3f68412c5c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-2	2	FEATURE	Authentification	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	r	f	f	f	f	f	f	REQ-2\nAuthentification	2026-10-12 12:44:51.914204+00	po	2026-10-12 12:44:51.914204+00	po	0
2296fe8a-ec13-48e4-9531-ea274772789b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-5	5	FEATURE	Catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	y	f	f	f	f	f	f	REQ-5\nCatalogue	2026-10-12 12:44:52.068614+00	po	2026-10-12 12:44:52.068614+00	po	0
a3dd920e-f432-4223-997c-db6db4b3eaab	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-9	9	FEATURE	Panier	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	zv	f	f	f	f	f	f	REQ-9\nPanier	2026-10-12 12:44:52.237223+00	po	2026-10-12 12:44:52.237223+00	po	0
213f7e56-e2ec-4042-9a29-0ed2bb157e33	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-4	4	USER_STORY	Refuser un compte verrouillé	\N	responsable sécurité	que les comptes verrouillés ne puissent pas se connecter	protéger la boutique	MUST	\N	2	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	c0e546fd-e6e2-4a14-a218-2e3f68412c5c	x	f	f	f	f	f	f	REQ-4\nRefuser un compte verrouillé\nresponsable sécurité\nque les comptes verrouillés ne puissent pas se connecter\nprotéger la boutique\nLe compte locked_out_user voit « Epic sadface: Sorry, this user has been locked out. » et reste sur la page de connexion.	2026-10-12 12:44:52.028792+00	po	2026-10-12 12:45:43.043331+00	po	3
702601a5-33df-4395-b47c-e3ca85e96993	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-6	6	USER_STORY	Consulter le catalogue des produits	\N	client	voir les produits avec leur prix	choisir mes achats	MUST	\N	3	DONE	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	2296fe8a-ec13-48e4-9531-ea274772789b	z	f	f	f	f	f	f	REQ-6\nConsulter le catalogue des produits\nclient\nvoir les produits avec leur prix\nchoisir mes achats\nLes six produits s’affichent avec leur nom, leur description, leur prix et un bouton « Add to cart ».	2026-10-12 12:44:52.108218+00	po	2026-10-12 12:45:43.085724+00	po	3
d96e0b06-c6fc-43c9-b110-ea61b93b8b56	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-11	11	USER_STORY	Visualiser le contenu du panier	\N	client	voir le contenu de mon panier	vérifier mes achats avant de commander	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	a3dd920e-f432-4223-997c-db6db4b3eaab	zy	f	f	f	f	f	f	REQ-11\nVisualiser le contenu du panier\nclient\nvoir le contenu de mon panier\nvérifier mes achats avant de commander\nLe panier liste chaque produit avec sa quantité, sa description et son prix.\n« Continue Shopping » ramène au catalogue sans vider le panier.	2026-10-12 12:44:52.315686+00	po	2026-10-12 12:45:46.100294+00	po	2
424484f0-be28-4f80-beba-57398970bf97	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-13	13	FEATURE	Commande	Parcours de commande (checkout) : **non développé** dans la release 1.0.	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	zzi	f	f	f	f	f	f	REQ-13\nCommande\nParcours de commande (checkout) : **non développé** dans la release 1.0.	2026-10-12 12:44:52.401621+00	po	2026-10-12 12:44:52.401621+00	po	0
ad2028b8-e429-450d-aa56-ca0831aedee5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-14	14	USER_STORY	Saisir les informations de livraison	\N	client	saisir mon nom et mon code postal	être livré	SHOULD	\N	5	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	424484f0-be28-4f80-beba-57398970bf97	zzr	f	f	f	f	f	f	REQ-14\nSaisir les informations de livraison\nclient\nsaisir mon nom et mon code postal\nêtre livré\nLe prénom, le nom et le code postal sont obligatoires.	2026-10-12 12:44:52.433328+00	po	2026-10-12 12:44:52.433328+00	po	0
26c7900c-066b-49a5-ab2a-3a8e6b22d58f	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-16	16	NON_FUNCTIONAL	Temps de chargement du catalogue	\N	\N	\N	\N	MUST	\N	\N	DRAFT	MEDIUM	PERFORMANCE	Délai entre le clic « Login » et l’affichage des six produits	p95 de 5 connexions successives (test Playwright de performance)	3000	1000	ms	t	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	zzx	f	f	f	f	f	f	REQ-16\nTemps de chargement du catalogue	2026-10-12 12:44:54.363289+00	po	2026-10-12 12:44:54.363289+00	po	0
5332dd2d-0ece-4253-96f6-5f995405899c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-17	17	NON_FUNCTIONAL	Contrat HTTP du site	\N	\N	\N	\N	SHOULD	\N	\N	DRAFT	MEDIUM	RELIABILITY	Part des ressources publiques servies conformément (page, manifeste, icônes)	Test d’API sans navigateur	100	100	%	t	\N	0	eb434eaf-4d35-46fd-9330-26a103936ed3	zzy	f	f	f	f	f	f	REQ-17\nContrat HTTP du site	2026-10-12 12:44:54.404431+00	po	2026-10-12 12:44:54.404431+00	po	0
dedb5353-a01d-43ce-9c70-d8d30ec4ef13	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-3	3	USER_STORY	Se connecter avec un compte valide	\N	client	me connecter avec mon identifiant et mon mot de passe	accéder au catalogue	MUST	\N	3	DONE	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	c0e546fd-e6e2-4a14-a218-2e3f68412c5c	v	f	f	f	f	f	f	REQ-3\nSe connecter avec un compte valide\nclient\nme connecter avec mon identifiant et mon mot de passe\naccéder au catalogue\nScénario: Connexion réussie\n  Étant donné que je suis sur la page de connexion\n  Quand je me connecte avec "standard_user" et "secret_sauce"\n  Alors le catalogue "Products" s'affiche\nLe compte problem_user accède lui aussi au catalogue.	2026-10-12 12:44:51.98218+00	po	2026-10-12 12:45:42.998237+00	po	3
636a60d1-7053-4d2b-a980-0ed4fc5a85f6	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-12	12	USER_STORY	Retirer un produit du panier	\N	client	retirer un produit ajouté par erreur	ne garder que ce que je veux acheter	MUST	\N	2	IN_SPRINT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	1	a3dd920e-f432-4223-997c-db6db4b3eaab	zz	f	f	f	f	f	f	REQ-12\nRetirer un produit du panier\nclient\nretirer un produit ajouté par erreur\nne garder que ce que je veux acheter\n« Remove » retire le produit, depuis le catalogue comme depuis le panier, et met à jour le badge.	2026-10-12 12:44:52.36144+00	po	2026-10-12 12:45:46.100294+00	po	2
7820c512-1276-4f53-8455-5c2682ee8847	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-15	15	USER_STORY	Valider la commande	\N	client	vérifier le récapitulatif et valider ma commande	recevoir mes produits	SHOULD	\N	\N	DRAFT	MEDIUM	\N	\N	\N	\N	\N	\N	f	\N	0	424484f0-be28-4f80-beba-57398970bf97	zzv	f	f	f	f	f	f	REQ-15\nValider la commande\nclient\nvérifier le récapitulatif et valider ma commande\nrecevoir mes produits	2026-10-12 12:44:54.111355+00	po	2026-10-12 12:44:54.111355+00	po	0
1815821a-5f7e-4621-a8f0-00996df35ac7	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-7	7	USER_STORY	Trier le catalogue	\N	client	trier les produits par nom ou par prix	trouver plus vite ce qui m’intéresse	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	2296fe8a-ec13-48e4-9531-ea274772789b	zi	f	f	f	f	f	f	REQ-7\nTrier le catalogue\nclient\ntrier les produits par nom ou par prix\ntrouver plus vite ce qui m’intéresse\nQuatre tris sont proposés : nom de A à Z, nom de Z à A, prix croissant, prix décroissant.	2026-10-12 12:44:52.153653+00	po	2026-10-12 12:45:43.126362+00	po	3
b68ddd88-cf31-4488-8ede-74b4d54de51d	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-10	10	USER_STORY	Ajouter un produit au panier	\N	client	ajouter un produit au panier depuis le catalogue	le commander plus tard	MUST	\N	3	IN_SPRINT	HIGH	\N	\N	\N	\N	\N	\N	f	\N	1	a3dd920e-f432-4223-997c-db6db4b3eaab	zx	f	f	f	f	f	f	REQ-10\nAjouter un produit au panier\nclient\najouter un produit au panier depuis le catalogue\nle commander plus tard\nScénario: Ajouter un produit au panier depuis le catalogue\n  Étant donné que je suis connecté en tant que "standard_user"\n  Quand j'ajoute le produit "Sauce Labs Backpack" au panier\n  Alors le badge du panier affiche "1"\n  Et le panier contient "Sauce Labs Backpack" au prix de "$29.99"\nLe bouton « Add to cart » devient « Remove ».	2026-10-12 12:44:52.273456+00	po	2026-10-12 12:45:46.100294+00	po	2
8585a79c-6c67-49e2-a77a-2bccbdaa84ba	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	REQ-8	8	USER_STORY	Consulter la fiche détaillée d’un produit	\N	client	ouvrir la fiche détaillée d’un produit	lire sa description complète	SHOULD	\N	2	DONE	LOW	\N	\N	\N	\N	\N	\N	f	\N	1	2296fe8a-ec13-48e4-9531-ea274772789b	zr	f	f	f	f	f	f	REQ-8\nConsulter la fiche détaillée d’un produit\nclient\nouvrir la fiche détaillée d’un produit\nlire sa description complète\nLa fiche affiche le nom, la description, le prix et un bouton « Back to products ».	2026-10-12 12:44:52.195915+00	po	2026-10-12 12:46:27.61253+00	po	4
\.


--
-- Data for Name: run_artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."run_artifacts" ("id", "run_id", "execution_id", "name", "content_type", "kind", "size", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
df333860-120d-4f0e-87d2-7ef2bc8e0621	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	c45bd0cc-db64-4d57-8a0c-a2279e820e79	log-TC-7.txt	text/plain	SYSTEM_TRACE	395	2026-10-12 12:45:39.390812+00	anonymousUser	2026-10-12 12:45:39.390812+00	anonymousUser	0
a73c7439-6fe8-478b-946e-9f9ec82246ce	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	4b444e83-a865-457a-8b78-3b61767901e8	log-TC-4.txt	text/plain	SYSTEM_TRACE	393	2026-10-12 12:45:39.651872+00	anonymousUser	2026-10-12 12:45:39.651872+00	anonymousUser	0
e61d5cde-1bad-45c4-8f9b-96e7c74cd9c6	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	f7dd5f19-b34f-4fd7-84cb-b3bc5a24c340	log-TC-3.txt	text/plain	SYSTEM_TRACE	525	2026-10-12 12:45:40.014399+00	anonymousUser	2026-10-12 12:45:40.014399+00	anonymousUser	0
86f70a2e-0c28-41c7-b6a1-c1b7ecdeda0e	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	1b062258-7b85-4cee-b9cf-5191d8bf2e5d	log-TC-5.txt	text/plain	SYSTEM_TRACE	391	2026-10-12 12:45:40.191093+00	anonymousUser	2026-10-12 12:45:40.191093+00	anonymousUser	0
2a7e15aa-86b1-4479-a29d-ec688b5dcdfe	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	04073aef-e58c-4e5c-a2d2-092a7de8605e	log-TC-6.txt	text/plain	SYSTEM_TRACE	377	2026-10-12 12:45:41.046001+00	anonymousUser	2026-10-12 12:45:41.046001+00	anonymousUser	0
bfd94312-e94c-4ca1-9a7a-e92ed058ac7d	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	\N	system.log	text/plain	SYSTEM_TRACE	4700	2026-10-12 12:45:41.072965+00	anonymousUser	2026-10-12 12:45:41.072965+00	anonymousUser	0
e021ce05-01af-4176-9db6-27e42b9e7585	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	\N	junit.xml	application/xml	JUNIT	1187	2026-10-12 12:45:41.074041+00	anonymousUser	2026-10-12 12:45:41.074041+00	anonymousUser	0
5d6c7216-9247-47e1-b4bb-3d512868cbca	e98d0e0f-3b6e-446b-8501-83f32e1b2a4e	\N	report.json	application/json	REPORT	484	2026-10-12 12:45:41.079235+00	anonymousUser	2026-10-12 12:45:41.079235+00	anonymousUser	0
d8c58532-6e59-44b2-89e4-fccacc80e6d3	d2836591-3c64-4148-8f7c-c3b30b68bf62	626c41ad-9eb4-4749-a2ee-068864d0e908	log-TC-8.txt	text/plain	SYSTEM_TRACE	360	2026-10-12 12:46:13.129548+00	anonymousUser	2026-10-12 12:46:13.129548+00	anonymousUser	0
66352fe5-8a91-42b5-94ff-aefa90340d03	d2836591-3c64-4148-8f7c-c3b30b68bf62	8aba4a7f-ddfc-49b2-b69f-97607a6ede86	log-TC-9.txt	text/plain	SYSTEM_TRACE	461	2026-10-12 12:46:13.150221+00	anonymousUser	2026-10-12 12:46:13.150221+00	anonymousUser	0
2fdfd441-a9eb-4a69-ab7d-71e2c92c63d2	d2836591-3c64-4148-8f7c-c3b30b68bf62	b74099fc-abc0-4e38-84e2-f90d5f54849d	log-TC-11.txt	text/plain	SYSTEM_TRACE	456	2026-10-12 12:46:13.607889+00	anonymousUser	2026-10-12 12:46:13.607889+00	anonymousUser	0
d3c01d93-c5c4-4636-99b2-e7390c4226b6	d2836591-3c64-4148-8f7c-c3b30b68bf62	a3185a8a-6d52-4027-9823-97ed15832c74	screenshot-TC-10.png	image/png	SCREENSHOT	264580	2026-10-12 12:46:16.124513+00	anonymousUser	2026-10-12 12:46:16.124513+00	anonymousUser	0
2e0f00f3-8044-476d-9905-8bce1ba95fad	d2836591-3c64-4148-8f7c-c3b30b68bf62	a3185a8a-6d52-4027-9823-97ed15832c74	log-TC-10.txt	text/plain	SYSTEM_TRACE	3300	2026-10-12 12:46:16.127449+00	anonymousUser	2026-10-12 12:46:16.127449+00	anonymousUser	0
a4aee3c8-aef4-43d6-a13a-f3df98f263bd	d2836591-3c64-4148-8f7c-c3b30b68bf62	\N	system.log	text/plain	SYSTEM_TRACE	8559	2026-10-12 12:46:16.148114+00	anonymousUser	2026-10-12 12:46:16.148114+00	anonymousUser	0
576c9c5d-6f3d-4274-bebe-6da99614d299	d2836591-3c64-4148-8f7c-c3b30b68bf62	\N	junit.xml	application/xml	JUNIT	1058	2026-10-12 12:46:16.150191+00	anonymousUser	2026-10-12 12:46:16.150191+00	anonymousUser	0
2afd545a-a3cc-4c31-b8b6-4e69c11d6004	d2836591-3c64-4148-8f7c-c3b30b68bf62	\N	report.json	application/json	REPORT	475	2026-10-12 12:46:16.151984+00	anonymousUser	2026-10-12 12:46:16.151984+00	anonymousUser	0
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."session_notes" ("id", "session_id", "type", "offset_seconds", "text", "noted_at", "defect_id", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
5815d9b7-f522-406c-b751-7d4cf83aed12	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	NOTE	252	standard_user : 3 produits ajoutés, badge à 3, panier cohérent avec le catalogue	2026-10-12 13:04:12+00	\N	2026-10-12 12:45:53.219969+00	qa1	2026-10-12 12:45:53.219969+00	qa1	0
8e38c630-b2b8-425a-ad84-6c9daace13fa	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	NOTE	760	Retour arrière du navigateur depuis le panier : badge et boutons conservés	2026-10-12 13:12:40+00	\N	2026-10-12 12:45:53.325756+00	qa1	2026-10-12 12:45:53.325756+00	qa1	0
262da201-eaf7-405b-8896-fafa3d502875	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	QUESTION	2280	Le panier doit-il survivre à une déconnexion ? (conservé aujourd’hui)	2026-10-12 13:38:00+00	\N	2026-10-12 12:45:53.456383+00	qa1	2026-10-12 12:45:53.456383+00	qa1	0
ca1dd088-dcd2-4286-8466-ea2ec994daf2	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	IDEA	3060	Afficher le total du panier avant le checkout	2026-10-12 13:51:00+00	\N	2026-10-12 12:45:53.525869+00	qa1	2026-10-12 12:45:53.525869+00	qa1	0
9bbf6b52-f189-41c0-b350-5354fdb8b5af	ac7afff4-c3e1-4e1e-97c6-9ecd7294de70	BUG	1590	problem_user : « Add to cart » sans effet sur Bolt T-Shirt, Fleece Jacket et Test.allTheThings() T-Shirt	2026-10-12 13:26:30+00	cd2537b4-e904-4a71-84ef-dea9b7e4b306	2026-10-12 12:45:53.389209+00	qa1	2026-10-12 12:45:54.39609+00	qa1	1
\.


--
-- Data for Name: sprint_scope; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprint_scope" ("id", "sprint_id", "requirement_id", "position", "committed_points", "outcome", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
7e461550-b2e4-4b37-9609-65e8f96bde8b	a0c8470f-6717-4499-b373-b4efa2bdbaae	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	1	3	DONE	2026-10-12 12:45:11.346622+00	po	2026-10-12 12:45:45.365356+00	po	1
d17dd93c-ed17-42fc-8c3a-7230a8376f7e	a0c8470f-6717-4499-b373-b4efa2bdbaae	213f7e56-e2ec-4042-9a29-0ed2bb157e33	2	2	DONE	2026-10-12 12:45:11.417015+00	po	2026-10-12 12:45:45.365356+00	po	1
4f5dac9d-900f-4fb2-a358-144d9ced3440	a0c8470f-6717-4499-b373-b4efa2bdbaae	702601a5-33df-4395-b47c-e3ca85e96993	3	3	DONE	2026-10-12 12:45:11.48868+00	po	2026-10-12 12:45:45.365356+00	po	1
9e3d838f-47e7-4182-bc0b-5d5629c2a587	a0c8470f-6717-4499-b373-b4efa2bdbaae	1815821a-5f7e-4621-a8f0-00996df35ac7	4	2	DONE	2026-10-12 12:45:11.561993+00	po	2026-10-12 12:45:45.365356+00	po	1
bbac288a-4d5f-476a-b6f2-8571403bfdb9	a0c8470f-6717-4499-b373-b4efa2bdbaae	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	5	2	DONE	2026-10-12 12:45:11.636245+00	po	2026-10-12 12:45:45.365356+00	po	1
a3c36f1f-451b-4e9f-a2b1-f3e5c55061e0	22c2616c-7486-4747-8085-a9eb65ee0ea5	b68ddd88-cf31-4488-8ede-74b4d54de51d	1	3	PLANNED	2026-10-12 12:45:46.053757+00	po	2026-10-12 12:45:46.053757+00	po	0
97ad26b6-c584-4969-8a99-792ab31d1106	22c2616c-7486-4747-8085-a9eb65ee0ea5	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	2	3	PLANNED	2026-10-12 12:45:46.053757+00	po	2026-10-12 12:45:46.053757+00	po	0
3bfab344-2a9a-4092-95e1-1ca4c67680e5	22c2616c-7486-4747-8085-a9eb65ee0ea5	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	3	2	PLANNED	2026-10-12 12:45:46.053757+00	po	2026-10-12 12:45:46.053757+00	po	0
\.


--
-- Data for Name: sprints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."sprints" ("id", "project_id", "release_id", "sprint_key", "key_number", "name", "goal", "start_date", "end_date", "capacity_points", "status", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
a0c8470f-6717-4499-b373-b4efa2bdbaae	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	25d7c25e-ee25-4a23-9f89-d9273c419eb5	SPR-1	1	Sprint 1 — Connexion et catalogue	Se connecter et parcourir le catalogue	2026-09-28	2026-10-09	13	CLOSED	2026-10-12 12:45:10.708551+00	po	2026-10-12 12:45:45.364801+00	po	2
22c2616c-7486-4747-8085-a9eb65ee0ea5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	25d7c25e-ee25-4a23-9f89-d9273c419eb5	SPR-2	2	Sprint 2 — Panier	Ajouter, visualiser et retirer des produits du panier	2026-10-12	2026-10-23	10	ACTIVE	2026-10-12 12:45:10.75155+00	po	2026-10-12 12:45:46.099777+00	po	1
\.


--
-- Data for Name: step_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."step_results" ("id", "execution_id", "position", "action", "expected_result", "test_data", "status", "actual_result", "created_at", "created_by", "updated_at", "updated_by", "version", "called_from") FROM stdin;
a7ed1a4e-eb8f-4ae2-bcc6-a99034479d57	d4612c4c-9021-4594-9291-c3e439601b89	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:14.696003+00	qa1	2026-10-12 12:45:14.827043+00	qa1	1	\N
92cdf850-a346-4dd6-9106-8b202d4f8a16	d4612c4c-9021-4594-9291-c3e439601b89	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:45:14.697003+00	qa1	2026-10-12 12:45:15.405544+00	qa1	1	\N
af1181a1-2d55-4b14-be98-b6bce463a270	d9e8fbe9-e6ce-48f2-9393-b7f292b2341d	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:15.445103+00	qa1	2026-10-12 12:45:15.462641+00	qa1	1	\N
14412a80-c96a-4a6b-80cb-3ea752dd2a45	d9e8fbe9-e6ce-48f2-9393-b7f292b2341d	2	Saisir locked_out_user et le mot de passe secret_sauce, puis cliquer « Login »	Message « Epic sadface: Sorry, this user has been locked out. »	\N	PASSED	\N	2026-10-12 12:45:15.445103+00	qa1	2026-10-12 12:45:15.478734+00	qa1	1	\N
9be3fc1e-f56f-49c4-9e61-39827f9a71d9	9aacec72-9323-4b91-a489-002a23a761c7	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:15.495575+00	qa1	2026-10-12 12:45:15.512939+00	qa1	1	\N
5a20a681-22ac-4c67-bdb6-f024273c0815	9aacec72-9323-4b91-a489-002a23a761c7	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:45:15.495575+00	qa1	2026-10-12 12:45:15.533563+00	qa1	1	\N
fd27c301-b3f5-468e-a5c4-5b1b22dc96a2	c19047cf-21b0-4417-8c80-eb7701404639	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.268162+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
47a8f64c-dc91-4dc5-9341-637d041c495b	c19047cf-21b0-4417-8c80-eb7701404639	2	Saisir problem_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.389105+00	qa2	1	TC-1 Se connecter avec les comptes de démonstration (problem_user)
093ece69-f069-4312-a742-2687a28e5db0	c19047cf-21b0-4417-8c80-eb7701404639	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.505891+00	qa2	1	\N
3b156981-0ac1-4081-9af1-de2e9b5acc29	c19047cf-21b0-4417-8c80-eb7701404639	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.620176+00	qa2	1	\N
7a2cc1af-344f-4ac3-89a9-2b2bc9cc7a5c	c19047cf-21b0-4417-8c80-eb7701404639	5	Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack	Le badge du panier disparaît	\N	FAILED	Le badge reste à 1 : le bouton « Remove » du catalogue est sans effet.	2026-10-12 12:45:48.139001+00	qa2	2026-10-12 12:45:48.886495+00	qa2	1	\N
40f83d6f-73f2-461f-8642-cb6576fb48b6	205ac971-ea1c-4c48-96ff-7edcc4cc97b7	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:51.022885+00	qa1	2026-10-12 12:45:51.169525+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
4120fbbf-f705-4d2f-888b-1e7db5b60297	205ac971-ea1c-4c48-96ff-7edcc4cc97b7	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:45:51.022885+00	qa1	2026-10-12 12:45:51.733901+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
fe91d798-c8db-4c3f-90ef-71348185bd00	205ac971-ea1c-4c48-96ff-7edcc4cc97b7	3	Cliquer « Add to cart » sur Sauce Labs Backpack	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:45:51.022885+00	qa1	2026-10-12 12:45:51.854509+00	qa1	1	\N
b4282f25-a327-4bee-8867-3ca67bf87863	205ac971-ea1c-4c48-96ff-7edcc4cc97b7	4	Ouvrir le panier	Sauce Labs Backpack est listé : quantité 1, $29.99	\N	PASSED	\N	2026-10-12 12:45:51.022885+00	qa1	2026-10-12 12:45:51.96927+00	qa1	1	\N
107c5cd8-b14a-4d11-a6e1-d9aef1c1721d	031f1bc4-8603-4eef-b19c-27503019c44d	1	Ouvrir https://www.saucedemo.com	La page de connexion « Swag Labs » s’affiche	\N	PASSED	\N	2026-10-12 12:45:52.021682+00	qa1	2026-10-12 12:45:52.038959+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
c5d06f2b-4fe3-4721-9994-64f892f09e5f	031f1bc4-8603-4eef-b19c-27503019c44d	2	Saisir standard_user et le mot de passe secret_sauce, puis cliquer « Login »	Le catalogue « Products » s’affiche	\N	PASSED	\N	2026-10-12 12:45:52.021682+00	qa1	2026-10-12 12:45:52.053703+00	qa1	1	TC-1 Se connecter avec les comptes de démonstration (standard_user)
284799b0-b2d6-4945-bda8-41c9a7866a82	031f1bc4-8603-4eef-b19c-27503019c44d	3	Cliquer « Add to cart » sur Sauce Labs Bike Light	Le badge du panier affiche 1	\N	PASSED	\N	2026-10-12 12:45:52.021682+00	qa1	2026-10-12 12:45:52.068684+00	qa1	1	\N
87c5e58c-413a-47d7-be3e-b2a2db8d25bf	031f1bc4-8603-4eef-b19c-27503019c44d	4	Ouvrir le panier	Sauce Labs Bike Light est listé : quantité 1, $9.99	\N	PASSED	\N	2026-10-12 12:45:52.021682+00	qa1	2026-10-12 12:45:52.083446+00	qa1	1	\N
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
9a322c39-830a-40c1-8465-2684b7362c76	700ee46f-2e16-4595-8e42-60df8efba238	1	{"key": "TC-1", "kind": "MANUAL", "tags": null, "steps": ["1. Ouvrir https://www.saucedemo.com → La page de connexion « Swag Labs » s’affiche", "2. Saisir ${utilisateur} et le mot de passe secret_sauce, puis cliquer « Login » → ${resultat_attendu}"], "title": "Se connecter avec les comptes de démonstration", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat_attendu=Le catalogue « Products » s’affiche}, {utilisateur=locked_out_user, resultat_attendu=Message « Epic sadface: Sorry, this user has been locked out. »}, {utilisateur=problem_user, resultat_attendu=Le catalogue « Products » s’affiche}]"], "priority": "MUST", "objective": "Vérifier l’accès au catalogue selon le type de compte.", "parameters": ["utilisateur = standard_user", "resultat_attendu = Le catalogue « Products » s’affiche"], "description": null, "automationCandidate": true, "estimatedDurationMin": 3, "automationJustification": "Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données."}	2026-10-12 12:45:02.706384+00	qa1	2026-10-12 12:45:02.706384+00	qa1	0
6ad817ac-e9a3-4536-9f05-de6af6fadf35	187c5fea-f6d8-4f2c-9980-e010cab078a0	1	{"key": "TC-2", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › problem_user]", "2. Cliquer « Add to cart » sur Sauce Labs Backpack → Le badge du panier affiche 1", "3. Ouvrir le panier → Sauce Labs Backpack est listé : quantité 1, $29.99", "4. Revenir au catalogue et cliquer « Remove » sur Sauce Labs Backpack → Le badge du panier disparaît"], "title": "Retirer un produit depuis le catalogue et le panier", "folder": "Panier", "status": "DRAFT", "dataSets": null, "priority": "MUST", "objective": null, "parameters": null, "description": null, "automationCandidate": false, "estimatedDurationMin": 5, "automationJustification": null}	2026-10-12 12:45:02.807127+00	qa1	2026-10-12 12:45:02.807127+00	qa1	0
5cd2b8e0-4304-4ffc-a39e-6b829642cc87	cc8fecbd-629e-4b49-9cb5-301da0d06f13	1	{"key": "TC-3", "kind": "AUTOMATED", "path": "saucedemo/app-tests/authentification.spec.ts", "tags": null, "title": "Connexion pilotée par les données", "branch": "depots-git", "folder": "Authentification", "status": "DRAFT", "dataSets": ["Comptes : [{utilisateur=standard_user, resultat=catalogue, message=}, {utilisateur=locked_out_user, resultat=refus, message=Epic sadface: Sorry, this user has been locked out.}, {utilisateur=problem_user, resultat=catalogue, message=}]"], "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "DATA_DRIVEN", "parameters": null, "description": null, "executionTags": "saucedemo, regression", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Authentification › connexion avec chaque compte du jeu de données", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:02.898806+00	dev	2026-10-12 12:45:02.898806+00	dev	0
72b0f002-9004-49aa-a630-1e693f8364be	c908281b-629c-4e68-a53c-cc6608cdeacf	1	{"key": "TC-4", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : six produits affichés", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › affiche les six produits du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:02.965732+00	dev	2026-10-12 12:45:02.965732+00	dev	0
6799f8fa-5e23-4656-a9ee-82fc7d08aa8b	be93af9c-6d55-40a3-a432-6f98fd300c13	1	{"key": "TC-5", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : tri par prix croissant", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › trie les produits par prix croissant", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:03.031956+00	dev	2026-10-12 12:45:03.031956+00	dev	0
0de1f9ca-5011-4ad3-aff4-0323150c4495	03f2bd14-310b-40c4-98cd-403a38526c96	1	{"key": "TC-6", "kind": "AUTOMATED", "path": "saucedemo/app-tests/catalogue.spec.ts", "tags": null, "title": "Catalogue : fiche produit", "branch": "depots-git", "folder": "Catalogue", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Catalogue › ouvre la fiche d’un produit", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:03.115361+00	dev	2026-10-12 12:45:03.115361+00	dev	0
a467f917-419d-4a50-a149-86578babad76	a420130e-db79-424c-8dc9-25f714dc3be6	1	{"key": "TC-7", "kind": "AUTOMATED", "path": "saucedemo/app-tests/api.spec.ts", "tags": null, "title": "Contrat HTTP : manifeste et icônes", "branch": "depots-git", "folder": "API", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "API", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Contrat HTTP › expose le manifeste PWA et ses icônes", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:03.195231+00	dev	2026-10-12 12:45:03.195231+00	dev	0
f7b5a5d8-0c4b-497c-9e13-f00a80b4e077	d254040b-f43a-4181-944f-27c1d035d594	1	{"key": "TC-8", "kind": "AUTOMATED", "path": "src/test/resources/features/req-10-ajouter-un-produit-au-panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": null, "folder": null, "status": "DRAFT", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Cucumber-JVM", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": null, "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:04.532535+00	qa1	2026-10-12 12:45:04.532535+00	qa1	0
c6b78356-611e-4cf1-b0d9-f9d53b102ef6	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	1	{"key": "TC-9", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : visualiser le contenu", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo, smoke", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › visualise le contenu du panier", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:05.561361+00	dev	2026-10-12 12:45:05.561361+00	dev	0
333b81b4-2e82-4b45-8a7e-455e79fcf392	d254040b-f43a-4181-944f-27c1d035d594	2	{"key": "TC-8", "kind": "AUTOMATED", "path": "saucedemo/features/panier.feature", "tags": null, "title": "Ajouter un produit au panier depuis le catalogue", "branch": "depots-git", "folder": "Panier", "status": "READY", "dataSets": null, "language": null, "priority": "SHOULD", "framework": "Playwright", "objective": "Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier", "technique": "BDD", "parameters": null, "description": null, "executionTags": "bdd", "gherkinSource": "# language: fr\\nFonctionnalité: Ajouter un produit au panier\\n\\n  @REQ-10 @AC-10-1\\n  Scénario: Ajouter un produit au panier depuis le catalogue\\n    Étant donné que je suis connecté en tant que \\"standard_user\\"\\n    Quand j'ajoute le produit \\"Sauce Labs Backpack\\" au panier\\n    Alors le badge du panier affiche \\"1\\"\\n    Et le panier contient \\"Sauce Labs Backpack\\" au prix de \\"$29.99\\"", "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Ajouter un produit au panier depuis le catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:04.672868+00	qa1	2026-10-12 12:45:04.672868+00	qa1	0
c968ae33-7009-4e95-b705-d3e372b4484d	9fdec814-d958-4de8-855a-e1a27cd20933	1	{"key": "TC-10", "kind": "AUTOMATED", "path": "saucedemo/app-tests/panier.spec.ts", "tags": null, "title": "Panier : retrait par problem_user", "branch": "depots-git", "folder": "Panier", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "UI", "parameters": null, "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Panier › problem_user retire un produit depuis le catalogue @fail", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:05.626157+00	dev	2026-10-12 12:45:05.626157+00	dev	0
b4f6d4fb-123e-40b4-a71a-bf116eebc32a	7239fab8-aed6-4e47-a3fe-b60e84557eab	1	{"key": "TC-11", "kind": "AUTOMATED", "path": "saucedemo/app-tests/performance.spec.ts", "tags": null, "title": "Performance : chargement du catalogue", "branch": "depots-git", "folder": "Performance", "status": "DRAFT", "dataSets": null, "language": "TypeScript", "priority": "SHOULD", "framework": "Playwright", "objective": null, "technique": "PERFORMANCE", "parameters": "{iterations=5, seuilMs=3000}", "description": null, "executionTags": "saucedemo", "gherkinSource": null, "repositoryUrl": "file:///depots/traceagile", "testIdentifier": "Performance › temps de chargement du catalogue", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null, "environmentRequirements": null}	2026-10-12 12:45:05.69156+00	dev	2026-10-12 12:45:05.69156+00	dev	0
a928c0f0-df17-4ab0-8138-d975f0ce3b6f	b0393b4a-992f-441a-9e85-d6a27de9108a	1	{"key": "TC-12", "kind": "EXPLORATORY", "tags": null, "areas": "Panier, Catalogue", "title": "Explorer le panier", "folder": "Panier", "status": "DRAFT", "mission": "Explorer le panier avec les comptes standard_user et problem_user, des ajouts et retraits répétés et le bouton retour du navigateur pour découvrir les écarts entre le badge, les boutons du catalogue et le contenu du panier.", "dataSets": null, "priority": "MUST", "objective": null, "heuristics": "CRUD, Goldilocks", "parameters": null, "setupNotes": null, "timeboxMin": 60, "description": null, "targetedRisk": "Panier faux au moment de commander", "automationCandidate": false, "estimatedDurationMin": null, "automationJustification": null}	2026-10-12 12:45:05.750158+00	qa1	2026-10-12 12:45:05.750158+00	qa1	0
c572cc42-df42-47d4-b705-eb2006658afe	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	1	{"key": "TC-13", "kind": "MANUAL", "tags": null, "steps": ["1. ↳ TC-1 [Comptes › standard_user]", "2. Cliquer « Add to cart » sur ${produit} → Le badge du panier affiche 1", "3. Ouvrir le panier → ${produit} est listé : quantité 1, ${prix}"], "title": "Ajouter un produit au panier après connexion", "folder": "Panier", "status": "DRAFT", "dataSets": ["Produits : [{produit=Sauce Labs Backpack, prix=$29.99}, {produit=Sauce Labs Bike Light, prix=$9.99}]"], "priority": "SHOULD", "objective": "Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.", "parameters": ["produit = Sauce Labs Backpack", "prix = $29.99"], "description": null, "automationCandidate": false, "estimatedDurationMin": 4, "automationJustification": null}	2026-10-12 12:45:05.815387+00	qa1	2026-10-12 12:45:05.815387+00	qa1	0
\.


--
-- Data for Name: test_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."test_cases" ("id", "project_id", "test_key", "key_number", "kind", "title", "description", "objective", "priority", "status", "estimated_duration_min", "folder", "current_version", "automation_candidate", "automation_justification", "created_at", "created_by", "updated_at", "updated_by", "version", "parameters", "data_sets", "flaky") FROM stdin;
700ee46f-2e16-4595-8e42-60df8efba238	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-1	1	MANUAL	Se connecter avec les comptes de démonstration	\N	Vérifier l’accès au catalogue selon le type de compte.	MUST	READY	3	Authentification	1	t	Rejoué à chaque sprint ; automatisé par TC-3 avec le même jeu de données.	2026-10-12 12:45:02.697484+00	qa1	2026-10-12 12:45:02.775816+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat_attendu", "description": null, "defaultValue": "Le catalogue « Products » s’affiche"}]	[{"name": "Comptes", "rows": [{"utilisateur": "standard_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}, {"utilisateur": "locked_out_user", "resultat_attendu": "Message « Epic sadface: Sorry, this user has been locked out. »"}, {"utilisateur": "problem_user", "resultat_attendu": "Le catalogue « Products » s’affiche"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
187c5fea-f6d8-4f2c-9980-e010cab078a0	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-2	2	MANUAL	Retirer un produit depuis le catalogue et le panier	\N	\N	MUST	READY	5	Panier	1	f	\N	2026-10-12 12:45:02.804827+00	qa1	2026-10-12 12:45:02.85664+00	qa1	1	[]	[]	f
cc8fecbd-629e-4b49-9cb5-301da0d06f13	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-3	3	AUTOMATED	Connexion pilotée par les données	\N	\N	SHOULD	READY	\N	Authentification	1	f	\N	2026-10-12 12:45:02.896745+00	dev	2026-10-12 12:45:02.936454+00	qa1	1	[{"name": "utilisateur", "description": null, "defaultValue": "standard_user"}, {"name": "resultat", "description": null, "defaultValue": "catalogue"}, {"name": "message", "description": null, "defaultValue": null}]	[{"name": "Comptes", "rows": [{"message": "", "resultat": "catalogue", "utilisateur": "standard_user"}, {"message": "Epic sadface: Sorry, this user has been locked out.", "resultat": "refus", "utilisateur": "locked_out_user"}, {"message": "", "resultat": "catalogue", "utilisateur": "problem_user"}], "rowNames": ["standard_user", "locked_out_user", "problem_user"]}]	f
c908281b-629c-4e68-a53c-cc6608cdeacf	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-4	4	AUTOMATED	Catalogue : six produits affichés	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 12:45:02.964498+00	dev	2026-10-12 12:45:02.998354+00	qa1	1	[]	[]	f
be93af9c-6d55-40a3-a432-6f98fd300c13	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-5	5	AUTOMATED	Catalogue : tri par prix croissant	\N	\N	SHOULD	READY	\N	Catalogue	1	f	\N	2026-10-12 12:45:03.031421+00	dev	2026-10-12 12:45:03.073373+00	qa1	1	[]	[]	f
a420130e-db79-424c-8dc9-25f714dc3be6	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-7	7	AUTOMATED	Contrat HTTP : manifeste et icônes	\N	\N	SHOULD	READY	\N	API	1	f	\N	2026-10-12 12:45:03.194453+00	dev	2026-10-12 12:45:03.238227+00	qa1	1	[]	[]	f
9fdec814-d958-4de8-855a-e1a27cd20933	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-10	10	AUTOMATED	Panier : retrait par problem_user	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 12:45:05.625649+00	dev	2026-10-12 12:45:05.662039+00	qa1	1	[]	[]	f
d254040b-f43a-4181-944f-27c1d035d594	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-8	8	AUTOMATED	Ajouter un produit au panier depuis le catalogue	\N	Vérifier le critère n° 1 de REQ-10 : Ajouter un produit au panier	SHOULD	READY	\N	Panier	2	f	\N	2026-10-12 12:45:04.532535+00	qa1	2026-10-12 12:45:04.682126+00	qa1	2	[]	[]	f
bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-9	9	AUTOMATED	Panier : visualiser le contenu	\N	\N	SHOULD	READY	\N	Panier	1	f	\N	2026-10-12 12:45:05.560834+00	dev	2026-10-12 12:45:05.598644+00	qa1	1	[]	[]	f
7239fab8-aed6-4e47-a3fe-b60e84557eab	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-11	11	AUTOMATED	Performance : chargement du catalogue	\N	\N	SHOULD	READY	\N	Performance	1	f	\N	2026-10-12 12:45:05.691016+00	dev	2026-10-12 12:45:05.724922+00	qa1	1	[]	[]	f
b0393b4a-992f-441a-9e85-d6a27de9108a	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-12	12	EXPLORATORY	Explorer le panier	\N	\N	MUST	READY	\N	Panier	1	f	\N	2026-10-12 12:45:05.748102+00	qa1	2026-10-12 12:45:05.786848+00	qa1	1	[]	[]	f
e84eb7db-0e1b-4206-ae24-ee6bc4feb938	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-13	13	MANUAL	Ajouter un produit au panier après connexion	\N	Vérifier le panier d’un client connecté, sans réécrire la connexion : TC-1 est appelé comme premier pas.	SHOULD	READY	4	Panier	1	f	\N	2026-10-12 12:45:05.814364+00	qa1	2026-10-12 12:45:05.851857+00	qa1	1	[{"name": "produit", "description": null, "defaultValue": "Sauce Labs Backpack"}, {"name": "prix", "description": null, "defaultValue": "$29.99"}]	[{"name": "Produits", "rows": [{"prix": "$29.99", "produit": "Sauce Labs Backpack"}, {"prix": "$9.99", "produit": "Sauce Labs Bike Light"}], "rowNames": ["Sac à dos", "Lampe de vélo"]}]	f
03f2bd14-310b-40c4-98cd-403a38526c96	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TC-6	6	AUTOMATED	Catalogue : fiche produit	\N	\N	SHOULD	NEEDS_UPDATE	\N	Catalogue	1	f	\N	2026-10-12 12:45:03.114856+00	dev	2026-10-12 12:46:27.620537+00	po	2	[]	[]	f
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
13e73492-515f-401d-9b8e-3bb64aae7353	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	700ee46f-2e16-4595-8e42-60df8efba238	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	VERIFIES	MANUAL	2026-10-12 12:45:02.717393+00	qa1	2026-10-12 12:45:02.717393+00	qa1	0	\N
4b075b97-c0e5-4435-8a77-337f6a5f7195	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	700ee46f-2e16-4595-8e42-60df8efba238	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	VERIFIES	MANUAL	2026-10-12 12:45:02.717979+00	qa1	2026-10-12 12:45:02.717979+00	qa1	0	\N
78c63cf5-4680-4ec6-a884-06da2d589fab	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	187c5fea-f6d8-4f2c-9980-e010cab078a0	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	PARTIALLY_VERIFIES	MANUAL	2026-10-12 12:45:02.812376+00	qa1	2026-10-12 12:45:02.812376+00	qa1	0	\N
4103a9fc-716c-44b4-8d12-29b982f1a2d8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	187c5fea-f6d8-4f2c-9980-e010cab078a0	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	VERIFIES	MANUAL	2026-10-12 12:45:02.812376+00	qa1	2026-10-12 12:45:02.812376+00	qa1	0	\N
9b0b4a9a-2093-460a-9ab0-43043510000d	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	cc8fecbd-629e-4b49-9cb5-301da0d06f13	REQUIREMENT	dedb5353-a01d-43ce-9c70-d8d30ec4ef13	VERIFIES	MANUAL	2026-10-12 12:45:02.902928+00	dev	2026-10-12 12:45:02.902928+00	dev	0	\N
f5d23aa5-9ed1-46c2-acf7-21c882990871	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	cc8fecbd-629e-4b49-9cb5-301da0d06f13	REQUIREMENT	213f7e56-e2ec-4042-9a29-0ed2bb157e33	VERIFIES	MANUAL	2026-10-12 12:45:02.903444+00	dev	2026-10-12 12:45:02.903444+00	dev	0	\N
1d70fa7a-144b-43ff-80d7-d9ef046b1433	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	c908281b-629c-4e68-a53c-cc6608cdeacf	REQUIREMENT	702601a5-33df-4395-b47c-e3ca85e96993	VERIFIES	MANUAL	2026-10-12 12:45:02.968478+00	dev	2026-10-12 12:45:02.968478+00	dev	0	\N
ecfec0c7-43e3-410e-962f-80e07cdae40c	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	be93af9c-6d55-40a3-a432-6f98fd300c13	REQUIREMENT	1815821a-5f7e-4621-a8f0-00996df35ac7	VERIFIES	MANUAL	2026-10-12 12:45:03.034932+00	dev	2026-10-12 12:45:03.034932+00	dev	0	\N
55907771-5473-4c65-906d-ba352dba12b8	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	a420130e-db79-424c-8dc9-25f714dc3be6	REQUIREMENT	5332dd2d-0ece-4253-96f6-5f995405899c	VERIFIES	MANUAL	2026-10-12 12:45:03.199162+00	dev	2026-10-12 12:45:03.199162+00	dev	0	\N
4f0a3ebf-f063-47d1-aaa9-f4e192a6d79f	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	d254040b-f43a-4181-944f-27c1d035d594	REQUIREMENT	b68ddd88-cf31-4488-8ede-74b4d54de51d	VERIFIES	GHERKIN_TAG	2026-10-12 12:45:04.540123+00	qa1	2026-10-12 12:45:04.540123+00	qa1	0	\N
58616ac8-c632-4f0e-9fa1-dc917f281492	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	d254040b-f43a-4181-944f-27c1d035d594	ACCEPTANCE_CRITERION	4ad68602-a82b-408b-b818-e3e4b90c5985	VERIFIES	GHERKIN_TAG	2026-10-12 12:45:04.54954+00	qa1	2026-10-12 12:45:04.54954+00	qa1	0	\N
f3fb3c89-84c0-41cd-a3ce-0d1934281b77	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	bd208c30-d8f0-448d-9b8f-8a9fb3d9a97e	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	VERIFIES	MANUAL	2026-10-12 12:45:05.564766+00	dev	2026-10-12 12:45:05.564766+00	dev	0	\N
1ecd8acb-a0b7-4a66-93f2-ae09cbb4140f	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	9fdec814-d958-4de8-855a-e1a27cd20933	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	VERIFIES	MANUAL	2026-10-12 12:45:05.629287+00	dev	2026-10-12 12:45:05.629287+00	dev	0	\N
1931dfcc-9c2d-4c2d-a459-a7af1ff62ca5	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	7239fab8-aed6-4e47-a3fe-b60e84557eab	REQUIREMENT	26c7900c-066b-49a5-ab2a-3a8e6b22d58f	VERIFIES	MANUAL	2026-10-12 12:45:05.695307+00	dev	2026-10-12 12:45:05.695307+00	dev	0	\N
7a34ed0f-aa53-471c-9ee4-6d68bc648a6b	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	b0393b4a-992f-441a-9e85-d6a27de9108a	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	VERIFIES	MANUAL	2026-10-12 12:45:05.753988+00	qa1	2026-10-12 12:45:05.753988+00	qa1	0	\N
bfb22445-0cb2-4e54-8b01-b6affee218fc	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	b0393b4a-992f-441a-9e85-d6a27de9108a	REQUIREMENT	636a60d1-7053-4d2b-a980-0ed4fc5a85f6	VERIFIES	MANUAL	2026-10-12 12:45:05.753988+00	qa1	2026-10-12 12:45:05.753988+00	qa1	0	\N
1681a0e1-d487-4b86-9e0a-da12e2b94106	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	e84eb7db-0e1b-4206-ae24-ee6bc4feb938	REQUIREMENT	d96e0b06-c6fc-43c9-b110-ea61b93b8b56	VERIFIES	MANUAL	2026-10-12 12:45:05.817449+00	qa1	2026-10-12 12:45:05.817449+00	qa1	0	\N
9fdac818-ff48-4593-8758-d43a918ce3dc	7b9e44a2-d56a-4180-b9a7-4dda7258a2ea	TEST_CASE	03f2bd14-310b-40c4-98cd-403a38526c96	REQUIREMENT	8585a79c-6c67-49e2-a77a-2bccbdaa84ba	VERIFIES	MANUAL	2026-10-12 12:45:03.118329+00	dev	2026-10-12 12:46:28.243515+00	qa1	2	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."users" ("id", "login", "email", "display_name", "password_hash", "active", "system_admin", "created_at", "created_by", "updated_at", "updated_by", "version") FROM stdin;
4980f78c-962c-4fb1-99f3-8b3ebae66490	admin	admin@traceagile.local	Administrateur	$2a$12$whLlsFto0wfL/jsZHE41KuRkd.mpWi81aLULsKOQ.oSFZGpl07PS6	t	t	2026-10-12 12:44:39.355358+00	system	2026-10-12 12:44:39.355358+00	system	0
8e12d588-2f31-4e08-9f57-f7b1d57c7915	po	po@traceagile.demo	Paula Owner	$2a$12$GGQx7dtSaOQSZj2hWdroRe0Y75Snx3C8j.4e.6jySnomw8ucZBY0K	t	f	2026-10-12 12:44:46.231209+00	admin	2026-10-12 12:44:46.231209+00	admin	0
65a7a55a-d8a6-438e-90ae-a9788fb611eb	qa1	qa1@traceagile.demo	Quentin Testeur	$2a$12$5UnC7naZ6buMlASkc1JH8eUiHQ2xD9bGOiljkRxSSv9x1zzB4Z/Q2	t	f	2026-10-12 12:44:46.413054+00	admin	2026-10-12 12:44:46.413054+00	admin	0
6ba2b9d3-29bb-4bed-9e9e-3830a752aef7	qa2	qa2@traceagile.demo	Quitterie Testeuse	$2a$12$IaHToMETkirecSsqniHBruwoRIQ2xs/xsDbaVdJumeKcYohptxyD2	t	f	2026-10-12 12:44:46.613321+00	admin	2026-10-12 12:44:46.613321+00	admin	0
1d1dc3ef-cf25-4058-abb9-7f739ed73ca0	dev	dev@traceagile.demo	Dev Eloppeur	$2a$12$UhQfCBygbeNxgwx0OwmUcuY/MhY6UTMsQT6AXFQzLjKUt9Y69d7NO	t	f	2026-10-12 12:44:46.807634+00	admin	2026-10-12 12:44:46.807634+00	admin	0
0a4829a1-d19b-4a1d-876b-a9a649d4b9a6	viewer	viewer@traceagile.demo	Victor Lecteur	$2a$12$B1NxQv8RdSne8kmZzJjGa.CF8umQWMWNsqt8yc9hxFr2bxbnFUvLa	t	f	2026-10-12 12:44:46.999145+00	admin	2026-10-12 12:44:46.999145+00	admin	0
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


