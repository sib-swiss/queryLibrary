# query_plan

## Description
This query returns the execution plan of any given query after optionally setting a given parameter to a given value. The variables set.parameter.statement (optionally) and query.sql must be set as options in the R session before execution.

## Query

```sql
explain analyze @~query.sql~@;
	
```
