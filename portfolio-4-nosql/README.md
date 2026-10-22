
# Portfolio 4 — NoSQL and Advanced Data Models

**Case Study:** Theoscyba Security Services

## Objectives

Explore a suitable NoSQL data model for
cybersecurity events, alerts or audit records.

Compare the proposed NoSQL approach with
the existing PostgreSQL relational design.

## Expected Evidence

NoSQL schema or document model, implementation
examples and technical justification.

**Status:** Planned


## 5. Repository Structure and Implementation Files

This portfolio is organised into three directories:
`documentation`, `nosql`, and `evidence`.

### 5.1 Documentation

The `documentation/` directory contains this README,
which describes the case study, NoSQL model,
implementation methodology, experimental results,
technical observations, individual reflection,
and AI-use declaration.

### 5.2 NoSQL Implementation

The `nosql/` directory contains the dataset and
technical query examples used during the experiments.

**01_incidents_seed.json**

Contains six fictional cybersecurity incident documents
covering VPN threats, malware detection, phishing,
brute-force login attempts, vulnerabilities, and
suspicious network activity.

The documents demonstrate:
- Flexible document structures
- Nested objects
- Arrays of security indicators
- Incident-specific attributes
- Analyst assignments and remediation actions

[View Incident Dataset](../nosql/01_incidents_seed.json)

**02_query_and_update_examples.md**

Documents the MongoDB Atlas Data Explorer operations:

1. Retrieve incidents with High or Critical severity.
2. Retrieve an incident using its incident_id.
3. Update incident 102 from Open to Investigating.
4. Verify the updated incident.

[View Query and Update Examples](../nosql/02_query_and_update_examples.md)

### 5.3 Screenshot Evidence

The `evidence/` directory contains three screenshots
supporting the practical implementation.

**P4_E01 — Inserted Incident Documents**

Demonstrates successful insertion of six fictional
security incident documents into the MongoDB collection.

[View E01](../evidence/P4_E01_Inserted_Incident_Documents.png)

**P4_E02 — High-Priority Incident Query**

Demonstrates MongoDB filtering using the $in operator
to retrieve four High or Critical severity incidents.

[View E02](../evidence/P4_E02_High_Priority_Incident_Query.png)

**P4_E03 — Incident Status Update**

Demonstrates successful modification and verification
of incident 102, whose status changed from Open to
Investigating.

[View E03](../evidence/P4_E03_Incident_Status_Update.png)

### 5.4 Reproducibility Notes

The dataset was inserted using MongoDB Atlas Data Explorer.

The JSON dataset contains the original incident values.
The status update to incident 102 was performed afterward
through the document editor.

To reproduce the experiments in a new collection:

1. Insert the six documents from the JSON dataset.
2. Execute the query filters provided in the examples.
3. Update incident 102 to Investigating.
4. Retrieve the updated document to confirm the change.

Do not insert the seed dataset again into the same
collection without first checking for existing records,
because duplicate incident IDs could otherwise be created.
