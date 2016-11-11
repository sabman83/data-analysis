#remove outliers
conversion_rate_table <- data.table(filter(conversion_rate_table, age < 80))


glm.fit <- glm(converted~.,data = conversion_rate_table, family = binomial)
summary(glm.fit)
glm.probs = predict(glm.fit, type="response")
glm.pred = rep(0, nrow(conversion_rate_table))
glm.pred[glm.probs>0.5] = 1
table(glm.pred,conversion_rate_table$converted)
mean(glm.pred == conversion_rate_table$converted) #0.013811

#validation set
test <- sample(nrow(conversion_rate_table),nrow(conversion_rate_table)/3)
glm.train.fit <- glm(converted ~ ., data = conversion_rate_table, subset = -test, family = binomial)
summary(glm.train.fit)
glm.test.probs <- predict(glm.train.fit, newdata = conversion_rate_table[test,], type = "response")
glm.test.pred <- rep(0, length(test))
glm.test.pred[glm.test.probs > 0.5] = 1
mean(glm.test.pred != conversion_rate_table[test]$converted) #0.01386161

#k-fold cross validation
set.seed(17)
cv.error.10=rep(0,10)
cost <- function(r, pi = 0) mean(abs(r-pi) > 0.7)

for (i in 1:10) {
  cv.error.10[i] = cv.glm(conversion_rate_table,glm.fit, cost = cost, K=10)
}


#Ridge and Lasso Regression

lasso.model <- glmnet(x[-test,], y[-test], family = "binomial", alpha = 1, lambda = grid)
set.seed(1)
cv.lasso.model = cv.glmnet(x[-test,], y[-test], family = "binomial", type.measure = "class", alpha = 1)
lasso.bestlam <- cv.lasso.model$lambda.min
lasso.prob <- predict(lasso.model, newx = x[test,], s = lasso.bestlam, type="response")
lasso.pred <- rep(0, length(test))
lasso.pred[lasso.prob > 0.4] <- 1
1 - mean(lasso.pred == y[test]) #0.01647074

lasso.coef <- predict(lasso.model, s = lasso.bestlam, type="coefficients")
lasso.coef

