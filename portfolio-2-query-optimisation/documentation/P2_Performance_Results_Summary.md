# MIT 8103 — Portfolio 2: Performance Results Summary

**Course:** Advanced Database Systems  
**Case study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**DBMS:** PostgreSQL 18  
**Benchmark database:** `theoscyba_portfolio2_lab`  
**Benchmark dataset:** 200,000 synthetic vulnerability records

## 1. Experiment Objective

The experiments evaluated how PostgreSQL query execution plans, indexing strategies and table statistics affect the retrieval of high-priority vulnerabilities. Additional experiments examined the storage and INSERT-maintenance overhead associated with secondary indexes.

The principal reporting query retrieved High or Critical vulnerabilities with Open or In Progress status, ordered by descending CVSS score and ascending vulnerability ID.

## 2. SELECT Query Performance

| Execution strategy | Average execution time | Main finding |
|---|---:|---|
| Sequential Scan | 68.859 ms | Full-table filtering and sorting |
| Composite Bitmap Index Scan | 12.465 ms | Index-assisted filtering; sorting retained |
| Ordered Partial Index Scan | 1.859 ms | Ordered retrieval without a separate Sort |
| Covering Partial Index Only Scan | 1.487 ms | No separate Sort; zero heap fetches |

Each reported average was calculated from three executions.

The covering partial B-tree index included the additional columns required by the SELECT query. PostgreSQL naturally selected an Index Only Scan using this index. All three repeated executions reported zero heap fetches.

The alternative scan strategies were evaluated at different experimental stages, and some involved temporary query-planner settings. Consequently, the timing comparisons are descriptive and do not represent a fully controlled production benchmark.

## 3. Index Storage

| Index | Storage |
|---|---:|
| Primary-key index | 4,408 kB |
| Composite severity/status index | 1,416 kB |
| Ordered partial index | 144 kB |
| Covering partial index | 336 kB |
| **Total** | **6,304 kB** |

The four indexes represented 24.00% of the benchmark relation's overall reported storage footprint.

The covering partial index occupied 192 kB more than the simpler ordered partial index but allowed PostgreSQL to retrieve the selected values without heap fetches during the measured executions.

## 4. INSERT Performance

Three benchmark pairs compared inserting 10,000 synthetic vulnerabilities into a primary-key-only table and a table containing the primary key plus three secondary indexes.

| Metric | Baseline table | Indexed table |
|---|---:|---:|
| Number of indexes | 1 | 4 |
| Mean INSERT execution time | 32.443 ms | 117.727 ms |
| Mean WAL bytes | 1,972,960 | 2,869,253 |

The indexed configuration required an average of 85.284 ms more execution time, corresponding to a 3.63-fold time ratio and an approximately 262.87% increase relative to the baseline.

Average WAL generation was approximately 45.4% higher with the secondary indexes present.

All INSERT trials used equivalent deterministic synthetic data. The transactions were rolled back, and both experimental tables were verified to contain zero records after each test.

## 5. Interpretation and Limitations

The experiments demonstrate a read-versus-write indexing trade-off. The covering partial index provided efficient access to the targeted vulnerability-reporting query through ordered index-only retrieval, while maintaining three additional secondary indexes increased observed INSERT execution time and WAL activity.

The benchmarks used synthetic records and small numbers of repeated executions. Runtime variability, cache state, planner settings, transactional resets and test order may affect measured timings. The INSERT benchmark measured the combined overhead of three secondary indexes, not the isolated cost of the covering index.

## 6. Preliminary Recommendation

For Theoscyba Security Services' specific high-priority vulnerability-reporting workload, the covering partial index is the strongest demonstrated candidate because PostgreSQL naturally selected it, avoided an explicit Sort and performed zero heap fetches during repeated measurements.

The composite index should be evaluated separately against other reporting queries before any decision to remove it. Redundant secondary indexes should not be retained without considering their query benefits, storage consumption and maintenance costs.

These findings support a workload-specific indexing strategy rather than indiscriminate index creation.