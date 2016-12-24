#Calculate the daily retention curve for users who used the app for the first time on the following dates: Feb 4th, and Feb 10th.
#Daily retention curve is defined as the % of users from the cohort, who used the product that day
grammarly <- stream_in(file("~/Projects/grammarly/data/pings.txt"))
?
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
 - maybe get a distribution of users who visit, once, 2 days, 3 days ,etc and then decide what is best.
 - Then find distribution of these users by source.
 - evaluate if the difference is significant enough. Should this be a t-test?
 - what about the time of the day? and the day?

users_visiting_grammalry <-
+ grammarly_table %>%
+ group_by(attributed_to) %>%
+ summarise(num_of_days = length(unique(date_time)))


worst_users <-
+ users_visiting_grammalry  %>%
+ filter(num_of_days < 4) %>%
+ select(attributed_to)

best_users <- users_visiting_grammalry  %>%
+ filter(num_of_days > 20) %>%
+ select(attributed_to)

#the above does not take into account that users might have joined in late
#so we can later filter these users from the main table, and ony include those whose first visit is no later than 4 days before the trial run

best_user_details <- (merge(grammarly_table, best_users, by = "attributed_to")  %>% filter(used_first_time_today == TRUE))
best_user_details$first_utm_source <- as.factor(best_user_details$first_utm_source)
summary(best_user_details)


#Separate from the data analysis, it would be great to hear your thoughts on the Grammarly product and what data-related projects/ideas you think we should be pursuing.
grammarly_table <- data.table(grammarly)
grammarly_table$date_time <- as.Date(grammarly_table$date_time)

sort(unique(grammarly_table$first_utm_source))
grammarly_table[first_utm_source == "[brand1, brand1]"]$first_utm_source <- "brand1"
grammarly_table[first_utm_source == "[brand1,+brand1]"]$first_utm_source <- "brand1"


users_info = data.table(user_id=unique(grammarly_table$attributed_to))
users_info$worst_user <- rep(0,nrow(users_info))
users_info$best_user <- rep(0,nrow(users_info))
users_info$first_utm_source <- rep(NA_character_,nrow(users_info))
best_users <- data.table(best_users)
setkeyv(best_users,c("attributed_to"))
setkeyv(users_info,c("user_id"))
users_info[best_users, best_user:=1]
worst_users <- data.table(worst_users)
setkeyv(worst_users, c("attributed_to"))
users_info[worst_users, worst_user:=1]
users_info %>% filter(best_user==1 & worst_user==1)
users_to_source <- grammarly_table %>% distinct(attributed_to, first_utm_source)  %>% filter(!is.na(first_utm_source))
users_info <- merge(users_info, users_to_source, by.x = "user_id", by.y = "attributed_to", all.x = TRUE)
users_info[,first_utm_source.x:=NULL]
users_info <- rename(users_info, first_utm_source =  first_utm_source.y)
summary(users_info)




