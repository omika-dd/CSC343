-- q3.sql

SET search_path TO bnb, public;

drop view if exists Invalid cascade;

create view Invalid as
select b1.listingId, b1.startdate, b1.numNights
from Booking as b1 join Booking as b2  
on b1.listingId = b2.listingId
where b1.startdate <> b2.startdate and (b1.startdate, b1.startdate + b1.numNights)
 overlaps (b2.startdate, b2.startdate + b2.numNights);

create view Valid as 
select listingId, startdate, numNights 
from Booking 
except 
(select * from Invalid);

-- Get all the information we need in one table
create view Regulations as
select owner, Valid.listingId, Valid.startdate, Valid.numNights, Listing.city,
 Listing.propertyType, CityRegulation.regulationType, days
from Valid natural join Listing natural join CityRegulation;

-- Get the listings that have a minimum limit
create view Min as
select owner, listingId, startdate,numNights, city, days
from Regulations
where regulationType = 'min';

-- Get the listings that have a maximum limit
create view Max as
select owner, listingId, startdate, numNights, city, days
from Regulations
where regulationType = 'max';

-- Listings that violate the minimum limit
create view MinViolate as
select owner as homeowner, listingId, numNights, extract(year from startdate) 
as year, city from Min  
where numNights < days;

-- Listings that violate the maximum limit
-- There are two cases to consider: 
-- 1. Bookings span less than 1 year
-- 2. Bookings span more than 1 year (cannot be more than 2 years)
-- First we deal with the bookings that span less than one year. 
-- If the startdate and end date have the same year, then the booking falls into this category.

create view OneYearMax as
select * 
from Max
where extract(year from startdate) = extract(year from (startdate+numNights));

-- Getting this table in the correct format for future use
create view CaseOneFinal as
select owner as homeowner, listingId, numNights, extract(year from startdate) as year, city, days
from OneYearMax;

-- The other case is simply the complement of OneYearMax
create view MoreThanOneMax as
select *
from Max except
(select * from OneYearMax);

-- Now we must split the more than one year listings into year one and year two
-- I will subtract the last day of the year from the startdate to
-- get the number of nights in year one, e.g Jan 1, 2016 - Dec 29, 2015 = 3 nights. 
create view YearOne as
select owner as homeowner, listingId,
(to_date(extract(year from startdate) ||'-12-31', 'YYYY-MM-DD') - startdate)
 as numNights , extract(year from startdate) as year, city, days
from MoreThanOneMax; 
 
-- For Year 2, I will subtract the last day of the second year from the enddate.
create view YearTwo as
select owner as homeowner, listingId,
((startdate + numNights) - to_date(extract(year from startdate) ||'-12-31', 'YYYY-MM-DD'))
 as numNights , extract(year from startdate + numNights) as year,
city, days
from MoreThanOneMax; 

-- Now I must add up the number of nights for each listing in the same year (for the max case only)
create view MaxListings as
(select * from YearOne) union (select * from YearTwo) union (select * from CaseOneFinal); 

create view FinalMax as
select a.homeowner, a.listingId, sum(a.numNights) + sum(b.numNights) as numNights,
 a.year, a.city, a.days
from  MaxListings as a join MaxListings as b
on a.listingId = b.listingId and a.year = b.year
group by a.homeowner, a.listingId, a.year, a.city, a.days;

-- Finally, I will determine which of the listings that have a maximum limit violated this limit.
create view MaxViolate as
select homeowner, listingId, numNights, year, city
from FinalMax
where numNights > days;

-- We want both the max and min violations in one table, so we must union them together.
-- This will not allow the same listing to appear twice in one year.
(select homeowner, listingId, cast(year as Integer), city from MaxViolate)
union
(select homeowner, listingId, cast(year as Integer), city from MinViolate)
order by homeowner asc, listingId asc, year asc;



