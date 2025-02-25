# visit_occurrence

## Description
This query loads the visit_occurrence table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT vo.*, c.concept_name as visit_name, t.concept_name as visit_type
FROM @cdm.visit_occurrence AS vo
LEFT JOIN @vocab.concept as c ON vo.visit_concept_id  = c.concept_id
LEFT JOIN @vocab.concept as t ON vo.visit_type_concept_id = t.concept_id
	
```
