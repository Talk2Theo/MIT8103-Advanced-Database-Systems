
# MIT 8103 — Portfolio 4
## MongoDB Query and Update Examples

**Organisation:** Theoscyba Security Services  
**Database:** theoscyba_nosql_db  
**Collection:** incidents  
**Platform:** MongoDB Atlas Data Explorer

## 1. Filter High-Priority Security Incidents

### MongoDB Filter

```json
{
  "severity": {
    "$in": ["High", "Critical"]
  }
}
```

### Execution

1. Open the `incidents` collection.
2. Navigate to the Documents tab.
3. Paste the JSON expression into the Filter field.
4. Click Find.

### Result

Four matching documents were returned:

| Incident ID | Severity |
|-------------|----------|
| 101 | High |
| 102 | Critical |
| 104 | High |
| 105 | Critical |

The `$in` operator retrieves documents whose
severity matches either High or Critical.

**Evidence:** P4_E02_High_Priority_Incident_Query.png

## 2. Filter a Specific Security Incident

### MongoDB Filter

```json
{
  "incident_id": 102
}
```

### Execution

1. Replace the previous Filter expression.
2. Enter the incident ID filter.
3. Click Find.

### Result

One document was returned.

Incident ID: 102  
Title: Malware Detected on Endpoint  
Severity: Critical  
Original Status: Open  
Assigned Analyst: Amina

This query demonstrates document retrieval using
an incident identifier.

## 3. Update an Incident Document

### Update Procedure

The existing incident was updated using the
MongoDB Atlas Data Explorer interface.

1. Retrieve incident 102 using the filter above.
2. Open the document editor.
3. Locate the `status` field.
4. Change its value from "Open" to "Investigating".
5. Click Update to save the document.
6. Run the incident ID filter again to verify.

### Verification Filter

```json
{
  "incident_id": 102,
  "status": "Investigating"
}
```

### Result

The updated document was successfully retrieved.

Incident ID: 102  
Previous Status: Open  
Updated Status: Investigating  

The operation demonstrated modification of an
existing document and verification of the saved
value.

**Evidence:** P4_E03_Incident_Status_Update.png

## 4. Technical Observations

- MongoDB supports filtering documents by specific
  field values.
- The `$in` operator supports matching multiple
  severity categories in a single query.
- Individual incident documents can be retrieved
  using the incident_id field.
- Existing document fields can be updated without
  recreating the entire collection.
- MongoDB supports nested objects, arrays and
  varying document structures across incidents.

## 5. Conclusion

The experiments demonstrated practical NoSQL
document retrieval, conditional filtering and
document updating using MongoDB Atlas.

These operations support Theoscyba Security
Services in managing cybersecurity incidents
with flexible document structures.
