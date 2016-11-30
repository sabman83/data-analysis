---
layout: post
title: Conversion Rate
tags: [random-forests, logistic-regression]
---

## Challenge Description

We have data about users who hit our site: whether they converted or not as well as some of their characteristics such as their country, the marketing channel, their age, whether they are repeat users and the number of pages visited during that session (as a proxy for site activity/time spent on site).

**Goals:**
Predict conversion rate
Come up with recommendations for the product team and the marketing team to improve conversion rate

## Data
The data is available [here](https://github.com/sabman83/data-analysis/raw/gh-pages/conversion-rate/data/conversion_data.csv){:target="_blank"}.

Columns:

* _country_ : user country based on the IP address
* _age_ : user age. Self-reported at sign-in step
* _new\_user_ : whether the user created the account during this session or had already an account and simply came back to the site
* _source_ : marketing channel source
  * _Ads_: came to the site by clicking on an advertisement
  * _Seo_: came to the site by clicking on search results
  * _Direct_: came to the site by directly typing the URL on the browser
* _total\_pages\_visited_: number of total pages visited during the session. This is a proxy for time spent on site and engagement during the session.
* _converted_: this is our label. 1 means they converted within the session, 0 means they left without buying anything. The company goal is to increase conversion rate: # conversions / total sessions.

## Exploring the data

I import the data from the csv file and store it in a data table. Besides the performance benefits, I also like data.table for its cleaner syntax especially when it comes to using the filters. I also convert the new_user and converted columns from numeric to factor.

~~~ r
conversion_rate_data <- read.csv("data/conversion_data.csv")
conversion_rate_table <- data.table(conversion_rate_data)
conversion_rate_table$new_user <- as.factor(conversion_rate_table$new_user)
conversion_rate_table$converted <- as.factor(conversion_rate_table$converted)

summary(conversion_rate_table)
~~~

|    country     |       age       |  new_user |     source     |  total_pages_visited| converted|
| China  : 76602 |  Min.   : 17.00 |  0: 99456 |  Ads   : 88740 |  Min.   : 1.000     | 0:306000 |
| Germany: 13056 |  1st Qu.: 24.00 |  1:216744 |  Direct: 72420 |  1st Qu.: 2.000     | 1: 10200 |
| UK     : 48450 |  Median : 30.00 |           |  Seo   :155040 |  Median : 4.000     |          |
| US     :178092 |  Mean   : 30.57 |           |                |  Mean   : 4.873     |          |
|                |  3rd Qu.: 36.00 |           |                |  3rd Qu.: 7.000     |          |
|                |  Max.   :123.00 |           |                |  Max.   :29.000     |          |


**Notes from summary**

* I notice that age has a maximum value of 123, This suggests that there might be some errors in the data.
* There no NA values, so we don't have to deal with empty values.
* The percentage of converted users  = (10200 / nrow(conversion_rate_table)) * 100 = 3.22%. So for a null classifier that predicts all users as non-converters, the error rate would be 3.22%.

I will now plot some visualizations to get a sense of the data and it's distribution.


**Total Pages Visited vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = total_pages_visited))
  + geom_point(aes(color = factor(converted)))
  + geom_vline(xintercept = 61, color = "black")
  + labs(x="Age", y = "Total Pages Visited", color="Converted (1 = True)")
  + ggtitle("Total Pages Visited vs Age") + theme(plot.title = element_text(face = "bold"))
~~~

![Total Pages Visted vs Age](/data-analysis/assets/pages-visited-vs-age.png)

There are two outliers having an age of over 100. We can safely assume that this is incorrect data and ignore them. Also, I notice that beyond a certain age all the users converted. This age threshold is marked by the vertical line at 61.
Users who have visited 20 or more pages also defintely converted.

**Source vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = source))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Source", color="Converted (1 = True)")
  + ggtitle("Source vs Age")
  + theme(plot.title = element_text(face = "bold"))
~~~

