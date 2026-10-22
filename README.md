# MIT 8103 — Advanced Database Systems

**Programme:** Master of Science in Information Technology (Cybersecurity Specialisation)  
**Course:** MIT 8103 — Advanced Database Systems  
**Institution:** Miva Open University  
**Academic Session:** 2026/2027  
**Project:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System

## Project Overview

This repository contains the practical coursework and supporting technical documentation developed for MIT 8103 Advanced Database Systems.

The central case study is a simulated cybersecurity incident and vulnerability management system designed for **Theoscyba Security Services**, a security service provider responsible for managing information assets, security incidents, vulnerabilities, remediation activities and analyst assignments across multiple client organisations.

The project provides a consistent cybersecurity-focused case study through which relational database design, query optimisation, transaction processing, NoSQL concepts and distributed database technologies can be investigated.

## Portfolio Overview

| Portfolio | Topic | Status |
|---|---|---|
| [Portfolio 1](portfolio-1-database-design/) | Database Design and Modelling | Completed and documented |
| [Portfolio 2](portfolio-2-query-optimisation/) | Query Processing and Optimisation | Completed and documented |
| [Portfolio 3](portfolio-3-transactions-concurrency/) | Transactions and Concurrency | Completed and documented |
| [Portfolio 4](portfolio-4-nosql/) | NoSQL and Advanced Data Models | Completed and documented |
| [Portfolio 5](portfolio-5-distributed-cloud/) | Distributed and Cloud Databases | Completed and documented |

All five practical portfolio activities have been successfully implemented, tested, documented and verified. Each portfolio contains the relevant technical documentation, implementation files and supporting evidence. The repository demonstrates practical applications of relational database design, query optimisation, transaction management, NoSQL modelling and cloud database concepts using the Theoscyba Security Services cybersecurity case study.

## Portfolio 1 — Relational Database Design and Implementation

Portfolio 1 implements a PostgreSQL relational database for managing cybersecurity operations across multiple clients.

### Technologies

- PostgreSQL 18
- pgAdmin 4
- SQL and PL/pgSQL
- JSONB data type
- Windows 11

### Database Structure

The implemented database contains eight relational tables:

1. `clients`
2. `assets`
3. `analysts`
4. `incidents`
5. `vulnerabilities`
6. `remediation_activities`
7. `audit_logs`
8. `incident_assignments`

The schema includes ten foreign-key relationships and database constraints supporting data integrity.

### Key Technical Features

- Relational modelling and entity relationships
- Primary keys, foreign keys, CHECK and UNIQUE constraints
- Asset, incident and vulnerability management
- Remediation activity tracking
- PostgreSQL JSONB change snapshots
- PL/pgSQL trigger-based auditing of vulnerability updates
- Partial unique indexing for active incident assignments
- Historical analyst-assignment tracking
- Controlled incident handover and integrity verification

### Portfolio 1 Files and Evidence

| Resource | Location |
|---|---|
| SQL implementation scripts | [SQL Directory](portfolio-1-database-design/sql/) |
| Final ER diagram | [View ERD](portfolio-1-database-design/diagrams/Theoscyba_Final_ERD.png) |
| Editable pgAdmin ERD | [Download ERD Project](portfolio-1-database-design/diagrams/Theoscyba_Final_ERD.pgerd) |
| Database verification screenshots | [Evidence Directory](portfolio-1-database-design/evidence/) |
| Evidence descriptions | [Evidence Index](portfolio-1-database-design/evidence/EVIDENCE_INDEX.md) |
| Technical report | [Documentation Directory](portfolio-1-database-design/documentation/) |
| Database rebuild instructions | [README_REBUILD.md](portfolio-1-database-design/documentation/README_REBUILD.md) |

### Implementation and Verification

The Portfolio 1 SQL directory contains 26 scripts covering schema creation, sample data, integrity constraints, audit functions, controlled testing and database verification.

The documented normal execution sequence comprises 24 scripts. Two additional scripts intentionally test constraint violations and are excluded from the normal rebuild sequence.

The implementation was verified using a separate PostgreSQL test database named `theoscyba_rebuild_test`, preserving the original project database.

Verification activities included checking relational structure, foreign keys, record counts, remediation activity states, JSONB audit snapshots, analyst handover history and active-assignment integrity.

The [database rebuild guide](portfolio-1-database-design/documentation/README_REBUILD.md) describes the execution sequence, prerequisites and special handling of test scripts.

**Important:** Some demonstration scripts intentionally modify test data or produce expected constraint errors. Review the rebuild guide before executing them. The provided scripts must not be run against production databases or databases containing real client information.

## Normalisation and Database Integrity

The Portfolio 1 technical report discusses First, Second and Third Normal Forms under the intended business dependencies, the separation of related business entities and the use of integrity constraints.

The audit design intentionally preserves historical JSONB snapshots to support change tracking. This historical storage approach is distinguished from conventional relational normalisation.

## Repository Organisation

```text
MIT8103-Advanced-Database-Systems/
├── README.md
├── portfolio-1-database-design/
│   ├── README.md
│   ├── sql/
│   ├── diagrams/
│   ├── evidence/
│   └── documentation/
├── portfolio-2-query-optimisation/
├── portfolio-3-transactions-concurrency/
├── portfolio-4-nosql/
└── portfolio-5-distributed-cloud/
```

## Academic Integrity and Responsible Tool Use

This repository documents individual academic work and practical database experimentation.

AI assistance was used to support technical explanation, SQL learning, troubleshooting, documentation drafting and review. The implemented SQL scripts and database behaviour were checked through practical execution and verification.

A more detailed reflection and AI-use declaration are included in the Portfolio 1 technical report.

## Data Confidentiality

All organisational scenarios, analysts, security incidents and demonstration records are fictional and are intended for educational use.

The repository is maintained privately for academic assessment. It does not intentionally contain production credentials, real customer records or confidential operational security information.

## Future Work

Subsequent portfolios will extend the database project through query optimisation, transaction and concurrency experiments, NoSQL modelling and distributed or cloud database concepts.

Results, supporting scripts, technical explanations and verification evidence will be committed progressively as each activity is completed.
