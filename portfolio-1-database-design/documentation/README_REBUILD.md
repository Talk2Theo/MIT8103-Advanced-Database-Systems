# Theoscyba Security Services — PostgreSQL Database Rebuild Guide

**Course:** MIT 8103 — Advanced Database Systems  
**Portfolio:** Portfolio 1  
**Case study:** Cybersecurity Incident and Vulnerability Management System  
**Environment:** Windows 11, PostgreSQL 18 (64-bit), pgAdmin 4  
**Demonstration database:** `theoscyba_rebuild_test`  
**Original database (protect from test scripts):** `theoscyba_security_db`

## 1. Purpose

This guide documents the intended SQL execution order for recreating the Theoscyba Security Services demonstration database and its selected operational test results. The system manages clients, assets, analysts, incidents, vulnerabilities, remediation activities, JSONB-based audit history, and incident assignment history.

This execution order was assembled from the successfully completed stepwise rebuild and subsequent verifications. The complete final set of saved scripts has **not yet been independently executed start-to-finish in a brand-new empty database**. Before treating it as a fully automated, validated rebuild procedure, perform a separate clean-room test after reviewing all scripts.

## 2. Preconditions and safety

1. Use PostgreSQL 18 and pgAdmin 4 (or a compatible PostgreSQL SQL client).
2. Connect to an **empty, disposable demonstration database**, provisioned separately from the original working database. The previously tested demonstration database is `theoscyba_rebuild_test` and is **already populated**; do not run initialization scripts in it again.
3. Do **not** execute state-changing rebuild or test scripts against `theoscyba_security_db`.
4. Confirm the connection with `SELECT current_database();` before running any script.
5. Run scripts **individually, in the explicit order below**, checking their messages and row counts after each stage. Do not execute the entire folder alphabetically; filename sorting is not the dependency order.
6. Scripts `14_test_audit_trigger.sql` and `18_incident_handover.sql` are intentional **one-time state-changing demonstrations**, not ordinary read-only verification scripts. Run each at most once on the appropriately prepared demonstration dataset.
7. The negative-test scripts `11_test_remediation_constraints.sql` and `17_test_assignment_constraints.sql` are **excluded** from the regular rebuild sequence. They may deliberately raise PostgreSQL errors; review and isolate them before any separate testing.

> **Caution:** Several existing SQL scripts and guards refer explicitly to `theoscyba_rebuild_test`. If performing an independent clean-room rebuild under a different database name, review and adapt those guards in copies of the scripts before execution. Do not bypass safeguards in the original working database.

## 3. Required normal execution order

### Phase A — Core tables and initial records

| Order | SQL file | Expected purpose |
|---:|---|---|
| 01 | `01_create_clients.sql` | Create clients table |
| 02 | `01b_insert_clients.sql` | Insert six clients |
| 03 | `02_create_assets.sql` | Create assets table with client relationship |
| 04 | `02b_insert_initial_assets.sql` | Insert six original assets |
| 05 | `03_create_analysts.sql` | Create analysts table |
| 06 | `03b_insert_analysts.sql` | Insert five analysts |
| 07 | `04_create_incidents.sql` | Create incidents table |
| 08 | `05_insert_incidents.sql` | Insert four incidents |
| 09 | `06_create_vulnerabilities.sql` | Create vulnerabilities table |
| 10 | `07_insert_vulnerabilities.sql` | Insert four initial vulnerabilities |

### Phase B — Expanded assets, vulnerabilities and remediation

| Order | SQL file | Expected purpose |
|---:|---|---|
| 11 | `08a_insert_expansion_assets.sql` | Insert six additional assets |
| 12 | `08_expand_vulnerabilities.sql` | Insert four vulnerabilities referencing the expanded assets |
| 13 | `09_create_remediation_activities.sql` | Create remediation activities table |
| 14 | `10_insert_remediation_activities.sql` | Insert seven remediation activities |

**Dependency:** `08a_insert_expansion_assets.sql` must run **before** `08_expand_vulnerabilities.sql`, because the new vulnerability records reference the new asset records.

### Phase C — JSONB audit history

| Order | SQL file | Expected purpose |
|---:|---|---|
| 15 | `12_create_audit_logs.sql` | Create audit table with JSONB snapshots |
| 16 | `13a_create_audit_function.sql` | Create `audit_vulnerability_updates()` function |
| 17 | `13_create_audit_trigger.sql` | Create the trigger on `vulnerabilities` |
| 18 | `14_test_audit_trigger.sql` | **One-time:** update a specified FOLM vulnerability and capture one audit event |

**Dependency:** The audit function must exist **before** its trigger is created. Script `14` deliberately changes the FOLM vulnerability description and should only run once when the original description matches its safety check.

