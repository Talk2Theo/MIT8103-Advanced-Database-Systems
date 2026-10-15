
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 13a_create_audit_function.sql
-- Purpose: Restore the original audit trigger function.
--
-- Target database: theoscyba_rebuild_test
--
-- Prerequisites:
-- 1. vulnerabilities table exists.
-- 2. audit_logs table exists.
--
-- Execute this function before
-- 13_create_audit_trigger.sql.

CREATE OR REPLACE FUNCTION public.audit_vulnerability_updates()
RETURNS trigger
LANGUAGE plpgsql
AS $function$

BEGIN

    IF OLD IS DISTINCT FROM NEW THEN

        INSERT INTO audit_logs (
            action_type,
            affected_table,
            affected_record_id,
            old_data,
            new_data,
            action_details
        )
        VALUES (
            'UPDATE',
            TG_TABLE_NAME,
            NEW.vulnerability_id,
            to_jsonb(OLD),
            to_jsonb(NEW),
            'Database session user: ' || session_user
        );

    END IF;

    RETURN NEW;

END;

$function$;
