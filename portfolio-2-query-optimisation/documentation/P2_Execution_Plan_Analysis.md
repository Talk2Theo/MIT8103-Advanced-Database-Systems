# MIT 8103 — Portfolio 2: PostgreSQL Execution Plan Analysis

**Course:** MIT 8103 — Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System  
**DBMS:** PostgreSQL 18.6  
**Experimental Database:** `theoscyba_portfolio2_lab`  
**Benchmark Dataset:** 200,000 synthetic vulnerability records

## 1. Sequential Scan and Sort — Initial Benchmark

### 1.1 Execution Plan

The initial benchmark query was evaluated before secondary filtering indexes were introduced to the 200,000-record laboratory table.

PostgreSQL selected a Sequential Scan followed by a Sort operation.

The principal execution-plan observations were:

| Metric | Recorded value |
|---|---:|
| Estimated qualifying rows | 4,051 |
| Actual qualifying rows | 4,000 |
| Rows removed by filtering | 196,000 |
| Sequential Scan actual time | 0.024–44.334 ms |
| Sort actual time | 55.573–56.245 ms |
| Sort method | Quicksort |
| Sort memory | 392 kB |
| Shared-buffer hits | 2,492 |
| Estimated total plan cost | 5,744.86 |
| Planning time | 0.423 ms |
| Initial execution time | 56.750 ms |

**Evidence:** `P2_E15` — Unindexed benchmark execution plan.

### 1.2 Interpretation of the Sequential Scan

The Sequential Scan examined the benchmark table and evaluated each candidate row against the vulnerability-reporting conditions.

The query selected vulnerabilities classified as Critical or High and whose remediation status was Open or In Progress.

Of the 200,000 records in the dataset, 196,000 were removed by the filter, leaving 4,000 qualifying vulnerabilities.

Therefore, only 2% of the dataset satisfied the reporting criteria.

The Sequential Scan was required to examine the table without the benefit of a secondary index designed specifically for the reporting predicate.

This illustrates why selective reporting queries may benefit from suitable indexing when tables become large.

### 1.3 Interpretation of the Sort Operation

The reporting query required results to be ordered by descending CVSS score and ascending vulnerability identifier.

Because the Sequential Scan did not produce rows in that order, PostgreSQL used a separate Sort operation.

The execution plan identified quicksort as the sorting method and reported approximately 392 kB of memory usage.

The Sort operation processed the 4,000 qualifying records after filtering.

The initial full-query execution time was 56.750 ms.

### 1.4 Cardinality Estimation

PostgreSQL estimated that 4,051 rows would satisfy the query predicate, while 4,000 rows actually qualified.

The estimate was close to the observed result.

However, accurate cardinality estimation does not independently guarantee an efficient execution plan. The available access paths and ordering requirements also influence the amount of work required.

### 1.5 Buffer Analysis

The initial plan recorded 2,492 shared-buffer hits.

These accesses were served from PostgreSQL's shared buffer cache during the measured execution.

The count is not necessarily a count of distinct physical disk reads.

The plan demonstrates the buffer-access activity associated with evaluating the reporting predicate across the benchmark table.

### 1.6 Repeated Sequential-Scan Measurements

A later diagnostic experiment used temporary planner settings to discourage index and bitmap access paths while retaining the same reporting query.

Three measured execution times were recorded:

| Trial | Execution time |
|---|---:|
| 1 | 79.229 ms |
| 2 | 57.996 ms |
| 3 | 69.352 ms |
| **Average** | **68.859 ms** |

The variation across these results demonstrates why a single execution time should not be presented as a universally representative measurement.

The repeated diagnostic average is treated separately from the original unindexed plan's 56.750 ms execution time.

**Evidence:** `P2_E21`–`P2_E23` — Sequential-scan diagnostic measurements.

### 1.7 Optimisation Significance

The Sequential Scan and Sort established a reference for evaluating subsequent indexing strategies.

The plan demonstrated that PostgreSQL had to evaluate a large number of records to identify a relatively small qualifying subset, then perform additional work to return that subset in the required order.

This justified investigating indexes that could improve predicate evaluation and potentially satisfy the ordering requirement without a separate Sort.

The next experiment evaluated a composite B-tree index on severity and vulnerability status.

## 2. Composite B-tree Index: Bitmap Index Scan and Bitmap Heap Scan

### 2.1 Index Design and Optimisation Objective

