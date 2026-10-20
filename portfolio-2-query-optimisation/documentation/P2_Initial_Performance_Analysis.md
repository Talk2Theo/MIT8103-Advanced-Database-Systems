# Portfolio 2 — Initial Query Performance Analysis

## Query: High-Priority Vulnerability Identification

The query retrieves vulnerabilities with a severity of High or Critical and a status of Open or In Progress, ordering the results by descending CVSS score and ascending vulnerability identifier.

The execution plan was examined using PostgreSQL 18.6 with `EXPLAIN` and `EXPLAIN ANALYZE` against the `theoscyba_rebuild_test` database.

### Observed Results

| Metric | Result |
|---|---|
| Access method | Sequential Scan |
| Estimated matching rows | 1 |
| Actual matching rows | 5 |
| Rows removed by filter | 3 |
| Estimated total cost | 11.67 |
| Sort method | Quicksort |
| Sorting memory | 25 kB |
| Planning time | 1.001 ms |
| Execution time | 0.111 ms |

### Analysis

The PostgreSQL query planner selected a sequential scan of the `vulnerabilities` table followed by an in-memory sorting operation.

The estimated matching-row count was one, while actual execution returned five rows, representing a fivefold underestimation of qualifying records. Three additional records were rejected by the query's filtering conditions.

The sequential scan remains a reasonable access method given the small size of the table, which contains eight vulnerability records. The sort operation used quicksort and approximately 25 kB of memory.

The measured execution time was 0.111 milliseconds, compared with a planning time of 1.001 milliseconds. These measurements describe a single execution and should not be interpreted as stable benchmark averages.

No index changes or query optimisations have yet been applied. Additional performance experiments using repeated measurements and a larger representative fictional dataset will be required to assess whether alternative access strategies improve query performance.