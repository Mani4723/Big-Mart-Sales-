## Bivariant Analysis

# iD fills the missing values of weight
# visibility has negative relationship with sales
#visibility variable can be converted using exponential function.

## Missing values Treatment
class_model = rpart(Item_Weight ~ Item_Identifier, 
                    data = missing_data[!is.na(missing_data$Item_Weight), ]
                    )
class_pred = predict(class_model, 
                     newdata = missing_data)
missing_data$Item_Weightnew = ifelse(is.na(missing_data$Item_Weight), 
                                  missing_data$pred, missing_data$Item_Weight)

## Test set missing values treatment.
test$Item_Weight[is.na(test$Item_Weight)] = test$Item_Weight[match(test$Item_Identifier, test$Item_Identifier)][which(is.na(test$Item_Weight))]

class_model2 = rpart(Item_Weight ~ Item_Identifier, data = test[!is.na(test$Item_Weight), ])
test$class_pred2 = predict(class_model2, newdata = test)
test$Item_Weightnew = ifelse(is.na(test$Item_Weight), 
                             test$class_pred2, test$Item_Weight)
test$Item_Weight = test$Item_Weightnew
test$Item_Weightnew = NULL
test$class_pred2 = NULL


# Filling the missing values in outlet
train$Outlet_Size = ifelse(train$Outlet_Size == "", 4, train$Outlet_Size)
train$Outlet_Size = as.factor(train$Outlet_Size)
train$Outlet_Size = ifelse(train$Outlet_Size == 2, "High", ifelse(train$Outlet_Size == 3, "Medium", ifelse(train$Outlet_Size==4, "small", train$Outlet_Size)))
train$Outlet_Size = as.factor(train$Outlet_Size)

test$Outlet_Size = ifelse(test$Outlet_Size=="", NA, test$Outlet_Size)
test$Outlet_Size = as.factor(test$Outlet_Size)
test$Outlet_Size = ifelse(test$Outlet_Size == 2, "High", ifelse(test$Outlet_Size == 3, "Medium", ifelse(test$Outlet_Size==4, "small", test$Outlet_Size)))