Following the initial Sequential Scan benchmark, a composite B-tree index was created on the `severity` and `vulnerability_status` columns of `public.vulnerabilities_benchmark`.

The index was named `idx_vuln_benchmark_severity_status`.

Its purpose was to accelerate the identification of outstanding high-priority vulnerabilities by supporting the query's filtering predicates.

The query continued to retrieve the same five result columns and retained its ordering requirements, allowing the indexed plan to be compared with the unindexed reference.

### 2.2 Execution Plan

After creating the composite index, PostgreSQL selected a Bitmap Index Scan followed by a Bitmap Heap Scan and a Sort operation.

The recorded execution-plan measurements were:

| Metric | Recorded value |
|---|---:|
| Selected index | `idx_vuln_benchmark_severity_status` |
| Estimated qualifying rows | 4,051 |
| Actual qualifying rows | 4,000 |
| Bitmap Index Scan actual time | 0.467 ms |
| Bitmap Heap Scan actual time | 0.814–3.221 ms |
| Exact heap blocks | 421 |
| Sort method | Quicksort |
| Sort memory | 392 kB |
| Shared-buffer hits | 423 |
| Shared-buffer reads | 7 |
| Estimated total plan cost | 2,962.99 |
| Planning time | 2.252 ms |
| Initial indexed execution time | 13.027 ms |

**Evidence:** `P2_E16` — Composite index creation; `P2_E17` — Indexed execution plan.

### 2.3 Interpretation of the Bitmap Index Scan

The Bitmap Index Scan used the composite B-tree index to identify entries satisfying the severity and vulnerability-status conditions.

PostgreSQL collected matching tuple locations into a bitmap, which was subsequently used by the Bitmap Heap Scan to retrieve the associated table records.

The Bitmap Index Scan returned 4,000 matching entries.

The execution plan also reported two index searches, reflecting PostgreSQL's selected index-access strategy for the query predicates.

This operation reduced the need to perform unrestricted row-by-row filtering across the entire 200,000-record table.

### 2.4 Interpretation of the Bitmap Heap Scan

The Bitmap Heap Scan retrieved the matching vulnerability records from the underlying table.

The execution plan reported 421 exact heap blocks.

The exact-block statistic indicates that PostgreSQL retained precise tuple-location information for those heap blocks rather than relying on a lossy bitmap requiring broader rechecking.

Bitmap heap access can be advantageous when multiple qualifying records are located on relatively few heap pages because PostgreSQL can organise heap retrieval around page locations.

This contrasts with an ordinary Index Scan, which follows index entries to retrieve corresponding table tuples.

The recorded Bitmap Heap Scan produced 4,000 qualifying rows.

### 2.5 Why PostgreSQL Retained the Sort Operation

Although the composite index improved filtering, its key columns were `severity` and `vulnerability_status`.

The reporting query required a different ordering:

1. Descending `cvss_score`, with null values last.
2. Ascending `vulnerability_id`.

Consequently, the composite index did not directly supply the required global output order.

Furthermore, the Bitmap Heap Scan retrieves records according to bitmap-driven heap access rather than preserving the B-tree's key order.

PostgreSQL therefore performed a separate Sort after retrieving the qualifying records.

The Sort used quicksort and approximately 392 kB of memory.

This result demonstrates that an index designed for efficient filtering does not necessarily eliminate a query's ordering cost.

### 2.6 Buffer and Cardinality Analysis

The indexed plan reported 423 shared-buffer hits and seven shared-buffer reads at the top execution node.

These represented 430 reported shared-buffer accesses during the measured execution.

The earlier unindexed plan reported 2,492 shared-buffer hits.

Although buffer accesses are not equivalent to distinct disk reads, the substantial difference illustrates the reduced buffer-access activity observed after introducing the composite index.

PostgreSQL estimated 4,051 qualifying rows, while the actual result contained 4,000 records.

The similarity between the estimate and the actual row count suggests that the planner had reasonably accurate cardinality statistics for this workload.

Nevertheless, accurate row estimates alone do not determine the optimal execution strategy; available access paths, heap-access costs and ordering requirements also influence planner decisions.

### 2.7 Execution-Time Comparison

The initial unindexed execution completed in 56.750 ms, while the initial indexed execution completed in 13.027 ms.

The indexed observation represented approximately a 77% reduction in execution time relative to the initial unindexed measurement.

