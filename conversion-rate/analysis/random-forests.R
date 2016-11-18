#Random Forests for feature selections
set.seed(12)
train <- sample(nrow(conversion_rate_table), 2 * (nrow(conversion_rate_table)/3))

rf.model <- randomForest(y=conversion_rate_table[train,]$converted,
                           x=conversion_rate_table[train,1:5, with=FALSE,],
                           ytest = conversion_rate_table[-train,]$converted, 
                           xtest = conversion_rate_table[-train,1:5, with=FALSE],
                           ntree=100, mtry=3, importance = TRUE, keep.forest = TRUE)

varImpPlot(rf.model)


rf_model_2 <- randomForest(y=conversion_rate_table[train,]$converted,
                         x=conversion_rate_table[train,1:4, with=FALSE,],
                         ytest = conversion_rate_table[-train,]$converted, 
                         xtest = conversion_rate_table[-train,1:4, with=FALSE],
                         ntree=100, mtry=3, importance = TRUE, keep.forest = TRUE)
partialPlot(rf_model_2, conversion_rate_table[train,], country, 1)
partialPlot(rf_model_2, conversion_rate_table[train,], age, 1)
partialPlot(rf_model_2, conversion_rate_table[train,], new_user, 1)
partialPlot(rf_model_2, conversion_rate_table[train,], source, 1)


tree.model <- rpart(conversion_rate_table$converted~., data = conversion_rate_table[,1:4,with=FALSE], control = rpart.control(maxdepth = 3), parms = list(prior = c(0.7,0.3)))
plot(tree.model)
text(tree.model)

