-- q7.sql

SET search_path TO bnb, public;

drop view if exists PerNightAvg cascade;

-- Calculating the average per night price per listing
create view PerNightAvg as
select listingId, avg(price/numNights) as pernightavg
from Booking
group by listingId;

create view Bargainers as
select a.listingId, a.travelerId, price, pernightavg
from Booking as a natural join PerNightAvg as b
where a.price < pernightavg * 0.75;

select travelerId, cast((1 - (price/pernightavg))* 100 as Integer) as
 largestBargainPercentage, listingId
from Bargainers 
where travelerId = 
(select travelerId 
from Bargainers 
group by travelerId
having count(travelerId) >= 3)
order by largestBargainPercentage desc, travelerId asc; 
