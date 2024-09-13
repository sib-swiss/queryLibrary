# set_session_param

## Description
Sets a session parameter (ex: set work_mem to '3 GB'). Both parameter.name and parameter.value must be present in the R session as options.
## Query

```sql
set @~parameter.name~@ to @~parameter.value~@
	
```
