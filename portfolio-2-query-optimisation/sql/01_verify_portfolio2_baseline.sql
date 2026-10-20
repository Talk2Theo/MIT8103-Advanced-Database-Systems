
SELECT 'clients' AS table_name, COUNT(*) AS record_count
FROM public.clients

UNION ALL

SELECT 'assets', COUNT(*)
FROM public.assets

UNION ALL

SELECT 'analysts', COUNT(*)
FROM public.analysts

UNION ALL

SELECT 'incidents', COUNT(*)
FROM public.incidents

UNION ALL

SELECT 'vulnerabilities', COUNT(*)
FROM public.vulnerabilities

UNION ALL

SELECT 'remediation_activities', COUNT(*)
FROM public.remediation_activities

UNION ALL

SELECT 'audit_logs', COUNT(*)
FROM public.audit_logs

UNION ALL

SELECT 'incident_assignments', COUNT(*)
FROM public.incident_assignments

ORDER BY table_name;
