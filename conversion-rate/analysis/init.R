if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, boot, dplyr, leaps, glmnet, ROCR, rpart, randomForest, rpart.plot)


setwd("./conversion-rate/")
conversion_rate_data <- read.csv("data/conversion_data.csv")
conversion_rate_table <- data.table(conversion_rate_data)
conversion_rate_table$new_user <- as.factor(conversion_rate_table$new_user)
conversion_rate_table$converted <- as.factor(conversion_rate_table$converted)
summary(conversion_rate_table)

# Total_Pages_Visited vs Age
ggplot(conversion_rate_table, aes(x = age, y = total_pages_visited))
  + geom_point(aes(color = factor(converted)))
  + geom_vline(xintercept = 61, color = "black")
  + labs(x="Age", y = "Total Pages Visited", color="Converted (1 = True)")
  + ggtitle("Total Pages Visited vs Age") + theme(plot.title = element_text(face = "bold"))

# Source vs Age
ggplot(conversion_rate_table, aes(x = age, y = source))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Source", color="Converted (1 = True)")
  + ggtitle("Source vs Age")
  + theme(plot.title = element_text(face = "bold"))

# Age
qplot(conversion_rate_table$age, geom = "histogram", binwidth=.5, bins=20, col=I("red"), fill=I("red"), alpha = I(.5), xlim = c(10,80), xlab = "Age", ylab = "Count", main = "Histogram of Age", breaks=seq(10,80, by = 5))

# Country vs Age
ggplot(conversion_rate_table, aes(x = age, y = country))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Country", color="Converted (1 = True)")
  + ggtitle("Country vs Age")
  + theme(plot.title = element_text(face = "bold"))

conversion_rate_by_country <- conversion_rate_table %>%
  + group_by(country) %>%
  + summarise(conversion_rate = mean(converted))

ggplot(data = conversion_rate_by_country, aes(x=country, y=conversion_rate))
  + geom_bar(stat = "identity", aes(fill=country))
  + labs(x="Country", y = "Conversion Rate")
  + ggtitle("Conversion Rate by Country") + theme(plot.title = element_text(face = "bold"))

#remove outliers
conversion_rate_table <- data.table(filter(conversion_rate_table, age < 80))


