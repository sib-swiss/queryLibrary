<!---
Group:drug era
Name:DER20 Counts of drugs, stratified by drug type and drug exposure count
Author:Patrick Ryan
CDM Version: 5.3
-->

# DER20: Counts of drugs, stratified by drug type and drug exposure count

## Description
This query is used to count drugs (drug_concept_id) across all drug exposure records stratified by drug exposure type (drug_type_concept_id, in CDM V2 drug_exposure_type) and drug exposure count (drug_exposure_count) for each era. The input to the query is a value (or a comma-separated list of values) of a drug_concept_id. If the input is omitted, all existing value combinations are summarized.

## Query
```sql
WITH parms as (select cid as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid),
drugs AS (
         SELECT drug_concept_id
         FROM   @cdm.drug_era
         WHERE ((select count(1) from parms) = 0 or drug_concept_id IN (select cid::integer from parms))
     ),
     tt AS (
         SELECT t.drug_concept_id
         ,      stat.stat_value
         ,      (SELECT COUNT(e.drug_concept_id)::integer FROM @cdm.drug_era e WHERE e.drug_concept_id = t.drug_concept_id) AS population_size
         ,      ROW_NUMBER() OVER (PARTITION BY t.drug_concept_id ORDER BY t.drug_concept_id, stat.stat_value) order_nr
         FROM @cdm.drug_era t
         ,    @cdm.person p
         LEFT OUTER JOIN (
             SELECT p1.person_id
             ,      date_part('year',(min(t1.drug_era_start_date) OVER(PARTITION BY t1.person_id, t1.drug_concept_id))) - p1.year_of_birth AS stat_value
             FROM @cdm.person p1
             ,    @cdm.drug_era t1
             WHERE t1.person_id = p1.person_id
             AND   t1.drug_concept_id IN (SELECT * FROM drugs)
         ) stat
         ON   p.person_id = stat.person_id
         WHERE t.person_id = p.person_id
         AND   t.drug_concept_id IN (SELECT * FROM drugs)
         GROUP BY t.drug_concept_id
         ,        t.person_id
         ,        t.drug_era_start_date
         ,        p.year_of_birth
         ,        stat.stat_value
     )
SELECT DISTINCT tt.drug_concept_id
,      cast(MIN(tt.stat_value) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS min_value
,      cast(MAX(tt.stat_value) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS max_value
,      cast(AVG(tt.stat_value) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS avg_value
,      round(cast(STDDEV(tt.stat_value) OVER ( PARTITION BY tt.drug_concept_id) as numeric),0) AS STDEV_value
,      cast(MIN(CASE WHEN tt.order_nr < .25 * tt.population_size THEN 9999 ELSE tt.stat_value END) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS percentile_25
,      cast(MIN(CASE WHEN tt.order_nr < .50 * tt.population_size THEN 9999 ELSE tt.stat_value END) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS median_value
,      cast(MIN(CASE WHEN tt.order_nr < .75 * tt.population_size THEN 9999 ELSE tt.stat_value END) OVER ( PARTITION BY tt.drug_concept_id) as numeric) AS percentile_75
FROM tt
GROUP BY tt.drug_concept_id
,        tt.order_nr
,        tt.population_size
,        tt.stat_value
ORDER BY tt.drug_concept_id;
```

## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| drug_concept_id |  1300978, 1304643, 1549080 | No |   |

## Output

|  Field |  Description |
| --- | --- |
| drug_concept_id |  A foreign key that refers to a standard concept identifier in the vocabulary for the drug concept. |
| min_value |   |
| max_value |   |
| avg_value |   |
| stddev_value |   |
| percentile_25 |   |
| median_value |   |
| percentile_75 |   |

## Example output record

|  Field |  Description |
| --- | --- |
| drug_concept_id |  1300978 |
| min_value | 0 |
| max_value | 89 |
| avg_value | 65 |
| stddev_value | 14 |
| percentile_25 | 59 |
| median_value | 70 |
| percentile_75 | 80 |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