![Source vs Age](/data-analysis/assets/source-vs-age.png)

There doesn't seem to be any correlation between source and age and nor does source seem to have any affect on conversion. But we will confirm this using regression later.

**Country vs Age**

~~~ r
ggplot(conversion_rate_table, aes(x = age, y = country))
  + geom_point(aes(color = factor(converted)))
  + labs(x="Age", y = "Country", color="Converted (1 = True)")
  + ggtitle("Country vs Age")
  + theme(plot.title = element_text(face = "bold"))
~~~

![Country vs Age](/data-analysis/assets/country-vs-age.png)

Again, country doesn't seem to have any correlation with age. China has very few converted users.


**Histogram of Age**

~~~ r
qplot(conversion_rate_table$age, geom = "histogram",
      binwidth=.5, bins=20,
      col=I("red"), fill=I("red"), alpha = I(.5),
      xlim = c(10,80), breaks=seq(10,80, by = 5)
      xlab = "Age", ylab = "Count", main = "Histogram of Age")
~~~

![Histogram of Age](/data-analysis/assets/histogram-of-age.png)

Majority of the users are between the age group of 20 to 40.


## Analyzing the data

Before analyzing the data, I remove the outliers.

~~~ r
conversion_rate_table <- data.table(filter(conversion_rate_table, age < 80))
~~~

**Logistic Regression**

The goal is to improve the conversion rate and predict if an user will convert. This is a case of binary classification so I opt for logistic regression. I will also generate decision trees since it might help in presenting a clearer analysis for the marketing team.

I use the glm package to generate a logistic regression model.

~~~ r
> glm.model <- glm(converted~.,data = conversion_rate_table, family = binomial)
> summary(glm.model)

Call:
glm(formula = converted ~ ., family = binomial, data = conversion_rate_table)

Deviance Residuals:
    Min       1Q   Median       3Q      Max
-3.1414  -0.0630  -0.0242  -0.0097   4.4249

Coefficients:
                      Estimate Std. Error z value Pr(>|z|)
(Intercept)         -10.341034   0.150389 -68.762  < 2e-16 ***
countryGermany        3.815818   0.132113  28.883  < 2e-16 ***
countryUK             3.609985   0.120238  30.024  < 2e-16 ***
countryUS             3.246895   0.116598  27.847  < 2e-16 ***
age                  -0.074071   0.002375 -31.191  < 2e-16 ***
new_user1            -1.739047   0.035581 -48.876  < 2e-16 ***
sourceDirect         -0.185901   0.048709  -3.817 0.000135 ***
sourceSeo            -0.023825   0.039838  -0.598 0.549811
total_pages_visited   0.758377   0.006212 122.092  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 90107  on 316197  degrees of freedom
Residual deviance: 25682  on 316189  degrees of freedom
AIC: 25700

Number of Fisher Scoring iterations: 10
~~~

The summary suggests that all the columns (note that for factor columns like source and country, each value is used as a dummy column) except for source=SEO are statistically significant.
I will now generate the confusion matrix and calculate the error rate.

~~~ r
> glm.probs = predict(glm.model, type="response")
> glm.pred = rep(0, nrow(conversion_rate_table))
> glm.pred[glm.probs>0.5] = 1
> table(glm.pred,conversion_rate_table$converted)

glm.pred      0      1
       0 304802   3169
       1   1198   7029
> 1- mean(glm.pred == conversion_rate_table$converted)
[1] 0.01381097
~~~

We get an error rate of 1.38% which is an improvement over the null classifier. (_Note:_ I have used 0.5 as the probability threshold to predict the class. Ideally, I would generate a ROC curve to generate an optimal threshold. For my work on using the ROC, check these posts.)

To validate this error rate, I will re-generate the model using a validation set (by using 2/3 of the data for traning the model and the rest to test it) and also using a 10-fold cross validation.

