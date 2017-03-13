## First linear Regression model 1
library(ggplot2)
library(ggbiplot)
library(gridExtra)
library(plyr)
library(dplyr)
library(caret)
library(mice)
library(VIM)


fulldata = rbind(train, test)

levels(fulldata$Fat_content) = c(levels(fulldata$Fat_content), "N")
fulldata[which(fulldata$Item_Type == "Health and Hygiene"), ]$Fat_content = "N"
fulldata[which(fulldata$Item_Type == "Household"), ]$Fat_content = "N"
fulldata[which(fulldata$Item_Type == "Others"), ]$Fat_content = "N"


ggplot(fulldata, aes(Item_Type, Item_Weight))+
geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) +
  xlab("Item Type") + ylab("Item_Weight") + ggtitle("Weight Vs type")

ggplot(fulldata, aes(Outlet_Identifier, Item_Weight)) + geom_boxplot() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, color = "black")) + 
  labs(title = "Weight Vs outlet", x = "Outlet", y = "Weight")

# assuming that each item identifier actually identifies a unique item,
# hence a unique weight, let's create a dataframe containing the mean
# weights by item identifier
weights = as.data.frame(tapply(combi$Item_Weight[!is.na(combi$Item_Weight)], 
                               combi$Item_Identifier[!is.na(combi$Item_Weight)], 
                               mean))
weights$ID = row.names(weights)
weights$weight = weights$`tapply(combi$Item_Weight[!is.na(combi$Item_Weight)], combi$Item_Identifier[!is.na(combi$Item_Weight)], `

# we can now use these values to fill in the missing weight values:
combi$Item_Weight = ifelse(is.na(combi$Item_Weight), 
                           weights$weight[match(combi$Item_Identifier, weights$ID)], combi$Item_Weight)


## checking the Item_mrp distributions
ggplot(combi, aes(x=Item_MRP)) + 
  geom_density(color = "blue", adjust=1/5) +
  geom_vline(xintercept = 69, color="red")+
  geom_vline(xintercept = 136, color="red")+
  geom_vline(xintercept = 203, color="red") + 
  ggtitle("Density of Item MRP")

ggplot(fulldata, aes(x = Item_MRP)) + 
  geom_density(color = "green", adjust = 1/5) +
  geom_vline(xintercept = 69, color = "blue")+
  geom_vline(xintercept = 136, color = "blue")+
  geom_vline(xintercept = 203, color = "blue")+
  ggtitle("Density of Item MRP") + xlab("Item_MRP")

## as we can see the 4 groups of MRP's
fulldata$Item_MRP_level = as.factor(
  ifelse(fulldata$Item_MRP < 69, "Low",
         ifelse(fulldata$Item_MRP < 136, "Medium", 
                ifelse(fulldata$Item_MRP < 203, "High", "V.High"))))

