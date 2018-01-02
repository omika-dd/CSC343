-- q8.sql

SET search_path TO bnb, public;

drop view if exists Reciprocals cascade;

-- For now we only include travelers who got atleast one reciprocal.
create view Reciprocals as
select c.travelerId, a.listingId, a.startdate, 
a.rating as ratingForHomeowner,b.rating as ratingForTraveler
from TravelerRating as a join HomeownerRating as b
on a.listingId = b.listingId and a.startdate = b.startdate 
join Booking as c
on b.listingId = c.listingId and b.startdate = c.startdate;

-- Number of reciprocals
create view NumReciprocals as
select travelerId, count(travelerId) as reciprocals
from Reciprocals
group by travelerId;

-- We now consider the case where either the traveler got 5 stars and the homeowner got 4 or vice versa
create view bs54 as
select travelerId, count(ratingforHomeowner) as bs54
from Reciprocals
where (ratingForHomeowner = 5 and ratingForTraveler = 4)
 or (ratingForHomeowner = 4 and ratingForTraveler = 5) or 
 (ratingForHomeowner = 5 and ratingForTraveler = 5) or (ratingForHomeowner = 4 and ratingForTraveler = 4)
group by travelerId;

-- We now consider the case where either the traveler got 4 stars and the homeowner got 3 or vice versa
create view bs43 as
select travelerId, count(ratingforHomeowner) as bs43
from Reciprocals
where (ratingForHomeowner = 4 and ratingForTraveler = 3)
 or (ratingForHomeowner = 3 and ratingForTraveler = 4) 
 or (ratingForHomeowner = 3 and ratingForTraveler = 3)
group by travelerId;

-- We now consider the case where either the traveler got 3 stars and the homeowner got 2 or vice versa
create view bs32 as
select travelerId, count(ratingforHomeowner) as bs32
from Reciprocals
where (ratingForHomeowner = 3 and ratingForTraveler = 2) 
or (ratingForHomeowner = 2 and ratingForTraveler = 3) 
or (ratingForHomeowner = 2 and ratingForTraveler = 2) 
group by travelerId;

-- We now consider the case where either the traveler got 2 stars and the homeowner got 1 or vice versa
create view bs21 as
select travelerId, count(ratingforHomeowner) as bs21
from Reciprocals
where (ratingForHomeowner = 2 and ratingForTraveler = 1) 
or (ratingForHomeowner = 1 and ratingForTraveler = 2) 
or (ratingForHomeowner = 1 and ratingForTraveler = 1)
group by travelerId;

-- Piecing it together
create view BackScratches as
select Reciprocals.travelerId, coalesce(bs54,0) + coalesce(bs43,0) + coalesce(bs32,0) + coalesce(bs21,0) as backScratches
from Reciprocals left join bs54
on Reciprocals.travelerId = bs54.travelerId
left join bs43 
on bs54.travelerId = bs43.travelerId
left join bs32
on bs43.travelerId = bs32.travelerId
left join bs21 
on bs32.travelerId = bs21.travelerId
group by Reciprocals.travelerId, bs54, bs43, bs32, bs21; 

select a.travelerId, coalesce(reciprocals, 0) as reciprocals,
 coalesce(backScratches, 0) as backScratches
from Traveler as a left join numReciprocals as b
on a.travelerId = b.travelerId
left join BackScratches as c
on b.travelerId = c.travelerId
order by reciprocals desc, backScratches desc, travelerId asc;




