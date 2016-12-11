##run_analysis.R
##Assignment: Getting and Cleaning Data Course Project
##By NORDIN RAMLI

library(reshape2)

filename <- "getdata_dataset.zip"

##Downloading/Unzipping Datasets
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

##Loading activity labels and features
ActivityLabel <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabel[,2] <- as.character(ActivityLabel[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

## Extract only the measurements data on mean and standard deviation
FeaturesWanted <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWanted.names <- Features[FeaturesWanted,2]
FeaturesWanted.names = gsub('-mean', 'Mean', FeaturesWanted.names)
FeaturesWanted.names = gsub('-std', 'Std', FeaturesWanted.names)
FeaturesWanted.names <- gsub('[-()]', '', FeaturesWanted.names)

## Loading the datasets
## Training Data
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWanted]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)
## Testing Data
Test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWanted]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

## Merging datasets of Train and Test
AllData <- rbind(Train, Test)
## Adding Labels
colnames(AllData) <- c("Subject", "Activity", FeaturesWanted.names)

## Turn Activities / Subjects into factors
AllData$Activity <- factor(AllData$Activity, levels = ActivityLabel[,1], labels = ActivityLabel[,2])
AllData$Subject <- as.factor(AllData$Subject)

AllData.melted <- melt(AllData, id = c("Subject", "Activity"))
AllData.mean <- dcast(AllData.melted, Subject + Activity ~ variable, mean)

## Create a tidy data set
write.table(AllData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
##-------------END--------------