## sales vs outlet identifier
ggplot(combi[1:nrow(train),], aes(Outlet_Identifier, Item_Outlet_Sales)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Outlet identifier") + 
  ylab("Sales") + 
  ggtitle("Sales vs Outlet identifier")

ggplot(combi[1:nrow(train),], aes(x = Outlet_Type, y = Item_Outlet_Sales, fill = year)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Outlet Type") + 
  ylab("Sales") + 
  ggtitle("Sales vs Outlet Type")

ggplot(combi[1:nrow(train),], aes(x = Outlet_Type, y = Item_Outlet_Sales, fill = Outlet_Size)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Outlet Type") + 
  ylab("Sales") + 
  ggtitle("Sales vs Outlet Type")

ggplot(fulldata[1:nrow(train), ], aes(x = Item_Type, y = Item_Outlet_Sales, fill = Outlet_Size)) +
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Item Type") +
  ylab("Sales") +
  ggtitle("Sales Vs Item Type")
  
ggplot(fulldata[1:nrow(train), ], aes(x = years_of_estd, y = Item_Outlet_Sales, fill = Outlet_Type)) +
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Item Type") +
  ylab("Sales") +
  ggtitle("Sales Vs Item Type")

# boxplot of Visibility vs Item type
ggplot(fulldata, aes(x = Item_Type, y = Item_Visibility)) +
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "red")) + 
  xlab("Item Type") + 
  ylab("Visibility") + ggtitle("Visibility Vs Type")

ggplot(fulldata, aes(x = Outlet_Identifier, y = Item_Visibility, fill = Outlet_Type)) + 
  geom_boxplot()+
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black")) +
  xlab("Outlet") + ylab("Visibility") +
  ggtitle("Visibility vs Outlet")

## keeping a copy of nonzero visibility set
combi_nonZeroVis = subset(combi, combi$Item_Visibility > 0)

## replace 0 by NA so that mice can work its magic
outletIdentifiers <- levels(combi$Outlet_Identifier)
itemTypes <- levels(combi$Item_Type)
for (outName in outletIdentifiers) {
  for (itemName in itemTypes) {
    combi[ which(combi$Outlet_Identifier == outName &
                   combi$Item_Type == itemName),]$Item_Visibility <-
      ifelse(
        combi[ which(combi$Outlet_Identifier == outName &
                       combi$Item_Type == itemName), ]$Item_Visibility == 0 ,
        NA ,
        combi[ which(combi$Outlet_Identifier == outName &
                       combi$Item_Type == itemName),]$Item_Visibility
      )
  }
}

## checking the missing value patterns
md.pattern(combi)
aggr_plot <- aggr(combi, col=c('navyblue','red'), 
                                     numbers=TRUE, 
                                     sortVars=TRUE, 
                                     labels=names(combi), 
                                     cex.axis=.7, 
                                     gap=3, 
                                     ylab=c("Histogram of missing data","Pattern"))
                   
marginplot(combi)

# mice imputining the missing values
newCombi = mice(combiNA, m = 1, maxit = 1, meth="pmm", seed=0)




## Creating New vaiables
fulldata$Item_ID_Class = substring(fulldata$Item_Identifier, 1, 2)
fulldata$Item_ID_Class = as.factor(fulldata$Item_ID_Class)

# More information can be obtained from first three letters of ID.
fulldata$Item_ID_class_type = substring(fulldata$Item_Identifier, 1, 3)
fulldata$Item_ID_class_type = as.factor(fulldata$Item_ID_class_type)

# looking at correlations in numeric variable
corMatrix <- cor(fulldata[1:nrow(train),][sapply(fulldata[1:nrow(train),], is.numeric)])
corMatrix


## Filling missing values by mean matching manually
VisByItem1 <- as.data.frame( ddply(na.omit(combi),  
                                      ~Item_Identifier + Outlet_Type, 
                                      summarise, 
                                      mean=mean(Item_Visibility), 
                                      sd=sd(Item_Visibility)))
VisByItem1$sd = NULL
combiNA = subset(combi, select = c("Item_Identifier", "Outlet_Type", "Item_Visibility"))
combiNA$ID = 1:14204
combi_merged = merge(combiNA, VisByItem1, all = TRUE)
combi_merged = combi_merged[order(combi_merged$ID), ]
combi_merged$Item_Visibility = ifelse(is.na(combi_merged$Item_Visibility), 
                                      combi_merged$mean, combi_merged$Item_Visibility)
combi$Item_Visibility = combi_merged$Item_Visibility
## Now filling the rest of missing values
VisByItem1 <- as.data.frame( ddply(na.omit(combi),  
                                   ~Item_Identifier,
                                   summarise, 
                                   mean=mean(Item_Visibility), 
                                   sd=sd(Item_Visibility)))
VisByItem1$sd = NULL
combiNA = subset(combi, select = c("Item_Identifier", "Item_Visibility"))
combiNA$ID = 1:14204
combi_merged = merge(combiNA, VisByItem1, all = TRUE)
combi_merged = combi_merged[order(combi_merged$ID), ]
combi_merged$Item_Visibility = ifelse(is.na(combi_merged$Item_Visibility), 
                                      combi_merged$mean, combi_merged$Item_Visibility)
combi$Item_Visibility = combi_merged$Item_Visibility

## checking the pattern before and after filling the missing values.
combi_org = subset(fulldata, fulldata$Item_Visibility > 0)
ggplot(combi_org, aes(x = "Item_Visibility")) + geom_density()


###  each outlet Visibility should be 100
shopvis = as.data.frame(setNames(
  aggregate(combi$Item_Visibility, 
            by = list(Category= combi$Outlet_Identifier), FUN = "sum"), 
  c("Outlet_Identifier", "TotalVis")))
shopvis

# Noramlize it to make 100 for all.
outletIdentifiers = levels(combi$Outlet_Identifier)

for (outletid in outletIdentifiers) {
  combi[which(combi$Outlet_Identifier==outletid), ]$Item_Visibility <- 
    100*combi[which(combi$Outlet_Identifier==outletid), ]$Item_Visibility/
    shopvis[which(shopvis$Outlet_Identifier==outletid), ]$TotalVis
} 

##  
ggplot() + geom_density(aes(x=combi$Item_Visibility), color = "green", data = combi)+ 
  geom_density(aes(x=combi_org$Item_Visibility), color="red", data=combi_org)

ggplot(combi_org[combi_org$Outlet_Type %in% "Grocery Store", ], 
       aes(Item_Visibility)) +
  geom_histogram(color="green", fill="green", bins = 20) + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black"))+
  xlim(0.0, 0.35)+
  xlab("Grocery store") + 
  ggtitle("Histogram of Visibilities of Grocery Store")

ggplot(combi[combi$Outlet_Type %in% "Grocery Store", ], 
       aes(Item_Visibility)) +
  geom_histogram(color="green", fill="green", bins = 20) + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black"))+
  xlim(0.0, 0.35)+
  xlab("Grocery store") + 
  ggtitle("Histogram of Visibilities of Grocery Store_completed")

ggplot(combi_org[combi_org$Outlet_Type %in% "Supermarket Type1", ], 
       aes(Item_Visibility)) +
  geom_histogram(color="green", fill="light blue", bins = 20) + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black"))+
  xlim(0.0, 0.35)+
  xlab("Supermarket Type1") + 
  ggtitle("Histogram of Visibilities of Supermarket Type1")

ggplot(combi[combi$Outlet_Type %in% "Supermarket Type1", ], 
       aes(Item_Visibility)) +
  geom_histogram(color="green", fill="light blue", bins = 20) + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black"))+
  xlim(0.0, 0.35)+
  xlab("Supermarket Type1") + 
  ggtitle("Histogram of Visibilities of Supermarket Type1")

ggplot(combi, aes(x = combi$Outlet_Identifier, y = combi$Item_Visibility)) + 
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 65, color = "black", vjust = 0.5)) + 
  xlab("Outlet") + 
  ylab("Visibility") +
  ggtitle("Visibility in Various Outlets")

