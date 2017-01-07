#The file is a JSON representation of "ping" data for an app for the month of February 2016.
#It has about 4.5M rows, so it is quite big, once you uncompress it.
#When the app is opened by a user, the app pings the analytics system. There might be multiple pings in a day.
#The data has 6 columns
#attributed_to: User id related to the ping. Don't worry about the difference between ids of format 'u:' vs. 'f:'
#user_id and fingerprint columns can be ignored
#date_time: timestamp of the ping.
#used_first_time_today: 'true' if this is the first day of ping from the user. Basically, it indicates the first usage date for the user.
#first_utm_source: the traffic source of the user.

#Determine if there are any differences in usage based on where the users came from. From which traffic source does the app get its best users? its worst users?
#Separate from the data analysis, it would be great to hear your thoughts on the Grammarly product and what data-related projects/ideas you think we should be pursuing.


#Calculate the daily retention curve for users who used the app for the first time on the following dates: Feb 4th, and Feb 10th.
#Daily retention curve is defined as the % of users from the cohort, who used the product that day
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, dplyr, jsonlite, lubridate)

grammarly <- stream_in(file("~/Projects/grammarly/data/pings.txt"))
grly_table <- data.table(grammarly)
grly_table$attributed_to <- as.factor(grly_table$attributed_to)
grly_table$first_utm_source <- as.factor(grly_table$first_utm_source)
grly_table$fingerprint <- NULL
grly_table$user_id <- NULL
grly_table$date_time <- parse_date_time(grly_table$date_time, orders = "ymd HM")
grly_table$date <- as.Date(grly_table$date_time)
summary(grly_table)

#Remove duplicate rows
grly_table <-  grly_table[!(duplicated(grly_table)),]

#still some duplicates found for a given user and date-time. They had different sources.
#Fixed it by using the row which had a source. the source was either set or was null.
duplicate_rows <- grly_table%>% group_by(attributed_to, date_time) %>% filter(n() > 1)
View(duplicate_rows)
indices <- seq(1,nrow(duplicate_rows),2)
for(i in indices) {
duplicate_rows[i,]$first_utm_source <- duplicate_rows[i+1,]$first_utm_source
}
duplicate_rows <- duplicate_rows[indices,]
View(duplicate_rows)
nrow(duplicate_rows)
grly_table <- grly_table%>% group_by(attributed_to, date_time) %>% filter(n() == 1) #TODO: better, faster way to filter out this data
grly_table <- rbind(grly_table,duplicate_rows)
nrow(grly_table%>% group_by(attributed_to, date_time) %>% filter(n() > 1))

length(unique(grly_table$attributed_to))
nrow(grly_table)

#ensuring that true and false are assigned correctly
qdata <- grly_table %>% group_by(attributed_to, date) %>% filter(!(sum(used_first_time_today) == n() || sum(used_first_time_today) == 0))
nrow(qdata)

#Exercise
#Calculate the daily retention curve for users who used the app for the first time on the following dates: Feb 4th, and Feb 10th.
#Daily retention curve is defined as the % of users from the cohort, who used the product that day
#grly_table <- data.table(grly_table)
#users_visited_on_4th <- filter(grly_table, date_time >= (as.POSIXct("2016-02-04 00:00:00", tz = "UTC")) & date_time <= as.POSIXct("2016-02-04 23:59:59", tz = "UTC"))
#summary(users_visited_on_4th)
#users_visited_on_10th <- filter(grly_table, date_time >= (as.POSIXct("2016-02-10 00:00:00", tz = "UTC")) & date_time <= as.POSIXct("2016-02-10 23:59:59", tz = "UTC"))
#summary(users_visited_on_10th)
#summarise(users_visited_on_10th, daily_retention_curve = (sum(used_first_time_today)/n() * 100))
#summarise(users_visited_on_4th, daily_retention_curve = (sum(used_first_time_today)/n() * 100))
#retention_data <- grly_table[!duplicated(grly_table, by = c(1,5))]
#users_4th <- retention_data %>% filter(date == as.Date("2016-02-04"))
#summarise(users_4th, daily_retention_curve = (sum(used_first_time_today)/n() * 100))
#View(users_4th)
#nrow(users_4th)
#length(unique(users_4th$attributed_to))
#users_10th <- retention_data %>% filter(date == as.Date("2016-02-10"))
#summarise(users_10th, daily_retention_curve = (sum(used_first_time_today)/n() * 100))
#length(unique(users_10th$attributed_to)) == nrow(users_10th)
retention_curve_for_4th <- grly_table %>% group_by(date) %>% summarise(retention_rate = length(intersect(new_users_on_4th,unique(attributed_to))) / length(unique(attributed_to)))
View(retention_curve_for_4th)
plot(retention_curve_for_4th)
retention_curve_for_4th <- grly_table %>% group_by(date) %>% summarise(retention_rate = length(intersect(new_users_on_4th,unique(attributed_to))) / length(new_users_on_4th))
plot(retention_curve_for_4th)
new_users_on_10th <- grly_table %>% filter(date == as.Date("2016-02-10") & used_first_time_today == TRUE)
new_users_on_10th <-  unique(new_users_on_10th$attributed_to)
retention_curve_for_10th <- grly_table %>% group_by(date) %>% summarise(retention_rate = length(intersect(new_users_on_10th,unique(attributed_to))) / length(new_users_on_10th))
plot(retention_curve_for_10th)

