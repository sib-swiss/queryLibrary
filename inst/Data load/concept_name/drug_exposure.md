# drug_exposure

## Description
This query loads the drug_exposure table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
SELECT d_name.concept_name as drug_name, d_type.concept_name as drug_type, d.*
FROM @cdm.drug_exposure AS d 
LEFT JOIN @vocab.concept as d_name ON d.drug_concept_id = d_name.concept_id
LEFT JOIN @vocab.concept as d_type ON d.drug_type_concept_id = d_type.concept_id

	
```