ggplot(combi_org, aes(x = combi_org$Outlet_Identifier, y = combi_org$Item_Visibility)) + 
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 65, color = "black", vjust = 0.5)) + 
  xlab("Outlet") + 
  ylab("Visibility") +
  ggtitle("Visibility in Various Outlets")

ggplot(combi, aes(x = combi$Outlet_Type, y = combi$Item_Visibility)) + 
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 65, color = "black", vjust = 0.5)) + 
  xlab("Outlet") + 
  ylab("Visibility") +
  ggtitle("Visibility in Various Outlets")

ggplot(combi_org, aes(x = combi_org$Outlet_Type, y = combi_org$Item_Visibility)) + 
  geom_boxplot() + 
  theme(axis.text.x = element_text(angle = 65, color = "black", vjust = 0.5)) + 
  xlab("Outlet") + 
  ylab("Visibility") +
  ggtitle("Visibility in Various Outlets")

## 
# let's have a look at the numerical variables now

# correlation between numerical variables
corMatrix <- cor(combi[1:nrow(train),][sapply(combi[1:nrow(train),], is.numeric)])
corMatrix

# a brief overview of the correlation matrix
corrplot(corMatrix, method="number", type="upper")
corrplot(corMatrix, method="number", type="upper", order="hclust")

#
# Item_Outlet_Sales has a strong positive correlation with Item_MRP
# and a somewhat weaker negative one with Item_Visibility
# Time for a quick principal component analysis
#

