# Portfolio 2 — Query Processing and Optimisation

**Course:** MIT 8103 — Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**Database Management System:** PostgreSQL 18.6  
**Administration Tool:** pgAdmin 4  
**Operating System:** Windows 11

## 1. Portfolio Overview

This portfolio investigates PostgreSQL query processing and performance optimisation using a cybersecurity incident and vulnerability management case study.

Theoscyba Security Services is a fictional cybersecurity service provider managing vulnerability and incident information for multiple client organisations.

The experiments examine how database statistics, query execution plans and B-tree indexes influence the retrieval of unresolved high-priority vulnerabilities.

The investigation also evaluates the storage and INSERT-maintenance costs introduced by secondary indexes.

## 2. Experimental Databases

Two database environments were used during the investigation:

| Database | Purpose |
|---|---|
| `theoscyba_rebuild_test` | Verified Portfolio 1 schema and small-dataset query-analysis reference |
| `theoscyba_portfolio2_lab` | Isolated Portfolio 2 indexing and performance benchmark environment |

The original project database, `theoscyba_security_db`, was preserved separately.

The laboratory benchmark table, `public.vulnerabilities_benchmark`, contained 200,000 synthetic vulnerability records.

Of these, 4,000 records satisfied the reporting query's high-priority filtering criteria.

## 3. Benchmark Query

The principal benchmark retrieves vulnerabilities classified as Critical or High with Open or In Progress status.

Results are ordered by descending CVSS score and ascending vulnerability identifier.

```sql
SELECT
    vulnerability_id,
    vulnerability_title,
    severity,
    cvss_score,
    vulnerability_status
FROM public.vulnerabilities_benchmark
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress')
ORDER BY
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC;
```

Query execution was investigated using PostgreSQL's `EXPLAIN`, `EXPLAIN ANALYZE`, `BUFFERS` and, for INSERT experiments, `WAL` reporting.

## 4. Query Execution Strategies

Four principal execution strategies were examined:

1. Sequential Scan followed by Sort.
2. Bitmap Index Scan and Bitmap Heap Scan using a composite B-tree index.
3. Ordered Index Scan using a partial B-tree index.
4. Index Only Scan using a covering partial B-tree index.

### SELECT Performance Results

| Execution strategy | Three-run average |
|---|---:|
| Diagnostic Sequential Scan | 68.859 ms |
| Composite Bitmap Index Scan | 12.465 ms |
| Ordered Partial Index Scan | 1.859 ms |
| Covering Partial Index Only Scan | 1.487 ms |

The initial unindexed benchmark completed in 56.750 ms.

The covering partial index produced the lowest observed three-run average. PostgreSQL naturally selected this index through an Index Only Scan, with no separate Sort operation and zero heap fetches in the measured executions.

Some alternative execution paths were investigated using transaction-local planner settings. Consequently, these measurements should not be interpreted as a fully controlled production comparison.

## 5. Index Storage Evaluation

The benchmark indexes occupied:

| Index | Size |
|---|---:|
| Primary-key index | 4,408 kB |
| Composite severity/status index | 1,416 kB |
| Ordered partial index | 144 kB |
| Covering partial index | 336 kB |
| **Total** | **6,304 kB** |

The four indexes represented approximately 24% of the benchmark relation's reported total storage footprint.

## 6. INSERT Performance and Index-Maintenance Trade-off

Separate experimental tables were used to compare inserting 10,000 synthetic vulnerability records under two configurations:

- A primary-key-only baseline.
- A configuration containing the primary key and three additional secondary indexes.

Three benchmark pairs were completed, including one with reversed test order.

| Metric | Baseline | Indexed |
|---|---:|---:|
| Mean INSERT time | 32.443 ms | 117.727 ms |
| Mean WAL bytes | 1,972,960 | 2,869,253 |

The indexed configuration produced a 3.63-fold average execution-time ratio and approximately 45.4% greater WAL volume.

The INSERT experiments measured the combined maintenance cost of three secondary indexes, not the isolated cost of the covering index.

The test transactions were rolled back to preserve the logical contents of the experimental tables.

