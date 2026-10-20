# MIT 8103 — Portfolio 2: Optimisation Decisions and Recommendations

**Course:** MIT 8103 — Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**Database Management System:** PostgreSQL 18.6  
**Experimental Database:** `theoscyba_portfolio2_lab`

## 1. Optimisation Decision Context

Theoscyba Security Services' cybersecurity incident and vulnerability management system supports the identification, prioritisation and remediation of vulnerabilities across multiple client organisations.

A significant reporting requirement is the timely retrieval of unresolved high-priority vulnerabilities. Security analysts and managers require results ordered by CVSS score so that the most severe findings can be investigated and assigned for remediation.

The experimental investigation evaluated alternative PostgreSQL execution strategies for this reporting requirement using a synthetic dataset of 200,000 vulnerability records.

The investigation also examined the storage and INSERT-maintenance costs associated with secondary indexes.

The objective of the final recommendation is therefore not simply to minimise SELECT execution time, but to identify a defensible balance between retrieval performance, storage utilisation and write-processing overhead.

## 2. Summary of Evaluated Indexing Strategies

Three secondary B-tree indexing strategies were investigated.

| Strategy | Index storage | Three-run SELECT average |
|---|---:|---:|
| Composite severity/status index | 1,416 kB | 12.465 ms |
| Ordered partial index | 144 kB | 1.859 ms |
| Covering partial index | 336 kB | 1.487 ms |

The sequential-scan diagnostic reference averaged 68.859 ms across three executions.

The covering partial index produced the lowest observed three-run SELECT average. PostgreSQL also selected its Index Only Scan naturally, without temporary planner restrictions.

By comparison, the ordinary ordered partial-index strategy was investigated using temporary planner settings, and the original composite strategy required a separate Sort operation.

These comparisons are descriptive because the benchmark strategies were evaluated at different stages and under partly different execution conditions.

## 3. Recommended Index for High-Priority Vulnerability Reporting

The covering partial B-tree index is recommended as the strongest demonstrated candidate for the tested high-priority vulnerability-reporting query.

The index uses CVSS score and vulnerability identifier as ordering keys, restricts entries to the required high-priority subset, and stores additional result columns through PostgreSQL's `INCLUDE` clause.

Its measured advantages included:

- Natural selection by PostgreSQL's query planner.
- Retrieval of the expected 4,000 qualifying vulnerability records.
- Elimination of a separate Sort operation.
- An Index Only Scan with zero heap fetches in repeated measurements.
- An observed three-run average execution time of 1.487 ms.
- A relatively small storage footprint of 336 kB.

The index addresses both the query's filtering predicate and its output-ordering requirement while providing the selected column values directly from the index.

These results support using the covering partial index for a stable, frequently executed version of this specific reporting query.

However, its suitability should be reassessed if the SELECT column list, severity conditions, remediation-status conditions or ordering requirements change.

## 4. Assessment of the Composite Index

The composite index on severity and vulnerability status improved filtering performance compared with the initial unindexed execution.

Its naturally selected plan used a Bitmap Index Scan and Bitmap Heap Scan.

However, PostgreSQL still required a separate Sort because the index did not provide the report's global CVSS-score ordering.

The composite index may remain useful for other queries, including reports grouped or filtered by severity and vulnerability status without the same ordering requirement.

Its wider applicability is a potential advantage over the specialised partial indexes.

The experiment did not benchmark every reporting query supported by the Theoscyba system.

Therefore, removing the composite index solely because the covering partial index performed better for one query would not be justified.

**Recommendation:** Retain the composite index as a candidate for broader reporting workloads until representative queries have been benchmarked and its continued value has been established.

## 5. Assessment of the Ordered Partial Index

The ordinary ordered partial index occupied 144 kB and provided an access path capable of retrieving qualifying vulnerabilities without a separate Sort.

Its three-run diagnostic average was 1.859 ms.

However, the query required columns unavailable directly from the index, causing PostgreSQL to retrieve additional information from the underlying table.

The recorded ordinary partial-index plans reported substantially more buffer accesses than the covering Index Only Scan.

The covering index uses the same ordering keys and partial-index predicate while also storing the additional selected columns.

Consequently, the two indexes overlap substantially in their support for the tested reporting workload.

Maintaining both indexes could introduce unnecessary storage and write-maintenance costs if neither provides an independent benefit for other important queries.

**Recommendation:** Treat the simpler ordered partial index as a candidate for removal if representative workload testing confirms that the covering index provides the necessary access paths and that the smaller index offers no independent performance or maintenance advantage.

No index should be dropped solely on the basis of the current single-query laboratory experiment.

## 6. Storage Cost Evaluation

The benchmark table's four indexes occupied the following storage:

| Index | Size |
|---|---:|
| Primary-key index | 4,408 kB |
| Composite filtering index | 1,416 kB |
| Ordered partial index | 144 kB |
| Covering partial index | 336 kB |
| **Total** | **6,304 kB** |

PostgreSQL reported approximately 20 MB of table storage and 26 MB of overall relation storage.

Indexes accounted for 24.00% of the overall storage footprint.

