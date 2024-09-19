# person

## Description
This query loads the person table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT p.*, p_gender.concept_name as gender,  p_race.concept_name as race, p_ethnic.concept_name as ethnicity 
FROM @cdm.person AS p 
LEFT JOIN @vocab.concept as p_gender ON p.gender_concept_id = p_gender.concept_id
LEFT JOIN @vocab.concept as p_race ON p.race_concept_id = p_race.concept_id
LEFT JOIN @vocab.concept as p_ethnic ON p.ethnicity_concept_id = p_ethnic.concept_id
	
```
