-- q6.sql

SET search_path TO bnb, public;

drop view if exists Committed cascade; 

create view Committed as
select distinct Booking.listingId, Booking.travelerId
from Booking join BookingRequest
on Booking.travelerId = BookingRequest.travelerId and 
Booking.listingId = BookingRequest.listingId;

select Committed.travelerId, surname, count(distinct listingId) as numListings
from Committed natural join Traveler
group by Committed.travelerId, surname 
order by Committed.travelerId asc;
