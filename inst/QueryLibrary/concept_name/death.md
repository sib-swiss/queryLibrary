# death

## Description
This query loads the death table and adds the main causing condition in clear  by joining it to the concept table.

## Query

```sql
SELECT d.*, c.concept_name as death_cause, t.concept_name as death_type
FROM @cdm.death AS d 
LEFT JOIN @vocab.concept as c ON d.cause_concept_id = c.concept_id
LEFT JOIN @vocab.concept as t  ON d.death_type_concept_id = t.concept_id
	
```
