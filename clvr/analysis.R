


#health_risk_assesment is combination of different factors, so it would be useful to break it down on the various factors
#that affect the dieases/risk assessment and then use the tree split.
#because of correlated varibales/ confounding

clvr_data <- read.csv("~/Projects/data-analysis/clvr/data/data.csv")
clvr_table <- data.table(clvr_data)
summary(clvr_table)
dim(clvr_table)
length(unique(clvr_table$member_id))
clvr_table$servicing_provider_id <- as.factor(clvr_table$servicing_provider_id)
clvr_table$member_id <- as.factor(clvr_table$member_id)
clvr_table$outcome <- as.factor(clvr_table$outcome)
clvr_table$member_sex <- as.factor(clvr_table$member_sex)
summary(clvr_table)
clvr_table$treatment_date <- as.Date(parse_date_time(clvr_data$treatment_date, orders="mdy HM"))
clvr_table$outcome <- ifelse(clvr_table$outcome == "failure", 0,1)
clvr_table$outcome <- as.factor(clvr_table$outcome)

doc_success_rate <- clvr_table %>% group_by(servicing_provider_id) %>% summarise(success_rate = sum(outcome==1)/n(), num_of_cases = n())
success_rate_by_sex <- clvr_table %>% group_by(member_sex) %>% summarise(success_rate = sum(outcome==1)/n(), num_of_cases = n())
ggplot(doc_success_rate, aes(x= success_rate, y = avg_risk_assessment)) + geom_point(aes(size=num_of_cases, color="red"))
ggplot(clvr_table, aes(x= member_age, y = health_risk_assesment)) + geom_point(aes(color=outcome))

clvr.tree.model <- rpart(clvr_table$outcome~., data = clvr_table[,c(2,6,7,8),with=FALSE])
rpart.plot(clvr.tree.model)
clvr.tree.model

clvr.glm.model <- glm(outcome~.,data = clvr_table[,c(2,6,7,8,9),with=FALSE], family = binomial)
summary(clvr.glm.model)



