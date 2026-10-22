# MIT 8103 — Portfolio 4: NoSQL and Advanced Data Models

## 1. Case Study and Technology

**Organisation:** Theoscyba Security Services  
**System:** Cybersecurity Incident and Vulnerability Management System  
**NoSQL Platform:** MongoDB Atlas  
**Cluster:** Theoscyba-P4  
**Database:** `theoscyba_nosql_db`  
**Collection:** `incidents`

This portfolio demonstrates document-oriented NoSQL database modelling and basic data operations using MongoDB Atlas.

The implementation uses six fictional cybersecurity incident documents representing VPN-related threats, malware detections, phishing attempts, brute-force attacks, vulnerabilities and suspicious network traffic.

## 2. NoSQL Data Model

A document-oriented model was selected because cybersecurity incidents can contain different attributes depending on their type.

Each incident includes core information such as incident ID, title, severity, status and assigned analyst.

Additional information is represented through nested objects and arrays, including:

- `asset` — affected systems and environments.
- `indicators` — security indicators and detection findings.
- `remediation_actions` — investigative and remediation tasks.
- `email_details` — information specific to phishing investigations.
- `vulnerability_details` — vulnerability severity and patch availability.
- `network_details` — relevant network connection information.

Unlike a fixed relational table structure, MongoDB allows incident documents to have different fields while remaining within the same collection.

## 3. Practical Implementation and Results

### Experiment 1 — Document Insertion

Six fictional incident documents were inserted into the MongoDB `incidents` collection through Atlas Data Explorer.

**Result:** All six documents were successfully stored and displayed, including their nested objects and arrays.

### Experiment 2 — Filtering High-Priority Incidents

The following MongoDB filter was executed:

```json
{
  "severity": {
    "$in": ["High", "Critical"]
  }
}
```

**Result:** Four incident documents were returned, with incident IDs 101, 102, 104 and 105.

This demonstrated retrieval of documents using a field-based filter and the `$in` query operator.

### Experiment 3 — Document Update

Incident 102, representing malware detected on an endpoint, was located using:

```json
{"incident_id": 102}
```

Its `status` field was updated through Atlas Data Explorer from `Open` to `Investigating`.

**Result:** The updated document was retrieved and verified successfully.

The original seed dataset retains the initial `Open` status. The update was performed afterward as a separate experiment.

## 4. Suitability of MongoDB

MongoDB is suitable for storing variable cybersecurity incident details because it supports flexible document structures, nested objects and arrays.

These capabilities allow related investigative information to be grouped within individual incident documents and simplify the representation of incident-specific attributes.

However, the document model also introduces considerations around data duplication, validation and consistency. PostgreSQL remains appropriate for the highly structured relational and transactional operations demonstrated in earlier portfolios.

MongoDB is therefore considered a complementary option for flexible incident and security-event records, rather than a replacement for every relational component of the system.

## 5. Implementation Files and Evidence

**NoSQL files**

- `01_incidents_seed.json` — Six fictional incident documents.
- `02_query_and_update_examples.md` — Query filters and document-update procedure.

**Screenshot evidence**

- `P4_E01_Inserted_Incident_Documents.png` — Inserted MongoDB documents.
- `P4_E02_High_Priority_Incident_Query.png` — High/Critical severity filtering.
- `P4_E03_Incident_Status_Update.png` — Verified incident status update.

## 6. Technical Reflection

This exercise demonstrated how a document-oriented database can represent different types of cybersecurity incidents without requiring every record to share an identical structure.

The most useful feature was the ability to store nested investigative details within a single incident document. The filtering experiment demonstrated how MongoDB retrieves incident records based on security priority, while the update experiment demonstrated how analysts can modify incident information.

The exercise also highlighted the importance of selecting database technologies according to application requirements rather than treating relational and NoSQL databases as universally interchangeable.

## 7. AI Use Declaration

I used OpenAI ChatGPT to assist me with the NoSQL implementation workflow, example JSON documents, query explanations and technical documentation.

I performed the MongoDB operations in Atlas Data Explorer, and checked the results checked against expected outcomes. I captured screenshots as supporting evidence.

## 8. Conclusion

The Portfolio 4 implementation demonstrated document-oriented NoSQL modelling, JSON document insertion, filtering and updating within a fictional cybersecurity incident-management system. The results illustrate the suitability and limitations of MongoDB for flexible security incident records.