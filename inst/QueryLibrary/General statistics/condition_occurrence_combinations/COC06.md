<!---
Group:condition occurrence combinations
Name:COC06 Time until death after initial diagnosis
Author:Patrick Ryan
CDM Version: 5.3
-->

# COC06: Time until death after initial diagnosis

## Description


## Query


```sql
SELECT COUNT(DISTINCT diagnosed.person_id)::integer AS all_deaths,
	ROUND(min(death.death_date - diagnosed.condition_era_start_date) / 365, 1)::numeric AS min_years,
	ROUND(max(death.death_date - diagnosed.condition_era_start_date) / 365, 1)::numeric AS max_years,
	ROUND(avg(death.death_date - diagnosed.condition_era_start_date) / 365, 1)::numeric AS avg_years
FROM 
	(
	SELECT DISTINCT person_id,
		condition_era_start_date
	FROM /* diagnosis of Acute Myocardial Infarction, ranked by date, 6 month clean*/
		(
		SELECT condition.person_id,
			condition.condition_era_start_date,
			rank() OVER (PARTITION BY condition.person_id ORDER BY condition_era_start_date) AS ranking
		FROM @cdm.condition_era condition
		INNER JOIN 
			(
			SELECT DISTINCT ca.descendant_concept_id AS concept_id
			FROM @vocab.concept concept1
			INNER JOIN @vocab.concept_relationship rel ON concept1.concept_id = rel.concept_id_1
			INNER JOIN @vocab.concept_ancestor ca ON ancestor_concept_id = concept_id_2
			WHERE concept1.concept_name = $1
				AND rel.invalid_reason IS NULL
			) conceptlist ON conceptlist.concept_id = condition_concept_id
		INNER JOIN @cdm.observation_period obs ON obs.person_id = condition.person_id
			AND condition.condition_era_start_date >=  obs.observation_period_start_date + 180*interval '1 day'
		) diagnosis_ranked
	WHERE ranking = 1
	) diagnosed
INNER JOIN @cdm.death ON death.person_id = diagnosed.person_id;
```
## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| concept_name | Acute myocardial infarction| Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| all_deaths |   |
| min_years |   |
| max_years |   |
| avg_years |   |

## Example output record

|  Field |  Description |
| --- | --- |
| all_deaths |   |
| min_years |   |
| max_years |   |
| avg_years |   |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
