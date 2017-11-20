--Create table
create table rover_data (
	distinct_id varchar(64),
    event_name varchar(32),
    page_category varchar(32),
    person_opk varchar(64),
    ts bigint,
    uri_path varchar(64),
    utm_source varchar(64)
);

--import data from csv

--Question 1: How many unique users both authenticated and anonymous visited the homepage?

--Need to figure how how to count the non authenticated users. distinct_id seems useful, but how much of an indication of a distinct user is it.
--Average number of distinct_ids per person_opk? This will tell us how heavily we should weight distinct_ids as a unique identifier.
--Need to count distinct number of distinct_ids per authenticated user (person_opk notnull) using the home page (page_category = 'home'), and find the average.
select avg(distinct_count) from (select person_opk, count(distinct distinct_id) as distinct_count from rover_data where page_category = 'home' and person_opk notnull group by person_opk) as sub;                   
--yields ~1.06 distinct distinct_ids per person_opk on average.
--Assumption 1: Every distinct_id is worth .94 Users. Based on calculations to determine how many distinct_ids per person_opk.
--Assumption 2: Visiting the homepage is defined as having a record with page_cateory = 'home'. This could also be changed to having uri_path='/'. Same with search.
select sum(user_count) from (
(select count(distinct person_opk) as user_count from rover_data where person_opk notnull and page_category = 'home')
    union all
(select count(distinct distinct_id) *.94 as user_count from rover_data where distinct_id notnull and page_category = 'home' and person_opk isnull)
) as sub;

--Answer 1: ~3988 Users visited the homepage.




--Question 2: Of authenticated users who visited the homepage, what percent go on to visit a search page in less than 30 minutes?
select cast(home_to_search_users as decimal)/user_count * 100 as percent_search_visitors from (
(select count(distinct person_opk) as user_count from rover_data where person_opk notnull and page_category = 'home') users
	cross join
(select count(distinct h.person_opk) as home_to_search_users from rover_data h join rover_data s on h.person_opk = s.person_opk where h.page_category = 'home' and s.page_category = 'search' and (s.ts - h.ts) between 0 and 1800000) searchers
) as sub_query;
--Answer to Question 2: ~ 4.7%



--Question 3: What is the average number of search pages that a user visits?
--Going to to check for just authenticated users first.
--select avg(count_search) from (select person_opk, count(1) as count_search from rover_data where page_category = 'search' and person_opk notnull group by person_opk) as sub;
--avg for authenticated users is 1.21;

--non authenticated users?
--select avg(search_visits) * 1.06 from (select distinct_id, count(1) as search_visits from rover_data where page_category='search' and person_opk isnull group by distinct_id) as sub;
--Assumption/Design choice 3: by multiplying the count of search_visits by 1.06 (Basically the conversion rate of distinct_id users to person_opk users) we are adjusting for the fact that some of those distinct_ids are from the same user.
select avg(search_visits) from (
(select person_opk, count(1) as search_visits from rover_data where page_category = 'search' and person_opk notnull group by person_opk)
    union all
(select distinct_id, count(1) * 1.06 as search_visits from rover_data where page_category='search' and person_opk isnull group by distinct_id) 
) as union_sub_query;

--Answer to question 3: 1.20 average number of search page visits per user. 

--Question 4: Which UTM source is best at generating users who visit the homepage and then a search page?
--Assumption 4: Since the question doesn't stipulate the 30 minute requirement here, I removed it. However, I did notice that the answer to the question is still the same.
select h.utm_source, count(distinct h.person_opk) as home_to_search_users 
from rover_data h join rover_data s on (h.person_opk = s.person_opk and h.person_opk notnull) or (h.distinct_id = s.distinct_id and h.person_opk isnull)
where h.page_category = 'home' and s.page_category = 'search' and h.utm_source = s.utm_source group by h.utm_source order by home_to_search_users desc;

--Answer to Question 4: '9113d19048abb65bbff551b3417301d6' has the best with 51. 


--Question 5: If we were testing two different versions of the homepage and trying to measure their impact on search rates, what further information would you need and how would you collect it?
--Answer to Question 5: We would need a way to tell what version the pageviews were from.
--I would probably choose to have the Javascript client running in the browser ask the server which version it is and add a new column to this table. Then you could just run all the queries above twice. 
   
