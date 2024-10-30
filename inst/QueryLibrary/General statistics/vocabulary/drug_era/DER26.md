<!---
Group:drug era
Name:DER26 Counts of genders, stratified by drug
Author:Patrick Ryan
CDM Version: 5.3
-->

# DER26: Counts of genders, stratified by drug

## Description
This query is used to count all genders (gender concept_id), stratified by drug (drug_concept_id). The input to the query is a value (or a comma-separated list of values) of a drug_concept_id. If the input is ommitted, all existing value combinations are summarized.

## Query
```sql
WITH parms as (select cid as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid)
SELECT p.gender_concept_id, count(1)::integer AS stat_value, t.drug_concept_id
FROM @cdm.drug_era t, @cdm.person p
WHERE ((select count(1) from parms) = 0 or t.drug_concept_id IN (select cid::integer from parms))
AND p.person_id = t.person_id
GROUP BY t.drug_concept_id, p.gender_concept_id
ORDER BY t.drug_concept_id, p.gender_concept_id;
```

## Input

| Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| list of drug_concept_id | 1300978, 1304643, 1549080 | Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| gender_concept_id |   |
| stat_valu |   |
| drug_concept_id |   |

## Example output record

|  Field |  Description |
| --- | --- |
| gender_concept_id | 8507 |
| stat_value | 60 |
| drug_concept_id | 1300978 |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
