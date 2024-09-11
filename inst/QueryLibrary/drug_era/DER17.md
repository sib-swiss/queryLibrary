<!---
Group:drug era
Name:DER17 Counts of drug era records stratified by observation month
Author:Patrick Ryan
CDM Version: 5.3
-->

# DER17: Counts of drug era records stratified by observation month

## Description
This query is used to count the drug era records stratified by observation month. The input to the query is a value (or a comma-separated list of values) of a month. If the input is ommitted, all possible values are summarized.

## Query
```sql
WITH parms as (select cid as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid) 
SELECT date_part('month',er.drug_era_start_date) month_num, COUNT(1)::integer as eras_in_month_count
FROM @cdm.drug_era er
WHERE date_part('month',er.drug_era_start_date)
IN (select cid::integer from parms)
GROUP BY date_part('month',er.drug_era_start_date)
ORDER BY 1;
```

## Input

| Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| list of month numbers | 3, 5 | Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| month_num | Month number (ex. 3 is March) |
| eras_in_month_count | Number of drug era count per month |

## Example output record

|  Field |  Description |
| --- | --- |
| month_num |  3 |
| eras_in_month_count | 19657680 |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
