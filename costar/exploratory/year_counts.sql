--Descriptive stats on a number of key inputs to the DCF model

select t1.year_fromdate, count(t1.year_fromdate) as year_count from 

		(select
		Year(convert(date, fromdate)) as year_fromdate
		from merged_lease 
		where fromdate is not null) as t1 

group by t1.year_fromdate
order by year_fromdate

select * from merged_lease
where (cbsa_cities like '%pitts%' or cbsa_cities like '%new york%')
order by cbsa_cities

