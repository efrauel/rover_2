# Rover Data Engineer Interview
Author: Eric Frauel
Date 11/19/17

Questions: 

1) How many unique users both authenticated and anonymous visited the homepage?
	Answer 1: ~3988 Users visited the homepage.
2) Of authenticated users who visited the homepage, what percent go on to visit a search page in less than 30 minutes?
	Answer to Question 2: ~4.7%

3) What is the average number of search pages that a user visits?
	Answer to question 3: ~1.20 average number of search page visits per user. 

4) Which UTM source is best at generating users who visit the homepage and then a search page?
	Answer to Question 4: '9113d19048abb65bbff551b3417301d6' has the best with 51. 

5) If we were testing two different versions of the homepage and trying to measure their impact on search rates, what further information would you need and how would you collect it?
	Answer to Question 5: We would need a way to tell what version the pageviews were from.
	I would probably choose to have the Javascript client running in the browser ask the server which version it is and add a new column to this table. 
	That is only if the javascript wasn't able to tell without asking the server.
	Then you could just run all the queries above twice. 
	
Assumptions:
	Assumption 1: Every distinct_id is worth .94 Users. Based on calculations to determine how many distinct_ids per person_opk. (See rover_data.sql for queries done to come to this assumption)
	Assumption 2: Visiting the homepage is defined as having a record with page_cateory = 'home'. This could also be changed to having uri_path='/'. Same with search.
	Assumption 3: by multiplying the count of search_visits by 1.06 (the conversion rate of distinct_id users to person_opk users from assumption 1) we are adjusting for the fact that some of those distinct_ids are from the same user.
	Assumption 4: Since the question (#4) doesn't stipulate the 30 minute requirement here, I removed it. However, I did notice that the answer to the question is still the same.
	
Environment:
	Local Postgresql DB running on my windows desktop.
	Code: Just postgresql. I thought about using the json file and loading it all into memory and performing my calculations that way. But after some deliberation I chose the full sql approach. 
	