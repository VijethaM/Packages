CREATE OR REPLACE FUNCTION countbusinessdays(date, date)
  RETURNS bigint AS
$BODY$
with alldates as (
	SELECT i, $1 + i AS date, extract ('dow'  from $1::date + i) AS dow
	FROM generate_series(0,$2-$1) i
),
businessdays as (
	select dt.date, dow from alldates dt
	left join im_vmc_holiday_list h on dt.date=h.date
	where h.date is null
	and dow between 1 and 5
	order by dt.date
)
select greatest(0,count(*)-1) from businessdays where date between $1 and $2;
$BODY$
  LANGUAGE 'sql' VOLATILE
  COST 100;
ALTER FUNCTION countbusinessdays(date, date) OWNER TO postgres;

-- select * from countbusinessdays('2009-12-24','2009-12-29');
