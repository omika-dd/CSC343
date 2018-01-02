-- q5.sql

SET search_path TO bnb, public;

drop view if exists AllRatings cascade; 
 
-- First we must get all the homeowners in one table, including those who did not receive any ratings
create view AllRatings as
select homeownerId, a.listingId, rating
from Listing as a natural join TravelerRating
right join Homeowner 
on homeownerId = owner
order by rating desc, homeownerId asc;

-- Five stars:
create view Five as
select distinct homeownerId, count(rating) as r5
from AllRatings
where rating = 5 
group by homeownerId;

-- Four stars:
create view Four as
select distinct homeownerId, count(rating) as r4
from AllRatings
where rating = 4  
group by homeownerId;

-- Three stars:
create view Three as
select distinct homeownerId, count(rating) as r3
from AllRatings
where rating = 3  
group by homeownerId;

-- Two stars:
create view Two as
select distinct homeownerId, count(rating) as r2
from AllRatings
where rating = 2 
group by homeownerId;

-- One star:
create view One as
select distinct homeownerId, count(rating) as r1
from AllRatings
where rating = 1
group by homeownerId;

select a.homeownerId, b.r5, c.r4, d.r3, e.r2, f.r1
from Homeowner as a natural full join Five as b 
natural full join Four as c
natural full join Three as d 
natural full join Two as e 
natural full join One as f
order by r5 desc, r4 desc, r3 desc,
r2 desc, r1 desc,  homeownerId asc;








