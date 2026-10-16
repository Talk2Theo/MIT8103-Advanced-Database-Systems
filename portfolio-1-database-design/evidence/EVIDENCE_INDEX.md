MIT 8103 – Advanced Database Systems

Portfolio 1: Database Implementation Evidence Index

Case Study: Theoscyba Security Services – Cybersecurity Incident and Vulnerability Management System

Database Management System: PostgreSQL 18
Administration Tool: pgAdmin 4
Operating System: Windows 11
Validation Database: theoscyba_rebuild_test

E01 — Final Entity–Relationship Diagram

File: E01_Final_ERD.png

Demonstrates the relational structure of the Cybersecurity Incident and Vulnerability Management System, including eight interconnected tables, primary keys and foreign-key relationships.

Academic relevance: Relational data modelling, entity relationships and referential integrity.

E02 — Database Schema and Foreign Keys

File: E02_Schema_Foreign_Keys.png

Documents verification of eight database tables and ten foreign-key constraints.

Academic relevance: Database schema implementation and referential integrity.

E03 — Final Database Record Counts

File: E03_Final_Database_Counts.png

Documents the validated dataset: six clients, twelve assets, five analysts, four incidents, eight vulnerabilities, seven remediation activities, one audit record and four assignment-history records.

Academic relevance: Data population, relational consistency and SQL verification.

E04 — Remediation Activity Verification

File: E04_Remediation_Status.png

Demonstrates the seven remediation activities, comprising four Planned, two In Progress and one Completed.

Academic relevance: Data integrity constraints, lifecycle status management and operational workflow modelling.

E05 — PostgreSQL Audit Trigger

File: E05_Audit_Trigger.png

Documents the enabled vulnerability audit trigger and evidence of an automatically generated audit record.

Academic relevance: Database triggers, procedural SQL and automated accountability mechanisms.

E06 — JSONB Audit History

File: E06_JSONB_Audit_History.png

Demonstrates how a controlled update to the FOLM Nigeria Ltd vulnerability description was captured using the old_data and new_data JSONB columns.

Academic relevance: PostgreSQL JSONB data types, change tracking and audit history.

E07 — Incident Assignment Handover

File: E07_Incident_Handover.png

Documents the transfer of the PaySecure suspicious VPN incident from Chineze Okafor to Amina Yusuf, preserving the previous assignment as an ended historical record.

Academic relevance: Transaction atomicity, concurrency control and temporal assignment history.

E08 — Final Assignment Integrity Verification

File: E08_Final_Integrity_Check.png

Documents four assignment-history records, comprising three active assignments and one ended assignment, alongside consistency between current incident ownership and active assignment history.

Academic relevance: Partial unique indexes, data integrity, referential consistency and verification queries.

Evidence Summary

The eight evidence items document the implemented relational database schema, populated operational dataset, database integrity controls, JSONB audit functionality and incident-assignment history.

Together, they support the technical discussion of the database implementation and its verified behaviour.

Note: Screenshots are supporting evidence. The corresponding SQL source files are maintained separately in the project's sql directory.