To reduce reliance on a single timing observation, the composite-index query was executed three additional times.

| Trial | Execution time |
|---|---:|
| 1 | 11.962 ms |
| 2 | 12.137 ms |
| 3 | 13.297 ms |
| **Average** | **12.465 ms** |

The three executions produced similar timings under the tested conditions.

The results provide evidence that the composite index improved execution of the selective vulnerability-reporting query.

However, the initial unindexed and indexed measurements were collected at different experimental stages, and execution-time comparisons may be affected by caching and other environmental factors.

**Evidence:** `P2_E18`–`P2_E20` — Repeated composite-index measurements.

### 2.8 Optimisation Significance

The composite B-tree experiment demonstrated that PostgreSQL could use index-assisted filtering to reduce the work required to identify the 4,000 high-priority vulnerabilities.

The Bitmap Index Scan and Bitmap Heap Scan improved access to qualifying records compared with the initial Sequential Scan approach.

However, the separate Sort remained necessary because the selected index did not directly support the query's CVSS-score ordering.

This finding motivated the subsequent investigation of an ordered partial B-tree index designed specifically around the reporting query's filtering predicate and ordering requirements.

The following section evaluates whether that partial index could eliminate the Sort operation and how its access pattern compared with the composite-index strategy.

## 3. Ordered Partial B-tree Index Scan

### 3.1 Index Design and Optimisation Objective

Following the composite B-tree experiment, an ordered partial index was created to support the specific access and ordering requirements of the high-priority vulnerability-reporting query.

The index was named `idx_vuln_benchmark_priority_order` and used two B-tree keys:

- `cvss_score DESC NULLS LAST`
- `vulnerability_id ASC`

Its partial-index predicate restricted entries to vulnerabilities classified as Critical or High whose status was Open or In Progress.

Only 4,000 of the benchmark table's 200,000 records satisfied these conditions, representing 2% of the dataset.

The index occupied 144 kB of storage.

The objective was to determine whether PostgreSQL could retrieve the qualifying vulnerabilities directly in the requested order without an additional Sort operation.

### 3.2 Initial Planner Decision

After the partial index was created, the benchmark query was executed using PostgreSQL's normal planner configuration.

Despite the availability of the new ordered partial index, PostgreSQL continued selecting the original composite severity/status index.

The resulting plan contained:

- A Bitmap Index Scan using `idx_vuln_benchmark_severity_status`.
- A Bitmap Heap Scan retrieving the qualifying records.
- A separate Sort by CVSS score and vulnerability identifier.

The query returned 4,000 matching records and completed in 10.971 ms.

This result demonstrated that PostgreSQL does not necessarily select a newly created index merely because it matches the query's ordering requirements.

The planner considers the estimated total cost of the available execution strategies, including index access, table-page retrieval and sorting.

**Evidence:** `P2_E24` — Partial index creation; `P2_E25` — Natural planner decision after partial-index creation.

### 3.3 Diagnostic Evaluation of Alternative Access Paths

To investigate the available access strategies, transaction-local planner settings were used.

An initial diagnostic experiment temporarily discouraged sequential scans and bitmap scans.

Under these conditions, PostgreSQL selected an ordinary Index Scan using the original composite index rather than the newly created partial index.

The execution plan still contained a Sort operation.

The diagnostic execution completed in 6.806 ms and reported 828 shared-buffer hits.

This demonstrated that changing the available planner choices could alter the scan method without necessarily changing the selected index or eliminating sorting.

A second diagnostic experiment also discouraged explicit sorting.

Under this configuration, PostgreSQL selected:

`Index Scan using idx_vuln_benchmark_priority_order`

The execution plan contained no separate Sort node.

This confirmed that the partial index was a valid access path capable of satisfying the query's ordering requirement.

The diagnostic planner settings were restored using `ROLLBACK` after each experiment.

**Evidence:** `P2_E26` — Ordinary composite Index Scan diagnostic; `P2_E27` — Ordered partial-index plan.

### 3.4 Interpretation of the Ordered Index Scan

The partial index stored matching vulnerabilities according to descending CVSS score and ascending vulnerability identifier.

These index keys matched the ordering expressions in the reporting query.

Consequently, PostgreSQL could traverse the index in the required order and return the qualifying records without performing a separate Sort.

The partial-index execution plan did not contain a Sort node.

