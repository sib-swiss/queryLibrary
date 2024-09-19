# procedure_occurrence

## Description
This query loads the "procedure_occurrence" table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT p.*, p_name.concept_name as procedure_name, p_type.concept_name as procedure_type
FROM @cdm.procedure_occurrence AS p 
LEFT JOIN @vocab.concept as p_name ON p.procedure_concept_id = p_name.concept_id
LEFT JOIN @vocab.concept as p_type ON p.procedure_type_concept_id = p_type.concept_id

	
```
