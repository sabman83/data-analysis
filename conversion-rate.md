#Conversion Rate

##Challenge Description

We have data about users who hit our site: whether they converted or not as well as some of their characteristics such as their country, the marketing channel, their age, whether they are repeat users and the number of pages visited during that session (as a proxy for site activity/time spent on site).

Your project is to:
Predict conversion rate
Come up with recommendations for the product team and the marketing team to improve conversion rate

##Data
The data is available here. 

Columns:
- _country_ : user country based on the IP address
- _age_ : user age. Self-reported at sign-in step
- _new\_user_ : whether the user created the account during this session or had already an account and simply came back to the site
- _source_ : marketing channel source
- _Ads_: came to the site by clicking on an advertisement
- _Seo_: came to the site by clicking on search results
- _Direct_: came to the site by directly typing the URL on the browser
- _total\_pages\_visited_: number of total pages visited during the session. This is a proxy for time spent on site and engagement during the session.
- _converted_: this is our label. 1 means they converted within the session, 0 means they left without buying anything. The company goal is to increase conversion rate: # conversions / total sessions.
