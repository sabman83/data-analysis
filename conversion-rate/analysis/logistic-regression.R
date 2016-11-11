glm.fit <- glm(converted~.,data = conversion_rate_table, family = binomial)
summary(glm.fit)
glm.probs = predict(glm.fit, type="response")
glm.pred = rep(0, nrow(conversion_rate_table))
glm.pred[glm.probs>0.5] = 1
table(glm.pred,conversion_rate_table$converted)
mean(glm.pred == conversion_rate_table$converted) #0.01381404

#validation set
test <- sample(nrow(conversion_rate_table),nrow(conversion_rate_table)/3)
glm.train.fit <- glm(converted ~ ., data = conversion_rate_table, subset = -test, family = binomial)
summary(glm.train.fit)
glm.test.probs <- predict(glm.train.fit, newdata = conversion_rate_table[test,], type = "response")
glm.test.pred <- rep(0, nrow(test.data))
glm.test.pred[glm.test.probs > 0.5] = 1
mean(glm.test.pred != conversion_rate_table[test]$converted) #0.01339658


