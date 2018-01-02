--q2.sql

SET search_path TO bnb, public;

drop view if exists Requests cascade;
drop view if exists Bookings cascade;
drop view if exists RequestedCities cascade;

-- Number of requests for each traveler
create view Requests as
select Traveler.travelerId, count(requestId) as numRequests
from Traveler left join BookingRequest
on Traveler.travelerId = BookingRequest.travelerId
group by Traveler.travelerId;

-- Number of bookings for each traveler
create view Bookings as
select Traveler.travelerId, count(listingId) as numBooking
from Traveler left join Booking
on Traveler.travelerId = Booking.travelerId
group by Traveler.travelerId;

-- Travelers who have numRequests > 10*avg and numBooking = 0
create view Scrapers as
select Bookings.TravelerId, numRequests, numBooking
from Requests natural join Bookings
where numRequests >  
(select 10 * avg(numRequests) from Requests)
and numBooking = 0; 

-- Most requested cities
create view RequestedCities as
select travelerId, city
from Listing join BookingRequest
on Listing.listingId = BookingRequest.listingId
group by travelerId, city
order by count(BookingRequest.requestId) desc, city asc
limit 1;

-- Piecing this information together
select distinct Scrapers.travelerId, 
(firstname || ' ' || surname) as name,
coalesce(email, 'unknown') as email, 
city as mostRequestedCity, numRequests
from Scrapers natural join Traveler natural join RequestedCities;