The three secondary indexes together occupied 1,896 kB.

The covering partial index required 192 kB more storage than the simpler ordered partial index.

That additional storage was associated with the ability to retrieve the selected values through an Index Only Scan.

Nevertheless, index storage must be considered alongside ongoing maintenance overhead, especially as client organisations, assets and vulnerability records increase.

## 7. INSERT Maintenance-Overhead Evaluation

The INSERT experiments compared two tables with equivalent column definitions and constraints.

The baseline table maintained only a primary-key index.

The indexed table maintained its primary key and the three secondary reporting indexes.

Each trial inserted 10,000 synthetic vulnerability records using equivalent deterministic data-generation logic.

Three benchmark pairs were completed, including one pair executed in reverse order.

| Trial | Baseline INSERT | Indexed INSERT |
|---|---:|---:|
| 1 | 34.153 ms | 116.884 ms |
| 2 | 30.337 ms | 127.934 ms |
| 3 | 32.839 ms | 108.364 ms |
| **Mean** | **32.443 ms** | **117.727 ms** |

The indexed configuration required an average of 85.284 ms more execution time.

Its mean execution time was approximately 3.63 times that of the baseline, representing an observed increase of 262.87%.

The indexed table also generated approximately 45.4% more WAL bytes on average.

These results were consistent with the additional processing required to maintain secondary indexes during record insertion.

However, the measurements represent the combined effect of all three secondary indexes rather than the isolated maintenance cost of any individual index.

## 8. Read-Versus-Write Trade-off

The experimental findings demonstrate that indexing decisions must be based on the balance between read-intensive and write-intensive workloads.

For a read-intensive workload dominated by recurring high-priority vulnerability reports, the covering partial index offers an attractive access strategy.

For a write-intensive workload involving frequent ingestion of new vulnerability findings, maintaining unnecessary secondary indexes can increase execution time and logged database activity.

The INSERT benchmark demonstrated this trade-off directly: the configuration with three additional secondary indexes consistently incurred higher observed INSERT execution times and WAL generation.

The system should therefore avoid introducing multiple overlapping indexes without a demonstrated workload requirement.

**Recommendation:** Prioritise indexes that support important and frequently executed security reports, while reviewing the necessity of additional indexes against the system's vulnerability-ingestion workload.

## 9. Operational Considerations

Several operational factors should be considered before implementing the proposed indexing strategy in a production environment.

**Query frequency:** A report executed frequently may justify a specialised index more strongly than an infrequently used query.

**Data distribution:** Changes in the proportion of Critical, High, Open and In Progress vulnerabilities can affect index selectivity and planner decisions.

**Statistics maintenance:** PostgreSQL statistics should remain sufficiently current for the planner to estimate query cardinality and access costs.

**MVCC visibility:** An Index Only Scan may require heap fetches if the relevant heap pages are not marked all-visible.

**Index maintenance:** INSERT, UPDATE and DELETE operations may require additional index processing and WAL generation.

**Storage growth:** Index sizes should be reassessed as the number of monitored assets and vulnerability findings increases.

**Workload coverage:** Indexes should be evaluated against multiple representative queries rather than a single reporting statement.

**Operational validation:** Proposed indexes should be assessed under production-like concurrency, update patterns and resource utilisation before deployment.

## 10. Experimental Limitations

The study used synthetic vulnerability records generated in a PostgreSQL laboratory database.

The measured execution times were obtained from small samples and may vary with system load, caching and execution order.

Certain diagnostic access paths were produced using temporary planner settings and should not be interpreted as PostgreSQL's naturally preferred production plans.

The INSERT experiments used transactional rollback to preserve logical table contents, but rollback did not erase generated WAL or necessarily restore all physical storage and cache conditions.

The INSERT measurements also excluded the separately executed table-reset operations and transaction-completion costs.

Most importantly, the INSERT benchmark measured the combined cost of maintaining three secondary indexes.

It did not isolate the cost of the covering partial index or determine the optimal index configuration for all possible Theoscyba queries.

Accordingly, the results support workload-specific recommendations rather than universal performance claims.

## 11. Final Optimisation Recommendation

The covering partial B-tree index is recommended as the preferred candidate for the specific high-priority vulnerability-reporting query evaluated in this portfolio.

The recommendation is supported by PostgreSQL's naturally selected Index Only Scan, zero heap fetches during repeated executions, elimination of a separate Sort operation, and an observed three-run average execution time of 1.487 ms.

The composite index should be retained as a candidate for more general severity/status reporting until its value across other workloads has been evaluated.

The simpler ordered partial index should be reviewed for potential redundancy because its filtering and ordering design overlaps with the covering index.

The three-index INSERT experiments also demonstrate that additional reporting indexes can introduce substantial write-maintenance and WAL overhead.

The preferred strategy is therefore to adopt **selective, workload-driven indexing**, retain indexes with demonstrated value, and avoid unnecessary duplication.

This approach balances timely vulnerability prioritisation with efficient data ingestion, storage utilisation and ongoing database maintainability for Theoscyba Security Services.