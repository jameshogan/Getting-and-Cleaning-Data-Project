# ##### Run_Analysis.R

# This R script does the following:
# 1. Merges the training and the test sets to create one data set.
library(data.table)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(url, destfile = "Dataset.zip", method = "curl")
unzip("Dataset.zip")

### set wd
setwd("~/Desktop/Coursera/UCI HAR Dataset")
##### read in files
trainX <- read.table("train/X_train.txt", header= FALSE)
testX <- read.table("test/X_test.txt", header= FALSE)
trainSubj <- read.table("train/subject_train.txt", header= FALSE)
testSubj <- read.table("test/subject_test.txt", header= FALSE)
trainY <- read.table("train/y_train.txt", header= FALSE)
testY <- read.table("test/y_test.txt", header= FALSE)
#### Merge #
mergedX <- rbind(trainX, testX)
mergedY <- rbind(trainY, testY)
mergedSubj <- rbind(trainSubj, testSubj)
merged <- list(X = mergedX, Y= mergedY, Subject = mergedSubj)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table("features.txt")
feature.index <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
merged$X <- merged$X[, feature.index]
names(merged$X) <- features[feature.index, 2]
names(merged$X) <- gsub("\\(|\\)", "", names(merged$X))
names(merged$X) <- tolower(names(merged$X))  # see last slide of the lecture Editing Text Variables (week 4)

# 3. Uses descriptive activity names to name the activities in the data set
activity <- read.table("activity_labels.txt")
activity[, 2] = gsub("_", "", tolower(as.character(activity[, 2])))
merged$Y[,1] = activity[merged$Y[,1], 2]
names(merged$Y) <- "activity"

# 4. Appropriately labels the data set with descriptive activity names.
names(merged$Subject) <- "subject"
cleaned <- cbind(merged$Subject, merged$Y, merged$X)
write.table(cleaned, "clean_merged_data.txt")

# 5. Creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject.
uniqueSubj <- unique(mergedSubj)[,1]
numSubj = length(unique(mergedSubj)[,1])
numActivity = length(activity[,1])
numCols = dim(cleaned)[2]
tidy <- cleaned[1:(numSubj*numActivity), ]

row <- 1
for (s in 1:numSubj) {
    for (a in 1:numActivity) {
        tidy[row, 1] = uniqueSubj[s]
        tidy[row, 2] = activity[a, 2]
        temp <- cleaned[cleaned$subject==s & cleaned$activity==activity[a, 2], ]
        tidy[row, 3:numCols] <- colMeans(temp[, 3:numCols])
        row = row+1
    }
}

write.table(tidy, "averaged_tidy.txt")
