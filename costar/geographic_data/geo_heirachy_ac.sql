--heirarchy of geographical area
select 
	count(distinct cbsaid) as cbsaid_count
	, count(distinct submarket_name) as submarket_count
	, count(distinct zip) as zip_count
from merged_aws

select 
	cbsaid
	, count(distinct submarket_name) submarket_count
from merged_aws
group by cbsaid
order by submarket_count desc

select distinct zip, submarket_name from merged_aws where cbsaid = '47900'

select * from merged_aws where zip = '17325'

select count(distinct researchmarket_name), count(distinct cbsa_cities) from merged_aws

select * from merged_aws where submarket_name is null

select count(leasedeal_id) from merged_aws 

where submarket_name is not null
and lease_term_inmonths > 0