## 7. Portfolio Files

### SQL Scripts

The `sql/` directory contains 41 numbered SQL scripts.

| Script range | Purpose |
|---|---|
| 01–11 | Baseline queries, execution plans and database statistics |
| 12–16 | Synthetic benchmark creation, data generation and initial execution |
| 17–20 | Composite-index evaluation and repeated comparisons |
| 21–26 | Ordered partial-index creation and diagnostic evaluation |
| 27–30 | Visibility statistics and covering-index experiments |
| 31–32 | Index and relation storage analysis |
| 33–40 | INSERT benchmarks, indexing overhead, WAL analysis and rollback verification |
| 41 | Consolidated INSERT benchmark calculations |

### Screenshot Evidence

Screenshots `P2_E01` through `P2_E54` document query results, index creation, execution plans, performance measurements, storage statistics and transaction verification.

The screenshots are stored in the Portfolio 2 directory.

### Technical Documentation

The following files provide the main written evidence:

- `P2_Initial_Performance_Analysis.md` — Initial query-performance investigation.
- `P2_Performance_Results_Summary.md` — Consolidated performance measurements.
- `P2_Experimental_Methodology.md` — Experimental procedures, controls and limitations.
- `P2_Execution_Plan_Analysis.md` — Detailed analysis of four PostgreSQL execution strategies.
- `P2_Optimisation_Decisions_and_Recommendations.md` — Final indexing recommendations and read/write trade-offs.
- [P2_SQL_Reproducibility_Guide.md](P2_SQL_Reproducibility_Guide.md) — Reconstructed INSERT benchmark table definitions, indexing configurations, transaction safeguards and safe reproduction instructions.


## 8. Reproducibility and Execution Safety

For detailed instructions on reconstructing the INSERT
benchmark tables and safely conducting the experiments,
see the [SQL Reproducibility Guide](P2_SQL_Reproducibility_Guide.md).

Some archived benchmark scripts contain only the measured
SQL statement. Transaction-management commands were
executed separately during the original experiments.

Do not run the INSERT benchmark scripts independently
without first establishing an appropriate transaction.


**The SQL scripts are an experimental record, not a single script bundle that should be executed indiscriminately.**

Some scripts create tables or indexes, generate records, modify table statistics, or perform measured INSERT operations.

The early baseline scripts refer to the small Portfolio 1-derived schema, while the larger benchmark scripts use the dedicated Portfolio 2 laboratory database.

Before replaying any script, the reviewer should inspect its SQL statements and confirm the intended database and required setup.

In particular:

- Use a separate disposable PostgreSQL database for fresh performance experiments.
- Do not execute benchmark scripts against production databases.
- Review table-creation and data-generation scripts before running them.
- Existing indexes may cause repeated `CREATE INDEX` commands to fail.
- `EXPLAIN ANALYZE` executes the underlying SQL statement; for INSERT statements, this means records are actually inserted unless protected by appropriate transaction handling.
- Diagnostic planner settings should be restored after testing.
- Execution times may differ across hardware, PostgreSQL configurations, workloads and cache conditions.

The screenshots and technical reports document the results observed during the original experiments.

## 9. Final Technical Recommendation

For the tested high-priority vulnerability-reporting query, the covering partial B-tree index is the strongest demonstrated optimisation candidate.

Its primary advantages are predicate-specific indexing, ordered retrieval, access to the selected columns from the index and zero heap fetches in the measured plans.

However, the INSERT experiments demonstrated that maintaining additional reporting indexes increases write-processing overhead and WAL activity under the tested conditions.

The recommended approach is therefore **workload-driven indexing**: retain indexes that provide demonstrable benefits to important queries and review overlapping or low-value indexes before deployment.

## 10. Portfolio Outcome

The portfolio demonstrates practical use of PostgreSQL query planning, table statistics, execution-plan interpretation, composite indexing, partial indexing, covering indexes, buffer analysis, index storage measurement and INSERT/WAL performance evaluation.

The completed experiments provide evidence for database optimisation decisions within a cybersecurity vulnerability management context.