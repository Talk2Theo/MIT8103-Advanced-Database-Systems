# MIT 8103 — Portfolio 2: SQL Reproducibility Guide

**Course:** Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**DBMS:** PostgreSQL 18.6  
**Experimental Database:** `theoscyba_portfolio2_lab`

## 1. Purpose

This guide documents the database structures, indexing configurations and transactional safeguards used during the Portfolio 2 INSERT benchmark experiments.

The original experiments compared the cost of inserting 10,000 synthetic vulnerability records into two otherwise equivalent PostgreSQL tables with different indexing configurations.

The original measurements, SQL scripts and evidence screenshots have been preserved separately.

**Important:** The SQL examples in this guide are for reproducing the experiment in a fresh, disposable PostgreSQL database. They must not be executed against the existing Portfolio 2 laboratory database or the Portfolio 1 databases.

## 2. Experimental Table Design

Two tables were used:

- `vuln_insert_baseline` — primary-key index only.
- `vuln_insert_indexed` — primary-key index plus three secondary indexes.

Both tables contained seven columns and equivalent data-integrity constraints.

The original laboratory tables were created using PostgreSQL's `LIKE` mechanism with identity, default and constraint options, followed by separate primary-key definitions.

The following explicit SQL recreates their essential column definitions and constraints in a new database.

### 2.1 Baseline Table

```sql
CREATE TABLE public.vuln_insert_baseline (
    vulnerability_id INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    asset_id INTEGER NOT NULL,

    vulnerability_title VARCHAR(200) NOT NULL,

    severity VARCHAR(20) NOT NULL
        CHECK (severity IN (
            'Low', 'Medium', 'High', 'Critical'
        )),

    cvss_score NUMERIC(3,1)
        CHECK (cvss_score BETWEEN 0 AND 10),

    vulnerability_status VARCHAR(30) NOT NULL
        CHECK (vulnerability_status IN (
            'Open', 'In Progress',
            'Remediated', 'Risk Accepted'
        )),

    identified_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP
);
```

The primary-key constraint automatically creates a unique B-tree index.

### 2.2 Indexed Table

```sql
CREATE TABLE public.vuln_insert_indexed (
    vulnerability_id INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    asset_id INTEGER NOT NULL,

    vulnerability_title VARCHAR(200) NOT NULL,

    severity VARCHAR(20) NOT NULL
        CHECK (severity IN (
            'Low', 'Medium', 'High', 'Critical'
        )),

    cvss_score NUMERIC(3,1)
        CHECK (cvss_score BETWEEN 0 AND 10),

    vulnerability_status VARCHAR(30) NOT NULL
        CHECK (vulnerability_status IN (
            'Open', 'In Progress',
            'Remediated', 'Risk Accepted'
        )),

    identified_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP
);
```

The definitions are intended to recreate the relevant column and constraint behaviour of the original benchmark tables; PostgreSQL-generated constraint names may differ.

## 3. Additional Indexes on the Indexed Table

The indexed configuration included the following secondary indexes.

### 3.1 Composite Filtering Index

```sql
CREATE INDEX idx_vuln_insert_severity_status
ON public.vuln_insert_indexed
USING btree (severity, vulnerability_status);
```

### 3.2 Ordered Partial Index

```sql
CREATE INDEX idx_vuln_insert_priority_order
ON public.vuln_insert_indexed
USING btree (
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC
)
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress');
```

### 3.3 Covering Partial Index

```sql
CREATE INDEX idx_vuln_insert_priority_covering
ON public.vuln_insert_indexed
USING btree (
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC
)
INCLUDE (
    vulnerability_title,
    severity,
    vulnerability_status
)
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress');
```

The baseline configuration contained no equivalent secondary indexes.

Consequently, PostgreSQL maintained one index during the baseline INSERT and four indexes during the indexed INSERT.

## 4. Benchmark Execution Procedure

A reviewer wishing to reproduce the experiments should first establish a fresh, disposable PostgreSQL database, connect the pgAdmin Query Tool to that database, and recreate the two table configurations.

