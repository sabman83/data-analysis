#remove outliers
conversion_rate_table <- data.table(filter(conversion_rate_table, age < 80))


glm.model <- glm(converted~.,data = conversion_rate_table, family = binomial)
summary(glm.fit)
glm.probs = predict(glm.model, type="response")
glm.pred = rep(0, nrow(conversion_rate_table))
glm.pred[glm.probs>0.5] = 1
table(glm.pred,conversion_rate_table$converted)
1 - mean(glm.pred == conversion_rate_table$converted) #0.013811

#validation set
set.seed(17)
train <- sample(nrow(conversion_rate_table), 2 * (nrow(conversion_rate_table)/3))
glm.train.model <- glm(converted ~ ., data = conversion_rate_table, subset = train, family = binomial)
summary(glm.train.model)
glm.test.probs <- predict(glm.train.model, newdata = conversion_rate_table[-train,], type = "response")
glm.test.pred <- rep(0, length(-train))
glm.test.pred[glm.test.probs > 0.5] = 1
mean(glm.test.pred != conversion_rate_table[-train]$converted) #0.01386161

#k-fold cross validation
cv.error.10=rep(0,10)
cost <- function(r, pi = 0) mean(abs(r-pi) > 0.5)

for (i in 1:10) {
  cv.error.10[i] = cv.glm(conversion_rate_table,glm.model, cost = cost, K=10)$delta[1]
}

cv.error.10

#Ridge and Lasso Regression

set.seed(17)
grid=10^seq(10,-2,length=100)
x=model.matrix(conversion_rate_table$converted~., conversion_rate_table)[,-1]
y=conversion_rate_table$converted
lasso.model <- glmnet(x[train,], y[train], family = "binomial", alpha = 1, lambda = grid)
cv.lasso.model = cv.glmnet(x[train,], y[train], family = "binomial", type.measure = "class", alpha = 1)
lasso.bestlam <- cv.lasso.model$lambda.min
lasso.prob <- predict(lasso.model, newx = x[-train,], s = lasso.bestlam, type="response")
lasso.pred <- rep(0, length(lasso.prob))
lasso.pred[lasso.prob > 0.5] <- 1
1 - mean(lasso.pred == y[-train]) #0.01647074

lasso.coef <- predict(lasso.model, s = lasso.bestlam, type="coefficients")
lasso.coef

