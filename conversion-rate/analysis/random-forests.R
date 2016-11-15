#Random Forests for feature selections
set.seed(12)
train <- sample(nrow(conversion_rate_table), 2 * (nrow(conversion_rate_table)/3))

rf.model <- randomForest(y=conversion_rate_table[train,]$converted,
                           x=conversion_rate_table[train,1:5, with=FALSE,],
                           ytest = conversion_rate_table[-train,]$converted, 
                           xtest = conversion_rate_table[-train,1:5, with=FALSE],
                           ntree=100, mtry=3, importance = TRUE, keep.forest = TRUE)