retention_curve <- retention_curve_for_4th
retention_curve$retention_rate_on_4th <- retention_curve_for_4th$retention_rate
retention_curve$retention_rate_on_10th <- retention_curve_for_10th$retention_rate
melted_retention_curve <- melt(retention_curve, id="date")
ggplot(data = melted_retention_curve, aes(x=date,y= value, colour = variable)) +geom_line()


#Determine if there are any differences in usage based on where the users came from. From which traffic source does the app get its best users? its worst users?
#Who are considered best users?,Who are worst users?

 #- probably users who came back to the app at least the next (or should it be 2 days or what is x?)
 #- maybe get a distribution of users who visit, once, 2 days, 3 days ,etc and then decide what is best.
 #- Then find distribution of these users by source.
 #- evaluate if the difference is significant enough. Should this be a t-test?
 #- what about the time of the day? and the day?
 #- possible have to do anova for comparing different means (No to ANOVA, which assumes a normally distributed outcome variable (among other things))
 #- instead of saying best vs worst , keep the num of visits and use that information. This way you can do anova as well

#users_visiting_grammalry <-
#+ grammarly_table %>%
#+ group_by(attributed_to) %>%
#+ summarise(num_of_days = length(unique(date_time)))


#worst_users <-
#+ users_visiting_grammalry  %>%
#+ filter(num_of_days < 4) %>%
#+ select(attributed_to)

#best_users <- users_visiting_grammalry  %>%
#+ filter(num_of_days > 20) %>%
#+ select(attributed_to)

##the above does not take into account that users might have joined in late
##so we can later filter these users from the main table, and ony include those whose first visit is no later than 4 days before the trial run

#best_user_details <- (merge(grammarly_table, best_users, by = "attributed_to")  %>% filter(used_first_time_today == TRUE))
#best_user_details$first_utm_source <- as.factor(best_user_details$first_utm_source)
#summary(best_user_details)


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

source_info = users_info %>% group_by(first_utm_source) %>% summarise(worst_convertes = mean(worst_user), best_converters=mean(best_user), total_users=n())

older_users <- grammarly_table[used_first_time_today==TRUE & date_time < as.Date("2016-02-17")]

avg_days_by_source <- users_info %>% group_by(first_utm_source) %>% summarise(avg_days = mean(num_of_days))
avg_days_by_source_older <- users_info[older_users] %>% group_by(first_utm_source) %>% summarise(avg_days = mean(num_of_days))
avg_days_by_source <- older_users_info %>% group_by(first_utm_source) %>% summarise(avg_days_spent = mean(num_of_days), num_of_users = n())
boxplot(older_users_info$num_of_days~older_users_info$first_utm_source)
boxplot(older_users_info$num_of_days~older_users_info$first_utm_source, col=rainbow(21))

par(mar=c(5,15,1,1))
boxplot(older_users_filtered_by_major_sources$daily_visit_rate~older_users_filtered_by_major_sources$first_utm_source, col=rainbow(21), las=2, horizontal = TRUE)

ggplot(data = visit_rate_by_source, aes(x=first_utm_source, y=(avg_visit_rate))) + geom_point(aes(size=num_of_users, label = first_utm_source))


install.packages("nortest")
library(nortest)
ad.test(older_users$daily_visit_rate)


kruskal.test(daily_visit_rate~first_utm_source, data = older_users_filtered_by_major_sources)
require(PMCMR)

phoc_dunn_results <- posthoc.kruskal.dunn.test(older_users_filtered_by_major_sources$daily_visit_rate~older_users_filtered_by_major_sources$first_utm_source)
summary(phoc_dunn_results)
phoc_dunn_matrix <- phoc_dunn_results$p.value
for(rname in rownames(phoc_dunn_matrix)) {
for(cname in colnames(phoc_dunn_matrix)) {
if((!is.na(phoc_dunn_matrix[rname,cname])) & (phoc_dunn_matrix[rname,cname] < 0.05)) {
print (paste0(rname, " - ", cname, " => " , phoc_dunn_matrix[rname, cname]))
}
}
}


aov_cont <- aov(older_users_info$num_of_days~older_users_info$first_utm_source)
summary(aov_cont)
tuk<- TukeyHSD(aov_cont)
tuk
tuk_results <- data.table(tuk$`older_users_info$first_utm_source`)
View(tuk_results)
avg_days_by_source <- older_users_info %>% group_by(first_utm_source) %>% summarise(avg_days_spent = mean(num_of_days), num_of_users = n(), stdDev = sd(num_of_days), num_of_best_users = sum(best_user), num_of_worst_users = sum(worst_user))
install.packages("PMCMR")
require(PMCMR)
posthoc.kruskal.nemenyi.test(users_info$num_of_days~users_info$first_utm_source, dist = "Tukey")
phoc_results_1 <- posthoc.kruskal.nemenyi.test(g=users_info$first_utm_source, x= users_info$num_of_days, p.adjust.methods="none")
summary(phoc_results_1)

