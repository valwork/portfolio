1 
-- В каких городах больше одного аэропорта?

select city ->> 'ru' as "Города"
from airports_data ad 
group by city having count (airport_code) > 1;

2 
-- В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
select distinct f.arrival_airport as "Аэропорт" from (
select ad.aircraft_code, max (ad.range)
from aircrafts_data ad 
group by ad.aircraft_code
order by max (ad.range)
desc limit 1
) mr
join flights f on f.aircraft_code = mr.aircraft_code;

3 
-- 10 рейсов с максимальной разницей между планируемым и фактическим временем перелета.
select flight_id, flight_no 
from flights_v fv 
where actual_duration > scheduled_duration 
order by actual_duration - scheduled_duration 
desc limit 10;

4 
-- Были ли брони, по которым не были получены посадочные талоны?
select distinct t.book_ref
from tickets t 
left join boarding_passes bp on t.ticket_no = bp.ticket_no 
where bp.ticket_no is null;

5
-- процентное соотношение перелетов по типам самолетов от общего количества
select fa.aircraft_code, round (fa.c1, 4) * 100 as "процент"
from (
select ad.aircraft_code, 
count (f.flight_id)::numeric/(select count(flight_id)::numeric from flights f) as c1
from flights f
right join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
group by ad.aircraft_code 
) fa


6
-- vtжду какими городами нет прямых рейсов?
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
except
select distinct c2.dc, c1.ac
from c1
join c2 on c1.flight_id = c2.flight_id
