if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, dplyr, rpart, rpart.plot)

translation_test_data <- read.csv("data/test_table.csv")
translation_test_table <- data.table(translation_test_data)

translation_user_data <- read.csv("data/user_table.csv")
translation_user_table <- data.table(translation_user_data)


summary(translation_test_table)


