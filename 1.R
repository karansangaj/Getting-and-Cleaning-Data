# Install and Load Packages
install.packages("data.table")
install.packages("reshape2")
library("data.table")
library("reshape2")

# Getting the Data
path <- getwd()
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")

# Loading Activity Labels and Features
ActivityLabels = fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
Features = fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
FeaturesWanted = grep("(mean|std)\\(\\)", Features[, featureNames])
measurements = Features[FeaturesWanted, featureNames]
measurements = gsub('[()]', '', measurements)

# Train Datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, FeaturesWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Test Datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, FeaturesWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# Merge Train and Test datasets
combined <- rbind(train, test)

# classLabels to activityName.
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = ActivityLabels[["classLabels"]]
                                 , labels = ActivityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

#Get TidyData
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