This differed from the composite bitmap strategy, which located the qualifying records efficiently but still required a separate sorting operation.

The partial index was also restricted to the specific reporting predicate, reducing its stored entries relative to indexes covering the entire table.

However, the ordinary Index Scan still required access to the underlying table because some selected columns were not stored in the index.

### 3.5 Measured Partial-Index Execution

The initial measured partial-index execution produced the following observations:

| Metric | Recorded value |
|---|---:|
| Selected index | `idx_vuln_benchmark_priority_order` |
| Access method | Index Scan |
| Estimated qualifying rows | 4,051 |
| Actual qualifying rows | 4,000 |
| Separate Sort | No |
| Shared-buffer hits | 4,000 |
| Shared-buffer reads | 17 |
| Total reported shared-buffer accesses | 4,017 |
| Planning time | 0.374 ms |
| Execution time | 7.747 ms |

The plan reported one index search.

The estimated total plan cost was 9,064.89.

The single observed execution time was 7.747 ms, but this alone was insufficient to establish consistent performance.

**Evidence:** `P2_E28` — Measured partial-index execution plan.

### 3.6 Repeated Performance Measurements

To investigate execution-time variation, the same partial-index strategy was measured three additional times under the diagnostic planner configuration.

| Trial | Execution time |
|---|---:|
| 1 | 2.281 ms |
| 2 | 2.219 ms |
| 3 | 1.076 ms |
| **Average** | **1.859 ms** |

Every repeated plan selected the ordered partial index and avoided the separate Sort operation.

Each repeated execution reported 4,017 shared-buffer hits.

The decrease in execution time compared with the initial measurement may have been influenced by cache state, runtime scheduling or other environmental factors.

The results demonstrate consistency in the selected execution strategy but also illustrate the variability of short-duration PostgreSQL benchmarks.

**Evidence:** `P2_E29`–`P2_E31` — Repeated ordered partial-index measurements.

### 3.7 Buffer-Access Trade-off

Although the ordered partial index eliminated the Sort operation, it generated more shared-buffer accesses than the composite bitmap strategy in the recorded plans.

The composite bitmap execution reported 430 shared-buffer accesses, while the ordinary ordered partial-index execution reported 4,017.

An ordinary Index Scan follows index entries to retrieve corresponding table tuples.

Because the requested result included columns unavailable directly from the partial index, PostgreSQL needed to access the underlying table.

The Bitmap Heap Scan, by contrast, could organise retrieval around heap-page locations.

This explains why the ordered partial index could eliminate sorting while still producing substantial buffer-access activity.

The recorded buffer counts represent accesses, not necessarily distinct database pages or physical disk reads.

The experiment therefore demonstrated that eliminating an execution-plan operator does not automatically minimise every component of query-processing work.

### 3.8 Estimated Cost Versus Actual Execution Time

The forced ordered partial-index plan reported an estimated total cost of 9,064.89.

The naturally selected composite bitmap plan had an estimated total cost of 2,962.99.

PostgreSQL's cost model therefore favoured the composite bitmap strategy under the normal planner configuration at that stage.

Nevertheless, the repeated partial-index diagnostic executions produced lower observed execution times than the earlier three-run composite bitmap average of 12.465 ms.

These measurements should not be interpreted as proof that PostgreSQL's planner made an incorrect decision.

The strategies were measured under different planner configurations and experimental conditions. The estimated costs also represent PostgreSQL's internal cost units rather than execution times in milliseconds.

A fully controlled performance comparison would require further repetitions under comparable conditions.

### 3.9 Optimisation Significance

The ordered partial-index experiment demonstrated that a B-tree index designed around both filtering and ordering requirements can eliminate a separate Sort operation for a selective reporting query.

The partial index occupied only 144 kB because it represented the qualifying high-priority subset rather than every record in the benchmark table.

Its repeated diagnostic executions averaged 1.859 ms.

However, the ordinary Index Scan still required considerable underlying table access, reflected in the recorded 4,017 shared-buffer hits per repeated execution.

This limitation motivated a further optimisation: creating a covering partial index with PostgreSQL's `INCLUDE` clause.

The next experiment investigated whether storing the additional selected columns in the index would allow PostgreSQL to use an Index Only Scan and avoid unnecessary heap fetches.

## 4. Covering Partial B-tree Index and Index Only Scan

### 4.1 Index Design and Optimisation Objective

