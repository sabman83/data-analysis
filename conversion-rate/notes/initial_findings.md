*On Summarizing*

- Only 4 countries (China, Germnay, UK and US)
- Mean age of 30.57, range from 17 - 123, 123 seems strange, maybe an error?
- Mean session of 4.8 pages
- Percentage of new users  = 68.55
- Percentage of converted users = 3.225 ==  # conversion rate ?
- No NA or omitted data

- plotting age vs converted doesn't seem to imply anything
-  there seems to be 2 outliers
- no one from china converted
- All those who visit more than 20 definitely convert
- Ages 61 and over don't convert
- Sources doesn't seem to play a pivotal role
- Amongst the converted users most are not new users
- Fewer converted users are from China



?-  So we need to predict conversion rate. Isn't it enough to predict a conversion?

*Questions*
 - Which source should we use to target our users?
 - Which age group should we target?
 - If new users dont convert , is it worth going after them?
 - Target users who have already created an account
 - Does country matter, which country should we spend less money on
 - If user has visited less than a number of pages then add more enticing pages? Or if has visited more then ignore user?


#Analysis

##Logistic Regression

- Except for SEO all other columns show significance. 
- The error on the training data (all of the data) is 1.381404 % which is slightly better then the null classifier of 3.225%
 - With validation error rate on test data is 1.386161%. About the same.
 - With 10 K fold and prob > 0.7, test error rate is .8854895 %
 - Feature Selection
  -- Lasso gives non-zero coefficients for new_user1 and total_pages_visited

##Random Forests
- Total pages visited is most important
- Error rate is slightly worse at 1.46%
- Total pages visted is most important. Since it is dominating so much we can ignore it and look at other variables. Also, people browse many pages because they already want to buy. 
- on Redoing it with total pages removed, and giving class weight of 0.7, 03 , we get new_users as most important and source as least, error rate went up by 14 % but we are trying to get insights into important factors
- Parital dependence plots say that, users from China have perform poorly on conversion rate while Germany does best. Old users have a better chance at converting. Users younger than 30 and older than 60 have a better chance of converting, source has no effect.
- Plottig simple tree confirms above hypothesis on age and countries


*Recommendations*

- Maybe if the probability of 0.3 is enough because the conversion rate is so low, that we can take more chances and try to target more users with a decent chance.
