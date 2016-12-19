if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, dplyr)


setwd("~/Projects/data-analysis/employee-retention/")
employee_retention <- read.csv("./data/employee_retention_data.csv")
summary(employee_retention)
as.character(employee_retention$employee_id)
as.character(employee_retention$company_id)
employee_retention <- data.table(employee_retention)

all_dates <- seq(as.Date("2011/01/24"), as.Date("2015/12/13"), by = "day")
all_company_ids <- unique(employee_retention$company_id)
all_company_ids <- sort(all_company_ids)
merge(all_company_ids,all_dates)



employees_quit_data <- employee_retention %>% group_by(company_id, quit_date) %>%
summarise(num_of_quitters  = n())
employees_quit_data <- rename(employees_quit_data, date = quit_date)
employees_hired_data <- employee_retention %>% group_by(company_id, join_date) %>%
summarise(num_of_hired  = n())
employees_hired_data <- rename(employees_hired_data, date = join_date)

employees_hired_quit_data <- merge(employees_hired_data,employees_quit_data,by = c("company_id","date"), all=TRUE) %>%
  arrange(company_id, date)
employees_hired_quit_data <- filter(employees_hired_quit_data, !is.na(date))

head_count_data <- merge(head_count_data, employees_hired_quit_data, by = c("company_id", "date"), all = TRUE)
head_count_data <- mutate(head_count_data,num_of_hired=replace(num_of_hired,is.na(num_of_hired),0))
head_count_data <- mutate(head_count_data,num_of_quitters=replace(num_of_quitters,is.na(num_of_quitters),0))
head_count_data <- mutate(head_count_data, diff = num_of_hired - num_of_quitters)
head_count_data <- head_count_data %>%
  group_by(company_id) %>%
  arrange(date) %>%
  mutate(head_count = cumsum(diff))