The final SELECT optimisation experiment investigated whether the ordered partial-index strategy could be improved by storing all columns required by the reporting query within the index.

The earlier ordered partial index eliminated the separate Sort operation but still required PostgreSQL to retrieve additional column values from the underlying heap.

To address this limitation, a covering partial B-tree index named `idx_vuln_benchmark_priority_covering` was created.

The index retained the existing ordering keys:

- `cvss_score DESC NULLS LAST`
- `vulnerability_id ASC`

It also used PostgreSQL's `INCLUDE` clause to store the additional result columns:

- `vulnerability_title`
- `severity`
- `vulnerability_status`

The partial-index predicate continued to restrict index entries to Critical or High vulnerabilities with Open or In Progress status.

The objective was to determine whether PostgreSQL could retrieve the complete query result through an Index Only Scan, eliminating unnecessary heap fetches while preserving the required output ordering.

### 4.2 Visibility Statistics and MVCC Considerations

Before creating the covering index, PostgreSQL's table visibility statistics were examined.

The following values were recorded:

| Metric | Recorded value |
|---|---:|
| Estimated table rows | 200,000 |
| Recorded heap pages | 2,492 |
| Recorded all-visible pages | 2,492 |
| Estimated all-visible percentage | 100.00% |

PostgreSQL uses Multi-Version Concurrency Control (MVCC) to determine the visibility of database tuples to concurrent transactions.

An Index Only Scan can avoid fetching heap tuples when the required column values are stored in the index and the relevant heap pages are marked all-visible in PostgreSQL's visibility map.

The recorded visibility statistics indicated favourable conditions for an Index Only Scan.

However, the statistics reflected PostgreSQL's recorded table metadata rather than a live examination of every visibility-map bit.

Consequently, actual heap-fetch activity was verified using `EXPLAIN ANALYZE`.

**Evidence:** `P2_E32` — Benchmark table visibility statistics.

### 4.3 Covering Index Creation

The covering partial index was created within the dedicated `theoscyba_portfolio2_lab` database.

It used B-tree ordering keys and three included columns.

The additional columns were stored as index payload data rather than becoming additional ordering keys.

This distinction allowed the index to preserve the required CVSS-score ordering while providing the values needed by the SELECT query.

The index was created successfully and verified through pgAdmin 4.

Its measured storage size was 336 kB, compared with 144 kB for the original ordered partial index.

Therefore, the covering index required an additional 192 kB of storage.

**Evidence:** `P2_E33` — Covering partial-index creation.

### 4.4 Naturally Selected Execution Plan

Following index creation, the reporting query was evaluated using:

`EXPLAIN (ANALYZE, BUFFERS)`

No temporary planner restrictions were applied.

PostgreSQL naturally selected an Index Only Scan using `idx_vuln_benchmark_priority_covering`.

The recorded measurements were:

| Metric | Recorded value |
|---|---:|
| Access method | Index Only Scan |
| Selected index | `idx_vuln_benchmark_priority_covering` |
| Estimated qualifying rows | 4,051 |
| Actual qualifying rows | 4,000 |
| Estimated total plan cost | 228.79 |
| Index searches | 1 |
| Heap fetches | 0 |
| Shared-buffer hits | 1 |
| Shared-buffer reads | 41 |
| Total reported buffer accesses | 42 |
| Separate Sort | No |
| Planning time | 3.437 ms |
| Initial execution time | 2.443 ms |

The query returned the expected 4,000 qualifying vulnerability records.

The absence of a separate Sort node confirmed that the B-tree ordering keys satisfied the reporting query's required output order.

The Index Only Scan demonstrated that the additional selected columns could be obtained directly from the covering index.

**Evidence:** `P2_E34` — Naturally selected covering Index Only Scan.

### 4.5 Interpretation of Zero Heap Fetches

The execution plan reported:

`Heap Fetches: 0`

This means PostgreSQL did not need to fetch heap tuples to perform visibility checks during the measured Index Only Scan.

The result was consistent with the earlier visibility statistics indicating that the benchmark table's recorded heap pages were all-visible.

In an ordinary Index Scan, PostgreSQL typically accesses the underlying table to retrieve column values that are unavailable from the index.

In the covering-index experiment, the required result columns were available in the index, allowing those heap tuple accesses to be avoided when visibility conditions permitted.

Zero heap fetches does not imply that PostgreSQL performed no memory or storage accesses.

