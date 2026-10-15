# Portfolio 1 — Database Design and Modelling

**Course:** MIT 8103 — Advanced Database Systems  
**Case Study:** Theoscyba Security Services — Cybersecurity Incident and Vulnerability Management System

## Overview

This portfolio documents the design, implementation and verification of a PostgreSQL relational database for a simulated cybersecurity service provider managing multiple client organisations.

The system supports client asset management, incident tracking, vulnerability assessments, remediation activities, analyst assignments and database audit logging.

## Database Technologies

- PostgreSQL 18
- pgAdmin 4
- SQL and PL/pgSQL
- Windows 11

## Database Structure

The implementation contains eight relational tables:

1. `clients`
2. `assets`
3. `analysts`
4. `incidents`
5. `vulnerabilities`
6. `remediation_activities`
7. `audit_logs`
8. `incident_assignments`

The relational schema includes ten foreign-key constraints.

## Advanced Database Features

- Primary and foreign-key constraints
- CHECK and UNIQUE constraints
- PostgreSQL JSONB audit logging
- PL/pgSQL trigger functions
- Partial unique indexing
- Transactional incident-assignment handover
- Historical assignment tracking

## Evidence and Documentation

The portfolio includes SQL implementation scripts, an entity–relationship diagram, database verification results, audit-trigger testing, incident-assignment history and technical documentation.

Detailed supporting files will be organised under the `sql`, `diagrams`, `evidence` and `documentation` directories as they are added.

## Academic Context

This project forms part of the individual practical database portfolio for MIT 8103 Advanced Database Systems. It uses fictional demonstration data and is intended for academic assessment.
