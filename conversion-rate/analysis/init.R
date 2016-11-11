if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, boot)


setwd("./conversion-rate/")
conversion_rate_data <- read.csv("data/conversion_data.csv")
conversion_rate_table <- data.table(conversion_rate_data)
conversion_rate_table$new_user <- as.factor(conversion_rate_table$new_user)
conversion_rate_table$converted <- as.factor(conversion_rate_table$converted)
summary(conversion_rate_table)


ggplot(conversion_rate_table, aes(x = age, y = total_pages_visited)) 
      + geom_point(aes(color = factor(converted))) 
      + geom_vline(xintercept = 61, color = "red")

ggplot(converted_users, aes(x = age, y = source)) 
      + geom_point(aes(color = total_pages_visited)) co

ggplot(converted_users, aes(x = age, y = source)) 
      + geom_point(aes(color = factor(new_user))) 

ggplot(conversion_rate_table, aes(x = age, y = country)) + geom_point(aes(color = factor(converted)))
ggplot(converted_users, aes(x = age, y = country)) + geom_point(aes(color = factor(converted)))
