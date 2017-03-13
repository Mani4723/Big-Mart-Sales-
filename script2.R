####  Data exploration and preparation 

## Univariable identification
str(train$Item_Identifier)
## Item id is a very important variable. It helps in finding missing values in item weight.
barplot(table(train$Item_Identifier))

## if required strip id variable into new variables. 

id = train[train$Item_Identifier == "DRA12", ]
id1 = train[train$Item_Identifier == "DRA24", ]
id2 = train[train$Item_Identifier == "DRB13", ]
id3 = train[train$Item_Identifier == "DRC01", ]
id4 = train[train$Item_Identifier == "DRD01", ]
id5 = train[train$Item_Identifier == "DRE12", ]
id6 = train[train$Item_Identifier == "FDA10", ]
id7 = train[train$Item_Identifier == "FDB02", ]
id8 = train[train$Item_Identifier == "FDD48", ]
id9 = train[train$Item_Identifier == "NCA05", ]
id10 = train[train$Item_Identifier == "NCB43", ]
id11 = train[train$Item_Identifier == "NCF18", ]

id = rbind(id, id1, id2, id3, id4, id5, id6, id7, id8, id9, id10, id11)
rm(id1, id2, id3, id4, id5, id6, id7, id8, id9, id10, id11)

## variable 2- Item weight - continous variable, numeric data type
str(train$Item_Weight)
summary(train$Item_Weight)
# histogram 
hist(train$Item_Weight, main = "Item-Weight plot", col = "blue", 
     xlab = "weight", ylab = "freq", freq = FALSE)
h = hist(train$Item_Weight)
text(h$mids, h$counts, labels = h$counts, adj = c(0.5, -0.5))

# boxplots to check the outliers
boxplot(train$Item_Weight, horizontal = TRUE, notch = TRUE,
        ylab = "Item_weight", xlab = "Weight", col = "blue", border = "brown")
b = boxplot(train$Item_Weight)
# so from boxplot we can see there are no outliers. This is pretty much nice.
## Filling missing values.
weight_model = randomForest(Weight$Item_Weight ~ Weight$Item_Identifier, data = Weight, na.rm = TRUE)
pred1 = predict(weight_model, newdata = Weight)
Weight = cbind(Weight, pred1)

## variable 3 : Fat content
train$Fat_content = ifelse(train$Item_Fat_Content == "reg" | train$Item_Fat_Content == "Regular", "R", "L")
train$Fat_content = as.factor(train$Fat_content)

test$Fat_content = ifelse(test$Item_Fat_Content == "reg" | test$Item_Fat_Content == "Regular", "R", "L")
test$Fat_content = as.factor(test$Fat_content)

train$Item_Fat_Content = NULL
test$Item_Fat_Content = NULL

barplot(table(train$Fat_content), col = c("lightblue", "green"), 
        legend.text = c("Low", "Regular"), ylab = "numberof items", 
        main = "Barplot of Fat content", names.arg = c("L", "R"))
barplot(table(test$Fat_content), col = c("lightblue", "green"), legend.text = c("Low", "Regular"), 
              ylab= "Number of items", names.arg = c("L", "R"))

barplot(table, legend.text = c("Train", "Test"), col = c("blue", "green"))

## variable 4 : Item_visibility
# from histogram it can be seen that data is higly skewed.
boxplot(train$Item_Visibility, test$Item_Visibility, notch = TRUE, col = c("lightblue", "green"),
        horizontal = TRUE, xlab = "% Visibilty", main = "Item_Visibility",
        names = c("train", "test"))

## treat the outliers and skewed distribution.

## variable 5 : item_type
barplot(table(train$Item_Type), col = "lightblue", density = 10,
        horiz = TRUE)

## item mrp 
hist(train$Item_MRP, xlab = "mrp", main = "Item_MRP", col = "green")
boxplot(train$Item_MRP, test$Item_MRP, horizontal = TRUE, main = "Boxplot of MRP", 
        xlab = "MRP", names = c("train", "test"), col = c("lightblue", "green"))

## No outliers and No skewness in the distribution. Just the scale might be different.

## Outlet_identifier
##outlet_establishment year - this can be converted into number of years of establishment.
train$years_of_estd = 2013 - train$Outlet_Establishment_Year
test$years_of_estd = 2013 - test$Outlet_Establishment_Year
## remove the outlet establishment year vaiable
## Outlet_size - missing values are present.
##Outlet_Location_type 

table_item_type = sort(table(train$Item_Type), decreasing = TRUE)
prop_item_type = prop.table(table_item_type)
precentage = prop_item_type * 100

boxplot(train$Item_Outlet_Sales ~ train$Item_Type, boxwex = 0.5, outpch = 16)

boxplot(train$Item_Outlet_Sales ~ train$Outlet_Identifier, boxwex = 0.5, outpch = 16)

means = aggregate(train$Item_Outlet_Sales ~ train$Outlet_Location_Type, FUN = mean)



