~~~ r
> #validate set
> set.seed(17)
> train <- sample(nrow(conversion_rate_table), 2 * (nrow(conversion_rate_table)/3))
> glm.train.model <- glm(converted ~ ., data = conversion_rate_table, subset = train, family = binomial)
> summary(glm.train.model)

Call:
glm(formula = converted ~ ., family = binomial, data = conversion_rate_table,
    subset = train)

Deviance Residuals:
    Min       1Q   Median       3Q      Max
-3.0825  -0.0632  -0.0240  -0.0095   4.2963

Coefficients:
                      Estimate Std. Error z value Pr(>|z|)
(Intercept)         -10.516418   0.192440 -54.648  < 2e-16 ***
countryGermany        4.038278   0.169911  23.767  < 2e-16 ***
countryUK             3.777663   0.156535  24.133  < 2e-16 ***
countryUS             3.432308   0.152176  22.555  < 2e-16 ***
age                  -0.072912   0.002917 -24.992  < 2e-16 ***
new_user1            -1.779272   0.043814 -40.610  < 2e-16 ***
sourceDirect         -0.190677   0.059759  -3.191  0.00142 **
sourceSeo            -0.027105   0.048757  -0.556  0.57826
total_pages_visited   0.758277   0.007619  99.526  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 60094  on 210797  degrees of freedom
Residual deviance: 17064  on 210789  degrees of freedom
AIC: 17082

Number of Fisher Scoring iterations: 10

> glm.test.probs <- predict(glm.train.model, newdata = conversion_rate_table[-train,], type = "response")
> glm.test.pred <- rep(0, length(glm.test.probs))
> glm.test.pred[glm.test.probs > 0.5] = 1
> mean(glm.test.pred != conversion_rate_table[-train]$converted)
[1] 0.01358634
~~~

The error rate is slightly better when using a validation set.

~~~ r
> set.seed(17)
> cv.error.10=rep(0,10)
> cost <- function(r, pi = 0) mean(abs(r-pi) > 0.5)
>
> for (i in 1:10) {
+     cv.error.10[i] = cv.glm(conversion_rate_table,glm.model, cost = cost, K=10)$delta[1]
+ }
> cv.error.10
 [1] 0.01382362 0.01382678 0.01381097 0.01382362 0.01380148 0.01381729 0.01382045 0.01382362 0.01382994
[10] 0.01382362
~~~

Again, the error is about the same at 1.38%.

We now perform feature selection by performing lasso regression on the logisitic model and identify variables with non-zero coefficients.


~~~ r
> grid=10^seq(10,-2,length=100)
> x=model.matrix(conversion_rate_table$converted~., conversion_rate_table)[,-1]
> y=conversion_rate_table$converted
> lasso.model <- glmnet(x[train,], y[train], family = "binomial", alpha = 1, lambda = grid)
> cv.lasso.model = cv.glmnet(x[train,], y[train], family = "binomial", type.measure = "class", alpha = 1)
> lasso.bestlam <- cv.lasso.model$lambda.min
> lasso.prob <- predict(lasso.model, newx = x[-train,], s = lasso.bestlam, type="response")
> lasso.pred <- rep(0, length(lasso.prob))
> lasso.pred[lasso.prob > 0.5] <- 1
> 1 - mean(lasso.pred == y[-train]) #0.01647074
[1] 0.01778937
>
> lasso.coef <- predict(lasso.model, s = lasso.bestlam, type="coefficients")
> lasso.coef
9 x 1 sparse Matrix of class "dgCMatrix"
                             1
(Intercept)         -7.5612220
countryGermany       .
countryUK            .
countryUS            .
age                  .
new_user1           -0.4607149
sourceDirect         .
sourceSeo            .
total_pages_visited  0.5372514
~~~

The error is slight worse over our previous models but the model now only has 2 predictor variables! (_new\_user_ and _total\_pages\_visited_)

The negative coefficient for _new\_user1_ (1 indicating the dummy column for _new\_user_=1) suggests that new users are less likely to convert. Also, the user is more likely to convert if he/she has visited more pages.