The benchmark procedure was:

1. Verify the intended database and check that both experimental tables contain zero records.
2. Start an explicit transaction with `BEGIN`.
3. For controlled trials, reset the appropriate test table using `TRUNCATE ... RESTART IDENTITY` within that transaction.
4. Execute the appropriate saved benchmark INSERT statement once using `EXPLAIN (ANALYZE, BUFFERS, WAL)`.
5. Record the execution time, buffer statistics and WAL measurements.
6. Verify that 10,000 records are visible inside the transaction.
7. Execute `ROLLBACK` in the same PostgreSQL session.
8. Verify that both test tables contain zero records afterward.

The original tests performed transaction management separately from some of the saved measurement scripts. Therefore, those individual SQL files should not be treated as complete, independently safe benchmark procedures.

## 5. Transaction Safety

`EXPLAIN ANALYZE` executes the statement being analysed.

Therefore:

```sql
EXPLAIN (ANALYZE, BUFFERS, WAL)
INSERT INTO ...
```

performs an actual INSERT.

A safe reproduction procedure must ensure that the benchmark is executed inside the intended transaction and that the transaction is rolled back afterward.

For example, the transaction should begin before the measurement:

```sql
BEGIN;

-- Execute the complete benchmark INSERT statement
-- in this same database session.

-- Check the number of inserted records.

ROLLBACK;
```

This example illustrates transaction boundaries and is not itself a complete benchmark script.

The original transaction-control steps should not be assumed to exist inside Scripts 35–40.

Rollback removes the inserted records logically but does not undo generated WAL or every physical and caching effect.

## 6. Original SQL Script References

| Script | Experimental purpose |
|---|---|
| `33_prepare_insert_benchmark_tables.sql` | Verification of benchmark table counts and indexes |
| `34_add_insert_benchmark_indexes.sql` | Secondary-index creation |
| `35_baseline_insert_benchmark.sql` | Initial baseline INSERT measurement |
| `36_indexed_insert_benchmark.sql` | Initial indexed INSERT measurement |
| `37_controlled_baseline_insert_benchmark.sql` | Controlled baseline measurement |
| `38_controlled_indexed_insert_benchmark.sql` | Controlled indexed measurement |
| `39_reverse_order_indexed_insert.sql` | Reverse-order indexed measurement |
| `40_reverse_order_baseline_insert.sql` | Reverse-order baseline measurement |
| `41_consolidate_insert_benchmark_results.sql` | Read-only calculation of benchmark averages |

Although Script 33 is named as a table-preparation script, the saved file contains verification queries rather than the original table-creation statements.

This guide provides the corresponding table definitions.

## 7. Recorded Experimental Results

Three matched INSERT benchmark pairs were completed.

| Trial | Baseline execution | Indexed execution |
|---|---:|---:|
| 1 | 34.153 ms | 116.884 ms |
| 2 | 30.337 ms | 127.934 ms |
| 3 | 32.839 ms | 108.364 ms |
| **Mean** | **32.443 ms** | **117.727 ms** |

The indexed configuration averaged 85.284 ms of additional INSERT execution time.

Its mean execution time was approximately 3.63 times that of the primary-key-only baseline.

The indexed configuration also generated approximately 45.4% more WAL bytes on average.

These results represent the combined maintenance overhead of three additional secondary indexes.

## 8. Reproduction Limitations

Measured execution times may differ across PostgreSQL installations because of hardware resources, caching, database configuration, operating-system scheduling and background workload.

The original experiments used synthetic vulnerability records and three paired measurement trials.

The controlled experiments used transactional table resets and the final pair reversed test order, but these controls did not eliminate every source of performance variation.

The guide reconstructs the essential database definitions and benchmark procedure. It does not guarantee identical execution timings, physical storage conditions or execution-plan choices.

The original screenshots and saved benchmark results remain the authoritative evidence of the measurements observed in this portfolio.
