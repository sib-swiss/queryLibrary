# measurement

## Description
This query loads the measurement table and adds a few useful columns (measurement name and type, measure unit) by joining it to the concept table.

## Query

```sql
SELECT m_name.concept_name as measurement_name, m_typ.concept_name as measurement_type, m_unit.concept_name as unit, m_visit.concept_name as visit, vo.visit_source_value as visit_label, m_value.concept_name as value_as_concept, m.*
FROM @cdm.measurement AS m
LEFT JOIN @vocab.concept as m_name ON m.measurement_concept_id = m_name.concept_id
LEFT JOIN @vocab.concept as m_unit ON m.unit_concept_id = m_unit.concept_id
LEFT JOIN @vocab.concept as m_typ ON m.measurement_type_concept_id = m_typ.concept_id
LEFT JOIN @vocab.concept as m_value ON m.value_as_concept_id = m_value.concept_id
LEFT JOIN @cdm.visit_occurrence as vo ON m.visit_occurrence_id = vo.visit_occurrence_id
LEFT JOIN @vocab.concept as m_visit ON vo.visit_concept_id = m_visit.concept_id 
	
```
