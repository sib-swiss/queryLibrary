
# get_analyze_info: Table statistics information

## Description
Information about the last analyze of a table and the statistics levels of its columns.
## Query


```sql

select ps.*, pa.attname as colname, pa.attstattarget as statstarget from
pg_stat_all_tables ps 
inner join pg_attribute pa on ps.relname::regclass::oid = pa.attrelid
where ps.relname = $1::text; 

```

## Input

|  Parameter |  Example |  Mandatory | 
| --- | --- | --- | --- |
|  table_name |  measurement |  Yes | 

## Output


## Example output record


## Documentation
