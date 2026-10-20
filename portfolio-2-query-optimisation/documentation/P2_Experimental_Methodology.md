# MIT 8103 — Portfolio 2: Experimental Methodology

**Course:** MIT 8103 — Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**Database Management System:** PostgreSQL 18.6  
**Administration Tool:** pgAdmin 4  
**Operating System:** Windows 11  
**Experimental Database:** `theoscyba_portfolio2_lab`

## 1. Experimental Aim

The experimental investigation evaluated the effects of query planning, database statistics and alternative B-tree indexing strategies on PostgreSQL query performance.

The principal objective was to optimise a vulnerability-reporting query used to identify outstanding high-priority cybersecurity vulnerabilities.

A secondary objective was to assess the trade-off between faster query retrieval and the additional storage, transaction logging and write-maintenance overhead associated with secondary indexes.

The experiments were conducted using synthetic cybersecurity data to provide a reproducible laboratory workload without exposing confidential client vulnerability information.

## 2. Experimental Environment and Dataset

PostgreSQL 18.6 was used on a Windows 11 workstation, with SQL commands executed through pgAdmin 4.

A dedicated database, `theoscyba_portfolio2_lab`, was used to isolate the performance experiments from the original Theoscyba Security Services database and the previously verified schema-rebuild database.

The principal benchmark table was `public.vulnerabilities_benchmark`, containing 200,000 synthetic vulnerability records.

The dataset contained the following severity distribution:

| Severity | Records |
|---|---:|
| Critical | 4,000 |
| High | 16,000 |
| Medium | 80,000 |
| Low | 100,000 |
| **Total** | **200,000** |

Vulnerability statuses were distributed across Open, In Progress, Remediated and Risk Accepted classifications.

A total of 4,000 records satisfied the high-priority reporting criteria. These represented 2% of the benchmark dataset.

The test data was generated using PostgreSQL's `generate_series()` function and deterministic SQL expressions.

## 3. Reporting Query and Optimisation Objective

The target query retrieved vulnerability identifiers, titles, severity classifications, CVSS scores and current statuses.

It selected vulnerabilities classified as Critical or High whose status was Open or In Progress.

The results were ordered by descending CVSS score, with vulnerability identifier used as an ascending secondary ordering key.

The optimisation objective was to reduce the cost of locating and returning the relevant records while preserving the query's filtering conditions and ordering requirements.

The exact reporting predicate and ordering expressions were retained throughout the principal SELECT benchmark experiments.

## 4. Query Planning and Baseline Evaluation

Initial execution plans were inspected using PostgreSQL's `EXPLAIN` and `EXPLAIN (ANALYZE, BUFFERS)` facilities.

The investigation began with the small original dataset before progressing to the 200,000-record laboratory dataset.

The `ANALYZE` command was used to update table statistics and investigate how estimated row counts influenced query-planning decisions.

The laboratory query was evaluated initially without secondary filtering indexes, establishing a sequential-scan reference.

Subsequent experiments examined how introducing indexes affected PostgreSQL's estimated costs, actual execution times, row estimates, sorting operations and buffer accesses.

## 5. Indexing Strategies Evaluated

Three secondary B-tree indexing strategies were evaluated.

### 5.1 Composite B-tree Index

A composite index on severity and vulnerability status was created to support filtering.

PostgreSQL naturally selected a Bitmap Index Scan and Bitmap Heap Scan for the relevant query during the initial indexed experiment.

A separate Sort operation remained necessary because the index keys did not directly supply the requested global CVSS-score ordering.

### 5.2 Ordered Partial B-tree Index

A partial index was created using CVSS score and vulnerability identifier as ordering keys, restricted to vulnerabilities satisfying the high-priority reporting predicate.

The partial index provided an alternative access path that could return qualifying records in the required order without a separate Sort operation.

Transaction-local planner settings were used diagnostically to encourage PostgreSQL to evaluate this alternative path.

These diagnostic results were distinguished from naturally selected plans.

### 5.3 Covering Partial B-tree Index

A covering partial index was created using the same ordering keys and partial-index predicate.

