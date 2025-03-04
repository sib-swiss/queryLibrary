# observation

## Description
This query loads the observation table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT o.*, o_name.concept_name as observation_name, o_type.concept_name as observation_type, o_unit.concept_name as unit, vo.visit_source_value as visit_label
FROM @cdm.observation AS o 
LEFT JOIN @cdm.visit_occurrence as vo ON o.visit_occurrence_id = vo.visit_occurrence_id
LEFT JOIN @vocab.concept as o_name ON o.observation_concept_id = o_name.concept_id
LEFT JOIN @vocab.concept as o_type ON o.observation_type_concept_id = o_type.concept_id
LEFT JOIN @vocab.concept as o_unit ON o.unit_concept_id = o_unit.concept_id

	
```
