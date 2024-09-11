# condition_occurrence

## Description
This query loads the condition_occurrence table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT co.*, c.concept_name as condition_name
FROM @cdm.condition_occurrence AS co
LEFT JOIN @vocab.concept as c ON co.condition_concept_id  = c.concept_id
	
```
