<!---
Group:drug era
Name:DER08 Counts of drug records
Author:Patrick Ryan
CDM Version: 5.3
-->

# DER08: Counts of drug records

## Description
This query is used to count the drug concepts across all drug era records. The input to the query is a value (or a comma-separated list of values) of a drug_concept_id. If the input is omitted, all possible values are summarized. values are summarized.

## Query
```sql
WITH parms as (select cid as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid)
SELECT count(1) AS total_count FROM @cdm.drug_era r WHERE r.drug_concept_id in (select cid::integer from parms);
```

## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| list of drug_concept_id | 1304643, 1549080 | Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| Total_count |  Total count of the drug concepts for all drug era records |

## Example output record

|  Field |  Value |
| --- | --- |
| Total_count |  9984588 |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
