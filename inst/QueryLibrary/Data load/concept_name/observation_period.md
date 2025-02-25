# observation_period

## Description
This query loads the observation_period table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT o.*, c.concept_name as period_type
FROM @cdm.observation_period AS o
LEFT JOIN @vocab.concept as c ON o.period_type_concept_id  = c.concept_id
	
```
