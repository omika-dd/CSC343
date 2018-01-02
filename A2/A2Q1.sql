-- q1.sql

SET search_path TO bnb, public;

drop view if exists BookingsLast10 cascade;
drop view if exists RequestsLast10 cascade;

-- We want the last 10 completed years from the current date, 
--so if today is Nov 10, 2016, then we will include 2006-2015 in the result.
create view BookingsLast10 as
select travelerId, extract(year from startdate) as year
from Booking 
where (extract(year from startdate) >= (extract(year from current_date) - 10)
and extract(year from startdate) < extract(year from current_date))
group by travelerId, startdate;

create view AllTravelerBookings as
select traveler.travelerId, year, count(year) as numBooking
from Traveler left join BookingsLast10
on Traveler.travelerId = BookingsLast10.travelerId
group by Traveler.travelerId, year;

create view RequestsLast10 as
select travelerId, extract(year from startdate) as year
from BookingRequest
where (extract(year from startdate) >= (extract(year from current_date) - 10)
 and extract(year from startdate) < extract(year from current_date))
group by travelerId, startdate;

create view AllTravelerRequests as 
select traveler.travelerId, year, count(year) as numRequests 
from Traveler left join RequestsLast10
on Traveler.travelerId = RequestsLast10.travelerId
group by Traveler.travelerId, year;

create view Requests as 
select Traveler.travelerId, email, year, numRequests
from Traveler natural join AllTravelerRequests;

create view Bookings as 
select Traveler.travelerId, email, year, numBooking
from Traveler natural join AllTravelerBookings;

select distinct coalesce(b1.travelerId, b2.travelerId) as travelerId, 
coalesce(b1.email, b2.email) as email, cast(coalesce(b1.year, b2.year) as Integer)
as year, coalesce(numRequests,0) as numRequests, coalesce(numBooking, 0) as numBooking
from Requests as b1 full join Bookings as b2
on b1.travelerId = b2.travelerId and b1.year = b2.year  
order by year desc, travelerId asc;










































