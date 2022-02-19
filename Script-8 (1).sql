1 +
select city ->> 'ru' as "Города"
from airports_data ad 
group by city having count (airport_code) > 1;

2 +
select distinct f.arrival_airport as "Аэропорт" from (
select ad.aircraft_code, max (ad.range)
from aircrafts_data ad 
group by ad.aircraft_code
order by max (ad.range)
desc limit 1
) mr
join flights f on f.aircraft_code = mr.aircraft_code;

3 +
select flight_id, flight_no 
from flights f
where actual_departure > scheduled_departure 
order by actual_departure - scheduled_departure 
desc limit 10;

4 +
select distinct t.book_ref
from tickets t 
left join boarding_passes bp on t.ticket_no = bp.ticket_no 
where bp.ticket_no is null;

5 +

with c1 as
(select distinct f.flight_id, count(s.seat_no) over (partition by f.aircraft_code, f.flight_id order by f.flight_id) as c1
from seats s 
join flights f on s.aircraft_code = f.aircraft_code 
),
 c2 as 
(select bp.flight_id, count (bp.seat_no) as c2
from boarding_passes bp
group by bp.flight_id 
), c3 as(
select c2.flight_id, (c1.c1 - c2.c2) as c3
from c2
join c1 on c2.flight_id = c1.flight_id
)
select c3.flight_id, c3.c3 "свободные", 
round(c3.c3::numeric / c1.c1::numeric, 3) * 100 as "процент",
f.actual_departure::date,
f.departure_airport,
count (bp.seat_no) over (partition by f.actual_departure::date, f.departure_airport
order by f.actual_departure::date rows between unbounded preceding and current row)
as "накопительный итог"
from c3
join c1 on c3.flight_id = c1.flight_id
join boarding_passes bp on c1.flight_id = bp.flight_id 
join flights f on bp.flight_id = f.flight_id 


6 +

select fa.aircraft_code, round (fa.c1, 4) * 100 as "процент"
from (
select ad.aircraft_code, 
count (f.flight_id)::numeric/(select count(flight_id)::numeric from flights f) as c1
from flights f
right join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
group by ad.aircraft_code 
) fa




7 -

with c1 as (
select tf.flight_id, tf.amount as a1
from ticket_flights tf 
where tf.fare_conditions ilike 'economy'
),
c2 as (
select tf.flight_id, tf.amount as a2
from ticket_flights tf 
where tf.fare_conditions ilike 'business'
), c3 as
(select distinct tf.flight_id 
from ticket_flights tf
join c1 on tf.flight_id = c1.flight_id
join c2 on tf.flight_id = c2.flight_id
where c1.a1 > c2.a2
group by tf.flight_id
)
select ad.city ->> 'ru'
from c3
join flights f on c3.flight_id = f.flight_id
join airports_data ad on f.arrival_airport = ad.airport_code 


8 +

with c1 as(
select f.arrival_airport as faa, ad.city ->> 'ru' as ac, f.flight_id 
from flights f 
join airports_data ad on f.arrival_airport = ad.airport_code 
),
c2 as(
select f.departure_airport as fda, ad.city ->> 'ru' as dc, f.flight_id 
from flights f 
join airports_data ad on f.departure_airport = ad.airport_code 
)
select ad.city ->> 'ru' as "city 1", ad2.city ->> 'ru' as "city 2"
from airports_data ad, airports_data ad2 
where ad.city ->> 'ru' != ad2.city ->> 'ru'
except
select distinct c2.dc, c1.ac
from c1
join c2 on c1.flight_id = c2.flight_id

