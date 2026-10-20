# MIT 8103 — Portfolio 3: Transactions and Concurrency Control

## 1. Case Study

**Organisation:** Theoscyba Security Services  
**System:** Cybersecurity Incident and Vulnerability Management System  
**Database:** PostgreSQL 18  
**Laboratory database:** `theoscyba_portfolio3_lab`

This practical exercise demonstrates transaction processing and concurrency control in a simulated cybersecurity incident-management environment. Security analysts update incident statuses and assignments while PostgreSQL ensures that concurrent operations are handled consistently.

A dedicated laboratory database containing **100 fictional security incidents** was created to isolate the experiments from the earlier portfolio databases.

## 2. Objectives

The experiments demonstrate:

- Transaction management using `BEGIN`, `COMMIT` and `ROLLBACK`.
- Transaction isolation using `READ COMMITTED`.
- Prevention of dirty reads.
- Row-level locking and concurrency control using `FOR UPDATE SKIP LOCKED`.
- Visibility of committed changes across independent database sessions.

## 3. Practical Implementation and Results

### Experiment 1 — COMMIT

A transaction updated incident 101 from `Open` to `Investigating`.

After executing `COMMIT`, a verification query confirmed that the new status persisted.

**Result:** COMMIT successfully preserved the updated incident status.

### Experiment 2 — ROLLBACK

A transaction temporarily updated incident 102 from `Open` to `Resolved`.

After executing `ROLLBACK`, a verification query returned the original status, `Open`.

**Result:** ROLLBACK successfully cancelled the uncommitted modification.

### Experiment 3 — Transaction Isolation

Two independent PostgreSQL sessions simulated concurrent security analysts.

Session A updated the assigned analyst for incident 103 from Tunde to Daniel but left the transaction uncommitted.

Session B, using `READ COMMITTED` isolation, still returned Tunde.

**Result:** Session B could not observe Session A's uncommitted change, demonstrating prevention of dirty reads.

### Experiment 4 — Concurrency Control

While Session A held a row-level lock on incident 103, Session B executed a query using `FOR UPDATE SKIP LOCKED`.

The query returned zero rows because the locked incident was skipped.

After Session A committed its transaction, Session B queried the incident again and returned Daniel.

**Result:** PostgreSQL successfully demonstrated row-level locking, non-blocking row selection and visibility of committed data.

## 4. ACID Properties and Technical Interpretation

- **Atomicity:** ROLLBACK cancelled the transaction's modifications.
- **Consistency:** Primary-key and CHECK constraints protected the validity of incident records.
- **Isolation:** READ COMMITTED prevented Session B from observing uncommitted changes.
- **Durability:** The committed update remained available in subsequent queries, demonstrating persistence at the SQL level.

The concurrency experiment also demonstrated that READ COMMITTED uses a new committed-data snapshot for each statement. The use of SKIP LOCKED provides a practical mechanism for allowing security analysts or automated workers to bypass records currently locked by another transaction.

## 5. SQL Implementation

The `sql/` directory contains:

1. `02_setup_transaction_lab.sql` — Creates and populates the 100-record incident laboratory.
2. `03_commit_rollback.sql` — Demonstrates COMMIT and ROLLBACK.
3. `04_session_a_concurrency.sql` — Performs the uncommitted update and subsequent COMMIT.
4. `05_session_b_concurrency.sql` — Tests isolation, locked-row skipping and committed-data visibility.

**Execution note:** The concurrency demonstration requires two independent pgAdmin Query Tool connections. Session A's transaction must remain open while Session B performs the isolation and locking tests. The Session B transaction is closed after verification.

The experiment is stateful: incident 103 is assigned to Daniel after completion. Repeating the demonstration requires restoring its initial assignment to Tunde before beginning a new test.

## 6. Screenshot Evidence

The `evidence/` directory contains seven supporting screenshots:

| Evidence | Description |
|---|---|
| P3_E01 | Laboratory setup and 100 incident records |
| P3_E02 | Successful COMMIT transaction |
| P3_E03 | Successful ROLLBACK transaction |
| P3_E04 | Session A uncommitted incident update |
| P3_E05 | Session B isolation verification |
| P3_E06 | Concurrent row-lock handling using SKIP LOCKED |
| P3_E07 | Committed update visible in Session B |

## 7. Technical Reflection

This exercise demonstrated why transaction management is important to cybersecurity operations. Multiple security analysts may attempt to investigate or reassign the same incident, creating risks of inconsistent records or conflicting updates.

The COMMIT and ROLLBACK experiments illustrated the difference between permanent changes and reversible transactions. The two-session experiment further showed that transaction isolation prevents one analyst from accessing another analyst's uncommitted work.

A key lesson was that row-level locking can protect concurrent operations, while SKIP LOCKED can help incident-processing workers avoid unnecessary waiting. However, skipped records must be revisited appropriately so that important incidents are not overlooked.

## 8. AI Use Declaration

OpenAI ChatGPT was used as a learning and technical assistance tool to help structure the PostgreSQL experiments, explain transaction concepts, develop SQL examples and organise the portfolio documentation.

The SQL exercises were executed in pgAdmin using the dedicated laboratory database. Results were inspected against expected outcomes, and screenshots were captured as evidence. The interpretations and final submission remain subject to my review and understanding.

## 9. Conclusion

The Portfolio 3 experiments successfully demonstrated COMMIT, ROLLBACK, READ COMMITTED isolation, row-level locking and SKIP LOCKED concurrency control within the Theoscyba cybersecurity incident-management scenario.