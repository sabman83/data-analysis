#Does day and time matter?

#difference between request created and invitations sent

#Are service providers becoming more or less inclined to quote over time?
# - THis is a tough one. Because a providers response to an invite depends on the invite. If it is bad then in general it is going to
 # receive less invites.
# The other problem is with getting response rate of providers over time.

#How should I calculate over time?
#cant include seasonality because of lack of data

#There are trend tests. With respect to removing confounding variables or accounting for confounding variables, we might need to model and explain
#the effect of these exogenous variables on our response variable: https://pubs.usgs.gov/twri/twri4a3/pdf/chapter12.pdf

#more or less inclined to quote over time --- a simple avg won't do. We need give more preference to newer responses than to old responses

#analysis done sone far does not take into account invites with no response


library(DBI)
install.packages("RSQLite")
library(RSQLite)
conn <- dbConnect(RSQLite::SQLite(), "~/Projects/data-analysis/tack/invite_dataset_ff829852.sqlite")
tack_categories <- data.table(dbReadTable(conn,"categories"))
tack_invites <- data.table(dbReadTable(conn,"invites"))
tack_locations <- data.table(dbReadTable(conn,"locations"))
tack_quotes <- data.table(dbReadTable(conn,"quotes"))
tack_requests <- data.table(dbReadTable(conn,"requests"))
tack_users <- data.table(dbReadTable(conn,"users"))
request_invite_table <- data.table(merge(tack_requests, tack_invites, by.x = "request_id", by.y = "request_id", all = TRUE,suffixes = c("_requesting","_provider")))
request_invite_table$creation_time <- (parse_date_time(request_invite_table$creation_time, orders = "ymd HMS"))
request_invite_quotes_tables <- data.table(merge(request_invite_table, tack_quotes, by.x = "invite_id", by.y = "invite_id", all = TRUE, suffixes = c("_of_invite", "_of_quote")))
request_invite_quotes_tables$invite_id <- as.factor(request_invite_quotes_tables$invite_id)
request_invite_quotes_tables$request_id <- as.factor(request_invite_quotes_tables$request_id)
request_invite_quotes_tables$user_id_requesting <- as.factor(request_invite_quotes_tables$user_id_requesting)
request_invite_quotes_tables$category_id <- as.factor(request_invite_quotes_tables$category_id)
request_invite_quotes_tables$location_id <- as.factor(request_invite_quotes_tables$location_id)
request_invite_quotes_tables$user_id_provider <- as.factor(request_invite_quotes_tables$user_id_provider)
request_invite_quotes_tables$quote_id <- as.factor(request_invite_quotes_tables$quote_id)
request_invite_quotes_tables$sent_time_of_invite <- (parse_date_time(request_invite_quotes_tables$sent_time_of_invite, orders = "ymd HMS"))
request_invite_quotes_tables$sent_time_of_quote <- (parse_date_time(request_invite_quotes_tables$sent_time_of_quote, orders = "ymd HMS"))
quote_rate_by_category <- request_invite_quotes_tables %>% group_by(category_id) %>% summarise(num_of_requests = length(unique(request_id)), num_of_quotes = length(unique(quote_id)), quotes_per_request = length(unique(quote_id))/length(unique(request_id)))
quote_rate_by_time <- request_invite_quotes_tables %>% group_by(creation_time) %>% summarise(num_of_requests = length(unique(request_id)), num_of_quotes = length(unique(quote_id)), quotes_per_request = length(unique(quote_id))/length(unique(request_id)))
invites_join_quotes <- merge(tack_invites, tack_quotes, by = "invite_id", all = TRUE)
response_rate_of_providers <- invites_join_quotes %>% group_by(user_id) %>% summarise(requests_received = length(unique(invite_id)), quotes_sent= length(unique(quote_id)))
response_rate_of_providers$rate = response_rate_of_providers$quotes_sent / response_rate_of_providers$requests_received
invites_join_quotes <- merge(tack_invites, tack_quotes, by = "invite_id", suffixes = c("_of_invite","_of_quote"), all = TRUE)
invites_join_quotes$sent_time_of_quote <- as.Date(invites_join_quotes$sent_time_of_quote)
invites_join_quotes$sent_time_of_invite <- as.Date(invites_join_quotes$sent_time_of_invite)
time_series_quotes_rate <- invites_join_quotes %>% group_by(sent_time_of_invite) %>% summarise(num_of_invites = length(unique(invite_id)), num_of_quotes = length(unique(quote_id)), quotes_per_invite = length(unique(quote_id)) / length(unique(invite_id)))
library(ggplot2)
ggplot(time_series_quotes_rate, aes(x=sent_time_of_invite,y=quotes_per_invite)) +
geom_line()+
geom_text(aes(label=day), size=2)
invites_join_quotes$response_time <- invites_join_quotes$sent_time_of_quote - invites_join_quotes$sent_time_of_invite
invites_join_quotes$response_time <- as.numeric(invites_join_quotes$response_time)

