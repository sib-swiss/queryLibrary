<!---
Group:condition occurrence combinations
Name:COC05 Mortality rate after initial diagnosis
Author:Patrick Ryan
CDM Version: 5.3
-->

# COC05: Mortality rate after initial diagnosis

## Description


## Query


```sql
SELECT COUNT(DISTINCT diagnosed.person_id)::integer AS all_occurrences,
	SUM(CASE
			WHEN death.person_id IS NULL
				THEN 0
			ELSE 1
			END)::integer AS death_from_occurrence
FROM 
	(
	SELECT DISTINCT person_id,
		condition_era_start_date
	FROM
		(
		SELECT condition.person_id,
			condition.condition_era_start_date,
			cast(SUM(1) OVER (
				PARTITION BY condition.person_id ORDER BY condition_era_start_date ROWS UNBOUNDED PRECEDING
				) as integer) AS ranking
		FROM @cdm.condition_era condition
		INNER JOIN
			(
			SELECT DISTINCT ca.descendant_concept_id AS concept_id
			FROM @vocab.concept concept1
			INNER JOIN @vocab.concept_relationship rel ON concept1.concept_id = rel.concept_id_1
			INNER JOIN @vocab.concept_ancestor ca ON ancestor_concept_id = concept_id_2
			  WHERE concept1.concept_name = $1::text /*'*/
				AND rel.invalid_reason IS NULL
			) conceptlist ON conceptlist.concept_id = condition_concept_id
		INNER JOIN @cdm.observation_period obs ON obs.person_id = condition.person_id
			AND condition_era_start_date >= observation_period_start_date + 180*interval '1 day'
			AND condition_era_start_date <= observation_period_end_date - 180*interval '1 day'
		) ranked_diagnosis
	WHERE ranking = 1
	) diagnosed
LEFT JOIN @cdm.death /* death within a year */
	ON death.person_id = diagnosed.person_id
	AND death.death_date <= condition_era_start_date + 360*interval '1 day';
```

## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| concept_name | Acute myocardial infarction| Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| all_occurrences |   |
| death_from_occurrence |   |

## Example output record

|  Field |  Description |
| --- | --- |
| all_occurrences |   |
| death_from_occurrence |   |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
