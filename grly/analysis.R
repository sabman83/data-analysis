#Calculate the daily retention curve for users who used the app for the first time on the following dates: Feb 4th, and Feb 10th.
#Daily retention curve is defined as the % of users from the cohort, who used the product that day

install.packages("lubridate")
library(lubridate)
parse_date_time("2016-02-01 10:32", orders = "ymd HM")
grammarly$date_time <- parse_date_time(grammarly$date_time, orders = "ymd HM")
grammarly$first_utm_source <- as.factor(grammarly$first_utm_source)

grammarly_between_4th_and_10th <- filter(grammarly, (as.POSIXct("2016-02-04") <= date_time) & (as.POSIXct("2016-02-10") >= date_time))


grammarly_between_4th_and_10th %>%
+ group_by(date_time) %>%
+ summarise(daily_retention_curve = ( sum(used_first_time_today == TRUE)/n()) * 100)

#Determine if there are any differences in usage based on where the users came from. From which traffic source does the app get its best users? its worst users?
Who are considered best users?,Who are worst users?
 - probably users who came back to the app at least the next (or should it be 2 days or what is x?)
 - Then find distribution of these users by source.
 - evaluate if the difference is significant enough. Should this be a t-test?


#Separate from the data analysis, it would be great to hear your thoughts on the Grammarly product and what data-related projects/ideas you think we should be pursuing.

