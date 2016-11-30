---
layout: post
title: Conversion Rate
tags: [random-forests, logistic-regression]
---

## Challenge Description

We have data about users who hit our site: whether they converted or not as well as some of their characteristics such as their country, the marketing channel, their age, whether they are repeat users and the number of pages visited during that session (as a proxy for site activity/time spent on site).

**Goals:**
Predict conversion rate
Come up with recommendations for the product team and the marketing team to improve conversion rate

## Data
The data is available [here](https://github.com/sabman83/data-analysis/raw/gh-pages/conversion-rate/data/conversion_data.csv){:target="_blank"}.

Columns:

* _country_ : user country based on the IP address
* _age_ : user age. Self-reported at sign-in step
* _new\_user_ : whether the user created the account during this session or had already an account and simply came back to the site
* _source_ : marketing channel source
  * _Ads_: came to the site by clicking on an advertisement
  * _Seo_: came to the site by clicking on search results
  * _Direct_: came to the site by directly typing the URL on the browser
* _total\_pages\_visited_: number of total pages visited during the session. This is a proxy for time spent on site and engagement during the session.
* _converted_: this is our label. 1 means they converted within the session, 0 means they left without buying anything. The company goal is to increase conversion rate: # conversions / total sessions.

## Exploring the data

I import the data from the csv file and store it in a data table. Besides the performance benefits, I also like data.table for its cleaner syntax especially when it comes to using the filters. I also convert the new_user and converted columns from numeric to factor.

~~~ r
conversion_rate_data <- read.csv("data/conversion_data.csv")
conversion_rate_table <- data.table(conversion_rate_data)
conversion_rate_table$new_user <- as.factor(conversion_rate_table$new_user)
conversion_rate_table$converted <- as.factor(conversion_rate_table$converted)

summary(conversion_rate_table)
~~~

|    country     |       age       |  new_user |     source     |  total_pages_visited| converted|
| China  : 76602 |  Min.   : 17.00 |  0: 99456 |  Ads   : 88740 |  Min.   : 1.000     | 0:306000 |
| Germany: 13056 |  1st Qu.: 24.00 |  1:216744 |  Direct: 72420 |  1st Qu.: 2.000     | 1: 10200 |
| UK     : 48450 |  Median : 30.00 |           |  Seo   :155040 |  Median : 4.000     |          |
| US     :178092 |  Mean   : 30.57 |           |                |  Mean   : 4.873     |          |
|                |  3rd Qu.: 36.00 |           |                |  3rd Qu.: 7.000     |          |
|                |  Max.   :123.00 |           |                |  Max.   :29.000     |          |


**Notes from summary**

* I notice that age has a maximum value of 123, This suggests that there might be some errors in the data.
* There no NA values, so we don't have to deal with empty values.
* The percentage of converted users  = (10200 / nrow(conversion_rate_table)) * 100 = 3.22%. So for a null classifier that predicts all users as non-converters, the error rate would be 3.22%.

I will now plot some visualizations to get a sense of the data and it's distribution.


**Total Pages Visited vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = total_pages_visited))
  + geom_point(aes(color = factor(converted)))
  + geom_vline(xintercept = 61, color = "black")
  + labs(x="Age", y = "Total Pages Visited", color="Converted (1 = True)")
  + ggtitle("Total Pages Visited vs Age") + theme(plot.title = element_text(face = "bold"))
~~~

![Total Pages Visted vs Age](/data-analysis/assets/pages-visited-vs-age.png)

There are two outliers having an age of over 100. We can safely assume that this is incorrect data and ignore them. Also, I notice that beyond a certain age all the users converted. This age threshold is marked by the vertical line at 61.
Users who have visited 20 or more pages also defintely converted.

**Source vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = source))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Source", color="Converted (1 = True)")
  + ggtitle("Source vs Age")
  + theme(plot.title = element_text(face = "bold"))
~~~

![Source vs Age](/data-analysis/assets/source-vs-age.png)

There doesn't seem to be any correlation between source and age and nor does source seem to have any affect on conversion. But we will confirm this using regression later.

**Country vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = country))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Country", color="Converted (1 = True)")
  + ggtitle("Country vs Age")
  + theme(plot.title = element_text(face = "bold"))
~~~

![Country vs Age](/data-analysis/assets/country-vs-age.png)

Again, country doesn't seem to have any correlation with age. China has very few converted users.


**Histogram of Age**

~~~ r
qplot(conversion_rate_table$age, geom = "histogram",
      binwidth=.5, bins=20,
      col=I("red"), fill=I("red"), alpha = I(.5),
      xlim = c(10,80), breaks=seq(10,80, by = 5)
      xlab = "Age", ylab = "Count", main = "Histogram of Age")
~~~

![Histogram of Age](/data-analysis/assets/histogram-of-age.png)

Majority of the users are between the age group of 20 to 40.
