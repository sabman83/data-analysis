#confirm uniqueness of users
length(unique(translation_test_table$user_id))
nrow(translation_test_table)

#users with no information
filter(translation_test_table, !(user_id %in% translation_user_table$user_id) )
unknown_users <- filter(translation_test_table, !(user_id %in% translation_user_table$user_id) )

#merge the two tables
translation_table <- merge(translation_test_table, translation_user_table, by = "user_id")

#confirm SPain users were not part of test group
filter(translation_table, test==1, country=="Spain")

#separate test and control group
test_users_table <- filter(translation_table, test==1)
control_users_table <- filter(translation_table, test==0)
nrow(test_users_table)
nrow(control_users_table)

#plot conversion rate for test and control group grouped by country
test_users_grouped_by_country = test_users_table %>% group_by(country) %>% summarise(test_conversion_rate = mean((conversion)))
control_users_grouped_by_country = control_users_table %>% group_by(country) %>% summarise(control_conversion_rate = mean(conversion))
conversion_rate_by_country <- merge(test_users_grouped_by_country, control_users_grouped_by_country, by = "country")
ggplot(melt(conversion_rate_by_country), aes(x=country, y=value)) + geom_bar(stat = "identity",aes(fill = variable), position = "dodge") + ggtitle("Conversion Rate by Countries") + labs(x="Country", y="Conversion Rate")+ theme(plot.title=element_text(face = "bold"))

#compare test and control conversion rates for significance
t_test_results <- translation_table_excluding_spain %>%
  group_by(country) %>%
  summarize(p_value <- t.test(conversion[test == 1], conversion[test == 0])$p.value,
              test_conversion_rate <- t.test(conversion[test == 1], conversion[test == 0])$estimate[1],
              control_conversion_rate <- t.test(conversion[test == 1], conversion[test == 0])$estimate[2]) %>%
  arrange(p.value)


#perform t-test to verify significance in conversion rate difference for each country
translation_table_excluding_spain <- filter(translation_table, country != "Spain")
t_test_results <- translation_table_excluding_spain %>%
  group_by(country) %>%
  summarize(p_value = t.test(conversion[test == 1], conversion[test == 0])$p.value,
            test_conversion_rate = t.test(conversion[test == 1], conversion[test == 0])$estimate[1],
            control_conversion_rate = t.test(conversion[test == 1], conversion[test == 0])$estimate[2]) %>%
  arrange(p_value)

t_test_results


#perform t-test for overall test vs control conversion rate
test_vs_control <- t.test(translation_table_excluding_spain$conversion[translation_table_excluding_spain$test==1], translation_table_excluding_spain$conversion[translation_table_excluding_spain$test==0])
test_vs_control

#verify selection bias
tree <- rpart(test~., translation_table_excluding_spain, control = rpart.control(maxdepth = 2))
