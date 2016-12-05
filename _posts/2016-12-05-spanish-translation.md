---
layout: post
title: Spanish Translation A/B Test
tags: [t-test, ab-testing]
---

## Contents
---

* [Problem Description](#problem-description)
* [Data](#data)
* [Exploring the data](#exploring-the-data)
* [Analysis](#analysis)
* [Conclusion](#conclusion)


## Problem Description

Company XYZ is a worldwide e-commerce site with localized versions of the site.

A data scientist at XYZ noticed that Spain-based users have a much higher conversion rate than any other Spanish-speaking country. She therefore went and talked to the international team in charge of Spain And LatAm to see if they had any ideas about why that was happening.

Spain and LatAm country manager suggested that one reason could be translation. All Spanish- speaking countries had the same translation of the site which was written by a Spaniard. They agreed to try a test where each country would have its one translation written by a local.

After they run the test however, they are really surprised cause the test is negative. I.e., it appears that the non-localized translation was doing better!

You are asked to:

* Confirm that the test is actually negative. That is, it appears that the old version of the site with just one translation across Spain and LatAm performs better
* Explain why that might be happening. Are the localized translations really worse?
* If you identified what was wrong, design an algorithm that would return FALSE if the same problem is happening in the future and TRUE if everything is good and the results can be trusted.

## Data
We have 2 tables in csv files. The 2 tables are:

*test_table* : general information about the test results

Columns:

* *user_id* : the id of the user. Unique by user. Can be joined to user id in the other table. For each user, we just check whether conversion happens the first time they land on the site since the test started.
* *date* : when they came to the site for the first time since the test started
* *source* : marketing channel: Ads, SEO, Direct .
* *browser_language* : in browser or app settings, the language chosen by the user. It can be EN, ES, Other (Other means any language except for English and Spanish) ads_channel : if marketing channel is ads, this is the site where the ad was displayed. It can be: Google, Facebook, Bing, Yahoo ,Other. If the user didn't come via an ad, this field is NA
* *browser* : user browser. It can be: IE, Chrome, Android_App, FireFox, Iphone_App, Safari, Opera
* *conversion* : whether the user converted (1) or not (0). This is our label. A test is considered successful if it increases the proportion of users who convert.
* *test* : users are randomly split into test (1) and control (0). Test users see the new translation and control the old one. For Spain-based users, this is obviously always 0 since there is no change there.



*user_table* - Information about the user

Columns:

* *user_id* : the id of the user. It can be joined to user id in the other table sex : user sex: Male or Female
* *age* : user age (self-reported)
* *country* : user country based on ip address

## Exploring the data

~~~ r

> translation_test_data <- read.csv("data/test_table.csv")
> translation_test_table <- data.table(translation_data)
>
> translation_user_data <- read.csv("data/user_table.csv")
> translation_user_table <- data.table(translation_user_data)
>
> nrow(translation_test_table)
[1] 453321
>
> summary(translation_test_table)
    user_id                date           source          device       browser_language   ads_channel
 Min.   :      1   2015-11-30: 71025   Ads   :181877   Mobile:201756   EN   : 63137     Bing    : 13689
 1st Qu.: 249816   2015-12-01: 70991   Direct: 90834   Web   :251565   ES   :377547     Facebook: 68425
 Median : 500019   2015-12-02: 70649   SEO   :180610                   Other: 12637     Google  : 68180
 Mean   : 499938   2015-12-03: 99493                                                    Other   :  4148
 3rd Qu.: 749522   2015-12-04:141163                                                    Yahoo   : 27435
 Max.   :1000000                                                                        NA's    :271444

        browser         conversion           test
 Android_App:155135   Min.   :0.00000   Min.   :0.0000
 Chrome     :101929   1st Qu.:0.00000   1st Qu.:0.0000
 FireFox    : 40766   Median :0.00000   Median :0.0000
 IE         : 61715   Mean   :0.04958   Mean   :0.4764
 Iphone_App : 46621   3rd Qu.:0.00000   3rd Qu.:1.0000
 Opera      :  6090   Max.   :1.00000   Max.   :1.0000
 Safari     : 41065
~~~

Looks like we have data for 5 days of activity from 30th November to 4th of December, 2015 containing nearly 500,000 rows.

I verify that each row has a unique user id.

~~~ r
> nrow(translation_test_table)
[1] 453321
> length(unique(translation_test_table$user_id))
[1] 453321
~~~

Next, I will verify if we have information for all the users in the test_table.

~~~ r
> unknown_users <- filter(translation_test_table, !(user_id %in% translation_user_table$user_id) )
> nrow(unknown_users)
[1] 454
~~~

We don't have information for 454 users. Since the number is relatively small compared to the total number of users, I am going to ignore these users and merge the two tables for further analysis.

~~~ r
translation_table <- merge(translation_test_table, translation_user_table, by = "user_id")
~~~

I now verify that the test users are not from Spain since their translations remain the same.

~~~ r
> nrow(filter(translation_table, test==1, country=="Spain"))
[1] 0
~~~

Next, I create a separate data table for test and control users.

~~~ r
> test_users_table <- filter(translation_table, test==1)
> control_users_table <- filter(translation_table, test==0)
> nrow(test_users_table)
[1] 215774
> nrow(control_users_table)
[1] 237093
~~~

The split percentage between test and control users is 47%  to 53% which is almost even.

Now, I want to compare the conversion rate between the test and control users for each country. I will plot this information on a bar chart.

~~~ r

> test_users_grouped_by_country = test_users_table %>%
    group_by(country) %>%
    summarise(test_conversion_rate = mean((conversion)))

> control_users_grouped_by_country = control_users_table %>%
    group_by(country) %>%
    summarise(control_conversion_rate = mean(conversion))

> conversion_rate_by_country <- merge(test_users_grouped_by_country, control_users_grouped_by_country, by = "country")

> ggplot(melt(conversion_rate_by_country), aes(x=country, y=value))
  + geom_bar(stat = "identity",aes(fill = variable), position = "dodge")
  + ggtitle("Conversion Rate by Countries") + labs(x="Country", y="Conversion Rate")
  + theme(plot.title=element_text(face = "bold"))
Using country as id variables
~~~

![Conversion Rate By Country](/data-analysis/assets/conversion-rate-by-spanish-countries.png)

The conversion rate is not always worse for test users over control users. In countries like Chile, Costa Rica, Nicaragua, Panama the conversion rate is slightly better for test users.

In the next section, I will evaluate if these differences are actually significant.

## Analysis

We earlier saw the differences in the conversion rate between the test and control users by each country. We will now use the t-test to measure if these differences are significant.

~~~ r
> translation_table_excluding_spain <- filter(translation_table, country != "Spain")
> t_test_results <- translation_table_excluding_spain %>%
+     group_by(country) %>%
+     summarize(p_value = t.test(conversion[test == 1], conversion[test == 0])$p.value,
+               test_conversion_rate = t.test(conversion[test == 1], conversion[test == 0])$estimate[1],
+               control_conversion_rate = t.test(conversion[test == 1], conversion[test == 0])$estimate[2]) %>%
+ arrange(p_value)
> t_test_results
# A tibble: 16 × 4
       country   p_value test_conversion_rate control_conversion_rate
        <fctr>     <dbl>                <dbl>                   <dbl>
1       Mexico 0.1655437           0.05118631              0.04949462
2  El Salvador 0.2481267           0.04794689              0.05355404
3        Chile 0.3028476           0.05129502              0.04810718
4    Argentina 0.3351465           0.01372502              0.01507054
5     Colombia 0.4237191           0.05057096              0.05208949
6     Honduras 0.4714629           0.04753981              0.05090576
7    Guatemala 0.5721072           0.04864721              0.05064288
8    Venezuela 0.5737015           0.04897831              0.05034367
9   Costa Rica 0.6878764           0.05473764              0.05225564
10      Panama 0.7053268           0.04937028              0.04679552
11     Bolivia 0.7188852           0.04790097              0.04936937
12        Peru 0.7719530           0.05060427              0.04991404
13   Nicaragua 0.7804004           0.05417676              0.05264697
14     Uruguay 0.8797640           0.01290670              0.01204819
15    Paraguay 0.8836965           0.04922910              0.04849315
16     Ecuador 0.9615117           0.04898842              0.04915381
~~~

The p-value for each country indicates that the differences are not significant to draw any conclusions.

## Conclusion

The hypothesis that the test conversion rates were worse cannot be proved. The conversion rates were better in some countries but the overall differences are not siginificant enough to validate the use of localized translations.

It might be worth considering to run these tests for a long period of time since the conversion rate has not been affected significantly.