### Phase D — Incident assignments and handover

| Order | SQL file | Expected purpose |
|---:|---|---|
| 19 | `15_create_incident_assignments.sql` | Create assignment-history table and partial unique index |
| 20 | `16_initial_incident_assignments.sql` | Insert three initial active assignment records |
| 21 | `16a_verify_initial_incident_ownership.sql` | **Read-only:** verify initial ownership *before* the handover |
| 22 | `18_incident_handover.sql` | **One-time:** end Chineze's PaySecure VPN assignment, insert Amina's assignment, update current ownership |
| 23 | `19_verify_assignment_history.sql` | Verify post-handover assignment history; confirm its saved contents before relying on it |

**Dependency:** Script `16` must run before script `18`. The handover ends Chineze's active PaySecure VPN assignment **before** creating Amina's new active assignment so that the partial unique index is respected. Script `16a` is a **pre-handover** check, not a final-state verification.

### Phase E — Final database verification

| Order | SQL file | Expected purpose |
|---:|---|---|
| 24 | `20_verify_database_rebuild.sql` | **Read-only:** verify table and record counts, advanced database objects, and incident ownership |

## 4. Scripts deliberately excluded from the normal rebuild

| SQL file | Reason | How to handle |
|---|---|---|
| `11_test_remediation_constraints.sql` | Contains deliberately invalid remediation operations intended to demonstrate CHECK constraints | Review and run separately only in a disposable test environment with deliberate transaction management |
| `17_test_assignment_constraints.sql` | Contains deliberately invalid assignment operations intended to demonstrate the active-assignment uniqueness rule | Review and run separately only in a disposable test environment; do not include in routine setup |

The presence of PostgreSQL constraint errors during these *negative tests* may be the intended outcome. Never treat them as normal setup scripts.

## 5. Expected final demonstration state

After all the ordinary setup, one-time demonstrations, and checks complete successfully, the documented demonstration state is:

| Object or metric | Expected count / value |
|---|---:|
| Base tables | 8 |
| Foreign-key constraints | 10 |
| Clients | 6 |
| Assets | 12 |
| Analysts | 5 |
| Incidents | 4 |
| Vulnerabilities | 8 |
| Remediation activities | 7 |
| Audit-log records | 1 |
| Incident assignment-history records | 4 |
| Active incident assignments | 3 |
| Ended incident assignments | 1 |

Additional expected checks:

- `trg_audit_vulnerability_updates` is enabled on `vulnerabilities`.
- `uq_active_incident_assignment` is present as a partial unique index for active assignment records (`unassigned_at IS NULL`).
- The FOLM *Missing Server Security Patches* audit record captures distinct old/new vulnerability descriptions in JSONB while the checked severity, CVSS and status fields remain unchanged.
- The PaySecure *Suspicious VPN Sign-in* incident is currently assigned to **Amina Yusuf**; **Chineze Okafor** retains one ended historical assignment for that incident.
- The PaySecure *Unauthorised Database Login Attempts* incident remains unassigned.
- The other incidents retain their expected owners: Chineze for MedTrust malware, Amina for ShopEase repeated failed logins.
- A consistency query reports `MATCH` for current ownership versus active assignment history across all four incidents.
- No incident has more than one active historical assignment.

**Dataset note:** The documented demonstration state has **12 assets**: six initial plus six expansion assets with assigned IP addresses. This is an intentional revision from the earlier 10-asset dataset.

## 6. Evidence and review

Store SQL scripts in `sql/` and screenshots in `screenshots/`. Useful evidence includes:

1. Final table and foreign-key counts.
2. The eight-table entity-relationship diagram (ERD).
3. Audit trigger enabled status and old/new JSONB snapshots.
4. Assignment-history records after the handover, including the ended Chineze and active Amina records.
5. Ownership consistency and duplicate-active-assignment checks.
6. The final result of `20_verify_database_rebuild.sql`.

Keep the ERD, SQL, screenshots, and academic report consistent with the final **12-asset** demonstration dataset.

## 7. Reproducibility status and next review

- **Completed:** All 26 expected SQL files have been confirmed present in the project `sql/` folder.
- **Completed:** The populated `theoscyba_rebuild_test` database passed the reported final table, foreign-key, row-count, audit-object and incident-ownership checks.
- **Completed:** The guarded audit update and incident handover were each executed and verified in the existing demonstration database.
- **Pending:** Inspect the saved contents of `19_verify_assignment_history.sql` and other scripts as needed to confirm that the *files on disk* match this guide.
- **Pending:** Independently replay the final saved scripts from a separate empty database if strict end-to-end rebuild reproducibility is required.

**Do not rerun the setup sequence in either existing populated database as part of the README preparation.**
