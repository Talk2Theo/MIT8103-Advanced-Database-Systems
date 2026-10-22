# MIT 8103 — Portfolio 5: Distributed and Cloud Database Exercise

## 1. Case Study and Environment

**Organisation:** Theoscyba Security Services  
**System:** Cybersecurity Incident and Vulnerability Management System  
**Database platform:** MongoDB Atlas  
**Cluster:** Theoscyba-P4  
**MongoDB version:** 8.0.34  
**Cloud provider:** Amazon Web Services (AWS)  
**Region:** Paris (`eu-west-3`)  
**Cluster tier:** Free  
**Portfolio 5 database:** `theoscyba_cloud_db`  
**Collection:** `security_events`

This exercise examines cloud database deployment, replication architecture, availability and consistency using MongoDB Atlas.

The implementation maintains continuity with the Theoscyba cybersecurity case study used throughout MIT 8103.

A separate logical database was created within the existing Atlas cluster to ensure that Portfolio 4's incident documents remained unchanged.

## 2. Cloud Deployment Architecture

MongoDB Atlas was deployed on AWS in the Paris region.

The Atlas cluster overview displayed three database members:

| Node role | Number |
|---|---:|
| Primary | 1 |
| Secondary | 2 |
| Total | 3 |

This configuration demonstrates a three-member MongoDB replica-set architecture.

The primary member receives database writes, while secondary members replicate changes from the primary.

The screenshot establishes the displayed node roles and deployment region. It does not independently demonstrate a failover, cross-region replication or the timing of replication between members.

## 3. Practical Implementation

### Experiment 1 — Cloud Database Creation and Data Insertion

A separate MongoDB database named `theoscyba_cloud_db` was created using Atlas Data Explorer.

Within this database, a `security_events` collection was created.

Five fictional cybersecurity event documents were inserted, representing:

1. Suspicious cloud login.
2. Cloud storage access alert.
3. Malware detection.
4. Unusual API requests.
5. Firewall policy alert.

Each document includes an event identifier, event type, severity, status, client and nested cloud-environment details.

**Result:** All five documents were successfully stored and displayed in MongoDB Atlas.

### Experiment 2 — Cloud Database Query

The following filter was executed in MongoDB Atlas Data Explorer:

`{"severity": "Critical"}`

**Result:** Two matching documents were returned:

| Event ID | Event type | Severity |
|---|---|---|
| CLOUD-001 | Suspicious Cloud Login | Critical |
| CLOUD-003 | Malware Detection | Critical |

This confirmed successful retrieval of data stored in the cloud-hosted database.

The experiment demonstrates cloud-hosted database operations, but does not directly measure replication delay, consistency guarantees or failover performance.

## 4. Distributed Database Concepts

### 4.1 Replication

MongoDB replica sets maintain copies of data across multiple database members.

The primary records write operations, and secondary members replicate these operations through the MongoDB operation log (oplog).

The three members visible in the Atlas cluster provide architectural evidence of replication support.

### 4.2 Availability and Fault Tolerance

Replica sets are designed to support redundancy and primary elections.

If a primary becomes unavailable, eligible secondary members may participate in an election to select a new primary.

However, primary-failover testing was not performed during this exercise.

The observed deployment uses a single AWS region. Multi-region disaster recovery was not implemented or tested.

### 4.3 Consistency

MongoDB provides read concern and write concern options for controlling read consistency and write acknowledgement.

For example:

- `w: 1` acknowledges a write after the primary accepts it.
- `w: "majority"` requires majority acknowledgement.
- `readConcern: "majority"` supports reading majority-committed data.

These options affect the trade-off between consistency guarantees, durability and operation latency.

The practical exercise verified successful insertion and retrieval through Atlas Data Explorer. It did not explicitly configure or measure read concern, write concern or secondary replication lag.

### 4.4 Sharding

Sharding distributes data across multiple shards to support horizontal scaling.

The Atlas Free tier used in this exercise does not support deployment as a sharded cluster.

Therefore, sharding is discussed as a distributed database concept rather than presented as a completed implementation.

## 5. Implementation Files and Evidence

The portfolio contains three directories: `documentation`, `cloud` and `evidence`.

**Implementation dataset**

[01_cloud_security_events.json](../cloud/01_cloud_security_events.json)

Contains the five fictional cloud security events inserted into the `security_events` collection.

**Screenshot evidence**

- [P5_E01 — Atlas Cloud Deployment](../evidence/P5_E01_Atlas_Cloud_Deployment.png): Shows AWS Paris, Free tier and the primary/secondary member roles.
- [P5_E02 — Cloud Database Insertion](../evidence/P5_E02_Cloud_Database_Insertion.png): Shows the five security event documents.
- [P5_E03 — Cloud Database Query](../evidence/P5_E03_Cloud_Database_Query.png): Shows the two Critical-severity events returned by the query.

**Reproducibility:** The five JSON documents can be inserted into a new MongoDB collection through Atlas Data Explorer. The Critical-severity filter can then be executed to reproduce the two-document result. Existing collections should be checked before reimporting the dataset to avoid duplicates.

## 6. Limitations and Technical Reflection

This exercise demonstrated how cybersecurity security-event data can be stored and retrieved through a managed cloud database.

The Atlas cluster overview also provided a practical example of a three-member replica-set architecture.

A key learning outcome was the distinction between observing distributed infrastructure and testing its failure behaviour. Although the cluster contains a primary and two secondary members, the exercise did not simulate an outage or verify recovery time.

The Free-tier deployment was sufficient for demonstrating cloud hosting and replica-set architecture, but it did not permit controlled failover or sharding experiments.

For a production cybersecurity incident-management service, additional considerations would include backup and recovery procedures, monitoring, access controls, regional resilience, documented recovery objectives and the appropriate consistency requirements for incident updates.

## 7. AI Use Declaration

I used OpenAI ChatGPT to assist with the experiment workflow, fictional JSON dataset, explanation of distributed database concepts and preparation of portfolio documentation.

The MongoDB Atlas operations were performed by me. The deployed cluster configuration, inserted documents and query results were inspected, verified and captured as supporting evidence.

I am responsible for reviewing the technical interpretations and understanding the final work.

## 8. References

1. MongoDB. *Atlas Free Cluster Limits.* https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/
2. MongoDB. *Replication.* https://www.mongodb.com/docs/manual/replication/
3. MongoDB. *Read Concern.* https://www.mongodb.com/docs/manual/reference/read-concern/
4. MongoDB. *Write Concern.* https://www.mongodb.com/docs/manual/reference/write-concern/

## 9. Conclusion

Portfolio 5 demonstrated cloud-hosted document storage and retrieval using MongoDB Atlas on AWS, together with a verified three-member replica-set deployment.

The exercise established practical evidence of cloud database operations and provided a technically grounded discussion of replication, availability, consistency and sharding limitations within the Theoscyba Security Services case study.