The index itself still had to be traversed, and PostgreSQL continued accessing shared buffers to process the query.

The observation also applies to the measured executions; updates to the underlying table could change visibility-map conditions and require heap fetches in future executions.

### 4.6 Buffer-Access Comparison

The original ordered partial-index execution reported 4,017 shared-buffer accesses.

The initial covering-index execution reported 42 shared-buffer accesses, comprising one shared-buffer hit and 41 shared-buffer reads.

This represented approximately a 99% reduction in reported buffer accesses for those particular execution plans.

The ordinary partial-index strategy needed to retrieve additional selected column values from the heap.

By contrast, the covering index stored all required result columns and supported index-only retrieval.

This substantially reduced the buffer-access work recorded during the initial covering-index experiment.

However, shared-buffer accesses are not necessarily distinct database pages or physical disk reads.

The buffer counts should therefore be interpreted as PostgreSQL's reported execution activity rather than direct measurements of disk I/O.

### 4.7 Repeated Covering-Index Performance Measurements

Three additional executions were performed to evaluate the covering-index strategy.

All three executions naturally selected the covering Index Only Scan.

Each reported zero heap fetches and no separate Sort operation.

| Trial | Execution time | Heap fetches | Shared-buffer hits |
|---|---:|---:|---:|
| 1 | 1.884 ms | 0 | 163 |
| 2 | 1.057 ms | 0 | 42 |
| 3 | 1.521 ms | 0 | 42 |
| **Average** | **1.487 ms** | **0 per trial** | — |

The difference in recorded buffer hits between executions illustrates that buffer activity may vary across repeated queries.

The available plans do not establish the precise cause of the first repeated run's higher buffer-hit count.

The average execution time of 1.487 ms was the lowest observed three-run SELECT average among the indexing strategies investigated.

However, the small sample size and differing conditions between earlier experiments limit the conclusions that can be drawn from direct timing comparisons.

**Evidence:** `P2_E35`–`P2_E37` — Repeated covering-index measurements.

### 4.8 Performance Comparison With the Ordered Partial Index

The ordinary ordered partial-index strategy produced a three-run average execution time of 1.859 ms.

The covering Index Only Scan produced a three-run average of 1.487 ms.

This represented an approximately 20% lower observed average execution time for the covering strategy.

The covering index also reduced the need to access the underlying heap and eliminated the separate Sort operation.

Nevertheless, the two benchmark series were conducted at different stages and under different planner conditions.

The partial-index strategy was evaluated using temporary planner settings, whereas PostgreSQL selected the covering index naturally.

Therefore, the percentage difference is treated as a descriptive result from the experiments rather than a guaranteed performance improvement attributable solely to the covering-index design.

### 4.9 Storage and Maintenance Considerations

The covering partial index occupied 336 kB of storage.

The simpler ordered partial index occupied 144 kB.

The additional included columns increased the covering index's storage requirement by 192 kB.

Although the covering index remained relatively small because it represented only the qualifying high-priority vulnerability subset, its additional payload columns introduced storage and maintenance costs.

Indexes must be maintained when relevant table records are inserted, updated or deleted.

Therefore, a covering index should not be selected solely because it improves one reporting query.

Its overall suitability depends on query frequency, write activity, storage constraints, data visibility and the requirements of other database workloads.

The subsequent INSERT experiments evaluated the combined write-maintenance overhead associated with three secondary reporting indexes.

Those experiments did not isolate the maintenance cost of the covering index individually.

### 4.10 Optimisation Significance

The covering partial-index experiment demonstrated the combined benefits of predicate-specific indexing, ordered B-tree access and included-column storage.

PostgreSQL naturally selected an Index Only Scan for the high-priority vulnerability-reporting query.

The measured execution avoided a separate Sort operation and required zero heap fetches.

The covering-index strategy produced the lowest observed three-run average execution time of the SELECT benchmark experiments.

Its index size of 336 kB represented a relatively small storage requirement for the selective reporting workload.

However, the index also required more storage than the simpler ordered partial index and contributed to the wider trade-off between query retrieval efficiency and secondary-index maintenance.

The results support recommending the covering partial index as the strongest demonstrated candidate for Theoscyba Security Services' specific high-priority vulnerability-reporting query.

This recommendation remains workload-specific and subject to further evaluation under production-like concurrency, update activity and data-distribution conditions.