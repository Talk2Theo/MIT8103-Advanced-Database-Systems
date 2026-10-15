
CREATE TRIGGER trg_audit_vulnerability_updates
AFTER UPDATE ON vulnerabilities
FOR EACH ROW
EXECUTE FUNCTION audit_vulnerability_updates();