Additional columns were stored through PostgreSQL's `INCLUDE` clause.

This allowed the benchmark query's selected columns to be satisfied from the index.

PostgreSQL naturally selected an Index Only Scan during the covering-index evaluation.

The measured executions reported zero heap fetches, consistent with the recorded high visibility of the benchmark table's heap pages.

## 6. SELECT Performance Measurement

The primary performance metric was PostgreSQL's reported `Execution Time` from `EXPLAIN ANALYZE`.

Additional observations included:

- Execution-plan node types and selected indexes.
- Estimated and actual row counts.
- Whether a separate Sort operation was required.
- Shared-buffer hits and reads.
- Heap fetches for Index Only Scans.
- Estimated planner costs.

Repeated measurements were obtained for the principal execution strategies, with three executions used to calculate each reported average.

Sequential and alternative index-access paths were sometimes examined using transaction-local planner settings. These settings were restored through `ROLLBACK`.

The final covering-index benchmark used PostgreSQL's naturally selected execution strategy.

Execution-time comparisons were treated as observational because measurements occurred at different experimental stages and under different planner conditions.

## 7. Index Storage Evaluation

PostgreSQL's relation-size functions and system catalogs were used to measure individual index sizes and the combined storage footprint of the benchmark table and its indexes.

The assessment distinguished the mandatory primary-key index from the three secondary indexes introduced for query optimisation.

Storage measurements were used to examine whether the observed query-performance benefits justified additional index space.

## 8. INSERT Maintenance-Overhead Evaluation

Two separate benchmark tables were prepared with equivalent column definitions and constraints.

The baseline table, `vuln_insert_baseline`, contained one primary-key index.

The indexed table, `vuln_insert_indexed`, contained its primary key and three additional reporting indexes.

Each test inserted 10,000 deterministic synthetic vulnerability records using equivalent SQL generation logic.

Execution time, shared-buffer activity and Write-Ahead Log (WAL) generation were captured using:

`EXPLAIN (ANALYZE, BUFFERS, WAL)`

Three benchmark pairs were recorded. The first two pairs executed the baseline test before the indexed test, while the third reversed that order.

The later experiments used transactional `TRUNCATE` operations to reset test-table storage before measuring the INSERT statement.

The transactions were rolled back, and row counts were checked afterward to confirm that no benchmark records remained logically visible in either experimental table.

The comparison assessed the combined overhead of maintaining three secondary indexes. It did not attempt to isolate the individual maintenance cost of each index.

## 9. Experimental Controls and Limitations

The following controls were applied:

- A dedicated laboratory database was used to avoid modifying the original project databases.
- The principal SELECT workload retained consistent filtering and ordering conditions.
- Deterministic synthetic data supported repeatability.
- SQL execution plans and measurements were captured as screenshots.
- Repeated executions were used rather than relying entirely on individual timings.
- Transaction-local planner changes were restored after diagnostic experiments.
- INSERT tests used equivalent generated records and matched benchmark pairs.

Several limitations remain.

The experiments used a synthetic workload rather than live production security data.

The benchmark sample sizes were limited, and measurements were not collected under a controlled multi-user production load.

Caching, operating-system scheduling, background PostgreSQL activity and execution order may have influenced timing variation.

Transactional rollback removed the inserted records logically but did not reverse all underlying physical activity, WAL generation or identity-sequence changes.

Furthermore, the reported INSERT execution times excluded the separately executed transactional reset operations and transaction-completion costs.

Therefore, the findings are interpreted as evidence of performance behaviour under the tested laboratory conditions, not as guaranteed production performance improvements.

## 10. Evidence and Reproducibility

SQL scripts, PostgreSQL execution plans, verification queries, table statistics, benchmark calculations and screenshots were saved throughout the experimental investigation.

These materials provide a traceable record of the database configurations, executed workloads, measured outcomes and optimisation decisions.

The experimental results are consolidated separately in `P2_Performance_Results_Summary.md`.

Together, the methodology and results documents support an evidence-based evaluation of PostgreSQL query processing and indexing strategies for Theoscyba Security Services.