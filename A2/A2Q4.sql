-- q4.sql

SET search_path TO bnb, public;

drop view if exists HomeOwnerInfo cascade;

create view HomeOwnerInfo as
select a.listingId, extract(year from startdate) as year, rating, owner
from Listing as a natural join TravelerRating
where extract(year from startdate) >=  extract(year from current_date); 

-- This table includes all the homeowners who should be included in the
-- calculation for the average, whether they satisfy the condition or not.
-- In other words, they will be included in the denominator. 
create view Avg as
select a.owner, a.year, avg(a.rating) as average
from HomeOwnerInfo as a join HomeOwnerInfo as b 
on a.year = b.year and a.owner = b.owner
group by a.owner, a.year;
 
-- This table includes only the homeowners who do not satisfy the condition.
create view Decreasing as
select a.owner,a.year, a.average
from Avg as a join Avg as b
on (a.year <  b.year and a.owner = b.owner and a.average > b.average);

select cast((1 - ((cast(count(distinct Decreasing.owner) 
as float)/cast(count(distinct Avg.owner) as float)))) * 100 as Integer) as percentage 
from Decreasing, Avg; 







