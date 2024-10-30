<!---
Group:condition occurrence combinations
Name:COC02 Determines length of course of therapy for a condition
Author:Patrick Ryan
CDM Version: 5.3
-->

# COC02: Determines length of course of therapy for a condition

## Description

## Query

```sql
WITH parms as (
select cid::integer as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid)
SELECT ingredient_name,
	ingredient_concept_id,
	count(*)::integer AS num_patients,
	min(length_of_therapy) AS min_length_of_therapy,
	max(length_of_therapy) AS max_length_of_therapy,
	avg(length_of_therapy) AS average_length_of_therapy
FROM (
	SELECT condition.person_id,
		condition.condition_start_date,
		rx.drug_era_start_date,
	  rx.drug_era_end_date - rx.drug_era_start_date, + 1 AS length_of_therapy,
		ingredient_name,
		ingredient_concept_id
	FROM (
		SELECT era.person_id,
			condition_era_start_date AS condition_start_date
		FROM @cdm.condition_era era
		INNER JOIN @cdm.observation_period AS obs ON obs.person_id = era.person_id
			AND condition_era_start_date >= observation_period_start_date + 180*interval '1 day'
				AND condition_era_start_date <= observation_period_end_date - 180*interval '1 day'
		WHERE condition_concept_id IN (select cid from parms) 
		) condition
	INNER JOIN @cdm.drug_era rx ON rx.person_id = condition.person_id
		AND rx.drug_era_start_date >= condition_start_date
			AND rx.drug_era_start_date <= condition_start_date + 30*interval '1 day'
	INNER JOIN (
		SELECT DISTINCT ingredient.concept_id AS ingredient_concept_id,
			ingredient.concept_name AS ingredient_name
		FROM @vocab.concept_ancestor ancestor
		INNER JOIN @vocab.concept indication ON ancestor.ancestor_concept_id = indication.concept_id
		INNER JOIN @vocab.concept ingredient ON ingredient.concept_id = ancestor.descendant_concept_id
			AND indication.vocabulary_id = 'Indication'
			AND ingredient.concept_class_id = 'Ingredient'
			AND indication.invalid_reason IS NULL 
					) ingredients ON ingredient_concept_id = drug_concept_id
	) treatment
GROUP BY ingredient_name,
	ingredient_concept_id
ORDER BY num_patients DESC;
```

## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
|list of  condition_concept_id | 4186108, 4187773, 4188208 | Yes |  |

## Output

|  Field |  Description |
| --- | --- |
| ingredient_name |   |
| ingredient_concept_id |   |
| count |   |
| min_length_of_therapy |   |
| max_length_of_therapy |   |
| average_length_of_therapy |   |

## Example output record

|  Field |  Description |
| --- | --- |
| ingredient_name |   |
| ingredient_concept_id |   |
| count |   |
| min_length_of_therapy |   |
| max_length_of_therapy |   |
| average_length_of_therapy |   |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
