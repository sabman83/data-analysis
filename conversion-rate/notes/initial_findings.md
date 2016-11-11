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


*Analysis*

**Logistic Regression**

- Except for SEO all other columns show significance. 
- The error on the training data (all of the data) is 1.381404 % which is slightly better then the null classifier of 3.225%


*Recommendations*