subData <- as.data.frame(cbind(
  combi[1:nrow(train),]$Item_Visibility, 
  combi[1:nrow(train),]$Item_MRP, 
  combi[1:nrow(train),]$Item_Outlet_Sales))

names(subData) <- c("Item_Visibility",
                    "Item_MRP",
                    "Item_Outlet_Sales")

sub.groupby <- combi[1:nrow(train),]$Outlet_Type

str(subData)

subData.pca <- prcomp(subData,
                      center = TRUE,
                      scale. = TRUE) 

summary(subData.pca)

g <- ggbiplot(subData.pca, 
              obs.scale = 1, 
              var.scale = 1, 
              groups = sub.groupby, 
              ellipse = TRUE, 
              circle = TRUE
)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)

theta <- seq(0,2*pi,length.out = 100)
circle <- data.frame(x = cos(theta), y = sin(theta))
p <- ggplot(circle,aes(x,y)) + geom_path()

loadings <- data.frame(subData.pca$rotation, 
                       .names = row.names(subData.pca$rotation))
p + geom_text(data=loadings, 
              mapping=aes(x = PC1, y = PC2, label = .names, colour = .names)) +
  coord_fixed(ratio=1) +
  labs(x = "PC1", y = "PC2")

ggplot(combi[1:nrow(train),], aes(Item_Visibility, Item_Outlet_Sales)) +
  geom_point(size = 2.5, aes(colour = factor(Outlet_Type))) +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Item Visibility") + 
  ylab("Item Outlet Sales") +
  ggtitle("Item Sales vs Item Visibility")
 
ggplot(combi[1:nrow(train),], aes(Item_Visibility, Item_Outlet_Sales)) +
  geom_point(size = 2.5, aes(colour = factor(Outlet_Size))) +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Item Visibility") + 
  ylab("Item Outlet Sales") +
  ggtitle("Item Sales vs Item Visibility")

ggplot(combi[1:nrow(train),], aes(Item_Visibility, Item_Outlet_Sales)) +
  geom_point(size = 2.5, aes(colour = factor(Outlet_Identifier))) +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5, color = "black")) + 
  xlab("Item Visibility") + 
  ylab("Item Outlet Sales") +
  ggtitle("Item Sales vs Item Visibility")

ggplot(combi[1:nrow(train), ], aes(Item_Type, Item_Outlet_Sales, fill = Outlet_Type)) + 
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 65, vjust = 0.5, color = "black")) + 
  xlab("Item Type") +
  ylab("Sales") +
  ggtitle("Sales Vs Type")
  
## Dealing with outliers from Sales
combi$Item_Outlet_Sales = combi$Item_Outlet_Sales/combi$Item_MRP
fulldata$Item_Outlet_Sales = fulldata$Item_Outlet_Sales/fulldata$Item_MRP

train = fulldata[1:nrow(train), ]
test = fulldata[8524:14204, ]
test$Item_Outlet_Sales = NULL

set.seed(0)

# one-hot encoding of the factor variables
# leave out the intercept column
new_train <- read.csv("M:/bla bla/D.sci/data sets/Big mart sales/new_train.csv")
new_test <- read.csv("M:/bla bla/D.sci/data sets/Big mart sales/new_test.csv")
new_train$Outlet_Establishment_Year = as.factor(new_train$Outlet_Establishment_Year)
new_test$Outlet_Establishment_Year = as.factor(new_test$Outlet_Establishment_Year)

new_train <- as.data.frame(model.matrix( ~ . + 0, data = new_train))
new_test <- as.data.frame(model.matrix( ~ . + 0, data = new_test))



sales <- new_train$Item_Outlet_Sales
predictors <- subset(new_train, select=-c(Item_Outlet_Sales))




